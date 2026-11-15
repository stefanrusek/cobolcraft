*> Implementation test of the per-biome decoration lists (core/src/nether-37-5.cob NETHER-FEATURE-ROW; T1691, T1692; docs/protocol/37-nether-5 sections 2 and 8): for every biome and
*> decoration step (2, 4, 7, 9) the placed features of the global order that list the biome, in order, equal the list of the biome file (the table of section 2, transcribed
*> here); the counts per biome are 18, 17, 18, 20 and 18 (91 in all), and basalt_deltas has no step 9, soul_sand_valley alone has step 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-KEY                 PIC X(26).
 01 WS-BIOMES              PIC X(5).
 01 WS-B                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-S                   PIC 99.
 01 WS-N                   PIC 99.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-TOTAL
     MOVE 1 TO WS-B
     MOVE 2 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 nether_wastes step 2: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 4 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 nether_wastes step 4: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 7 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 nether_wastes step 7: 15 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_open;patch_fire;patch_soul_fire;glowstone_extra;glowstone;brown_mushroom_nether;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "red_mushroom_nether;ore_magma;spring_closed;ore_gravel_nether;ore_blackstone;ore_gold_nether;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_quartz_nether;ore_ancient_debris_large;ore_debris_small;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 9 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 nether_wastes step 9: 3 placed features in list order" TO TL-CASE
     MOVE "spring_lava;brown_mushroom_normal;red_mushroom_normal;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     PERFORM COUNT-OF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 nether_wastes lists 18 placed features" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD WS-COUNT TO WS-TOTAL
     MOVE 2 TO WS-B
     MOVE 2 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 soul_sand_valley step 2: 1 placed features in list order" TO TL-CASE
     MOVE "basalt_pillar;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-B
     MOVE 4 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 soul_sand_valley step 4: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-B
     MOVE 7 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 soul_sand_valley step 7: 15 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_open;patch_fire;patch_soul_fire;glowstone_extra;glowstone;patch_crimson_roots;ore_magma;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "spring_closed;ore_soul_sand;ore_gravel_nether;ore_blackstone;ore_gold_nether;ore_quartz_nether;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_ancient_debris_large;ore_debris_small;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-B
     MOVE 9 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 soul_sand_valley step 9: 1 placed features in list order" TO TL-CASE
     MOVE "spring_lava;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-B
     PERFORM COUNT-OF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 soul_sand_valley lists 17 placed features" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD WS-COUNT TO WS-TOTAL
     MOVE 3 TO WS-B
     MOVE 2 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 crimson_forest step 2: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-B
     MOVE 4 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 crimson_forest step 4: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-B
     MOVE 7 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 crimson_forest step 7: 12 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_open;patch_fire;glowstone_extra;glowstone;ore_magma;spring_closed;ore_gravel_nether;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_blackstone;ore_gold_nether;ore_quartz_nether;ore_ancient_debris_large;ore_debris_small;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-B
     MOVE 9 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 crimson_forest step 9: 6 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_lava;brown_mushroom_normal;red_mushroom_normal;weeping_vines;crimson_fungi;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "crimson_forest_vegetation;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-B
     PERFORM COUNT-OF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 crimson_forest lists 18 placed features" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD WS-COUNT TO WS-TOTAL
     MOVE 4 TO WS-B
     MOVE 2 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 warped_forest step 2: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-B
     MOVE 4 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 warped_forest step 4: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-B
     MOVE 7 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 warped_forest step 7: 13 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_open;patch_fire;patch_soul_fire;glowstone_extra;glowstone;ore_magma;spring_closed;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_gravel_nether;ore_blackstone;ore_gold_nether;ore_quartz_nether;ore_ancient_debris_large;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_debris_small;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-B
     MOVE 9 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 warped_forest step 9: 7 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "spring_lava;brown_mushroom_normal;red_mushroom_normal;warped_fungi;warped_forest_vegetation;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "nether_sprouts;twisting_vines;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-B
     PERFORM COUNT-OF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 warped_forest lists 20 placed features" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD WS-COUNT TO WS-TOTAL
     MOVE 5 TO WS-B
     MOVE 2 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 basalt_deltas step 2: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-B
     MOVE 4 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 basalt_deltas step 4: 3 placed features in list order" TO TL-CASE
     MOVE "delta;small_basalt_columns;large_basalt_columns;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-B
     MOVE 7 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 basalt_deltas step 7: 15 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-P
     STRING "basalt_blobs;blackstone_blobs;spring_delta;patch_fire;patch_soul_fire;glowstone_extra;glowstone;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "brown_mushroom_nether;red_mushroom_nether;ore_magma;spring_closed_double;ore_gold_deltas;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     STRING "ore_quartz_deltas;ore_ancient_debris_large;ore_debris_small;" DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-P
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-B
     MOVE 9 TO WS-WANT
     PERFORM LIST-OF
     MOVE "acceptance US12-core 37-5§2 basalt_deltas step 9: 0 placed features in list order" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-B
     PERFORM COUNT-OF
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 basalt_deltas lists 18 placed features" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD WS-COUNT TO WS-TOTAL
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-core 37-5§8 91 placed feature entries in all, 37 distinct rows in the order" TO TL-CASE
     MOVE 91037 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-TOTAL * 1000 + 37
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 LIST-OF.
*>   the keys of the rows that list biome WS-B in step WS-WANT, in row order, each followed by ;
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 37
         CALL "NETHER-FEATURE-ROW" USING WS-ROW WS-STEP WS-INDEX WS-OFFSET WS-KEY WS-BIOMES
         IF WS-STEP = WS-WANT AND WS-BIOMES(WS-B:1) NOT = "."
             STRING FUNCTION TRIM(WS-KEY) ";" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
         END-IF
     END-PERFORM.

 COUNT-OF.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 37
         CALL "NETHER-FEATURE-ROW" USING WS-ROW WS-STEP WS-INDEX WS-OFFSET WS-KEY WS-BIOMES
         IF WS-BIOMES(WS-B:1) NOT = "."
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-NETHER-37-5-2.
