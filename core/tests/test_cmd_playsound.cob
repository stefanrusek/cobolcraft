*> Acceptance test of docs/protocol/16-commands-catalog.md §7.9 `playsound` (permission level 2): each target (the source itself when none is given) is sent Sound 0x77 (05b:
*> the holder, the source's ordinal, the position in eighths of a block, the volume, the pitch, the seed); the position defaults to the source's, the volume and pitch to 1.0;
*> commands.playsound.success.single [sound, player] or .multiple [sound, count] is broadcast and the result is the number of targets. The audible distance (commands.playsound.failed)
*> is not in the docs (BLOCKED). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-PLAYSOUND.
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
 01 WS-SUGGESTION-ID       BINARY-LONG VALUE 1.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HEX-1               PIC X(4096).
 01 WS-HEX-2               PIC X(4096).
 01 WS-SOURCES.
    05 FILLER               PIC X(8) VALUE "master".
    05 FILLER               PIC X(8) VALUE "music".
    05 FILLER               PIC X(8) VALUE "record".
    05 FILLER               PIC X(8) VALUE "weather".
    05 FILLER               PIC X(8) VALUE "block".
    05 FILLER               PIC X(8) VALUE "hostile".
    05 FILLER               PIC X(8) VALUE "neutral".
    05 FILLER               PIC X(8) VALUE "player".
    05 FILLER               PIC X(8) VALUE "ambient".
    05 FILLER               PIC X(8) VALUE "voice".
    05 FILLER               PIC X(8) VALUE "ui".
 01 WS-SOURCE-TABLE REDEFINES WS-SOURCES.
    05 WS-SOURCE            PIC X(8) OCCURS 11 TIMES.
 01 WS-ORDINALS            PIC X(22) VALUE "000102030405060708090a".
 01 WS-ORDINAL-TABLE REDEFINES WS-ORDINALS.
    05 WS-ORDINAL           PIC X(2) OCCURS 11 TIMES.
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
*>   A sound of the table (ambient.cave is entry 7: the holder is 8), x and z of a whole number are centred (1 -> 1.5 -> 12 eighths), y 64 -> 512.
     MOVE "acceptance US13 /playsound one target: Played sound minecraft:ambient.cave to Opal" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 1 64 1" TO WS-LINE
     MOVE "commands.playsound.success.single(minecraft:ambient.cave,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound the packet: holder 8, source master, position in eighths, volume 1.0, pitch 1.0, seed 0" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "08" "00" "0000000c" "00000200" "0000000c" "3f800000" "3f800000" "0000000000000000" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
*>   A sound the table does not hold goes inline; a position with a decimal point is not centred; volume 2.0 and pitch 1.5.
     MOVE "acceptance US13 /playsound a sound that is not in the table, with volume and pitch" TO TL-CASE
     MOVE "playsound cobolcraft:test.beep music Opal 0.5 64 0.5 2 1.5" TO WS-LINE
     MOVE "commands.playsound.success.single(cobolcraft:test.beep,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound the inline packet: holder 0, the identifier, no fixed range, source music" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "00" "14" "636f626f6c63726166743a746573742e62656570" "00" "01" "00000004" "00000200" "00000004" "40000000" "3fc00000"
         "0000000000000000" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
*>   All sources.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE SPACES TO WS-LINE TL-CASE WS-EXPECTED
         STRING "playsound minecraft:ambient.cave " FUNCTION TRIM(WS-SOURCE(WS-I)) " Opal 1 64 1" DELIMITED BY SIZE INTO WS-LINE
         STRING "acceptance US13 /playsound the packet of the source " FUNCTION TRIM(WS-SOURCE(WS-I)) " has its ordinal"
             DELIMITED BY SIZE INTO TL-CASE
         STRING "08" WS-ORDINAL(WS-I) "0000000c" "00000200" "0000000c" "3f800000" "3f800000" "0000000000000000"
             DELIMITED BY SIZE INTO WS-EXPECTED
         PERFORM RUN-PACKET
     END-PERFORM
*>   Defaults: no targets (the source), no position (the source's), a plain name (minecraft:).
     MOVE "acceptance US13 /playsound without targets the source hears it" TO TL-CASE
     MOVE "playsound ambient.cave voice" TO WS-LINE
     MOVE "commands.playsound.success.single(minecraft:ambient.cave,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "playsound minecraft:ambient.cave voice" TO WS-LINE
     PERFORM FIRST-HEX
     MOVE WS-TEXT TO WS-HEX-1
     MOVE "playsound minecraft:ambient.cave voice Opal ~ ~ ~" TO WS-LINE
     PERFORM FIRST-HEX
     MOVE WS-TEXT TO WS-HEX-2
     MOVE "acceptance US13 /playsound the default position is the source's (the same packet as ~ ~ ~)" TO TL-CASE
     MOVE WS-HEX-1 TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-HEX-2
*>   Several targets and the result value.
     MOVE "acceptance US13 /playsound several targets: Played sound minecraft:ambient.cave to 2 players" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave block @a" TO WS-LINE
     MOVE "commands.playsound.success.multiple(minecraft:ambient.cave,2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "playsound minecraft:ambient.cave block @a" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     MOVE "acceptance US13 /playsound the other target is sent the packet too" TO TL-CASE
     CALL "TC-PACKET-HEX" USING WS-ID-ALICE 119 WS-TEXT
     MOVE 1 TO WS-NUM
     IF WS-TEXT(1:4) = "none"
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /playsound the result is the number of targets" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   Arguments.
     MOVE "acceptance US13 /playsound the minimum volume is accepted" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 1 64 1 1 1 0.5" TO WS-LINE
     MOVE "commands.playsound.success.single(minecraft:ambient.cave,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound the volume may not be negative" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 1 64 1 -1" TO WS-LINE
     MOVE "argument.float.low(0.0,-1.0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound the pitch is at most 2" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 1 64 1 1 3" TO WS-LINE
     MOVE "argument.float.big(2.0,3.0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound the minimum volume is at most 1" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 1 64 1 1 1 2" TO WS-LINE
     MOVE "argument.float.big(1.0,2.0) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound an unknown source word" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave nonsense" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   The sound alone is executable (the listing of 57-4 section 7 marks it): the master source, the one target, the source's position.
     MOVE "acceptance US13 /playsound a sound alone plays on the master source to the source" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave" TO WS-LINE
     MOVE "commands.playsound.success.single(minecraft:ambient.cave,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "playsound minecraft:ambient.cave" TO WS-LINE
     PERFORM FIRST-HEX
     MOVE WS-TEXT TO WS-HEX-1
     MOVE "playsound minecraft:ambient.cave master Opal ~ ~ ~" TO WS-LINE
     PERFORM FIRST-HEX
     MOVE WS-TEXT TO WS-HEX-2
     MOVE "acceptance US13 /playsound a sound alone is the packet of the master source at the source's position" TO TL-CASE
     MOVE WS-HEX-1 TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-HEX-2
     MOVE "acceptance US13 /playsound a player below level 2 does not know the command" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /playsound the console prints the English text" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal" TO WS-LINE
     MOVE "Played sound minecraft:ambient.cave to Opal" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /playsound the console has no default target" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /playsound completion after the sound offers the sources" TO TL-CASE
     MOVE "/playsound minecraft:ambient.cave " TO WS-LINE
     MOVE 34 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 34 0 [ambient,block,hostile,master,music,neutral,player,record,ui,voice,weather]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
*>   Audible distance (54 s10): range 16 (16 x volume above 1); outside it nothing is sent unless minVolume > 0, then the sound is
*>   placed 2 blocks from the listener towards the point at volume minVolume. Opal stands at 0.5 64 0.5, the point is 100 blocks east.
     MOVE "tp Opal 0.5 64.0 0.5" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     MOVE "tp Alice 500.5 64.0 0.5" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /playsound a listener out of range with minVolume 0 is skipped: no one reached is commands.playsound.failed (54 s10)" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 100.5 64.0 0.5" TO WS-LINE
     MOVE "commands.playsound.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound a listener out of range with minVolume 0.5 hears it 2 blocks away at volume 0.5 (54 s10)" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 100.5 64.0 0.5 1 1 0.5" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     STRING "08" "00" "00000014" "00000200" "00000004" "3f000000" "3f800000" "0000000000000000" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /playsound volume 8 has range 128: the point 100 blocks away is in range, sent at the given point and volume (54 s10)" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master Opal 100.5 64.0 0.5 8" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     STRING "08" "00" "00000324" "00000200" "00000004" "41000000" "3f800000" "0000000000000000" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /playsound several targets, one in range: only the player reached is told (single, Opal) (54 s10)" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master @a 0.5 64.0 0.5" TO WS-LINE
     MOVE "commands.playsound.success.single(minecraft:ambient.cave,Opal)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /playsound with minVolume both players are reached: multiple with 2 (54 s10)" TO TL-CASE
     MOVE "playsound minecraft:ambient.cave master @a 0.5 64.0 0.5 1 1 0.5" TO WS-LINE
     MOVE "commands.playsound.success.multiple(minecraft:ambient.cave,2)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The line is run by Opal again and the body of the Sound packet she was sent (hex) is compared with WS-EXPECTED.
 RUN-PACKET.
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE 119 WS-EXPECTED.

*> WS-TEXT: the body (hex) of the first Sound packet the line makes Opal receive.
 FIRST-HEX.
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TC-PACKET-HEX" USING WS-ID-OPAL 119 WS-TEXT.
 END PROGRAM TEST-CMD-PLAYSOUND.

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
