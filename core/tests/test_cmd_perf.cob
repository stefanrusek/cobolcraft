*> Acceptance test of docs/protocol/16-commands-catalog.md §11.17 and §14a `perf start | stop` (permission level 4, dedicated): commands.perf.started; stop gives commands.perf.stopped [seconds (ticks / 20), ticks, ticks per second];
*> already running / not running are commands.perf.alreadyRunning / .notRunning; the messages are not broadcast (quiet); result 0. Opal and Olga hold level 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PERF.
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
     MOVE "acceptance US13 /perf stop before a start" TO TL-CASE
     MOVE "perf stop" TO WS-LINE
     MOVE "commands.perf.notRunning()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /perf start" TO TL-CASE
     MOVE "perf start" TO WS-LINE
     MOVE "commands.perf.started()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     MOVE "acceptance US13 /perf start is quiet: no other operator is told" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /perf start again" TO TL-CASE
     MOVE "perf start" TO WS-LINE
     MOVE "commands.perf.alreadyRunning()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US13 /perf stop after 40 ticks" TO TL-CASE
     MOVE "perf stop" TO WS-LINE
     MOVE "commands.perf.stopped(2.00,40,20.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /perf start for the second run" TO TL-CASE
     MOVE "perf start" TO WS-LINE
     MOVE "commands.perf.started()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /perf stop at once: no ticks" TO TL-CASE
     MOVE "perf stop" TO WS-LINE
     MOVE "commands.perf.stopped(0.00,0,0.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /perf start for the result" TO TL-CASE
     MOVE "perf start" TO WS-LINE
     MOVE "commands.perf.started()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /perf stop result 0" TO TL-CASE
     MOVE "perf stop" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /perf a player without permission level 4 does not know it" TO TL-CASE
     MOVE "perf start" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-PERF.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
