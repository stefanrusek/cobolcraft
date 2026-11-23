*> The item a mob holds, posed as ItemInHandLayer places it (34-1 section 8.3, 34-3 section 4 ItemInHandLayer; the display transform of 12 section 8.2). ENTITY-HELD-POSED puts the item
*> in the frame of the arm part (the origin at its pivot, the three axes a block long, found when the mob was drawn: ENTITY-HAND-FRAME, EN-HAND-F): rotate X by -90 degrees and Y by 180,
*> translate (s 1, 2, -10) / 16 for an adult or (0, 1, -4.5) / 16 for a baby (s = +1 right arm, -1 left), then the model's display transform for thirdperson_righthand or
*> thirdperson_lefthand (translate by the translation / 16, rotate X, Y and Z, scale, translate (-0.5, -0.5, -0.5)); the left arm with no left entry takes the right one mirrored (12 section 8.2:
*> translation x, rotation y and z negated). An item whose model names no entry takes the default of item/generated (translation (0, 3, 1), scale 0.55) or, for a block, of block/block
*> (rotation (75, 45, 0), translation (0, 2.5, 0), scale 0.375). A block item is the unit cube (a face to a sprite of its model), any other item its icon as a flat quad front and back at
*> z 17/32 and 15/32, the pose that HAND-BUILD gives the first-person item (without its extruded edges). Quads go to RL-GI-VERTEX (HAND-QUAD mode 4), lit by the light of the mob's cell.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-HELD-POSED.
*> USING CLIENT-STATE, replica row, hand (1 right arm, 2 left arm), item registry id, eye (3 FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-BRIGHT              BINARY-LONG VALUE 0.
 01 WS-BDYE                BINARY-LONG.
 01 WS-SHIELD              BINARY-LONG.
 01 WS-HSLOT               BINARY-LONG.
 01 WS-HFOIL               BINARY-LONG.
 01 WS-FLAVOUR             BINARY-LONG.
 01 WS-OPI.
    05 WS-OPIV             FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OPO.
    05 WS-OPOV             FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-HAND L-ITEM L-EYE-TABLE.
*>   The frame of the arm part as the matrix (the axes are its columns) at the mob's place relative to the eye.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         MOVE EN-HAND-F(L-ROW, L-HAND, 3 + WS-A) TO WS-MV((WS-A - 1) * 3 + 1)
         MOVE EN-HAND-F(L-ROW, L-HAND, 6 + WS-A) TO WS-MV((WS-A - 1) * 3 + 2)
         MOVE EN-HAND-F(L-ROW, L-HAND, 9 + WS-A) TO WS-MV((WS-A - 1) * 3 + 3)
     END-PERFORM
     COMPUTE WS-MV(10) = EN-HAND-F(L-ROW, L-HAND, 1) + EN-X(L-ROW) - L-EYE(1)
     COMPUTE WS-MV(11) = EN-HAND-F(L-ROW, L-HAND, 2) + EN-Y(L-ROW) - L-EYE(2)
     COMPUTE WS-MV(12) = EN-HAND-F(L-ROW, L-HAND, 3) + EN-Z(L-ROW) - L-EYE(3)
     MOVE 1 TO WS-SIDE
     IF L-HAND = 2
         MOVE -1 TO WS-SIDE
     END-IF
*>   A copper golem's translateToHand (34-3 9.3): after the arm part, the state IDLE turns the arm's frame by -90 (right) or +90 (left) about Y and moves it (0, 0, 0.125); any other
*>   state scales it by 0.55 and moves it (-0.125, 0.3125, -0.1875).
     IF EN-KEY(L-ROW) = "copper_golem"
         MOVE WS-SIDE TO WS-OPIV(1)
         MOVE 0 TO WS-OPIV(2)
         IF EN-X1(L-ROW) = 0
             MOVE 1 TO WS-OPIV(2)
         END-IF
         CALL "EM3-COPPER-HAND-OPS" USING WS-OPI WS-OPO
         MOVE 0 TO WS-FLAVOUR
         CALL "ENTITY-OPS-MATRIX" USING WS-M WS-OPO WS-FLAVOUR
     END-IF
*>   rotate X by -90, Y by 180, then translate: an adult (+-1, 2, -10) / 16, a baby (0, 1, -4.5) / 16.
     MOVE 1 TO WS-AXIS
     MOVE -90 TO WS-DEG
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 2 TO WS-AXIS
     MOVE 180 TO WS-DEG
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     IF EN-BABY(L-ROW) = 1
         MOVE 0 TO WS-AX
         COMPUTE WS-AY = 1 / 16
         COMPUTE WS-AZ = -4.5 / 16
     ELSE
         COMPUTE WS-AX = WS-SIDE / 16
         COMPUTE WS-AY = 2 / 16
         COMPUTE WS-AZ = -10 / 16
     END-IF
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE L-ITEM WS-BDYE
     IF WS-BDYE >= 0
         CALL "ENTITY-BANNER-HELD" USING CLIENT-STATE WS-M L-ROW L-HAND WS-BDYE L-EYE-TABLE
         GOBACK
     END-IF
     CALL "SHIELD-ITEM" USING CLIENT-STATE L-ITEM WS-SHIELD
     IF WS-SHIELD = 1
         CALL "ENTITY-SHIELD-HELD" USING CLIENT-STATE WS-M L-ROW L-HAND L-EYE-TABLE
         GOBACK
     END-IF
*>   The stack's glint (54 section 19.3): the main hand is the right arm's, a left-handed mob (mob flags bit 2) holds it in the left.
     MOVE L-HAND TO WS-HSLOT
     IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(L-ROW) / 2), 2) = 1
         COMPUTE WS-HSLOT = 3 - L-HAND
     END-IF
     MOVE EN-EQ-FOIL(L-ROW, WS-HSLOT) TO WS-HFOIL
     CALL "ITEM-POSED-DRAW" USING CLIENT-STATE WS-M L-ITEM L-HAND L-ROW L-EYE-TABLE WS-BRIGHT WS-HFOIL
     GOBACK.
 END PROGRAM ENTITY-HELD-POSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BANNER-HELD.
