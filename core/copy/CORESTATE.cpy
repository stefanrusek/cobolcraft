*> Core state (contracts/core-host-api.md: one world per process; data-model.md §1 to §3, §6, §12).
*> Every record is EXTERNAL: each core program that COPYs this book sees the same storage.
*> CORE-WORLD-OPEN initialises every record. Buffers are kept as the raw bytes of a PB-BUFFER
*> (contract/copy/PROTO.cpy, CORE-PB-SIZE bytes): a program moves them into its own PB-BUFFER,
*> works on it and moves them back, so the PROTO.cpy shape is never redefined here.

 78 CORE-MAX-CONNS          VALUE 64.
 78 CORE-MAX-PLAYERS        VALUE 64.
 78 CORE-MAX-DIMS           VALUE 5.
 78 CORE-MAX-CHUNKS         VALUE 4096.
 78 CORE-PB-SIZE            VALUE 21.     *> LENGTH OF PB-BUFFER
 78 CORE-CHUNK-CELLS        VALUE 65536.  *> cells of a 256-high chunk (16 x 256 x 16); CELLS.cpy holds up to CE-STATE-CELLS
 78 CORE-CHUNK-BYTES        VALUE 304640. *> CE-CHUNK-BYTES (contract/copy/CELLS.cpy)
 78 CORE-MAX-ENTITIES       VALUE 1024.

*> Connection phases (data-model §12; 01 §7.1).
 78 PH-HANDSHAKE            VALUE 0.
 78 PH-STATUS               VALUE 1.
 78 PH-LOGIN                VALUE 2.
 78 PH-CONFIG               VALUE 3.
 78 PH-PLAY                 VALUE 4.

*> Player life states (data-model §6).
 78 PS-JOINING              VALUE 0.
 78 PS-ALIVE                VALUE 1.
 78 PS-DEAD                 VALUE 2.
 78 PS-TRAVELLING           VALUE 3.

*> Keep-alive interval and login time limit in ticks (09 §2: 15 s; 01 §7.5: 600 ticks).
 78 CORE-KEEPALIVE-TICKS    VALUE 300.
 78 CORE-LOGIN-TICKS        VALUE 600.

*> Compression threshold on network connections (09 §2).
 78 CORE-COMPRESSION        VALUE 256.

*> One game tick lasts 50 ms (research R6); block break times (BLOCKS.cpy, milliseconds) are counted
*> in ticks.
 78 CORE-TICK-MS            VALUE 50.

*> Set Time is sent to every player in play every 20 ticks (09 §3.2 Set Time row).
 78 CORE-TIME-TICKS         VALUE 20.

*> World (data-model §1).
 01 CORE-WORLD EXTERNAL.
    05 CW-OPEN               PIC X.              *> "Y" once CORE-WORLD-OPEN has run
    05 CW-SETTINGS           PIC X(3829).        *> the CORE-SETTINGS bytes of CORE-WORLD-OPEN
    05 CW-FOLDER             PIC X(1024).
    05 CW-FOLDER-LENGTH      BINARY-LONG.
    05 CW-NAME               PIC X(64).
    05 CW-GAME-MODE          PIC 9.              *> level.dat GameMode (07 §9.2): new players, host kinds 1-2
    05 CW-WORLD-TYPE         PIC X(10).          *> level.dat WorldType: standard, cobolcraft or debug (world-types 2.1)
    05 CW-SEED               BINARY-DOUBLE.      *> level.dat Seed
    05 CW-CONTENT-JAR        PIC X(64).          *> level.dat ContentJar (informational, WT-6); spaces when absent
    05 CW-TIME               BINARY-DOUBLE.      *> time of day 0 to 23999 (RULES.cpy RULE-DAY-LENGTH; 33 §3)
    05 CW-TICKS              BINARY-DOUBLE.      *> ticks run since the world was opened
    05 CW-LAYOUT             PIC 9.              *> 1 when level.dat came in the 26.3 layout (Data compound): saved back in it (07 §10)
    05 CW-GAME-TIME          BINARY-DOUBLE.      *> `Time` of a 26.3 level.dat when read; saved as this + CW-TICKS
    05 CW-CLOCK-BASE         BINARY-DOUBLE.      *> whole days of the overworld clock's total_ticks when read (CW-TIME is the rest)
    05 CW-SPAWN-X            FLOAT-LONG.
    05 CW-SPAWN-Y            FLOAT-LONG.
    05 CW-SPAWN-Z            FLOAT-LONG.
    05 CW-SPAWN-YAW          FLOAT-SHORT.
    05 CW-DIM-COUNT          BINARY-LONG.        *> enabled dimensions, in Login order
    05 CW-DIM                BINARY-LONG OCCURS 5 TIMES.   *> row of the DIMENSIONS.cpy table
*>  Weather (docs/protocol/33 section 4; core/src/weather.cob): one WeatherData for the whole server (the times in
*>  ticks and the two flags) and, per DIMENSIONS.cpy row, the levels 0 to 1 and the levels of the tick before.
    05 CW-WEATHER-DATA.
       10 CW-CLEAR-TIME      BINARY-LONG.
       10 CW-RAIN-TIME       BINARY-LONG.
       10 CW-THUNDER-TIME    BINARY-LONG.
       10 CW-RAINING         PIC 9.
       10 CW-THUNDERING      PIC 9.
    05 CW-WEATHER-LEVELS OCCURS 5 TIMES.
       10 CW-RAIN-LEVEL         FLOAT-SHORT.
       10 CW-RAIN-LEVEL-OLD     FLOAT-SHORT.
       10 CW-THUNDER-LEVEL      FLOAT-SHORT.
       10 CW-THUNDER-LEVEL-OLD  FLOAT-SHORT.
    05 CW-RUN-STATE          PIC 9.              *> CST-RUN-STATE
    05 CW-NEXT-ENTITY-ID     BINARY-LONG.
    05 CW-NEXT-ENTER         BINARY-LONG.        *> entering order of the next player (PL-ENTERED)
    05 CW-CONSOLE            PIC X(21).          *> PB-BUFFER bytes: pending console lines

*> Connection table (core-host-api §3; data-model §12). The connection id is the row number.
 01 CORE-CONNS EXTERNAL.
    05 CN-ENTRY OCCURS 64 TIMES.
       10 CN-USED            PIC 9.
       10 CN-KIND            PIC 9.              *> CORE-CONN-NETWORK or CORE-CONN-MEMORY
       10 CN-PHASE           PIC 9.              *> PH-*
       10 CN-COMPRESS        PIC 9.              *> 1 after Set Compression
       10 CN-CLOSE           PIC 9.              *> 1 after a disconnect: no more input is handled
       10 CN-PROTOCOL        BINARY-LONG.        *> Intention protocol version
       10 CN-INTENT          BINARY-LONG.        *> Intention intent
       10 CN-PLAYER          BINARY-LONG.        *> player row, 0 = none
       10 CN-STATUS-DONE     PIC 9.              *> Status Response sent
       10 CN-PHASE-TICK      BINARY-DOUBLE.      *> CW-TICKS when the current phase began
       10 CN-KA-PENDING      PIC 9.              *> a Keep Alive is unanswered
       10 CN-KA-ID           BINARY-DOUBLE.      *> its id
       10 CN-KA-DEADLINE     BINARY-DOUBLE.      *> CW-TICKS of the next keep-alive check
       10 CN-TELEPORT-ID     BINARY-LONG.        *> last teleport id sent (counts up from 1)
       10 CN-TELEPORT-ACKED  PIC 9.
       10 CN-IN              PIC X(21).          *> PB-BUFFER bytes: inbound accumulator
       10 CN-OUT             PIC X(21).          *> PB-BUFFER bytes: outbound frames

