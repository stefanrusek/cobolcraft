*> The running state of the dragon fight (core/src/fight-44.cob; docs/protocol/21 section 6.4.5), EXTERNAL; the saved part is END-FIGHT (ENDFIGHT.cpy). FR-DIM is the End's dimension row (0 = no fight),
*> FR-SCANNED 1 after the first scan of the state, FR-SEEN the ticks since the dragon was seen, FR-CRYSTALS the living pillar crystals (recounted every 100 ticks), FR-BAR 1 while the boss bar exists,
*> FR-BAR-N and FR-BAR-PLAYER the uuids of the players on it, FR-PROG the progress last sent (thousandths), FR-RC the entity ids of the respawn crystals (FR-RC-N of them).
 01 FR-STATE EXTERNAL.
    05 FR-DIM               BINARY-LONG.
    05 FR-SCANNED           BINARY-LONG.
    05 FR-SEEN              BINARY-LONG.
    05 FR-CRYSTALS          BINARY-LONG.
    05 FR-BAR               BINARY-LONG.
    05 FR-BAR-N             BINARY-LONG.
    05 FR-BAR-PLAYER        PIC X(16) OCCURS 16 TIMES.
    05 FR-PROG              BINARY-LONG.
    05 FR-RC-N              BINARY-LONG.
    05 FR-RC                BINARY-LONG OCCURS 4 TIMES.
    05 FR-TICKS             BINARY-LONG.
*>   1 once the fight knows a dragon (created or adopted: the saved dragon UUID of 38 9.1 item 7); a fight without one makes it on the tick its scan fills the bar
    05 FR-HAS-DRAGON        BINARY-LONG.
