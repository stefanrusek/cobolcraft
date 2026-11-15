*> The End's terrain generator (docs/protocol/38-end.md sections 3 to 7; T1725 to T1734): the island density field (the central cone 4.2, the outer
*> islands 4.3 from SimplexNoise(r, true) after 17292 skipped draws, the larger of both), the old blended 3D noise of end/base_3d_noise (4.4), the
*> vertical profile and the 5 x 17 x 5 corner values of final_density (5.1), the block-step interpolation with squeeze (as nether-37-2.cob 6.2, cells of
*> 8 x 4 x 8), the fill without aquifers (5.2: end_stone where the density is above 0, y 0 to 127), the surface rule (6: end_stone everywhere, no change)
*> and the biome source (7). Float rounding is as the reference: every step named float goes through the cc_f64 functions. All state is END.cpy.
*>
*> Entry points:
*>   END-SETUP USING world seed (BINARY-DOUBLE, signed): builds the simplex permutation, the memo and the three stacks of the blended noise once per seed
*>     and noise store (reusing NETHER-STACK of nether-37-2.cob: the same legacy random and stack engine, other scales).
*>   END-STATES: resolves end_stone and the five biome ids (order the_end, end_highlands, end_midlands, small_end_islands, end_barrens).
*>   END-SIMPLEX USING px, pz (BINARY-LONG), value out (FLOAT-LONG): N.get((double) px, (double) pz) of 4.3, memoised.
*>   END-CENTRAL / END-OUTER / END-ISLANDS USING block x, block z (BINARY-LONG), value out: the central cone, the outer-island node and end/islands.
*>   END-OUTER-H USING ix, iz (BINARY-LONG; x / 8), value out: H(ix, iz) of 4.3.
*>   END-BLENDED USING x, y, z, value out: end/base_3d_noise.   END-PROFILE USING y, S (FLOAT-LONG), A_blend out: the vertical profile of 5.1.
*>   END-CORNERS USING chunk x, chunk z: fills EN-CORNER.   END-COLUMN USING local x, local z: fills EN-COL.   END-FILL USING chunk memory.
*>   END-SURFACE USING chunk memory: the surface pass (no change).   END-BIOME-OF USING section x, section z, index out (1 to 5): the biome source.
*>   END-BIOME-STORE USING chunk memory, chunk x, chunk z: the biome cells.
*>   END-GEN-CHUNK USING world seed, chunk x, chunk z, chunk memory (CELLS.cpy), marker-y out (-1): a whole terrain chunk of minecraft:the_end.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SIMPLEX-RAW.
*> USING px, pz (BINARY-LONG), value out: the 2D simplex noise of 10 section 3.5 with zero offsets, in double arithmetic, the result a float.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 01 WS-SIX                 FLOAT-LONG VALUE 6.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-K70                 FLOAT-LONG VALUE 70.
 01 WS-R3                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-G2                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-FL                  FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-Y2                  FLOAT-LONG.
 01 WS-N0                  FLOAT-LONG.
 01 WS-N1                  FLOAT-LONG.
 01 WS-N2                  FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-I1                  BINARY-LONG.
 01 WS-J1                  BINARY-LONG.
 01 WS-II                  BINARY-LONG.
 01 WS-JJ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RESULT.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-THREE WS-R3
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-R3 WS-ONE WS-T
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-HALF WS-T WS-F2
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-THREE WS-R3 WS-T
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-SIX WS-G2
     END-IF
     MOVE L-X TO WS-X
     MOVE L-Z TO WS-Y
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-X WS-Y WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-F2 WS-S
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-X WS-S WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-FL
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FL WS-I
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-Y WS-S WS-T
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-T WS-FL
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FL WS-J
     COMPUTE WS-K = WS-I + WS-J
     MOVE WS-K TO WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-G2 WS-S
     MOVE WS-I TO WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-S WS-U
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-X WS-U WS-X0
     MOVE WS-J TO WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-S WS-U
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-Y WS-U WS-Y0
     CALL "FCMP-GT" USING WS-X0 WS-Y0 WS-GT
     MOVE 0 TO WS-I1 WS-J1
     IF WS-GT = 1
         MOVE 1 TO WS-I1
     ELSE
         MOVE 1 TO WS-J1
     END-IF
     MOVE WS-I1 TO WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-X0 WS-T WS-U
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-U WS-G2 WS-X1
     MOVE WS-J1 TO WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-Y0 WS-T WS-U
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-U WS-G2 WS-Y1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-TWO WS-G2 WS-S
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-X0 WS-ONE WS-U
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-U WS-S WS-X2
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-Y0 WS-ONE WS-U
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-U WS-S WS-Y2
     COMPUTE WS-II = FUNCTION MOD(WS-I, 256)
     COMPUTE WS-JJ = FUNCTION MOD(WS-J, 256)
