*> State of the custom spawners that keep their own counters (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 6; 44-3 sections 1.6 and 1.7; core/src/q44-44-2c.cob),
*> EXTERNAL, zero at the start. CSP-CAT-NEXT is the CatSpawner's nextTick (0: the first call runs at once). The village siege (VillageSiege): CSP-SG-STATE 0 SIEGE_DONE or 1 SIEGE_TONIGHT,
*> CSP-SG-SETUP hasSetupSiege, CSP-SG-ZOMBIES zombiesToSpawn, CSP-SG-NEXT nextSpawnTime and the chosen centre CSP-SG-X, -Y, -Z.
 01 CUSTOM-SPAWNER-STATE EXTERNAL.
    05 CSP-CAT-NEXT         BINARY-LONG.
    05 CSP-SG-STATE         BINARY-LONG.
    05 CSP-SG-SETUP         BINARY-LONG.
    05 CSP-SG-ZOMBIES       BINARY-LONG.
    05 CSP-SG-NEXT          BINARY-LONG.
    05 CSP-SG-X             BINARY-LONG.
    05 CSP-SG-Y             BINARY-LONG.
    05 CSP-SG-Z             BINARY-LONG.
