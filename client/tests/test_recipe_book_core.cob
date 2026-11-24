*> T59711 (the recipe book half of the line: the empty list of the operator's screenshot): the recipe book against the real core. In a hosted superflat survival world of the standard set, with an
*> EMPTY inventory, the core's join sequence already tells the client the recipes it knows (27 section 5.9: a recipe without an inventory criterion is known from the start; Recipe Book Add with
*> replace), the open book's panel lists collections on its first page and their items are in the icon layer: the book is not empty (diagnosis: the model of the client and the core agree, so
*> the empty panel of the screenshot was not the book's content). After `give Alice oak_log 4` through the console the planks are listed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-BOOK-CORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-recipe-book-core".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 34.
 01 WS-FOLDER              PIC X(80) VALUE "Book".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-NAME                PIC X(64) VALUE "Book".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-GEN                 PIC X(1024).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-INVENTORY           BINARY-LONG VALUE SCR-INVENTORY.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(128).
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "oak_planks".
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PLANKS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "recipe book: the superflat survival world joins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-JOINED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
*>   An empty inventory: nothing is known, the open book lists nothing.
     MOVE 1 TO RK-OPEN(1)
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-INVENTORY
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE "recipe book: an empty inventory still knows recipes from the join (Recipe Book Add)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RK-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "recipe book: the open panel lists collections on its first page" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RK-CELL-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "recipe book: with no stack in the inventory every quad of the icon layer is a recipe cell's item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-IC-COUNT >= RK-CELL-COUNT * 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Four logs through the console: the core unlocks the recipes of the log and sends them.
     MOVE Z"give Alice oak_log 4" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 10 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PLANKS WS-ROW WS-STATUS
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-CELL-COUNT
         IF RK-RES-ITEM(RK-CELL-ROW(WS-I)) = WS-PLANKS
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "recipe book: the panel's first page lists the planks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-RECIPE-BOOK-CORE.
 COPY CLTEST.
