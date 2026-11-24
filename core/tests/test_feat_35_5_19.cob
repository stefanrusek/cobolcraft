*> Real-data test (skipped as a pass without the generated packs; T1252, docs/protocol/35-worldgen-features-5-water-and-surface.md section 19): where the placed features of this document run.
*> The biome files of the generated vanilla data are loaded (BIOMES-LOAD); F355-RUNS-IN counts the biomes that list a placed feature in a decoration step, and F355-BIOME-HAS asks about one biome.
*> Every row of the section's table is a case (the step and the biome count; the ranges where the document says 54 to 56), the nether, end and frozen groups are checked by biome name, and the
*> features the document says are in no biome (pile_*, bonus_chest, fill_layer) are in none, in no step.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-19.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-BIOME               PIC X(80).
 01 WS-STEP                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-TOTAL-SG            BINARY-LONG.
 01 WS-EDIT                PIC Z9.
 01 WS-ROWS.
*>  placed feature id, step, lowest and highest biome count
    05 FILLER PIC X(40) VALUE "lake_lava_underground".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC X(40) VALUE "lake_lava_surface".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC X(40) VALUE "sulfur_pool".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "forest_rock".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC X(40) VALUE "iceberg_packed".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC X(40) VALUE "iceberg_blue".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC X(40) VALUE "blue_ice".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC X(40) VALUE "ice_spike".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "ice_patch".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "desert_well".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "disk_clay".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 999 VALUE 54.
    05 FILLER PIC 999 VALUE 56.
    05 FILLER PIC X(40) VALUE "disk_sand".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 999 VALUE 54.
    05 FILLER PIC 999 VALUE 56.
    05 FILLER PIC X(40) VALUE "disk_gravel".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 999 VALUE 54.
    05 FILLER PIC 999 VALUE 56.
    05 FILLER PIC X(40) VALUE "underwater_magma".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 999 VALUE 54.
    05 FILLER PIC 999 VALUE 56.
    05 FILLER PIC X(40) VALUE "disk_grass".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "spring_open".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC X(40) VALUE "spring_closed".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC X(40) VALUE "spring_delta".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "basalt_blobs".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "blackstone_blobs".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "spring_water".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC X(40) VALUE "spring_lava".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC 999 VALUE 55.
    05 FILLER PIC X(40) VALUE "spring_lava_frozen".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC X(40) VALUE "spring_lava".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC X(40) VALUE "warm_ocean_vegetation".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "sea_pickle".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC 999 VALUE 1.
    05 FILLER PIC X(40) VALUE "kelp_cold".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC 999 VALUE 4.
    05 FILLER PIC X(40) VALUE "kelp_warm".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC 999 VALUE 2.
    05 FILLER PIC X(40) VALUE "freeze_top_layer".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC 999 VALUE 56.
    05 FILLER PIC 999 VALUE 56.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 29 TIMES.
       10 WS-R-KEY         PIC X(40).
       10 WS-R-STEP        PIC 99.
       10 WS-R-LO          PIC 999.
       10 WS-R-HI          PIC 999.
 01 WS-SEAGRASS.
    05 FILLER PIC X(40) VALUE "seagrass_cold".
    05 FILLER PIC X(40) VALUE "seagrass_deep".
    05 FILLER PIC X(40) VALUE "seagrass_deep_cold".
    05 FILLER PIC X(40) VALUE "seagrass_deep_warm".
    05 FILLER PIC X(40) VALUE "seagrass_normal".
    05 FILLER PIC X(40) VALUE "seagrass_river".
    05 FILLER PIC X(40) VALUE "seagrass_swamp".
    05 FILLER PIC X(40) VALUE "seagrass_warm".
 01 WS-SG REDEFINES WS-SEAGRASS.
    05 WS-SG-KEY           PIC X(40) OCCURS 8 TIMES.
 01 WS-NONE.
    05 FILLER PIC X(40) VALUE "pile_hay".
    05 FILLER PIC X(40) VALUE "pile_melon".
    05 FILLER PIC X(40) VALUE "pile_snow".
    05 FILLER PIC X(40) VALUE "pile_ice".
    05 FILLER PIC X(40) VALUE "pile_pumpkin".
    05 FILLER PIC X(40) VALUE "bonus_chest".
    05 FILLER PIC X(40) VALUE "fill_layer".
 01 WS-NO REDEFINES WS-NONE.
    05 WS-NO-KEY           PIC X(40) OCCURS 7 TIMES.
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
         MOVE "acceptance US12 35-5§19 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "BIOMES-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 35-5§19 the 67 biome files load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the table: step and count of each row
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         MOVE SPACES TO WS-KEY
         MOVE WS-R-KEY(WS-I) TO WS-KEY
         MOVE WS-R-STEP(WS-I) TO WS-STEP
         CALL "F355-RUNS-IN" USING WS-KEY WS-STEP WS-COUNT
         MOVE WS-STEP TO WS-EDIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 35-5§19 " FUNCTION TRIM(WS-KEY) " in step " WS-EDIT " is listed by the biome count of the table"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-R-LO(WS-I) TO WS-LO
         MOVE WS-R-HI(WS-I) TO WS-HI
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-COUNT >= WS-LO AND WS-COUNT <= WS-HI
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         IF TL-OBSERVED-N = 0
             DISPLAY "  " FUNCTION TRIM(WS-KEY) " step " WS-STEP " counted " WS-COUNT
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       and in no other step
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 10
             IF WS-S NOT = WS-STEP
                 CALL "F355-RUNS-IN" USING WS-KEY WS-S WS-COUNT
                 IF WS-COUNT > 0 AND WS-KEY NOT = "spring_lava"
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 35-5§19 " FUNCTION TRIM(WS-KEY) " (step " WS-EDIT ") runs in no other step"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the seagrass placed features: ten biome entries over the eight ids (swamp and warm two each) in step 9
     MOVE 0 TO WS-TOTAL-SG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-KEY
         MOVE WS-SG-KEY(WS-I) TO WS-KEY
         MOVE 9 TO WS-STEP
         CALL "F355-RUNS-IN" USING WS-KEY WS-STEP WS-COUNT
         ADD WS-COUNT TO WS-TOTAL-SG
     END-PERFORM
     MOVE "acceptance US12 35-5§19 seagrass_* is listed by 10 biome entries in step 9 (table row: ten named biomes)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-TOTAL-SG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   named biomes
     PERFORM CHECK-BIOMES

