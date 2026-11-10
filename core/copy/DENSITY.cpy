*> State of the density evaluator (core/src/density.cob): the world seed's positional factory and the names of the
*> normal noises built so far with their NOISE.cpy handles. EXTERNAL.
 01 DN-STATE EXTERNAL.
    05 DN-FACTORY.
       10 DN-FLO            BINARY-DOUBLE UNSIGNED.
       10 DN-FHI            BINARY-DOUBLE UNSIGNED.
    05 DN-NOISE-COUNT       BINARY-LONG.
    05 DN-NOISE-ENTRY OCCURS 64 TIMES.
       10 DN-NOISE-NAME     PIC X(112).
       10 DN-NOISE-HANDLE   BINARY-LONG.
*>  The old_blended_noise nodes built so far (one stack set per node of the store): the handles of the minimum
*>  limit, maximum limit and main stacks and the scales of 10 section 3.4.
    05 DN-BLEND-COUNT       BINARY-LONG.
    05 DN-BLEND-ENTRY OCCURS 8 TIMES.
       10 DN-BLEND-NODE     BINARY-LONG.
       10 DN-B-MIN          BINARY-LONG.
       10 DN-B-MAX          BINARY-LONG.
       10 DN-B-MAIN         BINARY-LONG.
       10 DN-B-XZ-MUL       FLOAT-LONG.
       10 DN-B-Y-MUL        FLOAT-LONG.
