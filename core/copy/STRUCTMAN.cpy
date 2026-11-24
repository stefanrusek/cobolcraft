*> The woodland mansion being generated (docs/protocol/36-structures-7-woodland-mansion.md sections 4 to 6; core/src/struct-mansion.cob, struct-man-place.cob). EXTERNAL, core-private, one start at a time.
*> MN-G holds the five 11 by 11 grids, cell (x, y) at index y * 11 + x + 1: 1 the base grid, 2 the third-floor grid, 3 to 5 the room codes of floors 0 to 2 (4.1, 4.2). A cell outside the grid reads 5.
*> Directions are 0 north, 1 east, 2 south, 3 west (HORIZONTAL order); a rotation is the number of clockwise quarter turns (0 to 3), so R.rotate(d) is (d + R) mod 4. Mirror codes 0 none, 1 left-right, 2 front-back.
*> MN-C are the three outer-wall cursors (6.3): position, rotation and the wall type (0 wall_flat, 1 wall_window).
*> MN-ENTRY is the piece layout in emission order (6.2): the template name (without the woodland_mansion/ directory), the position, the rotation and the mirror. MN-LOST counts the entries over the table.
 78 MN-LIST-MAX          VALUE 1500.
 01 STRUCT-MANSION EXTERNAL.
    05 MN-G OCCURS 5 TIMES.
       10 MN-CELL          BINARY-LONG OCCURS 121 TIMES.
    05 MN-COUNT            BINARY-LONG.
    05 MN-LOST             BINARY-LONG.
    05 MN-ROT              BINARY-LONG.
    05 MN-OX               BINARY-LONG.
    05 MN-OY               BINARY-LONG.
    05 MN-OZ               BINARY-LONG.
    05 MN-C OCCURS 3 TIMES.
       10 MN-CX            BINARY-LONG.
       10 MN-CY            BINARY-LONG.
       10 MN-CZ            BINARY-LONG.
       10 MN-CROT          BINARY-LONG.
       10 MN-CWALL         BINARY-LONG.
    05 MN-ENTRY OCCURS 1500 TIMES.
       10 ME-NAME          PIC X(24).
       10 ME-X             BINARY-LONG.
       10 ME-Y             BINARY-LONG.
       10 ME-Z             BINARY-LONG.
       10 ME-ROT           BINARY-LONG.
       10 ME-MIR           BINARY-LONG.
