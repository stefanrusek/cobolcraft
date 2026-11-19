*> The spawner clocks of 44 part 3 sections 1.6 and 1.7 (core/src/q44-44-3.cob), EXTERNAL, zero at the start. Q3-CAT-NEXT is CatSpawner's nextTick (0 at the start: the first
*> call runs at once). Siege: Q3-SG-STATE 0 SIEGE_DONE (initial) or 1 SIEGE_TONIGHT, Q3-SG-SETUP hasSetupSiege, Q3-SG-ZOMBIES zombiesToSpawn, Q3-SG-NEXT nextSpawnTime and the
*> chosen centre (dimension row and block position).
 01 Q3-STATE EXTERNAL.
    05 Q3-CAT-NEXT           BINARY-LONG.
    05 Q3-SG-STATE           BINARY-LONG.
    05 Q3-SG-SETUP           BINARY-LONG.
    05 Q3-SG-ZOMBIES         BINARY-LONG.
    05 Q3-SG-NEXT            BINARY-LONG.
    05 Q3-SG-DIM             BINARY-LONG.
    05 Q3-SG-X               BINARY-LONG.
    05 Q3-SG-Y               BINARY-LONG.
    05 Q3-SG-Z               BINARY-LONG.
