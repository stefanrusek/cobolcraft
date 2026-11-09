*> Test of the loader of docs/protocol/35-worldgen-features-3-tree-placers.md (worldgen features, part 3: the tree feature, feature sizes, trunk, foliage and root placers, fallen trees). LOAD-35-3 USING root (PIC X(1100)), status out: the fixture tree
*> content/tests/fixtures/load-35-3 loads (CT-OK, 23 elements, each of its type row); each reject case writes one bad file
*> into a fresh copy of the tree and expects CT-BAD-DATA with nothing kept (23 section 3.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COMMAND             PIC X(1200).
 01 WS-BODY                PIC X(720).
 01 WS-DIRNAME             PIC X(48).
 01 WS-LABEL               PIC X(60).
 01 WS-ELEMENTS.
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:oak".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:oak_decorated".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:forking".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:giant".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:mega_jungle".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:dark_oak".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:fancy".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:bending".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:mangrove".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:cherry".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:poplar".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:blob".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:bush".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:spruce".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:pine".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:acacia".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:jungle".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:mega_pine".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:random_spread".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:three_layers".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:fallen".
    05 FILLER PIC X(48) VALUE "fallen_tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:fallen_min".
    05 FILLER PIC X(48) VALUE "fallen_tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:other_part".
    05 FILLER PIC X(48) VALUE "unregistered".
 01 WS-ELEMENT-TABLE REDEFINES WS-ELEMENTS.
    05 WS-E OCCURS 23 TIMES.
       10 WS-E-REGISTRY      PIC X(48).
       10 WS-E-KEY           PIC X(64).
       10 WS-E-TYPE          PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a tree without trunk_provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_placer":{"type":"minecraft:s'.
    05 FILLER PIC X(60) VALUE 'traight_trunk_placer","base_height":4,"height_rand_a":2,"hei'.
    05 FILLER PIC X(60) VALUE 'ght_rand_b":0},"foliage_provider":{"Name":"minecraft:oak_lea'.
    05 FILLER PIC X(60) VALUE 'ves"},"foliage_placer":{"type":"minecraft:blob_foliage_place'.
    05 FILLER PIC X(60) VALUE 'r","radius":2,"offset":0,"height":3},"minimum_size":{"type":'.
    05 FILLER PIC X(60) VALUE '"minecraft:two_layers_feature_size","limit":1,"lower_size":0'.
    05 FILLER PIC X(60) VALUE ',"upper_size":1},"below_trunk_provider":{"Name":"minecraft:d'.
    05 FILLER PIC X(60) VALUE 'irt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a tree without trunk_placer".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"a"},"foli'.
    05 FILLER PIC X(60) VALUE 'age_provider":{"Name":"b"},"foliage_placer":{"type":"minecra'.
    05 FILLER PIC X(60) VALUE 'ft:blob_foliage_placer","radius":2,"offset":0,"height":3},"m'.
    05 FILLER PIC X(60) VALUE 'inimum_size":{"type":"minecraft:two_layers_feature_size"},"b'.
    05 FILLER PIC X(60) VALUE 'elow_trunk_provider":{"Name":"c"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a tree without below_trunk_provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":1,"lower_size":0,"upper_size":'.
    05 FILLER PIC X(60) VALUE '1}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a tree without minimum_size".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"a"},"trun'.
    05 FILLER PIC X(60) VALUE 'k_placer":{"type":"minecraft:straight_trunk_placer","base_he'.
    05 FILLER PIC X(60) VALUE 'ight":4,"height_rand_a":2,"height_rand_b":0},"foliage_provid'.
    05 FILLER PIC X(60) VALUE 'er":{"Name":"b"},"foliage_placer":{"type":"minecraft:blob_fo'.
    05 FILLER PIC X(60) VALUE 'liage_placer","radius":2,"offset":0,"height":3},"below_trunk'.
    05 FILLER PIC X(60) VALUE '_provider":{"Name":"c"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "ignore_vines that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":1,"lower_size":0,"upper_size":'.
    05 FILLER PIC X(60) VALUE '1},"below_trunk_provider":{"Name":"minecraft:dirt"},"ignore_'.
    05 FILLER PIC X(60) VALUE 'vines":1}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "decorators that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":1,"lower_size":0,"upper_size":'.
    05 FILLER PIC X(60) VALUE '1},"below_trunk_provider":{"Name":"minecraft:dirt"},"decorat'.
    05 FILLER PIC X(60) VALUE 'ors":{}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a trunk placer without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"base_height":4,"height_rand_a":2'.
    05 FILLER PIC X(60) VALUE ',"height_rand_b":0},"foliage_provider":{"Name":"minecraft:oa'.
    05 FILLER PIC X(60) VALUE 'k_leaves"},"foliage_placer":{"type":"minecraft:blob_foliage_'.
    05 FILLER PIC X(60) VALUE 'placer","radius":2,"offset":0,"height":3},"minimum_size":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:two_layers_feature_size","limit":1,"lower_si'.
    05 FILLER PIC X(60) VALUE 'ze":0,"upper_size":1},"below_trunk_provider":{"Name":"minecr'.
    05 FILLER PIC X(60) VALUE 'aft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a trunk placer without base_height".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","height_rand_a":2,"height_rand_b":0},"foliage_provid'.
    05 FILLER PIC X(60) VALUE 'er":{"Name":"minecraft:oak_leaves"},"foliage_placer":{"type"'.
    05 FILLER PIC X(60) VALUE ':"minecraft:blob_foliage_placer","radius":2,"offset":0,"heig'.
    05 FILLER PIC X(60) VALUE 'ht":3},"minimum_size":{"type":"minecraft:two_layers_feature_'.
    05 FILLER PIC X(60) VALUE 'size","limit":1,"lower_size":0,"upper_size":1},"below_trunk_'.
    05 FILLER PIC X(60) VALUE 'provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "base_height 33".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":33,"height_rand_a":2,"height_rand_b":1'.
    05 FILLER PIC X(60) VALUE '},"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliag'.
    05 FILLER PIC X(60) VALUE 'e_placer":{"type":"minecraft:blob_foliage_placer","radius":2'.
    05 FILLER PIC X(60) VALUE ',"offset":0,"height":3},"minimum_size":{"type":"minecraft:tw'.
    05 FILLER PIC X(60) VALUE 'o_layers_feature_size","limit":1,"lower_size":0,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "height_rand_a 25".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":5,"height_rand_a":25,"height_rand_b":1'.
    05 FILLER PIC X(60) VALUE '},"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliag'.
    05 FILLER PIC X(60) VALUE 'e_placer":{"type":"minecraft:blob_foliage_placer","radius":2'.
    05 FILLER PIC X(60) VALUE ',"offset":0,"height":3},"minimum_size":{"type":"minecraft:tw'.
    05 FILLER PIC X(60) VALUE 'o_layers_feature_size","limit":1,"lower_size":0,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "height_rand_b negative".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":5,"height_rand_a":2,"height_rand_b":-1'.
    05 FILLER PIC X(60) VALUE '},"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliag'.
    05 FILLER PIC X(60) VALUE 'e_placer":{"type":"minecraft:blob_foliage_placer","radius":2'.
    05 FILLER PIC X(60) VALUE ',"offset":0,"height":3},"minimum_size":{"type":"minecraft:tw'.
    05 FILLER PIC X(60) VALUE 'o_layers_feature_size","limit":1,"lower_size":0,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "base_height fractional".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4.5,"height_rand_a":2,"height_rand_b":'.
    05 FILLER PIC X(60) VALUE '1},"foliage_provider":{"Name":"minecraft:oak_leaves"},"folia'.
    05 FILLER PIC X(60) VALUE 'ge_placer":{"type":"minecraft:blob_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":0,"height":3},"minimum_size":{"type":"minecraft:t'.
    05 FILLER PIC X(60) VALUE 'wo_layers_feature_size","limit":1,"lower_size":0,"upper_size'.
    05 FILLER PIC X(60) VALUE '":1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "bending without bend_length".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:bending_trunk_p'.
    05 FILLER PIC X(60) VALUE 'lacer","base_height":5,"height_rand_a":2,"height_rand_b":1},'.
    05 FILLER PIC X(60) VALUE '"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage_'.
    05 FILLER PIC X(60) VALUE 'placer":{"type":"minecraft:blob_foliage_placer","radius":2,"'.
    05 FILLER PIC X(60) VALUE 'offset":0,"height":3},"minimum_size":{"type":"minecraft:two_'.
    05 FILLER PIC X(60) VALUE 'layers_feature_size","limit":1,"lower_size":0,"upper_size":1'.
    05 FILLER PIC X(60) VALUE '},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "bending min_height_for_leaves 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:bending_trunk_p'.
    05 FILLER PIC X(60) VALUE 'lacer","base_height":5,"height_rand_a":2,"height_rand_b":1,"'.
    05 FILLER PIC X(60) VALUE 'min_height_for_leaves":0,"bend_length":2},"foliage_provider"'.
    05 FILLER PIC X(60) VALUE ':{"Name":"minecraft:oak_leaves"},"foliage_placer":{"type":"m'.
    05 FILLER PIC X(60) VALUE 'inecraft:blob_foliage_placer","radius":2,"offset":0,"height"'.
    05 FILLER PIC X(60) VALUE ':3},"minimum_size":{"type":"minecraft:two_layers_feature_siz'.
    05 FILLER PIC X(60) VALUE 'e","limit":1,"lower_size":0,"upper_size":1},"below_trunk_pro'.
    05 FILLER PIC X(60) VALUE 'vider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "upwards_branching probability 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:upwards_branchi'.
    05 FILLER PIC X(60) VALUE 'ng_trunk_placer","base_height":5,"height_rand_a":2,"height_r'.
    05 FILLER PIC X(60) VALUE 'and_b":1,"extra_branch_steps":1,"place_branch_per_log_probab'.
    05 FILLER PIC X(60) VALUE 'ility":2,"extra_branch_length":1,"can_grow_through":"minecra'.
    05 FILLER PIC X(60) VALUE 'ft:mud"},"foliage_provider":{"Name":"minecraft:oak_leaves"},'.
    05 FILLER PIC X(60) VALUE '"foliage_placer":{"type":"minecraft:blob_foliage_placer","ra'.
    05 FILLER PIC X(60) VALUE 'dius":2,"offset":0,"height":3},"minimum_size":{"type":"minec'.
    05 FILLER PIC X(60) VALUE 'raft:two_layers_feature_size","limit":1,"lower_size":0,"uppe'.
    05 FILLER PIC X(60) VALUE 'r_size":1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "upwards_branching without can_grow_through".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:upwards_branchi'.
    05 FILLER PIC X(60) VALUE 'ng_trunk_placer","base_height":5,"height_rand_a":2,"height_r'.
    05 FILLER PIC X(60) VALUE 'and_b":1,"extra_branch_steps":1,"place_branch_per_log_probab'.
    05 FILLER PIC X(60) VALUE 'ility":0.5,"extra_branch_length":1},"foliage_provider":{"Nam'.
    05 FILLER PIC X(60) VALUE 'e":"minecraft:oak_leaves"},"foliage_placer":{"type":"minecra'.
    05 FILLER PIC X(60) VALUE 'ft:blob_foliage_placer","radius":2,"offset":0,"height":3},"m'.
    05 FILLER PIC X(60) VALUE 'inimum_size":{"type":"minecraft:two_layers_feature_size","li'.
    05 FILLER PIC X(60) VALUE 'mit":1,"lower_size":0,"upper_size":1},"below_trunk_provider"'.
    05 FILLER PIC X(60) VALUE ':{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "upwards_branching can_grow_through bad id".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:upwards_branchi'.
    05 FILLER PIC X(60) VALUE 'ng_trunk_placer","base_height":5,"height_rand_a":2,"height_r'.
    05 FILLER PIC X(60) VALUE 'and_b":1,"extra_branch_steps":1,"place_branch_per_log_probab'.
    05 FILLER PIC X(60) VALUE 'ility":0.5,"extra_branch_length":1,"can_grow_through":"Bad I'.
    05 FILLER PIC X(60) VALUE 'd"},"foliage_provider":{"Name":"minecraft:oak_leaves"},"foli'.
    05 FILLER PIC X(60) VALUE 'age_placer":{"type":"minecraft:blob_foliage_placer","radius"'.
    05 FILLER PIC X(60) VALUE ':2,"offset":0,"height":3},"minimum_size":{"type":"minecraft:'.
    05 FILLER PIC X(60) VALUE 'two_layers_feature_size","limit":1,"lower_size":0,"upper_siz'.
    05 FILLER PIC X(60) VALUE 'e":1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "cherry trunk without branch_count".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:cherry_trunk_pl'.
    05 FILLER PIC X(60) VALUE 'acer","base_height":5,"height_rand_a":2,"height_rand_b":1,"b'.
    05 FILLER PIC X(60) VALUE 'ranch_horizontal_length":2,"branch_start_offset_from_top":-3'.
    05 FILLER PIC X(60) VALUE ',"branch_end_offset_from_top":-1},"foliage_provider":{"Name"'.
    05 FILLER PIC X(60) VALUE ':"minecraft:oak_leaves"},"foliage_placer":{"type":"minecraft'.
    05 FILLER PIC X(60) VALUE ':blob_foliage_placer","radius":2,"offset":0,"height":3},"min'.
    05 FILLER PIC X(60) VALUE 'imum_size":{"type":"minecraft:two_layers_feature_size","limi'.
    05 FILLER PIC X(60) VALUE 't":1,"lower_size":0,"upper_size":1},"below_trunk_provider":{'.
    05 FILLER PIC X(60) VALUE '"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "poplar trunk without branch_amount".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:poplar_trunk_pl'.
    05 FILLER PIC X(60) VALUE 'acer","base_height":5,"height_rand_a":2,"height_rand_b":1,"t'.
    05 FILLER PIC X(60) VALUE 'runk_height_above_branches":1},"foliage_provider":{"Name":"m'.
    05 FILLER PIC X(60) VALUE 'inecraft:oak_leaves"},"foliage_placer":{"type":"minecraft:bl'.
    05 FILLER PIC X(60) VALUE 'ob_foliage_placer","radius":2,"offset":0,"height":3},"minimu'.
    05 FILLER PIC X(60) VALUE 'm_size":{"type":"minecraft:two_layers_feature_size","limit":'.
    05 FILLER PIC X(60) VALUE '1,"lower_size":0,"upper_size":1},"below_trunk_provider":{"Na'.
    05 FILLER PIC X(60) VALUE 'me":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a foliage placer without radius".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","offset":0,'.
    05 FILLER PIC X(60) VALUE '"height":3},"minimum_size":{"type":"minecraft:two_layers_fea'.
    05 FILLER PIC X(60) VALUE 'ture_size","limit":1,"lower_size":0,"upper_size":1},"below_t'.
    05 FILLER PIC X(60) VALUE 'runk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a foliage radius that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:acacia_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '"2"},"minimum_size":{"type":"minecraft:two_layers_feature_si'.
    05 FILLER PIC X(60) VALUE 'ze","limit":1,"lower_size":0,"upper_size":1},"below_trunk_pr'.
    05 FILLER PIC X(60) VALUE 'ovider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a blob without height".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":1},"minimum_size":{"type":"minecraft:two_layers_fea'.
    05 FILLER PIC X(60) VALUE 'ture_size","limit":1,"lower_size":0,"upper_size":1},"below_t'.
    05 FILLER PIC X(60) VALUE 'runk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a blob height 17".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":1,"height":17},"minimum_size":{"type":"minecraft:tw'.
    05 FILLER PIC X(60) VALUE 'o_layers_feature_size","limit":1,"lower_size":0,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a spruce without trunk_height".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:spruce_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size","limit":1,"lower_size":0,"upper_size":1},"below'.
    05 FILLER PIC X(60) VALUE '_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a random_spread attempts 257".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:random_spread_foliage_placer","r'.
    05 FILLER PIC X(60) VALUE 'adius":2,"offset":1,"foliage_height":2,"leaf_placement_attem'.
    05 FILLER PIC X(60) VALUE 'pts":257},"minimum_size":{"type":"minecraft:two_layers_featu'.
    05 FILLER PIC X(60) VALUE 're_size","limit":1,"lower_size":0,"upper_size":1},"below_tru'.
    05 FILLER PIC X(60) VALUE 'nk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a cherry height 3".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:cherry_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":1,"height":3,"wide_bottom_layer_hole_chance":0.1,'.
    05 FILLER PIC X(60) VALUE '"corner_hole_chance":0.1,"hanging_leaves_chance":0.1,"hangin'.
    05 FILLER PIC X(60) VALUE 'g_leaves_extension_chance":0.1},"minimum_size":{"type":"mine'.
    05 FILLER PIC X(60) VALUE 'craft:two_layers_feature_size","limit":1,"lower_size":0,"upp'.
    05 FILLER PIC X(60) VALUE 'er_size":1},"below_trunk_provider":{"Name":"minecraft:dirt"}'.
    05 FILLER PIC X(60) VALUE '}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a cherry chance 2".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:cherry_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":1,"height":5,"wide_bottom_layer_hole_chance":2,"c'.
    05 FILLER PIC X(60) VALUE 'orner_hole_chance":0.1,"hanging_leaves_chance":0.1,"hanging_'.
    05 FILLER PIC X(60) VALUE 'leaves_extension_chance":0.1},"minimum_size":{"type":"minecr'.
    05 FILLER PIC X(60) VALUE 'aft:two_layers_feature_size","limit":1,"lower_size":0,"upper'.
    05 FILLER PIC X(60) VALUE '_size":1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a poplar height 4".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:poplar_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":1,"height":4,"side_hole_chance":0.1},"minimum_siz'.
    05 FILLER PIC X(60) VALUE 'e":{"type":"minecraft:two_layers_feature_size","limit":1,"lo'.
    05 FILLER PIC X(60) VALUE 'wer_size":0,"upper_size":1},"below_trunk_provider":{"Name":"'.
    05 FILLER PIC X(60) VALUE 'minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a poplar without side_hole_chance".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:poplar_foliage_placer","radius":'.
    05 FILLER PIC X(60) VALUE '2,"offset":1,"height":6},"minimum_size":{"type":"minecraft:t'.
    05 FILLER PIC X(60) VALUE 'wo_layers_feature_size","limit":1,"lower_size":0,"upper_size'.
    05 FILLER PIC X(60) VALUE '":1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a feature size without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"limit":1,"lower_size'.
    05 FILLER PIC X(60) VALUE '":0,"upper_size":1},"below_trunk_provider":{"Name":"minecraf'.
    05 FILLER PIC X(60) VALUE 't:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a two_layers limit 82".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":82,"lower_size":0,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a two_layers lower_size 17".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":1,"lower_size":17,"upper_size"'.
    05 FILLER PIC X(60) VALUE ':1},"below_trunk_provider":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a three_layers upper_limit 81".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:thr'.
    05 FILLER PIC X(60) VALUE 'ee_layers_feature_size","upper_limit":81},"below_trunk_provi'.
    05 FILLER PIC X(60) VALUE 'der":{"Name":"minecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a min_clipped_height 81".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":{"Name":"minecraft'.
    05 FILLER PIC X(60) VALUE ':oak_log"},"trunk_placer":{"type":"minecraft:straight_trunk_'.
    05 FILLER PIC X(60) VALUE 'placer","base_height":4,"height_rand_a":2,"height_rand_b":0}'.
    05 FILLER PIC X(60) VALUE ',"foliage_provider":{"Name":"minecraft:oak_leaves"},"foliage'.
    05 FILLER PIC X(60) VALUE '_placer":{"type":"minecraft:blob_foliage_placer","radius":2,'.
    05 FILLER PIC X(60) VALUE '"offset":0,"height":3},"minimum_size":{"type":"minecraft:two'.
    05 FILLER PIC X(60) VALUE '_layers_feature_size","limit":1,"lower_size":0,"upper_size":'.
    05 FILLER PIC X(60) VALUE '1,"min_clipped_height":81},"below_trunk_provider":{"Name":"m'.
    05 FILLER PIC X(60) VALUE 'inecraft:dirt"}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a root placer without trunk_offset_y".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","root_placer":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:mangrove_root_placer","root_provider":{"Name'.
    05 FILLER PIC X(60) VALUE '":"a"},"mangrove_root_placement":{"can_grow_through":"a:b","'.
    05 FILLER PIC X(60) VALUE 'muddy_roots_in":"a:b","muddy_roots_provider":{"Name":"a"},"m'.
    05 FILLER PIC X(60) VALUE 'ax_root_width":8,"max_root_length":15,"random_skew_chance":0'.
    05 FILLER PIC X(60) VALUE '.2}}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a root placer without mangrove_root_placement".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","root_placer":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:mangrove_root_placer","trunk_offset_y":1,"ro'.
    05 FILLER PIC X(60) VALUE 'ot_provider":{"Name":"a"}}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a max_root_width 13".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","root_placer":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:mangrove_root_placer","trunk_offset_y":1,"ro'.
    05 FILLER PIC X(60) VALUE 'ot_provider":{"Name":"a"},"mangrove_root_placement":{"can_gr'.
    05 FILLER PIC X(60) VALUE 'ow_through":"a:b","muddy_roots_in":"a:b","muddy_roots_provid'.
    05 FILLER PIC X(60) VALUE 'er":{"Name":"a"},"max_root_width":13,"max_root_length":15,"r'.
    05 FILLER PIC X(60) VALUE 'andom_skew_chance":0.2}}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a max_root_length 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","root_placer":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:mangrove_root_placer","trunk_offset_y":1,"ro'.
    05 FILLER PIC X(60) VALUE 'ot_provider":{"Name":"a"},"mangrove_root_placement":{"can_gr'.
    05 FILLER PIC X(60) VALUE 'ow_through":"a:b","muddy_roots_in":"a:b","muddy_roots_provid'.
    05 FILLER PIC X(60) VALUE 'er":{"Name":"a"},"max_root_width":8,"max_root_length":0,"ran'.
    05 FILLER PIC X(60) VALUE 'dom_skew_chance":0.2}}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "an above_root chance 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:tree","trunk_provider":"a:a","trunk_place'.
    05 FILLER PIC X(60) VALUE 'r":{"type":"minecraft:straight_trunk_placer","base_height":1'.
    05 FILLER PIC X(60) VALUE ',"height_rand_a":0,"height_rand_b":0},"foliage_provider":"a:'.
    05 FILLER PIC X(60) VALUE 'b","foliage_placer":{"type":"minecraft:acacia_foliage_placer'.
    05 FILLER PIC X(60) VALUE '","radius":1},"minimum_size":{"type":"minecraft:two_layers_f'.
    05 FILLER PIC X(60) VALUE 'eature_size"},"below_trunk_provider":"a:c","root_placer":{"t'.
    05 FILLER PIC X(60) VALUE 'ype":"minecraft:mangrove_root_placer","trunk_offset_y":1,"ro'.
    05 FILLER PIC X(60) VALUE 'ot_provider":{"Name":"a"},"above_root_placement":{"above_roo'.
    05 FILLER PIC X(60) VALUE 't_provider":{"Name":"a"},"above_root_placement_chance":1.5},'.
    05 FILLER PIC X(60) VALUE '"mangrove_root_placement":{"can_grow_through":"a:b","muddy_r'.
    05 FILLER PIC X(60) VALUE 'oots_in":"a:b","muddy_roots_provider":{"Name":"a"},"max_root'.
    05 FILLER PIC X(60) VALUE '_width":8,"max_root_length":15,"random_skew_chance":0.2}}}'.
    05 FILLER PIC X(60) VALUE "a fallen_tree without log_length".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:fallen_tree","trunk_provider":{"Name":"a"'.
    05 FILLER PIC X(60) VALUE '}}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "a fallen_tree without trunk_provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:fallen_tree","log_length":3}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE "fallen_tree stump_decorators that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(60) VALUE '{"type":"minecraft:fallen_tree","trunk_provider":{"Name":"a"'.
    05 FILLER PIC X(60) VALUE '},"log_length":3,"stump_decorators":2}'.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
    05 FILLER PIC X(60) VALUE SPACES.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 42 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-DIR      PIC X(48).
       10 WS-CASE-BODY     PIC X(720).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-3" TO WS-DIR
     CALL "LOAD-35-3" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-3 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-3 every file is an element" TO TL-CASE
     MOVE 23 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         CALL "SHAPE-FIND" USING WS-E-REGISTRY(WS-I) WS-E-KEY(WS-I) WS-ROW
         PERFORM ASSERT-ELEMENT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 42
         MOVE WS-CASE-LABEL(WS-I) TO WS-LABEL
         MOVE WS-CASE-DIR(WS-I) TO WS-DIRNAME
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 ASSERT-ELEMENT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-3 " FUNCTION TRIM(WS-E-KEY(WS-I)) " in " FUNCTION TRIM(WS-E-REGISTRY(WS-I)) " is a " FUNCTION TRIM(WS-E-TYPE(WS-I))
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
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-35-3 2>/dev/null; rm -rf build/content-test/load-35-3; mkdir -p build/content-test/load-35-3 && cp -R content/tests/fixtures/load-35-3 build/content-test/load-35-3/t"
     MOVE "build/content-test/load-35-3/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-35-3/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) " && printf '%s' '"
         FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-3/t/data/minecraft/" FUNCTION TRIM(WS-DIRNAME) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-3" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-3 reject: " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-3 reject: " FUNCTION TRIM(WS-LABEL) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
