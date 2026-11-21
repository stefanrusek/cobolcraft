*> Implementation test of the menu lifecycle (core/src/menu-lifecycle.cob; docs/protocol/40-menus-1-model-and-containers.md section 3.8:
*> a bench menu is closed by the tick when its block is gone or the player is further than 4.5 + 4.0 blocks from the block's box;
*> a change of dimension and a respawn close it; a player who dies throws armor, off-hand, the grids and the cursor stack; a
*> player who leaves gives the grid and the cursor stack back to the inventory and keeps armor and off-hand).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MENU-LIFECYCLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CMENU.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY RULES.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 8.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BENCH-STATE         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-TOTAL-BEFORE        BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-PAD-STATE           BINARY-LONG.
 01 WS-PX                  BINARY-LONG VALUE 6.
 01 WS-PY                  BINARY-LONG VALUE 54.
 01 WS-PZ                  BINARY-LONG VALUE 12.
 01 WS-UUID                PIC X(16).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = "cobolcraft:crafting_bench"
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-BENCH-STATE
         END-IF
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-BENCH-STATE
     MOVE 8.5 TO PL-X(WS-ROW)
     MOVE 71 TO PL-Y(WS-ROW)
     MOVE 8.5 TO PL-Z(WS-ROW)
     PERFORM OPEN-BENCH

     MOVE "test menu lifecycle a bench menu whose block stands and whose player is near stays open over a tick"
         TO TL-CASE
     CALL "CORE-TICK"
     PERFORM CHECK-WINDOW-OPEN

     MOVE "test menu lifecycle a player 8 blocks from the bench (inside 4.5 + 4.0 of its box) keeps the menu open"
         TO TL-CASE
     MOVE 16.5 TO PL-Z(WS-ROW)
     CALL "CORE-TICK"
     PERFORM CHECK-WINDOW-OPEN

     MOVE "test menu lifecycle a player 10 blocks from the bench (beyond 4.5 + 4.0) has the menu closed and the "
         & "grid item back in the inventory" TO TL-CASE
     MOVE 18.5 TO PL-Z(WS-ROW)
     PERFORM TOTAL-ITEMS
     MOVE WS-TOTAL TO WS-TOTAL-BEFORE
     MOVE 3 TO MN-BGRID-ITEM(WS-ROW, 2)
     MOVE 2 TO MN-BGRID-COUNT(WS-ROW, 2)
     CALL "CORE-TICK"
     PERFORM TOTAL-ITEMS
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-TOTAL-BEFORE + 2
     COMPUTE TL-OBSERVED-N = WS-TOTAL + MN-WINDOW(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle a bench menu whose block was removed is closed by the tick" TO TL-CASE
     MOVE 8.5 TO PL-Z(WS-ROW)
     PERFORM OPEN-BENCH
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "CORE-TICK"
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-WINDOW(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle a bench menu is closed when the player changes dimension" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-BENCH-STATE
     MOVE TRAVEL-PAD-STATE TO WS-PAD-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-PZ WS-PAD-STATE
     PERFORM OPEN-BENCH
     CALL "TEST-USE-ON" USING WS-CONN WS-PX WS-PY WS-PZ WS-FACE WS-SEQ
     CALL "TEST-ACCEPT-TELEPORT" USING WS-CONN
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = MN-WINDOW(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle a dying player throws armor, off-hand, the 2 x 2 grid and the cursor stack and "
         & "keeps none of them" TO TL-CASE
     MOVE DIM-MAIN TO PL-DIM(WS-ROW)
     MOVE 5 TO MN-EQUIP-ITEM(WS-ROW, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-ROW, 3)
     MOVE 17 TO MN-EQUIP-ITEM(WS-ROW, 5)
     MOVE 3 TO MN-EQUIP-COUNT(WS-ROW, 5)
     MOVE 4 TO MN-IGRID-ITEM(WS-ROW, 1)
     MOVE 2 TO MN-IGRID-COUNT(WS-ROW, 1)
     MOVE 3 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 4 TO PL-CARRIED-COUNT(WS-ROW)
     INITIALIZE PL-INVENTORY(WS-ROW)
     PERFORM GROUND-ITEMS
     MOVE WS-TOTAL TO WS-TOTAL-BEFORE
     MOVE CAUSE-FALL TO WS-CAUSE
     MOVE 0 TO PL-HEALTH(WS-ROW)
     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-NOBODY
     PERFORM GROUND-ITEMS
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = WS-TOTAL-BEFORE + 10
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle after the death nothing is left in armor, off-hand, grid or cursor" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MN-EQUIP-COUNT(WS-ROW, 3) + MN-EQUIP-COUNT(WS-ROW, 5) + MN-IGRID-COUNT(WS-ROW, 1)
         + PL-CARRIED-COUNT(WS-ROW)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle a menu opened again for a dead player is closed by the respawn" TO TL-CASE
     MOVE 1 TO MN-WINDOW(WS-ROW)
     MOVE 12 TO MN-TYPE(WS-ROW)
     CALL "TEST-CLIENT-COMMAND" USING WS-CONN WS-ACTION
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-WINDOW(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test menu lifecycle a player who leaves with a grid item and a cursor stack gets them back into "
         & "the inventory and keeps armor and off-hand for the next join" TO TL-CASE
     MOVE 5 TO MN-EQUIP-ITEM(WS-ROW, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-ROW, 3)
     MOVE 4 TO MN-IGRID-ITEM(WS-ROW, 1)
     MOVE 2 TO MN-IGRID-COUNT(WS-ROW, 1)
     MOVE 3 TO PL-CARRIED-ITEM(WS-ROW)
     MOVE 4 TO PL-CARRIED-COUNT(WS-ROW)
     PERFORM OPEN-BENCH
     MOVE 4 TO MN-BGRID-ITEM(WS-ROW, 5)
     MOVE 3 TO MN-BGRID-COUNT(WS-ROW, 5)
     PERFORM TOTAL-ITEMS
     MOVE WS-TOTAL TO WS-TOTAL-BEFORE
     CALL "CORE-CONN-CLOSED" USING WS-CONN
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     PERFORM TOTAL-ITEMS
     COMPUTE TL-EXPECTED-N = (WS-TOTAL-BEFORE + 9) * 1000 + 5 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-TOTAL * 1000 + MN-EQUIP-ITEM(WS-ROW, 3) * 10 + MN-EQUIP-COUNT(WS-ROW, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 OPEN-BENCH.
     CALL "MENU-BENCH-OPEN" USING WS-CONN WS-X WS-Y WS-Z.

 CHECK-WINDOW-OPEN.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF MN-WINDOW(WS-ROW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 TOTAL-ITEMS.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-TOTAL
     END-PERFORM.

 GROUND-ITEMS.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD EN-ITEM-COUNT(WS-I) TO WS-TOTAL
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MENU-LIFECYCLE.

 COPY CORETEST.
