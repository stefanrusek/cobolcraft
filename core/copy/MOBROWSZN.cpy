*> The zombie nautilus row (44-7 section 10 with 21 section 4.10), included by STDMOBS.cpy last. Columns as the rows there. Animal base + MAX_HEALTH 15, MOVEMENT_SPEED 1.1 (the stroll modifier 1.0),
*> ATTACK_DAMAGE 3; SM-KIND 8 (NAUTILUS-TICK, category 1 monster but not removed in Peaceful: 20 section 19.4 does not list it); no panic (ZombieNautilusAi has no AnimalPanic); burns in daylight (tag
*> burn_in_daylight); no natural spawn (it comes as a drowned's mount, 20 section 4.5); the loot table is minecraft:entities/zombie_nautilus (rotten flesh).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zombie_nautilus".
       10 FILLER BINARY-LONG VALUE 15.  *> max health
       10 FILLER BINARY-LONG VALUE 1100.  *> walk x 1000
       10 FILLER BINARY-LONG VALUE 0.  *> panic x 1000
       10 FILLER BINARY-LONG VALUE 8.  *> kind
       10 FILLER BINARY-LONG VALUE 3.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 1.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 0.  *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
