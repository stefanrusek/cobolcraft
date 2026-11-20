*> The saved data of one map (docs/protocol/57-client-closures-2 section 4: data/minecraft/maps/<id>.dat), the record of MAP-DATA-WRITE and MAP-DATA-READ. The colours are
*> 16384 bytes (128 x 128, index x + z x 128, each (base colour id << 2) | brightness id); the scale is 0 to 4; the flags are 0 or 1. Banner markers (the block position,
*> the dye colour name, the custom name as a plain string) and item frame markers (the block position, the rotation in degrees, the frame's entity id) persist; the player
*> markers and the update state never do.
 78 MD-MAX-MARKERS         VALUE 64.
 01 MAP-DATA.
    05 MD-DIM-LENGTH         BINARY-LONG.
    05 MD-DIM                PIC X(64).
    05 MD-X-CENTER           BINARY-LONG.
    05 MD-Z-CENTER           BINARY-LONG.
    05 MD-SCALE              BINARY-LONG.
    05 MD-COLORS             PIC X(16384).
    05 MD-TRACKING           BINARY-LONG.
    05 MD-UNLIMITED          BINARY-LONG.
    05 MD-LOCKED             BINARY-LONG.
    05 MD-BANNER-COUNT       BINARY-LONG.
    05 MD-BANNER             OCCURS 64 TIMES.
       10 MD-B-X               BINARY-LONG.
       10 MD-B-Y               BINARY-LONG.
       10 MD-B-Z               BINARY-LONG.
       10 MD-B-COLOR-LENGTH    BINARY-LONG.
       10 MD-B-COLOR           PIC X(16).
       10 MD-B-NAME-LENGTH     BINARY-LONG.
       10 MD-B-NAME            PIC X(64).
    05 MD-FRAME-COUNT        BINARY-LONG.
    05 MD-FRAME              OCCURS 64 TIMES.
       10 MD-F-X               BINARY-LONG.
       10 MD-F-Y               BINARY-LONG.
       10 MD-F-Z               BINARY-LONG.
       10 MD-F-ROTATION        BINARY-LONG.
       10 MD-F-ENTITY          BINARY-LONG.
