*> Implementation test (002-lane-mobs3, T4202; docs/protocol/12 section 5 experience bar): a clipped sprite widget (WK-CLIP) draws the left w
*> pixels of its sprite unstretched, and the bar's background sprite is drawn when the pack stack has it; with no sprite the black and the
*> tinted white swatches stand in (one quad each). The sprites are given rows of a 256 x 256 atlas: background at (0, 20), progress at (0, 30),
*> both 182 x 5; progress 0.5 fills 91 pixels, so the clipped quad ends at u = 91 / 256 and spans v = 30 / 256 to 35 / 256.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-UI-CLIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-CLIP-QUADS          BINARY-LONG.
 01 WS-BACK-QUADS          BINARY-LONG.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO CL-CAMERA PL-OFFHAND-COUNT PL-HELD
     MOVE 0 TO CL-NOW-MS PL-HURT-UNTIL PL-XP-LEVEL
     MOVE 0.5 TO PL-XP-PROGRESS
     MOVE 0 TO PL-MODE
     MOVE 256 TO UA-W UA-H
     MOVE "N" TO TL-MODE
*>   No sprites in the stack: two swatch quads (6 vertices each) for the bar.
     MOVE 0 TO GS-W(GSP-XP-BACK) GS-W(GSP-XP-PROGRESS)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE RL-UI-COUNT TO WS-BEFORE
*>   With the sprites: the same two quads, textured by the sprites (and nothing else changes in the count).
     MOVE 182 TO GS-W(GSP-XP-BACK) GS-W(GSP-XP-PROGRESS)
     MOVE 5 TO GS-H(GSP-XP-BACK) GS-H(GSP-XP-PROGRESS)
     MOVE 0 TO GS-X(GSP-XP-BACK) GS-X(GSP-XP-PROGRESS)
     MOVE 20 TO GS-Y(GSP-XP-BACK)
     MOVE 30 TO GS-Y(GSP-XP-PROGRESS)
     MOVE 0 TO GS-NINE(GSP-XP-BACK) GS-NINE(GSP-XP-PROGRESS)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "test ui clip: the sprites replace the swatches one for one" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The clipped quad: u from 0 to 91 / 256, v from 30 / 256 to 35 / 256 (the background quad has v 20 / 256 to 25 / 256 and u to 182 / 256).
     COMPUTE WS-U = 91 / 256
     COMPUTE WS-V0 = 30 / 256
     COMPUTE WS-V1 = 35 / 256
     MOVE 0 TO WS-CLIP-QUADS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UI-COUNT
         IF RL-UI-U(WS-I) = WS-U AND RL-UI-V(WS-I) = WS-V1
             ADD 1 TO WS-CLIP-QUADS
         END-IF
     END-PERFORM
     MOVE "test ui clip: the progress quad ends at u = 91 / 256, bottom at v = 35 / 256 (2 vertices)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CLIP-QUADS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-U = 182 / 256
     COMPUTE WS-V1 = 25 / 256
     MOVE 0 TO WS-BACK-QUADS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UI-COUNT
         IF RL-UI-U(WS-I) = WS-U AND RL-UI-V(WS-I) = WS-V1
             ADD 1 TO WS-BACK-QUADS
         END-IF
     END-PERFORM
     MOVE "test ui clip: the background quad is the whole sprite (u = 182 / 256, v = 25 / 256: 2 vertices)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-BACK-QUADS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-UI-CLIP.
 COPY CLTEST.
