*> The work area of the tree feature (core/src/feat-tree.cob FR-TREE and the placers of feat-tree-trunk.cob and feat-tree-foliage.cob): the positions of the logs, leaves and soil block of the
*> tree being built, held in a grid around its origin (grid cell = position - origin + TW-OX in x and z, y - origin y + TW-OY (17: roots reach 16 below); a position on the outermost layer of the grid is outside it, so
*> every cell used has all six neighbours in the table; TW-GRID 0 empty, 1 log, 2 leaf) so that nothing is written to the level until the whole tree is known to fit the chunk.
*> TW-LS the log indices in the order of the decorator context (sorted by y, stable), TW-SH their shuffled copy, TW-LFS the leaf indices sorted likewise. TW-FC the branch list of the fancy trunk (attachment and the base height of its branch). TW-ATT is the list of foliage attachments the trunk placer returned (position, radius offset, double trunk flag). EXTERNAL.
 78 TW-OX                 VALUE 10.
 78 TW-GX                 VALUE 21.
 78 TW-GY                 VALUE 56.
 78 TW-OY                 VALUE 17.
 78 TW-GZ                 VALUE 21.
 78 TW-CELLS              VALUE 24696.
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
    05 TW-CGT-START          BINARY-LONG.
    05 TW-CGT-N              BINARY-LONG.
    05 TW-NRL                BINARY-LONG.
    05 TW-RL OCCURS 160 TIMES.
       10 TW-RL-X            BINARY-LONG.
       10 TW-RL-Y            BINARY-LONG.
       10 TW-RL-Z            BINARY-LONG.
    05 TW-REPL-START         BINARY-LONG.
    05 TW-REPL-N             BINARY-LONG.
    05 TW-LOGS-START         BINARY-LONG.
    05 TW-LOGS-N             BINARY-LONG.
    05 TW-LOG OCCURS 2048 TIMES.
       10 TW-LOG-X           BINARY-LONG.
       10 TW-LOG-Y           BINARY-LONG.
       10 TW-LOG-Z           BINARY-LONG.
       10 TW-LOG-A           BINARY-LONG.
    05 TW-LS                BINARY-LONG OCCURS 2048 TIMES.
    05 TW-SH                BINARY-LONG OCCURS 2048 TIMES.
    05 TW-LFS               BINARY-LONG OCCURS 24696 TIMES.
    05 TW-ATT OCCURS 256 TIMES.
       10 TW-ATT-X           BINARY-LONG.
       10 TW-ATT-Y           BINARY-LONG.
       10 TW-ATT-Z           BINARY-LONG.
       10 TW-ATT-R           BINARY-LONG.
       10 TW-ATT-D           BINARY-LONG.
    05 TW-LEAF OCCURS 24696 TIMES.
       10 TW-LEAF-X          BINARY-LONG.
       10 TW-LEAF-Y          BINARY-LONG.
       10 TW-LEAF-Z          BINARY-LONG.
       10 TW-LEAF-S          BINARY-LONG.
    05 TW-LP-START           BINARY-LONG.
    05 TW-LP-N               BINARY-LONG.
    05 TW-LP-TOTAL           BINARY-LONG.
    05 TW-LEAF-STATE0        BINARY-LONG.
    05 TW-LEAFAT             BINARY-LONG OCCURS 24696 TIMES.
    05 TW-GRIDS.
       10 TW-GRID            PIC 9 OCCURS 24696 TIMES.
    05 TW-DISTS.
       10 TW-DIST            PIC 9 OCCURS 24696 TIMES.
    05 TW-QUEUE              BINARY-LONG OCCURS 24760 TIMES.
*> Tree decorators of feat-tree-deco2.cob: TW-SHL the shuffled copy of the sorted leaf list, TW-RS the root indices sorted by y, TW-LL the lowest layer of getLowestTrunkOrRootOfTree (TW-NLL positions), TW-XC the
*> exclusion centres of attached_to_leaves, TW-CAND the beehive candidates.
    05 TW-SHL               BINARY-LONG OCCURS 24696 TIMES.
    05 TW-RS                BINARY-LONG OCCURS 160 TIMES.
    05 TW-NLL               BINARY-LONG.
    05 TW-LL OCCURS 2400 TIMES.
       10 TW-LL-X           BINARY-LONG.
       10 TW-LL-Y           BINARY-LONG.
       10 TW-LL-Z           BINARY-LONG.
    05 TW-NXC               BINARY-LONG.
    05 TW-XC OCCURS 1024 TIMES.
       10 TW-XC-X           BINARY-LONG.
       10 TW-XC-Y           BINARY-LONG.
       10 TW-XC-Z           BINARY-LONG.
    05 TW-NCAND             BINARY-LONG.
    05 TW-CAND OCCURS 2048 TIMES.
       10 TW-CAND-X         BINARY-LONG.
       10 TW-CAND-Y         BINARY-LONG.
       10 TW-CAND-Z         BINARY-LONG.
