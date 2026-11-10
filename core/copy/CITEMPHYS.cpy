*> The item entity of docs/protocol/41-item-entity-physics.md in the core (T0342 to T0358; core/src/itemphys-41.cob,
*> core/src/ground-items.cob). EXTERNAL, so every core program that COPYs this book sees the same state.
*>
*> One record per tracker row (CORE-ENTITIES, entity type CR-LOOSE-ITEM) beside the EN-* fields of the row (position, motion,
*> stack, EN-DELAY = pickupDelay, EN-AGE = age, EN-ON-GROUND): IP-I-ID is the network entity id the record belongs to; a row
*> whose EN-ID differs (a row filled by another program, a reused row) is initialised by IP-ENSURE with the defaults of 41 §1
*> (health 5, no thrower, no owner, no patch). IP-I-VAR is the component patch handle of the stack (CSTACK.cpy; 0 none),
*> IP-I-THROWER the entity id of the thrower (0 none), IP-I-OWNER the UUID of the only player allowed to pick it up when
*> IP-I-HAS-OWNER is 1, IP-I-RNG the item's own random source (a 48-bit linear congruential generator with the constants of
*> java.util.Random, seeded without the scramble from the entity id), IP-I-BOB the visual phase (bobOffs), IP-I-TICKS
*> tickCount, IP-I-FIRE remainingFireTicks, IP-I-INVULN invulnerableTime, IP-I-WET the previous-tick water flag,
*> IP-I-WATER-H and IP-I-LAVA-H the fluid heights of the last scan, IP-I-SENT-X/Y/Z the position the viewers last were told (Add
*> Entity or Teleport Entity: a move below the wire resolution of 1/4096 block is not sent, 05a VecDelta).
*> The level random source IP-LEVEL-RNG (popResource, dispenser) and one source per player row (IP-P-RNG: throws and death
*> drops) are seeded on first use (IP-LEVEL-SEEDED, IP-P-SEEDED 1 once set; a test or a world open may set them). IP-P-THROTTLE
*> is the creative-drop TickThrottler count. IP-NO-BLOCK-DROPS 1 is game rule block_drops false and IP-NO-MOB-GRIEFING 1
*> mob_griefing false (the core has no game rule store; whoever owns the rules sets them; both 0 by default).
*> IP-S-PICKED, IP-S-DROPPED (per player row and item id + 1) and IP-S-DROP-ACTIONS (per player row) are the statistics
*> item_picked_up, item_dropped and the custom stat drop (no statistics store exists in the core yet).
 78 IP-LIFETIME            VALUE 6000.
 78 IP-NEVER-PICKUP        VALUE 32767.
 78 IP-INFINITE-LIFETIME   VALUE -32768.
 78 IP-DEFAULT-HEALTH      VALUE 5.
 78 IP-DELAY-DEFAULT       VALUE 10.
 78 IP-DELAY-THROWN        VALUE 40.
 78 IP-DELAY-DISPENSER     VALUE 0.
 78 IP-THROTTLE-STEP       VALUE 20.
 78 IP-THROTTLE-LIMIT      VALUE 1480.
*> IP-SETUP kinds.
 78 IP-SET-DEFAULT-DELAY   VALUE 1.
 78 IP-SET-NO-DELAY        VALUE 2.
 78 IP-SET-NEVER-PICKUP    VALUE 3.
 78 IP-SET-UNLIMITED-LIFE  VALUE 4.
 78 IP-SET-EXTENDED-LIFE   VALUE 5.
 78 IP-SET-FAKE-ITEM       VALUE 6.
