*> /locate structure carried on from game tick to game tick (docs/protocol/16 section 7.7; 36-1 section 11): the search of a rare structure walks up to 40401 cells and took seconds to minutes on the debug
*> build, and the single-player host runs the command inside the game frame, so the game stood still for it. A player's own `locate` line (CMD-RUN-PACKET sets LQ-DIRECT) puts the search in the queue
*> (LOCATEQ.cpy) and CORE-TICK carries every queued search on for a slice of CPU time (LQ-SLICE, 10 ms by default) with CXC-LOCATE-TICK; the reply (the success text or the not_found failure) is
*> sent to the player when the search is over, with the player's own source. The search is the one of CXC-STRUCT-NEAREST made of the same programs (CXC-LOCATE-SETUP, -CONCENTRIC, -SPREAD,
*> CXC-STRUCT-SET-STEP), so the answer is the same. A player who leaves drops their searches. When the queue is full, or the line is nested in execute or a function or comes from the console, the command
*> answers at once as before.
*>
*> Entry points:
*>   CXC-LOCATE-QUEUE USING sender (player row), kind, identifier (PIC X(80)), text (PIC X(112), the identifier as printed), its length, source block x, z, seed (BINARY-DOUBLE), queued out (0 when the queue is full)
*>   CXC-LOCATE-REPLY USING found, x, z, squared distance (BINARY-DOUBLE), text (PIC X(112)), its length: the success feedback or the not_found failure of the command, for the source BR-SRC
*>   CXC-LOCATE-TICK (no parameters, once per CORE-TICK): the queued searches advance within one slice; finished ones reply, those of players that left are dropped

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-LOCATE-QUEUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY LOCATEQ.
 01 WS-E                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-TEXT                 PIC X(112).
 01 L-TEXT-LENGTH          BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-QUEUED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-KIND L-ID L-TEXT L-TEXT-LENGTH L-SX L-SZ L-SEED L-QUEUED.
     MOVE 0 TO L-QUEUED WS-SLOT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > LQ-MAX OR WS-SLOT > 0
         IF LQ-USED(WS-E) = 0
             MOVE WS-E TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
     INITIALIZE LQ-ENTRY(WS-SLOT)
     MOVE 1 TO LQ-USED(WS-SLOT)
     MOVE L-SENDER TO LQ-SENDER(WS-SLOT)
     MOVE PL-ENTITY-ID(L-SENDER) TO LQ-ENTITY(WS-SLOT)
     MOVE L-KIND TO LQ-KIND(WS-SLOT)
     MOVE L-ID TO LQ-ID(WS-SLOT)
     MOVE L-TEXT TO LQ-TEXT(WS-SLOT)
     MOVE L-TEXT-LENGTH TO LQ-TEXT-LENGTH(WS-SLOT)
     MOVE L-SX TO LQ-SX(WS-SLOT)
     MOVE L-SZ TO LQ-SZ(WS-SLOT)
     MOVE L-SEED TO LQ-SEED(WS-SLOT)
     MOVE 1 TO L-QUEUED
     GOBACK.
 END PROGRAM CXC-LOCATE-QUEUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-LOCATE-REPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72).
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-COORD               PIC X(64).
 01 WS-COORD-LENGTH        BINARY-LONG.
 01 WS-PART                PIC X(64).
 01 WS-PART-LENGTH         BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-DISTANCE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D2                   BINARY-DOUBLE.
 01 L-TEXT                 PIC X(112).
 01 L-TEXT-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND L-X L-Z L-D2 L-TEXT L-TEXT-LENGTH.
     IF L-FOUND = 0
         MOVE "commands.locate.structure.not_found" TO WS-KEY
         MOVE 1 TO WS-N-ARGS
         MOVE SPACES TO WS-A1 WS-A2
         MOVE FUNCTION MIN(L-TEXT-LENGTH, 64) TO WS-L1
         MOVE L-TEXT(1:WS-L1) TO WS-A1
         CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
         GOBACK
     END-IF
     COMPUTE WS-DISTANCE = FUNCTION INTEGER(FUNCTION SQRT(L-D2))
     MOVE SPACES TO WS-COORD
     MOVE "[" TO WS-COORD(1:1)
     MOVE 2 TO WS-COORD-LENGTH
     MOVE L-X TO WS-VALUE
     CALL "CXC-INT-TEXT" USING WS-VALUE WS-PART WS-PART-LENGTH
     MOVE WS-PART(1:WS-PART-LENGTH) TO WS-COORD(WS-COORD-LENGTH:WS-PART-LENGTH)
     ADD WS-PART-LENGTH TO WS-COORD-LENGTH
     MOVE ", ~, " TO WS-COORD(WS-COORD-LENGTH:5)
     ADD 5 TO WS-COORD-LENGTH
     MOVE L-Z TO WS-VALUE
     CALL "CXC-INT-TEXT" USING WS-VALUE WS-PART WS-PART-LENGTH
     MOVE WS-PART(1:WS-PART-LENGTH) TO WS-COORD(WS-COORD-LENGTH:WS-PART-LENGTH)
     ADD WS-PART-LENGTH TO WS-COORD-LENGTH
     MOVE "]" TO WS-COORD(WS-COORD-LENGTH:1)
     MOVE "commands.locate.structure.success" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT L-TEXT L-TEXT-LENGTH
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-COORD WS-COORD-LENGTH
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-DISTANCE
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE WS-DISTANCE TO BR-R-RESULT
     GOBACK.
 END PROGRAM CXC-LOCATE-REPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-LOCATE-ADVANCE.
