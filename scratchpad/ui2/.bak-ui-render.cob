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
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-UI-COUNT RL-IC-COUNT RL-UT-COUNT RL-UI-LAYER
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
                         CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(WS-W)
                             SM-W-Y(WS-W) SM-W-W(WS-W) SM-W-H(WS-W)
                     END-IF
                 END-IF
                 MOVE 0 TO WS-LENGTH
             WHEN SM-W-KIND(WS-W) = WK-METER
                 CALL "UI-METER" USING CLIENT-STATE WS-W
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
         CALL "UI-TEXT" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-X WS-Y
         IF WS-CARET = 1
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             ADD WS-WIDTH TO WS-X
             CALL "UI-TEXT" USING CLIENT-STATE WS-CARET-TEXT WS-ONE WS-X WS-Y
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM UI-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-METER.
*> USING CLIENT-STATE, widget (a meter): argument 1 hearts (icon k at x + 8 (k mod 10), y - 10 (k div 10): a container
*> sprite, then full when 2k + 2 <= value, half when 2k + 1 = value) or 2 food (icon k at x - 8 (k mod 10): the empty
*> sprite, then full or half likewise). The value is the state, the maximum the action (both in half icons).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-ICONS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NINE                BINARY-LONG VALUE 9.
 01 WS-NINE2               BINARY-LONG VALUE 9.
 01 WS-BASE                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-W.
     MOVE GSP-HEART-CONTAINER TO WS-BASE
     MOVE GSP-HEART-FULL TO WS-FULL
     MOVE GSP-HEART-HALF TO WS-HALF
     IF SM-W-ARG(L-W) = 2
         MOVE GSP-FOOD-EMPTY TO WS-BASE
         MOVE GSP-FOOD-FULL TO WS-FULL
         MOVE GSP-FOOD-HALF TO WS-HALF
     END-IF
     COMPUTE WS-ICONS = (SM-W-ACTION(L-W) + 1) / 2
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-ICONS
         COMPUTE WS-Y = SM-W-Y(L-W) - 10 * (WS-K / 10)
         IF SM-W-ARG(L-W) = 2
             COMPUTE WS-X = SM-W-X(L-W) - 8 * FUNCTION MOD(WS-K, 10)
         ELSE
             COMPUTE WS-X = SM-W-X(L-W) + 8 * FUNCTION MOD(WS-K, 10)
         END-IF
         MOVE WS-BASE TO WS-ROW
         IF GS-W(WS-ROW) > 0
             CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-NINE WS-NINE2
         END-IF
         MOVE 0 TO WS-ROW
         IF 2 * WS-K + 2 <= SM-W-STATE(L-W)
             MOVE WS-FULL TO WS-ROW
         END-IF
         IF 2 * WS-K + 1 = SM-W-STATE(L-W)
             MOVE WS-HALF TO WS-ROW
         END-IF
         IF WS-ROW > 0
             IF GS-W(WS-ROW) > 0
                 CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-NINE WS-NINE2
             END-IF
         END-IF
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
     IF SM-W-ARG(L-W) = 36
         MOVE PL-CARRIED-COUNT TO WS-COUNT
         MOVE PL-CARRIED-ITEM TO WS-ITEM
     ELSE
         IF SM-W-ARG(L-W) = 37
             MOVE PL-OFFHAND-COUNT TO WS-COUNT
             MOVE PL-OFFHAND-ITEM TO WS-ITEM
         ELSE
             MOVE PL-SLOT-COUNT(SM-W-ARG(L-W) + 1) TO WS-COUNT
             MOVE PL-SLOT-ITEM(SM-W-ARG(L-W) + 1) TO WS-ITEM
         END-IF
         MOVE SW-PANEL TO WS-SWATCH
         IF SM-W-STATE(L-W) = 1
             MOVE SW-SELECTED TO WS-SWATCH
         END-IF
*>       State 3 is a bare slot: the screen's own art (the hotbar sprite) carries the well.
         IF SM-W-STATE(L-W) = 3
             CONTINUE
         ELSE
             IF GS-W(GSP-SLOT) > 0 AND SM-W-STATE(L-W) NOT = 1
                 MOVE GSP-SLOT TO WS-SPRITE-ROW
                 CALL "UI-SPRITE-QUAD" USING CLIENT-STATE WS-SPRITE-ROW SM-W-X(L-W) SM-W-Y(L-W)
                     SM-W-W(L-W) SM-W-H(L-W)
             ELSE
                 CALL "UI-SWATCH-QUAD" USING CLIENT-STATE SM-W-X(L-W) SM-W-Y(L-W) SM-W-W(L-W)
                     SM-W-H(L-W) WS-SWATCH
             END-IF
         END-IF
     END-IF
     IF WS-COUNT > 0 AND WS-ITEM >= 0 AND WS-ITEM < CL-ITEM-COUNT
         MOVE IT-SPRITE(WS-ITEM + 1) TO WS-SPRITE
         COMPUTE WS-X0 = (SM-W-X(L-W) + 2) * CL-GUI-SCALE
         COMPUTE WS-Y0 = (SM-W-Y(L-W) + 2) * CL-GUI-SCALE
         COMPUTE WS-X1 = (SM-W-X(L-W) + 18) * CL-GUI-SCALE
         COMPUTE WS-Y1 = (SM-W-Y(L-W) + 18) * CL-GUI-SCALE
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
*> top-left, top-right, bottom-right, top-left, bottom-right, bottom-left (brightness and alpha 1),
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
             MOVE 1 TO B-B(WS-COUNT) B-A(WS-COUNT)
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
