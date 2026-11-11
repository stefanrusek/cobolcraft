*> Entity models part 1 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): shared records of client/src/entmodel-34-1.cob.
*> A cuboid in (EM1-CUBE-IN) and its baked faces out (EM1-CUBE-OUT); a pose (nine floats, 1.5).
 01 EM1-CUBE-IN.
    05 EC-U                FLOAT-LONG.
    05 EC-V                FLOAT-LONG.
    05 EC-OX               FLOAT-LONG.
    05 EC-OY               FLOAT-LONG.
    05 EC-OZ               FLOAT-LONG.
    05 EC-W                FLOAT-LONG.
    05 EC-H                FLOAT-LONG.
    05 EC-D                FLOAT-LONG.
    05 EC-GX               FLOAT-LONG.
    05 EC-GY               FLOAT-LONG.
    05 EC-GZ               FLOAT-LONG.
    05 EC-SU               FLOAT-LONG.
    05 EC-SV               FLOAT-LONG.
    05 EC-TEXW             FLOAT-LONG.
    05 EC-TEXH             FLOAT-LONG.
    05 EC-MIRROR           BINARY-LONG.
*> EC-FACES: sum of 1 DOWN, 2 UP, 4 WEST, 8 NORTH, 16 EAST, 32 SOUTH (63 = all six).
    05 EC-FACES            BINARY-LONG.
 01 EM1-CUBE-OUT.
    05 EF-COUNT            BINARY-LONG.
    05 EF-FACE OCCURS 6 TIMES.
*>      EF-DIR: 1 DOWN, 2 UP, 3 WEST, 4 NORTH, 5 EAST, 6 SOUTH (creation order).
       10 EF-DIR           BINARY-LONG.
       10 EF-NX            FLOAT-LONG.
       10 EF-NY            FLOAT-LONG.
       10 EF-NZ            FLOAT-LONG.
*>      EF-MINU, EF-MINV, EF-MAXU, EF-MAXV: the face rectangle in texture pixels (1.3 step 5).
       10 EF-MINU          FLOAT-LONG.
       10 EF-MINV          FLOAT-LONG.
       10 EF-MAXU          FLOAT-LONG.
       10 EF-MAXV          FLOAT-LONG.
       10 EF-VERT OCCURS 4 TIMES.
          15 EF-X          FLOAT-LONG.
          15 EF-Y          FLOAT-LONG.
          15 EF-Z          FLOAT-LONG.
          15 EF-TU         FLOAT-LONG.
          15 EF-TV         FLOAT-LONG.
 01 EM1-POSE.
    05 EP-X                FLOAT-LONG.
    05 EP-Y                FLOAT-LONG.
    05 EP-Z                FLOAT-LONG.
    05 EP-XROT             FLOAT-LONG.
    05 EP-YROT             FLOAT-LONG.
    05 EP-ZROT             FLOAT-LONG.
    05 EP-XSCALE           FLOAT-LONG.
    05 EP-YSCALE           FLOAT-LONG.
    05 EP-ZSCALE           FLOAT-LONG.
