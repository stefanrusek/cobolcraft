*> The GUI icon of a block item (lane bugguiitems; docs/protocol/12 section 8.1, 8.2 and 1.9; 08 sections 5.1, 5.6). An item whose model has elements (a block item: oak planks, a log,
*> a slab, stairs ...) is drawn in a slot as its model seen through the model's gui display transform (the block/block parent gives rotation (30, 225, 0), scale 0.625: the isometric
*> cube), not as one flat square of the sprite of one face. ITEM-GUI-BAKE (called by ITEM-SPRITE-OF when the item is first looked up) turns the elements of the resolved model
*> into the quads that face the viewer, far to near, and keeps them in the pool IG-QUAD of CLSTATE.cpy; ITEM-GUI-ICON draws the pooled quads of an item into the icon layer of a slot.
*> A flat item (builtin/generated) and a code-drawn item (item-special.cob) have no pooled quads: their icon is the flat sprite (or SPECIAL-GUI-ICON).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-GUI-BAKE.
*> USING CLIENT-STATE, item id, MODEL-RESOLVED (the item's model: ITEM-SPRITE-OF has just resolved it): bakes IS-GUI-FIRST and IS-GUI-COUNT of the item (0 when it has no face that shows
*> or the pool of 8192 quads is full). The display transform is the model's gui entry (identity when the chain names none: 12 section 8.2), M = translate(t / 16) x rotationXYZ x scale x
*> translate(-0.5) as SPECIAL-DISPLAY-M builds it; the model's quads come from ELEMENT-BAKE (corners 0 to 1, clockwise seen from outside, the sprite units of the uv) and a corner p goes to
*> (8 + 16 x (M p).x, 8 - 16 x (M p).y) of the 16 pixel cell (the viewer is on the +z side, 12 section 8.1; a quad shows when cross(c2 - c1, c3 - c2).z is below 0), shaded by the two
*> ITEMS_3D lights of 12 section 1.9 (a gui_light of front: full brightness, ITEMS_FLAT). The quads are kept far to near by their mean z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLQUAD.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-WP                  FLOAT-LONG OCCURS 12 TIMES.
 01 WS-KEYS.
    05 WS-KEY              FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-TQS.
    05 WS-TQ OCCURS 48 TIMES.
       10 WS-TQ-SPRITE     BINARY-LONG.
       10 WS-TQ-TINT       BINARY-LONG.
       10 WS-TQ-BRIGHT     FLOAT-SHORT.
       10 WS-TQ-CORNER OCCURS 4 TIMES.
          15 WS-TQ-X       FLOAT-SHORT.
          15 WS-TQ-Y       FLOAT-SHORT.
          15 WS-TQ-U       FLOAT-SHORT.
          15 WS-TQ-V       FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-DST                 BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-ZSUM                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 COPY CLMODEL.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM MODEL-RESOLVED.
     IF L-ITEM < 0 OR L-ITEM >= 2048
         GOBACK
     END-IF
     MOVE 0 TO IS-GUI-FIRST(L-ITEM + 1) IS-GUI-COUNT(L-ITEM + 1)
