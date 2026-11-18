*> Live redstone, the tripwire and its hooks (docs/protocol/30-redstone-8 section 7): the hook calculation of 7.3 (the scan along the facing, the attached and powered flags, the writes to
*> both hooks and the wires between them), the wire's entity detection and its 10 tick re-check (7.5), `updateSource` from a wire, the removal handlers (7.5 and 7.7), the wire's four sides (7.1).
*> Deviations: no click, attach or detach sound and no block_activate, block_deactivate, block_attach or block_detach game event goes out (RS3-HOOK-EMIT decides them; nothing is sent); the
*> wire's `disarmed` state is read but only the shears path of the player (7.5 last item) is not wired (no call site for a player breaking with shears reaches the wire); the hook's placement
*> orientation from the placer's look (7.1) is the placement code's, not this file's.
*> Entry points:
*>   RL-HOOK-CALC USING dimension row, x, y, z of a hook, the hook's state, removing, notify, changed cell c (-1 none), the state assumed in that cell (0 none)    TripWireHookBlock.calculateState
*>   RL-HOOK-HOOK USING kind, dimension row, x, y, z, state, a, b    kinds 1 onPlace, 2 removal and 7 tick of a tripwire hook
*>   RL-TRIP-HOOK USING kind, dimension row, x, y, z, state, a, b, out state    kinds 1, 2, 4 and 7 of a tripwire wire
*>   RL-TRIP-ENTITY USING dimension row, x, y, z, state    entityInside of a wire (REDSTONE-ENTITY-TICK)
*>   RL-WIRE-SIDES USING dimension row, x, y, z, state, state out    the four sides of a wire placed at the position (7.1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOOK-NOTIFY RECURSIVE.
*> USING dimension row, x, y, z, facing, block: notifyNeighbors (7.6): the neighbours of the position, then those of the support block at pos - facing.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-SECOND              BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-SX                  BINARY-LONG.
 01 LS-SY                  BINARY-LONG.
 01 LS-SZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-BLOCK.
     CALL "RS3-NOTIFY-SECOND" USING L-FACING LS-SECOND
     CALL "RS1-STEP" USING LS-SECOND LS-DX LS-DY LS-DZ
     COMPUTE LS-SX = L-X + LS-DX
     COMPUTE LS-SY = L-Y + LS-DY
     COMPUTE LS-SZ = L-Z + LS-DZ
     CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z L-BLOCK
     CALL "BU-NEIGHBORS-AT" USING L-DIM LS-SX LS-SY LS-SZ L-BLOCK
     GOBACK.
 END PROGRAM RL-HOOK-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOOK-CALC RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-ATTACHED            PIC X(16) VALUE "attached".
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-DISARMED            PIC X(16) VALUE "disarmed".
 LOCAL-STORAGE SECTION.
 01 LS-HBLOCK              BINARY-LONG.
 01 LS-F                   BINARY-LONG.
 01 LS-OPPF                BINARY-LONG.
 01 LS-VALID               BINARY-LONG.
 01 LS-WAS-A               BINARY-LONG.
 01 LS-WAS-P               BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-S                   BINARY-LONG.
 01 LS-USE                 BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 01 LS-STOP                BINARY-LONG.
 01 LS-KDG.
    05 LS-KD               BINARY-LONG OCCURS 64 TIMES.
 01 LS-DSG.
    05 LS-DS               BINARY-LONG OCCURS 64 TIMES.
 01 LS-PWG.
    05 LS-PW               BINARY-LONG OCCURS 64 TIMES.
 01 LS-STG.
    05 LS-ST               BINARY-LONG OCCURS 64 TIMES.
 01 LS-WDIS                BINARY-LONG.
 01 LS-WPOW                BINARY-LONG.
 01 LS-RAN                 BINARY-LONG.
 01 LS-ATT                 BINARY-LONG.
 01 LS-POW                 BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-SCHEDULE            BINARY-LONG.
 01 LS-WRITE-FAR           BINARY-LONG.
 01 LS-NOTIFY-FAR          BINARY-LONG.
 01 LS-WRITE-NEAR          BINARY-LONG.
 01 LS-NOTIFY-NEAR         BINARY-LONG.
 01 LS-CELLS               BINARY-LONG.
 01 LS-QX                  BINARY-LONG.
 01 LS-QZ                  BINARY-LONG.
 01 LS-FSTATE              BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-FBLOCK              BINARY-LONG.
 01 LS-NOW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-DELAY               BINARY-LONG VALUE 10.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HSTATE               BINARY-LONG.
 01 L-REMOVING             BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-WSTATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HSTATE L-REMOVING L-NOTIFY L-C L-WSTATE.
     MOVE CB-S-BLOCK(L-HSTATE + 1) TO LS-HBLOCK
     MOVE RL-S-DIR(L-HSTATE + 1) TO LS-F
     MOVE 0 TO LS-VALID
     IF RL-CLASS(LS-HBLOCK + 1) = 24 AND LS-F >= 2
         MOVE 1 TO LS-VALID
     END-IF
     IF LS-VALID = 0
         GOBACK
     END-IF
     CALL "RL-GET-BOOL" USING L-HSTATE WS-ATTACHED LS-WAS-A
     CALL "RL-GET-BOOL" USING L-HSTATE WS-POWERED LS-WAS-P
     CALL "RS1-OPP" USING LS-F LS-OPPF
     CALL "RS1-STEP" USING LS-F LS-DX LS-DY LS-DZ
*>   the scan (7.3): the cells k = 1 to 41 along the facing; the first hook ends it
     MOVE 0 TO LS-STOP LS-WDIS LS-WPOW
     PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 64
         MOVE 0 TO LS-KD(LS-K) LS-DS(LS-K) LS-PW(LS-K) LS-ST(LS-K)
     END-PERFORM
     IF L-WSTATE > 0
         CALL "RL-GET-BOOL" USING L-WSTATE WS-DISARMED LS-WDIS
         CALL "RL-GET-BOOL" USING L-WSTATE WS-POWERED LS-WPOW
     END-IF
     PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 41 OR LS-STOP = 1
         COMPUTE LS-CX = L-X + LS-DX * LS-K
         COMPUTE LS-CZ = L-Z + LS-DZ * LS-K
         CALL "RL-LOOK" USING L-DIM LS-CX L-Y LS-CZ LS-S LS-CLASS LS-COND
         IF LS-CLASS = 24
             MOVE 3 TO LS-KD(LS-K)
             IF RL-S-DIR(LS-S + 1) = LS-OPPF
                 MOVE 2 TO LS-KD(LS-K)
             END-IF
             MOVE 1 TO LS-STOP
         ELSE
             IF LS-CLASS = 25 OR LS-K = L-C
                 MOVE LS-S TO LS-USE
                 IF LS-K = L-C AND L-WSTATE > 0
                     MOVE L-WSTATE TO LS-USE
                 END-IF
                 MOVE 1 TO LS-KD(LS-K)
                 MOVE LS-USE TO LS-ST(LS-K)
                 CALL "RL-GET-BOOL" USING LS-USE WS-DISARMED LS-DS(LS-K)
                 CALL "RL-GET-BOOL" USING LS-USE WS-POWERED LS-PW(LS-K)
             END-IF
         END-IF
     END-PERFORM
     CALL "RS3-HOOK-CALC" USING LS-VALID L-REMOVING L-C LS-WDIS LS-WPOW LS-WAS-A LS-WAS-P LS-KDG LS-DSG LS-PWG LS-RAN LS-ATT LS-POW LS-D
         LS-SCHEDULE
     IF LS-RAN = 0
         GOBACK
     END-IF
     IF LS-SCHEDULE = 1
         CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-HBLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
     END-IF
     CALL "RS3-HOOK-WRITES" USING LS-D L-REMOVING L-NOTIFY LS-ATT LS-WAS-A LS-WRITE-FAR LS-NOTIFY-FAR LS-WRITE-NEAR LS-NOTIFY-NEAR LS-CELLS
*>   the state of a hook with the new attached and powered
     CALL "RL-SET-BOOL" USING L-HSTATE WS-ATTACHED LS-ATT LS-A
     CALL "RL-SET-BOOL" USING LS-A WS-POWERED LS-POW LS-NSTATE
     IF LS-WRITE-FAR = 1
         COMPUTE LS-QX = L-X + LS-DX * LS-D
         COMPUTE LS-QZ = L-Z + LS-DZ * LS-D
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-QX L-Y LS-QZ LS-FSTATE
         CALL "RL-SET-BOOL" USING LS-FSTATE WS-ATTACHED LS-ATT LS-A
         CALL "RL-SET-BOOL" USING LS-A WS-POWERED LS-POW LS-B
         CALL "LEVEL-SET-BLOCK" USING L-DIM LS-QX L-Y LS-QZ LS-B LS-FLAGS LS-BUDGET LS-RESULT
         MOVE CB-S-BLOCK(LS-FSTATE + 1) TO LS-FBLOCK
         IF LS-NOTIFY-FAR = 1
             CALL "RL-HOOK-NOTIFY" USING L-DIM LS-QX L-Y LS-QZ LS-OPPF LS-FBLOCK
         END-IF
*>       the far hook's updates may have removed this one (7.3 writes step 1)
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NOW
         IF RL-CLASS(CB-S-BLOCK(LS-NOW + 1) + 1) NOT = 24
             CALL "RL-HOOK-REMOVE" USING L-DIM L-X L-Y L-Z LS-NSTATE
             GOBACK
         END-IF
     END-IF
     IF LS-WRITE-NEAR = 1
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NSTATE LS-FLAGS LS-BUDGET LS-RESULT
         IF LS-NOTIFY-NEAR = 1
             CALL "RL-HOOK-NOTIFY" USING L-DIM L-X L-Y L-Z LS-F LS-HBLOCK
         END-IF
     END-IF
*>   the wires between the hooks follow the attached flag (7.3 writes step 4)
     IF LS-CELLS > 0
         PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K >= LS-D
             IF LS-KD(LS-K) = 1
                 COMPUTE LS-CX = L-X + LS-DX * LS-K
                 COMPUTE LS-CZ = L-Z + LS-DZ * LS-K
                 CALL "RL-LOOK" USING L-DIM LS-CX L-Y LS-CZ LS-NOW LS-CLASS LS-COND
                 IF LS-CLASS = 24 OR LS-CLASS = 25
                     CALL "RL-SET-BOOL" USING LS-ST(LS-K) WS-ATTACHED LS-ATT LS-A
                     CALL "LEVEL-SET-BLOCK" USING L-DIM LS-CX L-Y LS-CZ LS-A LS-FLAGS LS-BUDGET LS-RESULT
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM RL-HOOK-CALC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOOK-REMOVE RECURSIVE.
*> USING dimension row, x, y, z, the removed state: the removal handler (7.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-ATTACHED            PIC X(16) VALUE "attached".
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-A                   BINARY-LONG.
 01 LS-P                   BINARY-LONG.
 01 LS-CALC                BINARY-LONG.
 01 LS-NOTIFY              BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-NONE                BINARY-LONG VALUE -1.
 01 LS-NOSTATE             BINARY-LONG VALUE 0.
 01 LS-FACING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     CALL "RL-GET-BOOL" USING L-STATE WS-ATTACHED LS-A
     CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-P
     CALL "RS3-HOOK-REMOVAL" USING LS-A LS-P LS-CALC LS-NOTIFY
     IF LS-CALC = 1
         CALL "RL-HOOK-CALC" USING L-DIM L-X L-Y L-Z L-STATE LS-ONE LS-ZERO LS-NONE LS-NOSTATE
     END-IF
     IF LS-NOTIFY = 1
         MOVE RL-S-DIR(L-STATE + 1) TO LS-FACING
         CALL "RL-HOOK-NOTIFY" USING L-DIM L-X L-Y L-Z LS-FACING LS-BLOCK
     END-IF
     GOBACK.
 END PROGRAM RL-HOOK-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOOK-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-SAME                BINARY-LONG.
 01 LS-REMOVING            BINARY-LONG VALUE 0.
 01 LS-NOTIFY              BINARY-LONG.
 01 LS-NONE                BINARY-LONG VALUE -1.
 01 LS-NOSTATE             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B.
     EVALUATE L-KIND
         WHEN 1
*>           setPlacedBy (7.1): the calculation runs once, nobody is notified
             CALL "RL-SAME-BLOCK" USING L-STATE L-A LS-SAME
             IF LS-SAME = 0
                 MOVE 0 TO LS-NOTIFY
                 CALL "RL-HOOK-CALC" USING L-DIM L-X L-Y L-Z L-STATE LS-REMOVING LS-NOTIFY LS-NONE LS-NOSTATE
             END-IF
         WHEN 2
             IF L-B = 0
                 CALL "RL-HOOK-REMOVE" USING L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 7
*>           the tick (7.7 end): the calculation runs again and tells both hooks' neighbours
             MOVE 1 TO LS-NOTIFY
             CALL "RL-HOOK-CALC" USING L-DIM L-X L-Y L-Z L-STATE LS-REMOVING LS-NOTIFY LS-NONE LS-NOSTATE
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-HOOK-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TRIP-SOURCE RECURSIVE.
*> USING dimension row, x, y, z, the state of the wire: updateSource (7.5): south, then west, the first hook that faces the wire runs the calculation with this wire as the changed cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-DIRS                PIC X(2) VALUE "34".
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-DIGIT               PIC 9.
 01 LS-D                   BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-S                   BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 01 LS-STOP                BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-KDG.
    05 LS-KD               BINARY-LONG OCCURS 64 TIMES.
 01 LS-REMOVING            BINARY-LONG VALUE 0.
 01 LS-NOTIFY              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 2
         MOVE WS-DIRS(LS-I:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-D
         CALL "RS1-OPP" USING LS-D LS-OPP
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 64
             MOVE 0 TO LS-KD(LS-K)
         END-PERFORM
         MOVE 0 TO LS-STOP
         PERFORM VARYING LS-K FROM 1 BY 1 UNTIL LS-K > 41 OR LS-STOP = 1
             COMPUTE LS-CX = L-X + LS-DX * LS-K
             COMPUTE LS-CZ = L-Z + LS-DZ * LS-K
             CALL "RL-LOOK" USING L-DIM LS-CX L-Y LS-CZ LS-S LS-CLASS LS-COND
             EVALUATE TRUE
                 WHEN LS-CLASS = 25
                     MOVE 1 TO LS-KD(LS-K)
                 WHEN LS-CLASS = 24 AND RL-S-DIR(LS-S + 1) = LS-OPP
                     MOVE 2 TO LS-KD(LS-K)
                     MOVE 1 TO LS-STOP
                 WHEN LS-CLASS = 24
                     MOVE 3 TO LS-KD(LS-K)
                     MOVE 1 TO LS-STOP
                 WHEN OTHER
                     MOVE 1 TO LS-STOP
             END-EVALUATE
         END-PERFORM
         CALL "RS3-SOURCE-SCAN" USING LS-KDG LS-FOUND
         IF LS-FOUND > 0
             COMPUTE LS-CX = L-X + LS-DX * LS-FOUND
             COMPUTE LS-CZ = L-Z + LS-DZ * LS-FOUND
             CALL "WORLD-GET-BLOCK" USING L-DIM LS-CX L-Y LS-CZ LS-S
             CALL "RL-HOOK-CALC" USING L-DIM LS-CX L-Y LS-CZ LS-S LS-REMOVING LS-NOTIFY LS-FOUND L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-TRIP-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TRIP-CHECK RECURSIVE.
*> USING dimension row, x, y, z, state of the wire, pressed: checkPressed (7.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-POW                 BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-SOURCE              BINARY-LONG.
 01 LS-DELAY               BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-PRESSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-PRESSED.
     CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-POW
     CALL "RS3-WIRE-CHECK" USING L-PRESSED LS-POW LS-WRITE LS-NEW LS-SOURCE LS-DELAY
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     IF LS-WRITE = 1
         CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW LS-STATE
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE LS-FLAGS LS-BUDGET LS-RESULT
         IF LS-SOURCE = 1
             CALL "RL-TRIP-SOURCE" USING L-DIM L-X L-Y L-Z LS-STATE
         END-IF
     END-IF
     IF LS-DELAY > 0
         CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-TRIP-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TRIP-PRESSED.
*> USING dimension row, x, y, z, state of the wire, pressed out: 1 when an entity that triggers blocks overlaps the wire's current shape (7.1: y 1 to 2.5 sixteenths when attached, 0 to 8 when not).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ATTACHED            PIC X(16) VALUE "attached".
 01 WS-ATT                 BINARY-LONG.
 01 WS-LOX                 FLOAT-LONG.
 01 WS-HIX                 FLOAT-LONG.
 01 WS-LOY                 FLOAT-LONG.
 01 WS-HIY                 FLOAT-LONG.
 01 WS-LOZ                 FLOAT-LONG.
 01 WS-HIZ                 FLOAT-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-LIVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-PRESSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-PRESSED.
     CALL "RL-GET-BOOL" USING L-STATE WS-ATTACHED WS-ATT
     MOVE L-X TO WS-LOX
     COMPUTE WS-HIX = L-X + 1
     MOVE L-Z TO WS-LOZ
     COMPUTE WS-HIZ = L-Z + 1
     COMPUTE WS-LOY = L-Y + 0.0625
     COMPUTE WS-HIY = L-Y + 0.15625
     IF WS-ATT = 0
         MOVE L-Y TO WS-LOY
         COMPUTE WS-HIY = L-Y + 0.5
     END-IF
     CALL "RL-BOX-COUNT" USING L-DIM WS-LOX WS-HIX WS-LOY WS-HIY WS-LOZ WS-HIZ WS-ALL WS-LIVE
     MOVE 0 TO L-PRESSED
     IF WS-ALL > 0
         MOVE 1 TO L-PRESSED
     END-IF
     GOBACK.
 END PROGRAM RL-TRIP-PRESSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TRIP-ENTITY RECURSIVE.
*> USING dimension row, x, y, z, state of an unpowered wire: entityInside (7.5): nothing when a tick is pending, else the check over the entities there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-POWERED             BINARY-LONG.
 01 LS-SCHEDULED           BINARY-LONG.
 01 LS-RUNS                BINARY-LONG.
 01 LS-PRESSED             BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-POWER-NAME          PIC X(16) VALUE "powered".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     CALL "RL-GET-BOOL" USING L-STATE LS-POWER-NAME LS-POWERED
     CALL "BT-HAS" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-SCHEDULED
     CALL "RS3-WIRE-INSIDE" USING LS-SERVER LS-POWERED LS-SCHEDULED LS-RUNS
     IF LS-RUNS = 1
         CALL "RL-TRIP-PRESSED" USING L-DIM L-X L-Y L-Z L-STATE LS-PRESSED
         IF LS-PRESSED = 1
             CALL "RL-TRIP-CHECK" USING L-DIM L-X L-Y L-Z L-STATE LS-PRESSED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-TRIP-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TRIP-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-DISARMED            PIC X(16) VALUE "disarmed".
 01 WS-SIDES.
    05 FILLER              PIC X(16) VALUE "north".
    05 FILLER              PIC X(16) VALUE "south".
    05 FILLER              PIC X(16) VALUE "west".
    05 FILLER              PIC X(16) VALUE "east".
 01 FILLER REDEFINES WS-SIDES.
    05 WS-SIDE-NAME        PIC X(16) OCCURS 4 TIMES.
 LOCAL-STORAGE SECTION.
 01 LS-SAME                BINARY-LONG.
 01 LS-POWER               BINARY-LONG.
 01 LS-DIS                 BINARY-LONG.
 01 LS-OUT-DIS             BINARY-LONG.
 01 LS-OUT-POW             BINARY-LONG.
 01 LS-PRESSED             BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-GATHERS             BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-FACING              BINARY-LONG.
 01 LS-NBLOCK              BINARY-LONG.
 01 LS-IX                  BINARY-LONG.
 01 LS-NAME                PIC X(16).
 01 LS-SIDE                BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
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
     EVALUATE L-KIND
         WHEN 1
*>           onPlace (7.5): the hooks along the line are told about this wire
             CALL "RL-SAME-BLOCK" USING L-STATE L-A LS-SAME
             IF LS-SAME = 0
                 CALL "RL-TRIP-SOURCE" USING L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 2
*>           removal (7.5): the wire counts as powered in the calculation unless it was disarmed
             IF L-B = 0
                 CALL "RL-GET-BOOL" USING L-STATE WS-DISARMED LS-DIS
                 CALL "RS3-WIRE-REMOVAL-STATE" USING LS-DIS LS-OUT-DIS LS-OUT-POW
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-OUT-POW LS-A
                 CALL "RL-TRIP-SOURCE" USING L-DIM L-X L-Y L-Z LS-A
             END-IF
         WHEN 4
*>           the side of the changed direction (7.1)
             IF L-A >= 2
                 MOVE 0 TO LS-KIND LS-FACING
                 MOVE CB-S-BLOCK(L-B + 1) TO LS-NBLOCK
                 EVALUATE RL-CLASS(LS-NBLOCK + 1)
                     WHEN 24
                         MOVE 1 TO LS-KIND
                         MOVE RL-S-DIR(L-B + 1) TO LS-FACING
                     WHEN 25
                         MOVE 2 TO LS-KIND
                 END-EVALUATE
                 CALL "RS3-WIRE-SIDE" USING LS-KIND LS-FACING L-A LS-SIDE
                 COMPUTE LS-IX = L-A - 1
                 MOVE WS-SIDE-NAME(LS-IX) TO LS-NAME
                 CALL "RL-SET-BOOL" USING L-STATE LS-NAME LS-SIDE L-OUT
             END-IF
         WHEN 7
*>           the tick (7.5): a powered wire gathers its entities and checks
             CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-POWER
             CALL "RS3-WIRE-TICK" USING LS-POWER LS-GATHERS
             IF LS-GATHERS = 1
                 CALL "RL-TRIP-PRESSED" USING L-DIM L-X L-Y L-Z L-STATE LS-PRESSED
                 CALL "RL-TRIP-CHECK" USING L-DIM L-X L-Y L-Z L-STATE LS-PRESSED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-TRIP-HOOK.
