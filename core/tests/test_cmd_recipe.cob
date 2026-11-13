*> Acceptance test of docs/protocol/16-commands-catalog.md §6.5 `recipe` (permission level 2) with 14a: recipe give|take <targets> <recipe>|* unlocks or forgets
*> recipes (Recipe Book Add 0x4B, Remove 0x4C); commands.recipe.give.success.single / .multiple [recipe count, name or player count] and take likewise are
*> broadcast; none learned is commands.recipe.give.failed, none forgotten commands.recipe.take.failed; the result is the number of recipes added or removed. The
*> cobolcraft recipes are all known from the join (ten, display ids 0 to 9). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RECIPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY RECBOOK.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-REMOVE-ID           BINARY-LONG VALUE 76.
 01 WS-ADD-ID              BINARY-LONG VALUE 75.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE "acceptance US13 /recipe give of a recipe the player knows: No new recipes were learned" TO TL-CASE
     MOVE "recipe give Alice ledger_tile" TO WS-LINE
     MOVE "commands.recipe.give.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe take of one recipe by its short name: Took 1 recipe(s) from Alice" TO TL-CASE
     MOVE "recipe take Alice ledger_tile" TO WS-LINE
     MOVE "commands.recipe.take.success.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe Alice no longer knows the recipe" TO TL-CASE
     MOVE RB-KNOWN(CN-PLAYER(WS-ID-ALICE), 1) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /recipe Alice is sent Recipe Book Remove (0x4C) with the display id 0" TO TL-CASE
     MOVE "0100" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-REMOVE-ID WS-EXPECTED
     MOVE "acceptance US13 /recipe give of one recipe by its full key: Unlocked 1 recipe(s) for Alice" TO TL-CASE
     MOVE "recipe give Alice cobolcraft:ledger_tile" TO WS-LINE
     MOVE "commands.recipe.give.success.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe Alice knows the recipe again and is sent Recipe Book Add (0x4B)" TO TL-CASE
     MOVE RB-KNOWN(CN-PLAYER(WS-ID-ALICE), 1) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /recipe Alice is sent Recipe Book Add (75)" TO TL-CASE
     MOVE "75" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-ALICE TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /recipe take * removes every recipe: Took 10 recipe(s)" TO TL-CASE
     MOVE "recipe take Alice *" TO WS-LINE
     MOVE "commands.recipe.take.success.single(10,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe the Remove packet of take * holds the ten display ids" TO TL-CASE
     MOVE "0a00010203040506070809" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-REMOVE-ID WS-EXPECTED
     MOVE "acceptance US13 /recipe take * of a player who knows nothing: No recipes could be forgotten" TO TL-CASE
     MOVE "recipe take Alice *" TO WS-LINE
     MOVE "commands.recipe.take.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe give * : Unlocked 10 recipe(s) for Alice, the result is the 10 added" TO TL-CASE
     MOVE "recipe give Alice *" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 10 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "commands.recipe.give.success.single(10,Alice)" TO WS-EXPECTED
     MOVE "acceptance US13 /recipe give * tells commands.recipe.give.success.single(10,Alice)" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe take * of all players: Took 10 recipe(s) from 3 players" TO TL-CASE
     MOVE "recipe take @a *" TO WS-LINE
     MOVE "commands.recipe.take.success.multiple(10,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe give of one recipe to all players: Unlocked 1 recipe(s) for 3 players" TO TL-CASE
     MOVE "recipe give @a lucite" TO WS-LINE
     MOVE "commands.recipe.give.success.multiple(1,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe a recipe only one of several players had: the single message" TO TL-CASE
     MOVE "recipe take Alice lucite" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "recipe give @a lucite" TO WS-LINE
     MOVE "commands.recipe.give.success.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe an unknown recipe" TO TL-CASE
     MOVE "recipe give Alice nothing" TO WS-LINE
     MOVE "recipe.notFound(minecraft:nothing)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe an unknown recipe with a namespace is named as typed" TO TL-CASE
     MOVE "recipe take Alice cobolcraft:nothing" TO WS-LINE
     MOVE "recipe.notFound(cobolcraft:nothing)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe the recipe argument completes from the registry" TO TL-CASE
     MOVE "/recipe give Alice sod" TO WS-LINE
     MOVE 22 TO WS-NUM
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 3 WS-LINE WS-NUM
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "3 19 3 [cobolcraft:sod_cake]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe a player without operator status does not know the command" TO TL-CASE
     MOVE "recipe give Alice *" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /recipe the console prints the English text" TO TL-CASE
     MOVE "recipe take Alice *" TO WS-LINE
     MOVE "Took 10 recipe(s) from Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-RECIPE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