*>   g0 = perm(ii + perm(jj)) mod 12 and the like; perm(k) = perm[k and 255]
     COMPUTE WS-K = FUNCTION MOD(WS-II + EN-PERM(WS-JJ + 1), 256)
     COMPUTE WS-G = FUNCTION MOD(EN-PERM(WS-K + 1), 12)
     CALL "END-SIMPLEX-CORNER" USING WS-X0 WS-Y0 WS-G WS-N0
     COMPUTE WS-K = FUNCTION MOD(WS-JJ + WS-J1, 256)
     COMPUTE WS-K = FUNCTION MOD(WS-II + WS-I1 + EN-PERM(WS-K + 1), 256)
     COMPUTE WS-G = FUNCTION MOD(EN-PERM(WS-K + 1), 12)
     CALL "END-SIMPLEX-CORNER" USING WS-X1 WS-Y1 WS-G WS-N1
     COMPUTE WS-K = FUNCTION MOD(WS-JJ + 1, 256)
     COMPUTE WS-K = FUNCTION MOD(WS-II + 1 + EN-PERM(WS-K + 1), 256)
     COMPUTE WS-G = FUNCTION MOD(EN-PERM(WS-K + 1), 12)
     CALL "END-SIMPLEX-CORNER" USING WS-X2 WS-Y2 WS-G WS-N2
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-N0 WS-N1 WS-T
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-N2 WS-U
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-K70 WS-U WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-RESULT
     GOBACK.
 END PROGRAM END-SIMPLEX-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SIMPLEX-CORNER.
*> USING x, y (FLOAT-LONG offsets from the corner), gradient index 0 to 11, contribution out: c = 0.5 - x * x - y * y; 0 when c < 0, else
*> (c * c) * (c * c) * (gx * x + gy * y) with the first 12 gradients of 10 section 3.1 (x and y components).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GX-TEXT             PIC X(12) VALUE "pmpmpmpmzzzz".
 01 WS-GY-TEXT             PIC X(12) VALUE "ppmmzzzzpmpm".
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C4                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-XC                  FLOAT-LONG.
 01 WS-YC                  FLOAT-LONG.
 01 WS-CC                  FLOAT-LONG.
 01 WS-C2C                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-G                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-G L-RESULT.
     MOVE L-X TO WS-XC
     MOVE L-Y TO WS-YC
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-X WS-XC WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-HALF WS-T WS-U
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Y WS-YC WS-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U WS-T WS-C
     CALL "FCMP-GT" USING WS-ZERO WS-C WS-NEG
     IF WS-NEG = 1
         MOVE 0 TO L-RESULT
         GOBACK
     END-IF
     EVALUATE WS-GX-TEXT(L-G + 1:1)
         WHEN "p"
             MOVE 1 TO WS-GX
         WHEN "m"
             MOVE -1 TO WS-GX
         WHEN OTHER
             MOVE 0 TO WS-GX
     END-EVALUATE
     EVALUATE WS-GY-TEXT(L-G + 1:1)
         WHEN "p"
             MOVE 1 TO WS-GY
         WHEN "m"
             MOVE -1 TO WS-GY
         WHEN OTHER
             MOVE 0 TO WS-GY
     END-EVALUATE
     MOVE WS-C TO WS-CC
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C WS-CC WS-C2
     MOVE WS-C2 TO WS-C2C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C2 WS-C2C WS-C4
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-GX L-X WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-GY L-Y WS-B
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-B WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C4 WS-T L-RESULT
     GOBACK.
 END PROGRAM END-SIMPLEX-CORNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SIMPLEX.
