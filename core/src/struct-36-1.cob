*> Structures, part 1 (docs/protocol/36-structures-1-model-placement-starts.md sections 2, 4 and 5; STRUCTDATA.cpy, STRUCTENUM.cpy): the code-defined registries and enums,
*> the placement engines (random_spread, concentric_rings, dimension_origin, frequency reduction, exclusion zones, locate position), which structure starts in a chunk (the
*> weighted choice of a set, the biome check of the stub position, the gate of the structures that are on) and the hook of the generation pipeline. Random sources are the Java LCG
*> of rng-java.cob (WorldgenRandom over LegacyRandomSource(0), 10 section 2.6). The level seed is a signed 64-bit BINARY-DOUBLE; the sums of the seeding formulas run in COMPUTE's
*> wide intermediate precision and are reduced modulo 2^64. Doubles go through the cc_f64_* shim functions (exact IEEE operations, Math.cos, Math.sin, Math.round).
*> Not here (the rest of 36-1, later sub-batches): the generic stub is the chunk's middle column at y 0 until the per-structure generators (36-3 to 36-10) give findGenerationPoint,
*> so no pieces are built and an existing start of the chunk is not looked up (no chunk storage of starts yet); the dimension origin is chunk (0, 0) (the noise generator's spawn
*> target, Open question 1, is not read); a cycle of exclusion zones between sets would not end (4.5: no data does it).
*>
*> Entry points:
*>   STRUCT-ENUM-ID USING kind (1 to 8, STRUCTENUM.cpy), name (PIC X(40), namespace optional), id out (-1 when the registry has no such name): the registration index; a piece
*>     name is lower-cased and nvi, pcp, bastionremnant and runtime load as jigsaw (6.7)
*>   STRUCT-ENUM-NAME USING kind, id, name out (PIC X(40), spaces when the id is not in the registry)
*>   STRUCT-POTENTIAL USING set, seed (BINARY-DOUBLE), chunk x, chunk z, potential x out, potential z out: 4.3, the potential structure chunk of the chunk's spacing cell
*>   STRUCT-FREQ-OK USING set, seed, chunk x, chunk z, flag out: 4.4 and step 2 of 4.2
*>   STRUCT-IS-CHUNK USING set, seed, chunk x, chunk z, flag out: isStructureChunk (4.2), RECURSIVE through the exclusion zone
*>   STRUCT-IN-RANGE USING set, seed, chunk x, chunk z, radius, flag out: hasStructureChunkInRange (4.1)
*>   STRUCT-RINGS-RAW USING distance, spread, count, seed (BINARY-DOUBLE UNSIGNED), table (256 rows of x, z, fork seed): 4.6 positions before the biome snap
*>   STRUCT-RING-SNAP USING ring x, ring z, set, fork seed, chunk x out, chunk z out: 4.6.1 the biome search of one position
*>   STRUCT-RINGS-BUILD USING set, seed: builds the ring list of a rings set for the seed (SD-RING row of SS-RING-ROW); STRUCT-RING-HAS tests membership (building on demand)
*>   STRUCT-ORIGIN USING chunk x out, chunk z out; STRUCT-LOCATE-POS USING set, chunk x, chunk z, x out, y out, z out (4.8)
*>   STRUCT-POSSIBLE-BUILD: SS-POSSIBLE of every set from the climate points (4.1)
*>   STRUCT-QUART USING block coordinate, quart cell out; STRUCT-BIOME-OK USING structure, biome, flag; STRUCT-VALID-AT USING structure, x, y, z, flag (5.1 isValidBiome)
*>   STRUCT-ENTRY-ORDER USING set, seed, chunk x, chunk z, order out (64 entry numbers within the set), count out: the order in which 5.2 tries the entries if each fails
*>   STRUCT-GATE USING key (PIC X(80)), flag out; STRUCT-GATE-ON USING key; STRUCT-GATE-RESET: the structures that are on (none by default)
*>   STRUCT-CHUNK-STARTS USING seed, chunk x, chunk z, count out: the starts of the chunk in SD-START (5.2); STRUCT-STAGE-HOOK USING job: the pipeline hook (no-op without a gate)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ENUM-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTENUM.
 01 WS-NAME                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-NAME L-ID.
     MOVE -1 TO L-ID
     MOVE L-NAME TO WS-NAME
     IF L-NAME(1:10) = "minecraft:"
         MOVE SPACES TO WS-NAME
         MOVE L-NAME(11:30) TO WS-NAME
     END-IF
     IF L-KIND = 3
         MOVE FUNCTION LOWER-CASE(WS-NAME) TO WS-NAME
         IF WS-NAME = "nvi" OR WS-NAME = "pcp" OR WS-NAME = "bastionremnant" OR WS-NAME = "runtime"
             MOVE "jigsaw" TO WS-NAME
         END-IF
     END-IF
     MOVE EB-FIRST(L-KIND) TO WS-FIRST
     MOVE EB-COUNT(L-KIND) TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF EN-NAME(WS-FIRST + WS-I) = WS-NAME
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-ENUM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ENUM-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTENUM.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-KIND L-ID L-NAME.
     MOVE SPACES TO L-NAME
     MOVE EB-FIRST(L-KIND) TO WS-FIRST
     MOVE EB-COUNT(L-KIND) TO WS-COUNT
     IF L-ID >= 0 AND L-ID < WS-COUNT
         MOVE EN-NAME(WS-FIRST + L-ID + 1) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM STRUCT-ENUM-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-SALT-SEED.
