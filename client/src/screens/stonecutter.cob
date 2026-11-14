*> The stonecutter screen's recipe list (docs/protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md section 4.9; 27 section 4.3; 002-lane-stations T5201).
*> The list is the stonecutter entries of the latest Update Recipes (0x88): the server sends the entries of the input item when a stonecutter menu is open (core
*> menu-station.cob), so every entry held is a button of the grid, in the order received, and the entry's result stack is the item drawn on it. STONECUTTER-READ keeps
*> the result item and count of the entries (at most 32); a malformed packet changes nothing. STONECUTTER-DECOR draws the 4 x 3 grid at (52, 14) of the panel, cell 16 x 18
*> from the entry at SC-START: a clickable entry (the selected one, the data slot 0, is highlighted) under the result's item stack, which the display-stack widgets of the
*> merchant screen draw (argument 800 + position). The grid's sprites (recipe, recipe_highlighted, recipe_selected) are not in the built-in pack: the entry widget is the panel
*> fallback. The scroll bar of a list over 12 entries is not drawn; the wheel moves SC-START by one row (STONECUTTER-WHEEL).
*>
*> Entry points:
*>   STONECUTTER-READ USING CLIENT-STATE, packet     Update Recipes
*>   STONECUTTER-DECOR USING CLIENT-STATE, left, top  the widgets of the grid
*>   STONECUTTER-WHEEL USING CLIENT-STATE, direction (1 down, -1 up)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STONECUTTER-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==RX-==.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEMS.
    05 WS-ENTRY OCCURS 32 TIMES.
       10 WS-ITEM           BINARY-LONG.
       10 WS-AMOUNT         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-UPDATE-RECIPES" USING PB-BUFFER RX-UPDATE-RECIPES RX-SLOT-DISPLAY-TABLE
     IF PB-ERROR = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RX-UR-CUT-COUNT
         MOVE RX-UC-DISPLAY(WS-I) TO WS-NODE
         IF WS-NODE >= 1 AND WS-NODE <= RX-SDT-COUNT
             IF RX-SDN-TYPE(WS-NODE) = RX-SDX-ITEM-STACK
                 ADD 1 TO WS-N
                 MOVE RX-SDN-ITEM(WS-NODE) TO WS-ITEM(WS-N)
                 MOVE RX-SDN-COUNT(WS-NODE) TO WS-AMOUNT(WS-N)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-N TO SC-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-ITEM(WS-I) TO SC-ITEM(WS-I)
         MOVE WS-AMOUNT(WS-I) TO SC-AMOUNT(WS-I)
     END-PERFORM
     MOVE 0 TO SC-START
     GOBACK.
 END PROGRAM STONECUTTER-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STONECUTTER-DECOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 16.
 01 WS-H                   BINARY-LONG VALUE 18.
 01 WS-H16                 BINARY-LONG VALUE 16.
 01 WS-W16                 BINARY-LONG VALUE 16.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 11
         COMPUTE WS-INDEX = SC-START + WS-K
         IF WS-INDEX < SC-COUNT
             COMPUTE WS-X = L-LEFT + 52 + 16 * FUNCTION MOD(WS-K, 4)
             COMPUTE WS-Y = L-TOP + 14 + 18 * (WS-K / 4) + 1
             MOVE WK-ENTRY TO WS-KIND
             MOVE ACT-MENU-BUTTON TO WS-ACTION
             MOVE WS-INDEX TO WS-ARG
             MOVE 0 TO WS-STATE
             IF BM-DATA(1) = WS-INDEX
                 MOVE 1 TO WS-STATE
             END-IF
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
             MOVE SC-ITEM(WS-INDEX + 1) TO MC-DISP-ITEM(WS-K + 1)
             MOVE 1 TO MC-DISP-COUNT(WS-K + 1)
             COMPUTE WS-ARG = 800 + WS-K + 1
             MOVE WK-SLOT TO WS-KIND
             MOVE ACT-NONE TO WS-ACTION
             MOVE 3 TO WS-STATE
             COMPUTE WS-Y = WS-Y + 1
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W16 WS-H16 WS-TEXT WS-LENGTH WS-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STONECUTTER-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STONECUTTER-WHEEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DIRECTION            BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DIRECTION.
     CALL "MN4-STONE-ROWS" USING SC-COUNT WS-ROWS WS-MAX
     IF WS-MAX = 0
         GOBACK
     END-IF
     COMPUTE SC-START = SC-START + 4 * L-DIRECTION
     IF SC-START < 0
         MOVE 0 TO SC-START
     END-IF
     IF SC-START > 4 * WS-ROWS
         COMPUTE SC-START = 4 * WS-ROWS
     END-IF
     GOBACK.
 END PROGRAM STONECUTTER-WHEEL.
