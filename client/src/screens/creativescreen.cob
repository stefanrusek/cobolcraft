*> The creative inventory screen (docs/protocol/40-menus-7-creative-inventory.md sections 1, 3, 5, 6, 7, 8, 9) on the engines of creative.cob: in creative mode the inventory key opens it (screens/
*> common.cob) in place of the survival-style inventory screen. CREATIVE-OPEN selects the remembered tab; CREATIVE-BUILD draws the panel (195 x 136 at the screen centre), the displayed tabs, the
*> title, the 45 grid slots (argument 901 to 945), the 9 hotbar slots (argument 0 to 8), the scroller, the carried stack and the slot tooltip; CREATIVE-INPUT takes the wheel, the scroller drag, the
*> search text and clicks outside; CREATIVE-ACTION the tab, grid and hotbar clicks (left button, no shift); The survival inventory tab shows no inventory slots (its wrapper
*> layout, the delete slot and the player preview are not drawn), a tab is selected on press (not release) and the right button works only outside the image.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-GRID-STACK.
*> USING CLIENT-STATE, grid argument (901 to 945), count out, item out: the stack of the picker list at slot (argument - 901) of the scrolled window (empty beyond the list).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-COUNT L-ITEM.
     MOVE 0 TO L-COUNT L-ITEM
     CALL "CREATIVE-ROWS" USING CR-COUNT WS-ROWS
     CALL "CREATIVE-FIRST-ROW" USING CR-SCROLL WS-ROWS WS-FIRST
     COMPUTE WS-INDEX = WS-FIRST * 9 + L-ARG - 901 + 1
     IF WS-INDEX >= 1 AND WS-INDEX <= CR-COUNT
         MOVE CR-STACK-COUNT(WS-INDEX) TO L-COUNT
         MOVE CR-STACK-ITEM(WS-INDEX) TO L-ITEM
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-GRID-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-ENTER.
*> USING CLIENT-STATE: the screen opens on the remembered tab (the building blocks tab the first time), a tab no longer displayed gives the default tab; the search text is cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB                 BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE CR-TAB TO WS-TAB
     IF WS-TAB < 1 OR WS-TAB > 14
         MOVE 1 TO WS-TAB
     END-IF
     CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-TAB WS-SHOWN
     IF WS-SHOWN = 0
         MOVE 1 TO WS-TAB
     END-IF
     MOVE SPACES TO CR-QUERY
     MOVE 0 TO CR-QUERY-LEN CR-SCROLLING
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-TAB
     GOBACK.
 END PROGRAM CREATIVE-ENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the widgets of the creative screen (see the file header).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLLABLE          BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 01 WS-LANG-KEY            PIC X(80).
 01 WS-LANG-LENGTH         BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-LABEL-W             BINARY-LONG VALUE 160.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-NOTEXT              PIC X(512).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     GO TO MAIN-FLOW.

*> The tooltip of the slot widget just added (WS-K its argument, WS-X WS-Y its corner) when the pointer is in its cell and nothing is carried.
 HOVER.
     IF PL-CARRIED-COUNT = 0 AND WS-PX >= WS-X AND WS-PX < WS-X + 18 AND WS-PY >= WS-Y AND WS-PY < WS-Y + 18
         CALL "SLOT-TOOLTIP" USING CLIENT-STATE WS-K WS-PX WS-PY
     END-IF
     .
 MAIN-FLOW.
     COMPUTE WS-LEFT = (L-GW - 195) / 2
     COMPUTE WS-TOP = (L-GH - 136) / 2
     COMPUTE WS-PX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-PY = IN-CURSOR-Y / CL-GUI-SCALE
     MOVE SPACES TO WS-NOTEXT
     MOVE 0 TO WS-ZERO
     MOVE WK-OVERLAY TO WS-KIND
     MOVE ACT-NONE TO WS-ACTION
     MOVE SW-PANEL TO WS-SWATCH
     MOVE 195 TO WS-W
     MOVE 136 TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-LEFT WS-TOP WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
