*> Implementation test of the trunk placers (docs/protocol/35-worldgen-features-3-tree-placers.md section 4: fancy 4.6, dark oak 4.5, giant 4.3, mega jungle 4.4, forking 4.2) through
*> the tree feature (core/src/feat-tree.cob, feat-tree-trunk.cob): the data features compile as trees, the logs stand where the placers put them (the heights are redrawn here from the same seed
*> with F353-TREE-HEIGHT), the soil is changed under every trunk cell, every leaf has its distance through the leaves, and the three layers feature size blocks a tree one layer higher.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-4.
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
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DIRN                BINARY-LONG.
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
 01 WS-T                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOGB                BINARY-LONG.
 01 WS-LEAFB               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOGS                BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-EDGE                BINARY-LONG.
 01 WS-DX-I                BINARY-LONG.
 01 WS-LIMBS              BINARY-LONG.
 01 WS-DI                 BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-STATE-NO            BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-DISTS.
    05 WS-DIST             PIC 9 OCCURS 12288 TIMES.
 01 WS-A                   PIC X(196608) BASED.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-TABLE
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 4 TO WS-ID(1)
     MOVE 6 TO WS-ID(2)
     MOVE 8 TO WS-ID(3)
     MOVE 10 TO WS-ID(4)
     MOVE 12 TO WS-ID(5)
     MOVE 5 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 5 TO WS-ID(2)
     MOVE 7 TO WS-ID(3)
     MOVE 9 TO WS-ID(4)
     MOVE 11 TO WS-ID(5)
     MOVE 13 TO WS-ID(6)
     MOVE 6 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     MOVE 14 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:leaves" TO WS-TAG
     MOVE 5 TO WS-ID(1)
     MOVE 7 TO WS-ID(2)
     MOVE 9 TO WS-ID(3)
     MOVE 11 TO WS-ID(4)
     MOVE 13 TO WS-ID(5)
     MOVE 5 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   the data features compile as trees; an unknown decorator, the bending trunk and the cherry foliage do not, the cocoa decorator is ignored
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE 51 TO WS-EXP
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:fancy_oak" TO WS-KEY
             WHEN 2 MOVE "minecraft:dark_oak" TO WS-KEY
             WHEN 3 MOVE "minecraft:mega_jungle_tree" TO WS-KEY
             WHEN 4 MOVE "minecraft:mega_pine" TO WS-KEY
             WHEN 5 MOVE "minecraft:acacia" TO WS-KEY
             WHEN 6 MOVE "minecraft:t_giant_blob" TO WS-KEY
             WHEN 7 MOVE "minecraft:t_forking" TO WS-KEY
             WHEN 8 MOVE "minecraft:t_three_layers" TO WS-KEY
             WHEN 9 MOVE "minecraft:t_deco_ignored" TO WS-KEY
             WHEN 10 MOVE "minecraft:t_fancy_foliage" TO WS-KEY
             WHEN 11 MOVE "minecraft:t_giant_jungle" TO WS-KEY
             WHEN 12 MOVE "minecraft:t_jungle_single" TO WS-KEY
             WHEN 13 MOVE "minecraft:t_giant_megapine" TO WS-KEY
             WHEN 14 MOVE "minecraft:t_giant_darkoak" TO WS-KEY
             WHEN 15 MOVE "minecraft:t_single_darkoak" TO WS-KEY
             WHEN 16 MOVE "minecraft:t_acacia_foliage" TO WS-KEY
             WHEN 17 MOVE "minecraft:t_bad_deco" TO WS-KEY
                 MOVE -1 TO WS-EXP
             WHEN 18 MOVE "minecraft:t_bad_trunk" TO WS-KEY
                 MOVE -1 TO WS-EXP
             WHEN 19 MOVE "minecraft:t_bad_foliage" TO WS-KEY
                 MOVE -1 TO WS-EXP
             WHEN 20 MOVE "minecraft:fancy_oak" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "acceptance US12 35-3§4 Trunk placers: the data feature " FUNCTION TRIM(WS-KEY) " compiles as a tree or is unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         PERFORM ASSERT-N
     END-PERFORM

