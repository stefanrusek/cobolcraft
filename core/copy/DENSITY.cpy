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
*> Grid mode of the interpolated node (gen-stages.cob): while DNG-ACTIVE is 1 an interpolated node that has a grid in the
*> chunk grids at DNG-PTR (GENGRID.cpy) takes its eight corner values from it instead of evaluating its input there, for a
*> position inside the chunk column whose west and north corner is (DNG-X0, DNG-Z0).
 01 DN-GRID-CTL EXTERNAL.
    05 DNG-ACTIVE           BINARY-LONG.
    05 DNG-X0               BINARY-LONG.
    05 DNG-Z0               BINARY-LONG.
    05 DNG-PTR              USAGE POINTER.