*>   The tabs: a box (the selected one marked) and a clickable area over it.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-I WS-SHOWN
         IF WS-SHOWN = 1
             CALL "CREATIVE-TAB-BOX" USING WS-I WS-LEFT WS-TOP WS-X WS-Y WS-IX WS-IY
             MOVE SW-BUTTON TO WS-SWATCH
             IF WS-I = CR-TAB
                 MOVE SW-SELECTED TO WS-SWATCH
             END-IF
             MOVE 26 TO WS-W
             MOVE 32 TO WS-H
             MOVE WK-OVERLAY TO WS-KIND
             MOVE ACT-NONE TO WS-ACTION
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
             MOVE WK-IMAGE TO WS-KIND
             MOVE ACT-CREATIVE-TAB TO WS-ACTION
             MOVE WS-I TO WS-ARG
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
         END-IF
     END-PERFORM
*>   The selected tab's title at (8, 6).
     CALL "CREATIVE-TAB" USING CR-TAB WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLLABLE WS-SHOWTITLE WS-TITLE
     IF WS-SHOWTITLE = 1
         MOVE WS-TITLE TO WS-LANG-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TITLE)) TO WS-LANG-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-LANG-KEY WS-LANG-LENGTH WS-OUT WS-OUT-LENGTH
         COMPUTE WS-X = WS-LEFT + 8
         COMPUTE WS-Y = WS-TOP + 6
         MOVE WK-LABEL TO WS-KIND
         MOVE ACT-NONE TO WS-ACTION
         MOVE 0 TO WS-ARG
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-OUT WS-OUT-LENGTH WS-STATE
     END-IF
*>   The scroller (12 x 15) when the tab scrolls.
     CALL "CREATIVE-ROWS" USING CR-COUNT WS-ROWS
     IF WS-SCROLLABLE = 1 AND CR-COUNT > 45
         CALL "CREATIVE-SCROLLER-Y" USING CR-SCROLL WS-Y
         COMPUTE WS-Y = WS-TOP + WS-Y
         COMPUTE WS-X = WS-LEFT + 175
         MOVE 12 TO WS-W
         MOVE 15 TO WS-H
         MOVE SW-SELECTED TO WS-SWATCH
         MOVE WK-OVERLAY TO WS-KIND
         MOVE ACT-NONE TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
     END-IF
*>   The grid (not on the survival inventory tab) and the hotbar.
     IF WS-TYPE NOT = 2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 44
             COMPUTE WS-K = 901 + WS-I
             COMPUTE WS-CELL = WS-I / 9
             COMPUTE WS-X = WS-LEFT + 9 - 1 + 18 * FUNCTION MOD(WS-I, 9)
             COMPUTE WS-Y = WS-TOP + 18 - 1 + 18 * WS-CELL
             MOVE ACT-CREATIVE-GRID TO WS-ACTION
             CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-K WS-X WS-Y WS-ACTION
             MOVE 18 TO SM-W-W(SM-WIDGET-COUNT) SM-W-H(SM-WIDGET-COUNT)
             PERFORM HOVER
         END-PERFORM
     END-IF
*>   6.4: the survival tab shows the 27 main slots (arguments 9 to 35 at (9 + 18 col, 54 + 18 row); the armour and off-hand wrappers are not kept by this client) and the delete slot at (173, 112).
     IF WS-TYPE = 2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 26
             COMPUTE WS-K = 9 + WS-I
             COMPUTE WS-X = WS-LEFT + 9 - 1 + 18 * FUNCTION MOD(WS-I, 9)
             COMPUTE WS-CELL = WS-I / 9
             COMPUTE WS-Y = WS-TOP + 54 - 1 + 18 * WS-CELL
             MOVE ACT-CREATIVE-HOTBAR TO WS-ACTION
             CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-K WS-X WS-Y WS-ACTION
             MOVE 18 TO SM-W-W(SM-WIDGET-COUNT) SM-W-H(SM-WIDGET-COUNT)
             PERFORM HOVER
         END-PERFORM
         MOVE 99 TO WS-ARG
         MOVE WK-IMAGE TO WS-KIND
         MOVE ACT-CREATIVE-HOTBAR TO WS-ACTION
         COMPUTE WS-X = WS-LEFT + 173 - 1
         COMPUTE WS-Y = WS-TOP + 112 - 1
         MOVE 18 TO WS-W WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         MOVE WS-I TO WS-K
         COMPUTE WS-X = WS-LEFT + 9 - 1 + 18 * WS-I
         COMPUTE WS-Y = WS-TOP + 112 - 1
         MOVE ACT-CREATIVE-HOTBAR TO WS-ACTION
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-K WS-X WS-Y WS-ACTION
         MOVE 18 TO SM-W-W(SM-WIDGET-COUNT) SM-W-H(SM-WIDGET-COUNT)
         PERFORM HOVER
     END-PERFORM
