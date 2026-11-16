*> The flying move of allay, bee and parrot (002-lane-mobsa2; docs/protocol/18-mob-framework.md FlyingMoveControl and travelFlying, section 3).
*> M44-FLY-MOVE USING row, wanted x, y, z (FLOAT-LONG), speed modifier (0 = 1.0), max turn (degrees a tick), yaw (FLOAT-SHORT in and out):
*> - Nearer to the wanted point than sqrt(2.5E-7): no input. Otherwise the yaw turns toward atan2(dz, dx) - 90 degrees by at most the max turn, speed = modifier x flying_speed (bee 0.6,
*>   parrot 0.4, allay and the rest 0.1), and the vertical input is +speed when the point is above, -speed when below.
*> - moveRelative: the velocity (EN-VX, EN-VY, EN-VZ) gains (-sin yaw, 0, cos yaw) x speed and vy x speed more or less (input y x speed); the row moves by the velocity, each axis stopping at a solid
*>   cell (that component becomes 0); then the velocity is multiplied by 0.91 (air). There is no gravity. The pitch is sent as 0 (the pitch turn of the control is not done).
*> M44-FLY-SPEED USING species key, flying speed out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FLY-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-SPEED.
     EVALUATE L-KEY
         WHEN "bee" MOVE 0.6 TO L-SPEED
         WHEN "parrot" MOVE 0.4 TO L-SPEED
         WHEN OTHER MOVE 0.1 TO L-SPEED
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-FLY-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FLY-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-FLY                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-YAW-OUT             FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WX                   FLOAT-LONG.
 01 L-WY                   FLOAT-LONG.
 01 L-WZ                   FLOAT-LONG.
 01 L-MOD                  FLOAT-LONG.
 01 L-TURN                 FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-WX L-WY L-WZ L-MOD L-TURN L-YAW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "M44-FLY-SPEED" USING WS-KEY WS-FLY
     COMPUTE WS-DX = L-WX - EN-X(L-ROW)
     COMPUTE WS-DY = L-WY - EN-Y(L-ROW)
     COMPUTE WS-DZ = L-WZ - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     MOVE L-YAW TO WS-YAW
     IF WS-D2 >= 0.00000025
         COMPUTE WS-TARGET = FUNCTION ATAN(WS-DZ / WS-DX) * 180 / FUNCTION PI
         IF WS-DX = 0
             MOVE 90 TO WS-TARGET
             IF WS-DZ < 0
                 MOVE -90 TO WS-TARGET
             END-IF
         ELSE
             IF WS-DX < 0
                 IF WS-DZ >= 0
                     COMPUTE WS-TARGET = WS-TARGET + 180
                 ELSE
                     COMPUTE WS-TARGET = WS-TARGET - 180
                 END-IF
             END-IF
         END-IF
         COMPUTE WS-TARGET = WS-TARGET - 90
         COMPUTE WS-DIFF = WS-TARGET - WS-YAW
         PERFORM UNTIL WS-DIFF <= 180
             SUBTRACT 360 FROM WS-DIFF
         END-PERFORM
         PERFORM UNTIL WS-DIFF >= -180
             ADD 360 TO WS-DIFF
         END-PERFORM
         IF WS-DIFF > L-TURN
             MOVE L-TURN TO WS-DIFF
         END-IF
         IF WS-DIFF < - L-TURN
             COMPUTE WS-DIFF = - L-TURN
         END-IF
         COMPUTE WS-YAW = WS-YAW + WS-DIFF
         MOVE L-MOD TO WS-SPEED
         IF WS-SPEED = 0
             MOVE 1.0 TO WS-SPEED
         END-IF
         COMPUTE WS-SPEED = WS-SPEED * WS-FLY
         COMPUTE WS-RAD = WS-YAW * FUNCTION PI / 180
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - FUNCTION SIN(WS-RAD) * WS-SPEED
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-RAD) * WS-SPEED
         IF WS-DY > 0
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-SPEED * WS-SPEED
         END-IF
         IF WS-DY < 0
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - WS-SPEED * WS-SPEED
         END-IF
     END-IF
     MOVE WS-YAW TO WS-YAW-OUT
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     COMPUTE WS-NEW = WS-Y + EN-VY(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X WS-NEW WS-Z WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-Y
     ELSE
         MOVE 0 TO EN-VY(L-ROW)
     END-IF
     COMPUTE WS-NEW = WS-X + EN-VX(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-NEW WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-X
     ELSE
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-NEW = WS-Z + EN-VZ(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X WS-Y WS-NEW WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-Z
     ELSE
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.91
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.91
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.91
     IF WS-X NOT = EN-X(L-ROW) OR WS-Y NOT = EN-Y(L-ROW) OR WS-Z NOT = EN-Z(L-ROW) OR WS-YAW-OUT NOT = EN-YAW(L-ROW)
         CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW-OUT WS-PITCH WS-GROUND
     END-IF
     MOVE WS-YAW-OUT TO L-YAW
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     GOBACK.
 END PROGRAM M44-FLY-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FLY-TICK.
*> USING row, yaw (FLOAT-SHORT in and out), flier out (1 when the row is a bee, allay or parrot and has moved by the flying control, else 0 and nothing happens).
*> The wanted point: the middle of the target player (y + 0.9) at speed modifier 1.4 for a bee with a target (BeeAttack); otherwise the point of EN-FLY-X/Y/Z, which a stroll picks again
*> (RandomStroll.fly: up to 8 blocks in x and z and 3 in y around the row, modifier 1.0) when there is none or the row is within half a block of it. Max turn 20 degrees (bee, allay), 10 (parrot).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TURN                FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-FLIER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-YAW L-FLIER.
     MOVE 0 TO L-FLIER
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "bee" OR "allay" OR "parrot"
         MOVE 1 TO L-FLIER
         MOVE 20 TO WS-TURN
         IF WS-KEY = "parrot"
             MOVE 10 TO WS-TURN
         END-IF
         MOVE EN-TARGET(L-ROW) TO WS-P
         IF WS-KEY = "bee" AND WS-P > 0
             MOVE PL-X(WS-P) TO EN-FLY-X(L-ROW)
             COMPUTE EN-FLY-Y(L-ROW) = PL-Y(WS-P) + 0.9
             MOVE PL-Z(WS-P) TO EN-FLY-Z(L-ROW)
             MOVE 1.4 TO EN-FLY-MOD(L-ROW)
             MOVE 1 TO EN-FLY-ON(L-ROW)
         ELSE
             COMPUTE WS-D2 = (EN-FLY-X(L-ROW) - EN-X(L-ROW)) ** 2 + (EN-FLY-Y(L-ROW) - EN-Y(L-ROW)) ** 2
                 + (EN-FLY-Z(L-ROW) - EN-Z(L-ROW)) ** 2
             IF EN-FLY-ON(L-ROW) = 0 OR WS-D2 < 0.25
                 MOVE EN-ID(L-ROW) TO WS-ARG(1)
                 MOVE CW-TIME TO WS-ARG(2)
                 MOVE 81 TO WS-ARG(3)
                 CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
                 COMPUTE EN-FLY-X(L-ROW) = EN-X(L-ROW) + FUNCTION MOD(WS-R, 17) - 8
                 COMPUTE WS-Q = WS-R / 17
                 COMPUTE EN-FLY-Z(L-ROW) = EN-Z(L-ROW) + FUNCTION MOD(WS-Q, 17) - 8
                 COMPUTE WS-Q = WS-Q / 17
                 COMPUTE EN-FLY-Y(L-ROW) = EN-Y(L-ROW) + FUNCTION MOD(WS-Q, 7) - 3
                 MOVE 1.0 TO EN-FLY-MOD(L-ROW)
                 MOVE 1 TO EN-FLY-ON(L-ROW)
             END-IF
         END-IF
         CALL "M44-FLY-MOVE" USING L-ROW EN-FLY-X(L-ROW) EN-FLY-Y(L-ROW) EN-FLY-Z(L-ROW) EN-FLY-MOD(L-ROW) WS-TURN L-YAW
     END-IF
     GOBACK.
 END PROGRAM M44-FLY-TICK.
