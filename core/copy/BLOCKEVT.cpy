*> Block events (docs/protocol/29 section 6): the pending events of every level in insertion order (a set: an event equal in
*> all of dimension, position, block and both parameters to a pending one is not added).
 78 BE-MAX-EVENTS                VALUE 4096.
 01 BLOCK-EVENTS EXTERNAL.
    05 BE-COUNT                  BINARY-LONG.
    05 BE-EVENT OCCURS 4096 TIMES.
       10 BE-E-DIM               BINARY-LONG.
       10 BE-E-X                 BINARY-LONG.
       10 BE-E-Y                 BINARY-LONG.
       10 BE-E-Z                 BINARY-LONG.
       10 BE-E-BLOCK             BINARY-LONG.
       10 BE-E-A                 BINARY-LONG.
       10 BE-E-B                 BINARY-LONG.
