*> Implementation test of root_system (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 10; core/src/feat-root.cob, registry id 38): the data feature compiles (a root radius of 0, a space
*> above 64, a missing attempts number, replaceable set, provider, predicate or tree make it unsupported) and, over 21 seeds on a shadow array with a second random source, runs as the model of the section does:
*> the origin must be air; the cursor climbs from the origin through the rock; a world surface below the cursor ends the search; the allowed position (air with stone below, or air only) and spaceForTree (three
*> air cells above, the first one may be water) pick the cursor; a lava cell or a not solid block below ends it; the tree (a diamond block) goes in at the cursor and the rooted dirt column origin.y to
*> cursor.y - 1 follows (20 attempts of four nextInt(3) each, stone becomes dirt), then the hanging roots (8 attempts of six draws, an air cell under a solid one becomes gold). Worlds: a cave under stone (the
*> tree reaches the surface), water over the surface (one cell: allowed, two: no tree), a tall cave (the block below the cursor is air) and a tall cave with lava. Fixtures: core/tests/fixtures/gen_rootsys.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-10.
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
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/rootsys".
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
 01 WS-FT-AIR              BINARY-LONG.
 01 WS-FT-SHORT            BINARY-LONG.
 01 WS-FT-LEVEL            BINARY-LONG.
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
 01 WS-S-DIRT              BINARY-LONG.
 01 WS-S-DIAMOND           BINARY-LONG.
 01 WS-S-GOLD              BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-LAVA              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-N-TREE              BINARY-LONG VALUE 0.
 01 WS-N-NOTREE            BINARY-LONG VALUE 0.
 01 WS-N-DIRT              BINARY-LONG VALUE 0.
 01 WS-N-GOLD              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
*> model state
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-CY                   BINARY-LONG.
 01 M-H                    BINARY-LONG.
 01 M-V                    BINARY-LONG.
 01 M-DONE                 BINARY-LONG.
 01 M-TREE                 BINARY-LONG.
 01 M-ALLOWED              BINARY-LONG.
 01 M-SPACE                BINARY-LONG.
 01 M-QX                   BINARY-LONG.
 01 M-QY                   BINARY-LONG.
 01 M-QZ                   BINARY-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-SOL                  BINARY-LONG.
 01 M-MAXY                 BINARY-LONG.
 01 M-A                    BINARY-LONG.
 01 M-B                    BINARY-LONG.
 01 M-C                    BINARY-LONG.
 01 M-D                    BINARY-LONG.
 01 M-E                    BINARY-LONG.
 01 M-F                    BINARY-LONG.
 01 M-B3                   BINARY-LONG VALUE 3.
 01 M-B2                   BINARY-LONG VALUE 2.
 01 M-MAXH                 BINARY-LONG.
 01 M-STONEBELOW           BINARY-LONG.
 01 M-LTD                  BINARY-LONG.
 01 M-DIR                  BINARY-LONG.
 01 M-DX                   BINARY-LONG.
 01 M-DZ                   BINARY-LONG.
 01 M-BASEX                BINARY-LONG.
 01 M-BASEZ                BINARY-LONG.
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
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIRT
     MOVE "diamond_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIAMOND
     MOVE "gold_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GOLD
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LAVA
     MOVE "minecraft:rs_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-T
     CALL "FD-ENSURE-FT" USING WS-FT-T
     MOVE "minecraft:rs_air" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-AIR
     CALL "FD-ENSURE-FT" USING WS-FT-AIR
     MOVE "minecraft:rs_short" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-SHORT
     CALL "FD-ENSURE-FT" USING WS-FT-SHORT
     MOVE "minecraft:rs_level" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-LEVEL
     CALL "FD-ENSURE-FT" USING WS-FT-LEVEL
     MOVE "35-4§10: the variant with a level test compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT-LEVEL) TO WS-OBS
     MOVE 38 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§10: the data feature compiles as a root_system (38)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-T) TO WS-OBS
     MOVE 38 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§10: the variant with a bare air predicate compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT-AIR) TO WS-OBS
     PERFORM ASSERT-N
     MOVE "35-4§10: the variant with a short column compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT-SHORT) TO WS-OBS
     PERFORM ASSERT-N

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 21
         COMPUTE WS-SEED = WS-SEEDNO * 2003
         MOVE WS-SEEDNO TO WS-SEEDTXT
         MOVE WS-FT-T TO WS-CUR-FT
         MOVE 20 TO M-MAXH
         MOVE 1 TO M-STONEBELOW
         MOVE 0 TO M-LTD
         MOVE 50 TO WS-OY
         EVALUATE TRUE
             WHEN WS-SEEDNO >= 19
                 COMPUTE WS-KIND = WS-SEEDNO - 18
                 IF WS-KIND = 1
                     MOVE 1 TO WS-KIND
                 ELSE
                     ADD 4 TO WS-KIND
                 END-IF
                 MOVE WS-FT-LEVEL TO WS-CUR-FT
                 MOVE 2 TO M-LTD
             WHEN WS-SEEDNO <= 6
                 MOVE 1 TO WS-KIND
             WHEN WS-SEEDNO <= 10
                 MOVE 2 TO WS-KIND
             WHEN WS-SEEDNO <= 12
                 MOVE 3 TO WS-KIND
             WHEN WS-SEEDNO <= 14
                 MOVE 4 TO WS-KIND
                 MOVE WS-FT-AIR TO WS-CUR-FT
                 MOVE 0 TO M-STONEBELOW
             WHEN WS-SEEDNO <= 16
                 MOVE 5 TO WS-KIND
                 MOVE WS-FT-AIR TO WS-CUR-FT
                 MOVE 0 TO M-STONEBELOW
             WHEN WS-SEEDNO = 17
                 MOVE 1 TO WS-KIND
                 MOVE WS-FT-SHORT TO WS-CUR-FT
                 MOVE 5 TO M-MAXH
             WHEN OTHER
