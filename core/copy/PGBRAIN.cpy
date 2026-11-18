*> Piglin and hoglin brain state of lane mobsb7 (docs/protocol/44-residual-mob-questions-6-nether.md; core/src/mob-21-brain.cob), EXTERNAL: one entry per entity id (PG-ID 0 = free; the entry is
*> freed by PGB-FORGET from ENTITY-REMOVE). PG-AVOID the ticks of an AVOID_TARGET left, PG-AVOID-KIND 1 a zombified creature (the piglin has no attack target meanwhile), 2 a repellent block,
*> 3 the attacker of a baby; PG-AX and PG-AZ the point to walk away from. PG-CELEB the ticks of CELEBRATE_LOCATION left (300 after a kill), PG-CX and PG-CZ the place, PG-DANCE 0 never,
*> 1 dancing (metadata 19 true), 2 stopped (metadata 19 false is sent). PG-REACH the ticks spent walking to a wanted item (TIME_TRYING_TO_REACH_ADMIRE_ITEM), PG-NOWALK the ticks
*> left of DISABLE_WALK_TO_ADMIRE_ITEM, PG-ATE the ticks of ATE_RECENTLY left (200 after eating).
 78 PG-MAX                VALUE 64.
 01 PG-STATE EXTERNAL.
    05 PG-ENTRY              OCCURS 64 TIMES.
       10 PG-ID              BINARY-LONG.
       10 PG-AVOID           BINARY-LONG.
       10 PG-AVOID-KIND      BINARY-LONG.
       10 PG-AX              FLOAT-LONG.
       10 PG-AZ              FLOAT-LONG.
       10 PG-CELEB           BINARY-LONG.
       10 PG-DANCE           BINARY-LONG.
       10 PG-CX              FLOAT-LONG.
       10 PG-CZ              FLOAT-LONG.
       10 PG-REACH           BINARY-LONG.
       10 PG-NOWALK          BINARY-LONG.
       10 PG-ATE             BINARY-LONG.
