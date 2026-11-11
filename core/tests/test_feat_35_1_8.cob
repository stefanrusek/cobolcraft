*> Acceptance test of docs/protocol/35-worldgen-features-1 section 8 (PlacedFeature.place, FeaturePlacer and PlacementContext): an empty modifier list places the
*> feature once and returns its result; the stack evaluator of 8.2 makes the draw sequence dx1 dz1 y1 [F1] dx2 dz2 y2 [F2] dx3 dz3 y3 [F3] (the trace of the
*> section, checked against draws made by hand); a modifier that emits nothing gives a false result; the last modifier's emissions are placed in order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 COPY FEAT351.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-X                   BINARY-LONG VALUE 32.
 01 WS-Y                   BINARY-LONG VALUE 64.
 01 WS-Z                   BINARY-LONG VALUE -16.
 01 WS-RESULT              BINARY-LONG.
 01 WS-B16                 BINARY-LONG VALUE 16.
 01 WS-B65                 BINARY-LONG VALUE 65.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   8.2 step 1: no modifiers
     MOVE 0 TO FP-COUNT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-PLACE" USING XR-STATE WS-X WS-Y WS-Z WS-RESULT
     MOVE "acceptance US12 35-1§8 PlacedFeature.place, FeaturePlacer and PlacementContext: no modifiers places the feature once at the input and returns its result" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FO-COUNT * 100000 + WS-RESULT * 10000 + FO-X(1) * 100 + FO-Z(1) + 16
     MOVE 113200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the trace: [count 3, in_square, height_range uniform 0..64, biome]
     MOVE 4 TO FP-COUNT
     MOVE 1 TO FP-KIND(1)
     MOVE 3 TO FP-A(1)
     MOVE 2 TO FP-KIND(2)
     MOVE 3 TO FP-KIND(3)
     MOVE 0 TO FP-A(3)
     MOVE 64 TO FP-B(3)
     MOVE 4 TO FP-KIND(4)
     MOVE 1 TO FP-A(4)
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-PLACE" USING XR-STATE WS-X WS-Y WS-Z WS-RESULT
     MOVE "acceptance US12 35-1§8 PlacementContext: the trace places 3 positions and returns true" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FO-COUNT * 10 + WS-RESULT
     MOVE 31 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the draws by hand: dx dz y per repeat, depth first
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B65 WS-DY
         IF FO-X(WS-I) NOT = WS-X + WS-DX OR FO-Z(WS-I) NOT = WS-Z + WS-DZ OR FO-Y(WS-I) NOT = WS-DY
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-1§8 PlacedFeature.place: the draw sequence is dx1 dz1 y1 dx2 dz2 y2 dx3 dz3 y3 (depth first)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a biome filter that fails: nothing placed, false, the draws are still all made
     MOVE 0 TO FP-A(4)
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-PLACE" USING XR-STATE WS-X WS-Y WS-Z WS-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-NEXT
     MOVE "acceptance US12 35-1§8 PlacedFeature.place: a failing last modifier places nothing and returns false" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FO-COUNT * 10 + WS-RESULT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     PERFORM 9 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
     END-PERFORM
     MOVE "acceptance US12 35-1§8 PlacedFeature.place: the failing run made all 9 draws (the next nextInt(16) follows them)" TO TL-CASE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-I
     PERFORM 3 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B65 WS-DY
     END-PERFORM
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
     MOVE WS-DX TO TL-EXPECTED-N
     MOVE WS-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   count 0 emits nothing: false, no draws
     MOVE 2 TO FP-COUNT
     MOVE 0 TO FP-A(1)
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-PLACE" USING XR-STATE WS-X WS-Y WS-Z WS-RESULT
     MOVE "acceptance US12 35-1§8 PlacedFeature.place: a count of 0 places nothing and returns false" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FO-COUNT * 10 + WS-RESULT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the last modifier emits several positions: placed in emission order after the modifier finished
     MOVE 2 TO FP-COUNT
     MOVE 1 TO FP-KIND(1)
     MOVE 1 TO FP-A(1)
     MOVE 8 TO FP-KIND(2)
     MOVE 1 TO FP-A(2)
     MOVE 1 TO FP-B(2)
     MOVE 1 TO FP-C(2)
     MOVE 1 TO FP-D(2)
     CALL "F351-PLACE" USING XR-STATE WS-X WS-Y WS-Z WS-RESULT
     MOVE "acceptance US12 35-1§8 PlacedFeature.place: the last modifier's 8 cuboid cells are all placed, in emission order" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FO-COUNT * 10000 + (FO-X(2) - WS-X) * 1000 + (FO-Y(2) - WS-Y) * 100 + (FO-Z(2) - WS-Z) * 10 + (FO-Y(3) - WS-Y)
     MOVE 80011 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
