*> Acceptance test of the forms that the command tree holds from the listings of docs/protocol/57-client-closures-4 section 7 and the core does not run (BR-DOC-FILL, core/src/cmd-tree-doc.cob; T2014):
*> a form that parses to an executable node of the listing reports cobolcraft.command.unsupported with the first word of its context and has no other effect, a clause of execute
*> that the core does not run (store, if biome, ...) fails the same way before any later clause runs, and the forms the core does run keep their behaviour next to them. Opal holds
*> operator status (level 4), Alice does not (the unknown command).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-UNSUPPORTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-DISCARD             PIC X(4096).
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
     MOVE "acceptance US13 unsupported time of <clock> pause is a listed form the core does not run" TO TL-CASE
     MOVE "time of minecraft:overworld pause" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(time of pause)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported time query <timeline> repetition is a listed form the core does not run" TO TL-CASE
     MOVE "time query day repetition" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(time query repetition)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported random reset * is the reset branch of the listing" TO TL-CASE
     MOVE "random reset *" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(random reset *)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported random reset <sequence> <seed> is the reset branch of the listing" TO TL-CASE
     MOVE "random reset test:s 5 true false" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(random reset)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported test clearall is built from the listing and not run" TO TL-CASE
     MOVE "test clearall" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(test clearall)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported test run <tests> with its arguments is built from the listing and not run" TO TL-CASE
     MOVE "test run minecraft:all 3 true 1 4" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(test run)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported test create has its own width, height and depth arguments" TO TL-CASE
     MOVE "test create test:box 3 4 5" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(test create)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported test is level 2: a player below it does not know the command" TO TL-CASE
     MOVE "test stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported swing with no target is the form of the listing that swings the executing entity" TO TL-CASE
     MOVE "swing" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(swing)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 swing of the targets without a hand is a form the core runs" TO TL-CASE
     MOVE "swing Alice" TO WS-LINE
     MOVE "commands.swing.success.single(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported dialog show is a listed form the core does not run" TO TL-CASE
     MOVE "dialog show Alice test:d" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(dialog show)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported debug function <name> is a listed form the core does not run" TO TL-CASE
     MOVE "debug function test:f" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(debug function)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 unsupported data modify ... compute is a listed source the core does not run" TO TL-CASE
     MOVE "data modify storage test:s a set compute default integer test:i" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(data modify storage set compute default integer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 execute store result score is a clause the core does not run: it fails before the command after run" TO TL-CASE
     MOVE "execute store result score Alice obj run say hi" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(execute store result score)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 execute if biome as the last clause is a condition the core does not run" TO TL-CASE
     MOVE "execute if biome 0 64 0 minecraft:plains" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(execute if biome)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 execute if score before run fails at the clause the core does not run" TO TL-CASE
     MOVE "execute if score Alice obj = Alice obj run say hi" TO WS-LINE
     MOVE "cobolcraft.command.unsupported(execute if score =)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 execute as ... run keeps working next to the unsupported clauses" TO TL-CASE
     MOVE "execute as Alice run say hi" TO WS-LINE
     MOVE "chat.type.announcement(Alice,hi)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-UNSUPPORTED.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
