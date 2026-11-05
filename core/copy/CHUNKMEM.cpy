*> BASED view of one cached chunk's memory (CORESTATE.cpy CORE-CHUNKS: CK-ADDR points to
*> CORE-CHUNK-BYTES bytes). Cell index y * 256 + z * 16 + x (+ 1), x and z local 0 to 15, y 0 to 255;
*> each cell is one unsigned byte: the block state id (standin-content §1.2), the sky light level and
*> the block light level (0 to 15). The 4096 cells of block section s are cells s * 4096 + 1 to
*> (s + 1) * 4096, already in the entry order of 06 §5.4 and 06 §7.1. A program that needs two views
*> at once COPYs this book a second time REPLACING LEADING ==CM-== BY another prefix.
 01 CM-CHUNK BASED.
    05 CM-STATES             PIC X(65536).
    05 CM-STATE-TABLE REDEFINES CM-STATES.
       10 CM-STATE           BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
    05 CM-SKYS               PIC X(65536).
    05 CM-SKY-TABLE REDEFINES CM-SKYS.
       10 CM-SKY             BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
    05 CM-BLOCKS             PIC X(65536).
    05 CM-BLOCK-TABLE REDEFINES CM-BLOCKS.
       10 CM-BLOCK           BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
