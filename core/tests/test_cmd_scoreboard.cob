*> Acceptance test of docs/protocol/16-commands-catalog.md §9.1 `scoreboard` (permission level 2) with 14a: objectives list|add|remove|setdisplay|modify and players
*> list|set|get|add|remove|reset|enable|operation|display (in-memory state, not saved; the packets that follow score changes are not sent). Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SCOREBOARD.
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
    MOVE "acceptance US13 /scoreboard objectives list with none" TO TL-CASE
    MOVE "scoreboard objectives list" TO WS-LINE
    MOVE "commands.scoreboard.objectives.list.empty()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives add" TO TL-CASE
    MOVE "scoreboard objectives add kills dummy" TO WS-LINE
    MOVE "commands.scoreboard.objectives.add.success(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives add twice" TO TL-CASE
    MOVE "scoreboard objectives add kills dummy" TO WS-LINE
    MOVE "commands.scoreboard.objectives.add.duplicate()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives add with a display name" TO TL-CASE
    MOVE "scoreboard objectives add pts dummy ""Points""" TO WS-LINE
    MOVE "commands.scoreboard.objectives.add.success(pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives add a trigger objective" TO TL-CASE
    MOVE "scoreboard objectives add trig trigger" TO WS-LINE
    MOVE "commands.scoreboard.objectives.add.success(trig)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives list" TO TL-CASE
    MOVE "scoreboard objectives list" TO WS-LINE
    MOVE "commands.scoreboard.objectives.list.success(3,kills, pts, trig)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives list result is the count" TO TL-CASE
    MOVE "scoreboard objectives list" TO WS-LINE
    MOVE 3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard objectives add result is the count afterwards" TO TL-CASE
    MOVE "scoreboard objectives add res dummy" TO WS-LINE
    MOVE 4 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard objectives setdisplay" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar kills" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.set(sidebar,kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay again is already set" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar kills" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.alreadySet()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay another objective replaces" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar pts" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.set(sidebar,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay a team slot" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar.team.red kills" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.set(sidebar.team.red,kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay without an objective clears" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.cleared(sidebar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay clearing an empty slot" TO TL-CASE
    MOVE "scoreboard objectives setdisplay sidebar" TO WS-LINE
    MOVE "commands.scoreboard.objectives.display.alreadyEmpty()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay an unknown objective" TO TL-CASE
    MOVE "scoreboard objectives setdisplay list zzz" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives setdisplay a bad slot" TO TL-CASE
    MOVE "scoreboard objectives setdisplay nowhere kills" TO WS-LINE
    MOVE "argument.scoreboardDisplaySlot.invalid(nowhere) |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify displayname" TO TL-CASE
    MOVE "scoreboard objectives modify kills displayname ""Kill Count""" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.displayname(kills,Kill Count)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify rendertype hearts" TO TL-CASE
    MOVE "scoreboard objectives modify kills rendertype hearts" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.rendertype(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify rendertype integer" TO TL-CASE
    MOVE "scoreboard objectives modify kills rendertype integer" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.rendertype(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify displayautoupdate true" TO TL-CASE
    MOVE "scoreboard objectives modify kills displayautoupdate true" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.displayAutoUpdate.enable(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify displayautoupdate false" TO TL-CASE
    MOVE "scoreboard objectives modify kills displayautoupdate false" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.displayAutoUpdate.disable(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify numberformat blank" TO TL-CASE
    MOVE "scoreboard objectives modify kills numberformat blank" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.objectiveFormat.set(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify numberformat fixed" TO TL-CASE
    MOVE "scoreboard objectives modify kills numberformat fixed ""x""" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.objectiveFormat.set(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify numberformat styled" TO TL-CASE
    MOVE "scoreboard objectives modify kills numberformat styled {color:""red""}" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.objectiveFormat.set(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify numberformat cleared" TO TL-CASE
    MOVE "scoreboard objectives modify kills numberformat" TO WS-LINE
    MOVE "commands.scoreboard.objectives.modify.objectiveFormat.clear(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify an unknown objective" TO TL-CASE
    MOVE "scoreboard objectives modify zzz rendertype hearts" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives modify result is 0" TO TL-CASE
    MOVE "scoreboard objectives modify kills rendertype hearts" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard players list with no scores" TO TL-CASE
    MOVE "scoreboard players list" TO WS-LINE
    MOVE "commands.scoreboard.players.list.empty()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set one" TO TL-CASE
    MOVE "scoreboard players set Alice pts 5" TO WS-LINE
    MOVE "commands.scoreboard.players.set.success.single(pts,Alice,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set several" TO TL-CASE
    MOVE "scoreboard players set @a pts 3" TO WS-LINE
    MOVE "commands.scoreboard.players.set.success.multiple(pts,2,3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players get" TO TL-CASE
    MOVE "scoreboard players get Alice pts" TO WS-LINE
    MOVE "commands.scoreboard.players.get.success(Alice,3,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players get without a score" TO TL-CASE
    MOVE "scoreboard players get Zed pts" TO WS-LINE
    MOVE "commands.scoreboard.players.get.null(pts,Zed)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players get an unknown objective" TO TL-CASE
    MOVE "scoreboard players get Alice zzz" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players get result is the score" TO TL-CASE
    MOVE "scoreboard players get Alice pts" TO WS-LINE
    MOVE 3 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard players add one" TO TL-CASE
    MOVE "scoreboard players add Alice pts 2" TO WS-LINE
    MOVE "commands.scoreboard.players.add.success.single(2,pts,Alice,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players add several" TO TL-CASE
    MOVE "scoreboard players add @a pts 1" TO WS-LINE
    MOVE "commands.scoreboard.players.add.success.multiple(1,pts,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players remove one" TO TL-CASE
    MOVE "scoreboard players remove Alice pts 4" TO WS-LINE
    MOVE "commands.scoreboard.players.remove.success.single(4,pts,Alice,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players remove several" TO TL-CASE
    MOVE "scoreboard players remove @a pts 1" TO WS-LINE
    MOVE "commands.scoreboard.players.remove.success.multiple(1,pts,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice kills 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players list tracked holders" TO TL-CASE
    MOVE "scoreboard players list" TO WS-LINE
    MOVE "commands.scoreboard.players.list.success(2,Alice, Opal)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players list result is the number of holders" TO TL-CASE
    MOVE "scoreboard players list" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard players list one holder" TO TL-CASE
    MOVE "scoreboard players list Alice" TO WS-LINE
    MOVE "commands.scoreboard.players.list.entity.success(Alice,2) | commands.scoreboard.players.lis" & "t.entity.entry(pts,1) | commands.scoreboard.players.list.entity.entry(kills,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players list a holder without scores" TO TL-CASE
    MOVE "scoreboard players list Zed" TO WS-LINE
    MOVE "commands.scoreboard.players.list.entity.empty(Zed)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice pts 2147483647" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players add wraps like a Java int" TO TL-CASE
    MOVE "scoreboard players add Alice pts 1" TO WS-LINE
    MOVE "commands.scoreboard.players.add.success.single(1,pts,Alice,-2147483648)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set result is the sum of the scores set" TO TL-CASE
    MOVE "scoreboard players set Alice pts 5" TO WS-LINE
    MOVE 5 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard players add result is the new score" TO TL-CASE
    MOVE "scoreboard players add Alice pts 5" TO WS-LINE
    MOVE 10 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "scoreboard players set Alice pts 7" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard players set Opal pts 3" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation adds" TO TL-CASE
    MOVE "scoreboard players operation Alice pts += Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,10)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation subtracts" TO TL-CASE
    MOVE "scoreboard players operation Alice pts -= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,7)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation multiplies" TO TL-CASE
    MOVE "scoreboard players operation Alice pts *= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,21)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation divides" TO TL-CASE
    MOVE "scoreboard players operation Alice pts /= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,7)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation takes the remainder" TO TL-CASE
    MOVE "scoreboard players operation Alice pts %= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation assigns" TO TL-CASE
    MOVE "scoreboard players operation Alice pts = Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice pts 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation < takes the smaller" TO TL-CASE
    MOVE "scoreboard players operation Alice pts < Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,1)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation > takes the larger" TO TL-CASE
    MOVE "scoreboard players operation Alice pts > Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Opal pts 9" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation >< swaps" TO TL-CASE
    MOVE "scoreboard players operation Alice pts >< Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,9)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation >< gave Opal the other value" TO TL-CASE
    MOVE "scoreboard players get Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.get.success(Opal,3,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice pts -7" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation /= floors a negative quotient" TO TL-CASE
    MOVE "scoreboard players operation Alice pts /= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,-3)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice pts -7" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation %= has the sign of the divisor" TO TL-CASE
    MOVE "scoreboard players operation Alice pts %= Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.single(pts,Alice,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Opal pts 0" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players operation /= by zero" TO TL-CASE
    MOVE "scoreboard players operation Alice pts /= Opal pts" TO WS-LINE
    MOVE "arguments.operation.div0()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation %= by zero" TO TL-CASE
    MOVE "scoreboard players operation Alice pts %= Opal pts" TO WS-LINE
    MOVE "arguments.operation.div0()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation over several holders" TO TL-CASE
    MOVE "scoreboard players operation @a pts += Opal pts" TO WS-LINE
    MOVE "commands.scoreboard.players.operation.success.multiple(pts,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players operation result is the sum of the scores" TO TL-CASE
    MOVE "scoreboard players operation @a pts += Opal pts" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard players reset one score" TO TL-CASE
    MOVE "scoreboard players reset Alice pts" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.specific.single(pts,Alice)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players reset one score of several" TO TL-CASE
    MOVE "scoreboard players reset @a pts" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.specific.multiple(pts,2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice pts 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard players set Opal pts 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard players set Alice kills 4" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players reset all scores of one" TO TL-CASE
    MOVE "scoreboard players reset Alice" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.all.single(Alice)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players reset all scores of several" TO TL-CASE
    MOVE "scoreboard players reset @a" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.all.multiple(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice kills 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard players set Alice pts 1" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players reset * resets every tracked holder" TO TL-CASE
    MOVE "scoreboard players reset *" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.all.single(Alice)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players reset * with none tracked" TO TL-CASE
    MOVE "scoreboard players reset *" TO WS-LINE
    MOVE "argument.scoreHolder.empty()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players enable on a non-trigger objective" TO TL-CASE
    MOVE "scoreboard players enable Alice pts" TO WS-LINE
    MOVE "commands.scoreboard.players.enable.invalid()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players enable" TO TL-CASE
    MOVE "scoreboard players enable Alice trig" TO WS-LINE
    MOVE "commands.scoreboard.players.enable.success.single(trig,Alice)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players enable twice changes nothing" TO TL-CASE
    MOVE "scoreboard players enable Alice trig" TO WS-LINE
    MOVE "commands.scoreboard.players.enable.failed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players enable several changes only the new" TO TL-CASE
    MOVE "scoreboard players enable @a trig" TO WS-LINE
    MOVE "commands.scoreboard.players.enable.success.single(trig,Opal)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players reset *" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard players enable @a trig" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard players enable several" TO TL-CASE
    MOVE "scoreboard players reset *" TO WS-LINE
    MOVE "commands.scoreboard.players.reset.all.multiple(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display name set" TO TL-CASE
    MOVE "scoreboard players display name Alice pts ""Al""" TO WS-LINE
    MOVE "commands.scoreboard.players.display.name.set.success.single(Al,Alice,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display name set several" TO TL-CASE
    MOVE "scoreboard players display name @a pts ""Al""" TO WS-LINE
    MOVE "commands.scoreboard.players.display.name.set.success.multiple(Al,2,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display name cleared" TO TL-CASE
    MOVE "scoreboard players display name Alice pts" TO WS-LINE
    MOVE "commands.scoreboard.players.display.name.clear.success.single(Alice,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display name cleared several" TO TL-CASE
    MOVE "scoreboard players display name @a pts" TO WS-LINE
    MOVE "commands.scoreboard.players.display.name.clear.success.multiple(2,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display numberformat blank" TO TL-CASE
    MOVE "scoreboard players display numberformat Alice pts blank" TO WS-LINE
    MOVE "commands.scoreboard.players.display.numberFormat.set.success.single(Alice,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display numberformat fixed" TO TL-CASE
    MOVE "scoreboard players display numberformat Alice pts fixed ""x""" TO WS-LINE
    MOVE "commands.scoreboard.players.display.numberFormat.set.success.single(Alice,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display numberformat styled several" TO TL-CASE
    MOVE "scoreboard players display numberformat @a pts styled {color:""red""}" TO WS-LINE
    MOVE "commands.scoreboard.players.display.numberFormat.set.success.multiple(2,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display numberformat cleared" TO TL-CASE
    MOVE "scoreboard players display numberformat Alice pts" TO WS-LINE
    MOVE "commands.scoreboard.players.display.numberFormat.clear.success.single(Alice,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players display numberformat cleared several" TO TL-CASE
    MOVE "scoreboard players display numberformat @a pts" TO WS-LINE
    MOVE "commands.scoreboard.players.display.numberFormat.clear.success.multiple(2,pts)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set an unknown objective" TO TL-CASE
    MOVE "scoreboard players set Alice zzz 1" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set a selector that finds nobody" TO TL-CASE
    MOVE "scoreboard players set @a[name=Nobody] pts 1" TO WS-LINE
    MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE 0 TO WS-J
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
        IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND FUNCTION ABS(EN-X(WS-I) - 5.0) < 0.01 AND FUNCTION ABS(EN-Z(WS-I) - 5.0) < 0.01
            MOVE WS-I TO WS-J
        END-IF
    END-PERFORM
    CALL "PERSIST-UUID-TEXT" USING EN-UUID(WS-J) WS-UUID-TEXT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.scoreboard.players.set.success.single(pts," DELIMITED BY SIZE WS-UUID-TEXT DELIMITED BY SIZE ",9)" DELIMITED BY SIZE
        INTO WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players set a mob: its holder name is its UUID" TO TL-CASE
    MOVE "scoreboard players set @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] pts 9" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players list" TO WS-LINE
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.scoreboard.players.list.success(3,Alice, Opal, " DELIMITED BY SIZE WS-UUID-TEXT DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /scoreboard players list names a mob holder by its UUID" TO TL-CASE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players set Alice kills 6" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /scoreboard objectives remove" TO TL-CASE
    MOVE "scoreboard objectives remove kills" TO WS-LINE
    MOVE "commands.scoreboard.objectives.remove.success(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives remove drops its scores" TO TL-CASE
    MOVE "scoreboard players get Alice kills" TO WS-LINE
    MOVE "arguments.objective.notFound(kills)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard objectives remove result is the count afterwards" TO TL-CASE
    MOVE "scoreboard objectives remove res" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /scoreboard objectives remove an unknown objective" TO TL-CASE
    MOVE "scoreboard objectives remove zzz" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /scoreboard a player below level 2 cannot run it" TO TL-CASE
    MOVE "scoreboard objectives list" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-SCOREBOARD.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
