*> Villager brain: farmer and movement helpers, sensors, trading (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md sections 2.17, 2.18, 3.2 to 3.4, 4; lane
*> 002-lane-p49h, T22005). Pure decision units like q44-44-3b.cob. A flag is 1 or 0; a distance is squared, FLOAT-LONG.
*>   Q3-BLOCKMEM USING same dimension, has since, since, game time, give up after, manhattan distance, too far, close enough, random position found, outcome out
*>                    (0 nothing, 1 release and erase, 2 walk to the random position, 3 walk to the block)      SetWalkTargetFromBlockMemory
*>   Q3-BLOCKMEM-PARAMS USING instance (1 job_site, 2 home, 3 meeting_point meet, 4 meeting_point pre-raid), close enough out, too far out, give up out, speed out (times s)
*>   Q3-HIDDEN USING game time, heard bell time, counter (in/out), near hiding place, done out                  SetHiddenState (15 s, closeEnough 3)
*>   Q3-SKY-OFFSET USING draw (nextInt(20)), draw (nextInt(6)), draw (nextInt(20)), x, y, z offsets out; Q3-SKY-START USING sees sky, run out; Q3-SKY-ACCEPT USING sees sky, motion blocking height, villager y, ok out
*>   Q3-HARVEST-CELL USING fully grown crop, air, farmland below, valid out; Q3-HARVEST-START USING griefing, farmer, game time, next ok start, cells, draw, pick out
*>   Q3-HARVEST-STEP USING has cell, near the cell, game time, next ok start, time worked (in/out), act out; Q3-HARVEST-RECHOOSE USING remaining cells, draw, game time, next ok start (in/out), pick out
*>   Q3-HARVEST-STOP USING game time, next ok start out, time worked out; Q3-HARVEST-CONTINUE USING time worked, yes out                  HarvestFarmland
*>   Q3-BONEMEAL-START USING tick count, last session, has bone meal, has target, yes out; Q3-RESERVOIR USING qualifying cells, draw table (8; draw c is nextInt(c)), pick out
*>   Q3-BONEMEAL-TICK USING game time, next work cycle, near the cell, time worked (in/out), act out; Q3-BONEMEAL-GREW USING grew, game time, next work cycle (in/out); Q3-BONEMEAL-CONTINUE USING time worked, has target, yes out   UseBonemeal
*>   Q3-SENSOR-INIT USING interval, draw, countdown out; Q3-SENSOR-TICK USING countdown (in/out), interval, scan out                                                2.18
*>   Q3-SECONDARY USING farmer, farmland count, action out (1 store the list, 0 erase); Q3-GOLEM-SENSOR USING iron golem listed, set out, expiry out;
*>   Q3-BABIES USING entries, villager table (8), baby table (8), kept index table out (8), kept out; Q3-BED-GATE USING baby, game time, draw (nextInt(20)), last update out, run out
*>   Q3-HURTBY USING has damage source, source is living, held entity dead or elsewhere, hurt_by action out (1 set, 2 erase), hurt_by_entity action out (0 none, 1 set, 2 erase)
*>   Q3-HALF-STACK USING count, max stack size, split out (0 skipped); Q3-TRADE-THROW USING food points, farmer, partner wants food, wheat count, willing set not empty, holds willing item, food throw out, wheat throw out, item throw out
*>   Q3-TRADE-NEAR USING distance squared, near out; Q3-SHOW-START USING alive, baby, distance squared, yes out; Q3-SHOW-LOOK USING held item differs, an offer takes it, look time (in/out), display out (0 clear, 1 show, 2 unchanged)
*>   Q3-SHOW-CYCLE USING entries, index (in/out), timer (in/out); Q3-TRADE-SINK USING trading, alive, in water, hurt recently, distance squared, active out; Q3-RESTOCK-DAY USING last check day, day, changed out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BLOCKMEM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                  BINARY-LONG.
 01 L-HAS-SINCE             BINARY-LONG.
 01 L-SINCE                 BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-GIVE-UP               BINARY-LONG.
 01 L-DIST                  BINARY-LONG.
 01 L-TOO-FAR               BINARY-LONG.
 01 L-CLOSE                 BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-OUTCOME               BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-HAS-SINCE L-SINCE L-NOW L-GIVE-UP L-DIST L-TOO-FAR L-CLOSE L-FOUND L-OUTCOME.
     MOVE 0 TO L-OUTCOME
     EVALUATE TRUE
         WHEN L-SAME = 0
             MOVE 1 TO L-OUTCOME
         WHEN L-HAS-SINCE = 1 AND L-NOW - L-SINCE > L-GIVE-UP
             MOVE 1 TO L-OUTCOME
         WHEN L-DIST > L-TOO-FAR