*> The concentric rings (strongholds) search four rows of the biome search of a ring position per call (SD-SNAP-LIMIT, STRUCT-RING-READY-ROWS): the answer of a call that left a snap undone (SD-SNAP-PENDING) is not final, the next call goes on.
*> USING entry (the row of LQ-ENTRY), deadline (BINARY-DOUBLE, a clock() value in microseconds), done out: carries the search of the entry on until it is over (done 1) or the deadline has passed after a
*> unit of work (a phase, or a cell of the ring walk); at least one unit is done per call.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOCATEQ.
 COPY STRUCTDATA.
 01 WS-RADIUS              BINARY-LONG VALUE 100.
 01 WS-PAUSE               BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-F                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-SET-DONE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-E                    BINARY-LONG.
 01 L-DEADLINE             BINARY-DOUBLE.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-E L-DEADLINE L-DONE.
     MOVE 0 TO L-DONE WS-PAUSE
     ADD 1 TO LQ-TICKS(L-E)
     PERFORM UNTIL L-DONE = 1 OR WS-PAUSE = 1
         EVALUATE LQ-PHASE(L-E)
             WHEN 0
                 CALL "CXC-LOCATE-SETUP"
                 MOVE 1 TO LQ-PHASE(L-E)
             WHEN 1
                 MOVE 4 TO SD-SNAP-LIMIT
                 MOVE 0 TO SD-SNAP-PENDING
                 CALL "CXC-LOCATE-CONCENTRIC" USING LQ-KIND(L-E) LQ-ID(L-E) LQ-SX(L-E) LQ-SZ(L-E) LQ-SEED(L-E) LQ-FOUND(L-E) LQ-X(L-E) LQ-Z(L-E) LQ-D2(L-E)
                 MOVE 0 TO SD-SNAP-LIMIT
                 IF SD-SNAP-PENDING = 0
                     MOVE 2 TO LQ-PHASE(L-E)
                 END-IF
             WHEN 2
                 CALL "CXC-LOCATE-SPREAD" USING LQ-KIND(L-E) LQ-ID(L-E) LQ-SPREAD(L-E) LQ-SPREAD-COUNT(L-E)
                 MOVE 3 TO LQ-PHASE(L-E)
                 MOVE 0 TO LQ-RING(L-E) LQ-CI(L-E) LQ-CJ(L-E) LQ-ANSWERED(L-E)
                 MOVE 1 TO LQ-SI(L-E)
             WHEN OTHER
                 EVALUATE TRUE
                     WHEN LQ-RING(L-E) > WS-RADIUS
                         MOVE 1 TO L-DONE
                     WHEN LQ-SI(L-E) > LQ-SPREAD-COUNT(L-E)
