*> Test of the recipe lookup in the server (docs/protocol/27 section 6; core/src/recipes-27.cob): fetching a recipe by
*> its key (6.1 byKey) and the first recipe in store order winning when several match (6.1 getRecipeFor).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 2.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-MATCH               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DUP                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance US9 27§6 Recipe lookup in the server a recipe is fetched by key; an unknown key gives 0"
         TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "cobolcraft:ledger_tile" TO WS-KEY
     CALL "RECIPE-BY-KEY" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-EDIT
     STRING "ledger " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "cobolcraft:nothing" TO WS-KEY
     CALL "RECIPE-BY-KEY" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " none " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "ledger 1 none 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§6 Recipe lookup in the server when two recipes match the grid the first in store "
         & "order wins" TO TL-CASE
     MOVE 1 TO WS-DUP
     ADD 1 TO RC-COUNT
     MOVE RC-ROW(1) TO RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_duplicate" TO RR-KEY(RC-COUNT)
     MOVE "cobolcraft:sod_cake" TO RR-RESULT-ID(RC-COUNT)
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 9
         MOVE 0 TO WS-G(WS-ROW)
     END-PERFORM
     MOVE 2 TO WS-G(1) WS-G(2) WS-G(3) WS-G(4)
     CALL "CRAFT-MATCH" USING WS-W WS-H WS-GRID WS-MATCH WS-ITEM WS-COUNT
     MOVE WS-MATCH TO WS-EDIT
     MOVE RC-COUNT TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING "row " FUNCTION TRIM(WS-EDIT) " of " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "row 1 of " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-RECIPES-27-6.

 COPY CORETEST.
