*> Acceptance test of docs/protocol/16-commands-catalog.md §7.7 `locate` (permission level 2): biome searches the generator on the rings of a square around the source (step 32,
*> radius 6400) and answers with the nearest sample, its coordinates and the floor of the distance (commands.locate.biome.success [biome, coordinates, distance], quiet; the result
*> is the distance), none is commands.locate.biome.not_found [biome]; structure and poi find nothing in this world (commands.locate.structure.not_found, commands.locate.poi.not_found
*> [identifier]). The expected nearest sample is found here by a brute-force scan of the square with WORLDGEN-DIM-BIOMES. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE.
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
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-COLUMNS.
    05 WS-COLUMN            BINARY-LONG OCCURS 16 TIMES.
 01 WS-HERE                BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-KEY-HERE            PIC X(32).
 01 WS-KEY-OTHER           PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KM                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-MIN-D2              BINARY-DOUBLE.
 01 WS-REPORT-D2           BINARY-DOUBLE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-PART-A              PIC X(1024).
 01 WS-PART-B              PIC X(1024).
 01 WS-REST                PIC X(1024).
 01 WS-XS                  PIC X(32).
 01 WS-YS                  PIC X(32).
 01 WS-ZS                  PIC X(32).
 01 WS-DS                  PIC X(32).
 01 WS-REPORT-X            BINARY-LONG.
 01 WS-REPORT-Y            BINARY-LONG.
 01 WS-REPORT-Z            BINARY-LONG.
 01 WS-REPORT-D            BINARY-LONG.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Y              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
*>   Opal's block position and the biome of her column.
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE WS-PX TO WS-X
     MOVE WS-PZ TO WS-Z
     PERFORM BIOME-AT
     MOVE WS-BIOME TO WS-HERE
     COMPUTE WS-OTHER = 1 - WS-HERE
     PERFORM KEY-OF-HERE
*>   The biome of her own column is at distance 0.
     MOVE WS-PX TO WS-EDIT-X
     MOVE WS-PY TO WS-EDIT-Y
     MOVE WS-PZ TO WS-EDIT-Z
     MOVE SPACES TO WS-LINE WS-EXPECTED
     STRING "locate biome " FUNCTION TRIM(WS-KEY-HERE) DELIMITED BY SIZE INTO WS-LINE
     STRING "commands.locate.biome.success(" FUNCTION TRIM(WS-KEY-HERE) ",[" FUNCTION TRIM(WS-EDIT-X) ", " FUNCTION TRIM(WS-EDIT-Y)
         ", " FUNCTION TRIM(WS-EDIT-Z) "],0)" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US13 /locate biome the biome of the source's own column is 0 blocks away" TO TL-CASE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate biome the result is the distance (0)" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   The other biome of the main dimension: the nearest sample of the grid of step 32.
     COMPUTE WS-KM = 0
     MOVE WS-OTHER TO WS-HERE
     PERFORM KEY-OF-HERE
     MOVE SPACES TO WS-LINE
     STRING "locate biome " FUNCTION TRIM(WS-KEY-HERE) DELIMITED BY SIZE INTO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     PERFORM PARSE-REPORT
     MOVE "acceptance US13 /locate biome the other biome: the message names the biome" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     STRING "commands.locate.biome.success(" FUNCTION TRIM(WS-KEY-HERE) "," DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(WS-EXPECTED))) TO WS-DISCARD
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-DISCARD
     MOVE "acceptance US13 /locate biome the other biome: the height is the source's" TO TL-CASE
     MOVE WS-PY TO WS-EXPECTED-N
     MOVE WS-REPORT-Y TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE WS-REPORT-X TO WS-X
     MOVE WS-REPORT-Z TO WS-Z
     PERFORM BIOME-AT
     MOVE "acceptance US13 /locate biome the biome at the reported position is the one asked for" TO TL-CASE
     MOVE WS-OTHER TO WS-EXPECTED-N
     MOVE WS-BIOME TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     COMPUTE WS-DX = WS-REPORT-X - WS-PX
     COMPUTE WS-DZ = WS-REPORT-Z - WS-PZ
     COMPUTE WS-REPORT-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
     COMPUTE WS-KM = FUNCTION INTEGER(FUNCTION SQRT(WS-REPORT-D2) / 32) + 2
