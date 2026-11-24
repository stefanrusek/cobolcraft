*> Villager brain: work, stroll, bed and hiding behaviours (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md sections 2.7 to 2.10; lane 002-lane-p49h, T22003). Pure
*> decision units like q44-44-3b.cob: the caller keeps the state and passes what the rule reads. Distances are squared, FLOAT-LONG.
*>   Q3-WORK-START USING game time, last check (in/out), draw (nextInt(2)), same dimension, distance squared, yes out    WorkAtPoi start (300 ticks, 1 in 2, within 1.73)
*>   Q3-WORK-CONTINUE USING same dimension, distance squared, has job site, yes out
*>   Q3-MAKE-BREAD USING bread, wheat (in/out), room for bread, loaves out, dropped out                       WorkAtComposter.makeBread
*>   Q3-COMPOST-SCAN USING slots, kind table (8; 0 other, 1 wheat seeds, 2 beetroot seeds), count table (8), take table out (8), total out      compostItems
*>   Q3-STROLL-POI USING same dimension, near, cooldown (in/out), walk out                                     StrollToPoi (cooldown 80)
*>   Q3-STROLL-LIST USING main near, size, draw, same dimension, entry near, cooldown (in/out), walk out, pick out (1 based, 0 no draw)   StrollToPoiList (cooldown 100)
*>   Q3-HOME-GATE USING game time, last run (in/out), found, distance squared, draw (nextInt(20)), mode out (0 nothing, 1 collect)   SetClosestHomeAsWalkTarget steps 1 to 3
*>   Q3-BATCH-FILTER USING in map, counter (in/out), last run, accept out, expiry out                           the position filter of steps 4 (also nearest_bed, 4.5)
*>   Q3-HOME-RESULT USING path, can reach, type at target, counter, walk out, purge out                         steps 5 and 6
*>   Q3-VILLAGE-START USING is village, yes out                                                              GoToClosestVillage
*>   Q3-VILLAGE-PICK USING d0, samples, distance table (5), pick out (1 based, 0 none), kind out (1 accepted, 2 fallback, 0 none)
*>   Q3-WAKE USING rest active, sleeping, stop out                                                           WakeUp
*>   Q3-JUMP-START USING baby, on or over bed, nearest bed present, yes out                                  JumpOnBed
*>   Q3-JUMP-INIT USING draw (nextInt(4)), budget out, jumps out, cooldown out
*>   Q3-JUMP-TICK USING on or over bed, on bed surface, budget (in/out), jumps (in/out), cooldown (in/out), jump out
*>   Q3-JUMP-CONTINUE USING baby, bed jumpable, on or over bed, budget, jumps, yes out
*>   Q3-HIDE-PICK USING found, found within radius, random found, stored, source out (0 none, 1 find, 2 random, 3 stored)       LocateHidingPlace
*>   Q3-HIDE-WALK USING within close enough, walk out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-WORK-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 2.9929.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-SAME                  BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-LAST L-DRAW L-SAME L-D2 L-YES.
     MOVE 0 TO L-YES
     IF L-NOW - L-LAST < 300
         GOBACK
     END-IF
*>   lastCheck is set when the check passes the one-in-two gate (2.7).
     IF L-DRAW NOT = 0
         GOBACK
     END-IF
     MOVE L-NOW TO L-LAST
     IF L-SAME = 1 AND L-D2 < WS-LIMIT
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-WORK-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-WORK-CONTINUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 2.9929.
 LINKAGE SECTION.
 01 L-SAME                  BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-JOB                   BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-D2 L-JOB L-YES.
     MOVE 0 TO L-YES
     IF L-JOB = 1 AND L-SAME = 1 AND L-D2 < WS-LIMIT
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-WORK-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-MAKE-BREAD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BREAD                 BINARY-LONG.
 01 L-WHEAT                 BINARY-LONG.
 01 L-ROOM                  BINARY-LONG.
 01 L-LOAVES                BINARY-LONG.
 01 L-DROPPED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BREAD L-WHEAT L-ROOM L-LOAVES L-DROPPED.
     MOVE 0 TO L-LOAVES L-DROPPED
     IF L-BREAD > 36
         GOBACK
     END-IF
     COMPUTE L-LOAVES = FUNCTION MIN(3, FUNCTION INTEGER(L-WHEAT / 3))
     IF L-LOAVES = 0
         GOBACK
     END-IF
     COMPUTE L-WHEAT = L-WHEAT - L-LOAVES * 3
     IF L-LOAVES > L-ROOM
         COMPUTE L-DROPPED = L-LOAVES - L-ROOM
     END-IF
     GOBACK.
 END PROGRAM Q3-MAKE-BREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-COMPOST-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 01 WS-BUDGET               BINARY-LONG.
 01 WS-TOTAL-1              BINARY-LONG.
 01 WS-TOTAL-2              BINARY-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOTS                 BINARY-LONG.
 01 L-KIND-TABLE.
    05 L-KIND               BINARY-LONG OCCURS 8 TIMES.
 01 L-COUNT-TABLE.
    05 L-COUNT              BINARY-LONG OCCURS 8 TIMES.
 01 L-TAKE-TABLE.
    05 L-TAKE               BINARY-LONG OCCURS 8 TIMES.
 01 L-TOTAL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOTS L-KIND-TABLE L-COUNT-TABLE L-TAKE-TABLE L-TOTAL.
