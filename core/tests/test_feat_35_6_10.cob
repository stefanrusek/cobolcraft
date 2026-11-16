*> Implementation test of the fossil feature (docs/protocol/35-worldgen-features-6-underground.md section 10.2 and 10.4; core/src/feat-fossil.cob, registry id 18): the data feature compiles (a list of
*> unequal length, a missing template, an unknown processor list, a limit above 7, a missing overlay list and empty lists make it unsupported) and, over 46 seeds on a shadow array with a second random
*> source, places the fossil as the model of the section does: rotation = nextInt(4), index = nextInt(2), corner = origin + (-size.x / 2, 0, -size.z / 2) over the rotated size, the least floor height of
*> the footprint (columns of the chunk only), one nextInt(10) for base = max(y - 15 - draw, minY + 10), zero = getZeroPositionWithTransform, the box of the transformed template, the empty corner count
*> against the limit (a failing fossil consumes the three draws only), then the fossil and its overlay at the same origin with their processors (iron to gold, diamond to emerald) and one palette draw each.
*> Worlds: solid stone (limit 4), stone with holes (limit 1), a thin crust over air (fails), and an origin at the chunk edge (footprint columns outside the chunk are skipped: documented deviation).
*> Templates and features come from core/tests/fixtures/gen_fossil.py (f1 3 x 2 x 5, f2 2 x 1 x 3, overlays o1, o2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY STRUCTDATA.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/fossil".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-FT-T                BINARY-LONG.
 01 WS-FT-T1               BINARY-LONG.
 01 WS-CUR-FT              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-SH.
    05 WS-OS               BINARY-LONG OCCURS 10496 TIMES.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-GOLD              BINARY-LONG.
 01 WS-S-IRON              BINARY-LONG.
 01 WS-S-DIAMOND           BINARY-LONG.
 01 WS-S-EMERALD           BINARY-LONG.
 01 WS-N-ROT               BINARY-LONG OCCURS 4 TIMES.
 01 WS-N-IDX               BINARY-LONG OCCURS 2 TIMES.
 01 WS-N-OK                BINARY-LONG VALUE 0.
 01 WS-N-FAIL              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-STONE-LO            BINARY-LONG.
*> model state
 01 M-ROT                  BINARY-LONG.
 01 M-IDX                  BINARY-LONG.
 01 M-SX0                  BINARY-LONG.
 01 M-SY                   BINARY-LONG.
 01 M-SZ0                  BINARY-LONG.
 01 M-SX                   BINARY-LONG.
 01 M-SZ                   BINARY-LONG.
 01 M-CX                   BINARY-LONG.
 01 M-CZ                   BINARY-LONG.
 01 M-MINH                 BINARY-LONG.
 01 M-H                    BINARY-LONG.
 01 M-BASE                 BINARY-LONG.
 01 M-ZX                   BINARY-LONG.
 01 M-ZZ                   BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-K                    BINARY-LONG.
 01 M-V                    BINARY-LONG.
 01 M-B2                   BINARY-LONG VALUE 2.
 01 M-B4                   BINARY-LONG VALUE 4.
 01 M-B10                  BINARY-LONG VALUE 10.
 01 M-B1                   BINARY-LONG VALUE 1.
 01 M-LX                   BINARY-LONG.
 01 M-LY                   BINARY-LONG.
 01 M-LZ                   BINARY-LONG.
 01 M-DX                   BINARY-LONG.
 01 M-DZ                   BINARY-LONG.
 01 M-RX                   BINARY-LONG.
 01 M-RZ                   BINARY-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-AX                   BINARY-LONG.
 01 M-AZ                   BINARY-LONG.
 01 M-CX2                  BINARY-LONG.
 01 M-CZ2                  BINARY-LONG.
 01 M-X0                   BINARY-LONG.
 01 M-X1                   BINARY-LONG.
 01 M-Z0                   BINARY-LONG.
 01 M-Z1                   BINARY-LONG.
 01 M-EMPTY                BINARY-LONG.
 01 M-PASS                 BINARY-LONG.
 01 M-N                    BINARY-LONG.
 01 M-COL                  BINARY-LONG.
 01 M-QX                   BINARY-LONG.
 01 M-QY                   BINARY-LONG.
 01 M-QZ                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "core/tests/fixtures/fossil" TO SD-DIR
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "gold_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GOLD
     MOVE "iron_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-IRON
     MOVE "diamond_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIAMOND
     MOVE "emerald_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-EMERALD
     MOVE "minecraft:fossil_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-T
     CALL "FD-ENSURE-FT" USING WS-FT-T
     MOVE "minecraft:fossil_t1" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-T1
     CALL "FD-ENSURE-FT" USING WS-FT-T1
     MOVE "35-6§10.2: the data feature compiles as a fossil (18)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-T) TO WS-OBS
     MOVE 18 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§10.2: the feature with another limit compiles too" TO WS-CASE
     MOVE FT-TYPE(WS-FT-T1) TO WS-OBS
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 46
         COMPUTE WS-SEED = WS-SEEDNO * 3001
         MOVE WS-SEEDNO TO WS-SEEDTXT
         MOVE WS-FT-T TO WS-CUR-FT
         MOVE 4 TO WS-LIMIT
         MOVE 24 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 40 TO WS-Z
         EVALUATE TRUE
             WHEN WS-SEEDNO <= 16
                 MOVE 1 TO WS-KIND
                 IF FUNCTION MOD(WS-SEEDNO, 2) = 0
                     MOVE 62 TO WS-Y
                 END-IF
             WHEN WS-SEEDNO <= 32
                 MOVE 2 TO WS-KIND
                 MOVE WS-FT-T1 TO WS-CUR-FT
                 MOVE 1 TO WS-LIMIT
             WHEN WS-SEEDNO <= 40
                 MOVE 2 TO WS-KIND
                 MOVE 17 TO WS-X
                 MOVE 33 TO WS-Z
             WHEN WS-SEEDNO <= 44
                 MOVE 3 TO WS-KIND
             WHEN OTHER
*>               an origin far below the stone: base is clamped to minY + 10 (the corners are air, so it fails)
                 MOVE 1 TO WS-KIND
                 MOVE -40 TO WS-Y
         END-EVALUATE
         PERFORM NEW-WORLD
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-6§10.2: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-6§10.2: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
         MOVE SPACES TO WS-CASE
         MOVE M-I TO WS-DIGIT
         STRING "35-6§10.2: rotation code " WS-DIGIT " (1 = none) was drawn" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-N-ROT(M-I) > 0
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 2
         MOVE SPACES TO WS-CASE
         MOVE M-I TO WS-DIGIT
         STRING "35-6§10.2: fossil template " WS-DIGIT " was drawn" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-N-IDX(M-I) > 0
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-6§10.2: some fossils were placed" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-OK >= 8
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§10.2: some fossils failed the empty corner check" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-FAIL >= 4
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:fossil_badlen" TO WS-FTKEY
                 MOVE "lists of unequal length" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:fossil_missing" TO WS-FTKEY
                 MOVE "a missing template file" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:fossil_badproc" TO WS-FTKEY
                 MOVE "an unknown processor list" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:fossil_badmax" TO WS-FTKEY
                 MOVE "a limit above 7" TO WS-NAME
             WHEN 5
                 MOVE "minecraft:fossil_nooverlay" TO WS-FTKEY
                 MOVE "no overlay list" TO WS-NAME
             WHEN 6
                 MOVE "minecraft:fossil_empty" TO WS-FTKEY
                 MOVE "empty lists" TO WS-NAME
             WHEN 7
                 MOVE "minecraft:fossil_noproc" TO WS-FTKEY
                 MOVE "no overlay processors" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:fossil_nonstring" TO WS-FTKEY
                 MOVE "template ids that are not strings" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-6§10.2: " FUNCTION TRIM(WS-NAME) " makes the feature unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE -1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:fossil_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-6§10.2: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:fossil_upper" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§10.2: the gate admits the fossil placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 30 BY 1 UNTIL WS-QY > 70
                 COMPUTE WS-MIDX = (WS-QY - 30) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 30 BY 1 UNTIL WS-QY > 70
                 COMPUTE WS-MIDX = (WS-QY - 30) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): kind 1 stone from y 30 to 63; kind 2 the same with holes (air where (7 x + 13 z + 3 y) mod 11 = 0); kind 3 stone from y 60 to 63 only; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     IF WS-KIND = 3
         MOVE 60 TO WS-STONE-LO
     ELSE
         MOVE 30 TO WS-STONE-LO
     END-IF
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QY FROM WS-STONE-LO BY 1 UNTIL WS-QY > 63
             PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
                 IF WS-KIND = 2 AND FUNCTION MOD(7 * WS-QX + 13 * WS-QZ + 3 * WS-QY, 11) = 0
                     CONTINUE
                 ELSE
                     CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-STONE WS-FLAGS WS-OK
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> ---- the model
 M-PUT.
     IF M-RX >= 16 AND M-RX <= 31 AND M-RZ >= 32 AND M-RZ <= 47 AND M-LY >= 30 AND M-LY <= 70
         COMPUTE WS-MIDX = (M-LY - 30) * 256 + (M-RZ - 32) * 16 + (M-RX - 16) + 1
         MOVE M-ST TO WS-OS(WS-MIDX)
     END-IF
     .
