*> Acceptance test of docs/protocol/16-commands-catalog.md §8.7 `bossbar` (permission level 2) and §14a: add <id> <name>, remove <id>, list, set <id> name|color|style|value|max|visible|players, get <id> value|max|visible|players. Defaults: value 0, max 100, visible,
*> white progress. Messages and results as in the section (the bar in a message is its identifier with the namespace: an id without one gets minecraft:). Boss Event 0x09 is sent to the players of the bar: ADD (uuid, 0, title, progress float = value / max,
*> color, overlay, flags 0) when a player joins a visible bar, REMOVE (1) when one leaves, the bar is removed or hidden, UPDATE_PROGRESS (2), UPDATE_NAME (3), UPDATE_STYLE (4) on changes (inferred: 16 §8.7 says the boss-event objects send them). The uuid of a bar is
*> 15 zero bytes and its table index. BR-E-KEY of the framework holds 48 characters: the 49 of commands.bossbar.set.visibility.unchanged.visible arrive without the last letter (the test pins that, a framework limit). Opal holds operator status; Alice and Bob do not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-BOSSBAR.
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
     MOVE "acceptance US13 /bossbar list with none" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE "commands.bossbar.list.bars.none()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar list result 0" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar add" TO TL-CASE
     MOVE "bossbar add test ""Boss""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar add an existing id" TO TL-CASE
     MOVE "bossbar add test ""X""" TO WS-LINE
     MOVE "commands.bossbar.create.failed(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar add result is the number of bars" TO TL-CASE
     MOVE "bossbar add other {text:""Two""}" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar list" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE "commands.bossbar.list.bars.some(2,minecraft:test, minecraft:other)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar list result 2" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar get value" TO TL-CASE
     MOVE "bossbar get test value" TO WS-LINE
     MOVE "commands.bossbar.get.value(minecraft:test,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get value result" TO TL-CASE
     MOVE "bossbar get test value" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar get max" TO TL-CASE
     MOVE "bossbar get test max" TO WS-LINE
     MOVE "commands.bossbar.get.max(minecraft:test,100)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get max result" TO TL-CASE
     MOVE "bossbar get test max" TO WS-LINE
     MOVE 100 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar get visible" TO TL-CASE
     MOVE "bossbar get test visible" TO WS-LINE
     MOVE "commands.bossbar.get.visible.visible(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get visible result 1" TO TL-CASE
     MOVE "bossbar get test visible" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar get players with none" TO TL-CASE
     MOVE "bossbar get test players" TO WS-LINE
     MOVE "commands.bossbar.get.players.none(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get players result 0" TO TL-CASE
     MOVE "bossbar get test players" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set value" TO TL-CASE
     MOVE "bossbar set test value 50" TO WS-LINE
     MOVE "commands.bossbar.set.value.success(minecraft:test,50)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set value unchanged" TO TL-CASE
     MOVE "bossbar set test value 50" TO WS-LINE
     MOVE "commands.bossbar.set.value.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set value result is the argument" TO TL-CASE
     MOVE "bossbar set test value 60" TO WS-LINE
     MOVE 60 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set value back" TO TL-CASE
     MOVE "bossbar set test value 50" TO WS-LINE
     MOVE "commands.bossbar.set.value.success(minecraft:test,50)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set value below 0" TO TL-CASE
     MOVE "bossbar set test value -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set max" TO TL-CASE
     MOVE "bossbar set test max 200" TO WS-LINE
     MOVE "commands.bossbar.set.max.success(minecraft:test,200)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set max unchanged" TO TL-CASE
     MOVE "bossbar set test max 200" TO WS-LINE
     MOVE "commands.bossbar.set.max.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set max result is the argument" TO TL-CASE
     MOVE "bossbar set test max 300" TO WS-LINE
     MOVE 300 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set max back" TO TL-CASE
     MOVE "bossbar set test max 200" TO WS-LINE
     MOVE "commands.bossbar.set.max.success(minecraft:test,200)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set max below 1" TO TL-CASE
     MOVE "bossbar set test max 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set name" TO TL-CASE
     MOVE "bossbar set test name ""Other""" TO WS-LINE
     MOVE "commands.bossbar.set.name.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set name unchanged" TO TL-CASE
     MOVE "bossbar set test name ""Other""" TO WS-LINE
     MOVE "commands.bossbar.set.name.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set name result 0" TO TL-CASE
     MOVE "bossbar set test name ""New""" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set color" TO TL-CASE
     MOVE "bossbar set test color red" TO WS-LINE
     MOVE "commands.bossbar.set.color.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set color unchanged" TO TL-CASE
     MOVE "bossbar set test color red" TO WS-LINE
     MOVE "commands.bossbar.set.color.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set color result 0" TO TL-CASE
     MOVE "bossbar set test color blue" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set color back to red" TO TL-CASE
     MOVE "bossbar set test color red" TO WS-LINE
     MOVE "commands.bossbar.set.color.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set color an unknown color" TO TL-CASE
     MOVE "bossbar set test color mauve" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set style" TO TL-CASE
     MOVE "bossbar set test style notched_6" TO WS-LINE
     MOVE "commands.bossbar.set.style.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set style unchanged" TO TL-CASE
     MOVE "bossbar set test style notched_6" TO WS-LINE
     MOVE "commands.bossbar.set.style.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set style result 0" TO TL-CASE
     MOVE "bossbar set test style progress" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set style back to notched_6" TO TL-CASE
     MOVE "bossbar set test style notched_6" TO WS-LINE
     MOVE "commands.bossbar.set.style.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set visible false" TO TL-CASE
     MOVE "bossbar set test visible false" TO WS-LINE
     MOVE "commands.bossbar.set.visible.success.hidden(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set visible false again" TO TL-CASE
     MOVE "bossbar set test visible false" TO WS-LINE
     MOVE "commands.bossbar.set.visibility.unchanged.hidden()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get visible when hidden" TO TL-CASE
     MOVE "bossbar get test visible" TO WS-LINE
     MOVE "commands.bossbar.get.visible.hidden(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get visible result 0" TO TL-CASE
     MOVE "bossbar get test visible" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set visible true" TO TL-CASE
     MOVE "bossbar set test visible true" TO WS-LINE
     MOVE "commands.bossbar.set.visible.success.visible(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set visible true again" TO TL-CASE
     MOVE "bossbar set test visible true" TO WS-LINE
     MOVE "commands.bossbar.set.visibility.unchanged.visibl()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set visible result 0" TO TL-CASE
     MOVE "bossbar set test visible false" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set visible true for the players" TO TL-CASE
     MOVE "bossbar set test visible true" TO WS-LINE
     MOVE "commands.bossbar.set.visible.success.visible(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /bossbar the packets so far are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /bossbar set players result is the number of players" TO TL-CASE
     MOVE "bossbar set test players Alice" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar a player joining the bar is sent ADD" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001000a0800047465787400034e6577003e800000020100" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar set players unchanged" TO TL-CASE
     MOVE "bossbar set test players Alice" TO WS-LINE
     MOVE "commands.bossbar.set.players.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get players" TO TL-CASE
     MOVE "bossbar get test players" TO WS-LINE
     MOVE "commands.bossbar.get.players.some(minecraft:test,1,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get players result 1" TO TL-CASE
     MOVE "bossbar get test players" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar set value for the players" TO TL-CASE
     MOVE "bossbar set test value 100" TO WS-LINE
     MOVE "commands.bossbar.set.value.success(minecraft:test,100)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a changed value sends UPDATE_PROGRESS" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001023f000000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar set name for the players" TO TL-CASE
     MOVE "bossbar set test name ""Third""" TO WS-LINE
     MOVE "commands.bossbar.set.name.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a changed name sends UPDATE_NAME" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001030a080004746578740005546869726400" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar set style for the players" TO TL-CASE
     MOVE "bossbar set test style notched_12" TO WS-LINE
     MOVE "commands.bossbar.set.style.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a changed style sends UPDATE_STYLE" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001040203" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar set max for the players" TO TL-CASE
     MOVE "bossbar set test max 400" TO WS-LINE
     MOVE "commands.bossbar.set.max.success(minecraft:test,400)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a changed max sends UPDATE_PROGRESS" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001023e800000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar set color for the players" TO TL-CASE
     MOVE "bossbar set test color green" TO WS-LINE
     MOVE "commands.bossbar.set.color.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a changed color sends UPDATE_STYLE" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "00000000000000000000000000000001040303" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar hide the bar of the players" TO TL-CASE
     MOVE "bossbar set test visible false" TO WS-LINE
     MOVE "commands.bossbar.set.visible.success.hidden(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar hiding the bar sends REMOVE" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "0000000000000000000000000000000101" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar show the bar again" TO TL-CASE
     MOVE "bossbar set test visible true" TO WS-LINE
     MOVE "commands.bossbar.set.visible.success.visible(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /bossbar the ADD of the shown bar is drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /bossbar no players" TO TL-CASE
     MOVE "bossbar set test players" TO WS-LINE
     MOVE "commands.bossbar.set.players.success.none(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a player leaving the bar is sent REMOVE" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "0000000000000000000000000000000101" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar no players again" TO TL-CASE
     MOVE "bossbar set test players" TO WS-LINE
     MOVE "commands.bossbar.set.players.unchanged()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar every player" TO TL-CASE
     MOVE "bossbar set test players @a" TO WS-LINE
     MOVE "commands.bossbar.set.players.success.some(minecraft:test,3,Opal, Alice, Bob)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get players of every player" TO TL-CASE
     MOVE "bossbar get test players" TO WS-LINE
     MOVE "commands.bossbar.get.players.some(minecraft:test,3,Opal, Alice, Bob)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /bossbar the ADD is drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /bossbar a player who stays on the bar and two who leave" TO TL-CASE
     MOVE "bossbar set test players Alice" TO WS-LINE
     MOVE "commands.bossbar.set.players.success.some(minecraft:test,1,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar the player who stays is sent nothing" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-ALICE TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /bossbar the player who left is sent REMOVE (after the ADD)" TO TL-CASE
     MOVE "9x2" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-BOB TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /bossbar remove" TO TL-CASE
     MOVE "bossbar remove test" TO WS-LINE
     MOVE "commands.bossbar.remove.success(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar removing the bar sends REMOVE to its players" TO TL-CASE
     MOVE 9 TO WS-WANTED
     MOVE "0000000000000000000000000000000101" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /bossbar remove an unknown bar" TO TL-CASE
     MOVE "bossbar remove test" TO WS-LINE
     MOVE "commands.bossbar.unknown(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar get of an unknown bar" TO TL-CASE
     MOVE "bossbar get test value" TO WS-LINE
     MOVE "commands.bossbar.unknown(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar set of an unknown bar" TO TL-CASE
     MOVE "bossbar set test value 1" TO WS-LINE
     MOVE "commands.bossbar.unknown(minecraft:test)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar remove result is the number of bars left" TO TL-CASE
     MOVE "bossbar remove other" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /bossbar the console prints the list" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE "There are no custom bossbars active" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 1" TO TL-CASE
     MOVE "bossbar add b1 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 2" TO TL-CASE
     MOVE "bossbar add b2 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b2)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 3" TO TL-CASE
     MOVE "bossbar add b3 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 4" TO TL-CASE
     MOVE "bossbar add b4 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b4)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 5" TO TL-CASE
     MOVE "bossbar add b5 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 6" TO TL-CASE
     MOVE "bossbar add b6 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b6)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 7" TO TL-CASE
     MOVE "bossbar add b7 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b7)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 8" TO TL-CASE
     MOVE "bossbar add b8 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b8)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 9" TO TL-CASE
     MOVE "bossbar add b9 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b9)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 10" TO TL-CASE
     MOVE "bossbar add b10 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b10)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 11" TO TL-CASE
     MOVE "bossbar add b11 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b11)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 12" TO TL-CASE
     MOVE "bossbar add b12 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b12)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 13" TO TL-CASE
     MOVE "bossbar add b13 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b13)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 14" TO TL-CASE
     MOVE "bossbar add b14 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b14)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 15" TO TL-CASE
     MOVE "bossbar add b15 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b15)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar fill the table: bar 16" TO TL-CASE
     MOVE "bossbar add b16 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b16)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a full table" TO TL-CASE
     MOVE "bossbar add b17 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.failed(minecraft:b17)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a removed slot is free again" TO TL-CASE
     MOVE "bossbar remove b3" TO WS-LINE
     MOVE "commands.bossbar.remove.success(minecraft:b3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar the freed slot is used" TO TL-CASE
     MOVE "bossbar add b17 ""x""" TO WS-LINE
     MOVE "commands.bossbar.create.success(minecraft:b17)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /bossbar a player without permission level 2 does not know it" TO TL-CASE
     MOVE "bossbar list" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-BOSSBAR.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
