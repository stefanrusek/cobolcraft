*> Acceptance test of docs/protocol/16-commands-catalog.md §10.6 `return` (permission level 2) with 14a: return <value> gives the value as the result, return fail gives 0 (the failure of a
*> function frame needs the function engine, which does not exist), return run <command> runs the command and gives its result; no feedback of its own. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RETURN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-TICKS               BINARY-LONG.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-2              PIC -(9)9.
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
    MOVE "acceptance US13 /return a value tells nothing" TO TL-CASE
    MOVE "return 5" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /return a value is the result" TO TL-CASE
    MOVE "return 5" TO WS-LINE
    MOVE 5 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /return a negative value is the result" TO TL-CASE
    MOVE "return -3" TO WS-LINE
    MOVE -3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /return fail has result 0" TO TL-CASE
    MOVE "return fail" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /return fail tells nothing" TO TL-CASE
    MOVE "return fail" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /return run runs the command" TO TL-CASE
    MOVE "return run scoreboard objectives add a dummy" TO WS-LINE
    MOVE "commands.scoreboard.objectives.add.success(a)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /return run returns the result of the command" TO TL-CASE
    MOVE "return run scoreboard objectives add b dummy" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /return a player below level 2 cannot run it" TO TL-CASE
    MOVE "return 1" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-RETURN.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
