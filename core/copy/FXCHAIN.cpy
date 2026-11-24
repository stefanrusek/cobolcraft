*> The chain of one status effect of an entity (docs/protocol/44-residual-mob-questions-x1-continuation.md sections 8.2 and 11.2; lane 002-lane-p49s): node 1 is the active instance, nodes 2 to FX-N
*> the hidden instances beneath it (each one the hidden instance of the one before), at most 5 nodes. FX-FLAGS are the 05b 0x87 flags: 1 ambient, 2 particles (visible), 4 icon (showIcon).
 78 FX-MAX-NODES          VALUE 5.
 01 FX-CHAIN.
    05 FX-N                  BINARY-LONG.
    05 FX-NODE               OCCURS 5 TIMES.
       10 FX-AMP             BINARY-LONG.
       10 FX-DUR             BINARY-LONG.
       10 FX-FLAGS           BINARY-LONG.
