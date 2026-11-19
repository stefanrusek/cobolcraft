*> Villager brain: POI behaviours (docs/protocol/44-residual-mob-questions-3-villagers-poi-raids.md section 2.1 to 2.6; lane 002-lane-p49h, T22002). Pure decision units: the callers
*> keep the state (timers, caches, memories) and pass what the rule reads. A flag is 1 (true) or 0.
*>   Q3-ACQ-GATE USING baby, only adult, game time, next scan (in/out), draw (nextInt(20)), mode out      AcquirePoi steps 1 and 2 (mode 0 nothing, 1 first evaluation, 2 not yet, 3 scan)
*>   Q3-ACQ-RETRY USING game time, previous attempt (in/out), current delay (in/out), draw (nextInt(40)), next allowed out      JitteredLinearRetry.markAttempt (the constructor calls it too)
*>   Q3-ACQ-SHOULD-RETRY USING game time, next allowed, yes out
*>   Q3-ACQ-STILL-VALID USING game time, previous attempt, yes out                                  a cache entry is dropped when 400 ticks old
*>   Q3-ACQ-FILTER USING has entry, should retry, pass out, mark out                                the position filter of step 4
*>   Q3-ACQ-START USING one memory (1 when both roles use the same memory), first present, second present, yes out          the factory's start conditions
*>   Q3-ACQ-LIMIT USING count, valid table (12 flags), kept out                                    the limit of 5 before the validity predicate
*>   Q3-ACQ-OUTCOME USING has path, can reach, outcome out (1 claim the target, 2 every candidate gets a retry object)
*>   Q3-VALIDATE-POI USING same dimension, within 16, has record, home case, bed occupied, sleeping, other villager in bed, action out (0 nothing, 1 erase, 2 erase and release)   2.2
*>   Q3-COMPETE USING count, xp table (8; entry 1 is this villager), loser table out (8), winner out                          PoiCompetitorScan.selectWinner
*>   Q3-YIELD-WANTS USING has potential, accepts type, has job, can reach, same job position, yes out        nearbyWantsJobsite
*>   Q3-YIELD-START USING baby, profession none, type found, yes out
*>   Q3-POT-START USING activity (0 idle, 1 work, 2 meet, 3 rest, 4 play), yes out                  GoToPotentialJobSite start (idle, work and play)
*>   Q3-POT-STOP USING record acceptable, release out                                            the ticket is released when a record of an acquirable type remains

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                  BINARY-LONG.
 01 L-ADULT                 BINARY-LONG.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-MODE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-ADULT L-NOW L-NEXT L-DRAW L-MODE.
     EVALUATE TRUE
         WHEN L-ADULT = 1 AND L-BABY = 1
             MOVE 0 TO L-MODE
         WHEN L-NEXT = 0
             COMPUTE L-NEXT = L-NOW + L-DRAW
             MOVE 1 TO L-MODE
         WHEN L-NOW < L-NEXT
             MOVE 2 TO L-MODE
         WHEN OTHER
             COMPUTE L-NEXT = L-NOW + 20 + L-DRAW
             MOVE 3 TO L-MODE
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-ACQ-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-RETRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-PREVIOUS              BINARY-LONG.
 01 L-DELAY                 BINARY-LONG.
 01 L-DRAW                  BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-PREVIOUS L-DELAY L-DRAW L-NEXT.
     MOVE L-NOW TO L-PREVIOUS
     COMPUTE L-DELAY = FUNCTION MIN(L-DELAY + L-DRAW + 40, 400)
     COMPUTE L-NEXT = L-NOW + L-DELAY
     GOBACK.
 END PROGRAM Q3-ACQ-RETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-SHOULD-RETRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-NEXT                  BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-NEXT L-YES.
     MOVE 0 TO L-YES
     IF L-NOW >= L-NEXT
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-ACQ-SHOULD-RETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-STILL-VALID.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                   BINARY-LONG.
 01 L-PREVIOUS              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-PREVIOUS L-YES.
     MOVE 0 TO L-YES
     IF L-NOW - L-PREVIOUS < 400
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-ACQ-STILL-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-FILTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTRY                 BINARY-LONG.
 01 L-RETRY                 BINARY-LONG.
 01 L-PASS                  BINARY-LONG.
 01 L-MARK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY L-RETRY L-PASS L-MARK.
*>   A position with no cache entry passes with no call at all; one with an entry passes when shouldRetry holds, and then the attempt is marked.
     MOVE 1 TO L-PASS
     MOVE 0 TO L-MARK
     IF L-ENTRY = 1
         IF L-RETRY = 1
             MOVE 1 TO L-MARK
         ELSE
             MOVE 0 TO L-PASS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-ACQ-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                  BINARY-LONG.
 01 L-FIRST                 BINARY-LONG.
 01 L-SECOND                BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-FIRST L-SECOND L-YES.