*> Player table (data-model §6). The player row is kept in CN-PLAYER of its connection.
 01 CORE-PLAYERS EXTERNAL.
    05 PL-ENTRY OCCURS 64 TIMES.
       10 PL-USED            PIC 9.
       10 PL-CONN            BINARY-LONG.
       10 PL-NAME            PIC X(16).
       10 PL-NAME-LENGTH     BINARY-LONG.
       10 PL-UUID            PIC X(16).
       10 PL-ENTITY-ID       BINARY-LONG.
       10 PL-STATE           PIC 9.              *> PS-*
       10 PL-DIM             BINARY-LONG.        *> row of the DIMENSIONS.cpy table
       10 PL-X               FLOAT-LONG.
       10 PL-Y               FLOAT-LONG.
       10 PL-Z               FLOAT-LONG.
       10 PL-YAW             FLOAT-SHORT.
       10 PL-PITCH           FLOAT-SHORT.
       10 PL-ON-GROUND       PIC 9.
       10 PL-FALL-START      FLOAT-LONG.
       10 PL-MODE            PIC 9.              *> 0 survival, 1 creative
       10 PL-FLYING          PIC 9.
       10 PL-HEALTH          FLOAT-SHORT.
       10 PL-FOOD            BINARY-LONG.
       10 PL-AIR             BINARY-LONG.        *> air supply in ticks (18 section 2.5 item 4: 300 at most, drowning at -20; core/src/breath.cob)
*>     Hunger (standin §11; core/src/hunger.cob): exhaustion (§11.2, not saved), the sprinting flag of
*>     Player Command, the food item being eaten (0 = not eating) with its hotbar slot and the CW-TICKS
*>     of the Use Item that started it (§11.6), and the consecutive ticks at food 0 (§10.3).
       10 PL-EXHAUSTION      FLOAT-LONG.
       10 PL-SATURATION      FLOAT-LONG.         *> 17 section 4.9: 0 to the food level, 5.0 for a new player
       10 PL-SPRINTING       PIC 9.
       10 PL-SNEAKING        PIC 9.              *> 1 while Player Input (05c 0x2B) holds the shift flag 0x20
       10 PL-POSE            BINARY-LONG.        *> the Pose enum id of the player (docs/protocol/53 section 1): 0 standing, 3 swimming or crawling, 5 crouching (core/src/poses.cob)
       10 PL-SWIMMING        PIC 9.              *> 1 while the swimming flag (53 section 4) is set: sprinting in water
       10 PL-POSE-FLAGS      BINARY-LONG.        *> the shared-flags byte of the player's entity (18 section 1.4): 0x02 shift key down, 0x08 sprinting, 0x10 swimming
       10 PL-POSE-SENT       BINARY-LONG.        *> 0, or 1 + pose x 256 + flags as last sent in Set Entity Data
       10 PL-EATING-ITEM     BINARY-LONG.        *> 0 = not eating
       10 PL-EATING-SLOT     BINARY-LONG.
       10 PL-EATING-START    BINARY-DOUBLE.
       10 PL-STARVE-TICKS    BINARY-LONG.
       10 PL-OPERATOR        PIC 9.
       10 PL-HELD            BINARY-LONG.        *> hotbar slot 0 to 8
       10 PL-INVENTORY.                          *> the 36 slots as one area (288 bytes)
          15 PL-SLOT OCCURS 36 TIMES.            *> inventory slot n is PL-SLOT(n + 1)
             20 PL-SLOT-ITEM BINARY-LONG.
             20 PL-SLOT-COUNT BINARY-LONG.       *> 0 = empty
*>     The data component patch handle of each slot (core/copy/CSTACK.cpy, core/src/stack-patch.cob; 0 = none), kept
*>     outside PL-INVENTORY so the recipe book's inventory snapshot stays the items and counts.
       10 PL-SLOT-VARS.
          15 PL-SLOT-VAR BINARY-LONG OCCURS 36 TIMES.
*>     Recipe book (standin §13; core/src/crafting.cob): 1 once the join has sent Recipe Book Add,
*>     and the inventory that book was computed from; a different inventory re-sends it.
       10 PL-BOOK-SENT       PIC 9.
       10 PL-BOOK-INVENTORY  PIC X(288).
       10 PL-STATE-ID        BINARY-LONG.        *> container 0 state id
       10 PL-VIEW-DISTANCE   BINARY-LONG.        *> Client Information view distance
       10 PL-CENTER-X        BINARY-LONG.        *> chunk cache center
       10 PL-CENTER-Z        BINARY-LONG.
       10 PL-BATCH-PENDING   BINARY-LONG.        *> chunk batches sent and not yet acknowledged
       10 PL-ENTITY-ROW      BINARY-LONG.        *> CORE-ENTITIES row; 0 until the join is sent
       10 PL-ENTERED         BINARY-LONG.        *> order of entering the world this run (standin §9.3)
*>     The item on the cursor of the inventory screen (Container Click; core/src/inventory.cob).
       10 PL-CARRIED-ITEM    BINARY-LONG.
       10 PL-CARRIED-COUNT   BINARY-LONG.        *> 0 = nothing carried
       10 PL-CARRIED-VAR     BINARY-LONG.        *> its patch handle (0 = none)
*>     A Container Click drag (QUICK_CRAFT, 05c 0x12): its type (button / 4) and the slots added.
       10 PL-DRAG-ACTIVE     PIC 9.
       10 PL-DRAG-TYPE       BINARY-LONG.
       10 PL-DRAG-COUNT      BINARY-LONG.
       10 PL-DRAG-SLOT       BINARY-LONG OCCURS 36 TIMES.
*>     A survival break in progress (Player Action 0 to 3; data-model §3; core/src/breaking.cob).
       10 PL-BREAKING        PIC 9.
       10 PL-BREAK-X         BINARY-LONG.
       10 PL-BREAK-Y         BINARY-LONG.
       10 PL-BREAK-Z         BINARY-LONG.
       10 PL-BREAK-START     BINARY-DOUBLE.      *> CW-TICKS of START_DESTROY_BLOCK
       10 PL-BREAK-RATE      FLOAT-SHORT.        *> progress per tick on the ground (13 section 2.1), fixed at the start
       10 PL-BREAK-PROGRESS  FLOAT-LONG.         *> accumulated progress: each tick adds the rate, divided by 5 while airborne
       10 PL-BREAK-ITEM      BINARY-LONG.        *> the held item at the start (0 = empty hand)
       10 PL-BREAK-STATE     BINARY-LONG.        *> the target's block state at the start
       10 PL-BREAK-DELAYED   PIC 9.              *> 1 after a STOP that came early (13 section 2.4)
       10 PL-BREAK-STAGE     BINARY-LONG.        *> last Block Destruction stage sent, -1 none
*>     Health (standin §10; core/src/health.cob). PL-DEATH-CAUSE is the RULES.cpy CAUSE-* of the
*>     death while the player is dead (0 while alive); PL-KILLER-* name the attacker of a player kill.
       10 PL-HURT-COOLDOWN   BINARY-LONG.        *> invulnerableTime (17 section 4.7): 20 after an accepted hit
       10 PL-LAST-HURT       BINARY-LONG.        *> lastHurt: the damage of the last accepted hit
       10 PL-RECOVER-TICKS   BINARY-LONG.        *> consecutive ticks of the recovery condition (§10.5)
       10 PL-DEATH-CAUSE     BINARY-LONG.
       10 PL-KILLER-NAME     PIC X(16).
       10 PL-KILLER-LENGTH   BINARY-LONG.
       10 PL-KILLER-ITEM     PIC X(64).          *> the custom name of the attacker's held item at the last hit (the .item death message)
       10 PL-KILLER-ITEM-LENGTH BINARY-LONG.
       10 PL-CREDIT-NAME     PIC X(16).          *> kill credit (17 section 4.13.2): the player or mob that last hurt this player
       10 PL-CREDIT-LENGTH   BINARY-LONG.
       10 PL-CREDIT-TICK     BINARY-DOUBLE.      *> CW-TICKS of that hit: valid for 100 ticks
       10 PL-FALL-DISTANCE   BINARY-LONG.        *> the last fall damage's distance in thousandths of a block (the fall death message)
