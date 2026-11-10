*> Implementation test of Container Click and Set Creative Mode Slot (core/src/inventory.cob INV-CLICK,
*> INV-CREATIVE-SET; tasks T458; 05c 0x12 click types, 0x39) and of their decoding (core/src/play.cob
*> PLAY-DECODE). Alice is a first-time survival player (the standin §2 starting items), Bob a
*> creative player. After each step the cursor and the non-empty slots are rendered as
*> "cursor <item>x<count> <slot>:<item>x<count> ...".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-CLICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PLAYPKT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
*> Click being built: container, state id, slot, button, type, predicted slots, predicted cursor.
 01 WS-C-CONTAINER         BINARY-LONG.
 01 WS-C-STATE             BINARY-LONG.
 01 WS-C-SLOT              BINARY-LONG.
 01 WS-C-BUTTON            BINARY-LONG.
 01 WS-C-TYPE              BINARY-LONG.
 01 WS-C-COUNT             BINARY-LONG.
 01 WS-C-PREDICTED.
    05 WS-C-PRED OCCURS 4 TIMES.
       10 WS-C-PRED-SLOT   BINARY-LONG.
       10 WS-C-PRED-ITEM   BINARY-LONG.
       10 WS-C-PRED-AMOUNT BINARY-LONG.
 01 WS-C-CARRIED-ITEM      BINARY-LONG.
 01 WS-C-CARRIED-COUNT     BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE WS-ALICE TO WS-CONN
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

     MOVE "test inventory click PICKUP right: an empty cursor takes half the slot; a cursor puts "
         & "one item on an empty slot and on a slot of its item; left: a cursor swaps with "
         & "another item and is put down whole on an empty slot" TO TL-CASE
     MOVE 0 TO WS-C-TYPE
     MOVE 1 TO WS-C-BUTTON
     MOVE 36 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 20 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM CLICK
     MOVE 0 TO WS-C-BUTTON
     MOVE 37 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 21 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:11x1 20:2x2 21:3x64 36:2x32 37:2x30 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 "
         & "43:9x64 44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click PICKUP left: an empty cursor takes a slot, a cursor tops up a "
         & "slot of its item; a click outside the window (-999) with an empty cursor and a "
         & "button other than 0 and 1 change nothing" TO TL-CASE
     MOVE 20 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 36 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 37 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM CLICK
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 7 TO WS-C-BUTTON
     MOVE 39 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:11x1 21:3x64 36:2x34 37:2x30 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 "
         & "44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click QUICK_MOVE moves a hotbar stack into the main inventory and a "
         & "main stack into the hotbar (first empty slot when no stack of its item)" TO TL-CASE
     MOVE 1 TO WS-C-TYPE
     MOVE 0 TO WS-C-BUTTON
     MOVE 36 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 21 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 30 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:11x1 10:2x34 36:3x64 37:2x30 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 "
         & "44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click QUICK_MOVE of a stack that does not fit leaves the rest" TO TL-CASE
     PERFORM VARYING WS-S FROM 11 BY 1 UNTIL WS-S > 36
         MOVE 5 TO PL-SLOT-ITEM(WS-ROW, WS-S)
         MOVE 64 TO PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 60 TO PL-SLOT-COUNT(WS-ROW, 12)
     MOVE 39 TO WS-C-SLOT
     PERFORM CLICK
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(WS-ROW, 4) * 100 + PL-SLOT-COUNT(WS-ROW, 12)
     MOVE 6064 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-S FROM 11 BY 1 UNTIL WS-S > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S) PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 5 TO PL-SLOT-ITEM(WS-ROW, 4)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 4)
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 11)
     MOVE 34 TO PL-SLOT-COUNT(WS-ROW, 11)

     MOVE "test inventory click SWAP exchanges a slot with the hotbar slot of the button (0 to "
         & "8; others nothing); CLONE in survival and THROW with a button other than 0 and 1 "
         & "change nothing" TO TL-CASE
     MOVE 2 TO WS-C-TYPE
     MOVE 1 TO WS-C-BUTTON
     MOVE 10 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 9 TO WS-C-BUTTON
     PERFORM CLICK
     MOVE 3 TO WS-C-TYPE
     MOVE 2 TO WS-C-BUTTON
     MOVE 36 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 4 TO WS-C-TYPE
     MOVE 2 TO WS-C-BUTTON
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:11x1 10:2x30 36:3x64 37:2x34 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 "
         & "44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click QUICK_CRAFT kind 0 splits the cursor evenly over the slots "
         & "added (a slot added twice or holding another item is skipped)" TO TL-CASE
     MOVE 0 TO WS-C-TYPE WS-C-BUTTON
     MOVE 10 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-C-TYPE
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 1 TO WS-C-BUTTON
     MOVE 22 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 23 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 22 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 38 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 2 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 9:11x1 22:2x15 23:2x15 36:3x64 37:2x34 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 "
         & "43:9x64 44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click QUICK_CRAFT kind 1 puts one item on each slot; kind 2 (full "
         & "stacks) is creative only; stage 3 cancels" TO TL-CASE
     MOVE 0 TO WS-C-TYPE WS-C-BUTTON
     MOVE 22 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-C-TYPE
     MOVE 4 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-C-BUTTON
     MOVE 24 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 25 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 6 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 8 TO WS-C-BUTTON
     PERFORM CLICK
     MOVE 9 TO WS-C-BUTTON
     MOVE 26 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 10 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 4 TO WS-C-BUTTON
     PERFORM CLICK
     MOVE 3 TO WS-C-BUTTON
     PERFORM CLICK
     MOVE 6 TO WS-C-BUTTON
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 2x13 9:11x1 23:2x15 24:2x1 25:2x1 36:3x64 37:2x34 38:4x64 39:5x64 40:6x64 41:7x64 "
         & "42:8x64 43:9x64 44:10x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click PICKUP_ALL gathers the cursor's item from the slots up to a "
         & "full stack" TO TL-CASE
     MOVE 6 TO WS-C-TYPE
     MOVE 0 TO WS-C-BUTTON
     MOVE 30 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 2x64 9:11x1 36:3x64 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 44:10x1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click a click on another container than 0 is ignored (no packet)"
         TO TL-CASE
     MOVE 1 TO WS-C-CONTAINER
     MOVE 0 TO WS-C-TYPE
     MOVE 30 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 0 TO WS-C-CONTAINER
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM SHOW
     MOVE "cursor 2x64 9:11x1 36:3x64 38:4x64 39:5x64 40:6x64 41:7x64 42:8x64 43:9x64 44:10x1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click a click with a stale state id is applied, echoed and followed "
         & "by Container Set Content (then the recipe book of the changed inventory)" TO TL-CASE
     PERFORM BUILD-CLICK
     MOVE 999 TO WS-C-STATE
     PERFORM FEED-CLICK
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "20 18" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click a wrong predicted slot is followed by Container Set Content (then "
         & "the recipe book of the changed inventory); a predicted slot outside 0 to 35 is ignored"
         TO TL-CASE
     PERFORM BUILD-CLICK
     MOVE 2 TO WS-C-COUNT
     MOVE 30 TO WS-C-PRED-SLOT(1)
     MOVE 5 TO WS-C-PRED-ITEM(1)
     MOVE 1 TO WS-C-PRED-AMOUNT(1)
     MOVE -1 TO WS-C-PRED-SLOT(2)
     MOVE 2 TO WS-C-CARRIED-ITEM
     MOVE 64 TO WS-C-CARRIED-COUNT
     PERFORM FEED-CLICK
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "20 18" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click a survival player's Set Creative Mode Slot is ignored" TO TL-CASE
     MOVE 20 TO WS-NUM
     MOVE 12 TO WS-I
     MOVE 5 TO WS-S
     PERFORM CREATIVE-SET
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 21) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Creative player.
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE WS-BOB TO WS-CONN
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW

     MOVE "test inventory click Set Creative Mode Slot lowers a count to the item's maximum "
         & "stack; an unknown item, slot -1 and slot 46 are ignored; count 0 empties a slot"
         TO TL-CASE
     MOVE 36 TO WS-NUM
     MOVE 12 TO WS-I
     MOVE 100 TO WS-S
     PERFORM CREATIVE-SET
     MOVE 37 TO WS-NUM
     MOVE 99 TO WS-I
     MOVE 5 TO WS-S
     PERFORM CREATIVE-SET
     MOVE -1 TO WS-NUM
     MOVE 2 TO WS-I
     PERFORM CREATIVE-SET
     MOVE 46 TO WS-NUM
     PERFORM CREATIVE-SET
     MOVE 38 TO WS-NUM
     MOVE 7 TO WS-I
     MOVE 5 TO WS-S
     PERFORM CREATIVE-SET
     MOVE 39 TO WS-NUM
     PERFORM CREATIVE-SET
     MOVE 0 TO WS-S
     PERFORM CREATIVE-SET
     PERFORM SHOW
     MOVE "cursor 0x0 36:12x32 38:7x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory click CLONE in creative fills an empty cursor with a full stack of "
         & "the slot's item; QUICK_CRAFT kind 2 gives each slot a full stack and, as "
         & "every drag, takes the placed count off the cursor (40-1 §3.4 item 6)" TO TL-CASE
     MOVE 3 TO WS-C-TYPE
     MOVE 2 TO WS-C-BUTTON
     MOVE 38 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 5 TO WS-C-TYPE
     MOVE 8 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 9 TO WS-C-BUTTON
     MOVE 39 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 40 TO WS-C-SLOT
     PERFORM CLICK
     MOVE 10 TO WS-C-BUTTON
     MOVE -999 TO WS-C-SLOT
     PERFORM CLICK
     PERFORM SHOW
     MOVE "cursor 0x0 36:12x32 38:7x5 39:7x64 40:7x64" TO TL-EXPECTED
     PERFORM CHECK

