*> Core state (contracts/core-host-api.md: one world per process; data-model.md §1 to §3, §6, §12).
*> Every record is EXTERNAL: each core program that COPYs this book sees the same storage.
*> CORE-WORLD-OPEN initialises every record. Buffers are kept as the raw bytes of a PB-BUFFER
*> (contract/copy/PROTO.cpy, CORE-PB-SIZE bytes): a program moves them into its own PB-BUFFER,
*> works on it and moves them back, so the PROTO.cpy shape is never redefined here.

 78 CORE-MAX-CONNS          VALUE 64.
 78 CORE-MAX-PLAYERS        VALUE 64.
 78 CORE-MAX-DIMS           VALUE 2.
 78 CORE-MAX-CHUNKS         VALUE 4096.
 78 CORE-PB-SIZE            VALUE 21.     *> LENGTH OF PB-BUFFER
 78 CORE-SETTINGS-SIZE      VALUE 1707.   *> LENGTH OF CORE-SETTINGS
 78 CORE-CHUNK-CELLS        VALUE 65536.  *> 16 x 256 x 16 cells, index y * 256 + z * 16 + x
 78 CORE-CHUNK-BYTES        VALUE 196608. *> states, sky light, block light: one byte per cell each
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

*> Set Time is sent to every player in play every 20 ticks (09 §3.2 Set Time row).
 78 CORE-TIME-TICKS         VALUE 20.

*> World (data-model §1).
 01 CORE-WORLD EXTERNAL.
    05 CW-OPEN               PIC X.              *> "Y" once CORE-WORLD-OPEN has run
    05 CW-SETTINGS           PIC X(1707).        *> the CORE-SETTINGS bytes of CORE-WORLD-OPEN
    05 CW-FOLDER             PIC X(1024).
    05 CW-FOLDER-LENGTH      BINARY-LONG.
    05 CW-NAME               PIC X(64).
    05 CW-TIME               BINARY-DOUBLE.      *> time of day 0 to 29999 (standin §4.8)
    05 CW-TICKS              BINARY-DOUBLE.      *> ticks run since the world was opened
    05 CW-SPAWN-X            FLOAT-LONG.
    05 CW-SPAWN-Y            FLOAT-LONG.
    05 CW-SPAWN-Z            FLOAT-LONG.
    05 CW-SPAWN-YAW          FLOAT-SHORT.
    05 CW-DIM-COUNT          BINARY-LONG.        *> enabled dimensions, in Login order
    05 CW-DIM                BINARY-LONG OCCURS 2 TIMES.   *> row of the DIMENSIONS.cpy table
    05 CW-RUN-STATE          PIC 9.              *> CST-RUN-STATE
    05 CW-NEXT-ENTITY-ID     BINARY-LONG.
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
       10 PL-EXHAUSTION      FLOAT-SHORT.
       10 PL-SPRINTING       PIC 9.
       10 PL-EATING-ITEM     BINARY-LONG.        *> 0 = not eating
       10 PL-EATING-START    BINARY-DOUBLE.
       10 PL-OPERATOR        PIC 9.
       10 PL-HELD            BINARY-LONG.        *> hotbar slot 0 to 8
       10 PL-SLOT OCCURS 36 TIMES.               *> inventory slot n is PL-SLOT(n + 1)
          15 PL-SLOT-ITEM    BINARY-LONG.
          15 PL-SLOT-COUNT   BINARY-LONG.        *> 0 = empty
       10 PL-STATE-ID        BINARY-LONG.        *> container 0 state id
       10 PL-VIEW-DISTANCE   BINARY-LONG.        *> Client Information view distance
       10 PL-CENTER-X        BINARY-LONG.        *> chunk cache center
       10 PL-CENTER-Z        BINARY-LONG.
       10 PL-BATCH-PENDING   BINARY-LONG.        *> chunk batches sent and not yet acknowledged
       10 PL-ENTITY-ROW      BINARY-LONG.        *> CORE-ENTITIES row; 0 until the join is sent

*> Chunk cache (data-model §2, §3): one row per loaded chunk of any dimension. CK-ADDR points to
*> CORE-CHUNK-BYTES bytes: block states (cells 1 to 65536), sky light (65537 to 131072) and block
*> light (131073 to 196608), cell index y * 256 + z * 16 + x (+ 1). CK-INDEX is a hash index into
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
       10 CK-SOURCES         BINARY-LONG OCCURS 16 TIMES.

*> Entity tracker (data-model §5 to §7; 09 §3.2 entity rows; core/src/entities.cob). One row per
*> entity in the world that other players can see: players once their join is sent (EN-PLAYER is
*> the player row), later ground items and mobs. EN-X to EN-ON-GROUND are the values last sent to the
*> viewers (the base of the next Move Entity delta). EN-COUNT is the highest row number ever used.
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

*> What each player's client has been sent (US3-5): VW-SEEN(player row)(entity row:1) is "1" while
*> that client has the entity (Add Entity sent, Remove Entities not yet).
 01 CORE-VIEWS EXTERNAL.
    05 VW-ENTRY OCCURS 64 TIMES.
       10 VW-SEEN            PIC X(1024).
