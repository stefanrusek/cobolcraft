*> Acceptance test of docs/protocol/16-commands-catalog.md §10.11 `datapack` (permission level 2, create 4) with 14a: the pack list (the built-in vanilla pack, enabled, and the packs create makes, "file/<id>", in memory,
*> not saved and without files) with list [available|enabled], enable <pack> [first|last|before <pack>|after <pack>], disable and create <id> <description>. The checks of required flags, the metadata encoding
*> and the files of create cannot arise. Opal holds operator status (level 4), Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DATAPACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE           BINARY-LONG.
 01 WS-ID-MOD             BINARY-LONG.
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
    MOVE "acceptance US13 /datapack list shows both lists" TO TL-CASE
    MOVE "datapack list" TO WS-LINE
    MOVE "commands.datapack.list.enabled.success(1,vanilla) | commands.datapack.list.available.none(" & ")" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack list result is both counts" TO TL-CASE
    MOVE "datapack list" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /datapack list enabled" TO TL-CASE
    MOVE "datapack list enabled" TO WS-LINE
    MOVE "commands.datapack.list.enabled.success(1,vanilla)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack list available with none" TO TL-CASE
    MOVE "datapack list available" TO WS-LINE
    MOVE "commands.datapack.list.available.none()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack create" TO TL-CASE
    MOVE "datapack create foo ""Test pack""" TO WS-LINE
    MOVE "commands.datapack.create.success(foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack create result is 1" TO TL-CASE
    MOVE "datapack create bar ""Second""" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /datapack create an existing one" TO TL-CASE
    MOVE "datapack create foo ""Again""" TO WS-LINE
    MOVE "commands.datapack.create.already_exists(foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack create with a bad name" TO TL-CASE
    MOVE "datapack create ""Bad Name"" ""x""" TO WS-LINE
    MOVE "commands.datapack.create.invalid_name(Bad Name)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack list available shows the new packs" TO TL-CASE
    MOVE "datapack list available" TO WS-LINE
    MOVE "commands.datapack.list.available.success(2,file/foo, file/bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack enable" TO TL-CASE
    MOVE "datapack enable ""file/foo""" TO WS-LINE
    MOVE "commands.datapack.modify.enable(file/foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack enable result is the number enabled" TO TL-CASE
    MOVE "datapack enable ""file/bar"" first" TO WS-LINE
    MOVE 3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /datapack enable one that is enabled" TO TL-CASE
    MOVE "datapack enable ""file/foo""" TO WS-LINE
    MOVE "commands.datapack.enable.failed(file/foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack enabled order has first at the front" TO TL-CASE
    MOVE "datapack list enabled" TO WS-LINE
    MOVE "commands.datapack.list.enabled.success(3,file/bar, vanilla, file/foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "datapack create baz ""x""" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /datapack enable before another" TO TL-CASE
    MOVE "datapack enable ""file/baz"" before ""file/foo""" TO WS-LINE
    MOVE "commands.datapack.modify.enable(file/baz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "datapack create qux ""x""" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /datapack enable after another" TO TL-CASE
    MOVE "datapack enable ""file/qux"" after ""vanilla""" TO WS-LINE
    MOVE "commands.datapack.modify.enable(file/qux)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "datapack create end ""x""" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /datapack enable last" TO TL-CASE
    MOVE "datapack enable ""file/end"" last" TO WS-LINE
    MOVE "commands.datapack.modify.enable(file/end)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack enabled order" TO TL-CASE
    MOVE "datapack list enabled" TO WS-LINE
    MOVE "commands.datapack.list.enabled.success(6,file/bar, vanilla, file/qux, file/baz, file/foo, " & "file/end)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "datapack create two ""x""" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /datapack enable before an unknown pack" TO TL-CASE
    MOVE "datapack enable ""file/two"" before ""zzz""" TO WS-LINE
    MOVE "commands.datapack.unknown(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack enable an unknown pack" TO TL-CASE
    MOVE "datapack enable ""file/zzz""" TO WS-LINE
    MOVE "commands.datapack.unknown(file/zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack disable" TO TL-CASE
    MOVE "datapack disable ""file/foo""" TO WS-LINE
    MOVE "commands.datapack.modify.disable(file/foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack disable result is the number still enabled" TO TL-CASE
    MOVE "datapack disable ""file/baz""" TO WS-LINE
    MOVE 4 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /datapack disable one that is not enabled" TO TL-CASE
    MOVE "datapack disable ""file/foo""" TO WS-LINE
    MOVE "commands.datapack.disable.failed(file/foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack disable an unknown pack" TO TL-CASE
    MOVE "datapack disable ""file/zzz""" TO WS-LINE
    MOVE "commands.datapack.unknown(file/zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack list available after disabling" TO TL-CASE
    MOVE "datapack list available" TO WS-LINE
    MOVE "commands.datapack.list.available.success(3,file/foo, file/baz, file/two)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack a player below level 2 cannot run it" TO TL-CASE
    MOVE "datapack list" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "Mod" TO WS-NAME
    MOVE 3 TO WS-NAME-LENGTH
    CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-MOD
    MOVE 2 TO AC-LEVEL(ACCESS-OPERATORS, AC-COUNT(ACCESS-OPERATORS))
    CALL "TEST-DRAIN-CHAT" USING WS-ID-MOD WS-DISCARD
    MOVE "acceptance US13 /datapack create needs level 4: a level 2 operator is refused" TO TL-CASE
    MOVE "datapack create lowlevel ""x""" TO WS-LINE
    MOVE "command.unknown.argument() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-MOD TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /datapack list is still allowed at level 2" TO TL-CASE
    MOVE "datapack list enabled" TO WS-LINE
    MOVE 4 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-MOD TL-CASE WS-LINE WS-EXPECTED-N
    GOBACK.
 END PROGRAM TEST-CMD-DATAPACK.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
