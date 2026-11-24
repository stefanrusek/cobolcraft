*> Test of the loader LOAD-35-6 (docs/protocol/35-worldgen-features-6-underground.md). LOAD-35-6 USING root (PIC X(1100): the folder that holds data/),
*> status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load kept). Accept cases: the
*> fixture tree content/tests/fixtures/load-35-6 (12 files). Reject cases: one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-REG                 PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(2000).
 01 WS-BODY                PIC X(1500).
 01 WS-T                   PIC X(60).
 01 WS-I                   BINARY-LONG.
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-ACCEPT.
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:amethyst_geode".
    05 FILLER PIC X(48) VALUE "geode".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:pointed_dripstone_a".
    05 FILLER PIC X(48) VALUE "speleothem".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:dripstone_cluster".
    05 FILLER PIC X(48) VALUE "speleothem_cluster".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:sulfur_spike_cluster".
    05 FILLER PIC X(48) VALUE "speleothem_cluster".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:large_dripstone".
    05 FILLER PIC X(48) VALUE "large_dripstone".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:sculk_patch_deep_dark".
    05 FILLER PIC X(48) VALUE "sculk_patch".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:monster_room".
    05 FILLER PIC X(48) VALUE "monster_room".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:fossil_coal".
    05 FILLER PIC X(48) VALUE "fossil".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:fossil_diamonds".
    05 FILLER PIC X(48) VALUE "fossil".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:sulfur_spring_a".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:desert_well_part".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(112) VALUE "minecraft:sulfur_pool_seq".
    05 FILLER PIC X(48) VALUE SPACES.
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPT.
    05 WS-A OCCURS 12 TIMES.
       10 WS-A-REG     PIC X(48).
       10 WS-A-KEY     PIC X(112).
       10 WS-A-TYPE    PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a geode without blocks".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""layers"":{},""crack"":{""generate_crack_chance"":0.95},""in" &
        "valid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""min" &
        "_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode blocks without inner_placements".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""cannot_r" &
        "eplace"":""#minecraft:features_cannot_replace"",""invalid_blocks"":""#minecraft:geode_" &
        "invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance"":0.95},""invalid_blo" &
        "cks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""min_inclusiv" &
        "e"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode blocks without cannot_replace".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""invalid_blocks"":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack" &
        """:{""generate_crack_chance"":0.95},""invalid_blocks_threshold"":1,""outer_wall_distan" &
        "ce"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""use_altern" &
        "ate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode block provider that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":3,""inner_layer_provider"":" &
        "{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_provider"":{""id"":""minecr" &
        "aft:budding_amethyst""},""middle_layer_provider"":{""id"":""minecraft:calcite""},""outer" &
        "_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_placements"":[{""id""  :""m" &
        "inecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_cluster""}],""cannot_rep" &
        "lace"":""#minecraft:features_cannot_replace"",""invalid_blocks"":""#minecraft:geode_in" &
        "valid_blocks""},""layers"":{},""crack"":{""generate_crack_chance"":0.95},""invalid_block" &
        "s_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""min_inclusive""" &
        ":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode inner_placements that is no array".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":1,""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_block" &
        "s"":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chanc" &
        "e"":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:u" &
        "niform"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083" &
        "}".
    05 FILLER PIC X(60) VALUE "a geode inner_placements block state without Name".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_bl" &
        "ocks"":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_ch" &
        "ance"":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraf" &
        "t:uniform"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0." &
        "083}".
    05 FILLER PIC X(60) VALUE "a geode invalid_blocks that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":3},""layers"":{},""crack"":{""generate_crack_chance"":0.95},""invalid_blocks_threshold" &
        """:1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inc" &
        "lusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode without layers".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""crack"":{""generate_crack_chance"":0.95},""inva" &
        "lid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""min_i" &
        "nclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode layer filling above 50".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{""filling"":50.5},""crack"":{""generate" &
        "_crack_chance"":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":" &
        """minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_c" &
        "hance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode layer inner_layer below 0.01".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{""inner_layer"":0.001},""crack"":{""gen" &
        "erate_crack_chance"":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""t" &
        "ype"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_lay" &
        "er0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode without crack".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""invalid_blocks_threshold"":1,""ou" &
        "ter_wall_distance"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive""" &
        ":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode crack chance above 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":1.5},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:unif" &
        "orm"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode base_crack_size above 5".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""base_crack_size"":6},""i" &
        "nvalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform"",""mi" &
        "n_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode crack_point_offset above 10".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""crack_point_offset"":11" &
        "},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform""" &
        ",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode crack_point_offset fractional".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""crack_point_offset"":1." &
        "5},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uniform" &
        """,""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode use_potential_placements_chance above 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uni" &
        "form"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083,""" &
        "use_potential_placements_chance"":1.5}".
    05 FILLER PIC X(60) VALUE "a geode use_alternate_layer0_chance below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uni" &
        "form"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":-0.1}".
    05 FILLER PIC X(60) VALUE "a geode without invalid_blocks_threshold".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":0.95},""outer_wall_distance"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8},""use_alternate_layer0_chance"":0.083}".
    05 FILLER PIC X(60) VALUE "a geode point_offset that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uni" &
        "form"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083,""" &
        "point_offset"":""1""}".
    05 FILLER PIC X(60) VALUE "a geode noise_multiplier that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:geode"",""blocks"":{""filling_provider"":{""id"":""minecraft:air""},""i" &
        "nner_layer_provider"":{""id"":""minecraft:amethyst_block""},""alternate_inner_layer_pr" &
        "ovider"":{""id"":""minecraft:budding_amethyst""},""middle_layer_provider"":{""id"":""minec" &
        "raft:calcite""},""outer_layer_provider"":{""id"":""minecraft:smooth_basalt""},""inner_pl" &
        "acements"":[{""id""  :""minecraft:small_amethyst_bud""},{""id""  :""minecraft:amethyst_c" &
        "luster""}],""cannot_replace"":""#minecraft:features_cannot_replace"",""invalid_blocks""" &
        ":""#minecraft:geode_invalid_blocks""},""layers"":{},""crack"":{""generate_crack_chance""" &
        ":0.95},""invalid_blocks_threshold"":1,""outer_wall_distance"":{""type"":""minecraft:uni" &
        "form"",""min_inclusive"":2,""max_inclusive"":8},""use_alternate_layer0_chance"":0.083,""" &
        "noise_multiplier"":""0.05""}".
    05 FILLER PIC X(60) VALUE "a speleothem without pointed_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":""minecraft:dripstone_block"",""replace" &
        "able_blocks"":""#minecraft:dripstone_replaceable_blocks""}".
    05 FILLER PIC X(60) VALUE "a speleothem base_block that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":3,""pointed_block"":""minecraft:pointed" &
        "_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_replaceable_blocks""}".
    05 FILLER PIC X(60) VALUE "a speleothem base_block object without Name".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":{},""pointed_block"":""minecraft:pointe" &
        "d_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_replaceable_blocks""}".
    05 FILLER PIC X(60) VALUE "a speleothem base_block id that is invalid".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":""Bad Id"",""pointed_block"":""minecraft:" &
        "pointed_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_replaceable_blocks" &
        """}".
    05 FILLER PIC X(60) VALUE "a speleothem without replaceable_blocks".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":""minecraft:dripstone_block"",""pointed" &
        "_block"":""minecraft:pointed_dripstone""}".
    05 FILLER PIC X(60) VALUE "a speleothem chance_of_taller_generation above 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":""minecraft:dripstone_block"",""pointed" &
        "_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:dripstone" &
        "_replaceable_blocks"",""chance_of_taller_generation"":1.1}".
    05 FILLER PIC X(60) VALUE "a speleothem chance_of_spread_radius3 below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem"",""base_block"":""minecraft:dripstone_block"",""pointed" &
        "_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:dripstone" &
        "_replaceable_blocks"",""chance_of_spread_radius3"":-0.5}".
    05 FILLER PIC X(60) VALUE "a cluster floor_to_ceiling_search_range below 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":0,""height"":{""type"":" &
        """minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""minec" &
        "raft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_he" &
        "ight_diff"":1,""height_deviation"":3,""speleothem_block_layer_thickness"":{""type"":""mi" &
        "necraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""minecra" &
        "ft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""wetness"":0.0,""chance_of_sp" &
        "eleothem_at_max_distance_from_center"":0.1,""max_distance_from_edge_affecting_chan" &
        "ce_of_speleothem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster floor_to_ceiling_search_range above 512".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":513,""height"":{""type" &
        """:""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""min" &
        "ecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_" &
        "height_diff"":1,""height_deviation"":3,""speleothem_block_layer_thickness"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""minec" &
        "raft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""wetness"":0.0,""chance_of_" &
        "speleothem_at_max_distance_from_center"":0.1,""max_distance_from_edge_affecting_ch" &
        "ance_of_speleothem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster without height".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":12,""radius"":{""type""" &
        ":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalac" &
        "tite_height_diff"":1,""height_deviation"":3,""speleothem_block_layer_thickness"":{""ty" &
        "pe"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""wetness"":0.0,""chanc" &
        "e_of_speleothem_at_max_distance_from_center"":0.1,""max_distance_from_edge_affecti" &
        "ng_chance_of_speleothem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster height_deviation below 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":12,""height"":{""type""" &
        ":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""mine" &
        "craft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_h" &
        "eight_diff"":1,""height_deviation"":0,""speleothem_block_layer_thickness"":{""type"":""m" &
        "inecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""minecr" &
        "aft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""wetness"":0.0,""chance_of_s" &
        "peleothem_at_max_distance_from_center"":0.1,""max_distance_from_edge_affecting_cha" &
        "nce_of_speleothem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster height_deviation above 64".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":12,""height"":{""type""" &
        ":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""mine" &
        "craft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_h" &
        "eight_diff"":1,""height_deviation"":65,""speleothem_block_layer_thickness"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""minec" &
        "raft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""wetness"":0.0,""chance_of_" &
        "speleothem_at_max_distance_from_center"":0.1,""max_distance_from_edge_affecting_ch" &
        "ance_of_speleothem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster density that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":12,""height"":{""type""" &
        ":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""mine" &
        "craft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_h" &
        "eight_diff"":1,""height_deviation"":3,""speleothem_block_layer_thickness"":{""type"":""m" &
        "inecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":""x"",""wetness"":0" &
        ".0,""chance_of_speleothem_at_max_distance_from_center"":0.1,""max_distance_from_edg" &
        "e_affecting_chance_of_speleothem"":3,""max_distance_from_center_affecting_height_b" &
        "ias"":8}".
    05 FILLER PIC X(60) VALUE "a cluster without wetness".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:speleothem_cluster"",""base_block"":""minecraft:dripstone_block""," &
        """pointed_block"":""minecraft:pointed_dripstone"",""replaceable_blocks"":""#minecraft:d" &
        "ripstone_replaceable_blocks"",""floor_to_ceiling_search_range"":12,""height"":{""type""" &
        ":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""radius"":{""type"":""mine" &
        "craft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""max_stalagmite_stalactite_h" &
        "eight_diff"":1,""height_deviation"":3,""speleothem_block_layer_thickness"":{""type"":""m" &
        "inecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""density"":{""type"":""minecr" &
        "aft:uniform"",""min_inclusive"":0.3,""max_inclusive"":0.7},""chance_of_speleothem_at_m" &
        "ax_distance_from_center"":0.1,""max_distance_from_edge_affecting_chance_of_speleot" &
        "hem"":3,""max_distance_from_center_affecting_height_bias"":8}".
    05 FILLER PIC X(60) VALUE "a large_dripstone without replaceable_blocks".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""column_radius"":{""type"":""minecraft:clamped""," &
        """min_inclusive"":3,""max_inclusive"":16,""source"":{""type"":""minecraft:uniform"",""min_i" &
        "nclusive"":2,""max_inclusive"":8}},""height_scale"":{""type"":""minecraft:uniform"",""min_" &
        "inclusive"":2,""max_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""s" &
        "talactite_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusiv" &
        "e"":8},""stalagmite_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8},""wind_speed"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_in" &
        "clusive"":8},""min_radius_for_wind"":4,""min_bluntness_for_wind"":0.6}".
    05 FILLER PIC X(60) VALUE "a large_dripstone search range above 512".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_r" &
        "eplaceable_blocks"",""column_radius"":{""type"":""minecraft:clamped"",""min_inclusive"":3" &
        ",""max_inclusive"":16,""source"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8}},""height_scale"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max" &
        "_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""stalactite_bluntne" &
        "ss"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""stalagmite" &
        "_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""wi" &
        "nd_speed"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""min_" &
        "radius_for_wind"":4,""min_bluntness_for_wind"":0.6,""floor_to_ceiling_search_range"":" &
        "600}".
    05 FILLER PIC X(60) VALUE "a large_dripstone without column_radius".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_r" &
        "eplaceable_blocks"",""height_scale"":{""type"":""minecraft:uniform"",""min_inclusive"":2," &
        """max_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""stalactite_blu" &
        "ntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""stalag" &
        "mite_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8}" &
        ",""wind_speed"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""" &
        "min_radius_for_wind"":4,""min_bluntness_for_wind"":0.6}".
    05 FILLER PIC X(60) VALUE "a large_dripstone min_radius_for_wind above 100".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_r" &
        "eplaceable_blocks"",""column_radius"":{""type"":""minecraft:clamped"",""min_inclusive"":3" &
        ",""max_inclusive"":16,""source"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8}},""height_scale"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max" &
        "_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""stalactite_bluntne" &
        "ss"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""stalagmite" &
        "_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""wi" &
        "nd_speed"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""min_" &
        "radius_for_wind"":101,""min_bluntness_for_wind"":0.6}".
    05 FILLER PIC X(60) VALUE "a large_dripstone min_bluntness_for_wind above 5".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_r" &
        "eplaceable_blocks"",""column_radius"":{""type"":""minecraft:clamped"",""min_inclusive"":3" &
        ",""max_inclusive"":16,""source"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8}},""height_scale"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max" &
        "_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""stalactite_bluntne" &
        "ss"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""stalagmite" &
        "_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""wi" &
        "nd_speed"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""min_" &
        "radius_for_wind"":4,""min_bluntness_for_wind"":5.5}".
    05 FILLER PIC X(60) VALUE "a large_dripstone without wind_speed".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:large_dripstone"",""replaceable_blocks"":""#minecraft:dripstone_r" &
        "eplaceable_blocks"",""column_radius"":{""type"":""minecraft:clamped"",""min_inclusive"":3" &
        ",""max_inclusive"":16,""source"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_" &
        "inclusive"":8}},""height_scale"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max" &
        "_inclusive"":8},""max_column_radius_to_cave_height_ratio"":0.33,""stalactite_bluntne" &
        "ss"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""stalagmite" &
        "_bluntness"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""mi" &
        "n_radius_for_wind"":4,""min_bluntness_for_wind"":0.6}".
    05 FILLER PIC X(60) VALUE "a sculk_patch charge_count below 1".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":0,""amount_per_charge"":32,""spread_" &
        "attempts"":64,""growth_rounds"":0,""spread_rounds"":1}".
    05 FILLER PIC X(60) VALUE "a sculk_patch charge_count above 32".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":33,""amount_per_charge"":32,""spread" &
        "_attempts"":64,""growth_rounds"":0,""spread_rounds"":1}".
    05 FILLER PIC X(60) VALUE "a sculk_patch amount_per_charge above 500".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":10,""amount_per_charge"":501,""sprea" &
        "d_attempts"":64,""growth_rounds"":0,""spread_rounds"":1}".
    05 FILLER PIC X(60) VALUE "a sculk_patch spread_attempts above 64".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":10,""amount_per_charge"":32,""spread" &
        "_attempts"":65,""growth_rounds"":0,""spread_rounds"":1}".
    05 FILLER PIC X(60) VALUE "a sculk_patch growth_rounds above 8".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":10,""amount_per_charge"":32,""spread" &
        "_attempts"":64,""growth_rounds"":9,""spread_rounds"":1}".
    05 FILLER PIC X(60) VALUE "a sculk_patch without spread_rounds".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sculk_patch"",""charge_count"":10,""amount_per_charge"":32,""spread" &
        "_attempts"":64,""growth_rounds"":0}".
    05 FILLER PIC X(60) VALUE "a fossil fossil_structures that is no array".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fossil"",""fossil_structures"":""a:b"",""overlay_structures"":[""mine" &
        "craft:fossil/spine_1_coal""],""fossil_processors"":""minecraft:fossil_rot"",""overlay_" &
        "processors"":{""processors"":[]},""max_empty_corners_allowed"":4}".
    05 FILLER PIC X(60) VALUE "a fossil structure id that is invalid".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fossil"",""fossil_structures"":[""minecraft:fossil/spine_1""],""ove" &
        "rlay_structures"":[""Bad Id""],""fossil_processors"":""minecraft:fossil_rot"",""overlay_" &
        "processors"":{""processors"":[]},""max_empty_corners_allowed"":4}".
    05 FILLER PIC X(60) VALUE "a fossil without overlay_structures".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fossil"",""fossil_structures"":[""minecraft:fossil/spine_1""],""fos" &
        "sil_processors"":""minecraft:fossil_rot"",""overlay_processors"":{""processors"":[]},""m" &
        "ax_empty_corners_allowed"":4}".
    05 FILLER PIC X(60) VALUE "a fossil max_empty_corners_allowed above 7".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fossil"",""fossil_structures"":[""minecraft:fossil/spine_1""],""ove" &
        "rlay_structures"":[""minecraft:fossil/spine_1_coal""],""fossil_processors"":""minecraf" &
        "t:fossil_rot"",""overlay_processors"":{""processors"":[]},""max_empty_corners_allowed""" &
        ":8}".
    05 FILLER PIC X(60) VALUE "a fossil max_empty_corners_allowed below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fossil"",""fossil_structures"":[""minecraft:fossil/spine_1""],""ove" &
        "rlay_structures"":[""minecraft:fossil/spine_1_coal""],""fossil_processors"":""minecraf" &
        "t:fossil_rot"",""overlay_processors"":{""processors"":[]},""max_empty_corners_allowed""" &
        ":-1}".
    05 FILLER PIC X(60) VALUE "a template id that is no identifier".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""Bad Id""},""weight"":1}]}".
    05 FILLER PIC X(60) VALUE "a template entry without a weight".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""a:b""}}]}".
    05 FILLER PIC X(60) VALUE "a template without templates".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template""}".
    05 FILLER PIC X(60) VALUE "a feature without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""charge_count"":1}".
    05 FILLER PIC X(60) VALUE "a file that is no JSON".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:monster_room"",}".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 56 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-REG      PIC X(48).
       10 WS-CASE-BODY     PIC X(1500).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-6" TO WS-DIR
     CALL "LOAD-35-6" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-6 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-6 element count" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-A-REG(WS-I) TO WS-REG
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 35-6 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         PERFORM ASSERT-NUM
         IF WS-ROW = 0
             MOVE 1 TO WS-ROW
         END-IF
         MOVE SPACES TO WS-WANT-TYPE
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO WS-WANT-TYPE
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 35-6 " FUNCTION TRIM(WS-KEY) " has the type it names" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE WS-WANT-TYPE TO TL-OBSERVED
         IF WS-A-TYPE(WS-I) = SPACES AND SH-E-TYPE(WS-ROW) = 0
             MOVE SPACES TO TL-EXPECTED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 56
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-REG(WS-I) TO WS-REG
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-35-6/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-35-6 2>/dev/null; rm -rf build/content-test/load-35-6; mkdir -p build/content-test/load-35-6 && cp -R content/tests/fixtures/load-35-6 build/content-test/load-35-6/t && mkdir -p build/content-test/load-35-6/t/data/minecraft/" FUNCTION TRIM(WS-REG) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-6/t/data/minecraft/" FUNCTION TRIM(WS-REG) "/bad.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-6" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-6 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-6 " FUNCTION TRIM(WS-T) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
