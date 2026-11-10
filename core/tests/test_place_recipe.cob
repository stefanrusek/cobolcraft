*> Test of Place Recipe (docs/protocol/13 section 3.8, 27 section 4.7; core/src/recipe-unlock.cob): the grid is filled from
*> the inventory with one set of the recipe (or the biggest set with use max items), what the grid held goes back into the
*> inventory first, a shapeless recipe fills the grid slots in order, a shaped recipe sits top-left when it is at least half
*> the grid, and a recipe the player does not know, that does not fit the grid, with another container id, or that the
*> inventory cannot supply, changes nothing. Items: greystone 2, cardstack 6, ledger_tile 9 (the starting kit: slot 0 64
*> greystone, slot 4 64 cardstack, slot 7 64 ledger_tile); display ids 0 ledger_tile (4 greystone), 2 pry_bar (3 greystone,
*> 1 cardstack), 4 glowtube (lucite, dump_shard), 7 goto_pad (7 ingredients), 9 the bench recipe (shaped 2 x 2 of
*> ledger_tile).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLACE-RECIPE-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CMENU.
 COPY PLAYPKT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 5.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-REC                 BINARY-LONG VALUE 1.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-SAVED               PIC X(2048).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW

     MOVE "acceptance US9 13§3.8 Place Recipe in the inventory menu: recipe 0 puts one greystone in each of the "
         & "four grid cells and the result is 2 ledger_tile" TO TL-CASE
     MOVE 0 TO PSB-CONTAINER PSB-USE-MAX PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW-STATE
     MOVE "grid 2x1 2x1 2x1 2x1 | slot0 2x60 | result 9x2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9 13§3.8 Place Recipe replaces what the grid held: the grid goes back into the "
         & "inventory, a shapeless recipe fills the cells in order (pry_bar: 3 greystone, 1 cardstack)" TO TL-CASE
     MOVE 2 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW-STATE
     MOVE "grid 2x1 2x1 2x1 6x1 | slot0 2x61 | result 10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9 13§3.8 Place Recipe with use max items puts the biggest set in the grid (16 greystone "
         & "in each cell from 64)" TO TL-CASE
     MOVE 0 TO PSB-RECIPE
     MOVE 1 TO PSB-USE-MAX
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW-STATE
     MOVE "grid 2x16 2x16 2x16 2x16 | slot0 0x0 | result 9x2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9 13§3.8 a recipe that needs more cells than the 2 x 2 grid has (goto_pad, 7 "
         & "ingredients) changes nothing in the inventory menu" TO TL-CASE
     MOVE 0 TO PSB-USE-MAX
     PERFORM SAVE-STATE
     MOVE 7 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM CHECK-SAME

     MOVE "acceptance US9 13§3.8 a recipe the inventory cannot supply (glowtube without lucite) leaves the "
         & "grid emptied into the inventory and no result" TO TL-CASE
     MOVE 4 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW-STATE
     MOVE "grid 0x0 0x0 0x0 0x0 | slot0 2x64 | result 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9 27§4.7 Place Recipe for a recipe the player's book does not hold, and with another "
         & "container id, is ignored" TO TL-CASE
     CALL "RECBOOK-REMOVE" USING WS-ROW WS-REC WS-REMOVED
     PERFORM SAVE-STATE
     MOVE 0 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     MOVE 1 TO PSB-CONTAINER
     MOVE 2 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM CHECK-SAME

     MOVE "acceptance US9 13§3.8 Place Recipe in the crafting bench menu: the shaped 2 x 2 recipe sits top-left "
         & "(columns 0 and 1 of 3) in the 3 x 3 grid" TO TL-CASE
     CALL "MENU-BENCH-OPEN" USING WS-ID WS-X WS-Y WS-Z
     MOVE MN-WINDOW(WS-ROW) TO PSB-CONTAINER
     MOVE 9 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW-STATE
     MOVE "grid 9x1 9x1 0x0 9x1 9x1 0x0 0x0 0x0 0x0 | slot0 2x64 | result 18x1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> "grid <item>x<count> per cell | slot0 <item>x<count> | result <item>x<count>" of the player's open menu.
 SHOW-STATE.
     MOVE SPACES TO WS-TEXT
     MOVE "grid" TO WS-TEXT
     IF MN-WINDOW(WS-ROW) = 0
         MOVE 4 TO WS-CELLS
     ELSE
         MOVE 9 TO WS-CELLS
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         IF MN-WINDOW(WS-ROW) = 0
             MOVE MN-IGRID-ITEM(WS-ROW, WS-I) TO WS-E1
             MOVE MN-IGRID-COUNT(WS-ROW, WS-I) TO WS-E2
         ELSE
             MOVE MN-BGRID-ITEM(WS-ROW, WS-I) TO WS-E1
             MOVE MN-BGRID-COUNT(WS-ROW, WS-I) TO WS-E2
         END-IF
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
             DELIMITED BY SIZE INTO WS-TEXT
     END-PERFORM
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E2
     STRING FUNCTION TRIM(WS-TEXT) " | slot0 " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE MN-RESULT-ITEM(WS-ROW) TO WS-E1
     MOVE MN-RESULT-COUNT(WS-ROW) TO WS-E2
     STRING FUNCTION TRIM(WS-TEXT) " | result " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT.

*> The inventory, the grids and the result as one area.
 SAVE-STATE.
     MOVE PL-INVENTORY(WS-ROW) TO WS-SAVED(1:288)
     MOVE MN-IGRID(WS-ROW, 1) TO WS-SAVED(289:8)
     MOVE MN-IGRID(WS-ROW, 2) TO WS-SAVED(297:8)
     MOVE MN-IGRID(WS-ROW, 3) TO WS-SAVED(305:8)
     MOVE MN-IGRID(WS-ROW, 4) TO WS-SAVED(313:8).

 CHECK-SAME.
     MOVE "T" TO TL-MODE
     MOVE "same" TO TL-EXPECTED
     MOVE "changed" TO TL-OBSERVED
     IF PL-INVENTORY(WS-ROW) = WS-SAVED(1:288)
             AND MN-IGRID(WS-ROW, 1) = WS-SAVED(289:8) AND MN-IGRID(WS-ROW, 2) = WS-SAVED(297:8)
             AND MN-IGRID(WS-ROW, 3) = WS-SAVED(305:8) AND MN-IGRID(WS-ROW, 4) = WS-SAVED(313:8)
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PLACE-RECIPE-CASES.

 COPY CORETEST.
