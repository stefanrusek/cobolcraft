*> Implementation test of speleothem_cluster (docs/protocol/35-worldgen-features-6-underground.md section 6; core/src/feat-35-6.cob): the data features compile (type 46: the data of dripstone_cluster,
*> constant and uniform float providers; a missing member, a provider of an unsupported type, a missing wetness or a pool without the base stone tag make the feature unsupported); placements in
*> hand made caves (a plain cave, a cave with ground water, a roofless and floorless cave with lava, a low roof) change exactly the cells the rules of 6.2 give, replayed by a model of this test on a
*> second random source seeded alike: the five draws, the chance of every column, the scan (ranges, rays, lines, lava as a target), the pool (the water test and canPlacePool), the stalactite and
*> stalagmite flags with their layers, getSpeleothemHeight (float and double steps), the meeting, the merge flag and the columns of pointed blocks. The random state after every placement equals
*> the model's; the Gaussian spare is dropped before both runs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 COPY JSONDOC.
 01 WS-FA                  FLOAT-LONG.
 01 WS-THREEF              FLOAT-LONG VALUE 3.
 01 WS-DV                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUES.
    05 WS-VAL              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TEXT                PIC X(1200).
 01 WS-BASETEXT            PIC X(1200).
 01 WS-OLD                 PIC X(64).
 01 WS-POS                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-FR                  FLOAT-LONG.
 01 WS-FV                  FLOAT-LONG.
 01 WS-NM                  FLOAT-LONG.
 01 WS-NG                  FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-WET                 FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-CHMAX               FLOAT-LONG.
 01 WS-DRND                FLOAT-LONG.
 01 WS-ZEROF               FLOAT-LONG VALUE 0.
 01 WS-ONEF                FLOAT-LONG VALUE 1.
 01 WS-TWOF                FLOAT-LONG VALUE 2.
