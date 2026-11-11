*> Acceptance test of docs/protocol/15-commands-framework.md §14 Suggestions (tab completion; the server half): the answer carries the range of the
*> typed text and the sorted entries (15a §6); the server suggests online player names and, from level 2, the selector heads for an entity
*> argument, the enumerated names, the dimension names and the entries of a resource registry (14.3), with the matching helper of 14.2
*> (the start of the candidate, or the start after . _ or /; resources by namespace or path; an entry equal to the typed text is left out);
*> the list is cut at BR-SG-MAX = 1000 entries (14.1 step 3). The tooltips of the selector heads, the block position suggestions and the
*> item, function, time and nbt_path providers are BLOCKED. Alfred holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRIGADIER.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ALFRED              BINARY-LONG.
 01 WS-TRANSACTION         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alfred" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALFRED
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT
     MOVE "acceptance US13 15§14 Suggestions an operator is offered the" & " selector heads and the online names for a players argument" TO TL-CASE
     MOVE 1 TO WS-TRANSACTION
     MOVE "/msg " TO WS-LINE
     MOVE 5 TO WS-LENGTH
     MOVE "1 5 0 [@a,@e,@n,@p,@r,@s,Alfred,Alice]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a source below level 2 is " & "not offered the selector heads" TO TL-CASE
     MOVE 2 TO WS-TRANSACTION
     MOVE "/msg " TO WS-LINE
     MOVE 5 TO WS-LENGTH
     MOVE "2 5 0 [Alfred,Alice]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions the typed text matches the" & " start of a name" TO TL-CASE
     MOVE 3 TO WS-TRANSACTION
     MOVE "/msg al" TO WS-LINE
     MOVE 7 TO WS-LENGTH
     MOVE "3 5 2 [Alfred,Alice]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a text inside a name that " & "does not follow . _ or / does not match" TO TL-CASE
     MOVE 4 TO WS-TRANSACTION
     MOVE "/msg lfr" TO WS-LINE
     MOVE 8 TO WS-LENGTH
     MOVE "4 0 0 []" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a candidate that equals th" & "e typed text only ignoring case is still suggested (the equa" & "lity is case-sensitive)" TO TL-CASE
     MOVE 5 TO WS-TRANSACTION
     MOVE "/msg alice" TO WS-LINE
     MOVE 10 TO WS-LENGTH
     MOVE "5 5 5 [Alice]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a candidate equal to the t" & "yped text is not suggested" TO TL-CASE
     MOVE 11 TO WS-TRANSACTION
     MOVE "/msg Alice" TO WS-LINE
     MOVE 10 TO WS-LENGTH
     MOVE "11 0 0 []" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions an enum argument offers it" & "s names" TO TL-CASE
     MOVE 6 TO WS-TRANSACTION
     MOVE "/gamemode " TO WS-LINE
     MOVE 10 TO WS-LENGTH
     MOVE "6 10 0 [adventure,creative,spectator,survival]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions the enum names are matched" & " by their start" TO TL-CASE
     MOVE 7 TO WS-TRANSACTION
     MOVE "/gamemode s" TO WS-LINE
     MOVE 11 TO WS-LENGTH
     MOVE "7 10 1 [spectator,survival]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a resource matches by its " & "path as well as by its namespace" TO TL-CASE
     MOVE 8 TO WS-TRANSACTION
     MOVE "/summon sod" TO WS-LINE
     MOVE 11 TO WS-LENGTH
     MOVE "8 8 3 [cobolcraft:sodgrazer]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a text with a colon is mat" & "ched as a whole namespace:path" TO TL-CASE
     MOVE 9 TO WS-TRANSACTION
     MOVE "/summon cobolcraft:ab" TO WS-LINE
     MOVE 21 TO WS-LENGTH
     MOVE "9 8 13 [cobolcraft:abend]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions without a colon the namesp" & "ace or the path matches" TO TL-CASE
     MOVE 10 TO WS-TRANSACTION
     MOVE "/summon ab" TO WS-LINE
     MOVE 10 TO WS-LENGTH
     MOVE "10 8 2 [cobolcraft:abend]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15§14 Suggestions a dimension argument offer" & "s the enabled dimensions: only cobolcraft:main in a world wi" & "thout extra dimensions" TO TL-CASE
     MOVE 20 TO WS-TRANSACTION
     MOVE "/execute in " TO WS-LINE
     MOVE 12 TO WS-LENGTH
     MOVE "20 12 0 [cobolcraft:main]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO CW-DIM-COUNT
     MOVE "acceptance US13 15§14 Suggestions with extra dimensions cobo" & "lcraft:subroutine is offered too" TO TL-CASE
     MOVE 21 TO WS-TRANSACTION
     MOVE "20 12 0 [cobolcraft:main]" TO TL-EXPECTED
     MOVE "21 12 0 [cobolcraft:main,cobolcraft:subroutine]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CW-DIM-COUNT
     MOVE "acceptance US13 15§14 Suggestions the list is cut at 1000 entries (BR-SG-MAX)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1000 TO TL-EXPECTED-N
     MOVE BR-SG-MAX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-CMD-15-14.

 COPY CORETEST.
