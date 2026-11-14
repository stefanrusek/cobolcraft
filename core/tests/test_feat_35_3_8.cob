*> Implementation test of the bending trunk (docs/protocol/35-worldgen-features-3-tree-placers.md 4.7), the cherry trunk (4.9) and the bush, random spread and cherry foliage placers (5.2, with the
*> hanging leaves of 5.1): the data features compile as trees; the bending trunk has H logs, one per layer, then bend_length + 1 in a row on the top layer; cherry trunks are connected with branches
*> off the column; the cherry foliage of a straight trunk has the leaf count of each layer written out from the rows, the skip tests and the hanging leaves (no holes and every hanging leaf; none of
*> either; every hole), the bush foliage a count between its corner free and corner full rows, the random spread leaves stay inside the box its draws allow.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-8.
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
 01 WS-TX                  BINARY-LONG VALUE 24.
 01 WS-MIN-C               BINARY-LONG.
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
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 4 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 5 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     MOVE 1 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:leaves" TO WS-TAG
     MOVE 5 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   the data features compile as trees (type 51)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:t_bending" TO WS-KEY
             WHEN 2 MOVE "minecraft:t_cherry" TO WS-KEY
             WHEN 3 MOVE "minecraft:t_cherry_full" TO WS-KEY
             WHEN 4 MOVE "minecraft:t_cherry_none" TO WS-KEY
             WHEN 5 MOVE "minecraft:t_cherry_holes" TO WS-KEY
             WHEN 6 MOVE "minecraft:t_bush" TO WS-KEY
             WHEN 7 MOVE "minecraft:t_spread" TO WS-KEY
             WHEN 8 MOVE "minecraft:t_bending" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-3§4 and 5: the data feature " FUNCTION TRIM(WS-KEY) " compiles as a tree" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE 51 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   4.7 the bending trunk (H = 5, bend_length 2): one log in each of the layers 63 to 67, three in a row on layer 68, eight in all, and leaves
     MOVE "minecraft:t_bending" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 5 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT NOT = 8
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-D FROM 63 BY 1 UNTIL WS-D > 67
             MOVE WS-D TO WS-N
             PERFORM COUNT-LAYER
             IF WS-COUNT NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE 68 TO WS-N
         PERFORM COUNT-LAYER
         IF WS-COUNT NOT = 3
             ADD 1 TO WS-BAD
         END-IF
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT < 10
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-3§4.7: twenty bending trunks have one log per layer, three on the top layer and eight in all" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.9 the cherry trunk: placed, every log touches another log, branches leave the column, and the log counts differ between seeds
     MOVE "minecraft:t_cherry" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-OFFCOL
     MOVE 999 TO WS-MIN-C
     MOVE 0 TO WS-MAX-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 5 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT > WS-MAX-C
             MOVE WS-COUNT TO WS-MAX-C
         END-IF
         IF WS-COUNT < WS-MIN-C
             MOVE WS-COUNT TO WS-MIN-C
         END-IF
         PERFORM COUNT-LONELY
         ADD WS-NEIGH TO WS-BAD
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-3§4.9: thirty cherry trunks are placed, every log touches another log and leaves are placed" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§4.9: the cherry trunks differ in size and the longest has branches (more than the column of 7 to 8 logs)" TO WS-CASE
     IF WS-MAX-C > WS-MIN-C AND WS-MAX-C > 9
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   4.9 a branch whose end layer is below its start (end offset -6) is a long branch that goes down: still placed and connected
     MOVE "minecraft:t_cherry_low" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         PERFORM COUNT-LONELY
         ADD WS-NEIGH TO WS-BAD
     END-PERFORM
     MOVE "35-3§4.9: ten cherry trunks with a branch end below its start are placed and connected" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   5.2 the cherry foliage on a straight trunk (H = 6, the attachment at y = 69, radius 4, offset 0, height 5: rows (1, +2) (2, +1) (3, 0) (3, -1) (2, -2))
*>   no holes, every hanging leaf: 9, 25, 45, 44, 44, 28, 12 leaves on the layers 71 down to 65
     MOVE "minecraft:t_cherry_full" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 6 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§5.2: the cherry foliage without holes and with every hanging leaf has 207 leaves" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 207 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 6 TO WS-LOGB
     MOVE 71 TO WS-N
     MOVE 9 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 70 TO WS-N
     MOVE 25 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 69 TO WS-N
     MOVE 45 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 68 TO WS-N
     MOVE 44 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 67 TO WS-N
     MOVE 44 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 66 TO WS-N
     MOVE 28 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 65 TO WS-N
     MOVE 12 TO WS-EXP
     PERFORM LAYER-CASE

*>   no hanging leaves: 9, 25, 45, 44, 24
     MOVE "minecraft:t_cherry_none" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 6 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§5.1: with hanging chance 0 no hanging leaf is placed (147 leaves)" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 147 TO WS-EXP
     PERFORM ASSERT-N

*>   every hole: 5, 21, 37, 24, 20
     MOVE "minecraft:t_cherry_holes" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 6 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§5.2: with every hole chance 1 the cherry foliage has 107 leaves" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 107 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 71 TO WS-N
     MOVE 5 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 70 TO WS-N
     MOVE 21 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 69 TO WS-N
     MOVE 37 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 68 TO WS-N
     MOVE 24 TO WS-EXP
     PERFORM LAYER-CASE
     MOVE 67 TO WS-N
     MOVE 20 TO WS-EXP
     PERFORM LAYER-CASE

