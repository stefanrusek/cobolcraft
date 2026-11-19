*> Nether and End mobs with projectiles (lane 002-lane-mobsfull-h19; 21 sections 5.1, 5.2, 19 section 20), included by STDMOBS.cpy last; the columns are those of the rows there.
*> SM-RANGED 4: ghast (fireball goal and flight, GHAST-TICK), 5: blaze (attack goal and height keeping, BLAZE-ATTACK), 6: shulker (SHULKER-ATTACK). SM-SPAWN 10: the any-light monster rule (no Nether biome exists yet); 12 (the ghast): Ghast.checkGhastSpawnRules, rule 10 and one try in 20 (21 section 3.2).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "ghast".
       10 FILLER BINARY-LONG VALUE 10.  *> max health
       10 FILLER BINARY-LONG VALUE 0.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 100.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 4.  *> ranged (ranged 4: the ghast's fireball goal (GHAST-SHOOT, core/src/mob-21-shoot.cob); flies (GHAST-MOVE), walk speed unused)
       10 FILLER BINARY-LONG VALUE 12.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "blaze".
       10 FILLER BINARY-LONG VALUE 20.  *> max health
       10 FILLER BINARY-LONG VALUE 117.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 6.  *> attack damage
       10 FILLER BINARY-LONG VALUE 48.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 10.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 5.  *> ranged (ranged 5: the blaze's attack goal (BLAZE-ATTACK); speed 0.23 squared / 0.454; max health 20 is the attribute default (21 section 5.2 lists none))
       10 FILLER BINARY-LONG VALUE 10.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "shulker".
       10 FILLER BINARY-LONG VALUE 30.  *> max health
       10 FILLER BINARY-LONG VALUE 0.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 6.  *> ranged (the shulker's attack goal and bullet, SHULKER-ATTACK; it does not walk, the attach face and the teleport are open)
       10 FILLER BINARY-LONG VALUE 0.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "endermite".
       10 FILLER BINARY-LONG VALUE 8.  *> max health
       10 FILLER BINARY-LONG VALUE 138.  *> speed x 1000 (squared / 0.454) (speed 0.25; 20 section 8.2)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 2.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 3.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 0.  *> spawn rule (0: it appears only through an ender pearl or a spawner, 20 section 8.2; the lifetime of 2400 ticks counts in EN-WAKE)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
