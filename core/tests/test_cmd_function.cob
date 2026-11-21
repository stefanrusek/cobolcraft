*> Acceptance test of docs/protocol/16-commands-catalog.md §10.3 `function` (permission level 2) with 14a: no data-pack function exists (the function engine is not specified), so every form of
*> function <name|#tag> [<arguments> | with block|entity|storage ...] is commands.function.scheduled.no_functions [name] with the namespace added; the result is 0. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-FUNCTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-TICKS               BINARY-LONG.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-2              PIC -(9)9.
 PROCEDURE DIVISION.
    CALL "TEST-SETTINGS" USING CORE-SETTINGS
    CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
    MOVE "Opal" TO WS-NAME
    MOVE 4 TO WS-NAME-LENGTH
    CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
    MOVE "Alice" TO WS-NAME
    MOVE 5 TO WS-NAME-LENGTH
    CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
    CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
    CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
    MOVE "acceptance US13 /function a function that does not exist" TO TL-CASE
    MOVE "function foo:bar" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function the default namespace is minecraft" TO TL-CASE
    MOVE "function plain" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(minecraft:plain)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function a function tag" TO TL-CASE
    MOVE "function #foo:tag" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(#foo:tag)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with an argument compound" TO TL-CASE
    MOVE "function foo:bar {a:1}" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with a storage" TO TL-CASE
    MOVE "function foo:bar with storage foo:s" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with a storage path" TO TL-CASE
    MOVE "function foo:bar with storage foo:s a.b" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with a block" TO TL-CASE
    MOVE "function foo:bar with block 0 64 0" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with a block path" TO TL-CASE
    MOVE "function foo:bar with block 0 64 0 a.b" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with an entity" TO TL-CASE
    MOVE "function foo:bar with entity @s" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function with an entity path" TO TL-CASE
    MOVE "function foo:bar with entity @s a.b" TO WS-LINE
    MOVE "commands.function.scheduled.no_functions(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /function the result of a failure is 0" TO TL-CASE
    MOVE "function foo:bar" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /function a player below level 2 cannot run it" TO TL-CASE
    MOVE "function foo:bar" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-FUNCTION.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
