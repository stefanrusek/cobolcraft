*> Acceptance test of docs/protocol/16-commands-catalog.md §10.2 `execute` (permission level 2) over the modifier chain of 15a §4.3: run, as, at, positioned (and as), rotated (and as), facing
*> (and entity), align, anchored, in and if|unless with entity, dimension, block and loaded; a fork gives one source for each target, the result of a forked chain is the number of successful
*> runs, a failing condition drops the source, a condition as the last clause is Test passed or Test failed. BLOCKED: positioned over, summon, on, store and the other conditions, and
*> entities that are not players as the executing entity. Opal holds operator status and stands at 0 64 0, Alice at 10 64 0, Bob at 20 64 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-EXECUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY CBLOCKS.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-ONE-RESULT          BINARY-DOUBLE.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE 0 TO PL-X(CN-PLAYER(WS-ID-OPAL))
     MOVE 64 TO PL-Y(CN-PLAYER(WS-ID-OPAL))
     MOVE 0 TO PL-Z(CN-PLAYER(WS-ID-OPAL))
     MOVE 0 TO PL-YAW(CN-PLAYER(WS-ID-OPAL))
     MOVE 0 TO PL-PITCH(CN-PLAYER(WS-ID-OPAL))
     MOVE 10 TO PL-X(CN-PLAYER(WS-ID-ALICE))
     MOVE 64 TO PL-Y(CN-PLAYER(WS-ID-ALICE))
     MOVE 0 TO PL-Z(CN-PLAYER(WS-ID-ALICE))
     MOVE 20 TO PL-X(CN-PLAYER(WS-ID-BOB))
     MOVE 64 TO PL-Y(CN-PLAYER(WS-ID-BOB))
     MOVE 0 TO PL-Z(CN-PLAYER(WS-ID-BOB))
     MOVE "acceptance US13 /execute run executes the command with the c" & "urrent source" TO TL-CASE
     MOVE "execute run say hi" TO WS-LINE
     MOVE "chat.type.announcement(Opal,hi)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute as makes the target the executing e" & "ntity (the name in the announcement)" TO TL-CASE
     MOVE "execute as Alice run say hi" TO WS-LINE
     MOVE "chat.type.announcement(Alice,hi)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /execute as @a forks one source for each pla" & "yer (the sender still hears them all)" TO TL-CASE
     MOVE "execute as @a run say hi" TO WS-LINE
     MOVE "chat.type.announcement(Opal,hi) | chat.type.announcement(Ali" & "ce,hi) | chat.type.announcement(Bob,hi)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /execute the result of a forked chain is the" & " number of successful runs" TO TL-CASE
     MOVE "execute as @a run say hi" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /execute at takes the position of the target" & ": ~ ~ ~ is Alice's place" TO TL-CASE
     MOVE "execute at Alice run setblock ~ ~ ~ cobolcraft:loam" TO WS-LINE
     MOVE "commands.setblock.success(10,64,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute positioned sets the position" TO TL-CASE
     MOVE "execute positioned 5 70 5 run setblock ~ ~ ~ cobolcraft:loam" TO WS-LINE
     MOVE "commands.setblock.success(5,70,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute the block is at the position" TO TL-CASE
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM FIND-STATE
     CALL "WORLD-GET-BLOCK" USING PL-DIM(CN-PLAYER(WS-ID-OPAL)) 5 70 5 WS-OLD
     MOVE 0 TO WS-NUM
     IF WS-OLD = WS-STATE
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /execute align floors the listed axes" TO TL-CASE
     MOVE "execute positioned 6.7 71.9 6.2 align xyz run setblock ~ ~ ~" & " cobolcraft:greystone" TO WS-LINE
     MOVE "commands.setblock.success(6,71,6)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute align xz leaves y fractional: the b" & "lock of y 72.9 is 72" TO TL-CASE
     MOVE "execute positioned 7.5 72.9 7.5 align xz run setblock ~ ~ ~ " & "cobolcraft:turf" TO WS-LINE
     MOVE "commands.setblock.success(7,72,7)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute positioned is relative to the old p" & "osition and chains" TO TL-CASE
     MOVE "execute positioned 1 70 1 positioned ~2 ~ ~ run setblock ~ ~" & " ~ cobolcraft:grit" TO WS-LINE
     MOVE "commands.setblock.success(3,70,1)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute rotated: yaw 90 looks along -x, so " & "^ ^ ^2 is two blocks that way" TO TL-CASE
     MOVE "execute rotated 90 0 positioned ^ ^ ^2 run setblock ~ ~ ~ co" & "bolcraft:loam" TO WS-LINE
     MOVE "commands.setblock.success(-2,64,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute facing a point along +x: three bloc" & "ks ahead" TO TL-CASE
     MOVE "execute facing 10 64 0 positioned ^ ^ ^3.5 run setblock ~ ~ " & "~ cobolcraft:turf" TO WS-LINE
     MOVE "commands.setblock.success(3,64,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute anchored eyes: the local origin is " & "at the eyes" TO TL-CASE
     MOVE "execute anchored eyes positioned ^ ^ ^ run setblock ~ ~ ~ co" & "bolcraft:grit" TO WS-LINE
     MOVE "commands.setblock.success(0,65,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute rotated as takes the target's rotat" & "ion (Alice looks along yaw 0)" TO TL-CASE
     MOVE "execute rotated as Alice run say rot" TO WS-LINE
     MOVE "chat.type.announcement(Opal,rot)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute positioned as takes the target's po" & "sition" TO TL-CASE
     MOVE "execute positioned as Alice run setblock ~ ~ ~ cobolcraft:gr" & "eystone" TO WS-LINE
     MOVE "commands.setblock.success(10,64,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute facing entity looks at the target (" & "Alice is along +x): one block ahead is x 1" TO TL-CASE
     MOVE "execute facing entity Alice feet positioned ^ ^ ^1 run setbl" & "ock ~ ~ ~ cobolcraft:loam" TO WS-LINE
     MOVE "commands.setblock.success(1,64,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute an unknown dimension" TO TL-CASE
     MOVE "execute in nowhere run say hi" TO WS-LINE
     MOVE "argument.dimension.invalid(nowhere)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute in with the dimension of the source" TO TL-CASE
     MOVE "execute in cobolcraft:main run say hi" TO WS-LINE
     MOVE "chat.type.announcement(Opal,hi)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if entity as the last clause: Test " & "passed. Count: 1" TO TL-CASE
     MOVE "execute if entity Alice" TO WS-LINE
     MOVE "commands.execute.conditional.pass_count(1)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute unless entity over a present entity" & ": Test failed. Count: 1" TO TL-CASE
     MOVE "execute unless entity Alice" TO WS-LINE
     MOVE "commands.execute.conditional.fail_count(1)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if entity with none: Test failed. C" & "ount: 0" TO TL-CASE
     MOVE "execute if entity @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "commands.execute.conditional.fail_count(0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute unless entity with none passes" TO TL-CASE
     MOVE "execute unless entity @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "commands.execute.conditional.pass_count(0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if dimension: Test passed" TO TL-CASE
     MOVE "execute if dimension cobolcraft:main" TO WS-LINE
     MOVE "commands.execute.conditional.pass()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute unless dimension in that dimension:" & " Test failed" TO TL-CASE
     MOVE "execute unless dimension cobolcraft:main" TO WS-LINE
     MOVE "commands.execute.conditional.fail()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if block" TO TL-CASE
     MOVE "execute if block 5 70 5 cobolcraft:loam" TO WS-LINE
     MOVE "commands.execute.conditional.pass()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if block of another block fails" TO TL-CASE
     MOVE "execute if block 5 70 5 cobolcraft:grit" TO WS-LINE
     MOVE "commands.execute.conditional.fail()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if loaded" TO TL-CASE
     MOVE "execute if loaded 5 70 5" TO WS-LINE
     MOVE "commands.execute.conditional.pass()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if loaded of an unloaded chunk fail" & "s without an error" TO TL-CASE
     MOVE "execute if loaded 1000000 70 0" TO WS-LINE
     MOVE "commands.execute.conditional.fail()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute if block over an unloaded chunk is " & "an error" TO TL-CASE
     MOVE "execute if block 1000000 70 0 cobolcraft:loam" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute a passing condition continues with " & "the same source" TO TL-CASE
     MOVE "execute if entity Alice run say yes" TO WS-LINE
     MOVE "chat.type.announcement(Opal,yes)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute a failing condition drops the sourc" & "e: nothing runs, no error" TO TL-CASE
     MOVE "execute unless entity Alice run say no" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute clauses chain in any order: as @a a" & "t @s run" TO TL-CASE
     MOVE "execute as @a at @s run tp @s ~ ~1 ~" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Opal,0.000000,65.0" & "00000,0.000000) | commands.teleport.success.location.single(" & "Alice,10.000000,65.000000,0.000000) | commands.teleport.succ" & "ess.location.single(Bob,20.000000,65.000000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /execute a player below level 2 does not kno" & "w the command" TO TL-CASE
     MOVE "execute run say hi" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute execute alone is incomplete" TO TL-CASE
     MOVE "execute" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute a clause without its argument is in" & "complete" TO TL-CASE
     MOVE "execute as" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /execute the console runs execute (the annou" & "ncement is logged)" TO TL-CASE
     MOVE "execute as Alice run say console says hi" TO WS-LINE
     MOVE "[Alice] console says hi" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> WS-STATE: the default state of the block key WS-KEY-TEXT.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = WS-KEY-TEXT
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-EXECUTE.

 COPY CORETEST.
 COPY CMDTEST.
