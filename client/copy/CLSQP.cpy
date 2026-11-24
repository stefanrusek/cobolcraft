*> One cuboid of such a model for SPECIAL-CUBOID (52 sections 3.5 and 34 1.3): origin, size and texture offset in pixels, SP-SHIFT added to the origin (the part pivot), the rotation
*> pivot SP-RPIV, the rotation about X then about Z in degrees, SP-HIDE the faces left out (the table's DOWN 1, UP 2, WEST 4, NORTH 8, EAST 16, SOUTH 32 summed), SP-GROW the grow of every
*> side in hundredths of a pixel, SP-TSIZE and SP-THEIGHT the texture's width and height, SP-EXCH 1 for a model with y up (the letters take the opposite end of y), SP-SPRITE the atlas sprite, SP-T and SP-S the
*> translation and scale of the model in the unit cell (a pixel p goes to T + S p / 16) and SP-TINT the colour of the quads.
 01 SQ-PART.
    05 SP-ORIGIN            BINARY-LONG OCCURS 3 TIMES.
    05 SP-SIZE              BINARY-LONG OCCURS 3 TIMES.
    05 SP-TEX               BINARY-LONG OCCURS 2 TIMES.
    05 SP-SHIFT             BINARY-LONG OCCURS 3 TIMES.
    05 SP-RPIV              BINARY-LONG OCCURS 3 TIMES.
    05 SP-RX                FLOAT-LONG.
    05 SP-RZ                FLOAT-LONG.
    05 SP-HIDE              BINARY-LONG.
    05 SP-GROW              BINARY-LONG.
    05 SP-TSIZE             BINARY-LONG.
    05 SP-THEIGHT           BINARY-LONG.
    05 SP-EXCH              BINARY-LONG.
    05 SP-SPRITE            BINARY-LONG.
    05 SP-T                 FLOAT-LONG OCCURS 3 TIMES.
    05 SP-S                 FLOAT-LONG OCCURS 3 TIMES.
    05 SP-TINT              FLOAT-SHORT OCCURS 3 TIMES.
