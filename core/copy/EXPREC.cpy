*> The decoded firework_explosion component (stack-style.cob; docs/protocol/54 section 21.1): shape 0 small_ball, 1 large_ball, 2 star, 3 creeper, 4 burst; up to 8 colours and 8 fade colours (Ints).
 01 EX-REC.
    05 EX-SHAPE            BINARY-LONG.
    05 EX-N                BINARY-LONG.
    05 EX-COLOR            BINARY-LONG OCCURS 8 TIMES.
    05 EX-FN               BINARY-LONG.
    05 EX-FADE             BINARY-LONG OCCURS 8 TIMES.
    05 EX-TRAIL            BINARY-LONG.
    05 EX-TWINKLE          BINARY-LONG.
