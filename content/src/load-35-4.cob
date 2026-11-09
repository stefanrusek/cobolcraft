*> Loader of docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md (worldgen features, part 4: tree decorators and the vegetation features).
*> LOAD-35-4 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). It registers the type rows of
*> this document part (group, type, member list: the forms of CTSHAPE.cpy) and loads, through SHAPE-LOAD (the registry loader and
*> JSON-STRICT of 23 sections 1 and 3, then the shape check), the registries this part defines the file shapes of:
*>   worldgen/feature (group feature)
*> Sections 3.3 (the eleven tree decorators), 4 simple_block, 5 block_column, 6 bamboo, 7 vines, single_block_pillar,
*> random_neighbor_spread, overlay, replace_single_block, projected_random_patchy_square, 8 multiface_growth, 9 vegetation_patch and
*> waterlogged_vegetation_patch, 10 root_system, 11 huge mushrooms and huge fungus. Groups: tree_decorator (11 types; they occur inside a
*> tree feature, so the registry loaded is worldgen/feature, strict 0 as the other feature types belong to other parts), feature (the
*> rows of this part and the host row tree, the same text as 35-3: a row that exists is kept) and placed_feature (the typeless row of 35-1, for the inline placed features), column_layer, replace_target (typeless).
*> Providers and block states are any value X (see 35-2), block sets are H of the group block, predicates T of the group block_predicate
*> (checked when 35-2 has registered them), placed features R or H of the group placed_feature (35-1). The enum argument of CTSHAPE.cpy
*> holds 40 bytes, so the six directions of block_column are an E over 'up|down|north|south|west|east' (36 bytes) and the direction of
*> a decorator list is K (a list of identifiers).
*> ASSUMPTION: block_column members layers, direction, allowed_placement, prioritize_tip are all required (the document lists them without defaults)
*> ASSUMPTION: multiface_growth member can_be_placed_on is required and block is a block identifier D (the document gives defaults for the others)
*> ASSUMPTION: single_block_pillar members block and direction are required, can_replace, chance_to_continue and cap_feature optional (can_replace and chance_to_continue have the defaults the document states)
*> ASSUMPTION: decorator members of the list directions (attached_to_logs, attached_to_leaves) are lists of direction names as identifiers
*> ASSUMPTION: the root_system and vegetation_patch members are all required (the document lists no defaults), huge mushroom foliage_radius is optional (default 2 stated)
*> ASSUMPTION: alter_ground member provider, shelf_mushroom member probability (the class calls it placementProbability, the document lists JSON name probability) as stated; replace_single_block target and state per entry are required
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(100) VALUE "X trunk_provider;T trunk_placer=trunk_placer;X foliage_provider;T foliage_placer=foliage_placer;t ro".
    05 FILLER PIC X(100) VALUE "ot_placer=root_placer;T minimum_size=feature_size;l decorators=tree_decorator;b ignore_vines;X below".
    05 FILLER PIC X(100) VALUE "_trunk_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "trunk_vine".
    05 FILLER PIC X(100) VALUE "x type".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "leave_vine".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "cocoa".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "creaking_heart".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "beehive".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "shelf_mushroom".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "alter_ground".
    05 FILLER PIC X(100) VALUE "X provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "attached_to_logs".
    05 FILLER PIC X(100) VALUE "N probability=0..1;X block_provider;K directions".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "attached_to_leaves".
    05 FILLER PIC X(100) VALUE "N probability=0..1;I exclusion_radius_xz=0..16;I exclusion_radius_y=0..16;X block_provider;I require".
    05 FILLER PIC X(100) VALUE "d_empty_blocks=1..16;K directions".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "place_on_ground".
    05 FILLER PIC X(100) VALUE "i tries=1..;i radius=0..;i height=0..;X block_state_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "tree_decorator".
    05 FILLER PIC X(48) VALUE "pale_moss".
    05 FILLER PIC X(100) VALUE "N leaves_probability=0..1;N trunk_probability=0..1;N ground_probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "column_layer".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "V height=int_provider;X provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "replace_target".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "X target;X state".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(100) VALUE "X to_place;b schedule_tick".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(100) VALUE "L layers=column_layer;E direction=up|down|north|south|west|east;T allowed_placement=block_predicate;".
    05 FILLER PIC X(100) VALUE "B prioritize_tip".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "bamboo".
    05 FILLER PIC X(100) VALUE "N probability=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "vines".
    05 FILLER PIC X(100) VALUE "x type".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC X(100) VALUE "X block;t can_replace=block_predicate;E direction=up|down;n chance_to_continue=0..1;r cap_feature=pl".
    05 FILLER PIC X(100) VALUE "aced_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "random_neighbor_spread".
    05 FILLER PIC X(100) VALUE "X block;H accepted_neighbors=block;T can_replace=block_predicate;V attempts=int_provider;V xz_offset".
    05 FILLER PIC X(100) VALUE "=int_provider;V y_offset=int_provider".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC X(100) VALUE "H features=placed_feature".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(100) VALUE "L targets=replace_target".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "projected_random_patchy_square".
    05 FILLER PIC X(100) VALUE "X block;T project_through=block_predicate;V size=int_provider;I max_projection_height=0..".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "multiface_growth".
    05 FILLER PIC X(100) VALUE "D block;i search_range=1..64;b can_place_on_floor;b can_place_on_ceiling;b can_place_on_wall;n chanc".
    05 FILLER PIC X(100) VALUE "e_of_spreading=0..1;H can_be_placed_on=block".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "vegetation_patch".
    05 FILLER PIC X(100) VALUE "H replaceable=block;X ground_state;R vegetation_feature=placed_feature;E surface=floor|ceiling;V dep".
    05 FILLER PIC X(100) VALUE "th=int_provider;N extra_bottom_block_chance=0..1;I vertical_range=1..256;N vegetation_chance=0..1;V".
    05 FILLER PIC X(100) VALUE "xz_radius=int_provider;N extra_edge_column_chance=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "waterlogged_vegetation_patch".
    05 FILLER PIC X(100) VALUE "H replaceable=block;X ground_state;R vegetation_feature=placed_feature;E surface=floor|ceiling;V dep".
    05 FILLER PIC X(100) VALUE "th=int_provider;N extra_bottom_block_chance=0..1;I vertical_range=1..256;N vegetation_chance=0..1;V".
    05 FILLER PIC X(100) VALUE "xz_radius=int_provider;N extra_edge_column_chance=0..1".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "root_system".
    05 FILLER PIC X(100) VALUE "R feature=placed_feature;I required_vertical_space_for_tree=1..64;I level_test_distance=0..16;I max_".
    05 FILLER PIC X(100) VALUE "level_deviation=0..64;I root_radius=1..64;H root_replaceable=block;X root_state_provider;I root_plac".
    05 FILLER PIC X(100) VALUE "ement_attempts=1..256;I root_column_max_height=1..4096;I hanging_root_radius=1..64;I hanging_roots_v".
    05 FILLER PIC X(100) VALUE "ertical_span=1..16;X hanging_root_state_provider;I hanging_root_placement_attempts=1..256;I allowed_".
    05 FILLER PIC X(100) VALUE "vertical_water_for_tree=1..64;T allowed_tree_position=block_predicate".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "huge_brown_mushroom".
    05 FILLER PIC X(100) VALUE "X cap_provider;X stem_provider;i foliage_radius;T can_place_on=block_predicate".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "huge_red_mushroom".
    05 FILLER PIC X(100) VALUE "X cap_provider;X stem_provider;i foliage_radius;T can_place_on=block_predicate".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "huge_fungus".
    05 FILLER PIC X(100) VALUE "X valid_base_block;X stem_state;X hat_state;X decor_state;T replaceable_blocks=block_predicate;b pla".
    05 FILLER PIC X(100) VALUE "nted".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC X(100) VALUE SPACES.
 01 WS-ROW-COUNT           BINARY-LONG VALUE 31.
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
 END PROGRAM LOAD-35-4.
