*> Test of the loader of docs/protocol/35-worldgen-features-2-predicates-and-providers.md (worldgen features, part 2: block predicates and block state providers). LOAD-35-2 USING root (PIC X(1100)), status out: the fixture tree
*> content/tests/fixtures/load-35-2 loads (CT-OK, 26 elements, each of its type row); each reject case writes one bad file
*> into a fresh copy of the tree and expects CT-BAD-DATA with nothing kept (23 section 3.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-2.
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
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:simple".
    05 FILLER PIC X(48) VALUE "simple".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:cave_vines_head".
    05 FILLER PIC X(48) VALUE "weighted".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:random".
    05 FILLER PIC X(48) VALUE "random_block".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:tagged".
    05 FILLER PIC X(48) VALUE "random_block".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:rotated".
    05 FILLER PIC X(48) VALUE "rotated".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:copy".
    05 FILLER PIC X(48) VALUE "copy_properties".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:randomized".
    05 FILLER PIC X(48) VALUE "randomized_int".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:soil_beneath_tree".
    05 FILLER PIC X(48) VALUE "rule_based".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:noise".
    05 FILLER PIC X(48) VALUE "noise".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:dual".
    05 FILLER PIC X(48) VALUE "dual_noise".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(112) VALUE "minecraft:threshold".
    05 FILLER PIC X(48) VALUE "noise_threshold".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_matching".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_blocks_list".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_tag".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_fluids".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_biomes".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_sturdy".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_solid".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_replaceable".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_survive".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_inside".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_any".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_all".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_not".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_height".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(112) VALUE "minecraft:p_volume".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ELEMENT-TABLE REDEFINES WS-ELEMENTS.
    05 WS-E OCCURS 26 TIMES.
       10 WS-E-REGISTRY      PIC X(48).
       10 WS-E-KEY           PIC X(112).
       10 WS-E-TYPE          PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a provider without a type".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"state":{"id"  :"minecraft:stone"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an unknown provider type when strict".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:bogus"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a provider that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '"minecraft:stone"'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a simple provider without a state".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:simple"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a weighted provider without entries".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:weighted"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a weighted entry with a negative weight".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:weighted","entries":[{"data":"minecraft:a'.
    05 FILLER PIC X(60) VALUE '","weight":-2}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a weighted entry without data".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:weighted","entries":[{"weight":2}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "random_block blocks of a number".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:random_block","blocks":4}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a rotated direction that is not one".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:rotated","state":"minecraft:a","direction'.
    05 FILLER PIC X(60) VALUE '":"sideways"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a rotated provider without state".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:rotated"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a copy_properties without source".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:copy_properties"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "randomized_int without values".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:randomized_int","source":"minecraft:a","p'.
    05 FILLER PIC X(60) VALUE 'roperty":"age"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "randomized_int property that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:randomized_int","source":"minecraft:a","p'.
    05 FILLER PIC X(60) VALUE 'roperty":3,"values":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "rule_based without rules".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:rule_based"}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a rule without then".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:rule_based","rules":[{"if_true":{"type":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:true"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a rule with a bad predicate".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:rule_based","rules":[{"if_true":{"type":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:solid","offset":5},"then":"minecraft:a"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise scale 0".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":0}'.
    05 FILLER PIC X(60) VALUE ',"scale":0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise scale negative".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":0}'.
    05 FILLER PIC X(60) VALUE ',"scale":-1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise seed that is fractional".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1.5,"noise":{"base_octave":'.
    05 FILLER PIC X(60) VALUE '0},"scale":1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise without states".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":0}'.
    05 FILLER PIC X(60) VALUE ',"scale":1.0}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise parameters without base_octave".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{},"scale":1.0,"s'.
    05 FILLER PIC X(60) VALUE 'tates":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise base_octave 33".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":33'.
    05 FILLER PIC X(60) VALUE '},"scale":1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise octave_count 0".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":0,'.
    05 FILLER PIC X(60) VALUE '"octave_count":0},"scale":1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise base_amplitude above 1000000".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise","seed":1,"noise":{"base_octave":0,'.
    05 FILLER PIC X(60) VALUE '"base_amplitude":2000000.0},"scale":1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "dual_noise without slow_noise".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:dual_noise","variety":1,"slow_scale":1.0,'.
    05 FILLER PIC X(60) VALUE '"seed":1,"noise":{"base_octave":0},"scale":1.0,"states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise_threshold threshold 2".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise_threshold","seed":1,"noise":{"base_'.
    05 FILLER PIC X(60) VALUE 'octave":0},"scale":1.0,"threshold":2,"high_chance":0.5,"defa'.
    05 FILLER PIC X(60) VALUE 'ult_state":"minecraft:a","low_states":[],"high_states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise_threshold high_chance 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise_threshold","seed":1,"noise":{"base_'.
    05 FILLER PIC X(60) VALUE 'octave":0},"scale":1.0,"threshold":0,"high_chance":1.5,"defa'.
    05 FILLER PIC X(60) VALUE 'ult_state":"minecraft:a","low_states":[],"high_states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "noise_threshold without low_states".
    05 FILLER PIC X(48) VALUE "worldgen/block_state_provider".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:noise_threshold","seed":1,"noise":{"base_'.
    05 FILLER PIC X(60) VALUE 'octave":0},"scale":1.0,"threshold":0,"high_chance":0.5,"defa'.
    05 FILLER PIC X(60) VALUE 'ult_state":"minecraft:a","high_states":[]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_blocks without blocks".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_blocks"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_blocks with a bad id".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_blocks","blocks":"Bad Id"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_block_tag with a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_block_tag","tag":5}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_block_tag with a hash tag".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_block_tag","tag":"#minecraft:air"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_fluids without fluids".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_fluids"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "matching_biomes without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:matchi'.
    05 FILLER PIC X(60) VALUE 'ng_biomes"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "has_sturdy_face without direction".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:has_st'.
    05 FILLER PIC X(60) VALUE 'urdy_face"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "has_sturdy_face with a bad direction".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:has_st'.
    05 FILLER PIC X(60) VALUE 'urdy_face","direction":"left"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an offset that is not a list".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:solid"'.
    05 FILLER PIC X(60) VALUE ',"offset":5}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "would_survive without state".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:would_'.
    05 FILLER PIC X(60) VALUE 'survive"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "any_of without predicates".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:any_of'.
    05 FILLER PIC X(60) VALUE '"}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an all_of child that is bad".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:all_of'.
    05 FILLER PIC X(60) VALUE '","predicates":[{"type":"minecraft:not"}]}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "not without predicate".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:not"}}'.
    05 FILLER PIC X(60) VALUE ']}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a predicate that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":"minecraft:solid"}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a predicate without type".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"offset":[0,0,0]}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "height_range without max_inclusive".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:height'.
    05 FILLER PIC X(60) VALUE '_range","min_inclusive":{"absolute":0}}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "volume_match without match".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:volume'.
    05 FILLER PIC X(60) VALUE '_match","min":[0,0,0],"max":[1,1,1]}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "volume_match min that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature".
    05 FILLER PIC X(60) VALUE '{"feature":"minecraft:oak","placement":[{"type":"minecraft:b'.
    05 FILLER PIC X(60) VALUE 'lock_predicate_filter","predicate":{"type":"minecraft:volume'.
    05 FILLER PIC X(60) VALUE '_match","min":0,"max":[1,1,1],"match":{"type":"minecraft:tru'.
    05 FILLER PIC X(60) VALUE 'e"}}}]}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 46 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-DIR      PIC X(48).
       10 WS-CASE-BODY     PIC X(540).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-2" TO WS-DIR
     CALL "LOAD-35-2" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-2 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-2 every file is an element" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 26
         CALL "SHAPE-FIND" USING WS-E-REGISTRY(WS-I) WS-E-KEY(WS-I) WS-ROW
         PERFORM ASSERT-ELEMENT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 46
         MOVE WS-CASE-LABEL(WS-I) TO WS-LABEL
         MOVE WS-CASE-DIR(WS-I) TO WS-DIRNAME
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 ASSERT-ELEMENT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-2 " FUNCTION TRIM(WS-E-KEY(WS-I)) " in " FUNCTION TRIM(WS-E-REGISTRY(WS-I)) " is a " FUNCTION TRIM(WS-E-TYPE(WS-I))
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
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-35-2 2>/dev/null; rm -rf build/content-test/load-35-2; mkdir -p build/content-test/load-35-2 && cp -R content/tests/fixtures/load-35-2 build/content-test/load-35-2/t"
     MOVE "build/content-test/load-35-2/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-35-2/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) " && printf '%s' '"
         FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-2/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-2" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-2 reject: " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-2 reject: " FUNCTION TRIM(WS-LABEL) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
