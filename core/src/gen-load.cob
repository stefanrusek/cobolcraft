*> The state a loading screen shows while a new world's spawn is searched and its spawn area made (docs/protocol/50 sections 2.5, 2.6, 4, 5; docs/design/generation-worker.md).
*> A CobolCraft chunk is made whole and a worker reports no stage, so of the ten chunk statuses of 50 section 2.6 a cell shows three: EMPTY (a chunk of the area that is
*> still to be made), TERRAIN (a chunk a worker is making) and FULL.
*> Status codes of a grid cell: 0 none (black), 1 EMPTY, 2 to 9 the statuses between, 10 FULL (the number of the status in 50 section 2.6, plus 1).
*>
*> Entry points:
*>   GEN-LOAD-PROGRESS USING state, ready, total, permille, focus chunk x, focus chunk z (BINARY-LONG): state 0 nothing is being prepared (any more), 1 the spawn is
*>     searched, 2 the spawn area is made. ready of total (GQ-SP-RING = 49) chunks of the area are loaded. permille is the progress of 50 section 4.2 in thousandths,
*>     floor((10 + ready) * 1000 / 59): 0 while the search runs, 1000 when the area is done. The focus is the origin chunk while the search runs, then the spawn chunk.
*>   GEN-LOAD-GRID USING grid (PIC X(1225)): the 35 x 35 cells (R = 17) around the focus chunk, row by row from the north (cell (i, j) at 35 * j + i + 1, chunk
*>     x focus + i - 17, chunk z focus + j - 17), each cell one byte holding code + 1 (FUNCTION ORD - 1 gives the code). Only the 11 x 11 chunks around the
*>     focus can be loaded or wanted here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-LOAD-PROGRESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-READY                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-PERMILLE             BINARY-LONG.
 01 L-FX                   BINARY-LONG.
 01 L-FZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-READY L-TOTAL L-PERMILLE L-FX L-FZ.
     MOVE GQ-SP-STATE TO L-STATE
     MOVE GQ-SP-RING TO L-TOTAL
     MOVE GQ-SP-READY TO L-READY
     MOVE GQ-SP-FX TO L-FX
     MOVE GQ-SP-FZ TO L-FZ
     EVALUATE GQ-SP-STATE
         WHEN 1
             MOVE 0 TO L-READY L-PERMILLE L-FX L-FZ
         WHEN 2
             COMPUTE L-PERMILLE = (10 + GQ-SP-READY) * 1000 / 59
         WHEN OTHER
             MOVE 1000 TO L-PERMILLE
     END-EVALUATE
     GOBACK.
 END PROGRAM GEN-LOAD-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-LOAD-GRID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-AHEAD               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-GRID                 PIC X(1225).
 PROCEDURE DIVISION USING L-GRID.
     MOVE LOW-VALUES TO L-GRID
     MOVE CW-DIM(1) TO WS-DIM
     MOVE 0 TO WS-FX WS-FZ
     IF GQ-SP-STATE NOT = 1
         MOVE GQ-SP-FX TO WS-FX
         MOVE GQ-SP-FZ TO WS-FZ
     END-IF
*>   chunks still to be made: the spiral chunks being looked at while the spawn is searched, the 7 x 7 square of the spawn area after it
     IF GQ-SP-STATE = 1
         MOVE FUNCTION MAX(GQ-WORKERS, 1) TO WS-AHEAD
         COMPUTE WS-LAST = GQ-SP-CHUNK + WS-AHEAD - 1
         PERFORM VARYING WS-K FROM GQ-SP-CHUNK BY 1 UNTIL WS-K > WS-LAST
             CALL "WP-SPIRAL" USING WS-K WS-DX WS-DZ
             COMPUTE WS-CELL = (WS-DZ + 17) * 35 + WS-DX + 17 + 1
             MOVE FUNCTION CHAR(2) TO L-GRID(WS-CELL:1)
         END-PERFORM
     ELSE
         PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
             PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
                 COMPUTE WS-CELL = (WS-DZ + 17) * 35 + WS-DX + 17 + 1
                 MOVE FUNCTION CHAR(2) TO L-GRID(WS-CELL:1)
             END-PERFORM
         END-PERFORM
     END-IF
*>   chunks a generation worker is making: the chunk is somewhere in the pipeline, shown as TERRAIN (code 5; the worker reports no stage)
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > GW-MAX
         COMPUTE WS-DX = GW-CX(WS-W) - WS-FX
         COMPUTE WS-DZ = GW-CZ(WS-W) - WS-FZ
         IF GW-BUSY(WS-W) NOT = 0 AND GW-DIM(WS-W) = WS-DIM AND WS-DX >= -5 AND WS-DX <= 5 AND WS-DZ >= -5 AND WS-DZ <= 5
             COMPUTE WS-CELL = (WS-DZ + 17) * 35 + WS-DX + 17 + 1
             MOVE FUNCTION CHAR(6) TO L-GRID(WS-CELL:1)
         END-IF
     END-PERFORM
*>   chunks that are loaded
     PERFORM VARYING WS-DZ FROM -5 BY 1 UNTIL WS-DZ > 5
         PERFORM VARYING WS-DX FROM -5 BY 1 UNTIL WS-DX > 5
             COMPUTE WS-CX = WS-FX + WS-DX
             COMPUTE WS-CZ = WS-FZ + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 COMPUTE WS-CELL = (WS-DZ + 17) * 35 + WS-DX + 17 + 1
                 MOVE FUNCTION CHAR(11) TO L-GRID(WS-CELL:1)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-LOAD-GRID.
