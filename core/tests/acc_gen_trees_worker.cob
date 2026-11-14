*> End to end test of trees through the worker path (docs/design/world-types.md "Chunk borders", core/src/gen-worker.cob, feat-tree.cob): the feature lists of
*> core/tests/fixtures/gen-trees (ten oaks a chunk by the tree feature of the data) are loaded beside the terrain fixture; chunk (2, 3) is made by the atomic reference and by
*> a forked worker. The worker's chunk equals the reference byte for byte, holds real trees (logs and leaves), and the overflow list the worker returns (the canopies and
*> roots that leave the chunk) is the list the reference published.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-TREES-WORKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY GENOVER.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATINDEX.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE 2.
 01 WS-CZ                  BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SLEEP               PIC 9V99 VALUE 0.01.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-FEAT-DIR            PIC X(1100) VALUE "core/tests/fixtures/gen-trees".
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOGS                BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REF-GO.
    05 WS-REF-HEAD         PIC X(8).
    05 WS-RE OCCURS 1024 TIMES.
       10 WS-RE-X          BINARY-LONG.
       10 WS-RE-Y          BINARY-LONG.
       10 WS-RE-Z          BINARY-LONG.
       10 WS-RE-STATE      BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-REF-COUNT           BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-GEN-FIXTURE"
*>   the blocks of the trees after the four of the fixture: dirt, oak_log, oak_leaves (28 states, distance 7 default), oak_sapling
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE 300 TO CB-STATE-COUNT
     MOVE 13 TO CB-EPOCH
     MOVE "minecraft:dirt" TO CB-KEY(5)
     MOVE "minecraft:oak_log" TO CB-KEY(6)
     MOVE "minecraft:oak_leaves" TO CB-KEY(7)
     MOVE "minecraft:oak_sapling" TO CB-KEY(8)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE 1 TO CB-SOLID(2) CB-SOLID(5) CB-SOLID(6) CB-SOLID(7)
     MOVE 1 TO CB-STATES(5)
     MOVE 200 TO CB-FIRST-STATE(5) CB-DEFAULT-STATE(5)
     MOVE 4 TO CB-S-BLOCK(201)
     MOVE 1 TO CB-STATES(6)
     MOVE 201 TO CB-FIRST-STATE(6) CB-DEFAULT-STATE(6)
     MOVE 5 TO CB-S-BLOCK(202)
     MOVE 28 TO CB-STATES(7)
     MOVE 203 TO CB-FIRST-STATE(7)
     MOVE 230 TO CB-DEFAULT-STATE(7)
     PERFORM VARYING WS-I FROM 204 BY 1 UNTIL WS-I > 231
         MOVE 6 TO CB-S-BLOCK(WS-I)
     END-PERFORM
     MOVE 1 TO CB-STATES(8)
     MOVE 232 TO CB-FIRST-STATE(8) CB-DEFAULT-STATE(8)
     MOVE 7 TO CB-S-BLOCK(233)
*>   the tags the tree reads (block ids are the row numbers minus one)
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 5 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 6 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     MOVE 7 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:supports_vegetation" TO WS-TAG
     MOVE 1 TO WS-ID(1)
     MOVE 4 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "BIOMES-LOAD" USING WS-FEAT-DIR WS-STATUS
     CALL "FD-SET-DIR" USING WS-FEAT-DIR
     CALL "GEN-QUEUE-RESET"
     INITIALIZE GEN-STAGES

*>   the atomic reference
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     MOVE GO-DATA TO WS-REF-GO
     MOVE GO-COUNT TO WS-REF-COUNT
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-REF
     MOVE 0 TO WS-LOGS WS-LEAVES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-STATE-CELLS
         IF CE-STATE(WS-I) > 0
             COMPUTE WS-BLOCK = CB-S-BLOCK(CE-STATE(WS-I) + 1)
             EVALUATE WS-BLOCK
                 WHEN 5
                     ADD 1 TO WS-LOGS
                 WHEN 6
                     ADD 1 TO WS-LEAVES
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE "acceptance gen trees worker: the reference chunk holds oak logs (real trees)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LOGS >= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen trees worker: the reference chunk holds oak leaves" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEAVES >= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the same chunk from a worker
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-CZ
     MOVE 0 TO WS-TICKS WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW = 0
             CALL "C$SLEEP" USING WS-SLEEP
         END-IF
     END-PERFORM
     MOVE "acceptance gen trees worker: the chunk arrives from the worker" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
     MOVE "acceptance gen trees worker: the worker's chunk with trees equals the reference byte for byte" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the worker's overflow went through WORLD-CHUNK-LOAD into the pending list (no neighbour is loaded): the same entries, in the same order
     MOVE "acceptance gen trees worker: the overflow the worker returned (the canopies leaving the chunk) is pending, as many entries as the reference published" TO TL-CASE
     MOVE GP-COUNT TO TL-OBSERVED-N
     MOVE WS-REF-COUNT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-REF-COUNT
         IF GP-X(WS-I) NOT = WS-RE-X(WS-I) OR GP-Y(WS-I) NOT = WS-RE-Y(WS-I) OR GP-Z(WS-I) NOT = WS-RE-Z(WS-I) OR GP-STATE(WS-I) NOT = WS-RE-STATE(WS-I)
             ADD 1 TO WS-SAME
         END-IF
     END-PERFORM
     MOVE "acceptance gen trees worker: every pending overflow entry equals the reference entry (x, y, z, state)" TO TL-CASE
     MOVE WS-SAME TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     STOP RUN.
 END PROGRAM ACC-GEN-TREES-WORKER.
 COPY CORETEST.
 COPY GENFIXTURE.
