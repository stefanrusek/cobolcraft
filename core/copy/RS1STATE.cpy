*> Working state of the piston structure resolver (redstone-30-3.cob, docs 30 part 3 section 4): shared by RS1-PISTON-RESOLVE, RS1-PSR-LINE and RS1-PSR-BRANCH.
*> The grid is 16 x 16 x 16 cells of kind codes (0 air, 1 stone, 2 slime, 3 honey, 4 obsidian, 5 torch, 6 glazed terracotta, 7 piston, 8 extended piston, 9 chest, 10 bedrock);
*> a cell is addressed as (y - 1) * 256 + (z - 1) * 16 + x with x, y, z from 1.
 01 RSV-STATE EXTERNAL.
    05 RSV-GRID            BINARY-LONG OCCURS 4096 TIMES.
    05 RSV-PX              BINARY-LONG.
    05 RSV-PY              BINARY-LONG.
    05 RSV-PZ              BINARY-LONG.
    05 RSV-PUSHDIR         BINARY-LONG.
    05 RSV-MINY            BINARY-LONG.
    05 RSV-MAXY            BINARY-LONG.
    05 RSV-NPUSH           BINARY-LONG.
    05 RSV-PUSH            BINARY-LONG OCCURS 64 TIMES.
    05 RSV-NDEST           BINARY-LONG.
    05 RSV-DEST            BINARY-LONG OCCURS 64 TIMES.
