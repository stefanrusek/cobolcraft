*> Block cubes of entities in the ground item mesh (the block atlas, texture 0): primed TNT (docs/protocol/34-entity-models-9-non-living-entities.md 13.2) and falling blocks (13.1).
*>   ENTITY-OPS-POINT USING ops (count, then code and three values per op: 1 translate, 2 scale, 3 rotate Y, 5 rotate X, 7 rotate Z degrees; the last listed acts first), point (3 FLOAT-LONG in and out);
*>   ENTITY-CUBE-EMIT USING CLIENT-STATE, item id, ops, light (FLOAT-LONG), flash (FLOAT-LONG, 0 or 1), position (3 FLOAT-LONG), eye (3 FLOAT-LONG): the unit cube [0, 1] of the item's block model (a face's
*>     sprite is ITEM-FACE-SPRITE; an item with no block model draws nothing) carried through the ops and moved to the position; only the faces that face the eye are emitted (the mesh has no depth
*>     writes), shaded by their direction (up 1, down 0.5, north and south 0.8, west and east 0.6) times the light; the flash (overlay 15, alpha 63 of 13.2) takes the brightness 25 percent toward white;
*>   ENTITY-TNT-EMIT USING CLIENT-STATE, row, eye: a tnt entity (fuse = EN-VALUE, Set Entity Data entry 8, counted down by the client tick); ENTITY-FALLING-EMIT the same for a falling_block (EN-BSTATE,
*>     the data of Add Entity) unless the level holds that state at its block position (13.1 shouldRender).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-OPS-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 01 L-POINT.
    05 L-P                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-OPS L-POINT.
     PERFORM VARYING WS-J FROM L-OP(1) BY -1 UNTIL WS-J < 1
         COMPUTE WS-B = WS-J * 4 - 2
         IF L-OP(WS-B) = 1
             COMPUTE L-P(1) = L-P(1) + L-OP(WS-B + 1)
             COMPUTE L-P(2) = L-P(2) + L-OP(WS-B + 2)
             COMPUTE L-P(3) = L-P(3) + L-OP(WS-B + 3)
         ELSE
             IF L-OP(WS-B) = 2
                 COMPUTE L-P(1) = L-P(1) * L-OP(WS-B + 1)
                 COMPUTE L-P(2) = L-P(2) * L-OP(WS-B + 2)
                 COMPUTE L-P(3) = L-P(3) * L-OP(WS-B + 3)
             ELSE
                 COMPUTE WS-S = FUNCTION SIN(L-OP(WS-B + 1) * FUNCTION PI / 180)
                 COMPUTE WS-C = FUNCTION COS(L-OP(WS-B + 1) * FUNCTION PI / 180)
                 EVALUATE L-OP(WS-B)
                     WHEN 5
                         COMPUTE WS-T = L-P(2) * WS-C - L-P(3) * WS-S
                         COMPUTE L-P(3) = L-P(2) * WS-S + L-P(3) * WS-C
                         MOVE WS-T TO L-P(2)
                     WHEN 7
                         COMPUTE WS-T = L-P(1) * WS-C - L-P(2) * WS-S
                         COMPUTE L-P(2) = L-P(1) * WS-S + L-P(2) * WS-C
                         MOVE WS-T TO L-P(1)
                     WHEN OTHER
                         COMPUTE WS-T = L-P(1) * WS-C + L-P(3) * WS-S
                         COMPUTE L-P(3) = L-P(3) * WS-C - L-P(1) * WS-S
                         MOVE WS-T TO L-P(1)
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-OPS-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CUBE-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-PT.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-W.
    05 WS-WC OCCURS 4 TIMES.
       10 WS-WV            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NRM                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-BRIGHT              FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-QUAD.
    05 WS-Q OCCURS 4 TIMES.
       10 WS-QX              FLOAT-SHORT.
       10 WS-QY              FLOAT-SHORT.
       10 WS-QZ              FLOAT-SHORT.
       10 WS-QU              FLOAT-SHORT.
       10 WS-QV              FLOAT-SHORT.
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
 01 WS-DIR-DATA            PIC X(6) VALUE "436521".
 01 WS-DIR-TABLE REDEFINES WS-DIR-DATA.
    05 WS-FACE-DIR         PIC 9 OCCURS 6 TIMES.
 01 WS-SHADE-DATA.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
 01 WS-SHADE-TABLE REDEFINES WS-SHADE-DATA.
    05 WS-SHADE            PIC 9V9 OCCURS 6 TIMES.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-OPS.
    05 L-OP                FLOAT-LONG OCCURS 64 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 01 L-FLASH                FLOAT-LONG.
 01 L-POS.
    05 L-P                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-OPS L-LIGHT L-FLASH L-POS L-EYE-TABLE.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         MOVE WS-FACE-DIR(WS-F) TO WS-DIRECTION
         CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE L-ITEM WS-DIRECTION WS-SPRITE
         IF WS-SPRITE > 0 AND RL-GI-COUNT + 6 <= CL-MAX-GI-VERTICES
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 COMPUTE WS-A = WS-K * 3 - 3
                 MOVE WS-PICK(WS-F, WS-A + 1) TO WS-PV(1)
                 MOVE WS-PICK(WS-F, WS-A + 2) TO WS-PV(2)
                 MOVE WS-PICK(WS-F, WS-A + 3) TO WS-PV(3)
                 CALL "ENTITY-OPS-POINT" USING L-OPS WS-PT
                 COMPUTE WS-WV(WS-K, 1) = L-P(1) - L-EYE(1) + WS-PV(1)
                 COMPUTE WS-WV(WS-K, 2) = L-P(2) - L-EYE(2) + WS-PV(2)
                 COMPUTE WS-WV(WS-K, 3) = L-P(3) - L-EYE(3) + WS-PV(3)
             END-PERFORM
