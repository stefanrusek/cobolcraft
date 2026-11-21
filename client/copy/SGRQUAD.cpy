*> One quad for SGR-QUAD-ADD (sign-mesh.cob): the corner positions (eye-relative, top left, bottom left, bottom right, top right, x y z each), the texture rectangle
*> (u0 v0 u1 v1), the brightness and sky terms of the vertices and the tint.
 01 SGR-QUAD.
    05 SQ-POS              FLOAT-LONG OCCURS 12 TIMES.
    05 SQ-U0               FLOAT-LONG.
    05 SQ-V0               FLOAT-LONG.
    05 SQ-U1               FLOAT-LONG.
    05 SQ-V1               FLOAT-LONG.
    05 SQ-BRIGHT           FLOAT-LONG.
    05 SQ-SKY              FLOAT-LONG.
    05 SQ-RED              FLOAT-LONG.
    05 SQ-GREEN            FLOAT-LONG.
    05 SQ-BLUE             FLOAT-LONG.
