*> Acceptance test of docs/protocol/16-commands-catalog.md §4.11 `worldborder` (permission level 2) and §14a with 33 §7: get, set <size> [<time>], add <size> [<time>], center <x z>, damage amount | buffer, warning distance | time. The border belongs to the
*> executing level (cobolcraft:main here); defaults 33 §7.1 (size 59999968, centre 0 0, damage 0.2, buffer 5, warning 5 blocks and 300 ticks). Packets to the players of the level: Set Border Center 0x5A, Lerp Size 0x5B, Size 0x5C, Warning Delay 0x5D, Warning
*> Distance 0x5E (bodies computed apart: doubles big endian, the lerp time in milliseconds = ticks * 50 as a VarLong). A timed change moves with BB-TICK (not yet called by the tick loop: the test calls it). The time argument counts ticks without a unit
*> (10s = 200 ticks); the worked example of 15 ("set 100 10" shows 10.00 seconds) disagrees with the rules of 4.11 (ticks): the rules are followed. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-WORLDBORDER.
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
     MOVE "acceptance US13 /worldborder get at the default size" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "commands.worldborder.get(59999968.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder get result is the size rounded" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE 59999968 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /worldborder the join packets are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /worldborder set 200" TO TL-CASE
     MOVE "worldborder set 200" TO WS-LINE
     MOVE "commands.worldborder.set.immediate(200.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set sends Set Border Size 200.0" TO TL-CASE
     MOVE 92 TO WS-WANTED
     MOVE "4069000000000000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /worldborder set the same size" TO TL-CASE
     MOVE "worldborder set 200" TO WS-LINE
     MOVE "commands.worldborder.set.failed.nochange()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set 0.5 is smaller than 1" TO TL-CASE
     MOVE "worldborder set 0.5" TO WS-LINE
     MOVE "commands.worldborder.set.failed.small()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set result is the change of the size" TO TL-CASE
     MOVE "worldborder set 250" TO WS-LINE
     MOVE 50 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder get after the set" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE 250 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder add beyond the maximum" TO TL-CASE
     MOVE "worldborder add 59999968" TO WS-LINE
     MOVE "commands.worldborder.set.failed.big(59999968)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set a distance above the range of the argument" TO TL-CASE
     MOVE "worldborder set 60000000" TO WS-LINE
     MOVE "argument.double.big(5.9999968E7,6.0E7) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set 200 again" TO TL-CASE
     MOVE "worldborder set 200" TO WS-LINE
     MOVE "commands.worldborder.set.immediate(200.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /worldborder the earlier packets are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /worldborder set 100 over 10 seconds shrinks" TO TL-CASE
     MOVE "worldborder set 100 10s" TO WS-LINE
     MOVE "commands.worldborder.set.shrink(100.0,10.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder a timed set sends Set Border Lerp Size" TO TL-CASE
     MOVE 91 TO WS-WANTED
     MOVE "40690000000000004059000000000000904e" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /worldborder the size has not moved before the ticks" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "commands.worldborder.get(200.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     PERFORM 100 TIMES CALL "BB-TICK" END-PERFORM
     MOVE "acceptance US13 /worldborder half way after 100 of 200 ticks" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "commands.worldborder.get(150.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     PERFORM 100 TIMES CALL "BB-TICK" END-PERFORM
     MOVE "acceptance US13 /worldborder arrived after 200 ticks" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "commands.worldborder.get(100.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "BB-TICK"
     MOVE "acceptance US13 /worldborder a finished change stays at the target" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE 100 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder set the current size" TO TL-CASE
     MOVE "worldborder set 100" TO WS-LINE
     MOVE "commands.worldborder.set.failed.nochange()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder add 50" TO TL-CASE
     MOVE "worldborder add 50" TO WS-LINE
     MOVE "commands.worldborder.set.immediate(150.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder add with a time grows and returns the change" TO TL-CASE
     MOVE "worldborder add 25 20" TO WS-LINE
     MOVE 25 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder add while moving: the target plus the distance, the remaining" & " time plus the time" TO TL-CASE
     MOVE "worldborder add 25 20" TO WS-LINE
     MOVE "commands.worldborder.set.grow(200.0,2.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder set 100 in one tick" TO TL-CASE
     MOVE "worldborder set 100 1" TO WS-LINE
     MOVE "commands.worldborder.set.shrink(100.0,0.05)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder an immediate set ends the move" TO TL-CASE
     MOVE "worldborder set 160" TO WS-LINE
     MOVE "commands.worldborder.set.immediate(160.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /worldborder the earlier packets are drained again" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /worldborder center" TO TL-CASE
     MOVE "worldborder center 100 200" TO WS-LINE
     MOVE "commands.worldborder.center.success(100.0,200.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center sends Set Border Center" TO TL-CASE
     MOVE 90 TO WS-WANTED
     MOVE "40590000000000004069000000000000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /worldborder center result 0" TO TL-CASE
     MOVE "worldborder center 0 0" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder center the same place" TO TL-CASE
     MOVE "worldborder center 0 0" TO WS-LINE
     MOVE "commands.worldborder.center.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center too far in x" TO TL-CASE
     MOVE "worldborder center 30000000 0" TO WS-LINE
     MOVE "commands.worldborder.set.failed.far(29999984)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center too far in x (negative)" TO TL-CASE
     MOVE "worldborder center -30000000 0" TO WS-LINE
     MOVE "commands.worldborder.set.failed.far(29999984)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center too far in z (positive)" TO TL-CASE
     MOVE "worldborder center 0 29999985" TO WS-LINE
     MOVE "commands.worldborder.set.failed.far(29999984)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center too far in z" TO TL-CASE
     MOVE "worldborder center 0 -29999985" TO WS-LINE
     MOVE "commands.worldborder.set.failed.far(29999984)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center at the limit" TO TL-CASE
     MOVE "worldborder center 29999984 -29999984" TO WS-LINE
     MOVE "commands.worldborder.center.success(2.9999984E7,-2.9999984E7)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder a player to stand somewhere" TO TL-CASE
     MOVE "teleport Opal 10.5 70 20.5" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder center relative to the player" TO TL-CASE
     MOVE "worldborder center ~ ~" TO WS-LINE
     MOVE "commands.worldborder.center.success(10.5,20.5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder center relative with an offset" TO TL-CASE
     MOVE "worldborder center ~1 ~-0.5" TO WS-LINE
     MOVE "commands.worldborder.center.success(11.5,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage buffer at the default" TO TL-CASE
     MOVE "worldborder damage buffer 5" TO WS-LINE
     MOVE "commands.worldborder.damage.buffer.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage buffer" TO TL-CASE
     MOVE "worldborder damage buffer 7.5" TO WS-LINE
     MOVE "commands.worldborder.damage.buffer.success(7.5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage buffer result is the integer part" TO TL-CASE
     MOVE "worldborder damage buffer 9.5" TO WS-LINE
     MOVE 9 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder damage buffer negative" TO TL-CASE
     MOVE "worldborder damage buffer -1" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage amount" TO TL-CASE
     MOVE "worldborder damage amount 0.5" TO WS-LINE
     MOVE "commands.worldborder.damage.amount.success(0.5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage amount the same" TO TL-CASE
     MOVE "worldborder damage amount 0.5" TO WS-LINE
     MOVE "commands.worldborder.damage.amount.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder damage amount result is the integer part" TO TL-CASE
     MOVE "worldborder damage amount 3.5" TO WS-LINE
     MOVE 3 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder damage amount negative" TO TL-CASE
     MOVE "worldborder damage amount -1" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning time at the default" TO TL-CASE
     MOVE "worldborder warning time 300" TO WS-LINE
     MOVE "commands.worldborder.warning.time.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning distance at the default" TO TL-CASE
     MOVE "worldborder warning distance 5" TO WS-LINE
     MOVE "commands.worldborder.warning.distance.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /worldborder the earlier packets are drained once more" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /worldborder warning time 600 ticks is 30 seconds" TO TL-CASE
     MOVE "worldborder warning time 600" TO WS-LINE
     MOVE "commands.worldborder.warning.time.success(30.00)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning time sends Set Border Warning Delay 600" TO TL-CASE
     MOVE 93 TO WS-WANTED
     MOVE "d804" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning time result is the argument" TO TL-CASE
     MOVE "worldborder warning time 20" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder warning time the same" TO TL-CASE
     MOVE "worldborder warning time 20" TO WS-LINE
     MOVE "commands.worldborder.warning.time.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning distance 10" TO TL-CASE
     MOVE "worldborder warning distance 10" TO WS-LINE
     MOVE "commands.worldborder.warning.distance.success(10)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning distance sends Set Border Warning Distance 10" TO TL-CASE
     MOVE 94 TO WS-WANTED
     MOVE "0a" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning distance result is the argument" TO TL-CASE
     MOVE "worldborder warning distance 12" TO WS-LINE
     MOVE 12 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /worldborder warning distance the same" TO TL-CASE
     MOVE "worldborder warning distance 12" TO WS-LINE
     MOVE "commands.worldborder.warning.distance.failed()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder warning distance negative" TO TL-CASE
     MOVE "worldborder warning distance -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder a player without permission level 2 does not know it" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /worldborder the console reads the border of the main level" TO TL-CASE
     MOVE "worldborder get" TO WS-LINE
     MOVE "The world border is currently 160.0 block(s) wide" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-WORLDBORDER.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