*> M-ROTATE: M-LX, M-LZ (local x and z) turned by M-ROT (0 none, 1 clockwise 90, 2 clockwise 180, 3 counter-clockwise 90) into M-DX, M-DZ (pivot 0, 0)
 M-ROTATE.
     EVALUATE M-ROT
         WHEN 0
             MOVE M-LX TO M-DX
             MOVE M-LZ TO M-DZ
         WHEN 1
             COMPUTE M-DX = 0 - M-LZ
             MOVE M-LX TO M-DZ
         WHEN 2
             COMPUTE M-DX = 0 - M-LX
             COMPUTE M-DZ = 0 - M-LZ
         WHEN OTHER
             MOVE M-LZ TO M-DX
             COMPUTE M-DZ = 0 - M-LX
     END-EVALUATE
     .
*> M-SOLID: M-V = 1 when the shadow cell (M-QX, M-QY, M-QZ) is stone (the only block of the worlds besides air)
 M-SOLID.
     MOVE 0 TO M-V
     IF M-QY < 30
         EXIT PARAGRAPH
     END-IF
     COMPUTE WS-MIDX = (M-QY - 30) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
     IF WS-OS(WS-MIDX) = WS-S-STONE
         MOVE 1 TO M-V
     END-IF
     .
*> M-FLOOR: M-H = the first free y over the highest stone of the column (M-QX, M-QZ), -64 for none
 M-FLOOR.
     MOVE -64 TO M-H
     PERFORM VARYING M-QY FROM 70 BY -1 UNTIL M-QY < 30 OR M-H NOT = -64
         PERFORM M-SOLID
         IF M-V = 1
             COMPUTE M-H = M-QY + 1
         END-IF
     END-PERFORM
     .