*>               the origin is stone: nothing happens
                 MOVE 1 TO WS-KIND
                 MOVE 56 TO WS-OY
         END-EVALUATE
         MOVE 24 TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM NEW-WORLD
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-4§10: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-4§10: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-4§10: the tree was placed in several runs" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-TREE >= 8
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§10: runs without a tree happened" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-NOTREE >= 6
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-4§10: rooted dirt was laid" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-DIRT >= 20
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-4§10: hanging roots were placed" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-GOLD >= 3
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:rs_badrange" TO WS-FTKEY
                 MOVE "a root radius of 0" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:rs_badspace" TO WS-FTKEY
                 MOVE "a space above 64" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:rs_noattempts" TO WS-FTKEY
                 MOVE "no attempts number" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:rs_noreplaceable" TO WS-FTKEY
                 MOVE "no replaceable set" TO WS-NAME
             WHEN 5
                 MOVE "minecraft:rs_noprovider" TO WS-FTKEY
                 MOVE "no root provider" TO WS-NAME
             WHEN 6
                 MOVE "minecraft:rs_nopred" TO WS-FTKEY
                 MOVE "no allowed position" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:rs_notree" TO WS-FTKEY
                 MOVE "no tree feature" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-4§10: " FUNCTION TRIM(WS-NAME) " makes the feature unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE -1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:rs_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-4§10: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 80
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
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
             PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 80
                 COMPUTE WS-MIDX = (WS-QY - 40) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone from y 40 to 63, air above; a cave of air (x 20..28, z 36..44) from y 44 to 51 (kinds 1 to 3) or to 55 (kinds 4, 5); kind 2 has water at y 65 over the
