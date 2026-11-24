*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 3.3 and 3.4, biome spawn tables of the aquatic, Nether and End categories). GENERATED from the two doc tables by
*> a script that reads only the markdown (lane 002-lane-p49d, T18000): one case per biome and category compares the list in MOBSPAWN.cpy (the table the natural spawner draws from: entry,
*> weight, group size minimum and maximum, in list order) with the doc's list. The data is MOBSPAWN.cpy; there is no code in this test beyond reading it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBSPAWN.
 78 GROUPS VALUE 94.
 78 AQUATIC VALUE 79.
 01 WS-GROUP-DATA.
    05 FILLER.
       10 FILLER PIC X(32) VALUE "badlands".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "bamboo_jungle".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "beach".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "birch_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cherry_grove".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dappled_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dark_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "desert".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dripstone_caves".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "eroded_badlands".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "flower_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_peaks".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "grove".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ice_spikes".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "jagged_peaks".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "jungle".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "meadow".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "mushroom_fields".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_birch_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_pine_taiga".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_spruce_taiga".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "pale_garden".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "plains".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "savanna".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "savanna_plateau".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_beach".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_plains".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_slopes".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_taiga".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "sparse_jungle".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "stony_peaks".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "stony_shore".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "sunflower_plains".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "swamp".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "taiga".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_forest".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_gravelly_hills".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_hills".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_savanna".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "wooded_badlands".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cold_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_cold_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cold_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:15:3-6;salmon:15:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_cold_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:15:3-6;salmon:15:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cold_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:3:1-4;nautilus:2:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_cold_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:3:1-4;nautilus:2:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_frozen_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_frozen_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "salmon:15:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "salmon:15:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_frozen_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:1:1-4;nautilus:2:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:1:1-4;nautilus:2:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:8:3-6;pufferfish:5:1-3;tropical_fish:25:8-8;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:8:1-4;dolphin:2:1-2;nautilus:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:10:3-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:10:3-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:1:1-4;dolphin:1:1-2;nautilus:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:1:1-4;dolphin:1:1-2;nautilus:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_river".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "river".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_river".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "salmon:5:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "river".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "salmon:5:1-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_river".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:2:1-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "river".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:2:1-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "cod:15:3-6;pufferfish:5:1-3;tropical_fish:25:8-8;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lukewarm_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "squid:10:1-2;dolphin:2:1-2;nautilus:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lush_caves".
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER PIC X(200) VALUE "axolotl:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lush_caves".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lush_caves".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "tropical_fish:25:8-8;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "mangrove_swamp".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "mangrove_swamp".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "tropical_fish:25:8-8;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warm_ocean".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER PIC X(200) VALUE "glow_squid:10:4-6;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warm_ocean".
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER PIC X(200) VALUE "pufferfish:15:1-3;tropical_fish:25:8-8;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warm_ocean".
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER PIC X(200) VALUE "nautilus:5:1-1;squid:10:4-4;dolphin:2:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "nether_wastes".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(200) VALUE "strider:60:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "nether_wastes".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "ghast:50:4-4;zombified_piglin:100:4-4;magma_cube:2:4-4;enderman:1:4-4;piglin:15:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "soul_sand_valley".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(200) VALUE "strider:60:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "soul_sand_valley".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "skeleton:20:5-5;ghast:50:4-4;enderman:1:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "crimson_forest".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(200) VALUE "strider:60:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "crimson_forest".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "zombified_piglin:1:2-4;hoglin:9:3-4;piglin:5:3-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warped_forest".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(200) VALUE "strider:60:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warped_forest".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:1:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "basalt_deltas".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(200) VALUE "strider:60:1-2;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "basalt_deltas".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "ghast:40:1-1;magma_cube:100:2-5;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "the_end".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:10:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_highlands".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:10:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_midlands".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:10:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_barrens".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:10:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "small_end_islands".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER PIC X(200) VALUE "enderman:10:4-4;".
 01 WS-GROUP-TABLE REDEFINES WS-GROUP-DATA.
    05 WS-G OCCURS GROUPS TIMES.
       10 WS-G-BIOME         PIC X(32).
       10 WS-G-CAT           BINARY-LONG.
       10 WS-G-LIST          PIC X(200).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LIST                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-W                   PIC 999.
 01 WS-MIN                 PIC ZZ9.
 01 WS-MAX                 PIC ZZ9.
 01 WS-WEIGHT              PIC ZZ9.
 01 WS-KEY                 PIC X(24).
 01 WS-CATTEXT             PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GROUPS
         MOVE 0 TO WS-B
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-BIOMES
             IF SPB-NAME(WS-J) = WS-G-BIOME(WS-I)
                 MOVE WS-J TO WS-B
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-PTR
         IF WS-B > 0
             COMPUTE WS-LAST = SPB-FIRST(WS-B) + SPB-COUNT(WS-B)
             PERFORM VARYING WS-J FROM SPB-FIRST(WS-B) BY 1 UNTIL WS-J >= WS-LAST
                 IF SPE-CAT(WS-J + 1) = WS-G-CAT(WS-I)
                     MOVE SPE-WEIGHT(WS-J + 1) TO WS-WEIGHT
                     MOVE SPE-MIN(WS-J + 1) TO WS-MIN
                     MOVE SPE-MAX(WS-J + 1) TO WS-MAX
                     MOVE SPE-KEY(WS-J + 1) TO WS-KEY
                     STRING FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE ":" DELIMITED BY SIZE
                         FUNCTION TRIM(WS-WEIGHT, LEADING) DELIMITED BY SIZE ":" DELIMITED BY SIZE
                         FUNCTION TRIM(WS-MIN, LEADING) DELIMITED BY SIZE "-" DELIMITED BY SIZE
                         FUNCTION TRIM(WS-MAX, LEADING) DELIMITED BY SIZE ";" DELIMITED BY SIZE
                         INTO WS-LIST WITH POINTER WS-PTR
                 END-IF
             END-PERFORM
         END-IF
         MOVE WS-G-CAT(WS-I) TO WS-CATTEXT
         MOVE SPACES TO TL-CASE
         IF WS-I <= AQUATIC
             STRING "acceptance US15 21§3.3 " DELIMITED BY SIZE FUNCTION TRIM(WS-G-BIOME(WS-I)) DELIMITED BY SIZE
                 " category " DELIMITED BY SIZE WS-CATTEXT DELIMITED BY SIZE INTO TL-CASE
         ELSE
             STRING "acceptance US15 21§3.4 " DELIMITED BY SIZE FUNCTION TRIM(WS-G-BIOME(WS-I)) DELIMITED BY SIZE
                 " category " DELIMITED BY SIZE WS-CATTEXT DELIMITED BY SIZE INTO TL-CASE
         END-IF
         MOVE WS-G-LIST(WS-I) TO TL-EXPECTED
         MOVE WS-LIST TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-21-3-4.
