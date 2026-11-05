*> Mob rules (standin-content §12; §4.8 night; §15.4), transcribed. Tested by
*> core/tests/test_content_tables.cob. Lengths and speeds are integer THOUSANDTHS of a block (blocks
*> per tick for speeds), as in ENTITYTYPES.cpy and RULES.cpy; times are ticks.
*> Mob types (§12.1): index by (entity type id - MOB-FIRST-TYPE + 1): sodgrazer 1, abend 2. The size
*> of each type is in ENTITYTYPES.cpy. MB-CAUSE is the RULES.cpy CAUSE-* of its attack (0 = it never
*> attacks), whose amount is RULE-CAUSE-AMOUNT. MB-CAP: at most this many of the type in one
*> dimension's loaded chunks for a spawn to happen (§12.4 step 5).
 78 MOB-TYPE-COUNT            VALUE 2.
 78 MOB-FIRST-TYPE            VALUE 2.
 78 MOB-PASSIVE               VALUE 0.
 78 MOB-HOSTILE               VALUE 1.
 01 MOB-DATA.
    05 FILLER.                                  *> cobolcraft:sodgrazer
       10 FILLER BINARY-LONG VALUE 2.           *> entity type id
       10 FILLER BINARY-LONG VALUE 0.           *> passive
       10 FILLER BINARY-LONG VALUE 8.           *> maximum health
       10 FILLER BINARY-LONG VALUE 50.          *> wander speed/1000
       10 FILLER BINARY-LONG VALUE 100.         *> flee speed/1000
       10 FILLER BINARY-LONG VALUE 0.           *> pursue speed/1000
       10 FILLER BINARY-LONG VALUE 0.           *> notice range/1000
       10 FILLER BINARY-LONG VALUE 0.           *> give-up range/1000
       10 FILLER BINARY-LONG VALUE 0.           *> attack reach/1000
       10 FILLER BINARY-LONG VALUE 0.           *> attack cause: none
       10 FILLER BINARY-LONG VALUE 0.           *> attack cooldown
       10 FILLER BINARY-LONG VALUE 12.          *> yield: grazer_flank
       10 FILLER BINARY-LONG VALUE 2.           *> yield count
       10 FILLER BINARY-LONG VALUE 12.          *> dimension cap
    05 FILLER.                                  *> cobolcraft:abend
       10 FILLER BINARY-LONG VALUE 3.           *> entity type id
       10 FILLER BINARY-LONG VALUE 1.           *> hostile
       10 FILLER BINARY-LONG VALUE 12.          *> maximum health
       10 FILLER BINARY-LONG VALUE 40.          *> wander speed/1000
       10 FILLER BINARY-LONG VALUE 0.           *> flee speed/1000
       10 FILLER BINARY-LONG VALUE 120.         *> pursue speed/1000
       10 FILLER BINARY-LONG VALUE 12000.       *> notice range/1000
       10 FILLER BINARY-LONG VALUE 20000.       *> give-up range/1000
       10 FILLER BINARY-LONG VALUE 1750.        *> attack reach/1000
       10 FILLER BINARY-LONG VALUE 2.           *> attack cause: CAUSE-ABEND (3 damage, mob_attack)
       10 FILLER BINARY-LONG VALUE 30.          *> attack cooldown
       10 FILLER BINARY-LONG VALUE 15.          *> yield: dump_shard
       10 FILLER BINARY-LONG VALUE 1.           *> yield count
       10 FILLER BINARY-LONG VALUE 8.           *> dimension cap
 01 MOB-TABLE REDEFINES MOB-DATA.
    05 MB-ENTRY OCCURS 2 TIMES.
       10 MB-ENTITY-TYPE        BINARY-LONG.
       10 MB-KIND               BINARY-LONG.
       10 MB-HEALTH             BINARY-LONG.
       10 MB-WANDER-MILLI       BINARY-LONG.
       10 MB-FLEE-MILLI         BINARY-LONG.
       10 MB-PURSUE-MILLI       BINARY-LONG.
       10 MB-NOTICE-MILLI       BINARY-LONG.
       10 MB-GIVE-UP-MILLI      BINARY-LONG.
       10 MB-REACH-MILLI        BINARY-LONG.
       10 MB-CAUSE              BINARY-LONG.
       10 MB-COOLDOWN           BINARY-LONG.
       10 MB-YIELD-ITEM         BINARY-LONG.
       10 MB-YIELD-COUNT        BINARY-LONG.
       10 MB-CAP                BINARY-LONG.
