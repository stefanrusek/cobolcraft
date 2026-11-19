*> Breeze (002-lane-p49b; docs/protocol/20-mobs-overworld-hostile.md section 16).
*> Entry points:
*>   BREEZE-SHOOT USING tracker row, table row of a breeze (SM-RANGED 7): the shoot behaviour. It starts when the breeze is standing (on the ground) with an attack target
*>     whose squared distance is below 256; otherwise it ends (the breeze_shoot memory is erased). EN-DRAW is the phase (0 ready, 1 inhaling, 2 recovery, 3 cooldown) and
*>     EN-SHOOT-TIME its ticks left: the start tick sets 15; the tick that brings the inhale to 0 fires one breeze wind charge (PROJ-SPAWN kind 6, speed 0.7) from
*>     (x, y + 1.77 / 2 + 0.3, z) at the target's (x, y + 0.3 x 1.8, z) and sets recovery 4, then cooldown 10, then the phase is ready again.
*>   BREEZE-FIRE USING breeze row, target player row, charge row out: the shot with the spread of Projectile.shoot (16.2; mob-20-16b.cob BREEZE-AIM-VECTOR).
*>   Not here (named in the lane report): the long jump, the slide, the idle
*>     and stop-attacking behaviours, the damage and flight of the charge's burst, the pose and the inhale and shoot sounds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-FIRE.
*> USING breeze row, target player row, charge row out: one shot (16.2): the breeze wind charge is created at (x, y + 1.77 / 2 + 0.3, z) and given the velocity of Projectile.shoot with power 0.7f and
*> the uncertainty 5 - 4 x the difficulty id (Easy 1, Normal -3, Hard -7): (normalize(d) + error) x 0.699999988079071, the error of each component 0.0172275 x u x (nextDouble - nextDouble).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-SALT                BINARY-LONG VALUE 95.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW-F           FLOAT-LONG OCCURS 6 TIMES.
 01 WS-U                   BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-P L-CHARGE.
     CALL "BR-WORLD-READY"
                 MOVE EN-X(L-ROW) TO WS-SX
                 COMPUTE WS-SY = EN-Y(L-ROW) + 1.77 / 2 + 0.3
                 MOVE EN-Z(L-ROW) TO WS-SZ
                 COMPUTE WS-DX = PL-X(L-P) - EN-X(L-ROW)
                 COMPUTE WS-DY = PL-Y(L-P) + 1.8 * 0.3 - WS-SY
                 COMPUTE WS-DZ = PL-Z(L-P) - EN-Z(L-ROW)
                 MOVE EN-ID(L-ROW) TO WS-OWNER
                 MOVE EN-DIM(L-ROW) TO WS-DIM
                 CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-SY WS-SZ WS-DX WS-DY WS-DZ WS-POWER WS-OWNER L-CHARGE
     COMPUTE WS-U = 5 - 4 * BW-DIFFICULTY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
         COMPUTE WS-DRAW-F(WS-I) = WS-DRAW / 1000000
     END-PERFORM
     CALL "BREEZE-AIM-VECTOR" USING WS-DX WS-DY WS-DZ WS-U WS-DRAWS WS-VX WS-VY WS-VZ
     MOVE WS-VX TO EN-VX(L-CHARGE)
     MOVE WS-VY TO EN-VY(L-CHARGE)
     MOVE WS-VZ TO EN-VZ(L-CHARGE)
     CALL "PROJ-ROTATE" USING L-CHARGE
     GOBACK.
 END PROGRAM BREEZE-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-CHARGE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
*>   The stop-attacking rule runs first (16.1, priority 0 of FIGHT).
     CALL "BREEZE-STOP-CHECK" USING L-ROW
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
                 CALL "BREEZE-FIRE" USING L-ROW WS-P WS-CHARGE
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
