*> The experience of each player row (docs/protocol/16-commands-catalog.md §5.13, 17 §4.10; core/src/cmds-entities.cob): EXTERNAL, one entry per CORE-PLAYERS row.
*> XP-TOTAL is the total points (capped at the int range); the level and the points inside it come from it. XP-ENTITY is the PL-ENTITY-ID of the
*> player the total belongs to: an entry of another (earlier) player of the row counts as 0. Not saved.
 01 CORE-XP EXTERNAL.
    05 XP-PLAYER OCCURS 64 TIMES.
       10 XP-ENTITY          BINARY-LONG.
       10 XP-TOTAL           BINARY-DOUBLE.