*> the parameters of the fixture in the model (SET-PARAMS)
 01 WS-P.
    05 WS-PH-LO            BINARY-LONG.
    05 WS-PH-HI            BINARY-LONG.
    05 WS-PW-KIND          BINARY-LONG.
    05 WS-PW-MEAN          FLOAT-LONG.
    05 WS-PW-DEV           FLOAT-LONG.
    05 WS-PW-MIN           FLOAT-LONG.
    05 WS-PW-MAX           FLOAT-LONG.
    05 WS-PD-LO            FLOAT-LONG.
    05 WS-PD-HI            FLOAT-LONG.
    05 WS-PR-LO            BINARY-LONG.
    05 WS-PR-HI            BINARY-LONG.
    05 WS-PT-LO            BINARY-LONG.
    05 WS-PT-HI            BINARY-LONG.
    05 WS-P-RANGE          BINARY-LONG.
    05 WS-P-DIFF           BINARY-LONG.
    05 WS-P-DEV            BINARY-LONG.
    05 WS-P-EDGE           BINARY-LONG.
    05 WS-P-CENTER         BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CHEIGHT             BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-E1                  BINARY-LONG.
 01 WS-LI                  BINARY-LONG.
 01 WS-LX0                 BINARY-LONG.
 01 WS-LZ0                 BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-IV                  BINARY-LONG.
 01 WS-IA                  BINARY-LONG.
 01 WS-IB                  BINARY-LONG.
 01 WS-HAS-C               BINARY-LONG.
 01 WS-HAS-F               BINARY-LONG.
 01 WS-HAS-F2              BINARY-LONG.
 01 WS-YC                  BINARY-LONG.
 01 WS-YF                  BINARY-LONG.
 01 WS-YF2                 BINARY-LONG.
 01 WS-HA                  BINARY-LONG.
 01 WS-HB                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-MEET                BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-SDIR                 BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-NSTEPS               BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUNDY              BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-CASEN               BINARY-LONG.
 01 WS-CN                  PIC 9.
 01 WS-TOTAL-POINTED       BINARY-LONG.
 01 WS-TOTAL-WATER         BINARY-LONG.
 01 WS-TOTAL-MERGE         BINARY-LONG.
 01 WS-ALL-MERGE           BINARY-LONG VALUE 0.
 01 WS-BNAME               PIC X(48).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE WS-WANT TO WS-SETB(1)
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE "granite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(2)
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE "diorite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(3)
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE "andesite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(4)
     COMPUTE WS-ID(4) = WS-WANT - 1
     MOVE 4 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "dripstone_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BASE
     MOVE "pointed_dripstone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-POINTED
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LAVA
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
*>   the pool needs the tag base_stone_overworld: without it the feature is unsupported
     MOVE "minecraft:cluster" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.2: a content set without the tag base_stone_overworld makes the cluster unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FD-RESET"
     MOVE "minecraft:base_stone_overworld" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS

     MOVE 1 TO FI-GATE
     MOVE "minecraft:dripstone_cluster" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§6: the gate admits the placed feature dripstone_cluster" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   the data features compile
     MOVE "minecraft:cluster" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: the data feature dripstone_cluster compiles as type 46" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 46 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§6.1: the integers of the data: range 12, diff 1, deviation 3, edge 3, center 8" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 3) * 10000 + WA-I(FT-A(WS-FT), 4) * 1000 + WA-I(FT-A(WS-FT), 5) * 100 + WA-I(FT-A(WS-FT), 6) * 10 + WA-I(FT-A(WS-FT), 7)
     COMPUTE WS-EXP = 120000 + 1000 + 300 + 30 + 8
     PERFORM ASSERT-N
     MOVE "35-6§6.1: density uniform 0.3 to 0.7 (kind 2), wetness clamped normal 0.1, 0.3, 0.1, 0.9 (kind 3), chance at the maximum distance 0.1" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-I(FT-A(WS-FT), 8) = 2 AND WA-G(FT-A(WS-FT), 1) = 0.3 AND WA-G(FT-A(WS-FT), 2) = 0.7
        AND WA-I(FT-A(WS-FT), 9) = 3 AND WA-G(FT-A(WS-FT), 5) = 0.1 AND WA-G(FT-A(WS-FT), 6) = 0.3
        AND WA-G(FT-A(WS-FT), 7) = 0.1 AND WA-G(FT-A(WS-FT), 8) = 0.9 AND WA-F(FT-A(WS-FT), 1) = 0.1
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§6.1: the three int providers are uniform (type 2): height 3 to 6, radius 2 to 8, layer thickness 2 to 4" TO WS-CASE
     COMPUTE WS-OBS = WA-IPV(FT-A(WS-FT), 1, 1) * 100000 + WA-IPV(FT-A(WS-FT), 1, 2) * 10000 + WA-IPV(FT-A(WS-FT), 1, 3) * 1000
         + WA-IPV(FT-A(WS-FT), 2, 3) * 10 + WA-IPV(FT-A(WS-FT), 3, 3) * 1 + WA-IPV(FT-A(WS-FT), 2, 2) * 100 + WA-IPV(FT-A(WS-FT), 3, 2) * 0
     COMPUTE WS-EXP = 200000 + 30000 + 6000 + 80 + 4 + 200
     PERFORM ASSERT-N
     MOVE "minecraft:cluster_constdensity" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: a bare number is a constant float provider (kind 1)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF FT-TYPE(WS-FT) = 46 AND WA-I(FT-A(WS-FT), 8) = 1 AND WA-G(FT-A(WS-FT), 1) = 0.5
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:cluster_uniwet" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: a uniform wetness provider compiles (kind 2)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF FT-TYPE(WS-FT) = 46 AND WA-I(FT-A(WS-FT), 9) = 2
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:cluster_noradius" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: a missing radius makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:cluster_badprov" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: a float provider of another type (trapezoid) makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:cluster_nowet" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§6.1: a missing wetness makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   placements, with the parameters of dripstone_cluster in a plain cave, a roofless and floorless cave with lava, and a low roof
     PERFORM VARYING WS-CASEN FROM 1 BY 1 UNTIL WS-CASEN > 6
         IF WS-CASEN <= 3
             MOVE "minecraft:cluster" TO WS-FTKEY
             PERFORM SET-PARAMS-DOC
         ELSE
             MOVE "minecraft:cluster_wet" TO WS-FTKEY
             PERFORM SET-PARAMS-WET
         END-IF
         PERFORM COMPILE-FT
         MOVE 0 TO WS-BAD WS-TOTAL-POINTED WS-TOTAL-WATER WS-TOTAL-MERGE
         PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 8
             PERFORM NEW-WORLD
             EVALUATE WS-CASEN
                 WHEN 1
                 WHEN 4
                     CONTINUE
                 WHEN 2
                 WHEN 6
                     PERFORM OPEN-AIR-WORLD
                 WHEN 3
                     PERFORM LOW-ROOF-WORLD
                 WHEN 5
                     PERFORM WATER-WORLD
             END-EVALUATE
             MOVE 24 TO WS-OX
             IF WS-CASEN = 1 OR WS-CASEN = 4
                 MOVE 29 TO WS-OX
             END-IF
             MOVE 66 TO WS-OY
             IF WS-CASEN = 3
                 MOVE 64 TO WS-OY
             END-IF
             MOVE 40 TO WS-OZ
             PERFORM RUN-BOTH
         END-PERFORM
         ADD WS-TOTAL-MERGE TO WS-ALL-MERGE
         MOVE SPACES TO WS-CASE
         EVALUATE WS-CASEN
             WHEN 1
                 MOVE "35-6§6.2: dripstone_cluster in a plain cave equals the model (cells and random state), eight seeds" TO WS-CASE
             WHEN 2
                 MOVE "35-6§6.2: dripstone_cluster in a roofless, floorless cave with lava floors and ceilings equals the model, eight seeds" TO WS-CASE
             WHEN 3
                 MOVE "35-6§6.2: dripstone_cluster under a low roof (cave height 3) equals the model, eight seeds" TO WS-CASE
             WHEN 4
                 MOVE "35-6§6.2: a cluster with wetness 1.0 makes pools on dry floors and equals the model, eight seeds" TO WS-CASE
             WHEN 5
                 MOVE "35-6§6.2: a wet cluster over shallow water (no pool: water above the floor cell) equals the model, eight seeds" TO WS-CASE
             WHEN OTHER
                 MOVE "35-6§6.2: a wet cluster in the roofless, floorless cave with lava equals the model, eight seeds" TO WS-CASE
         END-EVALUATE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         MOVE WS-CASEN TO WS-CN
         STRING "35-6§6.2: case " WS-CN " wrote pointed dripstone" DELIMITED BY SIZE INTO WS-CASE
         MOVE 0 TO WS-OBS
         IF WS-TOTAL-POINTED > 20
             MOVE 1 TO WS-OBS
         END-IF
         MOVE 1 TO WS-EXP
         PERFORM ASSERT-N
         IF WS-CASEN = 4
             MOVE "35-6§6.2: wetness 1.0 made pools (water blocks written)" TO WS-CASE
             MOVE 0 TO WS-OBS
             IF WS-TOTAL-WATER > 20
                 MOVE 1 TO WS-OBS
             END-IF
             MOVE 1 TO WS-EXP
             PERFORM ASSERT-N
         END-IF
     END-PERFORM

     MOVE "35-6§6.2 step 8: the merge flag joined two columns (tip_merge pieces) in some run" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-ALL-MERGE > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   Mth.clampedMap directly (2.2): below the input range, above it, inside it, in single and in double precision
     MOVE 0 TO WS-BAD
     MOVE 0.1 TO WS-FA
     MOVE 1.0 TO WS-FB
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 1
         MOVE WS-K TO WS-DV
         MOVE -1.0 TO WS-FV
         MOVE 0 TO WS-FR
         CALL "FX-CLAMPED-MAP" USING WS-DV WS-FV WS-ZEROF WS-THREEF WS-FA WS-FB WS-G
         IF WS-G NOT = WS-FA
             ADD 1 TO WS-BAD
         END-IF
         MOVE 5.0 TO WS-FV
         CALL "FX-CLAMPED-MAP" USING WS-DV WS-FV WS-ZEROF WS-THREEF WS-FA WS-FB WS-G
         IF WS-G NOT = WS-FB
             ADD 1 TO WS-BAD
         END-IF
         MOVE 1.5 TO WS-FV
         CALL "FX-CLAMPED-MAP" USING WS-DV WS-FV WS-ZEROF WS-THREEF WS-FA WS-FB WS-G
         COMPUTE WS-DRND = FUNCTION ABS(WS-G - 0.55)
         IF WS-DRND > 0.000001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§2.2: Mth.clampedMap gives the low end below the input range, the high end above it and the lerp inside, in both precisions" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
