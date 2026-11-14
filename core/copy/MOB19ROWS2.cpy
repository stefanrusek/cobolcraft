*> Land species of document 19 added by lane 002-lane-mobsfull-h16 (parrot, turtle, bee, frog, tadpole, sniffer, allay), included by STDMOBS.cpy last; the columns are those of the rows there.
*> SM-WALK-MILLI and SM-PANIC-MILLI are (movement_speed x modifier) squared / 0.454 x 1000, capped at 999 (a step of one block a tick or more would tunnel through walls).
*> Open items: flight (parrot, bee, allay), the hop of the frog, the hive and flower behaviour of the bee, the sniffer's digging, the allay's item handling.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "parrot".
       10 FILLER BINARY-LONG VALUE 6.             *> parrot: speed 0.2 x 1.0 (ParrotWander), TamableAnimalPanic 1.25 (19 section 17); attack_damage 3
       10 FILLER BINARY-LONG VALUE 88.
       10 FILLER BINARY-LONG VALUE 138.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.
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
       10 FILLER PIC X(24) VALUE "turtle".
       10 FILLER BINARY-LONG VALUE 30.             *> turtle: speed 0.25 x 1.0, TurtlePanic 1.2 (19 section 12)
       10 FILLER BINARY-LONG VALUE 138.
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
    05 FILLER.
       10 FILLER PIC X(24) VALUE "bee".
       10 FILLER BINARY-LONG VALUE 10.             *> bee: speed 0.3 x 1.0; it has no panic goal, so the panic speed is the walk speed (open: BeeAttack 1.4, flight); attack_damage 2
       10 FILLER BINARY-LONG VALUE 198.
       10 FILLER BINARY-LONG VALUE 198.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
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
       10 FILLER PIC X(24) VALUE "frog".
       10 FILLER BINARY-LONG VALUE 10.             *> frog: speed 1.0 x 1.0, panic 2.0 (19 section 11.1); both capped below one block a tick (the move step does not sweep); attack_damage 10
       10 FILLER BINARY-LONG VALUE 999.
       10 FILLER BINARY-LONG VALUE 999.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 10.
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
       10 FILLER PIC X(24) VALUE "tadpole".
       10 FILLER BINARY-LONG VALUE 6.             *> tadpole: swimmer, speed 1.0 x 0.5, AnimalPanic 2.0 capped (19 section 11.2); kind 2 as the water animals
       10 FILLER BINARY-LONG VALUE 500.
       10 FILLER BINARY-LONG VALUE 999.
       10 FILLER BINARY-LONG VALUE 2.
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
       10 FILLER PIC X(24) VALUE "sniffer".
       10 FILLER BINARY-LONG VALUE 14.             *> sniffer: speed 0.1 x 1.0, panic 2.0 (19 section 14)
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 88.
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
       10 FILLER PIC X(24) VALUE "allay".
       10 FILLER BINARY-LONG VALUE 20.             *> allay: speed 0.1 x 1.0, AnimalPanic 2.5 (19 section 15); attack_damage 2
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 138.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 3.             *> natural spawn rule (SM-SPAWN)
       10 FILLER BINARY-LONG VALUE 0.             *> melee hit effect (SM-HITFX)
