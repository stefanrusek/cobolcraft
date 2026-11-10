*> The inventory replica (data-model §4 Inventory; docs/protocol/13 §3.5, 40-menus-1; contract/fixtures/wire/play-s2c-12-container-
*> set-content-46-slots.hex): the local player's 36 slots (PL-SLOT(slot + 1), with the damage component), the off hand, the extra
*> slots of the inventory menu (IX) and of the open bench menu (BX), the held hotbar slot, the stack on the screen's cursor and the
*> state ids. INVENTORY-PACKET applies Container Set Content (05a 0x12: the 46 menu slots, then the cursor), Container Set Slot
*> (0x14), Open Screen (0x3C, menu type 12 the bench), Container Close (0x11), Set Player Inventory (05b 0x6E: player index 0 to 35,
*> 36 to 39 feet to head, 40 off hand) and Set Held Slot (0x6B); the stacks carry their data components (PB-ITEMSTACK-X; only the damage
*> is kept). A container that is neither the inventory menu (0) nor the open bench is ignored. INV-PICKUP predicts a left click
*> (PICKUP, button 0) the way the server does it (core/src/inventory.cob): an empty cursor takes the whole slot; a full cursor is put
*> down on an empty slot, tops up a slot of its own item up to the item's maximum stack (standin-content §2; the rest stays on the
*> cursor), or is swapped with a slot of another item; a crafting result is only taken, never put into.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-PACKET.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id), packet id (17, 18, 19, 20, 60, 98, 107 or 110).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-MENU-TYPE           BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-CENTRED             BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-TITLE               PIC X(512).
 01 WS-TITLE-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-ID.
     EVALUATE L-ID
         WHEN 18
             CALL "PB-GET-CONTAINER-CONTENT-HEAD" USING PB-BUFFER WS-CONTAINER WS-STATE-ID WS-COUNT
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR PB-ERROR = 1
                 CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WS-ITEMSTACK-X
                 IF PB-ERROR = 0
                     CALL "STACK-DAMAGE" USING WS-ITEMSTACK-X WS-DAMAGE
                     CALL "STACK-NOTE-MAX" USING CLIENT-STATE WS-ITEMSTACK-X
                     CALL "CL-MENU-SET" USING CLIENT-STATE WS-CONTAINER WS-I WS-ISX-COUNT WS-ISX-ITEM WS-DAMAGE
                 END-IF
             END-PERFORM
             IF PB-ERROR = 0
                 CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WS-ITEMSTACK-X
             END-IF
             IF PB-ERROR = 0 AND (WS-CONTAINER = 0 OR (WS-CONTAINER > 0 AND WS-CONTAINER = BM-ID))
                 MOVE WS-ISX-COUNT TO PL-CARRIED-COUNT
                 MOVE WS-ISX-ITEM TO PL-CARRIED-ITEM
                 IF WS-ISX-COUNT <= 0
                     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
                 END-IF
                 IF WS-CONTAINER = 0
                     MOVE WS-STATE-ID TO PL-INV-STATE-ID
                 ELSE
                     MOVE WS-STATE-ID TO BM-STATE-ID
                 END-IF
             END-IF
         WHEN 20
             CALL "PB-GET-CONTAINER-SET-SLOT" USING PB-BUFFER WS-CONTAINER WS-STATE-ID WS-SLOT WS-ITEMSTACK-X
             IF PB-ERROR = 0
                 MOVE WS-SLOT TO WS-I
                 CALL "STACK-DAMAGE" USING WS-ITEMSTACK-X WS-DAMAGE
                 CALL "STACK-NOTE-MAX" USING CLIENT-STATE WS-ITEMSTACK-X
                 CALL "CL-MENU-SET" USING CLIENT-STATE WS-CONTAINER WS-I WS-ISX-COUNT WS-ISX-ITEM WS-DAMAGE
                 IF WS-CONTAINER = 0
                     MOVE WS-STATE-ID TO PL-INV-STATE-ID
                 END-IF
                 IF WS-CONTAINER > 0 AND WS-CONTAINER = BM-ID
                     MOVE WS-STATE-ID TO BM-STATE-ID
                 END-IF
             END-IF
         WHEN 60
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-MENU-TYPE
             CALL "CONTAINER-LAYOUT" USING WS-MENU-TYPE WS-OWN WS-HEIGHT WS-Y0 WS-CENTRED WS-KNOWN
             IF PB-ERROR = 0 AND WS-KNOWN = 1 AND WS-CONTAINER > 0
                 CALL "PB-GET-TEXT" USING PB-BUFFER WS-TEXT
                 IF PB-ERROR = 0
                     CALL "TEXT-RENDER" USING CLIENT-STATE WS-TEXT WS-TITLE WS-TITLE-LENGTH
                     MOVE WS-TITLE(1:64) TO SM-CX-TITLE
                     MOVE FUNCTION MIN(WS-TITLE-LENGTH, 64) TO SM-CX-TITLE-LENGTH
                     MOVE WS-CONTAINER TO BM-ID
                     MOVE WS-MENU-TYPE TO BM-TYPE
                     MOVE 0 TO BM-STATE-ID
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
                         MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
                     END-PERFORM
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                         MOVE 0 TO BM-DATA(WS-I)
                     END-PERFORM
                     CALL "CX-RESET" USING CLIENT-STATE
                     MOVE SCR-CONTAINER TO WS-ARG
                     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ARG
                 END-IF
             END-IF
             IF PB-ERROR = 0 AND WS-MENU-TYPE = 12 AND WS-CONTAINER > 0
                 MOVE WS-CONTAINER TO BM-ID
                 MOVE 12 TO BM-TYPE
                 MOVE 0 TO BM-STATE-ID
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                     MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
                 END-PERFORM
                 MOVE SCR-BENCH TO WS-ARG
                 CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ARG
             END-IF
         WHEN 19
