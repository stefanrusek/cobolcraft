*> Acceptance test, US8-6 core half (spec US8 scenario 6; tasks T520; standin-content §11.1, §11.6):
*> hunger applies only to survival players. A creative player's food does not change as time
*> passes, as they move or at food 0 (no starvation), and Use Item does not start eating. Alice
*> (entity 1) is creative and holds hotbar slot 0, which the test fills with grazer_flank (item 12).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-CREATIVE.
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
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG VALUE 120.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-MILLI               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 20 TO PL-FOOD(WS-ROW)
     MOVE 12 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 1)

     MOVE "acceptance US8-6 given creative when 1100 ticks pass (5.5 survival exhaustion) then "
         & "food does not change and no exhaustion accumulates" TO TL-CASE
     MOVE 1100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM SHOW-STATE
     MOVE "food 20 exhaustion 0 slot 12x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-6 given creative when they move 300 blocks (6.0 survival exhaustion) "
         & "then food does not change" TO TL-CASE
     MOVE 320.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM SHOW-STATE
     MOVE "food 20 exhaustion 0 slot 12x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-6 given creative with food 20 and a held grazer_flank when eat is held "
         & "past the eating time then nothing is eaten" TO TL-CASE
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM SHOW-STATE
     MOVE "food 20 exhaustion 0 slot 12x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-6 given creative with food 0 when 120 ticks pass then no starvation "
         & "damage is taken" TO TL-CASE
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 120 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Drains Alice's hunger packets and appends her food, exhaustion (thousandths) and slot 0.
 SHOW-STATE.
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE PL-FOOD(WS-ROW) TO WS-EDIT
     COMPUTE WS-MILLI ROUNDED = PL-EXHAUSTION(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT2
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " food " FUNCTION TRIM(WS-EDIT) " exhaustion "
         FUNCTION TRIM(WS-EDIT2) " slot " DELIMITED BY SIZE INTO WS-TEXT
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-EDIT
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT3
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US8-CREATIVE.

 COPY CORETEST.