*>   The gui transform of the model (rotation, translation in sixteenths, scale), identity when the chain names none.
     MOVE 0 TO WS-DV(1) WS-DV(2) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
     MOVE 1 TO WS-DV(7) WS-DV(8) WS-DV(9)
     IF MR-GUI-PRESENT = 1
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
             MOVE MR-GUI(WS-K) TO WS-DV(WS-K)
         END-PERFORM
     END-IF
     CALL "SPECIAL-DISPLAY-M" USING WS-VAL WS-M
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > MR-ELEMENT-COUNT
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
             IF MF-PRESENT(WS-E, WS-F) = 1 AND WS-N < 48
                 CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED MF-TEXTURE(WS-E, WS-F) WS-SPRITE
                 CALL "ELEMENT-BAKE" USING MODEL-RESOLVED WS-E WS-F WS-SPRITE QUAD
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     COMPUTE WS-WP((WS-K - 1) * 3 + 1) = WS-MV(1) * QD-X(WS-K) + WS-MV(2) * QD-Y(WS-K) + WS-MV(3) * QD-Z(WS-K) + WS-MV(10)
                     COMPUTE WS-WP((WS-K - 1) * 3 + 2) = WS-MV(4) * QD-X(WS-K) + WS-MV(5) * QD-Y(WS-K) + WS-MV(6) * QD-Z(WS-K) + WS-MV(11)
                     COMPUTE WS-WP((WS-K - 1) * 3 + 3) = WS-MV(7) * QD-X(WS-K) + WS-MV(8) * QD-Y(WS-K) + WS-MV(9) * QD-Z(WS-K) + WS-MV(12)
                 END-PERFORM
                 PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
                     COMPUTE WS-E1(WS-R) = WS-WP(3 + WS-R) - WS-WP(WS-R)
                     COMPUTE WS-E2(WS-R) = WS-WP(6 + WS-R) - WS-WP(3 + WS-R)
                 END-PERFORM
                 COMPUTE WS-C(1) = WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)
                 COMPUTE WS-C(2) = WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)
                 COMPUTE WS-C(3) = WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)
*>               The first two edges' cross product points away from the viewer (z below 0) for a quad that faces it.
                 IF WS-C(3) < 0
                     ADD 1 TO WS-N
                     MOVE WS-SPRITE TO WS-TQ-SPRITE(WS-N)
                     MOVE MF-TINT(WS-E, WS-F) TO WS-TQ-TINT(WS-N)
                     MOVE 1 TO WS-SHADE
                     IF MR-GUI-LIGHT NOT = 1
*>                       The outward normal in view space is minus that cross product; the ITEMS_3D lights (12 section 1.9) in view space with y up are (0.43256, 0.642451,
*>                       0.632573) and (-0.721948, 0.547067, 0.423684).
                         COMPUTE WS-LEN = FUNCTION SQRT(WS-C(1) * WS-C(1) + WS-C(2) * WS-C(2) + WS-C(3) * WS-C(3))
                         COMPUTE WS-NX = 0 - WS-C(1) / WS-LEN
                         COMPUTE WS-NY = 0 - WS-C(2) / WS-LEN
                         COMPUTE WS-NZ = 0 - WS-C(3) / WS-LEN
                         COMPUTE WS-D0 = FUNCTION MAX(0, 0.43256 * WS-NX + 0.642451 * WS-NY + 0.632573 * WS-NZ)
                         COMPUTE WS-D1 = FUNCTION MAX(0, -0.721948 * WS-NX + 0.547067 * WS-NY + 0.423684 * WS-NZ)
                         COMPUTE WS-SHADE = FUNCTION MIN(1, (WS-D0 + WS-D1) * 0.6 + 0.4)
                     END-IF
                     MOVE WS-SHADE TO WS-TQ-BRIGHT(WS-N)
                     MOVE 0 TO WS-ZSUM
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-TQ-X(WS-N, WS-K) = 8 + 16 * WS-WP((WS-K - 1) * 3 + 1)
                         COMPUTE WS-TQ-Y(WS-N, WS-K) = 8 - 16 * WS-WP((WS-K - 1) * 3 + 2)
                         MOVE QD-U(WS-K) TO WS-TQ-U(WS-N, WS-K)
                         MOVE QD-V(WS-K) TO WS-TQ-V(WS-N, WS-K)
                         COMPUTE WS-ZSUM = WS-ZSUM + WS-WP((WS-K - 1) * 3 + 3)
                     END-PERFORM
                     MOVE WS-ZSUM TO WS-KEY(WS-N)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   Room for all of them or none: an item that does not fit the pool keeps the flat icon of its sprite.
     IF WS-N > 0 AND IG-USED + WS-N <= 8192
         CALL "SPECIAL-SORT" USING WS-N WS-KEYS WS-ORDERS
         COMPUTE IS-GUI-FIRST(L-ITEM + 1) = IG-USED + 1
         MOVE WS-N TO IS-GUI-COUNT(L-ITEM + 1)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             MOVE WS-ORDER(WS-I) TO WS-SRC
             COMPUTE WS-DST = IG-USED + WS-I
             MOVE WS-TQ(WS-SRC) TO IG-QUAD(WS-DST)
         END-PERFORM
         ADD WS-N TO IG-USED
     END-IF
     GOBACK.
 END PROGRAM ITEM-GUI-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-GUI-ICON.
