*> Acceptance test of docs/protocol/16-commands-catalog.md §5.3 `spreadplayers` (permission level 2) with 14a: spreadplayers <center> <spreadDistance> <maxRange>
*> [under <maxHeight>] <respectTeams> <targets> places the piles (one per target, or one for every target without a team: the core keeps no teams, so respectTeams
*> gives one pile) at random in the box around the centre, relaxes them (at most 10000 iterations) until each is at least spreadDistance from the others, and teleports
*> each target to the middle of its pile's column at the spawn height; commands.spreadplayers.success.entities / .teams [piles, x, z, average distance] is broadcast,
*> too crowded is commands.spreadplayers.failed.entities / .teams [piles, x, z, smallest distance], a maxHeight under the world minimum is .failed.invalid.height; the
*> result is the number of piles. The positions are random: the tests check the properties the rules give. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SPREADPLAYERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-FRAC                FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR1                BINARY-LONG.
 01 WS-AIR2                BINARY-LONG.
 01 WS-EXPECTED-Y          BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-PREFIX              PIC X(4096).
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT-MIN            PIC -(9)9.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-A
     MOVE CN-PLAYER(WS-ID-CLEO) TO WS-C
     MOVE "acceptance US13 /spreadplayers one target is one pile: average distance 0.00" TO TL-CASE
     MOVE "spreadplayers 0 0 1 4 false Alice" TO WS-LINE
     MOVE "commands.spreadplayers.success.entities(1,0.0,0.0,0.00)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers the target stands in the middle of a column inside the box" TO TL-CASE
     PERFORM CHECK-HALF-AND-BOX
     MOVE "acceptance US13 /spreadplayers the height is the first solid block with two air blocks above, plus 1" TO TL-CASE
     PERFORM FIND-HEIGHT
     MOVE PL-Y(WS-A) TO WS-NUM
     MOVE WS-EXPECTED-Y TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spreadplayers two targets are two piles at least spreadDistance apart" TO TL-CASE
     MOVE "spreadplayers 0 0 5 8 false @a[name=!Opal]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "commands.spreadplayers.success.entities(2,0.0,0.0," TO WS-EXPECTED
     PERFORM CHECK-PREFIX
     MOVE "acceptance US13 /spreadplayers the targets stand at least 2 apart (the piles 5, each moved up to 1.4 by the floor)" TO TL-CASE
     COMPUTE WS-DX = PL-X(WS-A) - PL-X(WS-C)
     COMPUTE WS-DZ = PL-Z(WS-A) - PL-Z(WS-C)
     COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-DIST >= 2
         MOVE 1 TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spreadplayers the result is the number of piles" TO TL-CASE
     MOVE "spreadplayers 0 0 5 8 false @a[name=!Opal]" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /spreadplayers the under form with a maxHeight above the world" TO TL-CASE
     MOVE "spreadplayers 0 0 3 6 under 400 false Alice" TO WS-LINE
     MOVE "commands.spreadplayers.success.entities(1,0.0,0.0,0.00)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers respectTeams gives one pile: the teams message with a negative centre" TO TL-CASE
     MOVE "spreadplayers -10 -10.5 3 6 true Alice" TO WS-LINE
     MOVE "commands.spreadplayers.success.teams(1,-10.0,-10.5,0.00)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers two targets sharing the one pile of respectTeams: no other pile, an infinite average" TO TL-CASE
     MOVE "spreadplayers -10 -10 3 6 true @a[name=!Opal]" TO WS-LINE
     MOVE "commands.spreadplayers.success.teams(1,-10.0,-10.0,Infinity)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers a mob target is teleported too" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "spreadplayers 20 20 1 4 false @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.spreadplayers.success.entities(1,20.0,20.0,0.00)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) > 15 AND EN-X(WS-I) < 25
             MOVE WS-I TO WS-MOB
         END-IF
     END-PERFORM
     MOVE "acceptance US13 /spreadplayers the mob moved into the box (found at x 15 to 25)" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-MOB > 0
         MOVE 1 TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spreadplayers too many entities for the space: failed.entities with the last smallest distance" TO TL-CASE
     MOVE "spreadplayers 0 0 100 1 false @a" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "commands.spreadplayers.failed.entities(3,0.0,0.0," TO WS-EXPECTED
     PERFORM CHECK-PREFIX
     MOVE "acceptance US13 /spreadplayers a maxHeight under the world minimum is invalid.height" TO TL-CASE
     MOVE DM-MIN-Y(WS-DIM) TO WS-EDIT-MIN
     MOVE "spreadplayers 0 0 3 6 under -1000 false Alice" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     STRING "commands.spreadplayers.failed.invalid.height(-1000," FUNCTION TRIM(WS-EDIT-MIN) ")" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers a maxHeight at the world minimum has no ground: never spreads (the ground check re-rolls)" TO TL-CASE
     MOVE DM-MIN-Y(WS-DIM) TO WS-EDIT-MIN
     MOVE SPACES TO WS-LINE
     STRING "spreadplayers 0 0 3 6 under " FUNCTION TRIM(WS-EDIT-MIN) " false Alice" DELIMITED BY SIZE INTO WS-LINE
     MOVE "commands.spreadplayers.failed.entities(1,0.0,0.0,0.00)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers a negative spreadDistance is out of range" TO TL-CASE
     MOVE "spreadplayers 0 0 -1 6 false Alice" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers a maxRange under 1 is out of range" TO TL-CASE
     MOVE "spreadplayers 0 0 3 0.5 false Alice" TO WS-LINE
     MOVE "argument.float.low(1.0,0.5) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers a player without operator status does not know the command" TO TL-CASE
     MOVE "spreadplayers 0 0 3 6 false Alice" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spreadplayers the console prints the English text" TO TL-CASE
     MOVE "spreadplayers 0 0 1 4 false Alice" TO WS-LINE
     MOVE "Spread 1 entity/entities around 0.0, 0.0 with an average distance of 0.00 block(s) apart" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The player WS-A stands at .5 in x and inside the columns of the box of range 4 around the origin (floor + 0.5 of -4 to 4).
 CHECK-PREFIX.
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(WS-EXPECTED TRAILING))
     MOVE SPACES TO WS-PREFIX
     MOVE WS-TEXT(1:WS-N) TO WS-PREFIX
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-PREFIX.

 CHECK-HALF-AND-BOX.
     MOVE 0 TO WS-NUM
     COMPUTE WS-FRAC = FUNCTION MOD(PL-X(WS-A) - 0.5, 1)
     IF WS-FRAC = 0 AND PL-X(WS-A) >= -3.5 AND PL-X(WS-A) <= 4.5 AND PL-Z(WS-A) >= -3.5 AND PL-Z(WS-A) <= 4.5
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.

*> WS-EXPECTED-Y: the y above the first solid block (with two air blocks above it) of the column of the player WS-A, from the top of the world down.
 FIND-HEIGHT.
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-A))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-A))
     COMPUTE WS-EXPECTED-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) + 1
     MOVE 0 TO WS-AIR1 WS-AIR2
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
     PERFORM UNTIL WS-Y < DM-MIN-Y(WS-DIM) OR WS-AIR1 = 99
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE NOT = 0 AND WS-AIR1 = 1 AND WS-AIR2 = 1
             COMPUTE WS-EXPECTED-Y = WS-Y + 1
             MOVE 99 TO WS-AIR1
         END-IF
         IF WS-AIR1 NOT = 99
             MOVE WS-AIR1 TO WS-AIR2
             MOVE 0 TO WS-AIR1
             IF WS-STATE = 0
                 MOVE 1 TO WS-AIR1
             END-IF
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-SPREADPLAYERS.

 COPY CORETEST.
 COPY CMDTEST.
