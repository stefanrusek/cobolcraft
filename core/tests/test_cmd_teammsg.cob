*> Acceptance test of docs/protocol/16-commands-catalog.md §8.4 `teammsg <message>` (permission level 0; tm is an alias) and §15: the sender must be on a team, else commands.teammsg.failed.noteam;
*> a sender on a team (scoreboard state of core/src/cmds-scoreboard.cob) sends chat.type.team.text [team, sender, message] to the other members and chat.type.team.sent to itself; the result is the number of recipients.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TEAMMSG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL        BINARY-LONG.
 01 WS-ID-ALICE        BINARY-LONG.
 01 WS-ID-CLEO         BINARY-LONG.
 01 WS-DISCARD             PIC X(4096).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WANTED              BINARY-LONG.
 01 WS-OBSERVED-N          BINARY-DOUBLE.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-TEXT
     MOVE "acceptance US13 /teammsg a player on no team" TO TL-CASE
     MOVE "teammsg hello" TO WS-LINE
     MOVE "commands.teammsg.failed.noteam()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tm the alias gives the same failure" TO TL-CASE
     MOVE "tm hello world" TO WS-LINE
     MOVE "commands.teammsg.failed.noteam()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg an operator on no team" TO TL-CASE
     MOVE "teammsg hello" TO WS-LINE
     MOVE "commands.teammsg.failed.noteam()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg result 0 on failure" TO TL-CASE
     MOVE "teammsg hello" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /teammsg a message with a selector" TO TL-CASE
     MOVE "teammsg @a hi" TO WS-LINE
     MOVE "commands.teammsg.failed.noteam()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg needs a message" TO TL-CASE
     MOVE "teammsg" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg the console is on no team" TO TL-CASE
     MOVE "teammsg hello" TO WS-LINE
     MOVE "You must be on a team to message your team" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     MOVE "team add red" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "team join red Opal" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "team join red Alice" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /teammsg the sender is told chat.type.team.sent" TO TL-CASE
     MOVE "teammsg hi all" TO WS-LINE
     MOVE "chat.type.team.sent(red,Alice,hi all)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg another member is told chat.type.team.text" TO TL-CASE
     MOVE "chat.type.team.text(red,Alice,hi all)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teammsg a player on no team hears nothing" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teammsg result is the number of recipients including the sender" TO TL-CASE
     MOVE "tm again" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "team modify red displayName ""Reds""" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /teammsg the team shows its display name" TO TL-CASE
     MOVE "teammsg hello" TO WS-LINE
     MOVE "chat.type.team.sent(Reds,Alice,hello)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /teammsg a player who left the team fails again" TO TL-CASE
     MOVE "team leave Alice" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "teammsg hello" TO WS-LINE
     MOVE "commands.teammsg.failed.noteam()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-TEAMMSG.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
