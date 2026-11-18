*> Implementation test (lane nether, H6 task 2; docs/protocol/37-nether-5 section 3 and 4.1): NETHER-DIM-CHUNK runs the decoration driver
*> (NETHER-GEN-FEATURES) after the terrain (NETHER-GEN-CHUNK) once the tables are ready: the chunk is the terrain of NETHER-GEN-CHUNK plus the placed
*> features of the biomes it holds, byte for byte what the two programs make when called by hand; the features change some cells; the real placed-feature
*> data lists them for the Nether biomes in the `biome` modifier (FR-BIOME-HAS); a chunk takes a bounded time. Needs the generated packs
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-FEATURES-DIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-A                   PIC X(304640).
 01 WS-B                   PIC X(304640).
 01 WS-C                   PIC X(304640).
 01 WS-I                   BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-KEY                 PIC X(80).
 01 WS-FLAG                BINARY-LONG.
 01 WS-T0                  PIC X(21).
 01 WS-T1                  PIC X(21).
 01 WS-S0                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-ELAPSED             BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
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
         MOVE "N" TO TL-MODE
         MOVE "test nether features dim no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE DIM-STANDARD-NETHER TO WS-DIM
*>   A fixed seed: with seed 12345 chunk (1, 4) gets 13 changed cell groups from the compiled leaf types.
     MOVE 12345 TO CW-SEED
     MOVE 1 TO WS-CX
     MOVE 4 TO WS-CZ

*>   The terrain alone, the features by hand on top, and the dimension's own chunk.
     MOVE LOW-VALUES TO WS-A WS-B WS-C
     CALL "NETHER-GEN-CHUNK" USING CW-SEED WS-CX WS-CZ WS-A WS-MARKER
     MOVE WS-A TO WS-C
     CALL "NETHER-GEN-FEATURES" USING CW-SEED WS-CX WS-CZ WS-A WS-PLACED
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-B WS-MARKER

     MOVE "test nether features dim the dimension chunk is the terrain plus NETHER-GEN-FEATURES, byte for byte" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "same" TO TL-EXPECTED
     MOVE "different" TO TL-OBSERVED
     IF WS-A = WS-B
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test nether features dim the chunk selects placed features of its biomes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     IF WS-PLACED > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The features changed some of the terrain's cells (the compiled leaf types place blocks; the others place nothing).
     MOVE 0 TO WS-DIFF
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536 * 16
         IF WS-A(WS-I * 4 - 3:4) NOT = WS-C(WS-I * 4 - 3:4)
             ADD 1 TO WS-DIFF
         END-IF
     END-PERFORM
     MOVE WS-DIFF TO WS-E1
     DISPLAY "features changed bytes groups: " FUNCTION TRIM(WS-E1)
     MOVE "test nether features dim the features place blocks into the terrain of the chunk" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-DIFF > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   The `biome` modifier: the real data lists patch_fire for nether_wastes and no patch_soul_fire for crimson_forest (37-nether-5 section 2).
     MOVE "minecraft:nether_wastes" TO WS-BIOME
     MOVE "minecraft:patch_fire" TO WS-KEY
     CALL "FR-BIOME-HAS" USING WS-BIOME WS-KEY WS-FLAG
     MOVE "test nether features dim the loaded biome data lists patch_fire for nether_wastes (the biome modifier sees the Nether biomes)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:crimson_forest" TO WS-BIOME
     MOVE "minecraft:patch_soul_fire" TO WS-KEY
     CALL "FR-BIOME-HAS" USING WS-BIOME WS-KEY WS-FLAG
     MOVE "test nether features dim the loaded biome data lists no patch_soul_fire for crimson_forest" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Generation time of four chunks, terrain and features, from cold memo tables.
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     MOVE 8 TO WS-CX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE LOW-VALUES TO WS-B
         CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-B WS-MARKER
         ADD 1 TO WS-CX
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     COMPUTE WS-S0 = FUNCTION NUMVAL(WS-T0(9:2)) * 3600 + FUNCTION NUMVAL(WS-T0(11:2)) * 60 + FUNCTION NUMVAL(WS-T0(13:2))
     COMPUTE WS-S1 = FUNCTION NUMVAL(WS-T1(9:2)) * 3600 + FUNCTION NUMVAL(WS-T1(11:2)) * 60 + FUNCTION NUMVAL(WS-T1(13:2))
     COMPUTE WS-ELAPSED = WS-S1 - WS-S0
     MOVE WS-ELAPSED TO WS-SHOW
     DISPLAY "four nether chunks with features took seconds: " FUNCTION TRIM(WS-SHOW)
     MOVE "test nether features dim four chunks with terrain and features take under 60 seconds" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ELAPSED >= 0 AND WS-ELAPSED < 60
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-NETHER-FEATURES-DIM.

 COPY NOSPAWN.
 COPY CORETEST.
