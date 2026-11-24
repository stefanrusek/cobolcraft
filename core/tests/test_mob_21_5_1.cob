*> Implementation test (002-lane-mobsfull-h19; docs/protocol/21 section 5.1 Ghast with doc 44 part 6 section 9.1): the ghast row (health 10, follow range 100, XP 5,
*> not in Peaceful), the shoot goal (charge 1 a tick with a target in 64 blocks and in sight, the warning at 10, the fireball at 20 from 4 blocks ahead at half height + 0.5,
*> then chargeTime -40; a positive charge decays without a target; the charging flag while chargeTime > 10), the move control (floatDuration, thrust 0.1 along the way to the
*> wanted point, drag 0.91, a blocked way drops the point, a new point within the cube of 16) and the target (dy within 4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FB-TYPE             BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FB                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "PROJ-TYPE" USING WS-KIND WS-FB-TYPE
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 2 TO BW-DIFFICULTY

*>   The row.
     MOVE "acceptance US15 21§5.1 minecraft:ghast has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 minecraft:ghast max health 10" TO WS-CASE
     MOVE 10 TO WS-EXP
     MOVE SM-HEALTH(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 minecraft:ghast follow range 100" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE SM-FOLLOW(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 minecraft:ghast XP 5" TO WS-CASE
     MOVE 5 TO WS-EXP
     MOVE SM-XP(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 minecraft:ghast is a monster (not in Peaceful)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE SM-KIND(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The shoot goal: the ghast 12 blocks west of the player at +3, facing the player (yaw -90 faces +x).
     COMPUTE WS-GX = WS-X - 12
     COMPUTE WS-GY = WS-Y + 3
     MOVE WS-Z TO WS-GZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE -90 TO EN-YAW(WS-ROW)
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         CALL "GHAST-SHOOT" USING WS-ROW WS-M
     END-PERFORM
     MOVE "acceptance US15 21§5.1 ghast: chargeTime counts 1 a tick" TO WS-CASE
     MOVE 9 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: not charging (flag 0) up to chargeTime 10" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.1 ghast: charging flag (metadata 16) while chargeTime > 10" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the charging flag goes to the viewers as metadata index 16" TO WS-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 12 BY 1 UNTIL WS-I > 19
         CALL "GHAST-SHOOT" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.1 ghast: no fireball before chargeTime 20" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.1 ghast: a fireball at chargeTime 20" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: chargeTime -40 after the shot" TO WS-CASE
     MOVE -40 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the charging flag is off after the shot" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the fireball starts 4 blocks ahead (x)" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-X(WS-FB) - EN-X(WS-ROW) + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the fireball starts at half height + 0.5 (y + 2.5)" TO WS-CASE
     MOVE 25 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-Y(WS-FB) - EN-Y(WS-ROW)) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the fireball flies toward the player (vx > 0)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VX(WS-FB) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the fireball has explosion power 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-ITEM(WS-FB) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the ghast owns the fireball" TO WS-CASE
     MOVE EN-ID(WS-ROW) TO WS-EXP
     MOVE EN-TARGET-ID(WS-FB) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FB
*>   The next shot: chargeTime from -40 to 20 takes 60 ticks.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 59
         CALL "GHAST-SHOOT" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.1 ghast: no second fireball 59 ticks after the first" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.1 ghast: the second fireball 60 ticks after the first" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FB
*>   Without a target a positive chargeTime decays by 1 a tick.
     MOVE 15 TO EN-SHOOT-TIME(WS-ROW)
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.1 ghast: without a target the charge decays by 1" TO WS-CASE
     MOVE 14 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the charging flag follows the decaying charge" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -5 TO EN-SHOOT-TIME(WS-ROW)
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.1 ghast: a negative charge is left alone without a target" TO WS-CASE
     MOVE -5 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A target beyond 64 blocks (distance squared 4096) is not shot at: the charge decays.
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     MOVE 7 TO EN-SHOOT-TIME(WS-ROW)
     COMPUTE PL-X(WS-PLAYER) = WS-GX + 70
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.1 ghast: a target 70 blocks away is not shot at" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-X TO PL-X(WS-PLAYER)
*>   No line of sight: a stone block between them.
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 3
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 2
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ) + WS-I
         PERFORM VARYING WS-COUNT FROM -3 BY 1 UNTIL WS-COUNT > 3
             COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 2 + WS-COUNT
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 7 TO EN-SHOOT-TIME(WS-ROW)
     CALL "GHAST-SHOOT" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.1 ghast: no line of sight, no charge" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ) + WS-I
         PERFORM VARYING WS-COUNT FROM -3 BY 1 UNTIL WS-COUNT > 3
             COMPUTE WS-FY = FUNCTION INTEGER(WS-GY) + 2 + WS-COUNT
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
         END-PERFORM
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The move control. Wanted point 10 blocks east, floatDuration 1: thrust 0.1 along the way, drag 0.91 after the move.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX + 10
     MOVE WS-GY TO EN-PH-TY(WS-ROW)
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     MOVE 0 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: the move control thrusts 0.1 and it moves by it" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-X(WS-ROW) - WS-GX) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: drag 0.91 leaves vx 0.091" TO WS-CASE
     MOVE 910 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: floatDuration is 2 to 6 after a thrust" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-PH-SCAN(WS-ROW) >= 2 AND EN-PH-SCAN(WS-ROW) <= 6
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   With floatDuration above 1 it only counts down and drifts.
     MOVE 5 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: floatDuration counts down without a thrust" TO WS-CASE
     MOVE 4 TO WS-EXP
     MOVE EN-PH-SCAN(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: the velocity decays by 0.91 (0.082810)" TO WS-CASE
     MOVE 828 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A way blocked by stone: no thrust, the wanted point is dropped.
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX + 10
     MOVE WS-GY TO EN-PH-TY(WS-ROW)
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     MOVE 0 TO EN-PH-SCAN(WS-ROW)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 4
     COMPUTE WS-FY = FUNCTION INTEGER(WS-GY)
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-GZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: a blocked way gives no thrust" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: a blocked way drops the wanted point" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Without a wanted point a new one is chosen in the cube of half side 16 around the ghast.
     MOVE 9 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: a new wanted point is set" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-PH-SET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-DX = FUNCTION ABS(EN-PH-TX(WS-ROW) - EN-X(WS-ROW))
     COMPUTE WS-DY = FUNCTION ABS(EN-PH-TY(WS-ROW) - EN-Y(WS-ROW))
     COMPUTE WS-DZ = FUNCTION ABS(EN-PH-TZ(WS-ROW) - EN-Z(WS-ROW))
     MOVE "acceptance US15 21§5.1 ghast: the new point is within 16 blocks on each axis" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-DX <= 16 AND WS-DY <= 16 AND WS-DZ <= 16
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A wanted point reached (distance squared below 1) is replaced.
     MOVE EN-X(WS-ROW) TO EN-PH-TX(WS-ROW)
     MOVE EN-Y(WS-ROW) TO EN-PH-TY(WS-ROW)
     MOVE EN-Z(WS-ROW) TO EN-PH-TZ(WS-ROW)
     MOVE 9 TO EN-PH-SCAN(WS-ROW)
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: a reached point is replaced" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-PH-TX(WS-ROW) NOT = EN-X(WS-ROW) OR EN-PH-TZ(WS-ROW) NOT = EN-Z(WS-ROW)
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Flying into stone stops it (the cell it would enter is solid): no move, no speed.
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE 1.2 TO EN-VX(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     COMPUTE EN-PH-TX(WS-ROW) = WS-GX + 10
     MOVE WS-GY TO EN-PH-TY(WS-ROW)
     MOVE WS-GZ TO EN-PH-TZ(WS-ROW)
     MOVE 9 TO EN-PH-SCAN(WS-ROW)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "GHAST-MOVE" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: a solid cell ahead stops it" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     COMPUTE WS-FX = FUNCTION INTEGER(WS-GX) + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The whole tick (MOB-STEP): the ghast takes the player as its target, looks at it, charges and fires on the 20th tick.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE 1000 TO EN-PH-SCAN(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.1 ghast: MOB-STEP targets the player and fires on tick 20" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 ghast: it faces the player (yaw -90 within 10 degrees)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-YAW(WS-ROW) < -80 AND EN-YAW(WS-ROW) > -100
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-FB
*>   A player more than 4 blocks above or below is not the target.
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-GY = WS-Y + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§5.1 ghast: a player 12 blocks lower is not the target (dy within 4)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 COUNT-FIREBALLS.
*>   Counts the fireball rows and leaves the last one in WS-FB.
     MOVE 0 TO WS-COUNT WS-FB
     PERFORM VARYING WS-OK FROM 1 BY 1 UNTIL WS-OK > EN-COUNT
         IF EN-USED(WS-OK) = 1 AND EN-TYPE(WS-OK) = WS-FB-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-OK TO WS-FB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-21-5-1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
