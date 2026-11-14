*> The block states the structure code writes, resolved from the open content set once per table epoch (CB-EPOCH; core/src/struct-place.cob MSP-BLOCKS). EXTERNAL, core-private.
*> Directions index the tables by data value + 1 (1 south, 2 west, 3 north, 4 east): SBK-FENCE-S the fence with that side connected, SBK-TORCH-S the wall torch facing that way. Wood types
*> are 1 normal (oak), 2 mesa (dark oak). SB-*-B are block numbers as FL-BLOCK-OF gives them (0 when the set has no such block). SBK-FLAGS by block number: 1 falls (sand, gravel,
*> concrete powder, anvils, dragon egg), 2 is replaceable by structures (glow lichen, seagrass, tall seagrass), 3 both.
 01 STRUCT-BLOCKS EXTERNAL.
    05 SBK-EPOCH            BINARY-LONG.
    05 SBK-S-CAVE-AIR       BINARY-LONG.
    05 SBK-S-COBWEB         BINARY-LONG.
    05 SBK-S-SPAWNER        BINARY-LONG.
    05 SBK-S-CHAIN          BINARY-LONG.
    05 SBK-B-CHAIN          BINARY-LONG.
    05 SBK-S-RAIL           BINARY-LONG OCCURS 2 TIMES.
    05 SBK-S-TORCH          BINARY-LONG OCCURS 4 TIMES.
    05 SBK-WOOD OCCURS 2 TIMES.
       10 SBK-PLANKS-S      BINARY-LONG.
       10 SBK-PLANKS-B      BINARY-LONG.
       10 SBK-LOG-S         BINARY-LONG.
       10 SBK-LOG-B         BINARY-LONG.
       10 SBK-FENCE-B       BINARY-LONG.
       10 SBK-FENCE-S       BINARY-LONG OCCURS 4 TIMES.
       10 SBK-FENCE-P       BINARY-LONG.
    05 SBK-FLAGS            PIC 9 OCCURS 1400 TIMES.
