*> Acceptance test of docs/protocol/16-commands-catalog.md §4.7 `setworldspawn` (permission level 2): the world spawn point is the block
*> position (the source's block, or the argument), the rotation (0, 0 or the argument); every player in cobolcraft:main is sent Set
*> Default Spawn Position (99); commands.setworldspawn.success [x, y, z, yaw, pitch, dimension] (six arguments, the English text
*> shows the first four); broadcast; the result is 1. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SETWORLDSPAWN.
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
 01 WS-IDS                 PIC X(1024).
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
     MOVE "acceptance US13 /setworldspawn setworldspawn at a block: suc" & "cess with x y z yaw pitch dimension" TO TL-CASE
     MOVE "setworldspawn 10 64 20" TO WS-LINE
     MOVE "commands.setworldspawn.success(10,64,20,0.0,0.0,cobolcraft:m" & "ain)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn the spawn x is the block's ce" & "ntre, 10.5, times 2" TO TL-CASE
     COMPUTE WS-NUM = CW-SPAWN-X * 2
     MOVE 21 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setworldspawn the spawn y is 64" TO TL-CASE
     MOVE CW-SPAWN-Y TO WS-NUM
     MOVE 64 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setworldspawn the spawn z is the block's ce" & "ntre, 20.5, times 2" TO TL-CASE
     COMPUTE WS-NUM = CW-SPAWN-Z * 2
     MOVE 41 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setworldspawn every player is sent Set Defa" & "ult Spawn Position (99)" TO TL-CASE
     MOVE "setworldspawn 11 65 21" TO WS-LINE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "99" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn with a rotation" TO TL-CASE
     MOVE "setworldspawn 5 70 5 90 -10" TO WS-LINE
     MOVE "commands.setworldspawn.success(5,70,5,90.0,-10.0,cobolcraft:" & "main)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn the spawn yaw is 90" TO TL-CASE
     MOVE CW-SPAWN-YAW TO WS-NUM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /setworldspawn the result is 1" TO TL-CASE
     MOVE "setworldspawn 1 2 3" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE 7.5 TO PL-X(CN-PLAYER(WS-ID-OPAL))
     MOVE 80.25 TO PL-Y(CN-PLAYER(WS-ID-OPAL))
     MOVE -3.5 TO PL-Z(CN-PLAYER(WS-ID-OPAL))
     MOVE "acceptance US13 /setworldspawn without an argument: the bloc" & "k of the source" TO TL-CASE
     MOVE "setworldspawn" TO WS-LINE
     MOVE "commands.setworldspawn.success(7,80,-4,0.0,0.0,cobolcraft:ma" & "in)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn a position needs three coordi" & "nates" TO TL-CASE
     MOVE "setworldspawn 1 2" TO WS-LINE
     MOVE "argument.pos3d.incomplete() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn a player below level 2 does n" & "ot know the command" TO TL-CASE
     MOVE "setworldspawn 1 2 3" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /setworldspawn the console prints the Englis" & "h text (four of the six arguments)" TO TL-CASE
     MOVE "setworldspawn 3 4 5" TO WS-LINE
     MOVE "Set the world spawn point to 3, 4, 5 [0.0]" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SETWORLDSPAWN.

 COPY CORETEST.
 COPY CMDTEST.
