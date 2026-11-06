*> Acceptance test, US14-1 core half (spec US14 scenario 1; FR-016; standin-content §16.3;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Commands rows, §3.4 rule 5): the command tree a player
*> is sent on joining holds only the commands they may use, and Command Suggestion is answered with
*> online player names, dimension paths, mob type paths and item key paths for the word being typed.
*> Alfred holds operator status (the world's operator list), Alice does not; extra dimensions are on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-SUGGESTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ALFRED              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 16.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TRANSACTION         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Alfred" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME

     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "acceptance US14-1 given a player without operator status when they join then the "
         & "command tree they are sent holds only howto, roster and murmur" TO TL-CASE
     CALL "TEST-DRAIN-PACKET" USING WS-ALICE WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "Alfred" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALFRED
     MOVE "acceptance US14-1 given a player holding operator status when they join then the "
         & "command tree they are sent holds every command" TO TL-CASE
     CALL "TEST-DRAIN-PACKET" USING WS-ALFRED WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT

     MOVE "acceptance US14-1 given Alice and Alfred online when Alice types /murmur Al then the "
         & "suggestions for Al (start 8, length 2) are the online player names Alice and Alfred"
         TO TL-CASE
     MOVE 1 TO WS-TRANSACTION
     MOVE "/murmur Al" TO WS-LINE
     MOVE "1 8 2 [Alice,Alfred]" TO TL-EXPECTED
     PERFORM SUGGEST-CHECK

     MOVE "acceptance US14-1 when a player types /murmur with an empty word then every online "
         & "player name is offered" TO TL-CASE
     MOVE 2 TO WS-TRANSACTION
     MOVE "/murmur " TO WS-LINE
     MOVE 8 TO WS-LENGTH
     MOVE "2 8 0 [Alice,Alfred]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     PERFORM SUGGEST-CHECK-ALICE

     MOVE "acceptance US14-1 when an operator types /skies then the dimension names are offered"
         TO TL-CASE
     MOVE 3 TO WS-TRANSACTION
     MOVE "/skies " TO WS-LINE
     MOVE 7 TO WS-LENGTH
     MOVE "3 7 0 [main,subroutine]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR
     MOVE "acceptance US14-1 a dimension name is offered when it starts with the typed text"
         TO TL-CASE
     MOVE 4 TO WS-TRANSACTION
     MOVE "/skies su" TO WS-LINE
     MOVE "4 7 2 [subroutine]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 a typed word longer than every dimension name is offered nothing"
         TO TL-CASE
     MOVE 14 TO WS-TRANSACTION
     MOVE "/skies subroutines" TO WS-LINE
     MOVE "14 7 11 []" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 when an operator types /conjure then the mob types are offered"
         TO TL-CASE
     MOVE 5 TO WS-TRANSACTION
     MOVE "/conjure " TO WS-LINE
     MOVE 9 TO WS-LENGTH
     MOVE "5 9 0 [sodgrazer,abend]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR

     MOVE "acceptance US14-1 when an operator types /supply Alice then the item keys are offered "
         & "(ids 1 to 17)" TO TL-CASE
     MOVE 6 TO WS-TRANSACTION
     MOVE "/supply Alice " TO WS-LINE
     MOVE 14 TO WS-LENGTH
     MOVE "6 14 0 [baseplate,greystone,loam,turf,grit,cardstack,lucite,glowtube,ledger_tile,"
         & "pry_bar,trowel,grazer_flank,seared_flank,sod_cake,dump_shard,goto_pad,slag]"
         TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR
     MOVE "acceptance US14-1 item keys are matched without regard to case" TO TL-CASE
     MOVE 7 TO WS-TRANSACTION
     MOVE "/supply Alice G" TO WS-LINE
     MOVE "7 14 1 [greystone,grit,glowtube,grazer_flank,goto_pad]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 when an operator types /sweep then mobs, items, the mob types and "
         & "item keys starting with the typed text are offered" TO TL-CASE
     MOVE 8 TO WS-TRANSACTION
     MOVE "/sweep s" TO WS-LINE
     MOVE "8 7 1 [sodgrazer,seared_flank,sod_cake,slag]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED
     MOVE 9 TO WS-TRANSACTION
     MOVE "/sweep " TO WS-LINE
     MOVE 7 TO WS-LENGTH
     MOVE "acceptance US14-1 /sweep with an empty word offers mobs and items first" TO TL-CASE
     MOVE "9 7 0 [mobs,items,sodgrazer,abend,baseplate,greystone,loam,turf,grit,cardstack,lucite,"
         & "glowtube,ledger_tile,pry_bar,trowel,grazer_flank,seared_flank,sod_cake,dump_shard,"
         & "goto_pad,slag]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR

     MOVE "acceptance US14-1 a player without operator status is offered nothing for an operator "
         & "command" TO TL-CASE
     MOVE 10 TO WS-TRANSACTION
     MOVE "/skies " TO WS-LINE
     MOVE 7 TO WS-LENGTH
     MOVE "10 7 0 []" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     PERFORM SUGGEST-CHECK-ALICE

     MOVE "acceptance US14-1 a word at a literal or a name the player is completing is offered "
         & "nothing by the server (the client completes literals itself)" TO TL-CASE
     MOVE 11 TO WS-TRANSACTION
     MOVE "/guestlist a" TO WS-LINE
     MOVE "11 11 1 [] | 12 1 3 [] | 13 12 1 []" TO TL-EXPECTED
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     MOVE 12 TO WS-TRANSACTION
     MOVE "/how" TO WS-LINE
     MOVE 4 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     MOVE 13 TO WS-TRANSACTION
     MOVE "/frobnicate x" TO WS-LINE
     MOVE 13 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     PERFORM CHECK
     STOP RUN.

 SUGGEST-CHECK.
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     PERFORM SUGGEST-CHECK-ALICE.

 SUGGEST-CHECK-ALICE.
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT
     PERFORM CHECK.

 SUGGEST-OPERATOR-TRIMMED.
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     PERFORM SUGGEST-OPERATOR.

 SUGGEST-OPERATOR.
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     PERFORM CHECK.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US14-SUGGESTIONS.

 COPY CORETEST.