*>   Brute force: the nearest sample of the grid (px + 32 i, pz + 32 j) that has the biome, over the square that holds the answer.
     MOVE WS-REPORT-D2 TO WS-MIN-D2
     COMPUTE WS-I = 0 - WS-KM
     PERFORM UNTIL WS-I > WS-KM
         COMPUTE WS-J = 0 - WS-KM
         PERFORM UNTIL WS-J > WS-KM
             COMPUTE WS-X = WS-PX + WS-I * 32
             COMPUTE WS-Z = WS-PZ + WS-J * 32
             PERFORM BIOME-AT
             IF WS-BIOME = WS-OTHER
                 COMPUTE WS-D2 = (WS-I * 32) * (WS-I * 32) + (WS-J * 32) * (WS-J * 32)
                 IF WS-D2 < WS-MIN-D2
                     MOVE WS-D2 TO WS-MIN-D2
                 END-IF
             END-IF
             ADD 1 TO WS-J
         END-PERFORM
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US13 /locate biome the other biome: no sample of the grid with the biome is nearer than the reported one" TO TL-CASE
     MOVE WS-REPORT-D2 TO WS-EXPECTED-N
     MOVE WS-MIN-D2 TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /locate biome the other biome: the reported position is on the grid" TO TL-CASE
     COMPUTE WS-DX = FUNCTION MOD(WS-DX, 32)
     COMPUTE WS-DZ = FUNCTION MOD(WS-DZ, 32)
     COMPUTE WS-NUM = WS-DX + WS-DZ
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /locate biome the distance is the floor of the distance of the position" TO TL-CASE
     COMPUTE WS-DISTANCE = FUNCTION INTEGER(FUNCTION SQRT(WS-REPORT-D2))
     MOVE WS-DISTANCE TO WS-EXPECTED-N
     MOVE WS-REPORT-D TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /locate biome the result is the distance" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE WS-DISTANCE TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   Biomes the dimension cannot produce, tags.
     MOVE "acceptance US13 /locate biome ash_flats is not made by the main dimension: Could not find a biome of type" TO TL-CASE
     MOVE "locate biome cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.locate.biome.not_found(cobolcraft:ash_flats)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate biome a tag that holds no biome" TO TL-CASE
     MOVE "locate biome #minecraft:is_no_such" TO WS-LINE
     MOVE "commands.locate.biome.not_found(#minecraft:is_no_such)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate biome the namespace defaults to minecraft:" TO TL-CASE
     MOVE "locate biome plains" TO WS-LINE
     PERFORM RUN-TEXT-START
     MOVE "acceptance US13 /locate biome an unknown biome" TO TL-CASE
     MOVE "locate biome cobolcraft:nope" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nope,minecraft:worldgen/biome) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   The subroutine has the one biome ash_flats everywhere.
     MOVE WS-PX TO WS-EDIT-X
     MOVE WS-PY TO WS-EDIT-Y
     MOVE WS-PZ TO WS-EDIT-Z
     MOVE "acceptance US13 /locate biome in the subroutine ash_flats is where the source stands" TO TL-CASE
     MOVE "execute in cobolcraft:subroutine run locate biome cobolcraft:ash_flats" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     STRING "commands.locate.biome.success(cobolcraft:ash_flats,[" FUNCTION TRIM(WS-EDIT-X) ", " FUNCTION TRIM(WS-EDIT-Y) ", "
         FUNCTION TRIM(WS-EDIT-Z) "],0)" DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate biome in the subroutine plains does not exist" TO TL-CASE
     MOVE "execute in cobolcraft:subroutine run locate biome minecraft:plains" TO WS-LINE
     MOVE "commands.locate.biome.not_found(minecraft:plains)" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   structure and poi.
     MOVE "acceptance US13 /locate structure a tag: Could not find a structure of type nearby" TO TL-CASE
     MOVE "locate structure #minecraft:village" TO WS-LINE
     MOVE "commands.locate.structure.not_found(#minecraft:village)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate structure an id the structure registry does not hold: commands.locate.structure.invalid (16 7.7, T43401)" TO TL-CASE
     MOVE "locate structure minecraft:village" TO WS-LINE
     MOVE "commands.locate.structure.invalid(minecraft:village)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate poi a point of interest: no store, none found" TO TL-CASE
     MOVE "locate poi minecraft:home" TO WS-LINE
     MOVE "commands.locate.poi.not_found(minecraft:home)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate poi a tag" TO TL-CASE
     MOVE "locate poi #minecraft:acquirable_job_site" TO WS-LINE
     MOVE "commands.locate.poi.not_found(#minecraft:acquirable_job_site)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate poi an unknown point of interest" TO TL-CASE
     MOVE "locate poi minecraft:nope" TO WS-LINE
     MOVE "argument.resource.not_found(minecraft:nope,minecraft:point_of_interest_type) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate needs a kind" TO TL-CASE
     MOVE "locate" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /locate a player below level 2 does not know the command" TO TL-CASE
     MOVE "locate poi minecraft:home" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /locate the console prints the English text" TO TL-CASE
     MOVE "locate biome cobolcraft:ash_flats" TO WS-LINE
     MOVE "Could not find a biome of type ""cobolcraft:ash_flats"" within a reasonable distance" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /locate completion offers the three kinds" TO TL-CASE
     MOVE "/locate " TO WS-LINE
     MOVE 8 TO WS-LENGTH
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 8 0 [biome,poi,structure]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> The line is run by Opal and the reply must begin with the success key (the position is not asserted).
 RUN-TEXT-START.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "commands.locate.biome.success(minecraft:plains," TO WS-EXPECTED
     MOVE SPACES TO WS-DISCARD
     MOVE WS-TEXT(1:47) TO WS-DISCARD
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-DISCARD.

