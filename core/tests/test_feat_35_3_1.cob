*> Acceptance test of docs/protocol/35-worldgen-features-3 section 1 (shared helpers): getTreeHeight and its draws, getRandomDirection, the direction steps, validTreePos and isFree, the FoliageAttachment sizes and the waterlogged helper.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 4 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     CALL "F353-TREE-HEIGHT" USING XR-STATE WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: getTreeHeight 4 + nextInt(3) + nextInt(1) is 5 for seed 1000" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 4 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     CALL "F353-TREE-HEIGHT" USING XR-STATE WS-A WS-B WS-C WS-D
     MOVE 16 TO WS-E
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-E WS-F
     MOVE "acceptance US12 35-3§1 Shared helpers: both height draws are made, even for bound 1 (the next nextInt(16) is the third draw, 11)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F353-RANDOM-DIRECTION" USING XR-STATE WS-A
     CALL "F353-RANDOM-DIRECTION" USING XR-STATE WS-B
     CALL "F353-RANDOM-DIRECTION" USING XR-STATE WS-C
     CALL "F353-RANDOM-DIRECTION" USING XR-STATE WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: getRandomDirection over [NORTH, EAST, SOUTH, WEST]: SOUTH, SOUTH, SOUTH, EAST for seed 1000" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A * 1000 + WS-B * 100 + WS-C * 10 + WS-D
     MOVE 3335 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 0 steps (0, -1, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 101 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 1 steps (0, 1, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 121 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 2 steps (0, 0, -1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 3 steps (0, 0, 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 112 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 4 steps (-1, 0, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "F353-STEP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: direction 5 steps (1, 0, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-B + 1) * 100 + (WS-C + 1) * 10 + (WS-D + 1)
     MOVE 211 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "F353-VALID-TREE-POS" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "acceptance US12 35-3§1 Shared helpers: air is a valid tree position" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "F353-VALID-TREE-POS" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "acceptance US12 35-3§1 Shared helpers: a replaceable_by_trees block is valid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     CALL "F353-VALID-TREE-POS" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "acceptance US12 35-3§1 Shared helpers: a log is not a valid tree position" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 2 TO WS-D
     CALL "F353-VALID-TREE-POS" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "acceptance US12 35-3§1 Shared helpers: a log is free for a trunk" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 2 TO WS-D
     CALL "F353-VALID-TREE-POS" USING WS-A WS-B WS-C WS-D WS-E
     MOVE "acceptance US12 35-3§1 Shared helpers: stone is not free" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-E
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F353-ATTACHMENT-SIZE" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: an attachment with doubleTrunk false has sizes 1 and is not double" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 100 + WS-C * 10 + WS-D
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F353-ATTACHMENT-SIZE" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US12 35-3§1 Shared helpers: an attachment with doubleTrunk true has sizes 2 and is double" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 100 + WS-C * 10 + WS-D
     MOVE 221 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "F353-WATERLOGGED" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§1 Shared helpers: a state without waterlogged is unchanged" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "F353-WATERLOGGED" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§1 Shared helpers: waterlogged follows the fluid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "F353-WATERLOGGED" USING WS-A WS-B WS-C
     MOVE "acceptance US12 35-3§1 Shared helpers: waterlogged is false without the fluid" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
