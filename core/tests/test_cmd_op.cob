*> Acceptance test of docs/protocol/16-commands-catalog.md §11.1 `op` (permission level 3, dedicated) with 14a: each profile that is not an
*> operator becomes one (the operator list, the level of the entry 4, the player's operator status) and an online player is sent the
*> Commands packet of their new level; commands.op.success [name] (broadcast); none changed is commands.op.failed; the result is the
*> number changed; a source of level 2 does not see the command. Opal and Bob hold operator status (level 4), Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-OP.
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
 01 WS-LIST                BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-UUID-ZED            PIC X(16).
 01 WS-NAME-ALICE          PIC X(16) VALUE "Alice".
 01 WS-LEN-ALICE           BINARY-LONG VALUE 5.
 01 WS-NAME-ZED            PIC X(16) VALUE "Zed".
 01 WS-LEN-ZED             BINARY-LONG VALUE 3.
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
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /op an operator makes a player an operator: " & "Made Alice a server operator" TO TL-CASE
     MOVE "op Alice" TO WS-LINE
     MOVE "commands.op.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op the other operator is sent the command a" & "s chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Made Alice a server operator)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op Alice holds operator status" TO TL-CASE
     MOVE PL-OPERATOR(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /op Alice is on the operator list at level 4" TO TL-CASE
     MOVE 1 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-ALICE WS-LEN-ALICE WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE AC-LEVEL(1, WS-ROW) TO WS-NUM
     MOVE 4 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /op Alice is sent the permission Entity Even" & "t (34), the Commands packet of her new level (16) and the br" & "oadcast (124)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "34 16 124" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op a player who is an operator already: Not" & "hing changed" TO TL-CASE
     MOVE "op Alice" TO WS-LINE
     MOVE "commands.op.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op an offline name is accepted (the profile" & " is looked up): result 1" TO TL-CASE
     MOVE "op Zed" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /op Zed is on the operator list" TO TL-CASE
     MOVE 1 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-ZED WS-LEN-ZED WS-UUID-ZED
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID-ZED WS-ROW
     IF WS-ROW > 0
         MOVE 1 TO WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /op a profile argument is one word" TO TL-CASE
     MOVE "op Zed Yan" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 1 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-ALICE WS-LEN-ALICE WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE 2 TO AC-LEVEL(1, WS-ROW)
     MOVE "acceptance US13 /op a source of level 2 does not know a comm" & "and of level 3" TO TL-CASE
     MOVE "op Bob" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op the console prints the English text" TO TL-CASE
     MOVE "op Carl" TO WS-LINE
     MOVE "Made Carl a server operator" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /op op alone is incomplete" TO TL-CASE
     MOVE "op" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-OP.

 COPY CORETEST.
 COPY CMDTEST.
