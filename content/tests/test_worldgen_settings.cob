*> Test of the noise settings, surface rule, carver and ore feature loaders (T0224; docs/protocol/10-world-generation-terrain.md
*> sections 5, 9.1 and 10, 11 sections 5 and 7, 23 section 7, 37-nether-2 section 2, 37-nether-4 section 6).
*> NOISE-SETTINGS-LOAD, MATERIAL-RULES-LOAD (material_condition and material_rule), CARVERS-LOAD and ORE-FEATURES-LOAD
*> USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <kind> <key>: <detail>"; nothing of the failed registry stays loaded) build
*> function rows (CTWORLDGEN.cpy kinds 6, 3 and 2, 4, 5) over trees of nodes: the noise settings (domain 11: integers,
*> the block and fluid states, the surface rule, the eight router functions, the six aquifer functions and the spawn
*> boxes), the surface rules (domain 2) and conditions (domain 3) with their anchors, the carvers (domain 8) with
*> their value providers (domains 5, 6, 7) and the ore features (domain 9, only features of type minecraft:ore are
*> kept) with their targets (domain 10) and rule tests (domain 4). A block state is its name, then " name=value" for
*> each property. Fixture tree: content/tests/fixtures/worldgen.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDGEN-SETTINGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NODE                BINARY-LONG.
 01 WS-NODE-2              BINARY-LONG.
 01 WS-NODE-3              BINARY-LONG.
 01 WS-LABEL               PIC X(70).
 01 WS-GOT-N               BINARY-LONG.
 01 WS-WANT-N              BINARY-LONG.
 01 WS-GOT-T               PIC X(200).
 01 WS-WANT-T              PIC X(200).
 01 WS-GOT-F               USAGE FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-WANT-BITS           BINARY-DOUBLE.
 01 WS-DOMAIN              BINARY-LONG.
 01 WS-TYPE-NAME           PIC X(32).
 01 WS-FIELDS              PIC X(640).
 01 WS-T                   PIC X(70).
 01 WS-N                   BINARY-LONG.
 01 WS-N-TEXT              PIC Z(4)9.
 01 WS-DIR-NAME            PIC X(60).
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1000).
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/worldgen" TO WS-DIR

*>   Noise settings (10 5, 9.1; 37-2 2.1).
     MOVE 6 TO WS-KIND
     CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
     MOVE "settings: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "settings: 2 files" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:nether" TO WS-WANT-T
     PERFORM ASSERT-ORDER

     MOVE "minecraft:overworld" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "sea_level" TO WS-LABEL
     MOVE 63 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "noise.min_y" TO WS-LABEL
     MOVE -64 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "noise.height" TO WS-LABEL
     MOVE 384 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "legacy_random_source false" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "default_block" TO WS-LABEL
     MOVE "minecraft:stone" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "default_fluid with its property" TO WS-LABEL
     MOVE "minecraft:water level=0" TO WS-WANT-T
     MOVE WGN-TEXT-2(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "material_rule is a reference" TO WS-LABEL
     MOVE "minecraft:overworld" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-2
     MOVE "router temperature" TO WS-LABEL
     MOVE "minecraft:overworld/temperature" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE, 9) TO WS-NODE-2
     MOVE "router final_density is inline" TO WS-LABEL
     MOVE WGN-TYPE(WS-NODE-2) TO WS-GOT-N
     MOVE WS-NODE-2 TO WS-NODE-3
     MOVE WS-NODE TO WS-N
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "squeeze" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WS-N TO WS-NODE
     MOVE WGN-CHILD(WS-NODE, 10) TO WS-NODE-2
     MOVE "aquifer barrier is a noise node" TO WS-LABEL
     MOVE WS-NODE-2 TO WS-N
     MOVE WS-NODE TO WS-NODE-3
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "noise" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "aquifer barrier noise id" TO WS-LABEL
     MOVE "minecraft:aquifer_barrier" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WS-NODE-3 TO WS-NODE
     MOVE WGN-CHILD(WS-NODE, 14) TO WS-NODE-2
     MOVE "aquifer exclusion 0.0 is a constant" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 16) TO WS-NODE-2
     MOVE "spawn box 1 continentalness min bits of -0.11" TO WS-LABEL
     MOVE -4630781280847438807 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "spawn box 1 ridges max bits of -0.16" TO WS-LABEL
     MOVE -4628439409041206149 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 10) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "spawn box 1 erosion max" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE-2, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE "spawn box 2 ridges min bits of 0.16" TO WS-LABEL
     MOVE 4594932627813569659 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 9) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "no spawn box 3" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NEXT(WS-NODE-2) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:nether" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "sea_level" TO WS-LABEL
     MOVE 32 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "legacy_random_source true" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "disable_mob_generation left out" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "default_fluid without properties" TO WS-LABEL
     MOVE "minecraft:lava level=0" TO WS-WANT-T
     MOVE WGN-TEXT-2(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "no aquifer" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-CHILD(WS-NODE, 10) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "no spawn target" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 16) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "router depth is the constant 0" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 6) TO WS-NODE-2
     MOVE WGN-DOMAIN(WS-NODE-2) TO WS-GOT-N
     MOVE 1 TO WS-WANT-N
     PERFORM EXPECT-N
     CALL "WORLDGEN-FREE"

