*> Implementation test of the foliage placers (docs/protocol/35-worldgen-features-3-tree-placers.md section 5: fancy, jungle, mega pine, acacia, dark oak and the double trunk blob; core/src/feat-tree.cob,
*> feat-tree-foliage.cob) on straight or giant trunks of fixed height: every cell of the layer of a row is a leaf exactly when the row of the placer covers it and no log stands there (the radii, the
*> skip tests and the double trunk widening are written out again here for each placer).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-5.
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
 01 WS-DI                 BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-LYV                 BINARY-LONG.
 01 WS-CXX                 BINARY-LONG.
 01 WS-CZZ                 BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-DBL                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-DXX                 BINARY-LONG.
 01 WS-DZZ                 BINARY-LONG.
 01 WS-INROW               BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-ROWS.
    05 WS-ROW-RAD          BINARY-LONG OCCURS 12 TIMES.
 01 WS-NROWS               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-NAME                PIC X(40).
 01 WS-LYD                 PIC 999.
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
     MOVE 5 TO WS-SEED

*>   5.2 fancy: rows y = off .. off - FH around the attachment (24, 68, 40): radius 2, 3, 3, 3, 2, a cell is skipped when (ax + 0.5)^2 + (az + 0.5)^2 > rad^2
     MOVE "minecraft:t_fancy_foliage" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "fancy foliage" TO WS-NAME
     MOVE 24 TO WS-CXX
     MOVE 40 TO WS-CZZ
     MOVE 0 TO WS-DBL
     MOVE 1 TO WS-KIND
     MOVE 6 TO WS-LEAFB
     MOVE 5 TO WS-NROWS
     MOVE 2 TO WS-ROW-RAD(1)
     MOVE 3 TO WS-ROW-RAD(2)
     MOVE 3 TO WS-ROW-RAD(3)
     MOVE 3 TO WS-ROW-RAD(4)
     MOVE 2 TO WS-ROW-RAD(5)
     MOVE 72 TO WS-LYV
     PERFORM CHECK-ROWS-DOWN

*>   5.2 jungle on a giant trunk (double): hh = FH = 2, rows y = 0, -1, -2 around (24, 69, 40) with radius 2 + 1 - y, the row runs one cell further to the south and east
     MOVE "minecraft:t_giant_jungle" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "jungle foliage on a giant trunk" TO WS-NAME
     MOVE 1 TO WS-DBL
     MOVE 2 TO WS-KIND
     MOVE 10 TO WS-LEAFB
     MOVE 3 TO WS-NROWS
     MOVE 3 TO WS-ROW-RAD(1)
     MOVE 4 TO WS-ROW-RAD(2)
     MOVE 5 TO WS-ROW-RAD(3)
     MOVE 69 TO WS-LYV
     PERFORM CHECK-ROWS-DOWN

*>   5.2 jungle on a single trunk: hh = 1 + nextInt(2) (the draw replayed after the two height draws), rows at 69, 68 and, when hh is 2, 67
     MOVE "minecraft:t_jungle_single" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE 6 TO WS-BASE
     MOVE 0 TO WS-RA
     MOVE 0 TO WS-RB
     PERFORM REDRAW-HEIGHT
     MOVE 2 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-HH
     ADD 1 TO WS-HH
     MOVE "jungle foliage on a single trunk" TO WS-NAME
     MOVE 0 TO WS-DBL
     MOVE 2 TO WS-KIND
     MOVE 10 TO WS-LEAFB
     COMPUTE WS-NROWS = WS-HH + 1
     MOVE 3 TO WS-ROW-RAD(1)
     MOVE 4 TO WS-ROW-RAD(2)
     MOVE 5 TO WS-ROW-RAD(3)
     MOVE 69 TO WS-LYV
     PERFORM CHECK-ROWS-DOWN
     MOVE 67 TO WS-LYV
     MOVE -1 TO WS-RAD
     IF WS-HH = 1
         PERFORM CHECK-LAYER
         MOVE "acceptance US12 35-3§5 Foliage placers: jungle foliage with hh 1 has no third row" TO WS-CASE
         MOVE WS-DB TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
     END-IF

*>   5.2 mega pine on a giant trunk (H 8, crown 4, radius 3): rows at y = 67 .. 71 with radius 3 + floor(d / 4 * 3.5) = 6, 5, 4, 3, 3
     MOVE "minecraft:t_giant_megapine" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "mega pine" TO WS-NAME
     MOVE 1 TO WS-DBL
     MOVE 2 TO WS-KIND
     MOVE 12 TO WS-LEAFB
     MOVE 5 TO WS-NROWS
     MOVE 6 TO WS-ROW-RAD(1)
     MOVE 5 TO WS-ROW-RAD(2)
     MOVE 4 TO WS-ROW-RAD(3)
     MOVE 3 TO WS-ROW-RAD(4)
     MOVE 3 TO WS-ROW-RAD(5)
     MOVE 67 TO WS-LYV
     PERFORM CHECK-ROWS-UP

