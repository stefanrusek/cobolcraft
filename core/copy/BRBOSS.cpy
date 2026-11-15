*> The custom boss bars of docs/protocol/16-commands-catalog.md §8.7 (at most 16): the identifier with its namespace, the name (the text of the
*> component), color (ordinal 0 pink, 1 blue, 2 red, 3 green, 4 yellow, 5 purple, 6 white) and style (0 progress, 1 notched_6, 2 notched_10, 3 notched_12,
*> 4 notched_20) as the Boss Event packet (05a 0x09) numbers them, value, maximum, visibility and the uuids of the players (at most 16). A bar is
*> sent to its players under the uuid of 15 zero bytes and its table index.
 01 BR-BOSS EXTERNAL.
    05 BO-COUNT             BINARY-LONG.
    05 BO-BAR               OCCURS 16 TIMES.
       10 BO-USED            BINARY-LONG.
       10 BO-ID-LENGTH       BINARY-LONG.
       10 BO-ID              PIC X(64).
       10 BO-NAME-LENGTH     BINARY-LONG.
       10 BO-NAME            PIC X(256).
       10 BO-COLOR           BINARY-LONG.
       10 BO-STYLE           BINARY-LONG.
       10 BO-VALUE           BINARY-LONG.
       10 BO-MAX             BINARY-LONG.
       10 BO-VISIBLE         BINARY-LONG.
       10 BO-PLAYER-COUNT    BINARY-LONG.
       10 BO-PLAYER          PIC X(16) OCCURS 16 TIMES.