*>   the float providers: a clamped normal that always clamps (one end, then the other), a constant, and the members every kind needs
     MOVE '{"type": "minecraft:clamped_normal", "mean": 5.0, "deviation": 0.1, "min": 0.0, "max": 1.0}' TO WS-TEXT
     PERFORM PARSE-TEXT
     CALL "FD-FP" USING JSON-DOC WS-ONE WS-KIND WS-VALUES WS-OK
     CALL "FR-FP" USING XR-STATE WS-KIND WS-VALUES WS-FV
     MOVE "35-6§2.2: a clamped normal float far above its maximum gives the maximum" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-OK = 1 AND WS-KIND = 3 AND WS-FV = 1.0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE '{"type": "minecraft:clamped_normal", "mean": -5.0, "deviation": 0.1, "min": 0.0, "max": 1.0}' TO WS-TEXT
     PERFORM PARSE-TEXT
     CALL "FD-FP" USING JSON-DOC WS-ONE WS-KIND WS-VALUES WS-OK
     CALL "FR-FP" USING XR-STATE WS-KIND WS-VALUES WS-FV
     MOVE "35-6§2.2: a clamped normal float far below its minimum gives the minimum" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-OK = 1 AND WS-FV = 0.0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
         EVALUATE WS-K
             WHEN 1
                 MOVE '{"type": "minecraft:uniform", "max_exclusive": 1.0}' TO WS-TEXT
             WHEN 2
                 MOVE '{"type": "minecraft:uniform", "min_inclusive": 0.5}' TO WS-TEXT
             WHEN 3
                 MOVE '{"type": "minecraft:clamped_normal", "deviation": 0.1, "min": 0.0, "max": 1.0}' TO WS-TEXT
             WHEN 4
                 MOVE '{"type": "minecraft:clamped_normal", "mean": 1.0, "min": 0.0, "max": 1.0}' TO WS-TEXT
             WHEN 5
                 MOVE '{"type": "minecraft:clamped_normal", "mean": 1.0, "deviation": 0.1, "max": 1.0}' TO WS-TEXT
             WHEN 6
                 MOVE '{"type": "minecraft:clamped_normal", "mean": 1.0, "deviation": 0.1, "min": 0.0}' TO WS-TEXT
             WHEN OTHER
                 MOVE '"text"' TO WS-TEXT
         END-EVALUATE
         PERFORM PARSE-TEXT
         CALL "FD-FP" USING JSON-DOC WS-ONE WS-KIND WS-VALUES WS-OK
         IF WS-OK NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§6.1: a uniform or clamped normal float provider missing one of its members, or a string, is not ok" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
