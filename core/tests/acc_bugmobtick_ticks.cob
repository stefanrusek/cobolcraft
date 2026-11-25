*> CC-0052 (real-data test, skipped as a pass without the generated packs): a mob tick stays inside the per-tick CPU budget whatever chunks are loaded. In a standard world without generation workers
*> (the tests, a server with generation-workers=0) a block read of an unloaded chunk generated the chunk where the read stood (WORLD-GET-BLOCK, WORLD-CHUNK-LOAD, the whole pipeline in one call), and the
*> reads of a mob at the edge of the loaded chunks are such reads: a bat picks a target within 7 blocks, an animal's box covers the cells next to it. MOBS-TICK alone took 0.5 to 0.7 s of CPU (optimised
*> build) or 1.2 to 2.7 s (debug build) in about one tick per chunk the mob reached, with the hostile mobs off. With workers the read is void and the chunk is queued (WORLD-GET-DEFER); the mob tick now
*> does the same without them: the chunk is made by the steps of the generation queue (GQ-STEP-BUDGET steps, GQ-MS-HUNDREDTHS of wall time per tick).
*> The world is the one of the other tick tests (seed 424242, view distance 2, NOSPAWN): it ticks (the real CORE-TICK) until the chunk of the player is loaded, then a chunk three chunks away (outside the
*> view, loaded here and lit before the timing) gets a cow on its east edge whose box covers a chunk that is not loaded; MOBS-TICK, the step 6 of CORE-TICK, is timed alone (CPU time, C clock()) and must
*> take at most ten times the budget of the queue; the chunk it read is not loaded by it and is in the queue. A second cow on the north edge is stepped by the CORE-TICK itself, the whole tick of the game
*> loop must stay below thirty times the budget (the tick also holds the queue's steps and every other system).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGMOBTICK-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DISCARD             PIC X(4096).
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-MOB-US              BINARY-DOUBLE.
 01 WS-TICK-US             BINARY-DOUBLE.
 01 WS-BOUND-MOB-US        BINARY-DOUBLE.
 01 WS-BOUND-TICK-US       BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-QUEUED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SECONDS             PIC -(6)9.999.
 01 WS-SECONDS-2           PIC -(6)9.999.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "bug mob tick no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "424242" TO CS-SEED-TEXT
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   the generation of the first chunks takes more ticks than the keep-alive allows an unanswered player
     MOVE 999999999 TO CN-KA-DEADLINE(WS-ID-OPAL)
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-PROW
     MOVE PL-DIM(WS-PROW) TO WS-DIM
*>   the budget of the queue in microseconds is GQ-MS-HUNDREDTHS * 10000: ten times it for the mob tick alone, thirty times it for the whole tick (the queue's own steps are in it)
     COMPUTE WS-BOUND-MOB-US = GQ-MS-HUNDREDTHS * 10000 * 10
     COMPUTE WS-BOUND-TICK-US = GQ-MS-HUNDREDTHS * 10000 * 30
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PROW) / 16)
*>   the first chunk of the view is the player's: tick until it is loaded (the ticks of its generation are the other tests' subject)
     MOVE 0 TO WS-TICKS WS-ROW
     PERFORM WITH TEST AFTER UNTIL WS-ROW > 0 OR WS-TICKS > 20000
         CALL "CORE-TICK"
         ADD 1 TO WS-TICKS
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     END-PERFORM
     MOVE "bug mob tick the chunk of the player is loaded by the ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the edge chunk: three chunks east of the player, outside the view of distance 2 (the queue does not want it, nor the chunks round it) and inside the range of MOB-ACTIVE (64 blocks); loaded and lit here, outside the timing
     COMPUTE WS-EX = WS-CX + 3
     MOVE WS-CZ TO WS-EZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-EX WS-EZ WS-ROW
     CALL "STDMOB-READY" USING WS-DIM WS-EX WS-EZ WS-READY
     COMPUTE WS-NX = WS-EX + 1
     MOVE WS-EZ TO WS-NZ
     CALL "WORLD-FIND" USING WS-DIM WS-NX WS-NZ WS-ROW
     MOVE "bug mob tick the chunk east of the edge chunk is not loaded before the mob tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a cow on the east edge of the edge chunk: its box (0.9 wide) covers the first column of the chunk beyond it
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-EX * 16 + 15
     COMPUTE WS-Z = WS-EZ * 16 + 8
     PERFORM FIND-SURFACE
     COMPUTE WS-PX = WS-EX * 16 + 15.7
     COMPUTE WS-PY = WS-Y
     COMPUTE WS-PZ = WS-EZ * 16 + 8.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-COW
     CALL "COST-CLOCK" USING WS-T0
     CALL "MOBS-TICK"
     CALL "COST-CLOCK" USING WS-T1
     COMPUTE WS-MOB-US = WS-T1 - WS-T0
     COMPUTE WS-SECONDS = WS-MOB-US / 1000000
     DISPLAY "MOBTICK cow at the edge: MOBS-TICK cpu=" WS-SECONDS " s"
     MOVE "bug mob tick the mob tick of a cow at the edge of the loaded chunks takes at most ten times the budget of the queue in CPU time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MOB-US < WS-BOUND-MOB-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-FIND" USING WS-DIM WS-NX WS-NZ WS-ROW
     MOVE "bug mob tick the mob tick does not generate the chunk its cow read: it is not loaded after it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-QUEUED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
         IF GQ-DIM(WS-I) = WS-DIM AND GQ-X(WS-I) = WS-NX AND GQ-Z(WS-I) = WS-NZ
             MOVE 1 TO WS-QUEUED
         END-IF
     END-PERFORM
     IF GJ-ACTIVE NOT = 0 AND GJ-DIM = WS-DIM AND GJ-CX = WS-NX AND GJ-CZ = WS-NZ
         MOVE 1 TO WS-QUEUED
     END-IF
     MOVE "bug mob tick the chunk the cow read is in the generation queue" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-QUEUED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the game loop's own tick with a cow on the north edge of the same chunk, over the chunk north of it that is not loaded
     MOVE WS-EX TO WS-NX
     COMPUTE WS-NZ = WS-EZ - 1
     CALL "WORLD-FIND" USING WS-DIM WS-NX WS-NZ WS-ROW
     MOVE "bug mob tick the chunk north of the edge chunk is not loaded before the tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-EX * 16 + 8
     COMPUTE WS-Z = WS-EZ * 16
     PERFORM FIND-SURFACE
     COMPUTE WS-PX = WS-EX * 16 + 8.5
     COMPUTE WS-PY = WS-Y
     COMPUTE WS-PZ = WS-EZ * 16 + 0.3
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-COW
     CALL "COST-CLOCK" USING WS-T0
     CALL "CORE-TICK"
     CALL "COST-CLOCK" USING WS-T1
     COMPUTE WS-TICK-US = WS-T1 - WS-T0
     COMPUTE WS-SECONDS-2 = WS-TICK-US / 1000000
     DISPLAY "MOBTICK cow at the north edge: CORE-TICK cpu=" WS-SECONDS-2 " s"
     MOVE "bug mob tick the tick of the game loop with a cow at the edge takes less than thirty times the budget of the queue in CPU time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TICK-US < WS-BOUND-TICK-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The top of the terrain in the column of (WS-X, WS-Z): WS-Y is the cell above the highest cell that is not air, read without loading a chunk.
 FIND-SURFACE.
     MOVE 319 TO WS-Y
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-Y < -64
         CALL "WORLD-PEEK-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     ADD 1 TO WS-Y.
 END PROGRAM ACC-BUGMOBTICK-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COST-CLOCK.
*> USING microseconds out: the CPU time of the process (C clock(), CLOCKS_PER_SEC is 1000000 on this platform).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-US.
     CALL STATIC "clock" RETURNING L-US
     GOBACK.
 END PROGRAM COST-CLOCK.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY CMDTEST.
