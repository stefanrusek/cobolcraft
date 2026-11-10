*> The inventory menu (container id 0, 46 slots; docs/protocol/13 sections 3.5 to 3.7 and 40-1 section 3.6; T0376) over the
*> shared menu model of menus.cob: the result of the 2 x 2 grid, the consumption of the grid when the result is taken, and
*> the quick-move destinations of the inventory menu. The same result programs serve the crafting bench menu
*> (menu-bench.cob) with its 3 x 3 grid.
*>
*> Entry points:
*>   MENU-CRAFT-UPDATE USING player row                 recomputes the result slot from the grid of the current menu
*>   MENU-RESULT-TAKEN USING player row                 one item of each non-empty grid slot is used up, the result recomputed
*>   MENU-INV-QUICK-MOVE USING row, menu slot, item out, count out   quickMoveStack of the inventory menu (13 section 3.7 table)
*>   MENU-OFFHAND-SWAP USING connection id                the Player Action off-hand swap (13 section 4)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CRAFT-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-SIZE                BINARY-LONG.
 01 WS-SIZE-H              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEMS.
    05 WS-ITEM             BINARY-LONG OCCURS 9 TIMES.
 01 WS-RECIPE              BINARY-LONG.
 01 WS-RESULT-ITEM         BINARY-LONG.
 01 WS-RESULT-COUNT        BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-ITEM(WS-I)
     END-PERFORM
     IF MN-WINDOW(L-ROW) = 0
         MOVE 2 TO WS-SIZE WS-SIZE-H
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             IF MN-IGRID-COUNT(L-ROW, WS-I) > 0
                 MOVE MN-IGRID-ITEM(L-ROW, WS-I) TO WS-ITEM(WS-I)
             END-IF
         END-PERFORM
     ELSE
         MOVE 3 TO WS-SIZE WS-SIZE-H
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
             IF MN-BGRID-COUNT(L-ROW, WS-I) > 0
                 MOVE MN-BGRID-ITEM(L-ROW, WS-I) TO WS-ITEM(WS-I)
             END-IF
         END-PERFORM
     END-IF
     CALL "CRAFT-MATCH" USING WS-SIZE WS-SIZE-H WS-ITEMS WS-RECIPE WS-RESULT-ITEM WS-RESULT-COUNT
     IF WS-RECIPE = 0
         MOVE 0 TO MN-RESULT-ITEM(L-ROW) MN-RESULT-COUNT(L-ROW)
     ELSE
         MOVE WS-RESULT-ITEM TO MN-RESULT-ITEM(L-ROW)
         MOVE WS-RESULT-COUNT TO MN-RESULT-COUNT(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MENU-CRAFT-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-RESULT-TAKEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "CRAFT-GRID-TAKE" USING L-ROW
     CALL "MENU-CRAFT-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-RESULT-TAKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-FINISH.
*> USING row, menu slot, stack item, original count, count left, moved (1 or 0), returned item out, returned count out:
*> steps 3 and 4 of the quick-move template (40-1 section 3.6): the slot keeps what is left (empty when nothing), the
*> return value is the pre-move stack when something moved and an empty stack otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-LEFT L-MOVED L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     IF L-MOVED = 1
         CALL "MENU-SET" USING L-ROW L-SLOT L-ITEM L-LEFT
         MOVE L-ITEM TO L-RET-ITEM
         MOVE L-COUNT TO L-RET-COUNT
     END-IF
     GOBACK.
 END PROGRAM MENU-QUICK-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-RESULT.
*> USING row, first slot, end slot (the range a result goes to, scanned in reverse), returned item out, returned count
*> out: quick move of the result slot of either menu (13 section 3.7): the whole result goes into the range, what does not
*> fit is dropped, the grid is used up once; nothing changes when no item fits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-REVERSE             BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FIRST L-END L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW WS-ZERO WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE WS-COUNT TO WS-LEFT
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT L-FIRST L-END WS-REVERSE WS-MOVED WS-VAR
     IF WS-MOVED = 0
         GOBACK
     END-IF
     IF WS-LEFT > 0
         CALL "GI-THROW-STACK" USING L-ROW WS-ITEM WS-LEFT
     END-IF
     CALL "MENU-SET" USING L-ROW WS-ZERO WS-ITEM WS-NONE
     CALL "MENU-RESULT-TAKEN" USING L-ROW
     MOVE WS-ITEM TO L-RET-ITEM
     MOVE WS-COUNT TO L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-QUICK-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-INV-QUICK-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REVERSE             BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-TI                  BINARY-LONG.
 01 WS-TC                  BINARY-LONG.
 01 WS-F9                  BINARY-LONG VALUE 9.
 01 WS-E45                 BINARY-LONG VALUE 45.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     IF L-SLOT = 0
         CALL "MENU-QUICK-RESULT" USING L-ROW WS-F9 WS-E45 L-RET-ITEM L-RET-COUNT
         GOBACK
     END-IF
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-FIRST WS-END
*>   An armor item of a main or hotbar slot goes to its empty armor slot, an off-hand item to an empty off-hand slot.
     IF L-SLOT >= 9 AND L-SLOT <= 44
         CALL "MENU-EQUIP-KIND" USING WS-ITEM WS-KIND
         EVALUATE TRUE
             WHEN WS-KIND >= 1 AND WS-KIND <= 4
                 COMPUTE WS-TARGET = 9 - WS-KIND
             WHEN WS-KIND = 5
                 MOVE 45 TO WS-TARGET
             WHEN OTHER
                 MOVE 0 TO WS-TARGET
         END-EVALUATE
         IF WS-TARGET > 0
             CALL "MENU-GET" USING L-ROW WS-TARGET WS-TI WS-TC
             IF WS-TC = 0
                 MOVE WS-TARGET TO WS-FIRST
                 COMPUTE WS-END = WS-TARGET + 1
             END-IF
         END-IF
     END-IF
     IF WS-END = 0
         EVALUATE TRUE
             WHEN L-SLOT >= 9 AND L-SLOT <= 35
                 MOVE 36 TO WS-FIRST
                 MOVE 45 TO WS-END
             WHEN L-SLOT >= 36 AND L-SLOT <= 44
                 MOVE 9 TO WS-FIRST
                 MOVE 36 TO WS-END
             WHEN OTHER
                 MOVE 9 TO WS-FIRST
                 MOVE 45 TO WS-END
         END-EVALUATE
     END-IF
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REVERSE WS-MOVED WS-VAR
     CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-INV-QUICK-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-OFFHAND-SWAP.
*> USING connection id: Player Action SWAP_ITEM_WITH_OFFHAND (13 section 4, 05c 0x29 action 7): the held hotbar stack and
*> the off-hand stack (container slot 40) exchange places, whatever the stacks are (no slot rule applies to this swap).
*> The use of the held item stops (eating, a break in progress). The state id of the player's menu is raised once and
*> Container Set Slot is sent for the held slot and the off-hand slot as the current menu numbers them (a slot the menu
*> does not show is not sent). With both stacks empty nothing changes and nothing is sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 40.
 01 WS-HI                  BINARY-LONG.
 01 WS-HC                  BINARY-LONG.
 01 WS-OI                  BINARY-LONG.
 01 WS-OC                  BINARY-LONG.
 01 WS-HV                  BINARY-LONG.
 01 WS-OV                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MENU-SLOT           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     CALL "MENU-PLAYER-GET-X" USING WS-ROW WS-HELD WS-HI WS-HC WS-HV
     CALL "MENU-PLAYER-GET-X" USING WS-ROW WS-OFF WS-OI WS-OC WS-OV
     IF WS-HC = 0 AND WS-OC = 0
         GOBACK
     END-IF
     CALL "MENU-PLAYER-SET-X" USING WS-ROW WS-HELD WS-OI WS-OC WS-OV
     CALL "MENU-PLAYER-SET-X" USING WS-ROW WS-OFF WS-HI WS-HC WS-HV
     CALL "HUNGER-CANCEL" USING WS-ROW
     IF PL-BREAKING(WS-ROW) = 1
         CALL "BLOCK-BREAK-END" USING WS-ROW
     END-IF
     CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD WS-NEW
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-HELD WS-MENU-SLOT
     IF WS-MENU-SLOT >= 0
         CALL "MENU-SLOT-SEND" USING L-ID WS-MENU-SLOT
     END-IF
     CALL "MENU-CONTAINER-SLOT" USING WS-ROW WS-OFF WS-MENU-SLOT
     IF WS-MENU-SLOT >= 0
         CALL "MENU-SLOT-SEND" USING L-ID WS-MENU-SLOT
     END-IF
     GOBACK.
 END PROGRAM MENU-OFFHAND-SWAP.
