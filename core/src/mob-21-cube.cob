*> The cube-mob move control of the slime and the magma cube (docs/protocol/20 section 10, 21 section 5.3, 44-residual-mob-questions-6-nether.md section 9.3, 18 sections 3.2.1 and 3.3 E;
*> lane 002-lane-p49l made the jump, lane 002-lane-bugmobmove the hop's own motion). A cube moves only by hopping.
*> CubeMobMoveControl: on the ground the cube sets no forward input between its jumps; it counts jumpDelay (EN-HOP) down and jumps when the count reaches 0 (the jump tick decrements too: d ticks apart) (jump velocity 0.42, plus 0.1 x its
*> size for a magma cube, 21 section 5.3), then jumpDelay = getJumpDelay = nextInt(20) + 10 (x 4 for a magma cube), divided by 3 (integer) when the control is aggressive, which
*> CubeMobAttackGoal sets from canDealDamage() while the cube has a target (a size 1 slime cannot deal damage; a magma cube always can).
*> The hop's motion: the cube's speed is 0.2 + 0.1 x size (EN-VARIANT, 0 reads as 1) and its forward input is that speed, so the jump tick accelerates it along its yaw by speed x
*> speed (speed x 0.21600002 / F^3 x speed over ground of friction F above 0.6, 18 section 3.2.1), and an air tick by 0.02 x speed; the move uses the speed after the acceleration and
*> the drag (0.546 on the ground, F x 0.91 above 0.6, 0.91 in the air) is applied after it. The wanted yaw is the direction to the target (CubeMobAttackGoal) or, with no target,
*> CubeMobRandomDirectionGoal's: a yaw nextInt(360) chosen every 40 + nextInt(60) ticks while on the ground (EN-DEST-Z counts the ticks, EN-DEST-X is the yaw); the yaw turns towards it
*> by at most 90 degrees a tick (MoveControl.rotlerp). STDMOB-STEP gives a cube no walk of its own (no stroll, no path to the target), so the speed of its table row is not used.
*> Gaps: the float goal in liquids (a jump with probability 0.8 a tick) is the generic water physics; the give-up timer of 300 ticks of the attack goal has no effect on a cube that
*> keeps its target (the goal restarts at once); a new cube has EN-HOP 0 and hops on its first tick on the ground.
*>   CUBE-HOP USING tracker row, table row, hx, hz (FLOAT-LONG, in out: the move of this tick and the drag already applied to EN-VX, EN-VZ), yaw (FLOAT-SHORT, in out)
*>     one tick of the move control, called by STDMOB-STEP before the mob's physics

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUBE-HOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-SIZE                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-ACCEL               FLOAT-LONG.
 01 WS-FRICTION            FLOAT-LONG.
 01 WS-DRAG                FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-AGGRESSIVE          BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-WANT                FLOAT-SHORT.
 01 WS-TURN                FLOAT-LONG.
 01 WS-NEW-YAW             FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ L-YAW.
     COMPUTE WS-SIZE = FUNCTION MAX(EN-VARIANT(L-ROW), 1)
     COMPUTE WS-SPEED = 0.2 + 0.1 * WS-SIZE
     MOVE 0 TO WS-AGGRESSIVE
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         MOVE L-YAW TO WS-WANT
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-WANT
*>       lookAt(target, 10, 10) of the attack goal turns the cube by at most 10 degrees a tick (20 section 10.1); the move control then lerps to that yaw.
         COMPUTE WS-TURN = WS-WANT - L-YAW
         COMPUTE WS-TURN = WS-TURN - 360 * FUNCTION INTEGER((WS-TURN + 180) / 360)
         COMPUTE WS-TURN = FUNCTION MAX(-10, FUNCTION MIN(10, WS-TURN))
         COMPUTE WS-WANT = L-YAW + WS-TURN
         IF SM-KEY(L-M) = "magma_cube" OR WS-SIZE > 1
             MOVE 1 TO WS-AGGRESSIVE
         END-IF
     ELSE
         IF EN-ON-GROUND(L-ROW) = 1
             SUBTRACT 1 FROM EN-DEST-Z(L-ROW)
             IF EN-DEST-Z(L-ROW) <= 0
                 MOVE EN-ID(L-ROW) TO WS-ARG(1)
                 MOVE CW-TIME TO WS-ARG(2)
                 MOVE 29 TO WS-ARG(3)
                 CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
                 COMPUTE EN-DEST-Z(L-ROW) = 40 + FUNCTION MOD(WS-R, 60)
                 COMPUTE WS-Q = WS-R / 60
                 COMPUTE EN-DEST-X(L-ROW) = FUNCTION MOD(WS-Q, 360)
             END-IF
         END-IF
         MOVE EN-DEST-X(L-ROW) TO WS-WANT
     END-IF
*>   rotlerp: the yaw turns towards the wanted one by at most 90 degrees; the result is kept in (-180, 180].
     COMPUTE WS-TURN = WS-WANT - L-YAW
     COMPUTE WS-TURN = WS-TURN - 360 * FUNCTION INTEGER((WS-TURN + 180) / 360)
     COMPUTE WS-TURN = FUNCTION MAX(-90, FUNCTION MIN(90, WS-TURN))
     COMPUTE WS-NEW-YAW = L-YAW + WS-TURN
     COMPUTE WS-NEW-YAW = WS-NEW-YAW - 360 * FUNCTION INTEGER((WS-NEW-YAW + 180) / 360)
     MOVE WS-NEW-YAW TO L-YAW
     COMPUTE WS-RADIANS = L-YAW * FUNCTION PI / 180
     MOVE 0 TO WS-ACCEL
     MOVE 0.91 TO WS-DRAG
     IF EN-ON-GROUND(L-ROW) = 1
         MOVE 0.6 TO WS-FRICTION
         CALL "STDMOB-FRICTION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-FRICTION
         MOVE 0.546 TO WS-DRAG
         IF WS-FRICTION > 0.6
             COMPUTE WS-DRAG = WS-FRICTION * 0.91
         END-IF
*>       jumpDelay is decremented on the jump tick too: a drawn d gives the next jump d on-ground ticks later (20 section 10.1), so the tick that takes it from 1 to 0 jumps.
         IF EN-HOP(L-ROW) > 1
             SUBTRACT 1 FROM EN-HOP(L-ROW)
         ELSE
             MOVE EN-ID(L-ROW) TO WS-ARG(1)
             MOVE CW-TIME TO WS-ARG(2)
             MOVE 31 TO WS-ARG(3)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
             COMPUTE WS-DELAY = 10 + FUNCTION MOD(WS-R, 20)
             IF SM-KEY(L-M) = "magma_cube"
                 COMPUTE WS-DELAY = WS-DELAY * 4
             END-IF
             IF WS-AGGRESSIVE = 1
                 COMPUTE WS-DELAY = WS-DELAY / 3
             END-IF
             MOVE WS-DELAY TO EN-HOP(L-ROW)
             MOVE 0.42 TO EN-VY(L-ROW)
             IF SM-KEY(L-M) = "magma_cube"
                 COMPUTE EN-VY(L-ROW) = 0.42 + 0.1 * WS-SIZE
             END-IF
             MOVE WS-SPEED TO WS-ACCEL
             IF WS-FRICTION > 0.6
                 COMPUTE WS-ACCEL = WS-SPEED * 0.21600002 / (WS-FRICTION ** 3)
             END-IF
             COMPUTE WS-ACCEL = WS-ACCEL * WS-SPEED
         END-IF
     ELSE
         COMPUTE WS-ACCEL = 0.02 * WS-SPEED
     END-IF
*>   The move of this tick takes the acceleration; the velocity kept for the next one has the drag of this tick on it.
     COMPUTE WS-AX = - FUNCTION SIN(WS-RADIANS) * WS-ACCEL
     COMPUTE WS-AZ = FUNCTION COS(WS-RADIANS) * WS-ACCEL
     COMPUTE L-HX = L-HX + WS-AX
     COMPUTE L-HZ = L-HZ + WS-AZ
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-AX * WS-DRAG
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-AZ * WS-DRAG
     GOBACK.
 END PROGRAM CUBE-HOP.
