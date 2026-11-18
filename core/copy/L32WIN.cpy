*> The sliding light window kept between calls (core/src/light-32g.cob): the dimension the engine is sized for, the registry epoch its states come from, and for each of the 16 slots of the
*> engine's window (core/copy/L32.cpy) the block states of the chunk as they were loaded into the engine (the bytes of CE-STATES of CELLS.cpy), against which a cached chunk is compared to see
*> whether it changed. WN-VALID 0 until the first call.
 01 L32-WINDOW EXTERNAL.
    05 WN-VALID                BINARY-LONG.
    05 WN-DIM                  BINARY-LONG.
    05 WN-SKY                  BINARY-LONG.
    05 WN-NS                   BINARY-LONG.
    05 WN-MIN                  BINARY-LONG.
    05 WN-EPOCH                BINARY-LONG.
    05 WN-SLOT OCCURS 36 TIMES.
       10 WN-BYTES             PIC X(196608).
       10 WN-CELLS REDEFINES WN-BYTES.
          15 WN-STATE          BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
