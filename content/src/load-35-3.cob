*> Loader of docs/protocol/35-worldgen-features-3-tree-placers.md (worldgen features, part 3: the tree feature, feature sizes, trunk, foliage and root placers, fallen trees).
*> LOAD-35-3 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). It registers the type rows of
*> this document part (group, type, member list: the forms of CTSHAPE.cpy) and loads, through SHAPE-LOAD (the registry loader and
*> JSON-STRICT of 23 sections 1 and 3, then the shape check), the registries this part defines the file shapes of:
*>   worldgen/feature (group feature)
*> Sections 2 (the TreeFeature codec), 3 (feature sizes), 4 (the ten trunk placers), 5.2 (the twelve foliage placers), 6 (the root
*> placer), 7 (the fallen_tree feature). Groups: trunk_placer, foliage_placer, root_placer, feature_size (each registered whole here, but
*> they occur only inside feature files, so the one registry loaded is worldgen/feature, strict 0: the other feature types are of other
*> parts), mangrove_placement and above_root (typeless objects). Tree decorators (35-4) are objects of the group tree_decorator, checked
*> when 35-4 has registered them. Block providers and block states are kept as any value X (see 35-2), blocks sets are H of the group block.
*> The ranges of the int providers (radius, offset 0..16 and so on) are not checked (an engine gap); the integers of the document are.
*> 48 3.3 (census of the data): the common members of a trunk placer (base_height, height_rand_a, height_rand_b) are in every instance, so required.
*> 48 3.4: radius and offset are in every foliage placer, so both are required; radius, offset, height, crown_height and trunk_height are integers where the data holds integers and int providers where it holds provider objects (pine and poplar height, mega_pine crown_height, poplar radius, spruce radius, offset and trunk_height).
*> 48 3.1: decorators of a tree and stump_decorators and log_decorators of a fallen_tree are in every instance, so required. The cherry trunk placer's branch_start_offset_from_top is an untyped {min_inclusive, max_inclusive} object (48 2.3).
*> 48 3.3 and 3.4: the extra members of the placers (height, trunk_height, crown_height, foliage_height, leaf_placement_attempts, the cherry and poplar chances, bend_length, branch members) are in every instance of their type, so required.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(600) VALUE "G trunk_provider=block_state_provider;T trunk_placer=trunk_placer;G foliage_pr" &
        "ovider=block_state_provider;T foliage_placer=foliage_placer;t root_placer=root" &
        "_placer;T minimum_size=feature_size;L decorators=tree_decorator;b ignore_vines" &
        ";G below_trunk_provider=block_state_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "fallen_tree".
    05 FILLER PIC X(600) VALUE "G trunk_provider=block_state_provider;V log_length=int_provider;L stump_decora" &
        "tors=tree_decorator;L log_decorators=tree_decorator".
    05 FILLER PIC X(24) VALUE "feature_size".
    05 FILLER PIC X(48) VALUE "two_layers_feature_size".
    05 FILLER PIC X(600) VALUE "i limit=0..81;i lower_size=0..16;i upper_size=0..16;i min_clipped_height=0..80".
    05 FILLER PIC X(24) VALUE "feature_size".
    05 FILLER PIC X(48) VALUE "three_layers_feature_size".
    05 FILLER PIC X(600) VALUE "i limit=0..80;i upper_limit=0..80;i lower_size=0..16;i middle_size=0..16;i upp" &
        "er_size=0..16;i min_clipped_height=0..80".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "straight_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "forking_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "giant_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "mega_jungle_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "dark_oak_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "fancy_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "bending_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24;i min_height_f" &
        "or_leaves=1..;V bend_length=int_provider".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "upwards_branching_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24;V extra_branch" &
        "_steps=int_provider;N place_branch_per_log_probability=0..1;V extra_branch_len" &
        "gth=int_provider;H can_grow_through=block".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "cherry_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24;V branch_count" &
        "=int_provider;V branch_horizontal_length=int_provider;O branch_start_offset_fr" &
        "om_top;V branch_end_offset_from_top=int_provider".
    05 FILLER PIC X(24) VALUE "trunk_placer".
    05 FILLER PIC X(48) VALUE "poplar_trunk_placer".
    05 FILLER PIC X(600) VALUE "I base_height=0..32;I height_rand_a=0..24;I height_rand_b=0..24;I trunk_height" &
        "_above_branches;V branch_amount=int_provider".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "blob_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I height=0..16".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "bush_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I height=0..16".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "spruce_foliage_placer".
    05 FILLER PIC X(600) VALUE "V radius=int_provider;V offset=int_provider;V trunk_height=int_provider".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "pine_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;V height=int_provider".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "acacia_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "fancy_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I height=0..16".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "jungle_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I height=0..16".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "mega_pine_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;V crown_height=int_provider".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "dark_oak_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "random_spread_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I foliage_height;I leaf_placement_attempts=0..256".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "cherry_foliage_placer".
    05 FILLER PIC X(600) VALUE "I radius;I offset;I height=4..16;N wide_bottom_layer_hole_chance=0..1;N corner" &
        "_hole_chance=0..1;N hanging_leaves_chance=0..1;N hanging_leaves_extension_chan" &
        "ce=0..1".
    05 FILLER PIC X(24) VALUE "foliage_placer".
    05 FILLER PIC X(48) VALUE "poplar_foliage_placer".
    05 FILLER PIC X(600) VALUE "V radius=int_provider;I offset;V height=int_provider;N side_hole_chance=0..1".
    05 FILLER PIC X(24) VALUE "root_placer".
    05 FILLER PIC X(48) VALUE "mangrove_root_placer".
    05 FILLER PIC X(600) VALUE "V trunk_offset_y=int_provider;G root_provider=block_state_provider;t above_roo" &
        "t_placement=above_root;T mangrove_root_placement=mangrove_placement".
    05 FILLER PIC X(24) VALUE "above_root".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "X above_root_provider;N above_root_placement_chance=0..1".
    05 FILLER PIC X(24) VALUE "mangrove_placement".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "H can_grow_through=block;H muddy_roots_in=block;X muddy_roots_provider;I max_r" &
        "oot_width=1..12;I max_root_length=1..64;N random_skew_chance=0..1".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 29.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/feature".
 01 WS-GROUP-1            PIC X(24) VALUE "feature".
 01 WS-STRICT-1           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-35-3.