*>   every member of the cluster is needed: the key renamed makes the compile fail; the original text compiles
     MOVE '{"type": "minecraft:speleothem_cluster", "base_block": "minecraft:dripstone_block", "pointed_block": "minecraft:pointed_dripstone", "replaceable_blocks": "#minecraft:dripstone_replaceable_blocks", '
         & '"floor_to_ceiling_search_range": 12, "height": 4, "radius": 3, "max_stalagmite_stalactite_height_diff": 1, "height_deviation": 3, "speleothem_block_layer_thickness": 2, "density": 0.5, "wetness": 0.5, '
         & '"chance_of_speleothem_at_max_distance_from_center": 0.1, "max_distance_from_edge_affecting_chance_of_speleothem": 3, "max_distance_from_center_affecting_height_bias": 8}' TO WS-BASETEXT
     CALL "FD-RESET"
     MOVE WS-BASETEXT TO WS-TEXT
     PERFORM PARSE-TEXT
     MOVE 0 TO FD-BAD
     CALL "FD-CLUSTER-NODE" USING JSON-DOC WS-ONE WS-J
     MOVE "35-6§6.1: the compact cluster text compiles without a flag" TO WS-CASE
     MOVE FD-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 11
         EVALUATE WS-K
             WHEN 1
                 MOVE '"floor_to_ceiling_search_range"' TO WS-OLD
             WHEN 2
                 MOVE '"max_stalagmite_stalactite_height_diff"' TO WS-OLD
             WHEN 3
                 MOVE '"height_deviation"' TO WS-OLD
             WHEN 4
                 MOVE '"max_distance_from_edge_affecting_chance_of_speleothem"' TO WS-OLD
             WHEN 5
                 MOVE '"max_distance_from_center_affecting_height_bias"' TO WS-OLD
             WHEN 6
                 MOVE '"density"' TO WS-OLD
             WHEN 7
                 MOVE '"wetness"' TO WS-OLD
             WHEN 8
                 MOVE '"height"' TO WS-OLD
             WHEN 9
                 MOVE '"radius"' TO WS-OLD
             WHEN 11
                 MOVE '"chance_of_speleothem_at_max_distance_from_center"' TO WS-OLD
             WHEN OTHER
                 MOVE '"speleothem_block_layer_thickness"' TO WS-OLD
         END-EVALUATE
         MOVE WS-BASETEXT TO WS-TEXT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OLD)) TO WS-LEN
         MOVE 0 TO WS-POS
         INSPECT WS-TEXT TALLYING WS-POS FOR CHARACTERS BEFORE INITIAL WS-OLD(1:WS-LEN)
         MOVE "X" TO WS-TEXT(WS-POS + 2:1)
         PERFORM PARSE-TEXT
         CALL "FD-RESET"
         MOVE 0 TO FD-BAD
         CALL "FD-CLUSTER-NODE" USING JSON-DOC WS-ONE WS-J
         IF FD-BAD NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§6.1: each of the eleven members of the cluster is needed: a missing one is unsupported" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FD-RESET"
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE WS-BASETEXT TO WS-TEXT
     PERFORM PARSE-TEXT
     MOVE 0 TO FD-BAD
     CALL "FD-CLUSTER-NODE" USING JSON-DOC WS-ONE WS-J
     MOVE "35-6§6.1: a full feature table gives no row (row 0)" TO WS-CASE
     MOVE WS-J TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FD-RESET"

*>   an origin in stone is refused at once (no draw); an origin in water is fine
     MOVE "minecraft:cluster" TO WS-FTKEY
     PERFORM SET-PARAMS-DOC
     PERFORM COMPILE-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 75 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE 0 TO WS-BAD
     MOVE 3 TO WS-SEED
     PERFORM RUN-BOTH
     MOVE "35-6§6.2 step 1: an origin that is neither air nor water returns false and draws nothing" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§6.2 step 1: the result of the refused placement is 0" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

*> SET-PARAMS-DOC: the data of dripstone_cluster (6.1)
 SET-PARAMS-DOC.
     MOVE 3 TO WS-PH-LO
     MOVE 6 TO WS-PH-HI
     MOVE 3 TO WS-PW-KIND
     MOVE 0.1 TO WS-PW-MEAN
     MOVE 0.3 TO WS-PW-DEV
     MOVE 0.1 TO WS-PW-MIN
     MOVE 0.9 TO WS-PW-MAX
     MOVE 0.3 TO WS-PD-LO
     MOVE 0.7 TO WS-PD-HI
     MOVE 2 TO WS-PR-LO
     MOVE 8 TO WS-PR-HI
     MOVE 2 TO WS-PT-LO
     MOVE 4 TO WS-PT-HI
     MOVE 12 TO WS-P-RANGE
     MOVE 1 TO WS-P-DIFF
     MOVE 3 TO WS-P-DEV
     MOVE 3 TO WS-P-EDGE
     MOVE 8 TO WS-P-CENTER
     MOVE 0.1 TO WS-CHMAX
     .
*> SET-PARAMS-WET: the fixture cluster_wet: height 5, wetness 1.0, density 0.6 to 1.0, radius 2 to 4, thickness 1 to 3, diff 2, deviation 2, chance 0.5
 SET-PARAMS-WET.
     PERFORM SET-PARAMS-DOC
     MOVE 5 TO WS-PH-LO
     MOVE 5 TO WS-PH-HI
     MOVE 1 TO WS-PW-KIND
     MOVE 1.0 TO WS-PW-MEAN
     MOVE 0.6 TO WS-PD-LO
     MOVE 1.0 TO WS-PD-HI
     MOVE 2 TO WS-PR-LO
     MOVE 4 TO WS-PR-HI
     MOVE 1 TO WS-PT-LO
     MOVE 3 TO WS-PT-HI
     MOVE 2 TO WS-P-DIFF
     MOVE 2 TO WS-P-DEV
     MOVE 0.5 TO WS-CHMAX
     .
