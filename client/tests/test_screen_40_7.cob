*> Test US12-client (spec 002 T3262 to T3281, in one file; docs/protocol/40-menus-7-creative-inventory.md): the creative inventory's engines (client/src/screens/creative.cob), without
*> the screen widgets. Tabs (2.2: 14 in registry order with row, column, type, alignment), their boxes (3.1, worked example 11.1 at left 329, top 172), hit boxes (3.2), displayed tabs
*> (an empty CATEGORY tab is hidden), content lists (stand-in membership: block items, tools, food, the rest), the scroll maths (5.2, worked example 11.2 and 11.3), the grid click
*> table (7.3), outside drops (7.5), delete-all and drops with the throttler (9.1, 9.3), the swap (7.3), the name search (8.1) and the saved hotbars (10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 PIC X(24).
 01 WS-TITLE               PIC X(32).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLLABLE          BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG VALUE 329.
 01 WS-TOP                 BINARY-LONG VALUE 172.
 01 WS-ROWS                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SCROLL              FLOAT-SHORT.
 01 WS-WHEEL               FLOAT-SHORT.
 01 WS-MILLI               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-QUICK               BINARY-LONG.
 01 WS-CLONE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-QUERY               PIC X(64).
 01 WS-QLEN                BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-PACKETS             BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 1 TO PL-MODE
     MOVE "T" TO TL-MODE
*>   2.2 the registry: key row column type right-aligned scrollbar title (type 1 category, 2 inventory, 3 hotbar, 4 search).
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "CREATIVE-TAB" USING WS-I WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLLABLE WS-SHOWTITLE WS-TITLE
         MOVE WS-ROW TO WS-E1
         MOVE WS-COL TO WS-E2
         MOVE WS-TYPE TO WS-E3
         MOVE WS-RIGHT TO WS-E4
         STRING FUNCTION TRIM(WS-KEY) ":" FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 40-7§2 the 14 tabs in registry order with row (0 top), column, type and right alignment" TO TL-CASE
     MOVE "building_blocks:0010 colored_blocks:0110 natural_blocks:0210 functional_blocks:0310 redstone_blocks:0410 hotbar:0531 search:0641 tools_and_utilities:1010 combat:1110 food_and_drinks:1210 ingredients:1310 spawn_eggs:1410 op_blocks:1511 inventory:1621 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-I
     CALL "CREATIVE-TAB" USING WS-I WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLLABLE WS-SHOWTITLE WS-TITLE
     MOVE "acceptance US12 40-7§2.1 the survival inventory tab has no scrollbar and no title; its title key is itemGroup.inventory" TO TL-CASE
     MOVE FUNCTION TRIM(WS-TITLE) TO TL-OBSERVED
     MOVE WS-SCROLLABLE TO WS-E1
     MOVE WS-SHOWTITLE TO WS-E2
     STRING FUNCTION TRIM(WS-TITLE) " " FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "itemGroup.inventory 00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3.1 boxes at left 329, top 172 (worked example 11.1): x y icon x icon y for the search, inventory and tools tabs, and the hit tests (3.2) of the search tab.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 7 BY 1 UNTIL WS-I > 14
         IF WS-I = 7 OR WS-I = 8 OR WS-I = 14
             CALL "CREATIVE-TAB-BOX" USING WS-I WS-LEFT WS-TOP WS-X WS-Y WS-IX WS-IY
             MOVE WS-X TO WS-E1
             MOVE WS-Y TO WS-E2
             MOVE WS-IX TO WS-E3
             MOVE WS-IY TO WS-E4
             STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "," FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-7§11.1 tab boxes: search (498, 144) icon (503, 153); tools (329, 304) icon (334, 311); inventory (498, 304) icon (503, 311)" TO TL-CASE
     MOVE "498,144,503,153 329,304,334,311 498,304,503,311 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 7 TO WS-I
     MOVE 169 TO WS-X
     MOVE -32 TO WS-Y
     CALL "CREATIVE-TAB-HIT" USING WS-I WS-X WS-Y WS-HIT
     MOVE "acceptance US12 40-7§3.2 the hit box of the search tab is inclusive: its top-left corner (169, -32) hits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 195 TO WS-X
     MOVE 0 TO WS-Y
     CALL "CREATIVE-TAB-HIT" USING WS-I WS-X WS-Y WS-HIT
     MOVE "acceptance US12 40-7§3.2 the bottom-right corner (195, 0) hits too" TO TL-CASE
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 196 TO WS-X
     CALL "CREATIVE-TAB-HIT" USING WS-I WS-X WS-Y WS-HIT
     MOVE "acceptance US12 40-7§3.2 one pixel right of the box misses" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-I
     MOVE 170 TO WS-X
     MOVE 140 TO WS-Y
     CALL "CREATIVE-TAB-HIT" USING WS-I WS-X WS-Y WS-HIT
     MOVE "acceptance US12 40-7§3.2 a bottom-row tab is hit from y 136 to 168: (170, 140) hits the inventory tab" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Content: select the building blocks tab: the stand-in rule puts the items that place a block (11) there; the search list is the union (17).
     MOVE 1 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§4.3 building blocks (stand-in rule: items that place a block): 11 stacks of count 1" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§4.3 tools and utilities (stand-in rule: the tool classes): 2 stacks" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§4.3 food and drinks (stand-in rule: food items): 3 stacks" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§4.3 ingredients (stand-in rule: the rest, without item 0): 1 stack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§4.5 the search tab lists the union of the search lists of every other tab: 17 stacks" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.1 shouldDisplay: the CATEGORY tabs with no items are hidden; the three special tabs always show.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "CREATIVE-TAB-SHOWN" USING CLIENT-STATE WS-I WS-SHOWN
         IF WS-SHOWN = 1
             MOVE WS-I TO WS-E1
             STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-7§2.1 displayed tabs with the stand-in lists: building, hotbar, search, tools, food, ingredients, inventory" TO TL-CASE
     MOVE "1 6 7 8 10 11 14 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.2 scroll maths (examples 11.2 and 11.3).
     MOVE "N" TO TL-MODE
     MOVE 100 TO WS-COUNT
     CALL "CREATIVE-ROWS" USING WS-COUNT WS-ROWS
     MOVE "acceptance US12 40-7§11.2 100 stacks: ceil(100 / 9) - 5 = 7 scroll rows" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 45 TO WS-COUNT
     CALL "CREATIVE-ROWS" USING WS-COUNT WS-ROWS
     MOVE "acceptance US12 40-7§11.3 45 stacks give 0 rows: no scrolling" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 46 TO WS-COUNT
     CALL "CREATIVE-ROWS" USING WS-COUNT WS-ROWS
     MOVE "acceptance US12 40-7§11.3 46 stacks give 1 row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-ROWS
     MOVE 0.5 TO WS-SCROLL
     CALL "CREATIVE-FIRST-ROW" USING WS-SCROLL WS-ROWS WS-FIRST
     MOVE "acceptance US12 40-7§11.2 scroll 0.5 of 7 rows: first row (int)(3.5 + 0.5) = 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.07 TO WS-SCROLL
     CALL "CREATIVE-FIRST-ROW" USING WS-SCROLL WS-ROWS WS-FIRST
     MOVE "acceptance US12 40-7§11.2 scroll 0.07: first row (int)(0.49 + 0.5) = 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-SCROLL
     CALL "CREATIVE-FIRST-ROW" USING WS-SCROLL WS-ROWS WS-FIRST
     MOVE "acceptance US12 40-7§11.2 scroll 1.0: first row 7" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-SCROLL
     MOVE 1.0 TO WS-WHEEL
     CALL "CREATIVE-WHEEL" USING WS-SCROLL WS-WHEEL WS-ROWS
     COMPUTE WS-MILLI ROUNDED = WS-SCROLL * 1000000
     MOVE "acceptance US12 40-7§11.2 a wheel step of 1 at scroll 0.5 gives 0.5 - 1 / 7 = 0.357143" TO TL-CASE
     MOVE 357143 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CREATIVE-FIRST-ROW" USING WS-SCROLL WS-ROWS WS-FIRST
     MOVE "acceptance US12 40-7§11.2 and that scroll gives first row 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 246 TO WS-Y
     CALL "CREATIVE-DRAG" USING WS-Y WS-TOP WS-SCROLL
     COMPUTE WS-MILLI ROUNDED = WS-SCROLL * 1000
     MOVE "acceptance US12 40-7§11.2 a drag with the pointer at y 246 (top 172): (246 - 190 - 7.5) / 97 = 0.5" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-SCROLL
     CALL "CREATIVE-SCROLLER-Y" USING WS-SCROLL WS-Y
     MOVE "acceptance US12 40-7§6.2 the scroller sprite at scroll 0.5 is 18 + (int)(95 x 0.5) = 65 below the top" TO TL-CASE
     MOVE 65 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   7.3 the grid click table: carried C, grid stack S (loam, item 3, max 64): "item count" of the carried stack after each click.
     MOVE "T" TO TL-MODE
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 1 TO PL-CARRIED-COUNT
     MOVE 3 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     MOVE 0 TO WS-BUTTON WS-QUICK WS-CLONE
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 carried loam x1, left click on a loam slot: x2" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "3x2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-QUICK
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 shift-left click on the same item: the carried count becomes the maximum stack size (64)" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "3x64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-QUICK
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 left click at the maximum count: unchanged" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "3x64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BUTTON
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 right click on the same item: one less (63)" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "3x63" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-ITEM
     MOVE 0 TO WS-BUTTON
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 left click on a different item: the carried stack is deleted" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 empty carried, left click on turf x1: carried turf x1 (11.4)" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "4x1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT
     MOVE 1 TO WS-QUICK
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 empty carried, shift-click: the maximum stack size (64)" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "4x64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT WS-ITEM
     MOVE 0 TO WS-QUICK
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 left click on an empty grid slot: the carried stack is deleted" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CLONE
     MOVE 3 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 middle-button clone with an empty carried stack: the maximum stack size (64)" TO TL-CASE
     PERFORM CARRIED-TEXT
     MOVE "3x64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CLONE
*>   9.1, 7.5 and 9.3: drops. Carried loam x64, left click outside: Set Creative Mode Slot -1 with loam x64 (39 ffff 40 03 00 00).
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-BUTTON
     CALL "CREATIVE-OUTSIDE" USING CLIENT-STATE WS-BUTTON
     PERFORM FLUSH
     MOVE "acceptance US12 40-7§7.5 a left click outside drops the whole carried stack: 39 ffff 40 03 00 00" TO TL-CASE
     MOVE "39ffff40030000" TO TL-EXPECTED
     MOVE WS-TEXT(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CARRIED-TEXT
     MOVE "acceptance US12 40-7§7.5 and empties the carried stack" TO TL-CASE
     MOVE "0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 1 TO WS-BUTTON
     CALL "CREATIVE-OUTSIDE" USING CLIENT-STATE WS-BUTTON
     PERFORM FLUSH
     MOVE "acceptance US12 40-7§7.5 a right click outside drops one: 39 ffff 01 03 00 00" TO TL-CASE
     MOVE "39ffff01030000" TO TL-EXPECTED
     MOVE WS-TEXT(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CARRIED-TEXT
     MOVE "acceptance US12 40-7§7.5 and leaves 4 carried" TO TL-CASE
     MOVE "3x4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT
     CALL "CREATIVE-OUTSIDE" USING CLIENT-STATE WS-BUTTON
     PERFORM FLUSH
     MOVE "acceptance US12 40-7§7.5 an empty carried stack drops nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9.3 the throttler: step 20, threshold 1280 on the client: 64 drops pass, the 65th does not; each tick takes 1 off.
     MOVE 0 TO CR-THROTTLE
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70
         CALL "CREATIVE-DROP-OK" USING CLIENT-STATE WS-OK
         IF WS-OK = 1
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§9.3 the client throttler (step 20, threshold 1280) lets 64 drops through" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "CREATIVE-TICK" USING CLIENT-STATE
     END-PERFORM
     CALL "CREATIVE-DROP-OK" USING CLIENT-STATE WS-OK
     MOVE "acceptance US12 40-7§9.3 20 ticks later one more drop passes (the counter fell by 20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   7.3 SWAP with hotbar slot 3: the player's slot becomes the grid stack at its maximum size and Set Creative Mode Slot (39, loam x64) is sent.
     MOVE "T" TO TL-MODE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 3 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     MOVE 3 TO WS-SLOT
     CALL "CREATIVE-SWAP" USING CLIENT-STATE WS-ITEM WS-COUNT WS-SLOT
     PERFORM FLUSH
     MOVE "acceptance US12 40-7§11.5 the swap key 4 (button 3) sets the player's slot 3 to the grid stack at its maximum and sends slot 39: 39 0027 40 03 00 00" TO TL-CASE
     MOVE "39002740030000" TO TL-EXPECTED
     MOVE WS-TEXT(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-SLOT-ITEM(4) TO WS-E1
     MOVE PL-SLOT-COUNT(4) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-7§11.5 the player's slot 3 holds loam x64" TO TL-CASE
     MOVE "3x64" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   11.6 delete-all: 46 packets, slots 0 to 45, empty stacks.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "CREATIVE-DELETE-ALL" USING CLIENT-STATE
     PERFORM FLUSH
     MOVE 0 TO WS-PACKETS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1023
         IF WS-TEXT(WS-I:2) = "39"
             ADD 1 TO WS-PACKETS
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§11.6 shift-click on the delete slot sends 46 Set Creative Mode Slot packets" TO TL-CASE
     MOVE 46 TO TL-EXPECTED-N
     MOVE WS-PACKETS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§11.6 the first packet is slot 0 empty (39 0000 00), the player's slots are empty" TO TL-CASE
     MOVE "39000000" TO TL-EXPECTED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-SLOT-COUNT(4) TO WS-E1
     MOVE WS-E1 TO TL-OBSERVED
     MOVE "acceptance US12 40-7§11.6 the player's slot 3 is empty after delete-all" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   8.1 the name search over the stand-in items: "flank" matches the two flanks, a namespace part must be contained in minecraft, # (tags) has no data.
     MOVE 7 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "N" TO TL-MODE
     MOVE "flank" TO WS-QUERY
     MOVE 5 TO WS-QLEN
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.1 the query flank finds grazer_flank and seared_flank" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "FLANK" TO WS-QUERY
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.1 the query is lower-cased: FLANK finds the same 2" TO TL-CASE
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:flank" TO WS-QUERY
     MOVE 15 TO WS-QLEN
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.2 a namespace part contained in minecraft and a path part: minecraft:flank finds the 2" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "other:flank" TO WS-QUERY
     MOVE 11 TO WS-QLEN
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.2 a namespace part not contained in minecraft finds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "#logs" TO WS-QUERY
     MOVE 5 TO WS-QLEN
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.1 a tag query (#) finds nothing: the stand-in content has no item tags" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-QUERY
     MOVE 0 TO WS-QLEN
     CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
     MOVE "acceptance US12 40-7§8.1 an empty query lists the whole search tab list (17)" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   10 the saved hotbars: the hotbar tab lists 81 entries (9 per hotbar); an empty hotbar h has the lock paper at entry h; save and load of hotbar 3.
     MOVE 6 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§6.5 the saved hotbars tab lists 81 entries" TO TL-CASE
     MOVE 81 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§11.10 hotbar 3 empty: its row's entry 3 (list index 30) is the locked paper, entry 4 is not" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CR-STACK-LOCK(31) * 10 + CR-STACK-LOCK(32)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-SLOT-ITEM(1)
     MOVE 7 TO PL-SLOT-COUNT(1)
     MOVE 6 TO PL-SLOT-ITEM(9)
     MOVE 1 TO PL-SLOT-COUNT(9)
     MOVE 3 TO WS-K
     CALL "CREATIVE-HOTBAR-SAVE" USING CLIENT-STATE WS-K
     MOVE 0 TO PL-SLOT-COUNT(1) PL-SLOT-COUNT(9)
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "CREATIVE-HOTBAR-LOAD" USING CLIENT-STATE WS-K
     PERFORM FLUSH
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-SLOT-ITEM(1) TO WS-E1
     MOVE PL-SLOT-COUNT(1) TO WS-E2
     MOVE PL-SLOT-ITEM(9) TO WS-E3
     MOVE PL-SLOT-COUNT(9) TO WS-E4
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-7§10 hotbar 3 saved and loaded: slots 0 and 8 hold 5x7 and 6x1 again" TO TL-CASE
     MOVE "5x7 6x1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§10 the load sends slot 36 first: 39 0024 07 05 00 00" TO TL-CASE
     MOVE "39002407050000" TO TL-EXPECTED
     MOVE WS-TEXT(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Coverage of the remaining branches: a left-aligned tab is hit from its tabX (the building blocks tab at 0), the hotbar tab lists a saved hotbar's stacks, and a right click
*>   on an empty grid slot lowers the carried stack by one (coverage-only additions).
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-I
     MOVE 0 TO WS-X
     MOVE -32 TO WS-Y
     CALL "CREATIVE-TAB-HIT" USING WS-I WS-X WS-Y WS-HIT
     MOVE "acceptance US12 40-7§3.2 a left-aligned tab (building blocks, tabX 0) is hit at its corner (0, -32)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE "acceptance US12 40-7§6.5 a saved hotbar (3) lists its stacks: entry 27 of the tab is the saved 5x7 and entry 35 the saved 6x1, no locked paper in that row" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 1000000 + 7 * 10000 + 6 * 100 + 1
     COMPUTE TL-OBSERVED-N = CR-STACK-ITEM(28) * 1000000 + CR-STACK-COUNT(28) * 10000 + CR-STACK-ITEM(36) * 100 + CR-STACK-COUNT(36) + CR-STACK-LOCK(28) + CR-STACK-LOCK(36)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 0 TO WS-ITEM WS-COUNT
     MOVE 1 TO WS-BUTTON
     MOVE 0 TO WS-QUICK WS-CLONE
     CALL "CREATIVE-GRID-CLICK" USING CLIENT-STATE WS-ITEM WS-COUNT WS-BUTTON WS-QUICK WS-CLONE
     MOVE "acceptance US12 40-7§7.3 a right click on an empty grid slot lowers the carried stack: 5 becomes 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PL-CARRIED-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> TL-OBSERVED: "item" x "count" of the carried stack.
 CARRIED-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-CARRIED-ITEM TO WS-E1
     MOVE PL-CARRIED-COUNT TO WS-E2
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     IF PL-CARRIED-COUNT = 0
         MOVE "0x0" TO TL-OBSERVED
     END-IF
     .

*> One frame (pumps the queued packets) and the packets the server received as hex in WS-TEXT.
 FLUSH.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .

 END PROGRAM TEST-SCREEN-40-7.

 COPY CLTEST.
