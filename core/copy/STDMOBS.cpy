*> Standard (minecraft:) mobs (002-lane-mobs; docs/protocol/18 to 20; found by STDMOB-INDEX in core/src/stdmobs.cob). One row per
*> mob type, keyed by the entity type key, so the ids come from the open standard set and no number is repeated here.
*> SM-HEALTH: max_health (19 sections 2.1, 2.2, 20 section 4.1). SM-WALK-MILLI and SM-PANIC-MILLI: blocks per tick x 1000 at the stroll or
*> chase speed and the panic speed of the mob's goal list: (movement_speed x speedModifier) squared / 0.454 (18 section 3.2.1, the steady state
*> of a mob on ground with friction 0.6). SM-KIND 0 passive (category creature), 1 hostile (monster). SM-ATTACK: attack damage in points, before the
*> difficulty scaling of 20 section 3.1. SM-FOLLOW: the follow range in blocks. SM-BURNS 1: burns in daylight (20 section 3.5). SM-NEUTRAL 1: takes a target only where the light is below 13 (the spider, 20 section 7.1). The loot of a mob is its
*> table minecraft:entities/<key> (18 section 7.6; STDMOB-DROPS).
 78 SM-COUNT                 VALUE 7.
*> The first SM-NATURAL rows spawn on grass in the natural cycle (18 section 6.8 animal rule); rows SM-HOSTILE-FIRST to SM-COUNT are monsters.
 78 SM-NATURAL               VALUE 4.
 78 SM-HOSTILE-FIRST         VALUE 6.
 78 SM-HOSTILE-COUNT         VALUE 2.
 01 STD-MOB-DATA.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "pig".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 138.            *> 0.25 x 1.0
       10 FILLER BINARY-LONG VALUE 215.            *> 0.25 x 1.25
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "cow".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 88.            *> 0.2 x 1.0
       10 FILLER BINARY-LONG VALUE 352.            *> 0.2 x 2.0
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "sheep".
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 117.            *> 0.23 x 1.0
       10 FILLER BINARY-LONG VALUE 182.            *> 0.23 x 1.25
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "chicken".
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 138.            *> 0.25 x 1.0
       10 FILLER BINARY-LONG VALUE 270.            *> 0.25 x 1.4
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "mooshroom".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 88.            *> as cow (19 section 2.3)
       10 FILLER BINARY-LONG VALUE 352.            *> 0.2 x 2.0
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zombie".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER BINARY-LONG VALUE 117.            *> 0.23 x 1.0 (the melee chase modifier is 1.0)
       10 FILLER BINARY-LONG VALUE 0.            *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.             *> neutral by day (the target goal needs light below 13)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "spider".
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 198.            *> 0.3 x 1.0
       10 FILLER BINARY-LONG VALUE 0.              *> no panic goal
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.              *> attack damage 2.0 (the Monster default, 20 section 7.1)
       10 FILLER BINARY-LONG VALUE 16.             *> follow range 16 (the Mob base, 18 section 1.3)
       10 FILLER BINARY-LONG VALUE 0.              *> does not burn
       10 FILLER BINARY-LONG VALUE 1.              *> neutral by day
 01 STD-MOB-TABLE REDEFINES STD-MOB-DATA.
    05 SM-ENTRY OCCURS 7 TIMES.
       10 SM-KEY                PIC X(24).
       10 SM-HEALTH             BINARY-LONG.
       10 SM-WALK-MILLI         BINARY-LONG.
       10 SM-PANIC-MILLI        BINARY-LONG.
       10 SM-KIND               BINARY-LONG.
       10 SM-ATTACK             BINARY-LONG.
       10 SM-FOLLOW             BINARY-LONG.
       10 SM-BURNS              BINARY-LONG.
       10 SM-NEUTRAL            BINARY-LONG.
