*> Water animals of document 21 section 4 (lane 002-lane-mobsfull-h10), included by STDMOBS.cpy after the other row files. The columns are those of the rows there.
*> SM-KIND 2 water creature (category 6), 3 water ambient (7), 4 underground water creature (5): MS6-ROW-CAT. SM-WALK-MILLI and SM-PANIC-MILLI of these rows are
*> the speed the move control multiplies (attribute x modifier, x 1000), not blocks per tick: STDMOB-AQUATIC-STEP. SM-SPAWN 7: surface water animal rule, 8:
*> tropical fish, 9: glow squid (MS6-RULE-AT). SM-XP 0: 1 + nextInt(3) (44-7 section 6.1).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "cod".
       10 FILLER BINARY-LONG VALUE 3.  *> max health
       10 FILLER BINARY-LONG VALUE 700.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 875.  *> panic speed x 1000
       10 FILLER BINARY-LONG VALUE 3.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 7.  *> spawn rule (as every fish: MOVEMENT_SPEED default 0.7 (21 section 4.1))
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "salmon".
       10 FILLER BINARY-LONG VALUE 3.  *> max health
       10 FILLER BINARY-LONG VALUE 700.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 875.  *> panic speed x 1000
       10 FILLER BINARY-LONG VALUE 3.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 7.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "pufferfish".
       10 FILLER BINARY-LONG VALUE 3.  *> max health
       10 FILLER BINARY-LONG VALUE 700.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 875.  *> panic speed x 1000
       10 FILLER BINARY-LONG VALUE 3.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 7.  *> spawn rule
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "tropical_fish".
       10 FILLER BINARY-LONG VALUE 3.  *> max health
       10 FILLER BINARY-LONG VALUE 700.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 875.  *> panic speed x 1000
       10 FILLER BINARY-LONG VALUE 3.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 8.  *> spawn rule (tropical rule (21 section 3.2))
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "squid".
       10 FILLER BINARY-LONG VALUE 10.  *> max health
       10 FILLER BINARY-LONG VALUE 0.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 1.  *> panic marker: a hit squid flees (the speed is its vector m, 4.5)
       10 FILLER BINARY-LONG VALUE 2.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 7.  *> spawn rule (moves by its vector m (4.5), no walk speed)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "glow_squid".
       10 FILLER BINARY-LONG VALUE 10.  *> max health
       10 FILLER BINARY-LONG VALUE 0.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 1.  *> panic marker: a hit squid flees (the speed is its vector m, 4.5)
       10 FILLER BINARY-LONG VALUE 4.  *> kind
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 9.  *> spawn rule (glow squid rule: y <= sea - 33, dark, in water)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
    05 FILLER.
       10 FILLER PIC X(24) VALUE "dolphin".
       10 FILLER BINARY-LONG VALUE 10.  *> max health
       10 FILLER BINARY-LONG VALUE 1200.  *> speed x 1000
       10 FILLER BINARY-LONG VALUE 1200.  *> panic speed x 1000
       10 FILLER BINARY-LONG VALUE 2.  *> kind
       10 FILLER BINARY-LONG VALUE 3.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> does not burn
       10 FILLER BINARY-LONG VALUE 0.  *> not neutral
       10 FILLER BINARY-LONG VALUE 0.  *> experience 1 + nextInt(3)
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 7.  *> spawn rule (MOVEMENT_SPEED 1.2 (4.6); it never starts a fight)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
