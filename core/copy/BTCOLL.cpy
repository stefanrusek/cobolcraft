*> The working state of BT-COLLECT (core/src/blockupd-29.cob): the due ticks of one queue (trigger time up to CW-TICKS) as slots chained by chunk, the
*> chunks they fall in, and BC-AT, the slot of an entry of BLOCK-TICKS by its index (0 when the entry is not due; all zero between two calls).
 01 BT-COLLECT-STATE EXTERNAL.
    05 BC-CHUNK-COUNT            BINARY-LONG.
    05 BC-DUE-COUNT              BINARY-LONG.
    05 BC-CHUNK OCCURS 4096 TIMES.
       10 BC-C-CX                BINARY-LONG.
       10 BC-C-CZ                BINARY-LONG.
       10 BC-C-KP                BINARY-LONG.
       10 BC-C-KS                BINARY-LONG.
       10 BC-C-FIRST             BINARY-LONG.
       10 BC-C-HEAD              BINARY-LONG.
    05 BC-HEAP-COUNT             BINARY-LONG.
    05 BC-HEAP                   BINARY-LONG OCCURS 4096 TIMES.
    05 BC-DUE OCCURS 32768 TIMES.
       10 BC-D-IDX               BINARY-LONG.
       10 BC-D-NEXT              BINARY-LONG.
       10 BC-D-LIVE              BINARY-LONG.
       10 BC-D-CH                BINARY-LONG.
    05 BC-AT                     BINARY-LONG OCCURS 32768 TIMES.
