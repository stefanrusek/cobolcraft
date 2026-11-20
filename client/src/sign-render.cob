*> Sign text rendering, the arithmetic (docs/protocol/52-block-entity-models-2-signs.md): SGR-POSE is the text plane transform of section 4 for the four
*> sign families, SGR-COLOR the colour rules of section 6.1 to 6.3, SGR-OUTLINE-NEAR the outline distance rule of 6.3, SGR-GLYPH-CORNERS the quad of one
*> glyph with the bold and italic changes of 6.5, SGR-OBFUSCATE the glyph an obfuscated character is replaced by. Layout is sign-layout.cob, the mesh sign-mesh.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-POSE.
*> USING kind (1 standing sign, 2 wall sign, 3 ceiling hanging sign, 4 wall hanging sign), key (the rotation 0 to 15 of kinds 1 and 3; the facing 0 south,
*> 1 west, 2 north, 3 east of kinds 2 and 4), side (1 front, 2 back), pose out. 4.1: the matrix T1 . R(-angle) . T3 . [R(180) back] . T5 . S(s, -s, s) is
*> applied to a font point (fx, fy, fz) as block position = origin + fx * axis x + fy * axis y + fz * axis z: the pose holds the origin (block space),
*> the x axis (x and z components; y has none), the z axis (the normal of the drawn side, x and z components), the scale s (axis y is (0, -s, 0)).
*> The angle of 4.3: 22.5 degrees a rotation step (a value of 180 or more is the same turn minus 360), 90 degrees a facing step (south 0, west 90, north 180,
*> east 270).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-T1Y                 FLOAT-LONG.
 01 WS-T3Y                 FLOAT-LONG.
 01 WS-T3Z                 FLOAT-LONG.
 01 WS-T5Y                 FLOAT-LONG.
 01 WS-T5Z                 FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-ZL                  FLOAT-LONG.
 01 WS-SGN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-POSE.
    05 L-OX                FLOAT-LONG.
    05 L-OY                FLOAT-LONG.
    05 L-OZ                FLOAT-LONG.
    05 L-AXX               FLOAT-LONG.
    05 L-AXZ               FLOAT-LONG.
    05 L-AZX               FLOAT-LONG.
    05 L-AZZ               FLOAT-LONG.
    05 L-SCALE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-KEY L-SIDE L-POSE.
     MOVE 0 TO WS-T3Y WS-T3Z
     EVALUATE L-KIND
         WHEN 1
             MOVE 0.010416667 TO WS-S
             MOVE 0.5 TO WS-T1Y
             MOVE 0.33333334 TO WS-T5Y
             MOVE 0.046666667 TO WS-T5Z
             COMPUTE WS-ANGLE = L-KEY * 22.5
         WHEN 2
             MOVE 0.010416667 TO WS-S
             MOVE 0.5 TO WS-T1Y
             MOVE -0.3125 TO WS-T3Y
             MOVE -0.4375 TO WS-T3Z
             MOVE 0.33333334 TO WS-T5Y
             MOVE 0.046666667 TO WS-T5Z
             COMPUTE WS-ANGLE = L-KEY * 90
         WHEN 3
             MOVE 0.0140625 TO WS-S
             MOVE 0.9375 TO WS-T1Y
             MOVE -0.3125 TO WS-T3Y
             MOVE -0.32 TO WS-T5Y
             MOVE 0.073 TO WS-T5Z
             COMPUTE WS-ANGLE = L-KEY * 22.5
         WHEN OTHER
             MOVE 0.0140625 TO WS-S
             MOVE 0.9375 TO WS-T1Y
             MOVE -0.3125 TO WS-T3Y
             MOVE -0.32 TO WS-T5Y
             MOVE 0.073 TO WS-T5Z
             COMPUTE WS-ANGLE = L-KEY * 90
     END-EVALUATE
     COMPUTE WS-A = WS-ANGLE * FUNCTION PI / 180
     COMPUTE WS-SIN = FUNCTION SIN(WS-A)
     COMPUTE WS-COS = FUNCTION COS(WS-A)
*>   The back side turns the text plane half a turn about the vertical axis before the text offset (step 4): x and z of the point change sign, the wall
*>   translation (step 3) is applied after it.
     MOVE 1 TO WS-SGN
     COMPUTE WS-ZL = WS-T5Z + WS-T3Z
     IF L-SIDE = 2
         MOVE -1 TO WS-SGN
         COMPUTE WS-ZL = WS-T3Z - WS-T5Z
     END-IF
     COMPUTE L-OX = 0.5 - WS-ZL * WS-SIN
     COMPUTE L-OY = WS-T1Y + WS-T3Y + WS-T5Y
     COMPUTE L-OZ = 0.5 + WS-ZL * WS-COS
     COMPUTE L-AXX = WS-SGN * WS-S * WS-COS
     COMPUTE L-AXZ = WS-SGN * WS-S * WS-SIN
     COMPUTE L-AZX = 0 - WS-SGN * WS-S * WS-SIN
     COMPUTE L-AZZ = WS-SGN * WS-S * WS-COS
     MOVE WS-S TO L-SCALE
     GOBACK.
 END PROGRAM SGR-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-COLOR.
