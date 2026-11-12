*> The 2-D user interface (research R4; data-model §13; 08 §10.10 text rules): UI-RENDER turns the
*> screen model into UI-pipeline vertices on texture 2 (the UI atlas of FONT-LOAD), in window pixels
*> (GUI pixels x CL-GUI-SCALE): buttons, text fields and list entries get a background quad on the
*> centre texel of their swatch (button, or panel when disabled; field; entry, or selected when
*> selected), then the widget's text: one quad per non-space character from the pack font, advancing by the glyph's
*> advance (missing glyph for characters the font lacks). A button's text is centred, a field's or
*> entry's starts 4 GUI pixels in, both centred vertically; a focused field ends with a caret "_"
*> (a quad of its own after the text, so a field at its full 256 bytes keeps its caret).
*> An item slot (08 §10.8.6 hotbar; 10.11 item icons) gets a background quad (selected when it is
*> the held slot; none for the stack on the cursor), its stack's icon 2 GUI pixels in (16 x 16, the
*> item's icon sprite in the block-and-item atlas: the icon layer, texture 0) and its count in the
*> bottom-right corner on the layer drawn over the icons (RL-UI-LAYER 1). UI-QUAD writes to the
*> layer RL-UI-LAYER names: 0 the UI, 1 over the icons, 2 the icons. An overlay (the hurt
*> indication) is a quad over its rectangle on the swatch its argument names. A pack icon is a quad
*> over its rectangle on its 16 x 16 icon cell of the UI atlas (local.cob). A sprite widget (WK-SPRITE) is its GUI sprite
*> over its rectangle; a meter (WK-METER; UI-METER) is the hearts or the food row of the HUD (12 §5.4), one 9 x 9 sprite
*> quad per icon: the container or empty sprite, then the full or half sprite over it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-RENDER.
*> USING CLIENT-STATE: fills RL-UI-VERTEX and RL-UI-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-W                   BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CARET               BINARY-LONG.
 01 WS-CARET-TEXT          PIC X(256) VALUE "_".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SPRITE-ROW          BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-UI-COUNT RL-IC-COUNT RL-UT-COUNT RL-UI-LAYER RL-UI-FADE RL-UI-DARK
     CALL "HB-RNG-SEED" USING CLIENT-STATE
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         MOVE SM-W-TEXT(WS-W) TO WS-TEXT
         MOVE SM-W-LENGTH(WS-W) TO WS-LENGTH
         MOVE 0 TO WS-CARET
         MOVE -1 TO WS-SWATCH
         EVALUATE TRUE
             WHEN SM-W-KIND(WS-W) = WK-BUTTON AND SM-W-STATE(WS-W) = 2
                 MOVE SW-PANEL TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-BUTTON
                 MOVE SW-BUTTON TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-FIELD
                 MOVE SW-FIELD TO WS-SWATCH
                 MOVE SM-W-STATE(WS-W) TO WS-CARET
             WHEN SM-W-KIND(WS-W) = WK-ENTRY AND SM-W-STATE(WS-W) = 1
                 MOVE SW-SELECTED TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-ENTRY
                 MOVE SW-PANEL TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-SLOT
                 CALL "UI-SLOT" USING CLIENT-STATE WS-W
                 MOVE 0 TO WS-LENGTH
             WHEN SM-W-KIND(WS-W) = WK-OVERLAY
                 MOVE SM-W-ARG(WS-W) TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-ICON
                 CALL "UI-ICON-QUAD" USING CLIENT-STATE WS-W
             WHEN SM-W-KIND(WS-W) = WK-SPRITE
                 MOVE SM-W-ARG(WS-W) TO WS-SPRITE-ROW
                 IF WS-SPRITE-ROW >= 1 AND WS-SPRITE-ROW <= GSP-COUNT
                     IF GS-W(WS-SPRITE-ROW) > 0
