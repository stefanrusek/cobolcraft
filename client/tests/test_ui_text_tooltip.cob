*> Test US12-client (spec 002, shared gaps of the container chapters; docs/protocol/12-client-rendering.md 5.6 and 5.8, docs/design/builtin-ui-art.md 4.13.5 and 6):
*> (a) a text colour per widget (SM-W-COLOUR, WIDGET-COLOUR; the vertex carries one brightness, so a colour is drawn as its grey luminance: #404040 gives 0.251, white 1);
*> (b) the tooltip layer: TOOLTIP-ADD adds a line (text colour), TOOLTIP-LAYOUT places the block (mouse + 12, mouse - 12; right and bottom clamps; width the widest line, height
*> 10 per line, +2 after the first line with title spacing; the background rectangle from (x - 12, y - 12) of size (w + 24, h + 24)), UI-RENDER draws it on the top layer.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-UI-TEXT-TOOLTIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-KIND                BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 10.
 01 WS-Y                   BINARY-LONG VALUE 20.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LW                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-GUIW                BINARY-LONG.
 01 WS-GUIH                BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-LINE-LEN            BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-SPACING             BINARY-LONG.
 01 WS-GLYPHS              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 2 TO CL-GUI-SCALE
     MOVE "N" TO TL-MODE
*>   (a) colour of a label: default white, #404040 grey.
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE WK-LABEL TO WS-KIND
     MOVE "Hi" TO WS-TEXT
     MOVE 2 TO WS-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT WS-LENGTH WS-Z5
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-MILLI ROUNDED = RL-UI-B(1) * 1000
     MOVE "acceptance US12 12§5.6 a label with no colour is drawn white (brightness 1)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4210752 TO WS-RGB
     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-MILLI ROUNDED = RL-UI-B(1) * 1000
     MOVE "acceptance US12 12§5.6 a label coloured #404040 is drawn at brightness 0.251" TO TL-CASE
     MOVE 251 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 12§5.6 the colour applies to every glyph of the text and to no other widget (second glyph too)" TO TL-CASE
     COMPUTE WS-MILLI ROUNDED = RL-UI-B(RL-UI-COUNT) * 1000
     MOVE 251 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT WS-LENGTH WS-Z5
     CALL "UI-RENDER" USING CLIENT-STATE
     COMPUTE WS-MILLI ROUNDED = RL-UI-B(1) * 1000
     MOVE "acceptance US12 12§5.6 a widget added after a coloured one starts white again" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   (b) tooltip placement on a 320 x 240 GUI.
     MOVE 320 TO WS-GUIW
     MOVE 240 TO WS-GUIH
     MOVE 0 TO TT-COUNT
     MOVE "Hi" TO WS-LINE
     MOVE 2 TO WS-LINE-LEN
     MOVE 16777215 TO WS-RGB
     CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-LINE WS-LINE-LEN WS-RGB
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-LINE WS-LINE-LEN WS-WIDTH
     MOVE 100 TO TT-X
     MOVE 100 TO TT-Y
     MOVE 0 TO TT-TITLE-GAP
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 a one-line tooltip at mouse (100, 100) starts at (112, 88), 10 high, as wide as its text" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 112 * 1000000 + 88 * 1000 + 10
     COMPUTE TL-OBSERVED-N = WS-LX * 1000000 + WS-LY * 1000 + WS-LH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 12§5.8 the block's width is the widest line's text width" TO TL-CASE
     MOVE WS-WIDTH TO TL-EXPECTED-N
     MOVE WS-LW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "Longer line" TO WS-LINE
     MOVE 11 TO WS-LINE-LEN
     CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-LINE WS-LINE-LEN WS-RGB
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-LINE WS-LINE-LEN WS-WIDTH
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 two lines: width of the longer, height 20 without the title gap" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-WIDTH * 1000 + 20
     COMPUTE TL-OBSERVED-N = WS-LW * 1000 + WS-LH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TT-TITLE-GAP
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 an item tooltip (title gap) is 2 pixels higher: 22" TO TL-CASE
     MOVE 22 TO TL-EXPECTED-N
     MOVE WS-LH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TT-TITLE-GAP
     MOVE 300 TO TT-X
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 right clamp: x + width over the GUI width gives x = max(x - 24 - width, 4)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 300 + 12 - 24 - WS-LW
     MOVE WS-LX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO TT-X
     MOVE 230 TO TT-Y
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 bottom clamp: y + height + 3 over the GUI height gives y = guiH - height - 3" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 240 - WS-LH - 3
     MOVE WS-LY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TT-X
     MOVE 100 TO TT-Y
     MOVE 40 TO WS-GUIW
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-LX WS-LY WS-LW WS-LH
     MOVE "acceptance US12 12§5.8 a clamped x never goes below 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-LX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drawing: lines in their colours on the top layer, after the background.
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 0 TO TT-COUNT
     MOVE "Hi" TO WS-LINE
     MOVE 2 TO WS-LINE-LEN
     MOVE 4210752 TO WS-RGB
     CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-LINE WS-LINE-LEN WS-RGB
     MOVE 100 TO TT-X
     MOVE 100 TO TT-Y
     MOVE 0 TO GS-W(GSP-TOOLTIP-BACK) GS-W(GSP-TOOLTIP-FRAME)
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US12 12§5.8 without the sprites: one swatch quad over the padded block and one quad per glyph (2): 18 vertices" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE RL-UT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO GS-W(GSP-TOOLTIP-BACK) GS-H(GSP-TOOLTIP-BACK) GS-W(GSP-TOOLTIP-FRAME) GS-H(GSP-TOOLTIP-FRAME)
     MOVE 0 TO GS-NINE(GSP-TOOLTIP-BACK) GS-NINE(GSP-TOOLTIP-FRAME)
     MOVE 1 TO TT-TITLE-GAP
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US12 12§5.8 with the sprites: the background and the frame (two quads) and one quad per glyph (2): 24 vertices" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-UT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TT-TITLE-GAP
     COMPUTE WS-GLYPHS = RL-UT-COUNT / 6
     MOVE "acceptance US12 12§5.8 a tooltip is drawn on the top layer: background quads (a swatch fallback without the sprites) and one quad per glyph" TO TL-CASE
     IF WS-GLYPHS >= 3
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-MILLI ROUNDED = RL-UT-B(RL-UT-COUNT) * 1000
     MOVE "acceptance US12 12§5.8 the last glyph of the line has the line's colour brightness (0.251)" TO TL-CASE
     MOVE 251 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TT-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US12 12§5.8 with no tooltip lines nothing is drawn on the top layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-UT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-UI-TEXT-TOOLTIP.
