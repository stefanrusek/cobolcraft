*> The world borders of docs/protocol/16-commands-catalog.md §4.11 and 33 §7: one per dimension row (DIMENSIONS.cpy table row, the BS-DIM of a source),
*> set to the defaults of 33 §7.1 by BB-ENSURE (core/src/cmds-state.cob) the first time: centre 0 0, size 59999968, damage 0.2 per block, safe zone
*> (damage buffer) 5, warning 5 blocks and 300 ticks. A timed change keeps its start BB-FROM, its target BB-TARGET, its length BB-TOTAL and the ticks
*> left BB-LEFT (0 = static); BB-TICK moves BB-SIZE by one tick.
 01 BR-BORDERS EXTERNAL.
    05 BB-INIT              BINARY-LONG.
    05 BB-ENTRY             OCCURS 3 TIMES.
       10 BB-CX             FLOAT-LONG.
       10 BB-CZ             FLOAT-LONG.
       10 BB-SIZE           FLOAT-LONG.
       10 BB-FROM           FLOAT-LONG.
       10 BB-TARGET         FLOAT-LONG.
       10 BB-TOTAL          BINARY-LONG.
       10 BB-LEFT           BINARY-LONG.
       10 BB-DAMAGE         FLOAT-LONG.
       10 BB-BUFFER         FLOAT-LONG.
       10 BB-WARN-BLOCKS    BINARY-LONG.
       10 BB-WARN-TIME      BINARY-LONG.
