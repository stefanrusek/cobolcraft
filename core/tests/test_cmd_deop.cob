*> Acceptance test of docs/protocol/16-commands-catalog.md §11.2 `deop` (permission level 3, dedicated) with 14a: each profile that is an
*> operator stops being one (off the operator list, the player's operator status recomputed) and an online player is sent the
*> Commands packet of level 0; commands.deop.success [name] (broadcast); none changed is commands.deop.failed; the result is the
*> number changed. Opal and Bob hold operator status; Alice is an operator too and is demoted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DEOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
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
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /deop an operator makes an operator a player" & ": Made Alice no longer a server operator" TO TL-CASE
     MOVE "deop Alice" TO WS-LINE
     MOVE "commands.deop.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop the other operator is sent the command" & " as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Made Alice no longer a server operator)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop Alice no longer holds operator status" TO TL-CASE
     MOVE PL-OPERATOR(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /deop Alice is sent the permission Entity Ev" & "ent (34) and the Commands packet of level 0 (16)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "34 16" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop a player who is not an operator: Nothi" & "ng changed" TO TL-CASE
     MOVE "deop Alice" TO WS-LINE
     MOVE "commands.deop.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop the demoted player no longer has the l" & "evel-2 commands" TO TL-CASE
     MOVE "gamemode survival" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop the result is the number changed" TO TL-CASE
     MOVE "deop Bob" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /deop an offline name that is not an operato" & "r" TO TL-CASE
     MOVE "deop Zed" TO WS-LINE
     MOVE "commands.deop.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /deop the console prints the English text" TO TL-CASE
     MOVE "deop Opal" TO WS-LINE
     MOVE "Made Opal no longer a server operator" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-DEOP.

 COPY CORETEST.
 COPY CMDTEST.