*> OPEN-AIR-WORLD: no ceiling for x 16..21 z 44..47 and a ceiling of one layer (y 70) for z 32..43, no floor for x 26..31 z 44..47 and a floor of one layer (y 62) for z 32..43, lava floor x 20..22
*> z 36..38 (y 62), lava ceiling x 22..24 z 44..46 (y 70), a floor of dripstone x 28..30 z 36..38 (y 62)
 OPEN-AIR-WORLD.
     MOVE "air" TO WS-KEY
     MOVE 16 TO WS-X0
     MOVE 21 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 71 TO WS-Y0
     MOVE 80 TO WS-Y1
     PERFORM FILL-BOX
     MOVE 44 TO WS-Z0
     MOVE 70 TO WS-Y0
     PERFORM FILL-BOX
     MOVE 26 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 43 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 61 TO WS-Y1
     PERFORM FILL-BOX
     MOVE 44 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 62 TO WS-Y1
     PERFORM FILL-BOX
     MOVE "lava" TO WS-KEY
     MOVE 20 TO WS-X0
     MOVE 22 TO WS-X1
     MOVE 36 TO WS-Z0
     MOVE 38 TO WS-Z1
     MOVE 62 TO WS-Y0
     MOVE 62 TO WS-Y1
     PERFORM FILL-BOX
     MOVE 22 TO WS-X0
     MOVE 24 TO WS-X1
     MOVE 44 TO WS-Z0
     MOVE 46 TO WS-Z1
     MOVE 70 TO WS-Y0
     MOVE 70 TO WS-Y1
     PERFORM FILL-BOX
     MOVE "dripstone_block" TO WS-KEY
     MOVE 28 TO WS-X0
     MOVE 30 TO WS-X1
     MOVE 36 TO WS-Z0
     MOVE 38 TO WS-Z1
     MOVE 62 TO WS-Y0
     MOVE 62 TO WS-Y1
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
*> LOW-ROOF-WORLD: stone y 66..69 for x 20..28, z 36..44 (a cave of height 3 there) and a stone pillar x 22..23, z 38..39, y 63..65
 LOW-ROOF-WORLD.
     MOVE "stone" TO WS-KEY
     MOVE 20 TO WS-X0
     MOVE 28 TO WS-X1
     MOVE 36 TO WS-Z0
     MOVE 44 TO WS-Z1
     MOVE 66 TO WS-Y0
     MOVE 69 TO WS-Y1
     PERFORM FILL-BOX
     MOVE 22 TO WS-X0
     MOVE 23 TO WS-X1
     MOVE 38 TO WS-Z0
     MOVE 39 TO WS-Z1
     MOVE 63 TO WS-Y0
     MOVE 65 TO WS-Y1
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
*> WATER-WORLD: water y 63..64 over x 20..28, z 36..44
 WATER-WORLD.
     MOVE "water" TO WS-KEY
     MOVE 20 TO WS-X0
     MOVE 28 TO WS-X1
     MOVE 36 TO WS-Z0
     MOVE 44 TO WS-Z1
     MOVE 63 TO WS-Y0
     MOVE 64 TO WS-Y1
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
*> RUN-BOTH: the Gaussian spare dropped, both sources seeded with WS-SEED, the feature runs at (WS-OX, WS-OY, WS-OZ), the model replays it; WS-BAD += the differing cells, plus one for
*> differing random states and one for differing results
 RUN-BOTH.
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
     CALL "F351-GAUSSIAN-RESET"
     PERFORM MODEL-CLUSTER
     PERFORM COMPARE
     IF XR-LO NOT = X2-LO OR XR-HI NOT = X2-HI
         ADD 1 TO WS-BAD
     END-IF
     IF WS-RESULT NOT = WS-FULL
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-B-POINTED TO WS-WANT
     PERFORM COUNT-BLOCK
     ADD WS-N TO WS-TOTAL-POINTED
     MOVE WS-B-WATER TO WS-WANT
     PERFORM COUNT-BLOCK
     ADD WS-N TO WS-TOTAL-WATER
     .
*> the float steps of the model: each is the double operation of the C library rounded to single precision
 M-ADD32.
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-FA WS-FB WS-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FR WS-FV
     .
 M-SUB32.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FA WS-FB WS-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FR WS-FV
     .
 M-MUL32.
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FA WS-FB WS-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FR WS-FV
     .
 M-DIV32.
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-FB WS-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FR WS-FV
     .
 M-F32.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FA WS-FV
     .
*> M-INT: WS-IV = lo + nextInt(hi - lo + 1) on the model source (uniform int provider); lo in WS-IA, hi in WS-IB
 M-INT.
     COMPUTE WS-N = WS-IB - WS-IA + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-DRAW
     COMPUTE WS-IV = WS-IA + WS-DRAW
     .
*> M-NORMAL: WS-FV = clamp(mean + (float) nextGaussian * deviation, min, max) in single precision (mean WS-FA, deviation WS-FB, min WS-G, max WS-DRND on entry)
 M-NORMAL.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FA WS-NM
     CALL "F351-NEXT-GAUSSIAN" USING XR2-STATE WS-NG
     MOVE WS-NG TO WS-FA
     PERFORM M-F32
     MOVE WS-FV TO WS-FA
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FB WS-NG
     MOVE WS-NG TO WS-FB
     PERFORM M-MUL32
     MOVE WS-NM TO WS-FA
     MOVE WS-FV TO WS-FB
     PERFORM M-ADD32
     MOVE WS-FV TO WS-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-G WS-FA
     IF WS-FR < WS-FA
         MOVE WS-FA TO WS-FV
     ELSE
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-DRND WS-FB
         IF WS-FR > WS-FB
             MOVE WS-FB TO WS-FV
         ELSE
             MOVE WS-FR TO WS-FV
         END-IF
     END-IF
     .
