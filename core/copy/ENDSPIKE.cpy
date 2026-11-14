*> The spike list and the crystal list of the End's pillars (docs/protocol/35-worldgen-features-7 section 8; core/src/end-38c.cob). SPIKE-LIST: the ten
*> EndSpike records (centre x, centre z, radius, height, guarded 0 or 1). CRYSTAL-LIST: the end crystals a placement asks the caller to create (block
*> position of the crystal and its yaw in degrees, a float), EC-COUNT of them.
 01 SPIKE-LIST.
    05 SP-ROW               OCCURS 10 TIMES.
       10 SP-CX             BINARY-LONG.
       10 SP-CZ             BINARY-LONG.
       10 SP-R              BINARY-LONG.
       10 SP-H              BINARY-LONG.
       10 SP-G              BINARY-LONG.
 01 CRYSTAL-LIST.
    05 EC-COUNT             BINARY-LONG.
    05 EC-ROW               OCCURS 10 TIMES.
       10 EC-X              BINARY-LONG.
       10 EC-Y              BINARY-LONG.
       10 EC-Z              BINARY-LONG.
       10 EC-YAW            FLOAT-LONG.
