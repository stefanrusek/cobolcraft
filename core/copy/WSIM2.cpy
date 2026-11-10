*> Second state record of the world simulation wiring (core/src/worldsim-33b.cob, docs/protocol/33 sections 3, 5 and 7): the overworld clock's rate, pause
*> and partial tick, advance_time, the sleep counter of each player row, the sleeping percentage and one world border per dimension row. W2-READY is 0 until
*> WORLDSIM-ENSURE2 sets the defaults.
 01 WORLDSIM-STATE2 EXTERNAL.
    05 W2-READY                  BINARY-LONG.
    05 W2-ADVANCE                BINARY-LONG.
    05 W2-PAUSED                 BINARY-LONG.
    05 W2-RATE                   FLOAT-LONG.
    05 W2-PARTIAL                FLOAT-LONG.
    05 W2-SLEEP-PCT              BINARY-LONG.
    05 W2-SLEEPING               BINARY-LONG OCCURS 64 TIMES.
    05 W2-SLEEP-COUNTER          BINARY-LONG OCCURS 64 TIMES.
    05 W2-BORDER OCCURS 3 TIMES.
       10 W2-B-CX                FLOAT-LONG.
       10 W2-B-CZ                FLOAT-LONG.
       10 W2-B-SIZE              FLOAT-LONG.
       10 W2-B-ABSOLUTE          FLOAT-LONG.
       10 W2-B-DAMAGE            FLOAT-LONG.
       10 W2-B-SAFE              FLOAT-LONG.
       10 W2-B-FROM              FLOAT-LONG.
       10 W2-B-TO                FLOAT-LONG.
       10 W2-B-DURATION          BINARY-LONG.
       10 W2-B-PROGRESS          BINARY-LONG.
       10 W2-B-MOVING            BINARY-LONG.