*>                       A sprite's state above 0 is its alpha in thousandths plus 1 (the fading effect icons).
                         IF SM-W-STATE(WS-W) > 0
                             COMPUTE RL-UI-FADE = 1 - (SM-W-STATE(WS-W) - 1) / 1000
                         END-IF
                         CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(WS-W)
                             SM-W-Y(WS-W) SM-W-W(WS-W) SM-W-H(WS-W)
                         MOVE 0 TO RL-UI-FADE
                     END-IF
                 END-IF
                 MOVE 0 TO WS-LENGTH
             WHEN SM-W-KIND(WS-W) = WK-IMAGE
                 MOVE SM-W-SPRITE(WS-W) TO WS-SPRITE-ROW
                 IF WS-SPRITE-ROW >= 1 AND WS-SPRITE-ROW <= GSP-COUNT AND GS-W(WS-SPRITE-ROW) > 0
                     CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(WS-W)
                         SM-W-Y(WS-W) SM-W-W(WS-W) SM-W-H(WS-W)
                 END-IF
                 MOVE 0 TO WS-LENGTH
             WHEN SM-W-KIND(WS-W) = WK-METER
                 CALL "UI-METER" USING CLIENT-STATE WS-W
                 MOVE 0 TO WS-LENGTH
             WHEN SM-W-KIND(WS-W) = WK-SHEET
                 CALL "UI-SHEET-QUAD" USING CLIENT-STATE WS-W
                 MOVE 0 TO WS-LENGTH
         END-EVALUATE
         IF WS-SWATCH >= 0
             IF SM-W-KIND(WS-W) = WK-BUTTON AND GS-W(GSP-BUTTON) > 0
                 MOVE GSP-BUTTON TO WS-SPRITE-ROW
                 CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(WS-W) SM-W-Y(WS-W)
                     SM-W-W(WS-W) SM-W-H(WS-W)
             ELSE
                 CALL "UI-SWATCH-QUAD" USING CLIENT-STATE SM-W-X(WS-W) SM-W-Y(WS-W) SM-W-W(WS-W)
                     SM-W-H(WS-W) WS-SWATCH
             END-IF
         END-IF
         MOVE SM-W-X(WS-W) TO WS-X
         MOVE SM-W-Y(WS-W) TO WS-Y
         IF SM-W-KIND(WS-W) NOT = WK-LABEL
             COMPUTE WS-Y = SM-W-Y(WS-W) + (SM-W-H(WS-W) - FN-HEIGHT) / 2
             ADD 4 TO WS-X
         END-IF
         IF SM-W-KIND(WS-W) = WK-BUTTON
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             COMPUTE WS-X = SM-W-X(WS-W) + (SM-W-W(WS-W) - WS-WIDTH) / 2
         END-IF
         MOVE SM-W-COLOUR(WS-W) TO WS-RGB
         IF WS-RGB = 0
             MOVE 16777215 TO WS-RGB
         END-IF
         CALL "UI-TEXT-C" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y WS-RGB
         IF WS-CARET = 1
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             ADD WS-WIDTH TO WS-X
             CALL "UI-TEXT" USING CLIENT-STATE WS-CARET-TEXT WS-ONE WS-X WS-Y
         END-IF
     END-PERFORM
     IF TT-COUNT > 0
         CALL "TOOLTIP-DRAW" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM UI-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SHEET-QUAD.
*> USING CLIENT-STATE, widget (a sheet region): one quad over the widget's rectangle on the region of the sheet from its origin
*> (state 1: from (1, 1), the vanilla recipe-book panel) of the widget's size, in logical units of the 256 x 256 sheet (a sheet
*> of a larger size scales them by its width / 256).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ROW                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-W.
     MOVE SM-W-ARG(L-W) TO WS-ROW
     IF WS-ROW >= GSP-SHEET-INVENTORY AND WS-ROW <= GSP-SHEET-BOOK
         IF GS-W(WS-ROW) > 0
             COMPUTE WS-F = GS-W(WS-ROW) / 256
             COMPUTE WS-X0 = SM-W-X(L-W) * CL-GUI-SCALE
             COMPUTE WS-Y0 = SM-W-Y(L-W) * CL-GUI-SCALE
             COMPUTE WS-X1 = (SM-W-X(L-W) + SM-W-W(L-W)) * CL-GUI-SCALE
             COMPUTE WS-Y1 = (SM-W-Y(L-W) + SM-W-H(L-W)) * CL-GUI-SCALE
             COMPUTE WS-U0 = (GS-X(WS-ROW) + SM-W-STATE(L-W) * WS-F) / UA-W
             COMPUTE WS-V0 = (GS-Y(WS-ROW) + SM-W-STATE(L-W) * WS-F) / UA-H
             COMPUTE WS-U1 = (GS-X(WS-ROW) + (SM-W-STATE(L-W) + SM-W-W(L-W)) * WS-F) / UA-W
             COMPUTE WS-V1 = (GS-Y(WS-ROW) + (SM-W-STATE(L-W) + SM-W-H(L-W)) * WS-F) / UA-H
             CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM UI-SHEET-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-METER.
