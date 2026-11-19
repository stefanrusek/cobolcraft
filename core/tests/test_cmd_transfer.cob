*> Acceptance test of docs/protocol/16-commands-catalog.md §11.13 `transfer <hostname> [<port 1..65535> [<players>]]` (permission level 3, dedicated): each target is sent Transfer (0x84: host, port, default 25565);
*> commands.transfer.success.single [player, host, port] / .multiple [count, host, port] (broadcast); the result is the number of players; the console must name players. Opal holds level 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TRANSFER.
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
     MOVE "acceptance US13 /transfer the source player is the default target" TO TL-CASE
     MOVE "transfer example.org" TO WS-LINE
     MOVE "commands.transfer.success.single(Opal,example.org,25565)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
*>   The hostname is a phrase (57-4 section 7): a quoted one is the text between the quotes.
     MOVE "acceptance US13 /transfer a quoted hostname is its text between the quotes (a phrase)" TO TL-CASE
     MOVE 'transfer "my host.example" 25570' TO WS-LINE
     MOVE "commands.transfer.success.single(Opal,my host.example,25570)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer a port and a player" TO TL-CASE
     MOVE "transfer example.org 25566 Alice" TO WS-LINE
     MOVE "commands.transfer.success.single(Alice,example.org,25566)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer the player is sent Transfer: host and port 25566" TO TL-CASE
     MOVE 132 TO WS-WANTED
     MOVE "0b6578616d706c652e6f7267dec701" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /transfer result 1 for one player" TO TL-CASE
     MOVE "transfer example.org 25566 Alice" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /transfer the earlier packets are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /transfer several players" TO TL-CASE
     MOVE "transfer example.org 25567 @a" TO WS-LINE
     MOVE "commands.transfer.success.multiple(2,example.org,25567)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer several players: each is sent the packet" TO TL-CASE
     MOVE 132 TO WS-WANTED
     MOVE "0b6578616d706c652e6f7267dfc701" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /transfer result is the number of players" TO TL-CASE
     MOVE "transfer example.org 25567 @a" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /transfer port 0 is below the range" TO TL-CASE
     MOVE "transfer example.org 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer port 65536 is above the range" TO TL-CASE
     MOVE "transfer example.org 65536" TO WS-LINE
     MOVE "argument.integer.big(65535,65536) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer a player without permission level 3 does not know it" TO TL-CASE
     MOVE "transfer example.org" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /transfer the console without players" TO TL-CASE
     MOVE "transfer example.org" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-TRANSFER.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
