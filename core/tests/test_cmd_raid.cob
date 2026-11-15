*> Acceptance test of docs/protocol/16-commands-catalog.md §12 and §14a `raid start <omenlvl> | stop | check | sound <type> | spawnleader | setomen <level> | glow` (permission level 3, DEBUG_DEV_COMMANDS): no message; result 1 for every form.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RAID.
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
     MOVE "acceptance US13 /raid without DEBUG_DEV_COMMANDS the command is not registered" TO TL-CASE
     MOVE "raid stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO BA-DEV-COMMANDS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /raid start result 1" TO TL-CASE
     MOVE "raid start 2" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid stop result 1" TO TL-CASE
     MOVE "raid stop" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid check result 1" TO TL-CASE
     MOVE "raid check" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid sound result 1" TO TL-CASE
     MOVE "raid sound ""horn""" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid spawnleader result 1" TO TL-CASE
     MOVE "raid spawnleader" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid setomen result 1" TO TL-CASE
     MOVE "raid setomen 3" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid glow result 1" TO TL-CASE
     MOVE "raid glow" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /raid stop gives no message" TO TL-CASE
     MOVE "raid stop" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /raid start a negative omen level" TO TL-CASE
     MOVE "raid start -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /raid setomen a negative level" TO TL-CASE
     MOVE "raid setomen -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /raid a player without permission level 3 does not know it" TO TL-CASE
     MOVE "raid stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-RAID.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
