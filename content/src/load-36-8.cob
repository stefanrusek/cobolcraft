*> The loader of docs/protocol/36-structures-8-nether-and-end.md: 36-structures-8-nether-and-end (T0259/T0260). LOAD-36-8 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA with every error on standard error as "ERROR registry: <registry> <key>: <detail>"; nothing of a failed load stays).
*> It registers the type rows of the part (SHAPE-REGISTER) and loads worldgen/structure, worldgen/structure_set, worldgen/template_pool (SHAPE-LOAD: the registry loader, JSON-STRICT, then the shape check of
*> shapes.cob). Not strict: the structure types of the other parts of document 36 are accepted by their shape alone.
*> Structure templates (data/<namespace>/structure/**/*.nbt) are NBT, not JSON, and the processors, rule tests and pieces that the
*> generators of this part use in code are not data files; neither is loaded here.
*> Where the engine cannot express a constraint of the document, the member is checked more loosely (engine gaps, reported to the orchestrator):
*> a dispatch member other than "type" (element_type, processor_type, predicate_type) is an identifier and the row of the group lists the
*> members of every kind as optional; enum lists longer than 40 bytes (step, terrain_adaptation, the heightmap names) are checked as an
*> identifier or a string; max_distance_from_center, dimension_padding and start_height are not checked inside; spacing greater than
*> separation is not checked.
*> 48 3.15: a pool element is dispatched on element_type (the row "@"): single and legacy_single elements require location, processors and projection, a feature element feature and projection, a list element elements and projection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;D step;d terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "end_city".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;D step;d terrain_adaptation".
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
    05 FILLER PIC X(24) VALUE "processor_list".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L processors=processor".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 22.
 01 WS-NOT-STRICT          BINARY-LONG VALUE 0.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-REGISTRY-2         PIC X(48) VALUE "worldgen/structure_set".
 01 WS-GROUP-2            PIC X(24) VALUE "structure_set".
 01 WS-REGISTRY-3         PIC X(48) VALUE "worldgen/template_pool".
 01 WS-GROUP-3            PIC X(24) VALUE "template_pool".
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-2 WS-GROUP-2 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-3 WS-GROUP-3 WS-NOT-STRICT
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-36-8.
