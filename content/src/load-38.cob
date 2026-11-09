 *> The loader of docs/protocol/38-end.md (the End). LOAD-38 USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, CT-BAD-DATA; every error is on standard error as "ERROR registry: ..." and nothing of the load stays).
*> The files of the document: dimension type the_end (section 2), noise settings end (3), density functions end/* (4),
*> surface rule end (6), the five biomes (7): loaded by the phase 22 loaders (worldgen-*.cob, dimensions.cob). The data the
*> document wires up and no phase 22 loader reads goes through the shape engine (shapes.cob, CTSHAPE.cpy): worldgen/feature
*> (types end_spike, end_platform, end_island, end_gateway, chorus_plant, end_podium: members from section 8 and 35 part 7
*> sections 8 to 10), worldgen/placed_feature ({feature, placement}), the placement modifiers of section 8 (count, in_square,
*> biome, rarity_filter, heightmap, height_range, offset, fixed_placement; 35 part 1 section 7), worldgen/structure (end_city:
*> 36 section 3.1, section 10) and worldgen/structure_set (36 sections 3.2 and 3.3; random_spread). A type of another part is
*> accepted unchecked (strict off). Group names: feature, placed_feature, placement_modifier, int_provider, structure,
*> structure_set, structure_selection (the {structure, weight} entry), structure_placement.
*> Engine limits worked around here (not document facts): a type with no member carries the optional member "type" so
*> that its field list is not empty; heightmap and step are strings because an enum list of the engine is 40 bytes at most;
*> height_range height is any value (the bare anchor shorthand has no type); spacing > separation (36 section 3.3) is
*> not checked.
*> A failure of a phase 22 loader or of a shape check frees the world generation store and the shape elements.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-38.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC X(600) VALUE "A spikes;b crystal_invulnerable;a crystal_beam_target".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_platform".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_island".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "chorus_plant".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC X(600) VALUE "B exact;a exit".
    05 FILLER PIC X(24) VALUE "feature".
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC X(600) VALUE "b active".
    05 FILLER PIC X(24) VALUE "placed_feature".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R feature=feature;L placement=placement_modifier".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "count".
    05 FILLER PIC X(600) VALUE "V count=int_provider".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "in_square".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "biome".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "rarity_filter".
    05 FILLER PIC X(600) VALUE "I chance=1..".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "heightmap".
    05 FILLER PIC X(600) VALUE "S heightmap".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "height_range".
    05 FILLER PIC X(600) VALUE "X height".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "offset".
    05 FILLER PIC X(600) VALUE "V x=int_provider;V y=int_provider;V z=int_provider".
    05 FILLER PIC X(24) VALUE "placement_modifier".
    05 FILLER PIC X(48) VALUE "fixed_placement".
    05 FILLER PIC X(600) VALUE "A positions".
    05 FILLER PIC X(24) VALUE "int_provider".
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC X(600) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC X(24) VALUE "int_provider".
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC X(600) VALUE "I value".
    05 FILLER PIC X(24) VALUE "int_provider".
    05 FILLER PIC X(48) VALUE "weighted_list".
    05 FILLER PIC X(600) VALUE "A distribution".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "end_city".
    05 FILLER PIC X(600) VALUE "H biomes=biome;O spawn_overrides;S step;s terrain_adaptation".
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L structures=structure_selection;T placement=structure_placement".
    05 FILLER PIC X(24) VALUE "structure_selection".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R structure=structure;I weight=1..".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(600) VALUE "I spacing=0..4096;I separation=0..4096;I salt=0..;e spread_type=linear|triangular;n frequency=0..1;a locate_offset;s frequency_reduction_method;o exclusion_zone".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 22.
 01 WS-FEATURE             PIC X(48) VALUE "worldgen/feature".
 01 WS-FEATURE-GROUP       PIC X(24) VALUE "feature".
 01 WS-PLACED              PIC X(48) VALUE "worldgen/placed_feature".
 01 WS-PLACED-GROUP        PIC X(24) VALUE "placed_feature".
 01 WS-STRUCTURE           PIC X(48) VALUE "worldgen/structure".
 01 WS-STRUCTURE-GROUP     PIC X(24) VALUE "structure".
 01 WS-SET                 PIC X(48) VALUE "worldgen/structure_set".
 01 WS-SET-GROUP           PIC X(24) VALUE "structure_set".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-S3                  BINARY-LONG.
 01 WS-S4                  BINARY-LONG.
 01 WS-S5                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "DIMENSION-TYPES-LOAD" USING L-DIR WS-S1
     CALL "NOISE-SETTINGS-LOAD" USING L-DIR WS-S2
     CALL "MATERIAL-RULES-LOAD" USING L-DIR WS-S3
     CALL "DENSITY-FUNCTIONS-LOAD" USING L-DIR WS-S4
     CALL "BIOMES-LOAD" USING L-DIR WS-S5
     COMPUTE L-STATUS = FUNCTION MAX(WS-S1 WS-S2 WS-S3 WS-S4 WS-S5)
     IF L-STATUS = CT-OK
         CALL "SHAPE-BEGIN"
         CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
         CALL "SHAPE-LOAD" USING L-DIR WS-FEATURE WS-FEATURE-GROUP WS-LENIENT
         CALL "SHAPE-LOAD" USING L-DIR WS-PLACED WS-PLACED-GROUP WS-LENIENT
         CALL "SHAPE-LOAD" USING L-DIR WS-STRUCTURE WS-STRUCTURE-GROUP WS-LENIENT
         CALL "SHAPE-LOAD" USING L-DIR WS-SET WS-SET-GROUP WS-LENIENT
         CALL "SHAPE-END" USING L-STATUS
     END-IF
     IF L-STATUS NOT = CT-OK
         CALL "WORLDGEN-FREE"
     END-IF
     GOBACK.
 END PROGRAM LOAD-38.
