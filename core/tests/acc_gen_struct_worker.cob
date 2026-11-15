*> Acceptance test (docs/design/world-types.md structures part 3; 36-1 sections 7 and 8; docs/design/generation-worker.md): with the mineshaft gated on, a chunk that
*> a mineshaft start decorates is the same byte for byte whether it is made by the atomic path (GEN-JOB-RUN-ALL) or by a worker process (the queue), and
*> the mineshaft changes it. Fixture terrain data core/tests/fixtures/gen (a final density of two interpolated nodes), structure data core/tests/fixtures/struct-ms,
*> the stand-in standard content (content/tests/fixtures/std) for the block table. The chunk is the first of a 40 x 40 area whose stub chunk holds a start.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-STRUCT-WORKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CLIMATE.
 COPY STRUCTDATA.
 COPY GENQUEUE.
 COPY CELLS.
 01 WS-GEN-DIR             PIC X(1100) VALUE "core/tests/fixtures/gen".
 01 WS-STRUCT-DIR          PIC X(1100) VALUE "core/tests/fixtures/struct-ms".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FIRST-X             BINARY-LONG.
 01 WS-FIRST-Z             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-SLEEP               PIC 9(2)V9(2) VALUE 0.05.
 01 WS-REF                 PIC X(304640).
 01 WS-REF2                PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MESSAGE             PIC X(120).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "STRUCT-LOAD" USING WS-STRUCT-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-GEN-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-GEN-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "GEN-DATA-READY" USING WS-STATUS
     CALL "STRUCT-POSSIBLE-BUILD"
     CALL "STRUCT-GATE-RESET"
     MOVE "minecraft:mineshaft" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     CALL "GEN-QUEUE-RESET"
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-CX FROM -20 BY 1 UNTIL WS-CX > 19
         PERFORM VARYING WS-CZ FROM -20 BY 1 UNTIL WS-CZ > 19
             CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-CX WS-CZ WS-COUNT
             IF WS-COUNT > 0 AND WS-FOUND = 0
                 MOVE 1 TO WS-FOUND
                 MOVE WS-CX TO WS-FIRST-X
                 MOVE WS-CZ TO WS-FIRST-Z
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance gen struct worker given the mineshaft on when 40 x 40 chunks are scanned then a mineshaft start is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF

*>   the atomic chunk with the structure, and without it
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-FIRST-X WS-FIRST-Z WS-REF WS-REF-Y
     CALL "STRUCT-GATE-RESET"
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-FIRST-X WS-FIRST-Z WS-REF2 WS-REF-Y
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "acceptance gen struct worker given a chunk with a start when the mineshaft is on then the chunk differs from the chunk without it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REF NOT = WS-REF2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a worker makes the same chunk
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-FIRST-X WS-FIRST-Z
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         CALL "WORLD-FIND" USING WS-DIM WS-FIRST-X WS-FIRST-Z WS-ROW
     END-PERFORM
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
         IF WS-A = WS-REF
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     MOVE "acceptance gen struct worker given a chunk with a mineshaft start when a worker makes it then it equals the atomic chunk byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     STOP RUN.
 END PROGRAM ACC-GEN-STRUCT-WORKER.

 COPY CORETEST.
