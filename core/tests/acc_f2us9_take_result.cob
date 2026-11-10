*> Acceptance test, F2 US9-1 (taking the crafting result; FR-024, FR-025, FR-028, SC-005; T0379; docs/protocol/13 §3.6): in the
*> inventory menu's 2 x 2 grid four ledger tiles (item 9) make the bench item (item 18); taking the result with the cursor
*> consumes one of each ingredient and shows the result again while the grid still matches, a result is added to a
*> cursor of the same item and refused for another, shift-click crafts until the grid no longer matches, a full inventory
*> refuses the result and keeps the grid, and CRAFT-GRID-TAKE uses up one item of each non-empty grid slot. After each
*> step the cursor and the non-empty slots are rendered as "cursor <item>x<count> <slot>:<item>x<count> ..." in menu
*> slot numbers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US9-TAKE-RESULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
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

     MOVE "acceptance US9-1 given 2 ledger tiles in each grid cell when the result is taken with the "
         & "cursor then the cursor holds the bench item, one tile of each cell is used up and the "
         & "result shows again" TO TL-CASE
     PERFORM CLEAR
     PERFORM FILL-GRID-2
     MOVE 0 TO WS-TYPE WS-BUTTON
     MOVE 0 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 18x1 0:18x1 1:9x1 2:9x1 3:9x1 4:9x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given the bench item on the cursor when the result is taken again then the "
         & "cursor grows by the result count, the grid is empty and so is the result" TO TL-CASE
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 18x2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given another item on the cursor when the result is clicked then nothing "
         & "changes" TO TL-CASE
     PERFORM CLEAR
     MOVE 1 TO WS-COUNT
     PERFORM FILL-GRID-N
     MOVE 3 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 1 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 3x1 0:18x1 1:9x1 2:9x1 3:9x1 4:9x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given a full cursor of the bench item when the result is clicked then the "
         & "result stays (the stack limit)" TO TL-CASE
     MOVE 18 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 64 TO PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 18x64 0:18x1 1:9x1 2:9x1 3:9x1 4:9x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given 3 ledger tiles in each cell when the result is shift-clicked then "
         & "the craft repeats until the grid no longer matches and the items land in the hotbar" TO TL-CASE
     PERFORM CLEAR
     MOVE 3 TO WS-COUNT
     PERFORM FILL-GRID-N
     MOVE 1 TO WS-TYPE
     MOVE 0 TO WS-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 44:18x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given an inventory with no room when the result is shift-clicked then "
         & "nothing changes and nothing is used up" TO TL-CASE
     PERFORM CLEAR
     MOVE 3 TO WS-ITEM
     MOVE 64 TO WS-COUNT
     PERFORM VARYING WS-SLOT FROM 9 BY 1 UNTIL WS-SLOT > 44
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM
     MOVE 1 TO WS-COUNT
     PERFORM FILL-GRID-N
     MOVE 0 TO WS-SLOT
     PERFORM CLICK
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         ADD MN-IGRID-COUNT(WS-ROW, WS-SLOT) TO WS-COUNT
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     MOVE WS-COUNT TO WS-EDIT
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-EDIT2
     STRING "grid " FUNCTION TRIM(WS-EDIT) " result " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "grid 4 result 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-1 given 2 tiles in each cell when CRAFT-GRID-TAKE runs then one tile of each "
         & "cell is used up and the result slot is not touched" TO TL-CASE
     PERFORM CLEAR
     MOVE 2 TO WS-COUNT
     PERFORM FILL-GRID-N
     CALL "CRAFT-GRID-TAKE" USING WS-ROW
     PERFORM SHOW
     MOVE "cursor 0x0 0:18x1 1:9x1 2:9x1 3:9x1 4:9x1" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CLEAR.
     MOVE 0 TO WS-ITEM WS-COUNT PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-COUNT(WS-ROW)
         MN-DRAG-ACTIVE(WS-ROW) MN-DRAG-COUNT(WS-ROW)
     PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 45
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM.

 FILL-GRID-2.
     MOVE 2 TO WS-COUNT
     PERFORM FILL-GRID-N.

*> Puts WS-COUNT ledger tiles into each of the four grid cells and recomputes the result as a grid change does.
 FILL-GRID-N.
     MOVE 9 TO WS-ITEM
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 4
         CALL "MENU-SET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
     END-PERFORM
     CALL "MENU-CRAFT-UPDATE" USING WS-ROW.

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
 END PROGRAM ACC-F2US9-TAKE-RESULT.

 COPY CORETEST.
