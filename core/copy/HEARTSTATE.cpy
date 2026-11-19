*> The creaking hearts in play (lane 002-lane-p49r; docs/protocol/31 section 6, 44-5 section 8; core/src/mob-20-17c.cob), EXTERNAL. HT-ENTRY: one per heart (HT-USED 1): its block position and dimension,
*> HT-LINK the entity id of its protector creaking (0 none), HT-TICKER the countdown of the state update (the body runs when its value before the decrement was below 0, then it is 20 + a draw of 0 to 4),
*> HT-STATE 0 UPROOTED, 1 DORMANT, 2 AWAKE, HT-AGE the ticks it has existed.
 78 HT-MAX                VALUE 16.
 01 HT-STATE-TABLE EXTERNAL.
    05 HT-ENTRY              OCCURS 16 TIMES.
       10 HT-USED            BINARY-LONG.
       10 HT-DIM             BINARY-LONG.
       10 HT-X               BINARY-LONG.
       10 HT-Y               BINARY-LONG.
       10 HT-Z               BINARY-LONG.
       10 HT-LINK            BINARY-LONG.
       10 HT-TICKER          BINARY-LONG.
       10 HT-STATE           BINARY-LONG.
       10 HT-AGE             BINARY-LONG.
