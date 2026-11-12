*> Implementation test (user bug: the recipe book of a standard world was empty; docs/protocol/27, docs/design/world-types.md):
*> WORLD-RECIPES-OPEN loads the recipes of a world's content set. A standard or debug set reads <generated directory>/vanilla-data
*> (the folder that holds data/recipe and data/advancement/recipes) into the recipe store RC-STORE with RECIPES-LOAD; a cobolcraft set
*> keeps its ten built-in recipes. A player who joins afterwards is sent a Recipe Book Add that lists the recipes with no unlock
*> condition; a directory without data leaves the store empty and is not an error; WORLD-CONTENT-OPEN calls it,
*> so a world opens with its recipes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-RECIPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-DIR                 PIC X(1024) VALUE "build/world-recipes-gen".
 01 WS-TYPE                PIC X(10).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-COMMAND             PIC X(300).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "rm -rf build/world-recipes-gen && mkdir -p build/world-recipes-gen && cp -R content/tests/fixtures/recipes build/world-recipes-gen/vanilla-data"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND

     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes a cobolcraft set keeps its ten built-in recipes" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "standard" TO WS-TYPE
     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes a standard set loads the recipes of vanilla-data" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test world recipes a standard set holds the 31 recipes of the fixture" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:stick" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "test world recipes a standard set finds minecraft:stick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes a second open loads again without duplicates" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "debug" TO WS-TYPE
     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes a debug set loads the recipes like the standard set" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a player who joins now is sent the recipes with no unlock condition
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE CN-PLAYER(WS-ALICE) TO WS-PROW
     CALL "RECBOOK-JOIN" USING WS-PROW
     CALL "TEST-DRAIN-CRAFT" USING WS-ALICE WS-TEXT
     MOVE "test world recipes a player of a standard set is sent a Recipe Book Add with recipes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TEXT(1:9) = "settings " AND WS-TEXT(1:20) NOT = "settings | book 0 id"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes opening a cobolcraft set drops the recipes of the earlier set" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "rm -rf build/world-recipes-gen && mkdir -p build/world-recipes-gen" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-RECIPES-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world recipes a directory without vanilla-data loads nothing and is not an error" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-RECIPES.
 COPY CORETEST.
