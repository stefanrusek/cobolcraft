*> The compiled feature data of the feature stage (core/src/feat-data.cob compiles the JSON of worldgen/placed_feature and worldgen/feature elements into these
*> tables; core/src/feat-run.cob runs them). EXTERNAL. A placed feature (PF) is a modifier list and a feature; a feature (FT) a type and parameters; a modifier (MD)
*> a kind (the id of worldgen/placement_modifier_type, 35-1 section 3.2) and integer arguments; a predicate (PR) a type (the id of block_predicate_type, 35-2 3.1)
*> with an offset and children; a provider (PV) a block state provider. Anything the compiler does not know marks the placed feature unsupported (PF-STATUS 2): the
*> stage skips it, so no partly understood feature is ever placed.
 78 FD-MAX-PF            VALUE 1024.
 78 FD-MAX-MD            VALUE 8192.
 78 FD-MAX-FT            VALUE 2048.
 78 FD-MAX-CH            VALUE 16384.
 78 FD-MAX-PR            VALUE 4096.
 78 FD-MAX-POOL          VALUE 65536.
 78 FD-MAX-PV            VALUE 2048.
 01 FEAT-DATA EXTERNAL.
    05 FD-DIR               PIC X(1100).
    05 FD-GEN               BINARY-LONG.
    05 FD-PF-COUNT          BINARY-LONG.
    05 FD-MD-COUNT          BINARY-LONG.
    05 FD-FT-COUNT          BINARY-LONG.
    05 FD-CH-COUNT          BINARY-LONG.
    05 FD-PR-COUNT          BINARY-LONG.
    05 FD-POOL-COUNT        BINARY-LONG.
    05 FD-PV-COUNT          BINARY-LONG.
    05 FD-BAD               BINARY-LONG.
    05 FD-TR-COUNT          BINARY-LONG.
    05 FD-BC-COUNT          BINARY-LONG.
*>  placed features: PF-STATUS 0 stub (not compiled), 1 compiled, 2 unsupported; the modifiers PF-MD-FIRST on for PF-MD-COUNT; the feature index PF-FT
    05 FD-PF OCCURS 1024 TIMES.
       10 PF-KEY            PIC X(80).
       10 PF-STATUS         BINARY-LONG.
       10 PF-MD-FIRST       BINARY-LONG.
       10 PF-MD-COUNT       BINARY-LONG.
       10 PF-FT             BINARY-LONG.
*>  modifiers: MD-KIND, MD-A to MD-D, MD-PR (predicate, second predicate MD-PR2), MD-P twelve provider integers, MD-F and MD-F2 floats
    05 FD-MD OCCURS 8192 TIMES.
       10 MD-KIND           BINARY-LONG.
       10 MD-A              BINARY-LONG.
       10 MD-B              BINARY-LONG.
       10 MD-C              BINARY-LONG.
       10 MD-D              BINARY-LONG.
       10 MD-PR             BINARY-LONG.
       10 MD-PR2            BINARY-LONG.
       10 MD-P              BINARY-LONG OCCURS 12 TIMES.
       10 MD-F              FLOAT-LONG.
       10 MD-F2             FLOAT-LONG.
*>  features: FT-TYPE the id of worldgen/feature_type (-1 unsupported); FT-A, FT-B, FT-C parameters (children from CH-ROW FT-A for FT-B rows, FT-C the default placed feature)
    05 FD-FT OCCURS 2048 TIMES.
       10 FT-KEY            PIC X(80).
       10 FT-TYPE           BINARY-LONG.
       10 FT-A              BINARY-LONG.
       10 FT-B              BINARY-LONG.
       10 FT-C              BINARY-LONG.
       10 FT-D              BINARY-LONG.
       10 FT-E              BINARY-LONG.
       10 FT-F              FLOAT-LONG.
    05 FD-CH OCCURS 16384 TIMES.
       10 CH-PF             BINARY-LONG.
       10 CH-W              BINARY-LONG.
       10 CH-F              FLOAT-LONG.
*>  predicates: PR-TYPE (0 unsupported), the offset PR-OX, PR-OY, PR-OZ, PR-A and PR-B parameters, PR-POOL and PR-N a slice of the pool, PR-CHILD the first child and PR-NEXT the next sibling
    05 FD-PR OCCURS 4096 TIMES.
       10 PR-TYPE           BINARY-LONG.
       10 PR-OX             BINARY-LONG.
       10 PR-OY             BINARY-LONG.
       10 PR-OZ             BINARY-LONG.
       10 PR-A              BINARY-LONG.
       10 PR-B              BINARY-LONG.
       10 PR-C              BINARY-LONG.
       10 PR-D              BINARY-LONG.
       10 PR-E              BINARY-LONG.
       10 PR-F              BINARY-LONG.
       10 PR-POOL           BINARY-LONG.
       10 PR-N              BINARY-LONG.
       10 PR-CHILD          BINARY-LONG.
       10 PR-NEXT           BINARY-LONG.
    05 FD-POOL              BINARY-LONG OCCURS 65536 TIMES.