*> USING CLIENT-STATE, widget (a meter): its argument is the kind of row (hearts.cob: 1 hearts, 2 food, 3 armour, 4 air, 5 mount health), its position the
*> anchor of icon 0 (hearts grow right, the others left or right as METER-ICON says). One 9 x 9 sprite quad per sprite row of an icon: base, absorption,
*> ghost, current. The hearts are drawn from the last slot down to 0, the order of the random numbers of the frame.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NINE                BINARY-LONG VALUE 9.
 01 WS-NINE2               BINARY-LONG VALUE 9.
 01 WS-OUT.
    05 WS-OX               BINARY-LONG.
    05 WS-OY               BINARY-LONG.
    05 WS-ROWS             BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-W.
     MOVE SM-W-ARG(L-W) TO WS-KIND
     MOVE 1 TO WS-STEP
     EVALUATE WS-KIND
         WHEN 1
             CALL "HEART-MAX" USING CLIENT-STATE WS-M
             COMPUTE WS-A = FUNCTION INTEGER(PL-ABSORPTION)
             IF PL-ABSORPTION > WS-A
                 ADD 1 TO WS-A
             END-IF
             COMPUTE WS-FIRST = (WS-M + 1) / 2
             COMPUTE WS-I = (WS-A + 1) / 2
             COMPUTE WS-FIRST = WS-FIRST + WS-I - 1
             MOVE 0 TO WS-LAST
             MOVE -1 TO WS-STEP
         WHEN 4
             MOVE 1 TO WS-FIRST
             MOVE 10 TO WS-LAST
         WHEN 5
             MOVE 0 TO WS-FIRST
             COMPUTE WS-LAST = PL-MOUNT-HEARTS - 1
         WHEN OTHER
             MOVE 0 TO WS-FIRST
             MOVE 9 TO WS-LAST
     END-EVALUATE
     PERFORM VARYING WS-K FROM WS-FIRST BY WS-STEP UNTIL (WS-STEP = 1 AND WS-K > WS-LAST)
             OR (WS-STEP = -1 AND WS-K < WS-LAST)
         CALL "METER-ICON" USING CLIENT-STATE WS-KIND WS-K SM-W-X(L-W) SM-W-Y(L-W) WS-OUT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-ROWS(WS-I) TO WS-ROW
             IF WS-ROW > 0
                 IF GS-W(WS-ROW) > 0
                     CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-ROW WS-OX WS-OY WS-NINE WS-NINE2
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM UI-METER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SLOT.
*> USING CLIENT-STATE, widget (an item slot): its background, icon and count (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SPRITE-ROW          BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-INSET               BINARY-LONG.
 01 WS-MAXDMG              BINARY-LONG.
 01 WS-BARW                BINARY-LONG.
 01 WS-BARSW               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THIRTEEN            BINARY-LONG VALUE 13.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ZERO                FLOAT-SHORT VALUE 0.
 01 WS-ZERO2               FLOAT-SHORT VALUE 0.
 01 WS-SIXTEEN             FLOAT-SHORT VALUE 16.
 01 WS-SIXTEEN2            FLOAT-SHORT VALUE 16.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-W.
     MOVE SM-W-ARG(L-W) TO WS-ARG
     CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
     IF SM-W-ARG(L-W) NOT = 36
         MOVE SW-PANEL TO WS-SWATCH
*>       State 3 is a bare slot: the screen's own art (the hotbar sprite) carries the well.
         IF SM-W-STATE(L-W) = 3
             CONTINUE
         ELSE
             IF GS-W(GSP-SLOT) > 0
                 MOVE GSP-SLOT TO WS-SPRITE-ROW
                 CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(L-W) SM-W-Y(L-W)
                     SM-W-W(L-W) SM-W-H(L-W)
             ELSE
                 CALL "UI-SWATCH-QUAD" USING CLIENT-STATE SM-W-X(L-W) SM-W-Y(L-W) SM-W-W(L-W)
                     SM-W-H(L-W) WS-SWATCH
             END-IF
         END-IF
     END-IF
     MOVE 0 TO WS-SPRITE
     IF WS-COUNT > 0 AND WS-ITEM >= 0
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     END-IF
     IF WS-SPRITE > 0
*>       The icon cell is 16 x 16, centred in the slot (2 pixels in a 20 slot, 1 in an 18 slot).
         COMPUTE WS-INSET = (SM-W-W(L-W) - 16) / 2
         COMPUTE WS-X0 = (SM-W-X(L-W) + WS-INSET) * CL-GUI-SCALE
         COMPUTE WS-Y0 = (SM-W-Y(L-W) + WS-INSET) * CL-GUI-SCALE
         COMPUTE WS-X1 = (SM-W-X(L-W) + WS-INSET + 16) * CL-GUI-SCALE
         COMPUTE WS-Y1 = (SM-W-Y(L-W) + WS-INSET + 16) * CL-GUI-SCALE
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-ZERO WS-ZERO2 WS-U0 WS-V0
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-SIXTEEN WS-SIXTEEN2 WS-U1 WS-V1
         MOVE 2 TO RL-UI-LAYER
         CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         MOVE SM-W-TEXT(L-W) TO WS-TEXT
         MOVE SM-W-LENGTH(L-W) TO WS-LENGTH
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
*>       Count rule (FR-014): right-aligned at the slot's bottom edge, inside the slot (a glyph cell
*>       reaches 2 GUI pixels past its advance, and 1 pixel is kept free at the left); a count too wide for
*>       the slot loses digits from the right and ends with "+".
         PERFORM UNTIL WS-WIDTH <= SM-W-W(L-W) - 4 OR WS-LENGTH <= 1
             IF WS-TEXT(WS-LENGTH:1) = "+"
                 SUBTRACT 1 FROM WS-LENGTH
             END-IF
             SUBTRACT 1 FROM WS-LENGTH
             MOVE "+" TO WS-TEXT(WS-LENGTH + 1:1)
             ADD 1 TO WS-LENGTH
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
         END-PERFORM
         COMPUTE WS-X = SM-W-X(L-W) + SM-W-W(L-W) - WS-WIDTH - 3
         COMPUTE WS-Y = SM-W-Y(L-W) + SM-W-H(L-W) - FN-HEIGHT - 1
         MOVE 1 TO RL-UI-LAYER
         CALL "UI-TEXT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y
         MOVE 0 TO RL-UI-LAYER
