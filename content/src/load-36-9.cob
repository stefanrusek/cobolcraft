*> The loader of docs/protocol/36-structures-9-villages-outposts.md: 36-structures-9-villages-outposts (T0261/T0262). LOAD-36-9 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA with every error on standard error as "ERROR registry: <registry> <key>: <detail>"; nothing of a failed load stays).
*> It registers the type rows of the part (SHAPE-REGISTER) and loads worldgen/structure, worldgen/structure_set, worldgen/template_pool, worldgen/processor_list (SHAPE-LOAD: the registry loader, JSON-STRICT, then the shape check of
*> shapes.cob). Not strict: the structure types of the other parts of document 36 are accepted by their shape alone.
*> Structure templates (data/<namespace>/structure/**/*.nbt) are NBT, not JSON, and the processors, rule tests and pieces that the
*> generators of this part use in code are not data files; neither is loaded here.
*> Where the engine cannot express a constraint of the document, the member is checked more loosely (engine gaps, reported to the orchestrator):
*> a dispatch member other than "type" (element_type, processor_type, predicate_type) is an identifier and the row of the group lists the
*> members of every kind as optional; enum lists longer than 40 bytes (step, terrain_adaptation, the heightmap names) are checked as an
*> identifier or a string; max_distance_from_center, dimension_padding and start_height are not checked inside; spacing greater than
*> separation is not checked.
*> 48 3.15: a pool element is dispatched on element_type (the row "@"): single and legacy_single elements require location, processors and projection, a feature element feature and projection, a list element elements and projection.
*> 48 3.17: a rule test is dispatched on predicate_type: all_of and any_of require rules, not requires rule, block_match block, blockstate_match block_state, height_match min_inclusive and max_inclusive, random_block_match block and probability, tag_match tag, always_true nothing.
*> 48 3.18: a position test is dispatched on predicate_type; axis_aligned_linear_pos requires max_chance and max_dist; no ranges are checked on the chances beyond 0..1.
*> 48 3.16: processors are dispatched on processor_type: block_rot (integrity; rottable_blocks optional), capped (delegate, limit), protected_blocks (value), rule (rules); the other types of 36-2 keep their rows, members optional.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;D step;d terrain_adaptation;R start_pool=temp" &
        "late_pool;d start_jigsaw_name;I size=0..20;O start_height;B use_expansion_hack" &
        ";s project_start_to_heightmap;X max_distance_from_center;l pool_aliases=pool_a" &
        "lias_binding;x dimension_padding;e liquid_settings=ignore_waterlogging|apply_w" &
        "aterlogging".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(600) VALUE "I spacing=0..4096;I separation=0..4096;I salt=0..;e spread_type=linear|triangu" &
        "lar;n frequency=0..1;d frequency_reduction_method;t exclusion_zone=exclusion_z" &
        "one;a locate_offset".
    05 FILLER PIC X(24) VALUE "exclusion_zone".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R other_set=structure_set;I chunk_count=1..16".
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L structures=structure_entry;T placement=structure_placement".
    05 FILLER PIC X(24) VALUE "structure_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R structure=structure;I weight=1..".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "direct".
    05 FILLER PIC X(600) VALUE "D alias;D target".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "random".
    05 FILLER PIC X(600) VALUE "D alias;L targets=pool_alias_target".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "random_group".
    05 FILLER PIC X(600) VALUE "L groups=pool_alias_binding_group".
    05 FILLER PIC X(24) VALUE "pool_alias_binding_group".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L data=pool_alias_binding;I weight=1..".
    05 FILLER PIC X(24) VALUE "pool_alias_target".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D data;I weight=1..".
    05 FILLER PIC X(24) VALUE "template_pool".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L elements=pool_entry;R fallback=template_pool".
    05 FILLER PIC X(24) VALUE "pool_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T element=pool_element;I weight=1..150".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "element_type".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "empty_pool_element".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "feature_pool_element".
    05 FILLER PIC X(600) VALUE "R feature=placed_feature;E projection=rigid|terrain_matching;e override_liquid" &
        "_settings=ignore_waterlogging|apply_waterlogging".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "legacy_single_pool_element".
    05 FILLER PIC X(600) VALUE "D location;R processors=processor_list;E projection=rigid|terrain_matching;e o" &
        "verride_liquid_settings=ignore_waterlogging|apply_waterlogging".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "single_pool_element".
    05 FILLER PIC X(600) VALUE "D location;R processors=processor_list;E projection=rigid|terrain_matching;e o" &
        "verride_liquid_settings=ignore_waterlogging|apply_waterlogging".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "list_pool_element".
    05 FILLER PIC X(600) VALUE "L elements=pool_element;E projection=rigid|terrain_matching;e override_liquid_" &
        "settings=ignore_waterlogging|apply_waterlogging".
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(24) VALUE "processor_list".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L processors=processor".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "processor_type".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_rot".
    05 FILLER PIC X(600) VALUE "N integrity=0..1;h rottable_blocks=block".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "capped".
    05 FILLER PIC X(600) VALUE "T delegate=processor;V limit=int_provider".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "protected_blocks".
    05 FILLER PIC X(600) VALUE "H value=block".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "rule".
    05 FILLER PIC X(600) VALUE "L rules=processor_rule".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "gravity".
    05 FILLER PIC X(600) VALUE "s heightmap;i offset".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_ignore".
    05 FILLER PIC X(600) VALUE "l blocks=block_state".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_age".
    05 FILLER PIC X(600) VALUE "n mossiness".
    05 FILLER PIC X(24) VALUE "processor_rule".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T input_predicate=rule_test;T location_predicate=rule_test;Q output_state;t po" &
        "sition_predicate=pos_rule_test;t block_entity_modifier=block_entity_modifier".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "predicate_type".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "always_true".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "all_of".
    05 FILLER PIC X(600) VALUE "L rules=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "any_of".
    05 FILLER PIC X(600) VALUE "L rules=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "block_match".
    05 FILLER PIC X(600) VALUE "D block".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "blockstate_match".
    05 FILLER PIC X(600) VALUE "Q block_state".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "height_match".
    05 FILLER PIC X(600) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "not".
    05 FILLER PIC X(600) VALUE "T rule=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "random_block_match".
    05 FILLER PIC X(600) VALUE "D block;N probability=0..1".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "tag_match".
    05 FILLER PIC X(600) VALUE "D tag".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "predicate_type".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "axis_aligned_linear_pos".
    05 FILLER PIC X(600) VALUE "n min_chance=0..1;N max_chance=0..1;i min_dist;I max_dist;e axis=x|y|z".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "linear_pos".
    05 FILLER PIC X(600) VALUE "n min_chance=0..1;n max_chance=0..1;i min_dist;i max_dist".
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;o properties".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "passthrough".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "clear".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "append_static".
    05 FILLER PIC X(600) VALUE "O data".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "append_loot".
    05 FILLER PIC X(600) VALUE "D loot_table".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 47.
 01 WS-NOT-STRICT          BINARY-LONG VALUE 0.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-REGISTRY-2         PIC X(48) VALUE "worldgen/structure_set".
 01 WS-GROUP-2            PIC X(24) VALUE "structure_set".
 01 WS-REGISTRY-3         PIC X(48) VALUE "worldgen/template_pool".
 01 WS-GROUP-3            PIC X(24) VALUE "template_pool".
 01 WS-REGISTRY-4         PIC X(48) VALUE "worldgen/processor_list".
 01 WS-GROUP-4            PIC X(24) VALUE "processor_list".
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-2 WS-GROUP-2 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-3 WS-GROUP-3 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-4 WS-GROUP-4 WS-NOT-STRICT
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-36-9.