*>   4.3 the giant trunk: 2 x 2 logs for the first H - 1 layers (H = 6), one log in the last, dirt under the four cells
     MOVE "minecraft:t_giant_blob" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 5 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE "acceptance US12 35-3§4 Trunk placers: a giant trunk tree on open grass is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "acceptance US12 35-3§4 Trunk placers: a giant trunk of height 6 has 5 layers of 4 logs and 1 log (21)" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 21 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 67
         PERFORM VARYING WS-DX-I FROM 0 BY 1 UNTIL WS-DX-I > 3
             COMPUTE WS-LX = 24 + FUNCTION MOD(WS-DX-I, 2)
             COMPUTE WS-LZ = 40 + WS-DX-I / 2
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: the logs of the first five layers fill the 2 x 2 column" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     MOVE 62 TO WS-LY
     PERFORM VARYING WS-DX-I FROM 0 BY 1 UNTIL WS-DX-I > 3
         COMPUTE WS-LX = 24 + FUNCTION MOD(WS-DX-I, 2)
         COMPUTE WS-LZ = 40 + WS-DX-I / 2
         PERFORM READ-BLOCK
         IF WS-BLOCK NOT = 4
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: the four cells under a giant trunk become dirt" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 68 TO WS-LY
     MOVE 25 TO WS-LX
     MOVE 41 TO WS-LZ
     PERFORM READ-BLOCK
     MOVE "acceptance US12 35-3§4 Trunk placers: the last layer of a giant trunk has no log off the corner" TO WS-CASE
     MOVE WS-BLOCK TO WS-OBS
     IF WS-BLOCK = 5
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 6 TO WS-LEAFB
     PERFORM CHECK-DIST
     MOVE "acceptance US12 35-3§4 Trunk placers: the leaves of the giant trunk tree have their distances" TO WS-CASE
     MOVE WS-DB TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.6 the fancy trunk: the column to trunkTop = floor((H + 2) * 0.618) is log, the soil under it is dirt, the leaves have their distances
     MOVE "minecraft:fancy_oak" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-EDGE
     MOVE 0 TO WS-LIMBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 3 TO WS-BASE
         MOVE 11 TO WS-RA
         MOVE 0 TO WS-RB
         PERFORM REDRAW-HEIGHT
         COMPUTE WS-T = (WS-H + 2) * 618 / 1000
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 63 + WS-T
             MOVE 24 TO WS-LX
             MOVE 40 TO WS-LZ
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE 62 TO WS-LY
         PERFORM READ-BLOCK
         IF WS-BLOCK NOT = 4
             ADD 1 TO WS-BAD
         END-IF
         MOVE 5 TO WS-LOGB
         PERFORM COUNT-LOGS
         COMPUTE WS-N = WS-T + 1
         IF WS-COUNT < WS-N
             ADD 1 TO WS-BAD
         END-IF
         IF WS-COUNT > WS-N + 4
             ADD 1 TO WS-LIMBS
         END-IF
         MOVE 6 TO WS-LEAFB
         PERFORM COUNT-LEAVES
         IF WS-COUNT < 20
             ADD 1 TO WS-BAD
         END-IF
         IF FL-DISCARDED = 0
             PERFORM CHECK-DIST
             ADD WS-DB TO WS-EDGE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: sixty fancy oaks have the trunk column, the soil, limbs and leaves (draws replayed from the seed)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "acceptance US12 35-3§4 Trunk placers: the leaves of the fancy oaks that fit the chunk have their distances" TO WS-CASE
     MOVE WS-EDGE TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

     MOVE "acceptance US12 35-3§4 Trunk placers: some of the sixty fancy oaks grow limbs (more logs than the trunk and 4)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-LIMBS > 10
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   4.6 limbs that meet an obstacle are refused: with a stone slab at layer 70 around the trunk column the oaks are still placed and no log replaces the slab
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 IF WS-LX NOT = 24 OR WS-LZ NOT = 40
                     MOVE 70 TO WS-LY
                     MOVE 1 TO WS-STATE
                     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
                 END-IF
             END-PERFORM
         END-PERFORM
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 5 TO WS-LOGB
         PERFORM COUNT-LOGS
         MOVE WS-COUNT TO WS-N
         MOVE 70 TO WS-LY
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = 5
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-COUNT > 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: twenty fancy oaks among a slab of stone are placed and put no log into the slab but the trunk column" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.5 the dark oak trunk: a 2 x 2 base, at least 4 logs in each of the H layers, dirt under the four cells, leaves with their distances
     MOVE "minecraft:dark_oak" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-EDGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 6 TO WS-BASE
         MOVE 2 TO WS-RA
         MOVE 1 TO WS-RB
         PERFORM REDRAW-HEIGHT
         MOVE 7 TO WS-LOGB
         PERFORM COUNT-LOGS
         COMPUTE WS-N = 4 * WS-H
         IF WS-COUNT < WS-N
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-DX-I FROM 0 BY 1 UNTIL WS-DX-I > 3
             COMPUTE WS-LX = 24 + FUNCTION MOD(WS-DX-I, 2)
             COMPUTE WS-LZ = 40 + WS-DX-I / 2
             MOVE 62 TO WS-LY
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 4
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 63 TO WS-LY
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 7
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE 8 TO WS-LEAFB
         PERFORM COUNT-LEAVES
         IF WS-COUNT < 30
             ADD 1 TO WS-BAD
         END-IF
         IF FL-DISCARDED = 0
             PERFORM CHECK-DIST
             ADD WS-DB TO WS-EDGE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: thirty dark oaks have a 2 x 2 base on dirt, 4 logs in every layer and leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "acceptance US12 35-3§4 Trunk placers: the leaves of the dark oaks that fit the chunk have their distances" TO WS-CASE
     MOVE WS-EDGE TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.4 the mega jungle trunk: the giant trunk (4 logs in each of the first H - 1 layers) and more logs from the branches
     MOVE "minecraft:mega_jungle_tree" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-EDGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 10 TO WS-BASE
         MOVE 2 TO WS-RA
         MOVE 19 TO WS-RB
         PERFORM REDRAW-HEIGHT
         MOVE 9 TO WS-LOGB
         PERFORM COUNT-LOGS
         COMPUTE WS-N = 4 * (WS-H - 1) + 1
         IF WS-COUNT < WS-N
             ADD 1 TO WS-BAD
         END-IF
         MOVE 10 TO WS-LEAFB
         PERFORM COUNT-LEAVES
         IF WS-COUNT < 40
             ADD 1 TO WS-BAD
         END-IF
         IF FL-DISCARDED = 0
             PERFORM CHECK-DIST
             ADD WS-DB TO WS-EDGE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: twelve mega jungle trees have the 2 x 2 trunk, branches and leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "acceptance US12 35-3§4 Trunk placers: the leaves of the mega jungle trees that fit the chunk have their distances" TO WS-CASE
     MOVE WS-EDGE TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.3 the same trunk under the mega pine
     MOVE "minecraft:mega_pine" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 13 TO WS-BASE
         MOVE 2 TO WS-RA
         MOVE 14 TO WS-RB
         PERFORM REDRAW-HEIGHT
         MOVE 11 TO WS-LOGB
         PERFORM COUNT-LOGS
         COMPUTE WS-N = 4 * (WS-H - 1) + 1
         IF WS-COUNT NOT = WS-N
             ADD 1 TO WS-BAD
         END-IF
         MOVE 12 TO WS-LEAFB
         PERFORM COUNT-LEAVES
         IF WS-COUNT < 30
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: four mega pines have exactly 4 (H - 1) + 1 logs and leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   4.2 the forking trunk (H = 6): the first limb has 6 logs and the second at least none; the column at the origin has the first logs
     MOVE "minecraft:t_forking" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-EDGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 13 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT < 6 OR WS-COUNT > 11
             ADD 1 TO WS-BAD
         END-IF
         MOVE 24 TO WS-LX
         MOVE 40 TO WS-LZ
         MOVE 63 TO WS-LY
         PERFORM READ-BLOCK
         IF WS-BLOCK NOT = 13
             ADD 1 TO WS-BAD
         END-IF
         MOVE 62 TO WS-LY
         PERFORM READ-BLOCK
         IF WS-BLOCK NOT = 4
             ADD 1 TO WS-BAD
         END-IF
