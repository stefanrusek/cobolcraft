*> Acceptance test of docs/protocol/16-commands-catalog.md §12 `debugconfig config <target:player> | unconfig <target:uuid> | dialog <target:uuid> <dialog>` (permission level 3, DEBUG_DEV_COMMANDS and a dedicated host): no message; result 0 (the catalog gives none).
*> Opal holds level 4, Alice none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DEBUGCONFIG.
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
     MOVE 1 TO BA-DEV-COMMANDS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /debugconfig config a player gives no message" TO TL-CASE
     MOVE "debugconfig config Alice" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debugconfig config result 0" TO TL-CASE
     MOVE "debugconfig config Alice" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugconfig unconfig a uuid" TO TL-CASE
     MOVE "debugconfig unconfig 00112233-4455-6677-8899-aabbccddeeff" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugconfig dialog a uuid and a dialog" TO TL-CASE
     MOVE "debugconfig dialog 00112233-4455-6677-8899-aabbccddeeff minecraft:custom" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugconfig an invalid uuid" TO TL-CASE
     MOVE "debugconfig unconfig nope" TO WS-LINE
     MOVE "argument.uuid.invalid() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debugconfig a player without permission level 3 does not know it" TO TL-CASE
     MOVE "debugconfig config Alice" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO WS-TICKS
     CALL "TA-SET-HOST-KIND" USING WS-TICKS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /debugconfig a hosted (not dedicated) world does not register it" TO TL-CASE
     MOVE "debugconfig config Alice" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-DEBUGCONFIG.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
