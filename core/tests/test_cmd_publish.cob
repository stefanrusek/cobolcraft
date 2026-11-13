*> Acceptance test of docs/protocol/16-commands-catalog.md §11.15 and world-types §11.1 `publish [<allowCommands> [<port 0..65535>]]` (permission level 4, a hosted world): commands.publish.started.lan [port] (broadcast), result the port (a given 0 stays 0;
*> an omitted port is a free one); a second publish is commands.publish.alreadyPublished.lan [port]. The command is not registered on a dedicated host. BLOCKED docs: commands.publish.failed (the host binds).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PUBLISH.
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
     MOVE 0 TO WS-TICKS
     CALL "TA-SET-HOST-KIND" USING WS-TICKS
     MOVE "acceptance US13 /publish on a dedicated host the command is not registered" TO TL-CASE
     MOVE "publish" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO WS-TICKS
     CALL "TA-SET-HOST-KIND" USING WS-TICKS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /publish with allowCommands and a port" TO TL-CASE
     MOVE "publish true 25564" TO WS-LINE
     MOVE "commands.publish.started.lan(25564)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /publish again" TO TL-CASE
     MOVE "publish" TO WS-LINE
     MOVE "commands.publish.alreadyPublished.lan(25564)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 0 TO BP-PUBLISHED
     MOVE "acceptance US13 /publish the result is the port" TO TL-CASE
     MOVE "publish false 25565" TO WS-LINE
     MOVE 25565 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE 0 TO BP-PUBLISHED
     MOVE "acceptance US13 /publish a port of 0 is announced as 0" TO TL-CASE
     MOVE "publish false 0" TO WS-LINE
     MOVE "commands.publish.started.lan(0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 0 TO BP-PUBLISHED
     MOVE "publish" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 0 TO WS-TICKS
     IF BP-PORT > 0 MOVE 1 TO WS-TICKS END-IF
     MOVE WS-TICKS TO WS-OBSERVED-N
     MOVE 1 TO WS-EXPECTED-N
     MOVE "acceptance US13 /publish without a port picks a free port" TO TL-CASE
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-OBSERVED-N
     MOVE "acceptance US13 /publish port 65536 is above the range" TO TL-CASE
     MOVE "publish true 65536" TO WS-LINE
     MOVE "argument.integer.big(65535,65536) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /publish a player without permission level 4 does not know it" TO TL-CASE
     MOVE "publish" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-PUBLISH.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
