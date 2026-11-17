*> The llama's caravan and spit (002-lane-mobsa5; docs/protocol/44 part 4 section 2.2, 19 section 3.7, 21 section 8.14).
*> - M44-LLAMA-TICK USING row, hx out, hz out, walk out (STDMOB-STEP, for a llama): the caravan goal then the spit goal. walk 1: the llama walks with the heading hx, hz (a heading of almost
*>   zero only turns it).
*> - M44-LLAMA-CARAVAN (LlamaFollowCaravanGoal, speed 2.1, limit 8): canUse for a llama that is in no caravan and not leashed: the nearest llama in a caravan with no tail within the box inflated by
*>   (9, 4, 9), else the nearest leashed llama with no tail that is closer; nothing closer than 2 blocks (squared distance 4); the candidate must be leashed or its chain must reach a leashed llama (8 hops:
*>   the doc says "if the llama itself is not leashed", which would never let a free llama join a lone leashed one; the candidate reading of the vanilla goal is used). On joining the head and tail rows
*>   are set (EN-LLAMA-HEAD, -TAIL), the speed is 2.1 and the counter 0. canContinueToUse: the head is alive and the chain reaches a leashed llama; beyond 26 blocks (676) the speed is multiplied by 1.2
*>   while it is at most 3.0 and the counter is set to 40, otherwise the goal ends when the counter is 0; the counter counts down. tick: the llama walks toward the point max(0, distance - 2) blocks along
*>   the line to its head at the speed modifier / 0.7 of its stroll speed (the stroll modifier is 0.7). stop: the caravan is left and the speed is reset.
*> - M44-LLAMA-SPIT (RangedAttackGoal(1.25, interval 40, range 20) with LlamaHurtByTarget): a new hit by a player (EN-KILLER-AGE rises) makes that player the target; within 20 blocks the llama faces it and
*>   after the attack time (first tick -1, then 40) spits once (a llama_spit projectile, PROJ-SPAWN kind 5, from (x - 0.95 sin(yaw), eye - 0.1, z + 0.95 cos(yaw)), direction to the target's body third
*>   with the vertical offset 0.2 x the horizontal distance, speed 1.5), then gives up the target (didSpit). Gaps: the shoot uncertainty (10), the line of sight, the approach at 1.25 beyond 20 blocks
*>   (the target is dropped beyond 40), wolves as targets (LlamaAttackWolf), the trader llama (no wandering trader mob exists; the trader-llama leash behaviour is not read, doc 19 open question 29).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-IS.
*> USING row, ok out: a used, living llama (or trader llama) row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 0 TO L-OK
     IF L-ROW > 0 AND EN-USED(L-ROW) = 1 AND EN-PLAYER(L-ROW) = 0
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0 AND EN-HEALTH(L-ROW) > 0
             IF SM-KEY(WS-M) = "llama" OR "trader_llama"
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-LLAMA-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-CHAIN.
*> USING row, hops (the first hop count), ok out: firstIsLeashed: the chain of heads from the row reaches a leashed llama, a hop count above 8 ends it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CUR                 BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-HOPS                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HOPS                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HOPS L-OK.
     MOVE 0 TO L-OK WS-DONE
     MOVE L-ROW TO WS-CUR
     MOVE L-HOPS TO WS-HOPS
     PERFORM UNTIL WS-DONE = 1
         IF WS-HOPS > 8 OR EN-LLAMA-HEAD(WS-CUR) = 0
             MOVE 1 TO WS-DONE
         ELSE
             MOVE EN-LLAMA-HEAD(WS-CUR) TO WS-HEAD
             IF EN-LEASH(WS-HEAD) > 0 OR EN-LEASH-KNOT(WS-HEAD) > 0
                 MOVE 1 TO L-OK WS-DONE
             ELSE
                 MOVE WS-HEAD TO WS-CUR
                 ADD 1 TO WS-HOPS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-LLAMA-CHAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-LEAVE.
