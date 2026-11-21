*> The one cell and chunk layout of the standard and the cobolcraft world types (specs/002-client-polish/
*> data-model.md section 4; docs/protocol/06-chunk-format.md; T0053). It replaces core's CHUNKMEM.cpy
*> and the client's CLCELLS.cpy; core and client adopt it in their own lanes. Copybook only.
*> Contract artifact (constitution 3.3): not edited by lanes.
*>
*> A chunk column is one block of CE-CHUNK-BYTES bytes (CE-CHUNK BASED, addressed through a POINTER
*> the owner allocates). Geometry comes from the dimension (CE-DIMENSION): section count =
*> height / 16, from min_y; the buffer is sized for the tallest dimension (CE-MAX-SECTIONS).
*>
*> States: one cell is 2 bytes (unsigned, native little-endian, state ids to about 30,000). Cell
*> index (y - min_y) * 256 + z * 16 + x + 1 (x, z local 0 to 15), so block section s (0 = lowest)
*> holds cells s * 4096 + 1 to (s + 1) * 4096, already in the entry order of 06 section 5.4.
*>
*> Light: 4 bits per cell, one array of 2048 bytes per light section (06 section 7.1: byte index
*> (y*256 + z*16 + x) div 2, even cell in the low nibble). Light section i = 0 to section count + 1 is
*> the section (min section Y - 1 + i), so the arrays go to the wire unchanged. Byte index of light
*> section i, cell n (0 to 4095): i * 2048 + n div 2 + 1. Sky and block light are two such tables.
*>
*> Biomes: one byte per 4 x 4 x 4 cell (the synchronized biome id), 64 per section in the entry order
*> of 06 section 5.4: index s * 64 + (y mod 16 div 4) * 16 + (z div 4) * 4 + (x div 4) + 1.

 78 CE-MAX-SECTIONS        VALUE 24.      *> the tallest dimension (overworld: 384 / 16)
 78 CE-MAX-LIGHT-SECTIONS  VALUE 26.      *> CE-MAX-SECTIONS + 2
 78 CE-SECTION-CELLS       VALUE 4096.
 78 CE-LIGHT-BYTES         VALUE 2048.    *> per light section
 78 CE-BIOME-CELLS         VALUE 64.      *> per section
 78 CE-STATE-CELLS         VALUE 98304.   *> CE-MAX-SECTIONS * 4096
 78 CE-SKY-BYTES           VALUE 53248.   *> CE-MAX-LIGHT-SECTIONS * 2048
 78 CE-BLOCK-LIGHT-BYTES   VALUE 53248.
 78 CE-BIOME-BYTES         VALUE 1536.    *> CE-MAX-SECTIONS * 64
 78 CE-CHUNK-BYTES         VALUE 304640.  *> 2 * 98304 + 53248 + 53248 + 1536
 78 CE-DIMENSIONS          VALUE 3.       *> overworld, nether, end
 78 CE-DIM-OVERWORLD       VALUE 0.
 78 CE-DIM-NETHER          VALUE 1.
 78 CE-DIM-END             VALUE 2.

 01 CE-CHUNK BASED.
    05 CE-STATES             PIC X(196608).
    05 CE-STATE-TABLE REDEFINES CE-STATES.
       10 CE-STATE           BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
    05 CE-SKYS               PIC X(53248).
    05 CE-SKY-TABLE REDEFINES CE-SKYS.
       10 CE-SKY             BINARY-CHAR UNSIGNED OCCURS 53248 TIMES.
    05 CE-BLOCK-LIGHTS       PIC X(53248).
    05 CE-BLOCK-LIGHT-TABLE REDEFINES CE-BLOCK-LIGHTS.
       10 CE-BLOCK-LIGHT     BINARY-CHAR UNSIGNED OCCURS 53248 TIMES.
    05 CE-BIOMES             PIC X(1536).
    05 CE-BIOME-TABLE REDEFINES CE-BIOMES.
       10 CE-BIOME           BINARY-CHAR UNSIGNED OCCURS 1536 TIMES.

*> The geometry of one dimension, filled from its dimension type (04 section 6, 23 section 7.3.3).
*> Standard values: overworld min_y -64 height 384 (24 sections), nether and end min_y 0 height 256
*> (16 sections); the cobolcraft types are cobolcraft:surface min_y 0 height 256 and
*> cobolcraft:sunless (data-model section 4, world-types.md).
 01 CE-DIMENSION.
    05 CE-DIM-MIN-Y          BINARY-LONG.
    05 CE-DIM-HEIGHT         BINARY-LONG.   *> a multiple of 16, at most 384
    05 CE-DIM-SECTIONS       BINARY-LONG.   *> height div 16, at most CE-MAX-SECTIONS
    05 CE-DIM-MIN-SECTION    BINARY-LONG.   *> min_y div 16 (arithmetic)
    05 CE-DIM-SKY-LIGHT      PIC 9.         *> 1 = the dimension has sky light
