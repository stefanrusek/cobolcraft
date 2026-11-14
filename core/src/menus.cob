*> The shared menu model (docs/protocol/40-menus-1-model-and-containers.md §3 and §4; 13 §3.5 to §3.7; T0376): a menu is
*> a numbered list of slots over the storage of the player row, a cursor (PL-CARRIED-*), a container id and a state id.
*> The player's menu is the inventory menu (container id 0, 46 slots: result, 2 x 2 grid, armor, main, hotbar, off-hand)
*> or the open crafting bench menu (MN-WINDOW > 0, 46 slots: result, 3 x 3 grid, main, hotbar), see CMENU.cpy.
*>
*> A slot index is resolved to the storage it names by MENU-LOCATE: kind 1 the player slot PL-SLOT(index), 2 the
*> armor/off-hand slot MN-EQUIP(index) (container slots 36 to 40), 3 the inventory grid MN-IGRID(index), 4 the result
*> slot, 5 the bench grid MN-BGRID(index), 0 no such slot. The rules of a slot (MENU-MAY-PLACE) and the click
*> algorithm of 40-1 §3.4 (MENU-CLICK: PICKUP, QUICK_MOVE, SWAP, CLONE, THROW, QUICK_CRAFT, PICKUP_ALL), the mover
*> moveItemStackTo of §3.5 (MENU-MOVE-TO) are written once over the slots; the quick-move destinations of each menu
*> are in menu-inventory.cob and menu-bench.cob, the result slot in crafting-match.cob. A stack is an item id and a count
*> (a count of 0 is an empty slot, its item 0); the item decides the stack kind (no data components exist in the core).
*>
*> Equipment (13 §3.5: the armor slots take armor, the off-hand slot an item equippable there): the item table carries no
*> equippable component, so MENU-EQUIP-KIND reads the item key: a key ending "_boots", "_leggings", "_chestplate" or
*> "_helmet" (also minecraft:elytra as a chestplate) is armor of that slot, minecraft:shield is the off-hand item.
*>
*> Entry points:
*>   MENU-LOCATE USING player row, menu slot, kind out, index out
*>   MENU-GET USING player row, menu slot, item out, count out
*>   MENU-SET USING player row, menu slot, item, count          (count 0 empties the slot; no rule is checked)
*>   MENU-EQUIP-KIND USING item, kind out                       0 none, 1 boots, 2 leggings, 3 chestplate, 4 helmet, 5 off-hand
*>   MENU-MAY-PLACE USING player row, menu slot, item, result out (1 or 0)
*>   MENU-CONTAINER-SLOT USING player row, container slot (0 to 40), menu slot out   the menu slot of a player slot, -1 none
*>   MENU-PLAYER-GET-X / MENU-PLAYER-SET-X USING row, container slot (0 to 40), item (out), count (out), patch handle (out)
*>   MENU-MOVE-TO USING row, item, count (in and out: what is left), first, end, reverse (0 or 1), changed out
*>   MENU-CLICK USING row, menu slot, button, click type          one Container Click applied to the player's menu

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-LOCATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-KIND L-INDEX.
     MOVE 0 TO L-KIND L-INDEX
     CALL "MENU-SLOT-COUNT" USING L-ROW WS-COUNT
     IF L-SLOT < 0 OR L-SLOT >= WS-COUNT
         GOBACK
     END-IF
*>   A container menu (menu-container.cob): its own slots, the 27 main inventory slots, the 9 hotbar slots.
     IF MN-WINDOW(L-ROW) > 0 AND MN-CSIZE(L-ROW) > 0
         MOVE MN-CSIZE(L-ROW) TO WS-OWN
         EVALUATE TRUE
             WHEN L-SLOT < WS-OWN
                 MOVE 6 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT + 1
             WHEN L-SLOT < WS-OWN + 27
                 MOVE 1 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT - WS-OWN + 10
             WHEN OTHER
                 MOVE 1 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT - WS-OWN - 26
         END-EVALUATE
         GOBACK
     END-IF
     IF L-SLOT = 0
         MOVE 4 TO L-KIND
         MOVE 1 TO L-INDEX
         GOBACK
     END-IF
     IF MN-WINDOW(L-ROW) = 0
         EVALUATE TRUE
             WHEN L-SLOT <= 4
                 MOVE 3 TO L-KIND
                 MOVE L-SLOT TO L-INDEX
             WHEN L-SLOT <= 8
                 MOVE 2 TO L-KIND
                 COMPUTE L-INDEX = 9 - L-SLOT
             WHEN L-SLOT <= 35
                 MOVE 1 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT + 1
             WHEN L-SLOT <= 44
                 MOVE 1 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT - 35
             WHEN OTHER
                 MOVE 2 TO L-KIND
                 MOVE 5 TO L-INDEX
         END-EVALUATE
     ELSE
         EVALUATE TRUE
             WHEN L-SLOT <= 9
                 MOVE 5 TO L-KIND
                 MOVE L-SLOT TO L-INDEX
             WHEN L-SLOT <= 36
                 MOVE 1 TO L-KIND
                 MOVE L-SLOT TO L-INDEX
             WHEN OTHER
                 MOVE 1 TO L-KIND
                 COMPUTE L-INDEX = L-SLOT - 36
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM MENU-LOCATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GET-X.
*> USING player row, menu slot, item out, count out, patch handle out (CSTACK.cpy; 0 = none, also for an empty slot).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OWN-SLOT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE 0 TO L-ITEM L-COUNT L-VAR
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     EVALUATE WS-KIND
         WHEN 1
             MOVE PL-SLOT-ITEM(L-ROW, WS-INDEX) TO L-ITEM
             MOVE PL-SLOT-COUNT(L-ROW, WS-INDEX) TO L-COUNT
             MOVE PL-SLOT-VAR(L-ROW, WS-INDEX) TO L-VAR
         WHEN 2
             MOVE MN-EQUIP-ITEM(L-ROW, WS-INDEX) TO L-ITEM
             MOVE MN-EQUIP-COUNT(L-ROW, WS-INDEX) TO L-COUNT
             MOVE MN-EQUIP-VAR(L-ROW, WS-INDEX) TO L-VAR
         WHEN 3
             MOVE MN-IGRID-ITEM(L-ROW, WS-INDEX) TO L-ITEM
             MOVE MN-IGRID-COUNT(L-ROW, WS-INDEX) TO L-COUNT
             MOVE MN-IGRID-VAR(L-ROW, WS-INDEX) TO L-VAR
         WHEN 4
             MOVE MN-RESULT-ITEM(L-ROW) TO L-ITEM
             MOVE MN-RESULT-COUNT(L-ROW) TO L-COUNT
             MOVE MN-RESULT-VAR(L-ROW) TO L-VAR
         WHEN 5
             MOVE MN-BGRID-ITEM(L-ROW, WS-INDEX) TO L-ITEM
             MOVE MN-BGRID-COUNT(L-ROW, WS-INDEX) TO L-COUNT
             MOVE MN-BGRID-VAR(L-ROW, WS-INDEX) TO L-VAR
         WHEN 6
             COMPUTE WS-OWN-SLOT = WS-INDEX - 1
             CALL "MENU-CONT-GET" USING L-ROW WS-OWN-SLOT L-ITEM L-COUNT L-VAR
     END-EVALUATE
     IF L-COUNT <= 0
         MOVE 0 TO L-ITEM L-COUNT L-VAR
     END-IF
     GOBACK.
 END PROGRAM MENU-GET-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-GET.
