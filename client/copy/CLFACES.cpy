*> The face classes of the state tables while they are built (state-tables.cob): the distinct 16 x 16 masks of block faces, and the
*> class of each shape's six faces. EXTERNAL, shared by STATE-FACES-* and STATE-TABLES-BUILD.
*>   SF-COUNT      classes in use (class 1 is the whole face, 2 the empty face); SF-MASK(c) the mask, 256 characters "0" or "1", row (second
*>                 coordinate) times 16 plus column (first), 1 based; the columns run along x (down, up, north, south) or z (west, east),
*>                 the rows along z (down, up) or y
*>   SF-DONE       1 when the shape s + 1 has its classes: SF-OWN(s + 1, d) and SF-NB(s + 1, d), d = DIR-DOWN to DIR-EAST (the face toward d)
 01 SF-STORE EXTERNAL.
    05 SF-COUNT           BINARY-LONG.
    05 SF-MASK            PIC X(256) OCCURS 300 TIMES.
    05 SF-DONE            PIC 9 OCCURS 2000 TIMES.
    05 SF-SHAPE OCCURS 2000 TIMES.
       10 SF-FACE OCCURS 6 TIMES.
          15 SF-OWN       BINARY-SHORT UNSIGNED.
          15 SF-NB        BINARY-SHORT UNSIGNED.
