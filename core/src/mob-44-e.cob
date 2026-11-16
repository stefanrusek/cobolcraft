*> Bee pollination and camel posture (002-lane-mobsa2; docs/protocol/44-residual-mob-questions-4-land-animals.md sections 15 and 2.3).
*> - BeePollinate: a bee that carries no nectar and has not stung, with no retry cooldown (EN-BEE-CD) and a flower in reach, starts (EN-BEE-POLL 1). Without a flower the retry cooldown becomes
*>   20 + draw (U(20, 60)). Every tick counts pollinatingTicks and successfulPollinatingTicks (EN-BEE-SUCC); at 600 ticks, or when the flower goes, the goal stops: more than 400 successful
*>   ticks give nectar (EN-BEE-NECTAR 1), the retry cooldown is 200 and the counters are cleared.
*> - RandomSitting(20): a camel on the ground, not leashed and without a rider changes pose (standing to sitting and back) once the pose time (now - EN-CAMEL-POSE-T) is at least 400.
*> - Dash: a dash starts when the cooldown (EN-CAMEL-DASH) is 0 and sets 55; the cooldown counts down by 1 a call while it runs.
*> Open items: finding flowers, hive trips and the hover movement of a bee; the camel's dash motion (1.4285 vertical, 22.2222 horizontal), sit and stand animations, the suffocation test of a pose change.
*>
*> Entry points:
*>   M44-BEE-POLL-START USING row, flower in reach (0 or 1), draw (0 to 40), started out
*>   M44-BEE-POLL-TICK USING row, flower still valid (0 or 1), ended out
*>   M44-CAMEL-SIT USING row, now (game tick), leashed, rider present, changed out
*>   M44-CAMEL-DASH USING row, started out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-POLL-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLOWER               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLOWER L-DRAW L-STARTED.
     MOVE 0 TO L-STARTED
     IF EN-BEE-NECTAR(L-ROW) = 0 AND EN-BEE-STUNG(L-ROW) = 0 AND EN-BEE-POLL(L-ROW) = 0
         IF L-FLOWER = 0
             COMPUTE EN-BEE-CD(L-ROW) = 20 + FUNCTION MOD(L-DRAW, 41)
         ELSE
             IF EN-BEE-CD(L-ROW) = 0
                 MOVE 1 TO L-STARTED
                 MOVE 1 TO EN-BEE-POLL(L-ROW)
                 MOVE 0 TO EN-BEE-SUCC(L-ROW)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-BEE-POLL-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-BEE-POLL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLOWER               BINARY-LONG.
 01 L-ENDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLOWER L-ENDED.
     MOVE 0 TO L-ENDED
     IF EN-BEE-POLL(L-ROW) > 0
         IF L-FLOWER = 1
             ADD 1 TO EN-BEE-POLL(L-ROW)
             ADD 1 TO EN-BEE-SUCC(L-ROW)
         END-IF
         IF L-FLOWER = 0 OR EN-BEE-POLL(L-ROW) >= 600
             MOVE 1 TO L-ENDED
             IF EN-BEE-SUCC(L-ROW) > 400
                 MOVE 1 TO EN-BEE-NECTAR(L-ROW)
             END-IF
             MOVE 200 TO EN-BEE-CD(L-ROW)
             MOVE 0 TO EN-BEE-POLL(L-ROW) EN-BEE-SUCC(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-BEE-POLL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAMEL-SIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NOW                  BINARY-LONG.
 01 L-LEASHED              BINARY-LONG.
 01 L-RIDER                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NOW L-LEASHED L-RIDER L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF L-NOW - EN-CAMEL-POSE-T(L-ROW) >= 400 AND L-LEASHED = 0 AND L-RIDER = 0 AND EN-ON-GROUND(L-ROW) = 1
         MOVE 1 TO L-CHANGED
         COMPUTE EN-CAMEL-POSE(L-ROW) = 1 - EN-CAMEL-POSE(L-ROW)
         MOVE L-NOW TO EN-CAMEL-POSE-T(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-CAMEL-SIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-CAMEL-DASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STARTED.
     MOVE 0 TO L-STARTED
     IF EN-CAMEL-DASH(L-ROW) = 0
         MOVE 1 TO L-STARTED
         MOVE 55 TO EN-CAMEL-DASH(L-ROW)
     ELSE
         SUBTRACT 1 FROM EN-CAMEL-DASH(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-CAMEL-DASH.
