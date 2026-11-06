*> BASED view of one replica chunk row's cells (CLSTATE.cpy WR-ADDR points to 3 x 65536 + 1024
*> bytes; client/src/world-replica.cob): cell index y * 256 + z * 16 + x + 1 (x, z local 0 to 15, y
*> from the dimension's min_y); each cell is one unsigned byte: the block state id, the sky light
*> level, the block light level. Then the biome ids of the 4 x 4 x 4 biome cells (06 §5.4), index
*> (y div 4) * 16 + (z div 4) * 4 + (x div 4) + 1. A program needing two views COPYs it again
*> REPLACING LEADING ==RC-==.
 01 RC-CHUNK BASED.
    05 RC-STATES             PIC X(65536).
    05 RC-STATE-TABLE REDEFINES RC-STATES.
       10 RC-STATE           BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
    05 RC-SKYS               PIC X(65536).
    05 RC-SKY-TABLE REDEFINES RC-SKYS.
       10 RC-SKY             BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
    05 RC-BLOCKS             PIC X(65536).
    05 RC-BLOCK-TABLE REDEFINES RC-BLOCKS.
       10 RC-BLOCK           BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
    05 RC-BIOMES             PIC X(1024).
    05 RC-BIOME-TABLE REDEFINES RC-BIOMES.
       10 RC-BIOME           BINARY-CHAR UNSIGNED OCCURS 1024 TIMES.
