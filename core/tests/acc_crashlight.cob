*> Acceptance test, lane crashlight (operator crash: a creeper exploded and the game died inside WG-FIND, reached through the light
*> spreading of a block change: EXPLODE-RUN, BLOCK-CHANGE, LEVEL-SET-BLOCK, LIGHT-SET-BLOCK, LIGHT-SPREAD, WORLD-CHUNK-PEEK,
*> GEN-QUEUE-SLICED, GEN-DATA-READY, WG-FIND). A standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default
*> /tmp/cc-test/generated; skipped as a pass without it) is loaded around Alice; blocks change and explosions happen at the border of the
*> loaded area. No chunk may be queued or loaded by that (the light stops at the border), and nothing may crash.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-CRASHLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MAX-CX              BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-LOADED-AFTER        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 4.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NO-SOURCE           BINARY-LONG VALUE 0.
 01 WS-WORKERS             BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-T0                  PIC X(21).
 01 WS-T1                  PIC X(21).
 01 WS-SECONDS             BINARY-LONG.
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance crashlight no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Crashlight" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
*>   Two generation workers, as the client runs: a read in a chunk that is not loaded queues it and is void, nothing is made inline.
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS

*>   The loaded area: the highest chunk x loaded in the row of chunk z 0.
     MOVE -99 TO WS-MAX-CX
     PERFORM VARYING WS-CX FROM -12 BY 1 UNTIL WS-CX > 12
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-FOUND
         IF WS-FOUND > 0
             MOVE WS-CX TO WS-MAX-CX
         END-IF
     END-PERFORM
     PERFORM COUNT-LOADED
     MOVE WS-LOADED TO WS-LOADED-AFTER

*>   A lit field: 16 x 16 glowstone (256 sources) in the border chunk, then one block change beside it.
     COMPUTE WS-BX = WS-MAX-CX * 16 + 15
     MOVE 70 TO WS-BY
     MOVE 8 TO WS-BZ
     MOVE "glowstone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 15
             COMPUTE WS-X = WS-MAX-CX * 16 + WS-I
             COMPUTE WS-Z = WS-J
             COMPUTE WS-Y = 80
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     PERFORM ELAPSED
     MOVE "acceptance crashlight 256 light sources placed in a row take seconds, not minutes (a block change relights its window only)"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SECONDS < 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM COUNT-LOADED
     MOVE "acceptance crashlight a block change at the border of the loaded area loads no chunk" TO TL-CASE
     MOVE WS-LOADED-AFTER TO TL-EXPECTED-N
     MOVE WS-LOADED TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE WS-BX TO WS-EX
     MOVE 80 TO WS-EY
     MOVE WS-BZ TO WS-EZ
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     CALL "EXPLODE-RUN" USING WS-DIM WS-EX WS-EY WS-EZ WS-POWER WS-DESTROY WS-NO-SOURCE
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     PERFORM ELAPSED
     MOVE "acceptance crashlight an explosion in a field of light sources takes seconds, not minutes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SECONDS < 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-LOADED
     MOVE "acceptance crashlight an explosion at the border of the loaded area survives and loads no chunk" TO TL-CASE
     MOVE WS-LOADED-AFTER TO TL-EXPECTED-N
     MOVE WS-LOADED TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "GEN-WORKERS-STOP"
     STOP RUN.

 ELAPSED.
*>   Seconds from WS-T0 to WS-T1 (CURRENT-DATE: minutes at 11, seconds at 13), modulo the hour.
     COMPUTE WS-SECONDS = FUNCTION MOD((FUNCTION NUMVAL(WS-T1(11:2)) * 60 + FUNCTION NUMVAL(WS-T1(13:2)))
         - (FUNCTION NUMVAL(WS-T0(11:2)) * 60 + FUNCTION NUMVAL(WS-T0(13:2))) + 3600, 3600).

 COUNT-LOADED.
     MOVE 0 TO WS-LOADED
     PERFORM VARYING WS-CX FROM -12 BY 1 UNTIL WS-CX > 12
         PERFORM VARYING WS-CZ FROM -12 BY 1 UNTIL WS-CZ > 12
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-FOUND
             IF WS-FOUND > 0
                 ADD 1 TO WS-LOADED
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-CZ.
 END PROGRAM ACC-CRASHLIGHT.

 COPY CORETEST.
