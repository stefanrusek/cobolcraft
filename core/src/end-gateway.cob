*> End gateways (docs/protocol/38-end.md section 8, 39-portals.md section 7.6, 31-block-entities-5 section 4): a block entity per end_gateway block with its age,
*> teleport cooldown, exit position and ExactTeleport (ENDGATEWAY.cpy), the 40-tick cooldown and the teleport of a player whose box touches the block (the whole cell).
*> A gateway block the core meets without an entity is a return gateway of the generator (end_gateway_return: exit (100, 50, 0), exact, 38 section 8); the delayed gateways
*> of the dragon fight (no exit: the search of 31-5 section 4.4 step 1) and the saving of the entities are open items. The player moves by the same-dimension DIM-SWITCH
*> (a Respawn and the data a dimension switch sends, no sound, the rotation kept: relative DELTA and ROTATION, 7.6).
*>
*> Entry points:
*>   END-GATEWAY-IDS                                    the ids of end_gateway and bedrock, resolved again when CB-EPOCH changes
*>   END-GATEWAY-FIND USING dim, x, y, z, row out       the entity at a position (0 when the block there is not an end_gateway; it is created on first use)
*>   END-GATEWAY-SET USING dim, x, y, z, flags (1 exit present, 2 exact), exit x, y, z: the entity of a gateway the generator placed (feature end_gateway with an exit, 35-7 10.4): the row
*>                                                      is found or made without reading the block and given the exit and the flag (setExitPosition)
*>   END-GATEWAY-EXIT USING row, x, y, z out (FLOAT-LONG)   getPortalPosition: the bottom centre of the exit (exact), else of findExitPosition (4.4)
*>   END-GATEWAY-TICK                                   portalTick of every entity: age, cooldown, the attention interval 2400
*>   END-GATEWAY-PLAYER USING player row                a player's box inside a gateway block: the cooldown, the teleport

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-IDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY ENDGATEWAY.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 PROCEDURE DIVISION.
     IF EG-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO EG-EPOCH
     MOVE -1 TO EG-S-GATEWAY EG-S-BEDROCK
     MOVE "end_gateway" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS EG-S-GATEWAY
     MOVE "bedrock" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS EG-S-BEDROCK
     GOBACK.
 END PROGRAM END-GATEWAY-IDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENDGATEWAY.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW
     CALL "END-GATEWAY-IDS"
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF EG-S-GATEWAY < 0 OR WS-STATE NOT = EG-S-GATEWAY
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EG-COUNT
         IF EG-DIM(WS-I) = L-DIM AND EG-X(WS-I) = L-X AND EG-Y(WS-I) = L-Y AND EG-Z(WS-I) = L-Z
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW = 0 AND EG-COUNT < EG-MAX
         ADD 1 TO EG-COUNT
         MOVE EG-COUNT TO L-ROW
         INITIALIZE EG-ROW(L-ROW)
         MOVE L-DIM TO EG-DIM(L-ROW)
         MOVE L-X TO EG-X(L-ROW)
         MOVE L-Y TO EG-Y(L-ROW)
         MOVE L-Z TO EG-Z(L-ROW)
         MOVE 1 TO EG-HAS-EXIT(L-ROW) EG-EXACT(L-ROW)
         MOVE 100 TO EG-EXIT-X(L-ROW)
         MOVE 50 TO EG-EXIT-Y(L-ROW)
         MOVE 0 TO EG-EXIT-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM END-GATEWAY-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENDGATEWAY.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-EZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLAGS L-EX L-EY L-EZ.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EG-COUNT
         IF EG-DIM(WS-I) = L-DIM AND EG-X(WS-I) = L-X AND EG-Y(WS-I) = L-Y AND EG-Z(WS-I) = L-Z
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW = 0 AND EG-COUNT < EG-MAX
         ADD 1 TO EG-COUNT
         MOVE EG-COUNT TO WS-ROW
         INITIALIZE EG-ROW(WS-ROW)
         MOVE L-DIM TO EG-DIM(WS-ROW)
         MOVE L-X TO EG-X(WS-ROW)
         MOVE L-Y TO EG-Y(WS-ROW)
         MOVE L-Z TO EG-Z(WS-ROW)
     END-IF
     IF WS-ROW > 0
         IF FUNCTION MOD(L-FLAGS, 2) = 1
             MOVE 1 TO EG-HAS-EXIT(WS-ROW)
             MOVE L-EX TO EG-EXIT-X(WS-ROW)
             MOVE L-EY TO EG-EXIT-Y(WS-ROW)
             MOVE L-EZ TO EG-EXIT-Z(WS-ROW)
         ELSE
             MOVE 0 TO EG-HAS-EXIT(WS-ROW)
         END-IF
         IF L-FLAGS >= 2
             MOVE 1 TO EG-EXACT(WS-ROW)
         ELSE
             MOVE 0 TO EG-EXACT(WS-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM END-GATEWAY-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-EXIT.
*> findExitPosition (31-5 section 4.4): findTallestBlock at the exit raised by 2 with radius 5 and flag false (the column (0, 0) is skipped and bedrock is passed
*> over; each column is scanned from the top of the End, 255, down while y is above the best found so far), the result raised by 1; nothing found keeps the
*> input cell (exit + (0, 2, 0)), so the player arrives three above the exit. Returns FALSE (0) in L-FOUND when the entity has no exit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY ENDGATEWAY.
 01 WS-BEST-Y              BINARY-LONG.
 01 WS-BEST-X              BINARY-LONG.
 01 WS-BEST-Z              BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SCAN-X              BINARY-LONG.
 01 WS-SCAN-Z              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FOUND.
     MOVE EG-HAS-EXIT(L-ROW) TO L-FOUND
     IF L-FOUND = 0
         GOBACK
     END-IF
     IF EG-EXACT(L-ROW) = 1
         COMPUTE L-X = EG-EXIT-X(L-ROW) + 0.5
         MOVE EG-EXIT-Y(L-ROW) TO L-Y
         COMPUTE L-Z = EG-EXIT-Z(L-ROW) + 0.5
         GOBACK
     END-IF
     MOVE EG-EXIT-X(L-ROW) TO WS-BEST-X
     COMPUTE WS-BEST-Y = EG-EXIT-Y(L-ROW) + 3
     MOVE EG-EXIT-Z(L-ROW) TO WS-BEST-Z
     MOVE -1 TO WS-STOP
     PERFORM VARYING WS-DX FROM -5 BY 1 UNTIL WS-DX > 5
         PERFORM VARYING WS-DZ FROM -5 BY 1 UNTIL WS-DZ > 5
             IF WS-DX NOT = 0 OR WS-DZ NOT = 0
                 COMPUTE WS-SCAN-X = EG-EXIT-X(L-ROW) + WS-DX
                 COMPUTE WS-SCAN-Z = EG-EXIT-Z(L-ROW) + WS-DZ
                 MOVE 255 TO WS-Y
                 PERFORM UNTIL WS-Y <= WS-STOP OR WS-Y < 0
                     CALL "WORLD-GET-BLOCK" USING EG-DIM(L-ROW) WS-SCAN-X WS-Y WS-SCAN-Z WS-STATE
                     IF WS-STATE NOT = 0 AND WS-STATE NOT = EG-S-BEDROCK
                         IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                             MOVE WS-Y TO WS-STOP
                             MOVE WS-SCAN-X TO WS-BEST-X
                             COMPUTE WS-BEST-Y = WS-Y + 1
                             MOVE WS-SCAN-Z TO WS-BEST-Z
                             MOVE -1 TO WS-Y
                         END-IF
                     END-IF
                     SUBTRACT 1 FROM WS-Y
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE L-X = WS-BEST-X + 0.5
     MOVE WS-BEST-Y TO L-Y
     COMPUTE L-Z = WS-BEST-Z + 0.5
     GOBACK.
 END PROGRAM END-GATEWAY-EXIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENDGATEWAY.
 01 WS-I                   BINARY-LONG.
 01 WS-COOLDOWN-TICKS      BINARY-LONG VALUE 40.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EG-COUNT
         ADD 1 TO EG-AGE(WS-I)
         IF EG-COOLDOWN(WS-I) > 0
             SUBTRACT 1 FROM EG-COOLDOWN(WS-I)
         ELSE
             IF FUNCTION MOD(EG-AGE(WS-I), 2400) = 0
                 MOVE WS-COOLDOWN-TICKS TO EG-COOLDOWN(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-GATEWAY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GATEWAY-PLAYER.
*> entityInside (7.6): a player (not a spectator) whose box (0.6 x 1.8) touches an end_gateway block that is not cooling down starts the gateway's own cooldown of 40
*> ticks; she moves to the exit when her own portal cooldown (END-TRAVEL, ET-COOLDOWN) is 0, and her cooldown is 10 ticks either way.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENDTRAVEL.
 COPY ENDGATEWAY.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MAX-X               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-MAX-Z               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.00001.
 01 WS-F                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG VALUE 10.
 01 WS-GATE-COOLDOWN       BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-MODE(L-ROW) = 3
         GOBACK
     END-IF
     COMPUTE WS-F = PL-X(L-ROW) - 0.3 + WS-EPS
     COMPUTE WS-MIN-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-X(L-ROW) + 0.3 - WS-EPS
     COMPUTE WS-MAX-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Y(L-ROW) + WS-EPS
     COMPUTE WS-MIN-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Y(L-ROW) + 1.8 - WS-EPS
     COMPUTE WS-MAX-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Z(L-ROW) - 0.3 + WS-EPS
     COMPUTE WS-MIN-Z = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Z(L-ROW) + 0.3 - WS-EPS
     COMPUTE WS-MAX-Z = FUNCTION INTEGER(WS-F)
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-X FROM WS-MIN-X BY 1 UNTIL WS-X > WS-MAX-X
         PERFORM VARYING WS-BY FROM WS-MIN-Y BY 1 UNTIL WS-BY > WS-MAX-Y
             PERFORM VARYING WS-Z FROM WS-MIN-Z BY 1 UNTIL WS-Z > WS-MAX-Z
                 IF WS-DONE = 0
                     CALL "END-GATEWAY-FIND" USING PL-DIM(L-ROW) WS-X WS-BY WS-Z WS-GATE
                     IF WS-GATE > 0 AND EG-COOLDOWN(WS-GATE) = 0
                         MOVE 1 TO WS-DONE
                         MOVE WS-GATE-COOLDOWN TO EG-COOLDOWN(WS-GATE)
                         CALL "END-GATEWAY-EXIT" USING WS-GATE WS-TX WS-TY WS-TZ WS-FOUND
                         IF ET-COOLDOWN(L-ROW) > 0
                             MOVE WS-COOLDOWN TO ET-COOLDOWN(L-ROW)
                         ELSE
                             MOVE WS-COOLDOWN TO ET-COOLDOWN(L-ROW)
                             IF WS-FOUND = 1
                                 MOVE PL-DIM(L-ROW) TO WS-DEST
                                 CALL "DIM-SWITCH" USING L-ROW WS-DEST WS-TX WS-TY WS-TZ
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-GATEWAY-PLAYER.
