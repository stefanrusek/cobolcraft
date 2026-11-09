*> Loader of the data pack file shapes of docs/protocol/35-worldgen-features-6-underground.md (features: underground).
*> LOAD-35-6 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). The files come through the
*> registry loader and JSON-STRICT (23 section 3.2); each is checked against the shape of its type (shapes.cob, CTSHAPE.cpy).
*> Registry worldgen/feature (23 section 2.1): the feature types of 35-6 section 1: geode (4.1), speleothem (5.1), speleothem_cluster (6.1),
*> large_dripstone (7.1), sculk_patch (8.1), monster_room (9, no members), fossil (10.2) and template (10.1). Not strict: the other feature types
*> belong to the sibling parts. Groups shared with sibling parts (identical rows everywhere): block_state (S Name;o Properties), template_entry,
*> template_weighted. A block state may be written as a bare id string (5.1: data gives base_block as a bare id), so those members use form R.
*> ENGINE LIMIT: a shape member name is at most 32 bytes (shapes.cob), so these documented members are NOT checked here (a file may carry them):
*> placements_require_layer0_alternate (geode 4.1), max_stalagmite_stalactite_height_diff, chance_of_speleothem_at_max_distance_from_center,
*> max_distance_from_edge_affecting_chance_of_speleothem, max_distance_from_center_affecting_height_bias (cluster 6.1),
*> max_column_radius_to_cave_height_ratio (large_dripstone 7.1).
*> ASSUMPTION: geode.blocks provider members (filling_provider and four more) are checked as objects only: 35-6 section 4.1 says the data writes the simple provider as {"id": ...} with no type member, so the type-dispatched check of a state provider is not applied.
*> ASSUMPTION: fossil.fossil_processors and fossil.overlay_processors are checked as any value (an id string or an inline {"processors": [...]} object, 10.2); the equal length of fossil_structures and overlay_structures and the non-empty rule are not checked.
*> ASSUMPTION: geode layers/crack/blocks are objects without a type member; a member written 'required' in 4.1 is required, a member with a default is optional.
*> ASSUMPTION: large_dripstone column_radius, height_scale and the other provider members accept a number or an object of the provider group (provider type names are 35-2's).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "S Name;o Properties".
    05 FILLER PIC X(24) VALUE "template_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;a rotations".
    05 FILLER PIC X(24) VALUE "template_weighted".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T data=template_entry;I weight=0..".
    05 FILLER PIC X(24) VALUE "geode_blocks".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "O filling_provider;O inner_layer_provider;O alternate_inner_layer_provider;O mid" &
        "dle_layer_provider;O outer_layer_provider;L inner_placements=block_state;H canno" &
        "t_replace=block;H invalid_blocks=block".
    05 FILLER PIC X(24) VALUE "geode_layers".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "n filling=0.01..50;n inner_layer=0.01..50;n middle_layer=0.01..50;n outer_layer=" &
        "0.01..50".
    05 FILLER PIC X(24) VALUE "geode_crack".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "n generate_crack_chance=0..1;n base_crack_size=0..5;i crack_point_offset=0..10".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "geode".
    05 FILLER PIC X(600) VALUE "T blocks=geode_blocks;T layers=geode_layers;T crack=geode_crack;n use_potential_" &
        "placements_chance=0..1;n use_alternate_layer0_chance=0..1;v outer_wall_distance=" &
        "int_provider;v distribution_points=int_provider;v point_offset=int_provider;i mi" &
        "n_gen_offset;i max_gen_offset;n noise_multiplier;I invalid_blocks_threshold".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "speleothem".
    05 FILLER PIC X(600) VALUE "R base_block=block_state;R pointed_block=block_state;H replaceable_blocks=block;" &
        "n chance_of_taller_generation=0..1;n chance_of_directional_spread=0..1;n chance_" &
        "of_spread_radius2=0..1;n chance_of_spread_radius3=0..1".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "speleothem_cluster".
    05 FILLER PIC X(600) VALUE "R base_block=block_state;R pointed_block=block_state;H replaceable_blocks=block;" &
        "I floor_to_ceiling_search_range=1..512;V height=int_provider;V radius=int_provid" &
        "er;I height_deviation=1..64;V speleothem_block_layer_thickness=int_provider;V de" &
        "nsity=float_provider;V wetness=float_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "large_dripstone".
    05 FILLER PIC X(600) VALUE "H replaceable_blocks=block;i floor_to_ceiling_search_range=1..512;V column_radiu" &
        "s=int_provider;V height_scale=float_provider;V stalactite_bluntness=float_provid" &
        "er;V stalagmite_bluntness=float_provider;V wind_speed=float_provider;I min_radiu" &
        "s_for_wind=0..100;N min_bluntness_for_wind=0..5".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "sculk_patch".
    05 FILLER PIC X(600) VALUE "I charge_count=1..32;I amount_per_charge=1..500;I spread_attempts=1..64;I growth" &
        "_rounds=0..8;I spread_rounds=0..8".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "monster_room".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "fossil".
    05 FILLER PIC X(600) VALUE "K fossil_structures;K overlay_structures;X fossil_processors;X overlay_processor" &
        "s;I max_empty_corners_allowed=0..7".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(600) VALUE "L templates=template_weighted;x processors".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 14.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/feature".
 01 WS-GROUP-1            PIC X(24) VALUE "feature".
 01 WS-STRICT-1           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-35-6.
