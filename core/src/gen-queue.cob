*> The chunk generation queue (research R12; GENQUEUE.cpy): chunks that a player's view wants and
*> that are not loaded yet wait here, and CORE-TICK generates at most GQ-BUDGET of them per tick,
*> nearest to an alive player of the chunk's dimension first, so a slow generation never blocks the
*> 50 ms tick. It changes when a chunk exists, not what it holds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-RESET.
*> No parameters: empties the queue (WORLD-RESET, when a world is opened over another).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 PROCEDURE DIVISION.
     MOVE 0 TO GQ-COUNT
     MOVE 0 TO GQ-GENERATED
     MOVE 0 TO GQ-SETUP-DONE
     MOVE 0 TO GQ-STEPS
     MOVE 0 TO GQ-SP-STATE GQ-SP-CHUNK GQ-SP-COLUMN GQ-SP-DONE GQ-SP-TOTAL
     CALL "GEN-WORKERS-STOP"
     IF GJ-ACTIVE NOT = 0 AND GJ-ADDR NOT = NULL
         CALL "GEN-JOB-FREE" USING GQ-JOB
     END-IF
     MOVE 0 TO GJ-ACTIVE
     GOBACK.
 END PROGRAM GEN-QUEUE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-WANT.
*> USING dim (DIMENSIONS.cpy row), chunk x, chunk z (BINARY-LONG): queues the chunk unless it is loaded,
*> already queued, or the queue is full (it is wanted again the next time a view asks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
         IF GQ-DIM(WS-I) = L-DIM AND GQ-X(WS-I) = L-CX AND GQ-Z(WS-I) = L-CZ
             GOBACK
         END-IF
     END-PERFORM
     IF GJ-ACTIVE NOT = 0 AND GJ-DIM = L-DIM AND GJ-CX = L-CX AND GJ-CZ = L-CZ
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GW-MAX
         IF GW-BUSY(WS-I) NOT = 0 AND GW-DIM(WS-I) = L-DIM AND GW-CX(WS-I) = L-CX AND GW-CZ(WS-I) = L-CZ
             GOBACK
         END-IF
     END-PERFORM
     IF GQ-COUNT >= GQ-CAPACITY
         GOBACK
     END-IF
     ADD 1 TO GQ-COUNT
     MOVE L-DIM TO GQ-DIM(GQ-COUNT)
     MOVE L-CX TO GQ-X(GQ-COUNT)
     MOVE L-CZ TO GQ-Z(GQ-COUNT)
     GOBACK.
 END PROGRAM GEN-QUEUE-WANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-PICK-MODE.
*> USING mode (BINARY-LONG), index out (BINARY-LONG): mode 0 considers every entry, mode 1 only the chunks of the standard pipeline (the generation
*> workers' share), mode 2 only the others (the in-tick path while the workers serve the standard ones). The queue entry nearest to a player (squared distance in chunks to the nearest alive player
*> of its dimension; with no such player every chunk is equally far and the oldest goes first); 0 for an empty queue.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 COPY DIMENSIONS.
 01 WS-STANDARD            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST-D              BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-BEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-BEST.
     MOVE 0 TO L-BEST
     IF GQ-COUNT = 0
         GOBACK
     END-IF
     MOVE 999999999999 TO WS-BEST-D
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
         MOVE 0 TO WS-STANDARD
         IF DM-GENERATOR(GQ-DIM(WS-I)) = DIM-GEN-STANDARD
             MOVE 1 TO WS-STANDARD
         END-IF
         MOVE 999999999999 TO WS-D
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = GQ-DIM(WS-I)
                 COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-P) / 16)
                 COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-P) / 16)
                 COMPUTE WS-DX = GQ-X(WS-I) - WS-PX
                 COMPUTE WS-DZ = GQ-Z(WS-I) - WS-PZ
                 IF WS-DX * WS-DX + WS-DZ * WS-DZ < WS-D
                     COMPUTE WS-D = WS-DX * WS-DX + WS-DZ * WS-DZ
                 END-IF
             END-IF
         END-PERFORM
         IF (L-MODE = 0 OR (L-MODE = 1 AND WS-STANDARD = 1) OR (L-MODE = 2 AND WS-STANDARD = 0))
                 AND (L-BEST = 0 OR WS-D < WS-BEST-D)
             MOVE WS-D TO WS-BEST-D
             MOVE WS-I TO L-BEST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-QUEUE-PICK-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-PICK.