*> USING dye (0 white .. 15 black, 31-3 section 8), glow (0 or 1), outline near (1 when the outline-visible test of 6.3 holds), fill out, outline out
*> (RGB integers; -1 for no outline pass), full light out (1 for the light 0xF000F0 of 6.2): the fill is the dye's text colour scaled by 0.4 (each channel
*> truncated) and the block's light; glowing text is the unscaled colour at full light, with an outline in the scaled colour when it is black (then the
*> cream 0xF0EBCC) or when the outline is near (6.1, 6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> The text colours of 31-3 section 8 as RRRGGGBBB.
 01 WS-DYES.
    05 FILLER              PIC X(9) VALUE "255255255".
    05 FILLER              PIC X(9) VALUE "255104031".
    05 FILLER              PIC X(9) VALUE "255000255".
    05 FILLER              PIC X(9) VALUE "154192205".
    05 FILLER              PIC X(9) VALUE "255255000".
    05 FILLER              PIC X(9) VALUE "191255000".
    05 FILLER              PIC X(9) VALUE "255105180".
    05 FILLER              PIC X(9) VALUE "128128128".
    05 FILLER              PIC X(9) VALUE "211211211".
    05 FILLER              PIC X(9) VALUE "000255255".
    05 FILLER              PIC X(9) VALUE "160032240".
    05 FILLER              PIC X(9) VALUE "000000255".
    05 FILLER              PIC X(9) VALUE "139069019".
    05 FILLER              PIC X(9) VALUE "000255000".
    05 FILLER              PIC X(9) VALUE "255000000".
    05 FILLER              PIC X(9) VALUE "000000000".
 01 WS-DYE-TABLE REDEFINES WS-DYES.
    05 WS-DYE-ENTRY OCCURS 16 TIMES.
       10 WS-DYE-R         PIC 999.
       10 WS-DYE-G         PIC 999.
       10 WS-DYE-B         PIC 999.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-DR                  BINARY-LONG.
 01 WS-DG                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-CREAM               BINARY-LONG VALUE 15789004.
 LINKAGE SECTION.
 01 L-DYE                  BINARY-LONG.
 01 L-GLOW                 BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 01 L-OUTLINE              BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DYE L-GLOW L-NEAR L-FILL L-OUTLINE L-FULL.
*>   An id outside the 16 is white (31-3 section 8).
     COMPUTE WS-I = L-DYE + 1
     IF WS-I < 1 OR WS-I > 16
         MOVE 1 TO WS-I
     END-IF
     MOVE WS-DYE-R(WS-I) TO WS-R
     MOVE WS-DYE-G(WS-I) TO WS-G
     MOVE WS-DYE-B(WS-I) TO WS-B
     COMPUTE WS-DR = WS-R * 4 / 10
     COMPUTE WS-DG = WS-G * 4 / 10
     COMPUTE WS-DB = WS-B * 4 / 10
     COMPUTE WS-DARK = WS-DR * 65536 + WS-DG * 256 + WS-DB
     MOVE -1 TO L-OUTLINE
     MOVE 0 TO L-FULL
     IF L-GLOW = 1
         MOVE 1 TO L-FULL
         COMPUTE L-FILL = WS-R * 65536 + WS-G * 256 + WS-B
         IF WS-I = 16
             MOVE WS-CREAM TO WS-DARK
             MOVE WS-DARK TO L-OUTLINE
         END-IF
         IF WS-I NOT = 16 AND L-NEAR = 1
             MOVE WS-DARK TO L-OUTLINE
         END-IF
     ELSE
         MOVE WS-DARK TO L-FILL
     END-IF
     GOBACK.
 END PROGRAM SGR-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-OUTLINE-NEAR.
*> USING feet x, y, z (FLOAT-LONG, the camera entity's feet position), block x, y, z, scoping (1 when the player looks through a spyglass), near out: 6.3,
*> the squared distance from the feet to the block centre is strictly below 16 * 16 = 256, or the player is scoping.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-SCOPING              BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FX L-FY L-FZ L-BX L-BY L-BZ L-SCOPING L-NEAR.
     COMPUTE WS-DX = L-FX - (L-BX + 0.5)
     COMPUTE WS-DY = L-FY - (L-BY + 0.5)
     COMPUTE WS-DZ = L-FZ - (L-BZ + 0.5)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     MOVE 0 TO L-NEAR
     IF L-SCOPING = 1 OR WS-D2 < 256
         MOVE 1 TO L-NEAR
     END-IF
     GOBACK.
 END PROGRAM SGR-OUTLINE-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-GLYPH-CORNERS.
*> USING pen x, pen y (font pixels), width, height of the glyph box (8 x 8 for the default font), bold (0 or 1), italic (0 or 1), copy (1 the glyph, 2 the
*> second copy of a bold glyph), corners out (8 FLOAT-LONG: x, y of top left, bottom left, bottom right, top right), z out (font pixels toward the
*> viewer): 5.5 and 6.5. A plain glyph's quad is the box from (x, y) to (x + w, y + h). A bold glyph is drawn twice, the second copy one pixel to the right and
*> 0.001 nearer, each quad grown by 0.1 on every side. Italic moves the top edge by 1 - 0.25 * 0 = +1 and the bottom edge by 1 - 0.25 * 8 = -1 (the glyph's top and
*> bottom offsets in its box are 0 and 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-BOTTOM              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BOLD                 BINARY-LONG.
 01 L-ITALIC               BINARY-LONG.
 01 L-COPY                 BINARY-LONG.
 01 L-CORNERS.
    05 L-C                 FLOAT-LONG OCCURS 8 TIMES.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-W L-H L-BOLD L-ITALIC L-COPY L-CORNERS L-Z.
     MOVE L-X TO WS-X0
     COMPUTE WS-X1 = L-X + L-W
     MOVE L-Y TO WS-Y0
     COMPUTE WS-Y1 = L-Y + L-H
     MOVE 0 TO L-Z
     IF L-BOLD = 1
         COMPUTE WS-X0 = WS-X0 - 0.1
         COMPUTE WS-Y0 = WS-Y0 - 0.1
         COMPUTE WS-X1 = WS-X1 + 0.1
         COMPUTE WS-Y1 = WS-Y1 + 0.1
         IF L-COPY = 2
             COMPUTE WS-X0 = WS-X0 + 1
             COMPUTE WS-X1 = WS-X1 + 1
             MOVE 0.001 TO L-Z
         END-IF
     END-IF
     MOVE 0 TO WS-TOP WS-BOTTOM
     IF L-ITALIC = 1
         MOVE 1 TO WS-TOP
         MOVE -1 TO WS-BOTTOM
     END-IF
     COMPUTE L-C(1) = WS-X0 + WS-TOP
     MOVE WS-Y0 TO L-C(2)
     COMPUTE L-C(3) = WS-X0 + WS-BOTTOM
     MOVE WS-Y1 TO L-C(4)
     COMPUTE L-C(5) = WS-X1 + WS-BOTTOM
     MOVE WS-Y1 TO L-C(6)
     COMPUTE L-C(7) = WS-X1 + WS-TOP
     MOVE WS-Y0 TO L-C(8)
     GOBACK.
 END PROGRAM SGR-GLYPH-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-OBFUSCATE.
*> USING CLIENT-STATE, code point, replacement out: 6.5, an obfuscated character is replaced (each time it is drawn) by a code point of the font whose advance
*> equals the real one, picked uniformly (a generator of its own, advanced by every call); the space is not replaced, and a code point none else
*> shares an advance with stays itself. The candidates are the glyphs 33 to 126.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260101.
 01 WS-QUOT                BINARY-DOUBLE UNSIGNED.
 01 WS-WORK                BINARY-DOUBLE UNSIGNED.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ADV                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-PICK-Q              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CP                   BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CP L-OUT.
     MOVE L-CP TO L-OUT
     IF L-CP = 32
         GOBACK
     END-IF
     CALL "FONT-GLYPH" USING CLIENT-STATE L-CP WS-GX WS-GY WS-GW WS-GH WS-WANT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-CP FROM 33 BY 1 UNTIL WS-CP > 126
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
         IF WS-ADV = WS-WANT
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     COMPUTE WS-WORK = WS-SEED * 1103515245 + 12345
     DIVIDE WS-WORK BY 2147483648 GIVING WS-QUOT REMAINDER WS-SEED
     IF WS-COUNT > 0
         DIVIDE WS-SEED BY 65536 GIVING WS-PICK-Q
         DIVIDE WS-PICK-Q BY WS-COUNT GIVING WS-PICK-Q REMAINDER WS-PICK
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-CP FROM 33 BY 1 UNTIL WS-CP > 126
             CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
             IF WS-ADV = WS-WANT
                 IF WS-COUNT = WS-PICK
                     MOVE WS-CP TO L-OUT
                 END-IF
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SGR-OBFUSCATE.
