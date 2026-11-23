*> The Nether's noise pipeline (docs/protocol/37-nether-2; T1635 to T1658): the legacy (Java LCG) random sources this dimension turns on
*> (section 4), the noises built from them (the blended 3D noise 5.2, the legacy Nether-biome temperature and vegetation noises 4.3, the
*> named noises of the surface pass 4.4), the density at the chunk's 5 x 17 x 5 corners (5.1, 5.4, 6.1), the block-step interpolation with
*> squeeze (6.2) and the fill without aquifers: lava below y 32, air above (7). The noise primitives are those of noise.cob: a noise is built
*> there with a placeholder Xoroshiro source (its octave list, amplitudes and layers do not depend on the source) and every perlin row is then
*> filled again from the legacy generator in the order of the reference; the draws come from rng-java.cob.
*>
*> Entry points (all state in NETHER.cpy):
*>   NETHER-SETUP USING world seed (BINARY-DOUBLE): builds the master factory, the noises and the zoom seed once per seed and noise store.
*>   NETHER-STATES: resolves the block states and the five biome ids the generator places from the block and biome tables.
*>   NETHER-JHASH USING text (PIC X(64)), length, hash out (BINARY-LONG): Java String.hashCode.
*>   NETHER-FROM-HASH USING factory seed F (u64), text, length, generator out (u64 state): P.fromHashOf(name).
*>   NETHER-AT USING factory seed (u64), x, y, z, generator out: P.at(x, y, z).
*>   NETHER-RAND-DOUBLE USING generator, value out (FLOAT-LONG): nextDouble() of the legacy source.
*>   NETHER-BLENDED USING x, y, z (BINARY-LONG), value out: the old_blended_noise of nether/base_3d_noise.
*>   NETHER-CORNERS USING chunk x, chunk z: fills NH-CORNER.     NETHER-COLUMN USING local x, local z: fills NH-COL (the squeezed densities).
*>   NETHER-FILL USING chunk memory: netherrack where the density is above 0, else lava below y 32. The density of a block is the squeezed density plus the beardifier (37-2 section 10) while
*>     SBD-ACTIVE is 1 (STRUCTBEARD.cpy, the records of SBD-CX, SBD-CZ: NETHER-BEARD-COLLECT makes them, NETHER-BEARD-CLEAR empties them); without a record the fill is that of the squeezed density alone.
*>   NETHER-SOLID USING squeezed density (FLOAT-LONG), x, y, z, flag out: 1 when the squeezed density plus STRUCT-BEARD-SAMPLE (single precision sum) is above 0 (10: not interpolated, a block is solid iff the sum > 0).
*>   NETHER-FOSSIL-START USING world seed, chunk x, chunk z, valid out: 1 when the chunk holds a nether_fossil start (the set nether_fossils' candidate, the biome of the chunk's first quart, NFOS-FIND-POINT);
*>     the piece is in the builder. NETHER-BEARD-COLLECT USING world seed, chunk x, chunk z: 10.1 and 10.2 for the Nether: the one rigid record (beard_thin, ground level delta 0, the piece box) of every fossil start
*>     within 2 chunks whose box widened by 12 reaches the chunk; the junction term never occurs here (10.4). Run it before NETHER-CORNERS of the chunk (the start's base column fills NH-CORNER).
*>     NETHER-BEARD-CLEAR: empties the records again (the overworld's STRUCT-BEARD-PREPARE shares them).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-JHASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LEN                  BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-HASH.
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LEN
         COMPUTE WS-C = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         COMPUTE WS-H = FUNCTION MOD(WS-H * 31 + WS-C, 4294967296)
     END-PERFORM
     IF WS-H >= 2147483648
         SUBTRACT 4294967296 FROM WS-H
     END-IF
     MOVE WS-H TO L-HASH
     GOBACK.
 END PROGRAM NETHER-JHASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FROM-HASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HASH                BINARY-LONG.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-FS                   BINARY-DOUBLE UNSIGNED.
 01 L-TEXT                 PIC X(64).
 01 L-LEN                  BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-FS L-TEXT L-LEN L-STATE.
*>   (long) hash is sign extended: the 64 bits of the two's complement
     CALL "NETHER-JHASH" USING L-TEXT L-LEN WS-HASH
     MOVE WS-HASH TO WS-S
     IF WS-S < 0
         COMPUTE WS-U = WS-S + 18446744073709551616
     ELSE
         MOVE WS-S TO WS-U
     END-IF
     CALL "CBL_XOR" USING L-FS WS-U BY VALUE 8
     CALL "JRAND-SET-SEED" USING L-STATE WS-U
     GOBACK.
 END PROGRAM NETHER-FROM-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-FS                   BINARY-DOUBLE UNSIGNED.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-FS L-X L-Y L-Z L-STATE.
     CALL "XORO-GET-SEED" USING L-X L-Y L-Z WS-S
     IF WS-S < 0
         COMPUTE WS-U = WS-S + 18446744073709551616
     ELSE
         MOVE WS-S TO WS-U
     END-IF
     CALL "CBL_XOR" USING L-FS WS-U BY VALUE 8
     CALL "JRAND-SET-SEED" USING L-STATE WS-U
     GOBACK.
 END PROGRAM NETHER-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-RAND-DOUBLE.
*> nextDouble(): ((long) next(26) << 27) + next(27), times 2^-53 (an exact division by 2^53).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B26                 BINARY-LONG VALUE 26.
 01 WS-B27                 BINARY-LONG VALUE 27.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-V                   FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG VALUE 9007199254740992.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "JRAND-NEXT" USING L-STATE WS-B26 WS-A
     CALL "JRAND-NEXT" USING L-STATE WS-B27 WS-B
     COMPUTE WS-A = WS-A * 134217728 + WS-B
     MOVE WS-A TO WS-V
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-DEN L-RESULT
     GOBACK.
 END PROGRAM NETHER-RAND-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PERLIN-FILL.
*> USING generator (u64), perlin row: the offsets and the shuffle of PerlinNoise(r) (10 section 3.1) drawn from the legacy source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-D                   FLOAT-LONG.
 01 WS-256                 FLOAT-LONG VALUE 256.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-T                   BINARY-SHORT UNSIGNED.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-INDEX.
     CALL "NETHER-RAND-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OX(L-INDEX)
     CALL "NETHER-RAND-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OY(L-INDEX)
     CALL "NETHER-RAND-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OZ(L-INDEX)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE NZ-PERM(L-INDEX, WS-I + 1) = WS-I
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-BOUND = 256 - WS-I
         CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-J
         COMPUTE WS-TARGET = WS-I + WS-J + 1
         MOVE NZ-PERM(L-INDEX, WS-I + 1) TO WS-T
         MOVE NZ-PERM(L-INDEX, WS-TARGET) TO NZ-PERM(L-INDEX, WS-I + 1)
         MOVE WS-T TO NZ-PERM(L-INDEX, WS-TARGET)
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-PERLIN-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STACK.
*> USING generator (u64), first octave, y scale, amplitude base, handle out: the smeared octave stack fbm(r, firstOctave, yScale, ampBase)
*> of old_blended_noise (10 section 3.4), its perlins drawn from the legacy generator in layer order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-DUMMY== LEADING ==XR-== BY ==WS-D-==.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-ONE-SEED            BINARY-DOUBLE UNSIGNED VALUE 1.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-FIRST                BINARY-LONG.
 01 L-Y-SCALE              FLOAT-LONG.
 01 L-AMP                  FLOAT-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FIRST L-Y-SCALE L-AMP L-HANDLE.
     CALL "XORO-SEED" USING WS-ONE-SEED WS-DUMMY
     CALL "NOISE-SMEARED-STACK" USING WS-DUMMY L-FIRST L-Y-SCALE L-AMP L-HANDLE
     MOVE NZ-FIRST(L-HANDLE) TO WS-I
     COMPUTE WS-LAST = WS-I + NZ-LAYER-N(L-HANDLE) - 1
     PERFORM VARYING WS-I FROM WS-I BY 1 UNTIL WS-I > WS-LAST
         CALL "NETHER-PERLIN-FILL" USING L-STATE NZ-L-PERLIN(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-NOISE.
*> USING factory seed F (u64), name (PIC X(64)), name length, base octave, octave count, base amplitude (FLOAT-LONG), modifiers (32 FLOAT-LONG),
*> modifier count, normalize, handle out: NormalNoise.create of 10 section 3.3 fed with the legacy factory (37-2 section 4.4): the named
*> generator r = P.fromHashOf(name), the forks A and B are the next two nextLong() of r, and the perlin of octave n of the first stack is
*> LegacyRandomSource(hash("octave_n") xor A.seed), of the second stack the same with B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-DUMMY== LEADING ==XR-== BY ==WS-D-==.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-GEN                 BINARY-DOUBLE UNSIGNED.
 01 WS-FA                  BINARY-DOUBLE UNSIGNED.
 01 WS-FB                  BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OCTAVE              BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-ONAME               PIC X(64).
 01 WS-OLEN                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-ONE-SEED            BINARY-DOUBLE UNSIGNED VALUE 1.
 LINKAGE SECTION.
 01 L-FS                   BINARY-DOUBLE UNSIGNED.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-AMP                  FLOAT-LONG.
 01 L-MODS.
    05 L-MOD               FLOAT-LONG OCCURS 32 TIMES.
 01 L-MOD-COUNT            BINARY-LONG.
 01 L-NORMALIZE            BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FS L-NAME L-LENGTH L-BASE L-COUNT L-AMP L-MODS L-MOD-COUNT
         L-NORMALIZE L-HANDLE.
     CALL "XORO-SEED" USING WS-ONE-SEED WS-DUMMY
     CALL "NOISE-CREATE" USING WS-DUMMY L-NAME L-LENGTH L-BASE L-COUNT L-AMP L-MODS L-MOD-COUNT
         L-NORMALIZE L-HANDLE
     CALL "NETHER-FROM-HASH" USING L-FS L-NAME L-LENGTH WS-R
     CALL "JRAND-NEXT-LONG" USING WS-R WS-FA
     CALL "JRAND-NEXT-LONG" USING WS-R WS-FB
     MOVE 0 TO WS-LAYER
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > L-COUNT
         IF L-MOD-COUNT = 0 OR L-MOD(WS-SLOT) NOT = 0
             COMPUTE WS-OCTAVE = L-BASE + WS-SLOT - 1
             MOVE WS-OCTAVE TO WS-EDIT
             MOVE SPACES TO WS-ONAME
             STRING "octave_" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-ONAME
             COMPUTE WS-OLEN = 7 + FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
             COMPUTE WS-I = NZ-FIRST(L-HANDLE) + WS-LAYER
             CALL "NETHER-FROM-HASH" USING WS-FA WS-ONAME WS-OLEN WS-GEN
             CALL "NETHER-PERLIN-FILL" USING WS-GEN NZ-L-PERLIN(WS-I)
             ADD 1 TO WS-I
             CALL "NETHER-FROM-HASH" USING WS-FB WS-ONAME WS-OLEN WS-GEN
             CALL "NETHER-PERLIN-FILL" USING WS-GEN NZ-L-PERLIN(WS-I)
             ADD 2 TO WS-LAYER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-NOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CLIMATE-NOISE.
*> USING seed' (u64: world seed + 0 or + 1), handle out: NormalNoise.createForLegacyNetherBiome (37-2 section 4.3) for nether/temperature and
*> nether/vegetation (base octave -7, two octaves, base amplitude 0.9494731054427981). Each of the two stacks draws a perlin that is discarded,
*> skips 5 x 262 steps, then creates slot 1 and slot 0; the four layers (stack 1 slot 0 and 1, stack 2 slot 0 and 1) are flat.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-SKIP                BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-I                   BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-P0                  BINARY-LONG OCCURS 2 TIMES.
 01 WS-P1                  BINARY-LONG OCCURS 2 TIMES.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 01 WS-TEXT-NF             PIC X(32) VALUE Z"1.1702396884564004".
 01 WS-TEXT-BASE           PIC X(32) VALUE Z"0.9494731054427981".
 01 WS-TEXT-SECOND         PIC X(32) VALUE Z"1.0181268882175227".
 01 WS-NF                  FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-SECOND              FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-A0                  FLOAT-LONG.
 01 WS-A1                  FLOAT-LONG.
 01 WS-F0                  FLOAT-LONG VALUE 0.0078125.
 01 WS-F1                  FLOAT-LONG VALUE 0.015625.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-HANDLE.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-NF WS-NF
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-BASE WS-BASE
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT-SECOND WS-SECOND
*>   a = (float)(nf * base amplitude); the slot amplitudes (float)(2/3) and (float)(1/3) times a, each a float product
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-NF WS-BASE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-TWO WS-THREE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A0
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A0 WS-A WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A0
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE WS-THREE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A1 WS-A WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A1
     CALL "JRAND-SET-SEED" USING WS-R L-SEED
     PERFORM VARYING WS-STACK FROM 1 BY 1 UNTIL WS-STACK > 2
*>       the discarded perlin of slot k = 7 (its row is reused), the five skipped slots, then slot 1 and slot 0
         COMPUTE WS-I = NZ-PERLIN-COUNT + 1
         CALL "NETHER-PERLIN-FILL" USING WS-R WS-I
         PERFORM 1310 TIMES
             CALL "JRAND-NEXT" USING WS-R WS-BITS WS-SKIP
         END-PERFORM
         ADD 1 TO NZ-PERLIN-COUNT
         MOVE NZ-PERLIN-COUNT TO WS-P1(WS-STACK)
         CALL "NETHER-PERLIN-FILL" USING WS-R WS-P1(WS-STACK)
         ADD 1 TO NZ-PERLIN-COUNT
         MOVE NZ-PERLIN-COUNT TO WS-P0(WS-STACK)
         MOVE 0 TO NZ-FUDGE(WS-P0(WS-STACK))
         MOVE 0 TO NZ-FUDGE(WS-P1(WS-STACK))
         CALL "NETHER-PERLIN-FILL" USING WS-R WS-P0(WS-STACK)
     END-PERFORM
     ADD 1 TO NZ-NOISE-COUNT
     MOVE NZ-NOISE-COUNT TO L-HANDLE
     COMPUTE NZ-FIRST(L-HANDLE) = NZ-LAYER-COUNT + 1
     MOVE 4 TO NZ-LAYER-N(L-HANDLE)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-P0(1) TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     MOVE WS-F0 TO NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-A0 TO NZ-L-AMP(NZ-LAYER-COUNT)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-P1(1) TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     MOVE WS-F1 TO NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-A1 TO NZ-L-AMP(NZ-LAYER-COUNT)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-P0(2) TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-F0 WS-SECOND NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-A0 TO NZ-L-AMP(NZ-LAYER-COUNT)
     ADD 1 TO NZ-LAYER-COUNT
     MOVE WS-P1(2) TO NZ-L-PERLIN(NZ-LAYER-COUNT)
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-F1 WS-SECOND NZ-L-FREQ(NZ-LAYER-COUNT)
     MOVE WS-A1 TO NZ-L-AMP(NZ-LAYER-COUNT)
     GOBACK.
 END PROGRAM NETHER-CLIMATE-NOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-NOISE-DEF.
*> USING which (1 surface, 2 nether_state_selector, 3 netherrack, 4 nether_wart, 5 soul_sand_layer, 6 gravel_layer, 7 patch), handle out: the
*> definitions of 37-4 section 4.1 (base octave, octave count, base amplitude, amplitude modifiers), built with the legacy factory NH-FS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-MODS.
    05 WS-MOD              FLOAT-LONG OCCURS 32 TIMES.
 01 WS-MOD-COUNT           BINARY-LONG.
 01 WS-NORMALIZE           BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT2               PIC X(32).
 01 WS-LASTIDX             BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-HANDLE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         MOVE 0 TO WS-MOD(WS-I)
     END-PERFORM
     MOVE 0 TO WS-MOD-COUNT WS-LASTIDX
     MOVE SPACES TO WS-NAME
     EVALUATE L-WHICH
         WHEN 1
             MOVE "minecraft:surface" TO WS-NAME
             MOVE 17 TO WS-LEN
             MOVE -6 TO WS-BASE
             MOVE 3 TO WS-COUNT
             MOVE Z"0.9381732587751008" TO WS-TEXT
         WHEN 2
             MOVE "minecraft:nether_state_selector" TO WS-NAME
             MOVE 31 TO WS-LEN
             MOVE -4 TO WS-BASE
             MOVE 1 TO WS-COUNT
             MOVE Z"0.955388882960065" TO WS-TEXT
         WHEN 3
             MOVE "minecraft:netherrack" TO WS-NAME
             MOVE 20 TO WS-LEN
             MOVE -3 TO WS-BASE
             MOVE 4 TO WS-COUNT
             MOVE Z"1.4659491761370222" TO WS-TEXT
             MOVE 4 TO WS-MOD-COUNT
             MOVE 1 TO WS-MOD(1)
             MOVE Z"0.35" TO WS-TEXT2
             MOVE 4 TO WS-LASTIDX
         WHEN 4
             MOVE "minecraft:nether_wart" TO WS-NAME
             MOVE 21 TO WS-LEN
             MOVE -3 TO WS-BASE
             MOVE 4 TO WS-COUNT
             MOVE Z"1.3827102115748344" TO WS-TEXT
             MOVE 4 TO WS-MOD-COUNT
             MOVE 1 TO WS-MOD(1)
             MOVE Z"0.9" TO WS-TEXT2
             MOVE 4 TO WS-LASTIDX
         WHEN 5
             MOVE "minecraft:soul_sand_layer" TO WS-NAME
             MOVE 25 TO WS-LEN
             MOVE -8 TO WS-BASE
             MOVE 9 TO WS-COUNT
             MOVE Z"1.0569606747151457" TO WS-TEXT
             MOVE 9 TO WS-MOD-COUNT
             MOVE 1 TO WS-MOD(1) WS-MOD(2) WS-MOD(3) WS-MOD(4)
             MOVE Z"0.013333333333333334" TO WS-TEXT2
             MOVE 9 TO WS-LASTIDX
         WHEN 6
             MOVE "minecraft:gravel_layer" TO WS-NAME
             MOVE 22 TO WS-LEN
             MOVE -8 TO WS-BASE
             MOVE 9 TO WS-COUNT
             MOVE Z"1.0569606747151457" TO WS-TEXT
             MOVE 9 TO WS-MOD-COUNT
             MOVE 1 TO WS-MOD(1) WS-MOD(2) WS-MOD(3) WS-MOD(4)
             MOVE Z"0.013333333333333334" TO WS-TEXT2
             MOVE 9 TO WS-LASTIDX
         WHEN OTHER
             MOVE "minecraft:patch" TO WS-NAME
             MOVE 15 TO WS-LEN
             MOVE -5 TO WS-BASE
             MOVE 6 TO WS-COUNT
             MOVE Z"1.637127519350388" TO WS-TEXT
             MOVE 6 TO WS-MOD-COUNT
             MOVE 1 TO WS-MOD(1)
             MOVE Z"0.013333333333333334" TO WS-TEXT2
             MOVE 6 TO WS-LASTIDX
     END-EVALUATE
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT WS-AMP
*>   the last modifier of the definition
     IF WS-LASTIDX > 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT2 WS-MOD(WS-LASTIDX)
     END-IF
     CALL "NETHER-NOISE" USING NH-FS WS-NAME WS-LEN WS-BASE WS-COUNT WS-AMP WS-MODS WS-MOD-COUNT
         WS-NORMALIZE L-HANDLE
     GOBACK.
 END PROGRAM NETHER-NOISE-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BLENDED.
*> USING x, y, z (BINARY-LONG), result out: old_blended_noise of nether/base_3d_noise (37-2 section 5.2; node semantics of 10 section 3.4 as
*> DENSITY-BLENDED): t = clamp(main + 0.5f, 0, 1), lerp(t, lo, hi), lazily at t = 0 and t = 1. The stacks were built by NETHER-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-XF                  FLOAT-LONG VALUE 80.
 01 WS-YF                  FLOAT-LONG VALUE 60.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-XD                  FLOAT-LONG.
 01 WS-YD                  FLOAT-LONG.
 01 WS-ZD                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-RESULT.
     MOVE L-X TO WS-XD
     MOVE L-Y TO WS-YD
     MOVE L-Z TO WS-ZD
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-XD NH-XZ-MUL WS-X
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-YD NH-Y-MUL WS-Y
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ZD NH-XZ-MUL WS-Z
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-X WS-XF WS-MX
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Y WS-YF WS-MY
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Z WS-XF WS-MZ
     CALL "NOISE-GET" USING NH-H-MAIN WS-MX WS-MY WS-MZ WS-M
     CALL "DENSITY-F32" USING WS-OP-ADD WS-M WS-HALF WS-T
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-T WS-ZERO WS-ONE WS-M
     EVALUATE TRUE
         WHEN WS-M = 0
             CALL "NOISE-GET" USING NH-H-MIN WS-X WS-Y WS-Z L-RESULT
         WHEN WS-M = 1
             CALL "NOISE-GET" USING NH-H-MAX WS-X WS-Y WS-Z L-RESULT
         WHEN OTHER
             CALL "NOISE-GET" USING NH-H-MIN WS-X WS-Y WS-Z WS-LO
             CALL "NOISE-GET" USING NH-H-MAX WS-X WS-Y WS-Z WS-HI
             CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-M WS-LO WS-HI L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BLENDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STATES.
*> Resolves the block states of the generator and the ids of the five biomes (in the order nether_wastes, soul_sand_valley, crimson_forest,
*> warped_forest, basalt_deltas) from the block table (GEN-BLOCK-STATE) and the biome table (SURFACE-BIOME-ID).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-KEY                 PIC X(48).
 01 WS-NAME                PIC X(40).
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     MOVE "minecraft:netherrack" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-NETHERRACK
     MOVE "minecraft:lava" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-LAVA
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-BEDROCK
     MOVE "minecraft:basalt" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-BASALT
     MOVE "minecraft:gravel" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-GRAVEL
     MOVE "minecraft:blackstone" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-BLACKSTONE
     MOVE "minecraft:soul_sand" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-SOUL-SAND
     MOVE "minecraft:soul_soil" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-SOUL-SOIL
     MOVE "minecraft:warped_wart_block" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-WARPED-WART
     MOVE "minecraft:warped_nylium" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-WARPED-NYL
     MOVE "minecraft:nether_wart_block" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-WART-BLOCK
     MOVE "minecraft:crimson_nylium" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY NH-S-CRIMSON-NYL
     MOVE "minecraft:nether_wastes" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME NH-BIOME-ID(1)
     MOVE "minecraft:soul_sand_valley" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME NH-BIOME-ID(2)
     MOVE "minecraft:crimson_forest" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME NH-BIOME-ID(3)
     MOVE "minecraft:warped_forest" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME NH-BIOME-ID(4)
     MOVE "minecraft:basalt_deltas" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME NH-BIOME-ID(5)
     GOBACK.
 END PROGRAM NETHER-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SETUP.
*> USING world seed (BINARY-DOUBLE, signed): once per seed and noise store (NH-GEN = NZ-GEN): the master factory F (the first nextLong() of
*> LegacyRandomSource(seed)), the three stacks of the blended noise from LegacyRandomSource(seed) (minimum limit, maximum limit, main; 5.2),
*> the climate noises of seed + 0 and seed + 1 (4.3), the seven surface-pass noises (4.4), the factories of the two bedrock gradients
*> (P.fromHashOf(name).forkPositional(), 4.2) and the zoom seed of the biome lookup (10 section 7.7: the first 8 bytes of SHA-256 of the seed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY NETHER.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-ONE-U               BINARY-DOUBLE UNSIGNED VALUE 1.
 01 WS-S1                  BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE-TEXT           PIC X(32) VALUE Z"684.412".
 01 WS-LIMIT-TEXT          PIC X(32) VALUE Z"0.9999847412109375".
 01 WS-K064-TEXT           PIC X(32) VALUE Z"0.64".
 01 WS-XZ-SCALE            FLOAT-LONG VALUE 0.25.
 01 WS-Y-SCALE             FLOAT-LONG VALUE 0.375.
 01 WS-SMEAR-MUL           FLOAT-LONG VALUE 8.
 01 WS-Y-FACTOR            FLOAT-LONG VALUE 60.
 01 WS-MAIN-AMP            FLOAT-LONG VALUE 12.75.
 01 WS-MIN-FIRST           BINARY-LONG VALUE -15.
 01 WS-MAIN-FIRST          BINARY-LONG VALUE -7.
 01 WS-BASE                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-SMEAR               FLOAT-LONG.
 01 WS-MAIN-SCALE          FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-DATA                PIC X(8).
 01 WS-DIGEST              PIC X(64).
 01 WS-DIGEST-LENGTH       BINARY-LONG UNSIGNED.
 01 WS-DATA-LENGTH         BINARY-DOUBLE UNSIGNED VALUE 8.
 01 WS-ALGORITHM           USAGE POINTER.
 01 WS-ENGINE              USAGE POINTER VALUE NULL.
 01 WS-RC                  BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED.
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     IF NH-READY = 1 AND NH-GEN = NZ-GEN AND NH-SEED = WS-U
         GOBACK
     END-IF
     MOVE 1 TO NH-READY
     MOVE NZ-GEN TO NH-GEN
     MOVE WS-U TO NH-SEED
     CALL "JRAND-SET-SEED" USING WS-R WS-U
     CALL "JRAND-NEXT-LONG" USING WS-R NH-FS
*>   the blended noise: three stacks from one LegacyRandomSource(seed)
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-BASE-TEXT WS-BASE
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-LIMIT-TEXT WS-LIMIT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-K064-TEXT WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T NH-K064
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WS-XZ-SCALE NH-XZ-MUL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WS-Y-SCALE NH-Y-MUL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE NH-Y-MUL WS-SMEAR-MUL WS-SMEAR
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-SMEAR WS-Y-FACTOR WS-MAIN-SCALE
     CALL "JRAND-SET-SEED" USING WS-R WS-U
     CALL "NETHER-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT NH-H-MIN
     CALL "NETHER-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT NH-H-MAX
     CALL "NETHER-STACK" USING WS-R WS-MAIN-FIRST WS-MAIN-SCALE WS-MAIN-AMP NH-H-MAIN
*>   the climate noises
     CALL "NETHER-CLIMATE-NOISE" USING WS-U NH-H-TEMP
     CALL STATIC "cc_u64_add" USING BY REFERENCE WS-U WS-ONE-U WS-S1
     CALL "NETHER-CLIMATE-NOISE" USING WS-S1 NH-H-VEG
*>   the surface-pass noises
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "NETHER-NOISE-DEF" USING WS-I NH-H-NOISE(WS-I)
     END-PERFORM
*>   the gradient factories: P.fromHashOf(name).forkPositional() takes the first nextLong() of the named generator
     MOVE "minecraft:bedrock_floor" TO WS-NAME
     MOVE 23 TO WS-LEN
     CALL "NETHER-FROM-HASH" USING NH-FS WS-NAME WS-LEN WS-R
     CALL "JRAND-NEXT-LONG" USING WS-R NH-FLOOR-FS
     MOVE "minecraft:bedrock_roof" TO WS-NAME
     MOVE 22 TO WS-LEN
     CALL "NETHER-FROM-HASH" USING NH-FS WS-NAME WS-LEN WS-R
     CALL "JRAND-NEXT-LONG" USING WS-R NH-ROOF-FS
*>   obfuscateSeed: the first 8 bytes of SHA-256 of the 8 little-endian bytes of the seed, as a little-endian word
     MOVE WS-U TO WS-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-BYTE = FUNCTION MOD(WS-V, 256)
         MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-DATA(WS-I:1)
         DIVIDE WS-V BY 256 GIVING WS-V
     END-PERFORM
     CALL STATIC "EVP_sha256" RETURNING WS-ALGORITHM
     CALL STATIC "EVP_Digest" USING BY REFERENCE WS-DATA BY VALUE WS-DATA-LENGTH
         BY REFERENCE WS-DIGEST BY REFERENCE WS-DIGEST-LENGTH BY VALUE WS-ALGORITHM
         BY VALUE WS-ENGINE RETURNING WS-RC
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 8 BY -1 UNTIL WS-I < 1
         COMPUTE WS-BYTE = FUNCTION ORD(WS-DIGEST(WS-I:1)) - 1
         COMPUTE WS-A = WS-A * 256 + WS-BYTE
     END-PERFORM
     MOVE WS-A TO NH-ZOOM-SEED
     MOVE -1 TO NH-CC-X NH-CC-Z
     GOBACK.
 END PROGRAM NETHER-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-GRADIENT.
*> USING y, from coordinate, to coordinate (BINARY-LONG), from value, to value (FLOAT-LONG), result out: the clamped y gradient (37-2 section
*> 5.3): from + (float)(c - from_c) * ((to - from) / (float)(to_c - from_c)), c the integer clamp of y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-FROM-C               BINARY-LONG.
 01 L-TO-C                 BINARY-LONG.
 01 L-FROM-V               FLOAT-LONG.
 01 L-TO-V                 FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-FROM-C L-TO-C L-FROM-V L-TO-V L-RESULT.
     IF L-FROM-C < L-TO-C
         COMPUTE WS-C = FUNCTION MAX(L-FROM-C, FUNCTION MIN(L-TO-C, L-Y))
     ELSE
         COMPUTE WS-C = FUNCTION MAX(L-TO-C, FUNCTION MIN(L-FROM-C, L-Y))
     END-IF
     CALL "DENSITY-F32" USING WS-OP-SUB L-TO-V L-FROM-V WS-T
     COMPUTE WS-D = L-TO-C - L-FROM-C
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-D WS-U
     CALL "DENSITY-F32" USING WS-OP-DIV WS-T WS-U WS-A
     COMPUTE WS-D = WS-C - L-FROM-C
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-D WS-U
     CALL "DENSITY-F32" USING WS-OP-MUL WS-U WS-A WS-B
     CALL "DENSITY-F32" USING WS-OP-ADD L-FROM-V WS-B L-RESULT
     GOBACK.
 END PROGRAM NETHER-GRADIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SQUEEZE.
*> USING v, result out (FLOAT-LONG): c = clamp(v, -1, 1); c / 2 - (c * c * c) / 24, every step a float (37-2 section 5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-LO                  FLOAT-LONG VALUE -1.
 01 WS-HI                  FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-24                  FLOAT-LONG VALUE 24.
 01 WS-C                   FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 01 WS-CC                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-V L-RESULT.
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE L-V WS-LO WS-HI WS-C
     CALL "DENSITY-F32" USING WS-OP-DIV WS-C WS-TWO WS-A
     MOVE WS-C TO WS-CC
     CALL "DENSITY-F32" USING WS-OP-MUL WS-C WS-CC WS-C2
     CALL "DENSITY-F32" USING WS-OP-MUL WS-C2 WS-C WS-C3
     CALL "DENSITY-F32" USING WS-OP-DIV WS-C3 WS-24 WS-B
     CALL "DENSITY-F32" USING WS-OP-SUB WS-A WS-B L-RESULT
     GOBACK.
 END PROGRAM NETHER-SQUEEZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CORNERS.
*> USING chunk x, chunk z: the 5 x 17 x 5 corner values 0.64 * S of the chunk (37-2 sections 5.1, 5.4 and 6.1): S is lerp(gradient y -8 to 24
*> (0 to 1), 2.5, lerp(gradient y 104 to 128 (1 to 0), 0.9375, blended noise)). A corner whose alpha is 0 or 1 takes the first or the second value
*> without the Mth.lerp rounding (the lazy LerpFunction$ConstFirstSampler); the noise is not evaluated where the top alpha is 0 (y 128).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-FROM-B              BINARY-LONG VALUE -8.
 01 WS-TO-B                BINARY-LONG VALUE 24.
 01 WS-FROM-T              BINARY-LONG VALUE 104.
 01 WS-TO-T                BINARY-LONG VALUE 128.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-K25                 FLOAT-LONG VALUE 2.5.
 01 WS-K09375              FLOAT-LONG VALUE 0.9375.
 01 WS-GB                  FLOAT-LONG.
 01 WS-GT                  FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-SECOND              FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 4
             COMPUTE WS-X = L-CX * 16 + 4 * WS-I
             COMPUTE WS-Z = L-CZ * 16 + 4 * WS-K
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 16
                 COMPUTE WS-Y = 8 * WS-J
                 CALL "NETHER-GRADIENT" USING WS-Y WS-FROM-B WS-TO-B WS-ZERO WS-ONE WS-GB
                 CALL "NETHER-GRADIENT" USING WS-Y WS-FROM-T WS-TO-T WS-ONE WS-ZERO WS-GT
                 IF WS-GT = 0
                     MOVE WS-K09375 TO WS-SECOND
                 ELSE
                     CALL "NETHER-BLENDED" USING WS-X WS-Y WS-Z WS-N
                     IF WS-GT = 1
                         MOVE WS-N TO WS-SECOND
                     ELSE
                         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-GT WS-K09375 WS-N WS-SECOND
                     END-IF
                 END-IF
*>               (the bottom alpha is 0 only at y <= -8, below the column, so the first value 2.5 is never the result here)
                 EVALUATE TRUE
                     WHEN WS-GB = 1
                         MOVE WS-SECOND TO WS-S
                     WHEN OTHER
                         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-GB WS-K25 WS-SECOND WS-S
                 END-EVALUATE
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-S NH-K064 WS-T
                 COMPUTE WS-IDX = (WS-I * 5 + WS-K) * 17 + WS-J + 1
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T NH-CORNER(WS-IDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-COLUMN.
*> USING local x, local z (0 to 15): the 128 squeezed densities of the column into NH-COL (index y + 1), by the block-step fill of 37-2 section 6.2:
*> along z, then x, then up the cell by adding the float step (p1 - p0) * 0.125 once per block. Needs NETHER-CORNERS of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-EIGHTH              FLOAT-LONG VALUE 0.125.
 01 WS-CI                  BINARY-LONG.
 01 WS-CK                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-U00                 FLOAT-LONG.
 01 WS-U01                 FLOAT-LONG.
 01 WS-U10                 FLOAT-LONG.
 01 WS-U11                 FLOAT-LONG.
 01 WS-P0                  FLOAT-LONG.
 01 WS-P1                  FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-CA                  FLOAT-LONG.
 01 WS-CB                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LX                   BINARY-LONG.
 01 L-LZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LX L-LZ.
     DIVIDE L-LX BY 4 GIVING WS-CI REMAINDER WS-DX
     DIVIDE L-LZ BY 4 GIVING WS-CK REMAINDER WS-DZ
     MOVE WS-DX TO WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-QUARTER WS-FX
     MOVE WS-DZ TO WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-QUARTER WS-FZ
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 15
*>       corner (i, j, k): index ((i * 5 + k) * 17 + j) + 1
         COMPUTE WS-A = (WS-CI * 5 + WS-CK) * 17 + WS-J + 1
         COMPUTE WS-B = (WS-CI * 5 + WS-CK + 1) * 17 + WS-J + 1
         MOVE NH-CORNER(WS-A) TO WS-CA
         MOVE NH-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U00
         COMPUTE WS-A = (WS-CI * 5 + WS-CK) * 17 + WS-J + 2
         COMPUTE WS-B = (WS-CI * 5 + WS-CK + 1) * 17 + WS-J + 2
         MOVE NH-CORNER(WS-A) TO WS-CA
         MOVE NH-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U01
         COMPUTE WS-A = ((WS-CI + 1) * 5 + WS-CK) * 17 + WS-J + 1
         COMPUTE WS-B = ((WS-CI + 1) * 5 + WS-CK + 1) * 17 + WS-J + 1
         MOVE NH-CORNER(WS-A) TO WS-CA
         MOVE NH-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U10
         COMPUTE WS-A = ((WS-CI + 1) * 5 + WS-CK) * 17 + WS-J + 2
         COMPUTE WS-B = ((WS-CI + 1) * 5 + WS-CK + 1) * 17 + WS-J + 2
         MOVE NH-CORNER(WS-A) TO WS-CA
         MOVE NH-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U11
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FX WS-U00 WS-U10 WS-P0
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FX WS-U01 WS-U11 WS-P1
         CALL "DENSITY-F32" USING WS-OP-SUB WS-P1 WS-P0 WS-DIFF
         CALL "DENSITY-F32" USING WS-OP-MUL WS-DIFF WS-EIGHTH WS-STEP
         MOVE WS-P0 TO WS-V
         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 7
             COMPUTE WS-A = WS-J * 8 + WS-DY + 1
             CALL "NETHER-SQUEEZE" USING WS-V NH-COL(WS-A)
             CALL "DENSITY-F32" USING WS-OP-ADD WS-V WS-STEP WS-V2
             MOVE WS-V2 TO WS-V
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SOLID.
*> USING squeezed density (FLOAT-LONG), x, y, z (BINARY-LONG), flag out (BINARY-LONG): the final density of 37-2 section 10 is add(squeeze(...), beardifier), summed in single precision, and a block is solid iff it is above 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-B                   FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-X L-Y L-Z L-FLAG.
     CALL "STRUCT-BEARD-SAMPLE" USING L-X L-Y L-Z WS-B
     CALL "FX-OP" USING WS-OP-ADD L-V WS-B WS-SUM
     CALL "FCMP-GT" USING WS-SUM WS-ZERO L-FLAG
     GOBACK.
 END PROGRAM NETHER-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FILL.
*> USING chunk memory (CELLS.cpy): netherrack where the density is above 0 (the squeezed density plus the beardifier of 37-2 section 10 while SBD-ACTIVE is 1: NETHER-SOLID at the block of chunk SBD-CX, SBD-CZ),
*> else lava below y 32 (the disabled aquifer's sea status, section 7) and nothing above; y 0 to 127 only. Needs NETHER-CORNERS and NETHER-STATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY NETHER.
 COPY STRUCTBEARD.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             CALL "NETHER-COLUMN" USING WS-LX WS-LZ
             COMPUTE WS-BX = SBD-CX * 16 + WS-LX
             COMPUTE WS-BZ = SBD-CZ * 16 + WS-LZ
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
                 COMPUTE WS-I = WS-Y + 1
                 IF SBD-ACTIVE = 1
                     CALL "NETHER-SOLID" USING NH-COL(WS-I) WS-BX WS-Y WS-BZ WS-GT
                 ELSE
                     CALL "FCMP-GT" USING NH-COL(WS-I) WS-ZERO WS-GT
                 END-IF
                 COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                 EVALUATE TRUE
                     WHEN WS-GT = 1
                         MOVE NH-S-NETHERRACK TO CE-STATE(WS-CELL)
                     WHEN WS-Y < 32
                         MOVE NH-S-LAVA TO CE-STATE(WS-CELL)
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FOSSIL-START.
*> USING world seed (BINARY-DOUBLE), chunk x, chunk z, valid out (BINARY-LONG): the nether_fossil start of a chunk as the Nether's structure stage reads a start (nether-struct.cob): the chunk is the candidate of the set
*> nether_fossils (set 2 of NETHER-STRUCTURE-CANDIDATE), the biome of the chunk's first quart (standing for the stub's, as there) allows the structure (4: soul_sand_valley), and NFOS-FIND-POINT (struct-fossil.cob)
*> finds a generation point. The piece is left in the builder.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SET                 BINARY-LONG VALUE 2.
 01 WS-STRUCT              BINARY-LONG VALUE 4.
 01 WS-CAND-X              BINARY-LONG.
 01 WS-CAND-Z              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-BIOME-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:nether_wastes".
    05 FILLER              PIC X(40) VALUE "minecraft:soul_sand_valley".
    05 FILLER              PIC X(40) VALUE "minecraft:crimson_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:warped_forest".
    05 FILLER              PIC X(40) VALUE "minecraft:basalt_deltas".
 01 WS-BIOME-TAB REDEFINES WS-BIOME-NAMES.
    05 WS-BIOME-NAME       PIC X(40) OCCURS 5 TIMES.
 01 WS-NUM                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-TPL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-VALID.
     MOVE 0 TO L-VALID
     CALL "NETHER-STRUCTURE-CANDIDATE" USING L-SEED WS-SET L-CX L-CZ WS-CAND-X WS-CAND-Z WS-FLAG
     IF WS-FLAG = 1
         CALL "NETHER-DIM-BIOMES" USING L-CX L-CZ WS-BIOMES
         MOVE 0 TO WS-NUM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
             CALL "SURFACE-BIOME-ID" USING WS-BIOME-NAME(WS-J) WS-ID
             IF WS-ID = WS-BIOME(1)
                 MOVE WS-J TO WS-NUM
             END-IF
         END-PERFORM
         CALL "NETHER-STRUCTURE-BIOME" USING WS-STRUCT WS-NUM WS-ALLOWED
         IF WS-ALLOWED = 1
             CALL "NFOS-FIND-POINT" USING L-SEED L-CX L-CZ WS-X WS-Y WS-Z L-VALID WS-ROT WS-TPL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NETHER-FOSSIL-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BEARD-COLLECT.
*> USING world seed (BINARY-DOUBLE), chunk x, chunk z: the records of the beardifier of the Nether chunk (37-2 10.1 and 10.2): of the nether_fossil starts of the 5 x 5 chunks around it (a start box is at most a template
*> long, so its box widened by 12 reaches no chunk farther than 2 away), each whose piece box widened by 12 reaches the chunk's columns adds one rigid record {beard_thin (mode 2), the piece box, ground level delta 0} (at most 25, the table holds 1024); the
*> affected box is extended by it. No other Nether structure adapts the terrain (10.1: fortress, bastion remnant and ruined portal have none) and a fossil is no jigsaw piece, so there is no junction record (10.4).
*> SBD-READY stays 0: the stamps of STRUCT-BEARD-PREPARE (the overworld's chunk) never take these records for its own. Needs NETHER-STATES and the nether tables; leaves NH-CORNER of another chunk (NETHER-CORNERS after it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 01 WS-MARGIN              BINARY-LONG VALUE 12.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ.
     MOVE 0 TO SBD-READY SBD-ACTIVE SBD-RIGID-COUNT SBD-JUNC-COUNT SBD-LOST WS-HAVE
     MOVE L-CX TO SBD-CX
     MOVE L-CZ TO SBD-CZ
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 4
         COMPUTE WS-SX = L-CX - 2 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 4
             COMPUTE WS-SZ = L-CZ - 2 + WS-IZ
             CALL "NETHER-FOSSIL-START" USING L-SEED WS-SX WS-SZ WS-VALID
             IF WS-VALID = 1
                 CALL "SPB-UNION-ALL" USING WS-BOX
                 CALL "STRUCT-BEARD-CLOSE" USING B-X0 B-Z0 B-X1 B-Z1 L-CX L-CZ WS-MARGIN WS-CLOSE
                 IF WS-CLOSE = 1
                     ADD 1 TO SBD-RIGID-COUNT
                     MOVE WS-MODE TO SBR-MODE(SBD-RIGID-COUNT)
                     MOVE B-X0 TO SBR-X0(SBD-RIGID-COUNT)
                     MOVE B-Y0 TO SBR-Y0(SBD-RIGID-COUNT)
                     MOVE B-Z0 TO SBR-Z0(SBD-RIGID-COUNT)
                     MOVE B-X1 TO SBR-X1(SBD-RIGID-COUNT)
                     MOVE B-Y1 TO SBR-Y1(SBD-RIGID-COUNT)
                     MOVE B-Z1 TO SBR-Z1(SBD-RIGID-COUNT)
                     MOVE WS-GROUND TO SBR-GROUND(SBD-RIGID-COUNT)
                     CALL "STRUCT-BEARD-EXTEND" USING WS-HAVE B-X0 B-Y0 B-Z0 B-X1 B-Y1 B-Z1
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF SBD-RIGID-COUNT > 0
         MOVE 1 TO SBD-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM NETHER-BEARD-COLLECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BEARD-CLEAR.
*> empties the records of the beardifier after a Nether chunk (SBD-GEN changes: the density memo of the overworld stamps it)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 PROCEDURE DIVISION.
     MOVE 0 TO SBD-READY SBD-ACTIVE SBD-RIGID-COUNT SBD-JUNC-COUNT SBD-LOST
     ADD 1 TO SBD-GEN
     GOBACK.
 END PROGRAM NETHER-BEARD-CLEAR.