*>           The face's normal (right x up of the corner order) against the direction from the eye to the face.
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-E1(WS-A) = WS-WV(2, WS-A) - WS-WV(1, WS-A)
                 COMPUTE WS-E2(WS-A) = WS-WV(1, WS-A) - WS-WV(4, WS-A)
             END-PERFORM
             COMPUTE WS-NRM(1) = WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)
             COMPUTE WS-NRM(2) = WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)
             COMPUTE WS-NRM(3) = WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)
             COMPUTE WS-DOT = WS-NRM(1) * (WS-WV(1, 1) + WS-WV(3, 1)) + WS-NRM(2) * (WS-WV(1, 2) + WS-WV(3, 2))
                 + WS-NRM(3) * (WS-WV(1, 3) + WS-WV(3, 3))
             IF WS-DOT < 0
                 COMPUTE WS-BRIGHT = WS-SHADE(WS-F) * L-LIGHT
                 COMPUTE WS-BRIGHT = WS-BRIGHT * (1 - 0.25 * L-FLASH) + 0.25 * L-FLASH
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     MOVE WS-WV(WS-K, 1) TO WS-QX(WS-K)
                     MOVE WS-WV(WS-K, 2) TO WS-QY(WS-K)
                     MOVE WS-WV(WS-K, 3) TO WS-QZ(WS-K)
                     MOVE 0 TO WS-U16
                     IF WS-K = 2 OR WS-K = 3
                         MOVE 16 TO WS-U16
                     END-IF
                     MOVE 0 TO WS-V16
                     IF WS-K >= 3
                         MOVE 16 TO WS-V16
                     END-IF
                     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-QU(WS-K) WS-QV(WS-K)
                 END-PERFORM
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                     MOVE WS-ORD(WS-K) TO WS-N
                     ADD 1 TO RL-GI-COUNT
                     MOVE WS-QX(WS-N) TO RL-GI-X(RL-GI-COUNT)
                     MOVE WS-QY(WS-N) TO RL-GI-Y(RL-GI-COUNT)
                     MOVE WS-QZ(WS-N) TO RL-GI-Z(RL-GI-COUNT)
                     MOVE WS-QU(WS-N) TO RL-GI-U(RL-GI-COUNT)
                     MOVE WS-QV(WS-N) TO RL-GI-V(RL-GI-COUNT)
                     MOVE WS-BRIGHT TO RL-GI-B(RL-GI-COUNT)
                     MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                     MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                     MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-CUBE-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TNT-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FL.
    05 WS-FLV              FLOAT-LONG OCCURS 64 TIMES.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-FLASH               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-POS.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE SPACES TO WS-KEY
     MOVE "tnt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW-AREA WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE EN-VALUE(L-ROW) TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-I WS-O
     CALL "EF9-TNT-FLASH" USING WS-I WS-FL
     MOVE WS-FLV(1) TO WS-FLASH
     IF WS-FLASH > 0
         MOVE 1 TO WS-FLASH
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
     MOVE EN-X(L-ROW) TO WS-PV(1)
     MOVE EN-Y(L-ROW) TO WS-PV(2)
     MOVE EN-Z(L-ROW) TO WS-PV(3)
     CALL "ENTITY-CUBE-EMIT" USING CLIENT-STATE WS-ITEM WS-O WS-LIGHT WS-FLASH WS-POS L-EYE-TABLE
     GOBACK.
 END PROGRAM ENTITY-TNT-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-FALLING-EMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-BIX                 BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-FLASH               FLOAT-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LEVEL-STATE         BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-POS.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
