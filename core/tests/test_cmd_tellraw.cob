*> Acceptance test of docs/protocol/16-commands-catalog.md §8.8 `tellraw <targets:players> <message:component>` (permission level 2) and §14a: each target is sent the component as a system chat message; there is no success message; the result is the
*> number of players. A component is an SNBT string ("text", 'text', or an unquoted word), a compound with a text member ({text:"x"}, {"text":"x"}), anything else is shown as typed (selectors, scores and NBT inside it are not resolved here).
*> Opal holds operator status; Alice and Bob do not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TELLRAW.
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
     MOVE "acceptance US13 /tellraw sends the source nothing" TO TL-CASE
     MOVE "tellraw Alice ""hello world""" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw a double quoted string" TO TL-CASE
     MOVE "hello world" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a single quoted string (no message to the source)" TO TL-CASE
     MOVE "tellraw Alice 'single quoted'" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw a single quoted string is sent" TO TL-CASE
     MOVE "single quoted" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a compound with text" TO TL-CASE
     MOVE "tellraw Alice {text:""from compound""}" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw the text member is sent" TO TL-CASE
     MOVE "from compound" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a compound with a quoted key" TO TL-CASE
     MOVE "tellraw Bob {""text"":""json key""}" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     MOVE "acceptance US13 /tellraw the quoted text member is sent" TO TL-CASE
     MOVE "json key" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw an unquoted word" TO TL-CASE
     MOVE "tellraw Alice hello" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw the word is sent as typed" TO TL-CASE
     MOVE "hello" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a compound without a text member is shown as typed" TO TL-CASE
     MOVE "tellraw Alice {color:""red""}" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw the compound is sent as typed" TO TL-CASE
     MOVE "{color:""red""}" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a text member that is no string is shown as typed" TO TL-CASE
     MOVE "tellraw Alice {text:5}" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw the compound with a number is sent as typed" TO TL-CASE
     MOVE "{text:5}" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw every player (the source is one of them)" TO TL-CASE
     MOVE "tellraw @a ""all""" TO WS-LINE
     MOVE "all" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw every player: Alice" TO TL-CASE
     MOVE "all" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     MOVE "acceptance US13 /tellraw every player: Bob" TO TL-CASE
     MOVE "all" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw result is the number of players" TO TL-CASE
     MOVE "tellraw @a ""x""" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tellraw result 1 for one player" TO TL-CASE
     MOVE "tellraw Alice ""x""" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tellraw nobody found" TO TL-CASE
     MOVE "tellraw Nobody ""x""" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tellraw the earlier messages are drained" TO TL-CASE
     MOVE "x | x" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tellraw a player without permission level 2 does not know it" TO TL-CASE
     MOVE "tellraw Bob ""x""" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-TELLRAW.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