*> USING player row, menu slot, item out, count out: MENU-GET-X without the patch handle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT.
     CALL "MENU-GET-X" USING L-ROW L-SLOT L-ITEM L-COUNT WS-VAR
     GOBACK.
 END PROGRAM MENU-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SET-X.
*> USING player row, menu slot, item, count, patch handle (CSTACK.cpy): a count of 0 empties the slot (its item and handle 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-OWN-SLOT            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE L-ITEM TO WS-ITEM
     MOVE L-COUNT TO WS-COUNT
     MOVE L-VAR TO WS-VAR
     IF WS-COUNT <= 0
         MOVE 0 TO WS-ITEM WS-COUNT WS-VAR
     END-IF
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     EVALUATE WS-KIND
         WHEN 1
             MOVE WS-ITEM TO PL-SLOT-ITEM(L-ROW, WS-INDEX)
             MOVE WS-COUNT TO PL-SLOT-COUNT(L-ROW, WS-INDEX)
             MOVE WS-VAR TO PL-SLOT-VAR(L-ROW, WS-INDEX)
         WHEN 2
             MOVE WS-ITEM TO MN-EQUIP-ITEM(L-ROW, WS-INDEX)
             MOVE WS-COUNT TO MN-EQUIP-COUNT(L-ROW, WS-INDEX)
             MOVE WS-VAR TO MN-EQUIP-VAR(L-ROW, WS-INDEX)
         WHEN 3
             MOVE WS-ITEM TO MN-IGRID-ITEM(L-ROW, WS-INDEX)
             MOVE WS-COUNT TO MN-IGRID-COUNT(L-ROW, WS-INDEX)
             MOVE WS-VAR TO MN-IGRID-VAR(L-ROW, WS-INDEX)
         WHEN 4
             MOVE WS-ITEM TO MN-RESULT-ITEM(L-ROW)
             MOVE WS-COUNT TO MN-RESULT-COUNT(L-ROW)
             MOVE WS-VAR TO MN-RESULT-VAR(L-ROW)
         WHEN 5
             MOVE WS-ITEM TO MN-BGRID-ITEM(L-ROW, WS-INDEX)
             MOVE WS-COUNT TO MN-BGRID-COUNT(L-ROW, WS-INDEX)
             MOVE WS-VAR TO MN-BGRID-VAR(L-ROW, WS-INDEX)
         WHEN 6
             COMPUTE WS-OWN-SLOT = WS-INDEX - 1
             CALL "MENU-CONT-SET" USING L-ROW WS-OWN-SLOT WS-ITEM WS-COUNT WS-VAR
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-SET-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SET.
*> USING player row, menu slot, item, count (count 0 empties the slot; no rule is checked): MENU-SET-X for a stack whose patch
*> does not change: the slot keeps its patch handle when the item stays, else the stack has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD-ITEM            BINARY-LONG.
 01 WS-OLD-COUNT           BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT.
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-OLD-ITEM WS-OLD-COUNT WS-VAR
     IF L-ITEM NOT = WS-OLD-ITEM
         MOVE 0 TO WS-VAR
     END-IF
     CALL "MENU-SET-X" USING L-ROW L-SLOT L-ITEM L-COUNT WS-VAR
     GOBACK.
 END PROGRAM MENU-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-PLAYER-GET-X.
*> USING row, container slot 0 to 40 (hotbar 0 to 8, main 9 to 35, boots 36 ... helmet 39, off-hand 40), item out, count out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE 0 TO L-ITEM L-COUNT L-VAR
     EVALUATE TRUE
         WHEN L-SLOT >= 0 AND L-SLOT <= 35
             MOVE PL-SLOT-ITEM(L-ROW, L-SLOT + 1) TO L-ITEM
             MOVE PL-SLOT-COUNT(L-ROW, L-SLOT + 1) TO L-COUNT
             MOVE PL-SLOT-VAR(L-ROW, L-SLOT + 1) TO L-VAR
         WHEN L-SLOT >= 36 AND L-SLOT <= 40
             MOVE MN-EQUIP-ITEM(L-ROW, L-SLOT - 35) TO L-ITEM
             MOVE MN-EQUIP-COUNT(L-ROW, L-SLOT - 35) TO L-COUNT
             MOVE MN-EQUIP-VAR(L-ROW, L-SLOT - 35) TO L-VAR
     END-EVALUATE
     IF L-COUNT <= 0
         MOVE 0 TO L-ITEM L-COUNT L-VAR
     END-IF
     GOBACK.
 END PROGRAM MENU-PLAYER-GET-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-PLAYER-SET-X.
*> USING row, container slot 0 to 40, item, count, patch handle: a count of 0 empties the slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE L-ITEM TO WS-ITEM
     MOVE L-COUNT TO WS-COUNT
     MOVE L-VAR TO WS-VAR
     IF WS-COUNT <= 0
         MOVE 0 TO WS-ITEM WS-COUNT WS-VAR
     END-IF
     EVALUATE TRUE
         WHEN L-SLOT >= 0 AND L-SLOT <= 35
             MOVE WS-ITEM TO PL-SLOT-ITEM(L-ROW, L-SLOT + 1)
             MOVE WS-COUNT TO PL-SLOT-COUNT(L-ROW, L-SLOT + 1)
             MOVE WS-VAR TO PL-SLOT-VAR(L-ROW, L-SLOT + 1)
         WHEN L-SLOT >= 36 AND L-SLOT <= 40
             MOVE WS-ITEM TO MN-EQUIP-ITEM(L-ROW, L-SLOT - 35)
             MOVE WS-COUNT TO MN-EQUIP-COUNT(L-ROW, L-SLOT - 35)
             MOVE WS-VAR TO MN-EQUIP-VAR(L-ROW, L-SLOT - 35)
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-PLAYER-SET-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CONTAINER-SLOT.
*> USING row, container slot 0 to 40, menu slot out: the number the player slot has in the player's current menu
*> (-1 when the menu does not show it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-MENU-SLOT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-MENU-SLOT.
     MOVE -1 TO L-MENU-SLOT
     IF MN-WINDOW(L-ROW) > 0 AND MN-CSIZE(L-ROW) > 0
         EVALUATE TRUE
             WHEN L-SLOT >= 9 AND L-SLOT <= 35
                 COMPUTE L-MENU-SLOT = MN-CSIZE(L-ROW) + L-SLOT - 9
             WHEN L-SLOT >= 0 AND L-SLOT <= 8
                 COMPUTE L-MENU-SLOT = MN-CSIZE(L-ROW) + 27 + L-SLOT
         END-EVALUATE
         GOBACK
     END-IF
     IF MN-WINDOW(L-ROW) = 0
         EVALUATE TRUE
             WHEN L-SLOT >= 9 AND L-SLOT <= 35
                 MOVE L-SLOT TO L-MENU-SLOT
             WHEN L-SLOT >= 0 AND L-SLOT <= 8
                 COMPUTE L-MENU-SLOT = L-SLOT + 36
             WHEN L-SLOT >= 36 AND L-SLOT <= 39
                 COMPUTE L-MENU-SLOT = 44 - L-SLOT
             WHEN L-SLOT = 40
                 MOVE 45 TO L-MENU-SLOT
         END-EVALUATE
     ELSE
         EVALUATE TRUE
             WHEN L-SLOT >= 9 AND L-SLOT <= 35
                 COMPUTE L-MENU-SLOT = L-SLOT + 1
             WHEN L-SLOT >= 0 AND L-SLOT <= 8
                 COMPUTE L-MENU-SLOT = L-SLOT + 37
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM MENU-CONTAINER-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-EQUIP-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KIND.
     MOVE 0 TO L-KIND
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-LEN
     IF WS-LEN < 6 OR WS-LEN > 48
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN IT-KEY(L-ITEM + 1)(1:WS-LEN) = "minecraft:shield" OR "shield"
             MOVE 5 TO L-KIND
         WHEN IT-KEY(L-ITEM + 1)(1:WS-LEN) = "minecraft:elytra" OR "elytra"
             MOVE 3 TO L-KIND
         WHEN WS-LEN >= 6 AND IT-KEY(L-ITEM + 1)(WS-LEN - 5:6) = "_boots"
             MOVE 1 TO L-KIND
         WHEN WS-LEN >= 9 AND IT-KEY(L-ITEM + 1)(WS-LEN - 8:9) = "_leggings"
             MOVE 2 TO L-KIND
         WHEN WS-LEN >= 11 AND IT-KEY(L-ITEM + 1)(WS-LEN - 10:11) = "_chestplate"
             MOVE 3 TO L-KIND
         WHEN WS-LEN >= 7 AND IT-KEY(L-ITEM + 1)(WS-LEN - 6:7) = "_helmet"
             MOVE 4 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-EQUIP-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-MAY-PLACE.
*> USING row, menu slot, item, result out: the result slot takes nothing; an armor slot only its armor; the off-hand
*> slot only an off-hand item; every other slot takes anything.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-EQUIP               BINARY-LONG.
 01 WS-KL                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-RESULT.
     MOVE 1 TO L-RESULT
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     EVALUATE WS-KIND
         WHEN 0
             MOVE 0 TO L-RESULT
         WHEN 4
             MOVE 0 TO L-RESULT
*>       The shulker box's own slots refuse a shulker box item (40-1 section 8.2).
         WHEN 6
*>           The furnace family (40-2 section 2.3): nothing goes into the result slot; the fuel slot takes a fuel (a `fuel` component) or an
*>           empty bucket.
             IF MN-CFAMILY(L-ROW) = 8
                 EVALUATE WS-INDEX
                     WHEN 3
                         MOVE 0 TO L-RESULT
                     WHEN 2
                         CALL "FURN-MAY-FUEL" USING L-ITEM L-RESULT
                 END-EVALUATE
             END-IF
             IF MN-CFAMILY(L-ROW) = 4 AND L-ITEM > 0 AND L-ITEM < IT-COUNT
                 MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-KL
                 IF WS-KL >= 11
                     COMPUTE WS-START = WS-KL - 10
                     IF IT-KEY(L-ITEM + 1)(WS-START:11) = "shulker_box"
                         MOVE 0 TO L-RESULT
                     END-IF
                 END-IF
             END-IF
         WHEN 2
             CALL "MENU-EQUIP-KIND" USING L-ITEM WS-EQUIP
             IF WS-EQUIP NOT = WS-INDEX
                 MOVE 0 TO L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-MAY-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-MOVE-TO-X.
*> USING row, item, count (in: the stack to move; out: what is left), first slot, end slot (exclusive), reverse (1 scans
*> from end - 1 down), changed out (1 when anything moved): moveItemStackTo of 40-1 §3.5. Pass A merges into the
*> stacks of the same item (only for an item that stacks), pass B puts what is left into the first empty slot that
*> takes it (one slot per call). The stack has the patch handle USING last (a stack merges only into one with the same handle).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FIRST L-END L-REVERSE L-CHANGED L-VAR.
     MOVE 0 TO L-CHANGED
     IF L-COUNT <= 0 OR L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-MAX-STACK(L-ITEM + 1) TO WS-MAX
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         MOVE 0 TO WS-DONE
         IF WS-PASS = 1 AND WS-MAX <= 1
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-PASS = 2 AND L-COUNT = 0
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-DONE = 0
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-END - L-FIRST OR WS-DONE = 1
                 IF L-REVERSE = 1
                     COMPUTE WS-SLOT = L-END - 1 - WS-I
                 ELSE
                     COMPUTE WS-SLOT = L-FIRST + WS-I
                 END-IF
                 CALL "MENU-GET-X" USING L-ROW WS-SLOT WS-ITEM WS-COUNT WS-VAR
                 IF WS-PASS = 1
                     IF WS-COUNT > 0 AND WS-ITEM = L-ITEM AND WS-VAR = L-VAR AND WS-COUNT < WS-MAX
                         COMPUTE WS-N = FUNCTION MIN(L-COUNT, WS-MAX - WS-COUNT)
                         ADD WS-N TO WS-COUNT
                         SUBTRACT WS-N FROM L-COUNT
                         CALL "MENU-SET-X" USING L-ROW WS-SLOT WS-ITEM WS-COUNT L-VAR
                         MOVE 1 TO L-CHANGED
                         IF L-COUNT = 0
                             MOVE 1 TO WS-DONE
                         END-IF
                     END-IF
                 ELSE
                     IF WS-COUNT = 0
                         CALL "MENU-MAY-PLACE" USING L-ROW WS-SLOT L-ITEM WS-MAY
                         IF WS-MAY = 1
                             COMPUTE WS-N = FUNCTION MIN(L-COUNT, WS-MAX)
                             CALL "MENU-SET-X" USING L-ROW WS-SLOT L-ITEM WS-N L-VAR
                             SUBTRACT WS-N FROM L-COUNT
                             MOVE 1 TO L-CHANGED
                             MOVE 1 TO WS-DONE
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-MOVE-TO-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-MOVE-TO.
*> USING row, item, count (in and out), first slot, end slot, reverse, changed out: MENU-MOVE-TO-X for a stack without a patch.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FIRST L-END L-REVERSE L-CHANGED.
     CALL "MENU-MOVE-TO-X" USING L-ROW L-ITEM L-COUNT L-FIRST L-END L-REVERSE L-CHANGED WS-NONE
     GOBACK.
 END PROGRAM MENU-MOVE-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-INSERT.
*> USING row, menu slot, amount: safeInsert of 40-1 §3.2 of the cursor: puts up to amount of the cursor on the slot (an
*> empty slot or one of the cursor's item) when the slot takes the item and has room.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-AMOUNT.
     IF PL-CARRIED-COUNT(L-ROW) <= 0
         GOBACK
     END-IF
     CALL "MENU-MAY-PLACE" USING L-ROW L-SLOT PL-CARRIED-ITEM(L-ROW) WS-MAY
     IF WS-MAY = 0
         GOBACK
     END-IF
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     COMPUTE WS-N = IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) - WS-COUNT
     COMPUTE WS-N = FUNCTION MIN(WS-N, PL-CARRIED-COUNT(L-ROW), L-AMOUNT)
     IF WS-N <= 0
         GOBACK
     END-IF
     MOVE PL-CARRIED-ITEM(L-ROW) TO WS-ITEM
     ADD WS-N TO WS-COUNT
     CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT PL-CARRIED-VAR(L-ROW)
     SUBTRACT WS-N FROM PL-CARRIED-COUNT(L-ROW)
     IF PL-CARRIED-COUNT(L-ROW) = 0
         MOVE 0 TO PL-CARRIED-ITEM(L-ROW) PL-CARRIED-VAR(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MENU-INSERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-PICKUP.
*> USING row, menu slot (>= 0), button (0 or 1): the PICKUP rules of 40-1 §3.4 item 1. Taking from the result slot
*> takes its whole stack and then consumes the grid (MENU-RESULT-TAKEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     IF WS-KIND = 0
         GOBACK
     END-IF
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
     MOVE 0 TO WS-MAY
     IF PL-CARRIED-COUNT(L-ROW) > 0
         CALL "MENU-MAY-PLACE" USING L-ROW L-SLOT PL-CARRIED-ITEM(L-ROW) WS-MAY
     END-IF
     EVALUATE TRUE
         WHEN WS-SC = 0
             IF PL-CARRIED-COUNT(L-ROW) > 0
                 IF L-BUTTON = 0
                     MOVE PL-CARRIED-COUNT(L-ROW) TO WS-AMOUNT
                 ELSE
                     MOVE 1 TO WS-AMOUNT
                 END-IF
                 CALL "MENU-INSERT" USING L-ROW L-SLOT WS-AMOUNT
             END-IF
         WHEN PL-CARRIED-COUNT(L-ROW) = 0
             IF L-BUTTON = 0 OR WS-KIND = 4
                 MOVE WS-SC TO WS-AMOUNT
             ELSE
                 COMPUTE WS-AMOUNT = (WS-SC + 1) / 2
             END-IF
             MOVE WS-SI TO PL-CARRIED-ITEM(L-ROW)
             MOVE WS-AMOUNT TO PL-CARRIED-COUNT(L-ROW)
             MOVE WS-SV TO PL-CARRIED-VAR(L-ROW)
             SUBTRACT WS-AMOUNT FROM WS-SC
             CALL "MENU-SET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
             IF WS-KIND = 4
                 CALL "MENU-RESULT-TAKEN" USING L-ROW
             END-IF
         WHEN WS-MAY = 1
             IF PL-CARRIED-ITEM(L-ROW) = WS-SI AND PL-CARRIED-VAR(L-ROW) = WS-SV
                 IF L-BUTTON = 0
                     MOVE PL-CARRIED-COUNT(L-ROW) TO WS-AMOUNT
                 ELSE
                     MOVE 1 TO WS-AMOUNT
                 END-IF
                 CALL "MENU-INSERT" USING L-ROW L-SLOT WS-AMOUNT
             ELSE
                 IF PL-CARRIED-COUNT(L-ROW) <= IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1)
                     CALL "MENU-SET-X" USING L-ROW L-SLOT PL-CARRIED-ITEM(L-ROW) PL-CARRIED-COUNT(L-ROW)
                         PL-CARRIED-VAR(L-ROW)
                     MOVE WS-SI TO PL-CARRIED-ITEM(L-ROW)
                     MOVE WS-SC TO PL-CARRIED-COUNT(L-ROW)
                     MOVE WS-SV TO PL-CARRIED-VAR(L-ROW)
                 END-IF
             END-IF
         WHEN OTHER
*>           The slot refuses the cursor's stack: the same item is taken up to the cursor's maximum (a result
*>           slot adds its whole result when that fits, 13 §3.6).
             IF PL-CARRIED-ITEM(L-ROW) = WS-SI AND PL-CARRIED-VAR(L-ROW) = WS-SV
                 COMPUTE WS-N = IT-MAX-STACK(WS-SI + 1) - PL-CARRIED-COUNT(L-ROW)
                 IF WS-KIND = 4
                     IF WS-SC <= WS-N
                         MOVE WS-SC TO WS-N
                     ELSE
                         MOVE 0 TO WS-N
                     END-IF
                 ELSE
                     COMPUTE WS-N = FUNCTION MIN(WS-N, WS-SC)
                 END-IF
                 IF WS-N > 0
                     ADD WS-N TO PL-CARRIED-COUNT(L-ROW)
                     SUBTRACT WS-N FROM WS-SC
                     CALL "MENU-SET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
                     IF WS-KIND = 4
                         CALL "MENU-RESULT-TAKEN" USING L-ROW
                     END-IF
                 END-IF
             END-IF
     END-EVALUATE
     IF PL-CARRIED-COUNT(L-ROW) = 0
         MOVE 0 TO PL-CARRIED-ITEM(L-ROW) PL-CARRIED-VAR(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MENU-CLICK-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-SWAP.
*> USING row, menu slot (>= 0), button (0 to 8 a hotbar slot, 40 the off-hand): SWAP of 40-1 §3.4 item 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-HC                  BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-HV                  BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     IF NOT ((L-BUTTON >= 0 AND L-BUTTON <= 8) OR L-BUTTON = 40)
         GOBACK
     END-IF
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     IF WS-KIND = 0
         GOBACK
     END-IF
     CALL "MENU-PLAYER-GET-X" USING L-ROW L-BUTTON WS-HI WS-HC WS-HV
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
     IF WS-HC = 0 AND WS-SC = 0
         GOBACK
     END-IF
     IF WS-HC > 0
         CALL "MENU-MAY-PLACE" USING L-ROW L-SLOT WS-HI WS-MAY
         IF WS-MAY = 0
             GOBACK
         END-IF
     END-IF
     CALL "MENU-SET-X" USING L-ROW L-SLOT WS-HI WS-HC WS-HV
     CALL "MENU-PLAYER-SET-X" USING L-ROW L-BUTTON WS-SI WS-SC WS-SV
     IF WS-KIND = 4
         CALL "MENU-RESULT-TAKEN" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MENU-CLICK-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-THROW.
*> USING row, menu slot (>= 0), button (0 one item, 1 the stack): THROW of 40-1 §3.4 item 4, with the cursor empty. With
*> button 1 the take repeats while the slot still holds the same item (a result slot crafts again).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-AGAIN               BINARY-LONG.
 01 WS-LOOPS               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     CALL "MENU-LOCATE" USING L-ROW L-SLOT WS-KIND WS-INDEX
     CALL "MENU-GET" USING L-ROW L-SLOT WS-SI WS-SC
     IF WS-KIND = 0 OR WS-SC = 0
         GOBACK
     END-IF
     IF L-BUTTON = 0
         MOVE 1 TO WS-COUNT
     ELSE
         MOVE WS-SC TO WS-COUNT
     END-IF
     MOVE 1 TO WS-AGAIN
     MOVE 0 TO WS-LOOPS
     PERFORM UNTIL WS-AGAIN = 0 OR WS-LOOPS > 64
         ADD 1 TO WS-LOOPS
         CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-SC WS-VAR
         COMPUTE WS-TAKE = FUNCTION MIN(WS-COUNT, WS-SC)
         IF WS-KIND = 4
             MOVE WS-SC TO WS-TAKE
         END-IF
         MOVE 0 TO WS-AGAIN
         IF WS-TAKE > 0
             SUBTRACT WS-TAKE FROM WS-SC
             CALL "MENU-SET" USING L-ROW L-SLOT WS-ITEM WS-SC
             IF WS-KIND = 4
                 CALL "MENU-RESULT-TAKEN" USING L-ROW
             END-IF
             CALL "GI-THROW-STACK-X" USING L-ROW WS-ITEM WS-TAKE WS-VAR
             IF L-BUTTON = 1
                 CALL "MENU-GET" USING L-ROW L-SLOT WS-SI WS-SC
                 IF WS-SC > 0 AND WS-SI = WS-ITEM
                     MOVE 1 TO WS-AGAIN
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-CLICK-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-PICKUP-ALL.
*> USING row, menu slot, button: PICKUP_ALL of 40-1 §3.4 item 5 (the result slot is never taken from).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-LAST                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     MOVE IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) TO WS-MAX
     CALL "MENU-SLOT-COUNT" USING L-ROW WS-LAST
     SUBTRACT 1 FROM WS-LAST
     MOVE 1 TO WS-FIRST
     IF MN-WINDOW(L-ROW) > 0 AND MN-CSIZE(L-ROW) > 0
         MOVE 0 TO WS-FIRST
     END-IF
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-LAST OR PL-CARRIED-COUNT(L-ROW) >= WS-MAX
             IF L-BUTTON = 0
                 MOVE WS-I TO WS-SLOT
             ELSE
                 COMPUTE WS-SLOT = WS-LAST - WS-I
             END-IF
             IF WS-SLOT >= WS-FIRST
                 CALL "MENU-GET-X" USING L-ROW WS-SLOT WS-SI WS-SC WS-SV
                 IF WS-SC > 0 AND WS-SI = PL-CARRIED-ITEM(L-ROW) AND WS-SV = PL-CARRIED-VAR(L-ROW) AND (WS-PASS = 2 OR WS-SC < WS-MAX)
                     COMPUTE WS-N = FUNCTION MIN(WS-SC, WS-MAX - PL-CARRIED-COUNT(L-ROW))
                     ADD WS-N TO PL-CARRIED-COUNT(L-ROW)
                     SUBTRACT WS-N FROM WS-SC
                     CALL "MENU-SET" USING L-ROW WS-SLOT WS-SI WS-SC
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-CLICK-PICKUP-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DRAG-ADD.
*> USING row, menu slot: header 1 of a drag: adds the slot when the slot takes the cursor's item, is not in the set and the
*> cursor is large enough (40-1 section 3.4 item 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-I                   BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 1 TO WS-OK
     CALL "MENU-SLOT-COUNT" USING L-ROW WS-LIMIT
     IF L-SLOT < 0 OR L-SLOT >= WS-LIMIT
         MOVE 0 TO WS-OK
     END-IF
     IF WS-OK = 1
         CALL "MENU-GET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
         CALL "MENU-MAY-PLACE" USING L-ROW L-SLOT PL-CARRIED-ITEM(L-ROW) WS-MAY
         IF WS-MAY = 0
             MOVE 0 TO WS-OK
         END-IF
         IF WS-SC > 0 AND (WS-SI NOT = PL-CARRIED-ITEM(L-ROW) OR WS-SV NOT = PL-CARRIED-VAR(L-ROW))
             MOVE 0 TO WS-OK
         END-IF
         IF MN-DRAG-TYPE(L-ROW) < 2 AND PL-CARRIED-COUNT(L-ROW) < MN-DRAG-COUNT(L-ROW) + 1
             MOVE 0 TO WS-OK
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-DRAG-COUNT(L-ROW)
             IF MN-DRAG-SLOT(L-ROW, WS-I) = L-SLOT
                 MOVE 0 TO WS-OK
             END-IF
         END-PERFORM
     END-IF
     IF WS-OK = 1
         ADD 1 TO MN-DRAG-COUNT(L-ROW)
         MOVE L-SLOT TO MN-DRAG-SLOT(L-ROW, MN-DRAG-COUNT(L-ROW))
     END-IF.
     GOBACK.
 END PROGRAM MENU-DRAG-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DRAG-END.
*> USING row: header 2 of a drag: no slot ends with nothing, one slot is a PICKUP with the drag kind as button, several
*> share the cursor (40-1 section 3.4 item 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-PLACE               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-REMAINING           BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) TO WS-MAX
     EVALUATE TRUE
         WHEN MN-DRAG-COUNT(L-ROW) = 0
             CONTINUE
         WHEN MN-DRAG-COUNT(L-ROW) = 1
             MOVE MN-DRAG-SLOT(L-ROW, 1) TO WS-SLOT
             MOVE MN-DRAG-TYPE(L-ROW) TO WS-BUTTON
             MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
             IF WS-BUTTON < 2
                 CALL "MENU-CLICK-PICKUP" USING L-ROW WS-SLOT WS-BUTTON
             END-IF
         WHEN OTHER
             EVALUATE MN-DRAG-TYPE(L-ROW)
                 WHEN 0
                     COMPUTE WS-PLACE = PL-CARRIED-COUNT(L-ROW) / MN-DRAG-COUNT(L-ROW)
                 WHEN 1
                     MOVE 1 TO WS-PLACE
                 WHEN OTHER
                     MOVE WS-MAX TO WS-PLACE
             END-EVALUATE
             MOVE PL-CARRIED-COUNT(L-ROW) TO WS-REMAINING
             MOVE PL-CARRIED-ITEM(L-ROW) TO WS-ITEM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-DRAG-COUNT(L-ROW)
                 MOVE MN-DRAG-SLOT(L-ROW, WS-I) TO WS-SLOT
                 CALL "MENU-GET-X" USING L-ROW WS-SLOT WS-SI WS-SC WS-SV
                 COMPUTE WS-PLACED = FUNCTION MIN(WS-PLACE + WS-SC, WS-MAX)
                 COMPUTE WS-REMAINING = WS-REMAINING - (WS-PLACED - WS-SC)
                 CALL "MENU-SET-X" USING L-ROW WS-SLOT WS-ITEM WS-PLACED PL-CARRIED-VAR(L-ROW)
             END-PERFORM
             MOVE WS-REMAINING TO PL-CARRIED-COUNT(L-ROW)
             IF WS-REMAINING <= 0
                 MOVE 0 TO PL-CARRIED-COUNT(L-ROW) PL-CARRIED-ITEM(L-ROW) PL-CARRIED-VAR(L-ROW)
             END-IF
             MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
     END-EVALUATE
     IF MN-DRAG-ACTIVE(L-ROW) = 1 AND MN-DRAG-COUNT(L-ROW) = 0
         MOVE 0 TO MN-DRAG-ACTIVE(L-ROW)
     END-IF.
     GOBACK.
 END PROGRAM MENU-DRAG-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-DRAG.
*> USING row, menu slot, button: QUICK_CRAFT of 40-1 §3.4 item 6. The header (button mod 4) 0 starts a drag, 1 adds a
*> slot, 2 ends it; the kind (button / 4) 0 splits the cursor evenly, 1 puts one item in each slot, 2 (creative
*> only) a full stack in each. A header out of order resets the drag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-HEADER              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PLACE               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-REMAINING           BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     COMPUTE WS-HEADER = FUNCTION MOD(L-BUTTON, 4)
     COMPUTE WS-KIND = FUNCTION MOD((L-BUTTON - WS-HEADER) / 4, 4)
     IF PL-CARRIED-COUNT(L-ROW) <= 0
         MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
         GOBACK
     END-IF
     MOVE IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) TO WS-MAX
     EVALUATE TRUE
         WHEN WS-HEADER = 0
             MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
             IF WS-KIND < 2 OR (WS-KIND = 2 AND PL-MODE(L-ROW) = 1)
                 MOVE 1 TO MN-DRAG-ACTIVE(L-ROW)
                 MOVE WS-KIND TO MN-DRAG-TYPE(L-ROW)
             END-IF
         WHEN WS-HEADER = 1 AND MN-DRAG-ACTIVE(L-ROW) = 1
             CALL "MENU-DRAG-ADD" USING L-ROW L-SLOT
         WHEN WS-HEADER = 2 AND MN-DRAG-ACTIVE(L-ROW) = 1
             CALL "MENU-DRAG-END" USING L-ROW
         WHEN OTHER
             MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-CLICK-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-LOOP.
*> USING row, menu slot: QUICK_MOVE of 40-1 section 3.4 item 1: quickMoveStack repeated while the slot still holds the item
*> that was moved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-RET-ITEM            BINARY-LONG.
 01 WS-RET-COUNT           BINARY-LONG.
 01 WS-LOOPS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 0 TO WS-LOOPS
     CALL "MENU-QUICK-MOVE" USING L-ROW L-SLOT WS-RET-ITEM WS-RET-COUNT
     PERFORM UNTIL WS-RET-COUNT = 0 OR WS-LOOPS > 4096
         ADD 1 TO WS-LOOPS
         CALL "MENU-GET" USING L-ROW L-SLOT WS-SI WS-SC
         IF WS-SC > 0 AND WS-SI = WS-RET-ITEM
             CALL "MENU-QUICK-MOVE" USING L-ROW L-SLOT WS-RET-ITEM WS-RET-COUNT
         ELSE
             MOVE 0 TO WS-RET-COUNT
         END-IF
     END-PERFORM.
     GOBACK.
 END PROGRAM MENU-QUICK-LOOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK-PICK.
*> USING row, menu slot, button (0 or 1), click type (0 PICKUP, 1 QUICK_MOVE): the slot -999 throw from the cursor, a PICKUP
*> or a QUICK_MOVE of a slot (40-1 section 3.4 item 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON L-TYPE.
     IF L-SLOT = -999
         IF PL-CARRIED-COUNT(L-ROW) > 0
             MOVE PL-CARRIED-ITEM(L-ROW) TO WS-ITEM
             MOVE PL-CARRIED-COUNT(L-ROW) TO WS-COUNT
             MOVE PL-CARRIED-VAR(L-ROW) TO WS-VAR
             IF L-BUTTON = 1
                 MOVE 1 TO WS-COUNT
             END-IF
             SUBTRACT WS-COUNT FROM PL-CARRIED-COUNT(L-ROW)
             IF PL-CARRIED-COUNT(L-ROW) = 0
                 MOVE 0 TO PL-CARRIED-ITEM(L-ROW) PL-CARRIED-VAR(L-ROW)
             END-IF
             CALL "GI-THROW-STACK-X" USING L-ROW WS-ITEM WS-COUNT WS-VAR
         END-IF
     ELSE
         IF L-SLOT >= 0
             IF L-TYPE = 0
                 CALL "MENU-CLICK-PICKUP" USING L-ROW L-SLOT L-BUTTON
             ELSE
                 CALL "MENU-QUICK-LOOP" USING L-ROW L-SLOT
             END-IF
         END-IF
     END-IF.
     GOBACK.
 END PROGRAM MENU-CLICK-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLICK.
*> USING row, menu slot, button, click type: one Container Click applied to the player's current menu (40-1 §3.4):
*> no packet is sent here (INV-CLICK echoes). The order of the checks is the document's: a drag first, any other click
*> ends a drag in progress, then PICKUP and QUICK_MOVE, SWAP, CLONE, THROW, PICKUP_ALL. The result of the grid is
*> recomputed at the end (MENU-CRAFT-UPDATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-SI                  BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RET-ITEM            BINARY-LONG.
 01 WS-RET-COUNT           BINARY-LONG.
 01 WS-LOOPS               BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-SV                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON L-TYPE.
     CALL "MENU-SLOT-COUNT" USING L-ROW WS-LIMIT
     IF L-SLOT < -999 OR L-SLOT >= WS-LIMIT
         GOBACK
     END-IF
     IF L-TYPE = 5
         CALL "MENU-CLICK-DRAG" USING L-ROW L-SLOT L-BUTTON
         CALL "MENU-CRAFT-UPDATE" USING L-ROW
         GOBACK
     END-IF
     IF MN-DRAG-ACTIVE(L-ROW) = 1
         MOVE 0 TO MN-DRAG-ACTIVE(L-ROW) MN-DRAG-COUNT(L-ROW)
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN (L-TYPE = 0 OR L-TYPE = 1) AND L-BUTTON >= 0 AND L-BUTTON <= 1
             CALL "MENU-CLICK-PICK" USING L-ROW L-SLOT L-BUTTON L-TYPE
         WHEN L-TYPE = 2 AND L-SLOT >= 0
             CALL "MENU-CLICK-SWAP" USING L-ROW L-SLOT L-BUTTON
         WHEN L-TYPE = 3 AND L-SLOT >= 0 AND PL-MODE(L-ROW) = 1 AND PL-CARRIED-COUNT(L-ROW) = 0
             CALL "MENU-GET-X" USING L-ROW L-SLOT WS-SI WS-SC WS-SV
             IF WS-SC > 0
                 MOVE WS-SI TO PL-CARRIED-ITEM(L-ROW)
                 MOVE WS-SV TO PL-CARRIED-VAR(L-ROW)
                 MOVE IT-MAX-STACK(WS-SI + 1) TO PL-CARRIED-COUNT(L-ROW)
             END-IF
         WHEN L-TYPE = 4 AND L-SLOT >= 0 AND PL-CARRIED-COUNT(L-ROW) = 0 AND L-BUTTON >= 0
                 AND L-BUTTON <= 1
             CALL "MENU-CLICK-THROW" USING L-ROW L-SLOT L-BUTTON
         WHEN L-TYPE = 6 AND L-SLOT >= 0 AND PL-CARRIED-COUNT(L-ROW) > 0
             CALL "MENU-GET" USING L-ROW L-SLOT WS-SI WS-SC
             IF WS-SC = 0
                 CALL "MENU-CLICK-PICKUP-ALL" USING L-ROW L-SLOT L-BUTTON
             END-IF
     END-EVALUATE
     CALL "MENU-CRAFT-UPDATE" USING L-ROW
     GOBACK.
 END PROGRAM MENU-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-QUICK-MOVE.
*> USING row, menu slot, returned item out, returned count out: quickMoveStack of the player's current menu (the
*> template of 40-1 §3.6): the pre-move copy of the stack when something moved, an empty stack (count 0) when nothing did.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT.
     EVALUATE TRUE
         WHEN MN-WINDOW(L-ROW) = 0
             CALL "MENU-INV-QUICK-MOVE" USING L-ROW L-SLOT L-ITEM L-COUNT
         WHEN MN-CSIZE(L-ROW) > 0
             CALL "MENU-CONT-QUICK-MOVE" USING L-ROW L-SLOT L-ITEM L-COUNT
         WHEN OTHER
             CALL "MENU-BENCH-QUICK-MOVE" USING L-ROW L-SLOT L-ITEM L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-QUICK-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-STATE-RAISE.
*> USING row, old state id out, new state id out: raises the state id of the player's current menu by one (mod 32768).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OLD L-NEW.
     IF MN-WINDOW(L-ROW) = 0
         MOVE PL-STATE-ID(L-ROW) TO L-OLD
         COMPUTE PL-STATE-ID(L-ROW) = FUNCTION MOD(PL-STATE-ID(L-ROW) + 1, 32768)
         MOVE PL-STATE-ID(L-ROW) TO L-NEW
     ELSE
         MOVE MN-STATE-ID(L-ROW) TO L-OLD
         COMPUTE MN-STATE-ID(L-ROW) = FUNCTION MOD(MN-STATE-ID(L-ROW) + 1, 32768)
         MOVE MN-STATE-ID(L-ROW) TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM MENU-STATE-RAISE.
