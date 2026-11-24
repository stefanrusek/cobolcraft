*> Nether rows of document 21 section 5 (lane 002-lane-mobsfull-h12), included by STDMOBS.cpy after the other row files; the columns are those of the rows there.
*> SM-NEUTRAL 3: anger based (zombified piglin, 5.5.3: takes a target only when hurt by a player, EN-ANGER; NETHER-HURT, NETHER-AGGRO in core/src/mob-21-5.cob).
*> SM-NEUTRAL 4: the piglin (5.5.1: attacks a player without golden armor, anger 600 ticks when hit). SM-SPAWN 11: only the floor test (piglin, hoglin).
*> SM-SPAWN 10: any-light monster rule (21 section 3.2 checkAnyLightMonsterSpawnRules, with the not-Peaceful test of the magma cube and the zombified piglin).
*> SM-HITFX 3: Wither for 200 ticks (STDMOB-HIT-EFFECT). No Nether biome exists yet: the entries of 21 section 3.4 reach these rows through the biome data (SM-SPAWN > 0).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zombified_piglin".
       10 FILLER BINARY-LONG VALUE 20.  *> max health
       10 FILLER BINARY-LONG VALUE 117.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 5.  *> attack damage
       10 FILLER BINARY-LONG VALUE 35.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 3.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 10.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "wither_skeleton".
       10 FILLER BINARY-LONG VALUE 20.  *> max health
       10 FILLER BINARY-LONG VALUE 138.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 4.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 2.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 3.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "magma_cube".
       10 FILLER BINARY-LONG VALUE 1.  *> max health
       10 FILLER BINARY-LONG VALUE 198.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 1.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 1.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 10.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "piglin".
       10 FILLER BINARY-LONG VALUE 16.  *> max health
       10 FILLER BINARY-LONG VALUE 270.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 5.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 4.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 11.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "piglin_brute".
       10 FILLER BINARY-LONG VALUE 50.  *> max health
       10 FILLER BINARY-LONG VALUE 270.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 7.  *> attack damage
       10 FILLER BINARY-LONG VALUE 12.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 20.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 0.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "hoglin".
       10 FILLER BINARY-LONG VALUE 40.  *> max health
       10 FILLER BINARY-LONG VALUE 198.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 6.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 11.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zoglin".
       10 FILLER BINARY-LONG VALUE 40.  *> max health
       10 FILLER BINARY-LONG VALUE 198.  *> speed x 1000 (squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> panic speed
       10 FILLER BINARY-LONG VALUE 1.  *> kind (1 monster)
       10 FILLER BINARY-LONG VALUE 6.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 5.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 10.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
