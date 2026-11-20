*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 3 (Stronghold, T1506) and the stronghold rows of section 1 over the generated vanilla-data (CC_GENERATED_DIR,
*> read only; skipped as a pass without it): the set `strongholds` is concentric_rings with distance 32, spread 3, count 128, salt 0, preferred biomes (the tag stronghold_biased_to) and one entry
*> `stronghold` of weight 1; the structure is of type stronghold, step surface_structures, terrain adaptation bury, with biomes (the tag is_overworld); the world gates the stronghold on.
*> (The ring list of 128 chunks is tested by test_struct_36_5_4_1 and the assembly with its portal room by test_struct_stronghold: both are slow on the real biome source.)
*> (The file test_struct_36_5_3.cob is the mineshaft helper test: the task's file name is taken, so this test has its own name.)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-3-STRONGHOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SET                 BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NAME                PIC X(40).
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SEEDU               BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-PORTALS             BINARY-LONG.
 01 WS-TEXT                PIC X(40).
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
         MOVE "acceptance US12 36-5§3 Stronghold: no generated packs here, skipped" TO TL-CASE
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
     CALL "GEN-WORLD-SETUP"
     MOVE "minecraft:strongholds" TO WS-KEY
     CALL "STRUCT-FIND-SET" USING WS-KEY WS-SET
     MOVE "acceptance US12 36-5§3 Stronghold: the structure set strongholds is loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SET > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-SET = 0
         STOP RUN
     END-IF
     MOVE "acceptance US12 36-5§3 Stronghold: the placement is concentric_rings" TO TL-CASE
     MOVE SS-KIND(WS-SET) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3 Stronghold: distance 32, spread 3, count 128" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-DISTANCE(WS-SET) * 1000000 + SS-RING-SPREAD(WS-SET) * 1000 + SS-RING-COUNT(WS-SET)
     MOVE 32003128 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3 Stronghold: salt 0 and one entry" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-SALT(WS-SET) * 10 + SS-EN-COUNT(WS-SET)
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3 Stronghold: the entry is the structure stronghold with weight 1" TO TL-CASE
     MOVE SE-STRUCT(SS-EN-FIRST(WS-SET)) TO WS-STRUCT
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-KEY(WS-STRUCT) = "minecraft:stronghold" AND SE-WEIGHT(SS-EN-FIRST(WS-SET)) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3 Stronghold: the set has preferred biomes (stronghold_biased_to)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SS-PREF-COUNT(WS-SET) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KIND
     MOVE SDT-TYPE(WS-STRUCT) TO WS-ID
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
     MOVE "acceptance US12 36-5§3 Stronghold: the structure's type is stronghold" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "stronghold" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-KIND
     MOVE SDT-STEP(WS-STRUCT) TO WS-ID
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
     MOVE "acceptance US12 36-5§3 Stronghold: the step is surface_structures" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "surface_structures" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-KIND
     MOVE SDT-ADAPT(WS-STRUCT) TO WS-ID
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
     MOVE "acceptance US12 36-5§3 Stronghold: the terrain adaptation is bury" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "bury" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§3 Stronghold: its biomes (is_overworld) are many (at least 40)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-BIOME-COUNT(WS-STRUCT) >= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:stronghold" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE "acceptance US12 36-5§3 Stronghold: a standard world has the stronghold gated on" TO TL-CASE
     MOVE WS-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-5-3-STRONGHOLD.
 COPY CORETEST.
