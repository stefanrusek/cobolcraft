*> Acceptance test of docs/protocol/16-commands-catalog.md §8.10 `dialog clear <targets>` (permission level 2) and §14a: each target is sent Clear Dialog (0x8E, no fields); commands.dialog.clear.single [player] or .multiple [count], broadcast; the result is the
*> number of players. `dialog show` is BLOCKED docs: the dialog registry is empty in the stand-in content (no id to send) and the inline dialog needs an NBT encoding of the SNBT argument that no document gives.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DIALOG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL        BINARY-LONG.
 01 WS-ID-ALICE        BINARY-LONG.
 01 WS-ID-BOB        BINARY-LONG.
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
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     MOVE "acceptance US13 /dialog clear one player" TO TL-CASE
     MOVE "dialog clear Alice" TO WS-LINE
     MOVE "commands.dialog.clear.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /dialog clear sends Clear Dialog" TO TL-CASE
     MOVE "142" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-ALICE TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /dialog clear several players" TO TL-CASE
     MOVE "dialog clear @a" TO WS-LINE
     MOVE "commands.dialog.clear.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /dialog clear sends Clear Dialog to every player" TO TL-CASE
     MOVE "142" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-BOB TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /dialog clear result is the number of players" TO TL-CASE
     MOVE "dialog clear @a" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /dialog clear result 1" TO TL-CASE
     MOVE "dialog clear Bob" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /dialog clear nobody found" TO TL-CASE
     MOVE "dialog clear Nobody" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /dialog a player without permission level 2 does not know it" TO TL-CASE
     MOVE "dialog clear Bob" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /dialog the console prints the message" TO TL-CASE
     MOVE "dialog clear Alice" TO WS-LINE
     MOVE "Cleared dialog for Alice" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-DIALOG.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