*> USING px, pz (BINARY-LONG), value out: END-SIMPLEX-RAW through the direct-mapped memo (EN-C-*).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RESULT.
     COMPUTE WS-I = FUNCTION MOD(L-X * 73 + L-Z * 151, 4096) + 1
     IF EN-C-HAVE(WS-I) = 1 AND EN-C-X(WS-I) = L-X AND EN-C-Z(WS-I) = L-Z
         MOVE EN-C-VAL(WS-I) TO L-RESULT
         GOBACK
     END-IF
     CALL "END-SIMPLEX-RAW" USING L-X L-Z L-RESULT
     MOVE 1 TO EN-C-HAVE(WS-I)
     MOVE L-X TO EN-C-X(WS-I)
     MOVE L-Z TO EN-C-Z(WS-I)
     MOVE L-RESULT TO EN-C-VAL(WS-I)
     GOBACK.
 END PROGRAM END-SIMPLEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SETUP.
*> USING world seed (BINARY-DOUBLE, signed): once per seed and noise store. The island noise: r = LegacyRandomSource(seed), 17292 nextInt() discarded,
*> three nextDouble() draws (offsets, multiplied by 0), the shuffle of perm[0..255] (4.3). The blended noise: three stacks from one
*> LegacyRandomSource(seed) (minimum limit, maximum limit, main; 4.4): xz multiplier 684.412 * 0.25, y multiplier 684.412 * 0.25, smear = y multiplier * 4,
*> main y scale smear / 160.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY END.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-SKIP                BINARY-DOUBLE.
 01 WS-D                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BASE-TEXT           PIC X(32) VALUE Z"684.412".
 01 WS-LIMIT-TEXT          PIC X(32) VALUE Z"0.9999847412109375".
 01 WS-K064-TEXT           PIC X(32) VALUE Z"0.64".
 01 WS-SCALE               FLOAT-LONG VALUE 0.25.
 01 WS-SMEAR-MUL           FLOAT-LONG VALUE 4.
 01 WS-Y-FACTOR            FLOAT-LONG VALUE 160.
 01 WS-MAIN-AMP            FLOAT-LONG VALUE 12.75.
 01 WS-MIN-FIRST           BINARY-LONG VALUE -15.
 01 WS-MAIN-FIRST          BINARY-LONG VALUE -7.
 01 WS-BASE                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-SMEAR               FLOAT-LONG.
 01 WS-MAIN-SCALE          FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED.
     IF L-SEED < 0
         COMPUTE WS-U = L-SEED + 18446744073709551616
     ELSE
         MOVE L-SEED TO WS-U
     END-IF
     IF EN-READY = 1 AND EN-GEN = NZ-GEN AND EN-SEED = WS-U
         GOBACK
     END-IF
     MOVE 1 TO EN-READY
     MOVE NZ-GEN TO EN-GEN
     MOVE WS-U TO EN-SEED
*>   the island simplex noise
     CALL "JRAND-SET-SEED" USING WS-R WS-U
     PERFORM 17292 TIMES
         CALL "JRAND-NEXT" USING WS-R WS-BITS WS-SKIP
     END-PERFORM
     PERFORM 3 TIMES
         CALL "NETHER-RAND-DOUBLE" USING WS-R WS-D
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE EN-PERM(WS-I + 1) = WS-I
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-BOUND = 256 - WS-I
         CALL "JRAND-NEXT-INT-BOUND" USING WS-R WS-BOUND WS-J
         COMPUTE WS-TARGET = WS-I + WS-J + 1
         MOVE EN-PERM(WS-I + 1) TO WS-T
         MOVE EN-PERM(WS-TARGET) TO EN-PERM(WS-I + 1)
         MOVE WS-T TO EN-PERM(WS-TARGET)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
         MOVE 0 TO EN-C-HAVE(WS-I)
     END-PERFORM
