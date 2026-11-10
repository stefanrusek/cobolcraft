*> One entry of the neighbour updater's queues (29 section 3.3), the layout of BU-STACK and BU-ADDED elements (BUSTATE.cpy).
*> Kind 1 multi (dim, x y z = source position, block, skip, index), 2 simple (position, source block), 3 full (also state and
*> moved), 4 shape (x y z = receiver, dir = direction the receiver sees, nx ny nz = neighbour position, state = neighbour state,
*> flags, budget).
 01 E-ENTRY.
    05 E-KIND    BINARY-LONG.
    05 E-DIM     BINARY-LONG.
    05 E-X       BINARY-LONG.
    05 E-Y       BINARY-LONG.
    05 E-Z       BINARY-LONG.
    05 E-BLOCK   BINARY-LONG.
    05 E-SKIP    BINARY-LONG.
    05 E-INDEX   BINARY-LONG.
    05 E-DIR     BINARY-LONG.
    05 E-NX      BINARY-LONG.
    05 E-NY      BINARY-LONG.
    05 E-NZ      BINARY-LONG.
    05 E-STATE   BINARY-LONG.
    05 E-FLAGS   BINARY-LONG.
    05 E-BUDGET  BINARY-LONG.
    05 E-MOVED   BINARY-LONG.
