*> The mount rows of document 20 sections 4.4 and 18.3 (wrap I2, T2450 and T2506): camel_husk, zombie_horse and skeleton_horse, included by STDMOBS.cpy before the villager rows (the villager, the trader, the strider and the zombie nautilus stay the last four). Columns as the rows there.
*> Camel husk (20 section 4.4, 19 section 3.8): max_health 32, movement_speed 0.09 as the camel, stroll 2.0 (0.09 x 2.0 squared / 0.454 = 71), CamelPanic 4.0 (285); monster category, surface
*> monster spawn rule (SM-SPAWN 5: it comes only as the mount of a husk, HUSK-CAMEL), SM-NEUTRAL 7 (a mount takes no target), experience 5 (the Monster default, 20 section 3.1), no attack.
*> Zombie horse (19 section 3.6): max_health 25, speed the mean of the gene (9 + 1.5) / 42.16 = 0.249: stroll 0.7 = 67, mount panic 1.2 = 197; monster category, checkMonsterSpawnRules (SM-SPAWN 2),
*> burns in daylight (tag burn_in_daylight), inert targeting, experience 5.
*> Skeleton horse (19 section 3.6): max_health 15, movement_speed 0.2: stroll 0.7 = 43, no panic goal (its addBehaviourGoals registers nothing); creature category, no natural spawn (the trap only).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "camel_husk".
       10 FILLER BINARY-LONG VALUE 32.  *> max health
       10 FILLER BINARY-LONG VALUE 71.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 285.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 1.  *> kind: monster
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 7.  *> inert targeting
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 5.  *> natural spawn rule (SM-SPAWN): surface monster
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zombie_horse".
       10 FILLER BINARY-LONG VALUE 25.
       10 FILLER BINARY-LONG VALUE 67.
       10 FILLER BINARY-LONG VALUE 197.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "skeleton_horse".
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 43.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