*>       The durability bar of a damaged stack (17 section 5.7): a black bar 13 x 2 pixels at (2, 13) of the icon cell, the coloured
*>       part over it, 1 pixel high.
         IF WS-DAMAGE > 0
             CALL "ITEM-MAX-DAMAGE" USING CLIENT-STATE WS-ITEM WS-MAXDMG
             CALL "ITEM-BAR" USING WS-DAMAGE WS-MAXDMG WS-BARW WS-BARSW
             IF WS-BARW >= 0
                 COMPUTE WS-X = SM-W-X(L-W) + WS-INSET + 2
                 COMPUTE WS-Y = SM-W-Y(L-W) + WS-INSET + 13
                 MOVE 1 TO RL-UI-LAYER
                 CALL "UI-SWATCH-QUAD" USING CLIENT-STATE WS-X WS-Y WS-THIRTEEN WS-TWO SW-BLACK
                 IF WS-BARW > 0
                     CALL "UI-SWATCH-QUAD" USING CLIENT-STATE WS-X WS-Y WS-BARW WS-ONE WS-BARSW
                 END-IF
                 MOVE 0 TO RL-UI-LAYER
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM UI-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-TEXT-WIDTH.
*> USING CLIENT-STATE, text (PIC X(256), UTF-8), length, width out (GUI pixels: the sum of the
*> advances).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADVANCE             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-WIDTH.
     MOVE 0 TO L-WIDTH
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-LENGTH
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADVANCE
         ADD WS-ADVANCE TO L-WIDTH
     END-PERFORM
     GOBACK.
 END PROGRAM UI-TEXT-WIDTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-TEXT.