*>   Surface rules and conditions (10 10.4, 10.5).
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     MOVE "rules: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "rules: 2 conditions and 2 rules" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 3 TO WS-KIND
     MOVE "minecraft:on_floor" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "stone_depth" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "surface_type floor" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "add_surface_depth false" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:not_underwater" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "water" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "water offset" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE 2 TO WS-KIND
     MOVE "minecraft:nether" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "block" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "nether block state" TO WS-LABEL
     MOVE "minecraft:netherrack" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:overworld" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "sequence" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
*>   Rule 1: the bedrock floor, a vertical_gradient with two above_bottom anchors.
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "condition" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "vertical_gradient" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "random_name" TO WS-LABEL
     MOVE "minecraft:bedrock_floor" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "true_at_and_below kind above_bottom" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "false_at_and_above value" TO WS-LABEL
     MOVE 5 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE
     MOVE "block" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "bedrock state" TO WS-LABEL
     MOVE "minecraft:bedrock" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
*>   Rule 2: biome_is list, a nested sequence, a condition by reference, a state with a property.
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "biome" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "biome_is list joined" TO WS-LABEL
     MOVE "minecraft:swamp minecraft:plains" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE
     MOVE "sequence" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-3
     MOVE "condition by reference" TO WS-LABEL
     MOVE "minecraft:on_floor" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "reference has type 0" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-TYPE(WS-NODE-3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-3
     MOVE "state with a property" TO WS-LABEL
     MOVE "minecraft:grass_block snowy=false" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-3) TO WS-GOT-T
     PERFORM EXPECT-T
*>   Rule 3: not(y_above), noise_threshold, bandlands.
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE-3
     MOVE WS-NODE-2 TO WS-N
     MOVE WGN-NEXT(WS-N) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "not" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "y_above" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "y_above anchor kind absolute" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y_above anchor value" TO WS-LABEL
     MOVE 60 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y_above surface_depth_multiplier" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y_above add_stone_depth" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE-3
     MOVE WGN-CHILD(WS-NODE-3, 1) TO WS-NODE
     MOVE "noise_threshold" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "noise_threshold noise" TO WS-LABEL
     MOVE "minecraft:surface" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "noise_threshold max bits of 0.5" TO WS-LABEL
     MOVE 4602678819172646912 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "is_3d left out" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE-3, 2) TO WS-NODE
     MOVE "bandlands" TO WS-WANT-T
     PERFORM EXPECT-TYPE
