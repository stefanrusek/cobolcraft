*> A Level Particles packet as the server routes block-driven particles (42-6 sections 8 and 9; field names of 05a 0x30):
*>   PK-NAME particle type; PK-X, PK-Y, PK-Z position; PK-COUNT count; PK-DIST(1..3) the x, y, z distances; PK-SPEED(1..3) the maximum
*>   speeds; PK-MODE the randomisation (0 DEFAULT, 1 ALTERNATIVE, 2 ALTERNATIVE_WITH_SPEED); PK-STATE a block state option (0 none);
*>   PK-COLOR an RGB24 option colour (0 none); PK-DURATION a duration option.
 01 P6-PACKET.
    05 PK-NAME             PIC X(40).
    05 PK-X                FLOAT-LONG.
    05 PK-Y                FLOAT-LONG.
    05 PK-Z                FLOAT-LONG.
    05 PK-COUNT            BINARY-LONG.
    05 PK-DIST             FLOAT-LONG OCCURS 3 TIMES.
    05 PK-SPEED            FLOAT-LONG OCCURS 3 TIMES.
    05 PK-MODE             BINARY-LONG.
    05 PK-STATE            BINARY-LONG.
    05 PK-COLOR            BINARY-DOUBLE.
    05 PK-DURATION         BINARY-LONG.
