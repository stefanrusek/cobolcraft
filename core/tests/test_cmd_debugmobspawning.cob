*> Acceptance test of docs/protocol/16-commands-catalog.md §12 `debugmobspawning <mob_category> <at:block_pos>` (permission level 2, DEBUG_DEV_COMMANDS): the categories are those of 18 §1.2; no message; result 0 (the catalog gives none).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DEBUGMOBSPAWNING.
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
     MOVE "acceptance US13 /debugmobspawning without DEBUG_DEV_COMMANDS the command is not registered" TO TL-CASE
     MOVE "debugmobspawning monster 1 2 3" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO BA-DEV-COMMANDS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /debugmobspawning monster" TO TL-CASE
     MOVE "debugmobspawning monster 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning creature" TO TL-CASE
     MOVE "debugmobspawning creature 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning ambient" TO TL-CASE
     MOVE "debugmobspawning ambient 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning axolotls" TO TL-CASE
     MOVE "debugmobspawning axolotls 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning underground_water_creature" TO TL-CASE
     MOVE "debugmobspawning underground_water_creature 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning water_creature" TO TL-CASE
     MOVE "debugmobspawning water_creature 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning water_ambient" TO TL-CASE
     MOVE "debugmobspawning water_ambient ~ ~ ~" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning misc" TO TL-CASE
     MOVE "debugmobspawning misc 1 2 3" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /debugmobspawning gives no message" TO TL-CASE
     MOVE "debugmobspawning monster 1 2 3" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debugmobspawning an unknown category" TO TL-CASE
     MOVE "debugmobspawning dragon 1 2 3" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /debugmobspawning a player without permission level 2 does not know it" TO TL-CASE
     MOVE "debugmobspawning monster 1 2 3" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-DEBUGMOBSPAWNING.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