*> Physics (§12.2): vy <- (vy - 0.05) x 0.96 each tick; a blocked horizontal move on the ground is
*> retried 1 block higher.
 78 MOB-GRAVITY-MILLI         VALUE 50.
 78 MOB-DRAG-MILLI            VALUE 960.
 78 MOB-STEP-UP               VALUE 1.
*> Behaviour (§12.3): a wandering mob decides on ticks with Time mod 80 = 0, with r = H(floor(x),
*> floor(y), floor(z), Time): r mod 3 = 0 stands still, otherwise yaw ((r div 3) mod 8) x 45 degrees.
*> A damaged passive mob flees for 40 ticks; a pursuing mob stops within 1.0 horizontal block.
 78 MOB-DECIDE-TICKS          VALUE 80.
 78 MOB-STAND-MOD             VALUE 3.
 78 MOB-YAW-DIRECTIONS        VALUE 8.
 78 MOB-YAW-STEP              VALUE 45.
 78 MOB-FLEE-TICKS            VALUE 40.
 78 MOB-PURSUE-STOP-MILLI     VALUE 1000.
*> Spawning (§12.4): on ticks with Time mod 100 = 0; with r = H(dimension index, floor(p.x),
*> floor(p.z), Time), dx = (r mod 41) - 20, dz = ((r div 41) mod 41) - 20, no spawn when both are
*> below 8 in size, or when a player is within 8.0 blocks of the spawn position; yaw ((r div 1681)
*> mod 8) x 45 (1681 = 41 x 41). Night (§4.8): 16000 <= Time < 29000.
 78 MOB-SPAWN-TICKS           VALUE 100.
 78 MOB-SPAWN-SPREAD          VALUE 41.
 78 MOB-SPAWN-OFFSET          VALUE 20.
 78 MOB-SPAWN-MIN             VALUE 8.
 78 MOB-SPAWN-NEAR-MILLI      VALUE 8000.
 78 MOB-NIGHT-START           VALUE 16000.
 78 MOB-NIGHT-END             VALUE 29000.
*> Spawn rules (§12.4 step 4, §15.4), tried in order: the first rule of the dimension whose time
*> matches names the candidate type, which spawns only when the ground block (the column's top
*> block) and the block light at top + 1 meet the rule; otherwise there is no spawn. MS-DIM is the
*> DIMENSIONS.cpy row (dimension index + 1), MS-TIME 0 any time, 1 day, 2 night; MS-GROUND a block
*> id or -1 for any; MS-LIGHT the maximum block light or -1 for any.
 78 MOB-TIME-ANY              VALUE 0.
 78 MOB-TIME-DAY              VALUE 1.
 78 MOB-TIME-NIGHT            VALUE 2.
 78 MOB-SPAWN-RULE-COUNT      VALUE 3.
 01 MOB-SPAWN-DATA.
    05 FILLER.                                  *> cobolcraft:main at night: abend, block light <= 5
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE -1.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.                                  *> cobolcraft:main by day: sodgrazer, on turf
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE -1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> cobolcraft:subroutine: abend, on slag, light <= 5
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 11.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 3.
 01 MOB-SPAWN-TABLE REDEFINES MOB-SPAWN-DATA.
    05 MS-ENTRY OCCURS 3 TIMES.
       10 MS-DIM                BINARY-LONG.
       10 MS-TIME               BINARY-LONG.
       10 MS-GROUND             BINARY-LONG.
       10 MS-LIGHT              BINARY-LONG.
       10 MS-TYPE               BINARY-LONG.
