*> Acceptance test of the asynchronous initial spawn search (docs/design/generation-worker.md; docs/protocol/33 section 6.2): with generation workers the
*> new world's open generates nothing and stores the provisional spawn; the search then runs in the ticks and ends on the same column as the synchronous
*> search, whatever the number of workers and the timing; a chunk done without a spawn moves the search on, and after the last chunk the provisional
*> spawn stays; a world without the workers keeps the synchronous search. On the fixture terrain data (core/tests/fixtures/gen).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-SPAWN-ASYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY DIMENSIONS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Y              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 01 WS-SPAWN-1             PIC X(40).
 01 WS-SPAWN-2             PIC X(40).
 01 WS-SPAWN-3             PIC X(40).
 01 WS-PROVISIONAL         PIC X(40).
 01 WS-SLEEP               PIC 9V99 VALUE 0.01.
 01 WS-CHUNKS-DONE         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

*>   with two workers on the standard terrain: the open generates nothing; the last two chunks of the search are searched at their last column
*>   (the fixture terrain has water over stone everywhere: no column ever qualifies, and the 121 chunks of 256 columns would take hours)
     PERFORM FRESH-WORLD
     MOVE 3 TO CW-DIM(1)
     MOVE 2 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     PERFORM SPAWN-TEXT
     MOVE WS-SPAWN-1 TO WS-PROVISIONAL
     MOVE "acceptance gen spawn given workers when a new standard world is opened then the search is pending and nothing is generated" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING CW-DIM(1) WS-CX WS-CZ WS-ROW
     COMPUTE TL-OBSERVED-N = GQ-SP-STATE * 100 + WS-ROW * 10 + GQ-COUNT
     MOVE 100 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 120 TO GQ-SP-CHUNK
     MOVE 256 TO GQ-SP-COLUMN
     MOVE 119 TO GQ-SP-DONE
     PERFORM RUN-SEARCH
     MOVE "acceptance gen spawn given workers when the last chunks are made by the workers and searched then the search ends on the provisional spawn" TO TL-CASE
     MOVE WS-PROVISIONAL TO TL-EXPECTED
     MOVE WS-SPAWN-1 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen spawn given workers when the search ends then no search is pending and 121 chunks are done" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = GQ-SP-STATE * 1000 + GQ-SP-DONE
     MOVE 121 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   the main dimension (a world with a spawn column in its first chunk): the same spawn with two workers, one worker and none (synchronous)
     PERFORM FRESH-WORLD
     MOVE 2 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     PERFORM RUN-SEARCH
     MOVE WS-SPAWN-1 TO WS-SPAWN-2
     DISPLAY "async spawn (2 workers) " WS-SPAWN-2 " ticks " WS-TICKS " chunks done " GQ-SP-DONE
     MOVE "acceptance gen spawn given two workers when the search runs then it ends with a spawn that is not the provisional one" TO TL-CASE
     MOVE "N" TO TL-MODE
     IF WS-SPAWN-2 NOT = WS-PROVISIONAL
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     PERFORM FRESH-WORLD
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     PERFORM RUN-SEARCH
     MOVE WS-SPAWN-1 TO WS-SPAWN-3
     MOVE "acceptance gen spawn given one worker when the search runs then it ends on the same spawn as with two workers" TO TL-CASE
     MOVE WS-SPAWN-2 TO TL-EXPECTED
     MOVE WS-SPAWN-3 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM FRESH-WORLD
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     PERFORM SPAWN-TEXT
     MOVE "acceptance gen spawn given no workers when a new standard world is opened then the search is synchronous and finds the same spawn" TO TL-CASE
     MOVE WS-SPAWN-2 TO TL-EXPECTED
     MOVE WS-SPAWN-1 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen spawn given no workers when the world is opened then no search is pending" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE GQ-SP-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   chunks done without a spawn move the search on; after the last chunk the provisional spawn stays
     PERFORM FRESH-VOID-WORLD
     CALL "GEN-SPAWN-BEGIN"
     PERFORM SPAWN-TEXT
     MOVE WS-SPAWN-1 TO WS-PROVISIONAL
*>   (scanning every column of a void chunk is slow: the search is started at the last column of each of the last two chunks)
     MOVE 120 TO GQ-SP-CHUNK
     MOVE 256 TO GQ-SP-COLUMN
     MOVE 119 TO GQ-SP-DONE
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL GQ-SP-STATE = 0 OR WS-TICKS > 3000
         IF GQ-SP-CHUNK = 121 AND GQ-SP-COLUMN < 256
             MOVE 256 TO GQ-SP-COLUMN
         END-IF
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
     END-PERFORM
     PERFORM SPAWN-TEXT
     MOVE "acceptance gen spawn given a world with no spawn column when the last chunks are searched then the search ends and the provisional spawn stays" TO TL-CASE
     MOVE WS-PROVISIONAL TO TL-EXPECTED
     MOVE WS-SPAWN-1 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen spawn given a world with no spawn column then all the chunks are counted done" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE GQ-SP-DONE TO TL-OBSERVED-N
     MOVE 121 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FRESH-WORLD.
     CALL "TEST-GEN-FIXTURE"
     MOVE "standard" TO CW-WORLD-TYPE.

 FRESH-VOID-WORLD.
     CALL "TEST-GEN-FIXTURE"
     CALL "WORLDGEN-FREE"
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE 3 TO CW-DIM(1).

 RUN-SEARCH.
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL GQ-SP-STATE = 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
         IF GQ-SP-STATE = 1
             CALL "C$SLEEP" USING WS-SLEEP
         END-IF
     END-PERFORM
     PERFORM SPAWN-TEXT.

 SPAWN-TEXT.
     COMPUTE WS-EDIT-X = CW-SPAWN-X * 10
     MOVE CW-SPAWN-Y TO WS-EDIT-Y
     COMPUTE WS-EDIT-Z = CW-SPAWN-Z * 10
     MOVE SPACES TO WS-SPAWN-1
     STRING FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z) DELIMITED BY SIZE INTO WS-SPAWN-1.
 END PROGRAM ACC-GEN-SPAWN-ASYNC.
 COPY CORETEST.
 COPY GENFIXTURE.
