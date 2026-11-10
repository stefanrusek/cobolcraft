*> World state kept by the commands (docs/protocol/16-commands-catalog.md §4), EXTERNAL: BW-READY 0 until the first use (BR-WORLD-READY
*> sets the difficulty to normal), the difficulty (0 peaceful, 1 easy, 2 normal, 3 hard), and per player row the personal spawn
*> point of the spawnpoint command (BW-SPAWN-SET 1 once set; the dimension row, the position and the rotation). Neither is
*> persisted, and the respawn code does not read BW-SPAWN yet (BLOCKED for core/src/health.cob: when a player respawns,
*> a row with BW-SPAWN-SET 1 holds the place: BW-SPAWN-DIM, BW-SPAWN-X/Y/Z, BW-SPAWN-YAW, BW-SPAWN-PITCH).
 01 BR-WORLD EXTERNAL.
    05 BW-READY             BINARY-LONG.
    05 BW-DIFFICULTY        BINARY-LONG.
    05 BW-SPAWN             OCCURS 64 TIMES.
       10 BW-SPAWN-SET       BINARY-LONG.
       10 BW-SPAWN-DIM       BINARY-LONG.
       10 BW-SPAWN-X         FLOAT-LONG.
       10 BW-SPAWN-Y         FLOAT-LONG.
       10 BW-SPAWN-Z         FLOAT-LONG.
       10 BW-SPAWN-YAW       FLOAT-SHORT.
       10 BW-SPAWN-PITCH     FLOAT-SHORT.
