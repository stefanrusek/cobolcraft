*> Acceptance test, US14-4 core half and the §16.1 target-rule edge case (spec US14 scenario 4 and
*> edge cases; FR-016; standin-content §16.1, §16.4): an unknown command, a missing argument and an
*> invalid argument each change nothing and send the §16 message naming the help command (the
*> usage string's message key); a command acting on a player in the world that names a player who
*> is not online, or a dimension that does not exist or is not enabled, changes nothing and sends
*> the §16 not-found message. Opal holds operator status (operator list); Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-ERRORS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-OPAL                BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 1000 TO CW-TIME

     MOVE "acceptance US14-4 given a player when they run an unknown command then they are sent "
         & "the unknown-command message naming the word as typed" TO TL-CASE
     MOVE "frobnicate the widget" TO WS-LINE
     MOVE "cobolcraft.command.unknown(frobnicate)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "acceptance US14-4 command names are case-sensitive: Roster is unknown" TO TL-CASE
     MOVE "Roster" TO WS-LINE
     MOVE "cobolcraft.command.unknown(Roster)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "acceptance US14-4 given a player when they leave out an argument then they are sent "
         & "the missing-argument message with the usage string" TO TL-CASE
     MOVE "murmur Opal" TO WS-LINE
     MOVE "cobolcraft.command.missing_argument(murmur <player> <message...>)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "acceptance US14-4 given a player when they add words after the last argument then "
         & "they are sent the invalid-argument message with the word and the usage string"
         TO TL-CASE
     MOVE "roster everyone" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(everyone,roster)" TO TL-EXPECTED
     PERFORM ALICE-CHECK

     MOVE "acceptance US14-4 given an operator when an argument is out of range then they are "
         & "sent the invalid-argument message" TO TL-CASE
     MOVE "clock 30000" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(30000,clock <ticks>)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-4 an invalid argument changes nothing: the time of day is unchanged"
         TO TL-CASE
     MOVE CW-TIME TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1000" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-4 given an operator when a fixed word is not one of the listed words "
         & "then they are sent the invalid-argument message with the first matching usage"
         TO TL-CASE
     MOVE "guestlist maybe" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(maybe,guestlist on)" TO TL-EXPECTED
     PERFORM OPAL-CHECK

*>   The target rule (§16.1): a player in the world must be online.
     MOVE "US14 edge a command acting on a player in the world naming a player who is not online "
         & "changes nothing and sends the player-not-found message" TO TL-CASE
     MOVE "murmur Zed hello" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Zed)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "US14 edge player names match exactly, case-sensitive: alice is not Alice" TO TL-CASE
     MOVE "murmur alice hello" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(alice)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "US14 edge a name that is not valid as a login name is an invalid name" TO TL-CASE
     MOVE "murmur Al-ice hello" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(Al-ice)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "US14 edge a name of more than 16 characters is an invalid name" TO TL-CASE
     MOVE "murmur Abcdefghijklmnopq hello" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(Abcdefghijklmnopq)" TO TL-EXPECTED
     PERFORM ALICE-CHECK
     MOVE "US14 edge a command naming a dimension that does not exist changes nothing and sends "
         & "the dimension-not-found message" TO TL-CASE
     MOVE "skies nowhere drizzle" TO WS-LINE
     MOVE "cobolcraft.command.dimension_not_found(nowhere)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "US14 edge a dimension that is not enabled counts as nonexistent" TO TL-CASE
     MOVE "relocate Alice at 1 60 1 subroutine" TO WS-LINE
     MOVE "cobolcraft.command.dimension_not_found(subroutine)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "US14 edge naming an unknown dimension leaves the player where they were" TO TL-CASE
     COMPUTE WS-EDIT = PL-X(CN-PLAYER(WS-ALICE)) * 10
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "45" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     STOP RUN.

 ALICE-CHECK.
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 OPAL-CHECK.
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US14-ERRORS.

 COPY CORETEST.
