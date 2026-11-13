*> Acceptance test of docs/protocol/16-commands-catalog.md §10.1 `data` (permission level 2) with 14a, over the storage holder: get (whole, path, scale), merge, modify
*> (set, merge, append, prepend, insert with the value, from and string sources) and remove, with their messages and results. Entity and block holders are in test_cmd_data_holders. Opal holds
*> operator status, Alice does not. The compute source is not tested: BLOCKED (needs the float and int providers of 10.9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
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
    MOVE "acceptance US13 /data get of an empty storage" TO TL-CASE
    MOVE "data get storage foo" TO WS-LINE
    MOVE "commands.data.storage.query(minecraft:foo,{})" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data merge into storage" TO TL-CASE
    MOVE "data merge storage foo {a:1,b:{c:2}}" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get the whole storage" TO TL-CASE
    MOVE "data get storage foo" TO WS-LINE
    MOVE "commands.data.storage.query(minecraft:foo,{a:1,b:{c:2}})" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a path" TO TL-CASE
    MOVE "data get storage foo b.c" TO WS-LINE
    MOVE "commands.data.storage.get(b.c,minecraft:foo,1.00,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a path with a scale" TO TL-CASE
    MOVE "data get storage foo a 2.5" TO WS-LINE
    MOVE "commands.data.storage.get(a,minecraft:foo,2.50,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a compound is its key count" TO TL-CASE
    MOVE "data get storage foo b" TO WS-LINE
    MOVE "commands.data.storage.get(b,minecraft:foo,1.00,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a missing path" TO TL-CASE
    MOVE "data get storage foo z" TO WS-LINE
    MOVE "commands.data.get.unknown(z)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data merge changes nothing" TO TL-CASE
    MOVE "data merge storage foo {a:1}" TO WS-LINE
    MOVE "commands.data.merge.failed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data merge a changed value" TO TL-CASE
    MOVE 'data merge storage foo {a:2,d:"hello"}' TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a double with a scale is the floor of the product" TO TL-CASE
    MOVE "data merge storage foo {f:2.5d}" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "data get storage foo f 2" TO WS-LINE
    MOVE "commands.data.storage.get(f,minecraft:foo,2.00,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a string is its length" TO TL-CASE
    MOVE "data get storage foo d" TO WS-LINE
    MOVE "commands.data.storage.get(d,minecraft:foo,1.00,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set value" TO TL-CASE
    MOVE "data modify storage foo l set value [1,2,3]" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get a list is its size" TO TL-CASE
    MOVE "data get storage foo l" TO WS-LINE
    MOVE "commands.data.storage.get(l,minecraft:foo,1.00,3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get several matches" TO TL-CASE
    MOVE "data get storage foo l[]" TO WS-LINE
    MOVE "commands.data.get.multiple()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set to the same value" TO TL-CASE
    MOVE "data modify storage foo a set value 2" TO WS-LINE
    MOVE "commands.data.merge.failed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify append" TO TL-CASE
    MOVE "data modify storage foo l append value 4" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify prepend" TO TL-CASE
    MOVE "data modify storage foo l prepend value 0" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify insert" TO TL-CASE
    MOVE "data modify storage foo l insert 2 value 9" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data list after the inserts" TO TL-CASE
    MOVE "data get storage foo l[2]" TO WS-LINE
    MOVE "commands.data.storage.get(l[2],minecraft:foo,1.00,9)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify insert at a negative index counts from the end" TO TL-CASE
    MOVE "data modify storage foo l insert -1 value 7" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify insert past the end" TO TL-CASE
    MOVE "data modify storage foo l insert 99 value 1" TO WS-LINE
    MOVE "commands.data.modify.invalid_index(99)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify append to a value that is no list" TO TL-CASE
    MOVE "data modify storage foo a append value 1" TO WS-LINE
    MOVE "commands.data.modify.expected_list(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify append creates the list" TO TL-CASE
    MOVE "data modify storage foo fresh append value 1" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify merge" TO TL-CASE
    MOVE "data modify storage foo b merge value {e:5}" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify merge of a value that is no compound" TO TL-CASE
    MOVE "data modify storage foo b merge value 5" TO WS-LINE
    MOVE "commands.data.modify.expected_object(5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify merge into a value that is no compound" TO TL-CASE
    MOVE "data modify storage foo a merge value {x:1}" TO WS-LINE
    MOVE "commands.data.modify.expected_object(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set from storage" TO TL-CASE
    MOVE "data modify storage foo copy set from storage foo b" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set from a path that is missing" TO TL-CASE
    MOVE "data modify storage foo copy set from storage foo nope" TO WS-LINE
    MOVE "arguments.nbtpath.nothing_found(nope)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set from a whole storage" TO TL-CASE
    MOVE "data modify storage bar all set from storage foo" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify set from several values" TO TL-CASE
    MOVE "data modify storage foo many set from storage foo l[]" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify string source" TO TL-CASE
    MOVE "data modify storage foo s set string storage foo d" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data string source result" TO TL-CASE
    MOVE "data get storage foo s" TO WS-LINE
    MOVE "commands.data.storage.get(s,minecraft:foo,1.00,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify string source with a start" TO TL-CASE
    MOVE "data modify storage foo s2 set string storage foo d 1" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify string source with a start and an end" TO TL-CASE
    MOVE "data modify storage foo s3 set string storage foo d 1 3" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data string source cut is its length" TO TL-CASE
    MOVE "data get storage foo s3" TO WS-LINE
    MOVE "commands.data.storage.get(s3,minecraft:foo,1.00,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify string source with an invalid substring" TO TL-CASE
    MOVE "data modify storage foo s4 set string storage foo d 4 2" TO WS-LINE
    MOVE "commands.data.modify.invalid_substring(4,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data modify string source of a value that is no string" TO TL-CASE
    MOVE "data modify storage foo s5 set string storage foo a" TO WS-LINE
    MOVE "commands.data.modify.expected_value(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data string source with several values" TO TL-CASE
    MOVE "data modify storage foo s6 set string storage foo l[]" TO WS-LINE
    MOVE "commands.data.get.multiple()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data remove a key" TO TL-CASE
    MOVE "data remove storage foo a" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data remove a key that is missing" TO TL-CASE
    MOVE "data remove storage foo a" TO WS-LINE
    MOVE "arguments.nbtpath.nothing_found(a)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data remove list elements" TO TL-CASE
    MOVE "data remove storage foo l[]" TO WS-LINE
    MOVE "commands.data.storage.modified(minecraft:foo)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data a namespaced id" TO TL-CASE
    MOVE "data merge storage my:thing {k:1}" TO WS-LINE
    MOVE "commands.data.storage.modified(my:thing)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data get of a namespaced id" TO TL-CASE
    MOVE "data get storage my:thing k" TO WS-LINE
    MOVE "commands.data.storage.get(k,my:thing,1.00,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /data result: merge is 1" TO TL-CASE
    MOVE "data merge storage nums {n:1}" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: get without a path is 1" TO TL-CASE
    MOVE "data get storage nums" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: get a number with a scale is the floor" TO TL-CASE
    MOVE "data get storage nums n 3.7" TO WS-LINE
    MOVE 3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: get a negative number floors" TO TL-CASE
    MOVE "data merge storage nums {m:-2}" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: get a negative number floors toward minus infinity" TO TL-CASE
    MOVE "data get storage nums m 1.5" TO WS-LINE
    MOVE -3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: modify is the number of changes" TO TL-CASE
    MOVE "data modify storage nums n set value 9" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: modify of two values changes two" TO TL-CASE
    MOVE "data modify storage nums arr set value [1,2,3]" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: append of two values" TO TL-CASE
    MOVE "data modify storage nums arr append from storage nums arr[]" TO WS-LINE
    MOVE 3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data result: remove is the count removed" TO TL-CASE
    MOVE "data remove storage nums arr[]" TO WS-LINE
    MOVE 6 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /data a player below level 2 cannot run it" TO TL-CASE
    MOVE "data get storage foo" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "data merge storage full01 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full02 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full03 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full04 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full05 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full06 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full07 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full08 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full09 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full10 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full11 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full12 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full13 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full14 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full15 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full16 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full17 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full18 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full19 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full20 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full21 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full22 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full23 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full24 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full25 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full26 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full27 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "data merge storage full28 {k:1}" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /data the 33rd storage (the 29th named here) does not fit" TO TL-CASE
    MOVE "data merge storage full29 {k:1}" TO WS-LINE
    MOVE "cobolcraft.data.too_large()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-DATA.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
