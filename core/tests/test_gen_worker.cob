*> Implementation test of the generation worker (docs/design/generation-worker.md; core/src/gen-worker.cob): with workers configured, the
*> queue hands the standard chunks to forked worker processes and installs what they send back. On the fixture terrain data: a chunk
*> from a worker equals, byte for byte, the atomic reference of the same process; an in-flight chunk is not queued twice; two workers
*> make every chunk the reference makes, whatever the order they finish in; the dispatching tick returns at once (the chunk is not
*> there yet); a worker that died while busy is dropped and its chunk is made by a new one; a send to a dead worker is dropped the same
*> way; when no worker can be started the pool is switched off and the in-tick stepped path makes the chunk; a reset leaves no worker; a
*> chunk loaded another way while a worker had it is kept and the late result is discarded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-WORKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY CELLS.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAME                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-QUIT                PIC X(12).
 01 WS-QUIT-R REDEFINES WS-QUIT.
    05 WS-Q-DIM            BINARY-LONG.
    05 WS-Q-CX             BINARY-LONG.
    05 WS-Q-CZ             BINARY-LONG.
 01 WS-SLOTS.
    05 WS-DUMMY            BINARY-LONG OCCURS 8 TIMES.
 01 WS-SLEEP               PIC 9V99 VALUE 0.01.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-WORKERS             BINARY-LONG.
 01 WS-GRID                PIC X(1225).
 01 WS-CELL                BINARY-LONG.
 01 WS-SAVE-DIM            BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-BUSY                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-GEN-FIXTURE"

*>   the atomic references
     MOVE 2 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y

*>   one worker makes chunk (2, 3)
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     PERFORM CLOCK-NOW
     MOVE WS-T1 TO WS-T0
     CALL "GEN-QUEUE-TICK"
     PERFORM CLOCK-NOW
     MOVE "test gen worker the dispatching tick leaves the chunk to the worker" TO TL-CASE
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen worker an in-flight chunk is not queued again" TO TL-CASE
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE GQ-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the loading screen's grid (of the world's first dimension, here row 3) shows the chunk a worker is making as TERRAIN (code 5), then as FULL (10)
     MOVE CW-DIM(1) TO WS-SAVE-DIM
     MOVE 3 TO CW-DIM(1)
     CALL "GEN-LOAD-GRID" USING WS-GRID
     COMPUTE WS-CELL = (WS-CZ + 17) * 35 + WS-CX + 17 + 1
     MOVE "test gen worker the grid shows the chunk a worker is making as status TERRAIN (code 5)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION ORD(WS-GRID(WS-CELL:1)) - 1
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen worker no job runs in the tick" TO TL-CASE
     MOVE GJ-ACTIVE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM WAIT-FOR-CHUNK
     MOVE "test gen worker the chunk arrives from the worker" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-LOAD-GRID" USING WS-GRID
     MOVE "test gen worker the grid shows the finished chunk as FULL (code 10)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION ORD(WS-GRID(WS-CELL:1)) - 1
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-DIM TO CW-DIM(1)
     SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
     MOVE "test gen worker the worker's chunk equals the atomic reference byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen worker the queue counts the chunk once and nothing is left in flight" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GQ-GENERATED * 10 + GQ-COUNT
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an idle worker stopped gracefully ends at the end of its input (the worker side of a request answered, then of end of input)
     MOVE GW-SLOT(1) TO WS-SLOT
     CALL STATIC "cc_wk_stop" USING BY VALUE WS-SLOT BY VALUE 0 RETURNING WS-RC
     MOVE "test gen worker an idle worker stopped gracefully is reaped" TO TL-CASE
     MOVE WS-RC TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   two workers, six chunks, each equal to its own reference
     CALL "GEN-QUEUE-RESET"
     MOVE 2 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         MOVE WS-I TO WS-CX
         COMPUTE WS-CZ = 5 - WS-I
         CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE 0 TO WS-N
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL WS-N >= 6 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
             MOVE WS-I TO WS-CX
             COMPUTE WS-CZ = 5 - WS-I
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         MOVE WS-I TO WS-CX
         COMPUTE WS-CZ = 5 - WS-I
         CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW > 0
             SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
             IF WS-A = WS-REF
                 ADD 1 TO WS-SAME
             END-IF
         END-IF
     END-PERFORM
     MOVE "test gen worker two workers make six chunks, each equal to its reference" TO TL-CASE
     MOVE WS-SAME TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   chunk (2, 3) was loaded by the first part and is not made again: five are counted
     MOVE "test gen worker the five new chunks were counted" TO TL-CASE
     MOVE GQ-GENERATED TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a worker killed while busy: dropped, the chunk is made by a new worker
     CALL "GEN-QUEUE-RESET"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 9 TO WS-CX
     MOVE 9 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     MOVE GW-SLOT(1) TO WS-SLOT
     CALL STATIC "cc_wk_stop" USING BY VALUE WS-SLOT BY VALUE 1 RETURNING WS-RC
     CALL "GEN-QUEUE-TICK"
     MOVE "test gen worker a worker that died while busy is dropped and replaced, its chunk is queued again" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GW-BUSY(1) * 10 + GQ-COUNT
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM WAIT-FOR-CHUNK
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
     MOVE "test gen worker the chunk of the dead worker still arrives and equals the reference" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0 AND WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a request to a dead idle worker is dropped the same way
     MOVE GW-SLOT(1) TO WS-SLOT
     CALL STATIC "cc_wk_stop" USING BY VALUE WS-SLOT BY VALUE 1 RETURNING WS-RC
     MOVE 10 TO WS-CX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     MOVE "test gen worker a send to a dead worker is dropped and the chunk stays queued" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GW-BUSY(1) * 10 + GQ-COUNT + GW-SLOT(1) * 100
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-TICK"
     PERFORM WAIT-FOR-CHUNK
     MOVE "test gen worker the chunk arrives from the replacement worker" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a worker's result for a chunk that is loaded some other way meanwhile is discarded
     MOVE 11 TO WS-CX
     MOVE 11 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE GQ-GENERATED TO WS-N
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL GW-BUSY(1) = 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
     END-PERFORM
     MOVE "test gen worker a chunk loaded another way is kept and the late result is not counted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GQ-GENERATED - WS-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   no worker can be started: the pool is switched off and the stepped path makes the chunk
     CALL "GEN-QUEUE-RESET"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL STATIC "cc_wk_spawn" RETURNING WS-RC
         IF WS-RC = 0
             CALL "GEN-WORKER-EXIT" USING WS-I
         END-IF
         MOVE WS-RC TO WS-DUMMY(WS-I)
     END-PERFORM
     MOVE 12 TO WS-CX
     MOVE 12 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     MOVE "test gen worker with no worker to start the pool is switched off" TO TL-CASE
     MOVE GQ-WORKERS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 400
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     END-PERFORM
     MOVE "test gen worker the in-tick stepped path then makes the chunk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         IF WS-DUMMY(WS-I) > 0
             MOVE WS-DUMMY(WS-I) TO WS-SLOT
             CALL STATIC "cc_wk_stop" USING BY VALUE WS-SLOT BY VALUE 1 RETURNING WS-RC
         END-IF
     END-PERFORM

