*> The fluid post-processing of a generated chunk (docs/protocol/10 section 9 "mark the position for post-processing (a fluid tick scheduled later)", 36-1 6.5 placeBlock "schedule a
*> fluid tick for it with delay 0", 29a section 2.1 "chunk generation: aquifer or carver fluid cells flagged for post-processing"). The generators write cells only (the chunk window has no tick
*> queue), so a spring, a structure fountain, a cave waterfall or a lava well generated as a source stayed still until something next to it changed (operator, try15: the stronghold fountain
*> does not flow). CHUNK-FLUID-POST is run by WORLD-CHUNK-LOAD on a chunk the generator made, after the overflow of the neighbours was written into it: every water or lava cell that can
*> flow (the cell below, or a cell beside it, holds no fluid and has no collision) gets a scheduled fluid tick of delay 0, so the fluid tick of 29a section 3 runs on the next tick.
*> Approximations: the cells of the chunk are read only (a cell beside it in a neighbouring chunk is taken not to take fluid: that chunk's own cells decide when it is made), at most
*> FP-CAP cells per chunk are scheduled (BT-ADD is linear in the queue), and a chunk read from a region file gets the pending fluid ticks of its saved `fluid_ticks` list (CHUNK-TICKS-READ, chunk-ticks-read.cob), not these.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHUNK-FLUID-POST.
*> USING cache row (BINARY-LONG; its memory allocated and its cells filled), count out (BINARY-LONG): the number of fluid ticks scheduled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 78 FP-CAP                 VALUE 128.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-D                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     IF WS-WATER < 0 AND WS-LAVA < 0
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-CELLS = DM-HEIGHT(CK-DIM(L-ROW)) * 256
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS OR L-COUNT >= FP-CAP
         MOVE CB-S-BLOCK(CE-STATE(WS-I) + 1) TO WS-BLOCK
         MOVE 0 TO WS-FLUID
         IF WS-WATER >= 0 AND WS-BLOCK = WS-WATER
             MOVE 1 TO WS-FLUID
         END-IF
         IF WS-LAVA >= 0 AND WS-BLOCK = WS-LAVA
             MOVE 2 TO WS-FLUID
         END-IF
         IF WS-FLUID > 0
             COMPUTE WS-R = FUNCTION MOD(WS-I - 1, 256)
             COMPUTE WS-LY = (WS-I - 1 - WS-R) / 256
             COMPUTE WS-LZ = (WS-R - FUNCTION MOD(WS-R, 16)) / 16
             COMPUTE WS-LX = FUNCTION MOD(WS-R, 16)
             MOVE 0 TO WS-CAN
*>           Below (the cell index minus a layer), then the four sides when they are inside the chunk.
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
                 MOVE 1 TO WS-IN
                 EVALUATE WS-D
                     WHEN 1
                         MOVE -256 TO WS-STEP
                         IF WS-LY = 0
                             MOVE 0 TO WS-IN
                         END-IF
                     WHEN 2
                         MOVE -1 TO WS-STEP
                         IF WS-LX = 0
                             MOVE 0 TO WS-IN
                         END-IF
                     WHEN 3
                         MOVE 1 TO WS-STEP
                         IF WS-LX = 15
                             MOVE 0 TO WS-IN
                         END-IF
                     WHEN 4
                         MOVE -16 TO WS-STEP
                         IF WS-LZ = 0
                             MOVE 0 TO WS-IN
                         END-IF
                     WHEN OTHER
                         MOVE 16 TO WS-STEP
                         IF WS-LZ = 15
                             MOVE 0 TO WS-IN
                         END-IF
                 END-EVALUATE
                 IF WS-IN = 1
                     COMPUTE WS-J = WS-I + WS-STEP
                     MOVE CB-S-BLOCK(CE-STATE(WS-J) + 1) TO WS-NB
                     IF CB-SOLID(WS-NB + 1) = 0 AND WS-NB NOT = WS-WATER AND WS-NB NOT = WS-LAVA
                         MOVE 1 TO WS-CAN
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-CAN = 1
                 COMPUTE WS-X = CK-X(L-ROW) * 16 + WS-LX
                 COMPUTE WS-Z = CK-Z(L-ROW) * 16 + WS-LZ
                 COMPUTE WS-Y = DM-MIN-Y(CK-DIM(L-ROW)) + WS-LY
                 CALL "FLUID-SCHEDULE" USING CK-DIM(L-ROW) WS-X WS-Y WS-Z WS-FLUID WS-DELAY
                 ADD 1 TO L-COUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CHUNK-FLUID-POST.
