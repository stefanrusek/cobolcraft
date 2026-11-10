*> The player inventory (data-model §4; standin-content §2; docs/protocol/09-cobolcraft-profile.md
*> §3.2 "Inventory slots"; 05c 0x12, 0x36, 0x39; 05a 0x14).
*>
*> 36 slots: slot n is PL-SLOT(n + 1) of the player row, 0 to 8 the hotbar, 9 to 35 the main
*> inventory; a count of 0 is an empty slot (its item is 0). The held hotbar slot is PL-HELD. The item
*> on the cursor of the inventory screen is PL-CARRIED-ITEM/-COUNT. A stack never holds more than its
*> item's maximum stack size (ITEMS.cpy IT-MAX-STACK).
*>
*> Container Click (container 0 only; 05c click types) changes the slots and the cursor:
*>   0 PICKUP, button 0 (left): an empty cursor takes the whole slot; a full cursor is put down on an
*>     empty slot, tops up a slot of the same item (the rest stays on the cursor) or is swapped with a
*>     slot of another item. Button 1 (right): an empty cursor takes half the slot (rounded up); a
*>     full cursor puts one item on an empty slot or a non-full slot of the same item, or is swapped
*>     with a slot of another item. A click outside the window (slot -999) throws from the cursor
*>     (standin §9.1 inventory-screen throw): button 0 the whole carried stack, button 1 one item;
*>     with an empty cursor nothing changes.
*>   1 QUICK_MOVE: the slot's stack moves to the other part of the inventory (hotbar to main, main to
*>     hotbar), filling stacks of the same item first, then empty slots in slot order; what does not
*>     fit stays.
*>   2 SWAP: the slot is swapped with hotbar slot "button" (0 to 8).
*>   3 CLONE: creative only, with an empty cursor: the cursor gets a full stack of the slot's item.
*>   4 THROW: button 0 (Q) throws one item of the slot, button 1 (Ctrl+Q) the whole stack (standin
*>     §9.1, as Player Action 5 and 4 do for the held slot); an empty slot or another button
*>     changes nothing.
*>   5 QUICK_CRAFT (drag): button mod 4 is the stage (0 start, 1 add a slot, 2 end), button / 4 the
*>     kind (0 split the cursor evenly, 1 one item each, 2 a full stack each, creative only). Slots
*>     can be added when empty or holding the cursor's item below its maximum; at the end each slot
*>     receives its share (what does not fit stays on the cursor).
*>   6 PICKUP_ALL: the cursor gathers its item from the slots, non-full stacks first, then full ones,
*>     up to its maximum stack.
*> Every click raises the container's state id by one (mod 32768). Each slot the click changed is
*> echoed with Container Set Slot (container 0, the new state id, the slot, its stack). When the
*> click's state id was not the current one, or the client's predicted carried item or a predicted
*> slot differs from the server's, Container Set Content (with the cursor) follows to resynchronise.
*> A thrown stack becomes a ground item (GI-THROW-STACK, core/src/ground-items.cob) before the echoes.
*>
*> Container Close (container 0 only): the carried stack goes back into the inventory as INV-ADD
*> places it, what does not fit is thrown (standin §9.1), the cursor is emptied, an unfinished drag
*> ends, and the changed slots are echoed as for a click (the state id raised once).
*>
*> Entry points:
*>   INV-ADD USING player row, item, count, left out          add (matching stacks, then empty slots)
*>   INV-ADD-RANGE USING row, item, count, first, last, left out   the same within slots first..last
*>   INV-REMOVE USING player row, slot, count                  remove up to count from the slot
*>   INV-MOVE USING player row, from slot, to slot             move, merge or swap
*>   INV-HELD USING connection id, slot                        Set Carried Item (0 to 8; others ignored)
*>   INV-CLICK USING connection id, PLAY-SERVERBOUND           Container Click
*>   INV-CLOSE USING connection id, PLAY-SERVERBOUND           Container Close
*>   INV-CREATIVE-SET USING connection id, PLAY-SERVERBOUND    Set Creative Mode Slot
*>   INV-SLOT-SEND USING connection id, slot                   Container Set Slot of one slot
*>   CONTAINER-SET-SLOT-BUILD USING container, state id, slot, PB-ITEMSTACK, PB-BUFFER

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-ADD-RANGE.
*> USING player row, item, count, first slot, last slot, left out (BINARY-LONG): adds count items to
*> slots first..last: stacks of the same item below the maximum first, then empty slots, each in slot
*> order. Left is the part that did not fit (not added).
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
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FIRST L-LAST L-LEFT.
     MOVE L-COUNT TO L-LEFT
     MOVE IT-MAX-STACK(L-ITEM + 1) TO WS-MAX
     PERFORM VARYING WS-S FROM L-FIRST BY 1 UNTIL WS-S > L-LAST OR L-LEFT = 0
         IF PL-SLOT-COUNT(L-ROW, WS-S + 1) > 0 AND PL-SLOT-ITEM(L-ROW, WS-S + 1) = L-ITEM
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
             MOVE WS-N TO PL-SLOT-COUNT(L-ROW, WS-S + 1)
             SUBTRACT WS-N FROM L-LEFT
         END-IF
     END-PERFORM
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
         MOVE 0 TO PL-SLOT-ITEM(L-ROW, L-SLOT + 1)
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
         MOVE PL-SLOT-ITEM(L-ROW, WS-T) TO WS-ITEM
         COMPUTE WS-N = IT-MAX-STACK(WS-ITEM + 1) - PL-SLOT-COUNT(L-ROW, WS-T)
         COMPUTE WS-N = FUNCTION MIN(WS-N, PL-SLOT-COUNT(L-ROW, WS-F))
         ADD WS-N TO PL-SLOT-COUNT(L-ROW, WS-T)
         CALL "INV-REMOVE" USING L-ROW L-FROM WS-N
         GOBACK
     END-IF
     MOVE PL-SLOT-ITEM(L-ROW, WS-T) TO WS-ITEM
     MOVE PL-SLOT-COUNT(L-ROW, WS-T) TO WS-COUNT
     MOVE PL-SLOT(L-ROW, WS-F) TO PL-SLOT(L-ROW, WS-T)
     MOVE WS-ITEM TO PL-SLOT-ITEM(L-ROW, WS-F)
     MOVE WS-COUNT TO PL-SLOT-COUNT(L-ROW, WS-F)
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
 PROGRAM-ID. INV-SLOT-SEND.
