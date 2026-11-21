*> Test of the "one more set" step of Place Recipe (docs/protocol/13 section 3.8 item 4; core/src/recipe-unlock.cob; T3657): without use
*> max items one set is placed, except when the grid already holds the recipe's items: then one more set is added, up to the smallest
*> count in the grid plus one, bounded by the ingredients' stack sizes. Recipe 0 (display 0) is four greystone (item 2) in the 2 x 2 grid
*> of the inventory menu; the starting kit holds 64 greystone in container slot 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLACE-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CMENU.
 COPY PLAYPKT.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE 0 TO PSB-CONTAINER PSB-USE-MAX PSB-RECIPE

     MOVE "test place more the first Place Recipe puts one set in the grid" TO TL-CASE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW
     MOVE "grid 1 1 1 1 slot0 60" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test place more the same recipe again, with the grid already holding its items, adds one more set" TO TL-CASE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW
     MOVE "grid 2 2 2 2 slot0 56" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test place more and once more: three sets" TO TL-CASE
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW
     MOVE "grid 3 3 3 3 slot0 52" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test place more a grid that holds other items than the recipe's is replaced by one set" TO TL-CASE
     MOVE 4 TO MN-IGRID-ITEM(WS-ROW, 1)
     MOVE 1 TO MN-IGRID-COUNT(WS-ROW, 1)
     CALL "RECIPE-PLACE" USING WS-ID PLAY-SERVERBOUND
     PERFORM SHOW
     MOVE "grid 1 1 1 1 slot0 57" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 SHOW.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-I
     STRING "grid" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-I
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 4
         MOVE MN-IGRID-COUNT(CN-PLAYER(WS-ID), WS-ROW) TO WS-EDIT
         STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-I
     END-PERFORM
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-EDIT
     STRING " slot0 " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-I.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PLACE-MORE.
 COPY CORETEST.
