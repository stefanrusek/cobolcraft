*> Acceptance test of the end city in the End's worldgen (docs/protocol/36-structures-8-nether-and-end.md sections 8 to 11; core/src/struct-endcity-place.cob, end-dim.cob; T13512): on the
*> generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) a start of the end_cities set on an outer island is found (biome, rotation, lowest surface y at least 60), the
*> End chunk that holds it has purpur blocks and publishes the chest requests of the city's treasure and a shulker for every sentry marker in it, the same chunk with the structure off has
*> none, and regenerating it gives the same blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-REGEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY GENENT.
 COPY GENBE.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTEC.
 COPY DIMENSIONS.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-PURPUR              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SET                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-CITY                PIC X(80) VALUE "minecraft:end_city".
 01 WS-SET-KEY             PIC X(80) VALUE "minecraft:end_cities".
 01 WS-CHESTS              BINARY-LONG.
 01 WS-LAST-GB             BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-CITY-ROW            BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
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
         MOVE "acceptance US12 36-8§8 B. End city: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
     MOVE "minecraft:purpur_block" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-PURPUR
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO WS-DIM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
         IF DM-GENERATOR(WS-I) = DIM-GEN-END
             MOVE WS-I TO WS-DIM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         IF SS-KEY(WS-S) = WS-SET-KEY
             MOVE WS-S TO WS-SET
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the end_cities set and the End dimension are loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SET > 0 AND WS-DIM > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-SET = 0 OR WS-DIM = 0
         STOP RUN
     END-IF
*>   the first chunk of a scan of the outer End whose start is valid
     MOVE 0 TO WS-FOUND
     MOVE 0 TO WS-TRIES
     PERFORM VARYING WS-SX FROM 60 BY 1 UNTIL WS-SX > 240 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -60 BY 1 UNTIL WS-SZ > 60 OR WS-FOUND = 1
             CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-SX WS-SZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-TRIES
                 CALL "ENDCITY-FIND-POINT" USING WS-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-VALID
                 IF WS-VALID = 1
                     MOVE 1 TO WS-FOUND
                     MOVE WS-SX TO WS-FX
                     MOVE WS-SZ TO WS-FZ
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-TRIES TO WS-ED
     DISPLAY "PROBE end city start after " FUNCTION TRIM(WS-ED) " candidate chunks: " WS-FX " " WS-FZ " y " WS-Y
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: a valid end city start was found on an outer island" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF
*>   the generic start query builds the same city
     MOVE 0 TO WS-CITY-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-CITY
             MOVE WS-I TO WS-CITY-ROW
         END-IF
     END-PERFORM
     MOVE 0 TO WS-COUNT2
     CALL "STRUCT-FIND-POINT" USING WS-CITY-ROW WS-SEED WS-FX WS-FZ WS-X WS-Y WS-Z WS-VALID
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the generic start query builds the city at its stub (16 cx + 7, y, 16 cz + 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALID = 1 AND SP-COUNT > 4 AND WS-X = WS-FX * 16 + 7 AND WS-Z = WS-FZ * 16 + 7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the lowest surface y of the start is at least 60" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-Y >= 60
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the builder holds the layout as template pieces of kind 16" TO TL-CASE
     MOVE EC-COUNT TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         IF SP-T-KIND(WS-I) NOT = 16 OR SP-X0(WS-I) NOT = EP-X0(WS-I) OR SP-Y0(WS-I) NOT = EP-Y0(WS-I) OR SP-Z0(WS-I) NOT = EP-Z0(WS-I)
             OR SP-X1(WS-I) NOT = EP-X1(WS-I) OR SP-Y1(WS-I) NOT = EP-Y1(WS-I) OR SP-Z1(WS-I) NOT = EP-Z1(WS-I)
             ADD 1 TO WS-COUNT1
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: every template box equals the box of the layout" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the End chunk of the start: the first piece, base_floor, begins at (16 cx + 7, y, 16 cz + 7)
     MOVE 0 TO GB-COUNT GE-COUNT
     CALL "END-DIM-CHUNK" USING WS-DIM WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128 * 256
         IF CE-STATE(WS-I) = WS-PURPUR
             ADD 1 TO WS-COUNT1
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: the start chunk holds purpur blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT1 > 50
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GB-COUNT TO WS-LAST-GB
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: a Chest marker asks for the end_city_treasure table on the chest below" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GB-COUNT >= 1 AND GB-KIND(1) = 1 AND GB-LOOT(1) = "minecraft:chests/end_city_treasure"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§9 B. The template piece, connection arithmetic and data markers: a Sentry marker asks for a shulker" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GE-COUNT >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "PROBE purpur " WS-COUNT1 " block entity requests " GB-COUNT " entity requests " GE-COUNT
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "END-DIM-CHUNK" USING WS-DIM WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128 * 256
         IF CE-STATE(WS-I) = WS-PURPUR
             ADD 1 TO WS-COUNT2
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: regenerating the chunk gives the same purpur blocks" TO TL-CASE
     MOVE WS-COUNT1 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-GATE-RESET"
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "END-DIM-CHUNK" USING WS-DIM WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128 * 256
         IF CE-STATE(WS-I) = WS-PURPUR
             ADD 1 TO WS-COUNT2
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: with the structure off the chunk has no purpur" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-GATE-ON" USING WS-CITY
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-REGEND.

 COPY NOSPAWN.
 COPY CORETEST.
