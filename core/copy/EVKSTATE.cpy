*> Evoker spells, evoker fangs and vexes (docs/protocol/20 sections 13.3 and 13.4; core/src/mob-20-evoker.cob), EXTERNAL.
*> EV-ENTRY: one per evoker entity id (EV-ID 0 = free): the spell being cast (0 none, 1 summon vex, 2 fangs, 3 wololo), EV-CAST the casting ticks left, EV-WARM the warm-up
*> ticks left before the spell is performed, EV-NEXT the game tick from which the next spell may start.
*> EV-PLAN: the fang layout computed by EVK-FANGS-PLAN: offsets from the evoker and the warm-up of each fang.
*> EF-ENTRY: the live fangs (EF-USED 1), their warm-up counter and the entity id of the evoker that cast them.
*> VX-ENTRY: one per summoned vex (VX-ID 0 = free): the owner's entity id, the life ticks left and the starvation timer.
 78 EV-MAX                VALUE 32.
 78 EF-MAX                VALUE 128.
 78 VX-MAX                VALUE 96.
 01 EV-STATE EXTERNAL.
    05 EV-ENTRY              OCCURS 32 TIMES.
       10 EV-ID              BINARY-LONG.
       10 EV-SPELL           BINARY-LONG.
       10 EV-CAST            BINARY-LONG.
       10 EV-WARM            BINARY-LONG.
       10 EV-NEXT            BINARY-DOUBLE.
 01 EV-PLAN EXTERNAL.
    05 EV-PLAN-COUNT         BINARY-LONG.
    05 EV-PLAN-ENTRY         OCCURS 16 TIMES.
       10 EV-PLAN-DX         FLOAT-LONG.
       10 EV-PLAN-DZ         FLOAT-LONG.
       10 EV-PLAN-WARM       BINARY-LONG.
 01 EF-STATE EXTERNAL.
    05 EF-ENTRY              OCCURS 128 TIMES.
       10 EF-USED            BINARY-LONG.
       10 EF-DIM             BINARY-LONG.
       10 EF-X               FLOAT-LONG.
       10 EF-Y               FLOAT-LONG.
       10 EF-Z               FLOAT-LONG.
       10 EF-WARM            BINARY-LONG.
       10 EF-OWNER           BINARY-LONG.
 01 VX-STATE EXTERNAL.
    05 VX-ENTRY              OCCURS 96 TIMES.
       10 VX-ID              BINARY-LONG.
       10 VX-OWNER           BINARY-LONG.
       10 VX-LIFE            BINARY-LONG.
       10 VX-STARVE          BINARY-LONG.