*>   a block read in a chunk that is not loaded does not generate it inside the tick while the workers serve the dimension: it reads as void and
*>   the chunk is queued; without workers it is generated where it stands (the behaviour of the synchronous generator)
     CALL "GEN-QUEUE-RESET"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-WORKERS-TICK"
     MOVE 600 TO WS-N
     MOVE 40 TO WS-ROW
     MOVE 16 TO WS-I
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-N WS-ROW WS-I WS-RC
     MOVE 37 TO WS-CX
     MOVE 1 TO WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-SLOT
     MOVE "test gen worker a block read in an unloaded chunk of a served dimension is void, queues the chunk and generates nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RC * 100 + WS-SLOT * 10 + GQ-COUNT
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 600 TO WS-N
     MOVE 40 TO WS-ROW
     MOVE 16 TO WS-I
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-N WS-ROW WS-I WS-RC
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-SLOT
     MOVE "test gen worker without workers a block read in an unloaded chunk generates it where it stands" TO TL-CASE
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   while a spawn area is made (GQ-SP-STATE 2) the loading pool of 3 works though the pool is 1; afterwards the extra workers are stopped when idle
     CALL "GEN-QUEUE-RESET"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 3 TO GQ-LOAD-WORKERS
     MOVE 2 TO GQ-SP-STATE
     PERFORM VARYING WS-I FROM 20 BY 1 UNTIL WS-I > 25
         MOVE WS-I TO WS-CX
         MOVE 20 TO WS-CZ
         CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     CALL "GEN-QUEUE-TICK"
     MOVE 0 TO WS-BUSY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GW-MAX
         IF GW-BUSY(WS-I) = 1
             ADD 1 TO WS-BUSY
         END-IF
     END-PERFORM
     MOVE "test gen worker while the spawn area is made three workers are busy though the pool is one" TO TL-CASE
     MOVE WS-BUSY TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GQ-SP-STATE
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-N
     PERFORM UNTIL WS-N >= 6 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 20 BY 1 UNTIL WS-I > 25
             MOVE WS-I TO WS-CX
             MOVE 20 TO WS-CZ
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "GEN-QUEUE-TICK"
     MOVE "test gen worker all six chunks of the loading pool arrive" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen worker once the area is made the idle extra workers are stopped" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (GW-SLOT(2) + GW-SLOT(3)) * 10 + FUNCTION MIN(GW-SLOT(1), 1)
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a reset leaves no worker, a config of 0 or too many is bounded
     MOVE 2 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 13 TO WS-CX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     MOVE GW-SLOT(1) TO WS-SLOT
     CALL "GEN-QUEUE-RESET"
     CALL STATIC "cc_wk_send" USING BY VALUE WS-SLOT BY REFERENCE WS-QUIT BY VALUE 12 RETURNING WS-RC
     MOVE "test gen worker a reset stops the workers, their slots are gone" TO TL-CASE
     MOVE WS-RC TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE "test gen worker the pool size is bounded" TO TL-CASE
     CALL "GEN-WORKERS-GET" USING WS-N
     MOVE WS-N TO TL-OBSERVED-N
     MOVE GW-POOL-MAX TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-WORKERS-AUTO"
     CALL "GEN-WORKERS-GET" USING WS-N
     CALL STATIC "cc_wk_cpus" RETURNING WS-RC
     COMPUTE WS-WORKERS = WS-RC / 2
     IF WS-WORKERS < 1
         MOVE 1 TO WS-WORKERS
     END-IF
     IF WS-WORKERS > GW-POOL-MAX
         MOVE GW-POOL-MAX TO WS-WORKERS
     END-IF
     MOVE "test gen worker the automatic pool is half the processors, at least 1 and at most the maximum" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE WS-WORKERS TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the pool used while a world's spawn area is made: processors - 2 (at least the pool, at most GW-MAX = 8) for the automatic size, else the size asked for
     CALL "GEN-WORKERS-LOADING" USING WS-N
     COMPUTE WS-EXPECT = WS-RC - 2
     IF WS-EXPECT < WS-WORKERS
         MOVE WS-WORKERS TO WS-EXPECT
     END-IF
     IF WS-EXPECT > GW-MAX
         MOVE GW-MAX TO WS-EXPECT
     END-IF
     MOVE "test gen worker the automatic loading pool is processors - 2, not below the pool, at most 8" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE WS-EXPECT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-N
     CALL "GEN-WORKERS-CONFIG" USING WS-N
     CALL "GEN-WORKERS-LOADING" USING WS-N
     MOVE "test gen worker an explicit pool size is also the loading pool" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE "test gen worker a negative pool size is none" TO TL-CASE
     MOVE GQ-WORKERS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   without terrain data the pool has nothing to serve
     CALL "GEN-QUEUE-RESET"
     CALL "WORLDGEN-FREE"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-WORKERS-TICK"
     MOVE "test gen worker without terrain data the pool is not active" TO TL-CASE
     MOVE GW-ACTIVE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-GEN-FIXTURE"
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS

*>   graceful stop of a busy worker: the worker finishes, finds the pipe closed and ends (its write fails)
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE 14 TO WS-CX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     CALL "GEN-QUEUE-TICK"
     MOVE GW-SLOT(1) TO WS-SLOT
     CALL STATIC "cc_wk_stop" USING BY VALUE WS-SLOT BY VALUE 0 RETURNING WS-RC
     MOVE "test gen worker a graceful stop reaps a busy worker" TO TL-CASE
     MOVE WS-RC TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     MOVE "test gen worker the exit program does nothing unless told to" TO TL-CASE
     CALL "GEN-WORKER-EXIT" USING WS-ZERO
     MOVE 0 TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 WAIT-FOR-CHUNK.
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW = 0
             CALL "C$SLEEP" USING WS-SLEEP
         END-IF
     END-PERFORM.

 CLOCK-NOW.
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-T1 = (FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60 + FUNCTION NUMVAL(WS-CLOCK(13:2))) * 100
         + FUNCTION NUMVAL(WS-CLOCK(15:2)).
 END PROGRAM TEST-GEN-WORKER.
 COPY CORETEST.
 COPY GENFIXTURE.
