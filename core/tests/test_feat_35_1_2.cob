*> Acceptance test of docs/protocol/35-worldgen-features-1 section 2 (the place contract and the boolean result): the write flags of setBlock (3) and safeSetBlock (2) and markAboveForPostProcessing (up to two non-air positions above). The boolean result (OR over positions, the sequence stop) is checked with the evaluator in sections 8 and 9.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-2.
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
     CALL "F351-SET-FLAGS" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§2 The place contract and the boolean result: setBlock writes with flags 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F351-SET-FLAGS" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§2 The place contract and the boolean result: safeSetBlock writes with flag 2 only" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "F351-MARK-ABOVE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§2 The place contract and the boolean result: markAbove marks nothing when the block above is air" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "F351-MARK-ABOVE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§2 The place contract and the boolean result: markAbove marks one position when the second block above is air" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "F351-MARK-ABOVE" USING WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§2 The place contract and the boolean result: markAbove marks two positions when neither is air" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
