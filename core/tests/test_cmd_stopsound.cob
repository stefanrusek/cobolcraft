*> Acceptance test of docs/protocol/16-commands-catalog.md §7.10 `stopsound` (permission level 2): each target is sent Stop Sound 0x79 (05b: flags 1 = a source, 2 = a sound
*> name; the source's ordinal; the sound's identifier, minecraft: when it has no namespace); the message is broadcast (source and sound, a source alone, a sound alone with
*> `*`, neither) and the result is the number of targets. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-STOPSOUND.
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
*>   Neither a source nor a sound.
     MOVE "acceptance US13 /stopsound the target alone: Stopped all sounds" TO TL-CASE
     MOVE "stopsound Opal" TO WS-LINE
     MOVE "commands.stopsound.success.sourceless.any()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound the packet has no flags" TO TL-CASE
     MOVE "00" TO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /stopsound * is any source" TO TL-CASE
     MOVE "stopsound Opal *" TO WS-LINE
     MOVE "commands.stopsound.success.sourceless.any()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound * sends no flags either" TO TL-CASE
     MOVE "00" TO WS-EXPECTED
     PERFORM RUN-PACKET
*>   Every source: Stopped all 'x' sounds, flag 1 and the ordinal.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE SPACES TO WS-LINE TL-CASE WS-EXPECTED
         STRING "stopsound Opal " FUNCTION TRIM(WS-SOURCE(WS-I)) DELIMITED BY SIZE INTO WS-LINE
         STRING "commands.stopsound.success.source.any(" FUNCTION TRIM(WS-SOURCE(WS-I)) ")" DELIMITED BY SIZE INTO WS-EXPECTED
         STRING "acceptance US13 /stopsound the source " FUNCTION TRIM(WS-SOURCE(WS-I)) ": Stopped all sounds of it"
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM RUN-TEXT
         MOVE SPACES TO TL-CASE WS-EXPECTED
         STRING "acceptance US13 /stopsound the packet of the source " FUNCTION TRIM(WS-SOURCE(WS-I)) " is flag 1 and its ordinal"
             DELIMITED BY SIZE INTO TL-CASE
         STRING "01" WS-ORDINAL(WS-I) DELIMITED BY SIZE INTO WS-EXPECTED
         PERFORM RUN-PACKET
     END-PERFORM
*>   A sound.
     MOVE "acceptance US13 /stopsound * with a sound: Stopped sound 'minecraft:ambient.cave'" TO TL-CASE
     MOVE "stopsound Opal * minecraft:ambient.cave" TO WS-LINE
     MOVE "commands.stopsound.success.sourceless.sound(minecraft:ambient.cave)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound the packet is flag 2 and the identifier" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "02" "16" "6d696e6563726166743a616d6269656e742e63617665" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
     MOVE "acceptance US13 /stopsound a source and a sound, the namespace defaults to minecraft:" TO TL-CASE
     MOVE "stopsound Opal ambient ambient.cave" TO WS-LINE
     MOVE "commands.stopsound.success.source.sound(minecraft:ambient.cave,ambient)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound the packet is flags 3, the source, the identifier" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "0308" "16" "6d696e6563726166743a616d6269656e742e63617665" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-PACKET
*>   Several targets.
     MOVE "stopsound @a" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     MOVE "acceptance US13 /stopsound every target is sent the packet" TO TL-CASE
     MOVE "00" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE 121 WS-EXPECTED
     MOVE "acceptance US13 /stopsound the result is the number of targets" TO TL-CASE
     MOVE "stopsound @a" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /stopsound no target: No player was found" TO TL-CASE
     MOVE "stopsound Nobody" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound an unknown source word" TO TL-CASE
     MOVE "stopsound Opal nonsense" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /stopsound a player below level 2 does not know the command" TO TL-CASE
     MOVE "stopsound Opal" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /stopsound the console prints the English text" TO TL-CASE
     MOVE "stopsound Opal master" TO WS-LINE
     MOVE "Stopped all 'master' sounds" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /stopsound completion after the targets offers * and the sources" TO TL-CASE
     MOVE "/stopsound Opal " TO WS-LINE
     MOVE 16 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 16 0 [*,ambient,block,hostile,master,music,neutral,player,record,ui,voice,weather]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The line is run by Opal again and the body of the Stop Sound packet she was sent (hex) is compared with WS-EXPECTED.
 RUN-PACKET.
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE 121 WS-EXPECTED.
 END PROGRAM TEST-CMD-STOPSOUND.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
