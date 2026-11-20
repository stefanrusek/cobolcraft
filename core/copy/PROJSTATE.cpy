*> Per-entity state of the thrown and effect entities of lane mobsb6 (core/src/thrown-44.cob; docs/protocol/44 parts 8 and 9), EXTERNAL, a side table
*> keyed by the entity id (PJ-ENT 0 = free) so a reused tracker row never inherits it. PJ-KIND: 1 splash potion, 2 lingering potion, 3 area effect cloud,
*> 4 ender pearl, 5 eye of ender, 6 thrown egg, 7 fishing bobber, 8 firework rocket, 9 lightning bolt, 10 minecart, 11 armor stand, 12 item frame, 13 painting; 40 thrown experience bottle (lane p49f, mob-21-8-13.cob), 41 ominous item spawner (mob-21-8-17.cob).
*> PJ-I1 to PJ-I4 and PJ-R1 to PJ-R3 are kind specific (named in the program that owns the kind). PJ-FX is the effect list of a potion or cloud (id, amplifier, duration).
 78 PJ-MAX                VALUE 128.
 01 PJ-STATE EXTERNAL.
    05 PJ-ENTRY              OCCURS 128 TIMES.
       10 PJ-ENT             BINARY-LONG.
       10 PJ-KIND            BINARY-LONG.
       10 PJ-OWNER           BINARY-LONG.
       10 PJ-TICK            BINARY-LONG.
       10 PJ-DUR             BINARY-LONG.
       10 PJ-WAIT            BINARY-LONG.
       10 PJ-REAPP           BINARY-LONG.
       10 PJ-DUR-USE         BINARY-LONG.
       10 PJ-SCALE           BINARY-LONG.
       10 PJ-RADIUS          FLOAT-LONG.
       10 PJ-RPT             FLOAT-LONG.
       10 PJ-ROU             FLOAT-LONG.
       10 PJ-FXN             BINARY-LONG.
       10 PJ-FX              OCCURS 4 TIMES.
          15 PJ-FX-ID        BINARY-LONG.
          15 PJ-FX-AMP       BINARY-LONG.
          15 PJ-FX-DUR       BINARY-LONG.
       10 PJ-V               OCCURS 16 TIMES.
          15 PJ-V-ENT        BINARY-LONG.
          15 PJ-V-UNTIL      BINARY-LONG.
       10 PJ-I1              BINARY-LONG.
       10 PJ-I2              BINARY-LONG.
       10 PJ-I3              BINARY-LONG.
       10 PJ-I4              BINARY-LONG.
       10 PJ-I5              BINARY-LONG.
       10 PJ-I6              BINARY-LONG.
       10 PJ-I7              BINARY-LONG.
       10 PJ-I8              BINARY-LONG.
       10 PJ-I9              BINARY-LONG.
       10 PJ-I10             BINARY-LONG.
       10 PJ-POSE            FLOAT-LONG OCCURS 18 TIMES.
       10 PJ-EQ              BINARY-LONG OCCURS 8 TIMES.
       10 PJ-R1              FLOAT-LONG.
       10 PJ-R2              FLOAT-LONG.
       10 PJ-R3              FLOAT-LONG.