*>   Rules 4 and 5: above_preliminary_surface with a rule by reference; biome_is as one string and ore_vein.
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "above_preliminary_surface" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE
     MOVE "rule by reference" TO WS-LABEL
     MOVE "minecraft:overworld_surface" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "biome_is one string" TO WS-LABEL
     MOVE "minecraft:desert" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE
     MOVE "ore_vein" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "ore_vein density reference" TO WS-LABEL
     MOVE "minecraft:overworld/ore_vein/copper_density" TO WS-WANT-T
     MOVE WGN-TEXT-1(WGN-CHILD(WS-NODE, 1)) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein richness reference" TO WS-LABEL
     MOVE "minecraft:overworld/ore_vein/richness" TO WS-WANT-T
     MOVE WGN-TEXT-1(WGN-CHILD(WS-NODE, 2)) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein filler_gap reference" TO WS-LABEL
     MOVE "minecraft:overworld/ore_vein/gap" TO WS-WANT-T
     MOVE WGN-TEXT-1(WGN-CHILD(WS-NODE, 3)) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein ore_block" TO WS-LABEL
     MOVE "minecraft:copper_ore" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein raw_ore_block" TO WS-LABEL
     MOVE "minecraft:raw_copper_block" TO WS-WANT-T
     MOVE WGN-TEXT-2(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein filler_block (third text slot)" TO WS-LABEL
     MOVE "minecraft:granite" TO WS-WANT-T
     MOVE WGN-TEXT-3(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ore_vein raw_ore_chance bits of 0.02" TO WS-LABEL
     MOVE 4581421828931458171 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "no sixth rule" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NEXT(WS-NODE-2) TO WS-GOT-N
     PERFORM EXPECT-N
     CALL "WORLDGEN-FREE"

*>   Carvers (11 5.1, 37-4 6.1).
     MOVE 4 TO WS-KIND
     CALL "CARVERS-LOAD" USING WS-DIR WS-STATUS
     MOVE "carvers: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "carvers: 3 carvers" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:canyon" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE "minecraft:cave" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "cave" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "probability bits of 0.15" TO WS-LABEL
     MOVE 4594572339843380019 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "weird_thickness_bias" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "start_vertical_radius_multiplier left out" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-CHILD(WS-NODE, 8) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE WS-NODE TO WS-N
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "uniform" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "y min anchor kind above_bottom" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y min anchor value" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y max anchor kind absolute" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y max anchor value" TO WS-LABEL
     MOVE 180 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WS-N TO WS-NODE-3
     MOVE WGN-CHILD(WS-NODE-3, 2) TO WS-NODE
     MOVE "very_biased_to_bottom" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "count max" TO WS-LABEL
     MOVE 14 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE-3, 3) TO WS-NODE
     MOVE "uniform" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "floor_level min bits of -1.0" TO WS-LABEL
     MOVE -4616189618054758400 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "floor_level max bits of -0.4" TO WS-LABEL
     MOVE -4622494657533077094 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE-3, 7) TO WS-NODE
     MOVE "trapezoid" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "thickness plateau" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:nether_cave" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "weird_thickness_bias defaults to false" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-2
     MOVE "a number count is a constant" TO WS-LABEL
     MOVE 9 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 3) TO WS-NODE-2
     MOVE "a number floor_level is a constant" TO WS-LABEL
     MOVE -4618891777831180698 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE, 8) TO WS-NODE-2
     MOVE "start_vertical_radius_multiplier bits of 5.0" TO WS-LABEL
     MOVE 4617315517961601024 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "y max anchor kind below_top" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 3) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:canyon" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "canyon" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "width_smoothness" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "y is biased_to_bottom with inner 3" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "y max anchor value" TO WS-LABEL
     MOVE 67 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 8) TO WS-NODE-2
     MOVE "shape.y_scale bits of 3.0" TO WS-LABEL
     MOVE 4613937818241073152 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE, 6) TO WS-NODE-2
     MOVE "shape.vertical_radius_center_factor bits of 0.0" TO WS-LABEL
     MOVE 0 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "probability bits of 0.01" TO WS-LABEL
     MOVE 4576918229304087675 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     CALL "WORLDGEN-FREE"

*>   Ore features (11 7, 8.1): only the minecraft:ore ones are kept.
     MOVE 5 TO WS-KIND
     CALL "ORE-FEATURES-LOAD" USING WS-DIR WS-STATUS
     MOVE "ore: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "ore: 2 ore features, the tree feature is left out" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:ore_dirt" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "size" TO WS-LABEL
     MOVE 33 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "discard_chance_on_air_exposure bits of 0.5" TO WS-LABEL
     MOVE 4602678819172646912 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "minecraft:ore_coal" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "ore" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "target 1 state" TO WS-LABEL
     MOVE "minecraft:coal_ore" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE-3
     MOVE WS-NODE-3 TO WS-NODE
     MOVE "any_of" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE-3, 1) TO WS-NODE
     MOVE "all_of" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "block_match" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "block_match block" TO WS-LABEL
     MOVE "minecraft:tuff" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-NEXT(WS-NODE) TO WS-NODE
     MOVE "height_match" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "height_match max value" TO WS-LABEL
     MOVE 2031 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "height_match max kind absolute" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE-3, 1) TO WS-NODE
     MOVE WGN-NEXT(WS-NODE) TO WS-NODE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "not" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "block_match" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE "target 2 state" TO WS-LABEL
     MOVE "minecraft:deepslate_coal_ore" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE-2, 1) TO WS-NODE
     MOVE "tag_match" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "tag_match tag" TO WS-LABEL
     MOVE "minecraft:deepslate_ore_replaceables" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     CALL "WORLDGEN-FREE"

*>   The type table: one row per node type, a domain 0 outside.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-NODE FROM 1 BY 1 UNTIL WS-NODE > 200 OR WS-DOMAIN = 0 AND WS-NODE > 1
         CALL "WG-TYPE-AT" USING WS-NODE WS-DOMAIN WS-TYPE-NAME WS-FIELDS
         IF WS-DOMAIN > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "type table: more than 60 types" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-N > 60
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM

