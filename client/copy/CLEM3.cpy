*> Entity models part 1 section 3 (shared model base classes): the quadruped mesh rows of client/src/entmodel-34-1.cob (EM3-QUAD-MESH).
*> One row per part: pivot, pose xRot, then the single cuboid (texture offset, origin, size, deformation, mirror flag).
 01 EM3-PARTS.
    05 QP-COUNT            BINARY-LONG.
    05 QP-ROW OCCURS 8 TIMES.
       10 QP-NAME          PIC X(24).
       10 QP-PX            FLOAT-LONG.
       10 QP-PY            FLOAT-LONG.
       10 QP-PZ            FLOAT-LONG.
       10 QP-XROT          FLOAT-LONG.
       10 QP-U             FLOAT-LONG.
       10 QP-V             FLOAT-LONG.
       10 QP-OX            FLOAT-LONG.
       10 QP-OY            FLOAT-LONG.
       10 QP-OZ            FLOAT-LONG.
       10 QP-W             FLOAT-LONG.
       10 QP-H             FLOAT-LONG.
       10 QP-D             FLOAT-LONG.
       10 QP-GX            FLOAT-LONG.
       10 QP-GY            FLOAT-LONG.
       10 QP-GZ            FLOAT-LONG.
       10 QP-MIRROR        BINARY-LONG.
