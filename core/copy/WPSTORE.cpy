*> The waypoint settings of the waypoint command (docs/protocol/16-commands-catalog.md §5.15; core/src/cmds-entities.cob): EXTERNAL, one entry per living entity that was modified,
*> found by the network entity id of the entity (a player's PL-ENTITY-ID, any other entity's EN-ID). WP-ID 0 is a free entry. WP-COLOR-KIND 0 = no colour set, 1 = a team colour
*> (WP-COLOR its number 0 to 15 in the order black, dark_blue, ..., white), 2 = a hex colour (WP-COLOR the 24-bit RGB value); WP-STYLE-LENGTH 0 = the default style, else WP-STYLE is the
*> namespaced style identifier. Entries of removed entities are freed by the next waypoint command. Nothing draws these settings yet and they are not saved or sent.
 78 WP-MAX                 VALUE 1100.
 01 CORE-WAYPOINTS EXTERNAL.
    05 WP-ENTRY OCCURS 1100 TIMES.
       10 WP-ID              BINARY-LONG.
       10 WP-COLOR-KIND      BINARY-LONG.
       10 WP-COLOR           BINARY-LONG.
       10 WP-STYLE-LENGTH    BINARY-LONG.
       10 WP-STYLE           PIC X(64).