*>   shouldRender: the level's state at the block containing (x, maxY, z) (the box is 0.98 high) is not the entity's own.
     MOVE EN-X(L-ROW) TO WS-IV(1)
     MOVE EN-Y(L-ROW) TO WS-IV(2)
     MOVE EN-Z(L-ROW) TO WS-IV(3)
     MOVE 0.98 TO WS-IV(4)
     CALL "EF9-FALLING-POS" USING WS-I WS-O
     MOVE WS-OV(1) TO WS-CX
     MOVE WS-OV(2) TO WS-CY
     MOVE WS-OV(3) TO WS-CZ
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-LEVEL-STATE WS-S2 WS-B2
     MOVE EN-BSTATE(L-ROW) TO WS-IV(1)
     MOVE WS-LEVEL-STATE TO WS-IV(2)
     CALL "EF9-FALLING-SHOWN" USING WS-I WS-O
     IF WS-OV(1) = 0
         GOBACK
     END-IF
     MOVE EN-BSTATE(L-ROW) TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BID WS-BIX WS-BLOCK-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
     MOVE SPACES TO WS-KEY
     MOVE CT-BR-KEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW-AREA WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     CALL "EF9-FALLING-OPS" USING WS-I WS-O
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
     MOVE EN-X(L-ROW) TO WS-PV(1)
     MOVE EN-Y(L-ROW) TO WS-PV(2)
     MOVE EN-Z(L-ROW) TO WS-PV(3)
     CALL "ENTITY-CUBE-EMIT" USING CLIENT-STATE WS-ITEM WS-O WS-LIGHT WS-FLASH WS-POS L-EYE-TABLE
     GOBACK.
 END PROGRAM ENTITY-FALLING-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CART-EMIT.
*> USING CLIENT-STATE, replica row of a minecart, eye: the block a minecart carries (34-9 3.2 step 5, EF9-MINECART-DISPLAY: furnace, spawner, command block, tnt; the chest and the hopper have no cube model
*> and draw nothing yet) as its cube in the ground item mesh: the cart's pose operations up to the translate (and the hurt tilt), then the contents' scale 0.75, translate (-0.5, (displayOffset - 8) / 16, 0.5)
*> and Y rotation 90. The default display state is used (a custom display block, entry 11, is not kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-C.
    05 WS-CV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-OPS.
    05 WS-OP               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-KEY24               PIC X(24).
 01 WS-BLOCK-NAME          PIC X(24).
 01 WS-OFFSET              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-FLASH               FLOAT-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-POS.
    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     MOVE EN-KEY(L-ROW) TO WS-KEY24
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY24 WS-BLOCK-NAME WS-OFFSET
     IF WS-BLOCK-NAME = SPACES OR "chest" OR "hopper"
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE WS-BLOCK-NAME TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ROW-AREA WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     CALL "ENTITY-MINECART-SEQUENCE" USING CLIENT-STATE L-ROW WS-OPS
*>   The last listed operation is the model's scale (-1, -1, 1): the contents come before it.
     COMPUTE WS-N = WS-OP(1) - 1
     MOVE WS-OFFSET TO WS-IV(1)
     CALL "EF9-MINECART-CONTENTS" USING WS-I WS-C
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         MOVE WS-CV(WS-J * 4 - 2) TO WS-OP((WS-N + WS-J) * 4 - 2)
         MOVE WS-CV(WS-J * 4 - 1) TO WS-OP((WS-N + WS-J) * 4 - 1)
         MOVE WS-CV(WS-J * 4) TO WS-OP((WS-N + WS-J) * 4)
         MOVE WS-CV(WS-J * 4 + 1) TO WS-OP((WS-N + WS-J) * 4 + 1)
     END-PERFORM
     COMPUTE WS-OP(1) = WS-N + 3
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
     MOVE EN-X(L-ROW) TO WS-PV(1)
     MOVE EN-Y(L-ROW) TO WS-PV(2)
     MOVE EN-Z(L-ROW) TO WS-PV(3)
     CALL "ENTITY-CUBE-EMIT" USING CLIENT-STATE WS-ITEM WS-OPS WS-LIGHT WS-FLASH WS-POS L-EYE-TABLE
     GOBACK.
 END PROGRAM ENTITY-CART-EMIT.
