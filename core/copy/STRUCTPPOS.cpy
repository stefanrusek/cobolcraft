*> The positions a processor sees (docs/protocol/36-structures-2 section 7.1): the absolute position of the record being processed (PP-X..PP-Z), its template-local position
*> before any processing (PP-LX..PP-LZ) and the anchor (PP-AX..PP-AZ), the second position of placeInWorld.
 01 STRUCT-PPOS.
    05 PP-X                 BINARY-LONG.
    05 PP-Y                 BINARY-LONG.
    05 PP-Z                 BINARY-LONG.
    05 PP-LX                BINARY-LONG.
    05 PP-LY                BINARY-LONG.
    05 PP-LZ                BINARY-LONG.
    05 PP-AX                BINARY-LONG.
    05 PP-AY                BINARY-LONG.
    05 PP-AZ                BINARY-LONG.
