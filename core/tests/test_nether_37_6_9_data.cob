*> Test of the Nether's natural-spawn data (docs/protocol/37-nether-6 sections 9.1 to 9.4; T1717): the per-biome lists of the five Nether biomes in the spawner's table (MOBSPAWN.cpy, read by
*> MS6-LIST-TOTAL, MS6-COST-FIND and the entry table: entity, weight and pack size per category in list order, the category totals, no other category, the default world-generation probability 0.1),
*> the spawn costs of 9.3 and the fortress override of 9.4 (NETHER-FORTRESS-SPAWN, total weight 28).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-9-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBSPAWN.
 01 WS-KEY                 PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N1                  PIC Z(3)9.
 01 WS-N2                  PIC Z(3)9.
 01 WS-N3                  PIC Z(3)9.
 01 WS-CASE                PIC X(200).
 01 WS-BIOME               PIC X(24).
 01 WS-EXPECT              BINARY-DOUBLE SIGNED.
 01 WS-V                   BINARY-DOUBLE SIGNED.
 01 WS-ENTITY              PIC X(20).
 01 WS-COST-KEY            PIC X(24).
 01 WS-LEN                 BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST                PIC X(400).
 01 WS-WANT                PIC X(400).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "nether_wastes" TO WS-BIOME
     MOVE "ghast 50 4-4,zombified_piglin 100 4-4,magma_cube 2 4-4,enderman 1 4-4,piglin 15 4-4," TO WS-WANT
     PERFORM LIST-CASE
     MOVE "crimson_forest" TO WS-BIOME
     MOVE "zombified_piglin 1 2-4,hoglin 9 3-4,piglin 5 3-4," TO WS-WANT
     PERFORM LIST-CASE
     MOVE "warped_forest" TO WS-BIOME
     MOVE "enderman 1 4-4," TO WS-WANT
     PERFORM LIST-CASE
     MOVE "soul_sand_valley" TO WS-BIOME
     MOVE "skeleton 20 5-5,ghast 50 4-4,enderman 1 4-4," TO WS-WANT
     PERFORM LIST-CASE
     MOVE "basalt_deltas" TO WS-BIOME
     MOVE "ghast 40 1-1,magma_cube 100 2-5," TO WS-WANT
     PERFORM LIST-CASE
     PERFORM COST-CASES
     PERFORM OVERRIDE-CASES
     GOBACK.

 CHECK-V.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§9 Natural spawning in the Nether: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§9 Natural spawning in the Nether: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

*> the monster list (category 1) in order, the strider-only creature list (category 2), the totals and the empty other categories of one biome
 LIST-CASE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-BIOME) DELIMITED BY SIZE INTO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE WS-ROW TO WS-V
     MOVE 1 TO WS-EXPECT
     IF WS-ROW > 0
         MOVE 1 TO WS-V
     ELSE
         MOVE 0 TO WS-V
     END-IF
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " is in the spawn table" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-V
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     COMPUTE WS-LAST = SPB-FIRST(WS-ROW) + SPB-COUNT(WS-ROW)
     PERFORM VARYING WS-I FROM SPB-FIRST(WS-ROW) BY 1 UNTIL WS-I >= WS-LAST
         IF SPE-CAT(WS-I + 1) = 1
             MOVE SPE-WEIGHT(WS-I + 1) TO WS-N1
             MOVE SPE-MIN(WS-I + 1) TO WS-N2
             MOVE SPE-MAX(WS-I + 1) TO WS-N3
             STRING FUNCTION TRIM(SPE-KEY(WS-I + 1)) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) "-" FUNCTION TRIM(WS-N3) ","
                 DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE WS-LIST TO TL-OBSERVED
     MOVE WS-WANT TO TL-EXPECTED
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " monster list: entity, weight and pack size in order" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-CAT
     CALL "MS6-LIST-TOTAL" USING WS-ROW WS-CAT WS-TOTAL
     MOVE WS-TOTAL TO WS-V
     EVALUATE WS-BIOME
         WHEN "nether_wastes" MOVE 168 TO WS-EXPECT
         WHEN "crimson_forest" MOVE 15 TO WS-EXPECT
         WHEN "warped_forest" MOVE 1 TO WS-EXPECT
         WHEN "soul_sand_valley" MOVE 71 TO WS-EXPECT
         WHEN "basalt_deltas" MOVE 140 TO WS-EXPECT
     END-EVALUATE
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " monster total weight" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-V
*>   the creature list is the single strider entry: 60, pack size 1 to 2
     MOVE 0 TO WS-SUM
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM SPB-FIRST(WS-ROW) BY 1 UNTIL WS-I >= WS-LAST
         IF SPE-CAT(WS-I + 1) = 2
             MOVE SPE-WEIGHT(WS-I + 1) TO WS-N1
             MOVE SPE-MIN(WS-I + 1) TO WS-N2
             MOVE SPE-MAX(WS-I + 1) TO WS-N3
             STRING FUNCTION TRIM(SPE-KEY(WS-I + 1)) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) "-" FUNCTION TRIM(WS-N3) ","
                 DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE WS-LIST TO TL-OBSERVED
     MOVE "strider 60 1-2," TO TL-EXPECTED
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " creature list is the single strider entry, weight 60, 1 to 2" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-TEXT
*>   no other category is defined
     PERFORM VARYING WS-CAT FROM 3 BY 1 UNTIL WS-CAT > 7
         CALL "MS6-LIST-TOTAL" USING WS-ROW WS-CAT WS-TOTAL
         ADD WS-TOTAL TO WS-SUM
     END-PERFORM
     MOVE WS-SUM TO WS-V
     MOVE 0 TO WS-EXPECT
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " defines no ambient, water or underground water list" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-V
     MOVE SPB-PROB(WS-ROW) TO WS-V
     MOVE 100 TO WS-EXPECT
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-BIOME) " has the default creature_world_gen_spawn_probability 0.1 (100 thousandths)" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-V.

