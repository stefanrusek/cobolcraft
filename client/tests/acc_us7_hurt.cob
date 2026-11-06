*> Acceptance test of US7-2, the client half ("they see that they were hurt"; standin-content §10.2: a
*> damaged player is sent Damage Event and Hurt Animation; docs/protocol/09-cobolcraft-profile.md
*> §3.3 Damage Event 0x19, Hurt Animation 0x2B): either packet for the local player's entity puts
*> the hurt indication in the screen model, a red tint over the whole world screen (an overlay
*> widget drawn first, on the hurt swatch of the UI atlas) for half a second; the same packets for
*> another entity do not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-TICKS               BINARY-LONG VALUE 10.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 WS-E5                  PIC -(5)9.
 01 WS-U                   PIC 9.9(5).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "contract/fixtures/wire/play-s2c-19-damage-event.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-2 client half given the Player in the world when Damage Event for "
         & "their entity arrives then the screen model's first widget is the hurt overlay over "
         & "the whole screen (kind 6 at 0, 0, 427 x 240 GUI pixels)" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM FIRST-WIDGET
     MOVE "6 0 0 427 240" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US7-2 client half the hurt overlay is drawn first, from the window's top-left "
         & "corner, on the centre texel of the hurt swatch (u 0.40625)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE RL-UI-X(1) TO WS-E1
     MOVE RL-UI-Y(1) TO WS-E2
     MOVE RL-UI-U(1) TO WS-U
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " WS-U DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "0 0 0.40625" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "acceptance US7-2 client half when half a second has passed then the hurt indication "
         & "is gone (the crosshair is the first widget again)" TO TL-CASE
     PERFORM FIRST-WIDGET
     MOVE "1 210 116 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-2b-hurt-animation.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-2 client half when Hurt Animation for their entity arrives then the "
         & "hurt overlay is shown" TO TL-CASE
     PERFORM FIRST-WIDGET
     MOVE "6 0 0 427 240" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE 2 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-19-damage-event.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-2b-hurt-animation.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-2 client half given the local player is entity 2 when Damage Event and "
         & "Hurt Animation for entity 1 arrive then no hurt indication is shown" TO TL-CASE
     PERFORM FIRST-WIDGET
     MOVE "1 210 116 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIRST-WIDGET.
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-W-KIND(1) TO WS-E1
     MOVE SM-W-X(1) TO WS-E2
     MOVE SM-W-Y(1) TO WS-E3
     MOVE SM-W-W(1) TO WS-E4
     MOVE SM-W-H(1) TO WS-E5
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM ACC-US7-HURT.
 COPY CLTEST.
