*> Acceptance test of docs/protocol/35-worldgen-features-1 section 10 (numeric providers as the placement code draws them): the decode bounds of the providers of count, count_on_every_layer, offset and cuboid. The draws (nextInt of the wrapper, uniform, trapezoid) are checked in sections 5 and 7.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-HM                  PIC X(32).
 01 WS-TEXT                PIC X(60).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 4096 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: count accepts [0, 4096]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 4097 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: count rejects 4097" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE -1 TO WS-B
     MOVE 5 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: count rejects -1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 256 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: count_on_every_layer accepts [0, 256]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 257 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: count_on_every_layer rejects 257" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE -16 TO WS-B
     MOVE 16 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: offset accepts [-16, 16]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE -17 TO WS-B
     MOVE 0 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: offset rejects -17" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 17 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: offset rejects 17" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 16 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: cuboid accepts [1, 16]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 16 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: cuboid rejects 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 17 TO WS-C
     CALL "F351-BOUND-OK" USING WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§10 Numeric providers as the placement code draws them: cuboid rejects 17" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-D
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
