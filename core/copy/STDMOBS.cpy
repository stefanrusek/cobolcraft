*> Standard (minecraft:) mobs (002-lane-mobs; docs/protocol/18 and 19; found by STDMOB-INDEX in core/src/stdmobs.cob). One row per
*> mob type, keyed by the entity type key, so the ids come from the open standard set and no number is repeated here.
*> SM-HEALTH: max_health (19 sections 2.1, 2.2). SM-WALK-MILLI and SM-PANIC-MILLI: blocks per tick x 1000 at the stroll speed 1.0
*> and the panic speed of the mob's goal list: (movement_speed x speedModifier) squared / 0.454 (18 section 3.2.1, the steady state of a mob on
*> ground with friction 0.6). SM-DROP-KEY / MIN / MAX: the loot pools (an empty key = no pool). The mob category is creature
*> (18 section 1.2) for every row of this table.
 78 SM-COUNT                 VALUE 4.
 01 STD-MOB-DATA.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "pig".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 138.            *> 0.25 x 1.0
       10 FILLER BINARY-LONG VALUE 215.            *> 0.25 x 1.25
       10 FILLER PIC X(24) VALUE "porkchop".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "cow".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 88.             *> 0.2 x 1.0
       10 FILLER BINARY-LONG VALUE 352.            *> 0.2 x 2.0
       10 FILLER PIC X(24) VALUE "leather".
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "beef".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "sheep".
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 117.            *> 0.23 x 1.0
       10 FILLER BINARY-LONG VALUE 182.            *> 0.23 x 1.25
       10 FILLER PIC X(24) VALUE "mutton".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "white_wool".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "chicken".
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 138.            *> 0.25 x 1.0
       10 FILLER BINARY-LONG VALUE 270.            *> 0.25 x 1.4
       10 FILLER PIC X(24) VALUE "feather".
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER PIC X(24) VALUE "chicken".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
 01 STD-MOB-TABLE REDEFINES STD-MOB-DATA.
    05 SM-ENTRY OCCURS 4 TIMES.
       10 SM-KEY                PIC X(24).
       10 SM-HEALTH             BINARY-LONG.
       10 SM-WALK-MILLI         BINARY-LONG.
       10 SM-PANIC-MILLI        BINARY-LONG.
       10 SM-DROP-KEY-1         PIC X(24).
       10 SM-DROP-MIN-1         BINARY-LONG.
       10 SM-DROP-MAX-1         BINARY-LONG.
       10 SM-DROP-KEY-2         PIC X(24).
       10 SM-DROP-MIN-2         BINARY-LONG.
       10 SM-DROP-MAX-2         BINARY-LONG.
*> Walking (19 section 2.1, 18 section 4.2 RandomStrollGoal): a standing mob starts a stroll on a tick with probability 1/120; the
*> goal walks it up to 10 blocks (18 section 4.2 RandomStrollGoal, DefaultRandomPos 10 x 7) along one heading, then it stands.
 78 SM-STROLL-ODDS           VALUE 120.
 78 SM-STROLL-BLOCKS         VALUE 10.
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
 *> Death (18 sections 7.5 and 2.9): a defeated mob stays 20 ticks (deathTime), then Entity Event 60 and removal.
 78 SM-DEATH-TICKS           VALUE 20.
