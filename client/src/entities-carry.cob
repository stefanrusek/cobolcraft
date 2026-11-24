*> Blocks that mobs carry (T9905): the pumpkin of a snow golem's head (34-3 section 8 SnowGolemHeadLayer), the poppy an iron golem offers (7 IronGolemFlowerLayer), the block an enderman
*> carries (34-6 section 3 CarriedBlockLayer) and the block on a copper golem's antenna (34-3 9.3 and 9.4 BlockDecorationLayer). Each is the baked model of a block state (the quads of
*> BM-STATE, block units 0 to 1) put through the layer's operations in the frame of the part or the model root that the layer starts from (ENTITY-MODEL-EMIT: EN-ANC-FG, the right arm's
*> EN-HAND-FG), into the ground item mesh (RL-GI-VERTEX, the block atlas) as the items mobs hold are (HAND-QUAD mode 4).
*>   ENTITY-ROOT-FRAME USING render sequence (64 FLOAT-LONG, ENTITY-OPS-POINT's list), frame out (12 FLOAT-LONG as EN-HAND-F): the images of the origin and the three unit vectors;
*>   ENTITY-OPS-MATRIX USING M (12 FLOAT-LONG), operations (count, then code and three values each), flavour (0: 1 translate 2 scale 3 rotate Y 5 rotate X in degrees, the tables of 34-3;
*>     1: 1 translate 2 scale 3 rotate Y 4 rotate Z in degrees 5 rotate Z in radians 6 rotate X in degrees, the tables of 34-5 and 34-6): M = M x each operation in the order listed;
*>   ENTITY-BLOCK-STATE-OF-KEY USING block key (PIC X(112)), state out (BINARY-LONG, 0 when the open set has no such block): its default state;
*>   BLOCK-STATE-DRAW USING CLIENT-STATE, M (12 FLOAT-LONG: model to entity-relative world, then the eye offset), state id, light (FLOAT-LONG): the quads of the state;
*>   ENTITY-CARRY-EMIT USING CLIENT-STATE, replica row, eye: draws what the row carries.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ROOT-FRAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-P.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 01 L-FRAME.
    05 L-F                 FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-OPS L-FRAME.
     MOVE 0 TO WS-PV(1) WS-PV(2) WS-PV(3)
     CALL "ENTITY-OPS-POINT" USING L-OPS WS-P
     MOVE WS-PV(1) TO L-F(1)
     MOVE WS-PV(2) TO L-F(2)
     MOVE WS-PV(3) TO L-F(3)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE 0 TO WS-PV(1) WS-PV(2) WS-PV(3)
         MOVE 1 TO WS-PV(WS-K)
         CALL "ENTITY-OPS-POINT" USING L-OPS WS-P
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE L-F(WS-K * 3 + WS-A) = WS-PV(WS-A) - L-F(WS-A)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ROOT-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-OPS-MATRIX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 01 L-FLAVOUR              BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-OPS L-FLAVOUR.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-OP(1)
         COMPUTE WS-B = WS-J * 4 - 2
         MOVE L-OP(WS-B + 1) TO WS-X
         MOVE L-OP(WS-B + 2) TO WS-Y
         MOVE L-OP(WS-B + 3) TO WS-Z
         MOVE L-OP(WS-B + 1) TO WS-DEG
         EVALUATE TRUE
             WHEN L-OP(WS-B) = 1
                 CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             WHEN L-OP(WS-B) = 2
                 CALL "HAND-M-SCALE" USING L-M WS-X WS-Y WS-Z
             WHEN L-OP(WS-B) = 3
                 MOVE 2 TO WS-AXIS
                 CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             WHEN L-OP(WS-B) = 4
                 MOVE 3 TO WS-AXIS
                 CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             WHEN L-OP(WS-B) = 5 AND L-FLAVOUR = 1
                 MOVE 3 TO WS-AXIS
                 COMPUTE WS-DEG = L-OP(WS-B + 1) * 180 / FUNCTION PI
                 CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             WHEN OTHER
                 MOVE 1 TO WS-AXIS
                 CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-OPS-MATRIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BLOCK-STATE-OF-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STATE.
     MOVE 0 TO L-STATE
     CALL "CONTENT-BLOCK-BY-KEY" USING L-KEY WS-ID WS-ROW WS-STATUS
     IF WS-STATUS = CT-OK
*>       A block without a default state answers state 0 (CONTENT-STATE-DEFAULT).
         CALL "CONTENT-STATE-DEFAULT" USING WS-ID L-STATE WS-STATUS
     END-IF
     GOBACK.
 END PROGRAM ENTITY-BLOCK-STATE-OF-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-STATE-DRAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ROW                 BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 4.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-TEXEL.
    05 WS-TU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-TV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NOQ.
    05 WS-NOQV             FLOAT-LONG OCCURS 9 TIMES VALUE 0.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-SPRITE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-STATE                BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-STATE L-LIGHT.
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE L-STATE WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-ROW)
         IF RL-GI-COUNT + 6 <= CL-MAX-GI-VERTICES
             MOVE BM-SPRITE(WS-ROW, WS-Q) TO WS-SPRITE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 COMPUTE WS-A = (WS-K - 1) * 3
                 MOVE BM-X(WS-ROW, WS-Q, WS-K) TO WS-CP(WS-A + 1)
                 MOVE BM-Y(WS-ROW, WS-Q, WS-K) TO WS-CP(WS-A + 2)
                 MOVE BM-Z(WS-ROW, WS-Q, WS-K) TO WS-CP(WS-A + 3)
                 MOVE BM-U(WS-ROW, WS-Q, WS-K) TO WS-U16
                 MOVE BM-V(WS-ROW, WS-Q, WS-K) TO WS-V16
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-TU(WS-K) WS-TV(WS-K)
             END-PERFORM
