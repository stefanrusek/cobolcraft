*> Neutral and utility species of document 19 (lane 002-lane-mobsfull-h7), included by STDMOBS.cpy after MOB19ROWS.cpy; the columns are those of the rows there.
*> SM-WALK-MILLI and SM-PANIC-MILLI are (movement_speed x modifier) squared / 0.454 x 1000.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "wolf".
       10 FILLER BINARY-LONG VALUE 8.              *> wild max_health 8 (19 section 6.1; tamed 40)
       10 FILLER BINARY-LONG VALUE 198.            *> 0.3 x 1.0 (WaterAvoidingRandomStroll 1.0)
       10 FILLER BINARY-LONG VALUE 446.            *> 0.3 x 1.5 (TamableAnimalPanic 1.5)
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 4.              *> attack_damage 4
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.              *> experience: 1 + nextInt(3) like an animal
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