*> USING CLIENT-STATE, text (PIC X(256)), length, x, y (GUI pixels, top-left): glyph quads.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-POS                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADVANCE             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-X L-Y.
     MOVE L-X TO WS-X
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-LENGTH
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADVANCE
         IF WS-CP NOT = 32
             COMPUTE WS-X0 = WS-X * CL-GUI-SCALE
             COMPUTE WS-Y0 = L-Y * CL-GUI-SCALE
             COMPUTE WS-X1 = (WS-X + FN-HEIGHT * WS-GW / WS-GH) * CL-GUI-SCALE
             COMPUTE WS-Y1 = (L-Y + FN-HEIGHT) * CL-GUI-SCALE
             COMPUTE WS-U0 = WS-GX / UA-W
             COMPUTE WS-V0 = WS-GY / UA-H
             COMPUTE WS-U1 = (WS-GX + WS-GW) / UA-W
             COMPUTE WS-V1 = (WS-GY + WS-GH) / UA-H
             CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         END-IF
         ADD WS-ADVANCE TO WS-X
     END-PERFORM
     GOBACK.
 END PROGRAM UI-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SWATCH-QUAD.
*> USING CLIENT-STATE, x, y, width, height (GUI pixels), swatch: a quad on the swatch's centre
*> texel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-U2                  FLOAT-SHORT.
 01 WS-V2                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-SWATCH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-W L-H L-SWATCH.
     COMPUTE WS-X0 = L-X * CL-GUI-SCALE
     COMPUTE WS-Y0 = L-Y * CL-GUI-SCALE
     COMPUTE WS-X1 = (L-X + L-W) * CL-GUI-SCALE
     COMPUTE WS-Y1 = (L-Y + L-H) * CL-GUI-SCALE
     COMPUTE WS-U = (L-SWATCH * 8 + 4) / UA-W
     COMPUTE WS-V = (UA-H - 4) / UA-H
     MOVE WS-U TO WS-U2
     MOVE WS-V TO WS-V2
     CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U WS-V WS-U2 WS-V2
     GOBACK.
 END PROGRAM UI-SWATCH-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SPRITE-QUAD.
*> USING CLIENT-STATE, sprite row (GSP-*), x, y, width, height (GUI pixels): the GUI sprite over the
*> rectangle. A nine-slice sprite (12 §5.9) is nine quads: the borders (the .mcmeta's, in the sprite's own
*> size, each at most half the rectangle) copied unscaled, the edges and the centre stretched; the borders
*> in sprite pixels are the border x pixel width / .mcmeta width. Any other sprite is one stretched quad.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-BT                  BINARY-LONG.
 01 WS-BR                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-XS                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-YS                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-TX                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TY                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-W L-H.
     IF GS-NINE(L-ROW) = 0
         COMPUTE WS-X0 = L-X * CL-GUI-SCALE
         COMPUTE WS-Y0 = L-Y * CL-GUI-SCALE
         COMPUTE WS-X1 = (L-X + L-W) * CL-GUI-SCALE
         COMPUTE WS-Y1 = (L-Y + L-H) * CL-GUI-SCALE
         COMPUTE WS-U0 = GS-X(L-ROW) / UA-W
         COMPUTE WS-V0 = GS-Y(L-ROW) / UA-H
         COMPUTE WS-U1 = (GS-X(L-ROW) + GS-W(L-ROW)) / UA-W
         COMPUTE WS-V1 = (GS-Y(L-ROW) + GS-H(L-ROW)) / UA-H
         CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         GOBACK
     END-IF
     COMPUTE WS-BL = FUNCTION MIN(GS-BL(L-ROW), L-W / 2)
     COMPUTE WS-BR = FUNCTION MIN(GS-BR(L-ROW), L-W / 2)
     COMPUTE WS-BT = FUNCTION MIN(GS-BT(L-ROW), L-H / 2)
     COMPUTE WS-BB = FUNCTION MIN(GS-BB(L-ROW), L-H / 2)
     MOVE L-X TO WS-XS(1)
     COMPUTE WS-XS(2) = L-X + WS-BL
     COMPUTE WS-XS(3) = L-X + L-W - WS-BR
     COMPUTE WS-XS(4) = L-X + L-W
     MOVE L-Y TO WS-YS(1)
     COMPUTE WS-YS(2) = L-Y + WS-BT
     COMPUTE WS-YS(3) = L-Y + L-H - WS-BB
     COMPUTE WS-YS(4) = L-Y + L-H
