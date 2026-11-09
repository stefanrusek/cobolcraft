*> Loader of the data pack file shapes of docs/protocol/35-worldgen-features-5-water-and-surface.md (features: water and surface).
*> LOAD-35-5 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). The files come through the
*> registry loader and JSON-STRICT (23 section 3.2); each is checked against the shape of its type (shapes.cob, CTSHAPE.cpy).
*> Registry worldgen/feature (23 section 2.1): the feature types of 35-5 section 2.1 (lake, spring_feature, disk, block_blob,
*> netherrack_replace_blobs, freeze_top_layer, iceberg, blue_ice, fill_layer, block_pile, coral_tree, coral_claw, underwater_magma,
*> spike, bonus_chest) and the composition types of 35 5 sections 1.3, 13 and 17 (overlay, sequence, simple_random_selector,
*> weighted_random_selector, simple_block, block_column, template). Load is not strict: the other feature types belong to the sibling parts.
*> Groups shared with sibling parts (identical rows everywhere): block_state (S Name;o Properties; also the fluid state of a spring),
*> placed_feature (R feature=feature;L placement=placement_modifier, 35-1 section 1), weighted_entry (23 section 7.5: data, weight).
*> ASSUMPTION: overlay.features is a list of placed features (35-5 section 1.3 names the type but not the member; sequence and simple_random_selector use features, 35-1 sections 9.3 and 9.6).
*> ASSUMPTION: block_column: layers, direction, allowed_placement, prioritize_tip are all required (35-5 section 13.3 lists the names, not the defaults); layer = {height: int provider, provider: state provider}; direction one of the six direction names.
*> ASSUMPTION: template: processors is checked as any value (an id string, an inline object or an array: 35-6 section 10.2 writes a processor list as an id or an inline object); templates and each entry id are required, rotations optional (35-6 section 10.1 gives the {data, weight} entry form).
*> ASSUMPTION: spring_feature rock_count and hole_count have no documented range; valid_blocks is a holder set of blocks (string, #tag or list of ids).
*> ASSUMPTION: ENGINE LIMIT: the member placement_probability_per_valid_position of underwater_magma (40 bytes) is longer than the 32 bytes of a shape member name, so it is not checked (0..1 per 35-5 section 2.1); the file may carry it.
*> ASSUMPTION: disk radius and netherrack_replace_blobs radius ranges (0..8, 0..12) are limits of the int provider value and are not checked here (the provider may be an object); half_height 0..4 is checked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-35-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "S Name;o Properties".
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(24) VALUE "weighted_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R data=placed_feature;I weight=0..".
    05 FILLER PIC X(24) VALUE "block_column_layer".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "V height=int_provider;T provider=block_state_provider".
    05 FILLER PIC X(24) VALUE "template_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;a rotations".
    05 FILLER PIC X(24) VALUE "template_weighted".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T data=template_entry;I weight=0..".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "lake".
    05 FILLER PIC X(600) VALUE "T fluid=block_state_provider;T barrier=block_state_provider;T can_place_feature=" &
        "block_predicate;T can_replace_with_air_or_fluid=block_predicate;T can_replace_wi" &
        "th_barrier=block_predicate".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC X(600) VALUE "T state=block_state;H valid_blocks=block;b requires_block_below;i rock_count;i h" &
        "ole_count".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "disk".
    05 FILLER PIC X(600) VALUE "T state_provider=block_state_provider;T target=block_predicate;V radius=int_prov" &
        "ider;I half_height=0..4".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_blob".
    05 FILLER PIC X(600) VALUE "T state=block_state;T can_place_on=block_predicate".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs".
    05 FILLER PIC X(600) VALUE "T target=block_state;T state=block_state;V radius=int_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "freeze_top_layer".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "iceberg".
    05 FILLER PIC X(600) VALUE "T state=block_state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "blue_ice".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC X(600) VALUE "I height=0..4064;T state=block_state".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_pile".
    05 FILLER PIC X(600) VALUE "T state_provider=block_state_provider".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC X(600) VALUE "R feature=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC X(600) VALUE "R feature=placed_feature".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "underwater_magma".
    05 FILLER PIC X(600) VALUE "I floor_search_range=0..512;I placement_radius_around_floor=0..64".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "spike".
    05 FILLER PIC X(600) VALUE "T state=block_state;T can_place_on=block_predicate;T can_replace=block_predicate".
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
    05 FILLER PIC X(600) VALUE "T to_place=block_state_provider;b schedule_tick".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(600) VALUE "L layers=block_column_layer;E direction=down|up|north|south|west|east;T allowed_" &
        "placement=block_predicate;B prioritize_tip".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(600) VALUE "L templates=template_weighted;x processors".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 28.
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
