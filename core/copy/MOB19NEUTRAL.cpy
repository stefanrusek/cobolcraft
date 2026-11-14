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
    05 FILLER.
       10 FILLER PIC X(24) VALUE "iron_golem".
       10 FILLER BINARY-LONG VALUE 100.              *> max_health 100 (19 section 19); chase 1.0 (0.25 squared / 0.454); stroll only in villages: STDMOB-STEP lets it stand; no experience
       10 FILLER BINARY-LONG VALUE 138.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE -1.  *> SM-XP -1: no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "snow_golem".
       10 FILLER BINARY-LONG VALUE 4.              *> max_health 4, speed 0.2 x 1.0 (19 section 20); the snowball attack is an open item
       10 FILLER BINARY-LONG VALUE 88.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE -1.  *> SM-XP -1: no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "cat".
       10 FILLER BINARY-LONG VALUE 10.              *> max_health 10, 0.3 x 0.8 stroll, panic 1.5 (19 section 5.1); CatSpawner and villages place cats, so no natural spawn rule
       10 FILLER BINARY-LONG VALUE 127.
       10 FILLER BINARY-LONG VALUE 446.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.  *> SM-XP -1: no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "ocelot".
       10 FILLER BINARY-LONG VALUE 10.              *> max_health 10, 0.3 x 0.8 stroll (19 section 5.2)
       10 FILLER BINARY-LONG VALUE 127.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.  *> SM-XP -1: no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "polar_bear".
       10 FILLER BINARY-LONG VALUE 30.              *> max_health 30, follow range 20, stroll 1.0, panic 2.0 (19 section 9)
       10 FILLER BINARY-LONG VALUE 138.
       10 FILLER BINARY-LONG VALUE 551.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.  *> SM-XP -1: no experience
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 0.