*> origin column, kind 3 at y 65 and 66, kind 5 lava at (24, 51, 40); both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QY FROM 40 BY 1 UNTIL WS-QY > 63
             PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
                 IF WS-QX >= 20 AND WS-QX <= 28 AND WS-QZ >= 36 AND WS-QZ <= 44 AND WS-QY >= 44
                    AND (((WS-KIND < 4 OR WS-KIND > 5) AND WS-QY <= 51) OR ((WS-KIND = 4 OR WS-KIND = 5) AND WS-QY <= 55))
                     CONTINUE
                 ELSE
                     CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-STONE WS-FLAGS WS-OK
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-KIND = 2 OR WS-KIND = 3
         MOVE 24 TO WS-QX
         MOVE 65 TO WS-QY
         MOVE 40 TO WS-QZ
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-WATER WS-FLAGS WS-OK
     END-IF
     IF WS-KIND = 3
         MOVE 66 TO WS-QY
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-WATER WS-FLAGS WS-OK
     END-IF
     IF WS-KIND = 6
         MOVE 26 TO WS-QX
         MOVE 65 TO WS-QY
         MOVE 40 TO WS-QZ
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-STONE WS-FLAGS WS-OK
     END-IF
     IF WS-KIND = 7
         MOVE 22 TO WS-QX
         MOVE 63 TO WS-QY
         MOVE 40 TO WS-QZ
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ 0 WS-FLAGS WS-OK
     END-IF
     IF WS-KIND = 5
         MOVE 24 TO WS-QX
         MOVE 51 TO WS-QY
         MOVE 40 TO WS-QZ
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-LAVA WS-FLAGS WS-OK
     END-IF
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> ---- the model
*> M-GET: M-ST = the shadow state of (M-QX, M-QY, M-QZ) (air outside the window); M-SOL = 1 for stone, dirt, diamond and gold
 M-GET.
     MOVE 0 TO M-ST
     IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 40 AND M-QY <= 80
         COMPUTE WS-MIDX = (M-QY - 40) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO M-ST
     END-IF
     MOVE 0 TO M-SOL
     IF M-ST = WS-S-STONE OR M-ST = WS-S-DIRT OR M-ST = WS-S-DIAMOND OR M-ST = WS-S-GOLD
         MOVE 1 TO M-SOL
     END-IF
     .
 M-PUT.
     IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 40 AND M-QY <= 80
         COMPUTE WS-MIDX = (M-QY - 40) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
         MOVE M-ST TO WS-OS(WS-MIDX)
     END-IF
     .