*>   The sprite's texel columns and rows of the same cuts.
     MOVE 0 TO WS-TX(1)
     COMPUTE WS-TX(2) = WS-BL * GS-W(L-ROW) / GS-LW(L-ROW)
     COMPUTE WS-TX(3) = GS-W(L-ROW) - WS-BR * GS-W(L-ROW) / GS-LW(L-ROW)
     MOVE GS-W(L-ROW) TO WS-TX(4)
     MOVE 0 TO WS-TY(1)
     COMPUTE WS-TY(2) = WS-BT * GS-H(L-ROW) / GS-LH(L-ROW)
     COMPUTE WS-TY(3) = GS-H(L-ROW) - WS-BB * GS-H(L-ROW) / GS-LH(L-ROW)
     MOVE GS-H(L-ROW) TO WS-TY(4)
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
             COMPUTE WS-X0 = WS-XS(WS-C) * CL-GUI-SCALE
             COMPUTE WS-X1 = WS-XS(WS-C + 1) * CL-GUI-SCALE
             COMPUTE WS-Y0 = WS-YS(WS-R) * CL-GUI-SCALE
             COMPUTE WS-Y1 = WS-YS(WS-R + 1) * CL-GUI-SCALE
             COMPUTE WS-U0 = (GS-X(L-ROW) + WS-TX(WS-C)) / UA-W
             COMPUTE WS-U1 = (GS-X(L-ROW) + WS-TX(WS-C + 1)) / UA-W
             COMPUTE WS-V0 = (GS-Y(L-ROW) + WS-TY(WS-R)) / UA-H
             COMPUTE WS-V1 = (GS-Y(L-ROW) + WS-TY(WS-R + 1)) / UA-H
             CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM UI-SPRITE-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-QUAD.
*> USING CLIENT-STATE, x0, y0, x1, y1 (window pixels), u0, v0, u1, v1 (FLOAT-SHORT): two triangles
*> top-left, top-right, bottom-right, top-left, bottom-right, bottom-left (brightness and alpha 1, no sky term, white tint),
*> on the layer RL-UI-LAYER names (0 RL-UI-VERTEX, 1 RL-UT-VERTEX, 2 RL-IC-VERTEX), while it has
*> room.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-C                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 B-LAYER BASED.
    05 B-VERTEX OCCURS 24576 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-A              FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X0                   FLOAT-SHORT.
 01 L-Y0                   FLOAT-SHORT.
 01 L-X1                   FLOAT-SHORT.
 01 L-Y1                   FLOAT-SHORT.
 01 L-U0                   FLOAT-SHORT.
 01 L-V0                   FLOAT-SHORT.
 01 L-U1                   FLOAT-SHORT.
 01 L-V1                   FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-X0 L-Y0 L-X1 L-Y1 L-U0 L-V0 L-U1 L-V1.
     EVALUATE RL-UI-LAYER
         WHEN 1
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-UT-VERTEX(1)
             MOVE RL-UT-COUNT TO WS-COUNT
             MOVE CL-MAX-TOP-VERTICES TO WS-MAX
         WHEN 2
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-IC-VERTEX(1)
             MOVE RL-IC-COUNT TO WS-COUNT
             MOVE CL-MAX-ICON-VERTICES TO WS-MAX
         WHEN OTHER
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-UI-VERTEX(1)
             MOVE RL-UI-COUNT TO WS-COUNT
             MOVE CL-MAX-UI-VERTICES TO WS-MAX
     END-EVALUATE
     IF WS-COUNT + 6 <= WS-MAX
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             ADD 1 TO WS-COUNT
             MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
             MOVE L-X0 TO B-X(WS-COUNT)
             MOVE L-U0 TO B-U(WS-COUNT)
             IF WS-C = 2 OR WS-C = 3
                 MOVE L-X1 TO B-X(WS-COUNT)
                 MOVE L-U1 TO B-U(WS-COUNT)
             END-IF
             MOVE L-Y0 TO B-Y(WS-COUNT)
             MOVE L-V0 TO B-V(WS-COUNT)
             IF WS-C >= 3
                 MOVE L-Y1 TO B-Y(WS-COUNT)
                 MOVE L-V1 TO B-V(WS-COUNT)
             END-IF
             MOVE 0 TO B-Z(WS-COUNT)
             COMPUTE B-B(WS-COUNT) = 1 - RL-UI-DARK
             COMPUTE B-A(WS-COUNT) = 1 - RL-UI-FADE
             MOVE 0 TO B-SKY(WS-COUNT)
             MOVE 1 TO B-R(WS-COUNT) B-G(WS-COUNT) B-BLUE(WS-COUNT)
         END-PERFORM
     END-IF
     EVALUATE RL-UI-LAYER
         WHEN 1
             MOVE WS-COUNT TO RL-UT-COUNT
         WHEN 2
             MOVE WS-COUNT TO RL-IC-COUNT
         WHEN OTHER
             MOVE WS-COUNT TO RL-UI-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-ICON-QUAD.
