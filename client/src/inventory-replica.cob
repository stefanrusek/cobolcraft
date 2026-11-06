*> The inventory replica (data-model §4 Inventory; docs/protocol/09-cobolcraft-profile.md §3.2
*> "Inventory slots": container 0, slots 0 to 8 the hotbar, 9 to 35 the main inventory): the local
*> player's 36 slots (PL-SLOT(slot + 1)), the held hotbar slot, the stack on the inventory
*> screen's cursor and container 0's state id. INVENTORY-PACKET applies Container Set Content
*> (05a 0x12: the slots, then the cursor), Container Set Slot (0x14), Set Player Inventory (05b
*> 0x6E) and Set Held Slot (0x6B); other containers, slots outside 0 to 35 and held slots outside 0
*> to 8 are ignored. INV-PICKUP predicts a left click (PICKUP, button 0) the way the server does it
*> (core/src/inventory.cob): an empty cursor takes the whole slot; a full cursor is put down on an
*> empty slot, tops up a slot of its own item up to the item's maximum stack (standin-content §2;
*> the rest stays on the cursor), or is swapped with a slot of another item.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-PACKET.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id), packet id (18, 20, 107 or 110).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-ID.
     EVALUATE L-ID
         WHEN 18
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-STATE-ID
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
                 IF WS-CONTAINER = 0 AND WS-I <= 36
                     MOVE WS-IS-COUNT TO PL-SLOT-COUNT(WS-I)
                     MOVE WS-IS-ITEM TO PL-SLOT-ITEM(WS-I)
                 END-IF
             END-PERFORM
             CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
             IF WS-CONTAINER = 0
                 MOVE WS-STATE-ID TO PL-INV-STATE-ID
                 MOVE WS-IS-COUNT TO PL-CARRIED-COUNT
                 MOVE WS-IS-ITEM TO PL-CARRIED-ITEM
             END-IF
         WHEN 20
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-STATE-ID
             CALL "PB-GET-SHORT" USING PB-BUFFER WS-SLOT
             CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
             IF WS-CONTAINER = 0
                 MOVE WS-STATE-ID TO PL-INV-STATE-ID
                 CALL "INV-SLOT-SET" USING CLIENT-STATE WS-SLOT WS-ITEMSTACK
             END-IF
         WHEN 110
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SLOT
             CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
             CALL "INV-SLOT-SET" USING CLIENT-STATE WS-SLOT WS-ITEMSTACK
         WHEN OTHER
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SLOT
             IF WS-SLOT >= 0 AND WS-SLOT <= 8
                 MOVE WS-SLOT TO PL-HELD
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM INVENTORY-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-SLOT-SET.
*> USING CLIENT-STATE, slot (0 to 35; others ignored), PB-ITEMSTACK.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT PB-ITEMSTACK.
     IF L-SLOT >= 0 AND L-SLOT <= 35
         MOVE PB-IS-COUNT TO PL-SLOT-COUNT(L-SLOT + 1)
         MOVE PB-IS-ITEM TO PL-SLOT-ITEM(L-SLOT + 1)
     END-IF
     GOBACK.
 END PROGRAM INV-SLOT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-PICKUP.
*> USING CLIENT-STATE, slot (0 to 35): a left click on the slot, predicted (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT.
     COMPUTE WS-S = L-SLOT + 1
     MOVE PL-SLOT-ITEM(WS-S) TO WS-ITEM
     MOVE PL-SLOT-COUNT(WS-S) TO WS-COUNT
     EVALUATE TRUE
         WHEN PL-CARRIED-COUNT = 0
             MOVE WS-ITEM TO PL-CARRIED-ITEM
             MOVE WS-COUNT TO PL-CARRIED-COUNT
             MOVE 0 TO PL-SLOT-ITEM(WS-S) PL-SLOT-COUNT(WS-S)
         WHEN WS-COUNT > 0 AND WS-ITEM NOT = PL-CARRIED-ITEM
             MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-S)
             MOVE PL-CARRIED-COUNT TO PL-SLOT-COUNT(WS-S)
             MOVE WS-ITEM TO PL-CARRIED-ITEM
             MOVE WS-COUNT TO PL-CARRIED-COUNT
         WHEN OTHER
             MOVE PL-CARRIED-ITEM TO WS-ITEM
             COMPUTE WS-N = CL-IT-MAX(WS-ITEM + 1) - WS-COUNT
             COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(WS-N, PL-CARRIED-COUNT), 0)
             MOVE WS-ITEM TO PL-SLOT-ITEM(WS-S)
             ADD WS-N TO PL-SLOT-COUNT(WS-S)
             SUBTRACT WS-N FROM PL-CARRIED-COUNT
     END-EVALUATE
     IF PL-CARRIED-COUNT = 0
         MOVE 0 TO PL-CARRIED-ITEM
     END-IF
     GOBACK.
 END PROGRAM INV-PICKUP.
