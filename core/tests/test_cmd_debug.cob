*> Acceptance test of docs/protocol/16-commands-catalog.md §11.19 and §14a `debug start | stop` (permission level 3): commands.debug.started; stop gives commands.debug.stopped [seconds (ticks / 20), ticks, ticks per second];
*> alreadyRunning / notRunning; the messages are broadcast to the other operators; result 0 for start and the ticks per second for stop. `debug function` is BLOCKED docs (function engine).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DEBUG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL        BINARY-LONG.
 01 WS-ID-OLGA        BINARY-LONG.
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
     MOVE "Olga" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OLGA
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /debug stop before a start" TO TL-CASE
     MOVE "debug stop" TO WS-LINE
     MOVE "commands.debug.notRunning()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debug start" TO TL-CASE
     MOVE "debug start" TO WS-LINE
     MOVE "commands.debug.started()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     MOVE "acceptance US13 /debug start is broadcast to the other operators" TO TL-CASE
     MOVE "chat.type.admin(Opal,Started tick profiling)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /debug start again" TO TL-CASE
     MOVE "debug start" TO WS-LINE
     MOVE "commands.debug.alreadyRunning()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US13 /debug stop after 40 ticks" TO TL-CASE
     MOVE "debug stop" TO WS-LINE
     MOVE "commands.debug.stopped(2.00,40,20.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debug start for the second run" TO TL-CASE
     MOVE "debug start" TO WS-LINE
     MOVE "commands.debug.started()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debug stop at once: result 0 ticks per second" TO TL-CASE
     MOVE "debug stop" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debug start result 0" TO TL-CASE
     MOVE "debug start" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US13 /debug stop result is the ticks per second 20" TO TL-CASE
     MOVE "debug stop" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debug a player without permission level 3 does not know it" TO TL-CASE
     MOVE "debug start" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-DEBUG.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
