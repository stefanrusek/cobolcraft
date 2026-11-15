*> Illagers, witch, phantom, vex and ravager of document 20 (002-lane-mobsfull-h11; sections 11, 12, 13), rows 35 to 42, included by STDMOBS.cpy after
*> MOB20ROWS2.cpy; the columns are those of the rows there. SM-RANGED 1 bow, 2 crossbow (pillager, 13.2), 3 potion thrower (witch, 11). SM-SPAWN 2: the monster
*> rule in the dark; 0: no natural spawn here (patrols, raids, spells and the phantom spawner create them).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "witch".
       10 FILLER BINARY-LONG VALUE 26.              *> max health
       10 FILLER BINARY-LONG VALUE 138.              *> 0.25 x 1.0 (ranged attack speed 1.0, stroll 1.0)
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 0.              *> no melee: it throws potions (20 section 11)
       10 FILLER BINARY-LONG VALUE 16.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 2.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "phantom".
       10 FILLER BINARY-LONG VALUE 20.              *> max health
       10 FILLER BINARY-LONG VALUE 0.              *> flies: the flight is STDMOB-PHANTOM-TICK, no ground speed
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 6.              *> attack damage 6 + size (STDMOB-ATTACK-DAMAGE)
       10 FILLER BINARY-LONG VALUE 64.              *> follow range
       10 FILLER BINARY-LONG VALUE 1.              *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "vindicator".
       10 FILLER BINARY-LONG VALUE 24.              *> max health
       10 FILLER BINARY-LONG VALUE 270.              *> 0.35 x 1.0 squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 5.              *> attack damage 5.0
       10 FILLER BINARY-LONG VALUE 12.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "pillager".
       10 FILLER BINARY-LONG VALUE 24.              *> max health
       10 FILLER BINARY-LONG VALUE 270.              *> 0.35 x 1.0 squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 5.              *> attack damage 5.0 (unused: the crossbow)
       10 FILLER BINARY-LONG VALUE 32.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "evoker".
       10 FILLER BINARY-LONG VALUE 24.              *> max health
       10 FILLER BINARY-LONG VALUE 198.              *> 0.5 x 0.6 (stroll) squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 0.              *> no melee: spells (13.3)
       10 FILLER BINARY-LONG VALUE 12.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 10.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "vex".
       10 FILLER BINARY-LONG VALUE 14.              *> max health
       10 FILLER BINARY-LONG VALUE 0.              *> flies (13.4)
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 4.              *> attack damage 4.0
       10 FILLER BINARY-LONG VALUE 16.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "illusioner".
       10 FILLER BINARY-LONG VALUE 32.              *> max health
       10 FILLER BINARY-LONG VALUE 198.              *> 0.5 x 0.6 (stroll) squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 0.              *> no melee: bow and spells (13.5)
       10 FILLER BINARY-LONG VALUE 18.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "ravager".
       10 FILLER BINARY-LONG VALUE 100.              *> max health
       10 FILLER BINARY-LONG VALUE 198.              *> 0.3 x 1.0 squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 12.              *> attack damage 12.0
       10 FILLER BINARY-LONG VALUE 32.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 20.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
