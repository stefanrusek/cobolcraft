*> Acceptance test of docs/protocol/16-commands-catalog.md §11.3 `ban` (permission level 3, dedicated) with 14a: each profile that is not banned
*> gets a ban entry (the creation time, the source's name, no expiry, the reason) and, when online, is disconnected with
*> multiplayer.disconnect.banned.reason [reason]; commands.ban.success [name, reason] (the reason is "Banned by an operator." when none
*> was given; broadcast); none banned is commands.ban.failed; the result is the number banned. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-BAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
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
 01 WS-LIST                BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-NAME-MALLORY        PIC X(16) VALUE "Mallory".
 01 WS-LEN-MALLORY         BINARY-LONG VALUE 7.
 01 WS-NAME-ALICE          PIC X(16) VALUE "Alice".
 01 WS-LEN-ALICE           BINARY-LONG VALUE 5.
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
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE "acceptance US13 /ban an operator bans an online player: Bann" & "ed Alice: griefing" TO TL-CASE
     MOVE "ban Alice griefing" TO WS-LINE
     MOVE "commands.ban.success(Alice,griefing)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban the player is disconnected with the rea" & "son" TO TL-CASE
     CALL "TEST-DRAIN-DISCONNECT" USING WS-ID-ALICE WS-TEXT WS-CLOSED
     MOVE "multiplayer.disconnect.banned.reason(griefing)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban the connection is closed" TO TL-CASE
     MOVE WS-CLOSED TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban the ban entry names the source, the rea" & "son and no expiry" TO TL-CASE
     MOVE 2 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-ALICE WS-LEN-ALICE WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     IF WS-ROW > 0 AND AC-SOURCE(2, WS-ROW)(1:4) = "Opal" AND AC-REASON(2, WS-ROW)(1:AC-REASON-LENGTH(2, WS-ROW)) = "griefing" AND AC-EXPIRES(2, WS-ROW)(1:7) = "forever"
         MOVE 1 TO WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban the entry has a creation time (yyyy-MM-" & "dd HH:mm:ss +zzzz, 25 characters)" TO TL-CASE
     MOVE AC-CREATED-LENGTH(2, WS-ROW) TO WS-NUM
     MOVE 25 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban a player who is banned already: Nothing" & " changed" TO TL-CASE
     MOVE "ban Alice" TO WS-LINE
     MOVE "commands.ban.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban an offline name without a reason: the d" & "efault reason message" TO TL-CASE
     MOVE "ban Mallory" TO WS-LINE
     MOVE "commands.ban.success(Mallory,Banned by an operator.)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban the entry of a ban without a reason has" & " none stored" TO TL-CASE
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-MALLORY WS-LEN-MALLORY WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE AC-REASON-LENGTH(2, WS-ROW) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban a reason of several words" TO TL-CASE
     MOVE "ban Bob cheating and more" TO WS-LINE
     MOVE "commands.ban.success(Bob,cheating and more)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban the result is the number banned" TO TL-CASE
     MOVE "ban Carl" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /ban a player without operator status does n" & "ot know the command" TO TL-CASE
     MOVE "ban Dan" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-CLEO WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban the console prints the English text" TO TL-CASE
     MOVE "ban Dan" TO WS-LINE
     MOVE "Banned Dan: Banned by an operator." TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /ban ban alone is incomplete" TO TL-CASE
     MOVE "ban" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-BAN.

 COPY CORETEST.
 COPY CMDTEST.
