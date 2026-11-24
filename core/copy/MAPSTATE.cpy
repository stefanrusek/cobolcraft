*> The saved map data of the world (docs/protocol/25-item-registry-5 sections 8.1 and 8.2; lane p70c, T23501): EXTERNAL. Per map id the scale (0 to 4), the locked flag, the centre and the dimension
*> index; the 128 x 128 colour bytes, the markers and the decorations are not kept (nothing in the core draws on a map yet). MP-NEXT is the counter of getFreeMapId (the next id), emptied with the world.
 01 CORE-MAPS EXTERNAL.
    05 MP-NEXT             BINARY-LONG.
    05 MP-COUNT            BINARY-LONG.
    05 MP-ENTRY OCCURS 256 TIMES.
       10 MP-ID            BINARY-LONG.
       10 MP-SCALE         BINARY-LONG.
       10 MP-LOCKED        BINARY-LONG.
       10 MP-CX            BINARY-LONG.
       10 MP-CZ            BINARY-LONG.
       10 MP-DIM           BINARY-LONG.
