*> Extra fields of the part 5 particle classes (docs/protocol/42-particles-5-sculk-trial-wind-geyser.md), beside the PCL
*> record of CLPCL: the shriek delay, the vibration angles, the start position and displacement of the fly-towards
*> classes, the geyser plume constants and the sulfur bubble heights.
 01 P5X.
    05 X5-DELAY               BINARY-LONG.
    05 X5-ROT                 FLOAT-LONG.
    05 X5-PITCH               FLOAT-LONG.
    05 X5-OROT                FLOAT-LONG.
    05 X5-OPITCH              FLOAT-LONG.
    05 X5-START               FLOAT-LONG OCCURS 3 TIMES.
    05 X5-DISP                FLOAT-LONG OCCURS 3 TIMES.
    05 X5-MIN-SIZE            FLOAT-LONG.
    05 X5-MAX-SIZE            FLOAT-LONG.
    05 X5-INIT-PROP           FLOAT-LONG.
    05 X5-START-Y             FLOAT-LONG.
    05 X5-MAX-Y               FLOAT-LONG.
    05 X5-HSX                 FLOAT-LONG.
    05 X5-HSZ                 FLOAT-LONG.
    05 X5-DONE                BINARY-LONG.
    05 X5-SIZE-START          FLOAT-LONG.
    05 X5-Y-END               FLOAT-LONG.
    05 X5-Y-PREV              FLOAT-LONG.
