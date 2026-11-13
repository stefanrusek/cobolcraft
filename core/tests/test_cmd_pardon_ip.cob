*> Acceptance test of docs/protocol/16-commands-catalog.md §11.6 `pardon-ip <target:word>` (permission level 3, dedicated): the target must be an IPv4 address (else commands.pardonip.invalid) that is banned
*> (else commands.pardonip.failed); it leaves the IP list; commands.pardonip.success [address] (broadcast); the result is 1. Opal holds level 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PARDON-IP.
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
     MOVE "acceptance US13 /pardon-ip an address to ban first" TO TL-CASE
     MOVE "ban-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.banip.success(10.0.0.1,Banned by an operator.)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip the address is unbanned" TO TL-CASE
     MOVE "pardon-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.pardonip.success(10.0.0.1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip an address that is not banned" TO TL-CASE
     MOVE "pardon-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.pardonip.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip not an address" TO TL-CASE
     MOVE "pardon-ip Alice" TO WS-LINE
     MOVE "commands.pardonip.invalid()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip a second ban" TO TL-CASE
     MOVE "ban-ip 10.0.0.2" TO WS-LINE
     MOVE "commands.banip.success(10.0.0.2,Banned by an operator.)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip result 1" TO TL-CASE
     MOVE "pardon-ip 10.0.0.2" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /pardon-ip a player without permission level 3 does not know it" TO TL-CASE
     MOVE "pardon-ip 10.0.0.2" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /pardon-ip the console prints the failure text" TO TL-CASE
     MOVE "pardon-ip 10.0.0.2" TO WS-LINE
     MOVE "Nothing changed. That IP isn't banned" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-PARDON-IP.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
