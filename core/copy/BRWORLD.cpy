*> World state kept by the commands (docs/protocol/16-commands-catalog.md §4, §11.9), EXTERNAL: BW-READY 0 until the first use (BR-WORLD-READY
*> sets the difficulty to normal), the difficulty (0 peaceful, 1 easy, 2 normal, 3 hard), BW-SAVE-OFF 1 after save-off (WORLD-AUTOSAVE-TICK reads it), BW-AUTOSAVE-LEFT the
*> ticks until the next automatic save (6000 at the start), BW-FORCE-GAMEMODE 1 for the force-gamemode property (defaultgamemode then moves
*> every online player; the hosts' property wiring is BLOCKED: no settings field exists in COREAPI.cpy), and per player row the personal spawn
*> point of the spawnpoint command (BW-SPAWN-SET 1 once set; the dimension row, the position and the rotation). Not
*> persisted. HEALTH-RESPAWN reads it: a row with BW-SPAWN-SET 1 holds the place (BW-SPAWN-DIM, X/Y/Z, YAW, PITCH). BW-SPAWN-BED 1 marks a bed
*> (set by using one, 33 section 5.2; Y is the block y): the respawn goes there only while a bed is still in that cell, else to the world spawn.
 01 BR-WORLD EXTERNAL.
    05 BW-READY             BINARY-LONG.
    05 BW-DIFFICULTY        BINARY-LONG.
    05 BW-SAVE-OFF          BINARY-LONG.
    05 BW-AUTOSAVE-LEFT    BINARY-LONG.
    05 BW-FORCE-GAMEMODE   BINARY-LONG.
    05 BW-IDLE-MINUTES     BINARY-LONG.
    05 BW-SPAWN             OCCURS 64 TIMES.
       10 BW-SPAWN-SET       BINARY-LONG.
       10 BW-SPAWN-DIM       BINARY-LONG.
       10 BW-SPAWN-X         FLOAT-LONG.
       10 BW-SPAWN-Y         FLOAT-LONG.
       10 BW-SPAWN-Z         FLOAT-LONG.
       10 BW-SPAWN-YAW       FLOAT-SHORT.
       10 BW-SPAWN-PITCH     FLOAT-SHORT.
       10 BW-SPAWN-BED       BINARY-LONG.
