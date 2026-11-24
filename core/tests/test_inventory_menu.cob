*> Test of the 46-slot inventory menu and the shared menu model (core/src/menus.cob, core/src/menu-inventory.cob;
*> docs/protocol/40-menus-1-model-and-containers.md §3.4 to §3.6, 13 §3.5 to §3.7; T0375): the slot layout (result,
*> 2x2 grid, armor, main, hotbar, off-hand), the Container Click modes (pickup, quick move, swap, clone, throw, drag,
*> double click), the armor and off-hand slot rules and the 2x2 result. Items: 2 greystone (64), 3 loam (64),
*> 12 a food (32); the ids 10, 11 and 13 are renamed to an iron helmet, iron boots and a shield (max stack 1) so the
*> equipment rules can be tried with the cobolcraft set. After each step the cursor and the non-empty slots are rendered
*> as "cursor <item>x<count> <slot>:<item>x<count> ..." in menu slot numbers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-MENU.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT-2              PIC X(1024).
 01 WS-TEXT-3              PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.

 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "minecraft:iron_helmet" TO IT-KEY(11)
     MOVE 21 TO IT-KEY-LENGTH(11)
     MOVE "minecraft:iron_boots" TO IT-KEY(12)
     MOVE 20 TO IT-KEY-LENGTH(12)
     MOVE "minecraft:shield" TO IT-KEY(14)
     MOVE 16 TO IT-KEY-LENGTH(14)
     MOVE 1 TO IT-MAX-STACK(11) IT-MAX-STACK(12) IT-MAX-STACK(14)

     MOVE "test inventory menu layout: slot 36 is hotbar 0, 44 hotbar 8, 9 main 0, 45 the off-hand, 5 the "
         & "helmet, 8 the boots, 2 the second grid cell, 0 the result; a slot above 45 holds nothing"
         TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-ITEM
     MOVE 36 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     PERFORM PUT
     MOVE 9 TO WS-SLOT
     MOVE 2 TO WS-COUNT
     PERFORM PUT
     MOVE 44 TO WS-SLOT
     MOVE 3 TO WS-COUNT
     PERFORM PUT
     MOVE 45 TO WS-SLOT
     MOVE 4 TO WS-COUNT
     PERFORM PUT
     MOVE 5 TO WS-SLOT
     MOVE 5 TO WS-COUNT
     PERFORM PUT
     MOVE 8 TO WS-SLOT
     MOVE 6 TO WS-COUNT
     PERFORM PUT
     MOVE 2 TO WS-SLOT
     MOVE 7 TO WS-COUNT
     PERFORM PUT
     MOVE 0 TO WS-SLOT
     MOVE 8 TO WS-COUNT
     PERFORM PUT
     MOVE 46 TO WS-SLOT
     CALL "MENU-GET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         EVALUATE WS-S
             WHEN 1 MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT
             WHEN 2 MOVE PL-SLOT-COUNT(WS-ROW, 10) TO WS-EDIT
             WHEN 3 MOVE PL-SLOT-COUNT(WS-ROW, 9) TO WS-EDIT
             WHEN 4 MOVE MN-EQUIP-COUNT(WS-ROW, 5) TO WS-EDIT
             WHEN 5 MOVE MN-EQUIP-COUNT(WS-ROW, 4) TO WS-EDIT
             WHEN 6 MOVE MN-EQUIP-COUNT(WS-ROW, 1) TO WS-EDIT
             WHEN 7 MOVE MN-IGRID-COUNT(WS-ROW, 2) TO WS-EDIT
         END-EVALUATE
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO WS-TEXT POINTER WS-PTR
     MOVE "1 2 3 4 5 6 7 8 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu PICKUP: left takes a slot whole, right puts one on an empty slot, left "
         & "on another item swaps, right on an empty cursor takes the larger half, left puts all on an "
         & "empty slot" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     PERFORM PUT
     MOVE 3 TO WS-ITEM
     MOVE 10 TO WS-SLOT
     MOVE 5 TO WS-COUNT
     PERFORM PUT
     MOVE 2 TO WS-ITEM
     MOVE 36 TO WS-SLOT
     MOVE 6 TO WS-COUNT
     PERFORM PUT
     MOVE 0 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 11 TO WS-SLOT
     PERFORM CLICK
     MOVE 0 TO WS-BUTTON
     MOVE 10 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 36 TO WS-SLOT
     PERFORM CLICK
     MOVE 12 TO WS-SLOT
     PERFORM CLICK
     MOVE 0 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 10 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 2x5 9:2x5 10:2x4 11:2x1 12:2x1 36:3x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu armor and off-hand slots: a helmet goes only on slot 5, boots only on 8, "
         & "only a shield on 45; a stack of another item is refused" TO TL-CASE
     PERFORM CLEAR
     MOVE 10 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO WS-TYPE WS-BUTTON
     MOVE 8 TO WS-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-SLOT
     PERFORM CLICK
     MOVE 11 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 8 TO WS-SLOT
     PERFORM CLICK
     MOVE 13 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 45 TO WS-SLOT
     PERFORM CLICK
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 3 TO PL-CARRIED-COUNT(WS-ROW)
     PERFORM CLICK
     MOVE 6 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 2x3 5:10x1 8:11x1 45:13x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu SWAP: with a hotbar slot, with the off-hand (button 40, any item), "
         & "refused onto an armor slot by a stack that does not fit" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     PERFORM PUT
     MOVE 3 TO WS-ITEM
     MOVE 36 TO WS-SLOT
     MOVE 4 TO WS-COUNT
     PERFORM PUT
     MOVE 2 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 20 TO WS-SLOT
     PERFORM CLICK
     MOVE 40 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 20:2x10 45:3x4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu QUICK_MOVE: main to hotbar (merging first), hotbar to main, an armor "
         & "item to its empty armor slot, a shield to the off-hand, armor slot, grid cell and off-hand "
         & "back to the main inventory in slot order" TO TL-CASE
     PERFORM CLEAR
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     PERFORM PUT
     MOVE 37 TO WS-SLOT
     MOVE 60 TO WS-COUNT
     PERFORM PUT
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 3 TO WS-ITEM
     MOVE 38 TO WS-SLOT
     MOVE 2 TO WS-COUNT
     PERFORM PUT
     PERFORM CLICK
     MOVE 10 TO WS-ITEM
     MOVE 10 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     PERFORM PUT
     PERFORM CLICK
     MOVE 13 TO WS-ITEM
     MOVE 12 TO WS-SLOT
     PERFORM PUT
     PERFORM CLICK
     MOVE 5 TO WS-SLOT
     PERFORM CLICK
     MOVE 2 TO WS-ITEM
     MOVE 1 TO WS-SLOT
     MOVE 3 TO WS-COUNT
     PERFORM PUT
     PERFORM CLICK
     MOVE 45 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:3x2 10:10x1 11:13x1 36:2x9 37:2x64" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu CLONE: in creative with an empty cursor the cursor gets a full stack; "
         & "in survival nothing happens" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     PERFORM PUT
     MOVE 3 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     PERFORM CLICK
     PERFORM SHOW
     MOVE WS-TEXT TO WS-TEXT-2
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM CLICK
     PERFORM SHOW
     MOVE 0 TO PL-MODE(WS-ROW)
     STRING FUNCTION TRIM(WS-TEXT-2) " | " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-TEXT-3
     MOVE WS-TEXT-3 TO WS-TEXT
     MOVE "cursor 0x0 9:2x10 | cursor 2x64 9:2x10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu THROW: button 0 throws one item of the slot, button 1 the whole stack"
         TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     PERFORM PUT
     MOVE 36 TO WS-SLOT
     MOVE 9 TO WS-COUNT
     PERFORM PUT
     MOVE 4 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 36 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:2x9" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu QUICK_CRAFT: a left drag splits the cursor evenly over 3 slots, a right "
         & "drag puts one in each, a drag over one slot puts the cursor whole there" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 10 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 5 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 9 TO WS-SLOT
     PERFORM CLICK
     MOVE 10 TO WS-SLOT
     PERFORM CLICK
     MOVE 11 TO WS-SLOT
     PERFORM CLICK
     MOVE 2 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 5 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 4 TO WS-BUTTON
     PERFORM CLICK
     MOVE 5 TO WS-BUTTON
     MOVE 20 TO WS-SLOT
     PERFORM CLICK
     MOVE 21 TO WS-SLOT
     PERFORM CLICK
     MOVE 6 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     MOVE 0 TO WS-BUTTON
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     MOVE 22 TO WS-SLOT
     PERFORM CLICK
     MOVE 2 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:2x3 10:2x3 11:2x3 20:2x1 21:2x1 22:2x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu PICKUP_ALL: the cursor gathers its item, non-full stacks first, then full "
         & "ones, up to the maximum stack" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 10 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 2 TO WS-ITEM
     MOVE 9 TO WS-SLOT
     MOVE 20 TO WS-COUNT
     PERFORM PUT
     MOVE 10 TO WS-SLOT
     MOVE 64 TO WS-COUNT
     PERFORM PUT
     MOVE 36 TO WS-SLOT
     MOVE 30 TO WS-COUNT
     PERFORM PUT
     MOVE 3 TO WS-ITEM
     MOVE 11 TO WS-SLOT
     MOVE 5 TO WS-COUNT
     PERFORM PUT
     MOVE 6 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE 12 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 2x64 10:2x60 11:3x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory menu result: a 2x2 square of the bench ingredient in the grid makes the bench "
         & "item appear in slot 0 after the click that fills the grid" TO TL-CASE
     PERFORM CLEAR
     MOVE 9 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 8 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 5 TO WS-TYPE
     MOVE 0 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-BUTTON
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         PERFORM CLICK
     END-PERFORM
     MOVE 2 TO WS-BUTTON
     MOVE -999 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 0:18x1 1:9x2 2:9x2 3:9x2 4:9x2" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CLEAR.
     MOVE 0 TO WS-ITEM WS-COUNT PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-COUNT(WS-ROW)
         PL-MODE(WS-ROW) MN-DRAG-ACTIVE(WS-ROW) MN-DRAG-COUNT(WS-ROW)
     PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 45
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM.

 PUT.
     CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT.

 CLICK.
     CALL "MENU-CLICK" USING WS-ROW WS-SLOT WS-BUTTON WS-TYPE.

 SHOW.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-EDIT
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-EDIT2
     STRING "cursor " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO WS-TEXT POINTER WS-PTR
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
         IF WS-COUNT > 0
             MOVE WS-S TO WS-EDIT
             MOVE WS-ITEM TO WS-EDIT2
             MOVE WS-COUNT TO WS-EDIT3
             STRING " " FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY-MENU.

 COPY CORETEST.