*>   5.2 mega pine (H 7, crown 7): a row of the radius of the row below on an even layer is one wider: 6, 7, 5, 6, 4, 5, 3, 3 from y = 63 to 70
     MOVE "minecraft:t_giant_megapine2" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "mega pine with the widened rows" TO WS-NAME
     MOVE 8 TO WS-NROWS
     MOVE 6 TO WS-ROW-RAD(1)
     MOVE 7 TO WS-ROW-RAD(2)
     MOVE 5 TO WS-ROW-RAD(3)
     MOVE 6 TO WS-ROW-RAD(4)
     MOVE 4 TO WS-ROW-RAD(5)
     MOVE 5 TO WS-ROW-RAD(6)
     MOVE 3 TO WS-ROW-RAD(7)
     MOVE 3 TO WS-ROW-RAD(8)
     MOVE 63 TO WS-LYV
     PERFORM CHECK-ROWS-UP

*>   5.2 acacia (radius 3, hh 0): the row of radius 3 at y = -1 skips its corners, the rows at y = 0 are radius 2 and keep the cross and the inner 3 x 3 square
     MOVE "minecraft:t_acacia_foliage" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "acacia foliage" TO WS-NAME
     MOVE 0 TO WS-DBL
     MOVE 14 TO WS-LEAFB
     MOVE 67 TO WS-LYV
     MOVE 3 TO WS-RAD
     MOVE 3 TO WS-KIND
     PERFORM CHECK-NAMED
     MOVE 68 TO WS-LYV
     MOVE 2 TO WS-RAD
     MOVE 4 TO WS-KIND
     PERFORM CHECK-NAMED

*>   5.2 dark oak, single trunk: rows (radius 2, y = -1) without the corners and (radius 1, y = 0) whole
     MOVE "minecraft:t_single_darkoak" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "dark oak foliage on a single trunk" TO WS-NAME
     MOVE 8 TO WS-LEAFB
     MOVE 68 TO WS-LYV
     MOVE 2 TO WS-RAD
     MOVE 5 TO WS-KIND
     PERFORM CHECK-NAMED
     MOVE 69 TO WS-LYV
     MOVE 1 TO WS-RAD
     MOVE 6 TO WS-KIND
     PERFORM CHECK-NAMED

*>   5.2 dark oak, double trunk: rows (2, -1) whole, (3, 0) without the signed corners, (2, 1) with ax + az <= 2, and (0, 2) when nextBoolean is set
     MOVE "minecraft:t_giant_darkoak" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE "dark oak foliage on a double trunk" TO WS-NAME
     MOVE 1 TO WS-DBL
     MOVE 68 TO WS-LYV
     MOVE 2 TO WS-RAD
     MOVE 6 TO WS-KIND
     PERFORM CHECK-NAMED
     MOVE 69 TO WS-LYV
     MOVE 3 TO WS-RAD
     MOVE 7 TO WS-KIND
     PERFORM CHECK-NAMED
     MOVE 70 TO WS-LYV
     MOVE 2 TO WS-RAD
     MOVE 8 TO WS-KIND
     PERFORM CHECK-NAMED
     MOVE 71 TO WS-LYV
     MOVE 8 TO WS-LEAFB
     PERFORM COUNT-LAYER
     MOVE "acceptance US12 35-3§5 Foliage placers: the dark oak top row of radius 0 has 0 or 4 leaves" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-COUNT = 0 OR WS-COUNT = 4
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   5.2 blob on a double trunk: the row y = 0 (radius 1, one wider to the south and east) skips its four folded corners: 16 - 4 leaves
     MOVE "minecraft:t_giant_blob" TO WS-KEY
     PERFORM LOAD-AND-PLACE
     MOVE 6 TO WS-LEAFB
     MOVE 69 TO WS-LYV
     PERFORM COUNT-LAYER
     MOVE "acceptance US12 35-3§5 Foliage placers: the top blob row of a double trunk has 12 leaves" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 12 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 LOAD-AND-PLACE.
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE "acceptance US12 35-3§5 Foliage placers: the tree is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     .
 CHECK-ROWS-DOWN.
*>   the rows 1 .. WS-NROWS with the radii WS-ROW-RAD, the first at layer WS-LYV and each next one layer lower
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NROWS
         MOVE WS-ROW-RAD(WS-I) TO WS-RAD
         PERFORM CHECK-NAMED
         SUBTRACT 1 FROM WS-LYV
     END-PERFORM
     .
 CHECK-ROWS-UP.
