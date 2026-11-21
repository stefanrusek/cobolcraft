*> Acceptance test of docs/protocol/16-commands-catalog.md §12 `chase` (permission level 0, registered only with DEBUG_CHASE_COMMAND) and §14a: chase follow [<host> <port 1..65535>],
*> chase lead [<bind_address> <port 1024..65535>], chase stop; the result is 0; the command sends no message.
*> The flag BA-CHASE-COMMAND (core/copy/BRCMDA.cpy) is 0 in production: the command is then unknown. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-CHASE.
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
     MOVE "acceptance US13 /chase without DEBUG_CHASE_COMMAND the command is not registered" TO TL-CASE
     MOVE "chase stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO BA-CHASE-COMMAND
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /chase stop has no message (level 0: any player runs it)" TO TL-CASE
     MOVE "chase stop" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase stop result 0" TO TL-CASE
     MOVE "chase stop" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase follow with the default host and port result 0" TO TL-CASE
     MOVE "chase follow" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase follow has no message" TO TL-CASE
     MOVE "chase follow" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase follow host port result 0" TO TL-CASE
     MOVE "chase follow localhost 10001" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase follow the lowest port" TO TL-CASE
     MOVE "chase follow example.org 1" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase follow the highest port" TO TL-CASE
     MOVE "chase follow example.org 65535" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase follow port 0 is below the range" TO TL-CASE
     MOVE "chase follow localhost 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase follow port 65536 is above the range" TO TL-CASE
     MOVE "chase follow localhost 65536" TO WS-LINE
     MOVE "argument.integer.big(65535,65536) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase lead with the default bind address and port result 0" TO TL-CASE
     MOVE "chase lead" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase lead bind address port result 0" TO TL-CASE
     MOVE "chase lead 0.0.0.0 2000" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase lead the lowest port 1024" TO TL-CASE
     MOVE "chase lead 127.0.0.1 1024" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /chase lead port 1023 is below the range" TO TL-CASE
     MOVE "chase lead 127.0.0.1 1023" TO WS-LINE
     MOVE "argument.integer.low(1024,1023) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase lead port 65536 is above the range" TO TL-CASE
     MOVE "chase lead 127.0.0.1 65536" TO WS-LINE
     MOVE "argument.integer.big(65535,65536) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase alone is incomplete" TO TL-CASE
     MOVE "chase" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /chase the console runs it and prints nothing" TO TL-CASE
     MOVE "chase stop" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-CHASE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
