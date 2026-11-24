*> Acceptance test of docs/protocol/16-commands-catalog.md §4.4 and §13 `gamerule` (permission level 2) with 14a: each of the 59 rules is a
*> literal (bare or minecraft:-prefixed) with a query (commands.gamerule.query, not broadcast; result 1/0 or the integer) and a
*> set (a bool, or an integer within the rule's range); a value equal to the current one is commands.gamerule.not_set (an
*> error); a change is broadcast (commands.gamerule.set). The rules are not persisted (BLOCKED: level.dat GameRules). Opal holds
*> operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-GAMERULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
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
     MOVE "acceptance US13 /gamerule query a boolean rule at its defaul" & "t" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     MOVE "commands.gamerule.query(keep_inventory,false)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the result of a boolean query is 0" & " for false" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /gamerule set a boolean rule" TO TL-CASE
     MOVE "gamerule keep_inventory true" TO WS-LINE
     MOVE "commands.gamerule.set(keep_inventory,true)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the result is 1 for true" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /gamerule the same value: Game rule is alrea" & "dy set" TO TL-CASE
     MOVE "gamerule keep_inventory true" TO WS-LINE
     MOVE "commands.gamerule.not_set(keep_inventory,true)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the minecraft: form of the rule" TO TL-CASE
     MOVE "gamerule minecraft:keep_inventory false" TO WS-LINE
     MOVE "commands.gamerule.set(keep_inventory,false)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule an integer rule at its default" TO TL-CASE
     MOVE "gamerule random_tick_speed" TO WS-LINE
     MOVE "commands.gamerule.query(random_tick_speed,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the result of a set is the integer" & " value" TO TL-CASE
     MOVE "gamerule random_tick_speed 7" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 7 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /gamerule below the minimum of the rule" TO TL-CASE
     MOVE "gamerule random_tick_speed -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a rule whose minimum is -1" TO TL-CASE
     MOVE "gamerule fire_spread_radius_around_player -1" TO WS-LINE
     MOVE "commands.gamerule.set(fire_spread_radius_around_player,-1)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the maximum value" TO TL-CASE
     MOVE "gamerule max_command_forks 2147483647" TO WS-LINE
     MOVE "commands.gamerule.set(max_command_forks,2147483647)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a boolean rule takes true or false" TO TL-CASE
     MOVE "gamerule keep_inventory maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule an unknown rule" TO TL-CASE
     MOVE "gamerule no_such_rule" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a rule that the framework consults" & ": no feedback to the source when send_command_feedback is fa" & "lse" TO TL-CASE
     MOVE "gamerule send_command_feedback false" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "gamemode survival" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule feedback on again (set feedback go" & "es to the source when it is on)" TO TL-CASE
     MOVE "gamerule send_command_feedback true" TO WS-LINE
     MOVE "commands.gamerule.set(send_command_feedback,true)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule a player below level 2 does not kn" & "ow the command" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamerule the console prints the English tex" & "t" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     MOVE "Game rule keep_inventory is currently set to false" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-GAMERULE.

 COPY CORETEST.
 COPY CMDTEST.
