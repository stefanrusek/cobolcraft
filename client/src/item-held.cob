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
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-HAND L-ITEM L-EYE-TABLE.
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-SPRITE
     MOVE FUNCTION MAX(WS-SPRITE, 1) TO WS-SPRITE
*>   A code-drawn (special) model is not drawn from its icon.
     CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE L-ITEM WS-HAVE WS-VAL
     IF WS-HAVE = 2
         GOBACK
     END-IF
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
     MOVE 1 TO WS-CONTEXT
     IF L-HAND = 2
         MOVE 2 TO WS-CONTEXT
     END-IF
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
             CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-MODE
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
         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-MODE
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-HELD-POSED.