*> USING state out (the Java LCG state), seed (BINARY-DOUBLE), rx, rz, salt: setLargeFeatureWithSalt (4.3): setSeed(rx * 341873128712 + rz * 132897987541 + seed + salt), 64-bit wrap.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-RX                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-SALT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SEED L-RX L-RZ L-SALT.
     COMPUTE WS-V = FUNCTION MOD(L-RX * 341873128712 + L-RZ * 132897987541 + L-SEED + L-SALT, WS-M64)
     CALL "JRAND-SET-SEED" USING L-STATE WS-V
     GOBACK.
 END PROGRAM STRUCT-SALT-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-POTENTIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-PX L-PZ.
     COMPUTE WS-RX = FUNCTION INTEGER(L-CX / SS-SPACING(L-SET))
     COMPUTE WS-RZ = FUNCTION INTEGER(L-CZ / SS-SPACING(L-SET))
     CALL "STRUCT-SALT-SEED" USING WS-STATE L-SEED WS-RX WS-RZ SS-SALT(L-SET)
     COMPUTE WS-LIMIT = SS-SPACING(L-SET) - SS-SEPARATION(L-SET)
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-DX
     IF SS-SPREAD(L-SET) = 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-B
         COMPUTE WS-SUM = WS-DX + WS-B
         DIVIDE WS-SUM BY 2 GIVING WS-DX
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-DZ
     IF SS-SPREAD(L-SET) = 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-A
         COMPUTE WS-SUM = WS-DZ + WS-A
         DIVIDE WS-SUM BY 2 GIVING WS-DZ
     END-IF
     COMPUTE L-PX = WS-RX * SS-SPACING(L-SET) + WS-DX
     COMPUTE L-PZ = WS-RZ * SS-SPACING(L-SET) + WS-DZ
     GOBACK.
 END PROGRAM STRUCT-POTENTIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-FREQ-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FREQ32              FLOAT-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-QUOT                FLOAT-LONG.
 01 WS-QUOT32              FLOAT-LONG.
 01 WS-MAX-INT             FLOAT-LONG VALUE 2147483647.
 01 WS-BOUND               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-RZ16                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 10387320.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-DISCARD             BINARY-DOUBLE.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-FLAG.
     MOVE 1 TO L-FLAG
     IF SS-FREQ(L-SET) >= 1.0
         GOBACK
     END-IF
     MOVE 0 TO L-FLAG
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE SS-FREQ(L-SET) WS-FREQ32
     COMPUTE WS-SEED-U = FUNCTION MOD(L-SEED, WS-M64)
     EVALUATE SS-METHOD(L-SET)
         WHEN 0
             CALL "STRUCT-SALT-SEED" USING WS-STATE L-SEED L-CX L-CZ SS-SALT(L-SET)
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-DRAW
             IF WS-DRAW < WS-FREQ32
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN 1
*>           the cell of 16 chunks, ((rx xor (rz << 4)) widened) xor the seed, one nextInt() discarded, then nextInt(trunc(1.0f / frequency)) == 0
             COMPUTE WS-RX = FUNCTION INTEGER(L-CX / 16)
             COMPUTE WS-RZ = FUNCTION INTEGER(L-CZ / 16)
             COMPUTE WS-RZ16 = WS-RZ * 16
             COMPUTE WS-A = FUNCTION MOD(WS-RX, WS-M64)
             COMPUTE WS-B = FUNCTION MOD(WS-RZ16, WS-M64)
             CALL "CBL_XOR" USING WS-A WS-B BY VALUE 8
             CALL "CBL_XOR" USING WS-SEED-U WS-B BY VALUE 8
             CALL "JRAND-SET-SEED" USING WS-STATE WS-B
             CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-DISCARD
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE WS-FREQ32 WS-QUOT
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-QUOT WS-QUOT32
             COMPUTE WS-BOUND = FUNCTION MIN(WS-QUOT32, WS-MAX-INT)
             CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-RESULT
             IF WS-RESULT = 0
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN 2
             CALL "STRUCT-SALT-SEED" USING WS-STATE L-SEED L-CX L-CZ WS-SALT
             CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-DRAW
             IF WS-DRAW < WS-FREQ32
                 MOVE 1 TO L-FLAG
             END-IF
         WHEN OTHER
             CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-SEED-U L-CX L-CZ
             CALL "STRUCT-NEXT-DOUBLE" USING WS-STATE WS-DRAW
             IF WS-DRAW < WS-FREQ32
                 MOVE 1 TO L-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-FREQ-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-NEXT-DOUBLE.