*> USING CLIENT-STATE, placement (12 FLOAT-LONG: the arm's frame turned and translated as for any held item), replica row, hand (1 right arm, 2 left arm), dye of the banner's colour, eye (3 FLOAT-LONG):
*> a banner in a mob's hand (52 section 6.7): the display of template_banner for thirdperson_righthand (translation (0, 2, 0.5) / 16, rotation (0, 90, 0), scale 0.375; the left hand takes it
*> mirrored: rotation y negated), the recentring, then BANNER-DRAW into the entity mesh (the entity atlas holds the sprites; the entity pass draws it, ENTITIES-MESH) with the layers of the stack in the hand (EN-HB of the main hand's slot, the off hand's: the main
*> hand is the left arm of a left-handed mob), lit by the light of the mob's cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 5.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-BANNER.
    05 WS-COUNT            BINARY-LONG.
    05 WS-PAT              BINARY-LONG OCCURS 16 TIMES.
    05 WS-DYES             BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-ROW L-HAND L-DYE L-EYE-TABLE.
     MOVE L-M TO WS-M
     MOVE 0 TO WS-AX
     COMPUTE WS-AY = 2 / 16
     COMPUTE WS-AZ = 0.5 / 16
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE 2 TO WS-AXIS
     MOVE 90 TO WS-DEG
     IF L-HAND = 2
         MOVE -90 TO WS-DEG
     END-IF
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 0.375 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-SCALE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE -0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
*>   The hand's stack: the main hand is the right arm unless the mob is left-handed (mob flags bit 2).
     MOVE L-HAND TO WS-SLOT
     IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(L-ROW) / 2), 2) = 1
         COMPUTE WS-SLOT = 3 - L-HAND
     END-IF
     MOVE EN-HB-COUNT(L-ROW, WS-SLOT) TO WS-COUNT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
         MOVE EN-HB-PAT(L-ROW, WS-SLOT, WS-N) TO WS-PAT(WS-N)
         MOVE EN-HB-DYE(L-ROW, WS-SLOT, WS-N) TO WS-DYES(WS-N)
     END-PERFORM
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
     CALL "BANNER-DRAW" USING CLIENT-STATE WS-M WS-BANNER L-DYE WS-LIGHT WS-MODE
     GOBACK.
 END PROGRAM ENTITY-BANNER-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ICON-GLINT-QUADS.
