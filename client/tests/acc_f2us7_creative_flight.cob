*> Acceptance test US7-1 (spec 002 FR-016, FR-017; SC-004; docs/protocol/13 §1.4): in creative a double Space toggles
*> flying 20 of 20 times; in survival 0 of 20; in spectator (mayfly set) flying is on at once, with no double
*> tap, and Player Abilities (0x28) is sent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US7-CREATIVE-FLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-I                   BINARY-LONG.
 01 WS-BEFORE              PIC 9.
 01 WS-TOGGLES             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-SENT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM TWENTY-DOUBLE-PRESSES
     MOVE "acceptance US7-1 given creative when Space is pressed twice within 0.3 s, 20 times, then "
         & "flying toggles 20 of 20 times" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-TOGGLES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-survival.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     PERFORM TWENTY-DOUBLE-PRESSES
     MOVE "acceptance US7-1 given survival when Space is pressed twice within 0.3 s, 20 times, then "
         & "flying toggles 0 of 20 times" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TOGGLES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Landing (13 section 1.4): a flying creative Player that comes down onto the ground stops flying and
*>   Player Abilities is sent; a spectator stays flying.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO PL-FLYING
     MOVE 13 TO PL-Y
     MOVE 0 TO PL-ON-GROUND
     MOVE CC-KEY-LEFT-SHIFT TO WS-SHIFT
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SHIFT WS-DOWN
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SHIFT WS-UP
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-SENT
     INSPECT WS-TEXT TALLYING WS-SENT FOR ALL "28"
     MOVE "acceptance US7-1 given a flying creative Player when Left Shift brings it down onto the ground "
         & "then flying stops and Player Abilities is sent" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-FLYING = 0 AND WS-SENT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-spectator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 3 TO PL-MODE
     MOVE 0 TO PL-FLYING
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     CALL "TEST-SERVER-READ" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-SENT
     INSPECT WS-TEXT TALLYING WS-SENT FOR ALL "28"
     MOVE "acceptance US7-1 given spectator (mayfly) when ticks pass with no key then the Player is "
         & "flying and Player Abilities is sent (13 section 1.4)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-FLYING * 10 + FUNCTION MIN(WS-SENT, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TWENTY-DOUBLE-PRESSES.
     MOVE 0 TO WS-TOGGLES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE PL-FLYING TO WS-BEFORE
         CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
         CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
         IF PL-FLYING NOT = WS-BEFORE
             ADD 1 TO WS-TOGGLES
         END-IF
         CALL "TEST-TICKS" USING CLIENT-STATE WS-TEN
     END-PERFORM.
 END PROGRAM ACC-F2US7-CREATIVE-FLIGHT.
 COPY CLTEST.
