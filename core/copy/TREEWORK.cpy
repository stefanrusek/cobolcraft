*> The work area of the tree feature (core/src/feat-tree.cob FR-TREE and the placers of feat-tree-trunk.cob and feat-tree-foliage.cob): the positions of the logs, leaves and soil block of the
*> tree being built, held in a grid around its origin (grid cell = position - origin + TW-OX in x and z, y - origin y + 1; a position on the outermost layer of the grid is outside it, so
*> every cell used has all six neighbours in the table; TW-GRID 0 empty, 1 log, 2 leaf) so that nothing is written to the level until the whole tree is known to fit the chunk.
*> TW-FC the branch list of the fancy trunk (attachment and the base height of its branch). TW-ATT is the list of foliage attachments the trunk placer returned (position, radius offset, double trunk flag). EXTERNAL.
 78 TW-OX                 VALUE 10.
 78 TW-GX                 VALUE 21.
 78 TW-GY                 VALUE 40.
 78 TW-GZ                 VALUE 21.
 78 TW-CELLS              VALUE 17640.
 01 TREE-WORK EXTERNAL.
    05 TW-X0                 BINARY-LONG.
    05 TW-Y0                 BINARY-LONG.
    05 TW-Z0                 BINARY-LONG.
    05 TW-OUT                BINARY-LONG.
    05 TW-NLOG               BINARY-LONG.
    05 TW-NLEAF              BINARY-LONG.
    05 TW-NATT               BINARY-LONG.
    05 TW-NSOIL              BINARY-LONG.
    05 TW-SOILP OCCURS 4 TIMES.
       10 TW-SOIL-X          BINARY-LONG.
       10 TW-SOIL-Y          BINARY-LONG.
       10 TW-SOIL-Z          BINARY-LONG.
    05 TW-LVS-START          BINARY-LONG.
    05 TW-LVS-N              BINARY-LONG.
    05 TW-NFC                BINARY-LONG.
    05 TW-FC OCCURS 64 TIMES.
       10 TW-FC-X            BINARY-LONG.
       10 TW-FC-Y            BINARY-LONG.
       10 TW-FC-Z            BINARY-LONG.
       10 TW-FC-B            BINARY-LONG.
    05 TW-REPL-START         BINARY-LONG.
    05 TW-REPL-N             BINARY-LONG.
    05 TW-LOGS-START         BINARY-LONG.
    05 TW-LOGS-N             BINARY-LONG.
    05 TW-LOG OCCURS 2048 TIMES.
       10 TW-LOG-X           BINARY-LONG.
       10 TW-LOG-Y           BINARY-LONG.
       10 TW-LOG-Z           BINARY-LONG.
       10 TW-LOG-A           BINARY-LONG.
    05 TW-ATT OCCURS 64 TIMES.
       10 TW-ATT-X           BINARY-LONG.
       10 TW-ATT-Y           BINARY-LONG.
       10 TW-ATT-Z           BINARY-LONG.
       10 TW-ATT-R           BINARY-LONG.
       10 TW-ATT-D           BINARY-LONG.
    05 TW-LEAF OCCURS 17640 TIMES.
       10 TW-LEAF-X          BINARY-LONG.
       10 TW-LEAF-Y          BINARY-LONG.
       10 TW-LEAF-Z          BINARY-LONG.
    05 TW-GRIDS.
       10 TW-GRID            PIC 9 OCCURS 17640 TIMES.
    05 TW-DISTS.
       10 TW-DIST            PIC 9 OCCURS 17640 TIMES.
    05 TW-QUEUE              BINARY-LONG OCCURS 17700 TIMES.
