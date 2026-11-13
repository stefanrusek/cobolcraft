*> The inventory screen (US4-6, US9; client-surface §3 E; data-model §4 Inventory; 12 §5.6a; 13 §3.5; 09 §3.2 Container Click 0x12,
*> Set Creative Mode Slot 0x39): the 46-slot inventory menu on the 176 x 166 sheet of the built-in pack (or the pack's inventory
*> texture): the title "Crafting" at (97, 6), armour at (8, 8 + 18 i), the result at (154, 28), the 2 x 2 grid at (98 + 18 col, 18 + 18
*> row), the main inventory at (8 + 18 col, 84 + 18 row), the hotbar at (8 + 18 i, 142) and the off hand at (77, 62), each an item slot
*> widget (18 x 18 around the 16 x 16 icon cell, bare: the sheet carries the wells) that moves items when clicked, and the stack on
*> the cursor drawn at the pointer. MENU-BUILD lays out either menu (type 0 the inventory menu, 12 the crafting bench, screens/bench.cob).
*> The widget argument names the stack (menu.cob); the slot number that Container Click carries is the menu's (MENU-SLOT-WIRE).
*> INVENTORY-CLICK carries out a left click on a slot: the click is predicted on the replica (INV-PICKUP), then sent, in survival as
*> Container Click with the changed slot and the cursor, in creative as Set Creative Mode Slot of the changed slot (the cursor is the
*> client's).
*> The throws, drags, shift clicks and the other clicks of this screen are MENU-POINTER (screens/pointer.cob), which calls INVENTORY-CLICK-B for a
*> click it predicts.
*> INVENTORY-CLOSE (when the screen is left, in play) puts the carried stack back into the slots as the server's INV-ADD does (stacks
*> of its item first, then empty slots; the rest is thrown by the server), in creative sends Set Creative Mode Slot of each slot it
*> went to, and sends Container Close.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     CALL "MENU-BUILD" USING CLIENT-STATE L-GW L-GH WS-TYPE
     GOBACK.
 END PROGRAM INVENTORY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-ADD.
