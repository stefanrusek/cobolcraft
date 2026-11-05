*> Acceptance test, US10-2 to US10-4 core half (spec US10 scenarios 2 to 4; tasks T553;
*> standin-content §13, §2 starting inventory; data-model §4 add rule, §8;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Place Recipe row): Place Recipe crafts once,
*> atomically, in either game mode: the ingredients leave the inventory (slot order) and the result
*> is added (inventory add rule), with Container Set Slot for each changed slot and the recipe book
*> re-sent; or, with an ingredient missing or no room for the result, nothing changes and nothing
*> is sent. Alice is a first-time survival player with the §2 starting items (slot 0 64 greystone,
*> slot 4 64 cardstack, slot 7 64 ledger_tile, slots 10 to 35 empty); Bob is creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RECIPE              BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-STATUS              PIC X(9).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE

     MOVE "acceptance US10-2 given a survival player with 64 greystone when recipe 0 is crafted "
         & "then 4 greystone are removed and 2 ledger_tile added (slot 7 is full, so slot 10), "
         & "and the recipe book is re-sent" TO TL-CASE
     MOVE 0 TO WS-RECIPE
     CALL "TEST-PLACE-RECIPE" USING WS-ALICE WS-RECIPE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "slot 0=2x60 | slot 10=9x2 | book 9 craftable 0 1 2 3 5 8 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-2 given 3 greystone and 1 cardstack when recipe 2 is crafted then "
         & "both ingredient lines are removed and one pry_bar is added in the first empty slot"
         TO TL-CASE
     MOVE 2 TO WS-RECIPE
     CALL "TEST-PLACE-RECIPE" USING WS-ALICE WS-RECIPE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "slot 0=2x57 | slot 4=6x63 | slot 11=10x1 | book 9 craftable 0 1 2 3 5 8 replace 1"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-3 given a missing ingredient (no dump_shard) when recipe 4 is crafted "
         & "then nothing changes and nothing is sent" TO TL-CASE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-INVENTORY(WS-ROW) TO WS-TEXT
     MOVE 4 TO WS-RECIPE
     CALL "TEST-PLACE-RECIPE" USING WS-ALICE WS-RECIPE
     PERFORM CHECK-UNCHANGED
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     PERFORM CHECK-NOTHING

     MOVE "acceptance US10-3 given a display id that is no recipe (9) when it is crafted then "
         & "nothing changes and nothing is sent" TO TL-CASE
     MOVE PL-INVENTORY(WS-ROW) TO WS-TEXT
     MOVE 9 TO WS-RECIPE
     CALL "TEST-PLACE-RECIPE" USING WS-ALICE WS-RECIPE
     PERFORM CHECK-UNCHANGED
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     PERFORM CHECK-NOTHING

     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW

     MOVE "acceptance US10-4 given a creative player whose inventory is full (5 greystone in slot "
         & "0, a pry_bar in every other slot) when recipe 0 is crafted then there is no room for "
         & "the result, nothing changes and nothing is sent" TO TL-CASE
     PERFORM FILL-BOB
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE PL-INVENTORY(WS-ROW) TO WS-TEXT
     MOVE 0 TO WS-RECIPE
     CALL "TEST-PLACE-RECIPE" USING WS-BOB WS-RECIPE
     PERFORM CHECK-UNCHANGED
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     PERFORM CHECK-NOTHING

     MOVE "acceptance US10-2 given a creative player, full except that slot 0 holds exactly the "
         & "4 greystone of recipe 0, when it is crafted then the result takes the freed slot"
         TO TL-CASE
     PERFORM FILL-BOB
     MOVE 4 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     CALL "TEST-PLACE-RECIPE" USING WS-BOB WS-RECIPE
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "slot 0=9x2 | book 9 craftable replace 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Bob's slot 0 holds greystone, every other slot one pry_bar (max stack 1).
 FILL-BOB.
     PERFORM VARYING WS-S FROM 2 BY 1 UNTIL WS-S > 36
         MOVE 10 TO PL-SLOT-ITEM(WS-ROW, WS-S)
         MOVE 1 TO PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1).

*> WS-STATUS: whether the inventory equals the copy kept in WS-TEXT.
 CHECK-UNCHANGED.
     MOVE "changed" TO WS-STATUS
     IF PL-INVENTORY(WS-ROW) = WS-TEXT(1:288)
         MOVE "unchanged" TO WS-STATUS
     END-IF.

*> Asserts the inventory was unchanged and nothing was sent ("unchanged []").
 CHECK-NOTHING.
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-STATUS) " [" FUNCTION TRIM(WS-TEXT) "]" DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "unchanged []" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US10-CRAFT.

 COPY CORETEST.
