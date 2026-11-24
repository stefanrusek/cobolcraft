*> The nether fortress being generated (docs/protocol/36-structures-8-nether-and-end.md sections 2 to 4; core/src/struct-fortress.cob). EXTERNAL, core-private, one start at a time.
*> The pieces are in the pieces builder (STRUCTPIECE.cpy: SP-TYPE the registry id of 36-1 2.4, 4 NeBCr to 18 NeStart; SP-ORIENT the 2D data value 0 south, 1 west, 2 north, 3 east; SP-F1 the seed of a
*> bridge end filler or the chest flag of a turn piece). FO-ENT are the 13 table entries (1 to 6 the bridge table, 7 to 13 the castle table, in table order) with the placeCount, allowInRow and whether the
*> entry is still in its available list; FO-PREV is the previousPiece entry (0 none); FO-PEND the pendingChildren (builder rows); FO-SX and FO-SZ the start box's minimum x and z.
 01 STRUCT-FORTRESS EXTERNAL.
    05 FO-ENT OCCURS 13 TIMES.
       10 FE-TYPE          BINARY-LONG.
       10 FE-WEIGHT        BINARY-LONG.
       10 FE-MAX           BINARY-LONG.
       10 FE-PLACED        BINARY-LONG.
       10 FE-ROW           BINARY-LONG.
       10 FE-LIVE          BINARY-LONG.
    05 FO-PREV             BINARY-LONG.
    05 FO-PEND-N           BINARY-LONG.
    05 FO-SX               BINARY-LONG.
    05 FO-SZ               BINARY-LONG.
    05 FO-PEND             BINARY-LONG OCCURS 1024 TIMES.
