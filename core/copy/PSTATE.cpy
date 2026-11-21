*> Working state of the live piston code (core/src/piston-live.cob; docs/protocol/30-redstone-3-pistons.md): the structure resolver's lists (section 4: toPush and toDestroy, the cells in list order)
*> and the ids resolved from the open block table once per CB-EPOCH (the sticky blocks of 4.5). PS-IN-TICK is 1 while the level handles its tick (WORLDSIM-TICK: the
*> block ticks, the chunk tick and the block events; level.isHandlingTick(), 2.3).
 01 PST-STATE EXTERNAL.
    05 PS-EPOCH             BINARY-LONG.
    05 PS-SLIME             BINARY-LONG.
    05 PS-HONEY             BINARY-LONG.
    05 PS-IN-TICK           BINARY-LONG.
    05 PS-DIM               BINARY-LONG.
    05 PS-PX                BINARY-LONG.
    05 PS-PY                BINARY-LONG.
    05 PS-PZ                BINARY-LONG.
    05 PS-PUSHDIR           BINARY-LONG.
    05 PS-NPUSH             BINARY-LONG.
    05 PS-P OCCURS 64 TIMES.
       10 PS-P-X            BINARY-LONG.
       10 PS-P-Y            BINARY-LONG.
       10 PS-P-Z            BINARY-LONG.
    05 PS-NDEST             BINARY-LONG.
    05 PS-D OCCURS 64 TIMES.
       10 PS-D-X            BINARY-LONG.
       10 PS-D-Y            BINARY-LONG.
       10 PS-D-Z            BINARY-LONG.
