*> The state of wardens (002-lane-p49b; docs/protocol/20 section 15; core/src/mob-20-15.cob), EXTERNAL.
*> WD-ENTRY: one per warden entity id (WD-ID 0 = free). WD-ANGER: the anger value per player row (the anger manager, capped at 150); WD-SONIC-CD the ticks left of the sonic
*> boom cooldown memory (0 = absent); WD-BOOM the tick of the sonic boom behaviour (0 = not running, 1 at its start, 60 total); WD-DIG-CD the ticks left of the dig cooldown memory.
 78 WD-MAX                VALUE 8.
 01 WD-STATE EXTERNAL.
    05 WD-ENTRY              OCCURS 8 TIMES.
       10 WD-ID              BINARY-LONG.
       10 WD-SONIC-CD        BINARY-LONG.
       10 WD-BOOM            BINARY-LONG.
       10 WD-DIG-CD          BINARY-LONG.
       10 WD-ANGER           BINARY-LONG OCCURS 64 TIMES.
