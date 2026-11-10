*> Acceptance test of docs/protocol/16-commands-catalog.md §4.8 `spawnpoint` (permission level 2): each target's personal respawn point
*> (the dimension of the source, the block position, the rotation) is stored in BW-SPAWN (core/copy/BRWORLD.cpy; the respawn
*> code does not read it yet: BLOCKED for health.cob); commands.spawnpoint.success.single [x, y, z, yaw, pitch, dimension,
*> player] or .multiple [..., count] (seven arguments, the English text shows six); broadcast; the result is the number of players.
*> Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SPAWNPOINT.
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
 COPY BRWORLD.
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
     MOVE 7.5 TO PL-X(CN-PLAYER(WS-ID-OPAL))
     MOVE 80.25 TO PL-Y(CN-PLAYER(WS-ID-OPAL))
     MOVE -3.5 TO PL-Z(CN-PLAYER(WS-ID-OPAL))
     MOVE "acceptance US13 /spawnpoint spawnpoint with no argument: the" & " source at its block" TO TL-CASE
     MOVE "spawnpoint" TO WS-LINE
     MOVE "commands.spawnpoint.success.single(7,80,-4,0.0,0.0,cobolcraf" & "t:main,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint the respawn point of Opal is set" TO TL-CASE
     MOVE BW-SPAWN-SET(CN-PLAYER(WS-ID-OPAL)) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spawnpoint its y is 80" TO TL-CASE
     MOVE BW-SPAWN-Y(CN-PLAYER(WS-ID-OPAL)) TO WS-NUM
     MOVE 80 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spawnpoint a target and a position" TO TL-CASE
     MOVE "spawnpoint Alice 5 70 5" TO WS-LINE
     MOVE "commands.spawnpoint.success.single(5,70,5,0.0,0.0,cobolcraft" & ":main,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint Alice's respawn x is the block's" & " centre, 5.5, times 2" TO TL-CASE
     COMPUTE WS-NUM = BW-SPAWN-X(CN-PLAYER(WS-ID-ALICE)) * 2
     MOVE 11 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spawnpoint the rotation: the pitch is limit" & "ed to -90 to 90" TO TL-CASE
     MOVE "spawnpoint Bob 1 2 3 90 -100" TO WS-LINE
     MOVE "commands.spawnpoint.success.single(1,2,3,90.0,-90.0,cobolcra" & "ft:main,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint Bob's yaw is 90" TO TL-CASE
     MOVE BW-SPAWN-YAW(CN-PLAYER(WS-ID-BOB)) TO WS-NUM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /spawnpoint the yaw is wrapped to degrees" TO TL-CASE
     MOVE "spawnpoint Bob 1 2 3 270 0" TO WS-LINE
     MOVE "commands.spawnpoint.success.single(1,2,3,-90.0,0.0,cobolcraf" & "t:main,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint the result is the number of play" & "ers" TO TL-CASE
     MOVE "spawnpoint @a" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /spawnpoint several targets: success.multipl" & "e with the count" TO TL-CASE
     MOVE "spawnpoint @a 4 5 6" TO WS-LINE
     MOVE "commands.spawnpoint.success.multiple(4,5,6,0.0,0.0,cobolcraf" & "t:main,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint a name that is not online is No " & "player was found" TO TL-CASE
     MOVE "spawnpoint Zed" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint a player below level 2 does not " & "know the command" TO TL-CASE
     MOVE "spawnpoint" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spawnpoint the console without a target: a " & "player is required" TO TL-CASE
     MOVE "spawnpoint" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SPAWNPOINT.

 COPY CORETEST.
 COPY CMDTEST.
