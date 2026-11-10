*> Edge-case test of the recipe book (spec edge cases of US9; docs/protocol/13 section 3.8, 27 section 4.4 and 4.7; core/src/
*> recipe-unlock.cob): a book that knows no recipe is sent empty (replace set, no entries); a recipe that needs the 3 x 3
*> grid is not placed in the 2 x 2 grid of the inventory menu (the client shows it unavailable); Place Recipe with the
*> inventory full and items in the grid changes nothing, so no item is lost, because the grid does not fit back (13 3.8
*> step 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-BOOK-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY CMENU.
 COPY PLAYPKT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-SAVED-ITEM          BINARY-LONG.
 01 WS-SAVED-COUNT         BINARY-LONG.
 01 WS-SAVED               PIC X(288).
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance US9 27§4.4 edge a player who knows no recipe is sent an empty book with replace set"
         TO TL-CASE
*>   Every recipe waits for an unlock criterion that never holds.
     ADD 1 TO RC-UNLOCK-COUNT
     MOVE "impossible" TO RU-TRIGGER(RC-UNLOCK-COUNT)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(WS-K)
         MOVE 1 TO RR-UNLOCK-N(WS-K)
     END-PERFORM
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ID
     CALL "TEST-DRAIN-CRAFT" USING WS-ID WS-TEXT
     MOVE "settings | book 0 ids replace 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 13§3.8 edge a known recipe of 7 ingredients (goto_pad) is not placed in the 2 x 2 "
         & "grid of the inventory menu" TO TL-CASE
     MOVE WS-ID TO WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 8 TO WS-K
     CALL "RECBOOK-ADD" USING WS-ROW WS-K WS-ADDED
     PERFORM SAVE-STATE
     MOVE 0 TO PSB-CONTAINER PSB-USE-MAX
     MOVE 7 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-CONN PLAY-SERVERBOUND
     PERFORM CHECK-SAME

     MOVE "acceptance US9 13§3.8 edge Place Recipe with a full inventory and a grid that does not fit back "
         & "changes nothing and loses no item" TO TL-CASE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 36
         MOVE 10 TO PL-SLOT-ITEM(WS-ROW, WS-K)
         MOVE 1 TO PL-SLOT-COUNT(WS-ROW, WS-K)
     END-PERFORM
     MOVE 2 TO MN-IGRID-ITEM(WS-ROW, 1)
     MOVE 5 TO MN-IGRID-COUNT(WS-ROW, 1)
     MOVE 1 TO WS-K
     CALL "RECBOOK-ADD" USING WS-ROW WS-K WS-ADDED
     PERFORM SAVE-STATE
     MOVE 0 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-CONN PLAY-SERVERBOUND
     PERFORM CHECK-SAME
     STOP RUN.

 SAVE-STATE.
     MOVE PL-INVENTORY(WS-ROW) TO WS-SAVED
     MOVE MN-IGRID-ITEM(WS-ROW, 1) TO WS-SAVED-ITEM
     MOVE MN-IGRID-COUNT(WS-ROW, 1) TO WS-SAVED-COUNT.

 CHECK-SAME.
     MOVE "T" TO TL-MODE
     MOVE "same" TO TL-EXPECTED
     MOVE "changed" TO TL-OBSERVED
     IF PL-INVENTORY(WS-ROW) = WS-SAVED AND MN-IGRID-ITEM(WS-ROW, 1) = WS-SAVED-ITEM
             AND MN-IGRID-COUNT(WS-ROW, 1) = WS-SAVED-COUNT
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPE-BOOK-EDGES.

 COPY CORETEST.
