*> The cure of zombie villagers (docs/protocol/20 section 4.2; core/src/mob-zv.cob), EXTERNAL, one entry per converting zombie villager (ZC-ID 0 = free): ZC-TIME the
*> conversion ticks left, ZC-PLAYER the entity id of the player who fed the golden apple.
 78 ZC-MAX                VALUE 64.
 01 ZC-STATE EXTERNAL.
    05 ZC-ENTRY              OCCURS 64 TIMES.
       10 ZC-ID              BINARY-LONG.
       10 ZC-TIME            BINARY-LONG.
       10 ZC-PLAYER          BINARY-LONG.