*> Damage types by number (the tags of 41 §5.2: is_fire 1 to 8, is_explosion 9 to 12, is_fall 13 to 15,
*> bypasses_invulnerability 16 and 17; 0 any other).
 78 IP-DT-OTHER            VALUE 0.
 78 IP-DT-IN-FIRE          VALUE 1.
 78 IP-DT-CAMPFIRE         VALUE 2.
 78 IP-DT-ON-FIRE          VALUE 3.
 78 IP-DT-LAVA             VALUE 4.
 78 IP-DT-HOT-FLOOR        VALUE 5.
 78 IP-DT-SULFUR-CUBE-HOT  VALUE 6.
 78 IP-DT-UNATTRIBUTED-FIREBALL VALUE 7.
 78 IP-DT-FIREBALL         VALUE 8.
 78 IP-DT-FIREWORKS        VALUE 9.
 78 IP-DT-EXPLOSION        VALUE 10.
 78 IP-DT-PLAYER-EXPLOSION VALUE 11.
 78 IP-DT-BAD-RESPAWN-POINT VALUE 12.
 78 IP-DT-FALL             VALUE 13.
 78 IP-DT-ENDER-PEARL      VALUE 14.
 78 IP-DT-STALAGMITE       VALUE 15.
 78 IP-DT-OUT-OF-WORLD     VALUE 16.
 78 IP-DT-GENERIC-KILL     VALUE 17.
*> The source of a hit (IP-HURT): another source, a mob, a creative-mode player.
 78 IP-SRC-OTHER           VALUE 0.
 78 IP-SRC-MOB             VALUE 1.
 78 IP-SRC-CREATIVE        VALUE 2.
*> Statistic kinds of IP-STAT-ADD and IP-STAT-GET.
 78 IP-STAT-PICKED         VALUE 1.
 78 IP-STAT-DROPPED        VALUE 2.
 78 IP-STAT-DROP           VALUE 3.
 01 CORE-ITEM-PHYSICS EXTERNAL.
    05 IP-LEVEL-RNG          BINARY-DOUBLE.
    05 IP-LEVEL-SEEDED       BINARY-LONG.
    05 IP-NO-BLOCK-DROPS     BINARY-LONG.
    05 IP-NO-MOB-GRIEFING    BINARY-LONG.
    05 IP-PLAYER OCCURS 64 TIMES.
       10 IP-P-RNG           BINARY-DOUBLE.
       10 IP-P-SEEDED        BINARY-LONG.
       10 IP-P-THROTTLE      BINARY-LONG.
       10 IP-S-DROP-ACTIONS  BINARY-LONG.
    05 IP-ITEM OCCURS 1024 TIMES.
       10 IP-I-ID            BINARY-LONG.
       10 IP-I-VAR           BINARY-LONG.
       10 IP-I-THROWER       BINARY-LONG.
       10 IP-I-HAS-OWNER     PIC 9.
       10 IP-I-OWNER         PIC X(16).
       10 IP-I-HEALTH        BINARY-LONG.
       10 IP-I-RNG           BINARY-DOUBLE.
       10 IP-I-BOB           FLOAT-LONG.
       10 IP-I-TICKS         BINARY-LONG.
       10 IP-I-FIRE          BINARY-LONG.
       10 IP-I-INVULN        BINARY-LONG.
       10 IP-I-WET           BINARY-LONG.
       10 IP-I-WATER-H       FLOAT-LONG.
       10 IP-I-LAVA-H        FLOAT-LONG.
       10 IP-I-SENT-X        FLOAT-LONG.
       10 IP-I-SENT-Y        FLOAT-LONG.
       10 IP-I-SENT-Z        FLOAT-LONG.
    05 IP-STATS OCCURS 64 TIMES.
       10 IP-S-PICKED        BINARY-LONG OCCURS 1500 TIMES.
       10 IP-S-DROPPED       BINARY-LONG OCCURS 1500 TIMES.
*> 41 section 7 (the renderer of the client): shadow radius 0.15 and strength 0.75 in thousandths, the minimum hover 0.0625.
 78 IP-SHADOW-RADIUS-MILLI VALUE 150.
 78 IP-SHADOW-STRENGTH-MILLI VALUE 750.
