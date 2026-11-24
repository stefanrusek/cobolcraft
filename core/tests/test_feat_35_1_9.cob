*> Acceptance test of docs/protocol/35-worldgen-features-1 section 9 (generic and combinator features): random_selector (the data example 0.33333334 and
*> 0.0125 with two draws falling to the default for seed 1000), simple_random_selector (one draw even for a size of 1; 1, 0, 2 for nextInt(3)),
*> random_boolean_selector (true, true, true, false), weighted_random_selector (60 and 40: draws 67 and 34 choose the second then the first; an empty
*> list draws nothing), and sequence (stops at the first false).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-CHANCES.
    05 WS-CHANCE           FLOAT-LONG OCCURS 64 TIMES.
 01 WS-WEIGHTS.
    05 WS-WEIGHT           BINARY-LONG OCCURS 64 TIMES.
 01 WS-RESULTS.
    05 WS-R                BINARY-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-RAN                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-PTR                 BINARY-LONG.
 01 WS-NUM                 PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   9.2
     MOVE 0.33333334 TO WS-CHANCE(1)
     MOVE 0.0125 TO WS-CHANCE(2)
     MOVE 2 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-RANDOM-SELECTOR" USING XR-STATE WS-N WS-CHANCES WS-CHOSEN
     MOVE "acceptance US12 35-1§9 Generic and combinator features: random_selector falls through both entries to the default for seed 1000" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHOSEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-F
     MOVE "acceptance US12 35-1§9 Generic and combinator features: random_selector consumed two draws (the next float is the third, 0.740)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-F * 1000
     MOVE 740 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.7 TO WS-CHANCE(1)
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-RANDOM-SELECTOR" USING XR-STATE WS-N WS-CHANCES WS-CHOSEN
     MOVE "acceptance US12 35-1§9 Generic and combinator features: random_selector chooses the first entry whose chance exceeds the float (0.617 < 0.7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CHOSEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.3
     MOVE 3 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-RESULT
     PERFORM 6 TIMES
         CALL "F351-SIMPLE-SELECTOR" USING XR-STATE WS-N WS-CHOSEN
         COMPUTE WS-RESULT = WS-RESULT * 10 + WS-CHOSEN
     END-PERFORM
     MOVE "acceptance US12 35-1§9 Generic and combinator features: simple_random_selector over 3 chooses elements 2, 1, 3, 1, 2, 2 (nextInt(3) plus 1)" TO TL-CASE
     MOVE 213122 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-SIMPLE-SELECTOR" USING XR-STATE WS-N WS-CHOSEN
     MOVE 16 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-RESULT
     MOVE "acceptance US12 35-1§9 Generic and combinator features: a size of 1 still consumes a draw (the next nextInt(16) is the second, 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.4
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-RESULT
     PERFORM 6 TIMES
         CALL "F351-BOOLEAN-SELECTOR" USING XR-STATE WS-CHOSEN
         COMPUTE WS-RESULT = WS-RESULT * 10 + WS-CHOSEN
     END-PERFORM
     MOVE "acceptance US12 35-1§9 Generic and combinator features: random_boolean_selector gives true, true, true, false, true, false (1 and 2)" TO TL-CASE
     MOVE 111212 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.5
     MOVE 60 TO WS-WEIGHT(1)
     MOVE 40 TO WS-WEIGHT(2)
     MOVE 2 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-WEIGHTED-SELECTOR" USING XR-STATE WS-N WS-WEIGHTS WS-CHOSEN
     MOVE WS-CHOSEN TO WS-RESULT
     CALL "F351-WEIGHTED-SELECTOR" USING XR-STATE WS-N WS-WEIGHTS WS-CHOSEN
     COMPUTE WS-RESULT = WS-RESULT * 10 + WS-CHOSEN
     MOVE "acceptance US12 35-1§9 Generic and combinator features: weighted_random_selector 60 and 40: draws 67 and 34 choose entries 2 then 1" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-WEIGHTED-SELECTOR" USING XR-STATE WS-N WS-WEIGHTS WS-CHOSEN
     MOVE 16 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-RESULT
     MOVE "acceptance US12 35-1§9 Generic and combinator features: an empty weighted list chooses nothing and draws nothing (the next nextInt(16) is the first, 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-CHOSEN * 100 + WS-RESULT
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.6
     MOVE 1 TO WS-R(1)
     MOVE 1 TO WS-R(2)
     MOVE 0 TO WS-R(3)
     MOVE 1 TO WS-R(4)
     MOVE 4 TO WS-N
     CALL "F351-SEQUENCE" USING WS-N WS-RESULTS WS-RAN WS-RESULT
     MOVE "acceptance US12 35-1§9 Generic and combinator features: sequence stops at the first false (3 elements run, result false)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RAN * 10 + WS-RESULT
     MOVE 30 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-R(3)
     CALL "F351-SEQUENCE" USING WS-N WS-RESULTS WS-RAN WS-RESULT
     MOVE "acceptance US12 35-1§9 Generic and combinator features: sequence of true elements runs them all and returns true" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RAN * 10 + WS-RESULT
     MOVE 41 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
