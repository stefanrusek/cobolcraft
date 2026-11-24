*> Acceptance test of docs/protocol/16-commands-catalog.md §10.10 `stopwatch` (permission level 2) with 14a: create, query [scale], restart and remove of stopwatches that count game
*> ticks from their start (in-memory state, not saved); query tells the elapsed seconds times the scale and returns them truncated; the others return 1. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-STOPWATCH.
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
    MOVE "acceptance US13 /stopwatch create" TO TL-CASE
    MOVE "stopwatch create foo" TO WS-LINE
    MOVE "commands.stopwatch.create.success(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch create twice" TO TL-CASE
    MOVE "stopwatch create foo" TO WS-LINE
    MOVE "commands.stopwatch.already_exists(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch create result is 1" TO TL-CASE
    MOVE "stopwatch create bar" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /stopwatch query just made" TO TL-CASE
    MOVE "stopwatch query foo" TO WS-LINE
    MOVE "commands.stopwatch.query(minecraft:foo,0.0)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE 40 TO WS-TICKS
    CALL "TEST-TICKS" USING WS-TICKS
    MOVE "acceptance US13 /stopwatch query after 40 ticks is 2 seconds" TO TL-CASE
    MOVE "stopwatch query foo" TO WS-LINE
    MOVE "commands.stopwatch.query(minecraft:foo,2.0)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch query result is the whole seconds" TO TL-CASE
    MOVE "stopwatch query foo" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /stopwatch query with a scale" TO TL-CASE
    MOVE "stopwatch query foo 2.5" TO WS-LINE
    MOVE "commands.stopwatch.query(minecraft:foo,5.0)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch query with a scale result" TO TL-CASE
    MOVE "stopwatch query foo 2.5" TO WS-LINE
    MOVE 5 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /stopwatch restart" TO TL-CASE
    MOVE "stopwatch restart foo" TO WS-LINE
    MOVE "commands.stopwatch.restart.success(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch query after a restart" TO TL-CASE
    MOVE "stopwatch query foo" TO WS-LINE
    MOVE "commands.stopwatch.query(minecraft:foo,0.0)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch restart result is 1" TO TL-CASE
    MOVE "stopwatch restart foo" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /stopwatch create in another namespace" TO TL-CASE
    MOVE "stopwatch create my:watch" TO WS-LINE
    MOVE "commands.stopwatch.create.success(my:watch)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch remove" TO TL-CASE
    MOVE "stopwatch remove foo" TO WS-LINE
    MOVE "commands.stopwatch.remove.success(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch remove result is 1" TO TL-CASE
    MOVE "stopwatch remove bar" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /stopwatch remove a missing one" TO TL-CASE
    MOVE "stopwatch remove foo" TO WS-LINE
    MOVE "commands.stopwatch.does_not_exist(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch query a missing one" TO TL-CASE
    MOVE "stopwatch query foo" TO WS-LINE
    MOVE "commands.stopwatch.does_not_exist(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch restart a missing one" TO TL-CASE
    MOVE "stopwatch restart foo" TO WS-LINE
    MOVE "commands.stopwatch.does_not_exist(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /stopwatch a player below level 2 cannot run it" TO TL-CASE
    MOVE "stopwatch create x" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-STOPWATCH.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