*> M-BLOCK: M-ST and the position (M-LX, M-LY, M-LZ) of the block M-K of the template M-N (1 f1, 2 f2, 3 o1, 4 o2) after its processor
 M-BLOCK.
     EVALUATE M-N ALSO M-K
         WHEN 1 ALSO 1
             MOVE 0 TO M-LX
             MOVE 0 TO M-LY
             MOVE 0 TO M-LZ
             MOVE WS-S-GOLD TO M-ST
         WHEN 1 ALSO 2
             MOVE 2 TO M-LX
             MOVE 1 TO M-LY
             MOVE 4 TO M-LZ
             MOVE WS-S-DIAMOND TO M-ST
         WHEN 1 ALSO 3
             MOVE 1 TO M-LX
             MOVE 0 TO M-LY
             MOVE 2 TO M-LZ
             MOVE WS-S-GOLD TO M-ST
         WHEN 2 ALSO 1
             MOVE 0 TO M-LX
             MOVE 0 TO M-LY
             MOVE 0 TO M-LZ
             MOVE WS-S-GOLD TO M-ST
         WHEN 2 ALSO 2
             MOVE 1 TO M-LX
             MOVE 0 TO M-LY
             MOVE 2 TO M-LZ
             MOVE WS-S-GOLD TO M-ST
         WHEN 3 ALSO 1
             MOVE 1 TO M-LX
             MOVE 1 TO M-LY
             MOVE 2 TO M-LZ
             MOVE WS-S-EMERALD TO M-ST
         WHEN 3 ALSO 2
             MOVE 0 TO M-LX
             MOVE 1 TO M-LY
             MOVE 0 TO M-LZ
             MOVE WS-S-IRON TO M-ST
         WHEN OTHER
             MOVE 1 TO M-LX
             MOVE 0 TO M-LY
             MOVE 0 TO M-LZ
             MOVE WS-S-EMERALD TO M-ST
     END-EVALUATE
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B4 M-ROT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-IDX
     ADD 1 TO WS-N-ROT(M-ROT + 1)
     ADD 1 TO WS-N-IDX(M-IDX + 1)
     IF M-IDX = 0
         MOVE 3 TO M-SX0
         MOVE 2 TO M-SY
         MOVE 5 TO M-SZ0
     ELSE
         MOVE 2 TO M-SX0
         MOVE 1 TO M-SY
         MOVE 3 TO M-SZ0
     END-IF
     IF M-ROT = 1 OR M-ROT = 3
         MOVE M-SZ0 TO M-SX
         MOVE M-SX0 TO M-SZ
     ELSE
         MOVE M-SX0 TO M-SX
         MOVE M-SZ0 TO M-SZ
     END-IF
     COMPUTE M-CX = WS-X + (0 - M-SX) / 2
     COMPUTE M-CZ = WS-Z + (0 - M-SZ) / 2
     MOVE WS-Y TO M-MINH
     PERFORM VARYING M-I FROM 0 BY 1 UNTIL M-I >= M-SX
         PERFORM VARYING M-J FROM 0 BY 1 UNTIL M-J >= M-SZ
             COMPUTE M-QX = M-CX + M-I
             COMPUTE M-QZ = M-CZ + M-J
             IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47
                 PERFORM M-FLOOR
                 IF M-H < M-MINH
                     MOVE M-H TO M-MINH
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B10 M-V
     COMPUTE M-BASE = M-MINH - 15 - M-V
     IF M-BASE < -54
         MOVE -54 TO M-BASE
     END-IF
