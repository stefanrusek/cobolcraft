*> Tint sources (docs/protocol/43-tint-sources.md). Colours are ARGB in a BINARY-DOUBLE (0 to
*> 4294967295); opaque white FFFFFFFF is the document's -1 (no effect).
*> TINT-STATE is the colour data a loaded pack and the biome registry fill: the three colormaps
*> (raw ARGB pixels, row-major, index y * 256 + x + 1; all zero before a pack is loaded, section 3.1)
*> and the biome table (index = biome id + 1). TB-GRASS, TB-FOLIAGE and TB-DRY hold -1 when the biome
*> has no override; TB-MOD is 0 none, 1 dark_forest, 2 swamp.
 78 TS-NONE                 VALUE 0.
 78 TS-CONSTANT             VALUE 1.
 78 TS-CONSTANT-2           VALUE 2.
 78 TS-GRASS                VALUE 3.
 78 TS-GRASS-BLOCK          VALUE 4.
 78 TS-DOUBLE-TALL-GRASS    VALUE 5.
 78 TS-SUGAR-CANE           VALUE 6.
 78 TS-FOLIAGE              VALUE 7.
 78 TS-DRY-FOLIAGE          VALUE 8.
 78 TS-WATER                VALUE 9.
 78 TS-WATER-PARTICLES      VALUE 10.
 78 TS-REDSTONE             VALUE 11.
 78 TS-STEM                 VALUE 12.
 01 TINT-STATE EXTERNAL.
    05 TT-MAP-GRASS         BINARY-DOUBLE OCCURS 65536 TIMES.
    05 TT-MAP-FOLIAGE       BINARY-DOUBLE OCCURS 65536 TIMES.
    05 TT-MAP-DRY           BINARY-DOUBLE OCCURS 65536 TIMES.
    05 TT-BIOMES            BINARY-LONG.
    05 TT-PLAINS            BINARY-LONG.    *> biome id of minecraft:plains (the uncached biome, section 4)
    05 TT-BIOME             OCCURS 255 TIMES.
       10 TB-TEMP           COMP-1.
       10 TB-DOWN           COMP-1.
       10 TB-WATER          BINARY-DOUBLE.
       10 TB-GRASS          BINARY-DOUBLE.
       10 TB-FOLIAGE        BINARY-DOUBLE.
       10 TB-DRY            BINARY-DOUBLE.
       10 TB-MOD            BINARY-LONG.
