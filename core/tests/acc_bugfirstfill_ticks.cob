*> CC-0047 (real-data test, skipped as a pass without the generated packs): the first generation of a fresh standard world stays inside the per-tick budget of the generation queue. The queue
*> stops a tick between two steps once GQ-MS-HUNDREDTHS of wall time are used, so the only way for a tick to be far above it is one step that is too big. The first fill step of a chunk ran
*> STRUCT-BEARD-PREPARE, the scan of the 17 x 17 chunks around it for the starts of the structures that adapt the terrain (36-1 section 9): 0.6 s of CPU in one step for the first chunk of the
*> seed below (the heights of the starts of the window, one walk of the density corners each, 20 to 350 ms apiece). The world is the one of the other locate tests (seed 424242, the player at the
*> spawn chunk, NOSPAWN: no spawn search, so the first generation falls into the ticks), the ticks are the real CORE-TICK, and the CPU time (C clock()) of each one is measured from the first
*> tick on, without ticking the generation to its end first. Cases: the tick that runs the first fill step of each of the first two chunks of the view costs at most ten times the budget (the
*> chunk's later fill steps are not in that tick); no tick of that generation costs a second (a hundred times the budget: a start's own height walk is one unit of work that cannot be
*> cut, 0.1 to 0.4 s for the starts of this window); both fill steps were seen; the tick measured is the whole of the CORE-TICK, as the player's game loop runs it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFIRSTFILL-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTEPS.
 COPY STRUCTBEARD.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-DISCARD             PIC X(4096).
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-MAX-US              BINARY-DOUBLE.
 01 WS-FILL-MAX-US         BINARY-DOUBLE.
 01 WS-BOUND-FILL-US       BINARY-DOUBLE.
 01 WS-BOUND-ALL-US        BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FILL-TICKS          BINARY-LONG.
 01 WS-STAGE-BEFORE        BINARY-LONG.
 01 WS-SECONDS             PIC -(6)9.999.
 01 WS-SECONDS-2           PIC -(6)9.999.
 01 WS-CX0                 BINARY-LONG VALUE 0.
 01 WS-CZ0                 BINARY-LONG VALUE 0.
 01 WS-STEP                BINARY-LONG.
 01 WS-GEN-BEFORE          BINARY-LONG.
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
         MOVE "bug first fill tick no generated packs here, skipped" TO TL-CASE
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
*>   the budget of the queue in microseconds is GQ-MS-HUNDREDTHS * 10000: ten times it for the tick of a first fill step, a hundred times it for any tick
     COMPUTE WS-BOUND-FILL-US = GQ-MS-HUNDREDTHS * 10000 * 10
     COMPUTE WS-BOUND-ALL-US = GQ-MS-HUNDREDTHS * 10000 * 100
     MOVE 0 TO WS-TICKS WS-MAX-US WS-FILL-MAX-US WS-FILL-TICKS
*>   the first generation: ticks until the second chunk of the view is installed (the first one is the queue's job from the first tick on)
     PERFORM WITH TEST AFTER UNTIL GQ-GENERATED >= 2 OR WS-TICKS > 20000
         MOVE 0 TO WS-STAGE-BEFORE
         IF GJ-ACTIVE = 1
             MOVE GJ-STAGE TO WS-STAGE-BEFORE
         END-IF
         CALL "COST-CLOCK" USING WS-T0
         CALL "CORE-TICK"
         CALL "COST-CLOCK" USING WS-T1
         ADD 1 TO WS-TICKS
         COMPUTE WS-US = WS-T1 - WS-T0
         IF WS-US > WS-MAX-US
             MOVE WS-US TO WS-MAX-US
         END-IF
*>       the tick in which a job passes from before the fill stage to the fill stage ran the first fill step (slab 0) of its chunk
         IF GJ-ACTIVE = 1 AND WS-STAGE-BEFORE < GJ-STAGE-FILL AND GJ-STAGE >= GJ-STAGE-FILL
             ADD 1 TO WS-FILL-TICKS
             IF WS-US > WS-FILL-MAX-US
                 MOVE WS-US TO WS-FILL-MAX-US
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-SECONDS = WS-FILL-MAX-US / 1000000
     COMPUTE WS-SECONDS-2 = WS-MAX-US / 1000000
     DISPLAY "FIRSTFILL ticks=" WS-TICKS " fill ticks=" WS-FILL-TICKS " slowest first-fill tick cpu=" WS-SECONDS " s slowest tick cpu=" WS-SECONDS-2 " s"
     MOVE "bug first fill tick the first fill step of each of the first two chunks was seen" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-FILL-TICKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bug first fill tick the tick of a first fill step takes at most ten times the budget of the queue in CPU time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FILL-MAX-US < WS-BOUND-FILL-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bug first fill tick no tick of the first generation takes a hundred times the budget of the queue in CPU time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAX-US < WS-BOUND-ALL-US
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the slice of the scan that a biome step runs ahead (STRUCT-BEARD-AHEAD) leaves the beardifier of the chunk being generated as it was: records and the active flag stay, the density memo stamp changes
*>   each way of the switch off for the heights of the starts
     MOVE 1 TO SBD-ACTIVE
     MOVE 3 TO SBD-RIGID-COUNT
     MOVE SBD-GEN TO WS-GEN-BEFORE
     MOVE 5 TO WS-STEP
     CALL "STRUCT-BEARD-AHEAD" USING WS-CX0 WS-CZ0 WS-STEP
     MOVE "bug first fill tick a slice of the scan done ahead leaves an active beardifier and its records as they were" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SBD-ACTIVE = 1 AND SBD-RIGID-COUNT = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bug first fill tick a slice of the scan done ahead changes the density memo stamp of the beardifier twice" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SBD-GEN - WS-GEN-BEFORE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   steps past the 72nd have no chunk of the window left
     MOVE SBD-GEN TO WS-GEN-BEFORE
     MOVE 73 TO WS-STEP
     CALL "STRUCT-BEARD-AHEAD" USING WS-CX0 WS-CZ0 WS-STEP
     MOVE "bug first fill tick a step past the window of 289 chunks does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SBD-GEN - WS-GEN-BEFORE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the last slice holds one chunk only (positions 288)
     MOVE 72 TO WS-STEP
     CALL "STRUCT-BEARD-AHEAD" USING WS-CX0 WS-CZ0 WS-STEP
     MOVE "bug first fill tick the last slice of the scan done ahead is one chunk and leaves the beardifier as it was" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SBD-ACTIVE = 1 AND SBD-RIGID-COUNT = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGFIRSTFILL-TICKS.

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
