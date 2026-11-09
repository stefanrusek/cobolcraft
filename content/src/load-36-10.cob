*> The loader of docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md: 36-structures-10-ancient-city-trial-chambers-trail-ruins (T0245/T0246). LOAD-36-10 USING root (PIC X(1100): the folder that holds data/), status out
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
*> ASSUMPTION: pool_alias_binding random_group member groups is any array (the weighted list of binding lists is not checked inside).
*> ASSUMPTION: pool_alias_target members data and weight: the document says weighted list of pool keys and names the pair {data: key, weight: int} (36-3 section 3.4); weight is checked as an integer of at least 1.
*> ASSUMPTION: pool element members other than element_type are all optional (requiredness per element kind cannot be expressed in a dispatch-free row).
*> ASSUMPTION: processor members delegate and limit follow 36-10 section 2.7; limit is any value (an int provider); rule_test and pos_rule_test members as in 36-2 sections 8.3 and 8.4, all optional.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(100) VALUE "H biomes=biome;O spawn_overrides;D step;d terrain_adaptation;R start_pool=template_pool;d start_jigs".
    05 FILLER PIC X(100) VALUE "aw_name;I size=0..20;O start_height;B use_expansion_hack;s project_start_to_heightmap;X max_distance".
    05 FILLER PIC X(100) VALUE "_from_center;l pool_aliases=pool_alias_binding;x dimension_padding;e liquid_settings=ignore_waterlog".
    05 FILLER PIC X(100) VALUE "ging|apply_waterlogging                                                                             ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(100) VALUE "I spacing=0..4096;I separation=0..4096;I salt=0..;e spread_type=linear|triangular;n frequency=0..1;d".
    05 FILLER PIC X(100) VALUE " frequency_reduction_method;t exclusion_zone=exclusion_zone;a locate_offset                         ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "exclusion_zone".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R other_set=structure_set;I chunk_count=1..16                                                       ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "L structures=structure_entry;T placement=structure_placement                                        ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R structure=structure;I weight=1..                                                                  ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "direct".
    05 FILLER PIC X(100) VALUE "D alias;D target                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "random".
    05 FILLER PIC X(100) VALUE "D alias;L targets=pool_alias_target                                                                 ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_alias_binding".
    05 FILLER PIC X(48) VALUE "random_group".
    05 FILLER PIC X(100) VALUE "A groups                                                                                            ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_alias_target".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D data;I weight=1..                                                                                 ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "template_pool".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "L elements=pool_entry;R fallback=template_pool                                                      ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "T element=pool_element;I weight=1..150                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D element_type;d location;r processors=processor_list;e projection=rigid|terrain_matching;l elements".
    05 FILLER PIC X(100) VALUE "=pool_element;r feature=placed_feature;e override_liquid_settings=ignore_waterlogging|apply_waterlog".
    05 FILLER PIC X(100) VALUE "ging                                                                                                ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "R feature=feature;L placement=placement_modifier                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "processor_list".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "L processors=processor                                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D processor_type;l rules=processor_rule;n integrity=0..1;h rottable_blocks=block;t delegate=processo".
    05 FILLER PIC X(100) VALUE "r;x limit;d loot_table;h value=block;s heightmap;i offset;a blocks                                  ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "processor_rule".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "T input_predicate=rule_test;T location_predicate=rule_test;T output_state=block_state;t position_pre".
    05 FILLER PIC X(100) VALUE "dicate=pos_rule_test;t block_entity_modifier=block_entity_modifier                                  ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D predicate_type;d block;t block_state=block_state;d tag;n probability;i min_inclusive;i max_inclusi".
    05 FILLER PIC X(100) VALUE "ve;l rules=rule_test;t rule=rule_test                                                               ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D predicate_type;n min_chance;n max_chance;i min_dist;i max_dist;e axis=x|y|z                       ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D Name;o Properties                                                                                 ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "passthrough".
    05 FILLER PIC X(100) VALUE "x type                                                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "clear".
    05 FILLER PIC X(100) VALUE "x type                                                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "append_static".
    05 FILLER PIC X(100) VALUE "O data                                                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "block_entity_modifier".
    05 FILLER PIC X(48) VALUE "append_loot".
    05 FILLER PIC X(100) VALUE "D loot_table                                                                                        ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 23.
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
 END PROGRAM LOAD-36-10.
