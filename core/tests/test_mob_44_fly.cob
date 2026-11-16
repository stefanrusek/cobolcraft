*> Implementation test (US15; docs/protocol/18-mob-framework.md FlyingMoveControl and travelFlying): the flying move of allay, bee and parrot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-FLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-BEE                BINARY-LONG.
 01 WS-WX                 FLOAT-LONG.
 01 WS-WY                 FLOAT-LONG.
 01 WS-WZ                 FLOAT-LONG.
 01 WS-MOD                FLOAT-LONG.
 01 WS-TURN               FLOAT-LONG.
 01 WS-Y0                 FLOAT-LONG.
 01 WS-IX                 BINARY-LONG.
 01 WS-IY                 BINARY-LONG.
 01 WS-IZ                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-YAWF               FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     COMPUTE WS-FY = PL-Y(WS-PLAYER) + 12
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:bee" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-BEE
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     MOVE 1.0 TO WS-MOD
     MOVE 20 TO WS-TURN
     MOVE 0 TO WS-YAWF
*>   At the wanted point nothing is added; the velocity only decays by 0.91.
     MOVE 0.5 TO EN-VZ(WS-BEE)
     MOVE WS-FX TO WS-WX
     MOVE WS-FY TO WS-WY
     MOVE WS-FZ TO WS-WZ
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 FlyingMoveControl: at the wanted point the velocity decays by 0.91 (0.5 to 0.455)" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-VZ(WS-BEE) * 1000
     MOVE 455 TO WS-E
     PERFORM CHECK-N
*>   The yaw turns toward the target by at most maxTurn: a target at +x is yaw -90, the bee starts at 0 and turns 20.
     MOVE WS-FY TO EN-Y(WS-BEE)
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     COMPUTE WS-WX = WS-FX + 10
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 FlyingMoveControl: the yaw turns by at most maxTurn (20) toward -90" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-YAWF
     MOVE -20 TO WS-E
     PERFORM CHECK-N
*>   Acceleration: speed = modifier x flying_speed along the yaw; the bee 0.6 flying speed: vz before drag with yaw 0 toward +z.
     MOVE WS-FX TO EN-X(WS-BEE)
     MOVE WS-FY TO EN-Y(WS-BEE)
     MOVE WS-FZ TO EN-Z(WS-BEE)
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     MOVE WS-FX TO WS-WX
     COMPUTE WS-WZ = WS-FZ + 10
     MOVE 0 TO WS-YAWF
     MOVE 0.1 TO WS-MOD
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 travelFlying: modifier 0.1 x flying speed 0.6 = 0.06 along +z, then x 0.91 = 0.0546" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-VZ(WS-BEE) * 10000
     MOVE 546 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18 travelFlying: the bee moved by that velocity before the drag (z + 0.06)" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-Z(WS-BEE) - WS-FZ) * 1000
     MOVE 60 TO WS-E
     PERFORM CHECK-N
*>   Vertical: a target above gives yya = +speed (vy += speed x speed = 0.0036 before drag).
     MOVE WS-FY TO EN-Y(WS-BEE)
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     MOVE WS-FX TO WS-WX
     COMPUTE WS-WY = WS-FY + 5
     MOVE WS-FZ TO WS-WZ
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 FlyingMoveControl: a target above lifts the bee (vy > 0)" TO WS-CASE
     MOVE 0 TO WS-O
     IF EN-VY(WS-BEE) > 0
         MOVE 1 TO WS-O
     END-IF
     MOVE 1 TO WS-E
     PERFORM CHECK-N
*>   No gravity: a bee with no wanted point keeps its height.
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     MOVE EN-Y(WS-BEE) TO WS-Y0
     MOVE EN-X(WS-BEE) TO WS-WX
     MOVE EN-Y(WS-BEE) TO WS-WY
     MOVE EN-Z(WS-BEE) TO WS-WZ
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 travelFlying: gravity is not applied while flying" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-Y(WS-BEE) - WS-Y0) * 1000
     MOVE 0 TO WS-E
     PERFORM CHECK-N
