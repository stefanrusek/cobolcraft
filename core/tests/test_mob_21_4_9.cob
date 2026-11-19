*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.9 with 21 section 3.2 and 20 section 4.5): the drowned's spawn predicate and biome weights. The weights are the drowned entries of
*> every biome of doc 18 Appendix A (GENERATED from that table by a script that reads only the markdown: one case per biome compares the monster entry in MOBSPAWN.cpy). The row is the zombie's (health 20,
*> attack 3, experience 5, burns in daylight) with the IN_WATER predicate: water below unless a spawner, not Peaceful, the monster light test unless the trial spawner, water at the position unless a spawner,
*> then a spawner accepts and otherwise nextInt(15) = 0 in rivers or nextInt(40) = 0 below sea level - 5 elsewhere. Doc 21 section 4.9 says the weights are in its section 3.3: they are in doc 18 Appendix A.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY CBLOCKS.
 COPY MOBSPAWN.
 COPY XORO.
 78 BIOMES VALUE 67.
 01 WS-BIOME-DATA.
    05 FILLER.
       10 FILLER PIC X(32) VALUE "badlands".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "bamboo_jungle".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "basalt_deltas".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "beach".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "birch_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cherry_grove".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "cold_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "crimson_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dappled_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dark_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_cold_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_dark".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_frozen_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_lukewarm_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "deep_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "desert".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "dripstone_caves".
       10 FILLER PIC X(40) VALUE "drowned:95:4-4;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_barrens".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_highlands".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "end_midlands".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "eroded_badlands".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "flower_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_peaks".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "frozen_river".
       10 FILLER PIC X(40) VALUE "drowned:1:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "grove".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ice_spikes".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "jagged_peaks".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "jungle".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lukewarm_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "lush_caves".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "mangrove_swamp".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "meadow".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "mushroom_fields".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "nether_wastes".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_birch_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_pine_taiga".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "old_growth_spruce_taiga".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "pale_garden".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "plains".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "river".
       10 FILLER PIC X(40) VALUE "drowned:100:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "savanna".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "savanna_plateau".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "small_end_islands".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_beach".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_plains".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_slopes".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "snowy_taiga".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "soul_sand_valley".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "sparse_jungle".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "stony_peaks".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "stony_shore".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "sulfur_caves".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "sunflower_plains".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "swamp".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "taiga".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "the_end".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "the_void".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warm_ocean".
       10 FILLER PIC X(40) VALUE "drowned:5:1-1;".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "warped_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_forest".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_gravelly_hills".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_hills".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "windswept_savanna".
       10 FILLER PIC X(40) VALUE "none".
    05 FILLER.
       10 FILLER PIC X(32) VALUE "wooded_badlands".
       10 FILLER PIC X(40) VALUE "none".
 01 WS-BIOME-TABLE REDEFINES WS-BIOME-DATA.
    05 WS-BR OCCURS BIOMES TIMES.
       10 WS-BR-NAME          PIC X(32).
       10 WS-BR-LIST          PIC X(40).

 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-DROWNED             BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LIST                PIC X(40).
 01 WS-PTR                 BINARY-LONG.
 01 WS-W                   PIC ZZ9.
 01 WS-MIN                 PIC ZZ9.
 01 WS-MAX                 PIC ZZ9.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-PASS                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-BID                 BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BIOMES
         MOVE 0 TO WS-B
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-BIOMES
             IF SPB-NAME(WS-J) = WS-BR-NAME(WS-I)
                 MOVE WS-J TO WS-B
             END-IF
         END-PERFORM
         MOVE "none" TO WS-LIST
         MOVE 1 TO WS-PTR
         IF WS-B > 0
             COMPUTE WS-LAST = SPB-FIRST(WS-B) + SPB-COUNT(WS-B)
             PERFORM VARYING WS-J FROM SPB-FIRST(WS-B) BY 1 UNTIL WS-J >= WS-LAST
                 IF SPE-CAT(WS-J + 1) = 1 AND SPE-KEY(WS-J + 1) = "drowned"
                     MOVE SPACES TO WS-LIST
                     MOVE SPE-WEIGHT(WS-J + 1) TO WS-W
                     MOVE SPE-MIN(WS-J + 1) TO WS-MIN
                     MOVE SPE-MAX(WS-J + 1) TO WS-MAX
                     STRING "drowned:" DELIMITED BY SIZE FUNCTION TRIM(WS-W, LEADING) DELIMITED BY SIZE ":" DELIMITED BY SIZE
                         FUNCTION TRIM(WS-MIN, LEADING) DELIMITED BY SIZE "-" DELIMITED BY SIZE
                         FUNCTION TRIM(WS-MAX, LEADING) DELIMITED BY SIZE ";" DELIMITED BY SIZE INTO WS-LIST
                 END-IF
             END-PERFORM
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§4.9 drowned weight in " DELIMITED BY SIZE FUNCTION TRIM(WS-BR-NAME(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-BR-LIST(WS-I) TO TL-EXPECTED
         MOVE WS-LIST TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:drowned" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DROWNED WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-DROWNED WS-M
     MOVE "acceptance US15 21§4.9 the drowned has a mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-M > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 20§4.5 drowned: max health 20 (as the zombie)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 20§4.5 drowned: attack damage 3, experience 5, burns in daylight" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SM-ATTACK(WS-M) = 3 AND SM-XP(WS-M) = 5 AND SM-BURNS(WS-M) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.9 the drowned spawns in the monster category (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "MS6-ROW-CAT" USING WS-M TL-OBSERVED-N
     PERFORM CHECK-N
*>   The spawn predicate in sealed 3-cell water columns (stone above and below: dark): one 12 below the sea level of the dimension and one 3 below it.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BZ = WS-Z0 + 4
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     COMPUTE WS-LOW = WS-SEA - 12
     MOVE WS-LOW TO WS-BY
     PERFORM MAKE-COLUMN
     COMPUTE WS-HIGH = WS-SEA - 3
     MOVE WS-HIGH TO WS-BY
     PERFORM MAKE-COLUMN
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     MOVE 2 TO CBI-COUNT
     MOVE "minecraft:ocean" TO CBI-KEY(1)
     MOVE "minecraft:river" TO CBI-KEY(2)
     MOVE 0 TO WS-BID
     PERFORM SET-BIOME
     MOVE 0 TO WS-REASON
     MOVE WS-LOW TO WS-BY
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 in an ocean below sea level - 5 the drowned passes on about 1 draw in 40 (400 seeds: 3 to 25)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASS >= 3 AND WS-PASS <= 25
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE WS-HIGH TO WS-BY
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 at or above sea level - 5 an ocean drowned never spawns" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO WS-BID
     PERFORM SET-BIOME
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 in a river (more_frequent_drowned_spawns) it passes on about 1 draw in 15 at any height (400 seeds: 14 to 45)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PASS >= 14 AND WS-PASS <= 45
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 2 TO WS-REASON
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 a spawner (dark enough, water at the position) accepts without a draw" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO WS-REASON
*>   Stone at the position fails a natural spawn; stone below fails it too (water below is needed unless a spawner).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 no water at the position: a natural drowned never passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO WS-BY
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 no water below: never passes either" TO TL-CASE
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     SUBTRACT 1 FROM WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     MOVE 0 TO BW-DIFFICULTY
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     MOVE "acceptance US15 21§3.2 on Peaceful it never passes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
     STOP RUN.
*> MAKE-COLUMN: water at (WS-BX, WS-BY - 1 to WS-BY + 1, WS-BZ) between stone at WS-BY - 2 and WS-BY + 2.
 MAKE-COLUMN.
     COMPUTE WS-CELL = WS-BY - 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-STONE
     COMPUTE WS-CELL = WS-BY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-WATER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     COMPUTE WS-CELL = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-WATER
     COMPUTE WS-CELL = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-STONE.
 SET-BIOME.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE WS-BID TO CE-BIOME(WS-I)
     END-PERFORM.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-9.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
