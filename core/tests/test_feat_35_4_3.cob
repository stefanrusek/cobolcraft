*> Implementation test of the tree decorators trunk_vine, leave_vine and cocoa (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 3; core/src/feat-tree-deco.cob):
*> the draws of a straight trunk with trunk_vine and with cocoa are replayed from the same seed (the three draws of the tree first, then the decorator's in the doc's order) and the vines and pods
*> of the world must be exactly the ones the replay gives; leave_vine with probability 1 leaves no air beside a leaf and with probability 0 places nothing; decorators of other registered
*> types (the beehive) are accepted and ignored.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-3.
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

*>   the data features compile as trees
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:t_deco_vine" TO WS-KEY
             WHEN 2 MOVE "minecraft:t_deco_leaf" TO WS-KEY
             WHEN 3 MOVE "minecraft:t_deco_leaf0" TO WS-KEY
             WHEN 4 MOVE "minecraft:t_deco_cocoa" TO WS-KEY
             WHEN 5 MOVE "minecraft:t_deco_cocoa0" TO WS-KEY
             WHEN 6 MOVE "minecraft:t_deco_many" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-4§3: the data feature " FUNCTION TRIM(WS-KEY) " compiles as a tree" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE 51 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   3.3 trunk_vine: H = 5; per log (layers 63 to 67) the four sides west, east, north, south each draw nextInt(3); above 0 puts a vine on the side facing back at the log.
*>   The replay: height draws, the blob's one corner draw, then the decorator's draws
     MOVE "minecraft:t_deco_vine" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         PERFORM REPLAY-PREFIX
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 67
             PERFORM VARYING WS-DIR2 FROM 0 BY 1 UNTIL WS-DIR2 > 3
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-THREE WS-D
                 PERFORM SIDE-CELL
                 CALL "FL-GET-STATE" USING WS-NX WS-LY WS-NZ WS-STATE
                 MOVE 0 TO WS-EXPECT
                 IF WS-D > 0
                     COMPUTE WS-EXPECT = CB-FIRST-STATE(7) + 31 - WS-V
                     ADD 1 TO WS-SEEN
                 END-IF
                 IF WS-STATE NOT = WS-EXPECT
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-4§3.3: the vines of twenty straight trunks are exactly the ones the replayed draws give, each facing its log" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§3.3: trunk_vine puts vines at about two thirds of the 400 sides" TO WS-CASE
     IF WS-SEEN > 200 AND WS-SEEN < 330
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   3.3 cocoa with probability 1: after the first draw (below 1), the three lowest layers (63 to 65) each draw nextFloat for north, east, south, west; at most 0.25 puts a pod on the opposite side
*>   (age nextInt(3), drawn then) facing the log
     MOVE "minecraft:t_deco_cocoa" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         PERFORM REPLAY-PREFIX
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 65
             PERFORM VARYING WS-DIR2 FROM 0 BY 1 UNTIL WS-DIR2 > 3
                 CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
                 PERFORM POD-CELL
                 CALL "FL-GET-STATE" USING WS-NX WS-LY WS-NZ WS-STATE
                 MOVE 0 TO WS-EXPECT
                 IF WS-F <= WS-HALF
                     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-THREE WS-D
                     COMPUTE WS-EXPECT = CB-FIRST-STATE(8) + WS-D * 4 + WS-V
                     ADD 1 TO WS-SEEN
                     IF WS-STATE NOT = WS-EXPECT
                         ADD 1 TO WS-BAD
                     END-IF
                 ELSE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     IF WS-BLOCK = 8
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-4§3.3: the pods of twenty straight trunks are exactly the ones the replayed draws give, each facing its log with the drawn age" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§3.3: cocoa puts pods on about a quarter of the 240 sides" TO WS-CASE
     IF WS-SEEN > 30 AND WS-SEEN < 90
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   no pod above layer 65 and none with probability 0
     MOVE 8 TO WS-LOGB
     PERFORM COUNT-LOGS-ABOVE
     MOVE "35-4§3.3: no pod grows above the third log layer" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:t_deco_cocoa0" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 8 TO WS-LOGB
         PERFORM COUNT-LOGS
         ADD WS-COUNT TO WS-BAD
     END-PERFORM
     MOVE "35-4§3.3: cocoa with probability 0 places no pod" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   3.3 leave_vine: probability 1 puts a hanging vine on every air side of every leaf, so no air is left beside a leaf; probability 0 places no vine
     MOVE "minecraft:t_deco_leaf" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         PERFORM COUNT-AIR-BESIDE-LEAVES
         ADD WS-NEIGH TO WS-BAD
         MOVE 7 TO WS-LOGB
         PERFORM COUNT-LOGS
         ADD WS-COUNT TO WS-SEEN
     END-PERFORM
     MOVE "35-4§3.3: with leave_vine probability 1 no air cell is left beside a leaf" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§3.3: the leave_vine trees have many vines (a hanging vine is 1 to 5 cells)" TO WS-CASE
     IF WS-SEEN > 100
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:t_deco_leaf0" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 7 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-4§3.3: leave_vine with probability 0 places no vine" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the beehive is accepted and ignored: a trunk_vine, cocoa and beehive tree is placed with vines and no nest
     MOVE "minecraft:t_deco_many" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 7 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-4§3.1: a tree with trunk_vine, cocoa and beehive is placed and has vines" TO WS-CASE
     IF WS-RESULT = 1 AND WS-COUNT > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 REPLAY-PREFIX.
