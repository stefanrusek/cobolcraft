*> Acceptance test of docs/protocol/35-worldgen-features-2 section 4 (block state providers): the draws of rotated, random_block and randomized_int, the axis of a direction, the fall-through of rule_based (example 4), and the property identity rule of copy_properties.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-4.
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
 01 WS-DRAW                BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIST2.
    05 WS-L2               BINARY-LONG OCCURS 64 TIMES.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CH                  FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-S3                  BINARY-DOUBLE.
 01 WS-SEED2               BINARY-DOUBLE UNSIGNED.
 01 WS-EDIT                PIC -(19)9.
 01 WS-TEXT                PIC X(64).
 01 WS-NAME32              PIC X(32).
 01 WS-TXT16               PIC X(16).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -1 TO WS-A
     CALL "F352-ROTATED-DIRECTION" USING XR-STATE WS-A WS-B
     MOVE 6 TO WS-C
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rotated without a direction draws one nextInt(6) first (the draw equals a manual one)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B - WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 1 TO WS-A
     CALL "F352-ROTATED-DIRECTION" USING XR-STATE WS-A WS-B
     MOVE 16 TO WS-C
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rotated with a direction draws nothing (the next nextInt(16) is the first, 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 100 + WS-D
     MOVE 109 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction down has axis y" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction up has axis y" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction north has axis z" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction south has axis z" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction west has axis x" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "F352-AXIS-OF" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: direction east has axis x" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-A
     CALL "F352-RANDOM-BLOCK" USING XR-STATE WS-A WS-B
     MOVE 16 TO WS-C
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: random_block over an empty set draws nothing and chooses nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B * 100 + WS-D
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 3 TO WS-A
     CALL "F352-RANDOM-BLOCK" USING XR-STATE WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: random_block over 3 blocks draws one nextInt(3) (1 for seed 1000) and chooses the 2nd" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-L(1)
     MOVE 5 TO WS-L2(1)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 7 TO WS-C
     CALL "F352-RULE-BASED" USING WS-A WS-LIST WS-LIST2 WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rule_based, no rule holds and no fallback: nothing optional, the level state for getState (example 4)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-E
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 5 TO WS-L2(1)
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 7 TO WS-C
     CALL "F352-RULE-BASED" USING WS-A WS-LIST WS-LIST2 WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rule_based, the rule holds: the state is the rule's" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-E
     MOVE 505 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 0 TO WS-L2(1)
     MOVE 9 TO WS-L2(2)
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 7 TO WS-C
     CALL "F352-RULE-BASED" USING WS-A WS-LIST WS-LIST2 WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rule_based, a matching rule that gives nothing continues to the next rule" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-E
     MOVE 909 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 5 TO WS-L2(1)
     MOVE 0 TO WS-L2(2)
     MOVE 2 TO WS-A
     MOVE 4 TO WS-B
     MOVE 7 TO WS-C
     CALL "F352-RULE-BASED" USING WS-A WS-LIST WS-LIST2 WS-B WS-C WS-D WS-E
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: rule_based, the fallback gives the optional result when no rule gives one" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-E
     MOVE 404 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 1 TO WS-A
     MOVE 23 TO WS-B
     MOVE 25 TO WS-C
     CALL "F352-RANDOMIZED-INT" USING XR-STATE WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: randomized_int with the property draws one uniform sample (23 + nextInt(3) = 24 for seed 1000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 24 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-A
     MOVE 23 TO WS-B
     MOVE 25 TO WS-C
     CALL "F352-RANDOMIZED-INT" USING XR-STATE WS-A WS-B WS-C WS-D
     MOVE 16 TO WS-E
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-E WS-F
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: randomized_int without the property returns the state unchanged and draws nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-F
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-L(1)
     MOVE 0 TO WS-L(2)
     MOVE 1 TO WS-L(3)
     MOVE 3 TO WS-A
     CALL "F352-COPY-COUNT" USING WS-A WS-LIST WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§4 Block state providers: copy_properties copies only the properties the source has" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
