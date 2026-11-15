*> The state of the data group (docs/protocol/16-commands-catalog.md §10; core/src/cmds-data.cob), EXTERNAL and in memory only (not saved with the world): stopwatches (the game
*> tick CW-TICKS they started at), scheduled functions (the game tick they are due at; no function engine runs them) and the data packs (the built-in vanilla pack is row 1, made
*> when the first datapack command runs; SD-ENABLED lists the rows of the enabled packs in order).
 78 SD-MAX-WATCHES      VALUE 64.
 78 SD-MAX-SCHEDULES    VALUE 256.
 78 SD-MAX-PACKS        VALUE 64.
 01 SD-STATE EXTERNAL.
    05 SD-WATCH             OCCURS 64 TIMES.
       10 SD-W-USED          BINARY-LONG.
       10 SD-W-ID            PIC X(64).
       10 SD-W-LENGTH        BINARY-LONG.
       10 SD-W-START         BINARY-DOUBLE.
    05 SD-SCHEDULE          OCCURS 256 TIMES.
       10 SD-S-USED          BINARY-LONG.
       10 SD-S-ID            PIC X(64).
       10 SD-S-LENGTH        BINARY-LONG.
       10 SD-S-TAG           BINARY-LONG.
       10 SD-S-TIME          BINARY-DOUBLE.
    05 SD-PACK-COUNT        BINARY-LONG.
    05 SD-PACK              OCCURS 64 TIMES.
       10 SD-P-NAME          PIC X(64).
       10 SD-P-LENGTH        BINARY-LONG.
    05 SD-ENABLED-COUNT     BINARY-LONG.
    05 SD-ENABLED           BINARY-LONG OCCURS 64 TIMES.
