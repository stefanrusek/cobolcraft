*> Live redstone wiring (docs/protocol/30-redstone-1-model-signal-and-wire.md sections 5 and 6): the block-update hooks of the redstone wire as part of BU-HOOK, built from the decision
*> programs of redstone-30-1.cob (RS1-). Scope of this wiring: the wire block and the redstone block (a signal source of 15 in every direction). The signal sources and conductors of the other
*> parts (torches, levers, repeaters, solid blocks passing a signal, wires on top of or below a neighbouring block) are not read by it yet.
*>
*> Entry points:
*>   REDSTONE-IDS-ENSURE                                     resolves RSLIVE.cpy from the open block table (once per CB-EPOCH)
*>   REDSTONE-HOOK USING kind, dimension row, x, y, z, state, a, b, out state     the BU-HOOK part (29 section 3 hook kinds): 1 onPlace of a wire evaluates it (5.5), tells UP and DOWN and
*>        the neighbouring wires; 2 removal of a wire tells its six neighbours (5.5); 3 neighborChanged of a wire evaluates it (5.5)
*>   REDSTONE-EVALUATE USING dimension row, x, y, z, state   updatePowerStrength (5.4): the target power, the resolved sides (5.2), the write with flags 2 and, when the power changed, the seven
*>        updateNeighborsAt calls in the order of 5.4 step 4

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-IDS-ENSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF RL-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO RL-EPOCH
     MOVE -1 TO RL-WIRE RL-SOURCE
     MOVE 0 TO RL-WIRE-FIRST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         EVALUATE CB-KEY(WS-I)
             WHEN "redstone_wire"
                 COMPUTE RL-WIRE = WS-I - 1
                 MOVE CB-FIRST-STATE(WS-I) TO RL-WIRE-FIRST
             WHEN "redstone_block"
                 COMPUTE RL-SOURCE = WS-I - 1
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM REDSTONE-IDS-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-EVALUATE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-NBLOCK              BINARY-LONG.
 01 LS-ID                  BINARY-LONG.
 01 LS-BLOCK-SIGNAL        BINARY-LONG.
 01 LS-INCOMING            BINARY-LONG.
 01 LS-TARGET              BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-POWER               BINARY-LONG.
 01 LS-CUR.
    05 LS-CN               BINARY-LONG.
    05 LS-CE               BINARY-LONG.
    05 LS-CS               BINARY-LONG.
    05 LS-CW               BINARY-LONG.
 01 LS-FRESH.
    05 LS-FN               BINARY-LONG.
    05 LS-FE               BINARY-LONG.
    05 LS-FS               BINARY-LONG.
    05 LS-FW               BINARY-LONG.
 01 LS-MERGED.
    05 LS-MN               BINARY-LONG.
    05 LS-ME               BINARY-LONG.
    05 LS-MS               BINARY-LONG.
    05 LS-MW               BINARY-LONG.
 01 LS-FINAL.
    05 LS-ON               BINARY-LONG.
    05 LS-OE               BINARY-LONG.
    05 LS-OS               BINARY-LONG.
    05 LS-OW               BINARY-LONG.
 01 LS-WAS-DOT             BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-SIDE                BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-CALLS.
    05 LS-CALL             BINARY-LONG OCCURS 7 TIMES.
 01 LS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     COMPUTE LS-ID = L-STATE - RL-WIRE-FIRST + 5567
     CALL "RS1-WIRE-DECODE" USING LS-ID LS-CN LS-CE LS-CS LS-CW LS-POWER
*>   getBlockSignal (5.4 step 1): the strongest neighbour signal with the wire itself silent, here the redstone blocks around it
     MOVE 0 TO LS-BLOCK-SIGNAL LS-R
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NY = L-Y + LS-DY
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-NX LS-NY LS-NZ LS-NSTATE
         MOVE CB-S-BLOCK(LS-NSTATE + 1) TO LS-NBLOCK
         IF LS-NBLOCK = RL-SOURCE
             MOVE 15 TO LS-BLOCK-SIGNAL
         END-IF
*>       the incoming wire signal (5.4 step 2, the horizontal neighbours that are wire)
         IF LS-D >= 2 AND LS-NBLOCK = RL-WIRE
             COMPUTE LS-ID = LS-NSTATE - RL-WIRE-FIRST + 5567
             CALL "RS1-WIRE-DECODE" USING LS-ID LS-FN LS-FE LS-FS LS-FW LS-NSTATE
             IF LS-NSTATE > LS-R
                 MOVE LS-NSTATE TO LS-R
             END-IF
         END-IF
