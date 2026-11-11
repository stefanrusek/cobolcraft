*> State of the world simulation wiring (core/src/worldsim-33.cob, docs/protocol/33 section 2.4): each level's randValue of randomBlockPos (the
*> artifact starts it at a random integer; this core starts it at a fixed odd constant per level so a run is reproducible) and random_tick_speed
*> (the rule, default 3). WSM-READY is 0 until WORLDSIM-ENSURE sets the defaults.
 01 WORLDSIM-STATE EXTERNAL.
    05 WSM-READY                 BINARY-LONG.
    05 WSM-SPEED                 BINARY-LONG.
    05 WSM-RAND                  BINARY-LONG OCCURS 3 TIMES.