*> M-EW: WS-D = 1 when the model cell (WS-MX, WS-MY, WS-MZ) is air or water; M-LAVA: WS-D = 1 when it is lava
 M-EW.
     PERFORM MGET
     PERFORM MBLOCK
     MOVE 0 TO WS-D
     IF WS-MV = WS-S-AIR OR WS-MB = WS-B-WATER
         MOVE 1 TO WS-D
     END-IF
     .
 M-LAVA.
     PERFORM MGET
     PERFORM MBLOCK
     MOVE 0 TO WS-D
     IF WS-MB = WS-B-LAVA
         MOVE 1 TO WS-D
     END-IF
     .
*> M-SCAN: scanDirection from (WS-PX, WS-CY start = WS-OY of the column = WS-LY, WS-PZ) in the direction WS-SDIR (+1 up, -1 down): WS-FOUND, WS-FOUNDY
 M-SCAN.
     MOVE WS-LY TO WS-CY
     MOVE 1 TO WS-NSTEPS
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0
         MOVE WS-PX TO WS-MX
         MOVE WS-CY TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM M-EW
         IF WS-NSTEPS < WS-P-RANGE AND WS-D = 1
             ADD WS-SDIR TO WS-CY
             ADD 1 TO WS-NSTEPS
         ELSE
             MOVE 0 TO WS-GO
         END-IF
     END-PERFORM
     MOVE WS-PX TO WS-MX
     MOVE WS-CY TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM MODEL-ISBASE
     MOVE WS-D TO WS-E1
     PERFORM M-LAVA
     MOVE 0 TO WS-FOUND
     IF WS-E1 = 1 OR WS-D = 1
         MOVE 1 TO WS-FOUND
         MOVE WS-CY TO WS-FOUNDY
     END-IF
     .
*> M-STONE-OR-WATER: WS-D = 1 when the model cell is base stone (the four blocks) or water
 M-STONE-OR-WATER.
     PERFORM MGET
     PERFORM MBLOCK
     PERFORM MODEL-IN-SET
     IF WS-MB = WS-B-WATER
         MOVE 1 TO WS-D
     END-IF
     .
*> M-POOL-OK: canPlacePool at (WS-PX, WS-YF, WS-PZ): WS-D = 1 when true
 M-POOL-OK.
     MOVE WS-PX TO WS-MX
     MOVE WS-YF TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM MGET
     PERFORM MBLOCK
     IF WS-MB = WS-B-WATER OR WS-MB = WS-B-BASE OR WS-MB = WS-B-POINTED
         MOVE 0 TO WS-D
         EXIT PARAGRAPH
     END-IF
     COMPUTE WS-MY = WS-YF + 1
     PERFORM MGET
     PERFORM MBLOCK
     IF WS-MB = WS-B-WATER
         MOVE 0 TO WS-D
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-E2
     COMPUTE WS-MX = WS-PX - 1
     MOVE WS-YF TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM M-STONE-OR-WATER
     IF WS-D = 0
         MOVE 0 TO WS-E2
     END-IF
     COMPUTE WS-MX = WS-PX + 1
     PERFORM M-STONE-OR-WATER
     IF WS-D = 0
         MOVE 0 TO WS-E2
     END-IF
     MOVE WS-PX TO WS-MX
     COMPUTE WS-MZ = WS-PZ - 1
     PERFORM M-STONE-OR-WATER
     IF WS-D = 0
         MOVE 0 TO WS-E2
     END-IF
     COMPUTE WS-MZ = WS-PZ + 1
     PERFORM M-STONE-OR-WATER
     IF WS-D = 0
         MOVE 0 TO WS-E2
     END-IF
     MOVE WS-PZ TO WS-MZ
     COMPUTE WS-MY = WS-YF - 1
     PERFORM M-STONE-OR-WATER
     IF WS-D = 0
         MOVE 0 TO WS-E2
     END-IF
     MOVE WS-E2 TO WS-D
     .
*> M-HEIGHT: getSpeleothemHeight(random, WS-DX, WS-DZ, density WS-DEN, cap WS-CAP): WS-IV
 M-HEIGHT.
     MOVE 0 TO WS-IV
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-FA
     IF WS-FA > WS-DEN
         EXIT PARAGRAPH
     END-IF
*>   mean = (float) clampedMap((double) dist, 0, center, cap / 2.0, 0.0), double arithmetic
     COMPUTE WS-N = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DZ)
     MOVE WS-N TO WS-FA
     MOVE WS-P-CENTER TO WS-FB
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-FB WS-FR
     MOVE WS-CAP TO WS-FA
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-TWOF WS-FB
     EVALUATE TRUE
         WHEN WS-FR < 0
             MOVE WS-FB TO WS-FV
         WHEN WS-FR > 1
             MOVE 0 TO WS-FV
         WHEN OTHER
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZEROF WS-FB WS-FA
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FR WS-FA WS-G
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-FB WS-G WS-FV
     END-EVALUATE
     MOVE WS-FV TO WS-FA
     PERFORM M-F32
     MOVE WS-FV TO WS-FA
     MOVE WS-P-DEV TO WS-FB
     MOVE 0 TO WS-G
     MOVE WS-CAP TO WS-DRND
     PERFORM M-NORMAL
     MOVE WS-FV TO WS-FA
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FA WS-IV
     .