*>   The search text in the search tab at (82, 6).
     IF WS-TYPE = 4 AND CR-QUERY-LEN > 0
         MOVE SPACES TO WS-TEXT
         MOVE CR-QUERY(1:CR-QUERY-LEN) TO WS-TEXT
         COMPUTE WS-X = WS-LEFT + 82
         COMPUTE WS-Y = WS-TOP + 6
         MOVE WK-LABEL TO WS-KIND
         MOVE ACT-NONE TO WS-ACTION
         MOVE 0 TO WS-ARG
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-TEXT CR-QUERY-LEN WS-STATE
     END-IF
     IF PL-CARRIED-COUNT > 0
         MOVE 36 TO WS-K
         COMPUTE WS-X = WS-PX - 8
         COMPUTE WS-Y = WS-PY - 8
         MOVE ACT-NONE TO WS-ACTION
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-K WS-X WS-Y WS-ACTION
     END-IF
     GOBACK.

 END PROGRAM CREATIVE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-ACTION.
*> USING CLIENT-STATE, action, argument: ACT-CREATIVE-TAB selects the tab (CREATIVE-SELECT); ACT-CREATIVE-GRID is a left click on a grid slot (CREATIVE-GRID-CLICK on the stack there); ACT-CREATIVE-HOTBAR a
*> left click on a hotbar slot: an empty cursor takes the slot's stack, a stack on the cursor goes into an empty slot, tops up the same item up to its maximum or swaps with another item; the slot
*> change is sent as Set Creative Mode Slot 36 + slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-QUICK               BINARY-LONG VALUE 0.
 01 WS-CLONE               BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-HC                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     EVALUATE L-ACTION
         WHEN ACT-CREATIVE-TAB
             CALL "CREATIVE-SELECT" USING CLIENT-STATE L-ARG
             MOVE SPACES TO CR-QUERY
             MOVE 0 TO CR-QUERY-LEN
         WHEN ACT-CREATIVE-GRID
             CALL "CREATIVE-GRID-STACK" USING CLIENT-STATE L-ARG WS-COUNT WS-ITEM
             COMPUTE WS-QUICK = FUNCTION MOD(IN-MODS / CC-MOD-SHIFT, 2)
             CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
         WHEN ACT-CREATIVE-HOTBAR
             COMPUTE WS-QUICK = FUNCTION MOD(IN-MODS / CC-MOD-SHIFT, 2)
