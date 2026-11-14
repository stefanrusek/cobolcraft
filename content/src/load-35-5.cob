*> Loader of the data pack file shapes of docs/protocol/35-worldgen-features-5-water-and-surface.md (features: water and surface).
*> LOAD-35-5 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). The files come through the
*> registry loader and JSON-STRICT (23 section 3.2); each is checked against the shape of its type (shapes.cob, CTSHAPE.cpy).
*> Registry worldgen/feature (23 section 2.1): the feature types of 35-5 section 2.1 (lake, spring_feature, disk, block_blob,
*> netherrack_replace_blobs, freeze_top_layer, iceberg, blue_ice, fill_layer, block_pile, coral_tree, coral_claw, underwater_magma,
*> spike, bonus_chest) and the composition types of 35 5 sections 1.3, 13 and 17 (overlay, sequence, simple_random_selector,
*> weighted_random_selector, simple_block, block_column, template). Load is not strict: the other feature types belong to the sibling parts.
*> Groups shared with sibling parts (identical rows everywhere): block_state (D id;o properties; also the fluid state of a spring),
*> placed_feature (R feature=feature;L placement=placement_modifier, 35-1 section 1), weighted_entry (23 section 7.5: data, weight).
*> 48 3.1: overlay has the member features (an array of placed feature objects, or one object), required.
*> 48 3.1 and 2.8: block_column: layers, direction, allowed_placement, prioritize_tip are all required; a layer is {height, provider}, each optional; direction one of the six direction names.
*> 48 3.1 and 2.8: template: processors is an object (optional, 2 of 7); templates is required; each entry is {data, weight}, data an {id, rotations?} object.
*> 48 3.1: spring_feature state is required (a block state), valid_blocks (an id or an array of ids) required; rock_count, hole_count and requires_block_below optional; rock_count and hole_count have no documented range.
*> 48 3.1: underwater_magma has the member placement_probability_per_valid_position (40 bytes, required); the engine now reads member names of up to 64 bytes (WG-MEMBER-NAMED).
*> 48 3.1: disk radius and netherrack_replace_blobs radius are int providers whose ranges (0..8, 0..12) are limits of the provider value and are not checked here; half_height 0..4 is checked; the states and targets are block states (form Q).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(24) VALUE "weighted_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R data=placed_feature;I weight=0..".
    05 FILLER PIC X(24) VALUE "block_column_layer".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "v height=int_provider;g provider=block_state_provider".
    05 FILLER PIC X(24) VALUE "template_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;a rotations".
    05 FILLER PIC X(24) VALUE "template_weighted".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T data=template_entry;I weight=0..".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "lake".
    05 FILLER PIC X(600) VALUE "Q fluid;Q barrier;T can_place_feature=block_predicate;T can_replace_with_air_o" &
        "r_fluid=block_predicate;T can_replace_with_barrier=block_predicate".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC X(600) VALUE "Q state;H valid_blocks=block;b requires_block_below;i rock_count;i hole_count".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "disk".
    05 FILLER PIC X(600) VALUE "G state_provider=block_state_provider;T target=block_predicate;V radius=int_pr" &
        "ovider;I half_height=0..4".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_blob".
    05 FILLER PIC X(600) VALUE "Q state;T can_place_on=block_predicate".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs".
    05 FILLER PIC X(600) VALUE "Q target;Q state;V radius=int_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "freeze_top_layer".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "iceberg".
    05 FILLER PIC X(600) VALUE "Q state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "blue_ice".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC X(600) VALUE "I height=0..4064;Q state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_pile".
    05 FILLER PIC X(600) VALUE "G state_provider=block_state_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC X(600) VALUE "R feature=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC X(600) VALUE "R feature=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "underwater_magma".
    05 FILLER PIC X(600) VALUE "I floor_search_range=0..512;I placement_radius_around_floor=0..64;N placement_" &
        "probability_per_valid_position=0..1".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "spike".
    05 FILLER PIC X(600) VALUE "Q state;T can_place_on=block_predicate;T can_replace=block_predicate".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC X(600) VALUE "H features=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(600) VALUE "H features=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(600) VALUE "H features=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC X(600) VALUE "L features=weighted_entry".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(600) VALUE "G to_place=block_state_provider;b schedule_tick".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(600) VALUE "L layers=block_column_layer;E direction=down|up|north|south|west|east;T allowe" &
        "d_placement=block_predicate;B prioritize_tip".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(600) VALUE "L templates=template_weighted;o processors".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 27.
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
 END PROGRAM LOAD-35-5.