*> M-LAYER: replaceBlocksWithBaseBlocks(WS-PX, WS-LY, WS-PZ, thickness WS-IV, direction WS-SDIR (+1 up, -1 down))
 M-LAYER.
     MOVE WS-LY TO WS-CY
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-LI FROM 1 BY 1 UNTIL WS-LI > WS-IV OR WS-STOP = 1
         MOVE WS-PX TO WS-MX
         MOVE WS-CY TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM MGET
         PERFORM MBLOCK
         PERFORM MODEL-IN-SET
         IF WS-D = 1
             MOVE WS-S-BASE TO WS-MV
             PERFORM MSET
         ELSE
             MOVE 1 TO WS-STOP
         END-IF
         ADD WS-SDIR TO WS-CY
     END-PERFORM
     .
*> MODEL-CLUSTER: 6.2 on the model cells with the second random source
 MODEL-CLUSTER.
     MOVE 0 TO WS-FULL
     MOVE WS-OX TO WS-MX
     MOVE WS-OY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     PERFORM M-EW
     IF WS-D = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-FULL
*>   the height: uniform (one nextInt) unless the fixture gives a constant (both ends equal: no draw)
     IF WS-PH-LO = WS-PH-HI
         MOVE WS-PH-LO TO WS-CHEIGHT
     ELSE
         MOVE WS-PH-LO TO WS-IA
         MOVE WS-PH-HI TO WS-IB
         PERFORM M-INT
         MOVE WS-IV TO WS-CHEIGHT
     END-IF
     IF WS-PW-KIND = 1
         MOVE WS-PW-MEAN TO WS-FA
         PERFORM M-F32
         MOVE WS-FV TO WS-WET
     ELSE
         MOVE WS-PW-MEAN TO WS-FA
         MOVE WS-PW-DEV TO WS-FB
         MOVE WS-PW-MIN TO WS-G
         MOVE WS-PW-MAX TO WS-DRND
         PERFORM M-NORMAL
         MOVE WS-FV TO WS-WET
     END-IF
*>   density: uniform, nextFloat * (hi - lo) + lo in single precision
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-G
     MOVE WS-PD-HI TO WS-FA
     PERFORM M-F32
     MOVE WS-FV TO WS-FA
     MOVE WS-PD-LO TO WS-FB
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FB WS-FR
     MOVE WS-FR TO WS-FB
     PERFORM M-SUB32
     MOVE WS-G TO WS-FA
     MOVE WS-FV TO WS-FB
     PERFORM M-MUL32
     MOVE WS-FV TO WS-FA
     MOVE WS-FR TO WS-FB
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-PD-LO WS-FB
     PERFORM M-ADD32
     MOVE WS-FV TO WS-DEN
     MOVE WS-PR-LO TO WS-IA
     MOVE WS-PR-HI TO WS-IB
     PERFORM M-INT
     MOVE WS-IV TO WS-RX
     PERFORM M-INT
     MOVE WS-IV TO WS-RZ
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-CHMAX WS-FR
     MOVE WS-FR TO WS-CHANCE
     COMPUTE WS-LX0 = 0 - WS-RX
     COMPUTE WS-LZ0 = 0 - WS-RZ
     PERFORM VARYING WS-DX FROM WS-LX0 BY 1 UNTIL WS-DX > WS-RX
         PERFORM VARYING WS-DZ FROM WS-LZ0 BY 1 UNTIL WS-DZ > WS-RZ
             PERFORM M-COLUMN
         END-PERFORM
     END-PERFORM
     .
*> M-COLUMN: the chance of the column (WS-DX, WS-DZ) and placeColumn
 M-COLUMN.
     COMPUTE WS-N = WS-RX - FUNCTION ABS(WS-DX)
     COMPUTE WS-I = WS-RZ - FUNCTION ABS(WS-DZ)
     IF WS-I < WS-N
         MOVE WS-I TO WS-N
     END-IF
*>   clampedMap((float) e, 0, edge, chmax, 1.0) in single precision
     MOVE WS-N TO WS-FA
     MOVE WS-P-EDGE TO WS-FB
     PERFORM M-DIV32
     EVALUATE TRUE
         WHEN WS-FV < 0
             MOVE WS-CHMAX TO WS-FA
             PERFORM M-F32
             MOVE WS-FV TO WS-CHANCE
         WHEN WS-FV > 1
             MOVE 1 TO WS-CHANCE
         WHEN OTHER
             MOVE WS-FV TO WS-G
             MOVE WS-CHMAX TO WS-FA
             PERFORM M-F32
             MOVE WS-FV TO WS-DRND
             MOVE WS-ONEF TO WS-FA
             MOVE WS-DRND TO WS-FB
             PERFORM M-SUB32
             MOVE WS-G TO WS-FA
             MOVE WS-FV TO WS-FB
             PERFORM M-MUL32
             MOVE WS-DRND TO WS-FA
             MOVE WS-FV TO WS-FB
             PERFORM M-ADD32
             MOVE WS-FV TO WS-CHANCE
     END-EVALUATE
     COMPUTE WS-PX = WS-OX + WS-DX
     COMPUTE WS-PZ = WS-OZ + WS-DZ
     MOVE WS-OY TO WS-LY
     MOVE WS-PX TO WS-MX
     MOVE WS-OY TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM M-EW
     IF WS-D = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-SDIR
     PERFORM M-SCAN
     MOVE WS-FOUND TO WS-HAS-C
     MOVE WS-FOUNDY TO WS-YC
     MOVE -1 TO WS-SDIR
     PERFORM M-SCAN
     MOVE WS-FOUND TO WS-HAS-F
     MOVE WS-FOUNDY TO WS-YF
     IF WS-HAS-C = 0 AND WS-HAS-F = 0
         EXIT PARAGRAPH
     END-IF
