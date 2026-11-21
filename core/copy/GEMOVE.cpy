*> The context of one movement emission pass (lane p49y; core/src/game-events-move.cob GAME-EVENT-MOVED): the entity row, its new position and displacement, the cells and states under it and the rules that apply. A group of the caller's
*> working storage handed to the programs of the pass, so that no one of them needs a long USING list.
 01 MV-CTX.
    05 MV-ROW               BINARY-LONG.
    05 MV-DIM               BINARY-LONG.
    05 MV-X                 FLOAT-LONG.
    05 MV-Y                 FLOAT-LONG.
    05 MV-Z                 FLOAT-LONG.
    05 MV-DX                FLOAT-LONG.
    05 MV-DY                FLOAT-LONG.
    05 MV-DZ                FLOAT-LONG.
    05 MV-ON-GROUND         BINARY-LONG.
    05 MV-PLAYER            BINARY-LONG.
    05 MV-WET               BINARY-LONG.
    05 MV-SHIFT             BINARY-LONG.
    05 MV-SWIMMING          BINARY-LONG.
    05 MV-CROUCH            BINARY-LONG.
    05 MV-S0                BINARY-LONG.
    05 MV-S1                BINARY-LONG.
    05 MV-SAME              BINARY-LONG.
    05 MV-KEY               PIC X(48).