*>   A budget of 20 items per cycle, 10 kept of each seed type; the slots are scanned from the last to the first with running totals per type.
     MOVE 20 TO WS-BUDGET
     MOVE 0 TO WS-TOTAL-1 WS-TOTAL-2 L-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 0 TO L-TAKE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-SLOTS BY -1 UNTIL WS-I < 1 OR WS-BUDGET <= 0
         MOVE 0 TO WS-T
         EVALUATE L-KIND(WS-I)
             WHEN 1
                 ADD L-COUNT(WS-I) TO WS-TOTAL-1
                 MOVE WS-TOTAL-1 TO WS-T
             WHEN 2
                 ADD L-COUNT(WS-I) TO WS-TOTAL-2
                 MOVE WS-TOTAL-2 TO WS-T
         END-EVALUATE
         IF L-KIND(WS-I) > 0
             COMPUTE WS-N = FUNCTION MIN(WS-T - 10, WS-BUDGET)
             COMPUTE WS-N = FUNCTION MIN(WS-N, L-COUNT(WS-I))
             IF WS-N > 0
                 MOVE WS-N TO L-TAKE(WS-I)
                 SUBTRACT WS-N FROM WS-BUDGET
                 ADD WS-N TO L-TOTAL
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-COMPOST-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-STROLL-POI.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                  BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-COOLDOWN              BINARY-LONG.
 01 L-WALK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-NEAR L-COOLDOWN L-WALK.
     MOVE 0 TO L-WALK
     IF L-SAME = 1 AND L-NEAR = 0 AND L-COOLDOWN <= 0
         MOVE 1 TO L-WALK
         MOVE 80 TO L-COOLDOWN
     END-IF
     GOBACK.
 END PROGRAM Q3-STROLL-POI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-STROLL-LIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAIN                  BINARY-LONG.
 01 L-SIZE                  BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-SAME                  BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-COOLDOWN              BINARY-LONG.
 01 L-WALK                  BINARY-LONG.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MAIN L-SIZE L-DRAW L-SAME L-NEAR L-COOLDOWN L-WALK L-PICK.
*>   The entry is drawn (nextInt(size), the caller passes the draw) only when the main POI is within the distance.
     MOVE 0 TO L-WALK L-PICK
     IF L-MAIN = 1 AND L-SIZE > 0
         COMPUTE L-PICK = L-DRAW + 1
         IF L-SAME = 1 AND L-NEAR = 0 AND L-COOLDOWN <= 0
             MOVE 1 TO L-WALK
             MOVE 100 TO L-COOLDOWN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-STROLL-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HOME-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-DIST                  BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-MODE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-LAST L-FOUND L-DIST L-DRAW L-MODE.
     MOVE 0 TO L-MODE
     EVALUATE TRUE
         WHEN L-NOW - L-LAST < 20
             CONTINUE
         WHEN L-FOUND = 0 OR L-DIST <= 4
             CONTINUE
         WHEN OTHER
             COMPUTE L-LAST = L-NOW + L-DRAW
             MOVE 1 TO L-MODE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-HOME-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BATCH-FILTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-MAP                BINARY-LONG.
 01 L-COUNTER               BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-ACCEPT                BINARY-LONG.
 01 L-EXPIRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-MAP L-COUNTER L-LAST L-ACCEPT L-EXPIRY.
     MOVE 0 TO L-ACCEPT L-EXPIRY
     IF L-IN-MAP = 1
         GOBACK
     END-IF
     ADD 1 TO L-COUNTER
     IF L-COUNTER < 5
         MOVE 1 TO L-ACCEPT
         COMPUTE L-EXPIRY = L-LAST + 40
     END-IF
     GOBACK.
 END PROGRAM Q3-BATCH-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HOME-RESULT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                  BINARY-LONG.
 01 L-REACH                 BINARY-LONG.
 01 L-TYPE                  BINARY-LONG.
 01 L-COUNTER               BINARY-LONG.
 01 L-WALK                  BINARY-LONG.
 01 L-PURGE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-REACH L-TYPE L-COUNTER L-WALK L-PURGE.
     MOVE 0 TO L-WALK L-PURGE
     IF L-PATH = 1 AND L-REACH = 1
         IF L-TYPE = 1
             MOVE 1 TO L-WALK
         END-IF
     ELSE
         IF L-COUNTER < 5
             MOVE 1 TO L-PURGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-HOME-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-VILLAGE-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VILLAGE               BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VILLAGE L-YES.
     MOVE 1 TO L-YES
     IF L-VILLAGE = 1
         MOVE 0 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-VILLAGE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-VILLAGE-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-D0                    BINARY-LONG.
 01 L-SAMPLES               BINARY-LONG.
 01 L-D-TABLE.
    05 L-D                  BINARY-LONG OCCURS 5 TIMES.
 01 L-PICK                  BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D0 L-SAMPLES L-D-TABLE L-PICK L-KIND.
