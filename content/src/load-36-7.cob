*> The loader of docs/protocol/36-structures-7-woodland-mansion.md: 36-structures-7-woodland-mansion (T0257/T0258). LOAD-36-7 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA with every error on standard error as "ERROR registry: <registry> <key>: <detail>"; nothing of a failed load stays).
*> It registers the type rows of the part (SHAPE-REGISTER) and loads worldgen/structure, worldgen/structure_set (SHAPE-LOAD: the registry loader, JSON-STRICT, then the shape check of
*> shapes.cob). Not strict: the structure types of the other parts of document 36 are accepted by their shape alone.
*> Structure templates (data/<namespace>/structure/**/*.nbt) are NBT, not JSON, and the processors, rule tests and pieces that the
*> generators of this part use in code are not data files; neither is loaded here.
*> Where the engine cannot express a constraint of the document, the member is checked more loosely (engine gaps, reported to the orchestrator):
*> a dispatch member other than "type" (element_type, processor_type, predicate_type) is an identifier and the row of the group lists the
*> members of every kind as optional; enum lists longer than 40 bytes (step, terrain_adaptation, the heightmap names) are checked as an
*> identifier or a string; max_distance_from_center, dimension_padding and start_height are not checked inside; spacing greater than
*> separation is not checked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "woodland_mansion".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;D step;d terrain_adaptation".
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
 01 WS-ROW-COUNT           BINARY-LONG VALUE 5.
 01 WS-NOT-STRICT          BINARY-LONG VALUE 0.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/structure".
 01 WS-GROUP-1            PIC X(24) VALUE "structure".
 01 WS-REGISTRY-2         PIC X(48) VALUE "worldgen/structure_set".
 01 WS-GROUP-2            PIC X(24) VALUE "structure_set".
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-NOT-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-2 WS-GROUP-2 WS-NOT-STRICT
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-36-7.