*>     Travel (standin §15.5; core/src/dimensions.cob): 1 once the player has travelled this
*>     session, and the CW-TICKS of that travel (a use within TRAVEL-COOLDOWN ticks is ignored).
       10 PL-TRAVELLED       PIC 9.
       10 PL-TRAVEL-TICK     BINARY-DOUBLE.
*>     --- 002-lane-mobs2: experience (core/src/xp.cob; 17 section 4.10) ---
       10 PL-XP-LEVEL        BINARY-LONG.        *> experience level
       10 PL-XP-POINTS       BINARY-LONG.        *> points into the current level
       10 PL-XP-TOTAL        BINARY-LONG.        *> total experience points
       10 PL-XP-DELAY        BINARY-LONG.        *> takeXpDelay: ticks until the next orb pickup
*>     --- 002-lane-mobsfull-h11: the time_since_rest statistic (core/src/mob-20-12.cob; 44-5 section 10C item 2); not saved ---
       10 PL-REST            BINARY-LONG.        *> ticks since the last death or bed entry, not counting sleep
*>     --- 002-lane-itemcomp3: the enchantment seed of the enchanting table (core/src/menu-enchant.cob; 40-4 section 2.3); not saved, drawn at the first use ---
       10 PL-ENCH-INIT       PIC 9.              *> 1 once PL-ENCH-SEED holds a drawn seed
       10 PL-ENCH-SEED       BINARY-LONG.        *> the player's getEnchantmentSeed, an int
*>     --- end 002-lane-mobs2 ---

*> Chunk cache (data-model §2, §3): one row per loaded chunk of any dimension. CK-ADDR points to
*> CORE-CHUNK-BYTES bytes laid out as contract/copy/CELLS.cpy (2-byte states, 4-bit light, biomes). The
*> cell index is (y - min y) * 256 + z * 16 + x (+ 1). CK-INDEX is a hash index into
*> the rows: bucket (hash of dim, x, z) holds the first row number, CK-NEXT chains rows; a row with
*> CK-USED 0 is in no chain. CK-COUNT is the highest row number ever used. CK-SOURCES(s + 1) counts
*> the light-emitting cells of block section s (world.cob keeps it; light.cob scans only those
*> sections for block light sources).
 01 CORE-CHUNKS EXTERNAL.
    05 CK-COUNT              BINARY-LONG.
    05 CK-BUCKET             BINARY-LONG OCCURS 4096 TIMES.
    05 CK-ENTRY OCCURS 4096 TIMES.
       10 CK-USED            PIC 9.
       10 CK-DIM             BINARY-LONG.
       10 CK-X               BINARY-LONG.
       10 CK-Z               BINARY-LONG.
       10 CK-NEXT            BINARY-LONG.
       10 CK-ADDR            USAGE POINTER.
       10 CK-CHANGED         PIC 9.              *> set by a block change (persist on save)
       10 CK-LIT             PIC 9.              *> light computed
       10 CK-FOREIGN         PIC 9.              *> 1: its palette holds a key of another world type (WT-23): void, never saved
       10 CK-RESEND          PIC 9.              *> 1: overflow of a neighbour was written into this lit chunk, the tick sends it again (OV-FLUSH)
       10 CK-SOURCES         BINARY-LONG OCCURS 24 TIMES.
       10 CK-FRESH           PIC 9.              *> generated (not read from a file) and not yet given its chunk-generation spawns (MS6-CHUNK-GEN-TICK)

*> Entity tracker (data-model §5 to §7; 09 §3.2 entity rows; core/src/entities.cob). One row per
*> entity in the world that other players can see: players once their join is sent (EN-PLAYER is
*> the player row), ground items (core/src/ground-items.cob) and mobs (core/src/mobs.cob). EN-X to
*> EN-ON-GROUND are the values last sent to the viewers (the base of the next Move Entity delta); for
*> a ground item or a mob they are its position, sent after every change, and for a ground item
*> EN-ON-GROUND is 1 while it is resting.
*> EN-VX to EN-VZ: the current motion (blocks per tick; 0 for players). EN-ITEM to EN-AGE: the
*> stack, pickup delay and age of a ground item (data-model §5). EN-COUNT is the highest row number
*> ever used.
 01 CORE-ENTITIES EXTERNAL.
    05 EN-COUNT              BINARY-LONG.
    05 EN-ENTRY OCCURS 1024 TIMES.
       10 EN-USED            PIC 9.
       10 EN-ID              BINARY-LONG.        *> network entity id
       10 EN-TYPE            BINARY-LONG.        *> entity type id (ENTITYTYPES.cpy)
       10 EN-UUID            PIC X(16).
       10 EN-PLAYER          BINARY-LONG.        *> player row, 0 = not a player
       10 EN-DIM             BINARY-LONG.
       10 EN-X               FLOAT-LONG.
       10 EN-Y               FLOAT-LONG.
       10 EN-Z               FLOAT-LONG.
       10 EN-YAW             FLOAT-SHORT.
       10 EN-PITCH           FLOAT-SHORT.
       10 EN-ON-GROUND       BINARY-LONG.
       10 EN-VX              FLOAT-LONG.
       10 EN-VY              FLOAT-LONG.
       10 EN-VZ              FLOAT-LONG.
       10 EN-ITEM            BINARY-LONG.
       10 EN-ITEM-COUNT      BINARY-LONG.
       10 EN-DELAY           BINARY-LONG.        *> pickup delay, ticks
       10 EN-AGE             BINARY-LONG.        *> ticks a player was near (standin §9.2)
*>     Mobs (standin §12; core/src/mobs.cob). EN-VY is a mob's vertical velocity (its EN-VX and EN-VZ
*>     stay 0) and EN-ON-GROUND its on-ground flag; EN-X to EN-YAW are its position and yaw. EN-HEALTH
*>     and EN-HURT: health and hurt cooldown (§10.2). EN-WANDER-X/-Z: the horizontal velocity of the
*>     last wander decision. EN-FLEE: flee ticks left; EN-FLEE-PLAYER/-ID: the player row and entity
*>     id of the attacker fled from, EN-FLEE-X/-Z its last known position. EN-TARGET/-ID: the target
*>     player row and its entity id (0 = none). EN-COOLDOWN: attack cooldown. None of it is saved.
       10 EN-HEALTH          BINARY-LONG.
       10 EN-HURT            BINARY-LONG.
       10 EN-LAST-HURT       BINARY-LONG.
       10 EN-WANDER-X        FLOAT-LONG.
       10 EN-WANDER-Z        FLOAT-LONG.
       10 EN-FLEE            BINARY-LONG.
       10 EN-FLEE-PLAYER     BINARY-LONG.
       10 EN-FLEE-ID         BINARY-LONG.
       10 EN-FLEE-X          FLOAT-LONG.
       10 EN-FLEE-Z          FLOAT-LONG.
       10 EN-TARGET          BINARY-LONG.
       10 EN-TARGET-ID       BINARY-LONG.
       10 EN-COOLDOWN        BINARY-LONG.
       10 EN-BURN            BINARY-LONG.        *> ticks left on fire (a daylight-burning standard mob: 160, 1 damage every 20)
       10 EN-FIRE-SENT       BINARY-LONG.        *> 1 when the viewers were last sent the on-fire flag (metadata 0 bit 0) set (STDMOB-FIRE-SYNC)
       10 EN-WAY-X           FLOAT-LONG.         *> the next path waypoint (cell centre) of a walking standard mob (core/src/stdmobs.cob STDMOB-HEAD)
       10 EN-WAY-Z           FLOAT-LONG.
       10 EN-DEST-X          BINARY-LONG.        *> the cell a stroll is walking to (EN-COOLDOWN ticks left)
       10 EN-DEST-Z          BINARY-LONG.
       10 EN-PATH-TICKS      BINARY-LONG.        *> ticks until the path is searched again
       10 EN-KILLER          BINARY-LONG.        *> player row that last hit a mob (0 none): the killed_by_player loot condition (core/src/stdmobs.cob)
