*> Acceptance test of US3-3 on the client (client-surface §3: fly toggle Space twice within 0.3 s in
*> creative, Space rises, Left Shift descends; 09 §3.2 Player Abilities 0x28 flags 0x02 while flying;
*> client/src/physics.cob): a creative Player starts and stops flying with the double press, telling
*> the server each time; flying, Space rises and Left Shift descends 0.375 blocks per tick; a
*> survival Player cannot fly, and two presses further apart than 0.3 s do not toggle.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-FLY.
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
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-SHIFT               BINARY-LONG VALUE CC-KEY-LEFT-SHIFT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-FORTY               BINARY-LONG VALUE 40.
 01 WS-START               FLOAT-LONG.
 01 WS-RISE                PIC -(4)9.9(4).
 01 WS-FALL                PIC -(4)9.9(4).
 01 WS-TEXT                PIC X(1024).
 01 WS-SENT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   Survival: the double press does not fly.
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-survival.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     MOVE "acceptance US3-3 given survival when Space is pressed twice within 0.3 s then the "
         & "Player does not fly" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FORTY

*>   Creative: presses 0.4 s apart do not toggle.
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-TICKS" USING CLIENT-STATE WS-EIGHT
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     MOVE "acceptance US3-3 given creative when Space is pressed twice 0.4 s apart then the "
         & "Player does not fly" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FORTY
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD

*>   Creative: the double press flies and tells the server.
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-SENT
     INSPECT WS-TEXT TALLYING WS-SENT FOR ALL "28"
     MOVE "acceptance US3-3 given creative when Space is pressed twice within 0.3 s then the "
         & "Player flies and Player Abilities (flying) is sent" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-FLYING * 10 + WS-SENT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE PL-Y TO WS-START
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-THREE
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     COMPUTE WS-RISE ROUNDED = PL-Y - WS-START
     CALL "TEST-TICKS" USING CLIENT-STATE WS-THREE
     MOVE PL-Y TO WS-START
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SHIFT WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SHIFT WS-UP
     COMPUTE WS-FALL ROUNDED = PL-Y - WS-START
     MOVE "acceptance US3-3 given flying when Space is held for four ticks then the Player rises "
         & "1.5 blocks, and Left Shift held for two ticks descends 0.75" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1.5000 -0.7500" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-RISE) " " FUNCTION TRIM(WS-FALL) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-SENT
     INSPECT WS-TEXT TALLYING WS-SENT FOR ALL "28"
     CALL "TEST-TICKS" USING CLIENT-STATE WS-FORTY
     MOVE "acceptance US3-3 given flying when Space is pressed twice within 0.3 s then flying "
         & "stops (Player Abilities sent) and the Player falls to the floor" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-FLYING " " FUNCTION CHAR(WS-SENT + 49) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-POSITION" USING CLIENT-STATE TL-OBSERVED
     MOVE "0 1 0.5000/10.0000/0.5000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-FLY.
 COPY CLTEST.
