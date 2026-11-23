*> The beardifier of one chunk (docs/protocol/36-structures-1-model-placement-starts.md sections 9.2 to 9.4; core/src/struct-beard.cob). EXTERNAL, core-private, the working set of one terrain job.
*> SBD-READY 1 once STRUCT-BEARD-PREPARE made it for SBD-CX, SBD-CZ under the world seed SBD-SEED and the structure data epoch SBD-EPOCH; SBD-ACTIVE 1 when it holds a record (else the value is 0 everywhere).
*> SBD-AX0..SBD-AZ1 is the union of the record boxes before the inflation by 24 of 9.2 step 3 (the sampler inflates). A rigid record (9.2): the mode of terrain_adaptation (STRUCT-BEARD-RIGID: none 0,
*> bury 1, beard_thin 2, beard_box 3, encapsulate 4), the piece box and the ground level delta; a junction: source x, source ground y, source z.
 78 SBD-MAX               VALUE 1024.
 01 STRUCT-BEARDIFIER EXTERNAL.
    05 SBD-READY            BINARY-LONG.
    05 SBD-ACTIVE           BINARY-LONG.
    05 SBD-CX               BINARY-LONG.
    05 SBD-CZ               BINARY-LONG.
    05 SBD-SEED             BINARY-DOUBLE.
    05 SBD-EPOCH            BINARY-LONG.
    05 SBD-LOST             BINARY-LONG.
*>  SBD-GEN is part of the stamps of the density memo (density.cob): it changes whenever the value of the beardifier node can change (the chunk prepared, STRUCT-BASE-HEIGHT turning it off).
    05 SBD-GEN              BINARY-LONG.
    05 SBD-RIGID-COUNT      BINARY-LONG.
    05 SBD-JUNC-COUNT       BINARY-LONG.
    05 SBD-AX0              BINARY-LONG.
    05 SBD-AY0              BINARY-LONG.
    05 SBD-AZ0              BINARY-LONG.
    05 SBD-AX1              BINARY-LONG.
    05 SBD-AY1              BINARY-LONG.
    05 SBD-AZ1              BINARY-LONG.
    05 SBD-RIGID OCCURS 1024 TIMES.
       10 SBR-MODE          BINARY-LONG.
       10 SBR-X0            BINARY-LONG.
       10 SBR-Y0            BINARY-LONG.
       10 SBR-Z0            BINARY-LONG.
       10 SBR-X1            BINARY-LONG.
       10 SBR-Y1            BINARY-LONG.
       10 SBR-Z1            BINARY-LONG.
       10 SBR-GROUND        BINARY-LONG.
    05 SBD-JUNC OCCURS 1024 TIMES.
       10 SBJ-X             BINARY-LONG.
       10 SBJ-Y             BINARY-LONG.
       10 SBJ-Z             BINARY-LONG.
