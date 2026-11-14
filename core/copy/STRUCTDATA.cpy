*> The compiled structure data of the standard world (core/src/struct-data.cob compiles the JSON of worldgen/structure_set and worldgen/structure elements, and
*> the biome tags they name, from <dir>/data/<namespace>/...; core/src/struct-36-1.cob holds the placement engines; docs/protocol/36-structures-1 sections 2 to 5).
*> EXTERNAL, core-private. A set (SS) is a placement and a run of entries; an entry (SE) a structure and a weight; a structure (ST) its type, step, terrain
*> adaptation and a run of biome keys (a tag is expanded when loaded); the biome pool (SD-BIOME) holds the biome keys of structures and of preferred_biomes.
*> Ids are the registration indexes of 36-1 section 2 (STRUCT-ENUM-ID); spawn_overrides are read and left out (section 10 is a later sub-batch).
 78 SD-MAX-SETS          VALUE 64.
 78 SD-MAX-ENTRIES       VALUE 512.
 78 SD-MAX-STRUCTS       VALUE 128.
 78 SD-MAX-BIOMES        VALUE 8192.
 78 SD-MAX-RINGS         VALUE 4.
 78 SD-MAX-RING-POS      VALUE 256.
 78 SD-MAX-GATE          VALUE 64.
 78 SD-MAX-STARTS        VALUE 64.
 01 STRUCT-DATA EXTERNAL.
*>  SD-BAD: elements the schema rejected (left out); SD-POSS-DONE 1 once SS-POSSIBLE was built for the loaded sets; SD-STARTS-SEEN: starts the generation hook made
    05 SD-DIR               PIC X(1100).
    05 SD-BAD               BINARY-LONG.
    05 SD-SET-COUNT         BINARY-LONG.
    05 SD-EN-COUNT          BINARY-LONG.
    05 SD-ST-COUNT          BINARY-LONG.
    05 SD-BIOME-COUNT       BINARY-LONG.
    05 SD-RING-COUNT        BINARY-LONG.
    05 SD-POSS-DONE         BINARY-LONG.
    05 SD-STARTS-SEEN       BINARY-LONG.
    05 SD-GATE-COUNT        BINARY-LONG.
    05 SD-START-COUNT       BINARY-LONG.
*>  the biomes of the tag minecraft:mineshaft_blocking (a run of SD-BIOME, read by STRUCT-LOAD), ST-VARIANT the mineshaft_type of a structure (0 normal, 1 mesa)
    05 SD-BLOCK-FIRST       BINARY-LONG.
    05 SD-BLOCK-COUNT       BINARY-LONG.
*>  SS-KIND 0 concentric_rings, 1 dimension_origin, 2 random_spread (the placement registry ids); SS-SPREAD 0 linear 1 triangular; SS-METHOD the frequency reduction
*>  method id; SS-EX-SET the set index of the exclusion zone (0 none) and SS-EX-COUNT its chunk_count; SS-RING-ROW the row of SD-RING built for the set (0 none);
*>  SS-POSSIBLE 1 when a structure of the set has a biome the source can make (4.1)
    05 SD-SET OCCURS 64 TIMES.
       10 SS-KEY            PIC X(80).
       10 SS-KIND           BINARY-LONG.
       10 SS-SPACING        BINARY-LONG.
       10 SS-SEPARATION     BINARY-LONG.
       10 SS-SPREAD         BINARY-LONG.
       10 SS-SALT           BINARY-LONG.
       10 SS-LOC-X          BINARY-LONG.
       10 SS-LOC-Y          BINARY-LONG.
       10 SS-LOC-Z          BINARY-LONG.
       10 SS-METHOD         BINARY-LONG.
       10 SS-FREQ           FLOAT-LONG.
       10 SS-EX-KEY         PIC X(80).
       10 SS-EX-SET         BINARY-LONG.
       10 SS-EX-COUNT       BINARY-LONG.
       10 SS-DISTANCE       BINARY-LONG.
       10 SS-RING-SPREAD    BINARY-LONG.
       10 SS-RING-COUNT     BINARY-LONG.
       10 SS-PREF-FIRST     BINARY-LONG.
       10 SS-PREF-COUNT     BINARY-LONG.
       10 SS-EN-FIRST       BINARY-LONG.
       10 SS-EN-COUNT       BINARY-LONG.
       10 SS-RING-ROW       BINARY-LONG.
       10 SS-POSSIBLE       BINARY-LONG.
    05 SD-ENTRY OCCURS 512 TIMES.
       10 SE-STRUCT         BINARY-LONG.
       10 SE-WEIGHT         BINARY-LONG.
    05 SD-STRUCT OCCURS 128 TIMES.
       10 ST-KEY            PIC X(80).
       10 ST-TYPE           BINARY-LONG.
       10 ST-STEP           BINARY-LONG.
       10 ST-ADAPT          BINARY-LONG.
       10 ST-BIOME-FIRST    BINARY-LONG.
       10 ST-BIOME-COUNT    BINARY-LONG.
       10 ST-VARIANT        BINARY-LONG.
    05 SD-BIOME             PIC X(40) OCCURS 8192 TIMES.
*>  the ring list of a concentric_rings set for one seed: SR-SEED the world seed it was built for (SR-SET 0 = unused row), SR-N chunks SR-X, SR-Z
    05 SD-RING OCCURS 4 TIMES.
       10 SR-SET            BINARY-LONG.
       10 SR-SEED           BINARY-DOUBLE.
       10 SR-N              BINARY-LONG.
       10 SR-X              BINARY-LONG OCCURS 256 TIMES.
       10 SR-Z              BINARY-LONG OCCURS 256 TIMES.
*>  the gate: structure ids that are on (STRUCT-GATE); empty after a reset, so no structure starts anything
    05 SD-GATE              PIC X(80) OCCURS 64 TIMES.
*>  the starts of the chunk last asked (STRUCT-CHUNK-STARTS): the set and structure rows and the stub position
    05 SD-START OCCURS 64 TIMES.
       10 SC-SET            BINARY-LONG.
       10 SC-STRUCT         BINARY-LONG.
       10 SC-X              BINARY-LONG.
       10 SC-Y              BINARY-LONG.
       10 SC-Z              BINARY-LONG.
