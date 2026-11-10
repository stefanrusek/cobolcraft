*> Entity models, part 2 onward: a model with its cuboids, as client/src/entmodel-34-2.cob builds it from the document tables. Part 1 is the root.
*> MM-X..MM-ZSCALE is the definition (initial) pose, MM-CUR-* the current pose that setupAnim edits (EMM-RESET copies initial into current).
 01 EMM-MODEL.
    05 MM-TEXW             FLOAT-LONG.
    05 MM-TEXH             FLOAT-LONG.
    05 MM-COUNT            BINARY-LONG.
    05 MM-PART OCCURS 40 TIMES.
       10 MM-NAME          PIC X(24).
       10 MM-PARENT        BINARY-LONG.
       10 MM-VISIBLE       BINARY-LONG.
       10 MM-INIT.
          15 MM-X          FLOAT-LONG.
          15 MM-Y          FLOAT-LONG.
          15 MM-Z          FLOAT-LONG.
          15 MM-XROT       FLOAT-LONG.
          15 MM-YROT       FLOAT-LONG.
          15 MM-ZROT       FLOAT-LONG.
          15 MM-XSCALE     FLOAT-LONG.
          15 MM-YSCALE     FLOAT-LONG.
          15 MM-ZSCALE     FLOAT-LONG.
       10 MM-CUR.
          15 MM-CX         FLOAT-LONG.
          15 MM-CY         FLOAT-LONG.
          15 MM-CZ         FLOAT-LONG.
          15 MM-CXROT      FLOAT-LONG.
          15 MM-CYROT      FLOAT-LONG.
          15 MM-CZROT      FLOAT-LONG.
          15 MM-CXSCALE    FLOAT-LONG.
          15 MM-CYSCALE    FLOAT-LONG.
          15 MM-CZSCALE    FLOAT-LONG.
       10 MM-NCUBES        BINARY-LONG.
       10 MM-CUBE OCCURS 8 TIMES.
          15 MC-U          FLOAT-LONG.
          15 MC-V          FLOAT-LONG.
          15 MC-OX         FLOAT-LONG.
          15 MC-OY         FLOAT-LONG.
          15 MC-OZ         FLOAT-LONG.
          15 MC-W          FLOAT-LONG.
          15 MC-H          FLOAT-LONG.
          15 MC-D          FLOAT-LONG.
          15 MC-GX         FLOAT-LONG.
          15 MC-GY         FLOAT-LONG.
          15 MC-GZ         FLOAT-LONG.
          15 MC-MIRROR     BINARY-LONG.
