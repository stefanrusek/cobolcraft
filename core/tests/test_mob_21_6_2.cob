*> Implementation test (002-lane-mobsfull-h19; docs/protocol/21 section 6.2 Shulker and shulker bullet with 44 part 9 section 11.2): the shulker row (health 30, XP 5, monster, it
*> does not walk), the attack goal (the start opens the lid to raw peek 100 and sets attackTime 20, a bullet leaves when it runs out, then attackTime = 20 + nextInt(10) x 10; a target
*> beyond 20 blocks is dropped and the lid closes), the bullet (selectNextMoveDirection with the worked example E12, targetDelta of length 0.15, flightSteps 10 to 50; the velocity moves
*> a fifth of the way to a targetDelta that grows by 1.025 a tick; gravity without a target; the next direction when the steps run out or the way is blocked; a hit does 4 damage
*> and Levitation for 200 ticks; a block hit removes it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-6-2.
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
 01 WS-BULLET-TYPE         BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 4.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
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
 01 WS-AXIS                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-EFFECT              BINARY-LONG VALUE 24.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
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
     MOVE "minecraft:shulker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "PROJ-TYPE" USING WS-KIND WS-BULLET-TYPE
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 2 TO BW-DIFFICULTY

     MOVE "acceptance US15 21§6.2 minecraft:shulker has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 minecraft:shulker max health 30" TO WS-CASE
     MOVE 30 TO WS-EXP
     MOVE SM-HEALTH(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 minecraft:shulker XP 5" TO WS-CASE
     MOVE 5 TO WS-EXP
     MOVE SM-XP(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 minecraft:shulker is a monster that does not walk" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF SM-KIND(WS-M) = 1 AND SM-WALK-MILLI(WS-M) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The attack goal: the shulker 10 blocks west of the player.
     COMPUTE WS-SX = WS-X - 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-SX WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§6.2 shulker: starting the attack opens the lid (raw peek 100)" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: attackTime 20 at the start" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: the peek goes to the viewers as metadata index 17" TO WS-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 20
         CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-BULLETS
     MOVE "acceptance US15 21§6.2 shulker: no bullet before attackTime runs out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     PERFORM COUNT-BULLETS
     MOVE "acceptance US15 21§6.2 shulker: a bullet when attackTime reaches 0" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: attackTime is then 20 + nextInt(10) x 10" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-SHOOT-TIME(WS-ROW) >= 20 AND EN-SHOOT-TIME(WS-ROW) <= 110 AND FUNCTION MOD(EN-SHOOT-TIME(WS-ROW), 10) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: the bullet is owned by the shulker" TO WS-CASE
     MOVE EN-ID(WS-ROW) TO WS-EXP
     MOVE EN-TARGET-ID(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: the bullet homes on the player" TO WS-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-EXP
     MOVE EN-FOE-ID(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: the bullet starts at rest" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION ABS(EN-VX(WS-B)) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: flightSteps is 10, 20, 30, 40 or 50" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-DELAY(WS-B) >= 10 AND EN-DELAY(WS-B) <= 50 AND FUNCTION MOD(EN-DELAY(WS-B), 10) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: targetDelta has length 0.15 (x 1000)" TO WS-CASE
     MOVE 150 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION SQRT(EN-WANDER-X(WS-B) ** 2 + EN-FLEE-Z(WS-B) ** 2 + EN-WANDER-Z(WS-B) ** 2) * 1000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-B
*>   A target beyond 20 blocks (distance squared 400) is dropped and the lid closes.
     COMPUTE PL-X(WS-PLAYER) = WS-SX + 25
     CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§6.2 shulker: a target beyond 20 blocks is dropped" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-TARGET(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker: dropping the target closes the lid (peek 0)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Without a target (the lid already closed) nothing happens; with the lid open it closes.
     MOVE 100 TO EN-VARIANT(WS-ROW)
     CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§6.2 shulker: no target closes an open lid" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SHULKER-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§6.2 shulker: no target and a closed lid stay as they are" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-X TO PL-X(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   selectNextMoveDirection, worked example E12: bullet in block (bx, by, bz), the player's block 4 to the east in the same row: EAST, targetDelta (0.15, 0, 0).
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) - 8
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) + 8
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-SX = WS-BX + 0.5
     COMPUTE WS-DY = WS-BY + 0.5
     COMPUTE WS-DZ = WS-BZ + 0.5
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-OWNER
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-DZ WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FOE-ID(WS-B)
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 4.5
     COMPUTE PL-Y(WS-PLAYER) = WS-BY - 0.5
     MOVE WS-DZ TO PL-Z(WS-PLAYER)
     MOVE 0 TO WS-AXIS
     CALL "BULLET-SELECT" USING WS-B WS-AXIS
     MOVE "acceptance US15 44-9§E12 shulker bullet: the direction toward the target is EAST (6)" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE EN-VARIANT(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§E12 shulker bullet: targetDelta x is 0.15" TO WS-CASE
     MOVE 1500 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-WANDER-X(WS-B) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§E12 shulker bullet: targetDelta y and z are 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION ABS(EN-FLEE-Z(WS-B)) * 10000 + FUNCTION ABS(EN-WANDER-Z(WS-B)) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§E12 shulker bullet: flightSteps 10 + 10 x nextInt(5)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-DELAY(WS-B) >= 10 AND EN-DELAY(WS-B) <= 50 AND FUNCTION MOD(EN-DELAY(WS-B), 10) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   One tick of flight: targetDelta x 1.025 = 0.15375 and the velocity moves a fifth of the way: 0.03075; flightSteps counts down.
     MOVE 10 TO EN-DELAY(WS-B)
     MOVE 0 TO EN-VX(WS-B) EN-VY(WS-B) EN-VZ(WS-B)
     CALL "PROJ-STEP" USING WS-B
     MOVE "acceptance US15 44-9§11.2 shulker bullet: the velocity moves a fifth of the way (0.03075)" TO WS-CASE
     MOVE 3075 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-B) * 100000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: it moved by that velocity" TO WS-CASE
     MOVE 3075 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-X(WS-B) - WS-SX) * 100000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: targetDelta grows by 1.025 (0.15375)" TO WS-CASE
     MOVE 15375 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-WANDER-X(WS-B) * 100000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: flightSteps counts down" TO WS-CASE
     MOVE 9 TO WS-EXP
     MOVE EN-DELAY(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   flightSteps 1: it runs out and the next direction is chosen (axis of the current direction EAST = X): the bullet is now close to the target row.
     MOVE 1 TO EN-DELAY(WS-B)
     MOVE 6 TO EN-VARIANT(WS-B)
     CALL "PROJ-STEP" USING WS-B
     MOVE "acceptance US15 44-9§11.2 shulker bullet: flightSteps 0 draws new steps (10 to 50)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-DELAY(WS-B) >= 10 AND EN-DELAY(WS-B) <= 50
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The cell ahead is solid: the next direction is chosen at once.
     MOVE 30 TO EN-DELAY(WS-B)
     MOVE 6 TO EN-VARIANT(WS-B)
     COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-B)) + 1
     MOVE WS-BY TO WS-FY
     MOVE WS-BZ TO WS-FZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     MOVE 0 TO EN-VX(WS-B)
     MOVE WS-SX TO EN-X(WS-B)
     CALL "PROJ-STEP" USING WS-B
     MOVE "acceptance US15 44-9§11.2 shulker bullet: a solid cell ahead chooses a new direction at once" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-DELAY(WS-B) >= 10 AND EN-DELAY(WS-B) <= 50 AND EN-VARIANT(WS-B) NOT = 6
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The same with every direction toward the target blocked: the candidate list is empty and a random direction is drawn (up to 5 redraws).
     MOVE 0 TO WS-AXIS
*>   Stone in all six neighbours of the bullet's cell: every redraw names a blocked cell, so the 5 redraws are used.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-B))
         COMPUTE WS-FY = FUNCTION INTEGER(EN-Y(WS-B))
         COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-B))
         EVALUATE WS-I
             WHEN 1
                 SUBTRACT 1 FROM WS-FY
             WHEN 2
                 ADD 1 TO WS-FY
             WHEN 3
                 SUBTRACT 1 FROM WS-FZ
             WHEN 4
                 ADD 1 TO WS-FZ
             WHEN 5
                 SUBTRACT 1 FROM WS-FX
             WHEN OTHER
                 ADD 1 TO WS-FX
         END-EVALUATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     END-PERFORM
     CALL "BULLET-SELECT" USING WS-B WS-AXIS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-B))
         COMPUTE WS-FY = FUNCTION INTEGER(EN-Y(WS-B))
         COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-B))
         EVALUATE WS-I
             WHEN 1
                 SUBTRACT 1 FROM WS-FY
             WHEN 2
                 ADD 1 TO WS-FY
             WHEN 3
                 SUBTRACT 1 FROM WS-FZ
             WHEN 4
                 ADD 1 TO WS-FZ
             WHEN 5
                 SUBTRACT 1 FROM WS-FX
             WHEN OTHER
                 ADD 1 TO WS-FX
         END-EVALUATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     END-PERFORM
     MOVE "acceptance US15 44-9§11.2 shulker bullet: an empty candidate list still draws a direction (1 to 6)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VARIANT(WS-B) >= 1 AND EN-VARIANT(WS-B) <= 6
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
*>   Within 2 blocks of the target's centre there is no direction: the aim is the target point.
     COMPUTE PL-X(WS-PLAYER) = WS-SX + 1
     MOVE 0 TO WS-AXIS
     MOVE WS-SX TO EN-X(WS-B)
     CALL "BULLET-SELECT" USING WS-B WS-AXIS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: close to the target there is no direction" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: close to the target the aim delta has length 0.15" TO WS-CASE
     MOVE 150 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(FUNCTION SQRT(EN-WANDER-X(WS-B) ** 2 + EN-FLEE-Z(WS-B) ** 2 + EN-WANDER-Z(WS-B) ** 2) * 1000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Targets above and below and in front of the bullet pick the other axes (north, south, up, down, west).
     COMPUTE PL-X(WS-PLAYER) = WS-SX - 4
     COMPUTE PL-Y(WS-PLAYER) = WS-BY + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-DZ + 4
     CALL "BULLET-SELECT" USING WS-B WS-AXIS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: a target west, above, south gives one of those" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VARIANT(WS-B) = 5 OR EN-VARIANT(WS-B) = 2 OR EN-VARIANT(WS-B) = 4
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE PL-X(WS-PLAYER) = WS-SX + 4
     COMPUTE PL-Y(WS-PLAYER) = WS-BY - 4.5
     COMPUTE PL-Z(WS-PLAYER) = WS-DZ - 4
     CALL "BULLET-SELECT" USING WS-B WS-AXIS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: a target east, below and north gives one of those" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VARIANT(WS-B) = 6 OR EN-VARIANT(WS-B) = 1 OR EN-VARIANT(WS-B) = 3
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-B

*>   BULLET-STEER with each direction and the bullet in the target's row on that axis: the next direction is drawn at once (flightSteps a multiple of 10).
     CALL "ENTITY-REMOVE" USING WS-B
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-DZ WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FOE-ID(WS-B)
     COMPUTE EN-X(WS-B) = WS-BX + 0.5
     COMPUTE EN-Y(WS-B) = WS-BY + 0.5
     COMPUTE EN-Z(WS-B) = WS-BZ + 0.5
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 4.5
     COMPUTE PL-Y(WS-PLAYER) = WS-BY - 0.5
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 0.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-I TO EN-VARIANT(WS-B)
         MOVE 31 TO EN-DELAY(WS-B)
         CALL "BULLET-STEER" USING WS-B
         MOVE "acceptance US15 44-9§11.2 shulker bullet: in the target's row it picks a new direction" TO WS-CASE
         MOVE 1 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF FUNCTION MOD(EN-DELAY(WS-B), 10) = 0 OR WS-I > 4
             MOVE 1 TO WS-OBS
         END-IF
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     END-PERFORM
*>   The bullet in the target's column on X (direction EAST): a new direction at once.
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 0.5
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 4.5
     MOVE 6 TO EN-VARIANT(WS-B)
     MOVE 31 TO EN-DELAY(WS-B)
     CALL "BULLET-STEER" USING WS-B
     MOVE "acceptance US15 44-9§11.2 shulker bullet: in the target's column it picks a new direction" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION MOD(EN-DELAY(WS-B), 10)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-B
*>   The axis of each direction: none 0, DOWN and UP Y (2), NORTH and SOUTH Z (3), WEST and EAST X (1).
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 6
         CALL "BULLET-AXIS" USING WS-I WS-AXIS
         MOVE "acceptance US15 44-9§11.2 shulker bullet: the axis of a direction" TO WS-CASE
         EVALUATE WS-I
             WHEN 0
                 MOVE 0 TO WS-EXP
             WHEN 1
             WHEN 2
                 MOVE 2 TO WS-EXP
             WHEN 3
             WHEN 4
                 MOVE 3 TO WS-EXP
             WHEN OTHER
                 MOVE 1 TO WS-EXP
         END-EVALUATE
         MOVE WS-AXIS TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     END-PERFORM
*>   Without a target (the entity is gone): gravity 0.04 and no steering.
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-DZ WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE 999999 TO EN-FOE-ID(WS-B)
     MOVE 0 TO EN-VX(WS-B) EN-VY(WS-B) EN-VZ(WS-B)
     CALL "PROJ-STEP" USING WS-B
     MOVE "acceptance US15 44-9§11.2 shulker bullet: a target that is gone is forgotten" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-FOE-ID(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-9§11.2 shulker bullet: without a target it falls (vy -0.04)" TO WS-CASE
     MOVE -400 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-B) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-B

*>   A hit on the player: 4 damage and Levitation for 200 ticks; the bullet is gone.
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     COMPUTE WS-SX = WS-X + 3
     COMPUTE WS-DY = WS-Y + 1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-Z WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FOE-ID(WS-B)
     MOVE 1 TO EN-VARIANT(WS-B)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO WS-DX
     COMPUTE WS-DX = -1
     MOVE -0.5 TO EN-VX(WS-B)
     MOVE 0 TO EN-VY(WS-B) EN-VZ(WS-B)
     MOVE -0.15 TO EN-WANDER-X(WS-B)
     MOVE 0 TO EN-FLEE-Z(WS-B) EN-WANDER-Z(WS-B)
     MOVE 50 TO EN-DELAY(WS-B)
     MOVE 5 TO EN-VARIANT(WS-B)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-USED(WS-B) = 0
         CALL "PROJ-STEP" USING WS-B
     END-PERFORM
     MOVE "acceptance US15 21§6.2 shulker bullet: a hit removes the bullet" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§6.2 shulker bullet: a hit does 4 damage" TO WS-CASE
     MOVE 16 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-EFFECT WS-LEVEL WS-TICKS
     MOVE "acceptance US15 21§6.2 shulker bullet: Levitation for 200 ticks (amplifier 0)" TO WS-CASE
     MOVE 200 TO WS-EXP
     MOVE WS-TICKS TO WS-OBS
     IF WS-LEVEL NOT = 1
         MOVE -1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "EFFECT-CLEAR-ALL" USING WS-PLAYER

*>   A hit on a mob (a cow): 4 damage, no effect needed; into stone: the bullet is removed.
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-SX = WS-X - 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-SX WS-Y WS-Z WS-YAW WS-ROW
     MOVE 10 TO EN-HEALTH(WS-ROW)
     COMPUTE WS-SX = WS-X - 3
     COMPUTE WS-DY = WS-Y + 1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-Z WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE -0.5 TO EN-VX(WS-B)
     MOVE 0 TO EN-VY(WS-B) EN-VZ(WS-B)
     MOVE 0 TO EN-FOE-ID(WS-B)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-USED(WS-B) = 0
         CALL "PROJ-STEP" USING WS-B
     END-PERFORM
     MOVE "acceptance US15 21§6.2 shulker bullet: a hit on a mob does 4 damage" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) + 3
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + 5
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     COMPUTE WS-SX = WS-FX + 0.5
     COMPUTE WS-DY = WS-FY + 0.5
     COMPUTE WS-DZ = WS-FZ - 2
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-DY WS-DZ WS-DX WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-B
     MOVE 0 TO EN-VX(WS-B) EN-VY(WS-B)
     MOVE 0.5 TO EN-VZ(WS-B)
     MOVE 0 TO EN-FOE-ID(WS-B)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-USED(WS-B) = 0
         CALL "PROJ-STEP" USING WS-B
     END-PERFORM
     MOVE "acceptance US15 21§6.2 shulker bullet: a block hit removes it" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-B) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR

*>   Through MOB-STEP: the shulker takes the player (within 16 blocks), opens and shoots on tick 21.
     COMPUTE WS-SX = WS-X - 10
     MOVE "minecraft:shulker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-SX WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     PERFORM COUNT-BULLETS
     MOVE "acceptance US15 21§6.2 shulker: MOB-STEP shoots a bullet on tick 21" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 COUNT-BULLETS.
     MOVE 0 TO WS-COUNT WS-B
     PERFORM VARYING WS-OK FROM 1 BY 1 UNTIL WS-OK > EN-COUNT
         IF EN-USED(WS-OK) = 1 AND EN-TYPE(WS-OK) = WS-BULLET-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-OK TO WS-B
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-21-6-2.

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
