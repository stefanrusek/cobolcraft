*> Implementation test of the inventory model (core/src/inventory.cob; data-model §4; tasks T431):
*> 36 slots (0 to 8 hotbar, 9 to 35 main); add fills stacks of the same item first, then empty slots
*> in slot order, and returns the part that did not fit; remove; move and swap; the held slot is a
*> hotbar slot 0 to 8. Slots are rendered as "<slot>:<item>x<count>" for every non-empty slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-UUID                PIC X(16) VALUE "inventory-test-1".
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PLAYER-CREATE" USING WS-ID WS-NAME WS-NAME-LENGTH WS-UUID WS-ROW

     MOVE "test inventory a new creative player's 36 slots are empty and the held slot is 0"
         TO TL-CASE
     PERFORM SHOW-SLOTS
     STRING " held " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE PL-HELD(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "held 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory adding 100 greystone (stack 64) to an empty inventory fills slot 0 and "
         & "puts the rest in slot 1" TO TL-CASE
     MOVE 2 TO WS-ITEM
     MOVE 100 TO WS-COUNT
     PERFORM ADD-ITEMS
     MOVE "0:2x64 1:2x36 left 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory adding goes to stacks of the same item first, then to the first empty "
         & "slot" TO TL-CASE
     MOVE 3 TO WS-ITEM
     MOVE 5 TO WS-COUNT
     PERFORM ADD-ITEMS
     MOVE 2 TO WS-ITEM
     MOVE 30 TO WS-COUNT
     PERFORM ADD-ITEMS
     MOVE "0:2x64 1:2x64 2:3x5 3:2x2 left 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory a full inventory returns what did not fit (stack 1 tools fill one slot "
         & "each)" TO TL-CASE
     MOVE 10 TO WS-ITEM
     MOVE 40 TO WS-COUNT
     CALL "INV-ADD" USING WS-ROW WS-ITEM WS-COUNT WS-LEFT
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test inventory the last slot (35) holds a tool after the inventory filled up" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 36) * 100 + PL-SLOT-COUNT(WS-ROW, 36)
     MOVE 1001 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-S FROM 5 BY 1 UNTIL WS-S > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S) PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM

     MOVE "test inventory removing takes items from a slot; a slot emptied has no item" TO TL-CASE
     MOVE 0 TO WS-SLOT
     MOVE 10 TO WS-COUNT
     CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-COUNT
     MOVE 3 TO WS-SLOT
     MOVE 5 TO WS-COUNT
     CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-COUNT
     PERFORM SHOW-SLOTS
     MOVE "0:2x54 1:2x64 2:3x5" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-ITEM(WS-ROW, 4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test inventory moving a stack to an empty slot moves it" TO TL-CASE
     MOVE 2 TO WS-SLOT
     MOVE 20 TO WS-TO
     CALL "INV-MOVE" USING WS-ROW WS-SLOT WS-TO
     PERFORM SHOW-SLOTS
     MOVE "0:2x54 1:2x64 20:3x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory moving onto a stack of the same item tops it up and leaves the rest"
         TO TL-CASE
     MOVE 1 TO WS-SLOT
     MOVE 0 TO WS-TO
     CALL "INV-MOVE" USING WS-ROW WS-SLOT WS-TO
     PERFORM SHOW-SLOTS
     MOVE "0:2x64 1:2x54 20:3x5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory moving onto a stack of another item swaps the two" TO TL-CASE
     MOVE 20 TO WS-SLOT
     MOVE 1 TO WS-TO
     CALL "INV-MOVE" USING WS-ROW WS-SLOT WS-TO
     PERFORM SHOW-SLOTS
     MOVE "0:2x64 1:3x5 20:2x54" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory moving an empty slot or a slot onto itself changes nothing" TO TL-CASE
     MOVE 30 TO WS-SLOT
     MOVE 1 TO WS-TO
     CALL "INV-MOVE" USING WS-ROW WS-SLOT WS-TO
     MOVE 1 TO WS-SLOT
     CALL "INV-MOVE" USING WS-ROW WS-SLOT WS-TO
     PERFORM SHOW-SLOTS
     MOVE "0:2x64 1:3x5 20:2x54" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory the held slot takes hotbar slots 0 to 8 and ignores 9 and -1"
         TO TL-CASE
     MOVE 3 TO WS-SLOT
     CALL "INV-HELD" USING WS-ID WS-SLOT
     MOVE PL-HELD(WS-ROW) TO WS-EDIT
     MOVE 9 TO WS-SLOT
     CALL "INV-HELD" USING WS-ID WS-SLOT
     MOVE -1 TO WS-SLOT
     CALL "INV-HELD" USING WS-ID WS-SLOT
     MOVE PL-HELD(WS-ROW) TO WS-EDIT2
     MOVE 8 TO WS-SLOT
     CALL "INV-HELD" USING WS-ID WS-SLOT
     MOVE PL-HELD(WS-ROW) TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "3 3 8" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Adds WS-COUNT of WS-ITEM and renders the slots followed by " left <n>".
 ADD-ITEMS.
     CALL "INV-ADD" USING WS-ROW WS-ITEM WS-COUNT WS-LEFT
     PERFORM SHOW-SLOTS
     MOVE WS-LEFT TO WS-EDIT
     STRING " left " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR.

*> Renders the non-empty slots into TL-OBSERVED (WS-PTR after the text).
 SHOW-SLOTS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT-COUNT(WS-ROW, WS-S) > 0
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-IF
             COMPUTE WS-EDIT = WS-S - 1
             MOVE PL-SLOT-ITEM(WS-ROW, WS-S) TO WS-EDIT2
             MOVE PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-EDIT3
             STRING FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) "x"
                 FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY.

 COPY CORETEST.
