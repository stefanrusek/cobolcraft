*> Acceptance test of the resumable, time-sliced chunk generation (T0407; research R12, the decision on Risk R-P: a chunk of the
*> standard pipeline cannot be generated inside one 50 ms tick, so the queue advances a job by bounded steps under a per-tick
*> budget). On the fixture terrain data (core/tests/fixtures/gen: a final density of two interpolated nodes, the six climate
*> functions of the density fixture, a two point biome source): a tick with a pending chunk runs at most the step budget of
*> steps (a count, not wall time, so the test is deterministic) and the chunk is not in the cache until the last step, which
*> comes after exactly ceil(steps / budget) ticks; the chunk equals, byte for byte, the atomic reference (all steps back to back);
*> the chunk is the terrain the density says; a chunk that was loaded meanwhile is not generated twice; the job is the nearest
*> chunk first; CORE-TICK itself stays within GQ-STEP-BUDGET steps. The measured cost of each stage (hundredths of a second for
*> all the steps of the stage, on this machine and the fixture data) is printed as evidence for Risk R-P.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-COST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY GENSTEPS.
 COPY CLIMATE.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/gen".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-OVER                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-MARKER              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONES              BINARY-LONG.
 01 WS-WATERS              BINARY-LONG.
 01 WS-LOW-OK              BINARY-LONG.
 01 WS-HIGH-OK             BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BIOMES              BINARY-LONG.
 01 WS-EXPECTED-TICKS      BINARY-LONG.
 01 WS-STEPS-BEFORE        BINARY-DOUBLE.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-CUR-STAGE           BINARY-LONG.
 01 WS-STAGE-TIME.
    05 WS-ST               BINARY-LONG OCCURS 8 TIMES.
 01 WS-EDIT                PIC Z(5)9.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 01 WS-KEY48               PIC X(48).
 01 WS-KEY112              PIC X(112).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "12345" TO CS-SEED-TEXT
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 1 TO PL-USED(1)
     MOVE PS-ALIVE TO PL-STATE(1)
     MOVE 3 TO PL-DIM(1)
     MOVE 8.5 TO PL-X(1)
     MOVE 8.5 TO PL-Z(1)

*>   the block and biome tables the stages resolve keys in
     MOVE 4 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE 2 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     MOVE "minecraft:desert" TO CBI-KEY(2)
     MOVE 16 TO CBI-KEY-LENGTH(2)
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 1399 TO WS-MAX(6)
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE 10000 TO WS-MAX(6)
     MOVE 1400 TO WS-MIN(6)
     MOVE "minecraft:desert" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET

     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "test gen cost the fixture terrain data load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-DATA-READY" USING WS-READY
     MOVE "test gen cost the pipeline sees the data" TO TL-CASE
     MOVE WS-READY TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     INITIALIZE GEN-STAGES

*>   evidence: the measured cost of each stage (all its steps), by running a job step by step
     MOVE 0 TO WS-CX WS-CZ
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     MOVE T-STAGE TO WS-CUR-STAGE
     PERFORM CLOCK-NOW
     MOVE WS-T1 TO WS-T0
     PERFORM UNTIL T-ACTIVE NOT = 1
         MOVE T-STAGE TO WS-N
         CALL "GEN-JOB-STEP" USING WS-JOB
         IF T-STAGE NOT = WS-N
             PERFORM CLOCK-NOW
             COMPUTE WS-ST(WS-N) = FUNCTION MOD(WS-T1 - WS-T0 + 360000, 360000)
             MOVE WS-T1 TO WS-T0
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GJ-STAGE-COUNT
         MOVE WS-ST(WS-I) TO WS-EDIT
         DISPLAY "gen-cost stage " WS-I " hundredths-of-a-second " WS-EDIT
     END-PERFORM
     MOVE T-STEPS TO WS-N
     MOVE "test gen cost a job runs exactly the steps of GENSTEPS.cpy" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE GJ-STEPS-TOTAL TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   the atomic reference of chunk (2, 3)
     MOVE 2 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y

