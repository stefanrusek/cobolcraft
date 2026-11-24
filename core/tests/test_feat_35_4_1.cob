*> Acceptance test of docs/protocol/35-worldgen-features-4 section 1 (conventions): the derived draws (nextIntBetweenInclusive, Mth.nextInt, shuffle, pick) on the wrapped source
*> seeded with 1000 (nextInt(16) gives 9, 10, 11, 7 there) and the direction tables (the horizontal plane, getClockWise, from2DDataValue).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-B16                 BINARY-LONG VALUE 16.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F354-PICK" USING XR-STATE WS-B16 WS-A
     MOVE "acceptance US12 35-4§1 Conventions: pick draws one nextInt(size) (the first nextInt(16) is 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 4 TO WS-A
     MOVE 19 TO WS-B
     CALL "F354-BETWEEN-INCLUSIVE" USING XR-STATE WS-A WS-B WS-N
     MOVE "acceptance US12 35-4§1 Conventions: nextIntBetweenInclusive(4, 19) is nextInt(16) + 4 = 13" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N
     MOVE 13 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     CALL "F354-MTH-NEXT-INT" USING XR-STATE WS-A WS-B WS-N
     CALL "F354-PICK" USING XR-STATE WS-B16 WS-A
     MOVE "acceptance US12 35-4§1 Conventions: Mth.nextInt(r, 5, 5) is 5 and draws nothing (the next nextInt(16) is still 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N * 100 + WS-A
     MOVE 509 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-A
     MOVE 15 TO WS-B
     CALL "F354-MTH-NEXT-INT" USING XR-STATE WS-A WS-B WS-N
     MOVE "acceptance US12 35-4§1 Conventions: Mth.nextInt(r, 0, 15) is lo + nextInt(16) = 9" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 1 TO WS-L(1)
     MOVE 2 TO WS-L(2)
     MOVE 3 TO WS-L(3)
     MOVE 3 TO WS-N
     CALL "F354-SHUFFLE" USING XR-STATE WS-N WS-LIST
     MOVE "acceptance US12 35-4§1 Conventions: shuffle of three elements draws nextInt(3) then nextInt(2): (1, 2, 3) becomes (1, 3, 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-L(1) * 100 + WS-L(2) * 10 + WS-L(3)
     MOVE 132 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 7 TO WS-L(1)
     MOVE 1 TO WS-N
     CALL "F354-SHUFFLE" USING XR-STATE WS-N WS-LIST
     CALL "F354-PICK" USING XR-STATE WS-B16 WS-A
     MOVE "acceptance US12 35-4§1 Conventions: shuffle of one element draws nothing (the next nextInt(16) is 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-L(1) * 100 + WS-A
     MOVE 709 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-N
     CALL "F354-SHUFFLE" USING XR-STATE WS-N WS-LIST
     CALL "F354-PICK" USING XR-STATE WS-B16 WS-A
     MOVE "acceptance US12 35-4§1 Conventions: shuffle of no element draws nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F354-PLANE-DIRECTION" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: the horizontal plane holds NORTH, EAST, SOUTH, WEST: index 0 is ordinal 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F354-PLANE-DIRECTION" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: the horizontal plane holds NORTH, EAST, SOUTH, WEST: index 1 is ordinal 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F354-PLANE-DIRECTION" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: the horizontal plane holds NORTH, EAST, SOUTH, WEST: index 2 is ordinal 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F354-PLANE-DIRECTION" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: the horizontal plane holds NORTH, EAST, SOUTH, WEST: index 3 is ordinal 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F354-CLOCKWISE" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: getClockWise of ordinal 2 is 5 (N, E, S, W, N)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "F354-CLOCKWISE" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: getClockWise of ordinal 5 is 3 (N, E, S, W, N)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F354-CLOCKWISE" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: getClockWise of ordinal 3 is 4 (N, E, S, W, N)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "F354-CLOCKWISE" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: getClockWise of ordinal 4 is 2 (N, E, S, W, N)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(0) is ordinal 3 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(1) is ordinal 4 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(2) is ordinal 2 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(3) is ordinal 5 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(4) is ordinal 3 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(-1) is ordinal 4 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(-5) is ordinal 4 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "F354-FROM-2D" USING WS-A WS-B
     MOVE "acceptance US12 35-4§1 Conventions: from2DDataValue(6) is ordinal 2 (SOUTH, WEST, NORTH, EAST by |i mod 4|)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