*>   the blended noise: three stacks from one LegacyRandomSource(seed)
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-BASE-TEXT WS-BASE
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-LIMIT-TEXT WS-LIMIT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-K064-TEXT WS-F
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F EN-K064
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WS-SCALE EN-XZ-MUL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WS-SCALE EN-Y-MUL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE EN-Y-MUL WS-SMEAR-MUL WS-SMEAR
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-SMEAR WS-Y-FACTOR WS-MAIN-SCALE
     CALL "JRAND-SET-SEED" USING WS-R WS-U
     CALL "NETHER-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT EN-H-MIN
     CALL "NETHER-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT EN-H-MAX
     CALL "NETHER-STACK" USING WS-R WS-MAIN-FIRST WS-MAIN-SCALE WS-MAIN-AMP EN-H-MAIN
     GOBACK.
 END PROGRAM END-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-STATES.
*> Resolves end_stone from the block table and the five biome ids from the biome table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-KEY                 PIC X(48).
 01 WS-NAME                PIC X(40).
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     MOVE "minecraft:end_stone" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY EN-S-END-STONE
     MOVE "minecraft:the_end" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME EN-BIOME-ID(1)
     MOVE "minecraft:end_highlands" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME EN-BIOME-ID(2)
     MOVE "minecraft:end_midlands" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME EN-BIOME-ID(3)
     MOVE "minecraft:small_end_islands" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME EN-BIOME-ID(4)
     MOVE "minecraft:end_barrens" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME EN-BIOME-ID(5)
     GOBACK.
 END PROGRAM END-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CENTRAL.