*>           Up to 1000 attempts for a position within tooFar; when all fail, step 1's release applies.
             IF L-FOUND = 1
                 MOVE 2 TO L-OUTCOME
             ELSE
                 MOVE 1 TO L-OUTCOME
             END-IF
         WHEN L-DIST > L-CLOSE
             MOVE 3 TO L-OUTCOME
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-BLOCKMEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BLOCKMEM-PARAMS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSTANCE              BINARY-LONG.
 01 L-CLOSE                 BINARY-LONG.
 01 L-TOO-FAR               BINARY-LONG.
 01 L-GIVE-UP               BINARY-LONG.
 01 L-SPEED                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-INSTANCE L-CLOSE L-TOO-FAR L-GIVE-UP L-SPEED.
     MOVE 1.0 TO L-SPEED
     EVALUATE L-INSTANCE
         WHEN 1
             MOVE 9 TO L-CLOSE
             MOVE 100 TO L-TOO-FAR
             MOVE 1200 TO L-GIVE-UP
         WHEN 2
             MOVE 1 TO L-CLOSE
             MOVE 150 TO L-TOO-FAR
             MOVE 1200 TO L-GIVE-UP
         WHEN 3
             MOVE 6 TO L-CLOSE
             MOVE 100 TO L-TOO-FAR
             MOVE 200 TO L-GIVE-UP
         WHEN OTHER
             MOVE 2 TO L-CLOSE
             MOVE 150 TO L-TOO-FAR
             MOVE 200 TO L-GIVE-UP
             MOVE 1.5 TO L-SPEED
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-BLOCKMEM-PARAMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HIDDEN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-HEARD                 BINARY-LONG.
 01 L-COUNTER               BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-DONE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-HEARD L-COUNTER L-NEAR L-DONE.
     MOVE 0 TO L-DONE
     IF L-HEARD + 300 <= L-NOW OR L-COUNTER > 300
         MOVE 1 TO L-DONE
         MOVE 0 TO L-COUNTER
     ELSE
         IF L-NEAR = 1
             ADD 1 TO L-COUNTER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-HIDDEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SKY-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                    BINARY-LONG.
 01 L-DY                    BINARY-LONG.
 01 L-DZ                    BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-X L-Y L-Z.
     COMPUTE L-X = L-DX - 10
     COMPUTE L-Y = L-DY - 3
     COMPUTE L-Z = L-DZ - 10
     GOBACK.
 END PROGRAM Q3-SKY-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SKY-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SEES                  BINARY-LONG.
 01 L-RUN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SEES L-RUN.
     MOVE 1 TO L-RUN
     IF L-SEES = 1
         MOVE 0 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM Q3-SKY-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SKY-ACCEPT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SEES                  BINARY-LONG.
 01 L-HEIGHT                BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SEES L-HEIGHT L-Y L-OK.
     MOVE 0 TO L-OK
     IF L-SEES = 1 AND L-HEIGHT <= L-Y
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM Q3-SKY-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-CELL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAXAGE                BINARY-LONG.
 01 L-AIR                   BINARY-LONG.
 01 L-FARMLAND              BINARY-LONG.
 01 L-VALID                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MAXAGE L-AIR L-FARMLAND L-VALID.
     MOVE 0 TO L-VALID
     IF L-MAXAGE = 1 OR (L-AIR = 1 AND L-FARMLAND = 1)
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM Q3-HARVEST-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GRIEFING              BINARY-LONG.
 01 L-FARMER                BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT-OK               BINARY-LONG.
 01 L-CELLS                 BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GRIEFING L-FARMER L-NOW L-NEXT-OK L-CELLS L-DRAW L-PICK.
     MOVE 0 TO L-PICK
     IF L-GRIEFING = 1 AND L-FARMER = 1 AND L-CELLS > 0 AND L-NOW > L-NEXT-OK
         COMPUTE L-PICK = L-DRAW + 1
     END-IF
     GOBACK.
 END PROGRAM Q3-HARVEST-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-CELL              BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT-OK               BINARY-LONG.
 01 L-WORKED                BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-CELL L-NEAR L-NOW L-NEXT-OK L-WORKED L-ACT.
     MOVE 0 TO L-ACT
