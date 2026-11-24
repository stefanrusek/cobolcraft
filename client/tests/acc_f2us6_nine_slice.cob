*> Acceptance test US6-3 (spec 002 FR-013, FR-014, FR-015; SC-003; 12 §5.9): with a pack that has GUI sprites the
*> screens' sprites follow the pack's GUI textures. widget/button is drawn as nine quads (a nine_slice .mcmeta of
*> border 3: corners 3 GUI pixels square, copied unscaled; edges and centre stretched), container/slot as one quad
*> over the sprite; without the pack (no sprite) a button is the one swatch quad and the font stays the pack stack's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-NINE-SLICE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-nine".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-NAMES               PIC X(256) VALUE "guipack".
 01 WS-IDS                 PIC X(256) VALUE "file/guipack".
 01 WS-OK                  BINARY-LONG.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 01 WS-Q                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 2 TO CL-GUI-SCALE
     MOVE 1 TO SM-WIDGET-COUNT
     INITIALIZE SM-WIDGET(1)
     MOVE WK-BUTTON TO SM-W-KIND(1)
     MOVE 10 TO SM-W-X(1)
     MOVE 10 TO SM-W-Y(1)
     MOVE 100 TO SM-W-W(1)
     MOVE 20 TO SM-W-H(1)
     MOVE "N" TO TL-MODE
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "nine-slice with no pack a button is nine quads of the built-in art (54 vertices)" TO TL-CASE
     MOVE 54 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "nine-slice with the pack a button is nine quads (54 vertices)" TO TL-CASE
     MOVE 54 TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quad 1 is the top-left corner: window (20, 20) to (26, 26), the sprite's 3 x 3 texels at its top-left.
     COMPUTE WS-U0 = GS-X(GSP-BUTTON) / UA-W
     COMPUTE WS-U1 = (GS-X(GSP-BUTTON) + 3) / UA-W
     COMPUTE WS-V0 = GS-Y(GSP-BUTTON) / UA-H
     COMPUTE WS-V1 = (GS-Y(GSP-BUTTON) + 3) / UA-H
     MOVE 0 TO WS-OK
     IF RL-UI-X(1) = 20 AND RL-UI-Y(1) = 20 AND RL-UI-X(3) = 26 AND RL-UI-Y(3) = 26
             AND RL-UI-U(1) > WS-U0 - 0.00001 AND RL-UI-U(1) < WS-U0 + 0.00001
             AND RL-UI-U(3) > WS-U1 - 0.00001 AND RL-UI-U(3) < WS-U1 + 0.00001
             AND RL-UI-V(1) > WS-V0 - 0.00001 AND RL-UI-V(3) < WS-V1 + 0.00001
         MOVE 1 TO WS-OK
     END-IF
     MOVE "nine-slice the top-left corner is 3 GUI pixels square, copied unscaled from the sprite's corner" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quad 5 is the centre: from GUI (13, 13) to (107, 27): window (26, 26) to (214, 54); the sprite's inner texels.
     COMPUTE WS-Q = 4 * 6 + 1
     MOVE 0 TO WS-OK
     IF RL-UI-X(WS-Q) = 26 AND RL-UI-Y(WS-Q) = 26 AND RL-UI-X(WS-Q + 2) = 214 AND RL-UI-Y(WS-Q + 2) = 54
         MOVE 1 TO WS-OK
     END-IF
     MOVE "nine-slice the centre is stretched over the rest of the button (13, 13) to (107, 27)" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quad 9 is the bottom-right corner: GUI (107, 27) to (110, 30).
     COMPUTE WS-Q = 8 * 6 + 1
     MOVE 0 TO WS-OK
     IF RL-UI-X(WS-Q) = 214 AND RL-UI-Y(WS-Q) = 54 AND RL-UI-X(WS-Q + 2) = 220 AND RL-UI-Y(WS-Q + 2) = 60
         MOVE 1 TO WS-OK
     END-IF
     MOVE "nine-slice the bottom-right corner ends at the button's corner (110, 30)" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A slot over the pack's container/slot sprite: one quad textured from the sprite's rectangle.
     MOVE 1 TO SM-WIDGET-COUNT
     INITIALIZE SM-WIDGET(1)
     MOVE WK-SLOT TO SM-W-KIND(1)
     MOVE 36 TO SM-W-ARG(1)
     MOVE 10 TO SM-W-X(1)
     MOVE 10 TO SM-W-Y(1)
     MOVE 20 TO SM-W-W(1)
     MOVE 20 TO SM-W-H(1)
     MOVE 0 TO PL-SLOT-COUNT(1)
     MOVE 5 TO SM-W-ARG(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-U0 = GS-X(GSP-SLOT) / UA-W
     COMPUTE WS-U1 = (GS-X(GSP-SLOT) + GS-W(GSP-SLOT)) / UA-W
     MOVE 0 TO WS-OK
     IF RL-UI-COUNT = 6 AND RL-UI-U(1) > WS-U0 - 0.00001 AND RL-UI-U(1) < WS-U0 + 0.00001
             AND RL-UI-U(3) > WS-U1 - 0.00001 AND RL-UI-U(3) < WS-U1 + 0.00001 AND GS-W(GSP-SLOT) = 18
         MOVE 1 TO WS-OK
     END-IF
     MOVE "nine-slice a slot is one quad over the pack's container/slot sprite (18 x 18)" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US6-NINE-SLICE.

 COPY CLTEST.
 COPY PACKTEST.
