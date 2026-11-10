*> Extra fields of the part 3 particle classes (docs/protocol/42-particles-3-fluid-drip-water.md): the drip
*> family's fluid (0 empty, 1 water, 2 lava), glowing flag and follow-up particle id; the bubble classes'
*> and the squid ink's and sulfur bubble's fields.
 01 P3X.
    05 X3-FLUID               BINARY-LONG.
    05 X3-GLOWING             BINARY-LONG.
    05 X3-NEXT                BINARY-LONG.
    05 X3-KIND                BINARY-LONG.
    05 X3-ANGLE               FLOAT-LONG.
    05 X3-SIZE-START          FLOAT-LONG.
    05 X3-Y-START             FLOAT-LONG.
    05 X3-Y-END               FLOAT-LONG.
    05 X3-Y-PREV              FLOAT-LONG.
