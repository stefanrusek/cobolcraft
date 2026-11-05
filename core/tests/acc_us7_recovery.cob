*> Acceptance test, US7-3 core half (spec US7 scenario 3; tasks T493; standin-content §10.5; 09 §3.3
*> row 0x6A): while a hurt survival player's food is at least 20, every 50th consecutive tick gives
*> 1 health and sends Set Health, up to the maximum of 30; below food 20 health does not recover.
*> Alice is survival; her health is set to 26 (and her food to 19) as the starting condition.
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
     MOVE 26 TO PL-HEALTH(WS-ROW)

     MOVE "acceptance US7-3 given a hurt survival player with food 24 when 49 ticks pass then "
         & "health has not yet recovered" TO TL-CASE
     MOVE 49 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 24 when the 50th tick passes "
         & "then health recovers by 1 and Set Health is sent" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 27 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 24 when time passes then "
         & "health recovers 1 every 50 ticks up to the maximum 30 and no further" TO TL-CASE
     MOVE 250 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 28 food 24 | health 29 food 24 | health 30 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-3 given a hurt survival player with food 19, below the required 20, "
         & "when 100 ticks pass then health does not recover" TO TL-CASE
     MOVE 26 TO PL-HEALTH(WS-ROW)
     MOVE 19 TO PL-FOOD(WS-ROW)
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US7-3 given a hurt survival player with food 19 when 100 ticks pass then "
         & "the server's health stays 26" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 26 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US7-3 given the food level rises back to 20 when 50 ticks pass then health "
         & "recovers again" TO TL-CASE
     MOVE 20 TO PL-FOOD(WS-ROW)
     MOVE 50 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 27 food 20" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-RECOVERY.

 COPY CORETEST.
