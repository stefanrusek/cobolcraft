*> Acceptance test of the three ocean structure families at a glance (docs/protocol/36-structures-6-ocean.md section 1; core/src/struct-data.cob) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a
*> pass without it): the five structures with their types and fields (biome_temp, large_probability, cluster_probability, is_beached), the common settings (step surface_structures, terrain_adaptation none), the three structure sets
*> with their placement (random_spread, spacing, separation, salt, spread type) and members (weight 1), and the biomes of every structure (the tags has_structure/*, and the surrounding tag of the monument).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-1.
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
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-KIND-TYPE           BINARY-LONG VALUE 1.
 01 WS-KIND-STEP           BINARY-LONG VALUE 8.
 01 WS-KIND-ADAPT          BINARY-LONG VALUE 4.
 01 WS-NAME                PIC X(40).
 01 WS-LABEL               PIC X(80).
 01 WS-WANT                PIC X(40).
 01 WS-BIOME               PIC X(40).
 01 WS-D                   FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-R-WARM              BINARY-LONG.
 01 WS-R-COLD              BINARY-LONG.
 01 WS-R-SHIP              BINARY-LONG.
 01 WS-R-BEACH             BINARY-LONG.
 01 WS-R-MON               BINARY-LONG.
 01 WS-SET-RUIN            BINARY-LONG.
 01 WS-SET-SHIP            BINARY-LONG.
 01 WS-SET-MON             BINARY-LONG.
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
         MOVE "acceptance US12 36-6§1 The three families at a glance: no generated packs here, skipped" TO TL-CASE
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:ocean_ruin_warm"
                 MOVE WS-I TO WS-R-WARM
             WHEN "minecraft:ocean_ruin_cold"
                 MOVE WS-I TO WS-R-COLD
             WHEN "minecraft:shipwreck"
                 MOVE WS-I TO WS-R-SHIP
             WHEN "minecraft:shipwreck_beached"
                 MOVE WS-I TO WS-R-BEACH
             WHEN "minecraft:monument"
                 MOVE WS-I TO WS-R-MON
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         EVALUATE SS-KEY(WS-I)
             WHEN "minecraft:ocean_ruins"
                 MOVE WS-I TO WS-SET-RUIN
             WHEN "minecraft:shipwrecks"
                 MOVE WS-I TO WS-SET-SHIP
             WHEN "minecraft:ocean_monuments"
                 MOVE WS-I TO WS-SET-MON
         END-EVALUATE
     END-PERFORM
*>   the types and their fields
     MOVE WS-R-COLD TO WS-S
     MOVE "ocean_ruin" TO WS-WANT
     MOVE "ocean_ruin_cold" TO WS-LABEL
     PERFORM TYPE-CASE
     MOVE WS-R-WARM TO WS-S
     MOVE "ocean_ruin_warm" TO WS-LABEL
     PERFORM TYPE-CASE
     MOVE WS-R-SHIP TO WS-S
     MOVE "shipwreck" TO WS-WANT
     MOVE "shipwreck" TO WS-LABEL
     PERFORM TYPE-CASE
     MOVE WS-R-BEACH TO WS-S
     MOVE "shipwreck_beached" TO WS-LABEL
     PERFORM TYPE-CASE
     MOVE WS-R-MON TO WS-S
     MOVE "ocean_monument" TO WS-WANT
     MOVE "monument" TO WS-LABEL
     PERFORM TYPE-CASE
     MOVE "acceptance US12 36-6§1 The three families at a glance: biome_temp is cold for ocean_ruin_cold (0) and warm for ocean_ruin_warm (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-VARIANT(WS-R-COLD) = 0 AND SDT-VARIANT(WS-R-WARM) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§1 The three families at a glance: is_beached is true only for shipwreck_beached" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-VARIANT(WS-R-SHIP) = 0 AND SDT-VARIANT(WS-R-BEACH) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.3 TO WS-F32
     MOVE WS-F32 TO WS-D
     MOVE "acceptance US12 36-6§1 The three families at a glance: large_probability 0.3 and cluster_probability 0.9 of both ruins (float32)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SDT-LARGE(WS-R-COLD) = WS-D AND SDT-LARGE(WS-R-WARM) = WS-D
         MOVE 0.9 TO WS-F32
         MOVE WS-F32 TO WS-D
         IF SDT-CLUSTER(WS-R-COLD) = WS-D AND SDT-CLUSTER(WS-R-WARM) = WS-D
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the sets
     MOVE WS-SET-RUIN TO WS-S
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_ruins is random_spread, spacing 20, separation 8, salt 14357621, linear" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SS-KIND(WS-S) = 2 AND SS-SPACING(WS-S) = 20 AND SS-SEPARATION(WS-S) = 8 AND SS-SALT(WS-S) = 14357621 AND SS-SPREAD(WS-S) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SET-SHIP TO WS-S
     MOVE "acceptance US12 36-6§1 The three families at a glance: shipwrecks is random_spread, spacing 24, separation 4, salt 165745295, linear" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SS-KIND(WS-S) = 2 AND SS-SPACING(WS-S) = 24 AND SS-SEPARATION(WS-S) = 4 AND SS-SALT(WS-S) = 165745295 AND SS-SPREAD(WS-S) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SET-MON TO WS-S
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_monuments is random_spread, spacing 32, separation 5, salt 10387313, triangular" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SS-KIND(WS-S) = 2 AND SS-SPACING(WS-S) = 32 AND SS-SEPARATION(WS-S) = 5 AND SS-SALT(WS-S) = 10387313 AND SS-SPREAD(WS-S) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_ruins has the members ocean_ruin_cold and ocean_ruin_warm, weight 1 each" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     MOVE WS-SET-RUIN TO WS-S
     IF SS-EN-COUNT(WS-S) = 2 AND SE-WEIGHT(SS-EN-FIRST(WS-S)) = 1 AND SE-WEIGHT(SS-EN-FIRST(WS-S) + 1) = 1
         COMPUTE WS-I = SE-STRUCT(SS-EN-FIRST(WS-S))
         COMPUTE WS-J = SE-STRUCT(SS-EN-FIRST(WS-S) + 1)
         IF (WS-I = WS-R-COLD AND WS-J = WS-R-WARM) OR (WS-I = WS-R-WARM AND WS-J = WS-R-COLD)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§1 The three families at a glance: shipwrecks has shipwreck and shipwreck_beached, weight 1 each" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     MOVE WS-SET-SHIP TO WS-S
     IF SS-EN-COUNT(WS-S) = 2 AND SE-WEIGHT(SS-EN-FIRST(WS-S)) = 1 AND SE-WEIGHT(SS-EN-FIRST(WS-S) + 1) = 1
         COMPUTE WS-I = SE-STRUCT(SS-EN-FIRST(WS-S))
         COMPUTE WS-J = SE-STRUCT(SS-EN-FIRST(WS-S) + 1)
         IF (WS-I = WS-R-SHIP AND WS-J = WS-R-BEACH) OR (WS-I = WS-R-BEACH AND WS-J = WS-R-SHIP)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_monuments has the one member monument, weight 1" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     MOVE WS-SET-MON TO WS-S
     IF SS-EN-COUNT(WS-S) = 1 AND SE-WEIGHT(SS-EN-FIRST(WS-S)) = 1 AND SE-STRUCT(SS-EN-FIRST(WS-S)) = WS-R-MON
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the biomes
     MOVE WS-R-COLD TO WS-S
     MOVE 6 TO WS-N
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_ruin_cold has exactly the six cold and neutral oceans" TO TL-CASE
     PERFORM BIOME-COUNT
     MOVE "minecraft:frozen_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:cold_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:deep_frozen_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:deep_cold_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:deep_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE WS-R-WARM TO WS-S
     MOVE 3 TO WS-N
     MOVE "acceptance US12 36-6§1 The three families at a glance: ocean_ruin_warm has exactly the three warm oceans" TO TL-CASE
     PERFORM BIOME-COUNT
     MOVE "minecraft:lukewarm_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:warm_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:deep_lukewarm_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE WS-R-SHIP TO WS-S
     MOVE "minecraft:warm_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:deep_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:beach" TO WS-BIOME
     PERFORM BIOME-HAS-NOT
     MOVE WS-R-BEACH TO WS-S
     MOVE "minecraft:beach" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:snowy_beach" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:ocean" TO WS-BIOME
     PERFORM BIOME-HAS-NOT
     MOVE WS-R-MON TO WS-S
     MOVE 4 TO WS-N
     MOVE "acceptance US12 36-6§1 The three families at a glance: the monument's biomes are the four deep oceans (is_deep_ocean)" TO TL-CASE
     PERFORM BIOME-COUNT
     MOVE "minecraft:deep_ocean" TO WS-BIOME
     PERFORM BIOME-HAS
     MOVE "minecraft:ocean" TO WS-BIOME
     PERFORM BIOME-HAS-NOT
     STOP RUN.

*> the type name WS-WANT, the step surface_structures and the adjustment none of the structure row WS-S
 TYPE-CASE.
     CALL "STRUCT-ENUM-NAME" USING WS-KIND-TYPE SDT-TYPE(WS-S) WS-NAME
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-6§1 The three families at a glance: " FUNCTION TRIM(WS-LABEL) " is of the type " FUNCTION TRIM(WS-WANT) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NAME = WS-WANT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-6§1 The three families at a glance: " FUNCTION TRIM(WS-LABEL) " has the step surface_structures and no terrain adaptation" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     CALL "STRUCT-ENUM-NAME" USING WS-KIND-STEP SDT-STEP(WS-S) WS-NAME
     IF WS-NAME = "surface_structures"
         CALL "STRUCT-ENUM-NAME" USING WS-KIND-ADAPT SDT-ADAPT(WS-S) WS-NAME
         IF WS-NAME = "none"
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> SDT-BIOME-COUNT of the structure row WS-S against WS-N (the case name is in TL-CASE)
 BIOME-COUNT.
     MOVE WS-N TO TL-EXPECTED-N
     MOVE SDT-BIOME-COUNT(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 BIOME-FIND.
     MOVE 0 TO WS-FLAG
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= SDT-BIOME-COUNT(WS-S)
         COMPUTE WS-I = SDT-BIOME-FIRST(WS-S) + WS-J
         IF SD-BIOME(WS-I) = WS-BIOME
             MOVE 1 TO WS-FLAG
         END-IF
     END-PERFORM.
 BIOME-HAS.
     PERFORM BIOME-FIND
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-6§1 The three families at a glance: " FUNCTION TRIM(SDT-KEY(WS-S)) " holds " FUNCTION TRIM(WS-BIOME) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 BIOME-HAS-NOT.
     PERFORM BIOME-FIND
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-6§1 The three families at a glance: " FUNCTION TRIM(SDT-KEY(WS-S)) " does not hold " FUNCTION TRIM(WS-BIOME) DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-36-6-1.
 COPY NOSPAWN.
 COPY CORETEST.
