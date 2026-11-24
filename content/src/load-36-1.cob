*> Loader of docs/protocol/36-structures-1-model-placement-starts.md (structures: model, placement, starts (sections 2 and 3)).
*> Shapes: worldgen/structure elements (section 3.1: type, biomes, spawn_overrides, step, terrain_adaptation flattened beside the type; the 16 types of
*> section 2.2 each with the common settings; the type specific members are those of parts 36-3 to 36-10), worldgen/structure_set elements (3.2: structures
*> of structure and weight, placement) and the three placements of 2.3 and 3.3. Engine limits (worldgen shapes): step, terrain_adaptation and
*> frequency_reduction_method are checked as strings (their lists are longer than an enum argument), locate_offset only as an array, and
*> the rule spacing > separation of random_spread is not checked.
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "buried_treasure".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "desert_pyramid".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "end_city".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "igloo".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jungle_temple".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "mineshaft".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ocean_monument".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ocean_ruin".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "shipwreck".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "stronghold".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "swamp_hut".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "woodland_mansion".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L structures=structure_entry;T placement=structure_placement".
    05 FILLER PIC X(24) VALUE "structure_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R structure=structure;I weight=1..".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(600) VALUE "a locate_offset;s frequency_reduction_method;n frequency=0..1;I salt=0..;t exc" &
        "lusion_zone=exclusion_zone;I spacing=0..4096;I separation=0..4096;e spread_typ" &
        "e=linear|triangular".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "concentric_rings".
    05 FILLER PIC X(600) VALUE "a locate_offset;s frequency_reduction_method;n frequency=0..1;I salt=0..;t exc" &
        "lusion_zone=exclusion_zone;I distance=0..1023;I spread=0..1023;I count=1..4095" &
        ";H preferred_biomes=biome".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "dimension_origin".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "exclusion_zone".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R other_set=structure_set;I chunk_count=1..16".
 01 WS-COUNT              BINARY-LONG VALUE 22.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-STRICT-1           BINARY-LONG VALUE 1.
 01 WS-REGISTRY-2         PIC X(48) VALUE "worldgen/structure_set".
 01 WS-GROUP-2            PIC X(24) VALUE "structure_set".
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
 END PROGRAM LOAD-36-1.
