*> One question to TINT-BLOCK-COLOR: block name, tint index, mode (0 in hand, 1 in world, 2 terrain
*> particle), the state properties the sources read (half 1 = upper, power, age) and the block
*> position, the biome blend radius; the answer is TQ-COLOUR.
 01 TINT-QUERY.
    05 TQ-NAME              PIC X(32).
    05 TQ-INDEX             BINARY-LONG.
    05 TQ-MODE              BINARY-LONG.
    05 TQ-HALF              BINARY-LONG.
    05 TQ-POWER             BINARY-LONG.
    05 TQ-AGE               BINARY-LONG.
    05 TQ-X                 BINARY-LONG.
    05 TQ-Y                 BINARY-LONG.
    05 TQ-Z                 BINARY-LONG.
    05 TQ-RADIUS            BINARY-LONG.
    05 TQ-COLOUR            BINARY-DOUBLE.