*> USING CLIENT-STATE, widget argument, left, top (the sheet's origin), slot x, slot y (the item cell, in the sheet): one bare
*> item slot widget of 18 x 18 GUI pixels, 1 pixel out of the cell on each side.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-SLOT.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-LEFT L-TOP L-SX L-SY.
     COMPUTE WS-X = L-LEFT + L-SX - 1
     COMPUTE WS-Y = L-TOP + L-SY - 1
     CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE L-ARG WS-X WS-Y WS-ACTION
     MOVE 18 TO SM-W-W(SM-WIDGET-COUNT) SM-W-H(SM-WIDGET-COUNT)
     MOVE 3 TO SM-W-STATE(SM-WIDGET-COUNT)
*>   40-1 5.6: the item tooltip of the slot under the pointer while nothing is carried (the inventory and crafting screens).
     COMPUTE WS-PX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-PY = IN-CURSOR-Y / CL-GUI-SCALE
     IF PL-CARRIED-COUNT = 0 AND WS-PX >= WS-X AND WS-PX < WS-X + 18 AND WS-PY >= WS-Y AND WS-PY < WS-Y + 18
         CALL "SLOT-TOOLTIP" USING CLIENT-STATE L-ARG WS-PX WS-PY
     END-IF
     GOBACK.
 END PROGRAM MENU-SLOT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height, menu type (0 inventory menu, 12 crafting bench).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.crafting.title".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 32.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-CURSOR              BINARY-LONG VALUE 36.
 01 WS-SHEET-KIND          BINARY-LONG VALUE WK-SHEET.
 01 WS-SHEET-ROW           BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 176.
 01 WS-H                   BINARY-LONG VALUE 166.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-PX                  BINARY-LONG.
 01 WS-SEE                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH L-TYPE.
     CALL "RECIPE-BOOK-GEOMETRY" USING CLIENT-STATE L-GW L-GH WS-LEFT WS-TOP WS-PX
     MOVE SPACES TO WS-TEXT
*>   The effects panel of the survival inventory (49 section 3), drawn first (under the container); where it has no room the
*>   world HUD's icons are drawn instead (49 section 2.1).
     IF L-TYPE = 0
         CALL "EFFECTS-PANEL-ADD" USING CLIENT-STATE L-GW WS-LEFT WS-TOP WS-SEE
         IF WS-SEE = 0
             CALL "EFFECTS-HUD-ADD" USING CLIENT-STATE L-GW L-GH
         END-IF
     END-IF
     MOVE GSP-SHEET-INVENTORY TO WS-SHEET-ROW
     IF L-TYPE = 12
         MOVE GSP-SHEET-BENCH TO WS-SHEET-ROW
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-SHEET-KIND WS-NONE WS-SHEET-ROW WS-LEFT WS-TOP WS-W WS-H
         WS-TEXT WS-LENGTH WS-STATE
*>   The title: "Crafting" at x 97 in the inventory, 29 in the bench; y 6.
     COMPUTE WS-X = WS-LEFT + 97
     IF L-TYPE = 12
         COMPUTE WS-X = WS-LEFT + 29
     END-IF
     COMPUTE WS-Y = WS-TOP + 6
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY WS-KEY-LENGTH
*>   The main inventory and the hotbar, the same in both menus.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 35
         IF WS-I < 9
             MOVE WS-I TO WS-C
             MOVE 142 TO WS-Y
         ELSE
             COMPUTE WS-R = (WS-I - 9) / 9
             COMPUTE WS-C = WS-I - 9 - WS-R * 9
             COMPUTE WS-Y = 84 + WS-R * 18
         END-IF
         COMPUTE WS-X = 8 + WS-C * 18
         MOVE WS-I TO WS-ARG
         CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
     END-PERFORM
     IF L-TYPE = 12
*>       The result and the 3 x 3 grid.
         MOVE 105 TO WS-ARG
         MOVE 124 TO WS-X
         MOVE 35 TO WS-Y
         CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
             COMPUTE WS-ARG = 106 + WS-I
             COMPUTE WS-R = WS-I / 3
             COMPUTE WS-C = WS-I - WS-R * 3
             COMPUTE WS-X = 30 + 18 * WS-C
             COMPUTE WS-Y = 17 + 18 * WS-R
             CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
         END-PERFORM
     ELSE
*>       Armour, the result, the 2 x 2 grid and the off hand.
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-ARG = 101 + WS-I
             MOVE 8 TO WS-X
             COMPUTE WS-Y = 8 + 18 * WS-I
             CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
         END-PERFORM
         MOVE 105 TO WS-ARG
         MOVE 154 TO WS-X
         MOVE 28 TO WS-Y
         CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-ARG = 106 + WS-I
             COMPUTE WS-R = WS-I / 2
             COMPUTE WS-C = WS-I - WS-R * 2
             COMPUTE WS-X = 98 + 18 * WS-C
             COMPUTE WS-Y = 18 + 18 * WS-R
             CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
         END-PERFORM
         MOVE 37 TO WS-ARG
         MOVE 77 TO WS-X
         MOVE 62 TO WS-Y
         CALL "MENU-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-LEFT WS-TOP WS-X WS-Y
     END-IF
     CALL "RECIPE-GHOST-BUILD" USING CLIENT-STATE WS-LEFT WS-TOP L-TYPE
     CALL "RECIPE-BOOK-BUILD" USING CLIENT-STATE L-GH WS-LEFT WS-TOP WS-PX L-TYPE
     IF PL-CARRIED-COUNT > 0
         COMPUTE WS-X = IN-CURSOR-X / CL-GUI-SCALE - 8
         COMPUTE WS-Y = IN-CURSOR-Y / CL-GUI-SCALE - 8
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-CURSOR WS-X WS-Y WS-NONE
     END-IF
     GOBACK.
 END PROGRAM MENU-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-CLICK-B.
*> USING CLIENT-STATE, widget argument (menu.cob), button (0 left, 1 right).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-WIRE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-PICKUP              BINARY-LONG VALUE 0.
 01 WS-CHANGED             BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-BUTTON.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-BUTTON TO WS-BUTTON
     CALL "MENU-SLOT-WIRE" USING CLIENT-STATE L-ARG WS-WIRE
     IF L-ARG >= 106 AND L-ARG <= 114
         MOVE 0 TO RK-GHOST-W RK-LAST-PLACED
     END-IF
     IF WS-WIRE >= 0
         CALL "INV-PICKUP-B" USING CLIENT-STATE L-ARG L-BUTTON
         CALL "MENU-STACK-GET" USING CLIENT-STATE L-ARG WS-COUNT WS-ITEM WS-DAMAGE
         CALL "PB-RESET" USING PB-BUFFER
         MOVE 0 TO WS-CONTAINER
         MOVE PL-INV-STATE-ID TO WS-STATE-ID
         IF SM-SCREEN = SCR-BENCH OR SM-SCREEN = SCR-CONTAINER
             MOVE BM-ID TO WS-CONTAINER
             MOVE BM-STATE-ID TO WS-STATE-ID
         END-IF
         IF PL-MODE = 1 AND SM-SCREEN = SCR-INVENTORY
             CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER WS-WIRE WS-COUNT WS-ITEM
         ELSE
             CALL "CLP-MENU-CLICK-AS" USING PB-BUFFER WS-CONTAINER WS-STATE-ID WS-WIRE WS-BUTTON
                 WS-PICKUP WS-CHANGED WS-COUNT WS-ITEM PL-CARRIED-COUNT PL-CARRIED-ITEM
         END-IF
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM INVENTORY-CLICK-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-AT.
*> USING CLIENT-STATE, x, y (GUI pixels), argument out: the argument of the slot widget at that point (the cursor's stack excluded), -1 for none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-ARG.
     MOVE -1 TO L-ARG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) NOT = 36 AND (SM-W-ARG(WS-I) < 200 OR SM-W-ARG(WS-I) >= 401)
                 AND L-X >= SM-W-X(WS-I) AND L-X < SM-W-X(WS-I) + SM-W-W(WS-I)
                 AND L-Y >= SM-W-Y(WS-I) AND L-Y < SM-W-Y(WS-I) + SM-W-H(WS-I)
             MOVE SM-W-ARG(WS-I) TO L-ARG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-SLOT-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-CLOSE.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-PASS                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "ITEM-MAX-STACK" USING PL-CARRIED-ITEM WS-MAX
*>   Pass 1: stacks of the carried item below the maximum; pass 2: empty slots.
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR PL-CARRIED-COUNT = 0
             MOVE 0 TO WS-N
             IF WS-PASS = 1 AND PL-SLOT-COUNT(WS-S) > 0
                     AND PL-SLOT-ITEM(WS-S) = PL-CARRIED-ITEM
                 COMPUTE WS-N = FUNCTION MIN(PL-CARRIED-COUNT, WS-MAX - PL-SLOT-COUNT(WS-S))
             END-IF
             IF WS-PASS = 2 AND PL-SLOT-COUNT(WS-S) = 0
                 COMPUTE WS-N = FUNCTION MIN(PL-CARRIED-COUNT, WS-MAX)
             END-IF
             IF WS-N > 0
                 MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-S)
                 ADD WS-N TO PL-SLOT-COUNT(WS-S)
                 SUBTRACT WS-N FROM PL-CARRIED-COUNT
                 COMPUTE WS-ARG = WS-S - 1
                 CALL "MENU-SLOT-WIRE" USING CLIENT-STATE WS-ARG WS-SLOT
                 IF PL-MODE = 1
                     CALL "PB-RESET" USING PB-BUFFER
                     CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER WS-SLOT PL-SLOT-COUNT(WS-S)
                         PL-SLOT-ITEM(WS-S)
                     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "MENU-CONTAINER" USING CLIENT-STATE WS-CONTAINER WS-STATE-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MENU-CLOSE" USING PB-BUFFER WS-CONTAINER
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     IF SM-SCREEN = SCR-BENCH OR SM-SCREEN = SCR-CONTAINER
         MOVE 0 TO BM-ID
     END-IF
     GOBACK.
 END PROGRAM INVENTORY-CLOSE.