*> USING state, value out (FLOAT-LONG): nextDouble() of the legacy source: (next(26) * 2^27 + next(27)) * 2^-53 (exact: the numerator is below 2^53).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B26                 BINARY-LONG VALUE 26.
 01 WS-B27                 BINARY-LONG VALUE 27.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-N                   BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 9007199254740992.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-VALUE.
     CALL "JRAND-NEXT" USING L-STATE WS-B26 WS-HI
     CALL "JRAND-NEXT" USING L-STATE WS-B27 WS-LO
     COMPUTE WS-N = WS-HI * 134217728 + WS-LO
     MOVE WS-N TO WS-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-F WS-SCALE L-VALUE
     GOBACK.
 END PROGRAM STRUCT-NEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ORIGIN.
*> USING chunk x out, chunk z out: the chunk of a dimension_origin placement (4.1): (0, 0), the base generator's origin.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     MOVE 0 TO L-CX L-CZ
     GOBACK.
 END PROGRAM STRUCT-ORIGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IS-CHUNK IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 LOCAL-STORAGE SECTION.
 01 LS-OX                  BINARY-LONG.
 01 LS-OZ                  BINARY-LONG.
 01 LS-PX                  BINARY-LONG.
 01 LS-PZ                  BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-IN                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-FLAG.
     MOVE 0 TO L-FLAG LS-OK
     IF SS-KIND(L-SET) = 1
         CALL "STRUCT-ORIGIN" USING LS-OX LS-OZ
         IF L-CX = LS-OX AND L-CZ = LS-OZ
             MOVE 1 TO L-FLAG
         END-IF
         GOBACK
     END-IF
     IF SS-KIND(L-SET) = 2
         CALL "STRUCT-POTENTIAL" USING L-SET L-SEED L-CX L-CZ LS-PX LS-PZ
         IF LS-PX = L-CX AND LS-PZ = L-CZ
             MOVE 1 TO LS-OK
         END-IF
     ELSE
         CALL "STRUCT-RING-HAS" USING L-SET L-SEED L-CX L-CZ LS-OK
     END-IF
     IF LS-OK = 0
         GOBACK
     END-IF
     CALL "STRUCT-FREQ-OK" USING L-SET L-SEED L-CX L-CZ LS-OK
     IF LS-OK = 0
         GOBACK
     END-IF
     IF SS-EX-SET(L-SET) > 0
         CALL "STRUCT-IN-RANGE" USING SS-EX-SET(L-SET) L-SEED L-CX L-CZ SS-EX-COUNT(L-SET) LS-IN
         IF LS-IN = 1
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO L-FLAG
     GOBACK.
 END PROGRAM STRUCT-IS-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IN-RANGE IS RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-X                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-FROM-X              BINARY-LONG.
 01 LS-FROM-Z              BINARY-LONG.
 01 LS-TO-X                BINARY-LONG.
 01 LS-TO-Z                BINARY-LONG.
 01 LS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-R L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE LS-FROM-X = L-CX - L-R
     COMPUTE LS-FROM-Z = L-CZ - L-R
     COMPUTE LS-TO-X = L-CX + L-R
     COMPUTE LS-TO-Z = L-CZ + L-R
     PERFORM VARYING LS-X FROM LS-FROM-X BY 1 UNTIL LS-X > LS-TO-X OR L-FLAG = 1
         PERFORM VARYING LS-Z FROM LS-FROM-Z BY 1 UNTIL LS-Z > LS-TO-Z OR L-FLAG = 1
             CALL "STRUCT-IS-CHUNK" USING L-SET L-SEED LS-X LS-Z LS-FLAG
             IF LS-FLAG = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-LOCATE-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-CX L-CZ L-X L-Y L-Z.
     COMPUTE L-X = L-CX * 16 + SS-LOC-X(L-SET)
     MOVE SS-LOC-Y(L-SET) TO L-Y
     COMPUTE L-Z = L-CZ * 16 + SS-LOC-Z(L-SET)
     GOBACK.
 END PROGRAM STRUCT-LOCATE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RINGS-RAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PI-TEXT             PIC X(18).
 01 WS-PI                  FLOAT-LONG.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-TWO-HALF            FLOAT-LONG VALUE 2.5.
 01 WS-TWO-PI              FLOAT-LONG.
 01 WS-R                   BINARY-DOUBLE UNSIGNED.
 01 WS-R2                  BINARY-DOUBLE UNSIGNED.
 01 WS-D                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DIST-F              FLOAT-LONG.
 01 WS-SPAN                FLOAT-LONG.
 01 WS-BASE-F              FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-S-F                 FLOAT-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RING                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-RING-1              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RX                  BINARY-DOUBLE.
 01 WS-RZ                  BINARY-DOUBLE.
 01 WS-FORK                BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-RAW.
    05 L-ROW OCCURS 256 TIMES.
       10 L-X              BINARY-LONG.
       10 L-Z              BINARY-LONG.
       10 L-FORK           BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-DISTANCE L-SPREAD L-COUNT L-SEED L-RAW.
     MOVE SPACES TO WS-PI-TEXT
     MOVE "3.141592653589793" TO WS-PI-TEXT
     MOVE LOW-VALUES TO WS-PI-TEXT(18:1)
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-PI-TEXT WS-PI
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-PI WS-TWO WS-TWO-PI
     MOVE L-DISTANCE TO WS-DIST-F
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DIST-F WS-TWO-HALF WS-SPAN
     MOVE L-SEED TO WS-R2
     CALL "JRAND-SET-SEED" USING WS-R WS-R2
     CALL "STRUCT-NEXT-DOUBLE" USING WS-R WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-PI WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-TWO WS-ANGLE
     MOVE 0 TO WS-RING WS-POS
     MOVE L-SPREAD TO WS-S
     MOVE L-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-BASE = 4 * L-DISTANCE + L-DISTANCE * WS-RING * 6
         MOVE WS-BASE TO WS-BASE-F
         CALL "STRUCT-NEXT-DOUBLE" USING WS-R WS-D
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-D WS-HALF WS-T
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-SPAN WS-U
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-BASE-F WS-U WS-RADIUS
         CALL STATIC "cc_f64_cos" USING BY REFERENCE WS-ANGLE WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C WS-RADIUS WS-V
         CALL STATIC "cc_f64_round_f64" USING BY REFERENCE WS-V WS-RX
         CALL STATIC "cc_f64_sin" USING BY REFERENCE WS-ANGLE WS-C
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-C WS-RADIUS WS-V
         CALL STATIC "cc_f64_round_f64" USING BY REFERENCE WS-V WS-RZ
         CALL "JRAND-NEXT-LONG" USING WS-R WS-FORK
         MOVE WS-RX TO L-X(WS-I + 1)
         MOVE WS-RZ TO L-Z(WS-I + 1)
         MOVE WS-FORK TO L-FORK(WS-I + 1)
         MOVE WS-S TO WS-S-F
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-TWO-PI WS-S-F WS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ANGLE WS-T WS-U
         MOVE WS-U TO WS-ANGLE
         ADD 1 TO WS-POS
         IF WS-POS = WS-S
             ADD 1 TO WS-RING
             MOVE 0 TO WS-POS
             COMPUTE WS-RING-1 = WS-RING + 1
             COMPUTE WS-LEFT = 2 * WS-S
             DIVIDE WS-LEFT BY WS-RING-1 GIVING WS-ADD
             ADD WS-ADD TO WS-S
             COMPUTE WS-LEFT = WS-N - WS-I
             IF WS-LEFT < WS-S
                 MOVE WS-LEFT TO WS-S
             END-IF
             CALL "STRUCT-NEXT-DOUBLE" USING WS-R WS-D
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-PI WS-T
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-TWO WS-U
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ANGLE WS-U WS-T
             MOVE WS-T TO WS-ANGLE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-RINGS-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RING-SNAP.
