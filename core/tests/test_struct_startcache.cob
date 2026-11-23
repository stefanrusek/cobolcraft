*> The assembled start of a jigsaw structure is kept between chunk jobs (real data, world seed 3, skipped as a pass without the generated packs). The trial chambers (272 pieces, 542 junctions: the
*> jigsaw assembly takes seconds) is switched on alone; its first start in a 300 x 300 chunk area is found by STRUCT-CHUNK-STARTS and checked to span several chunks. The caches that hold an assembled
*> start are the jigsaw memo of JIG-FIND-POINT (12 slots, struct-jig.cob), the start list cache of STRUCT-CHUNK-STARTS and the store of captured starts (STRUCT-START-CAPTURE): a second STRUCT-FIND-POINT of
*> the same start is answered from the memo, a chunk job of a warm process costs less than one of a cold process, and the chunk is the same bytes either way: made atomically with every cache emptied (a new
*> epoch, JIG-RESET, STRUCT-TPL-RESET) and with them warm, and made by a worker process forked with the caches empty, whose second chunk comes from the worker's own warm caches. The PROBE lines show the
*> measured times (the first and the second assembly, a cold start chunk and a warm one, the start's neighbour).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-STARTCACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY GENQUEUE.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-SEEDENV             PIC X(20) VALUE SPACES.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "minecraft:trial_chambers".
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STRUCT-ROW          BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FV                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-GV                  BINARY-LONG.
 01 WS-LO-X                BINARY-LONG.
 01 WS-HI-X                BINARY-LONG.
 01 WS-LO-Z                BINARY-LONG.
 01 WS-HI-Z                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-PIECES              BINARY-LONG.
 01 WS-JUNCTIONS           BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-SLEEP               PIC 9(2)V9(2) VALUE 0.05.
 01 WS-REF-A-COLD          PIC X(304640).
 01 WS-REF-A-WARM          PIC X(304640).
 01 WS-REF-N-WARM          PIC X(304640).
 01 WS-REF-N-COLD          PIC X(304640).
 01 WS-MARKER              BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAME                BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-FIND-MS             BINARY-LONG.
 01 WS-FIND2-MS            BINARY-LONG.
 01 WS-A-COLD-MS           BINARY-LONG.
 01 WS-A-WARM-MS           BINARY-LONG.
 01 WS-N-WARM-MS           BINARY-LONG.
 01 WS-N-COLD-MS           BINARY-LONG.
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
 01 WS-EDIT3               PIC -(7)9.
 01 WS-EDIT4               PIC -(7)9.
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
         MOVE "test struct startcache no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "3" TO CS-SEED-TEXT
     ACCEPT WS-SEEDENV FROM ENVIRONMENT "CC_TEST_SEED"
     IF WS-SEEDENV NOT = SPACES
         MOVE WS-SEEDENV TO CS-SEED-TEXT
     END-IF
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE 0 TO WS-STRUCT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT-ROW
         END-IF
     END-PERFORM
     PERFORM FIND-START
     IF WS-FOUND = 1
         PERFORM START-CHECKS
         PERFORM CHUNK-CHECKS
         PERFORM WORKER-CHECKS
     END-IF
     STOP RUN.

*> the first chunk of a 300 x 300 chunk area that holds a start of the structure (the same scan as test_struct_gate4_real)
 FIND-START.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-SX FROM -150 BY 1 UNTIL WS-SX > 149 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -150 BY 1 UNTIL WS-SZ > 149 OR WS-FOUND = 1
             CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-SX WS-SZ WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 IF SC-STRUCT(WS-I) = WS-STRUCT-ROW AND WS-FOUND = 0
                     MOVE 1 TO WS-FOUND
                     MOVE WS-SX TO WS-CX
                     MOVE WS-SZ TO WS-CZ
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-CX TO WS-EDIT3
     MOVE WS-CZ TO WS-EDIT4
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) ": first start in the area at chunk (" FUNCTION TRIM(WS-EDIT3) "," FUNCTION TRIM(WS-EDIT4) ") found = " WS-FOUND
     MOVE "test struct startcache given the trial chambers alone when 300 x 300 chunks are scanned then a start is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the start spans several chunks, and the second assembly of it is the memo's (same stub, same pieces, no assembly time)
 START-CHECKS.
     PERFORM EMPTY-CACHES
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT-ROW CW-SEED WS-CX WS-CZ WS-FX WS-FY WS-FZ WS-FV
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-FIND-MS = WS-T0 - WS-T1
     MOVE SP-COUNT TO WS-PIECES
     MOVE JJ-COUNT TO WS-JUNCTIONS
     MOVE 1000000 TO WS-LO-X WS-LO-Z
     MOVE -1000000 TO WS-HI-X WS-HI-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         COMPUTE WS-V = FUNCTION INTEGER(SP-X0(WS-I) / 16)
         MOVE FUNCTION MIN(WS-LO-X, WS-V) TO WS-LO-X
         COMPUTE WS-V = FUNCTION INTEGER(SP-X1(WS-I) / 16)
         MOVE FUNCTION MAX(WS-HI-X, WS-V) TO WS-HI-X
         COMPUTE WS-V = FUNCTION INTEGER(SP-Z0(WS-I) / 16)
         MOVE FUNCTION MIN(WS-LO-Z, WS-V) TO WS-LO-Z
         COMPUTE WS-V = FUNCTION INTEGER(SP-Z1(WS-I) / 16)
         MOVE FUNCTION MAX(WS-HI-Z, WS-V) TO WS-HI-Z
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT-ROW CW-SEED WS-CX WS-CZ WS-GX WS-GY WS-GZ WS-GV
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-FIND2-MS = WS-T0 - WS-T1
     MOVE WS-FIND-MS TO WS-EDIT
     MOVE WS-FIND2-MS TO WS-EDIT2
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) " start " WS-PIECES " pieces " WS-JUNCTIONS " junctions: first assembly " FUNCTION TRIM(WS-EDIT) " ms, second " FUNCTION TRIM(WS-EDIT2) " ms"
     MOVE "test struct startcache given the start when its pieces are assembled then it has more than 100 pieces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FV = 1 AND WS-PIECES > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given the start when its pieces are assembled then the pieces span at least 3 chunks in x and in z" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HI-X - WS-LO-X >= 2 AND WS-HI-Z - WS-LO-Z >= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given an assembled start when it is asked again then the memo answers with the same stub and pieces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GV = 1 AND WS-GX = WS-FX AND WS-GY = WS-FY AND WS-GZ = WS-FZ AND SP-COUNT = WS-PIECES AND JJ-COUNT = WS-JUNCTIONS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given an assembled start when it is asked again then it takes under a tenth of the first assembly" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIND2-MS * 10 < WS-FIND-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the start chunk and its east neighbour: every cache empty, then warm; the bytes are the same
 CHUNK-CHECKS.
     COMPUTE WS-NX = WS-CX + 1
     PERFORM EMPTY-CACHES
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF-A-COLD WS-MARKER
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-A-COLD-MS = WS-T0 - WS-T1
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF-A-WARM WS-MARKER
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-A-WARM-MS = WS-T0 - WS-T1
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-NX WS-CZ WS-REF-N-WARM WS-MARKER
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-N-WARM-MS = WS-T0 - WS-T1
     PERFORM EMPTY-CACHES
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-NX WS-CZ WS-REF-N-COLD WS-MARKER
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-N-COLD-MS = WS-T0 - WS-T1
     MOVE WS-A-COLD-MS TO WS-EDIT
     MOVE WS-A-WARM-MS TO WS-EDIT2
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) " start chunk: " FUNCTION TRIM(WS-EDIT) " ms with every cache empty, " FUNCTION TRIM(WS-EDIT2) " ms warm"
     MOVE WS-N-COLD-MS TO WS-EDIT
     MOVE WS-N-WARM-MS TO WS-EDIT2
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) " east neighbour: " FUNCTION TRIM(WS-EDIT) " ms with every cache empty, " FUNCTION TRIM(WS-EDIT2) " ms warm"
     MOVE "test struct startcache given the start chunk when it is made twice atomically then the warm chunk is byte equal to the cold one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF-A-WARM = WS-REF-A-COLD
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given the start chunk when it is made warm then it takes less than 2 thirds of the cold time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A-WARM-MS * 3 < WS-A-COLD-MS * 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given the neighbour chunk when it is made with the caches warm and with them empty then the bytes are the same" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF-N-WARM = WS-REF-N-COLD
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct startcache given the neighbour chunk when it is made then it differs from the start chunk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF-N-COLD NOT = WS-REF-A-COLD
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> a worker forked with every cache empty makes the start chunk (cold) and then the neighbour (from its warm caches): both equal the atomic bytes
 WORKER-CHECKS.
     PERFORM EMPTY-CACHES
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     MOVE WS-CX TO WS-QX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-QX WS-CZ
     PERFORM WAIT-WORKER
     MOVE 0 TO WS-SAME
     IF WS-ROW > 0
         SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
         IF WS-A = WS-REF-A-COLD
             MOVE 1 TO WS-SAME
         END-IF
     END-IF
     MOVE "test struct startcache given a worker with empty caches when it makes the start chunk then it equals the atomic chunk byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-NX TO WS-QX
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-QX WS-CZ
     PERFORM WAIT-WORKER
     MOVE 0 TO WS-SAME
     IF WS-ROW > 0
         SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
         IF WS-A = WS-REF-N-COLD
             MOVE 1 TO WS-SAME
         END-IF
     END-IF
     MOVE "test struct startcache given the same worker when it makes the neighbour chunk then it equals the atomic chunk byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS.

*> ticks the queue until the chunk (WS-QX, WS-CZ) is in the world: WS-ROW is its row (0 after 12000 ticks)
 WAIT-WORKER.
     MOVE 0 TO WS-ROW
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 12000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         CALL "WORLD-FIND" USING WS-DIM WS-QX WS-CZ WS-ROW
     END-PERFORM.

*> every cache that holds an assembled start or the list of a chunk's starts: a new epoch (the start list cache and the store of captured starts), the jigsaw memo and the template tables
 EMPTY-CACHES.
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-GATE-ON" USING WS-KEY
     CALL "JIG-RESET"
     CALL "STRUCT-TPL-RESET".

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-STARTCACHE.

 COPY NOSPAWN.
 COPY CORETEST.