*> USING index out (BINARY-LONG): the queue entry nearest to a player (GEN-QUEUE-PICK-MODE, mode 0); 0 for an empty queue.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-BEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BEST.
     CALL "GEN-QUEUE-PICK-MODE" USING WS-MODE L-BEST
     GOBACK.
 END PROGRAM GEN-QUEUE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-RUN.
*> USING budget (BINARY-LONG), generated out (BINARY-LONG): generates up to budget queued chunks whole, each time the one
*> nearest to a player (GEN-QUEUE-PICK), and returns how many it generated. The chunk of the standard pipeline is generated by
*> all its steps in one go here (the atomic reference); the tick uses GEN-QUEUE-STEPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-BEST                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BUDGET               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BUDGET L-DONE.
     MOVE 0 TO L-DONE
     PERFORM UNTIL L-DONE >= L-BUDGET OR GQ-COUNT = 0
         CALL "GEN-QUEUE-PICK" USING WS-BEST
         MOVE GQ-DIM(WS-BEST) TO WS-DIM
         MOVE GQ-X(WS-BEST) TO WS-CX
         MOVE GQ-Z(WS-BEST) TO WS-CZ
         MOVE GQ-ENTRY(GQ-COUNT) TO GQ-ENTRY(WS-BEST)
         SUBTRACT 1 FROM GQ-COUNT
         CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
         ADD 1 TO L-DONE
         ADD 1 TO GQ-GENERATED
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-QUEUE-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-SLICED.
*> USING dimension row, flag out (BINARY-LONG): 1 when the dimension's chunks are generated by steps: its generator is the
*> standard one, the world is not of the debug type and the overworld terrain data are loaded (GEN-DATA-READY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-FLAG.
     MOVE 0 TO L-FLAG
     IF DM-GENERATOR(L-DIM) = DIM-GEN-STANDARD
         CALL "WORLD-IS-DEBUG" USING WS-DEBUG
         CALL "GEN-DATA-READY" USING WS-READY
         IF WS-DEBUG = 0 AND WS-READY = 1
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GEN-QUEUE-SLICED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-STEPS.
*> USING step budget, chunk budget, wall limit in hundredths of a second (0 = none), steps run out, chunks completed out
*> (all BINARY-LONG): the share of the queue in one tick. Nearest first, one chunk at a time: the chunk of the standard
*> pipeline is a job run by GEN-JOB-STEP, at most the step budget of steps and (when a limit is given) stopping between two
*> steps once the clock has run that long; it is installed in the chunk cache when its last step is done. A chunk of any other
*> generator is generated whole and counts against the chunk budget. It returns when the nearest chunk cannot be served
*> within what is left of the budgets.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-BEST                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLICED              BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-START               BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-PICK-MODE           BINARY-LONG.
 LINKAGE SECTION.
 01 L-STEPS                BINARY-LONG.
 01 L-CHUNKS               BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-STEPS-RUN            BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STEPS L-CHUNKS L-LIMIT L-STEPS-RUN L-DONE.
     MOVE 0 TO L-STEPS-RUN L-DONE WS-STOP
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-START = (FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60 + FUNCTION NUMVAL(WS-CLOCK(13:2))) * 100
         + FUNCTION NUMVAL(WS-CLOCK(15:2))
     PERFORM UNTIL WS-STOP = 1
         IF GJ-ACTIVE NOT = 0
             CALL "WORLD-FIND" USING GJ-DIM GJ-CX GJ-CZ WS-ROW
             IF WS-ROW > 0
*>               the chunk was loaded some other way meanwhile: the job is dropped, nothing is generated twice
                 CALL "GEN-JOB-FREE" USING GQ-JOB
             END-IF
         END-IF
         EVALUATE TRUE
             WHEN GJ-ACTIVE = 2
*>               complete: the generator dispatch installs the finished chunk (worldgen-standard.cob)
                 CALL "WORLD-CHUNK-LOAD" USING GJ-DIM GJ-CX GJ-CZ WS-ROW
                 ADD 1 TO L-DONE
                 ADD 1 TO GQ-GENERATED
             WHEN GJ-ACTIVE = 1
                 IF L-STEPS-RUN >= L-STEPS
                     MOVE 1 TO WS-STOP
                 ELSE
                     IF L-LIMIT > 0 AND L-STEPS-RUN > 0
                         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
                         COMPUTE WS-NOW = (FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60 + FUNCTION NUMVAL(WS-CLOCK(13:2))) * 100
                             + FUNCTION NUMVAL(WS-CLOCK(15:2))
                         IF FUNCTION MOD(WS-NOW - WS-START + 360000, 360000) >= L-LIMIT
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                     IF WS-STOP = 0
                         CALL "GEN-JOB-STEP" USING GQ-JOB
                         ADD 1 TO L-STEPS-RUN
                         ADD 1 TO GQ-STEPS
                     END-IF
                 END-IF
             WHEN OTHER
*>               while the workers serve the standard chunks only the other generators' chunks are the tick's
                 MOVE 0 TO WS-PICK-MODE
                 IF GQ-WORKERS > 0 AND GW-ACTIVE = 1
                     MOVE 2 TO WS-PICK-MODE
                 END-IF
                 CALL "GEN-QUEUE-PICK-MODE" USING WS-PICK-MODE WS-BEST
                 IF WS-BEST = 0
                     MOVE 1 TO WS-STOP
                 ELSE
                     MOVE GQ-DIM(WS-BEST) TO WS-DIM
                     MOVE GQ-X(WS-BEST) TO WS-CX
                     MOVE GQ-Z(WS-BEST) TO WS-CZ
                     CALL "GEN-QUEUE-SLICED" USING WS-DIM WS-SLICED
                     IF WS-SLICED = 1 AND L-STEPS-RUN >= L-STEPS
                         MOVE 1 TO WS-STOP
                     END-IF
                     IF WS-SLICED = 0 AND L-DONE >= L-CHUNKS
                         MOVE 1 TO WS-STOP
                     END-IF
                     IF WS-STOP = 0
                         MOVE GQ-ENTRY(GQ-COUNT) TO GQ-ENTRY(WS-BEST)
                         SUBTRACT 1 FROM GQ-COUNT
                         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
                         IF WS-ROW = 0
                             IF WS-SLICED = 1
                                 CALL "GEN-JOB-START" USING GQ-JOB WS-DIM WS-CX WS-CZ
                             ELSE
                                 CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
                                 ADD 1 TO L-DONE
                                 ADD 1 TO GQ-GENERATED
                             END-IF
                         END-IF
                     END-IF
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-QUEUE-STEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STANDARD-INSTALL.
*> USING dimension row, chunk x, chunk z, chunk memory, marker-y out: the chunk of the standard pipeline: a generation worker's finished
*> answer when it is this chunk's (GEN-STANDARD-TAKE), else the queue's finished job when it is this chunk's (installed and freed), else
*> every step run back to back (GEN-JOB-RUN-ALL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-TAKEN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     CALL "GEN-STANDARD-TAKE" USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y WS-TAKEN
     EVALUATE TRUE
         WHEN WS-TAKEN = 1
             CONTINUE
         WHEN GJ-ACTIVE = 2 AND GJ-DIM = L-DIM AND GJ-CX = L-CX AND GJ-CZ = L-CZ
             CALL "GEN-JOB-INSTALL" USING GQ-JOB L-CHUNK L-MARKER-Y
             CALL "GEN-JOB-FREE" USING GQ-JOB
         WHEN OTHER
             CALL "GEN-JOB-RUN-ALL" USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y
     END-EVALUATE
     GOBACK.
 END PROGRAM GEN-STANDARD-INSTALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-TICK.
*> No parameters: the queue's share of one game tick (CORE-TICK): up to GQ-BUDGET chunks of a cheap generator and up to
*> GQ-STEP-BUDGET steps (within GQ-MS-HUNDREDTHS of wall time) of the chunk of the standard pipeline.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-STEPS               BINARY-LONG VALUE GQ-STEP-BUDGET.
 01 WS-CHUNKS              BINARY-LONG VALUE GQ-BUDGET.
 01 WS-LIMIT               BINARY-LONG VALUE GQ-MS-HUNDREDTHS.
 01 WS-RUN                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 PROCEDURE DIVISION.
     IF GQ-WORKERS > 0
         CALL "GEN-WORKERS-TICK"
     END-IF
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     GOBACK.
 END PROGRAM GEN-QUEUE-TICK.