*> M-HEIGHT: M-H = the first free y over the highest non-air cell of the origin column, -64 for none
 M-HEIGHT.
     MOVE -64 TO M-H
     MOVE WS-X TO M-QX
     MOVE WS-Z TO M-QZ
     PERFORM VARYING M-QY FROM 80 BY -1 UNTIL M-QY < 40 OR M-H NOT = -64
         PERFORM M-GET
         IF M-ST NOT = 0
             COMPUTE M-H = M-QY + 1
         END-IF
     END-PERFORM
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE WS-X TO M-QX
     MOVE WS-Y TO M-QY
     MOVE WS-Z TO M-QZ
     PERFORM M-GET
     IF M-ST NOT = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     MOVE 0 TO M-DONE M-TREE
     PERFORM VARYING M-I FROM 0 BY 1 UNTIL M-I >= M-MAXH OR M-DONE = 1
         COMPUTE M-CY = WS-Y + M-I + 1
         PERFORM M-HEIGHT
         IF M-H < M-CY
             MOVE 1 TO M-DONE
         ELSE
             MOVE WS-X TO M-QX
             MOVE WS-Z TO M-QZ
             MOVE M-CY TO M-QY
             PERFORM M-GET
             MOVE 0 TO M-ALLOWED
             IF M-ST = 0
                 MOVE 1 TO M-ALLOWED
             END-IF
             IF M-ALLOWED = 1 AND M-STONEBELOW = 1
                 COMPUTE M-QY = M-CY - 1
                 PERFORM M-GET
                 IF M-ST NOT = WS-S-STONE
                     MOVE 0 TO M-ALLOWED
                 END-IF
             END-IF
             MOVE 0 TO M-SPACE
             IF M-ALLOWED = 1
                 MOVE 1 TO M-SPACE
                 PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 3
                     COMPUTE M-QY = M-CY + M-J
                     PERFORM M-GET
                     IF M-ST = 0 OR (M-ST = WS-S-WATER AND M-J = 1)
                         CONTINUE
                     ELSE
                         MOVE 0 TO M-SPACE
                     END-IF
                 END-PERFORM
             END-IF
             IF M-SPACE = 1 AND M-LTD > 0
                 PERFORM VARYING M-DIR FROM 0 BY 1 UNTIL M-DIR > 3
                     EVALUATE M-DIR
                         WHEN 0
                             MOVE 1 TO M-DX
                             MOVE 0 TO M-DZ
                         WHEN 1
                             MOVE -1 TO M-DX
                             MOVE 0 TO M-DZ
                         WHEN 2
                             MOVE 0 TO M-DX
                             MOVE 1 TO M-DZ
                         WHEN OTHER
                             MOVE 0 TO M-DX
                             MOVE -1 TO M-DZ
                     END-EVALUATE
                     COMPUTE M-QX = WS-X + M-DX * M-LTD
                     COMPUTE M-QZ = WS-Z + M-DZ * M-LTD
                     COMPUTE M-QY = M-CY - 1
                     PERFORM M-GET
                     IF M-ST = 0
                         MOVE 0 TO M-SPACE
                     END-IF
                     COMPUTE M-QY = M-CY + 1
                     PERFORM M-GET
                     IF M-ST NOT = 0
                         MOVE 0 TO M-SPACE
                     END-IF
                 END-PERFORM
             END-IF
             IF M-SPACE = 1
                 COMPUTE M-QY = M-CY - 1
                 PERFORM M-GET
                 IF M-ST = WS-S-LAVA OR M-SOL = 0
                     MOVE 1 TO M-DONE
                 ELSE
                     MOVE WS-X TO M-QX
                     MOVE WS-Z TO M-QZ
                     MOVE M-CY TO M-QY
                     MOVE WS-S-DIAMOND TO M-ST
                     PERFORM M-PUT
                     MOVE 1 TO M-TREE
                     MOVE 1 TO M-DONE
                     COMPUTE M-MAXY = WS-Y + M-I
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF M-TREE = 0
         ADD 1 TO WS-N-NOTREE
         EXIT PARAGRAPH
     END-IF
     ADD 1 TO WS-N-TREE
*>   the rooted dirt: each y from the origin to maxY - 1, 20 attempts of (a - b, c - d)
     PERFORM VARYING M-QY FROM WS-Y BY 1 UNTIL M-QY >= M-MAXY
         PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 20
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-A
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-B
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-C
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-D
             COMPUTE M-QX = WS-X + M-A - M-B
             COMPUTE M-QZ = WS-Z + M-C - M-D
             PERFORM M-GET
             IF M-ST = WS-S-STONE
                 MOVE WS-S-DIRT TO M-ST
                 PERFORM M-PUT
                 ADD 1 TO WS-N-DIRT
             END-IF
         END-PERFORM
     END-PERFORM
*>   the hanging roots: 8 attempts of (a - b, c - d, e - f) with radius 3 and span 2
     PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 8
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-A
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-B
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-C
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B2 M-D
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-E
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-F
         COMPUTE M-QX = WS-X + M-A - M-B
         COMPUTE M-QY = WS-Y + M-C - M-D
         COMPUTE M-QZ = WS-Z + M-E - M-F
         PERFORM M-GET
         IF M-ST = 0
             COMPUTE M-QY = M-QY + 1
             PERFORM M-GET
             IF M-SOL = 1
                 COMPUTE M-QY = M-QY - 1
                 MOVE WS-S-GOLD TO M-ST
                 PERFORM M-PUT
                 ADD 1 TO WS-N-GOLD
             END-IF
         END-IF
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-10.
 COPY NOSPAWN.
 COPY CORETEST.
