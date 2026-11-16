*> Raids (docs/protocol/20 section 14.2; core/src/mob-20-raid.cob), EXTERNAL.
*> RD-ENTRY: one raid (RD-USED 1): RD-STATUS 1 ongoing, 2 victory, 3 loss, 4 stopped; RD-STARTED 1 once the first wave spawned; RD-GROUPS waves spawned; RD-COOLDOWN
*> (300 at the start); RD-TICKS ticks active; RD-POST the ticks after the last raider fell; RD-CELEB the ticks after the raid ended; RD-OMEN the raid omen level (0 to 5);
*> RD-TOTAL the sum of the health of the raiders that joined (thousandths); RD-LEADER the entity id of the current wave's banner wearer (0 none); RD-SPAWN-SET 1 when
*> RD-SX, RD-SY, RD-SZ is the wave spawn position; RD-HERO the entity ids of the players that earned the Hero of the Village (0 free).
*> RR-ENTRY: one raider's membership (RR-ID entity id, 0 = free): RR-RAID the raid index, RR-WAVE its wave, RR-OUTSIDE the ticks it was outside a village.
*> RP-ENTRY: per player row, the position stored when Bad Omen turned into Raid Omen (RP-SET 1) and the id of the raid whose boss bar the player has (RP-BAR, 0 none).
 78 RD-MAX                VALUE 8.
 78 RR-MAX                VALUE 256.
 01 RD-STATE EXTERNAL.
    05 RD-NEXT-ID            BINARY-LONG.
    05 RD-ENTRY              OCCURS 8 TIMES.
       10 RD-USED            BINARY-LONG.
       10 RD-ID              BINARY-LONG.
       10 RD-DIM             BINARY-LONG.
       10 RD-CX              BINARY-LONG.
       10 RD-CY              BINARY-LONG.
       10 RD-CZ              BINARY-LONG.
       10 RD-STATUS          BINARY-LONG.
       10 RD-STARTED         BINARY-LONG.
       10 RD-GROUPS          BINARY-LONG.
       10 RD-COOLDOWN        BINARY-LONG.
       10 RD-TICKS           BINARY-LONG.
       10 RD-POST            BINARY-LONG.
       10 RD-CELEB           BINARY-LONG.
       10 RD-OMEN            BINARY-LONG.
       10 RD-TOTAL           BINARY-LONG.
       10 RD-LEADER          BINARY-LONG.
       10 RD-SPAWN-SET       BINARY-LONG.
       10 RD-SX              BINARY-LONG.
       10 RD-SY              BINARY-LONG.
       10 RD-SZ              BINARY-LONG.
       10 RD-HERO            BINARY-LONG OCCURS 8 TIMES.
 01 RR-STATE EXTERNAL.
    05 RR-ENTRY              OCCURS 256 TIMES.
       10 RR-ID              BINARY-LONG.
       10 RR-RAID            BINARY-LONG.
       10 RR-WAVE            BINARY-LONG.
       10 RR-OUTSIDE         BINARY-LONG.
       10 RR-LEADER          BINARY-LONG.
 01 RP-STATE EXTERNAL.
    05 RP-ENTRY              OCCURS 64 TIMES.
       10 RP-SET             BINARY-LONG.
       10 RP-X               BINARY-LONG.
       10 RP-Y               BINARY-LONG.
       10 RP-Z               BINARY-LONG.
       10 RP-BAR             BINARY-LONG.