*>   Up to 5 samples: a smaller section distance is accepted at once; an equal one is remembered (the last) as the fallback.
     MOVE 0 TO L-PICK L-KIND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-SAMPLES OR L-KIND = 1
         EVALUATE TRUE
             WHEN L-D(WS-I) < L-D0
                 MOVE WS-I TO L-PICK
                 MOVE 1 TO L-KIND
             WHEN L-D(WS-I) = L-D0
                 MOVE WS-I TO L-PICK
                 MOVE 2 TO L-KIND
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-VILLAGE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-WAKE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REST                  BINARY-LONG.
 01 L-SLEEPING              BINARY-LONG.
 01 L-STOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REST L-SLEEPING L-STOP.
     MOVE 0 TO L-STOP
     IF L-REST = 0 AND L-SLEEPING = 1
         MOVE 1 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM Q3-WAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-JUMP-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                  BINARY-LONG.
 01 L-ONBED                 BINARY-LONG.
 01 L-HASBED                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-ONBED L-HASBED L-YES.
     MOVE 0 TO L-YES
     IF L-BABY = 1 AND (L-ONBED = 1 OR L-HASBED = 1)
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-JUMP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-JUMP-INIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-BUDGET                BINARY-LONG.
 01 L-JUMPS                 BINARY-LONG.
 01 L-COOLDOWN              BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-BUDGET L-JUMPS L-COOLDOWN.
     MOVE 100 TO L-BUDGET
     COMPUTE L-JUMPS = 3 + L-DRAW
     MOVE 0 TO L-COOLDOWN
     GOBACK.
 END PROGRAM Q3-JUMP-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-JUMP-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ONBED                 BINARY-LONG.
 01 L-SURFACE               BINARY-LONG.
 01 L-BUDGET                BINARY-LONG.
 01 L-JUMPS                 BINARY-LONG.
 01 L-COOLDOWN              BINARY-LONG.
 01 L-JUMP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ONBED L-SURFACE L-BUDGET L-JUMPS L-COOLDOWN L-JUMP.
     MOVE 0 TO L-JUMP
     EVALUATE TRUE
         WHEN L-ONBED = 0
             SUBTRACT 1 FROM L-BUDGET
         WHEN L-COOLDOWN > 0
             SUBTRACT 1 FROM L-COOLDOWN
         WHEN L-SURFACE = 1
             MOVE 1 TO L-JUMP
             SUBTRACT 1 FROM L-JUMPS
             MOVE 5 TO L-COOLDOWN
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-JUMP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-JUMP-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                  BINARY-LONG.
 01 L-BEDOK                 BINARY-LONG.
 01 L-ONBED                 BINARY-LONG.
 01 L-BUDGET                BINARY-LONG.
 01 L-JUMPS                 BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-BEDOK L-ONBED L-BUDGET L-JUMPS L-YES.
     MOVE 0 TO L-YES
     IF L-BABY = 1 AND L-BEDOK = 1
         EVALUATE TRUE
             WHEN L-ONBED = 0 AND L-BUDGET <= 0
                 CONTINUE
             WHEN L-ONBED = 1 AND L-JUMPS <= 0
                 CONTINUE
             WHEN OTHER
                 MOVE 1 TO L-YES
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM Q3-JUMP-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HIDE-PICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOUND                 BINARY-LONG.
 01 L-WITHIN                BINARY-LONG.
 01 L-RANDOM                BINARY-LONG.
 01 L-STORED                BINARY-LONG.
 01 L-SOURCE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-WITHIN L-RANDOM L-STORED L-SOURCE.
     EVALUATE TRUE
         WHEN L-FOUND = 1 AND L-WITHIN = 1
             MOVE 1 TO L-SOURCE
         WHEN L-RANDOM = 1
             MOVE 2 TO L-SOURCE
         WHEN L-STORED = 1
             MOVE 3 TO L-SOURCE
         WHEN OTHER
             MOVE 0 TO L-SOURCE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-HIDE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HIDE-WALK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLOSE                 BINARY-LONG.
 01 L-WALK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CLOSE L-WALK.
     MOVE 1 TO L-WALK
     IF L-CLOSE = 1
         MOVE 0 TO L-WALK
     END-IF
     GOBACK.
 END PROGRAM Q3-HIDE-WALK.
