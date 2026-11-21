*> The flight of a vex (docs/protocol/20 section 13.4 and 13.4.1; lane 002-lane-p49r). The vex has no speed attribute: its goals give the move control a wanted point (EN-FLY-X/Y/Z, the speed modifier
*> EN-FLY-MOD, EN-FLY-ON 1 for MOVE_TO) and the control adds an acceleration of 0.05 x modifier towards it each tick (VexMoveControl). The move then ignores blocks (noPhysics) and the velocity is damped
*> by 0.91 (horizontal) and 0.98 (vertical) in air, 0.8 in water, 0.5 in lava. During the first tick of a vex (EN-WAKE 0) gravity still applies once. EN-WAKE counts the ticks flown.
*>   VEX-FLY USING vex row: the move control (13.4.1 steps 1 to 4), the move through blocks and the damping, one tick. Called by STDMOB-STEP in place of the walking physics.
*>   VEX-RANDOM-MOVE USING vex row: VexRandomMoveGoal (priority 8): with no wish and a 1 in 7 draw, up to 3 tries at the bound origin (else the vex's own block) + (-7 + nextInt(15), -5 + nextInt(11),
*>     -7 + nextInt(15)); the first empty block becomes the wanted point at modifier 0.25. The wanted point is the centre of the block (the document gives the block only).
*> Gaps: the shallow-lava damping (0.5, 0.8, 0.5), the head turn of the look control, the end of a charge whose wish was cleared without touching the target (no document text for the goal's stop).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-FLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-MOD                 FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-HEIGHT              FLOAT-LONG VALUE 0.8.
 01 WS-KIND-WATER          BINARY-LONG VALUE 1.
 01 WS-KIND-LAVA           BINARY-LONG VALUE 2.
 01 WS-WET                 BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-HOR                 FLOAT-LONG.
 01 WS-VER                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     IF EN-FLY-ON(L-ROW) = 1
         COMPUTE WS-DX = EN-FLY-X(L-ROW) - EN-X(L-ROW)
         COMPUTE WS-DY = EN-FLY-Y(L-ROW) - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-FLY-Z(L-ROW) - EN-Z(L-ROW)
         COMPUTE WS-D = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
*>       Within the average edge of its box ((0.4 + 0.8 + 0.4) / 3) it waits and halves its velocity.
         IF WS-D < 0.5333333333333333
             MOVE 0 TO EN-FLY-ON(L-ROW)
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.5
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.5
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.5
         ELSE
             MOVE EN-FLY-MOD(L-ROW) TO WS-MOD
             IF WS-MOD = 0
                 MOVE 1.0 TO WS-MOD
             END-IF
             COMPUTE WS-K = WS-MOD * 0.05 / WS-D
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-DX * WS-K
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-DY * WS-K
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-DZ * WS-K
*>           Without a target it faces its velocity (-atan2(vx, vz)), with one the target (not the wanted point).
             MOVE EN-TARGET(L-ROW) TO WS-P
             IF WS-P > 0
                 COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                 CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
             ELSE
                 CALL "MOB-YAW-TOWARD" USING EN-VX(L-ROW) EN-VZ(L-ROW) WS-YAW
             END-IF
         END-IF
     END-IF
*>   The move ignores blocks (noPhysics); the medium is that of the vex's cell before the move.
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HEIGHT WS-KIND-WATER WS-WET
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HEIGHT WS-KIND-LAVA WS-LAVA
     MOVE 0.9100000262260437 TO WS-HOR
     MOVE 0.9800000190734863 TO WS-VER
     IF WS-WET = 1
         MOVE 0.800000011920929 TO WS-HOR WS-VER
     ELSE
         IF WS-LAVA = 1
             MOVE 0.5 TO WS-HOR WS-VER
         END-IF
     END-IF
     CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * WS-HOR
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * WS-HOR
*>   Gravity applies once, in the first tick of a new vex (the no-gravity flag is set after that tick).
     IF EN-WAKE(L-ROW) = 0 AND WS-WET = 0 AND WS-LAVA = 0
         COMPUTE EN-VY(L-ROW) = (EN-VY(L-ROW) - 0.08) * WS-VER
     ELSE
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * WS-VER
     END-IF
     ADD 1 TO EN-WAKE(L-ROW)
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     GOBACK.
 END PROGRAM VEX-FLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VEX-RANDOM-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EVKSTATE.
 01 WS-SALT                BINARY-LONG VALUE 75.
 01 WS-B7                  BINARY-LONG VALUE 7.
 01 WS-B15                 BINARY-LONG VALUE 15.
 01 WS-B11                 BINARY-LONG VALUE 11.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-FLY-ON(L-ROW) = 1
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B7 WS-DRAW
     IF WS-DRAW NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-OX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-OY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-OZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VX-MAX OR WS-SLOT > 0
         IF VX-ID(WS-I) = EN-ID(L-ROW)
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT > 0 AND VX-BOUND(WS-SLOT) = 1
         MOVE VX-BX(WS-SLOT) TO WS-OX
         MOVE VX-BY(WS-SLOT) TO WS-OY
         MOVE VX-BZ(WS-SLOT) TO WS-OZ
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 3 OR WS-FOUND = 1
         CALL "XP-RANDOM" USING WS-SALT WS-B15 WS-DRAW
         COMPUTE WS-CX = WS-OX - 7 + WS-DRAW
         CALL "XP-RANDOM" USING WS-SALT WS-B11 WS-DRAW
         COMPUTE WS-CY = WS-OY - 5 + WS-DRAW
         CALL "XP-RANDOM" USING WS-SALT WS-B15 WS-DRAW
         COMPUTE WS-CZ = WS-OZ - 7 + WS-DRAW
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-STATE
         IF WS-STATE = 0
             COMPUTE EN-FLY-X(L-ROW) = WS-CX + 0.5
             COMPUTE EN-FLY-Y(L-ROW) = WS-CY + 0.5
             COMPUTE EN-FLY-Z(L-ROW) = WS-CZ + 0.5
             MOVE 0.25 TO EN-FLY-MOD(L-ROW)
             MOVE 1 TO EN-FLY-ON(L-ROW)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VEX-RANDOM-MOVE.
