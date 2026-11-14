*> Implementation test of the poplar trunk (docs/protocol/35-worldgen-features-3-tree-placers.md 4.10) and foliage (5.4 and 5.5; core/src/feat-tree-poplar.cob): the data features compile as
*> trees; the side logs of a poplar trunk are exactly the first branch_amount horizontals of the shuffle of the layer below the branch height (the shuffles are replayed from the same seed); the
*> leaves of a poplar crown without holes (side_hole_chance 0) and with every hole (1) have the per-layer counts written out from the rows of 5.4 and the inside test of 5.5; a crown of
*> radius 4 turns the leaf at the centre of its row hh - 4 into a log with the x axis.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-9.
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
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIRS.
    05 WS-DIRS-V           BINARY-LONG OCCURS 6 TIMES.
 01 WS-HORS.
    05 WS-HORS-V           BINARY-LONG OCCURS 6 TIMES.
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

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:t_poplar_trunk" TO WS-KEY
             WHEN 2 MOVE "minecraft:t_poplar_leaves" TO WS-KEY
             WHEN 3 MOVE "minecraft:t_poplar_holes" TO WS-KEY
             WHEN 4 MOVE "minecraft:t_poplar_logs" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-3§4.10 and 5.4: the data feature " FUNCTION TRIM(WS-KEY) " compiles as a tree" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE 51 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   4.10 H = 8, branch height 8 - 2 = 6, so the branch layer is i = 5 (y = 68) with 3 side logs; every layer shuffles the directions (5 draws): replayed from the seed
     MOVE "minecraft:t_poplar_trunk" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         MOVE 8 TO WS-BASE
         MOVE 0 TO WS-RA
         MOVE 0 TO WS-RB
         CALL "F353-TREE-HEIGHT" USING XR2-STATE WS-BASE WS-RA WS-RB WS-H
         PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 5
             PERFORM REPLAY-SHUFFLE
         END-PERFORM
*>       WS-NB horizontals in order, the first three are the expected side logs of layer 68
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > WS-NB
             PERFORM CHECK-SIDE
         END-PERFORM
         MOVE 5 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT NOT = 11
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-3§4.10: twenty poplar trunks have 8 + 3 logs, the side logs where the replayed shuffle says with the axis of their side" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   5.4 the crown without holes (radius 3, height 8, attachment y = 69): layers 76 down to 68 have 0, 1, 7, 17, 17, 17, 17, 7, 6 leaves, 89 in all
     MOVE "minecraft:t_poplar_leaves" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 5 TO WS-LOGB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT NOT = 89
             ADD 1 TO WS-BAD
         END-IF
         MOVE 76 TO WS-N
         MOVE 0 TO WS-EXP
         PERFORM LAYER-BAD
         MOVE 75 TO WS-N
         MOVE 1 TO WS-EXP
         PERFORM LAYER-BAD
         MOVE 74 TO WS-N
         MOVE 7 TO WS-EXP
         PERFORM LAYER-BAD
         PERFORM VARYING WS-N FROM 70 BY 1 UNTIL WS-N > 73
             MOVE 17 TO WS-EXP
             PERFORM LAYER-BAD
         END-PERFORM
         MOVE 69 TO WS-N
         MOVE 7 TO WS-EXP
         PERFORM LAYER-BAD
         MOVE 68 TO WS-N
         MOVE 6 TO WS-EXP
         PERFORM LAYER-BAD
     END-PERFORM
     MOVE "35-3§5.4 and 5.5: ten poplar crowns without holes have the leaves of every layer the rows give (89)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   every hole: 0, 1, 7 x 4, 1, 0 on the layers 75 to 68: 30 leaves
     MOVE "minecraft:t_poplar_holes" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 6 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-COUNT NOT = 30
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-3§5.5: ten poplar crowns with side_hole_chance 1 have 30 leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a crown of radius 4: the centre of the row at y = hh - 4 above the attachment (73) becomes a log with the x axis; 6 + 1 logs
     MOVE "minecraft:t_poplar_logs" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§5.5: a poplar crown of radius 4 has one log in its crown (6 + 1 logs)" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 7 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-LX
     MOVE 73 TO WS-LY
     MOVE 40 TO WS-LZ
     PERFORM READ-BLOCK
     MOVE "35-3§5.5: the log is at the centre of the crown row hh - 4" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     COMPUTE WS-EXP = CB-DEFAULT-STATE(5) - 1
     PERFORM ASSERT-N
     STOP RUN.

 REPLAY-SHUFFLE.
*>   the shuffle of one layer from XR2-STATE (5.1 4.10: for n = 6 down to 2 swap element nextInt(n) with element n - 1), then the horizontal directions in order in WS-HORS-V(1 .. WS-NB)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         COMPUTE WS-DIRS-V(WS-J) = WS-J - 1
     END-PERFORM
     PERFORM VARYING WS-K FROM 6 BY -1 UNTIL WS-K < 2
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-K WS-D
         MOVE WS-DIRS-V(WS-D + 1) TO WS-V
         MOVE WS-DIRS-V(WS-K) TO WS-DIRS-V(WS-D + 1)
         MOVE WS-V TO WS-DIRS-V(WS-K)
     END-PERFORM
     MOVE 0 TO WS-NB
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         IF WS-DIRS-V(WS-J) >= 2
             ADD 1 TO WS-NB
             MOVE WS-DIRS-V(WS-J) TO WS-HORS-V(WS-NB)
         END-IF
     END-PERFORM
     .
 CHECK-SIDE.
*>   WS-D = 1 .. WS-NB: the side log of direction WS-HORS-V(WS-D) beside (24, 68, 40) is there (a log with its axis) for the first three, absent for the others
     MOVE 24 TO WS-LX
     MOVE 68 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 5 TO WS-V
     EVALUATE WS-HORS-V(WS-D)
         WHEN 2
             MOVE 39 TO WS-LZ
             MOVE 1 TO WS-V
         WHEN 3
             MOVE 41 TO WS-LZ
             MOVE 1 TO WS-V
         WHEN 4
             MOVE 23 TO WS-LX
             MOVE -1 TO WS-V
         WHEN OTHER
             MOVE 25 TO WS-LX
             MOVE -1 TO WS-V
     END-EVALUATE
     PERFORM READ-BLOCK
     IF WS-D <= 3
         IF WS-STATE NOT = CB-DEFAULT-STATE(5) + WS-V
             ADD 1 TO WS-BAD
         END-IF
     ELSE
         IF WS-BLOCK = 5
             ADD 1 TO WS-BAD
         END-IF
     END-IF
     .
 LAYER-BAD.
*>   the leaves (block 6) of layer WS-N against WS-EXP: counts a fault
     MOVE 6 TO WS-LOGB
     PERFORM COUNT-LAYER
     IF WS-COUNT NOT = WS-EXP
         ADD 1 TO WS-BAD
     END-IF
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
     MOVE 15 TO CB-EPOCH
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
 END PROGRAM TEST-FEAT-35-3-9.
