*> Acceptance test of docs/protocol/16-commands-catalog.md §11.22 `whitelist` (permission level 3, dedicated): on and off switch the enforcement
*> (AC-ENFORCED; already in the state is an error), list tells the allow-listed names (Q), add and remove edit the allow list (an
*> error when nothing changed), remove with enforcement kicks the online players who are not listed (multiplayer.disconnect.
*> not_whitelisted), reload reads the allow list from access.dat again (the operators and bans of memory stay); the results are 1
*> or the number of profiles changed. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-WHITELIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE "acceptance US13 /whitelist an empty allow list: There are no" & " whitelisted players" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     MOVE "commands.whitelist.none()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist add a profile: Added Zed to the w" & "hitelist" TO TL-CASE
     MOVE "whitelist add Zed" TO WS-LINE
     MOVE "commands.whitelist.add.success(Zed)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist already listed: Player is already" & " whitelisted" TO TL-CASE
     MOVE "whitelist add Zed" TO WS-LINE
     MOVE "commands.whitelist.add.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the list names the one player" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     MOVE "commands.whitelist.list(1,Zed)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist a second profile" TO TL-CASE
     MOVE "whitelist add Yan" TO WS-LINE
     MOVE "commands.whitelist.add.success(Yan)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist two names joined by a comma and a" & " space" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     MOVE "commands.whitelist.list(2,Zed, Yan)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the result of list is the count" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /whitelist on: Whitelist is now turned on" TO TL-CASE
     MOVE "whitelist on" TO WS-LINE
     MOVE "commands.whitelist.enabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the allow list is enforced" TO TL-CASE
     MOVE AC-ENFORCED TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /whitelist on again: already on" TO TL-CASE
     MOVE "whitelist on" TO WS-LINE
     MOVE "commands.whitelist.alreadyOn()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist off: Whitelist is now turned off" TO TL-CASE
     MOVE "whitelist off" TO WS-LINE
     MOVE "commands.whitelist.disabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist off again: already off" TO TL-CASE
     MOVE "whitelist off" TO WS-LINE
     MOVE "commands.whitelist.alreadyOff()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the allow list is not enforced" TO TL-CASE
     MOVE AC-ENFORCED TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /whitelist remove a profile: Removed Yan fro" & "m the whitelist" TO TL-CASE
     MOVE "whitelist remove Yan" TO WS-LINE
     MOVE "commands.whitelist.remove.success(Yan)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist not listed: Player is not whiteli" & "sted" TO TL-CASE
     MOVE "whitelist remove Yan" TO WS-LINE
     MOVE "commands.whitelist.remove.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the result of add is the number a" & "dded" TO TL-CASE
     MOVE "whitelist add Opal" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /whitelist Cleo is listed, so enforcement do" & "es not disconnect her" TO TL-CASE
     MOVE "whitelist add Cleo" TO WS-LINE
     MOVE "commands.whitelist.add.success(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist Alice is listed" TO TL-CASE
     MOVE "whitelist add Alice" TO WS-LINE
     MOVE "commands.whitelist.add.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist enforced" TO TL-CASE
     MOVE "whitelist on" TO WS-LINE
     MOVE "commands.whitelist.enabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist removing an online player with en" & "forcement" TO TL-CASE
     MOVE "whitelist remove Alice" TO WS-LINE
     MOVE "commands.whitelist.remove.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the unlisted online player is dis" & "connected: You are not white-listed" TO TL-CASE
     CALL "TEST-DRAIN-DISCONNECT" USING WS-ID-ALICE WS-TEXT WS-CLOSED
     MOVE "multiplayer.disconnect.not_whitelisted()" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the listed player stays" TO TL-CASE
     CALL "TEST-DRAIN-DISCONNECT" USING WS-ID-OPAL WS-TEXT WS-CLOSED
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /whitelist reload: Reloaded the whitelist" TO TL-CASE
     MOVE "whitelist reload" TO WS-LINE
     MOVE "commands.whitelist.reloaded()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the allow list is the file's (non" & "e: empty)" TO TL-CASE
     MOVE AC-COUNT(3) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /whitelist the operator list of memory is ke" & "pt" TO TL-CASE
     MOVE AC-COUNT(1) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /whitelist the allow list holds Cleo again" TO TL-CASE
     MOVE "whitelist add Cleo" TO WS-LINE
     MOVE "commands.whitelist.add.success(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "ACCESS-DAT-WRITE"
     MOVE "acceptance US13 /whitelist a second name that is not in the " & "saved file" TO TL-CASE
     MOVE "whitelist add Yan" TO WS-LINE
     MOVE "commands.whitelist.add.success(Yan)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist two names are listed" TO TL-CASE
     MOVE AC-COUNT(3) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /whitelist reload with a saved access.dat re" & "ads it" TO TL-CASE
     MOVE "whitelist reload" TO WS-LINE
     MOVE "commands.whitelist.reloaded()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the allow list is the saved one (" & "Cleo)" TO TL-CASE
     MOVE AC-COUNT(3) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /whitelist a player without operator status " & "does not know the command" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-CLEO WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /whitelist the console prints the English te" & "xt" TO TL-CASE
     MOVE "whitelist list" TO WS-LINE
     MOVE "There are 1 whitelisted player(s): Cleo" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-WHITELIST.

 COPY CORETEST.
 COPY CMDTEST.