*>   Noise settings failures (10 5, 37-2 2.1 guards).
     MOVE "settings without sea_level" TO WS-T
     MOVE "noise_settings" TO WS-DIR-NAME
     MOVE '{"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a height of 100" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":100},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a min_y of 8" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":8,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a min_y of 2032" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":2032,"height":16},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a height of 4080" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":-2032,"height":4080},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings above 2032" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":2000,"height":64},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings without a router entry" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings without a default_block" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a default_block that is a number" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":3,"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a state without a name" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"properties":{}},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a state whose properties are a list" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b","properties":[]},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a property value that is a number" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b","properties":{"p":1}},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a state over 160 bytes" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b","properties":{"p1":"0123456789012345678901234567890123456789","p2":"0123456789012345678901234567890123456789","p3":"0123456789012345678901234567890123456789","p4":"0123456789012345678901234567890123456789"}},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a fluid state over 112 bytes" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0}}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a spawn box without ridges" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":[{"minecraft:overworld/continents":[0,1]}]}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a spawn range of three numbers" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":[{"minecraft:overworld/continents":[0,1,2],"minecraft:overworld/erosion":[0,1],"minecraft:overworld/temperature":[0,1],"minecraft:overworld/vegetation":[0,1],"minecraft:overworld/ridges":[0,1]}]}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a spawn range of texts" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":[{"minecraft:overworld/continents":["a","b"],"minecraft:overworld/erosion":[0,1],"minecraft:overworld/temperature":[0,1],"minecraft:overworld/vegetation":[0,1],"minecraft:overworld/ridges":[0,1]}]}' TO WS-BODY
     PERFORM SETTINGS-FAILS
     MOVE "settings with a spawn target that is not a list" TO WS-T
     MOVE '{"sea_level":1,"noise":{"min_y":0,"height":128},"default_block":{"id"  :"a:b"},"default_fluid":{"id"  :"a:b"},"material_rule":"a:b","noise_router":{"temperature":0,"vegetation":0,"continents":0,"erosion":0,"depth":0,"ridges":0,"chunk_surface_level":0,"final_density":0},"spawn_target":3}' TO WS-BODY
     PERFORM SETTINGS-FAILS

*>   Surface rule failures (10 10.4, 10.5, 23 7.3.1).
     MOVE "material_rule" TO WS-DIR-NAME
     MOVE "a rule of an unknown type" TO WS-T
     MOVE '{"type":"minecraft:bogus"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a rule that is a number" TO WS-T
     MOVE '3' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a rule with a sequence that is no list" TO WS-T
     MOVE '{"type":"minecraft:sequence","sequence":1}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a rule with a sequence element that is a number" TO WS-T
     MOVE '{"type":"minecraft:sequence","sequence":[1]}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a condition rule without if_true" TO WS-T
     MOVE '{"type":"minecraft:condition","then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a block rule without a result_state" TO WS-T
     MOVE '{"type":"minecraft:block"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a condition of an unknown type" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:bogus"},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a stone_depth with surface_type up" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:stone_depth","surface_type":"up","offset":0,"add_surface_depth":false,"secondary_depth_range":0},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a stone_depth with add_surface_depth 1" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:stone_depth","surface_type":"floor","offset":0,"add_surface_depth":1,"secondary_depth_range":0},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a y_above anchor with two keys" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:y_above","anchor":{"absolute":1,"below_top":2},"surface_depth_multiplier":0,"add_stone_depth":false},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a y_above anchor with no key" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:y_above","anchor":{},"surface_depth_multiplier":0,"add_stone_depth":false},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a y_above anchor of 2032" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:y_above","anchor":{"absolute":2032},"surface_depth_multiplier":0,"add_stone_depth":false},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a y_above anchor that is text" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:y_above","anchor":"x","surface_depth_multiplier":0,"add_stone_depth":false},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a y_above anchor value that is text" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:y_above","anchor":{"absolute":"x"},"surface_depth_multiplier":0,"add_stone_depth":false},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a biome_is that is a number" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:biome","biome_is":3},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a biome_is list with a number" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"minecraft:biome","biome_is":["a:b",3]},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a condition that is true" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":true,"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL
     MOVE "a condition of a namespace other than minecraft" TO WS-T
     MOVE '{"type":"minecraft:condition","if_true":{"type":"mod:hole"},"then_run":"a:b"}' TO WS-BODY
     PERFORM RULES-FAIL