*>           5.3, 7.1 rules 8 and 9 (the survival tab's delete slot, argument 99): a shift click empties every slot of the inventory menu, any other click empties the cursor.
             IF L-ARG = 99
                 IF WS-QUICK = 1
                     CALL "CREATIVE-DELETE-ALL" USING CLIENT-STATE
                 ELSE
                     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
                 END-IF
                 GOBACK
             END-IF
             COMPUTE WS-SLOT = L-ARG + 1
             MOVE PL-SLOT-COUNT(WS-SLOT) TO WS-HC
             MOVE PL-SLOT-ITEM(WS-SLOT) TO WS-HI
*>           5.3 quickMoveStack: a shift click on a hotbar slot with a stack deletes it (and sends the empty slot).
             IF WS-QUICK = 1 AND L-ARG < 9 AND WS-HC > 0
                 MOVE 0 TO PL-SLOT-COUNT(WS-SLOT) PL-SLOT-ITEM(WS-SLOT)
                 COMPUTE WS-WIRE = 36 + L-ARG
                 CALL "CREATIVE-SEND" USING CLIENT-STATE WS-WIRE PL-SLOT-COUNT(WS-SLOT) PL-SLOT-ITEM(WS-SLOT)
                 GOBACK
             END-IF
             EVALUATE TRUE
                 WHEN PL-CARRIED-COUNT = 0 AND WS-HC > 0
                     MOVE WS-HI TO PL-CARRIED-ITEM
                     MOVE WS-HC TO PL-CARRIED-COUNT
                     MOVE 0 TO PL-SLOT-COUNT(WS-SLOT) PL-SLOT-ITEM(WS-SLOT)
                 WHEN PL-CARRIED-COUNT > 0 AND WS-HC = 0
                     MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-SLOT)
                     MOVE PL-CARRIED-COUNT TO PL-SLOT-COUNT(WS-SLOT)
                     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
                 WHEN PL-CARRIED-COUNT > 0 AND PL-CARRIED-ITEM = WS-HI
                     CALL "CREATIVE-MAX-STACK" USING CLIENT-STATE WS-HI WS-MAX
                     COMPUTE WS-ROOM = FUNCTION MAX(WS-MAX - WS-HC, 0)
                     IF WS-ROOM > PL-CARRIED-COUNT
                         MOVE PL-CARRIED-COUNT TO WS-ROOM
                     END-IF
                     ADD WS-ROOM TO PL-SLOT-COUNT(WS-SLOT)
                     SUBTRACT WS-ROOM FROM PL-CARRIED-COUNT
                     IF PL-CARRIED-COUNT = 0
                         MOVE 0 TO PL-CARRIED-ITEM
                     END-IF
                 WHEN PL-CARRIED-COUNT > 0
                     MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-SLOT)
                     MOVE PL-CARRIED-COUNT TO PL-SLOT-COUNT(WS-SLOT)
                     MOVE WS-HI TO PL-CARRIED-ITEM
                     MOVE WS-HC TO PL-CARRIED-COUNT
             END-EVALUATE
             IF L-ARG >= 9
                 MOVE L-ARG TO WS-WIRE
             ELSE
                 COMPUTE WS-WIRE = 36 + L-ARG
             END-IF
             CALL "CREATIVE-SEND" USING CLIENT-STATE WS-WIRE PL-SLOT-COUNT(WS-SLOT) PL-SLOT-ITEM(WS-SLOT)
     END-EVALUATE
     GOBACK.
 END PROGRAM CREATIVE-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SLOT-RIGHT.
*> USING CLIENT-STATE, slot argument (0 to 8 the hotbar, 9 to 35 the main inventory of the survival tab): the right click of 40-1 3.4: an empty cursor takes half of the stack (the larger half), a stack on
*> the cursor puts one into an empty slot or onto the same item (up to its maximum), a different item swaps; the slot change is sent as Set Creative Mode Slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HC                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG.
     COMPUTE WS-SLOT = L-ARG + 1
     MOVE PL-SLOT-COUNT(WS-SLOT) TO WS-HC
     MOVE PL-SLOT-ITEM(WS-SLOT) TO WS-HI
     EVALUATE TRUE
         WHEN PL-CARRIED-COUNT = 0 AND WS-HC > 0
             COMPUTE WS-HALF = (WS-HC + 1) / 2
             MOVE WS-HI TO PL-CARRIED-ITEM
             MOVE WS-HALF TO PL-CARRIED-COUNT
             SUBTRACT WS-HALF FROM PL-SLOT-COUNT(WS-SLOT)
             IF PL-SLOT-COUNT(WS-SLOT) = 0
                 MOVE 0 TO PL-SLOT-ITEM(WS-SLOT)
             END-IF
         WHEN PL-CARRIED-COUNT > 0 AND WS-HC = 0
             MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-SLOT)
             MOVE 1 TO PL-SLOT-COUNT(WS-SLOT)
             SUBTRACT 1 FROM PL-CARRIED-COUNT
             IF PL-CARRIED-COUNT = 0
                 MOVE 0 TO PL-CARRIED-ITEM
             END-IF
         WHEN PL-CARRIED-COUNT > 0 AND PL-CARRIED-ITEM = WS-HI
             CALL "CREATIVE-MAX-STACK" USING CLIENT-STATE WS-HI WS-MAX
             IF WS-HC < WS-MAX
                 ADD 1 TO PL-SLOT-COUNT(WS-SLOT)
                 SUBTRACT 1 FROM PL-CARRIED-COUNT
                 IF PL-CARRIED-COUNT = 0
                     MOVE 0 TO PL-CARRIED-ITEM
                 END-IF
             END-IF
         WHEN PL-CARRIED-COUNT > 0
             MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-SLOT)
             MOVE PL-CARRIED-COUNT TO PL-SLOT-COUNT(WS-SLOT)
             MOVE WS-HI TO PL-CARRIED-ITEM
             MOVE WS-HC TO PL-CARRIED-COUNT
         WHEN OTHER
             GOBACK
     END-EVALUATE
     IF L-ARG >= 9
         MOVE L-ARG TO WS-WIRE
     ELSE
         COMPUTE WS-WIRE = 36 + L-ARG
     END-IF
     CALL "CREATIVE-SEND" USING CLIENT-STATE WS-WIRE PL-SLOT-COUNT(WS-SLOT) PL-SLOT-ITEM(WS-SLOT)
     GOBACK.
 END PROGRAM CREATIVE-SLOT-RIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-INPUT.
