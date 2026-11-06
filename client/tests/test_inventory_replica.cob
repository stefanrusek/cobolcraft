*> Implementation test of client/src/inventory-replica.cob (data-model §4 Inventory; 09 §3.2 slot
*> numbering 0 to 8 hotbar, 9 to 35 main; 05a Container Set Content 0x12, Container Set Slot 0x14,
*> 05b Set Player Inventory 0x6E, Set Held Slot 0x6B): the packets keep the 36 slots, the held
*> slot, the stack on the cursor and container 0's state id; other containers and slots or held
*> slots out of range are ignored. INV-PICKUP predicts a left click (PICKUP, button 0) on a slot as
*> the server does (core/src/inventory.cob): an empty cursor takes the slot; a full cursor is put
*> down on an empty slot, tops up a slot of its item up to the maximum stack, or is swapped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-REPLICA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-ID                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   PIC Z(5)9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "inventory replica Container Set Content fills the 36 slots: items 2 to 9 x 64 in the "
         & "hotbar, a pry bar in slot 8, a trowel in slot 9, the rest empty; state id 1" TO TL-CASE
     PERFORM SLOTS-TEXT
     MOVE "64x2 64x3 64x4 64x5 64x6 64x7 64x8 64x9 1x10 1x11 0x0 0x0 state 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Container 1 (no such container in CobolCraft): ignored.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 7 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 1 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 5 TO PB-IS-COUNT
     MOVE 3 TO PB-IS-ITEM
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     MOVE 18 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 8 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 0 TO WS-V
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-V
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     MOVE 20 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     MOVE "inventory replica Container Set Content and Container Set Slot of another container are "
         & "ignored" TO TL-CASE
     PERFORM SLOTS-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Slots and held slots out of range: ignored.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 36 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     MOVE 110 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 3 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE -1 TO WS-V
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-V
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     MOVE 20 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     MOVE 2 TO PL-HELD
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 107 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     MOVE "inventory replica Set Player Inventory slot 36, Container Set Slot slot -1 and Set Held "
         & "Slot 9 are ignored (the state id of the slot packet is kept)" TO TL-CASE
     PERFORM SLOTS-TEXT
     MOVE PL-HELD TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " held " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "64x2 64x3 64x4 64x5 64x6 64x7 64x8 64x9 1x10 1x11 0x0 0x0 state 3 held 2"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-V
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
     MOVE 0 TO PB-IS-COUNT
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     MOVE 110 TO WS-ID
     CALL "INVENTORY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ID
     MOVE "inventory replica Container Set Slot sets slot 0 to 63 greystone (state id 2), Set Held "
         & "Slot holds slot 0, Set Player Inventory empties slot 9" TO TL-CASE
     PERFORM SLOTS-TEXT
     MOVE PL-HELD TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " held " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "63x2 64x3 64x4 64x5 64x6 64x7 64x8 64x9 1x10 0x0 0x0 0x0 state 2 held 0"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Left clicks predicted as the server does.
     MOVE 0 TO WS-SLOT
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     MOVE "inventory replica a left click with an empty cursor takes the whole slot" TO TL-CASE
     PERFORM CURSOR-TEXT
     MOVE "slot 0 0x0 cursor 63x2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SLOT
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     MOVE "inventory replica a left click of a full cursor on another item swaps them" TO TL-CASE
     PERFORM CURSOR-TEXT
     MOVE "slot 1 63x2 cursor 64x3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-SLOT
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     MOVE "inventory replica a left click of a full cursor on an empty slot puts it all down"
         TO TL-CASE
     PERFORM CURSOR-TEXT
     MOVE "slot 10 64x3 cursor 0x0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE 1 TO WS-SLOT
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     MOVE "inventory replica a left click of a cursor on a slot of its item tops it up to the "
         & "maximum stack (64) and keeps the rest" TO TL-CASE
     PERFORM CURSOR-TEXT
     MOVE "slot 1 64x2 cursor 4x2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-SLOT
     MOVE 1 TO PL-CARRIED-COUNT
     MOVE 10 TO PL-CARRIED-ITEM
     MOVE 1 TO PL-SLOT-COUNT(9)
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     MOVE "inventory replica a pry bar (maximum stack 1) on a pry bar stays on the cursor"
         TO TL-CASE
     PERFORM CURSOR-TEXT
     MOVE "slot 8 1x10 cursor 1x10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SLOTS-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE PL-SLOT-COUNT(WS-I) TO WS-E
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE
             INTO TL-OBSERVED
         MOVE PL-SLOT-ITEM(WS-I) TO WS-E
         STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     MOVE PL-INV-STATE-ID TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " state " FUNCTION TRIM(WS-E) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 CURSOR-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-SLOT TO WS-E
     STRING "slot " FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-SLOT-COUNT(WS-SLOT + 1) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-SLOT-ITEM(WS-SLOT + 1) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) " cursor " DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE PL-CARRIED-ITEM TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-INVENTORY-REPLICA.
 COPY CLTEST.