*>     --- 002-lane-mobs2: creeper (core/src/stdmobs.cob STDMOB-SWELL) ---
       10 EN-SWELL           BINARY-LONG.        *> the swell counter (20 section 6.1), 0 to the fuse
       10 EN-SWELL-DIR       BINARY-LONG.        *> the last swell direction sent to the viewers (0 = none yet, the default -1)
       10 EN-SHOOT-TIME      BINARY-LONG.        *> a bow mob's attackTime: ticks until it draws the bow again (20 section 5; EN-SWELL is its seeTime)
       10 EN-DRAW            BINARY-LONG.        *> 0 = bow not drawn, else 1 + the ticks the bow has been drawn
*>     --- 002-lane-mobs3: bow goal strafing (20 section 5) ---
       10 EN-STRAFE-TIME     BINARY-LONG.        *> strafingTime (-1 = not strafing)
       10 EN-STRAFE-CW       BINARY-LONG.        *> strafingClockwise 0 or 1
       10 EN-STRAFE-BACK     BINARY-LONG.        *> strafingBackwards 0 or 1
       10 EN-STRAFE-X        FLOAT-LONG.         *> the strafe walk of this tick
       10 EN-STRAFE-Z        FLOAT-LONG.
*>     --- 002-lane-mobsfull-h5: per-entity variant (core/src/mob-20-3.cob) ---
       10 EN-VARIANT         BINARY-LONG.        *> zombie family: 1 = baby; creeper: 1 = powered; slime: its size (0 = not set, read as 1); the metadata sync is STDMOB-VARIANT-BUILD
       10 EN-EQUIP           BINARY-LONG.        *> armour of a zombie or skeleton: 10 x (tier + 1) + number of slots worn (head, chest, legs, feet in that order); 0 none (20 section 3.6)
       10 EN-REINF           BINARY-LONG.        *> zombie reinforcement chance in ten-thousandths (20 section 4.1)
       10 EN-ENDER-TICKS     BINARY-LONG.        *> enderman: ticks since its target changed (the 600-tick daylight rule, 20 section 8.1)
*>     --- 002-lane-mobsfull-h6: breeding, ageing, wool, eggs (core/src/mob-18-8.cob; 18 section 8.1, 19 sections 2.2 to 2.5) ---
*>     A baby has EN-VARIANT 1 (the same flag as the zombie family) and a negative EN-MOBAGE; an adult in breeding cooldown has a positive one.
       10 EN-MOBAGE          BINARY-LONG.        *> AgeableMob age in ticks: -24000 a new baby, 0 adult, 6000 after breeding (counts toward 0)
       10 EN-LOVE            BINARY-LONG.        *> inLove: ticks left in love mode (600 after feeding)
       10 EN-LOVE-CAUSE      BINARY-LONG.        *> player row that fed it (0 none)
       10 EN-LOVE-TIME       BINARY-LONG.        *> BreedGoal loveTime: ticks spent walking to the partner
       10 EN-LOVE-PARTNER    BINARY-LONG.        *> tracker row of the partner being walked to (0 none)
       10 EN-FORCED          BINARY-LONG.        *> forcedAgeTimer: ticks left of the age-up effect after feeding a baby
       10 EN-LOCKED          BINARY-LONG.        *> age locked (golden dandelion): 1 keeps the age from counting
       10 EN-TAMED           BINARY-LONG.        *> horse family: 1 when tamed (love mode needs it)
       10 EN-WOOL            BINARY-LONG.        *> sheep: the metadata byte (colour 0 to 15, +16 sheared); mooshroom: type 0 red 1 brown; pig, cow, chicken: variant
       10 EN-EGG             BINARY-LONG.        *> chicken: eggTime, ticks to the next egg
       10 EN-EAT             BINARY-LONG.        *> sheep: the EatBlock timer, 0 or the ticks left of the 40
*>     --- 002-lane-mobsfull-h7: taming (core/src/mob-18-8.cob 18 section 8.2; wolf, 19 section 6.1). EN-TAMED is the tame flag. ---
       10 EN-OWNER-UUID      PIC X(16).          *> the owner's UUID of a tame pet (spaces: none)
       10 EN-SIT             BINARY-LONG.        *> orderedToSit: 1 while the pet is ordered to sit
       10 EN-PET-MOVING      BINARY-LONG.        *> 1 while a pet walks to its owner (FollowOwnerGoal, M188-FOLLOW)
       10 EN-FOE             BINARY-LONG.        *> a pet's or golem's mob target: tracker row (0 none), its entity id in EN-FOE-ID
       10 EN-FOE-ID          BINARY-LONG.
       10 EN-PET-CD          BINARY-LONG.        *> ticks until the pet's next melee hit
*>     --- 002-lane-mobsfull-h8: main hand, helmet wear (core/src/mob-20-3.cob) ---
       10 EN-HAND            BINARY-LONG.        *> main-hand item: 0 empty, 1 iron sword, 2 iron spear, 3 iron shovel (zombie weapon draw, 20 section 4.1), 4 bow (skeleton family, 5)
       10 EN-HEAD-WEAR       BINARY-LONG.        *> durability damage of the helmet worn (EN-EQUIP head slot); -1 = broken, the head is empty (20 section 3.5)
       10 EN-HEALTH-MILLI     BINARY-LONG.        *> mob health: thousandths of a point already lost beyond EN-HEALTH (an armour-reduced hit is fractional, 18 section 7.3)
       10 EN-WOLF-WET        BINARY-LONG.        *> wolf: 1 after it was in water or rain (a shake is due when it is out of it, 19 section 6.1)
       10 EN-WOLF-SHAKE      BINARY-LONG.        *> wolf: 0 not shaking, else 1 + the ticks of the shake (shakeAnim = 0.05 per tick, ends at 2.0)
*>     --- 002-lane-mobsb4 (T8804): piglin family immunity to zombification (metadata 16 piglin and brute, 18 hoglin; 21 section 5.5) ---
       10 EN-PIG-IMMUNE       BINARY-LONG.        *> 1 = immune to zombification
       10 EN-WAKE            BINARY-LONG.        *> silverfish: wake-up-friends timer, 20 after a hit by an attacker, counting down to the scan (20 section 9.1)
*>     --- 002-lane-mobsfull-h10: aquatic mobs (core/src/mob-21-4.cob; docs/protocol/21 section 4) ---
       10 EN-DRY             BINARY-LONG.        *> ticks out of water (a fish: air 300 - EN-DRY; a dolphin: moistness 2400 - EN-DRY); 0 in water
       10 EN-SWIM-SPEED      FLOAT-LONG.         *> a swimmer's current move speed (FishMoveControl lerp 0.125 toward attribute x modifier)
       10 EN-DEST-Y          BINARY-LONG.        *> the cell y a swimmer is heading for (EN-DEST-X/-Z, EN-COOLDOWN the ticks left)
       10 EN-IDLE            BINARY-LONG.        *> squid noActionTime: ticks without a player within 32 blocks
       10 EN-SQ-MX           FLOAT-LONG.         *> a squid's movement vector m (blocks per tick, 21 section 4.5)
       10 EN-SQ-MY           FLOAT-LONG.
       10 EN-SQ-MZ           FLOAT-LONG.
       10 EN-SQ-PHASE        FLOAT-LONG.         *> tentacleMovement phase, 0 to 2 pi
       10 EN-SQ-TSPEED       FLOAT-LONG.         *> tentacleSpeed (0 = not drawn yet)
       10 EN-DARK            BINARY-LONG.        *> glow squid: ticks left without glowing after a hit
       10 EN-INFLATE         BINARY-LONG.        *> pufferfish inflateCounter (the puff state is EN-VARIANT, 0 to 2)
       10 EN-DEFLATE         BINARY-LONG.        *> pufferfish deflateTimer
