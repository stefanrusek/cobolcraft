*> Acceptance test of docs/protocol/15-commands-framework.md §13 Chat commands on the wire (the unsigned Chat Command 0x07; the signed 0x08, the
*> enforce-secure-profile check and the command rate limit of §13.1 points 5 to 7 are BLOCKED, 09 sends only 0x07): the text has no leading
*> slash and is run with the player's own source, a character that is not allowed in chat (U+00A7, below U+0020, U+007F) disconnects the player with
*> multiplayer.disconnect.illegal_characters and runs nothing, commands are not blocked by the chat visibility setting. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-CLOSED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "list" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire a Chat Comma" & "nd without a leading slash runs with the player's own source" TO TL-CASE
     MOVE "list" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "commands.list.players(2,64,Opal, Alice)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire the player's" & " level is the player's own: Alice does not know an operator " & "command" TO TL-CASE
     MOVE "time set 5" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire the same lin" & "e from an operator runs" TO TL-CASE
     MOVE "time set 5" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     MOVE "commands.time.set.absolute(cobolcraft:daylight,5)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire a leading sl" & "ash is part of the text (the client sends none): the command" & " is unknown" TO TL-CASE
     MOVE "/list" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire a text with " & "U+00A7 disconnects the player with illegal_characters" TO TL-CASE
     MOVE SPACES TO WS-LINE
     STRING "say a" X"C2A7" "c" DELIMITED BY SIZE INTO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-ALICE WS-LINE
     CALL "TEST-DRAIN-DISCONNECT" USING WS-ID-ALICE WS-TEXT WS-CLOSED
     MOVE WS-CLOSED TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-DISCARD
     MOVE WS-DISCARD TO WS-TEXT
     MOVE "multiplayer.disconnect.illegal_characters() 1" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§13 Chat commands on the wire the text of " & "a disconnected player ran nothing (the other player was told" & " nothing)" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-15-13.

 COPY CORETEST.
 COPY CMDTEST.
