*> Acceptance test of US14-2 (set-mode), the client half, and the US7 edge "switching back
*> restores the displays" (docs/protocol/09-cobolcraft-profile.md §3.2 Game Event 3: 0.0 survival,
*> 1.0 creative; client-surface §3 fly toggle; standin-content §10.1, §11.1 HUD labels): Game
*> Event 3 to creative hides the health and food displays and lets the Player fly (the double
*> Space press); back to survival the displays return with the values of the latest Set Health
*> (also one that arrived while creative) and flying ends.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-MODE-CHANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-SENT                PIC X(1024).
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-CREATIVE            FLOAT-SHORT VALUE 1.0.
 01 WS-HEALTH              FLOAT-SHORT VALUE 17.0.
 01 WS-FOOD                BINARY-LONG VALUE 9.
 01 WS-HEALTH2             FLOAT-SHORT VALUE 12.0.
 01 WS-FOOD2               BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH WS-FOOD
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-SENT WS-THRESHOLD

     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-CREATIVE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US14-2 client half (set-mode): given survival with Health 17/30 and Food "
         & "9/24 when Game Event 3 changes the mode to creative then the health and food "
         & "displays are hidden" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "||||||||" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-SENT WS-THRESHOLD
     MOVE "acceptance US14-2 client half (set-mode): when creative then Space pressed twice "
         & "within 0.3 s flies and Player Abilities (flying) is sent" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-FLYING " " FUNCTION TRIM(WS-SENT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 2802" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH2 WS-FOOD2
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-03-game-mode.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "US7 edge and US14-2 client half: when Game Event 3 changes the mode back to survival "
         & "then the displays show the latest Set Health (12/30, 5/24) and flying ends" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " flying " PL-FLYING DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "|||||||||Health 12/30|Food 5/24 flying 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     MOVE "US14-2 client half: when survival again then the double Space press does not fly"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US14-MODE-CHANGE.
 COPY CLTEST.
