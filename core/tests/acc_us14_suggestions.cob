*> Acceptance test, US14-1 core half (spec US14 scenario 1; FR-016; docs/protocol/15 §13 and §14, 15a §6): the command tree a player is sent on
*> joining holds only the commands they may use (the operator's tree is larger), and Command Suggestion is answered by the
*> standard suggestions: a literal child is offered when it starts with the text typed, other stock types suggest nothing (online player
*> names, dimension paths and item key paths are the commands' custom providers: BLOCKED), a player is not offered the commands above their
*> level. Alfred holds operator status (the world's operator list), Alice does not.
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
 01 WS-EDIT-N              PIC Z(9)9.
 01 WS-ALICE-SIZE          BINARY-LONG.
 01 WS-ALFRED-SIZE         BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
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
     CALL "TEST-DRAIN-PACKET" USING WS-ALICE WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE PB-LENGTH TO WS-ALICE-SIZE
     MOVE "acceptance US14-1 given a player without operator status when they join then they "
         & "are sent a command tree" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-LENGTH
     PERFORM CHECK-NUMBER

     MOVE "Alfred" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALFRED
     CALL "TEST-DRAIN-PACKET" USING WS-ALFRED WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE PB-LENGTH TO WS-ALFRED-SIZE
     MOVE "acceptance US14-1 given a player holding operator status when they join then the "
         & "command tree they are sent is larger than the everyone tree" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE 0 TO WS-LENGTH
     IF WS-FOUND = 1 AND WS-ALFRED-SIZE > WS-ALICE-SIZE AND WS-ALICE-SIZE > 20
         MOVE 1 TO WS-LENGTH
     END-IF
     PERFORM CHECK-NUMBER
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALICE WS-TEXT

     MOVE "acceptance US14-1 when an operator types /weather r then the literal rain is "
         & "offered for the text typed (start 9, length 1)" TO TL-CASE
     MOVE 1 TO WS-TRANSACTION
     MOVE "/weather r" TO WS-LINE
     MOVE "1 9 1 [rain]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 when an operator types /weather with an empty word then every kind "
         & "is offered" TO TL-CASE
     MOVE 2 TO WS-TRANSACTION
     MOVE "/weather " TO WS-LINE
     MOVE 9 TO WS-LENGTH
     MOVE "2 9 0 [clear,rain,thunder]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR

     MOVE "acceptance US14-1 literals are matched without regard to case" TO TL-CASE
     MOVE 3 TO WS-TRANSACTION
     MOVE "/weather T" TO WS-LINE
     MOVE "3 9 1 [thunder]" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 a typed word longer than every literal is offered nothing"
         TO TL-CASE
     MOVE 4 TO WS-TRANSACTION
     MOVE "/weather clears" TO WS-LINE
     MOVE "4 0 0 []" TO TL-EXPECTED
     PERFORM SUGGEST-OPERATOR-TRIMMED

     MOVE "acceptance US14-1 the requirements are not tested for suggestions (15a 6.1): a player "
         & "without operator status is offered every command that starts with ga" TO TL-CASE
     MOVE 5 TO WS-TRANSACTION
     MOVE "/ga" TO WS-LINE
     MOVE 3 TO WS-LENGTH
     MOVE "5 1 2 [gamemode,gamerule]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     PERFORM SUGGEST-CHECK-ALICE

     MOVE "acceptance US14-1 the root offers the commands the player may use: /li gives list"
         TO TL-CASE
     MOVE 6 TO WS-TRANSACTION
     MOVE "/li" TO WS-LINE
     MOVE 3 TO WS-LENGTH
     MOVE "6 1 2 [list]" TO TL-EXPECTED
     CALL "TEST-SUGGEST" USING WS-ALICE WS-TRANSACTION WS-LINE WS-LENGTH
     PERFORM SUGGEST-CHECK-ALICE

     MOVE "acceptance US14-1 a word that is a name the player is completing (a player argument) "
         & "is offered the online names by the server, and an unknown command nothing" TO TL-CASE
     MOVE 7 TO WS-TRANSACTION
     MOVE "/msg Al" TO WS-LINE
     MOVE "7 5 2 [Alfred,Alice] | 8 0 0 []" TO TL-EXPECTED
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     MOVE 8 TO WS-TRANSACTION
     MOVE "/frobnicate x" TO WS-LINE
     MOVE 13 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ALFRED WS-TRANSACTION WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ALFRED WS-TEXT
     PERFORM CHECK
     STOP RUN.

 CHECK-NUMBER.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-EDIT-N
     MOVE FUNCTION TRIM(WS-EDIT-N) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

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
