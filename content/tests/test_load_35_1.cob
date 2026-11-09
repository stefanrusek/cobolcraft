*> Test of the loader of docs/protocol/35-worldgen-features-1-model-and-placement.md (worldgen features, part 1: the feature model, placement modifiers and the generic features). LOAD-35-1 USING root (PIC X(1100)), status out: the fixture tree
*> content/tests/fixtures/load-35-1 loads (CT-OK, 14 elements, each of its type row); each reject case writes one bad file
*> into a fresh copy of the tree and expects CT-BAD-DATA with nothing kept (23 section 3.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COMMAND             PIC X(900).
 01 WS-BODY                PIC X(500).
 01 WS-DIRNAME             PIC X(48).
 01 WS-LABEL               PIC X(60).
 01 WS-ELEMENTS.
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:trees_plains".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:flower_plain".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:glow_lichen".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:cave_vines".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_platform".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(64) VALUE "minecraft:empty".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:nothing".
    05 FILLER PIC X(48) VALUE "no_op".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:trees_plains".
    05 FILLER PIC X(48) VALUE "random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:simple_sel".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:tag_sel".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:boolean".
    05 FILLER PIC X(48) VALUE "random_boolean_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:weighted".
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:sequence".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:other_part".
    05 FILLER PIC X(48) VALUE "unregistered".
 01 WS-ELEMENT-TABLE REDEFINES WS-ELEMENTS.
    05 WS-E OCCURS 14 TIMES.
       10 WS-E-REGISTRY      PIC X(48).
       10 WS-E-KEY           PIC X(64).
       10 WS-E-TYPE          PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a placed feature without a feature".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"placement":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a placed feature without placement".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a placed feature that is no object".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '[]'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a feature of a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":1,"placement":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an invalid feature id".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"Bad Id","placement":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "placement that is no list".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":{}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a modifier without a type".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"count":1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a count modifier without count".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:c'.
    05 FILLER PIC X(60) VALUE 'ount"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a count that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:c'.
    05 FILLER PIC X(60) VALUE 'ount","count":"3"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "rarity_filter chance 0".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:r'.
    05 FILLER PIC X(60) VALUE 'arity_filter","chance":0}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "rarity_filter chance 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:r'.
    05 FILLER PIC X(60) VALUE 'arity_filter","chance":1.5}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "random_chance above 1".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:r'.
    05 FILLER PIC X(60) VALUE 'andom_chance","chance":1.5}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a missing max_water_depth".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:s'.
    05 FILLER PIC X(60) VALUE 'urface_water_depth_filter"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a heightmap that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:h'.
    05 FILLER PIC X(60) VALUE 'eightmap","heightmap":3}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "max_steps 0".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:e'.
    05 FILLER PIC X(60) VALUE 'nvironment_scan","direction_of_search":"up","target_conditio'.
    05 FILLER PIC X(60) VALUE 'n":{"type":"minecraft:solid"},"max_steps":0}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "max_steps 33".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:e'.
    05 FILLER PIC X(60) VALUE 'nvironment_scan","direction_of_search":"up","target_conditio'.
    05 FILLER PIC X(60) VALUE 'n":{"type":"minecraft:solid"},"max_steps":33}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a sideways search direction".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:e'.
    05 FILLER PIC X(60) VALUE 'nvironment_scan","direction_of_search":"north","target_condi'.
    05 FILLER PIC X(60) VALUE 'tion":{"type":"minecraft:solid"},"max_steps":2}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an environment_scan without a target".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:e'.
    05 FILLER PIC X(60) VALUE 'nvironment_scan","direction_of_search":"up","max_steps":2}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an offset without z".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:o'.
    05 FILLER PIC X(60) VALUE 'ffset","x":0,"y":0}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a cuboid without sizes".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:c'.
    05 FILLER PIC X(60) VALUE 'uboid","xz_size":3}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a cuboid edge flag that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:c'.
    05 FILLER PIC X(60) VALUE 'uboid","xz_size":3,"y_size":3,"include_edges":0}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise_threshold_count without above_noise".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:n'.
    05 FILLER PIC X(60) VALUE 'oise_threshold_count","noise_level":0.1,"below_noise":1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise_based_count with a fractional ratio".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:n'.
    05 FILLER PIC X(60) VALUE 'oise_based_count","noise_to_count_ratio":1.5,"noise_factor":'.
    05 FILLER PIC X(60) VALUE '2.0}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "fixed_placement without positions".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:f'.
    05 FILLER PIC X(60) VALUE 'ixed_placement"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "randomly_selected whose list is bad".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:r'.
    05 FILLER PIC X(60) VALUE 'andomly_selected","placements":[{"type":"minecraft:count"}]}'.
    05 FILLER PIC X(60) VALUE ']}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a block_predicate_filter without a predicate".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a feature without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"features":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a random_selector without default".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_selector","features":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a selector entry chance 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_selector","features":[{"feature":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:a","chance":2}],"default":"minecraft:b"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a selector entry without chance".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_selector","features":[{"feature":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:a"}],"default":"minecraft:b"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a simple_random_selector of a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:simple_random_selector","features":3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a holder set with a bad tag".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:simple_random_selector","features":"#Bad '.
    05 FILLER PIC X(60) VALUE 'Tag"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a random_boolean_selector without feature_false".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_boolean_selector","feature_true":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:a"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a weighted entry with a negative weight".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:weighted_random_selector","features":[{"d'.
    05 FILLER PIC X(60) VALUE 'ata":"minecraft:a","weight":-1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a weighted entry without data".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:weighted_random_selector","features":[{"w'.
    05 FILLER PIC X(60) VALUE 'eight":1}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a sequence without features".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:sequence"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 36 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-DIR      PIC X(48).
       10 WS-CASE-BODY     PIC X(540).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-1" TO WS-DIR
     CALL "LOAD-35-1" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-1 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-1 every file is an element" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         CALL "SHAPE-FIND" USING WS-E-REGISTRY(WS-I) WS-E-KEY(WS-I) WS-ROW
         PERFORM ASSERT-ELEMENT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-CASE-LABEL(WS-I) TO WS-LABEL
         MOVE WS-CASE-DIR(WS-I) TO WS-DIRNAME
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 ASSERT-ELEMENT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-1 " FUNCTION TRIM(WS-E-KEY(WS-I)) " in " FUNCTION TRIM(WS-E-REGISTRY(WS-I)) " is a " FUNCTION TRIM(WS-E-TYPE(WS-I))
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-E-TYPE(WS-I) TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         ELSE
             MOVE "unregistered" TO TL-OBSERVED
         END-IF
     ELSE
         MOVE "not found" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     CALL "SHAPE-FREE"
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-35-1 2>/dev/null; rm -rf build/content-test/load-35-1; mkdir -p build/content-test/load-35-1 && cp -R content/tests/fixtures/load-35-1 build/content-test/load-35-1/t"
     MOVE "build/content-test/load-35-1/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-35-1/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) " && printf '%s' '"
         FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-1/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-1" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-1 reject: " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-1 reject: " FUNCTION TRIM(WS-LABEL) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
