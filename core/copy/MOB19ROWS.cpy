*> Land species rows of document 19 (lane 002-lane-mobsfull-h4), included by STDMOBS.cpy after the rows of the first mobs; the columns are those of the
*> rows there. These are the species that walk, stroll and flee on the ground with the generic mob AI: SM-WALK-MILLI and SM-PANIC-MILLI are
*> (movement_speed x modifier) squared / 0.454 x 1000 with the stroll modifier and the panic modifier of the species goal list (19 sections 3 to 13).
*> Neutral and flying species (wolf, bee, polar bear, parrot) wait for their own behaviour. Loot comes from the tables entities/<key>.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "horse".
       10 FILLER BINARY-LONG VALUE 22.             *> horse: health the mean of 15 + nextInt(8) + nextInt(9) (19 section 3.2); movement speed the mean gene 0.225; stroll 0.7 and mount panic 1.2 (3.1)
       10 FILLER BINARY-LONG VALUE 55.
       10 FILLER BINARY-LONG VALUE 161.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "donkey".
       10 FILLER BINARY-LONG VALUE 22.             *> donkey: chested base speed 0.175, health gene mean (3.2, 3.6); stroll 0.7, mount panic 1.2
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER BINARY-LONG VALUE 97.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "mule".
       10 FILLER BINARY-LONG VALUE 22.             *> mule: as donkey (3.6)
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER BINARY-LONG VALUE 97.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "llama".
       10 FILLER BINARY-LONG VALUE 22.             *> llama: speed 0.175, health gene mean (3.7); stroll 0.7, panic 1.2
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER BINARY-LONG VALUE 97.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "rabbit".
       10 FILLER BINARY-LONG VALUE 3.             *> rabbit: health 3, speed 0.3, stroll 0.6, panic 2.2 (4)
       10 FILLER BINARY-LONG VALUE 71.
       10 FILLER BINARY-LONG VALUE 959.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "goat".
       10 FILLER BINARY-LONG VALUE 10.             *> goat: health 10, speed 0.2, stroll 1.0, panic 2.0 (10)
       10 FILLER BINARY-LONG VALUE 88.
       10 FILLER BINARY-LONG VALUE 352.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "armadillo".
       10 FILLER BINARY-LONG VALUE 12.             *> armadillo: health 12, speed 0.14, stroll 1.0, panic 2.0 (13)
       10 FILLER BINARY-LONG VALUE 43.
       10 FILLER BINARY-LONG VALUE 173.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "camel".
       10 FILLER BINARY-LONG VALUE 32.             *> camel: health 32, speed 0.09, stroll 2.0, panic 4.0 (3.8)
       10 FILLER BINARY-LONG VALUE 71.
       10 FILLER BINARY-LONG VALUE 285.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "fox".
       10 FILLER BINARY-LONG VALUE 10.             *> fox: health 10, speed 0.3, stroll 1.0, panic 2.2 (7)
       10 FILLER BINARY-LONG VALUE 198.
       10 FILLER BINARY-LONG VALUE 959.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
    05 FILLER.
       10 FILLER PIC X(24) VALUE "panda".
       10 FILLER BINARY-LONG VALUE 20.             *> panda: health 20 (attribute default), speed 0.15, stroll 1.0, panic 2.0 (8)
       10 FILLER BINARY-LONG VALUE 50.
       10 FILLER BINARY-LONG VALUE 198.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