*>   A wall stops the move: the player floor is at 12 blocks below; a target far below is blocked by the ground (the bee stays above it).
     COMPUTE WS-IX = FUNCTION INTEGER(WS-FX) - 4
     COMPUTE WS-IZ = FUNCTION INTEGER(WS-FZ) - 4
     COMPUTE WS-IY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     MOVE 9 TO WS-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-IX WS-IZ WS-SIZE WS-IY WS-KIND
     COMPUTE EN-Y(WS-BEE) = WS-IY + 1
     MOVE 0 TO EN-VX(WS-BEE) EN-VZ(WS-BEE)
     MOVE -1 TO EN-VY(WS-BEE)
     MOVE EN-X(WS-BEE) TO WS-WX
     COMPUTE WS-WY = WS-FY - 50
     MOVE EN-Z(WS-BEE) TO WS-WZ
     CALL "M44-FLY-MOVE" USING WS-BEE WS-WX WS-WY WS-WZ WS-MOD WS-TURN WS-YAWF
     MOVE "acceptance US15 18 travelFlying: a move into the ground is blocked (vy 0 and the bee stays above the floor)" TO WS-CASE
     MOVE 0 TO WS-O
     IF EN-VY(WS-BEE) = 0 AND EN-Y(WS-BEE) > WS-IY
         MOVE 1 TO WS-O
     END-IF
     MOVE 1 TO WS-E
     PERFORM CHECK-N
*>   The tick: a bee without a wanted point picks one (8 blocks at most in x and z, 3 in y) and flies; reaching it picks another.
     MOVE 0 TO EN-FLY-ON(WS-BEE)
     MOVE 0 TO EN-VX(WS-BEE) EN-VY(WS-BEE) EN-VZ(WS-BEE)
     COMPUTE EN-Y(WS-BEE) = WS-IY + 6
     MOVE WS-FX TO EN-X(WS-BEE)
     MOVE WS-FZ TO EN-Z(WS-BEE)
     MOVE 0 TO WS-YAWF
     CALL "M44-FLY-TICK" USING WS-BEE WS-YAWF WS-WALK
     MOVE "acceptance US15 18 RandomStroll.fly: a flier without a wanted point picks one and flies (flag 1, walk 1)" TO WS-CASE
     COMPUTE WS-O = EN-FLY-ON(WS-BEE) * 10 + WS-WALK
     MOVE 11 TO WS-E
     PERFORM CHECK-N
     MOVE "acceptance US15 18 RandomStroll.fly: the picked point is within 8 blocks in x and z and 3 in y" TO WS-CASE
     MOVE 0 TO WS-O
     IF FUNCTION ABS(EN-FLY-X(WS-BEE) - WS-FX) <= 8 AND FUNCTION ABS(EN-FLY-Z(WS-BEE) - WS-FZ) <= 8
             AND FUNCTION ABS(EN-FLY-Y(WS-BEE) - EN-Y(WS-BEE)) <= 3
         MOVE 1 TO WS-O
     END-IF
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE EN-X(WS-BEE) TO EN-FLY-X(WS-BEE)
     MOVE EN-Y(WS-BEE) TO EN-FLY-Y(WS-BEE)
     MOVE EN-Z(WS-BEE) TO EN-FLY-Z(WS-BEE)
     CALL "M44-FLY-TICK" USING WS-BEE WS-YAWF WS-WALK
     MOVE "acceptance US15 18 RandomStroll.fly: standing on the point it picks a new one (the old flag stays 1)" TO WS-CASE
     MOVE EN-FLY-ON(WS-BEE) TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
*>   A target player is the wanted point (the bee attack), the player's middle (y + 0.9).
     MOVE WS-PLAYER TO EN-TARGET(WS-BEE)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-BEE)
     CALL "M44-FLY-TICK" USING WS-BEE WS-YAWF WS-WALK
     MOVE "acceptance US15 18 BeeAttack: with a target the wanted point is the target's middle" TO WS-CASE
     COMPUTE WS-O ROUNDED = (EN-FLY-Y(WS-BEE) - PL-Y(WS-PLAYER)) * 10
     MOVE 9 TO WS-E
     PERFORM CHECK-N
*>   Species that do not fly are left alone.
     MOVE "minecraft:cow" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     CALL "M44-FLY-TICK" USING WS-ROW WS-YAWF WS-WALK
     MOVE "acceptance US15 18 travelFlying: a cow is not a flier (walk 0)" TO WS-CASE
     MOVE WS-WALK TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-FLY.
 COPY CORETEST.
 COPY MOBSPTEST.