*> 9.3: warped forest enderman 1.0 / 0.12, soul sand valley enderman, ghast, skeleton, strider 0.7 / 0.15 (thousandths), none elsewhere
 COST-CASES.
     MOVE "minecraft:nether_wastes" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE SPB-COST-COUNT(WS-ROW) TO WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "nether_wastes has no spawn costs" TO WS-CASE
     PERFORM CHECK-V
     MOVE "minecraft:crimson_forest" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE SPB-COST-COUNT(WS-ROW) TO WS-V
     MOVE "crimson_forest has no spawn costs" TO WS-CASE
     PERFORM CHECK-V
     MOVE "minecraft:basalt_deltas" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE SPB-COST-COUNT(WS-ROW) TO WS-V
     MOVE "basalt_deltas has no spawn costs" TO WS-CASE
     PERFORM CHECK-V
     MOVE "minecraft:warped_forest" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE SPB-COST-COUNT(WS-ROW) TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "warped_forest has one spawn cost" TO WS-CASE
     PERFORM CHECK-V
     MOVE "enderman" TO WS-ENTITY
     MOVE WS-ENTITY TO WS-COST-KEY
     CALL "MS6-COST-FIND" USING WS-ROW WS-COST-KEY WS-INDEX
     MOVE SPC-CHARGE(WS-INDEX) TO WS-V
     MOVE 1000 TO WS-EXPECT
     MOVE "warped_forest enderman charge 1.0" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPC-BUDGET(WS-INDEX) TO WS-V
     MOVE 120 TO WS-EXPECT
     MOVE "warped_forest enderman energy budget 0.12" TO WS-CASE
     PERFORM CHECK-V
     MOVE "minecraft:soul_sand_valley" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-ROW
     MOVE SPB-COST-COUNT(WS-ROW) TO WS-V
     MOVE 4 TO WS-EXPECT
     MOVE "soul_sand_valley has four spawn costs" TO WS-CASE
     PERFORM CHECK-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "enderman" TO WS-ENTITY
             WHEN 2 MOVE "ghast" TO WS-ENTITY
             WHEN 3 MOVE "skeleton" TO WS-ENTITY
             WHEN 4 MOVE "strider" TO WS-ENTITY
         END-EVALUATE
         MOVE WS-ENTITY TO WS-COST-KEY
     CALL "MS6-COST-FIND" USING WS-ROW WS-COST-KEY WS-INDEX
         MOVE SPC-CHARGE(WS-INDEX) TO WS-V
         MOVE 700 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING "soul_sand_valley " FUNCTION TRIM(WS-ENTITY) " charge 0.7" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
         MOVE SPC-BUDGET(WS-INDEX) TO WS-V
         MOVE 150 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING "soul_sand_valley " FUNCTION TRIM(WS-ENTITY) " energy budget 0.15" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
     END-PERFORM.

*> 9.4: the five entries of the fortress override, total weight 28
 OVERRIDE-CASES.
     MOVE 0 TO WS-SUM
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "NETHER-FORTRESS-SPAWN" USING WS-I WS-ENTITY WS-LEN WS-WEIGHT WS-MIN WS-MAX
         ADD WS-WEIGHT TO WS-SUM
         MOVE WS-WEIGHT TO WS-N1
         MOVE WS-MIN TO WS-N2
         MOVE WS-MAX TO WS-N3
         STRING WS-ENTITY(1:WS-LEN) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) "-" FUNCTION TRIM(WS-N3) "," DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-LIST TO TL-OBSERVED
     MOVE "blaze 10 2-3,zombified_piglin 5 4-4,wither_skeleton 8 5-5,skeleton 2 5-5,magma_cube 3 4-4," TO TL-EXPECTED
     MOVE "fortress override: blaze, zombified_piglin, wither_skeleton, skeleton, magma_cube with weights and pack sizes" TO WS-CASE
     PERFORM CHECK-TEXT
     MOVE WS-SUM TO WS-V
     MOVE 28 TO WS-EXPECT
     MOVE "fortress override total weight is 28" TO WS-CASE
     PERFORM CHECK-V.
 END PROGRAM TEST-NETHER-37-6-9-DATA.
