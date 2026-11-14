*> The saved state of the ender dragon fight (docs/protocol/45-entity-nbt-9 section 3.1, ender_dragon_fight.dat; core/src/end-38f.cob). EF-STAGE: 0 no respawn sequence, 1 start,
*> 2 preparing_to_summon_pillars, 3 summoning_pillars, 4 summoning_dragon, 5 end. EF-UUID and EF-CRYSTAL-UUID are four ints each (UUIDUtil int array); EF-HAS-UUID and
*> EF-HAS-PORTAL tell whether the optional keys exist. EF-GATEWAY holds the remaining gateway indexes in pop order.
 01 END-FIGHT.
    05 EF-SCAN              BINARY-LONG.
    05 EF-KILLED            BINARY-LONG.
    05 EF-PREVIOUS          BINARY-LONG.
    05 EF-STAGE             BINARY-LONG.
    05 EF-TIME              BINARY-LONG.
    05 EF-HAS-UUID          BINARY-LONG.
    05 EF-UUID              BINARY-LONG OCCURS 4 TIMES.
    05 EF-HAS-PORTAL        BINARY-LONG.
    05 EF-PORTAL            BINARY-LONG OCCURS 3 TIMES.
    05 EF-GATEWAY-COUNT     BINARY-LONG.
    05 EF-GATEWAY           BINARY-LONG OCCURS 20 TIMES.
    05 EF-CRYSTAL-COUNT     BINARY-LONG.
    05 EF-CRYSTAL           OCCURS 8 TIMES.
       10 EF-CRYSTAL-UUID   BINARY-LONG OCCURS 4 TIMES.