*>     --- lane p49t: schooling fish (core/src/mob-21-school.cob; 21 section 4.1.1) ---
       10 EN-SCH-LEADER      BINARY-LONG.        *> the entity id of the leader a schooling fish follows (0 none)
       10 EN-SCH-FOLLOWERS   BINARY-LONG.        *> the followers of a leader: schoolSize is 1 + this
       10 EN-SCH-NEXT        BINARY-LONG.        *> FollowFlockLeaderGoal nextStartTick
       10 EN-SCH-ROLLED      BINARY-LONG.        *> 1 once nextStartTick was rolled (the constructor's roll, made at the first goal tick)
       10 EN-SCH-PATH        BINARY-LONG.        *> timeToRecalcPath
       10 EN-PEEK-CUR        FLOAT-LONG.         *> a shulker's current lid peek 0 to 1 (raw peek EN-VARIANT x 0.01 is the target; 0.05 a tick, 21 section 6.2)
*>     --- 002-lane-mobsfull-h11: mob effects, creeper ignition, phantom flight (core/src/mob-20-6.cob, 20-7, 20-11, 20-12) ---
*>     Effects of a mob (ticks left, -1 = no expiry, 0 = none): the spider's Hard spawn effect (20 section 7.1) and the witch's potions (20 section 11).
       10 EN-FX-SPEED          BINARY-LONG.        *> Speed: the walk speed x 1.2
       10 EN-FX-STRENGTH       BINARY-LONG.        *> Strength: +3 attack damage
       10 EN-FX-REGEN          BINARY-LONG.        *> Regeneration: 1 health every 50 ticks
       10 EN-FX-INVIS          BINARY-LONG.        *> Invisibility (the entity flags sent to the viewers do not show it: open)
       10 EN-FX-FIRE           BINARY-LONG.        *> Fire Resistance (witch)
       10 EN-FX-WATER          BINARY-LONG.        *> Water Breathing (witch)
       10 EN-FALL              FLOAT-LONG.         *> creeper: the distance fallen in the air so far (20 section 6.1)
       10 EN-IGNITED           BINARY-LONG.        *> creeper: 1 when set off by flint and steel or a fire charge (20 section 6.1)
       10 EN-PH-PHASE          BINARY-LONG.        *> phantom: 0 CIRCLE, 1 SWOOP (20 section 12)
       10 EN-PH-TIMER          BINARY-LONG.        *> phantom: ticks until the next sweep
       10 EN-PH-SCAN           BINARY-LONG.        *> phantom: the target scan counter
       10 EN-PH-CW             BINARY-LONG.        *> phantom: clockwise sign, +1 or -1
       10 EN-PH-SET            BINARY-LONG.        *> phantom: 1 once the anchor is set
       10 EN-PH-AX             FLOAT-LONG.         *> phantom: anchor block (lower corner)
       10 EN-PH-AY             FLOAT-LONG.
       10 EN-PH-AZ             FLOAT-LONG.
       10 EN-PH-TX             FLOAT-LONG.         *> phantom: move target point
       10 EN-PH-TY             FLOAT-LONG.
       10 EN-PH-TZ             FLOAT-LONG.
       10 EN-PH-ANGLE          FLOAT-LONG.         *> phantom: circle angle in radians
       10 EN-PH-DIST           FLOAT-LONG.         *> phantom: circle distance
       10 EN-PH-HEIGHT         FLOAT-LONG.         *> phantom: circle height
       10 EN-PH-SPEED          FLOAT-LONG.         *> phantom: the move control speed (starts 0.1)
*>     --- end 002-lane-mobs2 ---
*>     --- 002-lane-mobsfull-h12: Nether and End mobs (core/src/mob-21-5.cob) ---
       10 EN-ANGER           BINARY-LONG.        *> zombified piglin, piglin: ticks of anger left (0 calm); the target is EN-TARGET
       10 EN-ALERT           BINARY-LONG.        *> ticks until an angry zombified piglin alerts the others again (alertOthers, 4 to 6 s)
*>     --- 002-lane-mobsfull-h14: saddles, riding, leads (core/src/mob-18-ride.cob; 18 sections 8.3 and 8.4, 19 sections 2.1 and 3) ---
       10 EN-SADDLE          BINARY-LONG.        *> 1 when the saddle slot holds a saddle (horse family, pig)
       10 EN-RIDER           BINARY-LONG.        *> player row riding this mob (0 none)
       10 EN-VEHICLE         BINARY-LONG.        *> on a player's entity: the tracker row of the mob it rides (0 none)
       10 EN-TEMPER          BINARY-LONG.        *> horse family: temper 0 to 100 (19 section 3.4)
       10 EN-LEASH           BINARY-LONG.        *> player row holding a lead on this mob (0 none; a fence knot holder is EN-LEASH-KNOT)
       10 EN-LEASH-KNOT      BINARY-LONG.        *> entity row of the leash_knot entity holding a lead on this mob (0 none; EN-LEASH is then 0)
*>     --- 002-lane-mobsfull-h15: surroundings and memory of a standard mob (core/src/mob-18-2.cob; 18 sections 2.5, 2.8) ---
       10 EN-AIR-LOST        BINARY-LONG.        *> air supply lost: the air is 300 less this (0 = full); 320 = air -20, drowning damage and back to 300
       10 EN-KILLER-AGE      BINARY-LONG.        *> ticks left of lastHurtByPlayerMemoryTime (100 after a hit by a player); at 0 EN-KILLER is cleared (0 = not counting)
*>     --- 002-lane-mobsfull-h18: pet care (core/src/mob-19-5.cob; 19 sections 5 and 6) ---
       10 EN-COLLAR          BINARY-LONG.        *> collar colour of a tame wolf or cat: the dye id + 1 (0 = never dyed, the default red 14)
*>     --- 002-lane-mobsfull-h20: bee (core/src/mob-19-16.cob; 19 section 16) ---
       10 EN-BEE-STUNG       BINARY-LONG.        *> bee: 1 once it has stung (metadata 18 bit 4)
       10 EN-BEE-NECTAR      BINARY-LONG.        *> bee: 1 while it carries nectar (metadata 18 bit 8)
       10 EN-BEE-ROLL        BINARY-LONG.        *> bee: 1 while angry with its target within 2 blocks (metadata 18 bit 2)
       10 EN-BEE-T           BINARY-LONG.        *> bee: ticks since the sting (timeSinceSting)
       10 EN-BEE-WET         BINARY-LONG.        *> bee: consecutive ticks in water
*>     --- 002-lane-mobsfull-h20: turtle (core/src/mob-19-12.cob; 19 section 12) ---
       10 EN-HOME-SET         BINARY-LONG.        *> turtle: 1 once its home is set (the block of its spawn)
       10 EN-HOME-X           BINARY-LONG.        *> turtle: home block
       10 EN-HOME-Y           BINARY-LONG.
       10 EN-HOME-Z           BINARY-LONG.
       10 EN-TURTLE-EGG       BINARY-LONG.        *> turtle: 1 while it carries an egg (hasEgg, metadata 18)
       10 EN-TURTLE-LAY       BINARY-LONG.        *> turtle: layEggCounter, 0 = not laying (layingEgg, metadata 19, is counter > 0)
*>     --- 002-lane-mobsfull-h20: armadillo (core/src/mob-19-13.cob; 19 section 13) ---
       10 EN-ARMA            BINARY-LONG.        *> armadillo: state 0 idle, 1 rolling, 2 scared, 3 unrolling (metadata 18)
       10 EN-ARMA-T          BINARY-LONG.        *> armadillo: ticks left of the rolling (10) or unrolling (30) state
       10 EN-ARMA-SCAN       BINARY-LONG.        *> armadillo: ticks since the last danger scan (every 80)
       10 EN-DANGER          BINARY-LONG.        *> armadillo: ticks left of danger_detected_recently (80)
       10 EN-SCUTE           BINARY-LONG.        *> armadillo: scuteTime, ticks to the next scute
*>     --- 002-lane-mobsb: piglin (core/src/mob-21-piglin.cob; 21 section 5.5.1) ---
       10 EN-ADMIRE          BINARY-LONG.        *> piglin: ticks of admiring left (119 after a gold ingot), 0 = not admiring
       10 EN-ADMIRE-OFF      BINARY-LONG.        *> piglin: ticks left of ADMIRING_DISABLED (400 after a cancelled admiring)
       10 EN-ADMIRE-PL       BINARY-LONG.        *> piglin: the player row that gave the ingot
       10 EN-ZOMBIFY         BINARY-LONG.        *> piglin: timeInOverworld, ticks spent where piglins_zombify is true (converts above 300)
       10 EN-ADMIRE-CUR      BINARY-LONG.        *> piglin: 1 when the admired item is barter currency (it barters when the admiring ends), 0 a kept loved item
*>     --- 002-lane-mobsfull-h21: tadpole, frog, panda, fox, allay, sniffer, llama, camel (core/src/mob-19-7.cob to mob-19-15.cob) ---
       10 EN-TAD-AGE          BINARY-LONG.        *> tadpole: age in ticks (24000 = frog); locked with EN-LOCKED
       10 EN-TONGUE           BINARY-LONG.        *> frog: tongue state 0 none, 1 moving to the target, 2 catch animation, 3 eat animation
       10 EN-TONGUE-T         BINARY-LONG.        *> frog: animation timer of the tongue
       10 EN-TONGUE-ROW       BINARY-LONG.        *> frog: tracker row of the tongue target and its entity id in EN-TONGUE-ID
       10 EN-TONGUE-ID        BINARY-LONG.
       10 EN-GENE-MAIN        BINARY-LONG.        *> panda: main gene (0 normal, 1 lazy, 2 worried, 3 playful, 4 brown, 5 weak, 6 aggressive)
       10 EN-GENE-HIDDEN      BINARY-LONG.        *> panda: hidden gene
       10 EN-PANDA-SNEEZE     BINARY-LONG.        *> panda: sneeze counter (metadata 19), 0 = not sneezing
       10 EN-FOX-HELD         BINARY-LONG.        *> fox: item id in the main hand (0 empty); dropped on death
       10 EN-FOX-TRUST-A      PIC X(16).          *> fox: UUID of the first trusted player (spaces: none; metadata 20)
       10 EN-FOX-TRUST-B      PIC X(16).          *> fox: UUID of the second trusted player (metadata 21)
       10 EN-ALLAY-ITEM       BINARY-LONG.        *> allay: item id held in the main hand (0 empty)
       10 EN-ALLAY-LIKED      PIC X(16).          *> allay: UUID of the liked player (spaces: none)
       10 EN-ALLAY-DUP        BINARY-LONG.        *> allay: ticks of duplication cooldown left (metadata 17 canDuplicate is true at 0)
       10 EN-ALLAY-DANCE      BINARY-LONG.        *> allay: 1 while dancing (metadata 16)
       10 EN-ALLAY-T          BINARY-LONG.        *> allay: ticks since the last regeneration
       10 EN-STRENGTH         BINARY-LONG.        *> llama: strength 1 to 5 (metadata 20); the variant 0 to 3 is EN-WOOL (metadata 21)
*>     --- 002-lane-mobsfull-h23: wolf armour (core/src/mob-19-6.cob; 19 section 6.1) ---
       10 EN-WOLF-ARM         BINARY-LONG.        *> wolf: item id of the armour in the body slot (0 none)
       10 EN-WOLF-ARM-DMG     BINARY-LONG.        *> wolf: durability damage of that armour
*>     --- 002-lane-mobsfull-h23: sniffer (core/src/mob-19-14.cob; 19 section 14) ---
       10 EN-SNIF            BINARY-LONG.        *> sniffer: state 0 idling, 1 feeling happy, 2 scenting, 3 sniffing, 4 searching, 5 digging, 6 rising (metadata 18)
       10 EN-SNIF-T          BINARY-LONG.        *> sniffer: ticks left of a timed state (1 to 3)
       10 EN-SNIF-SEED       BINARY-LONG.        *> sniffer: tick at which the seed drops while digging (metadata 19)
       10 EN-SNIF-EXP-N      BINARY-LONG.        *> sniffer: number of explored positions (at most 20, newest first)
       10 EN-SNIF-EXP OCCURS 20 TIMES.
          15 EN-SNIF-EXP-X   BINARY-LONG.
          15 EN-SNIF-EXP-Y   BINARY-LONG.
          15 EN-SNIF-EXP-Z   BINARY-LONG.
*>     --- 002-lane-mobsfull-h24: falling block entity (core/src/mob-21-8.cob; 21 section 8.4, 29b part 1 section 4) ---
       10 EN-FB-STATE         BINARY-LONG.        *> falling block: the block state id it carries (0 = not a falling block); the Add Entity Data
       10 EN-FB-TIME          BINARY-LONG.        *> falling block: ticks lived
       10 EN-FB-CANCEL        BINARY-LONG.        *> falling block: cancelDrop, 1 = it never places itself
*>     --- 002-lane-mobsfull-h24: boats and rafts (core/src/mob-21-boat.cob; 21 section 8.8, 44 part 8 section 3) ---
       10 EN-BT-KIND          BINARY-LONG.        *> boat: 1 boat or raft, 2 chest boat or raft (0 = not a boat)
       10 EN-BT-HURT          BINARY-LONG.        *> boat: hurt time (metadata 8)
       10 EN-BT-HDIR          BINARY-LONG.        *> boat: hurt direction (metadata 9), 1 or -1
       10 EN-BT-DAMAGE        BINARY-LONG.        *> boat: damage (metadata 10, whole points x 10)
       10 EN-BT-OOC           BINARY-LONG.        *> boat: outOfControlTicks (ticks under water)
       10 EN-BT-STATUS        BINARY-LONG.        *> boat: the last status, 0 in water, 1 under water, 2 under flowing water, 3 on land, 4 in air, 5 none yet
       10 EN-BT-LASTYD        FLOAT-LONG.         *> boat: the vertical speed of the last move (lastYd)
       10 EN-BT-WLEVEL        FLOAT-LONG.         *> boat: waterLevel of the last status
*>     --- 002-lane-mobsfull-h25: saved mob state (core/src/entity-mobdata.cob) ---
       10 EN-LEASH-UUID      PIC X(16).          *> a mob loaded leashed: the UUID of the holder until that player is in the dimension (MOB-LEASH-RESTORE); spaces: none
       10 EN-RIDER2          BINARY-LONG.        *> a camel: the player row of its second rider, the rear seat (0 none; EN-RIDER is the first)
*>     --- 002-lane-tempt: the TemptGoal (core/src/mob-18-tempt.cob; 18 section 4.7) ---
       10 EN-TEMPT           BINARY-LONG.        *> 0 idle, -1 the tempt goal runs, above 0 the ticks of cooldown left after it stopped (100)
*>     --- 002-lane-mobsa2: species leftovers of documents 19 and 44 part 4 (core/src/mob-44-*.cob) ---
       10 EN-FOX-FLAGS        BINARY-LONG.        *> fox: metadata 19 flags byte (4 crouching, 8 interested, 16 pouncing, 32 sleeping, 64 faceplanted, 128 defending)
       10 EN-FOX-CROUCH       BINARY-LONG.        *> fox: ticks crouched, 0 to 25 (crouch amount 0.2 a tick up to 5.0)
       10 EN-PANDA-FLAGS      BINARY-LONG.        *> panda: metadata 23 flags byte, the sneeze bit 2 excluded (4 rolling, 8 sitting, 16 on back)
       10 EN-PANDA-EAT        BINARY-LONG.        *> panda: eating counter (metadata 20)
       10 EN-PANDA-T          BINARY-LONG.        *> panda: ticks of the current roll or lie on the back
       10 EN-PANDA-HAND       BINARY-LONG.        *> panda: item id held in the mouth (0 none)
       10 EN-RAM-STATE        BINARY-LONG.        *> goat: 0 none, 1 preparing to ram, 2 ramming
       10 EN-RAM-T            BINARY-LONG.        *> goat: ticks of the prepare phase
       10 EN-RAM-CD           BINARY-LONG.        *> goat: ticks until it may ram again
       10 EN-RAM-DX           FLOAT-LONG.         *> goat: the ram direction (unit, horizontal)
       10 EN-RAM-DZ           FLOAT-LONG.
       10 EN-RAM-PX           FLOAT-LONG.         *> goat: the ram point (where the charge ends)
       10 EN-RAM-PZ           FLOAT-LONG.
       10 EN-ARMA-PEEK        BINARY-LONG.        *> armadillo: peek timer (ArmadilloBallUp)
       10 EN-ARMA-AROUND      BINARY-LONG.        *> armadillo: the stored danger-around flag
       10 EN-BEE-POLL         BINARY-LONG.        *> bee: ticks of the current pollination (pollinatingTicks)
       10 EN-BEE-SUCC         BINARY-LONG.        *> bee: successfulPollinatingTicks
       10 EN-BEE-CD           BINARY-LONG.        *> bee: ticks until it looks for a flower again
       10 EN-BEE-CROPS        BINARY-LONG.        *> bee: crops grown since the last pollination
       10 EN-LLAMA-HEAD       BINARY-LONG.        *> llama: tracker row of the llama in front in a caravan (0 none)
       10 EN-LLAMA-TAIL       BINARY-LONG.        *> llama: tracker row of the llama behind it (0 none)
*>     --- 002-lane-mobsa5: llama caravan and spit (core/src/mob-44-p.cob) ---
       10 EN-SPIT-TGT         BINARY-LONG.        *> llama: player row it spits at (0 none)
       10 EN-SPIT-CD          BINARY-LONG.        *> llama: attackTime of the ranged attack goal (-1 not started)
       10 EN-SPIT-AGE         BINARY-LONG.        *> llama: the last EN-KILLER-AGE seen (a rise is a new hit)
*>     --- 002-lane-mobsa5: fox melee, sleep, faceplant, berries and item search (core/src/mob-44-q.cob) ---
       10 EN-FOX-ATK          BINARY-LONG.        *> fox: ticks until the melee attack may hit again
       10 EN-FOX-SLP          BINARY-LONG.        *> fox: the sleep countdown + 1 (0 = not rolled yet)
       10 EN-FOX-FP           BINARY-LONG.        *> fox: faceplant countdown (0 = not started)
       10 EN-FOX-BON          BINARY-LONG.        *> fox: 1 while a berry bush is the target
       10 EN-FOX-BX           BINARY-LONG.        *> fox: the berry bush block
       10 EN-FOX-BY           BINARY-LONG.
       10 EN-FOX-BZ           BINARY-LONG.
       10 EN-FOX-BT           BINARY-LONG.        *> fox: ticks waited at the bush
       10 EN-FOX-BCD          BINARY-LONG.        *> fox: ticks until the next bush search
       10 EN-FOX-ITEM         BINARY-LONG.        *> fox: entity id of the ground item it walks to (0 none)
*>     --- 002-lane-mobsa5: riding jump (core/src/mob-44-r.cob) ---
       10 EN-HORSE-JUMP        FLOAT-LONG.         *> horse: the jump strength attribute (0.4 to 1.0, drawn at spawn; 0 = not drawn: a loaded horse)
       10 EN-LLAMA-SPIT       BINARY-LONG.        *> llama: didSpit
       10 EN-LLAMA-SPEED      FLOAT-LONG.         *> llama: the caravan follow speed (2.1 at the start)
       10 EN-LLAMA-DIST       BINARY-LONG.        *> llama: the caravan distance counter
       10 EN-CAMEL-DASH       BINARY-LONG.        *> camel: ticks of the dash cooldown left
       10 EN-CAMEL-POSE       BINARY-LONG.        *> camel: 0 standing, 1 sitting
       10 EN-CAMEL-POSE-T     BINARY-LONG.        *> camel: game tick of the last pose change
       10 EN-FROG-CD          BINARY-LONG.        *> frog: ticks until the next long jump
       10 EN-SNIF-CD          BINARY-LONG.        *> sniffer: ticks of the sniff cooldown left (9600 after a dig)
       10 EN-SENT-X           FLOAT-LONG.         *> the position last sent to the viewers (18 section 9.2)
       10 EN-SENT-Y           FLOAT-LONG.
       10 EN-SENT-Z           FLOAT-LONG.
       10 EN-SENT-YAW         FLOAT-SHORT.
       10 EN-SENT-PITCH       FLOAT-SHORT.
       10 EN-FLY-ON           BINARY-LONG.        *> a flier: 1 while it has a wanted point (EN-FLY-X/Y/Z, core/src/mob-44-f.cob)
       10 EN-FLY-X            FLOAT-LONG.
       10 EN-FLY-Y            FLOAT-LONG.
       10 EN-FLY-Z            FLOAT-LONG.
       10 EN-FLY-MOD          FLOAT-LONG.         *> the speed modifier of the wanted point (0 = 1.0)
       10 EN-SENT-AGE         BINARY-LONG.        *> ticks since the last absolute position sent (a full sync every 400)
       10 EN-CAT-RELAX        BINARY-LONG.        *> tame cat: 1 while it relaxes on its sleeping owner, 2 once the owner has slept 100 ticks (CatRelaxOnOwnerGoal)
*>     --- 002-lane-mobsa4: allay items and the liked note block (core/src/mob-44-j.cob) ---
       10 EN-ALLAY-COUNT      BINARY-LONG.        *> allay: items of the held kind in its inventory (EN-ALLAY-ITEM is the main hand copy)
       10 EN-ALLAY-CD         BINARY-LONG.        *> allay: item pickup cooldown ticks (ITEM_PICKUP_COOLDOWN_TICKS)
       10 EN-ALLAY-NB-CD      BINARY-LONG.        *> allay: liked note block cooldown ticks (LIKED_NOTEBLOCK_COOLDOWN_TICKS)
       10 EN-ALLAY-NB-ON      BINARY-LONG.        *> allay: 1 while a liked note block position is stored
       10 EN-ALLAY-NB-DIM     BINARY-LONG.
       10 EN-ALLAY-NB-X       BINARY-LONG.
       10 EN-ALLAY-NB-Y       BINARY-LONG.
       10 EN-ALLAY-NB-Z       BINARY-LONG.
*>     --- 002-lane-mobsa4: bee flowers and hive trips (core/src/mob-44-k.cob) ---
       10 EN-BEE-FL-ON         BINARY-LONG.        *> bee: 1 while a flower position is remembered
       10 EN-BEE-FL-X          BINARY-LONG.
       10 EN-BEE-FL-Y          BINARY-LONG.
       10 EN-BEE-FL-Z          BINARY-LONG.
       10 EN-BEE-HV-ON         BINARY-LONG.        *> bee: 1 while a hive position is remembered
       10 EN-BEE-HV-X          BINARY-LONG.
       10 EN-BEE-HV-Y          BINARY-LONG.
       10 EN-BEE-HV-Z          BINARY-LONG.
       10 EN-BEE-STAY          BINARY-LONG.        *> bee: stayOutOfHiveCountdown
       10 EN-BEE-NONECT        BINARY-LONG.        *> bee: ticks since the last pollination
       10 EN-BEE-VAL           BINARY-LONG.        *> bee: ticks until the flower and hive are validated again
       10 EN-BEE-LOC           BINARY-LONG.        *> bee: ticks until it looks for a hive again
       10 EN-BEE-TRIP          BINARY-LONG.        *> bee: ticks travelled toward the hive (given up after 2400)
       10 EN-BEE-HOX           FLOAT-LONG.         *> bee: the hover offset above a flower
       10 EN-BEE-HOZ           FLOAT-LONG.
*>     --- 002-lane-mobsa4: frog long jump (core/src/mob-44-m.cob) ---
       10 EN-FROG-JS           BINARY-LONG.        *> frog: 0 no jump behaviour, 1 preparing, 3 mid-jump
       10 EN-FROG-CH           BINARY-LONG.        *> frog: 1 once a jump is chosen
       10 EN-FROG-JT           BINARY-LONG.        *> frog: ticks since the jump was chosen
       10 EN-FROG-TRIES        BINARY-LONG.        *> frog: tries left (20 at the start)
       10 EN-FROG-LIFE         BINARY-LONG.        *> frog: ticks the behaviour has run (time-out 200)
       10 EN-FROG-PREF         BINARY-LONG.        *> frog: 1 when it wants a preferred block (chance 0.5)
       10 EN-FROG-SX           BINARY-LONG.        *> frog: the start block of the behaviour
       10 EN-FROG-SY           BINARY-LONG.
       10 EN-FROG-SZ           BINARY-LONG.
       10 EN-FROG-TX           BINARY-LONG.        *> frog: the chosen target block
       10 EN-FROG-TY           BINARY-LONG.
       10 EN-FROG-TZ           BINARY-LONG.
       10 EN-FROG-MIDT         BINARY-LONG.        *> frog: ticks of the mid-jump
       10 EN-FROG-JVX          FLOAT-LONG.         *> frog: the launch vector
       10 EN-FROG-JVY          FLOAT-LONG.
       10 EN-FROG-JVZ          FLOAT-LONG.
*>     --- 002-lane-mobsb7: mobs riding mobs (core/src/mob-mount.cob; 18 section 8.4) ---
       10 EN-MOUNT           BINARY-LONG.        *> a mob riding another mob: the tracker row of its vehicle (0 none)
       10 EN-MOUNT-ID        BINARY-LONG.        *> and that vehicle's entity id (guards a reused row)
       10 EN-PASS            BINARY-LONG.        *> a mob with a mob rider: the tracker row of the rider (0 none)
       10 EN-JOCKEY          BINARY-LONG.        *> a chicken: 1 when it is a chicken jockey (never lays eggs)
*>     --- 002-lane-mobsb7: the strider (core/src/mob-21-strider.cob; 21 section 5.7) ---
       10 EN-COLD            BINARY-LONG.        *> strider: 1 when suffocating (not on or in lava; metadata 19)
       10 EN-BOOST           BINARY-LONG.        *> strider: the boost total in ticks (metadata 18)
       10 EN-BOOST-T         BINARY-LONG.        *> strider: ticks into the boost
       10 EN-BOOSTING        BINARY-LONG.        *> strider: 1 while boosting
*>     --- 002-lane-genent: mobs made by structures (core/src/gen-ent.cob) ---
       10 EN-PERSISTENT      BINARY-LONG.        *> PersistenceRequired: 1 when the mob never despawns (a mob of a structure template or marker; saved and read as the key)
*>     --- 002-lane-p49k: the Entity base keys that the saved compound carries (45-1 section 5; core/src/entity-nbt-1.cob) ---
       10 EN-INVULN          BINARY-LONG.        *> Invulnerable: the permanent flag (not the hit window), 1 = set
       10 EN-PORTAL-CD       BINARY-LONG.        *> PortalCooldown: ticks left
       10 EN-INVTIME         BINARY-LONG.        *> invulnerable_time: the post-hit counter, written only above 0
       10 EN-SILENT          BINARY-LONG.        *> Silent
       10 EN-NOGRAV          BINARY-LONG.        *> NoGravity
       10 EN-GLOW            BINARY-LONG.        *> Glowing (the glowing tag)
       10 EN-VISFIRE         BINARY-LONG.        *> HasVisualFire
       10 EN-NAME-VIS        BINARY-LONG.        *> CustomNameVisible
       10 EN-FROZEN          BINARY-LONG.        *> TicksFrozen

*> What each player's client has been sent (US3-5): VW-SEEN(player row)(entity row:1) is "1" while
*> that client has the entity (Add Entity sent, Remove Entities not yet).
 01 CORE-VIEWS EXTERNAL.
    05 VW-ENTRY OCCURS 64 TIMES.
       10 VW-SEEN            PIC X(1024).

*> Players who have been in the world (US4-8: the survival starting items are given once, to a
*> first-time player). One offline UUID per row, KN-COUNT rows used; a full table records no more.
*> A player whose file players/<uuid>.dat exists (07 §9.2) becomes known when it joins (the file is
*> read into a row: core/src/persistence.cob). A player who left while dead (standin §10.6,
*> data-model §6) keeps that death in KN-DEATH-CAUSE (0 = left alive) and KN-KILLER-*: on the next
*> join the player is dead again and is shown the death screen. A player who has left keeps the
*> dimension, position and facing it left from (KN-PLACED 1; US12-3, data-model §6 "state stored"):
*> the next join restores them while that dimension is enabled.
 78 CORE-MAX-KNOWN          VALUE 4096.
 01 CORE-KNOWN EXTERNAL.
    05 KN-COUNT              BINARY-LONG.
    05 KN-UUID               PIC X(16) OCCURS 4096 TIMES.
    05 KN-DEATH-CAUSE        BINARY-LONG OCCURS 4096 TIMES.
    05 KN-KILLER-NAME        PIC X(16) OCCURS 4096 TIMES.
    05 KN-KILLER-LENGTH      BINARY-LONG OCCURS 4096 TIMES.
    05 KN-PLACE OCCURS 4096 TIMES.
       10 KN-PLACED          PIC 9.
       10 KN-DIM             BINARY-LONG.
       10 KN-X               FLOAT-LONG.
       10 KN-Y               FLOAT-LONG.
       10 KN-Z               FLOAT-LONG.
       10 KN-YAW             FLOAT-SHORT.
       10 KN-PITCH           FLOAT-SHORT.
*>  The rest of the stored state of a player (FR-014; 07 §9.2 players/<uuid>.dat): KN-STORED 1 once
*>  a leave or a player file filled it (the next join restores game mode, health, food, held slot and
*>  inventory); KN-DIRTY 1 while it has changed since the last world save (the save writes its file).
    05 KN-STATE OCCURS 4096 TIMES.
       10 KN-STORED          PIC 9.
       10 KN-DIRTY           PIC 9.
       10 KN-NAME            PIC X(16).
       10 KN-NAME-LENGTH     BINARY-LONG.
       10 KN-MODE            PIC 9.
       10 KN-HEALTH          FLOAT-SHORT.
       10 KN-FOOD            BINARY-LONG.
       10 KN-HELD            BINARY-LONG.
       10 KN-INVENTORY       PIC X(288).         *> the PL-INVENTORY bytes

*> Access lists of the world (FR-016, US13-4; 07 §9.2 access.dat; core/src/access.cob): list
*> ACCESS-OPERATORS, ACCESS-BANS and ACCESS-ALLOW, each up to CORE-MAX-ACCESS offline identities
*> (name and offline UUID), and whether the allow-list is enforced in this world (operator decision
*> A2: a new world seeds it from the settings, an existing world keeps its stored value).
 78 CORE-MAX-ACCESS         VALUE 256.
 78 ACCESS-OPERATORS        VALUE 1.
 78 ACCESS-BANS             VALUE 2.
 78 ACCESS-ALLOW            VALUE 3.
 78 ACCESS-IPBANS           VALUE 4.   *> IPv4 addresses (the name field holds the dotted text, the UUID is empty)
 01 CORE-ACCESS EXTERNAL.
    05 AC-ENFORCED           PIC 9.
    05 AC-LIST OCCURS 4 TIMES.
       10 AC-COUNT           BINARY-LONG.
       10 AC-ENTRY OCCURS 256 TIMES.
          15 AC-NAME         PIC X(16).
          15 AC-NAME-LENGTH  BINARY-LONG.
          15 AC-UUID         PIC X(16).
*>        The rest of an entry (07 §9.2): AC-LEVEL the permission level of an operator (1 to 4, 4 for a new one; 0 in the other lists);
*>        of a ban the creation time as text, the source (the text name of whoever banned), the expiry text (forever) and the reason
*>        (length 0 = none).
          15 AC-LEVEL        BINARY-LONG.
          15 AC-CREATED      PIC X(32).
          15 AC-CREATED-LENGTH BINARY-LONG.
          15 AC-SOURCE       PIC X(32).
          15 AC-SOURCE-LENGTH BINARY-LONG.
          15 AC-EXPIRES      PIC X(32).
          15 AC-EXPIRES-LENGTH BINARY-LONG.
          15 AC-REASON       PIC X(128).
          15 AC-REASON-LENGTH BINARY-LONG.
