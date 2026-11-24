*> Acceptance test, US8-5 core half, also the starvation cause of US7-2 (spec US8 scenario 5, US7
*> scenario 2; tasks T518; standin-content §10.3, §11.3; 09 §3.3 Health rows): while a survival
*> player's food is 0, every 80th consecutive tick does 1 starvation damage (damage type 30
*> cobolcraft:starvation, no source), sent as Damage Event, Hurt Animation and Set Health; the count
*> starts again when food rises above 0; starvation can kill, with the death message
*> cobolcraft.death.starvation. Alice (entity 1) is survival.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-STARVATION.
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
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)

     MOVE "acceptance US8-5 given food at zero when 79 ticks pass then no starvation damage is "
         & "taken yet" TO TL-CASE
     MOVE 79 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-5 given food at zero when the 80th tick passes then 1 starvation damage "
         & "is taken (damage type 30)" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 30 source 0 | hurt 1 | health 19 food 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-5 given food still zero when another 80 ticks pass then another 1 "
         & "starvation damage is taken" TO TL-CASE
     MOVE 80 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 30 source 0 | hurt 1 | health 18 food 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-5 given food rises above zero after 40 ticks at zero when it is zero "
         & "again then the count starts again: no damage 40 ticks later" TO TL-CASE
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO PL-FOOD(WS-ROW)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-5 given food at zero and health 1 when 80 ticks pass then the player "
         & "does not starve (Normal difficulty: starvation stops at health 1)" TO TL-CASE
     MOVE 1 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 80 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US8-STARVATION.

 COPY CORETEST.
