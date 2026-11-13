*> The chunks marked by /forceload (docs/protocol/16-commands-catalog.md §7.6; core/src/cmds-world.cob): BF-COUNT entries in the order they were marked,
*> each the dimension row and the chunk position. The marks are kept in memory only (the world's saved data of forced chunks is a vanilla file format, which
*> this core does not write).
 78 BF-MAX                VALUE 4096.
 01 BR-FORCE EXTERNAL.
    05 BF-COUNT             BINARY-LONG.
    05 BF-ENTRY             OCCURS 4096 TIMES.
       10 BF-DIM             BINARY-LONG.
       10 BF-X               BINARY-LONG.
       10 BF-Z               BINARY-LONG.
