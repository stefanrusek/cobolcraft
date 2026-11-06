*> Acceptance test of US8-1 and US8-6, the client half (standin-content §11.1: maximum food 24,
*> hunger applies to survival players only; 08 §10.8.6 cobolcraft.hud.food "Food %s/%s";
*> docs/protocol/09-cobolcraft-profile.md §3.3 Set Health 0x6A food field): in survival the HUD
*> shows the food level (the last Set Health) and the maximum beside the health; in creative it
*> shows neither.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-FOOD-HUD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-HEALTH              FLOAT-SHORT VALUE 30.0.
 01 WS-FOOD                BINARY-LONG VALUE 11.
 01 WS-I                   BINARY-LONG.
 01 WS-HEALTH-W            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US8-1 given survival with food 24 when the Player is in the world then the "
         & "HUD shows Food 24/24 after the health" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+||||||||||Health 30/30|Food 24/24" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH WS-FOOD
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US8-1 given survival when Set Health with food 11 arrives then the HUD "
         & "shows Food 11/24" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+||||||||||Health 30/30|Food 11/24" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Beside: on the hotbar's row of labels, right of the health label.
     MOVE "acceptance US8-1 the food label is beside the health label: same row, to its right"
         TO TL-CASE
     MOVE SM-WIDGET-COUNT TO WS-I
     COMPUTE WS-HEALTH-W = WS-I - 1
     MOVE "same row, right" TO TL-EXPECTED
     MOVE "elsewhere" TO TL-OBSERVED
     IF SM-W-Y(WS-I) = SM-W-Y(WS-HEALTH-W)
             AND SM-W-X(WS-I) >= SM-W-X(WS-HEALTH-W) + SM-W-W(WS-HEALTH-W)
         MOVE "same row, right" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server made the player creative (Game Event 3, decoded in contract_wire_client).
     MOVE 1 TO PL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US8-6 given creative when the Player is in the world then the food level "
         & "is not shown" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+|||||||||" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US8-FOOD-HUD.
 COPY CLTEST.