*>       the logs of the first limb are one column of 6 whose cells touch face to face: the lowest log of every column cell above is adjacent to a log below
         PERFORM CHECK-CONNECTED
     END-PERFORM
     MOVE "acceptance US12 35-3§4 Trunk placers: thirty forking trunks have 6 to 11 connected logs on dirt" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   2.3 the feature sizes: the three layers size (limit 1, upper limit 1, lower 0, middle 1, upper 2) with H = 5 reaches 2 cells out at y = 4 only
     MOVE "minecraft:t_three_layers" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 5 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 26 TO WS-LX
     MOVE 67 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "acceptance US12 35-3§4 Trunk placers: a block 2 cells out at layer 4 stops a three layers tree of height 5" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     MOVE 26 TO WS-LX
     MOVE 66 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "acceptance US12 35-3§4 Trunk placers: a block 2 cells out at layer 3 does not stop it (middle size 1)" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 REDRAW-HEIGHT.
*>   the tree height of the same seed: the first two draws of the feature (2.2 step 1)
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     CALL "F353-TREE-HEIGHT" USING XR2-STATE WS-BASE WS-RA WS-RB WS-H
     .
 READ-BLOCK.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     .
 COUNT-LOGS.
*>   WS-COUNT = the blocks WS-LOGB in the chunk window above the floor
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
 COUNT-LEAVES.
     MOVE WS-LEAFB TO WS-LOGB
     PERFORM COUNT-LOGS
     .
 CHECK-CONNECTED.
