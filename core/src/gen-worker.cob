*> The generation workers (docs/design/generation-worker.md): chunks of the standard pipeline are made by forked worker processes, so the
*> game loop never waits for the 4 to 5 seconds one takes. The shim (cc_wk) forks and carries the bytes; nothing here shares memory with a
*> worker: a request is three BINARY-LONG (dimension row, chunk x, chunk z), the answer is marker-y and the chunk memory (GW-ANSWER-BYTES).
*> A chunk is a pure function of the seed, the settings, the content and the request, so which worker makes it and when it arrives changes
*> only when the chunk appears.
*>
*> Entry points:
*>   GEN-WORKERS-CONFIG USING size (BINARY-LONG): the pool size (0 to GW-MAX, other values are bounded); stops the running workers first.
*>   GEN-WORKERS-STOP: kills and reaps every worker (GEN-QUEUE-RESET, CORE-STOP).
*>   GEN-WORKERS-TICK: the pool's share of one tick (GEN-QUEUE-TICK): finished answers are installed, idle workers get the nearest chunks.
*>   GEN-STANDARD-TAKE USING dimension row, chunk x, chunk z, chunk memory, marker-y out, flag out: copies the finished answer GQ-READY into the chunk.
*>   GEN-WORKER-START, GEN-WORKER-SERVE, GEN-WORKER-HANDLE, GEN-WORKER-EXIT: the worker side.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-EXIT.
*> USING flag (BINARY-LONG): a worker ends here (cc_wk_child_exit) when the flag is not 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     IF L-FLAG NOT = 0
         CALL STATIC "cc_wk_child_exit"
     END-IF
     GOBACK.
 END PROGRAM GEN-WORKER-EXIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-HANDLE.
*> USING outcome out (BINARY-LONG): the worker side of one request: reads it, makes the chunk by the atomic reference (GEN-JOB-RUN-ALL) and
*> writes the answer; 1 when answered, 0 at end of input or when the answer cannot be written.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 78 WS-REQUEST-BYTES       VALUE 12.
 01 WS-REQUEST.
    05 WS-DIM              BINARY-LONG.
    05 WS-CX               BINARY-LONG.
    05 WS-CZ               BINARY-LONG.
 01 WS-ANSWER.
    05 WS-MARKER           BINARY-LONG.
    05 WS-CHUNK            PIC X(304640).
 01 WS-LENGTH              BINARY-LONG VALUE 304644.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-OUTCOME.
     MOVE 0 TO L-OUTCOME
     CALL STATIC "cc_wk_child_read" USING BY REFERENCE WS-REQUEST BY VALUE WS-REQUEST-BYTES RETURNING WS-RC
     IF WS-RC NOT = WS-REQUEST-BYTES
         GOBACK
     END-IF
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     CALL STATIC "cc_wk_child_write" USING BY REFERENCE WS-ANSWER BY VALUE WS-LENGTH RETURNING WS-RC
     IF WS-RC = WS-LENGTH
         MOVE 1 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM GEN-WORKER-HANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-SERVE.
*> No parameters: the worker's loop, one request after another until the parent's end of input.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME = 0
         CALL "GEN-WORKER-HANDLE" USING WS-OUTCOME
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-WORKER-SERVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-START.
*> USING slot out (BINARY-LONG): forks a worker; the slot of the shim, or -1 when none can be started. The child never returns from here:
*> it serves requests and ends.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     CALL STATIC "cc_wk_spawn" RETURNING L-SLOT
     IF L-SLOT = 0
         CALL "GEN-WORKER-SERVE"
         CALL "GEN-WORKER-EXIT" USING WS-ONE
     END-IF
     GOBACK.
 END PROGRAM GEN-WORKER-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-DROP.
*> USING worker index (BINARY-LONG): the worker is gone or not answering: its process is reaped, its buffer freed, the slot is free for a new
*> worker, and the chunk it had goes back to the queue.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-FORCE               BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I.
     CALL STATIC "cc_wk_stop" USING BY VALUE GW-SLOT(L-I) BY VALUE WS-FORCE RETURNING WS-RC
     MOVE 0 TO GW-SLOT(L-I)
     IF GW-ADDR(L-I) NOT = NULL
         FREE GW-ADDR(L-I)
         SET GW-ADDR(L-I) TO NULL
     END-IF
     IF GW-BUSY(L-I) NOT = 0
         MOVE 0 TO GW-BUSY(L-I)
         CALL "GEN-QUEUE-WANT" USING GW-DIM(L-I) GW-CX(L-I) GW-CZ(L-I)
     END-IF
     MOVE 0 TO GW-GOT(L-I)
     GOBACK.
 END PROGRAM GEN-WORKER-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-FORCE               BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GW-MAX
         IF GW-SLOT(WS-I) > 0
             CALL STATIC "cc_wk_stop" USING BY VALUE GW-SLOT(WS-I) BY VALUE WS-FORCE RETURNING WS-RC
         END-IF
         IF GW-ADDR(WS-I) NOT = NULL
             FREE GW-ADDR(WS-I)
         END-IF
         MOVE 0 TO GW-SLOT(WS-I) GW-BUSY(WS-I) GW-DIM(WS-I) GW-CX(WS-I) GW-CZ(WS-I) GW-GOT(WS-I)
         SET GW-ADDR(WS-I) TO NULL
     END-PERFORM
     MOVE 0 TO GW-ACTIVE GQ-READY
     GOBACK.
 END PROGRAM GEN-WORKERS-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-CONFIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE.
     CALL "GEN-WORKERS-STOP"
     MOVE FUNCTION MAX(0, FUNCTION MIN(L-SIZE, GW-POOL-MAX)) TO GQ-WORKERS
     MOVE GQ-WORKERS TO GQ-LOAD-WORKERS
     GOBACK.
 END PROGRAM GEN-WORKERS-CONFIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-COLLECT.