*>   the same with the first row at the lowest layer WS-LYV and each next one layer higher
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NROWS
         MOVE WS-ROW-RAD(WS-I) TO WS-RAD
         PERFORM CHECK-NAMED
         ADD 1 TO WS-LYV
     END-PERFORM
     .
 CHECK-NAMED.
     PERFORM CHECK-LAYER
     MOVE WS-LYV TO WS-LYD
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 35-3§5 Foliage placers: " FUNCTION TRIM(WS-NAME) " layer " WS-LYD " has exactly the leaves of its row" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-DB TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     .
 CHECK-LAYER.
*>   WS-DB = the cells of the window layer WS-LYV that disagree with the row (centre WS-CXX, WS-CZZ, radius WS-RAD, WS-DBL, skip test WS-KIND): a cell is a leaf of block WS-LEAFB when the row covers
*>   it, unless a log stands there (a log cell is not judged)
     MOVE 0 TO WS-DB
     MOVE WS-LYV TO WS-LY
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             PERFORM READ-BLOCK
             COMPUTE WS-DXX = WS-LX - WS-CXX
             COMPUTE WS-DZZ = WS-LZ - WS-CZZ
             PERFORM ROW-COVERS
             COMPUTE WS-D = WS-LEAFB - 1
             IF WS-BLOCK NOT = WS-D
                 IF WS-INROW = 1 AND WS-BLOCK NOT = WS-LEAFB
                     ADD 1 TO WS-DB
                 END-IF
                 IF WS-INROW = 0 AND WS-BLOCK = WS-LEAFB
                     ADD 1 TO WS-DB
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 ROW-COVERS.
*>   WS-INROW = 1 when the offset (WS-DXX, WS-DZZ) is in the row of radius WS-RAD (one wider to the south and east when WS-DBL = 1) and is not skipped by the test WS-KIND
     MOVE 0 TO WS-INROW
     IF WS-DXX >= 0 - WS-RAD AND WS-DXX <= WS-RAD + WS-DBL AND WS-DZZ >= 0 - WS-RAD AND WS-DZZ <= WS-RAD + WS-DBL
         MOVE 1 TO WS-INROW
         COMPUTE WS-AX = FUNCTION ABS(WS-DXX)
         COMPUTE WS-AZ = FUNCTION ABS(WS-DZZ)
         IF WS-DBL = 1
             COMPUTE WS-AX = FUNCTION MIN(FUNCTION ABS(WS-DXX), FUNCTION ABS(WS-DXX - 1))
             COMPUTE WS-AZ = FUNCTION MIN(FUNCTION ABS(WS-DZZ), FUNCTION ABS(WS-DZZ - 1))
         END-IF
         MOVE 0 TO WS-SKIP
         EVALUATE WS-KIND
             WHEN 1
                 COMPUTE WS-N = (2 * WS-AX + 1) * (2 * WS-AX + 1) + (2 * WS-AZ + 1) * (2 * WS-AZ + 1)
                 COMPUTE WS-D = 4 * WS-RAD * WS-RAD
                 IF WS-N > WS-D
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 2
                 COMPUTE WS-N = WS-AX * WS-AX + WS-AZ * WS-AZ
                 COMPUTE WS-D = WS-RAD * WS-RAD
                 IF WS-AX + WS-AZ >= 7 OR WS-N > WS-D
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 3
                 IF WS-AX = WS-RAD AND WS-AZ = WS-RAD AND WS-RAD > 0
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 4
                 IF (WS-AX > 1 OR WS-AZ > 1) AND WS-AX NOT = 0 AND WS-AZ NOT = 0
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 5
                 IF WS-AX = WS-RAD AND WS-AZ = WS-RAD
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 7
                 IF (WS-DXX = 0 - WS-RAD OR WS-DXX >= WS-RAD) AND (WS-DZZ = 0 - WS-RAD OR WS-DZZ >= WS-RAD)
                     MOVE 1 TO WS-SKIP
                 END-IF
             WHEN 8
                 COMPUTE WS-N = WS-RAD * 2 - 2
                 IF WS-AX + WS-AZ > WS-N
                     MOVE 1 TO WS-SKIP
                 END-IF
         END-EVALUATE
         IF WS-SKIP = 1
             MOVE 0 TO WS-INROW
         END-IF
     END-IF
     .
 COUNT-LAYER.
     MOVE 0 TO WS-COUNT
     MOVE WS-LYV TO WS-LY
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             PERFORM READ-BLOCK
             IF WS-BLOCK = WS-LEAFB
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     .
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
 END PROGRAM TEST-FEAT-35-3-5.

 COPY CORETEST.
