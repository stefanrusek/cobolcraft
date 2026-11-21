*> Particle record (docs/protocol/42-particles-1-shared-model-engine.md section 4): the fields of
*> Particle and SingleQuadParticle. Positions and velocities are doubles; flags are 0 or 1. The box is
*> PC-BB-MIN and PC-BB-MAX (index 1 x, 2 y, 3 z). PCL-COLLIDERS is the list of block collision boxes the
*> collision resolver clips against (the boxes met by the query box; section 4.4 step 2).
 01 PCL.
    05 PC-X                   FLOAT-LONG.
    05 PC-Y                   FLOAT-LONG.
    05 PC-Z                   FLOAT-LONG.
    05 PC-XO                  FLOAT-LONG.
    05 PC-YO                  FLOAT-LONG.
    05 PC-ZO                  FLOAT-LONG.
    05 PC-XD                  FLOAT-LONG.
    05 PC-YD                  FLOAT-LONG.
    05 PC-ZD                  FLOAT-LONG.
    05 PC-BB-MIN              FLOAT-LONG OCCURS 3 TIMES.
    05 PC-BB-MAX              FLOAT-LONG OCCURS 3 TIMES.
    05 PC-BBW                 FLOAT-LONG.
    05 PC-BBH                 FLOAT-LONG.
    05 PC-ON-GROUND           BINARY-LONG.
    05 PC-HAS-PHYSICS         BINARY-LONG.
    05 PC-STOPPED             BINARY-LONG.
    05 PC-REMOVED             BINARY-LONG.
    05 PC-SPEED-UP            BINARY-LONG.
    05 PC-AGE                 BINARY-LONG.
    05 PC-LIFETIME            BINARY-LONG.
    05 PC-GRAVITY             FLOAT-LONG.
    05 PC-FRICTION            FLOAT-LONG.
    05 PC-QUAD-SIZE           FLOAT-LONG.
    05 PC-RCOL                FLOAT-LONG.
    05 PC-GCOL                FLOAT-LONG.
    05 PC-BCOL                FLOAT-LONG.
    05 PC-ALPHA               FLOAT-LONG.
    05 PC-ROLL                FLOAT-LONG.
    05 PC-OROLL               FLOAT-LONG.
    05 PC-SPRITE              BINARY-LONG.
 78 PCL-MAX-COLLIDERS         VALUE 64.
 01 PCL-COLLIDERS.
    05 PK-COUNT               BINARY-LONG.
    05 PK-BOX                 OCCURS 64 TIMES.
       10 PK-MIN              FLOAT-LONG OCCURS 3 TIMES.
       10 PK-MAX              FLOAT-LONG OCCURS 3 TIMES.
