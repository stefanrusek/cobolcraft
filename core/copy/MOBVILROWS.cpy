*> Villager row (lane 002-lane-mobsb; 19 section 22.1), included by STDMOBS.cpy last. Columns as the rows there.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "villager".
       10 FILLER BINARY-LONG VALUE 20.  *> max health (the mob default)
       10 FILLER BINARY-LONG VALUE 551.  *> speed x 1000 (0.5 squared / 0.454)
       10 FILLER BINARY-LONG VALUE 1239.  *> panic speed (0.5 x 1.5 squared / 0.454)
       10 FILLER BINARY-LONG VALUE 0.  *> kind (0 passive)
       10 FILLER BINARY-LONG VALUE 0.  *> attack damage
       10 FILLER BINARY-LONG VALUE 16.  *> follow range
       10 FILLER BINARY-LONG VALUE 0.  *> burns in daylight
       10 FILLER BINARY-LONG VALUE 0.  *> neutral kind
       10 FILLER BINARY-LONG VALUE 0.  *> experience
       10 FILLER BINARY-LONG VALUE 0.  *> fuse
       10 FILLER BINARY-LONG VALUE 0.  *> blast
       10 FILLER BINARY-LONG VALUE 0.  *> ranged
       10 FILLER BINARY-LONG VALUE 0.  *> spawn rule (0: no natural spawn; villages place villagers)
       10 FILLER BINARY-LONG VALUE 0.  *> hit effect
*> Rows added by lane mobsb4 (T8802): the wandering trader (19 section 23: speed 0.7, stroll 0.35 and panic 0.5 modifiers; no natural spawn, the spawner TRADER-TICK places it) and the trader llama (19 section 3.7: the llama's stats, health gene mean 22).
    05 FILLER.
       10 FILLER PIC X(24) VALUE "wandering_trader".
       10 FILLER BINARY-LONG VALUE 20.
       10 FILLER BINARY-LONG VALUE 132.
       10 FILLER BINARY-LONG VALUE 270.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "trader_llama".
       10 FILLER BINARY-LONG VALUE 22.
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER BINARY-LONG VALUE 97.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