*>           Container Set Data: property (Short), value (Short) of the open container's data slots.
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
             CALL "PB-GET-SHORT" USING PB-BUFFER WS-SLOT
             CALL "PB-GET-SHORT" USING PB-BUFFER WS-COUNT
             IF PB-ERROR = 0 AND WS-CONTAINER > 0 AND WS-CONTAINER = BM-ID AND WS-SLOT >= 0 AND WS-SLOT < 16
                 MOVE WS-COUNT TO BM-DATA(WS-SLOT + 1)
*>               The beacon screen's powers follow the data slots 1 and 2 (40-5 section 3.7).
                 IF BM-TYPE = 9 AND WS-SLOT = 1
                     MOVE WS-COUNT TO BC-PRIMARY
                 END-IF
                 IF BM-TYPE = 9 AND WS-SLOT = 2
                     MOVE WS-COUNT TO BC-SECONDARY
                 END-IF
             END-IF
         WHEN 98
*>           Set Cursor Item: the carried stack.
             CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WS-ITEMSTACK-X
             IF PB-ERROR = 0
                 MOVE WS-ISX-COUNT TO PL-CARRIED-COUNT
                 MOVE WS-ISX-ITEM TO PL-CARRIED-ITEM
                 IF WS-ISX-COUNT <= 0
                     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
                 END-IF
             END-IF
         WHEN 17
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
             IF PB-ERROR = 0 AND WS-CONTAINER > 0 AND WS-CONTAINER = BM-ID
                 MOVE 0 TO BM-ID
                 IF SM-SCREEN = SCR-BENCH OR SM-SCREEN = SCR-CONTAINER
                     MOVE SCR-WORLD TO WS-ARG
                     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ARG
                 END-IF
             END-IF
         WHEN 110
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SLOT
             CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WS-ITEMSTACK-X
             IF PB-ERROR = 0
                 CALL "STACK-DAMAGE" USING WS-ITEMSTACK-X WS-DAMAGE
                 CALL "STACK-NOTE-MAX" USING CLIENT-STATE WS-ITEMSTACK-X