*> USING CLIENT-STATE, widget (a pack icon): a quad over the widget's rectangle on its icon cell
*> (the argument: cells of 16 x 16 from row UA-ICON-Y, as many to a row as fit).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PER                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-X0                  FLOAT-SHORT.
 01 WS-Y0                  FLOAT-SHORT.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-Y1                  FLOAT-SHORT.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-W.
     COMPUTE WS-PER = UA-W / 16
     COMPUTE WS-CX = FUNCTION MOD(SM-W-ARG(L-W) - 1, WS-PER) * 16
     COMPUTE WS-CY = (SM-W-ARG(L-W) - 1) / WS-PER
     COMPUTE WS-CY = UA-ICON-Y + WS-CY * 16
     COMPUTE WS-X0 = SM-W-X(L-W) * CL-GUI-SCALE
     COMPUTE WS-Y0 = SM-W-Y(L-W) * CL-GUI-SCALE
     COMPUTE WS-X1 = (SM-W-X(L-W) + SM-W-W(L-W)) * CL-GUI-SCALE
     COMPUTE WS-Y1 = (SM-W-Y(L-W) + SM-W-H(L-W)) * CL-GUI-SCALE
     COMPUTE WS-U0 = WS-CX / UA-W
     COMPUTE WS-V0 = WS-CY / UA-H
     COMPUTE WS-U1 = (WS-CX + 16) / UA-W
     COMPUTE WS-V1 = (WS-CY + 16) / UA-H
     CALL "UI-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-X1 WS-Y1 WS-U0 WS-V0 WS-U1 WS-V1
     GOBACK.
 END PROGRAM UI-ICON-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-TEXT-C.
