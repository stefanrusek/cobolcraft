*> Acceptance test of docs/protocol/16-commands-catalog.md §8.5 `list` (permission level 0): commands.list.players [number of players
*> online, max players, the names joined by ", "], each "name (uuid)" for `list uuids`; the result is the number of players online.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /list a player without operator status can l" & "ist the players" TO TL-CASE
     MOVE "list" TO WS-LINE
     MOVE "commands.list.players(3,64,Opal, Alice, Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /list uuids lists each name with its UUID" TO TL-CASE
     MOVE "list uuids" TO WS-LINE
     MOVE "commands.list.players(3,64,Opal (b4e3ae7d-a3c4-3657-9bd3-a58" & "b10a86462), Alice (10920508-d5d8-3eed-93d2-92f193afe7d7), Bo" & "b (faa5dca3-c3d4-354b-ae1b-dde9e5a14b3b))" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /list the result is the number of players on" & "line" TO TL-CASE
     MOVE "list" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /list the console prints the English text" TO TL-CASE
     MOVE "list" TO WS-LINE
     MOVE "There are 3 of a max of 64 players online: Opal, Alice, Bob" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /list a list is not broadcast" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /list an unknown argument is Incorrect argum" & "ent for command" TO TL-CASE
     MOVE "list nonsense" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-LIST.

 COPY CORETEST.
 COPY CMDTEST.
