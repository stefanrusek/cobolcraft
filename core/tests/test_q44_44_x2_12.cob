*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 12 as rule functions (lane 002-lane-p49j-b, T24400 range): the sensor base class tick (scan every rate ticks), rememberPositives (worked example true, true, true, false), the NearestItemSensor filters and the PlayerSensor range test.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-12.
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
     MOVE 5 TO WS-N1
     MOVE 20 TO WS-N2
     CALL "X2-SENSOR-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.1 a sensor at timeToTick 5 counts down without scanning" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§12 12.1 and the timer is 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 20 TO WS-N2
     CALL "X2-SENSOR-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.1 at 1 it scans" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§12 12.1 and the timer is reset to the scan rate 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 20 TO WS-N1
     MOVE 0 TO WS-N4
     PERFORM 100 TIMES
         CALL "X2-SENSOR-TICK" USING WS-N1 WS-N2 WS-N3
         ADD WS-N3 TO WS-N4
     END-PERFORM
     MOVE "acceptance US15 44-x2§12 12.1 a sensor with rate 20 scans on every 20th tick: 100 ticks from 20 give 5 scans" TO WS-CASE
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-REMEMBER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§12 12.1 rememberPositives n = 3: a true call gives true" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§12 12.1 the counter is 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N3
     CALL "X2-REMEMBER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§12 12.1 first false call: true (counter 2)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "X2-REMEMBER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§12 12.1 second false call: true (counter 1)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "X2-REMEMBER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§12 12.1 third false call: true (counter 0)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "X2-REMEMBER" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§12 12.1 fourth false call: false (counter -1)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1000 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X2-ITEM-FILTER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.2 an item the mob wants, within 32 blocks, in sight" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1024 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X2-ITEM-FILTER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.2 not beyond 32 blocks (squared 1024)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 10 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X2-ITEM-FILTER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.2 not when the mob does not want it" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 10 TO WS-A
     MOVE 0 TO WS-N2
     CALL "X2-ITEM-FILTER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§12 12.2 not without line of sight" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 255 TO WS-A
     MOVE 16 TO WS-B
     CALL "X2-PLAYER-IN-RANGE" USING WS-N1 WS-A WS-B WS-N2
     MOVE "acceptance US15 44-x2§12 12.3 a player closer than follow_range 16 (squared 255)" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 256 TO WS-A
     MOVE 16 TO WS-B
     CALL "X2-PLAYER-IN-RANGE" USING WS-N1 WS-A WS-B WS-N2
     MOVE "acceptance US15 44-x2§12 12.3 not at exactly 16 (squared 256)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 10 TO WS-A
     MOVE 16 TO WS-B
     CALL "X2-PLAYER-IN-RANGE" USING WS-N1 WS-A WS-B WS-N2
     MOVE "acceptance US15 44-x2§12 12.3 spectators are dropped" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-12.

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
