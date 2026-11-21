*> The wandering trader spawner (docs/protocol/19 section 23; core/src/mob-trader.cob; lane 002-lane-mobsb4, T8802), EXTERNAL. TS-INIT 0: the first TRADER-TICK sets delay 24000 and
*> chance 25. TS-DELAY ticks left until the next try, TS-CHANCE the spawn chance in percent.
 01 TS-STATE EXTERNAL.
    05 TS-INIT               BINARY-LONG.
    05 TS-DELAY              BINARY-LONG.
    05 TS-CHANCE             BINARY-LONG.
