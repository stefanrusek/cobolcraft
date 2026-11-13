*> The work area of the tree feature (core/src/feat-tree.cob FR-TREE): the positions of the logs, leaves and soil block of the tree being built, held in a grid around its
*> origin (grid cell = position - origin + 7 in x and z, y - origin y + 1; TW-GRID 0 empty, 1 log, 2 leaf) so that nothing is written to the level until the whole tree is known to
*> fit the chunk. EXTERNAL.
 78 TW-GX                 VALUE 15.
 78 TW-GY                 VALUE 40.
 78 TW-GZ                 VALUE 15.
 01 TREE-WORK EXTERNAL.
    05 TW-X0                 BINARY-LONG.
    05 TW-Y0                 BINARY-LONG.
    05 TW-Z0                 BINARY-LONG.
    05 TW-OUT                BINARY-LONG.
    05 TW-NLOG               BINARY-LONG.
    05 TW-NLEAF              BINARY-LONG.
    05 TW-SOIL               BINARY-LONG.
    05 TW-SOIL-X             BINARY-LONG.
    05 TW-SOIL-Y             BINARY-LONG.
    05 TW-SOIL-Z             BINARY-LONG.
    05 TW-REPL-START         BINARY-LONG.
    05 TW-REPL-N             BINARY-LONG.
    05 TW-LOGS-START         BINARY-LONG.
    05 TW-LOGS-N             BINARY-LONG.
    05 TW-LOG OCCURS 64 TIMES.
       10 TW-LOG-X           BINARY-LONG.
       10 TW-LOG-Y           BINARY-LONG.
       10 TW-LOG-Z           BINARY-LONG.
    05 TW-LEAF OCCURS 1536 TIMES.
       10 TW-LEAF-X          BINARY-LONG.
       10 TW-LEAF-Y          BINARY-LONG.
       10 TW-LEAF-Z          BINARY-LONG.
    05 TW-GRID               PIC 9 OCCURS 9000 TIMES.
    05 TW-DIST               PIC 9 OCCURS 9000 TIMES.
    05 TW-QUEUE              BINARY-LONG OCCURS 1700 TIMES.