*> USING CLIENT-STATE, item id, x, y (the icon cell's corner in GUI pixels), dye and potion (the stack's dyed_color RGB and potion id, -1 none: STACK-TINT), drawn out: draws the pooled quads of the item (ITEM-GUI-BAKE, filled by ITEM-SPRITE-OF, which the caller has
*> called) into the icon layer, a corner at ((x + cell x) times the GUI scale, (y + cell y) times it), in the sprite of the quad, the brightness of its lighting, far to near. Drawn out 1 when
*> the quads are drawn, a quad with a tintindex in the colour of that layer of the item's tint list (43 section 7; ITEM-ICON-TINT: the grass block's top, leaves, a vine); 0 and nothing added for an item with none (a flat item, a stand-in set, a set of the cobolcraft type) or when they do not all fit the icon layer: the caller draws
*> the flat icon.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-XY.
    05 WS-P                FLOAT-SHORT OCCURS 8 TIMES.
 01 WS-UVG.
    05 WS-GU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-GV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-B                   FLOAT-SHORT.
 01 WS-TINT.
    05 WS-T                FLOAT-SHORT OCCURS 3 TIMES.
 01 WS-LAST                BINARY-LONG.
 01 WS-TINTED              BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-QI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-X L-Y L-DYE L-POTION L-DRAWN.
     MOVE 0 TO L-DRAWN
     IF L-ITEM < 0 OR L-ITEM >= 2048
         GOBACK
     END-IF
*>   The baked quads belong to the standard set (ITEM-SPRITE-OF finds the other items' icons in the stand-in table).
     IF NOT (CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT)
         GOBACK
     END-IF
     MOVE IS-GUI-COUNT(L-ITEM + 1) TO WS-COUNT
     IF WS-COUNT = 0 OR RL-IC-COUNT + 6 * WS-COUNT > CL-MAX-ICON-VERTICES
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWN
     MOVE 1 TO WS-T(1) WS-T(2) WS-T(3)
     MOVE -1 TO WS-LAST
     PERFORM VARYING WS-QI FROM 1 BY 1 UNTIL WS-QI > WS-COUNT
         COMPUTE WS-Q = IS-GUI-FIRST(L-ITEM + 1) + WS-QI - 1
*>       The colour of the quad's layer (white without a tintindex), asked again only when the layer changes from the quad before.
         IF IG-TINT(WS-Q) NOT = WS-LAST
             MOVE IG-TINT(WS-Q) TO WS-LAST
             MOVE 1 TO WS-T(1) WS-T(2) WS-T(3)
             IF WS-LAST >= 0
                 CALL "ITEM-ICON-TINT" USING CLIENT-STATE L-ITEM WS-LAST L-DYE L-POTION WS-TINT WS-TINTED
             END-IF
         END-IF
         MOVE IG-SPRITE(WS-Q) TO WS-SPRITE
         MOVE IG-BRIGHT(WS-Q) TO WS-B
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-P(WS-K * 2 - 1) = (L-X + IG-X(WS-Q, WS-K)) * CL-GUI-SCALE
             COMPUTE WS-P(WS-K * 2) = (L-Y + IG-Y(WS-Q, WS-K)) * CL-GUI-SCALE
             MOVE IG-U(WS-Q, WS-K) TO WS-U16
             MOVE IG-V(WS-Q, WS-K) TO WS-V16
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16 WS-V16 WS-GU(WS-K) WS-GV(WS-K)
         END-PERFORM
         CALL "SPECIAL-UI-QUAD" USING CLIENT-STATE WS-XY WS-UVG WS-B WS-TINT
     END-PERFORM
     GOBACK.
 END PROGRAM ITEM-GUI-ICON.
