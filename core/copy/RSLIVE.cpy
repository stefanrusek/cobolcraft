*> The ids and tables the live redstone wiring (core/src/redstone-live.cob) resolves from the open block table once per CB-EPOCH. RL-CLASS is the role of each block id + 1
*> (0 none, 1 redstone_wire, 2 redstone_block, 3 redstone_torch, 4 redstone_wall_torch, 5 lever, 6 a button, 7 repeater, 8 comparator, 9 a trapdoor, 10 hopper); RL-COND is 1 for a
*> block that is a redstone conductor (30-1 section 2.4: the never and always lists, else the solid opaque block of this core). RL-S-* is the decoded state of every state of the
*> classes 3 to 8: RL-S-DIR the facing direction (2 north, 3 south, 4 west, 5 east) of a wall torch, repeater and comparator and the connected direction C of a lever and button (30-5
*> section 1), RL-S-ON lit or powered, RL-S-DELAY the repeater delay, RL-S-LOCKED its lock, RL-S-MODE the comparator mode (1 subtract). RL-SILENT is 1 only while the wire evaluates
*> getBlockSignal (30-1 section 5.5: the shouldSignal flag). The toggle list of the torches (30-1 section 8.3, one list for the process) and the stored comparator outputs (30-2 4.1) follow.
 01 RL-IDS EXTERNAL.
    05 RL-EPOCH             BINARY-LONG.
    05 RL-WIRE              BINARY-LONG.
    05 RL-WIRE-FIRST        BINARY-LONG.
    05 RL-SOURCE            BINARY-LONG.
    05 RL-SILENT            BINARY-LONG.
    05 RL-CLASS             BINARY-CHAR UNSIGNED OCCURS 1400 TIMES.
    05 RL-COND              BINARY-CHAR UNSIGNED OCCURS 1400 TIMES.
    05 RL-S OCCURS 40000 TIMES.
       10 RL-S-DIR          BINARY-CHAR UNSIGNED.
       10 RL-S-ON           BINARY-CHAR UNSIGNED.
       10 RL-S-DELAY        BINARY-CHAR UNSIGNED.
       10 RL-S-LOCKED       BINARY-CHAR UNSIGNED.
       10 RL-S-MODE         BINARY-CHAR UNSIGNED.
 01 RL-LISTS EXTERNAL.
    05 RL-TOG-COUNT         BINARY-LONG.
    05 RL-TOG OCCURS 256 TIMES.
       10 RL-TOG-DIM        BINARY-LONG.
       10 RL-TOG-X          BINARY-LONG.
       10 RL-TOG-Y          BINARY-LONG.
       10 RL-TOG-Z          BINARY-LONG.
       10 RL-TOG-WHEN       BINARY-DOUBLE.
    05 RL-CMP-COUNT         BINARY-LONG.
    05 RL-CMP OCCURS 256 TIMES.
       10 RL-CMP-DIM        BINARY-LONG.
       10 RL-CMP-X          BINARY-LONG.
       10 RL-CMP-Y          BINARY-LONG.
       10 RL-CMP-Z          BINARY-LONG.
       10 RL-CMP-OUT        BINARY-LONG.