*>   every log of block WS-LOGB above y = 63 has a log of that block next to it one layer lower or at the same layer (a connected limb); counts the ones that have not
     PERFORM VARYING WS-LY FROM 64 BY 1 UNTIL WS-LY > 110
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LOGB
                     MOVE 0 TO WS-N
                     COMPUTE WS-NY = WS-LY - 1
                     PERFORM VARYING WS-DIRN FROM 1 BY 1 UNTIL WS-DIRN > 5
                         EVALUATE WS-DIRN
                             WHEN 1 COMPUTE WS-NX = WS-LX - 1
                                 MOVE WS-LZ TO WS-NZ
                             WHEN 2 COMPUTE WS-NX = WS-LX + 1
                                 MOVE WS-LZ TO WS-NZ
                             WHEN 3 MOVE WS-LX TO WS-NX
                                 COMPUTE WS-NZ = WS-LZ - 1
                             WHEN 4 MOVE WS-LX TO WS-NX
                                 COMPUTE WS-NZ = WS-LZ + 1
                             WHEN 5 MOVE WS-LX TO WS-NX
                                 MOVE WS-LZ TO WS-NZ
                         END-EVALUATE
                         CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
                         CALL "FL-BLOCK-OF" USING WS-STATE WS-D
                         IF WS-D = WS-LOGB
                             ADD 1 TO WS-N
                         END-IF
                     END-PERFORM
                     IF WS-N = 0
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 CHECK-DIST.
*>   WS-DB = the leaves (block WS-LEAFB) of the chunk window whose stored distance is not the breadth first distance from a log (WS-LEAFB - 1) through the leaves, 7 when none within 6
     MOVE 0 TO WS-DB
     COMPUTE WS-LOGB = WS-LEAFB - 1
     PERFORM VARYING WS-DI FROM 1 BY 1 UNTIL WS-DI > 12288
         MOVE 7 TO WS-DIST(WS-DI)
     END-PERFORM
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 110
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LOGB
                     PERFORM DIST-INDEX
                     MOVE 0 TO WS-DIST(WS-T)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 110
                 PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                     PERFORM READ-BLOCK
                     IF WS-BLOCK = WS-LEAFB
                         PERFORM RELAX-LEAF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 110
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LEAFB
                     PERFORM DIST-INDEX
                     COMPUTE WS-STATE-NO = WS-STATE - CB-FIRST-STATE(WS-LEAFB)
                     COMPUTE WS-D = WS-STATE-NO / 4 + 1
                     IF WS-D NOT = WS-DIST(WS-T)
                         ADD 1 TO WS-DB
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 DIST-INDEX.
     COMPUTE WS-T = ((WS-LX - 16) * 48 + (WS-LY - 63)) * 16 + (WS-LZ - 32) + 1
     .
 RELAX-LEAF.
