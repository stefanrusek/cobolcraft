*> Implementation test of the bounds of a density function over a grid cell (core/src/density.cob, DENSITY-HULL; the terrain fill
*> uses them to skip the evaluation where a cell is decided). Fixture tree core/tests/fixtures/hull (an interpolated node with a
*> grid of this test's own, and the node types the bounds know: reference, cache, blend_density, constants, blend_alpha, blend_offset,
*> beardifier, sum, difference, product, minimum, maximum, absolute value, squeeze, range choice; clamp is one they do not know).
*> For every function the bounds of the cell (0, 0, 0) must hold for the value the evaluator gives at positions of the cell (the
*> property the fill relies on), and a few bounds are checked exactly. The cell's eight corners are -0.5, 0.25, 1.5, -0.25, 0.75, 1.0,
*> 0.0 and 0.5 (the other grid values 0), so the bounds of the grid node are -0.5 and 1.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DENSITY-HULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY DENSITY.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/hull".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NAMES.
    05 FILLER PIC X(16) VALUE "grid".
    05 FILLER PIC X(16) VALUE "ref".
    05 FILLER PIC X(16) VALUE "wrap".
    05 FILLER PIC X(16) VALUE "consts".
    05 FILLER PIC X(16) VALUE "sub".
    05 FILLER PIC X(16) VALUE "sub2".
    05 FILLER PIC X(16) VALUE "mul1".
    05 FILLER PIC X(16) VALUE "mul2".
    05 FILLER PIC X(16) VALUE "mul3".
    05 FILLER PIC X(16) VALUE "min".
    05 FILLER PIC X(16) VALUE "max".
    05 FILLER PIC X(16) VALUE "abs1".
    05 FILLER PIC X(16) VALUE "abs2".
    05 FILLER PIC X(16) VALUE "abs3".
    05 FILLER PIC X(16) VALUE "squeeze1".
    05 FILLER PIC X(16) VALUE "squeeze2".
    05 FILLER PIC X(16) VALUE "rc_in".
    05 FILLER PIC X(16) VALUE "rc_out".
    05 FILLER PIC X(16) VALUE "rc_below".
    05 FILLER PIC X(16) VALUE "rc_both1".
    05 FILLER PIC X(16) VALUE "rc_both2".
    05 FILLER PIC X(16) VALUE "unknown".
    05 FILLER PIC X(16) VALUE "loose".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 23 TIMES.
 01 WS-GRID.
    05 WS-G.
       COPY GENGRID REPLACING LEADING ==GJ-== BY ==WG-==.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-K              BINARY-LONG VALUE 0.
 01 WS-ZERO-J              BINARY-LONG VALUE 0.
 01 WS-ZERO-N              BINARY-LONG VALUE 0.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 3.
 01 WS-XT REDEFINES WS-XS.
    05 WS-XV               BINARY-LONG OCCURS 3 TIMES.
 01 WS-YS.
    05 FILLER              BINARY-LONG VALUE -64.
    05 FILLER              BINARY-LONG VALUE -60.
    05 FILLER              BINARY-LONG VALUE -57.
 01 WS-YT REDEFINES WS-YS.
    05 WS-YV               BINARY-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WORLDGEN-FREE"
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "test density hull the fixture functions load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DENSITY-SETUP" USING WS-SEED
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:t/grid" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     MOVE 1 TO WG-G-COUNT
     MOVE WS-NODE TO WG-G-NODE(1)
     MOVE -0.5 TO WG-G-VAL(1)
     MOVE 0.25 TO WG-G-VAL(246)
     MOVE 1.5 TO WG-G-VAL(2)
     MOVE -0.25 TO WG-G-VAL(247)
     MOVE 0.75 TO WG-G-VAL(50)
     MOVE 1.0 TO WG-G-VAL(295)
     MOVE 0.0 TO WG-G-VAL(51)
     MOVE 0.5 TO WG-G-VAL(296)
     MOVE 1 TO DNG-ACTIVE
     MOVE 0 TO DNG-X0 DNG-Z0
     SET DNG-PTR TO ADDRESS OF WS-GRID

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-KEY
         STRING "minecraft:t/" FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
         CALL "DENSITY-HULL" USING WS-ROOT WS-ZERO WS-ZERO-K WS-ZERO-J WS-LO WS-HI
