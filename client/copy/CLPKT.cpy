*> Level Particles packet (05a 0x30) after the particle (docs/protocol/42-particles-1-shared-model-engine.md
*> section 7.2). PP-TYPE is the particle registry id; the options are decoded into PART-OPTIONS.
*> PP-RANDOM is 0 DEFAULT, 1 ALTERNATIVE, 2 ALTERNATIVE_WITH_SPEED (out-of-range values map to 0).
 01 PART-PACKET.
    05 PP-ERROR               BINARY-LONG.
    05 PP-TYPE                BINARY-LONG.
    05 PP-OVERRIDE            BINARY-LONG.
    05 PP-ALWAYS              BINARY-LONG.
    05 PP-X                   FLOAT-LONG.
    05 PP-Y                   FLOAT-LONG.
    05 PP-Z                   FLOAT-LONG.
    05 PP-DX                  FLOAT-LONG.
    05 PP-DY                  FLOAT-LONG.
    05 PP-DZ                  FLOAT-LONG.
    05 PP-SX                  FLOAT-LONG.
    05 PP-SY                  FLOAT-LONG.
    05 PP-SZ                  FLOAT-LONG.
    05 PP-COUNT               BINARY-LONG.
    05 PP-RANDOM              BINARY-LONG.
 78 PP-MAX-SPAWNS             VALUE 32.
 01 PART-SPAWNS.
    05 PS-N                   BINARY-LONG.
    05 PS-SPAWN               OCCURS 32 TIMES.
       10 PS-V                FLOAT-LONG OCCURS 6 TIMES.
