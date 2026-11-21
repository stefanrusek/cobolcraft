*> A nether portal shape found by PORTAL-FIND-SHAPE (docs/protocol/39-portals.md section 3.1): PQ-VALID 1 when a shape with width 2 to
*> 21 and height 3 to 21 was found (else every field is 0), its axis (0 = X, 1 = Z), width and height in interior cells, the number of
*> nether_portal blocks counted in the interior, and the bottom-left interior cell (the end of the row on the left direction: EAST for
*> axis X, NORTH for axis Z; the right direction is WEST for X, SOUTH for Z).
 01 PORTAL-SHAPE.
    05 PQ-VALID               BINARY-LONG.
    05 PQ-AXIS                BINARY-LONG.
    05 PQ-W                   BINARY-LONG.
    05 PQ-H                   BINARY-LONG.
    05 PQ-COUNT               BINARY-LONG.
    05 PQ-BX                  BINARY-LONG.
    05 PQ-BY                  BINARY-LONG.
    05 PQ-BZ                  BINARY-LONG.