*>           The outward normal of a quad seen clockwise from outside: minus the cross product of its first two edges.
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-E1(WS-A) = WS-CP(3 + WS-A) - WS-CP(WS-A)
                 COMPUTE WS-E2(WS-A) = WS-CP(6 + WS-A) - WS-CP(3 + WS-A)
             END-PERFORM
             COMPUTE WS-NV(1) = WS-E1(3) * WS-E2(2) - WS-E1(2) * WS-E2(3)
             COMPUTE WS-NV(2) = WS-E1(1) * WS-E2(3) - WS-E1(3) * WS-E2(1)
             COMPUTE WS-NV(3) = WS-E1(2) * WS-E2(1) - WS-E1(1) * WS-E2(2)
             CALL "HAND-QUAD" USING CLIENT-STATE L-M WS-CORNERS WS-TEXEL WS-N3 L-LIGHT WS-MODE WS-NOQ
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-STATE-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CARRY-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-FR.
    05 WS-F                FLOAT-LONG OCCURS 12 TIMES.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FLAVOUR             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-INVIS               BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-AREA           PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE 0 TO WS-GO WS-STATE
     MOVE 0 TO WS-FLAVOUR
     MOVE SPACES TO WS-KEY
     EVALUATE EN-KEY(L-ROW)
*>       The snow golem's pumpkin: the head part's frame (the head turns with the golem's view), unless the state is invisible and not glowing (34-3 8).
         WHEN "snow_golem"
             COMPUTE WS-INVIS = FUNCTION MOD(FUNCTION INTEGER(EN-FLAGS(L-ROW) / 32), 2)
             COMPUTE WS-GLOW = FUNCTION MOD(FUNCTION INTEGER(EN-FLAGS(L-ROW) / 64), 2)
             IF EN-ANC-OK(L-ROW) = 1 AND EN-X1(L-ROW) = 0 AND (WS-INVIS = 0 OR WS-GLOW = 1)
                 MOVE "carved_pumpkin" TO WS-KEY
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 12
                     MOVE EN-ANC-F(L-ROW, WS-A) TO WS-F(WS-A)
                 END-PERFORM
                 CALL "EM3-SNOW-HEAD-OPS" USING WS-O
                 MOVE 1 TO WS-GO
             END-IF
*>       The poppy an iron golem offers: the right arm's frame while the offer-flower tick is above 0 (34-3 7).
         WHEN "iron_golem"
             IF EN-FLW(L-ROW) > 0 AND EN-HAND-FOK(L-ROW, 1) = 1
                 MOVE "poppy" TO WS-KEY
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 12
                     MOVE EN-HAND-F(L-ROW, 1, WS-A) TO WS-F(WS-A)
                 END-PERFORM
                 CALL "EM3-FLOWER-OPS" USING WS-O
                 MOVE 1 TO WS-GO
             END-IF
*>       The block an enderman carries (entry 16, a raw block state): the model root (34-6 3.3).
         WHEN "enderman"
             IF EN-ANC-OK(L-ROW) = 1 AND EN-CARRY(L-ROW) > 0
                 MOVE EN-CARRY(L-ROW) TO WS-STATE
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 12
                     MOVE EN-ANC-F(L-ROW, WS-A) TO WS-F(WS-A)
                 END-PERFORM
                 MOVE 1 TO WS-IV(1)
                 CALL "EF6-ENDERMAN-BLOCK-OPS" USING WS-I WS-O
                 MOVE 1 TO WS-FLAVOUR
                 MOVE 1 TO WS-GO
             END-IF
*>       The block on a copper golem's antenna: the block item of the antenna slot (the saddle slot, ordinal 7), after the head's frame and the antenna's translation, put through the
*>       fixed matrix of 9.4 (a unit-cube point (x, y, z) goes to (0.5 - x, 1 - y, z - 0.5): translate (0.5, 1, -0.5), then scale (-1, -1, 1)).
         WHEN "copper_golem"
             IF EN-ANC-OK(L-ROW) = 1 AND EN-EQ(L-ROW, 8) > 0
                 CALL "CONTENT-ITEM-BY-ID" USING EN-EQ(L-ROW, 8) WS-ITEM-AREA WS-STATUS
                 IF WS-STATUS = CT-OK
                     MOVE WS-ITEM-AREA TO CT-ITEM-ROW
                     MOVE CT-IR-KEY TO WS-KEY
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 12
                         MOVE EN-ANC-F(L-ROW, WS-A) TO WS-F(WS-A)
                     END-PERFORM
                     CALL "EM3-COPPER-ANTENNA-OPS" USING WS-O
                     MOVE 3 TO WS-OV(1)
                     MOVE 1 TO WS-OV(6)
                     MOVE 0.5 TO WS-OV(7)
                     MOVE 1 TO WS-OV(8)
                     MOVE -0.5 TO WS-OV(9)
                     MOVE 2 TO WS-OV(10)
                     MOVE -1 TO WS-OV(11) WS-OV(12)
                     MOVE 1 TO WS-OV(13)
                     MOVE 1 TO WS-GO
                 END-IF
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     IF WS-GO = 1 AND WS-KEY NOT = SPACES
         CALL "ENTITY-BLOCK-STATE-OF-KEY" USING WS-KEY WS-STATE
     END-IF
     IF WS-GO = 0 OR WS-STATE = 0
         GOBACK
     END-IF
*>   The frame as the matrix (the axes are its columns) at the mob's place relative to the eye, then the layer's operations.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         MOVE WS-F(3 + WS-A) TO WS-MV((WS-A - 1) * 3 + 1)
         MOVE WS-F(6 + WS-A) TO WS-MV((WS-A - 1) * 3 + 2)
         MOVE WS-F(9 + WS-A) TO WS-MV((WS-A - 1) * 3 + 3)
     END-PERFORM
     COMPUTE WS-MV(10) = WS-F(1) + EN-X(L-ROW) - L-EYE(1)
     COMPUTE WS-MV(11) = WS-F(2) + EN-Y(L-ROW) - L-EYE(2)
     COMPUTE WS-MV(12) = WS-F(3) + EN-Z(L-ROW) - L-EYE(3)
     CALL "ENTITY-OPS-MATRIX" USING WS-M WS-O WS-FLAVOUR
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-CELL WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
     CALL "BLOCK-STATE-DRAW" USING CLIENT-STATE WS-M WS-STATE WS-LIGHT
     GOBACK.
 END PROGRAM ENTITY-CARRY-EMIT.
