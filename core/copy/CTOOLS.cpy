*> Per player row state of the tool and combat rules (core/src/combat.cob; docs/protocol/17 sections 4.1 and 4.7); EXTERNAL, one entry per
*> CORE-PLAYERS row. TS-OWNER is the entity id of the player the entry was written for (a row another player took over counts as empty).
*> TS-LAST-ATTACK is CW-TICKS + 1 of the last attack or held-item change (0: never, a full charge); TS-LAST-HURT the lastHurt of the hurt window
*> in thousandths of a point.
 01 CORE-TOOLSTATE EXTERNAL.
    05 TS-ENTRY OCCURS 64 TIMES.
       10 TS-OWNER            BINARY-LONG.
       10 TS-LAST-ATTACK      BINARY-DOUBLE.
       10 TS-LAST-HURT        BINARY-LONG.
