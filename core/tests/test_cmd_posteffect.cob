*> Acceptance test of docs/protocol/16-commands-catalog.md §8.11 `posteffect add <targets> <id> | remove <targets> <id> | clear <targets> | list <target>` (permission level 2) and §14a: each player keeps a list of post effects; after a change the player is sent
*> Post Effects (0x53: the VarInt count and each identifier); messages .add.success.single [effect, player] / .multiple [effect, count] (broadcast), .remove.success, .clear.success [player] / [count]; the failures .add.failed (all had it), .remove.failed, .clear.failed;
*> list: .list.success [player, count, effects joined by ", "] or .list.empty [player], not broadcast, the result is the size. The result of the others is the tracker total (players changed). An identifier without a namespace gets minecraft:.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-POSTEFFECT.
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
     MOVE "acceptance US13 /posteffect list of a player with none" TO TL-CASE
     MOVE "posteffect list Alice" TO WS-LINE
     MOVE "commands.posteffect.list.empty(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add" TO TL-CASE
     MOVE "posteffect add Alice minecraft:transparency" TO WS-LINE
     MOVE "commands.posteffect.add.success.single(minecraft:transparency,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add sends Post Effects with the list" TO TL-CASE
     MOVE 83 TO WS-WANTED
     MOVE "01166d696e6563726166743a7472616e73706172656e6379" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /posteffect add the same effect again" TO TL-CASE
     MOVE "posteffect add Alice minecraft:transparency" TO WS-LINE
     MOVE "commands.posteffect.add.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add without a namespace" TO TL-CASE
     MOVE "posteffect add Alice blur" TO WS-LINE
     MOVE "commands.posteffect.add.success.single(minecraft:blur,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add sends the whole list" TO TL-CASE
     MOVE 83 TO WS-WANTED
     MOVE "02166d696e6563726166743a7472616e73706172656e63790e6d696e6563726166743a626c7572" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /posteffect list" TO TL-CASE
     MOVE "posteffect list Alice" TO WS-LINE
     MOVE "commands.posteffect.list.success(Alice,2,minecraft:transparency, minecraft:blur)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect list result is the size" TO TL-CASE
     MOVE "posteffect list Alice" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect remove" TO TL-CASE
     MOVE "posteffect remove Alice transparency" TO WS-LINE
     MOVE "commands.posteffect.remove.success.single(minecraft:transparency,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect remove an effect the player does not have" TO TL-CASE
     MOVE "posteffect remove Alice transparency" TO WS-LINE
     MOVE "commands.posteffect.remove.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /posteffect the earlier packets are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /posteffect clear" TO TL-CASE
     MOVE "posteffect clear Alice" TO WS-LINE
     MOVE "commands.posteffect.clear.success.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect clear sends an empty list" TO TL-CASE
     MOVE 83 TO WS-WANTED
     MOVE "00" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /posteffect clear with nothing to remove" TO TL-CASE
     MOVE "posteffect clear Alice" TO WS-LINE
     MOVE "commands.posteffect.clear.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect list after the clear" TO TL-CASE
     MOVE "posteffect list Alice" TO WS-LINE
     MOVE "commands.posteffect.list.empty(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add to Alice for the next case" TO TL-CASE
     MOVE "posteffect add Alice x" TO WS-LINE
     MOVE "commands.posteffect.add.success.single(minecraft:x,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add to every player counts the players changed" TO TL-CASE
     MOVE "posteffect add @a x" TO WS-LINE
     MOVE "commands.posteffect.add.success.multiple(minecraft:x,2)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add to every player when all have it" TO TL-CASE
     MOVE "posteffect add @a x" TO WS-LINE
     MOVE "commands.posteffect.add.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect remove result is the number of players" TO TL-CASE
     MOVE "posteffect remove @a x" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect add again to Alice only" TO TL-CASE
     MOVE "posteffect add Alice y" TO WS-LINE
     MOVE "commands.posteffect.add.success.single(minecraft:y,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect remove from every player: one changed is the single message" TO TL-CASE
     MOVE "posteffect remove @a y" TO WS-LINE
     MOVE "commands.posteffect.remove.success.single(minecraft:y,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add y to every player" TO TL-CASE
     MOVE "posteffect add @a y" TO WS-LINE
     MOVE "commands.posteffect.add.success.multiple(minecraft:y,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect remove y from every player" TO TL-CASE
     MOVE "posteffect remove @a y" TO WS-LINE
     MOVE "commands.posteffect.remove.success.multiple(minecraft:y,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add z to every player" TO TL-CASE
     MOVE "posteffect add @a z" TO WS-LINE
     MOVE "commands.posteffect.add.success.multiple(minecraft:z,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect clear result is the number of players" TO TL-CASE
     MOVE "posteffect clear @a" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect add z for the multiple clear" TO TL-CASE
     MOVE "posteffect add @a z" TO WS-LINE
     MOVE "commands.posteffect.add.success.multiple(minecraft:z,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect clear every player" TO TL-CASE
     MOVE "posteffect clear @a" TO WS-LINE
     MOVE "commands.posteffect.clear.success.multiple(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect clear every player with nothing to remove" TO TL-CASE
     MOVE "posteffect clear @a" TO WS-LINE
     MOVE "commands.posteffect.clear.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect add result is the number of players" TO TL-CASE
     MOVE "posteffect add Bob q" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect list of Bob" TO TL-CASE
     MOVE "posteffect list Bob" TO WS-LINE
     MOVE "commands.posteffect.list.success(Bob,1,minecraft:q)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect Bob gets effect p2" TO TL-CASE
     MOVE "posteffect add Bob p2" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p3" TO TL-CASE
     MOVE "posteffect add Bob p3" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p4" TO TL-CASE
     MOVE "posteffect add Bob p4" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p5" TO TL-CASE
     MOVE "posteffect add Bob p5" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p6" TO TL-CASE
     MOVE "posteffect add Bob p6" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p7" TO TL-CASE
     MOVE "posteffect add Bob p7" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect Bob gets effect p8" TO TL-CASE
     MOVE "posteffect add Bob p8" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /posteffect a list holds 8 effects: the ninth changes nothing" TO TL-CASE
     MOVE "posteffect add Bob p9" TO WS-LINE
     MOVE "commands.posteffect.add.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect removing from the middle keeps the order" TO TL-CASE
     MOVE "posteffect remove Bob p3" TO WS-LINE
     MOVE "commands.posteffect.remove.success.single(minecraft:p3,Bob)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect the list of Bob after the removal" TO TL-CASE
     MOVE "posteffect list Bob" TO WS-LINE
     MOVE "commands.posteffect.list.success(Bob,7,minecraft:q, minecraft:p2, minecraft:p4, minecraft:" & "p5, minecraft:p6, minecraft:p7, minecraft:p8)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect list needs one player" TO TL-CASE
     MOVE "posteffect list @a" TO WS-LINE
     MOVE "argument.player.toomany() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect nobody found" TO TL-CASE
     MOVE "posteffect clear Nobody" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /posteffect a player without permission level 2 does not know it" TO TL-CASE
     MOVE "posteffect clear Bob" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-POSTEFFECT.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