*> USING CLIENT-STATE, text, length, x, y, colour (RGB integer): UI-TEXT with the glyphs at the grey luminance of the colour (the
*> vertex carries one brightness, so #404040 is 0.251 and white 1); the brightness is restored afterwards.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-X L-Y L-RGB.
     COMPUTE WS-R = L-RGB / 65536
     COMPUTE WS-G = FUNCTION MOD(L-RGB / 256, 256)
     COMPUTE WS-B = FUNCTION MOD(L-RGB, 256)
     COMPUTE RL-UI-DARK = 1 - (WS-R * 299 + WS-G * 587 + WS-B * 114) / 255000
     CALL "UI-TEXT" USING CLIENT-STATE L-TEXT L-LENGTH L-X L-Y
     MOVE 0 TO RL-UI-DARK
     GOBACK.
 END PROGRAM UI-TEXT-C.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLTIP-ADD.
*> USING CLIENT-STATE, text (PIC X(256)), length, colour (RGB integer): appends a line to the tooltip (at most 8 lines, 120 bytes each).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-RGB.
     IF TT-COUNT < 8
         ADD 1 TO TT-COUNT
         MOVE FUNCTION MIN(L-LENGTH, 120) TO TT-L-LEN(TT-COUNT)
         MOVE L-RGB TO TT-L-RGB(TT-COUNT)
         MOVE L-TEXT(1:120) TO TT-L-TEXT(TT-COUNT)
     END-IF
     GOBACK.
 END PROGRAM TOOLTIP-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLTIP-LAYOUT.
*> USING CLIENT-STATE, GUI width, GUI height, x, y, width, height (all out; GUI pixels): 12 section 5.8: the text block is as wide as its widest line and 10 high
*> per line (2 more when TT-TITLE-GAP is 1: item tooltips); it starts at the mouse (TT-X, TT-Y) + (12, -12); when x + width is over the GUI width, x becomes
*> max(x - 24 - width, 4); when y + height + 3 is over the GUI height, y becomes GUI height - height - 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GUIW                 BINARY-LONG.
 01 L-GUIH                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GUIW L-GUIH L-X L-Y L-W L-H.
     MOVE 0 TO L-W
     COMPUTE L-H = 10 * TT-COUNT + 2 * TT-TITLE-GAP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TT-COUNT
         MOVE TT-L-TEXT(WS-I) TO WS-TEXT
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT TT-L-LEN(WS-I) WS-WIDTH
         MOVE FUNCTION MAX(L-W, WS-WIDTH) TO L-W
     END-PERFORM
     COMPUTE L-X = TT-X + 12
     COMPUTE L-Y = TT-Y - 12
     IF L-X + L-W > L-GUIW
         COMPUTE L-X = FUNCTION MAX(L-X - 24 - L-W, 4)
     END-IF
     IF L-Y + L-H + 3 > L-GUIH
         COMPUTE L-Y = L-GUIH - L-H - 3
     END-IF
     GOBACK.
 END PROGRAM TOOLTIP-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLTIP-DRAW.
*> USING CLIENT-STATE: draws the tooltip of TT-* on the top layer: the background and frame sprites over (x - 12, y - 12) with (width + 24, height + 24) (a
*> swatch over the padded text block when the sprites are not loaded), then the lines from (x, y), 10 down each (the first line 2 more with the title gap),
*> each in its colour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-GUIW                BINARY-LONG.
 01 WS-GUIH                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-W2                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     COMPUTE WS-GUIW = IN-WIN-W / CL-GUI-SCALE
     COMPUTE WS-GUIH = IN-WIN-H / CL-GUI-SCALE
     CALL "TOOLTIP-LAYOUT" USING CLIENT-STATE WS-GUIW WS-GUIH WS-X WS-Y WS-W WS-H
     MOVE 1 TO RL-UI-LAYER
     COMPUTE WS-X0 = WS-X - 12
     COMPUTE WS-Y0 = WS-Y - 12
     COMPUTE WS-W2 = WS-W + 24
     COMPUTE WS-H2 = WS-H + 24
     IF GS-W(GSP-TOOLTIP-BACK) > 0 AND GS-W(GSP-TOOLTIP-FRAME) > 0
         MOVE GSP-TOOLTIP-BACK TO WS-ROW
         CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-ROW WS-X0 WS-Y0 WS-W2 WS-H2
         MOVE GSP-TOOLTIP-FRAME TO WS-ROW
         CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-ROW WS-X0 WS-Y0 WS-W2 WS-H2
     ELSE
         COMPUTE WS-X0 = WS-X - 3
         COMPUTE WS-Y0 = WS-Y - 3
         COMPUTE WS-W2 = WS-W + 6
         COMPUTE WS-H2 = WS-H + 6
         CALL "UI-SWATCH-QUAD" USING CLIENT-STATE WS-X0 WS-Y0 WS-W2 WS-H2 SW-PANEL
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TT-COUNT
         MOVE TT-L-TEXT(WS-I) TO WS-TEXT
         COMPUTE WS-Y0 = WS-Y + 10 * (WS-I - 1) + 2 * TT-TITLE-GAP * FUNCTION MIN(WS-I - 1, 1)
         CALL "UI-TEXT-C" USING CLIENT-STATE WS-TEXT TT-L-LEN(WS-I) WS-X WS-Y0 TT-L-RGB(WS-I)
     END-PERFORM
     MOVE 0 TO RL-UI-LAYER
     GOBACK.
 END PROGRAM TOOLTIP-DRAW.
