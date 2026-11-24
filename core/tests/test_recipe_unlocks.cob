*> Test of the unlock criteria kinds (docs/protocol/27 sections 4.6 and 5.9; core/src/recipe-unlock.cob): a tick criterion
*> unlocks at the join, an inventory_changed criterion without an item predicate unlocks at once, a criterion of another
*> trigger kind never unlocks here, and a later unlock (whose recipe asks for a notification) is sent with replace clear.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-UNLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CTRECIPE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM ADD-ROWS

     MOVE "acceptance US9 27§4.6 a tick criterion and an inventory_changed criterion without predicates unlock at "
         & "the join (display ids 10 and 11); an enter_block criterion and a cardstack criterion do not" TO TL-CASE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-CRAFT" USING WS-ID WS-TEXT
     MOVE "settings | book 12 ids 0 1 2 3 4 5 6 7 8 9 10 11 replace 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9 27§4.6 a cardstack arriving unlocks the recipe that wants it, which is sent with replace clear" TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE 6 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "CRAFT-REFRESH-ALL"
     CALL "TEST-DRAIN-CRAFT" USING WS-ID WS-TEXT
     MOVE "book 1 ids 13 replace 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Display ids 10 (tick), 11 (no predicate), 12 (enter_block), 13 (cardstack, notifies).
 ADD-ROWS.
     PERFORM ADD-ONE
     MOVE "tick" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     PERFORM ADD-ONE
     MOVE "inventory_changed" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     MOVE SPACES TO RU-ITEMS(RC-UNLOCK-COUNT)
     PERFORM ADD-ONE
     MOVE "enter_block" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     PERFORM ADD-ONE
     MOVE "inventory_changed" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     MOVE "cobolcraft:cardstack" TO RU-ITEMS(RC-UNLOCK-COUNT)
     MOVE 1 TO RR-NOTIFY(RC-COUNT).

 ADD-ONE.
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_unlock" TO RR-KEY(RC-COUNT)
     MOVE 1 TO RR-SERIALIZER(RC-COUNT) RR-ING-COUNT(RC-COUNT) RR-RESULT-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(RC-COUNT)
     ADD 1 TO RC-UNLOCK-COUNT
     MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(RC-COUNT)
     MOVE 1 TO RR-UNLOCK-N(RC-COUNT).

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPE-UNLOCKS.

 COPY CORETEST.
