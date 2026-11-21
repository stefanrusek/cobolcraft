*> The loader of docs/protocol/37-nether-6...md (37-nether-6 sections 2 and 3): the Nether structure sets and structure
*> definitions. LOAD-37-6 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA when
*> any file is rejected; every error is printed on standard error as 'ERROR registry: <registry> <key>: <detail>' and
*> nothing of the part stays loaded).
*> The files of worldgen/structure_set, worldgen/structure are read through the registry loader and JSON-STRICT (SHAPE-
*> LOAD, shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy). Constraints the shape
*> forms cannot state are noted in the test.
*> NOTE: The enum member lists of step (11 names), terrain_adaptation (5) and the setup placement (6) are longer than the
*> 40 bytes of an enum argument of the shape engine, so they are checked as identifiers only (form D).
*> 48 3.13: random_spread requires salt, separation and spacing; exclusion_zone (an object), frequency (a number 0 to 1), locate_offset
*> (an array of integers, checked as an array) and the others are optional (1 to 3 of 20). 48 3.12: project_start_to_heightmap is a
*> string; spawn_overrides is an object and pool_aliases an array. 48 2.8 (structure_set / structures): a structure set entry has
*> structure (an id) and weight (an integer), both required; the minimum weight 1, the spacing range 1 to 4096 and the separation
*> range 0 to 4096 are from 37 and are not in 48, and the rule spacing > separation is not checked by the shape engine.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L structures=structure_set_entry;T placement=structure_placement".
    05 FILLER PIC X(24) VALUE "structure_set_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D structure;I weight=1..".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(600) VALUE "I spacing=1..4096;I separation=0..4096;I salt;e spread_type=linear|triangular;" &
        "a locate_offset;o exclusion_zone;n frequency=0..1".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(600) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(600) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;D start_pool;d st" &
        "art_jigsaw_name;I size=0..20;X start_height;B use_expansion_hack;s project_sta" &
        "rt_to_heightmap;V max_distance_from_center=max_distance;a pool_aliases;e liqui" &
        "d_settings=apply_waterlogging|ignore_waterlogging".
    05 FILLER PIC X(24) VALUE "max_distance".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I horizontal=1..128;i vertical=1..4064".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(600) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;L setups=ruined_p" &
        "ortal_setup".
    05 FILLER PIC X(24) VALUE "ruined_portal_setup".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D placement;N air_pocket_probability=0..1;N mossiness=0..1;B overgrown;B vines" &
        ";B can_be_cold;B replace_with_blackstone;N weight=0..".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(600) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;V height=height_p" &
        "rovider".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 9.
 01 WS-REG-1              PIC X(48) VALUE "worldgen/structure_set".
 01 WS-GROUP-1            PIC X(24) VALUE "structure_set".
 01 WS-REG-2              PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-2            PIC X(24) VALUE "structure".
 01 WS-STRICT              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-1 WS-GROUP-1 WS-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REG-2 WS-GROUP-2 WS-STRICT
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-37-6.
