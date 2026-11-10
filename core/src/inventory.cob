*> The player inventory and the wire side of the player's menu (data-model §4; standin-content §2; docs/protocol/09-cobolcraft-profile.md
*> §3.2 "Inventory slots"; 05c 0x12, 0x13, 0x36, 0x39; 05a 0x12, 0x14; 40-1 §3, §4; T0376).
*>
*> The inventory is the 36 slots of the player row (container slots 0 to 35: 0 to 8 the hotbar, 9 to 35 the main inventory;
*> PL-SLOT(n + 1)) plus the armor and off-hand slots (container slots 36 to 40, MN-EQUIP of CMENU.cpy); a count of 0
*> is an empty slot (its item is 0). The held hotbar slot is PL-HELD. The item on the cursor is PL-CARRIED-ITEM/-COUNT. A
*> stack never holds more than its item's maximum stack size (CITEMS.cpy IT-MAX-STACK).
*>
*> The slot numbers of the wire are the numbers of the player's menu (core/src/menus.cob, menu-inventory.cob, menu-bench.cob):
*> the inventory menu (container id 0) has 46 slots, 0 the result, 1 to 4 the 2 x 2 grid, 5 to 8 helmet to boots, 9 to 35
*> the main inventory, 36 to 44 the hotbar, 45 the off-hand; the crafting bench menu (container id 1 to 100) has the 3 x 3
*> grid in 1 to 9, the main inventory in 10 to 36 and the hotbar in 37 to 45. The internal programs below (INV-ADD,
*> INV-REMOVE, INV-MOVE, INV-SLOT-SEND) keep the container slot numbers 0 to 35.
*>
*> Container Click (05c 0x12; click types and their rules are MENU-CLICK in menus.cob) changes the slots and the cursor of the
*> menu named by the container id (the player's current one; another id is ignored). Every click raises the menu's state id by
*> one (mod 32768). Each slot the click changed is echoed with Container Set Slot (the container id, the new state id, the
*> slot, its stack). When the click's state id was not the current one, or the client's predicted carried item or a
*> predicted slot differs from the server's, Container Set Content (with the cursor) follows to resynchronise. A thrown stack
*> becomes a ground item (GI-THROW-STACK, core/src/ground-items.cob) before the echoes.
*>
*> Container Close: the carried stack goes back into the inventory as INV-ADD places it, the grid items of the closed menu
*> do the same, what does not fit is thrown (standin §9.1), the cursor is emptied, an unfinished drag ends, the menu becomes
*> the inventory menu, and the changed slots are echoed (container 0, the state id raised once).
*>
*> Entry points:
*>   INV-ADD USING player row, item, count, left out          add (matching stacks, then empty slots)
*>   INV-ADD-RANGE-X USING row, item, count, first, last, left out, patch handle   the same for a stack with a patch (CSTACK.cpy)
*>   INV-ADD-RANGE USING row, item, count, first, last, left out   the same within slots first..last
*>   INV-REMOVE USING player row, slot, count                  remove up to count from the slot
*>   INV-MOVE USING player row, from slot, to slot             move, merge or swap
*>   INV-HELD USING connection id, slot                        Set Carried Item (0 to 8; others ignored)
*>   INV-CLICK USING connection id, PLAY-SERVERBOUND           Container Click
*>   INV-CLOSE USING connection id, PLAY-SERVERBOUND           Container Close
*>   MENU-CLOSE USING connection id                            the close itself (also when another menu replaces the bench)
*>   INV-CREATIVE-SET USING connection id, PLAY-SERVERBOUND    Set Creative Mode Slot
*>   INV-SLOT-SEND USING connection id, container slot (0 to 35)   Container Set Slot of one inventory slot
*>   MENU-SLOT-SEND USING connection id, menu slot             Container Set Slot of one slot of the current menu
*>   CONTAINER-SET-SLOT-BUILD USING container, state id, slot, PB-ITEMSTACK, PB-BUFFER
*>   CONTAINER-SET-SLOT-BUILD-X USING container, state id, slot, PB-ITEMSTACK-X, PB-BUFFER   the same with the component patch

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-ADD-RANGE-X.
*> USING player row, item, count, first slot, last slot, left out (BINARY-LONG): adds count items to
*> slots first..last: stacks of the same item below the maximum first, then empty slots, each in slot
*> order. Left is the part that did not fit (not added). A stack with a patch handle (the last argument; 0 = none) merges only
*> onto stacks with the same handle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FIRST L-LAST L-LEFT L-VAR.
     MOVE L-COUNT TO L-LEFT
     MOVE IT-MAX-STACK(L-ITEM + 1) TO WS-MAX
     PERFORM VARYING WS-S FROM L-FIRST BY 1 UNTIL WS-S > L-LAST OR L-LEFT = 0
         IF PL-SLOT-COUNT(L-ROW, WS-S + 1) > 0 AND PL-SLOT-ITEM(L-ROW, WS-S + 1) = L-ITEM
                 AND PL-SLOT-VAR(L-ROW, WS-S + 1) = L-VAR
             COMPUTE WS-N = FUNCTION MIN(L-LEFT, WS-MAX - PL-SLOT-COUNT(L-ROW, WS-S + 1))
             IF WS-N > 0
                 ADD WS-N TO PL-SLOT-COUNT(L-ROW, WS-S + 1)
                 SUBTRACT WS-N FROM L-LEFT
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-S FROM L-FIRST BY 1 UNTIL WS-S > L-LAST OR L-LEFT = 0
         IF PL-SLOT-COUNT(L-ROW, WS-S + 1) = 0
             COMPUTE WS-N = FUNCTION MIN(L-LEFT, WS-MAX)
             MOVE L-ITEM TO PL-SLOT-ITEM(L-ROW, WS-S + 1)
             MOVE L-VAR TO PL-SLOT-VAR(L-ROW, WS-S + 1)
             MOVE WS-N TO PL-SLOT-COUNT(L-ROW, WS-S + 1)
             SUBTRACT WS-N FROM L-LEFT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM INV-ADD-RANGE-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-ADD-RANGE.
*> USING player row, item, count, first slot, last slot, left out: INV-ADD-RANGE-X for a stack without a patch.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FIRST L-LAST L-LEFT.
     CALL "INV-ADD-RANGE-X" USING L-ROW L-ITEM L-COUNT L-FIRST L-LAST L-LEFT WS-NONE
     GOBACK.
 END PROGRAM INV-ADD-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-ADD.
*> USING player row, item, count, left out (BINARY-LONG): INV-ADD-RANGE over slots 0 to 35.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIRST               BINARY-LONG VALUE 0.
 01 WS-LAST                BINARY-LONG VALUE 35.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-LEFT.
     CALL "INV-ADD-RANGE" USING L-ROW L-ITEM L-COUNT WS-FIRST WS-LAST L-LEFT
     GOBACK.
 END PROGRAM INV-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-REMOVE.
*> USING player row, slot (0 to 35), count (BINARY-LONG): removes up to count items from the slot; a
*> slot left with none is empty (item 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-COUNT.
     COMPUTE PL-SLOT-COUNT(L-ROW, L-SLOT + 1)
         = FUNCTION MAX(PL-SLOT-COUNT(L-ROW, L-SLOT + 1) - L-COUNT, 0)
     IF PL-SLOT-COUNT(L-ROW, L-SLOT + 1) = 0
         MOVE 0 TO PL-SLOT-ITEM(L-ROW, L-SLOT + 1) PL-SLOT-VAR(L-ROW, L-SLOT + 1)
     END-IF
     GOBACK.
 END PROGRAM INV-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-MOVE.
*> USING player row, from slot, to slot (BINARY-LONG, 0 to 35; US4-6): the stack of the from slot
*> moves to an empty to slot, tops up a stack of the same item there (the rest stays), or is swapped
*> with a stack of another item. An empty from slot or the same slot changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-F                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FROM L-TO.
     COMPUTE WS-F = L-FROM + 1
     COMPUTE WS-T = L-TO + 1
     IF PL-SLOT-COUNT(L-ROW, WS-F) = 0 OR WS-F = WS-T
         GOBACK
     END-IF
     IF PL-SLOT-COUNT(L-ROW, WS-T) > 0 AND PL-SLOT-ITEM(L-ROW, WS-T) = PL-SLOT-ITEM(L-ROW, WS-F)
             AND PL-SLOT-VAR(L-ROW, WS-T) = PL-SLOT-VAR(L-ROW, WS-F)
         MOVE PL-SLOT-ITEM(L-ROW, WS-T) TO WS-ITEM
         COMPUTE WS-N = IT-MAX-STACK(WS-ITEM + 1) - PL-SLOT-COUNT(L-ROW, WS-T)
         COMPUTE WS-N = FUNCTION MIN(WS-N, PL-SLOT-COUNT(L-ROW, WS-F))
         ADD WS-N TO PL-SLOT-COUNT(L-ROW, WS-T)
         CALL "INV-REMOVE" USING L-ROW L-FROM WS-N
         GOBACK
     END-IF
     MOVE PL-SLOT-ITEM(L-ROW, WS-T) TO WS-ITEM
     MOVE PL-SLOT-COUNT(L-ROW, WS-T) TO WS-COUNT
     MOVE PL-SLOT-VAR(L-ROW, WS-T) TO WS-VAR
     MOVE PL-SLOT(L-ROW, WS-F) TO PL-SLOT(L-ROW, WS-T)
     MOVE PL-SLOT-VAR(L-ROW, WS-F) TO PL-SLOT-VAR(L-ROW, WS-T)
     MOVE WS-ITEM TO PL-SLOT-ITEM(L-ROW, WS-F)
     MOVE WS-COUNT TO PL-SLOT-COUNT(L-ROW, WS-F)
     MOVE WS-VAR TO PL-SLOT-VAR(L-ROW, WS-F)
     GOBACK.
 END PROGRAM INV-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-HELD.
*> USING connection id, slot (BINARY-LONG): Set Carried Item (05c 0x36): a hotbar slot 0 to 8 becomes
*> the held slot; any other value is ignored. A change of held slot stops eating (standin §11.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     IF L-SLOT >= 0 AND L-SLOT <= 8
         IF L-SLOT NOT = PL-HELD(CN-PLAYER(L-ID))
             CALL "HUNGER-CANCEL" USING CN-PLAYER(L-ID)
*>           A changed held item restarts the attack strength ticker (17 section 4.1).
             CALL "COMBAT-TICKER-RESET" USING CN-PLAYER(L-ID)
*>           A changed held item ends a break in progress (13 section 2.4).
             IF PL-BREAKING(CN-PLAYER(L-ID)) = 1
                 CALL "BLOCK-BREAK-END" USING CN-PLAYER(L-ID)
             END-IF
         END-IF
         MOVE L-SLOT TO PL-HELD(CN-PLAYER(L-ID))
     END-IF
     GOBACK.
 END PROGRAM INV-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-SET-SLOT-BUILD.
*> USING container id, state id, slot (BINARY-LONG), PB-ITEMSTACK, PB-BUFFER: appends Container Set
*> Slot 0x14 (05a: VarInt container, VarInt state id, Short slot, ItemStack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTAINER L-STATE-ID L-SLOT PB-ITEMSTACK PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     GOBACK.
 END PROGRAM CONTAINER-SET-SLOT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-SET-SLOT-BUILD-X.
*> USING container id, state id, slot (BINARY-LONG), PB-ITEMSTACK-X, PB-BUFFER: appends Container Set Slot 0x14 (05a: VarInt
*> container, VarInt state id, Short slot, ItemStack with its DataComponentPatch, 00 section 12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTAINER L-STATE-ID L-SLOT PB-ITEMSTACK-X PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     GOBACK.
 END PROGRAM CONTAINER-SET-SLOT-BUILD-X.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-SLOT-SEND.
*> USING connection id, menu slot (BINARY-LONG): sends the player Container Set Slot of that slot of the current menu with the
*> menu's container id and current state id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "MENU-GET-X" USING WS-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     CALL "SP-EXPORT" USING WS-ITEM WS-COUNT WS-VAR PB-ITEMSTACK-X
     IF MN-WINDOW(WS-ROW) = 0
         MOVE PL-STATE-ID(WS-ROW) TO WS-STATE
     ELSE
         MOVE MN-STATE-ID(WS-ROW) TO WS-STATE
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONTAINER-SET-SLOT-BUILD-X" USING MN-WINDOW(WS-ROW) WS-STATE L-SLOT PB-ITEMSTACK-X PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     GOBACK.
 END PROGRAM MENU-SLOT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-SLOT-SEND.
*> USING connection id, container slot 0 to 35 (BINARY-LONG): sends the player Container Set Slot of that inventory slot,
*> numbered as the player's current menu shows it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MENU-SLOT           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     CALL "MENU-CONTAINER-SLOT" USING CN-PLAYER(L-ID) L-SLOT WS-MENU-SLOT
     IF WS-MENU-SLOT >= 0
         CALL "MENU-SLOT-SEND" USING L-ID WS-MENU-SLOT
     END-IF
     GOBACK.
 END PROGRAM INV-SLOT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CLICK.
*> USING connection id, PLAY-SERVERBOUND (a decoded Container Click): the click rules (MENU-CLICK), echoes and
*> resynchronisation above. A click on another container than the player's current menu, or on a slot number from 46 up,
*> is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OLD-STATE           BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-RESYNC              PIC 9.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 46 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
       10 WS-BEFORE-VAR    BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PSB-CONTAINER NOT = MN-WINDOW(WS-ROW) OR PSB-SLOT >= 46
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-BEFORE-ITEM(WS-S + 1) WS-BEFORE-COUNT(WS-S + 1)
             WS-BEFORE-VAR(WS-S + 1)
     END-PERFORM
     CALL "MENU-CLICK" USING WS-ROW PSB-SLOT PSB-BUTTON PSB-CLICK-TYPE
*>   State id, echoes of the changed slots, resynchronisation.
     CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD-STATE WS-NEW-STATE
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-ITEM WS-COUNT WS-VAR
         IF WS-ITEM NOT = WS-BEFORE-ITEM(WS-S + 1) OR WS-COUNT NOT = WS-BEFORE-COUNT(WS-S + 1)
                 OR WS-VAR NOT = WS-BEFORE-VAR(WS-S + 1)
             CALL "MENU-SLOT-SEND" USING L-ID WS-S
         END-IF
     END-PERFORM
     MOVE 0 TO WS-RESYNC
     IF PSB-STATE-ID NOT = WS-OLD-STATE OR PSB-CARRIED-COUNT NOT = PL-CARRIED-COUNT(WS-ROW)
             OR (PSB-CARRIED-COUNT > 0 AND PSB-CARRIED-ITEM NOT = PL-CARRIED-ITEM(WS-ROW))
         MOVE 1 TO WS-RESYNC
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-CHANGED-COUNT
         MOVE PSB-CHANGED-SLOT(WS-I) TO WS-SLOT
         IF WS-SLOT >= 0 AND WS-SLOT <= 45
             CALL "MENU-GET" USING WS-ROW WS-SLOT WS-ITEM WS-COUNT
             IF PSB-CHANGED-AMOUNT(WS-I) NOT = WS-COUNT
                     OR (PSB-CHANGED-AMOUNT(WS-I) > 0 AND PSB-CHANGED-ITEM(WS-I) NOT = WS-ITEM)
                 MOVE 1 TO WS-RESYNC
             END-IF
         END-IF
     END-PERFORM
     IF WS-RESYNC = 1
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
         CALL "CORE-SEND" USING L-ID PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM INV-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CLOSE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Container Close): the close rule above. Another container id than the
*> player's current menu is ignored; closing the inventory menu with an empty cursor and an empty grid changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-CONTAINER = MN-WINDOW(CN-PLAYER(L-ID))
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     GOBACK.
 END PROGRAM INV-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-RETURN-STACK-X.
*> USING player row, item, count, patch handle: puts the stack back into the inventory as INV-ADD places it and throws what does not fit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEFT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG VALUE 0.
 01 WS-LAST                BINARY-LONG VALUE 35.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-VAR.
     CALL "INV-ADD-RANGE-X" USING L-ROW L-ITEM L-COUNT WS-FIRST WS-LAST WS-LEFT L-VAR
     IF WS-LEFT > 0
         CALL "GI-THROW-STACK" USING L-ROW L-ITEM WS-LEFT
     END-IF
     GOBACK.
 END PROGRAM MENU-RETURN-STACK-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-CLOSE.
*> USING connection id: closes the player's current menu (the Container Close rule above, also run when a bench menu is
*> replaced by another menu).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-WINDOW              BINARY-LONG.
 01 WS-BUSY                BINARY-LONG.
 01 WS-OLD-STATE           BINARY-LONG.
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 46 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
       10 WS-BEFORE-VAR    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE MN-WINDOW(WS-ROW) TO WS-WINDOW
     MOVE 0 TO MN-DRAG-ACTIVE(WS-ROW) MN-DRAG-COUNT(WS-ROW)
     MOVE 0 TO WS-BUSY
     IF WS-WINDOW > 0 OR PL-CARRIED-COUNT(WS-ROW) > 0
         MOVE 1 TO WS-BUSY
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF MN-IGRID-COUNT(WS-ROW, WS-I) > 0
             MOVE 1 TO WS-BUSY
         END-IF
     END-PERFORM
     IF WS-BUSY = 0
         GOBACK
     END-IF
*>   What the client shows afterwards is the inventory menu: its slots before the changes are the reference.
     MOVE 0 TO MN-WINDOW(WS-ROW)
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-BEFORE-ITEM(WS-S + 1) WS-BEFORE-COUNT(WS-S + 1)
             WS-BEFORE-VAR(WS-S + 1)
     END-PERFORM
     MOVE WS-WINDOW TO MN-WINDOW(WS-ROW)
     IF PL-CARRIED-COUNT(WS-ROW) > 0
         MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-ITEM
         MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-COUNT
         MOVE PL-CARRIED-VAR(WS-ROW) TO WS-VAR
         MOVE 0 TO PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-COUNT(WS-ROW) PL-CARRIED-VAR(WS-ROW)
         CALL "MENU-RETURN-STACK-X" USING WS-ROW WS-ITEM WS-COUNT WS-VAR
     END-IF
     IF WS-WINDOW = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             IF MN-IGRID-COUNT(WS-ROW, WS-I) > 0
                 MOVE MN-IGRID-ITEM(WS-ROW, WS-I) TO WS-ITEM
                 MOVE MN-IGRID-COUNT(WS-ROW, WS-I) TO WS-COUNT
                 MOVE MN-IGRID-VAR(WS-ROW, WS-I) TO WS-VAR
                 MOVE 0 TO MN-IGRID-ITEM(WS-ROW, WS-I) MN-IGRID-COUNT(WS-ROW, WS-I) MN-IGRID-VAR(WS-ROW, WS-I)
                 CALL "MENU-RETURN-STACK-X" USING WS-ROW WS-ITEM WS-COUNT WS-VAR
             END-IF
         END-PERFORM
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
             IF MN-BGRID-COUNT(WS-ROW, WS-I) > 0
                 MOVE MN-BGRID-ITEM(WS-ROW, WS-I) TO WS-ITEM
                 MOVE MN-BGRID-COUNT(WS-ROW, WS-I) TO WS-COUNT
                 MOVE MN-BGRID-VAR(WS-ROW, WS-I) TO WS-VAR
                 MOVE 0 TO MN-BGRID-ITEM(WS-ROW, WS-I) MN-BGRID-COUNT(WS-ROW, WS-I) MN-BGRID-VAR(WS-ROW, WS-I)
                 CALL "MENU-RETURN-STACK-X" USING WS-ROW WS-ITEM WS-COUNT WS-VAR
             END-IF
         END-PERFORM
         MOVE 0 TO MN-WINDOW(WS-ROW) MN-TYPE(WS-ROW) MN-RESULT-ITEM(WS-ROW) MN-RESULT-COUNT(WS-ROW)
     END-IF
     CALL "MENU-CRAFT-UPDATE" USING WS-ROW
     CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD-STATE WS-NEW-STATE
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET-X" USING WS-ROW WS-S WS-ITEM WS-COUNT WS-VAR
         IF WS-ITEM NOT = WS-BEFORE-ITEM(WS-S + 1) OR WS-COUNT NOT = WS-BEFORE-COUNT(WS-S + 1)
                 OR WS-VAR NOT = WS-BEFORE-VAR(WS-S + 1)
             CALL "MENU-SLOT-SEND" USING L-ID WS-S
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CREATIVE-SET.
*> USING connection id, PLAY-SERVERBOUND (a decoded Set Creative Mode Slot, 05c 0x39): acted on only for a creative player
*> (09 §3.2) whose menu is the inventory menu. Slot 1 to 45 (menu numbers: grid, armor, main, hotbar, off-hand; not the
*> result slot 0) becomes the stack: count 0 empties it; an item id outside 1 to the item count is ignored; a count above
*> the item's maximum stack is lowered to it; the stack's component patch (PSB-STACK-VAR) goes into the slot with it. Slot -1 (the creative inventory's drop, CC-0006) throws the stack as a
*> ground item (the same limits); other slots are ignored. Nothing is echoed (the client set it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-MODE(WS-ROW) NOT = 1 OR MN-WINDOW(WS-ROW) NOT = 0
         GOBACK
     END-IF
*>   Slot -1 is the drop of the creative inventory screen (CC-0006): the stack becomes a ground item.
     IF PSB-SLOT = -1
         IF PSB-STACK-COUNT > 0 AND PSB-STACK-ITEM >= 1 AND PSB-STACK-ITEM < IT-COUNT
             MOVE PSB-STACK-ITEM TO WS-ITEM
             MOVE FUNCTION MIN(PSB-STACK-COUNT, IT-MAX-STACK(PSB-STACK-ITEM + 1)) TO WS-COUNT
             CALL "GI-THROW-STACK" USING WS-ROW WS-ITEM WS-COUNT
         END-IF
         GOBACK
     END-IF
     IF PSB-SLOT < 1 OR PSB-SLOT > 45
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN PSB-STACK-COUNT <= 0
             MOVE 0 TO WS-ITEM WS-COUNT
             CALL "MENU-SET" USING WS-ROW PSB-SLOT WS-ITEM WS-COUNT
         WHEN PSB-STACK-ITEM >= 1 AND PSB-STACK-ITEM < IT-COUNT
             MOVE PSB-STACK-ITEM TO WS-ITEM
             MOVE IT-MAX-STACK(PSB-STACK-ITEM + 1) TO WS-COUNT
             IF PSB-STACK-COUNT < WS-COUNT
                 MOVE PSB-STACK-COUNT TO WS-COUNT
             END-IF
             CALL "MENU-SET-X" USING WS-ROW PSB-SLOT WS-ITEM WS-COUNT PSB-STACK-VAR
             CALL "MENU-CRAFT-UPDATE" USING WS-ROW
     END-EVALUATE
     GOBACK.
 END PROGRAM INV-CREATIVE-SET.