*>  providers: PV-TYPE 1 simple (PV-A the state), 2 weighted (PV-POOL, PV-N pairs state and weight in the pool), 3 random_block (PV-POOL, PV-N block indices), 4 randomized_int (PV-POOL, PV-N the states of the values PV-LO on, PV-IP the int provider of the values); 0 unsupported
    05 FD-PV OCCURS 2048 TIMES.
       10 PV-TYPE           BINARY-LONG.
       10 PV-A              BINARY-LONG.
       10 PV-POOL           BINARY-LONG.
       10 PV-N              BINARY-LONG.
       10 PV-LO             BINARY-LONG.
       10 PV-IP.
          15 PV-IP-V        BINARY-LONG OCCURS 4 TIMES.
*>  tree features (type 51; core/src/feat-tree.cob FD-TREE-NODE and FR-TREE, docs/protocol/35-worldgen-features-3 sections 2 to 5): FT-A of the feature is the row. The trunk is the
*>  straight placer (base height and the two random heights); the foliage placer TR-FKIND 1 blob, 2 spruce, 3 pine, each int provider four integers like FR-INT-SAMPLE (TR-FH the
*>  height, TR-RAD the radius, TR-OFF the offset, TR-TH the spruce trunk_height); the size TR-SZ-LIMIT, TR-SZ-LOWER, TR-SZ-UPPER (two layers); the states are default states (the log's
*>  axis y, the leaves at distance 7, not persistent, not waterlogged); TR-LEAF-BLOCK the block index of the leaves. The pools hold block indices: the tag replaceable_by_trees, the tag
*>  logs and the tag cannot_replace_below_tree_trunk (the soil_beneath_tree provider puts TR-SOIL-STATE under the trunk where the block is not in that tag).
    05 FD-TR OCCURS 256 TIMES.
       10 TR-BASE           BINARY-LONG.
       10 TR-RA             BINARY-LONG.
       10 TR-RB             BINARY-LONG.
       10 TR-LOG-STATE      BINARY-LONG.
       10 TR-LEAF-STATE     BINARY-LONG.
       10 TR-LEAF-BLOCK     BINARY-LONG.
       10 TR-SOIL-STATE     BINARY-LONG.
       10 TR-FKIND          BINARY-LONG.
       10 TR-FH.
          15 TR-FH-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-RAD.
          15 TR-RAD-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-OFF.
          15 TR-OFF-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-TH.
          15 TR-TH-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-SZ-LIMIT       BINARY-LONG.
       10 TR-SZ-LOWER       BINARY-LONG.
       10 TR-SZ-UPPER       BINARY-LONG.
       10 TR-REPL-START     BINARY-LONG.
       10 TR-REPL-N         BINARY-LONG.
       10 TR-LOGS-START     BINARY-LONG.
       10 TR-LOGS-N         BINARY-LONG.
       10 TR-CANT-START     BINARY-LONG.
       10 TR-CANT-N         BINARY-LONG.
*>     batch 3 (tree types): the trunk placer TR-TKIND (1 straight, 2 fancy, 3 dark oak, 4 giant, 5 mega jungle, 6 forking), the foliage placer TR-FKIND adds 4 acacia, 5 fancy, 6 jungle, 7 mega pine,
*>     8 dark oak (TR-FH is its height or the crown_height of the mega pine); the size TR-SZ-KIND 0 two layers, 1 three layers (TR-SZ-UPLIM the upper_limit, TR-SZ-MID the middle_size)
       10 TR-TKIND          BINARY-LONG.
       10 TR-SZ-KIND        BINARY-LONG.
       10 TR-SZ-UPLIM       BINARY-LONG.
       10 TR-SZ-MID         BINARY-LONG.
       10 TR-LVS-START      BINARY-LONG.
       10 TR-LVS-N          BINARY-LONG.
