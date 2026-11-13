*> Acceptance test of docs/protocol/16-commands-catalog.md §5.13 `experience` (alias `xp`, permission level 2) with 14a and 17 §4.10: experience add|set <players> <amount>
*> [points|levels] and experience query <player> points|levels over the player's total experience (the points to go from level L to L + 1 are 7 + 2L below 15, 37 + 5(L - 15)
*> below 30, else 112 + 9(L - 30); the total is capped at the int range). set points needs an amount below the points of the current level (else
*> commands.experience.set.points.invalid); the messages are .success.single [amount, name] / .multiple [amount, count] (broadcast), the query .query.points / .levels
*> [name, value] (not broadcast); the result is the number of players (add, set) or the value (query). Set Experience (0x69) is sent after a change. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-EXPERIENCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY XPSTATE.
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
 01 WS-PACKET              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /experience set levels: Set 5 experience levels on Alice" TO TL-CASE
     MOVE "experience set Alice 5 levels" TO WS-LINE
     MOVE "commands.experience.set.levels.success.single(5,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience query levels: Alice has 5 experience levels" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /xp the alias adds points by default: Gave 3 experience points to Alice" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "xp add Alice 3" TO WS-LINE
     MOVE "commands.experience.add.points.success.single(3,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience Set Experience carries progress 3/17, level 5, total 58" TO TL-CASE
     MOVE 105 TO WS-PACKET
     CALL "TEST-DRAIN-PACKET" USING WS-ID-ALICE WS-PACKET PB-BUFFER WS-FOUND
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PROGRESS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-LEVEL
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-TOTAL
     COMPUTE WS-NUM ROUNDED = WS-PROGRESS * 1000
     MOVE 176 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /experience Set Experience level" TO TL-CASE
     MOVE WS-LEVEL TO WS-NUM
     MOVE 5 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /experience Set Experience total" TO TL-CASE
     MOVE WS-TOTAL TO WS-NUM
     MOVE 58 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /experience query points: the result is the 3 points of the level" TO TL-CASE
     MOVE "experience query Alice points" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "experience add Alice 20 points" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience points past the level raise it: level 6" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,6)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience points left in the new level: 6" TO TL-CASE
     MOVE "experience query Alice points" TO WS-LINE
     MOVE "commands.experience.query.points(Alice,6)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience add Alice -30 points" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience negative points lower the level: level 4" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,4)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience negative points leave 8 points" TO TL-CASE
     MOVE "experience query Alice points" TO WS-LINE
     MOVE "commands.experience.query.points(Alice,8)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience add Alice -1000 points" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience points cannot go below zero" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience add levels: Gave 2 experience levels to Alice" TO TL-CASE
     MOVE "experience add Alice 2 levels" TO WS-LINE
     MOVE "commands.experience.add.levels.success.single(2,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience Alice is at level 2" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set points: Set 3 experience points on Alice" TO TL-CASE
     MOVE "experience set Alice 3 points" TO WS-LINE
     MOVE "commands.experience.set.points.success.single(3,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set points by default" TO TL-CASE
     MOVE "experience set Alice 4" TO WS-LINE
     MOVE "commands.experience.set.points.success.single(4,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set points not below the 11 needed: invalid" TO TL-CASE
     MOVE "experience set Alice 11 points" TO WS-LINE
     MOVE "commands.experience.set.points.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience add several players levels: Gave 1 experience levels to 3 players" TO TL-CASE
     MOVE "experience add @a 1 levels" TO WS-LINE
     MOVE "commands.experience.add.levels.success.multiple(1,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience add points to several players" TO TL-CASE
     MOVE "experience add @a 1 points" TO WS-LINE
     MOVE "commands.experience.add.points.success.multiple(1,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set levels on several players" TO TL-CASE
     MOVE "experience set @a 1 levels" TO WS-LINE
     MOVE "commands.experience.set.levels.success.multiple(1,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set points on several players" TO TL-CASE
     MOVE "experience set @a 2 points" TO WS-LINE
     MOVE "commands.experience.set.points.success.multiple(2,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience set @a 0 levels" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "experience set Alice 10 levels" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience set points valid for one player only: Set 8 experience points on Alice" TO TL-CASE
     MOVE "experience set @a 8 points" TO WS-LINE
     MOVE "commands.experience.set.points.success.single(8,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience the result of add is the number of players" TO TL-CASE
     MOVE "experience add @a 1 points" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /experience add negative levels floor at level 0" TO TL-CASE
     MOVE "experience add Alice -100 levels" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /experience level 0 after the negative levels" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience set Alice 100 levels" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience a high level: 100" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,100)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience set Alice 2000000000 levels" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience the total is capped at the int range: level 21863" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,21863)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience the capped total leaves 75704 points in the level" TO TL-CASE
     MOVE "experience query Alice points" TO WS-LINE
     MOVE "commands.experience.query.points(Alice,75704)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "experience set Alice 0 levels" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "experience add Alice 2000000000 points" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "experience add Alice 2000000000 points" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /experience points are capped at the int range as well: level 21863" TO TL-CASE
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,21863)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience the state of an earlier player of the row is ignored" TO TL-CASE
     MOVE 0 TO XP-ENTITY(CN-PLAYER(WS-ID-ALICE))
     MOVE "experience query Alice levels" TO WS-LINE
     MOVE "commands.experience.query.levels(Alice,0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience set below zero is out of range" TO TL-CASE
     MOVE "experience set Alice -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience query a name that is not online" TO TL-CASE
     MOVE "experience query Zed levels" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience a player without operator status does not know the command" TO TL-CASE
     MOVE "experience query Opal levels" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /experience the console prints the English text" TO TL-CASE
     MOVE "experience add Alice 3 points" TO WS-LINE
     MOVE "Gave 3 experience points to Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-EXPERIENCE.

 COPY CORETEST.
 COPY CMDTEST.