*>   A cell set and the villager not within 1.0 block of it: nothing happens, the counter does not advance either.
     IF L-HAS-CELL = 1 AND L-NEAR = 0
         GOBACK
     END-IF
     IF L-NOW > L-NEXT-OK
         MOVE 1 TO L-ACT
     END-IF
     ADD 1 TO L-WORKED
     GOBACK.
 END PROGRAM Q3-HARVEST-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-RECHOOSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMAINING             BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT-OK               BINARY-LONG.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REMAINING L-DRAW L-NOW L-NEXT-OK L-PICK.
     MOVE 0 TO L-PICK
     IF L-REMAINING > 0
         COMPUTE L-PICK = L-DRAW + 1
         COMPUTE L-NEXT-OK = L-NOW + 20
     END-IF
     GOBACK.
 END PROGRAM Q3-HARVEST-RECHOOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT-OK               BINARY-LONG.
 01 L-WORKED                BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-NEXT-OK L-WORKED.
     COMPUTE L-NEXT-OK = L-NOW + 40
     MOVE 0 TO L-WORKED
     GOBACK.
 END PROGRAM Q3-HARVEST-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HARVEST-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WORKED                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WORKED L-YES.
     MOVE 0 TO L-YES
     IF L-WORKED < 200
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-HARVEST-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BONEMEAL-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                  BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-MEAL                  BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-LAST L-MEAL L-TARGET L-YES.
     MOVE 0 TO L-YES
     IF FUNCTION MOD(L-TICK, 10) = 0 AND (L-LAST = 0 OR L-LAST + 160 <= L-TICK) AND L-MEAL = 1 AND L-TARGET = 1
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-BONEMEAL-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-RESERVOIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                     BINARY-LONG.
 01 L-DRAW-TABLE.
    05 L-DRAW               BINARY-LONG OCCURS 8 TIMES.
 01 L-PICK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-DRAW-TABLE L-PICK.
*>   The c-th qualifying cell replaces the choice when nextInt(c) is 0 (one draw per qualifying cell; the first always).
     MOVE 0 TO L-PICK
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > L-N
         IF L-DRAW(WS-C) = 0
             MOVE WS-C TO L-PICK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-RESERVOIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BONEMEAL-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-WORKED                BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-NEXT L-NEAR L-WORKED L-ACT.
     MOVE 0 TO L-ACT
     IF L-NOW >= L-NEXT AND L-NEAR = 1
         MOVE 1 TO L-ACT
         ADD 1 TO L-WORKED
     END-IF
     GOBACK.
 END PROGRAM Q3-BONEMEAL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BONEMEAL-GREW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GREW                  BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GREW L-NOW L-NEXT.
     IF L-GREW = 1
         COMPUTE L-NEXT = L-NOW + 40
     END-IF
     GOBACK.
 END PROGRAM Q3-BONEMEAL-GREW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BONEMEAL-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WORKED                BINARY-LONG.
 01 L-TARGET                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WORKED L-TARGET L-YES.
     MOVE 0 TO L-YES
     IF L-WORKED < 80 AND L-TARGET = 1
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-BONEMEAL-CONTINUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SENSOR-INIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INTERVAL              BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-COUNTDOWN             BINARY-LONG.
 PROCEDURE DIVISION USING L-INTERVAL L-DRAW L-COUNTDOWN.
     MOVE L-DRAW TO L-COUNTDOWN
     GOBACK.
 END PROGRAM Q3-SENSOR-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SENSOR-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTDOWN             BINARY-LONG.
 01 L-INTERVAL              BINARY-LONG.
 01 L-SCAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTDOWN L-INTERVAL L-SCAN.