*>   5.2 bush: rows of radius 1 to 4 (the attachment at y = 68); the corners are drawn: 145 to 161 leaves (three logs in the centres), and not always the same
     MOVE "minecraft:t_bush" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 999 TO WS-MIN-C
     MOVE 0 TO WS-MAX-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT < 145 OR WS-COUNT > 161
             ADD 1 TO WS-BAD
         END-IF
         IF WS-COUNT > WS-MAX-C
             MOVE WS-COUNT TO WS-MAX-C
         END-IF
         IF WS-COUNT < WS-MIN-C
             MOVE WS-COUNT TO WS-MIN-C
         END-IF
     END-PERFORM
     MOVE "35-3§5.2: twenty bush foliages have 145 to 161 leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§5.2: the corner draws of the bush make the leaf counts differ" TO WS-CASE
     IF WS-MAX-C > WS-MIN-C
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   5.2 random spread: 64 attempts around the attachment (24, 67, 40) inside the box of radius 1 (nextInt(2) - nextInt(2)) and height 1: all leaves in the 3 x 3 x 3 box, between 5 and 26
     MOVE "minecraft:t_spread" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 999 TO WS-MIN-C
     MOVE 0 TO WS-MAX-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         MOVE WS-COUNT TO WS-LAYER-TOTAL
         PERFORM COUNT-BOX
         IF WS-COUNT NOT = WS-LAYER-TOTAL OR WS-COUNT < 5 OR WS-COUNT > 26
             ADD 1 TO WS-BAD
         END-IF
         IF WS-COUNT > WS-MAX-C
             MOVE WS-COUNT TO WS-MAX-C
         END-IF
         IF WS-COUNT < WS-MIN-C
             MOVE WS-COUNT TO WS-MIN-C
         END-IF
     END-PERFORM
     MOVE "35-3§5.2: random spread leaves of twenty trees stay in the 3 x 3 x 3 box and number 5 to 26" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§5.2: the random spread leaf counts differ between seeds" TO WS-CASE
     IF WS-MAX-C > WS-MIN-C
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 LAYER-CASE.
*>   the leaves (block WS-LOGB) of layer WS-N against WS-EXP
     MOVE SPACES TO WS-CASE
     MOVE WS-N TO WS-LYD
     STRING "35-3§5.2: layer " WS-LYD " of the cherry foliage has the leaves of its rows" DELIMITED BY SIZE INTO WS-CASE
     PERFORM COUNT-LAYER
     MOVE WS-COUNT TO WS-OBS
     PERFORM ASSERT-N
     .
 COUNT-LAYER.
*>   WS-COUNT = the blocks WS-LOGB in layer y = WS-N of the chunk window
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE WS-N TO WS-LY
             PERFORM READ-BLOCK
             IF WS-BLOCK = WS-LOGB
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     .
 COUNT-BOX.
*>   WS-COUNT = the leaves in x 23 to 25, y 66 to 68, z 39 to 41
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LX FROM 23 BY 1 UNTIL WS-LX > 25
         PERFORM VARYING WS-LY FROM 66 BY 1 UNTIL WS-LY > 68
             PERFORM VARYING WS-LZ FROM 39 BY 1 UNTIL WS-LZ > 41
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = 6
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COUNT-LONELY.
*>   WS-NEIGH = the logs (block 5) without a log among their six neighbours
     MOVE 0 TO WS-NEIGH
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 90
         PERFORM VARYING WS-LX FROM 17 BY 1 UNTIL WS-LX > 30
             PERFORM VARYING WS-LZ FROM 33 BY 1 UNTIL WS-LZ > 46
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = 5
                     MOVE 0 TO WS-N
                     COMPUTE WS-X = WS-LX - 1
                     PERFORM NEIGHBOUR-X
                     COMPUTE WS-X = WS-LX + 1
                     PERFORM NEIGHBOUR-X
                     COMPUTE WS-Y = WS-LY - 1
                     PERFORM NEIGHBOUR-Y
                     COMPUTE WS-Y = WS-LY + 1
                     PERFORM NEIGHBOUR-Y
                     COMPUTE WS-Z = WS-LZ - 1
                     PERFORM NEIGHBOUR-Z
                     COMPUTE WS-Z = WS-LZ + 1
                     PERFORM NEIGHBOUR-Z
                     IF WS-N = 0
                         ADD 1 TO WS-NEIGH
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 NEIGHBOUR-X.
     CALL "FL-GET-STATE" USING WS-X WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = 5
         ADD 1 TO WS-N
     END-IF
     .
 NEIGHBOUR-Y.
     CALL "FL-GET-STATE" USING WS-LX WS-Y WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = 5
         ADD 1 TO WS-N
     END-IF
     .
 NEIGHBOUR-Z.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = 5
         ADD 1 TO WS-N
     END-IF
     .
 READ-BLOCK.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     .
 COUNT-LOGS.
*>   WS-COUNT = the blocks WS-LOGB in the chunk window from y = 63
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 110
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LOGB
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
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
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 BUILD-TABLE.
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 oak_log (3 states, default the second), 6 oak_leaves (28, default the last)
     MOVE 6 TO CB-BLOCK-COUNT
     MOVE 12 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 1 TO WS-N
         MOVE 0 TO WS-D
         EVALUATE WS-I
             WHEN 5
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 6
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
         END-EVALUATE
         MOVE WS-STATE-NO TO CB-FIRST-STATE(WS-I)
         MOVE WS-N TO CB-STATES(WS-I)
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-STATE-NO + WS-D
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
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:oak_log" TO CB-KEY(5)
     MOVE "minecraft:oak_leaves" TO CB-KEY(6)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-3-8.
