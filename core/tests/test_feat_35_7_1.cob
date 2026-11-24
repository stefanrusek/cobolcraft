*> Real-data test (skipped as a pass without the generated packs; T1270, docs/protocol/35-worldgen-features-7-nether-end-misc.md section 1): how the data pack reaches the nether, end and misc features.
*> Each row of the table: the biome that lists the placed feature in the step the table names (F355-BIOME-HAS, exactly one biome listing it in that step: F355-RUNS-IN), and the modifier
*> list of the placed feature (the count the table gives, FD-GET-PF), and the four data features that no placed feature names (end_podium_active, end_podium_inactive, end_gateway_delayed,
*> bonus_chest): no biome lists them in any step.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-FULL                PIC X(80).
 01 WS-BIOME               PIC X(80).
 01 WS-STEP                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-EDIT                PIC Z9.
 01 WS-ROWS.
*>  placed feature, biome, decoration step, number of placement modifiers (the biome filter included)
    05 FILLER PIC X(32) VALUE "delta".
    05 FILLER PIC X(32) VALUE "basalt_deltas".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "small_basalt_columns".
    05 FILLER PIC X(32) VALUE "basalt_deltas".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "large_basalt_columns".
    05 FILLER PIC X(32) VALUE "basalt_deltas".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "basalt_pillar".
    05 FILLER PIC X(32) VALUE "soul_sand_valley".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "basalt_blobs".
    05 FILLER PIC X(32) VALUE "basalt_deltas".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "blackstone_blobs".
    05 FILLER PIC X(32) VALUE "basalt_deltas".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "ice_spike".
    05 FILLER PIC X(32) VALUE "ice_spikes".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "end_spike".
    05 FILLER PIC X(32) VALUE "the_end".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(32) VALUE "end_platform".
    05 FILLER PIC X(32) VALUE "the_end".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(32) VALUE "end_gateway_return".
    05 FILLER PIC X(32) VALUE "end_highlands".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "chorus_plant".
    05 FILLER PIC X(32) VALUE "end_highlands".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "end_island_decorated".
    05 FILLER PIC X(32) VALUE "small_end_islands".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "void_start_platform".
    05 FILLER PIC X(32) VALUE "the_void".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 99 VALUE 1.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 13 TIMES.
       10 WS-R-KEY         PIC X(32).
       10 WS-R-BIOME       PIC X(32).
       10 WS-R-STEP        PIC 99.
       10 WS-R-MODS        PIC 99.
 01 WS-CODE.
    05 FILLER PIC X(32) VALUE "end_podium_active".
    05 FILLER PIC X(32) VALUE "end_podium_inactive".
    05 FILLER PIC X(32) VALUE "end_gateway_delayed".
    05 FILLER PIC X(32) VALUE "bonus_chest".
 01 WS-CD REDEFINES WS-CODE.
    05 WS-CD-KEY           PIC X(32) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 35-7§1 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "BIOMES-LOAD" USING WS-DIR WS-STATUS
     CALL "FD-RESET"
     CALL "FD-SET-DIR" USING WS-DIR

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         MOVE SPACES TO WS-KEY WS-BIOME
         MOVE WS-R-KEY(WS-I) TO WS-KEY
         MOVE WS-R-BIOME(WS-I) TO WS-BIOME
         MOVE WS-R-STEP(WS-I) TO WS-STEP
         MOVE WS-STEP TO WS-EDIT
         CALL "F355-BIOME-HAS" USING WS-BIOME WS-KEY WS-STEP WS-FLAG
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 35-7§1 " FUNCTION TRIM(WS-KEY) " is listed by " FUNCTION TRIM(WS-BIOME) " in step " WS-EDIT
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FLAG TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "F355-RUNS-IN" USING WS-KEY WS-STEP WS-COUNT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 35-7§1 " FUNCTION TRIM(WS-KEY) " is listed by that one biome only"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-FULL
         STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-FULL
         CALL "FD-GET-PF" USING WS-FULL WS-PF
         CALL "FD-ENSURE-PF" USING WS-PF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 35-7§1 " FUNCTION TRIM(WS-KEY) " has the modifier list of the table"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-R-MODS(WS-I) TO TL-EXPECTED-N
         MOVE PF-MD-COUNT(WS-PF) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-CD-KEY(WS-I) TO WS-KEY
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 10
             CALL "F355-RUNS-IN" USING WS-KEY WS-S WS-COUNT
             ADD WS-COUNT TO WS-BAD
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 35-7§1 end_podium_*, end_gateway_delayed and bonus_chest are in no biome (only code reaches them)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-35-7-1.
