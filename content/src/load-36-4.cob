*> Loader of docs/protocol/36-structures-4-scattered-and-small.md (desert pyramid, jungle temple, swamp hut, igloo, buried treasure, ruined portal, nether fossil (sections 1, 8.1, 9.1)).
*> Shapes: the structure elements of the seven types of the map in section 1 (the common settings of 36-1; ruined_portal adds setups, 8.1;
*> nether_fossil adds height, 9.1) and the structure sets that section 1 quotes (the placements of 36-1 section 3.3, registered here too: a row that
*> exists is left as it is). A setup's placement is checked as a string (the six names are longer than an enum argument), height as any value (a height
*> provider with no "type" is an anchor object), and setups only as an array (the non-empty rule is not checked).
*> ASSUMPTION: ruined_portal setup: only placement is required; air_pocket_probability, mossiness, overgrown, vines, can_be_cold, replace_with_blackstone and weight are optional (8.1 lists the members but not which are required; the nether portal has no mossiness).
*> ASSUMPTION: ruined_portal setup: weight is a number (float) of any size; 8.1 gives no range.
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "buried_treasure".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "desert_pyramid".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "igloo".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jungle_temple".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "swamp_hut".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;L setups=ruined_portal_setup".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;X height".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "ruined_portal_setup".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "S placement;n air_pocket_probability=0..1;n mossiness=0..1;b overgrown;b vines;b can_be_cold;b replace_with_blackstone;n".
    05 FILLER PIC X(120) VALUE " weight".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "L structures=structure_entry;T placement=structure_placement".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "R structure=structure;I weight=1..".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(120) VALUE "a locate_offset;s frequency_reduction_method;n frequency=0..1;I salt=0..;t exclusion_zone=exclusion_zone;I spacing=0..40".
    05 FILLER PIC X(120) VALUE "96;I separation=0..4096;e spread_type=linear|triangular".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "concentric_rings".
    05 FILLER PIC X(120) VALUE "a locate_offset;s frequency_reduction_method;n frequency=0..1;I salt=0..;t exclusion_zone=exclusion_zone;I distance=0..1".
    05 FILLER PIC X(120) VALUE "023;I spread=0..1023;I count=1..4095;H preferred_biomes=biome".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "dimension_origin".
    05 FILLER PIC X(120) VALUE "x type".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "exclusion_zone".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "R other_set=structure_set;I chunk_count=1..16".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
 01 WS-COUNT              BINARY-LONG VALUE 14.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-STRICT-1           BINARY-LONG VALUE 0.
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
 END PROGRAM LOAD-36-4.