*> USING row: stop: the llama leaves its caravan (the head loses its tail) and its speed modifier is reset to 2.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-LLAMA-HEAD(L-ROW) > 0
         IF EN-LLAMA-TAIL(EN-LLAMA-HEAD(L-ROW)) = L-ROW
             MOVE 0 TO EN-LLAMA-TAIL(EN-LLAMA-HEAD(L-ROW))
         END-IF
         MOVE 0 TO EN-LLAMA-HEAD(L-ROW)
     END-IF
     MOVE 2.1 TO EN-LLAMA-SPEED(L-ROW)
     MOVE 0 TO EN-LLAMA-DIST(L-ROW)
     GOBACK.
 END PROGRAM M44-LLAMA-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-CARAVAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-GO                  FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-HOPS1               BINARY-LONG VALUE 1.
 01 WS-HOPS0               BINARY-LONG VALUE 0.
 01 WS-CHAIN               BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     IF EN-LLAMA-HEAD(L-ROW) = 0
         IF EN-LEASH(L-ROW) = 0 AND EN-LEASH-KNOT(L-ROW) = 0
             PERFORM JOIN-SEARCH
         END-IF
     ELSE
         PERFORM FOLLOW
     END-IF
     GO TO MAIN-EXIT.

 JOIN-SEARCH.
     MOVE 0 TO WS-BEST
     MOVE 1000000 TO WS-BEST-D2
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                 CALL "M44-LLAMA-IS" USING WS-E WS-OK
                 IF WS-OK = 1 AND EN-LLAMA-TAIL(WS-E) = 0
                     COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                     COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF FUNCTION ABS(WS-DX) <= 9.9 AND FUNCTION ABS(WS-DZ) <= 9.9 AND FUNCTION ABS(WS-DY) <= 5.87
                             AND WS-D2 < WS-BEST-D2
                         IF (WS-PASS = 1 AND EN-LLAMA-HEAD(WS-E) > 0)
                                 OR (WS-PASS = 2 AND (EN-LEASH(WS-E) > 0 OR EN-LEASH-KNOT(WS-E) > 0))
                             MOVE WS-E TO WS-BEST
                             MOVE WS-D2 TO WS-BEST-D2
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-BEST > 0 AND WS-BEST-D2 >= 4
         MOVE 1 TO WS-CHAIN
         IF EN-LEASH(WS-BEST) = 0 AND EN-LEASH-KNOT(WS-BEST) = 0
             CALL "M44-LLAMA-CHAIN" USING WS-BEST WS-HOPS1 WS-CHAIN
         END-IF
         IF WS-CHAIN = 1
             MOVE WS-BEST TO EN-LLAMA-HEAD(L-ROW)
             MOVE L-ROW TO EN-LLAMA-TAIL(WS-BEST)
             MOVE 2.1 TO EN-LLAMA-SPEED(L-ROW)
             MOVE 0 TO EN-LLAMA-DIST(L-ROW)
         END-IF
     END-IF.

 FOLLOW.
     MOVE EN-LLAMA-HEAD(L-ROW) TO WS-HEAD
     CALL "M44-LLAMA-IS" USING WS-HEAD WS-OK
     IF WS-OK = 1
         CALL "M44-LLAMA-CHAIN" USING L-ROW WS-HOPS0 WS-CHAIN
         MOVE WS-CHAIN TO WS-OK
     END-IF
     IF WS-OK = 1
         COMPUTE WS-DX = EN-X(WS-HEAD) - EN-X(L-ROW)
         COMPUTE WS-DY = EN-Y(WS-HEAD) - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-Z(WS-HEAD) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF WS-D2 > 676
             IF EN-LLAMA-SPEED(L-ROW) <= 3.0
                 COMPUTE EN-LLAMA-SPEED(L-ROW) = EN-LLAMA-SPEED(L-ROW) * 1.2
                 MOVE 40 TO EN-LLAMA-DIST(L-ROW)
             ELSE
                 IF EN-LLAMA-DIST(L-ROW) = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-OK = 1
         IF EN-LLAMA-DIST(L-ROW) > 0 AND WS-D2 <= 676
             SUBTRACT 1 FROM EN-LLAMA-DIST(L-ROW)
         END-IF
         PERFORM WALK-TO-HEAD
     ELSE
         CALL "M44-LLAMA-LEAVE" USING L-ROW
     END-IF.

 WALK-TO-HEAD.
