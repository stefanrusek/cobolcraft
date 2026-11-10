*> The chunk generation queue (research R12; GENQUEUE.cpy): chunks that a player's view wants and
*> that are not loaded yet wait here, and CORE-TICK generates at most GQ-BUDGET of them per tick,
*> nearest to an alive player of the chunk's dimension first, so a slow generation never blocks the
*> 50 ms tick. It changes when a chunk exists, not what it holds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-RESET.
*> No parameters: empties the queue (WORLD-RESET, when a world is opened over another).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 PROCEDURE DIVISION.
     MOVE 0 TO GQ-COUNT
     MOVE 0 TO GQ-GENERATED
     GOBACK.
 END PROGRAM GEN-QUEUE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-WANT.
*> USING dim (DIMENSIONS.cpy row), chunk x, chunk z (BINARY-LONG): queues the chunk unless it is loaded,
*> already queued, or the queue is full (it is wanted again the next time a view asks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
         IF GQ-DIM(WS-I) = L-DIM AND GQ-X(WS-I) = L-CX AND GQ-Z(WS-I) = L-CZ
             GOBACK
         END-IF
     END-PERFORM
     IF GQ-COUNT >= GQ-CAPACITY
         GOBACK
     END-IF
     ADD 1 TO GQ-COUNT
     MOVE L-DIM TO GQ-DIM(GQ-COUNT)
     MOVE L-CX TO GQ-X(GQ-COUNT)
     MOVE L-CZ TO GQ-Z(GQ-COUNT)
     GOBACK.
 END PROGRAM GEN-QUEUE-WANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-RUN.
*> USING budget (BINARY-LONG), generated out (BINARY-LONG): generates up to budget queued chunks, each
*> time the one nearest to a player (squared distance in chunks to the nearest alive player of its
*> dimension; with no such player every chunk is equally far and the oldest goes first), and returns
*> how many it generated.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D              BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-BUDGET               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BUDGET L-DONE.
     MOVE 0 TO L-DONE
     PERFORM UNTIL L-DONE >= L-BUDGET OR GQ-COUNT = 0
         MOVE 1 TO WS-BEST
         MOVE 999999999999 TO WS-BEST-D
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GQ-COUNT
             MOVE 0 TO WS-D
             MOVE 999999999999 TO WS-D
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                 IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = GQ-DIM(WS-I)
                     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-P) / 16)
                     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-P) / 16)
                     COMPUTE WS-DX = GQ-X(WS-I) - WS-PX
                     COMPUTE WS-DZ = GQ-Z(WS-I) - WS-PZ
                     IF WS-DX * WS-DX + WS-DZ * WS-DZ < WS-D
                         COMPUTE WS-D = WS-DX * WS-DX + WS-DZ * WS-DZ
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-D < WS-BEST-D
                 MOVE WS-D TO WS-BEST-D
                 MOVE WS-I TO WS-BEST
             END-IF
         END-PERFORM
         MOVE GQ-DIM(WS-BEST) TO WS-DIM
         MOVE GQ-X(WS-BEST) TO WS-CX
         MOVE GQ-Z(WS-BEST) TO WS-CZ
         MOVE GQ-ENTRY(GQ-COUNT) TO GQ-ENTRY(WS-BEST)
         SUBTRACT 1 FROM GQ-COUNT
         CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
         ADD 1 TO L-DONE
         ADD 1 TO GQ-GENERATED
     END-PERFORM
     GOBACK.
 END PROGRAM GEN-QUEUE-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-QUEUE-TICK.
*> No parameters: the queue's share of one game tick (CORE-TICK): up to GQ-BUDGET chunks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENQUEUE.
 01 WS-BUDGET              BINARY-LONG VALUE GQ-BUDGET.
 01 WS-DONE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "GEN-QUEUE-RUN" USING WS-BUDGET WS-DONE
     GOBACK.
 END PROGRAM GEN-QUEUE-TICK.
