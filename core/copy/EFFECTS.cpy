*> The player effect store (core/src/effects.cob): one slot per player row and mob effect id (0 to 39, 49 section 2.4).
*> EXTERNAL: every core program that COPYs this book sees the same storage, zero filled at the start of the process.
*> EF-OWNER is the entity id of the player the slot was written for: a row that another player has taken over does not
*> see the old player's effects (a mismatch counts as empty and is cleared on the next tick).
 78 EF-MAX-EFFECTS         VALUE 40.
 01 CORE-EFFECTS EXTERNAL.
    05 EF-PLAYER OCCURS 64 TIMES.
       10 EF-SLOT OCCURS 40 TIMES.
          15 EF-ON          PIC 9.
          15 EF-OWNER       BINARY-LONG.
          15 EF-AMPLIFIER   BINARY-LONG.
          15 EF-DURATION    BINARY-LONG.        *> ticks left; -1 infinite
          15 EF-FLAGS       BINARY-LONG.        *> 05b 0x87 flags: 1 ambient, 2 particles, 4 icon, 8 blend