*> USING CLIENT-STATE: the wheel moves the scroll (CREATIVE-WHEEL); a press on the scrollbar box (x 175 to 188, y 18 to 129 of the panel, when the tab scrolls and the list is over 45) starts the
*> drag, which follows the pointer (CREATIVE-DRAG) until the release; a press outside the image and outside the displayed tabs with a stack on the cursor drops it (CREATIVE-OUTSIDE: the left button
*> all, the right button one); in the search tab typed characters and Backspace edit the search text and refilter (CREATIVE-SEARCH).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-WHEEL               FLOAT-SHORT.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-COUNT               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLLABLE          BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 01 WS-ZQ                  BINARY-LONG VALUE 0.
 01 WS-ZC                  BINARY-LONG VALUE 0.
 01 WS-CELL                BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     COMPUTE WS-GW = FUNCTION MAX(IN-WIN-W / CL-GUI-SCALE, CL-MIN-GUI-W)
     COMPUTE WS-GH = FUNCTION MAX(IN-WIN-H / CL-GUI-SCALE, CL-MIN-GUI-H)
     COMPUTE WS-LEFT = (WS-GW - 195) / 2
     COMPUTE WS-TOP = (WS-GH - 136) / 2
     CALL "CREATIVE-TAB" USING CR-TAB WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLLABLE WS-SHOWTITLE WS-TITLE
     CALL "CREATIVE-ROWS" USING CR-COUNT WS-ROWS
     IF IN-SCROLL-Y NOT = 0 AND WS-SCROLLABLE = 1 AND CR-COUNT > 45
         MOVE IN-SCROLL-Y TO WS-WHEEL
         CALL "CREATIVE-WHEEL" USING CR-SCROLL WS-WHEEL WS-ROWS
     END-IF
     COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
     COMPUTE WS-Y = IN-CLICK-Y / CL-GUI-SCALE
     IF IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1 AND WS-SCROLLABLE = 1 AND CR-COUNT > 45
             AND WS-X >= WS-LEFT + 175 AND WS-X < WS-LEFT + 189 AND WS-Y >= WS-TOP + 18 AND WS-Y < WS-TOP + 130
         MOVE 1 TO CR-SCROLLING
     END-IF
     IF CR-SCROLLING = 1 AND IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 1
         COMPUTE WS-Y = IN-CURSOR-Y / CL-GUI-SCALE
         CALL "CREATIVE-DRAG" USING WS-Y WS-TOP CR-SCROLL
     END-IF
     IF IN-BUTTON-RELEASED(CC-BUTTON-LEFT + 1) = 1
         MOVE 0 TO CR-SCROLLING
     END-IF
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1
         COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
         COMPUTE WS-Y = IN-CLICK-Y / CL-GUI-SCALE
         IF WS-X >= WS-LEFT + 8 AND WS-X < WS-LEFT + 170 AND WS-Y >= WS-TOP + 111 AND WS-Y < WS-TOP + 129
             COMPUTE WS-COUNT = (WS-X - WS-LEFT - 8) / 18
             CALL "CREATIVE-SLOT-RIGHT" USING CLIENT-STATE WS-COUNT
         END-IF
         IF WS-TYPE = 2 AND WS-X >= WS-LEFT + 8 AND WS-X < WS-LEFT + 170 AND WS-Y >= WS-TOP + 53 AND WS-Y < WS-TOP + 107
             COMPUTE WS-CELL = (WS-Y - WS-TOP - 53) / 18
             COMPUTE WS-COUNT = 9 + WS-CELL * 9 + (WS-X - WS-LEFT - 8) / 18
             CALL "CREATIVE-SLOT-RIGHT" USING CLIENT-STATE WS-COUNT
         END-IF
     END-IF
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND WS-TYPE NOT = 2
         COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
         COMPUTE WS-Y = IN-CLICK-Y / CL-GUI-SCALE
         IF WS-X >= WS-LEFT + 8 AND WS-X < WS-LEFT + 170 AND WS-Y >= WS-TOP + 17 AND WS-Y < WS-TOP + 107
             COMPUTE WS-COUNT = (WS-X - WS-LEFT - 8) / 18
             COMPUTE WS-CHANGED = (WS-Y - WS-TOP - 17) / 18
             COMPUTE WS-CELL = 901 + WS-CHANGED * 9 + WS-COUNT
             CALL "CREATIVE-GRID-STACK" USING CLIENT-STATE WS-CELL WS-COUNT WS-HIT
             MOVE 1 TO WS-BUTTON
             CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-HIT WS-COUNT WS-BUTTON WS-ZQ WS-ZC
         END-IF
     END-IF
     PERFORM VARYING WS-BUTTON FROM 0 BY 1 UNTIL WS-BUTTON > 1
         IF IN-BUTTON-PRESSED(WS-BUTTON + 1) = 1 AND PL-CARRIED-COUNT > 0
             COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
             COMPUTE WS-Y = IN-CLICK-Y / CL-GUI-SCALE
             MOVE 0 TO WS-HIT
             IF WS-X >= WS-LEFT AND WS-X < WS-LEFT + 195 AND WS-Y >= WS-TOP AND WS-Y < WS-TOP + 136
                 MOVE 1 TO WS-HIT
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14 OR WS-HIT = 1
                 CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-I WS-SHOWN
                 IF WS-SHOWN = 1
                     COMPUTE WS-COUNT = WS-X - WS-LEFT
                     COMPUTE WS-CHANGED = WS-Y - WS-TOP
                     CALL "CREATIVE-TAB-HIT" USING WS-I WS-COUNT WS-CHANGED WS-HIT
                 END-IF
             END-PERFORM
             IF WS-HIT = 0
                 CALL "CREATIVE-OUTSIDE" USING CLIENT-STATE WS-BUTTON
             END-IF
         END-IF
     END-PERFORM
     IF WS-TYPE = 4
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) < 127 AND CR-QUERY-LEN < 50
                 ADD 1 TO CR-QUERY-LEN
                 MOVE FUNCTION CHAR(IN-TEXT(WS-I) + 1) TO CR-QUERY(CR-QUERY-LEN:1)
                 MOVE 1 TO WS-CHANGED
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND CR-QUERY-LEN > 0
             MOVE CR-QUERY TO WS-LINE
             MOVE CR-QUERY-LEN TO WS-LEN
             CALL "TEXT-DROP-LAST" USING WS-LINE WS-LEN
             MOVE WS-LINE TO CR-QUERY
             MOVE WS-LEN TO CR-QUERY-LEN
             MOVE 1 TO WS-CHANGED
         END-IF
         IF WS-CHANGED = 1
             CALL "CREATIVE-SEARCH" USING CLIENT-STATE CR-QUERY CR-QUERY-LEN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-INPUT.