*> USING worker index: reads what the busy worker has sent without waiting; when the answer is complete the chunk is installed (unless it
*> was loaded another way meanwhile) and the worker is idle again; a worker that is gone is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-PTR                 USAGE POINTER.
 01 WS-WANT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I.
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-MORE = 0
         COMPUTE WS-WANT = GW-ANSWER-BYTES - GW-GOT(L-I)
         SET WS-PTR TO GW-ADDR(L-I)
         SET WS-PTR UP BY GW-GOT(L-I)
         CALL STATIC "cc_wk_recv" USING BY VALUE GW-SLOT(L-I) BY VALUE WS-PTR BY VALUE WS-WANT RETURNING WS-RC
         EVALUATE TRUE
             WHEN WS-RC < 0
                 CALL "GEN-WORKER-DROP" USING L-I
                 MOVE 0 TO WS-MORE
             WHEN WS-RC = 0
                 MOVE 0 TO WS-MORE
             WHEN OTHER
                 ADD WS-RC TO GW-GOT(L-I)
                 IF GW-GOT(L-I) = GW-ANSWER-BYTES
                     MOVE 0 TO WS-MORE
                     CALL "WORLD-FIND" USING GW-DIM(L-I) GW-CX(L-I) GW-CZ(L-I) WS-ROW
                     IF WS-ROW = 0
                         MOVE L-I TO GQ-READY
                         CALL "WORLD-CHUNK-LOAD" USING GW-DIM(L-I) GW-CX(L-I) GW-CZ(L-I) WS-ROW
                         MOVE 0 TO GQ-READY
                         ADD 1 TO GQ-GENERATED
                     END-IF
                     MOVE 0 TO GW-BUSY(L-I) GW-GOT(L-I)
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-WORKER-COLLECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKER-ASSIGN.
*> USING worker index (the worker is idle): the nearest queued chunk of the standard pipeline is sent to it (the worker is started first
*> when it is the first request). When no worker can be started the pool is switched off (the in-tick steps take over); a worker that
*> does not take the request is dropped and the chunk stays queued.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 78 WS-REQUEST-BYTES       VALUE 12.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-BEST                BINARY-LONG.
 01 WS-REQUEST.
    05 WS-DIM              BINARY-LONG.
    05 WS-CX               BINARY-LONG.
    05 WS-CZ               BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-BYTES               BINARY-LONG VALUE 304644.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 PROCEDURE DIVISION USING L-I.
     CALL "GEN-QUEUE-PICK-MODE" USING WS-MODE WS-BEST
     IF WS-BEST = 0
         GOBACK
     END-IF
     IF GW-SLOT(L-I) = 0
         CALL "GEN-WORKER-START" USING GW-SLOT(L-I)
         IF GW-SLOT(L-I) < 0
             MOVE 0 TO GW-SLOT(L-I) GQ-WORKERS GW-ACTIVE
             GOBACK
         END-IF
         ALLOCATE WS-BYTES CHARACTERS RETURNING GW-ADDR(L-I)
     END-IF
     MOVE GQ-DIM(WS-BEST) TO WS-DIM GW-DIM(L-I)
     MOVE GQ-X(WS-BEST) TO WS-CX GW-CX(L-I)
     MOVE GQ-Z(WS-BEST) TO WS-CZ GW-CZ(L-I)
     MOVE GQ-ENTRY(GQ-COUNT) TO GQ-ENTRY(WS-BEST)
     SUBTRACT 1 FROM GQ-COUNT
     CALL STATIC "cc_wk_send" USING BY VALUE GW-SLOT(L-I) BY REFERENCE WS-REQUEST BY VALUE WS-REQUEST-BYTES RETURNING WS-RC
     IF WS-RC = WS-REQUEST-BYTES
         MOVE 1 TO GW-BUSY(L-I)
         MOVE 0 TO GW-GOT(L-I)
     ELSE
         CALL "GEN-WORKER-DROP" USING L-I
         CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     END-IF
     GOBACK.
 END PROGRAM GEN-WORKER-ASSIGN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-TICK.
