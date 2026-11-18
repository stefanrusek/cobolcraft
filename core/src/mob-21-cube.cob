*> The cube-mob move control of the slime and the magma cube (docs/protocol/44-residual-mob-questions-6-nether.md section 9.3 and 21 section 5.3; lane 002-lane-p49l).
*> CubeMobMoveControl: on the ground the cube sets no forward input between its jumps; it counts jumpDelay (EN-HOP) down and jumps when it reaches 0 (jump velocity 0.42, plus 0.1 x its
*> size for a magma cube, 21 section 5.3), then jumpDelay = getJumpDelay = nextInt(20) + 10 (x 4 for a magma cube), divided by 3 (integer) when the control is aggressive, which
*> CubeMobAttackGoal sets from canDealDamage() while the cube has a target (a size 1 slime cannot deal damage; a magma cube always can). In the air the cube keeps its course.
*> Gaps: the random direction goal (CubeMobRandomDirectionGoal: a new yaw nextInt(360) every 40 + nextInt(60) ticks) is the cube's ordinary stroll here, the float goal in liquids (a jump
*> with probability 0.8 a tick) is the generic water physics, the give-up timer of 300 ticks of the attack goal has no effect on a cube that keeps its target (the goal restarts at once).
*>   CUBE-HOP USING tracker row, table row, hx, hz (FLOAT-LONG, in out)    one tick of the move control, called before the mob's physics with the walk it wants

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUBE-HOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-SALT                BINARY-LONG VALUE 131.
 01 WS-BOUND               BINARY-LONG VALUE 20.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ.
     IF EN-ON-GROUND(L-ROW) NOT = 1
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-HOP(L-ROW)
     IF EN-HOP(L-ROW) > 0
         MOVE 0 TO L-HX L-HZ
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     COMPUTE WS-DELAY = 10 + WS-DRAW
     IF SM-KEY(L-M) = "magma_cube"
         COMPUTE WS-DELAY = WS-DELAY * 4
     END-IF
     CALL "STDMOB-ATTACK-DAMAGE" USING L-ROW L-M WS-DAMAGE
     IF EN-TARGET(L-ROW) > 0 AND WS-DAMAGE > 0
         DIVIDE WS-DELAY BY 3 GIVING WS-DELAY
     END-IF
     MOVE WS-DELAY TO EN-HOP(L-ROW)
     MOVE 0.42 TO EN-VY(L-ROW)
     IF SM-KEY(L-M) = "magma_cube"
         COMPUTE WS-SIZE = FUNCTION MAX(EN-VARIANT(L-ROW), 1)
         COMPUTE EN-VY(L-ROW) = 0.42 + 0.1 * WS-SIZE
     END-IF
     GOBACK.
 END PROGRAM CUBE-HOP.
