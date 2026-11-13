*> Acceptance test of docs/protocol/16-commands-catalog.md §5.14 `swing` (permission level 2) with 14a: swing <targets> mainhand|offhand and swing <targets> none|whack|stab <duration>
*> (time, at least 1 tick) make the living targets (players and mobs) swing; commands.swing.success.single [name] / .multiple [count] is broadcast; no living target is
*> commands.swing.failed.notliving; the result is the number of living targets. The animation packet is BLOCKED (05a does not give the Animate action of an arm swing).
*> Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SWING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 70.
 01 WS-SX                  FLOAT-LONG VALUE 30.
 01 WS-SZ                  FLOAT-LONG VALUE 30.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-B              FLOAT-LONG VALUE 0.
 01 WS-ZERO-C              FLOAT-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /swing mainhand of one player: Made Alice swing an arm" TO TL-CASE
     MOVE "swing Alice mainhand" TO WS-LINE
     MOVE "commands.swing.success.single(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing offhand of three players: Made 3 entities swing their arms" TO TL-CASE
     MOVE "swing @a offhand" TO WS-LINE
     MOVE "commands.swing.success.multiple(3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing the result is the number of living targets" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /swing a mob is living" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "swing @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] mainhand" TO WS-LINE
     MOVE "commands.swing.success.single(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing the whack animation with a duration" TO TL-CASE
     MOVE "swing Alice whack 20" TO WS-LINE
     MOVE "commands.swing.success.single(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing the stab animation with a duration" TO TL-CASE
     MOVE "swing Cleo stab 5" TO WS-LINE
     MOVE "commands.swing.success.single(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing the none animation with a duration" TO TL-CASE
     MOVE "swing @a none 1" TO WS-LINE
     MOVE "commands.swing.success.multiple(3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing a duration below one tick is out of range" TO TL-CASE
     MOVE "swing Alice whack 0" TO WS-LINE
     MOVE "argument.time.tick_count_too_low(1,0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing a ground item is not living: No living entities were found to swing" TO TL-CASE
     CALL "GI-SPAWN" USING WS-DIM WS-SX WS-Y WS-SZ WS-ZERO WS-ZERO-B WS-ZERO-C WS-STONE WS-ONE WS-DELAY WS-ITEM-ROW
     MOVE "swing @e[type=cobolcraft:loose_item] mainhand" TO WS-LINE
     MOVE "commands.swing.failed.notliving()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing a player without operator status does not know the command" TO TL-CASE
     MOVE "swing Opal mainhand" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /swing the console prints the English text" TO TL-CASE
     MOVE "swing Alice mainhand" TO WS-LINE
     MOVE "Made Alice swing an arm" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SWING.

 COPY CORETEST.
 COPY CMDTEST.
