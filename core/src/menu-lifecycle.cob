*> The menu lifecycle the player rules call outside the click handlers (docs/protocol/40-menus-1-model-and-containers.md section 3.8, 6;
*> 17 section 4.7): a bench menu is checked every tick (stillValid) and closed when its block is gone or the player is out of
*> reach, a menu is closed with the player's other state at a change of dimension and a respawn, and a player who leaves or dies
*> gives up what the menu holds (the cursor stack and the grids).
*>
*> stillValid of the crafting bench menu (40-1 section 3.8, the block-bound helper): the block at the position the menu was opened at
*> is a bench and the squared distance from the player's eye (feet + 1.62) to the unit box of the block is below (4.5 + 4.0) squared.
*>
*> Entry points:
*>   MENU-STILL-VALID USING player row, valid out    1 for an open bench menu that is still valid (the caller has one open)
*>   MENU-TICK                                       closes the invalid bench menus (MENU-FORCE-CLOSE)
*>   MENU-FORCE-CLOSE USING player row               Container Close to the player, then the close of MENU-CLOSE (the grid goes back
*>                                                   into the inventory, the cursor stack too); nothing for the inventory menu
*>   MENU-RELEASE USING player row, mode             silent: the cursor stack and the grids of the inventory menu and of the open
*>                                                   bench menu leave the menu (mode 0: back into the inventory, what does not fit is
*>                                                   thrown; mode 1: thrown), the menu is the inventory menu again

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STILL-VALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-STATE               BINARY-LONG.
 01 WS-BENCH               BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 72.25.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALID.
     MOVE 0 TO L-VALID
     CALL "WORLD-GET-BLOCK" USING MN-BENCH-DIM(L-ROW) MN-BENCH-X(L-ROW) MN-BENCH-Y(L-ROW)
         MN-BENCH-Z(L-ROW) WS-STATE
     IF MN-CSIZE(L-ROW) > 0
         CALL "MENU-CONT-VALID" USING L-ROW WS-BENCH
     ELSE
         CALL "MENU-IS-BENCH" USING WS-STATE WS-BENCH
     END-IF
     IF WS-BENCH = 0
         GOBACK
     END-IF
     COMPUTE WS-EYE = PL-Y(L-ROW) + 1.62
     COMPUTE WS-DX = FUNCTION MAX(MN-BENCH-X(L-ROW) - PL-X(L-ROW), 0, PL-X(L-ROW) - MN-BENCH-X(L-ROW) - 1)
     COMPUTE WS-DY = FUNCTION MAX(MN-BENCH-Y(L-ROW) - WS-EYE, 0, WS-EYE - MN-BENCH-Y(L-ROW) - 1)
     COMPUTE WS-DZ = FUNCTION MAX(MN-BENCH-Z(L-ROW) - PL-Z(L-ROW), 0, PL-Z(L-ROW) - MN-BENCH-Z(L-ROW) - 1)
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < WS-LIMIT
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM MENU-STILL-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-FORCE-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 17.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF MN-WINDOW(L-ROW) = 0
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-CONTAINER-CLOSE" USING PB-BUFFER MN-WINDOW(L-ROW)
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "MENU-CLOSE" USING PL-CONN(L-ROW)
     GOBACK.
 END PROGRAM MENU-FORCE-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND MN-WINDOW(WS-ROW) > 0 AND PL-CONN(WS-ROW) > 0
             CALL "MENU-STILL-VALID" USING WS-ROW WS-VALID
             IF WS-VALID = 0
                 CALL "MENU-FORCE-CLOSE" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-RELEASE-STACK.
*> USING player row, item, count, patch handle, mode: one stack leaves the menu (see MENU-RELEASE).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-VAR L-MODE.
     IF L-COUNT > 0
         IF L-MODE = 0
             CALL "MENU-RETURN-STACK-X" USING L-ROW L-ITEM L-COUNT L-VAR
         ELSE
             CALL "GI-THROW-STACK-X" USING L-ROW L-ITEM L-COUNT L-VAR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-RELEASE-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MODE.
     MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW) PL-DRAG-ACTIVE(L-ROW) PL-DRAG-COUNT(L-ROW)
     MOVE PL-CARRIED-ITEM(L-ROW) TO WS-ITEM
     MOVE PL-CARRIED-COUNT(L-ROW) TO WS-COUNT
     MOVE PL-CARRIED-VAR(L-ROW) TO WS-VAR
     MOVE 0 TO PL-CARRIED-ITEM(L-ROW) PL-CARRIED-COUNT(L-ROW) PL-CARRIED-VAR(L-ROW)
     CALL "MENU-RELEASE-STACK" USING L-ROW WS-ITEM WS-COUNT WS-VAR L-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE MN-IGRID-ITEM(L-ROW, WS-I) TO WS-ITEM
         MOVE MN-IGRID-COUNT(L-ROW, WS-I) TO WS-COUNT
         MOVE MN-IGRID-VAR(L-ROW, WS-I) TO WS-VAR
         MOVE 0 TO MN-IGRID-ITEM(L-ROW, WS-I) MN-IGRID-COUNT(L-ROW, WS-I) MN-IGRID-VAR(L-ROW, WS-I)
         CALL "MENU-RELEASE-STACK" USING L-ROW WS-ITEM WS-COUNT WS-VAR L-MODE
     END-PERFORM
     CALL "MENU-CONT-STOP" USING L-ROW
     IF MN-WINDOW(L-ROW) > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
             MOVE MN-BGRID-ITEM(L-ROW, WS-I) TO WS-ITEM
             MOVE MN-BGRID-COUNT(L-ROW, WS-I) TO WS-COUNT
             MOVE MN-BGRID-VAR(L-ROW, WS-I) TO WS-VAR
             MOVE 0 TO MN-BGRID-ITEM(L-ROW, WS-I) MN-BGRID-COUNT(L-ROW, WS-I) MN-BGRID-VAR(L-ROW, WS-I)
             CALL "MENU-RELEASE-STACK" USING L-ROW WS-ITEM WS-COUNT WS-VAR L-MODE
         END-PERFORM
     END-IF
     MOVE 0 TO MN-WINDOW(L-ROW) MN-TYPE(L-ROW) MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW)
         MN-RESULT-VAR(L-ROW)
     GOBACK.
 END PROGRAM MENU-RELEASE.
