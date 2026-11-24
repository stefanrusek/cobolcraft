*> Acceptance test of docs/protocol/16-commands-catalog.md §7.8 `particle` (permission level 2) and 42-particles-7 §2: Level Particles 0x30 is sent to every viewer within 32 blocks
*> of the position (512 with force) in the source's dimension; the position of a whole number is centred, the delta is not; the short forms send count 0; the result is the
*> number of viewers sent the packet and none is commands.particle.failed; commands.particle.success [name] is broadcast; an unknown particle is particle.notFound, a type that
*> needs options and gets none is particle.invalidOptions. Opal holds operator status; Opal and Alice stand at the spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PARTICLE.
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
 01 WS-OBSERVED            PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
 01 WS-LENGTH              BINARY-LONG.
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
*>   The worked example of 42-7 §2: flame (39) at 0 64 0 (centred to 0.5 64 0.5), spread 0.5, speed 0.01, count 20, force.
     MOVE "acceptance US13 /particle the worked example: Displaying particle minecraft:flame" TO TL-CASE
     MOVE "particle minecraft:flame 0 64 0 0.5 0.5 0.5 0.01 20 force" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle the packet of the worked example" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "27" "01" "00" "3fe0000000000000" "4050000000000000" "3fe0000000000000" "3f000000" "3f000000" "3f000000"
         "3c23d70a" "3c23d70a" "3c23d70a" "14" "00" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /particle the delta is not centred: 1 2 3 stay 1 2 3" TO TL-CASE
     MOVE "particle minecraft:flame 0 64 0 1 2 3 0.01 5 force" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     STRING "27" "01" "00" "3fe0000000000000" "4050000000000000" "3fe0000000000000" "3f800000" "40000000" "40400000"
         "3c23d70a" "3c23d70a" "3c23d70a" "05" "00" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /particle normal: the override flag is 0 (type 39, override 0, always show 0)" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 1 normal Opal" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TC-PACKET-HEX" USING WS-ID-OPAL 48 WS-TEXT
     MOVE "270000" TO WS-EXPECTED
     MOVE WS-TEXT(1:6) TO WS-OBSERVED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-OBSERVED
*>   The result value, the short forms and the viewers.
     MOVE "acceptance US13 /particle the short form with a relative position reaches both players" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /particle the short form sends count 0, zero speed and zero spread (the last 26 bytes)" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TC-PACKET-HEX" USING WS-ID-OPAL 48 WS-TEXT
     MOVE ALL "0" TO WS-EXPECTED(1:52)
     MOVE SPACES TO WS-EXPECTED(53:)
     MOVE WS-TEXT(55:52) TO WS-OBSERVED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-OBSERVED
     MOVE "acceptance US13 /particle the name alone: the position is the source's" TO TL-CASE
     MOVE "particle minecraft:flame" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle a default namespace: flame is minecraft:flame" TO TL-CASE
     MOVE "particle flame ~ ~ ~" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle viewers: only Alice is sent the packet (result 1)" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 1 normal Alice" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /particle force with viewers" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 1 force Opal" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle viewers without the force word is no form (57-client-closures-4 section 7.36: the viewers follow force or normal)" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 1 @a" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle no viewer selected" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 1 force @a[name=Nobody]" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   The radius: 32 blocks, 512 with force.
     MOVE "acceptance US13 /particle 400 blocks away is out of reach: The particle was not visible for anybody" TO TL-CASE
     MOVE "particle minecraft:flame 400 64 0 0 0 0 0 1 normal" TO WS-LINE
     MOVE "commands.particle.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle 400 blocks away is visible with force" TO TL-CASE
     MOVE "particle minecraft:flame 400 64 0 0 0 0 0 1 force" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle 1000 blocks away is out of reach even with force" TO TL-CASE
     MOVE "particle minecraft:flame 1000 64 0 0 0 0 0 1 force" TO WS-LINE
     MOVE "commands.particle.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   The particle.
     MOVE "acceptance US13 /particle an unknown particle: Unknown particle: minecraft:nope" TO TL-CASE
     MOVE "particle minecraft:nope" TO WS-LINE
     MOVE "particle.notFound(minecraft:nope)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle a type with options and none given" TO TL-CASE
     MOVE "particle minecraft:block ~ ~ ~" TO WS-LINE
     MOVE "particle.invalidOptions(minecraft:block)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle the braces after a type without options are ignored" TO TL-CASE
     MOVE "particle minecraft:flame{} ~ ~ ~" TO WS-LINE
     MOVE "commands.particle.success(minecraft:flame)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle the speed may not be negative" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 -1 1" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle the count may not be negative" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0 0 -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle the delta needs the speed and the count" TO TL-CASE
     MOVE "particle minecraft:flame ~ ~ ~ 0 0 0" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /particle a player below level 2 does not know the command" TO TL-CASE
     MOVE "particle minecraft:flame" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /particle the console prints the English text" TO TL-CASE
     MOVE "particle minecraft:flame 0 64 0 0 0 0 0 1 force" TO WS-LINE
     MOVE "Displaying particle minecraft:flame" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /particle completion after the count offers force and normal only (the viewers come after the word)" TO TL-CASE
     MOVE "/particle minecraft:flame ~ ~ ~ 0 0 0 0 1 " TO WS-LINE
     MOVE 42 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 42 0 [force,normal]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The line is run by Opal again and the body of the Level Particles packet she was sent (hex) is compared with WS-EXPECTED.
 RUN-PACKET.
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE 48 WS-EXPECTED.
 END PROGRAM TEST-CMD-PARTICLE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.

*> TC-PACKET-HEX USING connection id, wanted packet id (BINARY-LONG), hex out (PIC X(4096)): the body of the first packet of that id the connection was sent as lowercase
*> hex ("none" when there is none); the output of the connection is drained.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TC-PACKET-HEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AREA                PIC X(65536) BASED.
 01 WS-COPY                PIC X(512).
 01 WS-HEX                 PIC X(1024).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-WANTED               BINARY-LONG.
 01 L-HEX                  PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-WANTED L-HEX.
     MOVE "none" TO L-HEX
     MOVE 0 TO WS-FOUND WS-OUTCOME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             COMPUTE WS-COUNT = PK-LENGTH - PK-POS
             MOVE SPACES TO WS-COPY
             MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
             CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
             MOVE WS-HEX TO L-HEX
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TC-PACKET-HEX.
