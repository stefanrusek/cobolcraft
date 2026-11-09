*> The loader of docs/protocol/37-nether-6...md (37-nether-6 sections 2 and 3): the Nether structure sets and structure
*> definitions. LOAD-37-6 USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA when
*> any file is rejected; every error is printed on standard error as 'ERROR registry: <registry> <key>: <detail>' and
*> nothing of the part stays loaded).
*> The files of worldgen/structure_set, worldgen/structure are read through the registry loader and JSON-STRICT (SHAPE-
*> LOAD, shapes.cob) and checked against the type rows below (the field list forms of CTSHAPE.cpy). Constraints the shape
*> forms cannot state are noted in the test.
*> NOTE: The enum member lists of step (11 names), terrain_adaptation (5) and the setup placement (6) are longer than the
*> 40 bytes of an enum argument of the shape engine, so they are checked as identifiers only (form D).
*> ASSUMPTION: random_spread placement members locate_offset (array of 3 numbers, unchecked beyond being an array),
*> exclusion_zone (object) and frequency (number 0 to 1) are optional; the document names them but gives no shapes.
*> ASSUMPTION: the structure member project_start_to_heightmap is a string (heightmap type name); spawn_overrides and
*> pool_aliases are only checked as an object and an array.
*> ASSUMPTION: a structure set entry has members structure (identifier) and weight (integer, at least 1), both required.
*> ASSUMPTION: random_spread spacing is 1 to 4096 and separation 0 to 4096; the rule spacing > separation is not checked
*> by the shape engine.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-37-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "structure_set".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "L structures=structure_set_entry;T placement=structure_placement                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure_set_entry".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D structure;I weight=1..                                                                            ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure_placement".
    05 FILLER PIC X(48) VALUE "random_spread".
    05 FILLER PIC X(100) VALUE "I spacing=1..4096;I separation=0..4096;I salt;e spread_type=linear|triangular;a locate_offset;o excl".
    05 FILLER PIC X(100) VALUE "usion_zone;n frequency=0..1                                                                         ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(100) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation                                        ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(100) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;D start_pool;d start_jigsaw_name;I size".
    05 FILLER PIC X(100) VALUE "=0..20;X start_height;B use_expansion_hack;s project_start_to_heightmap;V max_distance_from_center=m".
    05 FILLER PIC X(100) VALUE "ax_distance;a pool_aliases;e liquid_settings=apply_waterlogging|ignore_waterlogging                 ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "max_distance".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "I horizontal=1..128;i vertical=1..4064                                                              ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(100) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;L setups=ruined_portal_setup           ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "ruined_portal_setup".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(100) VALUE "D placement;N air_pocket_probability=0..1;N mossiness=0..1;B overgrown;B vines;B can_be_cold;B repla".
    05 FILLER PIC X(100) VALUE "ce_with_blackstone;N weight=0..                                                                     ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(24) VALUE "structure".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(100) VALUE "H biomes=biome;D step;o spawn_overrides;d terrain_adaptation;V height=height_provider               ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
    05 FILLER PIC X(100) VALUE "                                                                                                    ".
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
