*> Acceptance test, US10-1 core half (spec US10 scenario 1; tasks T551; standin-content §13;
*> docs/protocol/09-cobolcraft-profile.md §3.2 join sequence, §3.3 Crafting rows and the Recipe
*> Book Add fixture note): a joining player is sent every recipe (Recipe Book Add, Replace = true,
*> display ids 0 to 8) with craftable marked (crafting requirements present) from their inventory,
*> and the book is sent again whenever the inventory changes, whether by a packet (Container Click)
*> or in a tick (a ground-item pickup). A packet that leaves the inventory as it was sends nothing.
*> With the §2 starting inventory, display ids 0, 1, 2, 3, 5 and 8 are craftable (09 §3.3 note).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-RECIPE-BOOK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-CLICK               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-GI                  BINARY-LONG.
 01 WS-V                   FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance US10-1 given a first-time survival player with the starting items when "
         & "they join then all nine recipes are sent with craftable marked for display ids 0, 1, "
         & "2, 3, 5 and 8" TO TL-CASE
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "book 9 craftable 0 1 2 3 5 8 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a joined player when a packet leaves the inventory unchanged "
         & "(Set Carried Item) then no recipe book is sent" TO TL-CASE
     MOVE 3 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a joined player when the inventory changes (the 64 greystone "
         & "of slot 0 taken onto the cursor) then the flags are re-sent: only 1, 5 and 8 are "
         & "craftable without greystone" TO TL-CASE
     MOVE 0 TO WS-SLOT
     CALL "TEST-CLICK" USING WS-ALICE WS-SLOT WS-BUTTON WS-CLICK
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "slot 0=0x0 | book 9 craftable 1 5 8 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a first-time creative player (no starting items) when "
         & "they join then all nine recipes are sent with none craftable" TO TL-CASE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "book 9 craftable replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-1 given a joined player with an empty inventory when a tick picks up "
         & "a ground item of 4 greystone then the flags are re-sent with display id 0 craftable"
         TO TL-CASE
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     CALL "GI-SPAWN" USING WS-DIM PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW) WS-V WS-VY WS-VZ
         WS-ITEM WS-COUNT WS-DELAY WS-GI
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE "slot 0=2x4 | book 9 craftable 0 replace 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US10-RECIPE-BOOK.

 COPY CORETEST.
