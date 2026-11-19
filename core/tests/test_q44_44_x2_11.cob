*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 11 as rule functions (lane 002-lane-p49j-b, T24400 range): the declarative behaviour engine: memory condition semantics (registered, present, absent; unregistered fails all) and the Brain.setMemory write rules.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 registered(m) passes for a registered memory without a value" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 present(m) passes with a value" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 present(m) fails without a value" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 absent(m) passes without a value" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 absent(m) fails with a value" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 an unregistered memory fails registered" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 an unregistered memory fails present" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-MEM-CONDITION" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§11 11.1 an unregistered memory fails absent" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-MEM-SET" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§11 11.2 setMemory on an unregistered type is a no-op" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-MEM-SET" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§11 11.2 a null or empty value clears the slot" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-MEM-SET" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§11 11.2 a real value is stored" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-11.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
