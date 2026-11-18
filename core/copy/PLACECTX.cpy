*> The placement context of a block item used on a block (lane wallitems, CC-0009; docs/protocol/29 sections 9.5 and 9.6): everything BlockPlaceContext offers
*> that the getStateForPlacement of the block families (core/src/place-*.cob) read. Directions are the face numbers of Use Item On: 0 down, 1 up, 2 north, 3 south,
*> 4 west, 5 east. PC-ORDER is getNearestLookingDirections (UI-NEAREST, with the opposite of the clicked face first unless the clicked block is replaced), PC-NEAREST
*> the first of orderedByNearest, PC-HDIR the player's horizontal direction (Direction.fromYRot of the yaw, 2 to 5). The cursor is the hit point inside the clicked
*> block (0 to 1 on each axis). PC-STATE is the state the item places on the way in and the state to place on the way out; PC-FITS 0 refuses the placement.
 01 PLACE-CONTEXT.
    05 PC-DIM                BINARY-LONG.
    05 PC-X                  BINARY-LONG.
    05 PC-Y                  BINARY-LONG.
    05 PC-Z                  BINARY-LONG.
    05 PC-BX                 BINARY-LONG.
    05 PC-BY                 BINARY-LONG.
    05 PC-BZ                 BINARY-LONG.
    05 PC-FACE               BINARY-LONG.
    05 PC-REPLACE            BINARY-LONG.
    05 PC-CX                 FLOAT-LONG.
    05 PC-CY                 FLOAT-LONG.
    05 PC-CZ                 FLOAT-LONG.
    05 PC-YAW                FLOAT-LONG.
    05 PC-PITCH              FLOAT-LONG.
    05 PC-SNEAK              BINARY-LONG.
    05 PC-HDIR               BINARY-LONG.
    05 PC-NEAREST            BINARY-LONG.
    05 PC-ORDER.
       10 PC-DIR             BINARY-LONG OCCURS 6 TIMES.
    05 PC-STATE              BINARY-LONG.
    05 PC-FITS               BINARY-LONG.
