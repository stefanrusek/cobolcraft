*> What PST-PUSH-ENTITIES (core/src/piston-push.cob) hands to PST-PUSH-ONE for each entity (docs/protocol/30-redstone-3-pistons.md section 8.1):
*>   PP-DIM the level; PP-SHAPE the collision shape id of the collision related state; PP-MDIR the movement direction (0 down, 1 up, 2 north, 3 south, 4 west, 5 east); PP-EXT extending;
*>   PP-SRC source piston; PP-SLIME the moved block is a slime block; PP-DELTA the progress step (0.5); PP-CELL the cell's corner; PP-OFF the offset of the block from its cell
*>   (step of the piston's facing times extendedProgress); PP-S the box that is searched (the shape's bounds shifted by the offset, with the movement area united: min x y z, max x y z).
 01 PP-ARG.
    05 PP-DIM               BINARY-LONG.
    05 PP-SHAPE             BINARY-LONG.
    05 PP-MDIR              BINARY-LONG.
    05 PP-EXT               BINARY-LONG.
    05 PP-SRC               BINARY-LONG.
    05 PP-SLIME             BINARY-LONG.
    05 PP-DELTA             FLOAT-LONG.
    05 PP-CELL              FLOAT-LONG OCCURS 3 TIMES.
    05 PP-OFF               FLOAT-LONG OCCURS 3 TIMES.
    05 PP-S                 FLOAT-LONG OCCURS 6 TIMES.