*>               Set Player Inventory: the player index WS-SLOT (0 to 35 the slots, 36 to 39 feet to head, 40 the off hand).
                 EVALUATE TRUE
                     WHEN WS-SLOT >= 0 AND WS-SLOT <= 35
                         MOVE WS-SLOT TO WS-ARG
                         CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-ISX-COUNT WS-ISX-ITEM WS-DAMAGE
                     WHEN WS-SLOT = 40
                         MOVE 37 TO WS-ARG
                         CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-ISX-COUNT WS-ISX-ITEM WS-DAMAGE
                     WHEN WS-SLOT >= 36 AND WS-SLOT <= 39
                         MOVE 0 TO WS-CONTAINER
                         COMPUTE WS-I = 44 - WS-SLOT
                         CALL "CL-MENU-SET" USING CLIENT-STATE WS-CONTAINER WS-I WS-ISX-COUNT WS-ISX-ITEM WS-DAMAGE
                 END-EVALUATE
             END-IF
         WHEN OTHER
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SLOT
             IF WS-SLOT >= 0 AND WS-SLOT <= 8
                 MOVE WS-SLOT TO PL-HELD
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM INVENTORY-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INV-PICKUP.
*> USING CLIENT-STATE, widget argument (a player slot 0 to 35, the off hand 37 or an extra slot 100 + n): a left click on the
*> slot, predicted (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CARRIED             BINARY-LONG VALUE 36.
 01 WS-CITEM               BINARY-LONG.
 01 WS-CCOUNT              BINARY-LONG.
 01 WS-CDAMAGE             BINARY-LONG.
 01 WS-NEW-COUNT           BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG.
     CALL "MENU-STACK-GET" USING CLIENT-STATE L-ARG WS-COUNT WS-ITEM WS-DAMAGE
     CALL "ITEM-MAX-STACK" USING PL-CARRIED-ITEM WS-MAX
     MOVE PL-CARRIED-COUNT TO WS-CCOUNT
     MOVE PL-CARRIED-ITEM TO WS-CITEM
     MOVE 0 TO WS-CDAMAGE
     EVALUATE TRUE
         WHEN WS-CCOUNT = 0
             MOVE WS-ITEM TO PL-CARRIED-ITEM
             MOVE WS-COUNT TO PL-CARRIED-COUNT
             CALL "MENU-STACK-PUT" USING CLIENT-STATE L-ARG WS-Z1 WS-Z2 WS-Z3
         WHEN L-ARG = 105
*>           The crafting result takes a stack of its own item only.
             IF WS-COUNT > 0 AND WS-ITEM = WS-CITEM
                 COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(WS-MAX - WS-CCOUNT, WS-COUNT), 0)
                 IF WS-N = WS-COUNT
                     ADD WS-N TO PL-CARRIED-COUNT
                     CALL "MENU-STACK-PUT" USING CLIENT-STATE L-ARG WS-Z1 WS-Z2 WS-Z3
                 END-IF
             END-IF
         WHEN WS-COUNT > 0 AND WS-ITEM NOT = WS-CITEM
             CALL "MENU-STACK-PUT" USING CLIENT-STATE L-ARG WS-CCOUNT WS-CITEM WS-CDAMAGE
             MOVE WS-ITEM TO PL-CARRIED-ITEM
             MOVE WS-COUNT TO PL-CARRIED-COUNT
         WHEN OTHER
             MOVE WS-CITEM TO WS-ITEM
             COMPUTE WS-N = WS-MAX - WS-COUNT
             COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(WS-N, WS-CCOUNT), 0)
             COMPUTE WS-NEW-COUNT = WS-COUNT + WS-N
             CALL "MENU-STACK-PUT" USING CLIENT-STATE L-ARG WS-NEW-COUNT WS-ITEM WS-DAMAGE
             SUBTRACT WS-N FROM PL-CARRIED-COUNT
     END-EVALUATE
     IF PL-CARRIED-COUNT = 0
         MOVE 0 TO PL-CARRIED-ITEM
     END-IF
     GOBACK.
 END PROGRAM INV-PICKUP.
