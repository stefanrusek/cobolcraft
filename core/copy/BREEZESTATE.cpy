*> The brain state of breezes (lane 002-lane-p49u; docs/protocol/20 section 16.1 and 16.4; core/src/mob-20-16c.cob), EXTERNAL. BZ-ENTRY: one per breeze entity id (BZ-ID 0 = free).
*> BZ-ACT the active activity (0 not chosen yet, read as FIGHT, the default activity; 1 FIGHT; 2 IDLE), chosen at the end of a tick. BZ-POSE 0 STANDING, 1 INHALING, 2 LONG_JUMPING,
*> 3 SLIDING. Memories with their ticks left (0 = absent), counted down at the start of a tick: BZ-SHOOT breeze_shoot, BZ-CD breeze_jump_cooldown, BZ-INHALE breeze_jump_inhaling.
*> BZ-JSET 1 when breeze_jump_target is present (the cell BZ-JX/JY/JZ); BZ-JVX/JVZ the constant horizontal velocity of the flight (discard friction); BZ-RUN the ticks the long jump has
*> run (it ends at 200). BZ-WALK 1 when walk_target is present (the block BZ-WX/WY/WZ); BZ-SINK 1 while the slide sink runs, BZ-SLIDE its ticks left. BZ-CANT-ON 1 when
*> cant_reach_walk_target_since is present (the game tick BZ-CANT-AT). BZ-HAD 1 when the breeze had an attack target at the end of the last tick.
 78 BZ-MAX                VALUE 16.
 01 BZ-STATE-TABLE EXTERNAL.
    05 BZ-ENTRY              OCCURS 16 TIMES.
       10 BZ-ID              BINARY-LONG.
       10 BZ-ACT             BINARY-LONG.
       10 BZ-POSE            BINARY-LONG.
       10 BZ-SHOOT           BINARY-LONG.
       10 BZ-CD              BINARY-LONG.
       10 BZ-INHALE          BINARY-LONG.
       10 BZ-JSET            BINARY-LONG.
       10 BZ-JX              BINARY-LONG.
       10 BZ-JY              BINARY-LONG.
       10 BZ-JZ              BINARY-LONG.
       10 BZ-JVX             FLOAT-LONG.
       10 BZ-JVZ             FLOAT-LONG.
       10 BZ-RUN             BINARY-LONG.
       10 BZ-WALK            BINARY-LONG.
       10 BZ-WX              BINARY-LONG.
       10 BZ-WY              BINARY-LONG.
       10 BZ-WZ              BINARY-LONG.
       10 BZ-SINK            BINARY-LONG.
       10 BZ-SLIDE           BINARY-LONG.
       10 BZ-CANT-ON         BINARY-LONG.
       10 BZ-CANT-AT         BINARY-DOUBLE.
       10 BZ-HAD             BINARY-LONG.