*>   the pool
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-FA
     MOVE WS-HAS-F TO WS-HAS-F2
     MOVE WS-YF TO WS-YF2
     IF WS-FA < WS-WET AND WS-HAS-F = 1
         PERFORM M-POOL-OK
         IF WS-D = 1
             MOVE WS-PX TO WS-MX
             MOVE WS-YF TO WS-MY
             MOVE WS-PZ TO WS-MZ
             MOVE WS-S-WATER TO WS-MV
             PERFORM MSET
             COMPUTE WS-YF2 = WS-YF - 1
         END-IF
     END-IF
     CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-DRND
     MOVE 0 TO WS-HA
     IF WS-HAS-C = 1 AND WS-DRND < WS-CHANCE
         MOVE WS-PX TO WS-MX
         MOVE WS-YC TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM M-LAVA
         IF WS-D = 0
             MOVE WS-PT-LO TO WS-IA
             MOVE WS-PT-HI TO WS-IB
             PERFORM M-INT
             MOVE WS-YC TO WS-LY
             MOVE 1 TO WS-SDIR
             PERFORM M-LAYER
             MOVE WS-CHEIGHT TO WS-CAP
             IF WS-HAS-F2 = 1 AND WS-YC - WS-YF2 < WS-CAP
                 COMPUTE WS-CAP = WS-YC - WS-YF2
             END-IF
             PERFORM M-HEIGHT
             MOVE WS-IV TO WS-HA
         END-IF
     END-IF
     CALL "WGR-NEXT-DOUBLE" USING XR2-STATE WS-DRND
     MOVE 0 TO WS-HB
     IF WS-HAS-F2 = 1 AND WS-DRND < WS-CHANCE
         MOVE WS-PX TO WS-MX
         MOVE WS-YF2 TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM M-LAVA
         IF WS-D = 0
             MOVE WS-PT-LO TO WS-IA
             MOVE WS-PT-HI TO WS-IB
             PERFORM M-INT
             MOVE WS-YF2 TO WS-LY
             MOVE -1 TO WS-SDIR
             PERFORM M-LAYER
             IF WS-HAS-C = 1
                 COMPUTE WS-IA = 0 - WS-P-DIFF
                 MOVE WS-P-DIFF TO WS-IB
                 PERFORM M-INT
                 COMPUTE WS-HB = WS-HA + WS-IV
                 IF WS-HB < 0
                     MOVE 0 TO WS-HB
                 END-IF
             ELSE
                 MOVE WS-CHEIGHT TO WS-CAP
                 PERFORM M-HEIGHT
                 MOVE WS-IV TO WS-HB
             END-IF
         END-IF
     END-IF
     IF WS-HAS-C = 1 AND WS-HAS-F2 = 1
         IF WS-YC - WS-HA <= WS-YF2 + WS-HB
             COMPUTE WS-LO = WS-YC - WS-HA
             IF WS-YF2 + 1 > WS-LO
                 COMPUTE WS-LO = WS-YF2 + 1
             END-IF
             COMPUTE WS-HI = WS-YF2 + WS-HB
             IF WS-YC - 1 < WS-HI
                 COMPUTE WS-HI = WS-YC - 1
             END-IF
             MOVE WS-LO TO WS-IA
             COMPUTE WS-IB = WS-HI + 1
             PERFORM M-INT
             COMPUTE WS-HA = WS-YC - WS-IV
             COMPUTE WS-HB = WS-IV - 1 - WS-YF2
         END-IF
     END-IF
     CALL "F351-NEXT-BOOLEAN" USING XR2-STATE WS-DRAW
     MOVE 0 TO WS-MERGE
     IF WS-DRAW = 1 AND WS-HA > 0 AND WS-HB > 0 AND WS-HAS-C = 1 AND WS-HAS-F2 = 1 AND WS-HA + WS-HB = WS-YC - WS-YF2 - 1
         MOVE 1 TO WS-MERGE
         ADD 1 TO WS-TOTAL-MERGE
     END-IF
     IF WS-HAS-C = 1
         MOVE WS-PX TO WS-GX
         COMPUTE WS-GY = WS-YC - 1
         MOVE WS-PZ TO WS-GZ
         MOVE 0 TO WS-TIP
         MOVE WS-HA TO WS-HT
         PERFORM MODEL-GROW
     END-IF
     IF WS-HAS-F2 = 1
         MOVE WS-PX TO WS-GX
         COMPUTE WS-GY = WS-YF2 + 1
         MOVE WS-PZ TO WS-GZ
         MOVE 1 TO WS-TIP
         MOVE WS-HB TO WS-HT
         PERFORM MODEL-GROW
     END-IF
     .
 PARSE-TEXT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     .
 COPY SPELMODEL.
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-6.
 COPY CORETEST.
