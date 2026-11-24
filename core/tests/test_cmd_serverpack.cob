*> The url is a quotable string (a word with : and / needs quotes).
*> Acceptance test of docs/protocol/16-commands-catalog.md §11.21 and §14a `serverpack push <url> <uuid> <hash> | pop <uuid>` (permission level 2, DEBUG_DEV_COMMANDS): every player is sent Resource Pack Push (0x52: uuid, url, hash,
*> required false, no prompt) or Pop (0x51, the uuid present); no message; result 0. Expected bodies computed apart (uuid bytes, VarInt string lengths).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SERVERPACK.
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
     MOVE "acceptance US13 /serverpack without DEBUG_DEV_COMMANDS the command is not registered" TO TL-CASE
     MOVE "serverpack pop 00112233-4455-6677-8899-aabbccddeeff" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 1 TO BA-DEV-COMMANDS
     CALL "BR-STD-TREE"
     MOVE "acceptance US13 /serverpack push result 0" TO TL-CASE
     MOVE "serverpack push ""http://example.org/p.zip"" 00112233-4455-6677-8899-aabbccddeeff 01234567" & "89abcdef0123456789abcdef01234567" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /serverpack push every player gets Resource Pack Push" TO TL-CASE
     MOVE "82" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-ALICE TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /serverpack push gives no message" TO TL-CASE
     MOVE "serverpack push ""http://example.org/p.zip"" 00112233-4455-6677-8899-aabbccddeeff 01234567" & "89abcdef0123456789abcdef01234567" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /serverpack push body" TO TL-CASE
     MOVE 82 TO WS-WANTED
     MOVE "00112233445566778899aabbccddeeff18687474703a2f2f6578616d706c652e6f72672f702e7a697028303132" & "333435363738396162636465663031323334353637383961626364656630313233343536370000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /serverpack push a quoted url" TO TL-CASE
     MOVE "serverpack push ""http://a b/p.zip"" 00112233-4455-6677-8899-aabbccddeeff 0123456789abcdef" & "0123456789abcdef01234567" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /serverpack push the quotes are not part of the url" TO TL-CASE
     MOVE 82 TO WS-WANTED
     MOVE "00112233445566778899aabbccddeeff10687474703a2f2f6120622f702e7a6970283031323334353637383961" & "62636465663031323334353637383961626364656630313233343536370000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /serverpack pop result 0" TO TL-CASE
     MOVE "serverpack pop 00112233-4455-6677-8899-aabbccddeeff" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /serverpack pop body" TO TL-CASE
     MOVE 81 TO WS-WANTED
     MOVE "0100112233445566778899aabbccddeeff" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /serverpack a player without permission level 2 does not know it" TO TL-CASE
     MOVE "serverpack pop 00112233-4455-6677-8899-aabbccddeeff" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /serverpack pop an invalid uuid" TO TL-CASE
     MOVE "serverpack pop nope" TO WS-LINE
     MOVE "argument.uuid.invalid() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-SERVERPACK.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
