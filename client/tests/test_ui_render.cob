*> Implementation test of client/src/ui-render.cob (UI-RENDER, UI-TEXT-WIDTH; data-model §13; 08
*> §10.10 text rules): the screen model's labels, buttons, text fields and list entries become
*> UI-pipeline vertices (texture 2, window pixels, GUI scale 2): a background quad from the UI
*> atlas swatches (their centre texel) for buttons (button colour), fields (field colour, with a caret when focused) and
*> entries (selected colour when selected), then one quad per non-space character from the pack font,
*> advancing by the glyph's advance; a button's text is centred; a label has no background.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-UI-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   PIC -(4)9.99.
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUT                 PIC X(1024).
 01 WS-VERTEX              BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-UNFOCUSED           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     MOVE 800 TO IN-WIN-W
     MOVE 600 TO IN-WIN-H

     MOVE "Ab c" TO WS-TEXT
     MOVE 4 TO WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
     MOVE "ui text width of 'Ab c' is the sum of advances 6 + 6 + 4 + 6 GUI pixels" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 22 TO TL-EXPECTED-N
     MOVE WS-WIDTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A label "Ab" at GUI (10, 20).
     MOVE 1 TO SM-WIDGET-COUNT
     INITIALIZE SM-WIDGET(1)
     MOVE WK-LABEL TO SM-W-KIND(1)
     MOVE 10 TO SM-W-X(1)
     MOVE 20 TO SM-W-Y(1)
     MOVE "Ab" TO SM-W-TEXT(1)
     MOVE 2 TO SM-W-LENGTH(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "ui a label is one quad per character: 'A' at window (20, 40) to (36, 56) with the cell "
         & "(8, 16)-(16, 24) of the 256-wide UI atlas (font, icon cells, swatches, GUI sprites); 'b' 12 "
         & "pixels further" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "12.00 20.00 40.00 0.03 0.01 36.00 56.00 0.06 0.01 1.00 1.00 32.00" TO TL-EXPECTED
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     MOVE RL-UI-COUNT TO WS-E
     STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE 1 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     MOVE 3 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     COMPUTE WS-E ROUNDED = RL-UI-B(1)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = RL-UI-A(1)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     COMPUTE WS-E ROUNDED = RL-UI-X(7)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A button 100 x 20 at (0, 0) with "Ab" centred; a focused field "x"; a selected entry "y".
     MOVE 3 TO SM-WIDGET-COUNT
     INITIALIZE SM-WIDGET(1) SM-WIDGET(2) SM-WIDGET(3)
     MOVE WK-BUTTON TO SM-W-KIND(1)
     MOVE 100 TO SM-W-W(1)
     MOVE 20 TO SM-W-H(1)
     MOVE "Ab" TO SM-W-TEXT(1)
     MOVE 2 TO SM-W-LENGTH(1)
     MOVE WK-FIELD TO SM-W-KIND(2)
     MOVE 1 TO SM-W-STATE(2)
     MOVE 50 TO SM-W-Y(2) SM-W-W(2)
     MOVE 20 TO SM-W-H(2)
     MOVE "x" TO SM-W-TEXT(2)
     MOVE 1 TO SM-W-LENGTH(2)
     MOVE WK-ENTRY TO SM-W-KIND(3)
     MOVE 1 TO SM-W-STATE(3)
     MOVE 100 TO SM-W-Y(3) SM-W-W(3)
     MOVE 20 TO SM-W-H(3)
     MOVE "y" TO SM-W-TEXT(3)
     MOVE 1 TO SM-W-LENGTH(3)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "ui a button: nine quads of the built-in button art from (0, 0), the first 6 window pixels "
         & "square on the sprite corner; a focused field: field swatch, text, caret; a selected entry"
         TO TL-CASE
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-PTR
     MOVE RL-UI-COUNT TO WS-E
     STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE 1 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     MOVE 3 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     COMPUTE WS-E ROUNDED = RL-UI-X(7)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-OUT WITH POINTER WS-PTR
     MOVE 19 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     MOVE 37 TO WS-VERTEX
     CALL "TEST-UI-VERTEX" USING CLIENT-STATE WS-VERTEX WS-OUT WS-PTR
     MOVE WS-OUT TO TL-OBSERVED
     MOVE "96.00 0.00 0.00 0.00 0.04 6.00 6.00 0.01 0.04 6.00 0.00 6.00 0.00 0.04 0.00 34.00 0.00 0.05"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A disabled button (state 2) is drawn with the quads of an enabled one: the button sprite.
     MOVE 1 TO SM-WIDGET-COUNT
     MOVE 0 TO SM-W-STATE(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE RL-UI-COUNT TO WS-UNFOCUSED
     MOVE 2 TO SM-W-STATE(1)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "ui a disabled button renders the same quads as an enabled one (the sprite is the same)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-UNFOCUSED TO TL-EXPECTED-N
     MOVE RL-UI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The edit-server screen with the address field holding its full 256 bytes: focused, the field
*>   renders its text and one caret quad more than unfocused (the caret must not overrun the text).
     MOVE ALL "a" TO SM-EDIT-ADDR
     MOVE 256 TO SM-EDIT-ADDR-LENGTH
     MOVE "n" TO SM-EDIT-NAME
     MOVE 1 TO SM-EDIT-NAME-LENGTH
     MOVE 0 TO SM-FOCUS SM-WIDGET-COUNT
     MOVE 400 TO WS-GW
     MOVE 300 TO WS-GH
     CALL "EDIT-SERVER-BUILD" USING CLIENT-STATE WS-GW WS-GH
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE RL-UI-COUNT TO WS-UNFOCUSED
     MOVE 2 TO SM-FOCUS
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "EDIT-SERVER-BUILD" USING CLIENT-STATE WS-GW WS-GH
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "ui the edit-server screen with a focused address field of 256 bytes renders a frame "
         & "with one caret quad (6 vertices) more than unfocused" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-UI-COUNT - WS-UNFOCUSED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-UI-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-UI-VERTEX.
*> USING CLIENT-STATE, vertex (literal), text, pointer: appends " x y u v" of the UI vertex.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E                   PIC -(4)9.99.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-VERTEX               BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-PTR                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-VERTEX L-TEXT L-PTR.
     MOVE L-VERTEX TO WS-V
     COMPUTE WS-E ROUNDED = RL-UI-X(WS-V)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO L-TEXT WITH POINTER L-PTR
     COMPUTE WS-E ROUNDED = RL-UI-Y(WS-V)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO L-TEXT WITH POINTER L-PTR
     COMPUTE WS-E ROUNDED = RL-UI-U(WS-V)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO L-TEXT WITH POINTER L-PTR
     COMPUTE WS-E ROUNDED = RL-UI-V(WS-V)
     STRING " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO L-TEXT WITH POINTER L-PTR
     GOBACK.
 END PROGRAM TEST-UI-VERTEX.
