*> Acceptance test of docs/protocol/16-commands-catalog.md §8.9 `title <targets> clear | reset | title <c> | subtitle <c> | actionbar <c> | times <fadeIn> <stay> <fadeOut>` (permission level 2) and §14a: Clear Titles 0x0E (reset flag), Set Title Text 0x74,
*> Set Subtitle Text 0x72, Set Action Bar Text 0x59, Set Titles Animation 0x75 (three 4-byte Ints) to each target; commands.title.<kind>.single [player] or .multiple [count], broadcast; the result is the number of players.
*> (The console text of the title keys is BLOCKED outside this file: the generated BRLANGC.cpy rows of "single / multiple" pairs hold both texts in the .single key.)
*> Text bodies are the network NBT compound {text} (0a, string tag 08, name "text", the value, 00). Opal holds operator status; Alice and Bob do not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TITLE.
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
     MOVE "acceptance US13 /title clear" TO TL-CASE
     MOVE "title Alice clear" TO WS-LINE
     MOVE "commands.title.cleared.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title clear sends Clear Titles without reset" TO TL-CASE
     MOVE 14 TO WS-WANTED
     MOVE "00" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title reset" TO TL-CASE
     MOVE "title Alice reset" TO WS-LINE
     MOVE "commands.title.reset.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title reset sends Clear Titles with reset" TO TL-CASE
     MOVE 14 TO WS-WANTED
     MOVE "01" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title title" TO TL-CASE
     MOVE "title Alice title ""Hello""" TO WS-LINE
     MOVE "commands.title.show.title.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title title sends Set Title Text" TO TL-CASE
     MOVE 116 TO WS-WANTED
     MOVE "0a08000474657874000548656c6c6f00" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title subtitle" TO TL-CASE
     MOVE "title Alice subtitle ""Sub""" TO WS-LINE
     MOVE "commands.title.show.subtitle.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title subtitle sends Set Subtitle Text" TO TL-CASE
     MOVE 114 TO WS-WANTED
     MOVE "0a08000474657874000353756200" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title actionbar" TO TL-CASE
     MOVE "title Alice actionbar {text:""Bar""}" TO WS-LINE
     MOVE "commands.title.show.actionbar.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title actionbar sends Set Action Bar Text" TO TL-CASE
     MOVE 89 TO WS-WANTED
     MOVE "0a08000474657874000342617200" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title times" TO TL-CASE
     MOVE "title Alice times 10 70 20" TO WS-LINE
     MOVE "commands.title.times.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title times sends Set Titles Animation" TO TL-CASE
     MOVE 117 TO WS-WANTED
     MOVE "0000000a0000004600000014" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title times with units" TO TL-CASE
     MOVE "title Bob times 1s 2s 0.5s" TO WS-LINE
     MOVE "commands.title.times.single(Bob)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title times 1s 2s 0.5s are 20 40 10 ticks" TO TL-CASE
     MOVE 117 TO WS-WANTED
     MOVE "00000014000000280000000a" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-BOB TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title several players" TO TL-CASE
     MOVE "title @a title ""All""" TO WS-LINE
     MOVE "commands.title.show.title.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title every player is sent the title" TO TL-CASE
     MOVE 116 TO WS-WANTED
     MOVE "0a080004746578740003416c6c00" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-BOB TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /title result is the number of players" TO TL-CASE
     MOVE "title @a clear" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /title result 1" TO TL-CASE
     MOVE "title Alice reset" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /title several players cleared" TO TL-CASE
     MOVE "title @a clear" TO WS-LINE
     MOVE "commands.title.cleared.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title several players reset" TO TL-CASE
     MOVE "title @a reset" TO WS-LINE
     MOVE "commands.title.reset.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title several players subtitle" TO TL-CASE
     MOVE "title @a subtitle ""s""" TO WS-LINE
     MOVE "commands.title.show.subtitle.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title several players actionbar" TO TL-CASE
     MOVE "title @a actionbar ""a""" TO WS-LINE
     MOVE "commands.title.show.actionbar.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title several players times" TO TL-CASE
     MOVE "title @a times 1 2 3" TO WS-LINE
     MOVE "commands.title.times.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title nobody found" TO TL-CASE
     MOVE "title Nobody clear" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /title a player without permission level 2 does not know it" TO TL-CASE
     MOVE "title Bob clear" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-TITLE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