*>   Carver failures.
     MOVE "carver" TO WS-DIR-NAME
     MOVE "a carver of an unknown type" TO WS-T
     MOVE '{"type":"minecraft:bogus","probability":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a cave without probability" TO WS-T
     MOVE '{"type":"minecraft:canyon","y":1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a canyon without y" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a canyon without a shape" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":{"absolute":1},"vertical_rotation":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a height provider with no anchor" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":{},"vertical_rotation":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a height provider of an unknown type" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":{"type":"minecraft:bogus"},"vertical_rotation":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a height provider that is a number" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":5,"vertical_rotation":0.1}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a float provider without its fields" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":{"absolute":1},"vertical_rotation":{"type":"minecraft:uniform"}}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "a float provider that is text" TO WS-T
     MOVE '{"type":"minecraft:canyon","probability":0.1,"y":{"absolute":1},"vertical_rotation":"x"}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "an int provider that is text" TO WS-T
     MOVE '{"type":"minecraft:cave","probability":0.1,"y":{"absolute":1},"count":"x"}' TO WS-BODY
     PERFORM CARVER-FAILS
     MOVE "an int provider of a float type" TO WS-T
     MOVE '{"type":"minecraft:cave","probability":0.1,"y":{"absolute":1},"count":{"type":"minecraft:clamped_normal"}}' TO WS-BODY
     PERFORM CARVER-FAILS

*>   Ore feature failures.
     MOVE "feature" TO WS-DIR-NAME
     MOVE "an ore feature without size" TO WS-T
     MOVE '{"type":"minecraft:ore"}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore feature without targets" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore feature with targets that is no list" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":3}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore target that is no object" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[3]}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore target without a state" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[{"target":{"predicate_type":"minecraft:tag_match","tag":"a:b"}}]}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore rule test of an unknown type" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[{"state":{"id"  :"a:b"},"target":{"predicate_type":"minecraft:bogus"}}]}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore rule test without a predicate_type" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[{"state":{"id"  :"a:b"},"target":{"tag":"a:b"}}]}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an all_of whose rules are no list" TO WS-T
     MOVE '{"type":"minecraft:ore","size":3,"discard_chance_on_air_exposure":0.0,"targets":[{"state":{"id"  :"a:b"},"target":{"predicate_type":"minecraft:all_of","rules":1}}]}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore feature without a type" TO WS-T
     MOVE '{"size":3}' TO WS-BODY
     PERFORM ORE-FAILS
     MOVE "an ore feature file that is no object" TO WS-T
     MOVE '[]' TO WS-BODY
     PERFORM ORE-FAILS
     STOP RUN.

 FRESH-TREE.
     MOVE "build/content-test/worldgen/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/worldgen 2>/dev/null; rm -rf build/content-test/worldgen; mkdir -p build/content-test/worldgen && cp -R content/tests/fixtures/worldgen build/content-test/worldgen/t".

*> A bad file of the registry WS-DIR-NAME is written into a fresh tree (a condition file is the bad one for the rule
*> cases: it is named in the rule and the registry material_condition holds it).
 WRITE-BAD.
     PERFORM FRESH-TREE
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/worldgen/t/data/minecraft/worldgen/"
         FUNCTION TRIM(WS-DIR-NAME) "/bad.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND.

 SETTINGS-FAILS.
     PERFORM WRITE-BAD
     CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 RULES-FAIL.
     PERFORM WRITE-BAD
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 CARVER-FAILS.
     PERFORM WRITE-BAD
     CALL "CARVERS-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 ORE-FAILS.
     PERFORM WRITE-BAD
     CALL "ORE-FEATURES-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 FAILED-LOAD.
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "worldgen: after " FUNCTION TRIM(WS-T) " nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "worldgen: after " FUNCTION TRIM(WS-T) " no node stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE WG-COUNT(WGK-NODE) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE".

 FIND-NODE.
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     IF WS-NODE = 0
         MOVE 1 TO WS-NODE
     END-IF.

 ASSERT-ORDER.
     MOVE WGF-KEY(WS-N) TO WS-GOT-T
     MOVE WS-N TO WS-N-TEXT
     MOVE SPACES TO TL-CASE
     STRING "worldgen: listing position " WS-N-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-TYPE.
     CALL "WG-TYPE-AT" USING WGN-TYPE(WS-NODE) WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE WS-TYPE-NAME TO WS-GOT-T
     MOVE "type" TO WS-LABEL
     PERFORM EXPECT-T.

 EXPECT-N.
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-N TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 EXPECT-T.
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-BITS.
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-GOT-F WS-BITS
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-BITS TO TL-EXPECTED-N
     MOVE WS-BITS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
