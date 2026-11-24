*> Unit test, lane bugstall: a fluid tick at the edge of a loaded chunk never makes the neighbouring chunk in the tick (FLUID-TICK, core/src/fluids-world-29a.cob). Operator report: the frame
*> rate is 0 for the first minute after loading a world. The sample of the stall shows the core tick inside FLUID-SPREAD-TO > WORLD-SET-BLOCK > WORLD-CHUNK-LOAD > GEN-JOB-RUN-ALL: water at the border of
*> the loaded area read the unloaded neighbour as air (the read is void while the generation workers make the chunk), spread into it, and the write generated the whole chunk (seconds) in the 50 ms tick.
*> With the workers serving the standard chunks (GQ-WORKERS and GW-ACTIVE, the worker pool itself is not needed for the decision) the tick of a cell next to a chunk that is neither loaded nor
*> made yet queues that chunk and puts the cell's own tick back (FLUID-EDGE-DEFER, 10 ticks later); once the chunk is there the same tick spreads into it; a cell not at an edge, and a world
*> without workers, behave as before (the chunk is made where the write finds it missing).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLUID-DEFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 COPY GENQUEUE.
 COPY BLOCKTICK.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 3.
 01 WS-CZ                  BINARY-LONG VALUE 5.
 01 WS-NCX                 BINARY-LONG VALUE 4.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NROW                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-SET-STATE           BINARY-LONG.
 01 WS-FLUID               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS0              BINARY-LONG.
 01 WS-QUEUED              BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-STANDARD-TABLES"
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     COMPUTE WS-FY = DM-MIN-Y(WS-DIM) + 10
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELLS = DM-HEIGHT(WS-DIM) * 256
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE 0 TO CE-STATE(WS-I)
     END-PERFORM
*>   A stone floor over the whole chunk at y = floor, a water source on it at the east edge (local x 15, z 8) and another in the middle (local x 8, z 3).
     MOVE WS-STONE TO WS-SET-STATE
     MOVE WS-FY TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM PUT-CELL
         END-PERFORM
     END-PERFORM
*>   A hole in the floor beside the middle source (local x 9, z 3), where the water runs to.
     MOVE 0 TO WS-SET-STATE
     MOVE WS-FY TO WS-Y
     MOVE 9 TO WS-X
     MOVE 3 TO WS-Z
     PERFORM PUT-CELL
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     COMPUTE WS-Y = WS-FY + 1
     MOVE 15 TO WS-X
     MOVE 8 TO WS-Z
     PERFORM PUT-CELL
     MOVE 8 TO WS-X
     MOVE 3 TO WS-Z
     PERFORM PUT-CELL

*>   The workers serve the standard chunks (dimension row 3, DIM-GEN-STANDARD; the pool's decision, set the way a tick of the pool would).
     MOVE 1 TO GQ-WORKERS
     MOVE 1 TO GW-ACTIVE
     MOVE 0 TO GQ-COUNT
     MOVE BT-COUNT TO WS-TICKS0
     COMPUTE WS-X = WS-CX * 16 + 15
     COMPUTE WS-Z = WS-CZ * 16 + 8
     COMPUTE WS-Y = WS-FY + 1
     CALL "FLUID-TICK" USING WS-DIM WS-X WS-Y WS-Z WS-FLUID
     CALL "WORLD-FIND" USING WS-DIM WS-NCX WS-CZ WS-NROW
     MOVE "test fluid defer: water at the east edge does not make the unloaded neighbour chunk in the tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test fluid defer: the neighbour chunk is queued for the workers" TO TL-CASE
     MOVE 0 TO WS-QUEUED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
         IF GQ-DIM(WS-I) = WS-DIM AND GQ-X(WS-I) = WS-NCX AND GQ-Z(WS-I) = WS-CZ
             MOVE 1 TO WS-QUEUED
         END-IF
     END-PERFORM
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-QUEUED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test fluid defer: the cell's own fluid tick is put back" TO TL-CASE
     COMPUTE TL-OBSERVED-N = BT-COUNT - WS-TICKS0
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cell in the middle of the chunk spreads as before, nothing is put back.
     MOVE BT-COUNT TO WS-TICKS0
     COMPUTE WS-X = WS-CX * 16 + 8
     COMPUTE WS-Z = WS-CZ * 16 + 3
     CALL "FLUID-TICK" USING WS-DIM WS-X WS-Y WS-Z WS-FLUID
     COMPUTE WS-X = WS-CX * 16 + 9
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test fluid defer: water away from the edge spreads to its side" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The neighbour chunk has arrived: the same tick now spreads into it.
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-NCX WS-CZ WS-NROW
     COMPUTE WS-X = WS-CX * 16 + 15
     COMPUTE WS-Z = WS-CZ * 16 + 8
     CALL "FLUID-TICK" USING WS-DIM WS-X WS-Y WS-Z WS-FLUID
     COMPUTE WS-X = WS-NCX * 16
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test fluid defer: once the neighbour chunk is loaded the edge water spreads into it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Without workers nothing is deferred: the chunk is made where the write finds it missing (the chunk to the west of the water at local x 0).
     MOVE 0 TO GQ-WORKERS GW-ACTIVE
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     MOVE 0 TO WS-X
     MOVE 12 TO WS-Z
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM FIND-ROW
     PERFORM PUT-CELL
     COMPUTE WS-X = WS-CX * 16
     COMPUTE WS-Z = WS-CZ * 16 + 12
     CALL "FLUID-TICK" USING WS-DIM WS-X WS-Y WS-Z WS-FLUID
     COMPUTE WS-X = WS-CX - 1
     CALL "WORLD-FIND" USING WS-DIM WS-X WS-CZ WS-NROW
     MOVE "test fluid defer: without workers the edge water makes the neighbour chunk where it stands (as before)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-ROW.
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW).

 PUT-CELL.
     COMPUTE WS-W = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-SET-STATE TO CE-STATE(WS-W).

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-FLUID-DEFER.

 COPY NOSPAWN.
 COPY CORETEST.
