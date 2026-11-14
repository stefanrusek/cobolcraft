*> Acceptance test, US10-1 core half (spec US10 scenario 1; docs/protocol/27 sections 4.4, 4.6 and 5.9, 6.3; core/src/
*> recipe-unlock.cob): a joining player is sent Recipe Book Settings and then Recipe Book Add with replace set, holding
*> every recipe they know (all ten built-in recipes of the cobolcraft world, which have no unlock criteria: display ids 0
*> to 9). A packet or tick that changes the inventory sends nothing when no recipe becomes known. A recipe whose recipe
*> advancement has an inventory_changed criterion becomes known when the inventory holds every item predicate of it
*> and is then sent with replace clear.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-RECIPE-BOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CTRECIPE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-CLICK               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM ADD-UNLOCK-RECIPES

     MOVE "acceptance US10-1 given a first-time survival player when they join then Recipe Book Settings and "
         & "a replacing Recipe Book Add of display ids 0 to 11 are sent (the starting kit holds the items both unlock "
         & "recipes want)"
         TO TL-CASE
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "settings | book 12 ids 0 1 2 3 4 5 6 7 8 9 10 11 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a joined player when a packet leaves the inventory unchanged (Set Carried "
         & "Item) then no recipe book is sent" TO TL-CASE
     MOVE 3 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a joined player when the inventory changes without unlocking a recipe (the "
         & "greystone of slot 0 taken onto the cursor) then only the slot is sent" TO TL-CASE
     MOVE 36 TO WS-SLOT
     CALL "TEST-CLICK" USING WS-ALICE WS-SLOT WS-BUTTON WS-CLICK
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "slot 36=0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a first-time creative player when they join then the same ten recipes are sent"
         TO TL-CASE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM ADD-UNLOCK-RECIPES
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "settings | book 10 ids 0 1 2 3 4 5 6 7 8 9 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given an empty inventory when a cardstack arrives then the "
         & "recipe whose advancement wants a cardstack becomes known (display id 10, replace clear), the "
         & "cardstack and lucite one does not" TO TL-CASE
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE 6 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "book 1 ids 10 replace 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a known unlock recipe when a lucite also arrives then the cardstack and "
         & "lucite recipe becomes known (display id 11) and the first is not sent again" TO TL-CASE
     MOVE 7 TO PL-SLOT-ITEM(WS-ROW, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 2)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "book 1 ids 11 replace 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given an unchanged inventory when the next tick runs then nothing is sent"
         TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Two recipes after the built-ins: display id 10 unlocks on a cardstack, 11 on a cardstack and a lucite.
 ADD-UNLOCK-RECIPES.
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_unlock_a" TO RR-KEY(RC-COUNT)
     MOVE 1 TO RR-SERIALIZER(RC-COUNT) RR-ING-COUNT(RC-COUNT) RR-RESULT-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(RC-COUNT)
     ADD 1 TO RC-UNLOCK-COUNT
     MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(RC-COUNT)
     MOVE 1 TO RR-UNLOCK-N(RC-COUNT)
     MOVE "inventory_changed" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     MOVE "cobolcraft:cardstack" TO RU-ITEMS(RC-UNLOCK-COUNT)
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_unlock_b" TO RR-KEY(RC-COUNT)
     MOVE 1 TO RR-SERIALIZER(RC-COUNT) RR-ING-COUNT(RC-COUNT) RR-RESULT-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(RC-COUNT)
     ADD 1 TO RC-UNLOCK-COUNT
     MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(RC-COUNT)
     MOVE 1 TO RR-UNLOCK-N(RC-COUNT)
     MOVE "inventory_changed" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     MOVE "cobolcraft:cardstack & cobolcraft:lucite" TO RU-ITEMS(RC-UNLOCK-COUNT).

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US10-RECIPE-BOOK.

 COPY CORETEST.
