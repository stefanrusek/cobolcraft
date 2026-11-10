*> Test of the spawn data loaders (T0290; docs/protocol/44-residual-mob-questions-2-spawning-structures.md sections 7.1 to 7.3,
*> 18-mob-framework.md section 6.6, 21 section 3.3 and 3.4, 23 section 9.1, 19 section 1; 21 section 2 for the entity rows).
*> SPAWN-DATA-LOAD USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error and nothing of the load staying): the biome files of data/<namespace>/worldgen/biome (the attribute
*> minecraft:gameplay/natural_mob_spawns: spawns_by_category and spawn_costs) and the seven variant registries with spawn_conditions
*> are checked through the shape engine. Accessors: SPAWN-LIST-COUNT USING biome key (PIC X(112)), category (PIC X(32)), count out
*> (BINARY-LONG; -1 when the biome does not define the category, 0 when it defines it empty), status out (CT-OK, CT-NOT-FOUND for
*> an unknown biome); SPAWN-LIST-ENTRY USING biome key, category, index (1-based), type out (PIC X(112)), weight, minimum, maximum
*> (BINARY-LONG), status; SPAWN-COST USING biome key, entity key (PIC X(112)), charge, energy budget (FLOAT-LONG), status;
*> SPAWN-VARIANT-COUNT USING registry (PIC X(48)), key, count out, status; SPAWN-VARIANT-SELECTOR USING registry, key, index,
*> priority out, kind out (0 no condition, 1 biome, 2 structure, 3 moon_brightness), argument out (PIC X(112): the first identifier
*> or #tag of the biomes or structures), status. The CT-ENTITY-ROW size and category of 21 section 2 are asked of
*> CONTENT-ENTITY-BY-KEY. The fixture tree is content/tests/fixtures/load-44; each reject case copies a file of
*> content/tests/fixtures/load-44-bad into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPAWN-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BIOME               PIC X(112).
 01 WS-CATEGORY            PIC X(32).
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-TYPE                PIC X(112).
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-PRIORITY            BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ARGUMENT            PIC X(112).
 01 WS-CHARGE              USAGE FLOAT-LONG.
 01 WS-BUDGET              USAGE FLOAT-LONG.
 01 WS-EDITED              PIC -9.99.
 01 WS-ENTITY-ID           BINARY-LONG.
 01 WS-ROW                 PIC X(66).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(3).
    05 WS-R-KEY            PIC X(22).
    05 WS-R-SIZE           PIC X(15).
    05 WS-R-CATEGORY       PIC X(26).
 01 WS-COMMAND             PIC X(600).
 01 WS-T                   PIC X(60).
 01 WS-PATH                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC 99.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a biome spawn category dragons".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry without a type".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry of weight -1".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry whose weight is a string".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry whose count is a string".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry whose uniform count has no max".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawner entry without a weight".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "spawns_by_category that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawn category whose list is an object".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawn cost without a charge".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a spawn cost that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "spawn_costs that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "attributes that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "natural_mob_spawns that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "natural_mob_spawns whose argument is a number".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a variant without spawn_conditions".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a variant whose spawn_conditions is an object".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a variant selector without a priority".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a variant condition of an unknown type".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a biome condition without biomes".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a structure condition whose structures is a number".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a moon_brightness condition without a range".
    05 FILLER PIC X(48) VALUE "wolf_variant/bad.json".
    05 FILLER PIC X(60) VALUE "a biome file that is not JSON".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(60) VALUE "a biome file with a bad identifier".
    05 FILLER PIC X(48) VALUE "worldgen/biome/Bad.json".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 24 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(48).
 PROCEDURE DIVISION.
*>   The entity rows (21 section 2): size and category.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "creeper" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "acceptance US15 entity creeper is entity 32" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-ENTITY-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 entity creeper size" TO TL-CASE
     MOVE "0.6 x 1.7" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US15 entity creeper category" TO TL-CASE
     MOVE "MONSTER" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "ender_dragon" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "acceptance US15 entity ender_dragon size" TO TL-CASE
     MOVE "16.0 x 8.0" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "glow_squid" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "acceptance US15 entity glow_squid category" TO TL-CASE
     MOVE "UNDERGROUND_WATER_CREATURE" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "axolotl" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "acceptance US15 entity axolotl category" TO TL-CASE
     MOVE "AXOLOTLS" TO TL-EXPECTED
     MOVE WS-R-CATEGORY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "acacia_boat" TO WS-KEY
     PERFORM ENTITY-ROW
     MOVE "acceptance US15 entity acacia_boat size" TO TL-CASE
     MOVE "1.375 x 0.5625" TO TL-EXPECTED
     MOVE WS-R-SIZE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 0 TO CT-OPEN

     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-44" TO WS-DIR
     CALL "SPAWN-DATA-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US15 spawn data the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 spawn data 7 biomes and 11 variants are 18 elements" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Biome lists (44 section 7.3: not defined, defined and empty, defined; the plain form and the argument form).
     MOVE "minecraft:plains" TO WS-BIOME
     MOVE "creature" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 plains creature list has 2 entries" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains creature 1 is sheep" TO TL-CASE
     MOVE "minecraft:sheep" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US15 plains creature 1 weight 12" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-WEIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 plains creature 1 count 4 to 4 (a bare integer)" TO TL-CASE
     MOVE 44 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MIN * 10 + WS-MAX
     PERFORM ASSERT-NUM
     MOVE 2 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains creature 2 is horse" TO TL-CASE
     MOVE "minecraft:horse" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US15 plains creature 2 count 2 to 6 (uniform)" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MIN * 10 + WS-MAX
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 plains creature 2 weight 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-WEIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 3 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains creature 3 is not there" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 0 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains creature 0 is not there" TO TL-CASE
     PERFORM ASSERT-NUM
     MOVE "monster" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 plains monster list has 1 entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains monster 1 count is a constant 4 to 4" TO TL-CASE
     MOVE 44 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MIN * 10 + WS-MAX
     PERFORM ASSERT-NUM
     MOVE "ambient" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 plains ambient is defined and empty (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "water_creature" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 plains water_creature is not defined (-1)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 plains water_creature status is ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "water_creature" TO WS-CATEGORY
     MOVE 1 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 plains water_creature entry 1 is not there" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Duplicate entries are two list items (44 section 7.2).
     MOVE "minecraft:swamp" TO WS-BIOME
     MOVE "monster" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 swamp monster list keeps both slime entries" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 swamp slime 1 weight 100 count 4" TO TL-CASE
     MOVE 10044 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-WEIGHT * 100 + WS-MIN * 10 + WS-MAX
     PERFORM ASSERT-NUM
     MOVE 2 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 swamp slime 2 weight 1 count 1" TO TL-CASE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-WEIGHT * 100 + WS-MIN * 10 + WS-MAX
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 swamp slime 2 is slime" TO TL-CASE
     MOVE "minecraft:slime" TO TL-EXPECTED
     MOVE WS-TYPE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   The plain form, no attribute, an unknown biome, the all-empty biome.
     MOVE "minecraft:meadow" TO WS-BIOME
     MOVE "creature" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 meadow (plain form) creature list has 1 entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:the_void" TO WS-BIOME
     PERFORM LIST-COUNT
     MOVE "acceptance US15 the_void (other attributes only) creature is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:bare" TO WS-BIOME
     PERFORM LIST-COUNT
     MOVE "acceptance US15 bare (no attributes) creature is -1" TO TL-CASE
     PERFORM ASSERT-NUM
     MOVE "minecraft:nowhere" TO WS-BIOME
     PERFORM LIST-COUNT
     MOVE "acceptance US15 an unknown biome is CT-NOT-FOUND" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 an unknown biome has count -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM LIST-ENTRY
     MOVE "acceptance US15 an unknown biome has no entry" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:deep_dark" TO WS-BIOME
     MOVE 0 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE "ambient" TO WS-CATEGORY
             WHEN 2 MOVE "axolotls" TO WS-CATEGORY
             WHEN 3 MOVE "creature" TO WS-CATEGORY
             WHEN 4 MOVE "misc" TO WS-CATEGORY
             WHEN 5 MOVE "monster" TO WS-CATEGORY
             WHEN 6 MOVE "underground_water_creature" TO WS-CATEGORY
             WHEN 7 MOVE "water_ambient" TO WS-CATEGORY
             WHEN OTHER MOVE "water_creature" TO WS-CATEGORY
         END-EVALUATE
         PERFORM LIST-COUNT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 deep_dark lists " FUNCTION TRIM(WS-CATEGORY) " empty" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-COUNT TO TL-OBSERVED-N
         PERFORM ASSERT-NUM
     END-PERFORM

*>   Spawn costs (21 section 3.4).
     MOVE "minecraft:soul_sand_valley" TO WS-BIOME
     MOVE "monster" TO WS-CATEGORY
     PERFORM LIST-COUNT
     MOVE "acceptance US15 soul_sand_valley monster list has 2 entries" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:enderman" TO WS-KEY
     PERFORM COST
     MOVE "acceptance US15 soul_sand_valley enderman has a cost" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     COMPUTE WS-EDITED ROUNDED = WS-CHARGE
     MOVE "acceptance US15 soul_sand_valley enderman charge 0.7" TO TL-CASE
     MOVE " 0.70" TO TL-EXPECTED
     MOVE WS-EDITED TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     COMPUTE WS-EDITED ROUNDED = WS-BUDGET
     MOVE "acceptance US15 soul_sand_valley enderman energy budget 0.15" TO TL-CASE
     MOVE " 0.15" TO TL-EXPECTED
     MOVE WS-EDITED TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:creeper" TO WS-KEY
     PERFORM COST
     MOVE "acceptance US15 soul_sand_valley creeper has no cost" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:swamp" TO WS-BIOME
     MOVE "minecraft:slime" TO WS-KEY
     PERFORM COST
     MOVE "acceptance US15 swamp (no spawn_costs) has no cost" TO TL-CASE
     PERFORM ASSERT-NUM
     MOVE "minecraft:nowhere" TO WS-BIOME
     PERFORM COST
     MOVE "acceptance US15 an unknown biome has no cost" TO TL-CASE
     PERFORM ASSERT-NUM
     MOVE "minecraft:bare" TO WS-BIOME
     PERFORM COST
     MOVE "acceptance US15 bare (no attributes) has no cost" TO TL-CASE
     PERFORM ASSERT-NUM

*>   Mob variants (19 section 1, 23 section 9.1).
     MOVE "wolf_variant" TO WS-REGISTRY
     MOVE "minecraft:ashen" TO WS-KEY
     PERFORM VARIANT-COUNT
     MOVE "acceptance US15 wolf ashen has 1 selector" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 wolf ashen selector 1 priority 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PRIORITY TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 wolf ashen selector 1 is a biome condition" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 wolf ashen selector 1 names snowy_taiga" TO TL-CASE
     MOVE "minecraft:snowy_taiga" TO TL-EXPECTED
     MOVE WS-ARGUMENT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:rusty" TO WS-KEY
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 wolf rusty selector names the tag is_jungle" TO TL-CASE
     MOVE "#minecraft:is_jungle" TO TL-EXPECTED
     MOVE WS-ARGUMENT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:pale" TO WS-KEY
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 wolf pale selector has priority 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PRIORITY TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 wolf pale selector has no condition (kind 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 2 TO WS-INDEX
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 wolf pale selector 2 is not there" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "cat_variant" TO WS-REGISTRY
     MOVE "minecraft:all_black" TO WS-KEY
     PERFORM VARIANT-COUNT
     MOVE "acceptance US15 cat all_black has 2 selectors" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 cat all_black selector 1 is a structure condition" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 cat all_black selector 1 names cats_spawn_as_black" TO TL-CASE
     MOVE "#minecraft:cats_spawn_as_black" TO TL-EXPECTED
     MOVE WS-ARGUMENT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-INDEX
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 cat all_black selector 2 is a moon_brightness condition" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 cat all_black selector 2 has priority 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PRIORITY TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "pig_variant" TO WS-REGISTRY
     MOVE "minecraft:cold" TO WS-KEY
     MOVE 1 TO WS-INDEX
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 pig cold names the first of two biomes" TO TL-CASE
     MOVE "minecraft:taiga" TO TL-EXPECTED
     MOVE WS-ARGUMENT TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:absent" TO WS-KEY
     PERFORM VARIANT-COUNT
     MOVE "acceptance US15 an absent variant is CT-NOT-FOUND" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 an absent variant has count 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARIANT-SELECTOR
     MOVE "acceptance US15 an absent variant has no selector" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-44/t" TO WS-DIR
     MOVE WS-I TO WS-N-TEXT
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-44 2>/dev/null; rm -rf build/content-test/load-44; "
         "mkdir -p build/content-test/load-44 && cp -R content/tests/fixtures/load-44 build/content-test/load-44/t && "
         "cp content/tests/fixtures/load-44-bad/" WS-N-TEXT ".json build/content-test/load-44/t/data/minecraft/"
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "SPAWN-DATA-LOAD" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 spawn data " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 spawn data after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ENTITY-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ENTITY-ID WS-ROW WS-STATUS.

 LIST-COUNT.
     CALL "SPAWN-LIST-COUNT" USING WS-BIOME WS-CATEGORY WS-COUNT WS-STATUS.

 LIST-ENTRY.
     CALL "SPAWN-LIST-ENTRY" USING WS-BIOME WS-CATEGORY WS-INDEX WS-TYPE WS-WEIGHT WS-MIN WS-MAX WS-STATUS.

 COST.
     CALL "SPAWN-COST" USING WS-BIOME WS-KEY WS-CHARGE WS-BUDGET WS-STATUS.

 VARIANT-COUNT.
     CALL "SPAWN-VARIANT-COUNT" USING WS-REGISTRY WS-KEY WS-COUNT WS-STATUS.

 VARIANT-SELECTOR.
     CALL "SPAWN-VARIANT-SELECTOR" USING WS-REGISTRY WS-KEY WS-INDEX WS-PRIORITY WS-KIND WS-ARGUMENT WS-STATUS.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
