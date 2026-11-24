*> The biome source the structure code reads (core/src/struct-36-1.cob STRUCT-BIOME-AT): SDM-KIND 0 the overworld's multi-noise source (the default), 1 the Nether's (NETHER-STRUCT-BIOME-AT),
*> set by the dimension's structure stage (nether-struct.cob) around its starts. EXTERNAL, core-private.
 01 STRUCT-DIM EXTERNAL.
    05 SDM-KIND            BINARY-LONG.
