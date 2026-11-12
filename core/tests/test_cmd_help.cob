*> Acceptance test of docs/protocol/16-commands-catalog.md §8.6 `help` (permission level 0): one line "/" + usage per command the
*> source may use, or the usage lines of the children of the command named; no node parsed is commands.help.failed; the lines are
*> literal texts; the result is the number of lines.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-HELP.
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
     MOVE "acceptance US13 /help a player below level 2 sees the comman" & "ds of level 0 (with the aliases)" TO TL-CASE
     MOVE "help" TO WS-LINE
     MOVE "/me <action> | /help [<command>] | /list [uuids] | /msg <tar" & "gets> <message> | /tell -> msg | /w -> msg | /random (value|" & "roll)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help the result is the number of lines" TO TL-CASE
     MOVE "help" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-ALICE WS-LINE WS-NUM
     MOVE 7 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /help the usage of the children of a command" TO TL-CASE
     MOVE "help list" TO WS-LINE
     MOVE "/list [uuids]" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help a command whose child takes arguments" TO TL-CASE
     MOVE "help msg" TO WS-LINE
     MOVE "/msg <targets> <message>" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help an unknown command is Unknown command " & "or insufficient permissions" TO TL-CASE
     MOVE "help bogus" TO WS-LINE
     MOVE "commands.help.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help a command the source may not use is th" & "e same failure" TO TL-CASE
     MOVE "help say" TO WS-LINE
     MOVE "commands.help.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help the console prints the lines" TO TL-CASE
     MOVE "help list" TO WS-LINE
     MOVE "/list [uuids]" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /help an operator sees the commands of level" & " 2" TO TL-CASE
     MOVE "help say" TO WS-LINE
     MOVE "/say <message>" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-HELP.

 COPY CORETEST.
 COPY CMDTEST.
