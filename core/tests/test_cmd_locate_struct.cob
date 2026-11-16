*> Real-data test of /locate structure (docs/protocol/16 section 7.7; core/src/cmd-locate.cob; lane bugsw T10301): on the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a
*> pass without it) a standard world of seed 3 is opened, the swamp hut is found by the command from the origin and the answer is checked against STRUCT-CHUNK-STARTS: the chunk of the
*> reported position holds a swamp hut start, the message is commands.locate.structure.success [structure, [x, ~, z], distance] and the distance is the horizontal floor. A structure
*> that has no set in the data (the stronghold's ring set is not searched) and a structure tag are answered too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-STRUCT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PART-A              PIC X(1024).
 01 WS-PART-B              PIC X(1024).
 01 WS-REST                PIC X(1024).
 01 WS-XS                  PIC X(32).
 01 WS-YS                  PIC X(32).
 01 WS-ZS                  PIC X(32).
 01 WS-DS                  PIC X(32).
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-RD                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HUT-ROW             BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test cmd locate struct no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "3" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE 0 TO WS-HUT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:swamp_hut"
             MOVE WS-I TO WS-HUT-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US13 /locate structure the swamp hut is one of the structures of the data" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-HUT-ROW > 0
         MOVE 1 TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "locate structure minecraft:swamp_hut" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /locate structure the swamp hut is found: commands.locate.structure.success" TO TL-CASE
     MOVE "commands.locate.structure.success(minecraft:swamp_hut," TO WS-EXPECTED
     MOVE SPACES TO WS-DISCARD
     MOVE WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(WS-EXPECTED))) TO WS-DISCARD
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-DISCARD
     PERFORM PARSE-REPORT
*>   The chunk of the reported position holds a swamp hut start.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-RX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-RZ / 16)
     CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-CX WS-CZ WS-COUNT
     MOVE 0 TO WS-HAS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF SC-STRUCT(WS-I) = WS-HUT-ROW
             MOVE 1 TO WS-HAS
         END-IF
     END-PERFORM
     MOVE "acceptance US13 /locate structure the chunk of the reported position holds a swamp hut start" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-HAS TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     COMPUTE WS-DX = WS-RX - WS-PX
     COMPUTE WS-DZ = WS-RZ - WS-PZ
     COMPUTE WS-NUM = FUNCTION INTEGER(FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ))
     MOVE "acceptance US13 /locate structure the distance is the floor of the horizontal distance" TO TL-CASE
     MOVE WS-RD TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /locate structure the result is the distance" TO TL-CASE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE WS-RD TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   A tag that holds the swamp hut: the answer names the tag.
     MOVE "locate structure #minecraft:swamp_hut" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /locate structure a structure tag is searched too (the answer is a success or not_found, never an error)" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-NUM
     IF WS-TEXT(1:34) = "commands.locate.structure.success(" OR WS-TEXT(1:38) = "commands.locate.structure.not_found(#m"
         MOVE 1 TO WS-NUM
     END-IF
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     STOP RUN.

*> WS-RX, WS-RZ, WS-RD: the numbers of the reply WS-TEXT, commands.locate.structure.success(key,[x, ~, z],d).
 PARSE-REPORT.
     UNSTRING WS-TEXT DELIMITED BY "[" INTO WS-PART-A WS-PART-B
     UNSTRING WS-PART-B DELIMITED BY ", " INTO WS-XS WS-YS WS-REST
     UNSTRING WS-REST DELIMITED BY "]" INTO WS-ZS WS-PART-A
     UNSTRING WS-PART-A DELIMITED BY "," INTO WS-PART-B WS-DS
     UNSTRING WS-DS DELIMITED BY ")" INTO WS-PART-B
     COMPUTE WS-RX = FUNCTION NUMVAL(WS-XS)
     COMPUTE WS-RZ = FUNCTION NUMVAL(WS-ZS)
     COMPUTE WS-RD = FUNCTION NUMVAL(WS-PART-B).
 END PROGRAM TEST-CMD-LOCATE-STRUCT.

 COPY CORETEST.
 COPY CMDTEST.