*> USING block x, z (BINARY-LONG), value out: (clamp(100 - d, -100, 80) - 8) * 0.0078125 with d = float sqrt(x * x + z * z), every step a float (4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-HUNDRED             FLOAT-LONG VALUE 100.
 01 WS-LO                  FLOAT-LONG VALUE -100.
 01 WS-HI                  FLOAT-LONG VALUE 80.
 01 WS-EIGHT               FLOAT-LONG VALUE 8.
 01 WS-SCALE               FLOAT-LONG VALUE 0.0078125.
 01 WS-DI                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-DX2                 FLOAT-LONG.
 01 WS-DZ2                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RESULT.
     COMPUTE WS-DI = 0 - L-X
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-DI WS-DX
     COMPUTE WS-DI = 0 - L-Z
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-DI WS-DZ
     MOVE WS-DX TO WS-DX2
     MOVE WS-DZ TO WS-DZ2
     CALL "DENSITY-F32" USING WS-OP-MUL WS-DX WS-DX2 WS-A
     CALL "DENSITY-F32" USING WS-OP-MUL WS-DZ WS-DZ2 WS-B
     CALL "DENSITY-F32" USING WS-OP-ADD WS-A WS-B WS-S
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-S WS-W
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-W WS-D
     CALL "DENSITY-F32" USING WS-OP-SUB WS-HUNDRED WS-D WS-V
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-V WS-LO WS-HI WS-W
     CALL "DENSITY-F32" USING WS-OP-SUB WS-W WS-EIGHT WS-V
     CALL "DENSITY-F32" USING WS-OP-MUL WS-V WS-SCALE L-RESULT
     GOBACK.
 END PROGRAM END-CENTRAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-OUTER-H.
*> USING ix, iz (BINARY-LONG), value out: H(ix, iz) of 4.3 over the 25 x 25 candidate cells around (ix / 2, iz / 2) (Java division and remainder):
*> a cell outside 64 units of the origin whose noise is below the float -0.9 is an island centre; w = ((|px| * 3439 + |pz| * 147) % 13) + 9 in float,
*> v = 100 - sqrt(ddx^2 + ddz^2) * w clamped to [-100, 80], the best v wins (start -100).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-HUNDRED             FLOAT-LONG VALUE 100.
 01 WS-LO                  FLOAT-LONG VALUE -100.
 01 WS-HI                  FLOAT-LONG VALUE 80.
 01 WS-K3439               FLOAT-LONG VALUE 3439.
 01 WS-K147                FLOAT-LONG VALUE 147.
 01 WS-K13                 FLOAT-LONG VALUE 13.
 01 WS-K9                  FLOAT-LONG VALUE 9.
 01 WS-NEG09               FLOAT-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-N                   FLOAT-LONG.
 01 WS-LT                  BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-DDX                 FLOAT-LONG.
 01 WS-DDZ                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-DDX2                FLOAT-LONG.
 01 WS-DDZ2                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IX                   BINARY-LONG.
 01 L-IZ                   BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-IX L-IZ L-RESULT.
     MOVE -0.9 TO WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-NEG09
     DIVIDE L-IX BY 2 GIVING WS-HX REMAINDER WS-SX
     DIVIDE L-IZ BY 2 GIVING WS-HZ REMAINDER WS-SZ
     MOVE WS-LO TO WS-BEST
     PERFORM VARYING WS-OX FROM -12 BY 1 UNTIL WS-OX > 12
         PERFORM VARYING WS-OZ FROM -12 BY 1 UNTIL WS-OZ > 12
             COMPUTE WS-PX = WS-HX + WS-OX
             COMPUTE WS-PZ = WS-HZ + WS-OZ
             COMPUTE WS-D2 = WS-PX * WS-PX + WS-PZ * WS-PZ
             IF WS-D2 > 4096
                 CALL "END-SIMPLEX" USING WS-PX WS-PZ WS-N
                 CALL "FCMP-GT" USING WS-NEG09 WS-N WS-LT
                 IF WS-LT = 1
                     COMPUTE WS-I = FUNCTION ABS(WS-PX)
                     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-I WS-A
                     COMPUTE WS-I = FUNCTION ABS(WS-PZ)
                     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-I WS-B
                     CALL "DENSITY-F32" USING WS-OP-MUL WS-A WS-K3439 WS-S
                     CALL "DENSITY-F32" USING WS-OP-MUL WS-B WS-K147 WS-T
                     CALL "DENSITY-F32" USING WS-OP-ADD WS-S WS-T WS-A
                     CALL STATIC "cc_f64_fmod" USING BY REFERENCE WS-A WS-K13 WS-S
                     CALL "DENSITY-F32" USING WS-OP-ADD WS-S WS-K9 WS-W
                     COMPUTE WS-I = WS-SX - WS-OX * 2
                     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-I WS-DDX
                     COMPUTE WS-I = WS-SZ - WS-OZ * 2
                     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-I WS-DDZ
                     MOVE WS-DDX TO WS-DDX2
                     MOVE WS-DDZ TO WS-DDZ2
                     CALL "DENSITY-F32" USING WS-OP-MUL WS-DDX WS-DDX2 WS-A
                     CALL "DENSITY-F32" USING WS-OP-MUL WS-DDZ WS-DDZ2 WS-B
                     CALL "DENSITY-F32" USING WS-OP-ADD WS-A WS-B WS-S
                     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-S WS-T
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
                     CALL "DENSITY-F32" USING WS-OP-MUL WS-A WS-W WS-B
                     CALL "DENSITY-F32" USING WS-OP-SUB WS-HUNDRED WS-B WS-V
                     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-V WS-LO WS-HI WS-A
                     CALL "FCMP-GT" USING WS-A WS-BEST WS-GT
                     IF WS-GT = 1
                         MOVE WS-A TO WS-BEST
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-BEST TO L-RESULT
     GOBACK.
 END PROGRAM END-OUTER-H.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-OUTER.
*> USING block x, z (BINARY-LONG), value out: end_outer_islands at a block: (H(x / 8, z / 8) - 8) / 128 in float (4.3; truncating division).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-EIGHT               FLOAT-LONG VALUE 8.
 01 WS-K128                FLOAT-LONG VALUE 128.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RESULT.
     DIVIDE L-X BY 8 GIVING WS-IX
     DIVIDE L-Z BY 8 GIVING WS-IZ
     CALL "END-OUTER-H" USING WS-IX WS-IZ WS-H
     CALL "DENSITY-F32" USING WS-OP-SUB WS-H WS-EIGHT WS-V
     CALL "DENSITY-F32" USING WS-OP-DIV WS-V WS-K128 L-RESULT
     GOBACK.
 END PROGRAM END-OUTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-ISLANDS.
*> USING block x, z (BINARY-LONG), value out: end/islands = max(central, outer) (4.2); it does not depend on y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RESULT.
     CALL "END-CENTRAL" USING L-X L-Z WS-C
     CALL "END-OUTER" USING L-X L-Z WS-O
     CALL "FCMP-GT" USING WS-O WS-C WS-GT
     IF WS-GT = 1
         MOVE WS-O TO L-RESULT
     ELSE
         MOVE WS-C TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM END-ISLANDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-BLENDED.
*> USING x, y, z (BINARY-LONG), value out: end/base_3d_noise (4.4; xz factor 80, y factor 160) as NETHER-BLENDED: t = clamp(main + 0.5f, 0, 1),
*> lerp(t, lo, hi), lazily at t = 0 and t = 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-XF                  FLOAT-LONG VALUE 80.
 01 WS-YF                  FLOAT-LONG VALUE 160.
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
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-XD EN-XZ-MUL WS-X
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-YD EN-Y-MUL WS-Y
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ZD EN-XZ-MUL WS-Z
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-X WS-XF WS-MX
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Y WS-YF WS-MY
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Z WS-XF WS-MZ
     CALL "NOISE-GET" USING EN-H-MAIN WS-MX WS-MY WS-MZ WS-M
     CALL "DENSITY-F32" USING WS-OP-ADD WS-M WS-HALF WS-T
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-T WS-ZERO WS-ONE WS-M
     EVALUATE TRUE
         WHEN WS-M = 0
             CALL "NOISE-GET" USING EN-H-MIN WS-X WS-Y WS-Z L-RESULT
         WHEN WS-M = 1
             CALL "NOISE-GET" USING EN-H-MAX WS-X WS-Y WS-Z L-RESULT
         WHEN OTHER
             CALL "NOISE-GET" USING EN-H-MIN WS-X WS-Y WS-Z WS-LO
             CALL "NOISE-GET" USING EN-H-MAX WS-X WS-Y WS-Z WS-HI
             CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-M WS-LO WS-HI L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM END-BLENDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PROFILE.
*> USING y (BINARY-LONG), S (FLOAT-LONG), A_blend out: lerp(grad_lo(y), -0.234375, lerp(grad_hi(y), -23.4375, S)) of 5.1 with grad_lo from y 4 (0) to
*> 32 (1) and grad_hi from y 56 (1) to 312 (0); an alpha of 0 or 1 gives its first or second value without the rounding of the lerp.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C4                  BINARY-LONG VALUE 4.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C56                 BINARY-LONG VALUE 56.
 01 WS-C312                BINARY-LONG VALUE 312.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-FIRST               FLOAT-LONG VALUE -0.234375.
 01 WS-BIG                 FLOAT-LONG VALUE -23.4375.
 01 WS-GL                  FLOAT-LONG.
 01 WS-GH                  FLOAT-LONG.
 01 WS-IN                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-S L-RESULT.
     CALL "NETHER-GRADIENT" USING L-Y WS-C4 WS-C32 WS-ZERO WS-ONE WS-GL
     CALL "NETHER-GRADIENT" USING L-Y WS-C56 WS-C312 WS-ONE WS-ZERO WS-GH
     EVALUATE TRUE
         WHEN WS-GH = 0
             MOVE WS-BIG TO WS-IN
         WHEN WS-GH = 1
             MOVE L-S TO WS-IN
         WHEN OTHER
             CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-GH WS-BIG L-S WS-IN
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-GL = 0
             MOVE WS-FIRST TO L-RESULT
         WHEN WS-GL = 1
             MOVE WS-IN TO L-RESULT
         WHEN OTHER
             CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-GL WS-FIRST WS-IN L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM END-PROFILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CORNER-VALUE.
*> USING y (BINARY-LONG), S (FLOAT-LONG), corner value out: 0.64 * A_blend(y, S) as a float (5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-A                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-S L-RESULT.
     CALL "END-PROFILE" USING L-Y L-S WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A EN-K064 WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-RESULT
     GOBACK.
 END PROGRAM END-CORNER-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CORNERS.
*> USING chunk x, chunk z: the 3 x 33 x 3 corner values 0.64 * A_blend of the chunk (5.1): corner columns at x = 16 cx + 8 i, z = 16 cz + 8 k, rows at
*> y = 4 j. S = end/islands (slice y 0) + end/base_3d_noise; the noise is not evaluated where the bottom alpha is 0 (y <= 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ISLAND              FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
             COMPUTE WS-X = L-CX * 16 + 8 * WS-I
             COMPUTE WS-Z = L-CZ * 16 + 8 * WS-K
             CALL "END-ISLANDS" USING WS-X WS-Z WS-ISLAND
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 32
                 COMPUTE WS-Y = 4 * WS-J
                 MOVE 0 TO WS-S
                 IF WS-Y > 4
                     CALL "END-BLENDED" USING WS-X WS-Y WS-Z WS-N
                     CALL "DENSITY-F32" USING WS-OP-ADD WS-ISLAND WS-N WS-S
                 END-IF
                 COMPUTE WS-IDX = (WS-I * 3 + WS-K) * 33 + WS-J + 1
                 CALL "END-CORNER-VALUE" USING WS-Y WS-S EN-CORNER(WS-IDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-COLUMN.
*> USING local x, local z (0 to 15): the 128 squeezed densities of the column into EN-COL (index y + 1) by the block-step fill of nether-37-2.cob
*> NETHER-COLUMN with cells of 8 x 4 x 8: along z, then x, then up the cell by adding the float step (p1 - p0) * 0.25 once per block. Needs END-CORNERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
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
     DIVIDE L-LX BY 8 GIVING WS-CI REMAINDER WS-DX
     DIVIDE L-LZ BY 8 GIVING WS-CK REMAINDER WS-DZ
     MOVE WS-DX TO WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-EIGHTH WS-FX
     MOVE WS-DZ TO WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-EIGHTH WS-FZ
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 31
         COMPUTE WS-A = (WS-CI * 3 + WS-CK) * 33 + WS-J + 1
         COMPUTE WS-B = (WS-CI * 3 + WS-CK + 1) * 33 + WS-J + 1
         MOVE EN-CORNER(WS-A) TO WS-CA
         MOVE EN-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U00
         COMPUTE WS-A = (WS-CI * 3 + WS-CK) * 33 + WS-J + 2
         COMPUTE WS-B = (WS-CI * 3 + WS-CK + 1) * 33 + WS-J + 2
         MOVE EN-CORNER(WS-A) TO WS-CA
         MOVE EN-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U01
         COMPUTE WS-A = ((WS-CI + 1) * 3 + WS-CK) * 33 + WS-J + 1
         COMPUTE WS-B = ((WS-CI + 1) * 3 + WS-CK + 1) * 33 + WS-J + 1
         MOVE EN-CORNER(WS-A) TO WS-CA
         MOVE EN-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U10
         COMPUTE WS-A = ((WS-CI + 1) * 3 + WS-CK) * 33 + WS-J + 2
         COMPUTE WS-B = ((WS-CI + 1) * 3 + WS-CK + 1) * 33 + WS-J + 2
         MOVE EN-CORNER(WS-A) TO WS-CA
         MOVE EN-CORNER(WS-B) TO WS-CB
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FZ WS-CA WS-CB WS-U11
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FX WS-U00 WS-U10 WS-P0
         CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-FX WS-U01 WS-U11 WS-P1
         CALL "DENSITY-F32" USING WS-OP-SUB WS-P1 WS-P0 WS-DIFF
         CALL "DENSITY-F32" USING WS-OP-MUL WS-DIFF WS-QUARTER WS-STEP
         MOVE WS-P0 TO WS-V
         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 3
             COMPUTE WS-A = WS-J * 4 + WS-DY + 1
             CALL "NETHER-SQUEEZE" USING WS-V EN-COL(WS-A)
             CALL "DENSITY-F32" USING WS-OP-ADD WS-V WS-STEP WS-V2
             MOVE WS-V2 TO WS-V
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-FILL.
*> USING chunk memory (CELLS.cpy): end_stone where the squeezed density is above 0, y 0 to 127 only (5.2: no aquifer, the substance of an empty cell is
*> air). Needs END-CORNERS and END-STATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY END.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             CALL "END-COLUMN" USING WS-LX WS-LZ
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
                 COMPUTE WS-I = WS-Y + 1
                 CALL "FCMP-GT" USING EN-COL(WS-I) WS-ZERO WS-GT
                 IF WS-GT = 1
                     COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE EN-S-END-STONE TO CE-STATE(WS-CELL)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SURFACE-STATE.
*> USING state out: the surface rule minecraft:end (6) yields end_stone for every position it is asked about.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE.
     MOVE EN-S-END-STONE TO L-STATE
     GOBACK.
 END PROGRAM END-SURFACE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-SURFACE.
*> USING chunk memory: the surface pass of the End (6): every solid block already is end_stone, so it replaces each non-air cell by the rule's result (the
*> same state) and changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-STATE               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     CALL "END-SURFACE-STATE" USING WS-STATE
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 32768
         IF CE-STATE(WS-CELL) NOT = 0
             MOVE WS-STATE TO CE-STATE(WS-CELL)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-BIOME-OF.
*> USING section x, section z (BINARY-LONG), index out (1 the_end, 2 end_highlands, 3 end_midlands, 4 small_end_islands, 5 end_barrens): 7 steps 3 to 5.
*> Inside sx * sx + sz * sz <= 4096 it is the_end; else e = end/islands at ((2 sx + 1) * 8, (2 sz + 1) * 8): e > 0.25 highlands, e >= -0.0625
*> midlands, e < -0.21875 small_end_islands, else barrens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 01 WS-MID                 FLOAT-LONG VALUE -0.0625.
 01 WS-LOW                 FLOAT-LONG VALUE -0.21875.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SZ L-INDEX.
     COMPUTE WS-D2 = L-SX * L-SX + L-SZ * L-SZ
     IF WS-D2 <= 4096
         MOVE 1 TO L-INDEX
         GOBACK
     END-IF
     COMPUTE WS-X = (L-SX * 2 + 1) * 8
     COMPUTE WS-Z = (L-SZ * 2 + 1) * 8
     CALL "END-ISLANDS" USING WS-X WS-Z WS-E
     CALL "FCMP-GT" USING WS-E WS-HIGH WS-GT
     IF WS-GT = 1
         MOVE 2 TO L-INDEX
         GOBACK
     END-IF
     CALL "FCMP-GT" USING WS-MID WS-E WS-GT
     IF WS-GT = 0
         MOVE 3 TO L-INDEX
         GOBACK
     END-IF
     CALL "FCMP-GT" USING WS-LOW WS-E WS-GT
     IF WS-GT = 1
         MOVE 4 TO L-INDEX
     ELSE
         MOVE 5 TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM END-BIOME-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-BIOME-STORE.
*> USING chunk memory, chunk x, chunk z: the biome of every 4 x 4 x 4 cell of the chunk (the source's answer depends on the chunk only, 7 notes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY END.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-CX L-CZ.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     CALL "END-BIOME-OF" USING L-CX L-CZ WS-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE EN-BIOME-ID(WS-INDEX) TO CE-BIOME(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM END-BIOME-STORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GEN-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE -1 TO L-MARKER-Y
     MOVE LOW-VALUES TO CE-STATES
     MOVE LOW-VALUES TO CE-BIOMES
     CALL "END-SETUP" USING L-SEED
     CALL "END-STATES"
     CALL "END-CORNERS" USING L-CX L-CZ
     CALL "END-FILL" USING L-CHUNK
     CALL "END-SURFACE" USING L-CHUNK
     CALL "END-BIOME-STORE" USING L-CHUNK L-CX L-CZ
     GOBACK.
 END PROGRAM END-GEN-CHUNK.
