*> Acceptance test of docs/protocol/16-commands-catalog.md §4.9 `tick` (permission level 3) and §14a: query (state line, rate line, percentiles; not broadcast), rate <1..10000>, step [<ticks> | stop], sprint <ticks> | stop, freeze, unfreeze.
*> Ticking State (0x82: rate float, frozen) and Ticking Step (0x83: ticks) go to every player. No tick is measured here: the average, the percentiles and the sample count are 0.0 and 0 (the tick loop does not read the state yet).
*> Results: rate and query the rate as an integer; step, sprint and their stops 1; freeze 1, unfreeze 0. Opal and Olga hold level 4, Alice none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL        BINARY-LONG.
 01 WS-ID-OLGA        BINARY-LONG.
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
     MOVE "Olga" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OLGA
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tick query at the default rate" TO TL-CASE
     MOVE "tick query" TO WS-LINE
     MOVE "commands.tick.status.running() | commands.tick.query.rate.running(20.0,0.0,50.0) | command" & "s.tick.query.percentiles(0.0,0.0,0.0,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick query result is the rate 20" TO TL-CASE
     MOVE "tick query" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     MOVE "acceptance US13 /tick query is quiet" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tick rate 10" TO TL-CASE
     MOVE "tick rate 10" TO WS-LINE
     MOVE "commands.tick.rate.success(10.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     MOVE "acceptance US13 /tick rate is broadcast to the other operators" TO TL-CASE
     MOVE "chat.type.admin(Opal,Set the target tick rate to 10.0 per second)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tick rate sends Ticking State to every player" TO TL-CASE
     MOVE "130" TO WS-EXPECTED
     CALL "TA-CHECK-IDS" USING WS-ID-ALICE TL-CASE WS-EXPECTED
     MOVE "acceptance US13 /tick query at rate 10" TO TL-CASE
     MOVE "tick query" TO WS-LINE
     MOVE "commands.tick.status.running() | commands.tick.query.rate.running(10.0,0.0,100.0) | comman" & "ds.tick.query.percentiles(0.0,0.0,0.0,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick rate result is the rate" TO TL-CASE
     MOVE "tick rate 20" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick rate below 1" TO TL-CASE
     MOVE "tick rate 0.5" TO WS-LINE
     MOVE "argument.float.low(1.0,0.5) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick rate above 10000" TO TL-CASE
     MOVE "tick rate 10001" TO WS-LINE
     MOVE "argument.float.big(10000.0,10001.0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step when the game is not frozen" TO TL-CASE
     MOVE "tick step" TO WS-LINE
     MOVE "commands.tick.step.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step stop with no step in progress" TO TL-CASE
     MOVE "tick step stop" TO WS-LINE
     MOVE "commands.tick.step.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick sprint stop with no sprint in progress" TO TL-CASE
     MOVE "tick sprint stop" TO WS-LINE
     MOVE "commands.tick.sprint.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE "acceptance US13 /tick the packets of the rate commands are drained" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /tick freeze" TO TL-CASE
     MOVE "tick freeze" TO WS-LINE
     MOVE "commands.tick.status.frozen()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick freeze sends Ticking State: rate 20.0 frozen" TO TL-CASE
     MOVE 130 TO WS-WANTED
     MOVE "41a0000001" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /tick query while frozen" TO TL-CASE
     MOVE "tick query" TO WS-LINE
     MOVE "commands.tick.status.frozen() | commands.tick.query.rate.running(20.0,0.0,50.0) | commands" & ".tick.query.percentiles(0.0,0.0,0.0,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step one tick" TO TL-CASE
     MOVE "tick step" TO WS-LINE
     MOVE "commands.tick.step.success(1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step sends Ticking Step 1" TO TL-CASE
     MOVE 131 TO WS-WANTED
     MOVE "01" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /tick step several ticks" TO TL-CASE
     MOVE "tick step 5" TO WS-LINE
     MOVE "commands.tick.step.success(5)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step 5 sends Ticking Step 5" TO TL-CASE
     MOVE 131 TO WS-WANTED
     MOVE "05" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /tick step stop result 1" TO TL-CASE
     MOVE "tick step stop" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick step again for the stop message" TO TL-CASE
     MOVE "tick step 3" TO WS-LINE
     MOVE "commands.tick.step.success(3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step stop" TO TL-CASE
     MOVE "tick step stop" TO WS-LINE
     MOVE "commands.tick.step.stop.success()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step stop twice" TO TL-CASE
     MOVE "tick step stop" TO WS-LINE
     MOVE "commands.tick.step.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick step result 1" TO TL-CASE
     MOVE "tick step 2" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick step 0 is below the minimum" TO TL-CASE
     MOVE "tick step 0" TO WS-LINE
     MOVE "argument.time.tick_count_too_low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick unfreeze ends the step in progress" TO TL-CASE
     MOVE "tick unfreeze" TO WS-LINE
     MOVE "commands.tick.status.running()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick the step ended with the unfreeze" TO TL-CASE
     MOVE "tick step stop" TO WS-LINE
     MOVE "commands.tick.step.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick unfreeze sends Ticking State: not frozen" TO TL-CASE
     MOVE 130 TO WS-WANTED
     MOVE "41a0000000" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /tick sprint" TO TL-CASE
     MOVE "tick sprint 100" TO WS-LINE
     MOVE "commands.tick.status.sprinting()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick query while sprinting" TO TL-CASE
     MOVE "tick query" TO WS-LINE
     MOVE "commands.tick.status.sprinting() | commands.tick.query.rate.sprinting(20.0,0.0) | commands" & ".tick.query.percentiles(0.0,0.0,0.0,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick sprint stop" TO TL-CASE
     MOVE "tick sprint stop" TO WS-LINE
     MOVE "commands.tick.sprint.stop.success()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick sprint stop twice" TO TL-CASE
     MOVE "tick sprint stop" TO WS-LINE
     MOVE "commands.tick.sprint.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick sprint result 1" TO TL-CASE
     MOVE "tick sprint 10" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick freeze ends the sprint" TO TL-CASE
     MOVE "tick freeze" TO WS-LINE
     MOVE "commands.tick.status.frozen()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick the sprint ended with the freeze" TO TL-CASE
     MOVE "tick sprint stop" TO WS-LINE
     MOVE "commands.tick.sprint.stop.fail()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick unfreeze result 0" TO TL-CASE
     MOVE "tick unfreeze" TO WS-LINE
     MOVE 0 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick freeze result 1" TO TL-CASE
     MOVE "tick freeze" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /tick a player without permission level 3 does not know it" TO TL-CASE
     MOVE "tick freeze" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /tick the console prints the state line" TO TL-CASE
     MOVE "tick unfreeze" TO WS-LINE
     MOVE "The game is running normally" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-TICK.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