*>   the draws before the decorators: the two height draws and the blob's corner draw
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE 5 TO WS-BASE
     MOVE 0 TO WS-RA
     MOVE 0 TO WS-RB
     CALL "F353-TREE-HEIGHT" USING XR2-STATE WS-BASE WS-RA WS-RB WS-H
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-TWO WS-D
     .
 SIDE-CELL.
*>   trunk_vine: WS-DIR2 0 west, 1 east, 2 north, 3 south of the trunk (24, 40): the neighbour cell WS-NX, WS-NZ and WS-V the stride of the face that points back (east 16, west 1, south 4, north 8)
     MOVE 24 TO WS-NX
     MOVE 40 TO WS-NZ
     EVALUATE WS-DIR2
         WHEN 0
             MOVE 23 TO WS-NX
             MOVE 16 TO WS-V
         WHEN 1
             MOVE 25 TO WS-NX
             MOVE 1 TO WS-V
         WHEN 2
             MOVE 39 TO WS-NZ
             MOVE 4 TO WS-V
         WHEN OTHER
             MOVE 41 TO WS-NZ
             MOVE 8 TO WS-V
     END-EVALUATE
     .
 POD-CELL.
*>   cocoa: WS-DIR2 0 north, 1 east, 2 south, 3 west is the direction d the pod faces; the pod sits on the opposite side of the trunk (24, 40); WS-V the facing index (north 0, south 1, west 2, east 3)
     MOVE 24 TO WS-NX
     MOVE 40 TO WS-NZ
     EVALUATE WS-DIR2
         WHEN 0
             MOVE 41 TO WS-NZ
             MOVE 0 TO WS-V
         WHEN 1
             MOVE 23 TO WS-NX
             MOVE 3 TO WS-V
         WHEN 2
             MOVE 39 TO WS-NZ
             MOVE 1 TO WS-V
         WHEN OTHER
             MOVE 25 TO WS-NX
             MOVE 2 TO WS-V
     END-EVALUATE
     .
 COUNT-LOGS-ABOVE.
*>   WS-COUNT = the blocks WS-LOGB above layer 65
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LY FROM 66 BY 1 UNTIL WS-LY > 110
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
 COUNT-AIR-BESIDE-LEAVES.
*>   WS-NEIGH = the air cells (inside x 17 to 30, z 33 to 46) that touch a leaf on one of its four horizontal sides
     MOVE 0 TO WS-NEIGH
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 80
         PERFORM VARYING WS-LX FROM 17 BY 1 UNTIL WS-LX > 30
             PERFORM VARYING WS-LZ FROM 33 BY 1 UNTIL WS-LZ > 46
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = 1
                     MOVE 0 TO WS-N
                     COMPUTE WS-X = WS-LX - 1
                     PERFORM LEAF-X
                     COMPUTE WS-X = WS-LX + 1
                     PERFORM LEAF-X
                     COMPUTE WS-Z = WS-LZ - 1
                     PERFORM LEAF-Z
                     COMPUTE WS-Z = WS-LZ + 1
                     PERFORM LEAF-Z
                     IF WS-N > 0
                         ADD 1 TO WS-NEIGH
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 LEAF-X.
     CALL "FL-GET-STATE" USING WS-X WS-LY WS-LZ WS-ST
     CALL "FL-BLOCK-OF" USING WS-ST WS-NB
     IF WS-NB = 6
         ADD 1 TO WS-N
     END-IF
     .
 LEAF-Z.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-Z WS-ST
     CALL "FL-BLOCK-OF" USING WS-ST WS-NB
     IF WS-NB = 6
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
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 oak_log (3 states, default the second), 6 oak_leaves (28, default the last), 7 vine (32, default the last), 8 cocoa (12, default the first)
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE 13 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 1 TO WS-N
         MOVE 0 TO WS-D
         EVALUATE WS-I
             WHEN 5
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 6
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
             WHEN 7
                 MOVE 32 TO WS-N
                 MOVE 31 TO WS-D
             WHEN 8
                 MOVE 12 TO WS-N
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
     MOVE "minecraft:vine" TO CB-KEY(7)
     MOVE "minecraft:cocoa" TO CB-KEY(8)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-4-3.
