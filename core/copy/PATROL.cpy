*> Pillager patrols (docs/protocol/20 sections 13 and 14.1; core/src/mob-20-patrol.cob), EXTERNAL. PT-NEXT the spawner counter (ticks until the next attempt); PT-ENTRY one patrol
*> member (PT-ID entity id, 0 = free): PT-LEADER 1 for the leader (wears the ominous banner in the original), PT-TX and PT-TZ the patrol target.
 78 PT-MAX                VALUE 64.
 01 PT-STATE EXTERNAL.
    05 PT-NEXT               BINARY-LONG.
    05 PT-ENTRY              OCCURS 64 TIMES.
       10 PT-ID              BINARY-LONG.
       10 PT-LEADER          BINARY-LONG.
       10 PT-TX              BINARY-LONG.
       10 PT-TZ              BINARY-LONG.
