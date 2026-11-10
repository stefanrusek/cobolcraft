*> Extra fields of the part 2 particle classes (docs/protocol/42-particles-2-effects-fire-smoke-magic.md
*> section 3), beside the PCL record (CLPCL) and the shared extras PCLX (CLPCLX): the original alpha of the
*> spell class, the start position of the fly-towards and portal classes, the firework spark flags.
 01 P2X.
    05 X2-ORIG-ALPHA          FLOAT-LONG.
    05 X2-XSTART              FLOAT-LONG.
    05 X2-YSTART              FLOAT-LONG.
    05 X2-ZSTART              FLOAT-LONG.
    05 X2-TRAIL               BINARY-LONG.
    05 X2-TWINKLE             BINARY-LONG.
 01 P2SP.
    05 SP-COUNT               BINARY-LONG.
    05 SP-ROW                 OCCURS 6 TIMES.
       10 SP-X                FLOAT-LONG.
       10 SP-Y                FLOAT-LONG.
       10 SP-Z                FLOAT-LONG.
       10 SP-SCALE            FLOAT-LONG.
