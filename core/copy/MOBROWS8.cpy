*> Rows added by lane p49b (T15000 ff.), included by STDMOBS.cpy after MOB21ROWS3.cpy (the villager rows and the strider stay the last four). Columns as the rows there.
*> The giant (20 section 18.1: max health 100, movement speed 0.5, attack damage 50, experience 5; no goals and no targets: SM-NEUTRAL 7 is the inert code of
*> STDMOB-AGGRO and of the stroll; summon only: no natural spawn rule).
*> The creaking (20 section 17: health 1, speed 0.4 at modifier 1.0, attack 3, follow 32, no experience; spawned by hearts and summons only).
*> The breeze (20 section 16: max health 30, movement speed 0.63 at modifier 1.0: 0.63 squared / 0.454 = 874, attack damage 3, follow range 24, experience 10; no biome
*> spawn entry; SM-RANGED 7: it has no melee goal, BREEZE-SHOOT fires its wind charge).
*> The sulfur cube (20 section 18.2): a cube mob of size 2 (health 4) or 1 (health 1), speed 0.2 + 0.1 x size (not applied here: no hop movement), no contact damage and no
*> target (SM-NEUTRAL 7 inert targeting; it still strolls), empty loot, stays in Peaceful (STDMOB-STEP exempts the key), no natural spawn here.
*> The warden (20 section 15: max health 500, movement speed 0.3 at the fighting modifier 1.2: (0.3 x 1.2) squared / 0.454 = 285, attack damage 30, follow range 24,
*> experience 5; no biome spawn entry; the Darkness pulse is WARDEN-DARKNESS).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "giant".
       10 FILLER BINARY-LONG VALUE 100.
       10 FILLER BINARY-LONG VALUE 551.              *> 0.5 squared / 0.454 (it never walks)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 50.              *> attack damage 50 (never used: inert)
       10 FILLER BINARY-LONG VALUE 16.              *> follow range of the Mob base (18 section 7); no goal uses it
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 7.              *> inert
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "warden".
       10 FILLER BINARY-LONG VALUE 500.
       10 FILLER BINARY-LONG VALUE 285.              *> (0.3 x 1.2) squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 30.              *> attack damage 30
       10 FILLER BINARY-LONG VALUE 24.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> fire immune, does not burn
       10 FILLER BINARY-LONG VALUE 8.              *> SM-NEUTRAL 8: targets by anger (WARDEN-AGGRO)
       10 FILLER BINARY-LONG VALUE 5.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "creaking".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 352.              *> 0.4 squared / 0.454 (walk modifier 1.0)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 3.              *> attack damage 3
       10 FILLER BINARY-LONG VALUE 32.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE -1.              *> no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "breeze".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER BINARY-LONG VALUE 874.              *> 0.63 squared / 0.454
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> monster
       10 FILLER BINARY-LONG VALUE 3.              *> attack damage 3 (unused: no melee goal)
       10 FILLER BINARY-LONG VALUE 24.              *> follow range
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 10.              *> experience points
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 7.              *> ranged kind: breeze wind charge
       10 FILLER BINARY-LONG VALUE 0.              *> natural spawn rule
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "sulfur_cube".
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.              *> monster category
       10 FILLER BINARY-LONG VALUE 0.              *> never deals contact damage
       10 FILLER BINARY-LONG VALUE 16.              *> Mob base follow range (no target goals)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 7.              *> inert targeting
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> ranged kind
       10 FILLER BINARY-LONG VALUE 13.             *> natural spawn rule 13: checkSulfurCubeSpawnRules, always true (20 section 18.2)
       10 FILLER BINARY-LONG VALUE 0.
