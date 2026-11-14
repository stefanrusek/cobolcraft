*> The code-defined registries and enums of docs/protocol/36-structures-1 sections 2.2 to 2.5, in registration (declaration) order, one name per row (core/src/struct-36-1.cob
*> STRUCT-ENUM-ID, STRUCT-ENUM-NAME). EB-FIRST(kind) is the table row before the kind's first name, EB-COUNT(kind) its number of names. Kinds: 1 worldgen/structure_type (16),
*> 2 structure_placement (3), 3 structure_piece (56: the lower-case registry key), 4 TerrainAdjustment (5), 5 StructureSpawnOverride bounding box type (2), 6 RandomSpreadType (2),
*> 7 FrequencyReductionMethod (4), 8 GenerationStep.Decoration (11).
 01 ENUM-ROWS.
 05 FILLER PIC X(24) VALUE "buried_treasure".
 05 FILLER PIC X(24) VALUE "desert_pyramid".
 05 FILLER PIC X(24) VALUE "end_city".
 05 FILLER PIC X(24) VALUE "fortress".
 05 FILLER PIC X(24) VALUE "igloo".
 05 FILLER PIC X(24) VALUE "jigsaw".
 05 FILLER PIC X(24) VALUE "jungle_temple".
 05 FILLER PIC X(24) VALUE "mineshaft".
 05 FILLER PIC X(24) VALUE "nether_fossil".
 05 FILLER PIC X(24) VALUE "ocean_monument".
 05 FILLER PIC X(24) VALUE "ocean_ruin".
 05 FILLER PIC X(24) VALUE "ruined_portal".
 05 FILLER PIC X(24) VALUE "shipwreck".
 05 FILLER PIC X(24) VALUE "stronghold".
 05 FILLER PIC X(24) VALUE "swamp_hut".
 05 FILLER PIC X(24) VALUE "woodland_mansion".
 05 FILLER PIC X(24) VALUE "concentric_rings".
 05 FILLER PIC X(24) VALUE "dimension_origin".
 05 FILLER PIC X(24) VALUE "random_spread".
 05 FILLER PIC X(24) VALUE "mscorridor".
 05 FILLER PIC X(24) VALUE "mscrossing".
 05 FILLER PIC X(24) VALUE "msroom".
 05 FILLER PIC X(24) VALUE "msstairs".
 05 FILLER PIC X(24) VALUE "nebcr".
 05 FILLER PIC X(24) VALUE "nebef".
 05 FILLER PIC X(24) VALUE "nebs".
 05 FILLER PIC X(24) VALUE "neccs".
 05 FILLER PIC X(24) VALUE "nectb".
 05 FILLER PIC X(24) VALUE "nece".
 05 FILLER PIC X(24) VALUE "nescsc".
 05 FILLER PIC X(24) VALUE "nesclt".
 05 FILLER PIC X(24) VALUE "nesc".
 05 FILLER PIC X(24) VALUE "nescrt".
 05 FILLER PIC X(24) VALUE "necsr".
 05 FILLER PIC X(24) VALUE "nemt".
 05 FILLER PIC X(24) VALUE "nerc".
 05 FILLER PIC X(24) VALUE "nesr".
 05 FILLER PIC X(24) VALUE "nestart".
 05 FILLER PIC X(24) VALUE "shcc".
 05 FILLER PIC X(24) VALUE "shfc".
 05 FILLER PIC X(24) VALUE "sh5c".
 05 FILLER PIC X(24) VALUE "shlt".
 05 FILLER PIC X(24) VALUE "shli".
 05 FILLER PIC X(24) VALUE "shpr".
 05 FILLER PIC X(24) VALUE "shph".
 05 FILLER PIC X(24) VALUE "shrt".
 05 FILLER PIC X(24) VALUE "shrc".
 05 FILLER PIC X(24) VALUE "shsd".
 05 FILLER PIC X(24) VALUE "shstart".
 05 FILLER PIC X(24) VALUE "shs".
 05 FILLER PIC X(24) VALUE "shssd".
 05 FILLER PIC X(24) VALUE "tejp".
 05 FILLER PIC X(24) VALUE "orp".
 05 FILLER PIC X(24) VALUE "iglu".
 05 FILLER PIC X(24) VALUE "rupo".
 05 FILLER PIC X(24) VALUE "tesh".
 05 FILLER PIC X(24) VALUE "tedp".
 05 FILLER PIC X(24) VALUE "omb".
 05 FILLER PIC X(24) VALUE "omcr".
 05 FILLER PIC X(24) VALUE "omdxr".
 05 FILLER PIC X(24) VALUE "omdxyr".
 05 FILLER PIC X(24) VALUE "omdyr".
 05 FILLER PIC X(24) VALUE "omdyzr".
 05 FILLER PIC X(24) VALUE "omdzr".
 05 FILLER PIC X(24) VALUE "omentry".
 05 FILLER PIC X(24) VALUE "ompenthouse".
 05 FILLER PIC X(24) VALUE "omsimple".
 05 FILLER PIC X(24) VALUE "omsimplet".
 05 FILLER PIC X(24) VALUE "omwr".
 05 FILLER PIC X(24) VALUE "ecp".
 05 FILLER PIC X(24) VALUE "wmp".
 05 FILLER PIC X(24) VALUE "btp".
 05 FILLER PIC X(24) VALUE "shipwreck".
 05 FILLER PIC X(24) VALUE "nefos".
 05 FILLER PIC X(24) VALUE "jigsaw".
 05 FILLER PIC X(24) VALUE "none".
 05 FILLER PIC X(24) VALUE "bury".
 05 FILLER PIC X(24) VALUE "beard_thin".
 05 FILLER PIC X(24) VALUE "beard_box".
 05 FILLER PIC X(24) VALUE "encapsulate".
 05 FILLER PIC X(24) VALUE "piece".
 05 FILLER PIC X(24) VALUE "full".
 05 FILLER PIC X(24) VALUE "linear".
 05 FILLER PIC X(24) VALUE "triangular".
 05 FILLER PIC X(24) VALUE "default".
 05 FILLER PIC X(24) VALUE "legacy_type_1".
 05 FILLER PIC X(24) VALUE "legacy_type_2".
 05 FILLER PIC X(24) VALUE "legacy_type_3".
 05 FILLER PIC X(24) VALUE "raw_generation".
 05 FILLER PIC X(24) VALUE "lakes".
 05 FILLER PIC X(24) VALUE "local_modifications".
 05 FILLER PIC X(24) VALUE "underground_structures".
 05 FILLER PIC X(24) VALUE "surface_structures".
 05 FILLER PIC X(24) VALUE "strongholds".
 05 FILLER PIC X(24) VALUE "underground_ores".
 05 FILLER PIC X(24) VALUE "underground_decoration".
 05 FILLER PIC X(24) VALUE "fluid_springs".
 05 FILLER PIC X(24) VALUE "vegetal_decoration".
 05 FILLER PIC X(24) VALUE "top_layer_modification".
 01 ENUM-TABLE REDEFINES ENUM-ROWS.
    05 EN-NAME PIC X(24) OCCURS 99 TIMES.
 01 ENUM-BASES.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC 99 VALUE 56.
    05 FILLER PIC 99 VALUE 75.
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC 99 VALUE 80.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 82.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 84.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 88.
    05 FILLER PIC 99 VALUE 11.
 01 ENUM-BASE-TABLE REDEFINES ENUM-BASES.
    05 EB-KIND OCCURS 8 TIMES.
       10 EB-FIRST PIC 99.
       10 EB-COUNT PIC 99.