*> Walking (19 section 2.1, 18 section 4.2 RandomStrollGoal): a standing mob starts a stroll on a tick with probability 1/120 and walks it
*> 3 to 10 blocks along one heading, then it stands.
 78 SM-STROLL-ODDS           VALUE 120.
 78 SM-STROLL-BLOCKS         VALUE 10.
 78 SM-STROLL-TICKS          VALUE 200.
*> Natural spawning of the creature category (18 sections 6.1, 6.3, 6.5, 6.8): the friendly cycle runs when Time mod 400 = 0; a
*> player's local cap is 10 creatures in the chunks within 5 chunks of the player; the animal rule needs grass_block below and a
*> raw brightness above 8; a pack is 1 to 4 mobs, each placed by a cursor that moves up to 5 blocks per axis from the start.
 78 SM-SPAWN-TICKS           VALUE 400.
 78 SM-LOCAL-CAP             VALUE 10.
 78 SM-CAP-CHUNKS            VALUE 5.
 78 SM-LIGHT-MIN             VALUE 9.
 78 SM-PACK-MAX              VALUE 4.
 78 SM-CURSOR-STEP           VALUE 6.
 78 SM-NEAR-BLOCKS           VALUE 24.
*> Monsters (18 section 6.1, 6.3, 20 section 3.3, 3.4): one attempt per player every SM-HOSTILE-TICKS ticks (the chunk cycle of the game
*> runs every tick for each chunk; this is its per-player approximation), a local cap of 70 monsters, a solid block below, two air cells.
 78 SM-HOSTILE-TICKS         VALUE 20.
 78 SM-HOSTILE-CAP           VALUE 70.
*> Death (18 sections 7.5 and 2.9): a defeated mob stays 20 ticks (deathTime), then Entity Event 60 and removal.
 78 SM-DEATH-TICKS           VALUE 20.
*> Melee (18 section 4.2 MeleeAttackGoal; 20 section 4.1): the attack timer is 20 ticks after a hit; the target's box must meet the mob's box
*> inflated by 0.8283 on x and z (sqrt(2.04) - 0.6): half widths 0.3 (zombie) and 0.3 (player) make the horizontal reach 1.4283 per axis,
*> the boxes overlap vertically when the feet differ by less than 1.8 (player height) below to 1.95 (zombie height) above.
 78 SM-ATTACK-TICKS          VALUE 20.
 78 SM-REACH-MILLI           VALUE 1428.
 78 SM-REACH-BELOW-MILLI     VALUE 1800.
 78 SM-REACH-ABOVE-MILLI     VALUE 1950.
*> Daylight burning (20 section 3.5): the monsters_burn window of the day clock, the burn time (8 seconds) and the damage step (1 point a second).
*> The per-tick chance in ten-thousandths by raw light 13, 14, 15 is (B - 0.4) / 15 with B(l) = (l/15) / (4 - 3 l/15).
 78 SM-BURN-DAY-END          VALUE 12542.
 78 SM-BURN-DAY-START        VALUE 23460.
 78 SM-BURN-TICKS            VALUE 160.
 78 SM-BURN-STEP             VALUE 20.
 01 SM-BURN-DATA.
    05 FILLER BINARY-LONG VALUE 146.
    05 FILLER BINARY-LONG VALUE 252.
    05 FILLER BINARY-LONG VALUE 400.
 01 SM-BURN-TABLE REDEFINES SM-BURN-DATA.
    05 SM-BURN-CHANCE           BINARY-LONG OCCURS 3 TIMES.
*> Night darkness of the sky light (12 section 3.2 D4: dark from 13140 to 22860, ramps 11270 to 13140 and 22860 to 24730): at most 11 points.
 78 SM-DARK-MAX              VALUE 11.
 78 SM-DARK-RAMP-UP          VALUE 11270.
 78 SM-DARK-FULL-START       VALUE 13140.
 78 SM-DARK-FULL-END         VALUE 22860.
 78 SM-DARK-RAMP-END         VALUE 24730.
