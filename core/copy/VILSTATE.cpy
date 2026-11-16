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
       10 VL-O-N             BINARY-LONG.
       10 VL-OFFER           OCCURS 16 TIMES.
          15 VL-O-ROW        BINARY-LONG.
          15 VL-O-USES       BINARY-LONG.
          15 VL-O-DEMAND     BINARY-LONG.
          15 VL-O-SPECIAL    BINARY-LONG.
          15 VL-O-EXTRA      BINARY-LONG.