*>   Decoding.
     MOVE "test inventory click decode: a click type outside 0 to 6 is PICKUP (0)" TO TL-CASE
     PERFORM BUILD-CLICK
     MOVE 9 TO WS-C-TYPE
     PERFORM ENCODE-CLICK
     PERFORM DECODE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 10 + PSB-CLICK-TYPE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test inventory click decode: more than 128 changed slots is malformed" TO TL-CASE
     PERFORM BUILD-CLICK
     MOVE 129 TO WS-C-COUNT
     PERFORM ENCODE-CLICK
     PERFORM DECODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test inventory click decode: a HashedStack with data components is malformed"
         TO TL-CASE
     PERFORM BUILD-CLICK
     PERFORM ENCODE-CLICK
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 18 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     MOVE 2 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     MOVE 1 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-INT" USING PB-BUFFER WS-NUM
     MOVE 0 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     PERFORM DECODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> A click with the current state id (WS-C-TYPE, -BUTTON, -SLOT), no predictions, empty cursor.
 CLICK.
     MOVE PL-STATE-ID(WS-ROW) TO WS-C-STATE
     MOVE 0 TO WS-C-COUNT WS-C-CARRIED-ITEM WS-C-CARRIED-COUNT
     PERFORM FEED-CLICK.

*> Resets the click to: container 0, the current state id, PICKUP left on slot 30, no
*> predictions, empty cursor.
 BUILD-CLICK.
     MOVE 0 TO WS-C-CONTAINER WS-C-TYPE WS-C-BUTTON WS-C-COUNT
     MOVE 0 TO WS-C-CARRIED-ITEM WS-C-CARRIED-COUNT
     MOVE 30 TO WS-C-SLOT
     MOVE PL-STATE-ID(WS-ROW) TO WS-C-STATE.

 ENCODE-CLICK.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 18 TO WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-STATE
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-C-SLOT
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-C-BUTTON
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-C-COUNT OR WS-I > 4
         CALL "PB-PUT-SHORT" USING PB-BUFFER WS-C-PRED-SLOT(WS-I)
         PERFORM PUT-HASHED-PRED
     END-PERFORM
     IF WS-C-CARRIED-COUNT > 0
         MOVE 1 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-CARRIED-ITEM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-CARRIED-COUNT
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     END-IF.

 PUT-HASHED-PRED.
     IF WS-C-PRED-AMOUNT(WS-I) > 0
         MOVE 1 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-PRED-ITEM(WS-I)
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-C-PRED-AMOUNT(WS-I)
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-NUM
     END-IF.

 FEED-CLICK.
     PERFORM ENCODE-CLICK
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER.

*> Set Creative Mode Slot: slot WS-NUM, item WS-I, count WS-S.
 CREATIVE-SET.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 57 TO WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-NUM
     MOVE WS-S TO PB-IS-COUNT
     MOVE WS-I TO PB-IS-ITEM
     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER PB-ITEMSTACK
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER.

*> Decodes the packet in PB-BUFFER (from its start) with PLAY-DECODE into WS-OUTCOME.
 DECODE.
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME.

 SHOW.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-EDIT
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-EDIT2
     STRING "cursor " FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO WS-TEXT POINTER WS-PTR
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 45
         CALL "MENU-GET" USING WS-ROW WS-S WS-ITEM WS-COUNT
         IF WS-COUNT > 0
             MOVE WS-S TO WS-EDIT
             MOVE WS-ITEM TO WS-EDIT2
             MOVE WS-COUNT TO WS-EDIT3
             STRING " " FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY-CLICK.

 COPY CORETEST.
