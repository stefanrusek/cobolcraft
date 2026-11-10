*> The interpolation grids of one chunk (core/src/gen-stages.cob, core/src/density.cob): for each interpolated node of the
*> final density, the value of its input at the 5 x 5 x 49 cell corners of the chunk (x and z at 4-block steps from the chunk's
*> west and north edge, y at 8-block steps from -64), index ((i * 5 + j) * 49 + k) + 1 for corner x i, z j, y k.
*> Included at level 10, under a group (the job's GJ-GRID, density.cob's based DG-GRID).
          10 GJ-G-COUNT          BINARY-LONG.
          10 GJ-G-NODE           BINARY-LONG OCCURS 16 TIMES.
          10 GJ-G-VAL            FLOAT-LONG OCCURS 19600 TIMES.
