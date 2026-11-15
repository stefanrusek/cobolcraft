*> Acceptance test of docs/protocol/16-commands-catalog.md §12 and §14a `warden_spawn_tracker clear | set <warning_level 0..4>` (permission level 2, DEBUG_DEV_COMMANDS): the player running it is the target;
*> commands.warden_spawn_tracker.clear.success.single / set.success.single [player]; result 1. The console is no player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-WARDEN-SPAWN-TRACKER.
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
     MOVE "acceptance US13 /warden_spawn_tracker clear tells the player" TO TL-CASE
     MOVE "warden_spawn_tracker clear" TO WS-LINE
     MOVE "commands.warden_spawn_tracker.clear.success.single(Opal)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /warden_spawn_tracker set tells the player" TO TL-CASE
     MOVE "warden_spawn_tracker set 3" TO WS-LINE
     MOVE "commands.warden_spawn_tracker.set.success.single(Opal)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /warden_spawn_tracker clear result 1" TO TL-CASE
     MOVE "warden_spawn_tracker clear" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /warden_spawn_tracker set 0 result 1" TO TL-CASE
     MOVE "warden_spawn_tracker set 0" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /warden_spawn_tracker set 5 is above the range" TO TL-CASE
     MOVE "warden_spawn_tracker set 5" TO WS-LINE
     MOVE "argument.integer.big(4,5) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /warden_spawn_tracker a player without permission level 2 does not know it" TO TL-CASE
     MOVE "warden_spawn_tracker clear" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /warden_spawn_tracker the console needs a player" TO TL-CASE
     MOVE "warden_spawn_tracker clear" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-WARDEN-SPAWN-TRACKER.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
