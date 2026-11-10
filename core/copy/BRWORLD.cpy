*> World state kept by the commands (docs/protocol/16-commands-catalog.md §4, §11.9), EXTERNAL: BW-READY 0 until the first use (BR-WORLD-READY
*> sets the difficulty to normal), the difficulty (0 peaceful, 1 easy, 2 normal, 3 hard), BW-SAVE-OFF 1 after save-off (the automatic saves
*> of the host do not read it yet: BLOCKED for the host's save timer, interface BW-SAVE-OFF), and per player row the personal spawn
*> point of the spawnpoint command (BW-SPAWN-SET 1 once set; the dimension row, the position and the rotation). Neither is
*> persisted, and the respawn code does not read BW-SPAWN yet (BLOCKED for core/src/health.cob: when a player respawns,
*> a row with BW-SPAWN-SET 1 holds the place: BW-SPAWN-DIM, BW-SPAWN-X/Y/Z, BW-SPAWN-YAW, BW-SPAWN-PITCH).
 01 BR-WORLD EXTERNAL.
    05 BW-READY             BINARY-LONG.
    05 BW-DIFFICULTY        BINARY-LONG.
    05 BW-SAVE-OFF          BINARY-LONG.
    05 BW-SPAWN             OCCURS 64 TIMES.
       10 BW-SPAWN-SET       BINARY-LONG.
       10 BW-SPAWN-DIM       BINARY-LONG.
       10 BW-SPAWN-X         FLOAT-LONG.
       10 BW-SPAWN-Y         FLOAT-LONG.
       10 BW-SPAWN-Z         FLOAT-LONG.
       10 BW-SPAWN-YAW       FLOAT-SHORT.
       10 BW-SPAWN-PITCH     FLOAT-SHORT.
