*> Loader of docs/protocol/36-structures-5-mineshaft-stronghold.md (mineshaft and stronghold (section 1 data table)).
*> Shapes: the structure elements mineshaft (type mineshaft with mineshaft_type normal or mesa, 2.1) and stronghold, and the structure sets mineshafts
*> and strongholds of the table in section 1 (the placements of 36-1 section 3.3, registered here too: a row that exists is left as it is).
*> step and terrain_adaptation are checked as strings (their lists are longer than an enum argument).
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "mineshaft".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation;E mineshaft_type=normal|mesa".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "stronghold".
    05 FILLER PIC X(120) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(120).
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
 01 WS-COUNT              BINARY-LONG VALUE 8.
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
 END PROGRAM LOAD-36-5.
