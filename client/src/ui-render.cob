*> The 2-D user interface (research R4; data-model §13; 08 §10.10 text rules): UI-RENDER turns the
*> screen model into UI-pipeline vertices on texture 2 (the UI atlas of FONT-LOAD), in window pixels
*> (GUI pixels x CL-GUI-SCALE): buttons, text fields and list entries get a background quad on the
*> centre texel of their swatch (button; field; entry, or selected when selected), then the
*> widget's text: one quad per non-space character from the pack font, advancing by the glyph's
*> advance (missing glyph for characters the font lacks). A button's text is centred, a field's or
*> entry's starts 4 GUI pixels in, both centred vertically; a focused field ends with a caret "_".

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
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-UI-COUNT
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         MOVE SM-W-TEXT(WS-W) TO WS-TEXT
         MOVE SM-W-LENGTH(WS-W) TO WS-LENGTH
         MOVE -1 TO WS-SWATCH
         EVALUATE TRUE
             WHEN SM-W-KIND(WS-W) = WK-BUTTON
                 MOVE SW-BUTTON TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-FIELD
                 MOVE SW-FIELD TO WS-SWATCH
                 IF SM-W-STATE(WS-W) = 1
                     ADD 1 TO WS-LENGTH
                     MOVE "_" TO WS-TEXT(WS-LENGTH:1)
                 END-IF
             WHEN SM-W-KIND(WS-W) = WK-ENTRY AND SM-W-STATE(WS-W) = 1
                 MOVE SW-SELECTED TO WS-SWATCH
             WHEN SM-W-KIND(WS-W) = WK-ENTRY
                 MOVE SW-PANEL TO WS-SWATCH
         END-EVALUATE
         IF WS-SWATCH >= 0
             CALL "UI-SWATCH-QUAD" USING CLIENT-STATE SM-W-X(WS-W) SM-W-Y(WS-W) SM-W-W(WS-W)
                 SM-W-H(WS-W) WS-SWATCH
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
     END-PERFORM
     GOBACK.
 END PROGRAM UI-RENDER.

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
 PROGRAM-ID. UI-QUAD.
*> USING CLIENT-STATE, x0, y0, x1, y1 (window pixels), u0, v0, u1, v1 (FLOAT-SHORT): two triangles
*> top-left, top-right, bottom-right, top-left, bottom-right, bottom-left (brightness and alpha 1),
*> while RL-UI-VERTEX has room.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-C                   BINARY-LONG.
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
     IF RL-UI-COUNT + 6 <= CL-MAX-UI-VERTICES
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             ADD 1 TO RL-UI-COUNT
             MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
             MOVE L-X0 TO RL-UI-X(RL-UI-COUNT)
             MOVE L-U0 TO RL-UI-U(RL-UI-COUNT)
             IF WS-C = 2 OR WS-C = 3
                 MOVE L-X1 TO RL-UI-X(RL-UI-COUNT)
                 MOVE L-U1 TO RL-UI-U(RL-UI-COUNT)
             END-IF
             MOVE L-Y0 TO RL-UI-Y(RL-UI-COUNT)
             MOVE L-V0 TO RL-UI-V(RL-UI-COUNT)
             IF WS-C >= 3
                 MOVE L-Y1 TO RL-UI-Y(RL-UI-COUNT)
                 MOVE L-V1 TO RL-UI-V(RL-UI-COUNT)
             END-IF
             MOVE 0 TO RL-UI-Z(RL-UI-COUNT)
             MOVE 1 TO RL-UI-B(RL-UI-COUNT) RL-UI-A(RL-UI-COUNT)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM UI-QUAD.
