*> Golden hash of a generated fixture chunk (performance work of the world generation, Risk R-P): the bytes of chunk (2, 3) of the
*> standard pipeline on the fixture data (core/tests/fixtures/gen) hash to the value recorded before the optimisations, so every later
*> speed-up of the pipeline keeps its output bit for bit (the hash was taken on the unoptimised pipeline).
*> standard pipeline cannot be generated inside one 50 ms tick, so the queue advances a job by bounded steps under a per-tick
*> budget). On the fixture terrain data (core/tests/fixtures/gen: a final density of two interpolated nodes, the six climate
*> functions of the density fixture, a two point biome source): a tick with a pending chunk runs at most the step budget of
*> steps (a count, not wall time, so the test is deterministic) and the chunk is not in the cache until the last step, which
*> comes after exactly ceil(steps / budget) ticks; the chunk equals, byte for byte, the atomic reference (all steps back to back);
*> the chunk is the terrain the density says; a chunk that was loaded meanwhile is not generated twice; the job is the nearest
*> chunk first; CORE-TICK itself stays within GQ-STEP-BUDGET steps. The measured cost of each stage (hundredths of a second for
*> all the steps of the stage, on this machine and the fixture data) is printed as evidence for Risk R-P.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-GOLDEN.
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
 01 WS-HASH               BINARY-DOUBLE.
 01 WS-POS                BINARY-LONG.
 01 WS-EDIT-H             PIC Z(18)9.
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
     MOVE 12345 TO CW-SEED
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
     MOVE 2 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     MOVE 7 TO WS-HASH
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 304640
         COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + FUNCTION ORD(WS-REF(WS-POS:1)), 1000000007)
     END-PERFORM
     MOVE WS-HASH TO WS-EDIT-H
     DISPLAY "golden hash " WS-EDIT-H
     MOVE "test gen golden the bytes of the fixture chunk (2, 3) hash to the recorded value" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE 155538646 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GEN-GOLDEN.
 COPY CORETEST.