*>                       every set has had the ring: the first ring in which any set answered ends the search
                         IF LQ-ANSWERED(L-E) = 1
                             MOVE 1 TO L-DONE
                         ELSE
                             ADD 1 TO LQ-RING(L-E)
                             MOVE 1 TO LQ-SI(L-E)
                             COMPUTE LQ-CI(L-E) = 0 - LQ-RING(L-E)
                             MOVE LQ-CI(L-E) TO LQ-CJ(L-E)
                         END-IF
                     WHEN OTHER
                         CALL "CXC-STRUCT-SET-STEP" USING LQ-SPREAD-SET(L-E, LQ-SI(L-E)) LQ-KIND(L-E) LQ-ID(L-E) LQ-SEED(L-E) LQ-SX(L-E) LQ-SZ(L-E)
                             LQ-RING(L-E) LQ-CI(L-E) LQ-CJ(L-E) L-DEADLINE WS-F WS-X WS-Z WS-D2 WS-SET-DONE
                         IF WS-SET-DONE = 1
                             IF WS-F = 1
                                 MOVE 1 TO LQ-ANSWERED(L-E)
                                 IF LQ-FOUND(L-E) = 0 OR WS-D2 < LQ-D2(L-E)
                                     MOVE 1 TO LQ-FOUND(L-E)
                                     MOVE WS-X TO LQ-X(L-E)
                                     MOVE WS-Z TO LQ-Z(L-E)
                                     MOVE WS-D2 TO LQ-D2(L-E)
                                 END-IF
                             END-IF
                             ADD 1 TO LQ-SI(L-E)
                             COMPUTE LQ-CI(L-E) = 0 - LQ-RING(L-E)
                             MOVE LQ-CI(L-E) TO LQ-CJ(L-E)
                         ELSE
                             MOVE 1 TO WS-PAUSE
                         END-IF
                 END-EVALUATE
         END-EVALUATE
         IF L-DONE = 0 AND WS-PAUSE = 0
             CALL STATIC "clock" RETURNING WS-NOW
             IF WS-NOW >= L-DEADLINE
                 MOVE 1 TO WS-PAUSE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXC-LOCATE-ADVANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-LOCATE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY LOCATEQ.
 01 WS-E                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SLICE               BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-DEADLINE            BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE 10000 TO WS-SLICE
     IF LQ-SLICE > 0
         MOVE LQ-SLICE TO WS-SLICE
     END-IF
     CALL STATIC "clock" RETURNING WS-NOW
     COMPUTE WS-DEADLINE = WS-NOW + WS-SLICE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > LQ-MAX
         IF LQ-USED(WS-E) = 1
             MOVE LQ-SENDER(WS-E) TO WS-ROW
             IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ID(WS-ROW) = LQ-ENTITY(WS-E)
                 CALL "CXC-LOCATE-ADVANCE" USING WS-E WS-DEADLINE WS-DONE
                 IF WS-DONE = 1
                     MOVE 0 TO LQ-USED(WS-E)
                     CALL "BR-SOURCE-OF" USING WS-ROW
                     MOVE 0 TO BR-R-FAILED
                     CALL "CXC-LOCATE-REPLY" USING LQ-FOUND(WS-E) LQ-X(WS-E) LQ-Z(WS-E) LQ-D2(WS-E) LQ-TEXT(WS-E) LQ-TEXT-LENGTH(WS-E)
                     IF BR-R-FAILED = 1
                         CALL "BR-FAIL-EXCEPTION"
                     END-IF
                 END-IF
             ELSE
                 MOVE 0 TO LQ-USED(WS-E)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXC-LOCATE-TICK.
