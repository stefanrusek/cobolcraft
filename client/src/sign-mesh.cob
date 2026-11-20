*> Sign text mesh (docs/protocol/52-block-entity-models-2-signs.md): SGR-MESH builds the glyph quads of every sign the client holds text for (SN-ENTRY, signtext.cob)
*> that lies within 64 blocks of the camera (7) and whose cell still holds a sign: both sides, four lines each, laid out by SGR-LAYOUT, placed by SGR-POSE, coloured by
*> SGR-COLOR. The vertices are the world format (position eye-relative, u, v, brightness, alpha, sky, tint rgb: 11 FLOAT-SHORT) of the UI atlas that holds the font
*> (texture 2); the render list draws them with CC-PIPE-OPAQUE in the slot MESH-SLOT-SIGNS (CLSIGN.cpy). The outline of glowing text (eight copies at one font pixel,
*> section 6.4) is written before the fill, and the fill is pulled a little nearer the eye than the outline and the board, standing in for the polygon offset.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-QUAD-ADD.
*> USING vertex area (PIC X, SGR-MAX-VERTICES vertices of 44 bytes), count (in and out), capacity, SGR-QUAD (SGRQUAD.cpy): six vertices, top left, bottom left, bottom
*> right, top left, bottom right, top right, alpha 1, while the area has room.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ORDER               PIC X(6) VALUE "123134".
 01 WS-AT                  BINARY-LONG.
 01 B-AREA BASED.
    05 B-VERTEX OCCURS 65536 TIMES.
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
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 COPY SGRQUAD.
 PROCEDURE DIVISION USING L-AREA L-COUNT L-CAPACITY SGR-QUAD.
     IF L-COUNT + 6 > L-CAPACITY
         GOBACK
     END-IF
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         ADD 1 TO L-COUNT
         MOVE FUNCTION NUMVAL(WS-ORDER(WS-K:1)) TO WS-C
         COMPUTE WS-AT = (WS-C - 1) * 3
         MOVE SQ-POS(WS-AT + 1) TO B-X(L-COUNT)
         MOVE SQ-POS(WS-AT + 2) TO B-Y(L-COUNT)
         MOVE SQ-POS(WS-AT + 3) TO B-Z(L-COUNT)
         MOVE SQ-U0 TO B-U(L-COUNT)
         IF WS-C = 3 OR WS-C = 4
             MOVE SQ-U1 TO B-U(L-COUNT)
         END-IF
         MOVE SQ-V0 TO B-V(L-COUNT)
         IF WS-C = 2 OR WS-C = 3
             MOVE SQ-V1 TO B-V(L-COUNT)
         END-IF
         MOVE SQ-BRIGHT TO B-B(L-COUNT)
         MOVE 1 TO B-A(L-COUNT)
         MOVE SQ-SKY TO B-SKY(L-COUNT)
         MOVE SQ-RED TO B-R(L-COUNT)
         MOVE SQ-GREEN TO B-G(L-COUNT)
         MOVE SQ-BLUE TO B-BLUE(L-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM SGR-QUAD-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-RUN.
*> USING CLIENT-STATE, pose (SGR-POSE, origin eye-relative), text (UTF-8, any size), length (the piece), pen x, pen y (font pixels), SGR-PAINT, vertex area, count,
*> capacity: one glyph quad (two for a bold one, 6.5) for every character but the space, from the pen, the pen advancing by the glyph's advance (+1 bold). The
*> glyph box is the font height square of the cell (8 x 8); the texture rectangle is the cell inset by 0.01 texel (5.5). An obfuscated character is drawn as another
*> glyph of the same advance (SGR-OBFUSCATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SGRQUAD.
 01 WS-POS                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADV                 BINARY-LONG.
 01 WS-ADV2                BINARY-LONG.
 01 WS-PEN                 BINARY-LONG.
 01 WS-BW                  BINARY-LONG.
 01 WS-BH                  BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-COPIES              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CORNERS.
    05 WS-C                FLOAT-LONG OCCURS 8 TIMES.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-KEEP                FLOAT-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-TINT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-POSE.
    05 L-OX                FLOAT-LONG.
    05 L-OY                FLOAT-LONG.
    05 L-OZ                FLOAT-LONG.
    05 L-AXX               FLOAT-LONG.
    05 L-AXZ               FLOAT-LONG.
    05 L-AZX               FLOAT-LONG.
    05 L-AZZ               FLOAT-LONG.
    05 L-SCALE             FLOAT-LONG.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 COPY SGRPAINT.
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-POSE L-TEXT L-LENGTH L-X L-Y SGR-PAINT L-AREA L-COUNT L-CAPACITY.
     MOVE L-X TO WS-PEN
     COMPUTE WS-KEEP = 1 - SP-BIAS
     COMPUTE WS-TINT = SP-RGB / 65536
     COMPUTE SQ-RED = WS-TINT / 255
     COMPUTE WS-TINT = SP-RGB / 256
     COMPUTE WS-TINT = FUNCTION MOD(WS-TINT, 256)
     COMPUTE SQ-GREEN = WS-TINT / 255
     COMPUTE WS-TINT = FUNCTION MOD(SP-RGB, 256)
     COMPUTE SQ-BLUE = WS-TINT / 255
     MOVE SP-BRIGHT TO SQ-BRIGHT
     MOVE SP-SKY TO SQ-SKY
     MOVE FN-HEIGHT TO WS-BH
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-LENGTH
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         MOVE WS-CP TO WS-DRAW
         IF SP-OBF = 1
             CALL "SGR-OBFUSCATE" USING CLIENT-STATE WS-CP WS-DRAW
         END-IF
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
         IF WS-CP NOT = 32
             CALL "FONT-GLYPH" USING CLIENT-STATE WS-DRAW WS-GX WS-GY WS-GW WS-GH WS-ADV2
             COMPUTE WS-BW = FN-HEIGHT * WS-GW / WS-GH
             COMPUTE SQ-U0 = (WS-GX + 0.01) / UA-W
             COMPUTE SQ-V0 = (WS-GY + 0.01) / UA-H
             COMPUTE SQ-U1 = (WS-GX + WS-GW - 0.01) / UA-W
             COMPUTE SQ-V1 = (WS-GY + WS-GH - 0.01) / UA-H
             MOVE 1 TO WS-COPIES
             IF SP-BOLD = 1
                 MOVE 2 TO WS-COPIES
             END-IF
             PERFORM VARYING WS-COPY FROM 1 BY 1 UNTIL WS-COPY > WS-COPIES
                 CALL "SGR-GLYPH-CORNERS" USING WS-PEN L-Y WS-BW WS-BH SP-BOLD SP-ITALIC WS-COPY WS-CORNERS WS-Z
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     MOVE WS-C(WS-K * 2 - 1) TO WS-FX
                     MOVE WS-C(WS-K * 2) TO WS-FY
                     COMPUTE WS-AT = (WS-K - 1) * 3
                     COMPUTE SQ-POS(WS-AT + 1) = (L-OX + WS-FX * L-AXX + WS-Z * L-AZX) * WS-KEEP
                     COMPUTE SQ-POS(WS-AT + 2) = (L-OY - WS-FY * L-SCALE) * WS-KEEP
                     COMPUTE SQ-POS(WS-AT + 3) = (L-OZ + WS-FX * L-AXZ + WS-Z * L-AZZ) * WS-KEEP
                 END-PERFORM
                 CALL "SGR-QUAD-ADD" USING L-AREA L-COUNT L-CAPACITY SGR-QUAD
             END-PERFORM
         END-IF
         ADD WS-ADV TO WS-PEN
         IF SP-BOLD = 1
             ADD 1 TO WS-PEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SGR-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG), vertex area, capacity, count out: the glyph quads of the signs near the eye (squared distance from the eye to the block centre
*> below 64 * 64, 2.3), eye-relative. A row whose cell holds no sign (the block changed, the chunk went) is skipped, a side with no text draws nothing. Non-glowing text is
*> lit by the light of the sign's own cell, glowing text by 15 and 15 (6.2). The outline of coloured glowing text needs the player's feet within 16 blocks of the block (6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SGRPAINT.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-SCOPING             BINARY-LONG VALUE 0.
 01 WS-SIDE                BINARY-LONG.
 01 WS-TEXTS               BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-OUTLINE             BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-OUTLINE-BIAS        FLOAT-LONG VALUE 0.0002.
 01 WS-POSE.
    05 WS-OX               FLOAT-LONG.
    05 WS-OY               FLOAT-LONG.
    05 WS-OZ               FLOAT-LONG.
    05 WS-AXX              FLOAT-LONG.
    05 WS-AXZ              FLOAT-LONG.
    05 WS-AZX              FLOAT-LONG.
    05 WS-AZZ              FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-AREA L-CAPACITY L-COUNT.
     MOVE 0 TO L-COUNT SP-BOLD SP-ITALIC SP-OBF
     MOVE 0.0004 TO SP-BIAS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF SN-USED(WS-I) = 1
             COMPUTE WS-DX = SN-X(WS-I) + 0.5 - L-EYE(1)
             COMPUTE WS-DY = SN-Y(WS-I) + 0.5 - L-EYE(2)
             COMPUTE WS-DZ = SN-Z(WS-I) + 0.5 - L-EYE(3)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             MOVE 0 TO WS-KIND
             IF WS-D2 < 4096
                 CALL "WORLD-CELL" USING CLIENT-STATE SN-X(WS-I) SN-Y(WS-I) SN-Z(WS-I) WS-STATE WS-SKY WS-BLOCK
                 CALL "SGR-KIND" USING CLIENT-STATE WS-STATE WS-KIND WS-KEY
             END-IF
             IF WS-KIND > 0
                 CALL "SGR-OUTLINE-NEAR" USING PL-X PL-Y PL-Z SN-X(WS-I) SN-Y(WS-I) SN-Z(WS-I) WS-SCOPING WS-NEAR
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 2
*>                   SN-SIDE(1) is the back text, SN-SIDE(2) the front text.
                     MOVE 0 TO WS-TEXTS
                     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 4
                         ADD SN-LEN(WS-I, WS-S, WS-L) TO WS-TEXTS
                     END-PERFORM
                     IF WS-TEXTS > 0
                         COMPUTE WS-SIDE = 3 - WS-S
                         CALL "SGR-POSE" USING WS-KIND WS-KEY WS-SIDE WS-POSE
                         COMPUTE WS-OX = WS-OX + SN-X(WS-I) - L-EYE(1)
                         COMPUTE WS-OY = WS-OY + SN-Y(WS-I) - L-EYE(2)
                         COMPUTE WS-OZ = WS-OZ + SN-Z(WS-I) - L-EYE(3)
                         CALL "SGR-COLOR" USING SN-COLOR(WS-I, WS-S) SN-GLOW(WS-I, WS-S) WS-NEAR WS-FILL WS-OUTLINE WS-FULL
                         MOVE WS-FILL TO SP-RGB
                         COMPUTE SP-BRIGHT = FUNCTION MAX(WS-BLOCK / 15, 0.1)
                         COMPUTE SP-SKY = WS-SKY / 15
                         IF WS-FULL = 1
                             MOVE 1 TO SP-BRIGHT SP-SKY
                         END-IF
                         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 4
                             CALL "SGR-LAYOUT" USING CLIENT-STATE WS-KIND WS-L SN-TEXT(WS-I, WS-S, WS-L)
                                 SN-LEN(WS-I, WS-S, WS-L) WS-X WS-Y WS-PIECE WS-WIDTH
                             IF WS-PIECE > 0
                                 CALL "SGR-LINE-DRAW" USING CLIENT-STATE WS-POSE SN-TEXT(WS-I, WS-S, WS-L) WS-PIECE
                                     WS-X WS-Y SGR-PAINT WS-OUTLINE WS-OUTLINE-BIAS L-AREA L-COUNT L-CAPACITY
                             END-IF
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SGR-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-LINE-DRAW.
*> USING CLIENT-STATE, pose, text, length (the piece), pen x, pen y, SGR-PAINT (the fill), outline colour (RGB integer; -1 none), outline pull (as SP-BIAS), vertex area,
*> count, capacity: 6.4, with an outline the whole line is first drawn eight times at the offsets (dx, dy) of -1, 0, +1 except (0, 0), dx = -1 first (dy -1, 0, +1), then
*> dx = 0 (dy -1, +1), then dx = +1, in the outline colour; the fill pass comes last.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SGRPAINT REPLACING ==SGR-PAINT== BY ==WS-OUTLINE-PAINT== LEADING ==SP-== BY ==XP-==.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-POSE.
    05 L-OX                FLOAT-LONG.
    05 L-OY                FLOAT-LONG.
    05 L-OZ                FLOAT-LONG.
    05 L-AXX               FLOAT-LONG.
    05 L-AXZ               FLOAT-LONG.
    05 L-AZX               FLOAT-LONG.
    05 L-AZZ               FLOAT-LONG.
    05 L-SCALE             FLOAT-LONG.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 COPY SGRPAINT.
 01 L-OUTLINE              BINARY-LONG.
 01 L-OUTLINE-BIAS         FLOAT-LONG.
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-CAPACITY             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-POSE L-TEXT L-LENGTH L-X L-Y SGR-PAINT L-OUTLINE L-OUTLINE-BIAS
         L-AREA L-COUNT L-CAPACITY.
     IF L-OUTLINE >= 0
         MOVE L-OUTLINE TO XP-RGB
         MOVE L-OUTLINE-BIAS TO XP-BIAS
         MOVE SP-BRIGHT TO XP-BRIGHT
         MOVE SP-SKY TO XP-SKY
         MOVE SP-BOLD TO XP-BOLD
         MOVE SP-ITALIC TO XP-ITALIC
         MOVE SP-OBF TO XP-OBF
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                 IF WS-DX NOT = 0 OR WS-DY NOT = 0
                     COMPUTE WS-X = L-X + WS-DX
                     COMPUTE WS-Y = L-Y + WS-DY
                     CALL "SGR-RUN" USING CLIENT-STATE L-POSE L-TEXT L-LENGTH WS-X WS-Y WS-OUTLINE-PAINT
                         L-AREA L-COUNT L-CAPACITY
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     CALL "SGR-RUN" USING CLIENT-STATE L-POSE L-TEXT L-LENGTH L-X L-Y SGR-PAINT L-AREA L-COUNT L-CAPACITY
     GOBACK.
 END PROGRAM SGR-LINE-DRAW.