*> WS-KEY-HERE: the key of the biome id WS-HERE (0 minecraft:plains, 1 cobolcraft:upland).
 KEY-OF-HERE.
     MOVE "minecraft:plains" TO WS-KEY-HERE
     IF WS-HERE = 1
         MOVE "cobolcraft:upland" TO WS-KEY-HERE
     END-IF.

*> WS-BIOME: the biome of the column at the block position (WS-X, WS-Z) of dimension WS-DIM, from the generator.
 BIOME-AT.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-COLUMNS
     COMPUTE WS-LOCAL = FUNCTION MOD(WS-Z, 16)
     COMPUTE WS-CELL = FUNCTION INTEGER(WS-LOCAL / 4) * 4 + 1
     COMPUTE WS-LOCAL = FUNCTION MOD(WS-X, 16)
     COMPUTE WS-CELL = WS-CELL + FUNCTION INTEGER(WS-LOCAL / 4)
     MOVE WS-COLUMN(WS-CELL) TO WS-BIOME.

*> WS-REPORT-X, -Y, -Z, -D: the numbers of the reply WS-TEXT, commands.locate.biome.success(key,[x, y, z],d).
 PARSE-REPORT.
     UNSTRING WS-TEXT DELIMITED BY "[" INTO WS-PART-A WS-PART-B
     UNSTRING WS-PART-B DELIMITED BY ", " INTO WS-XS WS-YS WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-ZS WS-PART-A
     UNSTRING WS-PART-A DELIMITED BY "," INTO WS-PART-B WS-DS
     UNSTRING WS-DS DELIMITED BY ")" INTO WS-PART-B
     COMPUTE WS-REPORT-X = FUNCTION NUMVAL(WS-XS)
     COMPUTE WS-REPORT-Y = FUNCTION NUMVAL(WS-YS)
     COMPUTE WS-REPORT-Z = FUNCTION NUMVAL(WS-ZS)
     COMPUTE WS-REPORT-D = FUNCTION NUMVAL(WS-PART-B).
 END PROGRAM TEST-CMD-LOCATE.

 COPY CORETEST.
 COPY CMDTEST.