*>   the distance of the leaf at (WS-LX, WS-LY, WS-LZ) = min(its own, 1 + a neighbour's) over the six neighbours inside the window
     PERFORM DIST-INDEX
     MOVE WS-T TO WS-N
     PERFORM VARYING WS-DIRN FROM 1 BY 1 UNTIL WS-DIRN > 6
         MOVE WS-LX TO WS-NX
         MOVE WS-LY TO WS-NY
         MOVE WS-LZ TO WS-NZ
         EVALUATE WS-DIRN
             WHEN 1 SUBTRACT 1 FROM WS-NX
             WHEN 2 ADD 1 TO WS-NX
             WHEN 3 SUBTRACT 1 FROM WS-NY
             WHEN 4 ADD 1 TO WS-NY
             WHEN 5 SUBTRACT 1 FROM WS-NZ
             WHEN 6 ADD 1 TO WS-NZ
         END-EVALUATE
         IF WS-NX >= 16 AND WS-NX <= 31 AND WS-NY >= 63 AND WS-NY <= 110 AND WS-NZ >= 32 AND WS-NZ <= 47
             COMPUTE WS-D = ((WS-NX - 16) * 48 + (WS-NY - 63)) * 16 + (WS-NZ - 32) + 1
             IF WS-DIST(WS-D) < 6 AND WS-DIST(WS-D) + 1 < WS-DIST(WS-N)
                 COMPUTE WS-DIST(WS-N) = WS-DIST(WS-D) + 1
                 MOVE 1 TO WS-CHANGED
             END-IF
         END-IF
     END-PERFORM
     .
 PLACE-TREE.
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 NEW-WORLD.
*>   an empty chunk (1, 2) with a grass floor at y = 62; air is state 0
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
*>   1 air, 2 stone, 3 grass_block, 4 dirt, then log and leaves pairs: 5 oak, 7 dark_oak, 9 jungle, 11 spruce, 13 acacia (log, leaves), 15 bedrock, 16 water. Logs have 3 states
*>   (default axis y, the second), leaves 28 (distance 1 to 7, persistent, waterlogged; default the last).
     MOVE 16 TO CB-BLOCK-COUNT
     MOVE 9 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 1 TO WS-N
         MOVE 0 TO WS-D
         IF WS-I >= 5 AND WS-I <= 14
             IF FUNCTION MOD(WS-I, 2) = 1
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             ELSE
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
             END-IF
         END-IF
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
     MOVE 1 TO CB-SOLID(15)
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:oak_log" TO CB-KEY(5)
     MOVE "minecraft:oak_leaves" TO CB-KEY(6)
     MOVE "minecraft:dark_oak_log" TO CB-KEY(7)
     MOVE "minecraft:dark_oak_leaves" TO CB-KEY(8)
     MOVE "minecraft:jungle_log" TO CB-KEY(9)
     MOVE "minecraft:jungle_leaves" TO CB-KEY(10)
     MOVE "minecraft:spruce_log" TO CB-KEY(11)
     MOVE "minecraft:spruce_leaves" TO CB-KEY(12)
     MOVE "minecraft:acacia_log" TO CB-KEY(13)
     MOVE "minecraft:acacia_leaves" TO CB-KEY(14)
     MOVE "minecraft:bedrock" TO CB-KEY(15)
     MOVE "minecraft:water" TO CB-KEY(16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-3-4.

 COPY CORETEST.
