*> Breeze (002-lane-p49b; docs/protocol/20-mobs-overworld-hostile.md section 16).
*> Entry points:
*>   BREEZE-SHOOT USING tracker row, table row of a breeze (SM-RANGED 7): the shoot behaviour. It starts when the breeze is standing (on the ground) with an attack target
*>     whose squared distance is below 256; otherwise it ends (the breeze_shoot memory is erased). EN-DRAW is the phase (0 ready, 1 inhaling, 2 recovery, 3 cooldown) and
*>     EN-SHOOT-TIME its ticks left: the start tick sets 15; the tick that brings the inhale to 0 fires one breeze wind charge (PROJ-SPAWN kind 6, speed 0.7) from
*>     (x, y + 1.77 / 2 + 0.3, z) at the target's (x, y + 0.3 x 1.8, z) and sets recovery 4, then cooldown 10, then the phase is ready again.
*>   Not here (named in the lane report): the spread of the shot (inaccuracy 5 - 4 x difficulty id; `Projectile.shoot` is not in the document), the long jump, the slide, the idle
*>     and stop-attacking behaviours, the damage and flight of the charge's burst, the pose and the inhale and shoot sounds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE EN-TARGET(L-ROW) TO WS-P
     MOVE 0 TO WS-D2
     IF WS-P > 0
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     IF WS-P = 0 OR WS-D2 >= 256 OR (EN-ON-GROUND(L-ROW) = 0 AND EN-DRAW(L-ROW) = 0)
         IF EN-DRAW(L-ROW) = 1
             MOVE 0 TO EN-DRAW(L-ROW) EN-SHOOT-TIME(L-ROW)
         END-IF
         IF EN-DRAW(L-ROW) = 0
             GOBACK
         END-IF
     END-IF
     EVALUATE EN-DRAW(L-ROW)
         WHEN 0
             MOVE 1 TO EN-DRAW(L-ROW)
             MOVE 15 TO EN-SHOOT-TIME(L-ROW)
         WHEN 1
             SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 MOVE EN-X(L-ROW) TO WS-SX
                 COMPUTE WS-SY = EN-Y(L-ROW) + 1.77 / 2 + 0.3
                 MOVE EN-Z(L-ROW) TO WS-SZ
                 COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DY = PL-Y(WS-P) + 1.8 * 0.3 - WS-SY
                 COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                 MOVE EN-ID(L-ROW) TO WS-OWNER
                 MOVE EN-DIM(L-ROW) TO WS-DIM
                 CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-SY WS-SZ WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-CHARGE
                 MOVE 2 TO EN-DRAW(L-ROW)
                 MOVE 4 TO EN-SHOOT-TIME(L-ROW)
             END-IF
         WHEN 2
             SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 MOVE 3 TO EN-DRAW(L-ROW)
                 MOVE 10 TO EN-SHOOT-TIME(L-ROW)
             END-IF
         WHEN OTHER
             SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 MOVE 0 TO EN-DRAW(L-ROW)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BREEZE-SHOOT.
