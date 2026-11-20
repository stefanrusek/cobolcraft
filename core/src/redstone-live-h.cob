*> Live redstone, the target block (docs/protocol/30-redstone-5 section 6): a projectile that hits it writes the strength of the hit position as its power (6.1, only when no release tick is
*> pending) and schedules the release 20 ticks (an arrow) later, the tick sets the power back to 0, a placed target with power and no tick pending is reset (6).
*> The only projectiles of this core that hit blocks are arrows (arrows.cob), so every hit counts as an arrow's; the criterion trigger and the statistic of an owner that is a player are not awarded.
*> Entry points:
*>   RL-TARGET-HIT USING dimension row, solid cell x, y, z, the last free point x, y, z (FLOAT-LONG)    onProjectileHit of an arrow that stopped in the cell (ARROW-STEP)
*>   RL-TARGET-HOOK USING kind, dimension row, x, y, z, state, a    kinds 1 onPlace and 7 tick of a target block

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TARGET-HIT RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWER               PIC X(16) VALUE "power".
 LOCAL-STORAGE SECTION.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-HX                  FLOAT-LONG.
 01 LS-HY                  FLOAT-LONG.
 01 LS-HZ                  FLOAT-LONG.
 01 LS-PLANE               FLOAT-LONG.
 01 LS-FACE                BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-STRENGTH            BINARY-LONG.
 01 LS-ARROW               BINARY-LONG VALUE 1.
 01 LS-PENDING             BINARY-LONG.
 01 LS-OWNER               BINARY-LONG VALUE 0.
 01 LS-WRITE               BINARY-LONG.
 01 LS-NEW-POWER           BINARY-LONG.
 01 LS-DURATION            BINARY-LONG.
 01 LS-SCHEDULED           BINARY-LONG.
 01 LS-CRITERION           BINARY-LONG.
 01 LS-CSTRENGTH           BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CY L-CZ L-PX L-PY L-PZ.
     CALL "RL-LOOK" USING L-DIM L-CX L-CY L-CZ LS-STATE LS-CLASS LS-COND
     IF LS-CLASS NOT = 21
         GOBACK
     END-IF
*>   the face that was crossed: the first axis on which the last free point lies outside the cell (6.1 table: Z axis 1, X axis 2, Y axis 5)
     MOVE L-PX TO LS-HX
     MOVE L-PY TO LS-HY
     MOVE L-PZ TO LS-HZ
     MOVE 0 TO LS-DONE
     EVALUATE TRUE
         WHEN L-PX < L-CX
             MOVE L-CX TO LS-HX
             MOVE 2 TO LS-FACE
         WHEN L-PX >= L-CX + 1
             COMPUTE LS-HX = L-CX + 1
             MOVE 2 TO LS-FACE
         WHEN L-PY < L-CY
             MOVE L-CY TO LS-HY
             MOVE 5 TO LS-FACE
         WHEN L-PY >= L-CY + 1
             COMPUTE LS-HY = L-CY + 1
             MOVE 5 TO LS-FACE
         WHEN L-PZ < L-CZ
             MOVE L-CZ TO LS-HZ
             MOVE 1 TO LS-FACE
         WHEN OTHER
             COMPUTE LS-HZ = L-CZ + 1
             MOVE 1 TO LS-FACE
     END-EVALUATE
     CALL "RS2-TARGET-STRENGTH" USING LS-HX LS-HY LS-HZ LS-FACE LS-STRENGTH
     MOVE CB-S-BLOCK(LS-STATE + 1) TO LS-BLOCK
     CALL "BT-HAS" USING L-DIM LS-TYPE LS-BLOCK L-CX L-CY L-CZ LS-PENDING
     CALL "RS2-TARGET-HIT" USING LS-ARROW LS-PENDING LS-STRENGTH LS-OWNER LS-WRITE LS-NEW-POWER LS-DURATION LS-SCHEDULED
         LS-CRITERION LS-CSTRENGTH
     IF LS-WRITE = 1
         CALL "RL-SET-NUM" USING LS-STATE WS-POWER LS-NEW-POWER LS-NEW
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-CX L-CY L-CZ LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
     END-IF
     IF LS-SCHEDULED = 1
         CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-CX L-CY L-CZ LS-DURATION LS-PRIO LS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-TARGET-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TARGET-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWER               PIC X(16) VALUE "power".
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-POW                 BINARY-LONG.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-SAME                BINARY-LONG.
 01 LS-PENDING             BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-NEW                 BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-S-POWER(L-STATE + 1) TO LS-POW
     EVALUATE L-KIND
         WHEN 7
*>           release (6): a powered target goes back to 0
             CALL "RS2-TARGET-TICK" USING LS-POW LS-WRITE
             IF LS-WRITE = 1
                 CALL "RL-SET-NUM" USING L-STATE WS-POWER LS-ZERO LS-NEW
                 MOVE 3 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
         WHEN 1
*>           onPlace (6): a placed target with power and no tick pending is reset quietly
             CALL "RL-SAME-BLOCK" USING L-STATE L-A LS-SAME
             CALL "BT-HAS" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-PENDING
             CALL "RS2-TARGET-PLACE" USING LS-SERVER LS-SAME LS-POW LS-PENDING LS-WRITE LS-FLAGS
             IF LS-WRITE = 1
                 CALL "RL-SET-NUM" USING L-STATE WS-POWER LS-ZERO LS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-TARGET-HOOK.