*>   The point max(0, d - 2) blocks along the line to the head.
     COMPUTE WS-D = FUNCTION SQRT(WS-D2)
     COMPUTE WS-GO = WS-D - 2
     IF WS-GO < 0
         MOVE 0 TO WS-GO
     END-IF
     MOVE 1 TO L-WALK
     IF WS-GO > 0
         COMPUTE WS-GX = FUNCTION INTEGER(EN-X(L-ROW) + WS-DX / WS-D * WS-GO)
         COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(L-ROW) + WS-DZ / WS-D * WS-GO)
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
         COMPUTE WS-SCALE = EN-LLAMA-SPEED(L-ROW) / 0.7
         COMPUTE L-HX = L-HX * WS-SCALE
         COMPUTE L-HZ = L-HZ * WS-SCALE
     ELSE
         COMPUTE L-HX = WS-DX * 0.000001
         COMPUTE L-HZ = WS-DZ * 0.000001
     END-IF.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM M44-LLAMA-CARAVAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-SPIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-KIND                BINARY-LONG VALUE 5.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-SPIT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
*>   A new hit by a player: the age of the memory rose.
     IF EN-KILLER(L-ROW) > 0 AND EN-KILLER-AGE(L-ROW) > EN-SPIT-AGE(L-ROW)
         MOVE EN-KILLER(L-ROW) TO EN-SPIT-TGT(L-ROW)
         MOVE -1 TO EN-SPIT-CD(L-ROW)
     END-IF
     MOVE EN-KILLER-AGE(L-ROW) TO EN-SPIT-AGE(L-ROW)
     IF EN-SPIT-TGT(L-ROW) > 0
         MOVE EN-SPIT-TGT(L-ROW) TO WS-P
         MOVE 0 TO WS-OK
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
             IF WS-D2 <= 1600
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 0
             MOVE 0 TO EN-SPIT-TGT(L-ROW)
         ELSE
             IF WS-D2 <= 400
                 MOVE 1 TO L-WALK
                 COMPUTE L-HX = WS-DX * 0.000001
                 COMPUTE L-HZ = WS-DZ * 0.000001
                 ADD -1 TO EN-SPIT-CD(L-ROW)
                 EVALUATE TRUE
                     WHEN EN-SPIT-CD(L-ROW) = 0
                         PERFORM SPIT
                     WHEN EN-SPIT-CD(L-ROW) < 0
                         MOVE 40 TO EN-SPIT-CD(L-ROW)
                 END-EVALUATE
             END-IF
         END-IF
     END-IF
     GO TO MAIN-EXIT.

 SPIT.
*>   Spawned at (x - (width + 1) x 0.5 x sin(body yaw), eye - 0.1, z + (width + 1) x 0.5 x cos(body yaw)), width 0.9, eye 1.7765.
     COMPUTE WS-RADIANS = EN-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-SX = EN-X(L-ROW) - 0.95 * FUNCTION SIN(WS-RADIANS)
     COMPUTE WS-SY = EN-Y(L-ROW) + 1.7765 - 0.1
     COMPUTE WS-SZ = EN-Z(L-ROW) + 0.95 * FUNCTION COS(WS-RADIANS)
     COMPUTE WS-DX = PL-X(WS-P) - WS-SX
     COMPUTE WS-DY = PL-Y(WS-P) + 0.6 - WS-SY
     COMPUTE WS-DZ = PL-Z(WS-P) - WS-SZ
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) * 0.2
     COMPUTE WS-DY = WS-DY + WS-H
     CALL "PROJ-SPAWN" USING WS-KIND EN-DIM(L-ROW) WS-SX WS-SY WS-SZ WS-DX WS-DY WS-DZ WS-POWER EN-ID(L-ROW) WS-SPIT
*>   didSpit: the hurt-by goal ends once, the target is given up.
     MOVE 0 TO EN-SPIT-TGT(L-ROW)
     MOVE 40 TO EN-SPIT-CD(L-ROW).
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM M44-LLAMA-SPIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LLAMA-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     CALL "M44-LLAMA-CARAVAN" USING L-ROW L-HX L-HZ L-WALK
     IF L-WALK = 0
         CALL "M44-LLAMA-SPIT" USING L-ROW L-HX L-HZ L-WALK
     END-IF
     GOBACK.
 END PROGRAM M44-LLAMA-TICK.
