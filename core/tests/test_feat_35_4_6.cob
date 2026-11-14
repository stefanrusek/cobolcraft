*> Implementation test of the bamboo feature (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 6; core/src/feat-bamboo.cob): the data feature compiles (as 1000: bamboo is
*> registry id 0, which marks an uncompiled feature); a stalk of 5 + nextInt(12) cells with the three top cells leafy is placed exactly as the replayed draws say; with probability 1 a podzol disc of
*> radius 1 + nextInt(4) is laid under it; the origin must be air with a supporting block below, and a stalk blocked before the third cell keeps no leaves.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CONTENT.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/tree-types".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/feat-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOGB                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-SEEDS-OK            BINARY-LONG.
 01 WS-OFFCOL              BINARY-LONG.
 01 WS-MUDDY               BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 01 WS-ROOTS               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-MIN-C               BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.25.
 01 WS-DIR2                BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-TWELVE              BINARY-LONG VALUE 12.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-LYD                 PIC 999.
 01 WS-MAX-C               BINARY-LONG.
 01 WS-NEIGH               BINARY-LONG.
 01 WS-LAYER-TOTAL         BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-STATE-NO            BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-A                   PIC X(196608) BASED.

 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-TABLE
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     MOVE "minecraft:supports_bamboo" TO WS-TAG
     MOVE 2 TO WS-ID(1)
     MOVE 3 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:beneath_bamboo_podzol_replaceable" TO WS-TAG
     MOVE 2 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         IF WS-I = 1
             MOVE "minecraft:t_bamboo" TO WS-KEY
         ELSE
             MOVE "minecraft:t_bamboo_podzol" TO WS-KEY
         END-IF
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-4§6: the data feature " FUNCTION TRIM(WS-KEY) " compiles as bamboo (1000)" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE 1000 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   thirty stalks: 5 + nextInt(12) cells of TRUNK (age 1, no leaves: state 6), the cursor cell above gets FINAL_LARGE (11), the cell below it TOP_LARGE (10), the one below that TOP_SMALL (8)
     MOVE "minecraft:t_bamboo" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-TWELVE WS-D
         COMPUTE WS-H = 5 + WS-D
         MOVE 24 TO WS-LX
         MOVE 40 TO WS-LZ
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 63 + WS-H + 1
             CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
             COMPUTE WS-N = WS-LY - 63
             EVALUATE TRUE
                 WHEN WS-N = WS-H
                     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 11
                 WHEN WS-N = WS-H - 1
                     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 10
                 WHEN WS-N = WS-H - 2
                     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 8
                 WHEN WS-N < WS-H
                     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 6
                 WHEN OTHER
                     MOVE 0 TO WS-EXP
             END-EVALUATE
             IF WS-STATE NOT = WS-EXP
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "35-4§6: thirty bamboo stalks have the cells and leaf states the replayed height says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   probability 1: radius 1 + nextInt(4) after the height and the float draw; the disc of the floor (dx^2 + dz^2 <= r^2) becomes podzol: 5, 13, 29 or 49 cells
     MOVE "minecraft:t_bamboo_podzol" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-TWELVE WS-D
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-FOUR WS-D
         EVALUATE WS-D
             WHEN 0
                 MOVE 5 TO WS-EXP
             WHEN 1
                 MOVE 13 TO WS-EXP
             WHEN 2
                 MOVE 29 TO WS-EXP
             WHEN OTHER
                 MOVE 49 TO WS-EXP
         END-EVALUATE
         MOVE 5 TO WS-LOGB
         MOVE 62 TO WS-N
         PERFORM COUNT-LAYER
         IF WS-COUNT NOT = WS-EXP
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-4§6: the podzol disc under twenty bamboo stalks has the cells of the drawn radius" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the origin must be air and a supporting block below: a stone at the origin, or stone floor, places nothing and draws nothing
     MOVE "minecraft:t_bamboo" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-LX
     MOVE 63 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE CB-DEFAULT-STATE(2) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "35-4§6.1: a bamboo whose origin is not air is not placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     MOVE 62 TO WS-LY
     MOVE CB-DEFAULT-STATE(2) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "35-4§6.1: a bamboo on a block that does not support it is not placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a stone two cells above the origin stops the stalk after two cells: no leaves
     PERFORM NEW-WORLD
     MOVE 65 TO WS-LY
     MOVE CB-DEFAULT-STATE(2) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE 63 TO WS-LY
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     MOVE "35-4§6: a stalk blocked at the third cell has two plain trunk cells" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 6
     PERFORM ASSERT-N
     MOVE 64 TO WS-LY
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     MOVE "35-4§6: and no leaves (the second cell is plain trunk too)" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     COMPUTE WS-EXP = CB-FIRST-STATE(7) + 6
     PERFORM ASSERT-N
     MOVE 66 TO WS-LY
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     MOVE "35-4§6: nothing is placed above the blocking stone" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 COUNT-LAYER.
*>   WS-COUNT = the blocks WS-LOGB in layer y = WS-N of the chunk window
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE WS-N TO WS-LY
             CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-BLOCK = WS-LOGB
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     .
 PLACE-TREE.
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 NEW-WORLD.
*>   an empty chunk (1, 2) with a grass floor at y = 62
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE 62 TO WS-LY
             MOVE CB-DEFAULT-STATE(3) TO WS-STATE
             CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
         END-PERFORM
     END-PERFORM
     MOVE 24 TO WS-LX
     MOVE 40 TO WS-LZ
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 BUILD-TABLE.
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 podzol, 6 bamboo_sapling (unused), 7 bamboo (12 states, default the first)
     MOVE 7 TO CB-BLOCK-COUNT
     MOVE 14 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE 1 TO WS-N
         IF WS-I = 7
             MOVE 12 TO WS-N
         END-IF
         MOVE WS-STATE-NO TO CB-FIRST-STATE(WS-I)
         MOVE WS-N TO CB-STATES(WS-I)
         MOVE WS-STATE-NO TO CB-DEFAULT-STATE(WS-I)
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= WS-N
             COMPUTE WS-Y = WS-STATE-NO + WS-X + 1
             COMPUTE CB-S-BLOCK(WS-Y) = WS-I - 1
         END-PERFORM
         ADD WS-N TO WS-STATE-NO
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE WS-STATE-NO TO CB-STATE-COUNT
     MOVE 1 TO CB-SOLID(2)
     MOVE 1 TO CB-SOLID(3)
     MOVE 1 TO CB-SOLID(4)
     MOVE 1 TO CB-SOLID(5)
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:podzol" TO CB-KEY(5)
     MOVE "minecraft:bamboo_sapling" TO CB-KEY(6)
     MOVE "minecraft:bamboo" TO CB-KEY(7)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-4-6.