*>   the chunk (2, 3) by ticks of 4 steps (no wall limit)
     INITIALIZE GEN-STAGES
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 4 TO WS-STEPS
     MOVE 2 TO WS-CHUNKS
     MOVE 0 TO WS-LIMIT
     MOVE 0 TO WS-TICKS WS-OVER
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 100
         CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
         ADD 1 TO WS-TICKS
         IF WS-RUN > WS-STEPS
             ADD 1 TO WS-OVER
         END-IF
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW = 0 AND WS-RUN NOT = WS-STEPS
             ADD 1 TO WS-OVER
         END-IF
     END-PERFORM
     MOVE "test gen cost no tick ran more than the step budget (and a tick without the chunk ran all of it)" TO TL-CASE
     MOVE WS-OVER TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-EXPECTED-TICKS = (GJ-STEPS-TOTAL + WS-STEPS - 1) / WS-STEPS
     MOVE "test gen cost the chunk appears after ceil(steps / budget) ticks" TO TL-CASE
     MOVE WS-TICKS TO TL-OBSERVED-N
     MOVE WS-EXPECTED-TICKS TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen cost the chunk was generated by the queue exactly once, the job is free" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GQ-GENERATED * 10 + GJ-ACTIVE
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
     MOVE "test gen cost the stepped chunk equals the atomic reference byte for byte" TO TL-CASE
     IF WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the terrain is what the density says: stone below y 28 (the gradient), air above the sea
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO WS-STONES WS-WATERS WS-LOW-OK WS-HIGH-OK WS-BIOMES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CELL = (-60 + 64) * 256 + WS-I
         IF CE-STATE(WS-CELL) = 1
             ADD 1 TO WS-LOW-OK
         END-IF
         COMPUTE WS-CELL = (200 + 64) * 256 + WS-I
         IF CE-STATE(WS-CELL) = 0
             ADD 1 TO WS-HIGH-OK
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-STATE-CELLS
         IF CE-STATE(WS-I) = 1
             ADD 1 TO WS-STONES
         END-IF
         IF CE-STATE(WS-I) = 86
             ADD 1 TO WS-WATERS
         END-IF
     END-PERFORM
     MOVE "test gen cost every column is stone at y -60 and air at y 200" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LOW-OK * 1000 + WS-HIGH-OK
     MOVE 256256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen cost the chunk holds both stone and sea water" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STONES > 20000 AND WS-WATERS > 1000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         IF CE-BIOME(WS-I) > 0
             ADD 1 TO WS-BIOMES
         END-IF
     END-PERFORM
     MOVE "test gen cost the biome cells hold the biome source's two biomes (ids 0 and 1)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BIOMES > 0 AND WS-BIOMES < 1536
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a chunk loaded some other way while its job runs is not generated twice
     MOVE -3 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 3 TO WS-STEPS
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 200 TO WS-STEPS
     MOVE GQ-GENERATED TO WS-STEPS-BEFORE
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     MOVE "test gen cost the job of a chunk loaded meanwhile is dropped and the chunk stays one row" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GJ-ACTIVE * 100 + (GQ-GENERATED - WS-STEPS-BEFORE) * 10 + FUNCTION MIN(WS-ROW, 1)
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   nearest first: the player is at chunk (0, 0); (9, 0) is wanted before (1, 0)
     MOVE 9 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 1 TO WS-CX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 1 TO WS-STEPS
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     MOVE "test gen cost the job started is the nearest chunk (1, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GJ-CX * 10 + GJ-ACTIVE
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen cost a want for the chunk of the running job is ignored" TO TL-CASE
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE GQ-COUNT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   CORE-TICK itself: one tick runs at most GQ-STEP-BUDGET steps
     MOVE GQ-STEPS TO WS-STEPS-BEFORE
     CALL "CORE-TICK"
     MOVE "test gen cost CORE-TICK runs between 1 and GQ-STEP-BUDGET generation steps" TO TL-CASE
     COMPUTE WS-N = GQ-STEPS - WS-STEPS-BEFORE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1 AND WS-N <= GQ-STEP-BUDGET
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a tick under a wall limit of one hundredth of a second stops between two steps (a biome step takes more than that)
     MOVE 1000 TO WS-STEPS
     MOVE 1 TO WS-LIMIT
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     MOVE "test gen cost a wall limit stops the tick after a few steps, far below the step budget" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-RUN >= 1 AND WS-RUN <= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     MOVE "test gen cost resetting the queue frees the job in progress" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GJ-ACTIVE * 10 + GQ-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the interpolated nodes of a tree: through references (a node reached twice counts once), not into a spline or find_top_surface
     MOVE 1 TO WS-N
     MOVE "minecraft:t/walk" TO WS-KEY112
     CALL "WG-FIND" USING WS-N WS-KEY112 WS-I
     MOVE 0 TO T-G-COUNT
     CALL "GEN-FIND-INTERP" USING WS-I WS-JOB
     MOVE "test gen cost the walk finds the one interpolated node of the tree" TO TL-CASE
     MOVE T-G-COUNT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   edge cases of the pieces: a negative seed text, a 48 byte block key, an empty node, a step of an idle job, an empty point table
     MOVE "-5" TO CS-SEED-TEXT
     MOVE CORE-SETTINGS TO CW-SETTINGS
     CALL "GEN-WORLD-SETUP"
     MOVE "test gen cost the world setup runs once per world (negative seed text)" TO TL-CASE
     MOVE GQ-SETUP-DONE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:a_block_with_a_key_of_exactly_forty_8" TO CB-KEY(5)
     MOVE 48 TO CB-KEY-LENGTH(5)
     MOVE 77 TO CB-DEFAULT-STATE(5)
     MOVE 5 TO CB-BLOCK-COUNT
     MOVE "minecraft:a_block_with_a_key_of_exactly_forty_8" TO WS-KEY48
     CALL "GEN-BLOCK-STATE" USING WS-KEY48 WS-N
     MOVE "test gen cost a block key of 48 bytes is found" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 77 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nothing" TO WS-KEY48
     CALL "GEN-BLOCK-STATE" USING WS-KEY48 WS-N
     MOVE "test gen cost an unknown block key gives state 0" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     MOVE 0 TO T-G-COUNT
     CALL "GEN-FIND-INTERP" USING WS-N WS-JOB
     MOVE 0 TO T-ACTIVE
     CALL "GEN-JOB-STEP" USING WS-JOB
     MOVE "test gen cost an empty node has no interpolated node and an idle job takes no step" TO TL-CASE
     MOVE T-G-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   with no points in the biome source the overworld list is built on the first biome step
     CALL "CLIMATE-POINTS-RESET"
     CALL "GEN-QUEUE-RESET"
     MOVE 0 TO WS-CX WS-CZ
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     CALL "GEN-JOB-STEP" USING WS-JOB
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "test gen cost the first biome step builds the overworld point list when there is none" TO TL-CASE
     MOVE CL-COUNT TO TL-OBSERVED-N
     MOVE 7594 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the budget of steps ends exactly with a chunk: the next chunk waits for the next tick
     MOVE 1 TO WS-CX
     MOVE 1 TO WS-CZ
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 2 TO WS-CX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE GJ-STEPS-TOTAL TO WS-STEPS
     MOVE 0 TO WS-LIMIT
     CALL "GEN-QUEUE-STEPS" USING WS-STEPS WS-CHUNKS WS-LIMIT WS-RUN WS-DONE
     MOVE "test gen cost a tick whose budget ends with a chunk completes it and leaves the next one queued" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DONE * 100 + WS-RUN - GJ-STEPS-TOTAL + GQ-COUNT * 10
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test gen cost a world without terrain data keeps the void chunk" TO TL-CASE
     CALL "WORLDGEN-FREE"
     MOVE 7 TO WS-CX
     MOVE 7 TO WS-CZ
     MOVE HIGH-VALUES TO WS-REF
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-REF WS-MARKER
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-REF
     COMPUTE TL-OBSERVED-N = CE-STATE(1) + CE-STATE(98304) + WS-MARKER
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOCK-NOW.
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-T1 = (FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60 + FUNCTION NUMVAL(WS-CLOCK(13:2))) * 100
         + FUNCTION NUMVAL(WS-CLOCK(15:2)).
 END PROGRAM TEST-GEN-COST.
 COPY CORETEST.
