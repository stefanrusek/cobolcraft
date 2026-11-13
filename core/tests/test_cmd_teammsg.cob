*> Acceptance test of docs/protocol/16-commands-catalog.md §8.4 `teammsg <message>` (permission level 0; tm is an alias) and §15: the sender must be on a team, else commands.teammsg.failed.noteam. No team exists yet (the scoreboard lane owns teams): every sender
*> is on none, so the delivery to the team (chat.type.team.text and .sent, result the number of recipients) is not done here.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
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
     GOBACK.
 END PROGRAM TEST-CMD-TEAMMSG.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
