*> Acceptance test, US7-2 core half for falls (spec US7 scenario 2; tasks T488; standin-content §10.2,
*> §10.3; 09 §3.3 Health rows): a survival player who lands after falling farther than the safe fall
*> height of 4 blocks loses 2 x (floor(D) - 4) health and is sent Damage Event (damage type 1
*> cobolcraft:impact, no source), Hurt Animation and Set Health; the players who see it are sent
*> Damage Event and Hurt Animation; within the 12-tick hurt cooldown further damage is ignored.
*> Alice (entity 1) and Bobby (entity 2) are survival; Alice stands on greystone at (20, 100, 20).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-FALL-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT

     MOVE "acceptance US7-2 given a survival player when they land after falling 10 blocks then "
         & "they lose 2 x (10 - 4) = 12 health and are sent Damage Event, Hurt Animation and Set "
         & "Health" TO TL-CASE
     MOVE 111 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 18 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a survival player when they are hurt by a fall then another "
         & "player who sees them is sent Damage Event and Hurt Animation" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US7-2 given a player hurt this tick when they fall 6 blocks within the 12-tick hurt "
         & "cooldown then the damage is ignored" TO TL-CASE
     MOVE 107 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given the hurt cooldown is over when a survival player falls 5 blocks "
         & "then they lose 2 health" TO TL-CASE
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 106 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 16 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a survival player when they fall 4.9 blocks, not farther than "
         & "the safe fall height, then they take no damage" TO TL-CASE
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 105.9 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Alice rises (on-ground false) to WS-FY, then lands on the greystone (feet y 101, on-ground true).
 FALL-TO-101.
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-FALL-DAMAGE.

 COPY CORETEST.