*> USING ring x, ring z, set, fork seed (BINARY-DOUBLE UNSIGNED), chunk x out, chunk z out: findBiomeHorizontal at the block (rx * 16 + 8, 0, rz * 16 + 8) with radius 112
*> (quart radius 28, every cell of the square, z outer) and the predicate "preferred_biomes has the biome": reservoir sampling with the forked source (the first
*> qualifying cell draws nothing, each later one one nextInt(k + 1)); the result is the chunk of the chosen cell, the ring position itself when no cell qualifies.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-BLOCK-X             BINARY-LONG.
 01 WS-BLOCK-Z             BINARY-LONG.
 01 WS-QX0                 BINARY-LONG.
 01 WS-QZ0                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG VALUE 0.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RX                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-FORK                 BINARY-DOUBLE UNSIGNED.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RX L-RZ L-SET L-FORK L-CX L-CZ.
     CALL "JRAND-SET-SEED" USING WS-STATE L-FORK
     COMPUTE WS-BLOCK-X = L-RX * 16 + 8
     COMPUTE WS-BLOCK-Z = L-RZ * 16 + 8
     CALL "STRUCT-QUART" USING WS-BLOCK-X WS-QX0
     CALL "STRUCT-QUART" USING WS-BLOCK-Z WS-QZ0
     MOVE 0 TO WS-K
     MOVE L-RX TO L-CX
     MOVE L-RZ TO L-CZ
     PERFORM VARYING WS-DZ FROM -28 BY 1 UNTIL WS-DZ > 28
         PERFORM VARYING WS-DX FROM -28 BY 1 UNTIL WS-DX > 28
             COMPUTE WS-QX = WS-QX0 + WS-DX
             COMPUTE WS-QZ = WS-QZ0 + WS-DZ
             CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
             MOVE 0 TO WS-HIT
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= SS-PREF-COUNT(L-SET)
                 IF SD-BIOME(SS-PREF-FIRST(L-SET) + WS-J) = WS-BIOME
                     MOVE 1 TO WS-HIT
                 END-IF
             END-PERFORM
             IF WS-HIT = 1
                 IF WS-K = 0
                     COMPUTE L-CX = FUNCTION INTEGER(WS-QX / 4)
                     COMPUTE L-CZ = FUNCTION INTEGER(WS-QZ / 4)
                 ELSE
                     COMPUTE WS-BOUND = WS-K + 1
                     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-DRAW
                     IF WS-DRAW = 0
                         COMPUTE L-CX = FUNCTION INTEGER(WS-QX / 4)
                         COMPUTE L-CZ = FUNCTION INTEGER(WS-QZ / 4)
                     END-IF
                 END-IF
                 ADD 1 TO WS-K
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-RING-SNAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RINGS-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-RAW.
    05 WS-RAW-ROW OCCURS 256 TIMES.
       10 WS-RAW-X         BINARY-LONG.
       10 WS-RAW-Z         BINARY-LONG.
       10 WS-RAW-FORK      BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SET L-SEED.
     MOVE SS-RING-ROW(L-SET) TO WS-ROW
     IF WS-ROW = 0
         COMPUTE WS-ROW = FUNCTION MIN(SD-RING-COUNT + 1, SD-MAX-RINGS)
         MOVE WS-ROW TO SD-RING-COUNT
         MOVE WS-ROW TO SS-RING-ROW(L-SET)
     END-IF
     COMPUTE WS-SEED-U = FUNCTION MOD(L-SEED, WS-M64)
     MOVE FUNCTION MIN(SS-RING-COUNT(L-SET), SD-MAX-RING-POS) TO WS-N
     CALL "STRUCT-RINGS-RAW" USING SS-DISTANCE(L-SET) SS-RING-SPREAD(L-SET) WS-N WS-SEED-U WS-RAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "STRUCT-RING-SNAP" USING WS-RAW-X(WS-I) WS-RAW-Z(WS-I) L-SET WS-RAW-FORK(WS-I) WS-CX WS-CZ
         MOVE WS-CX TO SR-X(WS-ROW, WS-I)
         MOVE WS-CZ TO SR-Z(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-N TO SR-N(WS-ROW)
     MOVE L-SET TO SR-SET(WS-ROW)
     MOVE L-SEED TO SR-SEED(WS-ROW)
     GOBACK.
 END PROGRAM STRUCT-RINGS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RING-HAS.
*> USING set, seed, chunk x, chunk z, flag out: 1 when the chunk is in the set's ring list for the seed (built when absent, or built for another seed or set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STALE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE SS-RING-ROW(L-SET) TO WS-ROW
     MOVE 1 TO WS-STALE
     IF WS-ROW > 0
         IF SR-SET(WS-ROW) = L-SET AND SR-SEED(WS-ROW) = L-SEED
             MOVE 0 TO WS-STALE
         END-IF
     END-IF
     IF WS-STALE = 1
         CALL "STRUCT-RINGS-BUILD" USING L-SET L-SEED
         MOVE SS-RING-ROW(L-SET) TO WS-ROW
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(WS-ROW) OR L-FLAG = 1
         IF SR-X(WS-ROW, WS-I) = L-CX AND SR-Z(WS-ROW, WS-I) = L-CZ
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-RING-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-QUART.
*> USING block coordinate, quart cell out: coordinate >> 2 (floor division, negative blocks go to negative cells).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    BINARY-LONG.
 01 L-Q                    BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-Q.
     COMPUTE L-Q = FUNCTION INTEGER(L-V / 4)
     GOBACK.
 END PROGRAM STRUCT-QUART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BIOME-OK.
*> USING structure row, biome key (PIC X(40)), flag out: 1 when the structure's biomes contain the biome (the validBiome predicate of 5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-BIOME                PIC X(40).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-BIOME L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= SDT-BIOME-COUNT(L-STRUCT)
         IF SD-BIOME(SDT-BIOME-FIRST(L-STRUCT) + WS-J) = L-BIOME
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-BIOME-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-VALID-AT.
*> USING structure row, x, y, z (block position of a stub), flag out: isValidBiome(stub): the biome of the multi-noise source at the quart cell (x >> 2, y >> 2, z >> 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-X L-Y L-Z L-FLAG.
     CALL "STRUCT-QUART" USING L-X WS-QX
     CALL "STRUCT-QUART" USING L-Y WS-QY
     CALL "STRUCT-QUART" USING L-Z WS-QZ
     CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
     CALL "STRUCT-BIOME-OK" USING L-STRUCT WS-BIOME L-FLAG
     GOBACK.
 END PROGRAM STRUCT-VALID-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-POSSIBLE-BUILD.
*> SS-POSSIBLE of every loaded set: 1 when at least one structure of the set has at least one biome that is one of the climate points' biomes (the biome source's possible set, 4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY CLIMATE.
 01 WS-S                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO SS-POSSIBLE(WS-S)
         PERFORM VARYING WS-E FROM 0 BY 1 UNTIL WS-E >= SS-EN-COUNT(WS-S)
             MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-E) TO WS-ST
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= SDT-BIOME-COUNT(WS-ST)
                 PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CL-COUNT
                     IF CL-BIOME(WS-P) = SD-BIOME(SDT-BIOME-FIRST(WS-ST) + WS-J)
                         MOVE 1 TO SS-POSSIBLE(WS-S)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO SD-POSS-DONE
     ADD 1 TO SD-EPOCH
     GOBACK.
 END PROGRAM STRUCT-POSSIBLE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ENTRY-ORDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 01 WS-N                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-GONE.
    05 WS-GONE-FLAG        BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ORDER.
    05 L-ORDER-ENTRY       BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-SEED L-CX L-CZ L-ORDER L-COUNT.
     MOVE FUNCTION MIN(SS-EN-COUNT(L-SET), 64) TO WS-N
     MOVE 0 TO L-COUNT WS-TOTAL
     IF WS-N = 1
*>       a set with one entry tries it alone: no draw
         MOVE 1 TO L-ORDER-ENTRY(1)
         MOVE 1 TO L-COUNT
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE 0 TO WS-GONE-FLAG(WS-I)
         ADD SE-WEIGHT(SS-EN-FIRST(L-SET) + WS-I - 1) TO WS-TOTAL
     END-PERFORM
     COMPUTE WS-SEED-U = FUNCTION MOD(L-SEED, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-SEED-U L-CX L-CZ
     PERFORM UNTIL L-COUNT >= WS-N
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-TOTAL WS-R
         MOVE 0 TO WS-DONE WS-J
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-DONE = 1
             IF WS-GONE-FLAG(WS-I) = 0
                 SUBTRACT SE-WEIGHT(SS-EN-FIRST(L-SET) + WS-I - 1) FROM WS-R
                 IF WS-R < 0
                     MOVE 1 TO WS-DONE
                     MOVE WS-I TO WS-J
                 END-IF
             END-IF
         END-PERFORM
         MOVE 1 TO WS-GONE-FLAG(WS-J)
         SUBTRACT SE-WEIGHT(SS-EN-FIRST(L-SET) + WS-J - 1) FROM WS-TOTAL
         ADD 1 TO L-COUNT
         MOVE WS-J TO L-ORDER-ENTRY(L-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-ENTRY-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-GATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-GATE-COUNT
         IF SD-GATE(WS-I) = L-KEY
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-GATE-ON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 PROCEDURE DIVISION USING L-KEY.
     CALL "STRUCT-GATE" USING L-KEY WS-FLAG
     IF WS-FLAG = 0 AND SD-GATE-COUNT < SD-MAX-GATE
         ADD 1 TO SD-GATE-COUNT
         ADD 1 TO SD-EPOCH
         MOVE L-KEY TO SD-GATE(SD-GATE-COUNT)
     END-IF
     GOBACK.
 END PROGRAM STRUCT-GATE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-GATE-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 PROCEDURE DIVISION.
     MOVE 0 TO SD-GATE-COUNT
     ADD 1 TO SD-EPOCH
     GOBACK.
 END PROGRAM STRUCT-GATE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHUNK-STARTS-RAW.
*> USING seed (BINARY-DOUBLE), chunk x, chunk z, count out: 5.2 for each set whose structures the biome source can make, in set order: a set that is not holding a start in this chunk
*> (isStructureChunk) makes none; else the entries are tried in the chooser's order (STRUCT-ENTRY-ORDER); an entry that is off in the gate or whose stub position fails the biome
*> check fails and the next is tried; the first that passes is the set's start (SD-START: set, structure, stub x, y 0, z at the chunk's middle). At most one start per set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ORDER.
    05 WS-ORDER-ENTRY      BINARY-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-COUNT.
     MOVE 0 TO SD-START-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO WS-ANY
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
             MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
             MOVE SDT-KEY(WS-ST) TO WS-KEY
             CALL "STRUCT-GATE" USING WS-KEY WS-ON
             IF WS-ON = 1
                 MOVE 1 TO WS-ANY
             END-IF
         END-PERFORM
         IF SS-POSSIBLE(WS-S) = 1 AND WS-ANY = 1
             CALL "STRUCT-IS-CHUNK" USING WS-S L-SEED L-CX L-CZ WS-FLAG
             IF WS-FLAG = 1
                 CALL "STRUCT-ENTRY-ORDER" USING WS-S L-SEED L-CX L-CZ WS-ORDER WS-N
                 MOVE 0 TO WS-DONE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N OR WS-DONE = 1
                     MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-ORDER-ENTRY(WS-K) - 1) TO WS-ST
                     MOVE SDT-KEY(WS-ST) TO WS-KEY
                     CALL "STRUCT-GATE" USING WS-KEY WS-ON
                     MOVE 0 TO WS-VALID
                     IF WS-ON = 1
                         CALL "STRUCT-FIND-POINT" USING WS-ST L-SEED L-CX L-CZ WS-X WS-Y WS-Z WS-VALID
                         IF WS-VALID = 1
                             CALL "STRUCT-VALID-AT" USING WS-ST WS-X WS-Y WS-Z WS-VALID
                         END-IF
                     END-IF
                     IF WS-VALID = 1
                         ADD 1 TO SD-START-COUNT
                         MOVE WS-S TO SC-SET(SD-START-COUNT)
                         MOVE WS-ST TO SC-STRUCT(SD-START-COUNT)
                         MOVE WS-X TO SC-X(SD-START-COUNT)
                         MOVE WS-Y TO SC-Y(SD-START-COUNT)
                         MOVE WS-Z TO SC-Z(SD-START-COUNT)
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     MOVE SD-START-COUNT TO L-COUNT
     GOBACK.
 END PROGRAM STRUCT-CHUNK-STARTS-RAW.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-CHUNK-STARTS.
*> USING seed (BINARY-DOUBLE), chunk x, chunk z, count out: the starts of the chunk (STRUCT-CHUNK-STARTS-RAW), answered from the start list cache when the chunk was asked for under the same seed,
*> content and noise generation, structure data epoch (SD-EPOCH: data, gate and possible sets) and test aid of the jigsaw surface. The starts of a chunk are a pure function of those, so a
*> cached answer is the answer the engine would make (docs/design/world-types.md structures part 8); a chunk of more than SD-CACHE-STARTS starts is never kept. The rows SC-* of the answer are
*> left in SD-START as the engine leaves them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 COPY CTWORLDGEN.
 COPY NOISE.
 01 WS-GEN                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-COUNT.
     COMPUTE WS-GEN = WG-LOAD-GEN + NZ-GEN
*>   the slot is the chunk's place in a 64 x 64 chunk tile, so any 64 x 64 chunks (a window of 17 x 17 and the whole area around a player) never share one
     COMPUTE WS-SX = FUNCTION MOD(L-CX, 64)
     COMPUTE WS-SZ = FUNCTION MOD(L-CZ, 64)
     COMPUTE WS-SLOT = WS-SX * 64 + WS-SZ + 1
     IF SK-USED(WS-SLOT) = 1 AND SK-CX(WS-SLOT) = L-CX AND SK-CZ(WS-SLOT) = L-CZ AND SK-SEED(WS-SLOT) = L-SEED
        AND SK-GEN(WS-SLOT) = WS-GEN AND SK-EPOCH(WS-SLOT) = SD-EPOCH AND SK-AID(WS-SLOT) = JIG-TEST-SURFACE
         MOVE SK-N(WS-SLOT) TO SD-START-COUNT L-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SK-N(WS-SLOT)
             MOVE SK-SET(WS-SLOT, WS-I) TO SC-SET(WS-I)
             MOVE SK-STRUCT(WS-SLOT, WS-I) TO SC-STRUCT(WS-I)
             MOVE SK-X(WS-SLOT, WS-I) TO SC-X(WS-I)
             MOVE SK-Y(WS-SLOT, WS-I) TO SC-Y(WS-I)
             MOVE SK-Z(WS-SLOT, WS-I) TO SC-Z(WS-I)
         END-PERFORM
         ADD 1 TO SD-CACHE-HITS
         GOBACK
     END-IF
     CALL "STRUCT-CHUNK-STARTS-RAW" USING L-SEED L-CX L-CZ L-COUNT
     ADD 1 TO SD-CACHE-MISSES
     IF L-COUNT <= SD-CACHE-STARTS
         MOVE 1 TO SK-USED(WS-SLOT)
         MOVE L-SEED TO SK-SEED(WS-SLOT)
         MOVE L-CX TO SK-CX(WS-SLOT)
         MOVE L-CZ TO SK-CZ(WS-SLOT)
         MOVE WS-GEN TO SK-GEN(WS-SLOT)
         MOVE SD-EPOCH TO SK-EPOCH(WS-SLOT)
         MOVE JIG-TEST-SURFACE TO SK-AID(WS-SLOT)
         MOVE L-COUNT TO SK-N(WS-SLOT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             MOVE SC-SET(WS-I) TO SK-SET(WS-SLOT, WS-I)
             MOVE SC-STRUCT(WS-I) TO SK-STRUCT(WS-SLOT, WS-I)
             MOVE SC-X(WS-I) TO SK-X(WS-SLOT, WS-I)
             MOVE SC-Y(WS-I) TO SK-Y(WS-SLOT, WS-I)
             MOVE SC-Z(WS-I) TO SK-Z(WS-SLOT, WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM STRUCT-CHUNK-STARTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STAGE-HOOK.
*> USING job (GENJOB.cpy): called by GEN-STAGE-FEATURES at every step of a chunk; does nothing while no structure is gated on (SD-GATE-COUNT 0), and only at step 0 otherwise: builds
*> the possible sets once per load and counts the chunk's starts in SD-STARTS-SEEN (no piece is placed yet: the per-structure generators and the decoration of 36-1 section 8 follow).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY CARVER.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     IF SD-GATE-COUNT = 0
         GOBACK
     END-IF
     IF SD-POSS-DONE = 0
         CALL "STRUCT-POSSIBLE-BUILD"
     END-IF
     IF J-SUB = 0
         COMPUTE WS-SEED = FUNCTION MOD(CV-SEED + WS-M63, WS-M64) - WS-M63
         CALL "STRUCT-CHUNK-STARTS" USING WS-SEED J-CX J-CZ WS-COUNT
         ADD WS-COUNT TO SD-STARTS-SEEN
     END-IF
     CALL "STRUCT-DECORATE" USING L-JOB
     GOBACK.
 END PROGRAM STRUCT-STAGE-HOOK.
