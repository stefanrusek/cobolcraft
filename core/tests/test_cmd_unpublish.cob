*> Acceptance test of docs/protocol/16-commands-catalog.md §11.16 `unpublish` (permission level 4, a hosted world): a published world is closed (commands.unpublish.success, broadcast, result 1); else commands.unpublish.notPublished.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-UNPUBLISH.
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
     MOVE 1 TO WS-TICKS
     CALL "TA-SET-HOST-KIND" USING WS-TICKS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /unpublish when nothing is published" TO TL-CASE
     MOVE "unpublish" TO WS-LINE
     MOVE "commands.unpublish.notPublished()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /unpublish a world to close" TO TL-CASE
     MOVE "publish true 25570" TO WS-LINE
     MOVE "commands.publish.started.lan(25570)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /unpublish result 1" TO TL-CASE
     MOVE "unpublish" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /unpublish closed the world: publishing works again" TO TL-CASE
     MOVE "publish true 25571" TO WS-LINE
     MOVE "commands.publish.started.lan(25571)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /unpublish the message" TO TL-CASE
     MOVE "unpublish" TO WS-LINE
     MOVE "commands.unpublish.success()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /unpublish a player without permission level 4 does not know it" TO TL-CASE
     MOVE "unpublish" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-UNPUBLISH.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