*>       the value at positions of the cell lies within the bounds (less than 0.001 outside, the margin of the fill)
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 3
             PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 3
                 PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 3
                     MOVE WS-XV(WS-X) TO WS-A
                     MOVE WS-YV(WS-Y) TO WS-B
                     MOVE WS-XV(WS-Z) TO WS-C
                     CALL "DENSITY-EVAL" USING WS-KEY WS-A WS-B WS-C WS-V
                     COMPUTE WS-T = WS-LO - 0.001
                     IF WS-V < WS-T
                         ADD 1 TO WS-BAD
                     END-IF
                     COMPUTE WS-T = WS-HI + 0.001
                     IF WS-V > WS-T
                         ADD 1 TO WS-BAD
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "test density hull " FUNCTION TRIM(WS-NAME(WS-I)) ": the value inside the cell is within the bounds"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-BAD TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       a few bounds exactly, in thousandths
         MOVE 0 TO WS-P
         EVALUATE FUNCTION TRIM(WS-NAME(WS-I))
             WHEN "grid"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 1500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "ref"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 1500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "wrap"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "consts"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE 3500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "sub"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 1000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "sub2"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "mul1"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -3000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "min"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE -1000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "max"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE 3000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "abs1"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE 0 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 1500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "abs2"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE 500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "abs3"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 2500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "rc_in"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 2500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "rc_out"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -500 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "rc_below"
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE -3000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "rc_both1"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -3000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 2000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "rc_both2"
                 COMPUTE WS-P ROUNDED = WS-LO * 1000
                 MOVE -2000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
                 COMPUTE WS-P ROUNDED = WS-HI * 1000
                 MOVE 5000 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "unknown"
                 MOVE 0 TO WS-P
                 IF WS-LO < -100000000000 AND WS-HI > 100000000000
                     MOVE 1 TO WS-P
                 END-IF
                 MOVE 1 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
             WHEN "loose"
*>               grid2 has no slot in the grids: its bounds are open, so is the sum
                 MOVE 0 TO WS-P
                 IF WS-LO < -100000000000 AND WS-HI > 100000000000
                     MOVE 1 TO WS-P
                 END-IF
                 MOVE 1 TO TL-EXPECTED-N
                 PERFORM CHECK-EXACT
         END-EVALUATE
     END-PERFORM

*>   a cache node of a function that does not read y is kept by column: the position of another column in between, then the first
*>   column at another y
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:t/cached" TO WS-KEY
     MOVE 0 TO WS-A WS-C
     MOVE 5 TO WS-B
     CALL "DENSITY-EVAL" USING WS-KEY WS-A WS-B WS-C WS-V
     MOVE 2 TO WS-A
     CALL "DENSITY-EVAL" USING WS-KEY WS-A WS-B WS-C WS-V
     MOVE 0 TO WS-A
     MOVE 9 TO WS-B
     CALL "DENSITY-EVAL" USING WS-KEY WS-A WS-B WS-C WS-V
     MOVE "test density hull a cache node's value is the same at another y of its column" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 10
     MOVE 25 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a position outside the chunk's 16 x 16 columns does not use the grid: the input (0) is interpolated
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:t/grid" TO WS-KEY
     MOVE 20 TO WS-A
     MOVE -60 TO WS-B
     MOVE 1 TO WS-C
     CALL "DENSITY-EVAL" USING WS-KEY WS-A WS-B WS-C WS-V
     MOVE "test density hull an interpolated node outside the grid columns takes its input" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 10
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   without the grid mode an interpolated node has open bounds
     MOVE 0 TO DNG-ACTIVE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:t/grid" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
     CALL "DENSITY-HULL" USING WS-ROOT WS-ZERO WS-ZERO-K WS-ZERO-J WS-LO WS-HI
     MOVE "test density hull without the grid mode an interpolated node has open bounds" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LO < -100000000000 AND WS-HI > 100000000000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the node 0 (no function) is the constant 0
     CALL "DENSITY-HULL" USING WS-ZERO-N WS-ZERO WS-ZERO-K WS-ZERO-J WS-LO WS-HI
     MOVE "test density hull the node 0 has the bounds 0 and 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LO + WS-HI
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-EXACT.
     MOVE SPACES TO TL-CASE
     STRING "test density hull " FUNCTION TRIM(WS-NAME(WS-I)) ": a bound of the cell is exact (thousandths)"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-P TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-DENSITY-HULL.
