*> Acceptance test, US7-3 core half (spec US7 scenario 3; tasks T493; 17 section 4.9; 09 §3.3
*> row 0x6A): a hurt survival player recovers 1 health every 80 ticks from food 18, and 5 / 6 every 10
*> ticks while saturated at food 20; below food 18 health does not recover; Set Health is sent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-RECOVERY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 10 TO PL-HEALTH(WS-ROW)

     MOVE "acceptance US7-3 given a hurt survival player with food 17, below 18, when 100 ticks "
         & "pass then health does not recover" TO TL-CASE
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 18 and no saturation when 79 "
         & "ticks pass then health has not yet recovered" TO TL-CASE
     MOVE 18 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 79 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 18 when the 80th tick passes "
         & "then health recovers by 1 and Set Health is sent" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 11 food 18" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 20 and saturation 5.0 when 9 "
         & "ticks pass then health has not yet recovered" TO TL-CASE
     MOVE 20 TO PL-FOOD(WS-ROW)
     MOVE 5 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 10 TO PL-HEALTH(WS-ROW)
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given saturation when the 10th tick passes then health recovers by "
         & "5 / 6 (shown as 11) and Set Health is sent" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 11 food 20" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-RECOVERY.

 COPY CORETEST.
