*> The modifier list and the position buffers of the placement evaluator (docs/protocol/35-worldgen-features-1 sections 7 and 8; core/src/feat-35-1.cob).
*> A modifier: kind (1 count, 2 in_square, 3 height_range with a uniform provider, 4 biome, 5 rarity_filter, 6 random_chance, 8 cuboid),
*> integer arguments A, B, C, D and a float F (see F351-MODIFY). The placed feature at the end of the list records the positions it is placed at.
 78 F351-MAX-MODS         VALUE 16.
 78 F351-MAX-POS          VALUE 8192.
 01 F351-PROGRAM EXTERNAL.
    05 FP-COUNT             BINARY-LONG.
    05 FP-MOD OCCURS 16 TIMES.
       10 FP-KIND           BINARY-LONG.
       10 FP-A              BINARY-LONG.
       10 FP-B              BINARY-LONG.
       10 FP-C              BINARY-LONG.
       10 FP-D              BINARY-LONG.
       10 FP-F              FLOAT-LONG.
 01 F351-PLACED EXTERNAL.
    05 FO-COUNT             BINARY-LONG.
    05 FO-POS OCCURS 8192 TIMES.
       10 FO-X              BINARY-LONG.
       10 FO-Y              BINARY-LONG.
       10 FO-Z              BINARY-LONG.
