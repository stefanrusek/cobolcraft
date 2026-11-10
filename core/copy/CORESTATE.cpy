*> Core state (contracts/core-host-api.md: one world per process; data-model.md §1 to §3, §6, §12).
*> Every record is EXTERNAL: each core program that COPYs this book sees the same storage.
*> CORE-WORLD-OPEN initialises every record. Buffers are kept as the raw bytes of a PB-BUFFER
*> (contract/copy/PROTO.cpy, CORE-PB-SIZE bytes): a program moves them into its own PB-BUFFER,
*> works on it and moves them back, so the PROTO.cpy shape is never redefined here.

 78 CORE-MAX-CONNS          VALUE 64.
 78 CORE-MAX-PLAYERS        VALUE 64.
 78 CORE-MAX-DIMS           VALUE 3.
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
    05 CW-SPAWN-X            FLOAT-LONG.
    05 CW-SPAWN-Y            FLOAT-LONG.
    05 CW-SPAWN-Z            FLOAT-LONG.
    05 CW-SPAWN-YAW          FLOAT-SHORT.
    05 CW-DIM-COUNT          BINARY-LONG.        *> enabled dimensions, in Login order
    05 CW-DIM                BINARY-LONG OCCURS 3 TIMES.   *> row of the DIMENSIONS.cpy table
*>  Weather (docs/protocol/33 section 4; core/src/weather.cob): one WeatherData for the whole server (the times in
*>  ticks and the two flags) and, per DIMENSIONS.cpy row, the levels 0 to 1 and the levels of the tick before.
    05 CW-WEATHER-DATA.
       10 CW-CLEAR-TIME      BINARY-LONG.
       10 CW-RAIN-TIME       BINARY-LONG.
       10 CW-THUNDER-TIME    BINARY-LONG.
       10 CW-RAINING         PIC 9.
       10 CW-THUNDERING      PIC 9.
    05 CW-WEATHER-LEVELS OCCURS 3 TIMES.
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
*>     Hunger (standin §11; core/src/hunger.cob): exhaustion (§11.2, not saved), the sprinting flag of
*>     Player Command, the food item being eaten (0 = not eating) with its hotbar slot and the CW-TICKS
*>     of the Use Item that started it (§11.6), and the consecutive ticks at food 0 (§10.3).
       10 PL-EXHAUSTION      FLOAT-LONG.
       10 PL-SATURATION      FLOAT-LONG.         *> 17 section 4.9: 0 to the food level, 5.0 for a new player
       10 PL-SPRINTING       PIC 9.
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
       10 PL-BREAK-RATE      FLOAT-SHORT.        *> progress per tick (13 section 2.1), fixed at the start
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
*>     Travel (standin §15.5; core/src/dimensions.cob): 1 once the player has travelled this
*>     session, and the CW-TICKS of that travel (a use within TRAVEL-COOLDOWN ticks is ignored).
       10 PL-TRAVELLED       PIC 9.
       10 PL-TRAVEL-TICK     BINARY-DOUBLE.

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
       10 CK-SOURCES         BINARY-LONG OCCURS 24 TIMES.

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
 01 CORE-ACCESS EXTERNAL.
    05 AC-ENFORCED           PIC 9.
    05 AC-LIST OCCURS 3 TIMES.
       10 AC-COUNT           BINARY-LONG.
       10 AC-ENTRY OCCURS 256 TIMES.
          15 AC-NAME         PIC X(16).
          15 AC-NAME-LENGTH  BINARY-LONG.
          15 AC-UUID         PIC X(16).
