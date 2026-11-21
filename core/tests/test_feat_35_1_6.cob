*> Acceptance test of docs/protocol/35-worldgen-features-1 section 6 (the decoration driver): the step count max(11, size) and the sorted set of feature indices of a step. The seeding of the driver is checked in sections 5 and 11.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-6.
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
 01 WS-NUM                PIC Z(9)9.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-A
     CALL "F351-STEP-COUNT" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: the step loop runs to max(11, 0) = 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "F351-STEP-COUNT" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: the step loop runs to max(11, 5) = 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-A
     CALL "F351-STEP-COUNT" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: the step loop runs to max(11, 11) = 11" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-A
     CALL "F351-STEP-COUNT" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: the step loop runs to max(11, 12) = 12" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 5 TO WS-L(1)
     MOVE 1 TO WS-L(2)
     MOVE 3 TO WS-L(3)
     MOVE 1 TO WS-L(4)
     MOVE 9 TO WS-L(5)
     CALL "F351-SORT-INDICES" USING WS-A WS-LIST
     MOVE SPACES TO WS-TEXT
     COMPUTE WS-SUM = WS-A * 100000 + WS-L(1) * 10000 + WS-L(2) * 1000 + WS-L(3) * 100 + WS-L(4)
     MOVE WS-SUM TO WS-NUM
     MOVE WS-NUM TO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: the indices of a step are sorted ascending and without repeats" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NUM) TO TL-OBSERVED
     MOVE "413509" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "F351-SORT-INDICES" USING WS-A WS-LIST
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§6 The decoration driver: an empty step has no index" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
