*> Loader of docs/protocol/36-structures-3-jigsaw-assembly.md (jigsaw structures, template pools and pool aliases (section 3)).
*> Shapes: worldgen/structure elements of type jigsaw (3.1), worldgen/template_pool elements (3.2: elements of element and weight 1 to 150, fallback),
*> the pool elements of 3.3 (member element_type, which is not the engine's "type" member: one untyped row of the members of all five element types,
*> only element_type required) and the pool alias bindings of 3.4 (member type: direct, random, random_group). start_height (a height provider
*> without "type" is an anchor object) and max_distance_from_center (an int or an object) and dimension_padding (an int or an object) are only checked
*> to be present or any value. Jigsaw block entity data of 3.5 lives in structure NBT files and is not loaded here.
*> ASSUMPTION: alias binding random: the weight of a targets entry (member data, weight) is an integer of at least 1; 3.4 says only int.
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;R start_pool=template_pool;d start_jigsaw_name;I size=0..20".
    05 FILLER PIC X(120) VALUE ";X start_height;B use_expansion_hack;s project_start_to_heightmap;X max_distance_from_center;l pool_aliases=pool_alias;x".
    05 FILLER PIC X(120) VALUE " dimension_padding;e liquid_settings=ignore_waterlogging|apply_waterlogging".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "template_pool".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "L elements=pool_entry;R fallback=template_pool".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "T element=pool_element;I weight=1..150".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_element".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "S element_type;d location;r processors=processor_list;e projection=rigid|terrain_matching;e override_liquid_settings=ign".
    05 FILLER PIC X(120) VALUE "ore_waterlogging|apply_waterlogging;l elements=pool_element;r feature=placed_feature".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_alias".
    05 FILLER PIC X(48) VALUE "direct".
    05 FILLER PIC X(120) VALUE "D alias;D target".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_alias".
    05 FILLER PIC X(48) VALUE "random".
    05 FILLER PIC X(120) VALUE "D alias;L targets=pool_target".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_alias".
    05 FILLER PIC X(48) VALUE "random_group".
    05 FILLER PIC X(120) VALUE "A groups".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "pool_target".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "D data;I weight=1..".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
 01 WS-COUNT              BINARY-LONG VALUE 8.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-STRICT-1           BINARY-LONG VALUE 0.
 01 WS-REGISTRY-2         PIC X(48) VALUE "worldgen/template_pool".
 01 WS-GROUP-2            PIC X(24) VALUE "template_pool".
 01 WS-STRICT-2           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-2 WS-GROUP-2 WS-STRICT-2
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-36-3.
