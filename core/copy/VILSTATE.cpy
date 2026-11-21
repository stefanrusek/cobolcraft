*> The state of villagers and wandering traders (docs/protocol/19-mobs-land-friendly-and-neutral.md section 22 and 23; core/src/mob-vil.cob), EXTERNAL, one entry per
*> entity id (VL-ID 0 = free). A side table, not part of EN-ENTRY, so the 1024 entity rows do not grow. VL-KIND 1 villager, 2 wandering trader. VL-TYPE 0 desert to
*> 6 taiga (22.1), VL-PROF the profession key, VL-LEVEL 1 to 5, VL-XP the villager xp. Offers (22.4): VL-O-ROW is the TRADES.cpy row, uses, demand, special price
*> difference, extra price (the modifier price of the offer); VL-O-N offers exist, VL-BUILT the level whose trade set was added last.
 78 VL-MAX                VALUE 256.
 01 VL-STATE EXTERNAL.
    05 VL-ENTRY              OCCURS 256 TIMES.
       10 VL-ID              BINARY-LONG.
       10 VL-KIND            BINARY-LONG.
       10 VL-TYPE            BINARY-LONG.
       10 VL-PROF            PIC X(16).
       10 VL-LEVEL           BINARY-LONG.
       10 VL-XP              BINARY-LONG.
       10 VL-BUILT           BINARY-LONG.
       10 VL-LAST-RESTOCK    BINARY-LONG.
       10 VL-RESTOCKS        BINARY-LONG.
       10 VL-FOOD            BINARY-LONG.
       10 VL-LAST-DECAY      BINARY-LONG.
       10 VL-NEXT-SCAN       BINARY-LONG.
       10 VL-GIFT-CD         BINARY-LONG.        *> GiveGiftToHero: cooldown left + 1 (0 = not started: 600), T8104
       10 VL-GIFT-ACT        BINARY-LONG.        *> 1 while a gift is on its way
       10 VL-GIFT-AGE        BINARY-LONG.        *> ticks since the start
       10 VL-GIFT-PL         BINARY-LONG.        *> the hero's player row
       10 VL-NEXT-BRAIN      BINARY-LONG.        *> the tick of the next brain decision (T8106)
       10 VL-SLEEP           BINARY-LONG.        *> 1 while sleeping in the home bed
       10 VL-LAST-SLEPT      BINARY-LONG.        *> game tick of the last sleep start (0 never)
       10 VL-LAST-WOKEN      BINARY-LONG.        *> game tick of the last waking (0 never)
       10 VL-POT             BINARY-LONG.        *> 1 while a job site is claimed but the profession is not taken yet
       10 VL-INV             BINARY-LONG.        *> food points in the inventory (22.6; items are not modelled, only their nutrition), T8800
       10 VL-LOVE            BINARY-LONG.        *> VillagerMakeLove: the partner's entity id (0 none)
       10 VL-LOVE-AT         BINARY-LONG.        *> the tick of the birth
       10 VL-GOLEM-UNTIL     BINARY-LONG.        *> golem_detected_recently: the tick it expires (0 none), T8801
       10 VL-LAST-GOSSIP     BINARY-LONG.        *> lastGossipTime
       10 VL-DESPAWN         BINARY-LONG.        *> wandering trader: ticks to despawn (48000 from the spawner, 0 none), T8802
       10 VL-LLAMA-A         BINARY-LONG.        *> wandering trader: entity ids of its two trader llamas
       10 VL-LLAMA-B         BINARY-LONG.
       10 VL-O-N             BINARY-LONG.
       10 VL-OFFER           OCCURS 16 TIMES.
          15 VL-O-ROW        BINARY-LONG.
          15 VL-O-USES       BINARY-LONG.
          15 VL-O-DEMAND     BINARY-LONG.
          15 VL-O-SPECIAL    BINARY-LONG.
          15 VL-O-EXTRA      BINARY-LONG.
          15 VL-O-VAR        BINARY-LONG.        *> the patch handle of the result (an enchanted book's stored_enchantments), 0 none
