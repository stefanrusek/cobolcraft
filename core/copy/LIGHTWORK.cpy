*> The work area of the block light engine (core/src/light.cob): the 3 x 3 chunks around the chunk being lit or changed (entry (dz + 1) * 3 +
*> dx + 2, 0 for a chunk that is not loaded or not lit), the queue of cells to raise by level (LW-HEAD per level 1 to 15, linked through
*> LW-E-NEXT; a cell is a position (y * 48 + z) * 48 + x in the 48 x 48 square of those chunks), the queue of the removal pass, and the number
*> of cells the engine touched (LW-CELLS: written or expanded; the caller sets it to 0 to count).
*> LW-E: every cell is raised at most once by the relaxation, plus at most two seeds each: 884736 cells of the square and 98304 + 24576 seeds.
 01 LW-STATE EXTERNAL.
    05 LW-DIM                BINARY-LONG.
    05 LW-TOP                BINARY-LONG.
    05 LW-CELLS              BINARY-LONG.
    05 LW-R3                 BINARY-LONG OCCURS 9 TIMES.
    05 LW-HEAD               BINARY-LONG OCCURS 15 TIMES.
    05 LW-EN                 BINARY-LONG.
    05 LW-RHEAD              BINARY-LONG.
    05 LW-RTAIL              BINARY-LONG.
    05 LW-RQ OCCURS 16384 TIMES.
       10 LW-RQ-POS          BINARY-LONG.
       10 LW-RQ-LEVEL        BINARY-LONG.
    05 LW-E OCCURS 1100000 TIMES.
       10 LW-E-POS           BINARY-LONG.
       10 LW-E-NEXT          BINARY-LONG.
