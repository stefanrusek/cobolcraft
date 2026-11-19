*> The code-drawn item models (item-special.cob) on the ground, in the GUI and in the hand (docs/protocol/52 sections 3.10, 4.5, 6.7 for the display transforms, 34-9 section 9.2 for
*> the dropped item, 12 sections 6.3 and 6.10 for the hand). SPECIAL-ITEM-DISPLAY gives a kind's display transform of a context, SPECIAL-DISPLAY-M the matrix of ItemTransform.apply
*> (translate, rotationXYZ, scale, translate -0.5), SPECIAL-SORT orders quads far to near for the pipelines that do not write depth, SPECIAL-GUI-ICON draws the model into the icon layer
*> of a slot, SPECIAL-GROUND-MESH draws the dropped item of an entity row into the ground items mesh and HAND-SPECIAL-MESH draws the item of the hand through HAND-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-ITEM-DISPLAY.
*> USING kind (1 the chest family and 2 the shulker boxes: template_chest and template_shulker_box, 3 the banners: template_banner), context (1 gui, 2 ground, 3 firstperson_righthand),
*> values out (9 FLOAT-LONG: rotation x y z in degrees, translation x y z in sixteenths, scale x y z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER PIC X(72) VALUE "+0300000+0450000+0000000+0000000+0000000+0000000+0006250+0006250+0006250".
    05 FILLER PIC X(72) VALUE "+0000000+0000000+0000000+0000000+0030000+0000000+0002500+0002500+0002500".
    05 FILLER PIC X(72) VALUE "+0000000+3150000+0000000+0000000+0000000+0000000+0004000+0004000+0004000".
    05 FILLER PIC X(72) VALUE "+0300000+0200000+0000000+0000000-0032500+0000000+0005325+0005325+0005325".
    05 FILLER PIC X(72) VALUE "+0000000+0000000+0000000+0000000+0010000+0000000+0002500+0002500+0002500".
    05 FILLER PIC X(72) VALUE "+0000000+0900000+0000000+0000000+0000000+0000000+0003750+0003750+0003750".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-ROW OCCURS 6 TIMES.
       10 WS-V             PIC S999V9999 SIGN LEADING SEPARATE OCCURS 9 TIMES.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CONTEXT              BINARY-LONG.
 01 L-VALUES.
    05 L-VALUE             FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-KIND L-CONTEXT L-VALUES.
     COMPUTE WS-R = L-CONTEXT
     IF L-KIND = 3
         COMPUTE WS-R = L-CONTEXT + 3
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         MOVE WS-V(WS-R, WS-K) TO L-VALUE(WS-K)
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-ITEM-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-DISPLAY-M.
*> USING values (SPECIAL-ITEM-DISPLAY), M out (12 FLOAT-LONG: the 3 x 3 matrix by rows, then the translation): ItemTransform.apply, M = translate(t / 16) x rotationXYZ(rx, ry, rz) x
*> scale(s) x translate(-0.5, -0.5, -0.5) (52 section 3.10), a point p of the unit cell goes to M p.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUES.
    05 L-VALUE             FLOAT-LONG OCCURS 9 TIMES.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-VALUES L-M.
     CALL "HAND-M-IDENT" USING L-M
     COMPUTE WS-AX = L-VALUE(4) / 16
     COMPUTE WS-AY = L-VALUE(5) / 16
     COMPUTE WS-AZ = L-VALUE(6) / 16
     CALL "HAND-M-TRANSLATE" USING L-M WS-AX WS-AY WS-AZ
     PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
         MOVE L-VALUE(WS-AXIS) TO WS-DEG
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-PERFORM
     MOVE L-VALUE(7) TO WS-AX
     MOVE L-VALUE(8) TO WS-AY
     MOVE L-VALUE(9) TO WS-AZ
     CALL "HAND-M-SCALE" USING L-M WS-AX WS-AY WS-AZ
     MOVE -0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-TRANSLATE" USING L-M WS-AX WS-AY WS-AZ
     GOBACK.
 END PROGRAM SPECIAL-DISPLAY-M.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-SORT.
*> USING count, keys (48 FLOAT-LONG), order out (48 BINARY-LONG): the indexes 1 to count by ascending key (an insertion sort, stable): the painter's order of quads, far to near.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-KEYS.
    05 L-KEY               FLOAT-LONG OCCURS 48 TIMES.
 01 L-ORDERS.
    05 L-ORDER             BINARY-LONG OCCURS 48 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-KEYS L-ORDERS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         MOVE WS-I TO L-ORDER(WS-I)
         MOVE WS-I TO WS-J
         PERFORM UNTIL WS-J <= 1
             IF L-KEY(L-ORDER(WS-J - 1)) > L-KEY(L-ORDER(WS-J))
                 MOVE L-ORDER(WS-J) TO WS-T
                 MOVE L-ORDER(WS-J - 1) TO L-ORDER(WS-J)
                 MOVE WS-T TO L-ORDER(WS-J - 1)
                 SUBTRACT 1 FROM WS-J
             ELSE
                 MOVE 1 TO WS-J
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-SORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-UI-QUAD.
*> USING CLIENT-STATE, corners (8 FLOAT-SHORT: x y of the four corners, window pixels), uv (4 u then 4 v), brightness, tint (3 FLOAT-SHORT): the two triangles 1 2 3, 1 3 4 of a quad in
*> the icon layer (RL-IC-VERTEX, the block atlas) while it has room.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-XY.
    05 L-P                 FLOAT-SHORT OCCURS 8 TIMES.
 01 L-UV.
    05 L-U                 FLOAT-SHORT OCCURS 4 TIMES.
    05 L-V                 FLOAT-SHORT OCCURS 4 TIMES.
 01 L-B                    FLOAT-SHORT.
 01 L-TINT.
    05 L-T                 FLOAT-SHORT OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-XY L-UV L-B L-TINT.
     IF RL-IC-COUNT + 6 <= CL-MAX-ICON-VERTICES
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             ADD 1 TO RL-IC-COUNT
             MOVE WS-ORD(WS-K) TO WS-C
             MOVE L-P(WS-C * 2 - 1) TO RL-IC-X(RL-IC-COUNT)
             MOVE L-P(WS-C * 2) TO RL-IC-Y(RL-IC-COUNT)
             MOVE 0 TO RL-IC-Z(RL-IC-COUNT)
             MOVE L-U(WS-C) TO RL-IC-U(RL-IC-COUNT)
             MOVE L-V(WS-C) TO RL-IC-V(RL-IC-COUNT)
             MOVE L-B TO RL-IC-B(RL-IC-COUNT)
             MOVE 1 TO RL-IC-A(RL-IC-COUNT)
             MOVE 0 TO RL-IC-SKY(RL-IC-COUNT)
             MOVE L-T(1) TO RL-IC-R(RL-IC-COUNT)
             MOVE L-T(2) TO RL-IC-G(RL-IC-COUNT)
             MOVE L-T(3) TO RL-IC-BLUE(RL-IC-COUNT)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SPECIAL-UI-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-GUI-ICON.
*> USING CLIENT-STATE, kind, item id, x, y (the icon cell's corner in GUI pixels): the model of the item drawn with the gui display transform (52 3.10, 4.5, 6.7) into the icon layer. The cell
*> is 16 pixels: a point of the transformed model p goes to (x + 8 + 16 p.x, y + 8 - 16 p.y) times the GUI scale (the GUI's own projection with y flipped), the quads that face the
*> viewer (the view is along -z: cross(c2 - c1, c3 - c2).z below 0) are drawn from the far one to the near one (mean z), shaded by the two level lights of 12 section 6.10; drawn out (1)
*> when they all fit the icon layer, else 0 and nothing is added (the caller draws the flat icon).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLSQ.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-W                   FLOAT-LONG OCCURS 576 TIMES.
 01 WS-KEYS.
    05 WS-KEY              FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOW                BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-CONTEXT             BINARY-LONG VALUE 1.
 01 WS-Q                   BINARY-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-ZSUM                FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-CROSS               FLOAT-LONG.
 01 WS-N                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-XY.
    05 WS-P                FLOAT-SHORT OCCURS 8 TIMES.
 01 WS-B                   FLOAT-SHORT.
 01 WS-UVG.
    05 WS-GU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-GV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-TINT.
    05 WS-T                FLOAT-SHORT OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-ITEM L-X L-Y L-DRAWN.
     MOVE 0 TO L-DRAWN
     CALL "SPECIAL-ITEM-QUADS" USING CLIENT-STATE L-ITEM SQ-TABLE
     CALL "SPECIAL-ITEM-DISPLAY" USING L-KIND WS-CONTEXT WS-VAL
     CALL "SPECIAL-DISPLAY-M" USING WS-VAL WS-M
     MOVE 0 TO WS-SHOWN
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SQ-COUNT
         COMPUTE WS-BASE = (WS-Q - 1) * 12
         MOVE 0 TO WS-ZSUM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
                 COMPUTE WS-W(WS-BASE + (WS-K - 1) * 3 + WS-R) = WS-MV((WS-R - 1) * 3 + 1) * SQ-C(WS-Q, (WS-K - 1) * 3 + 1)
                     + WS-MV((WS-R - 1) * 3 + 2) * SQ-C(WS-Q, (WS-K - 1) * 3 + 2)
                     + WS-MV((WS-R - 1) * 3 + 3) * SQ-C(WS-Q, (WS-K - 1) * 3 + 3) + WS-MV(9 + WS-R)
             END-PERFORM
             COMPUTE WS-ZSUM = WS-ZSUM + WS-W(WS-BASE + (WS-K - 1) * 3 + 3)
         END-PERFORM
*>       Facing the viewer: the first two edges' cross product points away from the viewer (z below 0).
         COMPUTE WS-AX = WS-W(WS-BASE + 4) - WS-W(WS-BASE + 1)
         COMPUTE WS-AY = WS-W(WS-BASE + 5) - WS-W(WS-BASE + 2)
         COMPUTE WS-BX = WS-W(WS-BASE + 7) - WS-W(WS-BASE + 4)
         COMPUTE WS-BY = WS-W(WS-BASE + 8) - WS-W(WS-BASE + 5)
         COMPUTE WS-CROSS = WS-AX * WS-BY - WS-AY * WS-BX
         IF WS-CROSS < 0
             ADD 1 TO WS-SHOWN
             MOVE WS-Q TO WS-SHOW(WS-SHOWN)
             COMPUTE WS-KEY(WS-SHOWN) = WS-ZSUM / 4
         END-IF
     END-PERFORM
*>   Room for all of them or none: a model that does not fit the icon layer is left to the flat icon of the slot (L-DRAWN 0).
     IF RL-IC-COUNT + 6 * WS-SHOWN > CL-MAX-ICON-VERTICES
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWN
     CALL "SPECIAL-SORT" USING WS-SHOWN WS-KEYS WS-ORDERS
     PERFORM VARYING WS-QI FROM 1 BY 1 UNTIL WS-QI > WS-SHOWN
         MOVE WS-SHOW(WS-ORDER(WS-QI)) TO WS-Q
         COMPUTE WS-BASE = (WS-Q - 1) * 12
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-P(WS-K * 2 - 1) = (L-X + 8 + 16 * WS-W(WS-BASE + (WS-K - 1) * 3 + 1)) * CL-GUI-SCALE
             COMPUTE WS-P(WS-K * 2) = (L-Y + 8 - 16 * WS-W(WS-BASE + (WS-K - 1) * 3 + 2)) * CL-GUI-SCALE
         END-PERFORM
*>       The normal in view space (the matrix's rotation and uniform scale), the two lights of the level.
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-N(WS-R) = WS-MV((WS-R - 1) * 3 + 1) * SQ-N(WS-Q, 1) + WS-MV((WS-R - 1) * 3 + 2) * SQ-N(WS-Q, 2)
                 + WS-MV((WS-R - 1) * 3 + 3) * SQ-N(WS-Q, 3)
         END-PERFORM
         COMPUTE WS-LEN = FUNCTION SQRT(WS-N(1) * WS-N(1) + WS-N(2) * WS-N(2) + WS-N(3) * WS-N(3))
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-N(WS-R) = WS-N(WS-R) / WS-LEN
         END-PERFORM
         COMPUTE WS-D0 = FUNCTION MAX(0, 0.16169 * WS-N(1) + 0.808452 * WS-N(2) - 0.565916 * WS-N(3))
         COMPUTE WS-D1 = FUNCTION MAX(0, -0.16169 * WS-N(1) + 0.808452 * WS-N(2) + 0.565916 * WS-N(3))
         COMPUTE WS-SHADE = FUNCTION MIN(1, (WS-D0 + WS-D1) * 0.6 + 0.4)
         MOVE WS-SHADE TO WS-B
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             MOVE SQ-T(WS-Q, WS-K) TO WS-T(WS-K)
         END-PERFORM
         MOVE SQ-UV(WS-Q) TO WS-UVG
         CALL "SPECIAL-UI-QUAD" USING CLIENT-STATE WS-XY WS-UVG WS-B WS-TINT
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-GUI-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-GROUND-MESH.
*> USING CLIENT-STATE, entity row, eye (3 FLOAT-LONG), kind: appends the dropped item of an entity row (EN-VANILLA 1, key `item`) whose model is code-drawn to RL-GI-VERTEX as
*> ItemEntityRenderer draws it (34-9 section 9.2): the model's quads with the ground display transform (52 3.10, 4.5, 6.7), base = 0.0625 - the lowest y of the transformed model, bob =
*> sin(age / 10 + phase) x 0.1 + 0.1, spun about Y by age / 20 + phase; copies by stack size (1, 2, 3, 4, 5 at 1, 2 to 16, 17 to 32, 33 to 48, 49 up) with the random offsets of the thick (z size
*> above 0.0625: three offsets of 0.15) and the flat model (step = z size x 1.5 along z, two offsets of 0.075), from the Java LCG seeded with the item id. Only the quads that face the
*> camera are emitted (the mesh is drawn without depth writes), far to near by the distance of their centre, shaded by the face direction (up 1, down 0.5, north and south 0.8, west and
*> east 0.6) and the light of the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLSQ.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CONTEXT             BINARY-LONG VALUE 2.
 01 WS-W                   FLOAT-LONG OCCURS 576 TIMES.
 01 WS-WORLD               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-S                   FLOAT-LONG OCCURS 576 TIMES.
 01 WS-KEYS.
    05 WS-KEY              FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOW                BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-COPIES              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-ZS                  FLOAT-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-PHASE               FLOAT-LONG.
 01 WS-BOB                 FLOAT-LONG.
 01 WS-SPIN-SIN            FLOAT-LONG.
 01 WS-SPIN-COS            FLOAT-LONG.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-FACING              FLOAT-LONG.
 01 WS-ORD-DATA            PIC X(6) VALUE "123134".
 01 WS-ORD-TABLE REDEFINES WS-ORD-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-DIST                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE L-KIND.
     CALL "SPECIAL-ITEM-QUADS" USING CLIENT-STATE EN-STACK-ITEM(L-ROW) SQ-TABLE
     EVALUATE TRUE
         WHEN EN-STACK-COUNT(L-ROW) <= 1
             MOVE 1 TO WS-COPIES
         WHEN EN-STACK-COUNT(L-ROW) <= 16
             MOVE 2 TO WS-COPIES
         WHEN EN-STACK-COUNT(L-ROW) <= 32
             MOVE 3 TO WS-COPIES
         WHEN EN-STACK-COUNT(L-ROW) <= 48
             MOVE 4 TO WS-COPIES
         WHEN OTHER
             MOVE 5 TO WS-COPIES
     END-EVALUATE
     IF RL-GI-COUNT + 6 * SQ-COUNT * WS-COPIES > CL-MAX-GI-VERTICES
         GOBACK
     END-IF
     CALL "SPECIAL-ITEM-DISPLAY" USING L-KIND WS-CONTEXT WS-VAL
     CALL "SPECIAL-DISPLAY-M" USING WS-VAL WS-M
*>   The model in the entity's frame (the ground display transform) and its extents.
     MOVE 1000 TO WS-MINY WS-MINZ
     MOVE -1000 TO WS-MAXZ
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SQ-COUNT
         COMPUTE WS-BASE = (WS-Q - 1) * 12
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
                 COMPUTE WS-W(WS-BASE + (WS-K - 1) * 3 + WS-R) = WS-MV((WS-R - 1) * 3 + 1) * SQ-C(WS-Q, (WS-K - 1) * 3 + 1)
                     + WS-MV((WS-R - 1) * 3 + 2) * SQ-C(WS-Q, (WS-K - 1) * 3 + 2)
                     + WS-MV((WS-R - 1) * 3 + 3) * SQ-C(WS-Q, (WS-K - 1) * 3 + 3) + WS-MV(9 + WS-R)
             END-PERFORM
             MOVE WS-W(WS-BASE + (WS-K - 1) * 3 + 2) TO WS-LY
             MOVE WS-W(WS-BASE + (WS-K - 1) * 3 + 3) TO WS-LZ
             IF WS-LY < WS-MINY
                 MOVE WS-LY TO WS-MINY
             END-IF
             IF WS-LZ < WS-MINZ
                 MOVE WS-LZ TO WS-MINZ
             END-IF
             IF WS-LZ > WS-MAXZ
                 MOVE WS-LZ TO WS-MAXZ
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-ZS = WS-MAXZ - WS-MINZ
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE-ID WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
     COMPUTE WS-AGE = CL-NOW-MS / 50
     COMPUTE WS-PHASE = FUNCTION MOD(EN-ID(L-ROW), 64) / 64 * 2 * FUNCTION PI
     COMPUTE WS-BOB = FUNCTION SIN(WS-AGE / 10 + WS-PHASE) * 0.1 + 0.1 + 0.0625 - WS-MINY
     COMPUTE WS-SPIN-SIN = FUNCTION SIN(WS-AGE / 20 + WS-PHASE)
     COMPUTE WS-SPIN-COS = FUNCTION COS(WS-AGE / 20 + WS-PHASE)
     COMPUTE WS-STEP = WS-ZS * 1.5
     MOVE EN-STACK-ITEM(L-ROW) TO WS-SEED
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N >= WS-COPIES
         MOVE 0 TO WS-OX WS-OY WS-OZ
         IF WS-ZS > 0.0625
             IF WS-N > 0
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R3
                 COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.15
                 COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.15
                 COMPUTE WS-OZ = (WS-R3 * 2 - 1) * 0.15
             END-IF
         ELSE
             COMPUTE WS-OZ = WS-STEP * WS-N - WS-STEP * (WS-COPIES - 1) / 2
             IF WS-N > 0
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
                 CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
                 COMPUTE WS-OX = (WS-R1 * 2 - 1) * 0.075
                 COMPUTE WS-OY = (WS-R2 * 2 - 1) * 0.075
             END-IF
         END-IF
*>       The quads of this copy in the camera's frame, those that face the camera, far to near.
         MOVE 0 TO WS-SHOWN
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SQ-COUNT
             COMPUTE WS-BASE = (WS-Q - 1) * 12
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 COMPUTE WS-LX = WS-W(WS-BASE + (WS-K - 1) * 3 + 1) + WS-OX
                 COMPUTE WS-LY = WS-W(WS-BASE + (WS-K - 1) * 3 + 2) + WS-OY
                 COMPUTE WS-LZ = WS-W(WS-BASE + (WS-K - 1) * 3 + 3) + WS-OZ
                 COMPUTE WS-WORLD((WS-K - 1) * 3 + 1) = EN-X(L-ROW) - L-EYE(1) + WS-LX * WS-SPIN-COS + WS-LZ * WS-SPIN-SIN
                 COMPUTE WS-WORLD((WS-K - 1) * 3 + 2) = EN-Y(L-ROW) - L-EYE(2) + WS-BOB + WS-LY
                 COMPUTE WS-WORLD((WS-K - 1) * 3 + 3) = EN-Z(L-ROW) - L-EYE(3) + WS-LZ * WS-SPIN-COS - WS-LX * WS-SPIN-SIN
             END-PERFORM
             COMPUTE WS-AX = WS-WORLD(4) - WS-WORLD(1)
             COMPUTE WS-AY = WS-WORLD(5) - WS-WORLD(2)
             COMPUTE WS-AZ = WS-WORLD(6) - WS-WORLD(3)
             COMPUTE WS-BX = WS-WORLD(7) - WS-WORLD(4)
             COMPUTE WS-BY = WS-WORLD(8) - WS-WORLD(5)
             COMPUTE WS-BZ = WS-WORLD(9) - WS-WORLD(6)
             COMPUTE WS-FACING = (WS-AY * WS-BZ - WS-AZ * WS-BY) * WS-WORLD(1) + (WS-AZ * WS-BX - WS-AX * WS-BZ) * WS-WORLD(2)
                 + (WS-AX * WS-BY - WS-AY * WS-BX) * WS-WORLD(3)
             IF WS-FACING > 0
                 ADD 1 TO WS-SHOWN
                 MOVE WS-Q TO WS-SHOW(WS-SHOWN)
                 COMPUTE WS-DIST = 0
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     COMPUTE WS-DIST = WS-DIST + WS-WORLD((WS-K - 1) * 3 + 1) ** 2 + WS-WORLD((WS-K - 1) * 3 + 2) ** 2
                         + WS-WORLD((WS-K - 1) * 3 + 3) ** 2
                 END-PERFORM
                 COMPUTE WS-KEY(WS-SHOWN) = 0 - WS-DIST
*>               The corners go to the work table until the order is known.
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
                     MOVE WS-WORLD(WS-K) TO WS-S((WS-SHOWN - 1) * 12 + WS-K)
                 END-PERFORM
             END-IF
         END-PERFORM
         CALL "SPECIAL-SORT" USING WS-SHOWN WS-KEYS WS-ORDERS
         PERFORM VARYING WS-QI FROM 1 BY 1 UNTIL WS-QI > WS-SHOWN
             MOVE WS-SHOW(WS-ORDER(WS-QI)) TO WS-Q
             COMPUTE WS-SHADE = FUNCTION MAX(SQ-N(WS-Q, 2), 0) + 0.5 * FUNCTION MAX(0 - SQ-N(WS-Q, 2), 0)
                 + 0.8 * FUNCTION ABS(SQ-N(WS-Q, 3)) + 0.6 * FUNCTION ABS(SQ-N(WS-Q, 1))
             COMPUTE WS-SHADE = FUNCTION MAX(WS-SHADE * WS-LIGHT, 0.1)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-ORD(WS-I) TO WS-K
                 ADD 1 TO RL-GI-COUNT
                 COMPUTE WS-BASE = (WS-ORDER(WS-QI) - 1) * 12 + (WS-K - 1) * 3
                 MOVE WS-S(WS-BASE + 1) TO RL-GI-X(RL-GI-COUNT)
                 MOVE WS-S(WS-BASE + 2) TO RL-GI-Y(RL-GI-COUNT)
                 MOVE WS-S(WS-BASE + 3) TO RL-GI-Z(RL-GI-COUNT)
                 MOVE SQ-U(WS-Q, WS-K) TO RL-GI-U(RL-GI-COUNT)
                 MOVE SQ-V(WS-Q, WS-K) TO RL-GI-V(RL-GI-COUNT)
                 MOVE WS-SHADE TO RL-GI-B(RL-GI-COUNT)
                 MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                 MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 1) TO RL-GI-R(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 2) TO RL-GI-G(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 3) TO RL-GI-BLUE(RL-GI-COUNT)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-GROUND-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-SPECIAL-MESH.
*> USING CLIENT-STATE, kind, item id, M (the hand's model to view matrix with the display transform applied by this program), light, Q (HAND-VIEW-ROT): the quads of the item's
*> model into the hand mesh through HAND-QUAD (culling, level lights), the quads of a tinted layer (a banner's dyed cloth) coloured by their tint. M arrives without the display transform.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSQ.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-D.
    05 WS-DM               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-MM.
    05 WS-MMV              FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CONTEXT             BINARY-LONG VALUE 3.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-UVG.
    05 WS-GU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-GV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 01 L-Q.
    05 L-QV                FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-ITEM L-M L-LIGHT L-Q.
     CALL "SPECIAL-ITEM-QUADS" USING CLIENT-STATE L-ITEM SQ-TABLE
     CALL "SPECIAL-ITEM-DISPLAY" USING L-KIND WS-CONTEXT WS-VAL
     CALL "SPECIAL-DISPLAY-M" USING WS-VAL WS-D
*>   M x display: the arm's matrix times the display transform.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             COMPUTE WS-MMV((WS-R - 1) * 3 + WS-K) = L-MV((WS-R - 1) * 3 + 1) * WS-DM(WS-K) + L-MV((WS-R - 1) * 3 + 2) * WS-DM(3 + WS-K)
                 + L-MV((WS-R - 1) * 3 + 3) * WS-DM(6 + WS-K)
         END-PERFORM
         COMPUTE WS-MMV(9 + WS-R) = L-MV((WS-R - 1) * 3 + 1) * WS-DM(10) + L-MV((WS-R - 1) * 3 + 2) * WS-DM(11)
             + L-MV((WS-R - 1) * 3 + 3) * WS-DM(12) + L-MV(9 + WS-R)
     END-PERFORM
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SQ-COUNT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
             MOVE SQ-C(WS-Q, WS-K) TO WS-CP(WS-K)
         END-PERFORM
         MOVE SQ-UV(WS-Q) TO WS-UVG
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             MOVE SQ-N(WS-Q, WS-K) TO WS-NV(WS-K)
         END-PERFORM
         MOVE RL-HAND-COUNT TO WS-COUNT
         CALL "HAND-QUAD" USING CLIENT-STATE WS-MM WS-CORNERS WS-UVG WS-N3 L-LIGHT L-Q
         IF RL-HAND-COUNT > WS-COUNT
             PERFORM VARYING WS-K FROM WS-COUNT BY 1 UNTIL WS-K >= RL-HAND-COUNT
                 MOVE SQ-T(WS-Q, 1) TO RL-HAND-R(WS-K + 1)
                 MOVE SQ-T(WS-Q, 2) TO RL-HAND-G(WS-K + 1)
                 MOVE SQ-T(WS-Q, 3) TO RL-HAND-BLUE(WS-K + 1)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-SPECIAL-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-EMIT-WORLD.
*> USING CLIENT-STATE, SQ-TABLE, offset (3 FLOAT-LONG: the model's unit-cell origin relative to the eye), light 0 to 1: the quads of a block entity model into RL-GI-VERTEX (the block atlas,
*> the pipeline without depth writes): only the quads that face the eye (cross(c2 - c1, c3 - c2) . c1 above 0), far to near by the distance of their centre, shaded by the face direction (up 1,
*> down 0.5, north and south 0.8, west and east 0.6) times the light (at least 0.1), tinted by SQ-T; a quad that does not fit is left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-S                   FLOAT-LONG OCCURS 576 TIMES.
 01 WS-KEYS.
    05 WS-KEY              FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOW                BINARY-LONG OCCURS 48 TIMES.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-FACING              FLOAT-LONG.
 01 WS-ORD-DATA            PIC X(6) VALUE "123134".
 01 WS-ORD-TABLE REDEFINES WS-ORD-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLSQ.
 01 L-OFFSET.
    05 L-OF                FLOAT-LONG OCCURS 3 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE SQ-TABLE L-OFFSET L-LIGHT.
     MOVE 0 TO WS-SHOWN
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > SQ-COUNT
         COMPUTE WS-BASE = WS-SHOWN * 12
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
             COMPUTE WS-S(WS-BASE + WS-K) = SQ-C(WS-Q, WS-K) + L-OF(FUNCTION MOD(WS-K - 1, 3) + 1)
         END-PERFORM
         COMPUTE WS-AX = WS-S(WS-BASE + 4) - WS-S(WS-BASE + 1)
         COMPUTE WS-AY = WS-S(WS-BASE + 5) - WS-S(WS-BASE + 2)
         COMPUTE WS-AZ = WS-S(WS-BASE + 6) - WS-S(WS-BASE + 3)
         COMPUTE WS-BX = WS-S(WS-BASE + 7) - WS-S(WS-BASE + 4)
         COMPUTE WS-BY = WS-S(WS-BASE + 8) - WS-S(WS-BASE + 5)
         COMPUTE WS-BZ = WS-S(WS-BASE + 9) - WS-S(WS-BASE + 6)
         COMPUTE WS-FACING = (WS-AY * WS-BZ - WS-AZ * WS-BY) * WS-S(WS-BASE + 1) + (WS-AZ * WS-BX - WS-AX * WS-BZ) * WS-S(WS-BASE + 2)
             + (WS-AX * WS-BY - WS-AY * WS-BX) * WS-S(WS-BASE + 3)
         IF WS-FACING > 0
             ADD 1 TO WS-SHOWN
             MOVE WS-Q TO WS-SHOW(WS-SHOWN)
             MOVE 0 TO WS-DIST
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 COMPUTE WS-DIST = WS-DIST + WS-S(WS-BASE + (WS-K - 1) * 3 + 1) ** 2 + WS-S(WS-BASE + (WS-K - 1) * 3 + 2) ** 2
                     + WS-S(WS-BASE + (WS-K - 1) * 3 + 3) ** 2
             END-PERFORM
             COMPUTE WS-KEY(WS-SHOWN) = 0 - WS-DIST
         END-IF
     END-PERFORM
     CALL "SPECIAL-SORT" USING WS-SHOWN WS-KEYS WS-ORDERS
     PERFORM VARYING WS-QI FROM 1 BY 1 UNTIL WS-QI > WS-SHOWN
         MOVE WS-SHOW(WS-ORDER(WS-QI)) TO WS-Q
         IF RL-GI-COUNT + 6 <= CL-MAX-GI-VERTICES
             COMPUTE WS-SHADE = FUNCTION MAX(SQ-N(WS-Q, 2), 0) + 0.5 * FUNCTION MAX(0 - SQ-N(WS-Q, 2), 0)
                 + 0.8 * FUNCTION ABS(SQ-N(WS-Q, 3)) + 0.6 * FUNCTION ABS(SQ-N(WS-Q, 1))
             COMPUTE WS-SHADE = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-ORD(WS-I) TO WS-K
                 ADD 1 TO RL-GI-COUNT
                 COMPUTE WS-BASE = (WS-ORDER(WS-QI) - 1) * 12 + (WS-K - 1) * 3
                 MOVE WS-S(WS-BASE + 1) TO RL-GI-X(RL-GI-COUNT)
                 MOVE WS-S(WS-BASE + 2) TO RL-GI-Y(RL-GI-COUNT)
                 MOVE WS-S(WS-BASE + 3) TO RL-GI-Z(RL-GI-COUNT)
                 MOVE SQ-U(WS-Q, WS-K) TO RL-GI-U(RL-GI-COUNT)
                 MOVE SQ-V(WS-Q, WS-K) TO RL-GI-V(RL-GI-COUNT)
                 MOVE WS-SHADE TO RL-GI-B(RL-GI-COUNT)
                 MOVE 1 TO RL-GI-A(RL-GI-COUNT)
                 MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 1) TO RL-GI-R(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 2) TO RL-GI-G(RL-GI-COUNT)
                 MOVE SQ-T(WS-Q, 3) TO RL-GI-BLUE(RL-GI-COUNT)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-EMIT-WORLD.
