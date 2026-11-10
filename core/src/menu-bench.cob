*> The crafting bench menu (menu type 12 "crafting", container id 1 to 100; docs/protocol/13 sections 3.5 and 3.7; T0403): 46
*> slots, 0 the result, 1 to 9 the 3 x 3 grid, 10 to 36 the main inventory, 37 to 45 the hotbar. The result and the grid
*> use the programs of menu-inventory.cob.
*>
*> Opening: Use Item On a bench block (the block key cobolcraft:crafting_bench or minecraft:crafting_table) opens the menu
*> whatever the hand holds (MENU-IS-BENCH, MENU-BENCH-OPEN): a menu already open is closed first (its grid and the cursor go
*> back into the inventory), the container id is the next of the cycle 1, 2, ..., 100, 1, ... (40-1 section 4.1), the state id
*> of the new menu starts at 1, and the player gets Open Screen (menu type 12, the title the translation key
*> "container.crafting") and Container Set Content. The menu is closed by Container Close (inventory.cob).
*>
*> Entry points:
*>   MENU-BENCH-QUICK-MOVE USING row, menu slot, item out, count out   quickMoveStack of the bench menu
*>   MENU-IS-BENCH USING block state, result out (1 or 0)              whether the state belongs to a bench block
*>   MENU-BENCH-OPEN USING connection id, x, y, z                      opens the bench menu for the player

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BENCH-QUICK-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REVERSE             BINARY-LONG VALUE 0.
 01 WS-F10                 BINARY-LONG VALUE 10.
 01 WS-E46                 BINARY-LONG VALUE 46.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     IF L-SLOT = 0
         CALL "MENU-QUICK-RESULT" USING L-ROW WS-F10 WS-E46 L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     IF L-SLOT >= 10
*>       An inventory slot goes first into the grid, then to the other part of the inventory.
         MOVE 1 TO WS-FIRST
         MOVE 10 TO WS-END
         CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REVERSE WS-MOVED WS-VAR
         IF WS-MOVED = 0
             IF L-SLOT <= 36
                 MOVE 37 TO WS-FIRST
                 MOVE 46 TO WS-END
             ELSE
                 MOVE 10 TO WS-FIRST
                 MOVE 37 TO WS-END
             END-IF
             CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REVERSE WS-MOVED WS-VAR
         END-IF
     ELSE
         CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-F10 WS-E46 WS-REVERSE WS-MOVED WS-VAR
     END-IF
     CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-BENCH-QUICK-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-IS-BENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     IF CB-KEY(WS-BLOCK) = "cobolcraft:crafting_bench" OR CB-KEY(WS-BLOCK) = "minecraft:crafting_table"
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM MENU-IS-BENCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BENCH-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET-ID           BINARY-LONG VALUE 60.
 01 WS-TYPE                BINARY-LONG VALUE 12.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF MN-WINDOW(WS-ROW) > 0
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     COMPUTE MN-COUNTER(WS-ROW) = FUNCTION MOD(MN-COUNTER(WS-ROW), 100) + 1
     MOVE MN-COUNTER(WS-ROW) TO MN-WINDOW(WS-ROW)
     MOVE 12 TO MN-TYPE(WS-ROW)
     MOVE 1 TO MN-STATE-ID(WS-ROW)
     MOVE PL-DIM(WS-ROW) TO MN-BENCH-DIM(WS-ROW)
     MOVE L-X TO MN-BENCH-X(WS-ROW)
     MOVE L-Y TO MN-BENCH-Y(WS-ROW)
     MOVE L-Z TO MN-BENCH-Z(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO MN-BGRID-ITEM(WS-ROW, WS-I) MN-BGRID-COUNT(WS-ROW, WS-I)
     END-PERFORM
     MOVE 0 TO MN-RESULT-ITEM(WS-ROW) MN-RESULT-COUNT(WS-ROW)
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "container.crafting" TO PB-TX-VALUE
     MOVE 18 TO PB-TX-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-OPEN-SCREEN" USING PB-BUFFER MN-WINDOW(WS-ROW) WS-TYPE PB-TEXT
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     GOBACK.
 END PROGRAM MENU-BENCH-OPEN.
