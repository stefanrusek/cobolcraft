*> Acceptance test, US10-2 and US10-3 core half (spec US10 scenarios 2 and 3; docs/protocol/13 sections 3.6 and 3.8;
*> core/src/recipe-unlock.cob): Place Recipe moves the ingredients of a known recipe from the inventory into the crafting
*> grid and the result appears in the result slot; taking the result (Container Click on slot 0) puts it on the cursor and
*> uses one item of each grid cell. With an ingredient missing, or a display id that is no recipe, nothing changes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US10-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CMENU.
 COPY PLAYPKT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-CLICK               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-SAVED               PIC X(288).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

     MOVE "acceptance US10-2 given a survival player with 64 greystone when recipe 0 is placed then the grid "
         & "holds 4 greystone and the menu content is sent" TO TL-CASE
     MOVE 0 TO PSB-CONTAINER PSB-USE-MAX PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-ALICE PLAY-SERVERBOUND
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE SPACES TO WS-TEXT
     MOVE WS-IDS TO WS-TEXT
     MOVE "18" TO TL-EXPECTED
     PERFORM CHECK-SENT

     MOVE "acceptance US10-2 given the result in the result slot when it is taken then the cursor holds 2 "
         & "ledger_tile and each grid cell is used up" TO TL-CASE
     MOVE 0 TO WS-SLOT
     CALL "TEST-CLICK" USING WS-ALICE WS-SLOT WS-BUTTON WS-CLICK
     MOVE SPACES TO WS-TEXT
     MOVE PL-CARRIED-ITEM(WS-ROW) TO WS-E1
     MOVE PL-CARRIED-COUNT(WS-ROW) TO WS-E2
     STRING "cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " grid"
         DELIMITED BY SIZE INTO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE MN-IGRID-COUNT(WS-ROW, WS-I) TO WS-E1
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     END-PERFORM
     MOVE "cursor 9x2 grid 0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-3 given a creative player with an empty inventory when recipe 4 (glowtube) is "
         & "placed then nothing changes and no result appears" TO TL-CASE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE PL-INVENTORY(WS-ROW) TO WS-SAVED
     MOVE 4 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-BOB PLAY-SERVERBOUND
     MOVE SPACES TO WS-TEXT
     IF PL-INVENTORY(WS-ROW) = WS-SAVED AND MN-RESULT-COUNT(WS-ROW) = 0 AND MN-IGRID-COUNT(WS-ROW, 1) = 0
         MOVE "unchanged" TO WS-TEXT
     ELSE
         MOVE "changed" TO WS-TEXT
     END-IF
     MOVE "unchanged" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US10-3 given a display id that is no recipe (99) when it is placed then nothing is "
         & "sent" TO TL-CASE
     MOVE 99 TO PSB-RECIPE
     CALL "RECIPE-PLACE" USING WS-BOB PLAY-SERVERBOUND
     CALL "TEST-DRAIN-CRAFT" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK-SENT.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US10-CRAFT.

 COPY CORETEST.
