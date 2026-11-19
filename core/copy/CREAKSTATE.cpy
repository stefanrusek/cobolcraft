*> The state of creakings (lane 002-lane-p49r; docs/protocol/20 section 17; core/src/mob-20-17b.cob), EXTERNAL.
*> CRK-ENTRY: one per creaking entity id (CRK-ID 0 = free). CRK-CAN-MOVE and CRK-ACTIVE are the metadata CAN_MOVE (default 1) and IS_ACTIVE (default 0); CRK-SENSOR the ticks to the next scan of the
*> nearest_players sensor (a draw of 0 to 19 at the start, then 20); CRK-LIST the player rows of the last scan (CRK-COUNT of them, nearest first); CRK-TEAR the ticks left of the teardown of a dying
*> heart-bound creaking (0 = not tearing down); CRK-HOME 1 when it is bound to a creaking heart at (CRK-HX, CRK-HY, CRK-HZ).
 78 CRK-MAX                VALUE 16.
 01 CRK-STATE EXTERNAL.
    05 CRK-ENTRY              OCCURS 16 TIMES.
       10 CRK-ID              BINARY-LONG.
       10 CRK-CAN-MOVE        BINARY-LONG.
       10 CRK-ACTIVE          BINARY-LONG.
       10 CRK-SENSOR          BINARY-LONG.
       10 CRK-COUNT           BINARY-LONG.
       10 CRK-LIST            BINARY-LONG OCCURS 16 TIMES.
       10 CRK-TEAR            BINARY-LONG.
       10 CRK-HOME            BINARY-LONG.
       10 CRK-HX              BINARY-LONG.
       10 CRK-HY              BINARY-LONG.
       10 CRK-HZ              BINARY-LONG.
