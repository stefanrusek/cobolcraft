*> Piglin and hoglin brain state of lane mobsb7 (docs/protocol/44-residual-mob-questions-6-nether.md; core/src/mob-21-brain.cob), EXTERNAL: one entry per entity id (PG-ID 0 = free; the entry is
*> freed by PGB-FORGET from ENTITY-REMOVE). PG-AVOID the ticks of an AVOID_TARGET left, PG-AVOID-KIND 1 a zombified creature (the piglin has no attack target meanwhile), 2 a repellent block,
*> 3 the attacker of a baby; PG-AX and PG-AZ the point to walk away from. PG-CELEB the ticks of CELEBRATE_LOCATION left (300 after a kill), PG-CX and PG-CZ the place, PG-DANCE 0 never,
*> 1 dancing (metadata 19 true), 2 stopped (metadata 19 false is sent). PG-REACH the ticks spent walking to a wanted item (TIME_TRYING_TO_REACH_ADMIRE_ITEM), PG-NOWALK the ticks
*> left of DISABLE_WALK_TO_ADMIRE_ITEM, PG-ATE the ticks of ATE_RECENTLY left (200 after eating). PG-PACIFIED the ticks of a hoglin's PACIFIED memory left (200 near a repellent, 44-6 section 6.2), PG-AVTYPE the entity type of the
*> creature a piglin retreats from (44-6 section 2.3 step 5), PG-OFFHAND 1 + the item id of a loved item that is not currency held in the off hand while admiring (0 none), PG-INV the 8 inventory slots of a piglin
*> (44-6 section 3.2 step 5: an item id and a count, 64 at most per slot), PG-AVOID-KIND 4 a hoglin's walk away from a visible adult piglin (speed 0.4).
*> Lane p49s (core/src/mob-21-pgw.cob, 44-6 sections 2.11, 5.7, 5.8): PG-SP-STATUS the SPEAR_STATUS memory (0 absent, 1 APPROACH, 2 CHARGING, 3 RETREAT), PG-SP-RUN which spear behaviour runs
*> (0 none, 1 SpearApproach, 2 SpearAttack, 3 SpearRetreat), PG-SP-ENGAGE SPEAR_ENGAGE_TIME, PG-SP-CSET/CX/CZ SPEAR_CHARGE_POSITION, PG-SP-FSET/FX/FZ SPEAR_FLEEING_POSITION, PG-SP-FTIME
*> SPEAR_FLEEING_TIME, PG-SP-AGE the ticks the running spear behaviour has run, PG-USING 1 while the main-hand item is in use; PG-XB-STATE the CrossbowAttack state (0 UNCHARGED, 1 CHARGING,
*> 2 CHARGED, 3 READY_TO_ATTACK), PG-XB-DELAY attackDelay, PG-XB-USED the ticks the crossbow was drawn, PG-XB-RUN 1 while CrossbowAttack runs, PG-XB-AGE its ticks, PG-XB-LOADED 1 with a charged projectile.
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
       10 PG-PACIFIED        BINARY-LONG.
       10 PG-AVTYPE          BINARY-LONG.
       10 PG-OFFHAND         BINARY-LONG.
       10 PG-INV             OCCURS 8 TIMES.
          15 PG-INV-ITEM     BINARY-LONG.
          15 PG-INV-COUNT    BINARY-LONG.
       10 PG-SP-STATUS       BINARY-LONG.
       10 PG-SP-RUN          BINARY-LONG.
       10 PG-SP-ENGAGE       BINARY-LONG.
       10 PG-SP-CSET         BINARY-LONG.
       10 PG-SP-CX           FLOAT-LONG.
       10 PG-SP-CZ           FLOAT-LONG.
       10 PG-SP-FSET         BINARY-LONG.
       10 PG-SP-FX           FLOAT-LONG.
       10 PG-SP-FZ           FLOAT-LONG.
       10 PG-SP-FTIME        BINARY-LONG.
       10 PG-SP-AGE          BINARY-LONG.
       10 PG-USING           BINARY-LONG.
       10 PG-XB-STATE        BINARY-LONG.
       10 PG-XB-DELAY        BINARY-LONG.
       10 PG-XB-USED         BINARY-LONG.
       10 PG-XB-RUN          BINARY-LONG.
       10 PG-XB-AGE          BINARY-LONG.
       10 PG-XB-LOADED       BINARY-LONG.
