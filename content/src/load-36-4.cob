*> Loader of docs/protocol/36-structures-4-scattered-and-small.md (desert pyramid, jungle temple, swamp hut, igloo, buried treasure, ruined portal, nether fossil (sections 1, 8.1, 9.1)).
*> Shapes: the structure elements of the seven types of the map in section 1 (the common settings of 36-1; ruined_portal adds setups, 8.1;
*> nether_fossil adds height, 9.1) and the structure sets that section 1 quotes (the placements of 36-1 section 3.3, registered here too: a row that
*> exists is left as it is). A setup's placement is checked as a string (the six names are longer than an enum argument), height as any value (a height
*> provider with no "type" is an anchor object), and setups only as an array (the non-empty rule is not checked).
*> 48 2.8 (structure / setups): a ruined_portal setup has placement, air_pocket_probability, mossiness, overgrown, vines, can_be_cold, replace_with_blackstone and weight in every instance, so all eight are required.
*> 48 2.6: a setup's weight is a number (decimal in the data); 8.1 gives no range.
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-4.
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
    05 FILLER PIC X(48) VALUE "igloo".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jungle_temple".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "swamp_hut".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;L setups=ruined_p" &
        "ortal_setup".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;X height".
    05 FILLER PIC X(24) VALUE "ruined_portal_setup".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D placement;N air_pocket_probability=0..1;N mossiness=0..1;B overgrown;B vines" &
        ";B can_be_cold;B replace_with_blackstone;N weight=0..".
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