*>     batch 4 (mangrove, 35-3 4.8 and 6): TR-TKIND 7 upwards branching (TR-EBS extra_branch_steps and TR-EBL extra_branch_length are int providers, TR-PROB the branch probability, the
*>     pool TR-CGT the can_grow_through blocks), TR-MINCLIP the min_clipped_height (-1 absent); the root placer (TR-ROOT 1): TR-TOY the trunk_offset_y provider, the states TR-ROOT-STATE,
*>     TR-ABOVE-STATE (TR-ABOVE-ON, TR-ABOVE-CHANCE) and TR-MUD-STATE, the pools TR-RCG (root can_grow_through) and TR-MUD (muddy_roots_in), TR-MAXW and TR-MAXL the root width and length
*>     limits, TR-SKEW the random skew chance
       10 TR-EBS.
          15 TR-EBS-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-EBL.
          15 TR-EBL-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-TOY.
          15 TR-TOY-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-PROB           FLOAT-LONG.
       10 TR-ABOVE-CHANCE   FLOAT-LONG.
       10 TR-SKEW           FLOAT-LONG.
       10 TR-CGT-START      BINARY-LONG.
       10 TR-CGT-N          BINARY-LONG.
       10 TR-MINCLIP        BINARY-LONG.
       10 TR-ROOT           BINARY-LONG.
       10 TR-ROOT-STATE     BINARY-LONG.
       10 TR-ABOVE-ON       BINARY-LONG.
       10 TR-ABOVE-STATE    BINARY-LONG.
       10 TR-MUD-STATE      BINARY-LONG.
       10 TR-RCG-START      BINARY-LONG.
       10 TR-RCG-N          BINARY-LONG.
       10 TR-MUD-START      BINARY-LONG.
       10 TR-MUD-N          BINARY-LONG.
       10 TR-MAXW           BINARY-LONG.
       10 TR-MAXL           BINARY-LONG.
*>     batch 5 (35-3 4.7 bending, 4.9 cherry, 5.2 bush, random spread and cherry foliage): TR-TKIND 8 cherry, 9 bending; TR-FKIND 9 bush, 10 random spread, 11 cherry. TR-MHL the min_height_for_leaves
*>     and TR-BEND the bend_length provider of the bending trunk; the cherry trunk's providers TR-BC (branch_count), TR-BHL (branch_horizontal_length), TR-BSO (branch_start_offset_from_top, the uniform
*>     range: a and b of the provider) and TR-BEO (branch_end_offset_from_top); TR-ATTEMPTS the leaf_placement_attempts of the random spread; TR-CF1 to TR-CF4 the cherry foliage chances
*>     (wide_bottom_layer_hole_chance, corner_hole_chance, hanging_leaves_chance, hanging_leaves_extension_chance)
       10 TR-MHL            BINARY-LONG.
       10 TR-ATTEMPTS       BINARY-LONG.
       10 TR-BEND.
          15 TR-BEND-V      BINARY-LONG OCCURS 4 TIMES.
       10 TR-BC.
          15 TR-BC-V        BINARY-LONG OCCURS 4 TIMES.
       10 TR-BHL.
          15 TR-BHL-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-BSO.
          15 TR-BSO-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-BEO.
          15 TR-BEO-V       BINARY-LONG OCCURS 4 TIMES.
       10 TR-CF1            FLOAT-LONG.
       10 TR-CF2            FLOAT-LONG.
       10 TR-CF3            FLOAT-LONG.
       10 TR-CF4            FLOAT-LONG.
*>     batch 6 (decorators): TR-NDEC decorators in TR-DEC(1 ..), the stump decorators of a fallen tree TR-NSDEC from TR-DEC(6); TD-KIND 0 accepted and ignored, 1 attached_to_logs,
*>     TD-PROB the probability, TD-PV the provider (PV row), TD-ND and TD-DIR the directions (ordinals DOWN 0 UP 1 NORTH 2 SOUTH 3 WEST 4 EAST 5)
       10 TR-NDEC           BINARY-LONG.
       10 TR-NSDEC          BINARY-LONG.
       10 TR-DEC OCCURS 10 TIMES.
          15 TD-KIND        BINARY-LONG.
          15 TD-PROB        FLOAT-LONG.
          15 TD-PV          BINARY-LONG.
          15 TD-ND          BINARY-LONG.
          15 TD-DIR         BINARY-LONG OCCURS 6 TIMES.
*>  block columns (type 2; core/src/feat-column.cob FR-BLOCK-COLUMN, docs/protocol/35-worldgen-features-4 section 5): FT-A of the feature is the row. BC-DIR 1 up or -1 down, BC-TIP prioritize_tip, BC-PR the
*>  allowed_placement predicate, BC-N layers (at most 4), each with the four integers of its height int provider and the provider index.
    05 FD-BC OCCURS 128 TIMES.
       10 BC-DIR            BINARY-LONG.
       10 BC-TIP            BINARY-LONG.
       10 BC-PR             BINARY-LONG.
       10 BC-N              BINARY-LONG.
       10 BC-LAYER OCCURS 4 TIMES.
          15 BC-H           BINARY-LONG OCCURS 4 TIMES.
          15 BC-PV          BINARY-LONG.
