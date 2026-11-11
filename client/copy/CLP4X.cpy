*> Extra fields of the part 4 particle classes (docs/protocol/42-particles-4-block-item-dust-ambient.md), beside the
*> PCL record of CLPCL: the quarter-size sprite window offsets (terrain and item break particles), the layer
*> (0 OPAQUE, 1 TRANSLUCENT, 2 OPAQUE_TERRAIN, 3 TRANSLUCENT_TERRAIN), the roll speed of falling dust, the
*> dust colours of the transition (from and to, three channels each) and the firefly fade fields.
 01 P4X.
    05 X4-UO                  FLOAT-LONG.
    05 X4-VO                  FLOAT-LONG.
    05 X4-LAYER               BINARY-LONG.
    05 X4-ROT-SPEED           FLOAT-LONG.
    05 X4-FROM                FLOAT-LONG OCCURS 3 TIMES.
    05 X4-TO                  FLOAT-LONG OCCURS 3 TIMES.
    05 X4-SCALE               FLOAT-LONG.
    05 X4-KIND                BINARY-LONG.
