*> State of the portal rules (docs/protocol/39-portals.md; core/src/portal-39.cob, portals.cob). Every record is EXTERNAL (zero at start;
*> CORE-WORLD-OPEN empties POI and players).
*> PORTAL-IDS: the block ids and states of the open content set, resolved by key again when CB-EPOCH changes (-1 when absent).
 01 PORTAL-IDS EXTERNAL.
    05 PI-EPOCH               BINARY-LONG.
    05 PI-OBSIDIAN            BINARY-LONG.
    05 PI-PORTAL              BINARY-LONG.
    05 PI-FIRE                BINARY-LONG.
    05 PI-SOUL-FIRE           BINARY-LONG.
    05 PI-AIR                 BINARY-LONG.
    05 PI-CAVE-AIR            BINARY-LONG.
    05 PI-VOID-AIR            BINARY-LONG.
    05 PI-PORTAL-X            BINARY-LONG.
    05 PI-PORTAL-Z            BINARY-LONG.
    05 PI-WATER               BINARY-LONG.
    05 PI-LAVA                BINARY-LONG.
*> PORTAL-POI: the points of interest of type nether_portal (44 section 1.4a: one for every portal block), kept while the world is open.
*> The core keeps no POI region files; a chunk loaded from a region file registers the portal blocks it holds (PORTAL-POI-SCAN).
 78 PQ-POI-MAX               VALUE 8192.
 01 PORTAL-POI EXTERNAL.
    05 PQ-POI-COUNT           BINARY-LONG.
    05 PQ-POI OCCURS 8192 TIMES.
       10 PQ-P-DIM            BINARY-LONG.
       10 PQ-P-X              BINARY-LONG.
       10 PQ-P-Y              BINARY-LONG.
       10 PQ-P-Z              BINARY-LONG.
*> PORTAL-PLAYERS: the entity-side portal process of each player row (39 section 2.1): owner entity id (a different one resets the
*> record), portalCooldown, process present, portalTime, insidePortalThisTick and the entry position.
 01 PORTAL-PLAYERS EXTERNAL.
    05 PQ-PL OCCURS 64 TIMES.
       10 PQ-PL-OWNER         BINARY-LONG.
       10 PQ-PL-COOLDOWN      BINARY-LONG.
       10 PQ-PL-PROCESS       BINARY-LONG.
       10 PQ-PL-TIME          BINARY-LONG.
       10 PQ-PL-FLAG          BINARY-LONG.
       10 PQ-PL-EX            BINARY-LONG.
       10 PQ-PL-EY            BINARY-LONG.
       10 PQ-PL-EZ            BINARY-LONG.
       10 PQ-PL-CHANGING      BINARY-LONG.
*> PORTAL-LIMITS: PQ-LOGICAL-CAP, when above 0, caps the logical height PORTAL-TOP uses (the logical_height field of a dimension type; every
*> built-in dimension of the table has at least 128, so tests set it to emulate a datapack dimension type with a small one). 0 is no cap.
 01 PORTAL-LIMITS EXTERNAL.
    05 PQ-LOGICAL-CAP         BINARY-LONG.
*> Portal rule constants (39 section 1.1).
 78 PQ-MIN-WIDTH             VALUE 2.
 78 PQ-MAX-WIDTH             VALUE 21.
 78 PQ-MIN-HEIGHT            VALUE 3.
 78 PQ-MAX-HEIGHT            VALUE 21.
 78 PQ-PLACE-FLAGS           VALUE 18.
 78 PQ-RADIUS-NETHER         VALUE 16.
 78 PQ-RADIUS-OVERWORLD      VALUE 128.
 78 PQ-SPIRAL-RADIUS         VALUE 16.
 78 PQ-PLAYER-COOLDOWN       VALUE 10.
 78 PQ-DECAY                 VALUE 4.
 78 PQ-DEFAULT-DELAY         VALUE 80.
 78 PQ-CREATIVE-DELAY        VALUE 0.