*> USING connection id, slot (BINARY-LONG): sends the player Container Set Slot of that inventory
*> slot with the container's current state id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-SLOT-ITEM(WS-ROW, L-SLOT + 1) TO PB-IS-ITEM
     MOVE PL-SLOT-COUNT(WS-ROW, L-SLOT + 1) TO PB-IS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONTAINER-SET-SLOT-BUILD" USING WS-ZERO PL-STATE-ID(WS-ROW) L-SLOT PB-ITEMSTACK
         PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     GOBACK.
 END PROGRAM INV-SLOT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CLICK-PICKUP.
*> USING player row, slot (0 to 35), button (BINARY-LONG): click type 0 PICKUP on a slot (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     COMPUTE WS-S = L-SLOT + 1
     EVALUATE TRUE
         WHEN PL-CARRIED-COUNT(L-ROW) = 0 AND L-BUTTON = 0
             MOVE PL-SLOT-ITEM(L-ROW, WS-S) TO PL-CARRIED-ITEM(L-ROW)
             MOVE PL-SLOT-COUNT(L-ROW, WS-S) TO PL-CARRIED-COUNT(L-ROW)
             MOVE 0 TO PL-SLOT-ITEM(L-ROW, WS-S) PL-SLOT-COUNT(L-ROW, WS-S)
         WHEN PL-CARRIED-COUNT(L-ROW) = 0
             MOVE PL-SLOT-ITEM(L-ROW, WS-S) TO PL-CARRIED-ITEM(L-ROW)
             COMPUTE PL-CARRIED-COUNT(L-ROW) = (PL-SLOT-COUNT(L-ROW, WS-S) + 1) / 2
             SUBTRACT PL-CARRIED-COUNT(L-ROW) FROM PL-SLOT-COUNT(L-ROW, WS-S)
         WHEN PL-SLOT-COUNT(L-ROW, WS-S) > 0
                 AND PL-SLOT-ITEM(L-ROW, WS-S) NOT = PL-CARRIED-ITEM(L-ROW)
             MOVE PL-SLOT-ITEM(L-ROW, WS-S) TO WS-ITEM
             MOVE PL-SLOT-COUNT(L-ROW, WS-S) TO WS-COUNT
             MOVE PL-CARRIED-ITEM(L-ROW) TO PL-SLOT-ITEM(L-ROW, WS-S)
             MOVE PL-CARRIED-COUNT(L-ROW) TO PL-SLOT-COUNT(L-ROW, WS-S)
             MOVE WS-ITEM TO PL-CARRIED-ITEM(L-ROW)
             MOVE WS-COUNT TO PL-CARRIED-COUNT(L-ROW)
         WHEN OTHER
*>           An empty slot or one of the cursor's item: put all (left) or one (right) that fits.
             MOVE PL-CARRIED-ITEM(L-ROW) TO WS-ITEM
             COMPUTE WS-N = IT-MAX-STACK(WS-ITEM + 1) - PL-SLOT-COUNT(L-ROW, WS-S)
             IF L-BUTTON NOT = 0
                 MOVE 1 TO WS-COUNT
             ELSE
                 MOVE PL-CARRIED-COUNT(L-ROW) TO WS-COUNT
             END-IF
             COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(WS-N, WS-COUNT), 0)
             MOVE PL-CARRIED-ITEM(L-ROW) TO PL-SLOT-ITEM(L-ROW, WS-S)
             ADD WS-N TO PL-SLOT-COUNT(L-ROW, WS-S)
             SUBTRACT WS-N FROM PL-CARRIED-COUNT(L-ROW)
     END-EVALUATE
     IF PL-SLOT-COUNT(L-ROW, WS-S) = 0
         MOVE 0 TO PL-SLOT-ITEM(L-ROW, WS-S)
     END-IF
     IF PL-CARRIED-COUNT(L-ROW) = 0
         MOVE 0 TO PL-CARRIED-ITEM(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM INV-CLICK-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CLICK-DRAG.
*> USING player row, slot, button (BINARY-LONG): click type 5 QUICK_CRAFT (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-STAGE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SHARE               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-NEW                 PIC 9.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BUTTON.
     COMPUTE WS-STAGE = FUNCTION MOD(L-BUTTON, 4)
     COMPUTE WS-KIND = (L-BUTTON - WS-STAGE) / 4
     MOVE IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) TO WS-MAX
     EVALUATE TRUE
         WHEN WS-STAGE = 0
             MOVE 0 TO PL-DRAG-ACTIVE(L-ROW) PL-DRAG-COUNT(L-ROW)
             IF PL-CARRIED-COUNT(L-ROW) > 0 AND (WS-KIND < 2 OR PL-MODE(L-ROW) = 1)
                 MOVE 1 TO PL-DRAG-ACTIVE(L-ROW)
                 MOVE WS-KIND TO PL-DRAG-TYPE(L-ROW)
             END-IF
         WHEN WS-STAGE = 1 AND PL-DRAG-ACTIVE(L-ROW) = 1 AND L-SLOT >= 0 AND L-SLOT <= 35
             COMPUTE WS-S = L-SLOT + 1
             MOVE 1 TO WS-NEW
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PL-DRAG-COUNT(L-ROW)
                 IF PL-DRAG-SLOT(L-ROW, WS-I) = L-SLOT
                     MOVE 0 TO WS-NEW
                 END-IF
             END-PERFORM
             IF PL-SLOT-COUNT(L-ROW, WS-S) > 0 AND (PL-SLOT-ITEM(L-ROW, WS-S)
                     NOT = PL-CARRIED-ITEM(L-ROW) OR PL-SLOT-COUNT(L-ROW, WS-S) >= WS-MAX)
                 MOVE 0 TO WS-NEW
             END-IF
             IF WS-NEW = 1
                 ADD 1 TO PL-DRAG-COUNT(L-ROW)
                 MOVE L-SLOT TO PL-DRAG-SLOT(L-ROW, PL-DRAG-COUNT(L-ROW))
             END-IF
         WHEN WS-STAGE = 2 AND PL-DRAG-ACTIVE(L-ROW) = 1 AND PL-DRAG-COUNT(L-ROW) > 0
             EVALUATE PL-DRAG-TYPE(L-ROW)
                 WHEN 0
                     COMPUTE WS-SHARE = PL-CARRIED-COUNT(L-ROW) / PL-DRAG-COUNT(L-ROW)
                 WHEN 1
                     MOVE 1 TO WS-SHARE
                 WHEN OTHER
                     MOVE WS-MAX TO WS-SHARE
             END-EVALUATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PL-DRAG-COUNT(L-ROW)
                 COMPUTE WS-S = PL-DRAG-SLOT(L-ROW, WS-I) + 1
                 COMPUTE WS-N = FUNCTION MIN(WS-SHARE, WS-MAX - PL-SLOT-COUNT(L-ROW, WS-S))
                 IF PL-DRAG-TYPE(L-ROW) < 2
                     COMPUTE WS-N = FUNCTION MIN(WS-N, PL-CARRIED-COUNT(L-ROW))
                     SUBTRACT WS-N FROM PL-CARRIED-COUNT(L-ROW)
                 END-IF
                 IF WS-N > 0
                     MOVE PL-CARRIED-ITEM(L-ROW) TO PL-SLOT-ITEM(L-ROW, WS-S)
                     ADD WS-N TO PL-SLOT-COUNT(L-ROW, WS-S)
                 END-IF
             END-PERFORM
             IF PL-CARRIED-COUNT(L-ROW) = 0
                 MOVE 0 TO PL-CARRIED-ITEM(L-ROW)
             END-IF
             MOVE 0 TO PL-DRAG-ACTIVE(L-ROW) PL-DRAG-COUNT(L-ROW)
         WHEN OTHER
             MOVE 0 TO PL-DRAG-ACTIVE(L-ROW) PL-DRAG-COUNT(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM INV-CLICK-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-PICKUP-ALL.
*> USING player row (BINARY-LONG): click type 6 PICKUP_ALL (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-PASS                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE IT-MAX-STACK(PL-CARRIED-ITEM(L-ROW) + 1) TO WS-MAX
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-S FROM 1 BY 1
                 UNTIL WS-S > 36 OR PL-CARRIED-COUNT(L-ROW) >= WS-MAX
             IF PL-SLOT-COUNT(L-ROW, WS-S) > 0
                     AND PL-SLOT-ITEM(L-ROW, WS-S) = PL-CARRIED-ITEM(L-ROW)
                     AND (WS-PASS = 2 OR PL-SLOT-COUNT(L-ROW, WS-S) < WS-MAX)
                 COMPUTE WS-N = FUNCTION MIN(PL-SLOT-COUNT(L-ROW, WS-S),
                     WS-MAX - PL-CARRIED-COUNT(L-ROW))
                 ADD WS-N TO PL-CARRIED-COUNT(L-ROW)
                 COMPUTE WS-SLOT = WS-S - 1
                 CALL "INV-REMOVE" USING L-ROW WS-SLOT WS-N
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM INV-PICKUP-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CLICK.
*> USING connection id, PLAY-SERVERBOUND (a decoded Container Click): the click rules, echoes and
*> resynchronisation above. A click on another container than 0 is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OLD-STATE           BINARY-LONG.
 01 WS-HOTBAR              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RESYNC              PIC 9.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 36 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-CONTAINER NOT = 0
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PSB-SLOT TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE PL-SLOT(WS-ROW, WS-S) TO WS-BEFORE-SLOT(WS-S)
     END-PERFORM
     IF WS-SLOT >= 0 AND WS-SLOT <= 35
         COMPUTE WS-S = WS-SLOT + 1
         EVALUATE TRUE
             WHEN PSB-CLICK-TYPE = 0 AND PSB-BUTTON >= 0 AND PSB-BUTTON <= 1
                 CALL "INV-CLICK-PICKUP" USING WS-ROW WS-SLOT PSB-BUTTON
             WHEN PSB-CLICK-TYPE = 1 AND PL-SLOT-COUNT(WS-ROW, WS-S) > 0
                 MOVE 9 TO WS-FIRST
                 MOVE 35 TO WS-LAST
                 IF WS-SLOT > 8
                     MOVE 0 TO WS-FIRST
                     MOVE 8 TO WS-LAST
                 END-IF
                 CALL "INV-ADD-RANGE" USING WS-ROW PL-SLOT-ITEM(WS-ROW, WS-S)
                     PL-SLOT-COUNT(WS-ROW, WS-S) WS-FIRST WS-LAST WS-LEFT
                 MOVE WS-LEFT TO PL-SLOT-COUNT(WS-ROW, WS-S)
                 IF WS-LEFT = 0
                     MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S)
                 END-IF
             WHEN PSB-CLICK-TYPE = 2 AND PSB-BUTTON >= 0 AND PSB-BUTTON <= 8
                 COMPUTE WS-HOTBAR = PSB-BUTTON + 1
                 MOVE PL-SLOT-ITEM(WS-ROW, WS-HOTBAR) TO WS-ITEM
                 MOVE PL-SLOT-COUNT(WS-ROW, WS-HOTBAR) TO WS-COUNT
                 MOVE PL-SLOT(WS-ROW, WS-S) TO PL-SLOT(WS-ROW, WS-HOTBAR)
                 MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-S)
                 MOVE WS-COUNT TO PL-SLOT-COUNT(WS-ROW, WS-S)
             WHEN PSB-CLICK-TYPE = 3 AND PL-MODE(WS-ROW) = 1 AND PL-CARRIED-COUNT(WS-ROW) = 0
                     AND PL-SLOT-COUNT(WS-ROW, WS-S) > 0
                 MOVE PL-SLOT-ITEM(WS-ROW, WS-S) TO PL-CARRIED-ITEM(WS-ROW)
                 MOVE IT-MAX-STACK(PL-CARRIED-ITEM(WS-ROW) + 1) TO PL-CARRIED-COUNT(WS-ROW)
             WHEN PSB-CLICK-TYPE = 4 AND PSB-BUTTON >= 0 AND PSB-BUTTON <= 1
                     AND PL-SLOT-COUNT(WS-ROW, WS-S) > 0
                 MOVE PL-SLOT-ITEM(WS-ROW, WS-S) TO WS-ITEM
                 MOVE 1 TO WS-COUNT
                 IF PSB-BUTTON = 1
                     MOVE PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-COUNT
                 END-IF
                 CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-COUNT
                 CALL "GI-THROW-STACK" USING WS-ROW WS-ITEM WS-COUNT
         END-EVALUATE
     END-IF
     IF WS-SLOT = -999 AND PSB-CLICK-TYPE = 0 AND PSB-BUTTON >= 0 AND PSB-BUTTON <= 1
             AND PL-CARRIED-COUNT(WS-ROW) > 0
         MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-ITEM
         MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-COUNT
         IF PSB-BUTTON = 1
             MOVE 1 TO WS-COUNT
         END-IF
         SUBTRACT WS-COUNT FROM PL-CARRIED-COUNT(WS-ROW)
         IF PL-CARRIED-COUNT(WS-ROW) = 0
             MOVE 0 TO PL-CARRIED-ITEM(WS-ROW)
         END-IF
         CALL "GI-THROW-STACK" USING WS-ROW WS-ITEM WS-COUNT
     END-IF
     IF PSB-CLICK-TYPE = 5
         CALL "INV-CLICK-DRAG" USING WS-ROW WS-SLOT PSB-BUTTON
     END-IF
     IF PSB-CLICK-TYPE = 6 AND PL-CARRIED-COUNT(WS-ROW) > 0
         CALL "INV-PICKUP-ALL" USING WS-ROW
     END-IF
*>   State id, echoes of the changed slots, resynchronisation.
     MOVE PL-STATE-ID(WS-ROW) TO WS-OLD-STATE
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT(WS-ROW, WS-S) NOT = WS-BEFORE-SLOT(WS-S)
             COMPUTE WS-SLOT = WS-S - 1
             CALL "INV-SLOT-SEND" USING L-ID WS-SLOT
         END-IF
     END-PERFORM
     MOVE 0 TO WS-RESYNC
     IF PSB-STATE-ID NOT = WS-OLD-STATE OR PSB-CARRIED-COUNT NOT = PL-CARRIED-COUNT(WS-ROW)
             OR (PSB-CARRIED-COUNT > 0 AND PSB-CARRIED-ITEM NOT = PL-CARRIED-ITEM(WS-ROW))
         MOVE 1 TO WS-RESYNC
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-CHANGED-COUNT
         MOVE PSB-CHANGED-SLOT(WS-I) TO WS-SLOT
         IF WS-SLOT >= 0 AND WS-SLOT <= 35
             COMPUTE WS-S = WS-SLOT + 1
             IF PSB-CHANGED-AMOUNT(WS-I) NOT = PL-SLOT-COUNT(WS-ROW, WS-S)
                     OR (PSB-CHANGED-AMOUNT(WS-I) > 0
                     AND PSB-CHANGED-ITEM(WS-I) NOT = PL-SLOT-ITEM(WS-ROW, WS-S))
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
*> USING connection id, PLAY-SERVERBOUND (a decoded Container Close): the close rule above. Another
*> container than 0 is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 36 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PSB-CONTAINER NOT = 0 OR PL-CARRIED-COUNT(WS-ROW) = 0
         GOBACK
     END-IF
     MOVE 0 TO PL-DRAG-ACTIVE(WS-ROW) PL-DRAG-COUNT(WS-ROW)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         MOVE PL-SLOT(WS-ROW, WS-S) TO WS-BEFORE-SLOT(WS-S)
     END-PERFORM
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-ITEM
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-COUNT
     MOVE 0 TO PL-CARRIED-ITEM(WS-ROW) PL-CARRIED-COUNT(WS-ROW)
     CALL "INV-ADD" USING WS-ROW WS-ITEM WS-COUNT WS-LEFT
     IF WS-LEFT > 0
         CALL "GI-THROW-STACK" USING WS-ROW WS-ITEM WS-LEFT
     END-IF
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT(WS-ROW, WS-S) NOT = WS-BEFORE-SLOT(WS-S)
             COMPUTE WS-SLOT = WS-S - 1
             CALL "INV-SLOT-SEND" USING L-ID WS-SLOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM INV-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-CREATIVE-SET.
*> USING connection id, PLAY-SERVERBOUND (a decoded Set Creative Mode Slot, 05c 0x39): acted on only
*> for a creative player (09 §3.2). Slot 0 to 35 becomes the stack: count 0 empties it; an item id
*> outside 1 to 17 (standin §2) is ignored; a count above the item's maximum stack is lowered to it.
*> Other slots (-1, a creative-inventory throw, is no ground-item source of standin §9.1) are
*> ignored. Nothing is echoed (the client set it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-MODE(WS-ROW) NOT = 1 OR PSB-SLOT < 0 OR PSB-SLOT > 35
         GOBACK
     END-IF
     COMPUTE WS-S = PSB-SLOT + 1
     EVALUATE TRUE
         WHEN PSB-STACK-COUNT <= 0
             MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S) PL-SLOT-COUNT(WS-ROW, WS-S)
         WHEN PSB-STACK-ITEM >= 1 AND PSB-STACK-ITEM < IT-COUNT
             MOVE PSB-STACK-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-S)
             MOVE IT-MAX-STACK(PSB-STACK-ITEM + 1) TO PL-SLOT-COUNT(WS-ROW, WS-S)
             IF PSB-STACK-COUNT < PL-SLOT-COUNT(WS-ROW, WS-S)
                 MOVE PSB-STACK-COUNT TO PL-SLOT-COUNT(WS-ROW, WS-S)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM INV-CREATIVE-SET.
