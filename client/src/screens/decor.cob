*> The pack's sprites of the container screens' pictures (docs/protocol/40-menus-2 to 40-menus-6; lane screenwidgets): DECOR-SPRITE and DECOR-CLIP add a sprite widget of a
*> GSP-* row when the pack stack has that sprite (GS-W above 0) and say so (drawn 1); a pack without it (the built-in pack has none of the container sprites) gives drawn 0 and
*> the caller keeps its swatch. DECOR-FURNACE-ROWS names the flame and arrow rows of the three furnace kinds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-SPRITE.
*> USING CLIENT-STATE, sprite row, x, y, width, height (GUI pixels), drawn (out 1/0): a sprite widget (WK-SPRITE) of the row stretched (or nine-sliced) over the rectangle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-SPRITE.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-W L-H L-DRAWN.
     MOVE 0 TO L-DRAWN
     IF GS-W(L-ROW) > 0
         MOVE SPACES TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION L-ROW L-X L-Y L-W L-H WS-TEXT WS-LENGTH WS-STATE
         MOVE 1 TO L-DRAWN
     END-IF
     GOBACK.
 END PROGRAM DECOR-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-CLIP.
*> USING CLIENT-STATE, sprite row, x, y, width, height, bottom (1: the bottom rows of the sprite, 0: the top rows), source column, drawn (out 1/0): a clipped sprite widget (WK-CLIP):
*> width x height pixels of the sprite from the source column (and from its top or its bottom), not stretched.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-CLIP.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BOTTOM               BINARY-LONG.
 01 L-SRC-X                BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-W L-H L-BOTTOM L-SRC-X L-DRAWN.
     MOVE 0 TO L-DRAWN
     IF GS-W(L-ROW) > 0
         MOVE SPACES TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION L-ROW L-X L-Y L-W L-H WS-TEXT WS-LENGTH L-BOTTOM
         MOVE L-SRC-X TO SM-W-SPRITE(SM-WIDGET-COUNT)
         MOVE 1 TO L-DRAWN
     END-IF
     GOBACK.
 END PROGRAM DECOR-CLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DECOR-FURNACE-ROWS.
*> USING menu type (10 blast furnace, 14 furnace, 22 smoker), flame row out, arrow row out (40-2 3.3): each kind has its own lit_progress and burn_progress sprites.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-BURN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-LIT L-BURN.
     MOVE GSP-FURNACE-LIT TO L-LIT
     MOVE GSP-FURNACE-BURN TO L-BURN
     IF L-TYPE = 10
         MOVE GSP-BLAST-LIT TO L-LIT
         MOVE GSP-BLAST-BURN TO L-BURN
     END-IF
     IF L-TYPE = 22
         MOVE GSP-SMOKER-LIT TO L-LIT
         MOVE GSP-SMOKER-BURN TO L-BURN
     END-IF
     GOBACK.
 END PROGRAM DECOR-FURNACE-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOM-DECOR.
*> USING CLIENT-STATE, left, top: the loom's pictures that need no pattern list (40-4 3.10): the empty-slot icon (16 x 16 at the slot's item cell) of the banner (slot 0), dye (1) and
*> pattern (2) slots while each is empty, and the scroll thumb 12 x 15 at (119, 13), the disabled sprite (the thumb is enabled only with a displayed list of over 16 patterns, which the
*> client does not hold: the pattern buttons, the banner previews and the maximum-layers error icon are not drawn). Nothing without the pack's sprites.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-SIZE16              BINARY-LONG VALUE 16.
 01 WS-SIZE16H             BINARY-LONG VALUE 16.
 01 WS-THUMB-W             BINARY-LONG VALUE 12.
 01 WS-THUMB-H             BINARY-LONG VALUE 15.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         IF BX-COUNT(WS-I + 1) = 0
             CALL "CONTAINER-SLOT-POS" USING BM-TYPE WS-I WS-PX WS-PY
             COMPUTE WS-X = L-LEFT + WS-PX
             COMPUTE WS-Y = L-TOP + WS-PY
             MOVE GSP-SLOT-BANNER TO WS-ROW
             IF WS-I = 1
                 MOVE GSP-SLOT-DYE TO WS-ROW
             END-IF
             IF WS-I = 2
                 MOVE GSP-SLOT-BANNER-PATTERN TO WS-ROW
             END-IF
             CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-SIZE16 WS-SIZE16H WS-DRAWN
         END-IF
     END-PERFORM
     COMPUTE WS-X = L-LEFT + 119
     COMPUTE WS-Y = L-TOP + 13
     MOVE GSP-LOOM-SCROLLER-OFF TO WS-ROW
     CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-THUMB-W WS-THUMB-H WS-DRAWN
     GOBACK.
 END PROGRAM LOOM-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CARTOGRAPHY-DECOR.
*> USING CLIENT-STATE, left, top: the cartography table's preview frames (40-4 5.7) by the item in the additional slot (slot 1): paper the scaled_map frame 66 x 66 at (67, 13); the empty map
*> (key map) the duplicated_map frame 50 x 66 at (83, 13) and again at (67, 29); a glass pane the map frame 66 x 66 at (67, 13) and the locked icon 10 x 14 at (118, 60); anything else the map frame.
*> The client holds no map saved data, so the map pixels and the error icon (a locked map or a paper that cannot extend it, drawn at (35, 31)) are not drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-W66                 BINARY-LONG VALUE 66.
 01 WS-H66                 BINARY-LONG VALUE 66.
 01 WS-W50                 BINARY-LONG VALUE 50.
 01 WS-W10                 BINARY-LONG VALUE 10.
 01 WS-H14                 BINARY-LONG VALUE 14.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     COMPUTE WS-X = L-LEFT + 67
     COMPUTE WS-Y = L-TOP + 13
     MOVE GSP-CART-MAP TO WS-ROW
     IF BX-COUNT(2) > 0
         MOVE "paper" TO WS-KEY
         CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY WS-ITEM
         IF WS-ITEM > 0 AND BX-ITEM(2) = WS-ITEM
             MOVE GSP-CART-SCALED TO WS-ROW
         END-IF
         MOVE "map" TO WS-KEY
         CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY WS-ITEM
         IF WS-ITEM > 0 AND BX-ITEM(2) = WS-ITEM
             MOVE GSP-CART-DUPLICATED TO WS-ROW
         END-IF
     END-IF
     IF WS-ROW = GSP-CART-DUPLICATED
         COMPUTE WS-X = L-LEFT + 83
         CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-W50 WS-H66 WS-DRAWN
         COMPUTE WS-X = L-LEFT + 67
         COMPUTE WS-Y = L-TOP + 29
         CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-W50 WS-H66 WS-DRAWN
     ELSE
         CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-W66 WS-H66 WS-DRAWN
     END-IF
     IF BX-COUNT(2) > 0
         MOVE "glass_pane" TO WS-KEY
         CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY WS-ITEM
         IF WS-ITEM > 0 AND BX-ITEM(2) = WS-ITEM
             COMPUTE WS-X = L-LEFT + 118
             COMPUTE WS-Y = L-TOP + 60
             MOVE GSP-CART-LOCKED TO WS-ROW
             CALL "DECOR-SPRITE" USING CLIENT-STATE WS-ROW WS-X WS-Y WS-W10 WS-H14 WS-DRAWN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CARTOGRAPHY-DECOR.