*>   The second memory must be absent; a different first memory must be absent too (it is never written).
     MOVE 1 TO L-YES
     IF L-SECOND = 1
         MOVE 0 TO L-YES
     END-IF
     IF L-SAME = 0 AND L-FIRST = 1
         MOVE 0 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-ACQ-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-LIMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                 BINARY-LONG.
 01 L-VALID.
    05 L-FLAG               BINARY-LONG OCCURS 12 TIMES.
 01 L-KEPT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-VALID L-KEPT.
*>   The candidates passed the position filter already (closest first); the stream is limited to 5, then the validity predicate runs on those.
     MOVE 0 TO L-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FUNCTION MIN(L-COUNT, 5)
         IF L-FLAG(WS-I) = 1
             ADD 1 TO L-KEPT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-ACQ-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-ACQ-OUTCOME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                  BINARY-LONG.
 01 L-REACH                 BINARY-LONG.
 01 L-OUTCOME               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-REACH L-OUTCOME.
     MOVE 2 TO L-OUTCOME
     IF L-PATH = 1 AND L-REACH = 1
         MOVE 1 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM Q3-ACQ-OUTCOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-VALIDATE-POI.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME-DIM              BINARY-LONG.
 01 L-NEAR                  BINARY-LONG.
 01 L-RECORD                BINARY-LONG.
 01 L-HOME                  BINARY-LONG.
 01 L-OCCUPIED              BINARY-LONG.
 01 L-SLEEPING              BINARY-LONG.
 01 L-OTHER                 BINARY-LONG.
 01 L-ACTION                BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME-DIM L-NEAR L-RECORD L-HOME L-OCCUPIED L-SLEEPING L-OTHER L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE TRUE
         WHEN L-SAME-DIM = 0 OR L-NEAR = 0
             CONTINUE
         WHEN L-RECORD = 0
             MOVE 1 TO L-ACTION
         WHEN L-HOME = 1 AND L-OCCUPIED = 1 AND L-SLEEPING = 0
*>           A player or another non-villager sleeps in the bed: the claim is handed back unless a villager lies in it.
             MOVE 2 TO L-ACTION
             IF L-OTHER = 1
                 MOVE 1 TO L-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q3-VALIDATE-POI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-COMPETE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                 BINARY-LONG.
 01 L-XP-TABLE.
    05 L-XP                 BINARY-LONG OCCURS 8 TIMES.
 01 L-LOSER-TABLE.
    05 L-LOSER              BINARY-LONG OCCURS 8 TIMES.
 01 L-WINNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-XP-TABLE L-LOSER-TABLE L-WINNER.
*>   The fold starts with this villager (entry 1) and meets the competitors in list order: the accumulated one stays only with strictly more xp, so on a tie the later one wins.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 0 TO L-LOSER(WS-I)
     END-PERFORM
     MOVE 1 TO L-WINNER
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COUNT
         IF L-XP(L-WINNER) > L-XP(WS-I)
             MOVE 1 TO L-LOSER(WS-I)
         ELSE
             MOVE 1 TO L-LOSER(L-WINNER)
             MOVE WS-I TO L-WINNER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q3-COMPETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-YIELD-WANTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POTENTIAL             BINARY-LONG.
 01 L-ACCEPTS               BINARY-LONG.
 01 L-JOB                   BINARY-LONG.
 01 L-REACH                 BINARY-LONG.
 01 L-SAME                  BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POTENTIAL L-ACCEPTS L-JOB L-REACH L-SAME L-YES.
*>   nearbyWantsJobsite: (a) no potential_job_site, (b) the profession accepts the type, (c) no job_site and a path, or the same job_site position.
     MOVE 0 TO L-YES
     IF L-POTENTIAL = 0 AND L-ACCEPTS = 1
         IF (L-JOB = 0 AND L-REACH = 1) OR L-SAME = 1
             MOVE 1 TO L-YES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q3-YIELD-WANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-YIELD-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                  BINARY-LONG.
 01 L-NONE                  BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-NONE L-FOUND L-YES.
     MOVE 0 TO L-YES
     IF L-BABY = 0 AND L-NONE = 1 AND L-FOUND = 1
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-YIELD-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-POT-START.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVITY              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVITY L-YES.
     MOVE 0 TO L-YES
     IF L-ACTIVITY = 0 OR 1 OR 4
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM Q3-POT-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q3-POT-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACCEPTABLE            BINARY-LONG.
 01 L-RELEASE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACCEPTABLE L-RELEASE.
     MOVE L-ACCEPTABLE TO L-RELEASE
     GOBACK.
 END PROGRAM Q3-POT-STOP.