*> USING CLIENT-STATE, placement (12 FLOAT-LONG: the 3 x 3 matrix by rows, then the translation, as HAND-QUAD takes it; the icon's unit square is x and y from 0 to 1, y up, at z 17/32 and 15/32 of the model),
*> sprite (atlas row of the item icon): the glint layer of a flat item icon (54 section 19.3, T9903) in RL-WG-VERTEX (HAND-QUAD glint 6): one quad of each opaque texel (alpha above 0) on the front and on the back,
*> its glint coordinates those of the texel's corners. Shared by the item a mob holds, the framed item (ITEM-POSED-DRAW) and the dropped item (VANILLA-ITEMS-MESH).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CORNER-DATA.
    05 FILLER PIC X(12) VALUE "011111101001".
    05 FILLER PIC X(12) VALUE "110010000100".
 01 WS-CORNER-TABLE REDEFINES WS-CORNER-DATA.
    05 WS-FACE OCCURS 2 TIMES.
       10 WS-PICK            PIC 9 OCCURS 12 TIMES.
 01 WS-GMODE               BINARY-LONG VALUE 6.
 01 WS-LIGHT               FLOAT-LONG VALUE 1.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-GN                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-OPAQUE              PIC 9 OCCURS 1024 TIMES.
 01 WS-CELL                FLOAT-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-UV.
    05 WS-U16              FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-V16              FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-TEXEL.
    05 WS-TU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-TV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NOQ.
    05 WS-NOQV              FLOAT-LONG OCCURS 9 TIMES VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-SPRITE.
     MOVE AT-SW(L-SPRITE) TO WS-GN
     IF WS-GN > 32
         MOVE 32 TO WS-GN
     END-IF
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     COMPUTE WS-CELL = 1 / WS-GN
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-GN
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-GN
             COMPUTE WS-OFF = ((AT-Y(L-SPRITE) + WS-PY) * AT-W + AT-X(L-SPRITE) + WS-PX) * 4 + 4
             MOVE 0 TO WS-OPAQUE(WS-PY * WS-GN + WS-PX + 1)
             IF FUNCTION ORD(B-ATLAS(WS-OFF:1)) > 1
                 MOVE 1 TO WS-OPAQUE(WS-PY * WS-GN + WS-PX + 1)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-NV(1) WS-NV(2)
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 2
         COMPUTE WS-NV(3) = 3 - 2 * WS-F
         PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-GN
             PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-GN
                 IF WS-OPAQUE(WS-PY * WS-GN + WS-PX + 1) = 1
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-CP((WS-K - 1) * 3 + 1) = (WS-PX + WS-PICK(WS-F, (WS-K - 1) * 3 + 1)) * WS-CELL
                         COMPUTE WS-CP((WS-K - 1) * 3 + 2) = 1 - (WS-PY + 1 - WS-PICK(WS-F, (WS-K - 1) * 3 + 2)) * WS-CELL
                         COMPUTE WS-CP((WS-K - 1) * 3 + 3) = (19 - 2 * WS-F) / 32
                         COMPUTE WS-U16(WS-K) = (WS-PX + FUNCTION MOD(FUNCTION INTEGER(WS-K / 2), 2)) * 16 / WS-GN
                         COMPUTE WS-V16(WS-K) = (WS-PY + FUNCTION INTEGER(WS-K / 3)) * 16 / WS-GN
                         CALL "ATLAS-UV" USING CLIENT-STATE L-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
                     END-PERFORM
                     CALL "HAND-QUAD" USING CLIENT-STATE L-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GMODE WS-NOQ
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ICON-GLINT-QUADS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GROUND-GLINT.
*> USING CLIENT-STATE, corners (four of x, y, z, u, v FLOAT-SHORT: a quad of a dropped item as it is drawn, top-left, top-right, bottom-right, bottom-left, relative to the eye, with its atlas
*> coordinates), sprite (the icon's atlas row), flat (1 the quad is the item's flat icon: ICON-GLINT-QUADS over its opaque texels, the quad's parallelogram as the placement; 0 one face of a cube:
*> the same corners and coordinates in the glint layer, HAND-QUAD glint 6): the glint layer of a dropped item with the enchantment glint (54 section 19.3, T9903).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GMODE               BINARY-LONG VALUE 6.
 01 WS-LIGHT               FLOAT-LONG VALUE 1.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-TEXEL.
    05 WS-TU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-TV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-NOQ.
    05 WS-NOQV             FLOAT-LONG OCCURS 9 TIMES VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CORNERS.
    05 L-C OCCURS 4 TIMES.
       10 L-CX             FLOAT-SHORT.
       10 L-CY             FLOAT-SHORT.
       10 L-CZ             FLOAT-SHORT.
       10 L-CU             FLOAT-SHORT.
       10 L-CV             FLOAT-SHORT.
 01 L-SPRITE               BINARY-LONG.
 01 L-FLAT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CORNERS L-SPRITE L-FLAT.
     IF L-FLAT = 1
*>       The icon's unit square (x right, y up) maps to the quad: its bottom-left corner 4 is the origin, the right edge 3 - 4 and the up edge 1 - 4 the columns of the matrix.
         MOVE 0 TO WS-MV(3) WS-MV(6) WS-MV(9)
         COMPUTE WS-MV(1) = L-CX(3) - L-CX(4)
         COMPUTE WS-MV(4) = L-CY(3) - L-CY(4)
         COMPUTE WS-MV(7) = L-CZ(3) - L-CZ(4)
         COMPUTE WS-MV(2) = L-CX(1) - L-CX(4)
         COMPUTE WS-MV(5) = L-CY(1) - L-CY(4)
         COMPUTE WS-MV(8) = L-CZ(1) - L-CZ(4)
         MOVE L-CX(4) TO WS-MV(10)
         MOVE L-CY(4) TO WS-MV(11)
         MOVE L-CZ(4) TO WS-MV(12)
         CALL "ICON-GLINT-QUADS" USING CLIENT-STATE WS-M L-SPRITE
         GOBACK
     END-IF
     MOVE 0 TO WS-MV(2) WS-MV(3) WS-MV(4) WS-MV(6) WS-MV(7) WS-MV(8) WS-MV(10) WS-MV(11) WS-MV(12)
     MOVE 1 TO WS-MV(1) WS-MV(5) WS-MV(9)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-R = (WS-K - 1) * 3
         MOVE L-CX(WS-K) TO WS-CP(WS-R + 1)
         MOVE L-CY(WS-K) TO WS-CP(WS-R + 2)
         MOVE L-CZ(WS-K) TO WS-CP(WS-R + 3)
         MOVE L-CU(WS-K) TO WS-TU(WS-K)
         MOVE L-CV(WS-K) TO WS-TV(WS-K)
     END-PERFORM
     CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GMODE WS-NOQ
     GOBACK.
 END PROGRAM GROUND-GLINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-POSED-DRAW.
*> USING CLIENT-STATE, placement (12 FLOAT-LONG: the columns of the 3 x 3 matrix, then the translation, relative to the eye), item registry id, display context (1 thirdperson_righthand,
*> 2 thirdperson_lefthand, 3 fixed), replica row whose cell gives the light, eye (3 FLOAT-LONG), bright (BINARY-LONG, 1 for full bright), foil (BINARY-LONG, 1 when the stack has the
*> glint: the same quads are added to the glint mesh RL-WG-VERTEX, a cube's six faces, a flat icon one quad of each opaque texel on the front and the back: 54 section 19.3, T9903): draws the item at the placement with its display
*> transform of the context (as above for the hands; the fixed context of an item frame without an entry: item/generated rotates (0, 180, 0), block/block scales 0.5, 12 section 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-CORNER-DATA.
    05 FILLER PIC X(12) VALUE "011111101001".
    05 FILLER PIC X(12) VALUE "110010000100".
    05 FILLER PIC X(12) VALUE "111110100101".
    05 FILLER PIC X(12) VALUE "010011001000".
    05 FILLER PIC X(12) VALUE "010110111011".
    05 FILLER PIC X(12) VALUE "100000001101".
 01 WS-CORNER-TABLE REDEFINES WS-CORNER-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-PICK            PIC 9 OCCURS 12 TIMES.
 01 WS-NORMALS.
    05 WS-NRM OCCURS 6 TIMES.
       10 WS-NRM-V           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR-DATA            PIC X(6) VALUE "436521".
 01 WS-DIR-TABLE REDEFINES WS-DIR-DATA.
    05 WS-FACE-DIR         PIC 9 OCCURS 6 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-HAVE                BINARY-LONG.
 01 WS-CONTEXT             BINARY-LONG.
 01 WS-SIDE                FLOAT-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-STD                 BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-FACE-SPR            BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 4.
 01 WS-GMODE               BINARY-LONG VALUE 6.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-UV.
    05 WS-U16              FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-V16              FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-TEXEL.
    05 WS-TU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-TV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NOQ.
    05 WS-NOQV              FLOAT-LONG OCCURS 9 TIMES VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-ITEM                 BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-BRIGHT               BINARY-LONG.
 01 L-FOIL                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-ITEM L-HAND L-ROW L-EYE-TABLE L-BRIGHT L-FOIL.
     MOVE L-M TO WS-M
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-SPRITE
     MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
*>   A code-drawn (special) model is not drawn from its icon.
     CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE L-ITEM WS-HAVE WS-VAL
     IF WS-HAVE = 2
         GOBACK
     END-IF
*>   A block item is the unit cube when its model has faces (a standard set) or it is a stand-in block; any other item is its icon.
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE L-ITEM WS-BLOCK WS-TOOL WS-FOOD
     MOVE 0 TO WS-STD
     IF CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         MOVE 1 TO WS-STD
     END-IF
     MOVE 0 TO WS-CUBE
     IF WS-BLOCK = 1 AND (WS-STD = 0 OR IS-FACE-DONE(L-ITEM + 1) = 1)
         MOVE 1 TO WS-CUBE
     END-IF
*>   A whole item or none: the icon's two quads or the cube's six need the room.
     IF WS-CUBE = 1
         IF RL-GI-COUNT + 36 > CL-MAX-GI-VERTICES
             GOBACK
         END-IF
     ELSE
         IF RL-GI-COUNT + 12 > CL-MAX-GI-VERTICES
             GOBACK
         END-IF
     END-IF
*>   The display transform: the arm's own entry, else the right entry (mirrored for the left arm), else the default of item/generated or block/block.
     MOVE L-HAND TO WS-CONTEXT
     CALL "ITEM-DISPLAY" USING CLIENT-STATE L-ITEM WS-CONTEXT WS-HAVE WS-VAL
     IF WS-HAVE = 0 AND L-HAND = 2
         MOVE 1 TO WS-CONTEXT
         CALL "ITEM-DISPLAY" USING CLIENT-STATE L-ITEM WS-CONTEXT WS-HAVE WS-VAL
         IF WS-HAVE = 1
             COMPUTE WS-DV(4) = 0 - WS-DV(4)
             COMPUTE WS-DV(2) = 0 - WS-DV(2)
             COMPUTE WS-DV(3) = 0 - WS-DV(3)
         END-IF
     END-IF
     IF WS-HAVE = 0 AND L-HAND = 3
         MOVE 0 TO WS-DV(1) WS-DV(2) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
         MOVE 1 TO WS-DV(7) WS-DV(8) WS-DV(9)
         MOVE 180 TO WS-DV(2)
         IF WS-CUBE = 1
             MOVE 0 TO WS-DV(2)
             MOVE 0.5 TO WS-DV(7) WS-DV(8) WS-DV(9)
         END-IF
         MOVE 1 TO WS-HAVE
     END-IF
     IF WS-HAVE = 0
         MOVE 0 TO WS-DV(1) WS-DV(2) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
         MOVE 0.55 TO WS-DV(7) WS-DV(8) WS-DV(9)
         MOVE 3 TO WS-DV(5)
         MOVE 1 TO WS-DV(6)
         IF WS-CUBE = 1
             MOVE 75 TO WS-DV(1)
             MOVE 45 TO WS-DV(2)
             MOVE 0 TO WS-DV(4) WS-DV(6)
             MOVE 2.5 TO WS-DV(5)
             MOVE 0.375 TO WS-DV(7) WS-DV(8) WS-DV(9)
             IF L-HAND = 2
                 MOVE -45 TO WS-DV(2)
             END-IF
         END-IF
     END-IF
     COMPUTE WS-AX = WS-DV(4) / 16
     COMPUTE WS-AY = WS-DV(5) / 16
     COMPUTE WS-AZ = WS-DV(6) / 16
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
         MOVE WS-DV(WS-AXIS) TO WS-DEG
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     END-PERFORM
     MOVE WS-DV(7) TO WS-AX
     MOVE WS-DV(8) TO WS-AY
     MOVE WS-DV(9) TO WS-AZ
     CALL "HAND-M-SCALE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE -0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
*>   The light of the mob's cell.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
     IF L-BRIGHT = 1
         MOVE 1 TO WS-LIGHT
     END-IF
*>   The geometry in the model's unit cube (the faces of HAND-BUILD's tables): corner texels of the icon top-left, top-right, bottom-right, bottom-left.
     MOVE 0 TO WS-NRM-V(1, 1) WS-NRM-V(1, 2) WS-NRM-V(2, 1) WS-NRM-V(2, 2) WS-NRM-V(3, 2) WS-NRM-V(3, 3)
         WS-NRM-V(4, 2) WS-NRM-V(4, 3) WS-NRM-V(5, 1) WS-NRM-V(5, 3) WS-NRM-V(6, 1) WS-NRM-V(6, 3)
     MOVE 1 TO WS-NRM-V(1, 3) WS-NRM-V(3, 1) WS-NRM-V(5, 2)
     MOVE -1 TO WS-NRM-V(2, 3) WS-NRM-V(4, 1) WS-NRM-V(6, 2)
     MOVE 0 TO WS-U16(1) WS-V16(1) WS-V16(2) WS-U16(4)
     MOVE 16 TO WS-U16(2) WS-U16(3) WS-V16(3) WS-V16(4)
     IF WS-CUBE = 1
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
             MOVE WS-SPRITE TO WS-FACE-SPR
             IF WS-STD = 1
                 MOVE WS-FACE-DIR(WS-F) TO WS-DIRECTION
                 CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE L-ITEM WS-DIRECTION WS-FACE-SPR
             END-IF
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-FACE-SPR WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     COMPUTE WS-C = (WS-K - 1) * 3 + WS-A
                     MOVE WS-PICK(WS-F, WS-C) TO WS-CP(WS-C)
                 END-PERFORM
             END-PERFORM
             MOVE WS-NRM-V(WS-F, 1) TO WS-NV(1)
             MOVE WS-NRM-V(WS-F, 2) TO WS-NV(2)
             MOVE WS-NRM-V(WS-F, 3) TO WS-NV(3)
             CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-MODE WS-NOQ
             IF L-FOIL = 1
                 CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GMODE WS-NOQ
             END-IF
         END-PERFORM
         GOBACK
     END-IF
*>   The icon: front (z 17/32) and back (z 15/32).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
     END-PERFORM
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 2
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-C = (WS-K - 1) * 3 + WS-A
                 IF WS-A = 3
                     COMPUTE WS-CP(WS-C) = (19 - 2 * WS-F) / 32
                 ELSE
                     MOVE WS-PICK(WS-F, WS-C) TO WS-CP(WS-C)
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE WS-NRM-V(WS-F, 1) TO WS-NV(1)
         MOVE WS-NRM-V(WS-F, 2) TO WS-NV(2)
         MOVE WS-NRM-V(WS-F, 3) TO WS-NV(3)
         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-MODE WS-NOQ
     END-PERFORM
*>   The glint of a foil icon covers the opaque texels only (ICON-GLINT-QUADS).
     IF L-FOIL = 1
         CALL "ICON-GLINT-QUADS" USING CLIENT-STATE WS-M WS-SPRITE
     END-IF
     GOBACK.
 END PROGRAM ITEM-POSED-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FRAME-EMIT.
*> USING CLIENT-STATE, replica row of an item_frame or glow_item_frame with an item (EN-STACK-ITEM, EN-STACK-COUNT above 0), eye (3 FLOAT-LONG): the framed item (34-9 section 10 submit):
*> from the entity position translate the direction's unit step x 0.46875; a horizontal direction rotates X by 0 and Y by 180 - toYRot (north 180, south 0, west 90, east 270), a vertical one X by
*> -90 x the step (up -90, down +90) and Y by 180; translate (0, 0, 0.4375) (0.5 when the frame is invisible, the flags bit 32); rotate Z by rotation x 45 degrees; scale 0.5; then the item with its
*> fixed display transform (ITEM-POSED-DRAW, context 3), full bright for a glow frame. A map in the frame is not drawn (the client keeps no map data).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-FFOIL               BINARY-LONG.
 01 WS-CONTEXT             BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-MV(2) WS-MV(3) WS-MV(4) WS-MV(6) WS-MV(7) WS-MV(8)
     MOVE 1 TO WS-MV(1) WS-MV(5) WS-MV(9)
     COMPUTE WS-MV(10) = EN-X(L-ROW) - L-EYE(1)
     COMPUTE WS-MV(11) = EN-Y(L-ROW) - L-EYE(2)
     COMPUTE WS-MV(12) = EN-Z(L-ROW) - L-EYE(3)
     MOVE 0 TO WS-AX WS-AY WS-AZ
     EVALUATE EN-FDIR(L-ROW)
         WHEN 0
             MOVE -0.46875 TO WS-AY
         WHEN 1
             MOVE 0.46875 TO WS-AY
         WHEN 2
             MOVE -0.46875 TO WS-AZ
         WHEN 3
             MOVE 0.46875 TO WS-AZ
         WHEN 4
             MOVE -0.46875 TO WS-AX
         WHEN OTHER
             MOVE 0.46875 TO WS-AX
     END-EVALUATE
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE 1 TO WS-AXIS
     MOVE 2 TO WS-STEP
     EVALUATE EN-FDIR(L-ROW)
         WHEN 0
             MOVE 90 TO WS-DEG
             MOVE 180 TO WS-STEP
         WHEN 1
             MOVE -90 TO WS-DEG
             MOVE 180 TO WS-STEP
         WHEN 2
             MOVE 0 TO WS-DEG
             MOVE 0 TO WS-STEP
         WHEN 3
             MOVE 0 TO WS-DEG
             MOVE 180 TO WS-STEP
         WHEN 4
             MOVE 0 TO WS-DEG
             MOVE 90 TO WS-STEP
         WHEN OTHER
             MOVE 0 TO WS-DEG
             MOVE -90 TO WS-STEP
     END-EVALUATE
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 2 TO WS-AXIS
     MOVE WS-STEP TO WS-DEG
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 0 TO WS-AX WS-AY
     MOVE 0.4375 TO WS-AZ
     IF FUNCTION MOD(FUNCTION INTEGER(EN-FLAGS(L-ROW) / 32), 2) = 1
         MOVE 0.5 TO WS-AZ
     END-IF
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE 3 TO WS-AXIS
     COMPUTE WS-DEG = EN-FROT(L-ROW) * 45
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-SCALE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE 0 TO WS-BRIGHT
     IF EN-KEY(L-ROW) = "glow_item_frame"
         MOVE 1 TO WS-BRIGHT
     END-IF
     MOVE EN-STACK-FOIL(L-ROW) TO WS-FFOIL
     CALL "ITEM-POSED-DRAW" USING CLIENT-STATE WS-M EN-STACK-ITEM(L-ROW) WS-CONTEXT L-ROW L-EYE-TABLE WS-BRIGHT WS-FFOIL
     GOBACK.
 END PROGRAM ENTITY-FRAME-EMIT.
