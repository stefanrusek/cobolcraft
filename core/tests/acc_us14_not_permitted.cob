*> Acceptance test, US14-3 core half (spec US14 scenario 3; FR-016; docs/protocol/15 §5 requirements and 16 §3): a player below the level of a
*> command does not know it (the node is not offered: Commands lacks it and the line is command.unknown.command), nothing
*> changes, and a command of level 0 works for everyone. Alice has no operator status (dedicated server, empty operator list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-NOT-PERMITTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
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
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE 1000 TO CW-TIME
     MOVE "acceptance US13 /not_permitted a player without operator sta" & "tus runs an operator command: Unknown or incomplete command" TO TL-CASE
     MOVE "time set 5000" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /not_permitted the time of day is unchanged" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 1000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /not_permitted the check comes before the ar" & "guments: op with no argument is the same" TO TL-CASE
     MOVE "op" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /not_permitted a player without operator sta" & "tus does not gain operator status" TO TL-CASE
     MOVE "op Alice" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /not_permitted Alice holds no operator statu" & "s" TO TL-CASE
     MOVE PL-OPERATOR(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /not_permitted a command of level 0 is permi" & "tted to everyone" TO TL-CASE
     MOVE "list" TO WS-LINE
     MOVE "commands.list.players(1,64,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM ACC-US14-NOT-PERMITTED.

 COPY CORETEST.
 COPY CMDTEST.