*>       the sides (5.2): a wire or a signal source beside it connects (side), else none
         IF LS-D >= 2
             MOVE 2 TO LS-SIDE
             IF LS-NBLOCK = RL-WIRE OR LS-NBLOCK = RL-SOURCE
                 MOVE 1 TO LS-SIDE
             END-IF
             EVALUATE LS-D
                 WHEN 2
                     MOVE LS-SIDE TO LS-FN
                 WHEN 3
                     MOVE LS-SIDE TO LS-FS
                 WHEN 4
                     MOVE LS-SIDE TO LS-FW
                 WHEN OTHER
                     MOVE LS-SIDE TO LS-FE
             END-EVALUATE
         END-IF
     END-PERFORM
     COMPUTE LS-INCOMING = FUNCTION MAX(0, LS-R - 1)
     CALL "RS1-WIRE-TARGET" USING LS-BLOCK-SIGNAL LS-INCOMING LS-TARGET
     CALL "RS1-IS-DOT" USING LS-CN LS-CE LS-CS LS-CW LS-WAS-DOT
     CALL "RS1-MISSING-CONNECTIONS" USING LS-CN LS-CE LS-CS LS-CW LS-FN LS-FE LS-FS LS-FW LS-MN LS-ME LS-MS LS-MW
     CALL "RS1-CONNECTION-STATE" USING LS-WAS-DOT LS-MN LS-ME LS-MS LS-MW LS-ON LS-OE LS-OS LS-OW
     CALL "RS1-WIRE-STATE" USING LS-ON LS-OE LS-OS LS-OW LS-TARGET LS-NEW
     COMPUTE LS-NEW = LS-NEW - 5567 + RL-WIRE-FIRST
     IF LS-NEW = L-STATE
         GOBACK
     END-IF
*>   the write reaches the clients only (flags 2), then the seven neighbour updates when the power changed
     MOVE 2 TO LS-FLAGS
     MOVE 512 TO LS-BUDGET
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
     IF LS-TARGET NOT = LS-POWER
         CALL "RS1-WIRE-NOTIFY-ORDER" USING L-X L-Y L-Z LS-CALL(1) LS-CALL(2) LS-CALL(3) LS-CALL(4)
             LS-CALL(5) LS-CALL(6) LS-CALL(7)
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 7
             MOVE L-X TO LS-NX
             MOVE L-Y TO LS-NY
             MOVE L-Z TO LS-NZ
             IF LS-CALL(LS-I) >= 0
                 CALL "RS1-STEP" USING LS-CALL(LS-I) LS-DX LS-DY LS-DZ
                 ADD LS-DX TO LS-NX
                 ADD LS-DY TO LS-NY
                 ADD LS-DZ TO LS-NZ
             END-IF
             CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM REDSTONE-EVALUATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-OLD-BLOCK           BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     IF L-KIND NOT = 1 AND L-KIND NOT = 2 AND L-KIND NOT = 3
         GOBACK
     END-IF
     CALL "REDSTONE-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     IF RL-WIRE < 0 OR LS-BLOCK NOT = RL-WIRE
         GOBACK
     END-IF
     EVALUATE L-KIND
         WHEN 1
*>           onPlace (5.5): nothing when the old state is the same block
             MOVE CB-S-BLOCK(L-A + 1) TO LS-OLD-BLOCK
             IF LS-OLD-BLOCK = RL-WIRE
                 GOBACK
             END-IF
             CALL "REDSTONE-EVALUATE" USING L-DIM L-X L-Y L-Z L-STATE
             PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 1
                 CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
                 COMPUTE LS-NX = L-X + LS-DX
                 COMPUTE LS-NY = L-Y + LS-DY
                 COMPUTE LS-NZ = L-Z + LS-DZ
                 CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
             END-PERFORM
         WHEN 2
*>           affectNeighborsAfterRemoval (5.5): every neighbour is told (not for a piston move)
             IF L-B = 0
                 PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5
                     CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
                     COMPUTE LS-NX = L-X + LS-DX
                     COMPUTE LS-NY = L-Y + LS-DY
                     COMPUTE LS-NZ = L-Z + LS-DZ
                     CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
                 END-PERFORM
             END-IF
         WHEN OTHER
             CALL "REDSTONE-EVALUATE" USING L-DIM L-X L-Y L-Z L-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM REDSTONE-HOOK.