*> No parameters: the pool's share of one tick: finished answers are collected (every worker, busy ones only), idle workers up to the pool size get the nearest chunks; the pool
*> is GQ-LOAD-WORKERS while a spawn area is made (GQ-SP-STATE above 0), else GQ-WORKERS, and the idle workers above it are stopped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-FORCE               BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WORLD-IS-DEBUG" USING WS-DEBUG
     CALL "GEN-DATA-READY" USING WS-READY
     MOVE 0 TO GW-ACTIVE
     IF WS-DEBUG = 0 AND WS-READY = 1
         MOVE 1 TO GW-ACTIVE
     END-IF
     IF GW-ACTIVE = 0
         GOBACK
     END-IF
     MOVE GQ-WORKERS TO WS-LIMIT
     IF GQ-SP-STATE > 0
         MOVE GQ-LOAD-WORKERS TO WS-LIMIT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GW-MAX
         IF GW-BUSY(WS-I) = 1
             CALL "GEN-WORKER-COLLECT" USING WS-I
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIMIT
         IF GW-BUSY(WS-I) = 0
             CALL "GEN-WORKER-ASSIGN" USING WS-I
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GW-MAX
         IF WS-I > WS-LIMIT AND GW-BUSY(WS-I) = 0 AND GW-SLOT(WS-I) > 0
             CALL STATIC "cc_wk_stop" USING BY VALUE GW-SLOT(WS-I) BY VALUE WS-FORCE RETURNING WS-RC
             MOVE 0 TO GW-SLOT(WS-I)
             IF GW-ADDR(WS-I) NOT = NULL
                 FREE GW-ADDR(WS-I)
                 SET GW-ADDR(WS-I) TO NULL
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-WORKERS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STANDARD-TAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-ANSWER              PIC X(304644) BASED.
 01 WS-DST                 PIC X(304640) BASED.
 01 WS-MARKER              BINARY-LONG BASED.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y L-FLAG.
     MOVE 0 TO L-FLAG
     IF GQ-READY > 0
         IF GW-DIM(GQ-READY) = L-DIM AND GW-CX(GQ-READY) = L-CX AND GW-CZ(GQ-READY) = L-CZ
             SET ADDRESS OF WS-ANSWER TO GW-ADDR(GQ-READY)
             SET ADDRESS OF WS-MARKER TO GW-ADDR(GQ-READY)
             SET ADDRESS OF WS-DST TO ADDRESS OF L-CHUNK
             MOVE WS-ANSWER(5:304640) TO WS-DST
             MOVE WS-MARKER TO L-MARKER-Y
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GEN-STANDARD-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-GET-DEFER.
*> USING dimension row, chunk x, chunk z (an unloaded chunk), flag out (BINARY-LONG): 1 when the chunk is not to be generated where a block read finds it
*> missing: the workers serve the standard chunks (GW-ACTIVE) and the dimension is generated by that pipeline. The chunk is queued; the read is void, as a read in
*> a chunk that is not loaded is. 0 otherwise (the chunk is generated where it stands).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 COPY DIMENSIONS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-FLAG.
     MOVE 0 TO L-FLAG
     IF GQ-WORKERS > 0 AND GW-ACTIVE = 1 AND DM-GENERATOR(L-DIM) = DIM-GEN-STANDARD
         CALL "GEN-QUEUE-WANT" USING L-DIM L-CX L-CZ
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WORLD-GET-DEFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-GET.
*> USING size out (BINARY-LONG): the pool size a host asked for (GEN-WORKERS-CONFIG), 0 = none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE.
     MOVE GQ-WORKERS TO L-SIZE
     GOBACK.
 END PROGRAM GEN-WORKERS-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-AUTO.
*> No parameters: sizes the pool from the processors online (cc_wk_cpus): half of them, at least 1 and at most GW-MAX, so the game loop, the renderer and
*> the rest of the machine keep the other half (docs/design/generation-worker.md).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-CPUS                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL STATIC "cc_wk_cpus" RETURNING WS-CPUS
     COMPUTE WS-SIZE = WS-CPUS / 2
     CALL "GEN-WORKERS-CONFIG" USING WS-SIZE
     IF GQ-WORKERS < 1
         MOVE 1 TO WS-SIZE
         CALL "GEN-WORKERS-CONFIG" USING WS-SIZE
     END-IF
*>   while a world's spawn area is made the player waits for it, so more of the machine is used: all but two processors (at least the pool, at most GW-MAX)
     COMPUTE WS-SIZE = WS-CPUS - 2
     IF WS-SIZE < GQ-WORKERS
         MOVE GQ-WORKERS TO WS-SIZE
     END-IF
     IF WS-SIZE > GW-MAX
         MOVE GW-MAX TO WS-SIZE
     END-IF
     MOVE WS-SIZE TO GQ-LOAD-WORKERS
     GOBACK.
 END PROGRAM GEN-WORKERS-AUTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-WORKERS-LOADING.
*> USING size out (BINARY-LONG): the pool while a world's spawn area is made (GQ-LOAD-WORKERS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE.
     MOVE GQ-LOAD-WORKERS TO L-SIZE
     GOBACK.
 END PROGRAM GEN-WORKERS-LOADING.
