*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 14 as rule functions (lane 002-lane-p49j-b, T24400 range): the reputation event to gossip table, including golem_killed with no producer.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-14.
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
     MOVE 1 TO WS-N1
     CALL "X2-REPUTATION" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§14 14 zombie_villager_cured: major_positive 20" TO WS-CASE
     MOVE 3020 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 1000 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§14 14 zombie_villager_cured: and minor_positive 25" TO WS-CASE
     MOVE 4025 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 1000 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     CALL "X2-REPUTATION" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§14 14 trade: trading 2" TO WS-CASE
     MOVE 5002 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 1000 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§14 14 trade: no second gossip" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     CALL "X2-REPUTATION" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§14 14 villager_hurt: minor_negative 25" TO WS-CASE
     MOVE 2025 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 1000 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4 TO WS-N1
     CALL "X2-REPUTATION" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§14 14 villager_killed: major_negative 25" TO WS-CASE
     MOVE 1025 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 * 1000 + WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 5 TO WS-N1
     CALL "X2-REPUTATION" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§14 14 golem_killed has no producer and no gossip" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2 + WS-N3 + WS-N4 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-14.

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