*>   getZeroPositionWithTransform (no mirror): the unrotated size minus one
     EVALUATE M-ROT
         WHEN 0
             MOVE M-CX TO M-ZX
             MOVE M-CZ TO M-ZZ
         WHEN 1
             COMPUTE M-ZX = M-CX + M-SZ0 - 1
             MOVE M-CZ TO M-ZZ
         WHEN 2
             COMPUTE M-ZX = M-CX + M-SX0 - 1
             COMPUTE M-ZZ = M-CZ + M-SZ0 - 1
         WHEN OTHER
             MOVE M-CX TO M-ZX
             COMPUTE M-ZZ = M-CZ + M-SX0 - 1
     END-EVALUATE
*>   the box: the transformed corners (0, 0) and (size.x - 1, size.z - 1), moved by zero
     MOVE 0 TO M-LX
     MOVE 0 TO M-LZ
     PERFORM M-ROTATE
     MOVE M-DX TO M-X0
     MOVE M-DZ TO M-Z0
     COMPUTE M-LX = M-SX0 - 1
     COMPUTE M-LZ = M-SZ0 - 1
     PERFORM M-ROTATE
     MOVE M-DX TO M-X1
     MOVE M-DZ TO M-Z1
     IF M-X0 > M-X1
         MOVE M-X0 TO M-V
         MOVE M-X1 TO M-X0
         MOVE M-V TO M-X1
     END-IF
     IF M-Z0 > M-Z1
         MOVE M-Z0 TO M-V
         MOVE M-Z1 TO M-Z0
         MOVE M-V TO M-Z1
     END-IF
     COMPUTE M-X0 = M-X0 + M-ZX
     COMPUTE M-X1 = M-X1 + M-ZX
     COMPUTE M-Z0 = M-Z0 + M-ZZ
     COMPUTE M-Z1 = M-Z1 + M-ZZ
     MOVE 0 TO M-EMPTY
     PERFORM VARYING M-I FROM 0 BY 1 UNTIL M-I > 7
         IF FUNCTION MOD(M-I, 2) = 0
             MOVE M-X0 TO M-QX
         ELSE
             MOVE M-X1 TO M-QX
         END-IF
         COMPUTE M-K = M-I / 2
         IF FUNCTION MOD(M-K, 2) = 0
             MOVE M-Z0 TO M-QZ
         ELSE
             MOVE M-Z1 TO M-QZ
         END-IF
         IF M-I < 4
             MOVE M-BASE TO M-QY
         ELSE
             COMPUTE M-QY = M-BASE + M-SY - 1
         END-IF
         IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47
             PERFORM M-SOLID
             IF M-V = 0
                 ADD 1 TO M-EMPTY
             END-IF
         END-IF
     END-PERFORM
     IF M-EMPTY > WS-LIMIT
         ADD 1 TO WS-N-FAIL
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     ADD 1 TO WS-N-OK
*>   the fossil, then the overlay: one palette draw before each, the blocks rotated about zero
     PERFORM VARYING M-PASS FROM 0 BY 1 UNTIL M-PASS > 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B1 M-V
         COMPUTE M-N = M-IDX + 1 + M-PASS * 2
         EVALUATE M-N
             WHEN 1
                 MOVE 3 TO M-AZ
             WHEN 4
                 MOVE 1 TO M-AZ
             WHEN OTHER
                 MOVE 2 TO M-AZ
         END-EVALUATE
         PERFORM VARYING M-K FROM 1 BY 1 UNTIL M-K > M-AZ
             PERFORM M-BLOCK
             PERFORM M-ROTATE
             COMPUTE M-RX = M-ZX + M-DX
             COMPUTE M-RZ = M-ZZ + M-DZ
             COMPUTE M-LY = M-BASE + M-LY
             PERFORM M-PUT
         END-PERFORM
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-10.
 COPY CORETEST.
