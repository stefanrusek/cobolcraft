*> Entity models part 1 section 2 (mesh definitions): the part-definition tree of client/src/entmodel-34-1.cob. Part 1 is the root (no cuboids, pose
*> zero). A part's parent is an index (0 for the root); MH-CUBES is the number of cuboids the part owns.
 01 EM2-MESH.
    05 MH-COUNT            BINARY-LONG.
    05 MH-PART OCCURS 64 TIMES.
       10 MH-NAME          PIC X(24).
       10 MH-PARENT        BINARY-LONG.
       10 MH-CUBES         BINARY-LONG.
       10 MH-POSE.
          15 MH-X          FLOAT-LONG.
          15 MH-Y          FLOAT-LONG.
          15 MH-Z          FLOAT-LONG.
          15 MH-XROT       FLOAT-LONG.
          15 MH-YROT       FLOAT-LONG.
          15 MH-ZROT       FLOAT-LONG.
          15 MH-XSCALE     FLOAT-LONG.
          15 MH-YSCALE     FLOAT-LONG.
          15 MH-ZSCALE     FLOAT-LONG.
*> The seven BabyModelTransform fields except the head-part set (2.3).
 01 EM2-BABY.
    05 BB-SCALE-HEAD       BINARY-LONG.
    05 BB-Y-HEAD           FLOAT-LONG.
    05 BB-Z-HEAD           FLOAT-LONG.
    05 BB-HEAD-SCALE       FLOAT-LONG.
    05 BB-BODY-SCALE       FLOAT-LONG.
    05 BB-BODY-Y           FLOAT-LONG.
