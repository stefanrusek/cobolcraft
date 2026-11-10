*> Acceptance test of docs/protocol/16-commands-catalog.md §5.2 `teleport` and its alias `tp` (permission level 2) with 14a: a destination is a
*> location (components absolute, relative to the target's own, or local to the source) or an entity; the entities moved are the players
*> the targets select (none given: the source, which must be an entity); a rotation (yaw pitch, absolute or relative to the target's) or
*> facing a point or an entity turns the target; the player is sent Player Position; a location outside the spawnable bounds
*> is commands.teleport.invalidPosition; commands.teleport.success.location.single [name, x, y, z] or .multiple [count, x, y, z] (six
*> decimals) and .entity.single [name, destination] or .multiple [count, destination] (broadcast); the result is the number moved.
*> Opal holds operator status; the test world has the one dimension cobolcraft:main.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TELEPORT.
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
 01 WS-IDS                 PIC X(1024).
 01 WS-AX                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
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
     MOVE "acceptance US13 /teleport teleport Alice to a location: whol" & "e numbers centre x and z" TO TL-CASE
     MOVE "tp Alice 10 70 20" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,10.500000,70" & ".000000,20.500000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice's x is 10.5 (twice: 21)" TO TL-CASE
     COMPUTE WS-NUM = PL-X(CN-PLAYER(WS-ID-ALICE)) * 2
     MOVE 21 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport Alice's y is 70" TO TL-CASE
     COMPUTE WS-NUM = PL-Y(CN-PLAYER(WS-ID-ALICE))
     MOVE 70 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport Alice is sent Player Position (73)" & " and the others see her move" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE "73" TO WS-TEXT
     MOVE "73" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport teleport is the same command, a de" & "cimal point keeps the value" TO TL-CASE
     MOVE "teleport Alice 1.0 2.0 3.0" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,1.000000,2.0" & "00000,3.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport relative components are the target" & "'s plus the offset" TO TL-CASE
     MOVE "tp Alice ~1 ~ ~-1" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,2.000000,2.0" & "00000,2.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport teleport to an entity: Teleported " & "Alice to Bob" TO TL-CASE
     MOVE "tp Alice Bob" TO WS-LINE
     MOVE "commands.teleport.success.entity.single(Alice,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice is at Bob's x" TO TL-CASE
     MOVE PL-X(CN-PLAYER(WS-ID-ALICE)) TO WS-AX
     MOVE PL-X(CN-PLAYER(WS-ID-BOB)) TO WS-BX
     IF WS-AX = WS-BX
         MOVE "same" TO WS-TEXT
     ELSE
         MOVE WS-AX TO WS-EDIT
         STRING "a=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
         MOVE WS-BX TO WS-EDIT
         STRING FUNCTION TRIM(WS-TEXT) " b=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     MOVE "same" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport a single entity destination moves " & "the source" TO TL-CASE
     MOVE "tp Bob" TO WS-LINE
     MOVE "commands.teleport.success.entity.single(Opal,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport a location alone moves the source" TO TL-CASE
     MOVE "tp 5.0 6.0 7.0" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Opal,5.000000,6.00" & "0000,7.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport the result is the number moved" TO TL-CASE
     MOVE "tp @a 0.0 64.0 0.0" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /teleport several targets: the multiple mess" & "age with the count" TO TL-CASE
     MOVE "tp @a 0.0 64.0 0.0" TO WS-LINE
     MOVE "commands.teleport.success.location.multiple(3,0.000000,64.00" & "0000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport several targets to an entity" TO TL-CASE
     MOVE "tp @a Opal" TO WS-LINE
     MOVE "commands.teleport.success.entity.multiple(3,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport with a rotation" TO TL-CASE
     MOVE "tp Alice 1.0 2.0 3.0 90 45" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,1.000000,2.0" & "00000,3.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice's yaw is 90" TO TL-CASE
     COMPUTE WS-NUM = PL-YAW(CN-PLAYER(WS-ID-ALICE))
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport Alice's pitch is 45" TO TL-CASE
     COMPUTE WS-NUM = PL-PITCH(CN-PLAYER(WS-ID-ALICE))
     MOVE 45 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport a rotation relative to the target'" & "s" TO TL-CASE
     MOVE "tp Alice 1.0 2.0 3.0 ~10 ~" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,1.000000,2.0" & "00000,3.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice's yaw is 100" TO TL-CASE
     COMPUTE WS-NUM = PL-YAW(CN-PLAYER(WS-ID-ALICE))
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport facing a point along +x" TO TL-CASE
     MOVE "tp Alice 0.0 64.0 0.0 facing 10.0 64.0 0.0" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,0.000000,64." & "000000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice looks along +x: yaw -90" TO TL-CASE
     COMPUTE WS-NUM = PL-YAW(CN-PLAYER(WS-ID-ALICE))
     MOVE -90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 10 TO PL-X(CN-PLAYER(WS-ID-BOB))
     MOVE 64 TO PL-Y(CN-PLAYER(WS-ID-BOB))
     MOVE 0 TO PL-Z(CN-PLAYER(WS-ID-BOB))
     MOVE "acceptance US13 /teleport facing an entity (feet)" TO TL-CASE
     MOVE "tp Alice 0.0 64.0 0.0 facing entity Bob" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,0.000000,64." & "000000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport Alice looks at Bob: yaw -90" TO TL-CASE
     COMPUTE WS-NUM = PL-YAW(CN-PLAYER(WS-ID-ALICE))
     MOVE -90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport facing an entity at the eyes" TO TL-CASE
     MOVE "tp Alice 0.0 64.0 0.0 facing entity Bob eyes" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,0.000000,64." & "000000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport facing a point straight down" TO TL-CASE
     MOVE "tp Alice 0.0 74.0 0.0 facing 0.0 64.0 0.0" TO WS-LINE
     MOVE "commands.teleport.success.location.single(Alice,0.000000,74." & "000000,0.000000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport the pitch is 90 looking down" TO TL-CASE
     COMPUTE WS-NUM = PL-PITCH(CN-PLAYER(WS-ID-ALICE))
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /teleport a block outside the spawnable boun" & "ds: Invalid position for teleport" TO TL-CASE
     MOVE "tp Alice 30000000.0 0.0 0.0" TO WS-LINE
     MOVE "commands.teleport.invalidPosition()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport a name that is not online: No enti" & "ty was found" TO TL-CASE
     MOVE "tp Zed 1 2 3" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport a location needs three coordinates" & ": the destination branch takes Alice and the rest is Incorre" & "ct argument" TO TL-CASE
     MOVE "tp Alice 1 2" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport a player without operator status d" & "oes not know the command" TO TL-CASE
     MOVE "tp 1 2 3" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport the console prints the English tex" & "t" TO TL-CASE
     MOVE "tp Alice 1.0 2.0 3.0" TO WS-LINE
     MOVE "Teleported Alice to 1.000000, 2.000000, 3.000000" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /teleport the console without a target: an e" & "ntity is required (permissions.requires.entity)" TO TL-CASE
     MOVE "tp 1.0 2.0 3.0" TO WS-LINE
     MOVE "An entity is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-TELEPORT.

 COPY CORETEST.
 COPY CMDTEST.
