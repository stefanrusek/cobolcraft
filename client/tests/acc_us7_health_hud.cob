*> Acceptance test of US7-1 and US7-6, the client half (standin-content §10: maximum health 30,
*> creative players have no health shown; 08 §10.8.6 cobolcraft.hud.health "Health %s/%s";
*> docs/protocol/09-cobolcraft-profile.md §3.3 Set Health 0x6A): in survival the HUD shows the
*> current health (the last Set Health, a whole number) and the maximum; in creative it shows none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-HEALTH-HUD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-HEALTH              FLOAT-SHORT VALUE 17.0.
 01 WS-FOOD                BINARY-LONG VALUE 20.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-6a-set-health.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-1 given survival and Set Health 30 when the Player is in the world then "
         & "the HUD shows Health 20/20 after the crosshair and the hotbar" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+||||||||||Health 20/20|Food 20/20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH WS-FOOD
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-1 given survival when Set Health 17 arrives then the HUD shows the "
         & "current and maximum health Health 17/20" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+||||||||||Health 17/20|Food 20/20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The server made the player creative (Game Event 3, decoded in contract_wire_client).
     MOVE 1 TO PL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-6 given creative when the Player is in the world then no health is "
         & "shown" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+|||||||||" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PL-MODE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "US7 edge given a switch back to survival then the health display returns with the "
         & "value it had" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "+||||||||||Health 17/20|Food 20/20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US7-HEALTH-HUD.
 COPY CLTEST.