*>   The countdown is decremented first; at 0 or below it is reset to the interval and the sensor scans.
     MOVE 0 TO L-SCAN
     SUBTRACT 1 FROM L-COUNTDOWN
     IF L-COUNTDOWN <= 0
         MOVE L-INTERVAL TO L-COUNTDOWN
         MOVE 1 TO L-SCAN
     END-IF
     GOBACK.
 END PROGRAM Q3-SENSOR-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SECONDARY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FARMER                BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 01 L-ACTION                BINARY-LONG.
 PROCEDURE DIVISION USING L-FARMER L-COUNT L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-FARMER = 1 AND L-COUNT > 0
         MOVE 1 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM Q3-SECONDARY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-GOLEM-SENSOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GOLEM                 BINARY-LONG.
 01 L-SET                   BINARY-LONG.
 01 L-EXPIRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-GOLEM L-SET L-EXPIRY.
     MOVE 0 TO L-SET
     MOVE 599 TO L-EXPIRY
     IF L-GOLEM = 1
         MOVE 1 TO L-SET
     END-IF
     GOBACK.
 END PROGRAM Q3-GOLEM-SENSOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BABIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                     BINARY-LONG.
 01 L-VILLAGER-TABLE.
    05 L-VILLAGER           BINARY-LONG OCCURS 8 TIMES.
 01 L-BABY-TABLE.
    05 L-BABY               BINARY-LONG OCCURS 8 TIMES.
 01 L-KEPT-TABLE.
    05 L-KEPT-INDEX         BINARY-LONG OCCURS 8 TIMES.
 01 L-KEPT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-VILLAGER-TABLE L-BABY-TABLE L-KEPT-TABLE L-KEPT.
     MOVE 0 TO L-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         IF L-VILLAGER(WS-I) = 1 AND L-BABY(WS-I) = 1
             ADD 1 TO L-KEPT
             MOVE WS-I TO L-KEPT-INDEX(L-KEPT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-BABIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-BED-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                  BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-LAST                  BINARY-LONG.
 01 L-RUN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-NOW L-DRAW L-LAST L-RUN.
     MOVE 0 TO L-RUN
     IF L-BABY = 1
         MOVE 1 TO L-RUN
         COMPUTE L-LAST = L-NOW + L-DRAW
     END-IF
     GOBACK.
 END PROGRAM Q3-BED-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HURTBY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-DAMAGE            BINARY-LONG.
 01 L-LIVING                BINARY-LONG.
 01 L-ENT-BAD               BINARY-LONG.
 01 L-HURT-ACTION           BINARY-LONG.
 01 L-ENT-ACTION            BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-DAMAGE L-LIVING L-ENT-BAD L-HURT-ACTION L-ENT-ACTION.
     MOVE 0 TO L-ENT-ACTION
     IF L-HAS-DAMAGE = 1
         MOVE 1 TO L-HURT-ACTION
         IF L-LIVING = 1
             MOVE 1 TO L-ENT-ACTION
         END-IF
     ELSE
         MOVE 2 TO L-HURT-ACTION
     END-IF
     IF L-ENT-BAD = 1
         MOVE 2 TO L-ENT-ACTION
     END-IF
     GOBACK.
 END PROGRAM Q3-HURTBY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-HALF-STACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                 BINARY-LONG.
 01 L-MAX                   BINARY-LONG.
 01 L-SPLIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-MAX L-SPLIT.
     MOVE 0 TO L-SPLIT
     EVALUATE TRUE
         WHEN L-COUNT > FUNCTION INTEGER(L-MAX / 2)
             COMPUTE L-SPLIT = FUNCTION INTEGER(L-COUNT / 2)
         WHEN L-COUNT > 24
             COMPUTE L-SPLIT = L-COUNT - 24
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-HALF-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TRADE-THROW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FOOD                  BINARY-LONG.
 01 L-FARMER                BINARY-LONG.
 01 L-PARTNER               BINARY-LONG.
 01 L-WHEAT                 BINARY-LONG.
 01 L-WILLING               BINARY-LONG.
 01 L-HAS-ITEM              BINARY-LONG.
 01 L-A                     BINARY-LONG.
 01 L-B                     BINARY-LONG.
 01 L-C                     BINARY-LONG.
 PROCEDURE DIVISION USING L-FOOD L-FARMER L-PARTNER L-WHEAT L-WILLING L-HAS-ITEM L-A L-B L-C.
*>   The three throws do not exclude each other: excess food, wheat above half a stack, then the willing-to-trade items.
     MOVE 0 TO L-A L-B L-C
     IF L-FOOD >= 24 AND (L-FARMER = 1 OR L-PARTNER = 1)
         MOVE 1 TO L-A
     END-IF
     IF L-FARMER = 1 AND L-WHEAT > 32
         MOVE 1 TO L-B
     END-IF
     IF L-WILLING = 1 AND L-HAS-ITEM = 1
         MOVE 1 TO L-C
     END-IF
     GOBACK.
 END PROGRAM Q3-TRADE-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TRADE-NEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 5.0.
 LINKAGE SECTION.
 01 L-D2                    FLOAT-LONG.
 01 L-NEAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-NEAR.
     MOVE 0 TO L-NEAR
     IF L-D2 <= WS-LIMIT
         MOVE 1 TO L-NEAR
     END-IF
     GOBACK.
 END PROGRAM Q3-TRADE-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SHOW-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 17.0.
 LINKAGE SECTION.
 01 L-ALIVE                 BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-BABY L-D2 L-YES.
     MOVE 0 TO L-YES
     IF L-ALIVE = 1 AND L-BABY = 0 AND L-D2 <= WS-LIMIT
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-SHOW-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SHOW-LOOK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFERS               BINARY-LONG.
 01 L-MATCHES               BINARY-LONG.
 01 L-LOOK                  BINARY-LONG.
 01 L-DISPLAY               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFERS L-MATCHES L-LOOK L-DISPLAY.
     MOVE 2 TO L-DISPLAY
     IF L-DIFFERS = 1
         IF L-MATCHES = 1
             MOVE 1 TO L-DISPLAY
             MOVE 900 TO L-LOOK
         ELSE
             MOVE 0 TO L-DISPLAY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-SHOW-LOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-SHOW-CYCLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                     BINARY-LONG.
 01 L-INDEX                 BINARY-LONG.
 01 L-TIMER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-INDEX L-TIMER.
     IF L-N > 1
         ADD 1 TO L-TIMER
         IF L-TIMER >= 40
             MOVE 0 TO L-TIMER
             COMPUTE L-INDEX = FUNCTION MOD(L-INDEX + 1, L-N)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-SHOW-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-TRADE-SINK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT                FLOAT-LONG VALUE 16.0.
 LINKAGE SECTION.
 01 L-TRADING               BINARY-LONG.
 01 L-ALIVE                 BINARY-LONG.
 01 L-WATER                 BINARY-LONG.
 01 L-HURT                  BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 01 L-ACTIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRADING L-ALIVE L-WATER L-HURT L-D2 L-ACTIVE.
     MOVE 0 TO L-ACTIVE
     IF L-TRADING = 1 AND L-ALIVE = 1 AND L-WATER = 0 AND L-HURT = 0 AND L-D2 <= WS-LIMIT
         MOVE 1 TO L-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM Q3-TRADE-SINK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-RESTOCK-DAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LAST-DAY              BINARY-LONG.
 01 L-DAY                   BINARY-LONG.
 01 L-CHANGED               BINARY-LONG.
 PROCEDURE DIVISION USING L-LAST-DAY L-DAY L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF L-LAST-DAY NOT = L-DAY
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM Q3-RESTOCK-DAY.