*>   pile_*, bonus_chest, fill_layer are in no biome
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-KEY
         MOVE WS-NO-KEY(WS-I) TO WS-KEY
         PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 10
             CALL "F355-RUNS-IN" USING WS-KEY WS-S WS-COUNT
             ADD WS-COUNT TO WS-BAD
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 35-5§19 pile_*, bonus_chest and fill_layer are in no biome" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an unknown step or a missing feature counts none
     MOVE "lake_lava_surface" TO WS-KEY
     MOVE 11 TO WS-STEP
     CALL "F355-RUNS-IN" USING WS-KEY WS-STEP WS-COUNT
     MOVE "acceptance US12 35-5§19 a step above 10 counts no biome" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-BIOMES.
     MOVE "desert" TO WS-BIOME
     MOVE "desert_well" TO WS-KEY
     MOVE 4 TO WS-STEP
     MOVE "acceptance US12 35-5§19 desert lists desert_well in step 4" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "ice_spikes" TO WS-BIOME
     MOVE "ice_spike" TO WS-KEY
     MOVE "acceptance US12 35-5§19 ice_spikes lists ice_spike in step 4" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "ice_patch" TO WS-KEY
     MOVE "acceptance US12 35-5§19 ice_spikes lists ice_patch in step 4" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "frozen_ocean" TO WS-BIOME
     MOVE "blue_ice" TO WS-KEY
     MOVE "acceptance US12 35-5§19 frozen_ocean lists blue_ice in step 4" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "deep_frozen_ocean" TO WS-BIOME
     MOVE 2 TO WS-STEP
     MOVE "iceberg_blue" TO WS-KEY
     MOVE "acceptance US12 35-5§19 deep_frozen_ocean lists iceberg_blue in step 2" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "old_growth_pine_taiga" TO WS-BIOME
     MOVE "forest_rock" TO WS-KEY
     MOVE "acceptance US12 35-5§19 old_growth_pine_taiga lists forest_rock in step 2" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "old_growth_spruce_taiga" TO WS-BIOME
     MOVE "acceptance US12 35-5§19 old_growth_spruce_taiga lists forest_rock in step 2" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "sulfur_caves" TO WS-BIOME
     MOVE "sulfur_pool" TO WS-KEY
     MOVE 1 TO WS-STEP
     MOVE "acceptance US12 35-5§19 sulfur_caves lists sulfur_pool in step 1" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "mangrove_swamp" TO WS-BIOME
     MOVE "disk_grass" TO WS-KEY
     MOVE 6 TO WS-STEP
     MOVE "acceptance US12 35-5§19 mangrove_swamp lists disk_grass in step 6" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "basalt_deltas" TO WS-BIOME
     MOVE "basalt_blobs" TO WS-KEY
     MOVE 7 TO WS-STEP
     MOVE "acceptance US12 35-5§19 basalt_deltas lists basalt_blobs in step 7" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "nether_wastes" TO WS-BIOME
     MOVE "spring_open" TO WS-KEY
     MOVE "acceptance US12 35-5§19 nether_wastes lists spring_open in step 7" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "spring_lava" TO WS-KEY
     MOVE 9 TO WS-STEP
     MOVE "acceptance US12 35-5§19 nether_wastes lists spring_lava again in step 9" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "frozen_peaks" TO WS-BIOME
     MOVE "spring_lava_frozen" TO WS-KEY
     MOVE 8 TO WS-STEP
     MOVE "acceptance US12 35-5§19 frozen_peaks lists spring_lava_frozen in step 8" TO TL-CASE
     PERFORM EXPECT-HAS
     MOVE "warm_ocean" TO WS-BIOME
     MOVE "sea_pickle" TO WS-KEY
     MOVE 9 TO WS-STEP
     MOVE "acceptance US12 35-5§19 warm_ocean lists sea_pickle in step 9" TO TL-CASE
     PERFORM EXPECT-HAS
*>   a biome that does not list it: plains has no desert_well, no such biome has none
     MOVE "plains" TO WS-BIOME
     MOVE "desert_well" TO WS-KEY
     MOVE 4 TO WS-STEP
     MOVE "acceptance US12 35-5§19 plains does not list desert_well" TO TL-CASE
     CALL "F355-BIOME-HAS" USING WS-BIOME WS-KEY WS-STEP WS-FLAG
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "no_such_biome" TO WS-BIOME
     MOVE "acceptance US12 35-5§19 an unknown biome lists nothing" TO TL-CASE
     CALL "F355-BIOME-HAS" USING WS-BIOME WS-KEY WS-STEP WS-FLAG
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 EXPECT-HAS.
     CALL "F355-BIOME-HAS" USING WS-BIOME WS-KEY WS-STEP WS-FLAG
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-5-19.
