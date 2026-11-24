*> The console shows a key that BRLANGC.cpy has no English text for (the keys of 16 §11.20 are in prose only) as the key itself.
*> Acceptance test of docs/protocol/16-commands-catalog.md §11.20 and §14a `fetchprofile name <name> | id <id> | entity <entity>` (permission level 2): without a profile service name and id fail
*> (commands.fetchprofile.name.failure / id.failure); a player entity gets entity.success [name, profile text]; another entity commands.fetchprofile.no_profile [type]; result 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-FETCHPROFILE.
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
     MOVE "acceptance US13 /fetchprofile name fails without a profile service" TO TL-CASE
     MOVE "fetchprofile name Zed" TO WS-LINE
     MOVE "commands.fetchprofile.name.failure(Zed)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile name is greedy" TO TL-CASE
     MOVE "fetchprofile name Zed Yan" TO WS-LINE
     MOVE "commands.fetchprofile.name.failure(Zed Yan)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile id fails without a profile service" TO TL-CASE
     MOVE "fetchprofile id 00112233-4455-6677-8899-aabbccddeeff" TO WS-LINE
     MOVE "commands.fetchprofile.id.failure(00112233-4455-6677-8899-aabbccddeeff)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile entity a player" TO TL-CASE
     MOVE "fetchprofile entity Alice" TO WS-LINE
     MOVE "commands.fetchprofile.entity.success(Alice,Alice (10920508-d5d8-3eed-93d2-92f193afe7d7))" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile result 1" TO TL-CASE
     MOVE "fetchprofile name Zed" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /fetchprofile entity a mob to look at" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     MOVE "commands.summon.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile entity a mob has no profile" TO TL-CASE
     MOVE "fetchprofile entity @e[type=cobolcraft:sodgrazer,limit=1]" TO WS-LINE
     MOVE "commands.fetchprofile.no_profile(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile entity nobody found" TO TL-CASE
     MOVE "fetchprofile entity Nobody" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile a player without permission level 2 does not know it" TO TL-CASE
     MOVE "fetchprofile name Zed" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /fetchprofile the console prints the failure text" TO TL-CASE
     MOVE "fetchprofile name Zed" TO WS-LINE
     MOVE "commands.fetchprofile.name.failure" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-FETCHPROFILE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
