*> Acceptance test, the ender dragon's phases (docs/protocol/21 section 6.4.3, 44 part 9 sections 1.1 to 1.3; lane 002-lane-mobsb8, T9702): the nearest player, the holding pattern (new target,
*> landing approach chance), the strafe set-up (extra node at the player, yOffset), the strafe tick (no player, fireball after 5 charges, decay), the dragon fireball and its cloud, landing, takeoff,
*> sitting scanning/attacking/flaming (timers, the breath cloud), charging, dying and hovering, and the second tick after a phase change.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-DRAGON-PHASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-MAXD                FLOAT-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-CLOUDS0             BINARY-LONG.
 01 WS-CLOUDS1             BINARY-LONG.
 01 WS-BALLS               BINARY-LONG.
 01 WS-SEEN2               BINARY-LONG.
 01 WS-SEENH               BINARY-LONG.
 01 WS-BALL-ROW            BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The podium column: one stone block at (0, 200, 0): its surface is 201.
     MOVE 0 TO WS-SX WS-SZ
     MOVE 200 TO WS-SY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     MOVE 0 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE 0 TO FR-CRYSTALS
*>   The nearest player: 30 blocks east of the dragon.
     MOVE 30 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 40 TO WS-MAXD
     CALL "DRAGON-PLAYER-NEAR" USING WS-ROW WS-X WS-Y WS-Z WS-MAXD WS-FOUND
     MOVE "acceptance US16 21 6.4.3 a player 30 blocks away is the nearest within 40" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-MAXD
     CALL "DRAGON-PLAYER-NEAR" USING WS-ROW WS-X WS-Y WS-Z WS-MAXD WS-FOUND
     MOVE "acceptance US16 21 6.4.3 and none within 20" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The player far away for the pattern tests.
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
*>   Landing: far above the podium the target is the podium's bottom centre (0.5, 201, 0.5); within 1 block it sits down (SITTING_SCANNING, flame count reset) and scans once at once.
     MOVE 3 TO DG-PHASE
     MOVE 0.5 TO EN-X(WS-ROW)
     MOVE 210 TO EN-Y(WS-ROW)
     MOVE 0.5 TO EN-Z(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 landing: the target is the podium's bottom centre (y 201)" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-TY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 landing: still landing while far" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO DG-FLAMES
     MOVE 201.5 TO EN-Y(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 landing: arrival makes the phase SITTING_SCANNING (6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 landing: the flame count is reset" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-FLAMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 a phase changed by its own tick is ticked once more in the same tick (scan time 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-SCAN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Scanning with no player within 150 after 100 ticks: TAKEOFF.
     MOVE 6 TO DG-PHASE
     MOVE 99 TO DG-SCAN
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 scanning for 100 ticks with nobody within 150 blocks: TAKEOFF (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Scanning with a player 100 blocks away at 100 ticks: CHARGING_PLAYER toward the player.
     MOVE 100 TO PL-X(WS-PLAYER)
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 6 TO DG-PHASE
     MOVE 99 TO DG-SCAN
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 scanning for 100 ticks with a player 100 blocks away: CHARGING_PLAYER (8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the charge target is the player's position (x 100)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-TX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Scanning with a player within 20 x 10: after 25 ticks SITTING_ATTACKING; before, the dragon turns toward the player.
     MOVE 10 TO PL-X(WS-PLAYER)
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE 0 TO PL-Z(WS-PLAYER)
     MOVE 6 TO DG-PHASE
     MOVE 3 TO DG-SCAN
     MOVE 0 TO DG-YROT-A
     MOVE 0 TO EN-YAW(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 scanning with a player 10 blocks east and the dragon facing north: it turns (yRotA > 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-YROT-A > 0 AND DG-PHASE = 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO DG-SCAN
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 scanning time above 25 with a player close: SITTING_ATTACKING (7)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A player straight ahead needs no turning (angle below 10): the turn rate stays.
     MOVE 6 TO DG-PHASE
     MOVE 3 TO DG-SCAN
     MOVE 0 TO DG-YROT-A
     MOVE 0 TO PL-X(WS-PLAYER)
     MOVE -10 TO PL-Z(WS-PLAYER)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 a player straight ahead needs no turning" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-YROT-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Attacking (roar) lasts 40 ticks, then SITTING_FLAMING.
     MOVE 7 TO DG-PHASE
     MOVE 10 TO DG-ROAR
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 the roar is still going at 11 ticks" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 39 TO DG-ROAR
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 after 40 ticks of roaring: SITTING_FLAMING (5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 beginning the flaming counts a flame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-FLAMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Flaming: the breath cloud at tick 10; at tick 200 TAKEOFF after 4 flames, else scanning.
     MOVE 0 TO WS-CLOUDS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS0
         END-IF
     END-PERFORM
     MOVE 5 TO DG-PHASE
     MOVE 9 TO DG-FLAME-T
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE 0 TO WS-CLOUDS1
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS1
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.3 at flame tick 10 a breath cloud appears" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CLOUDS0 + 1
     MOVE WS-CLOUDS1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the breath cloud has radius 5, duration 200, scale 0.25 and instant damage" TO TL-CASE
     MOVE 5200250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-RADIUS(WS-SLOT) * 1000000 + PJ-DUR(WS-SLOT) * 1000 + PJ-SCALE(WS-SLOT) - 0
     COMPUTE TL-EXPECTED-N = 5 * 1000000 + 200 * 1000 + 250
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the breath effect is instant damage (6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE PJ-FX-ID(WS-SLOT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO DG-FLAMES
     MOVE 199 TO DG-FLAME-T
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 after 200 flame ticks and 4 flames: TAKEOFF (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO DG-PHASE
     MOVE 2 TO DG-FLAMES
     MOVE 199 TO DG-FLAME-T
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 after 200 flame ticks and fewer flames: SITTING_SCANNING (6)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Charging: no target, HOLDING_PATTERN; near the target the counter starts; at 10, HOLDING_PATTERN.
     MOVE 8 TO DG-PHASE
     MOVE 0 TO DG-HAS-TARGET DG-CHARGE-T
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 charging without a target: HOLDING_PATTERN" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO DG-PHASE
     MOVE 1 TO DG-HAS-TARGET
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 60 TO DG-TX
     MOVE 100 TO DG-TY
     MOVE 0 TO DG-TZ
     MOVE 0 TO DG-CHARGE-T DG-WALL
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 charging 60 blocks from the target keeps charging (counter 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-CHARGE-T TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 55 TO EN-X(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 within 10 blocks of the target the counter starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-CHARGE-T TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO DG-CHARGE-T
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 ten ticks after the counter started: HOLDING_PATTERN (or its landing approach roll)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-PHASE <= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Dying: arrival (within 10 blocks) sets health 0; far away the health is kept.
     MOVE 9 TO DG-PHASE
     MOVE 1 TO DG-HP
     MOVE 60 TO EN-X(WS-ROW)
     MOVE 150 TO EN-Y(WS-ROW)
     MOVE 60 TO EN-Z(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 dying: while still flying toward the podium the health stays 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 205 TO EN-Y(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 dying: on arrival the health is set to 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hovering: the target is the dragon's own position.
     MOVE 10 TO DG-PHASE
     MOVE 0 TO DG-HAS-TARGET
     MOVE 7 TO EN-X(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 hovering: the target is its own position" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-TX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Takeoff: the first tick makes a path to the node nearest to 40 blocks ahead (yaw 90 = east: node 12 at x 40), then it leaves for HOLDING_PATTERN once 10 blocks from the podium.
     MOVE 4 TO DG-PHASE
     MOVE 0 TO DG-HAS-TARGET DG-HAS-PATH DG-CHARGE-T
     MOVE 90 TO EN-YAW(WS-ROW)
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 206 TO EN-Y(WS-ROW)
     MOVE 3 TO FR-CRYSTALS
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 takeoff: the target is on the way toward the node ahead (an inner or outer ring node east)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-HAS-TARGET = 1 AND DG-CHARGE-T = 1 AND DG-PHASE = 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 230 TO EN-Y(WS-ROW)
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 takeoff: 29 blocks above the podium it is HOLDING_PATTERN" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Landing approach: with no player near the podium the goal is the node nearest (40, podium y, 0) (node 12); the path to it ends with the podium; the phase becomes LANDING.
     MOVE 2 TO DG-PHASE
     MOVE 0 TO DG-HAS-TARGET DG-HAS-PATH
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
     MOVE 40 TO EN-X(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO EN-Z(WS-ROW)
     MOVE 3 TO FR-CRYSTALS
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 landing approach: the path ends at the podium and the phase becomes LANDING (3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the last node was the podium (0, 201, 0)" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = DG-EY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Strafe set-up: a player at (51.5, 100, 30.2), the dragon at the origin: the extra node is (51, floor(100 + yOffset), 30).
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 51.5 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 30.2 TO PL-Z(WS-PLAYER)
     MOVE 1 TO WS-PHASE
     MOVE 0 TO DG-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     CALL "DRAGON-STRAFE-SET" USING WS-ROW WS-PLAYER
     MOVE "acceptance US16 21 6.4 strafe set-up: the extra node is at the player's block (51, 100, 30)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 51 * 10000 + 100 * 100 + 30
     COMPUTE TL-OBSERVED-N = DG-EX * 10000 + DG-EY * 100 + DG-EZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 strafe set-up: the path ends with the extra node and the player is remembered" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 24 * 1000 + WS-PLAYER
     COMPUTE TL-OBSERVED-N = DG-PATH-NODE(DG-PATH-N) * 1000 + DG-PROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Strafe tick without a player: HOLDING_PATTERN.
     MOVE 0 TO DG-PROW
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 strafe without a player goes back to HOLDING_PATTERN (or its landing approach roll)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-PHASE <= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Strafe fireball: the player straight ahead (north) within 64 blocks, the charge at 4: the fifth charge launches a fireball and the phase returns to the pattern.
     MOVE 0 TO WS-BALLS
     MOVE 0 TO EN-YAW(WS-ROW) EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE -30 TO PL-Z(WS-PLAYER)
     MOVE 0 TO DG-PHASE
     MOVE 1 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     CALL "DRAGON-STRAFE-SET" USING WS-ROW WS-PLAYER
     MOVE 4 TO DG-CHARGE
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 18
             ADD 1 TO WS-BALLS
             MOVE PJ-ENT(WS-I) TO WS-BALL-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.3 the fifth charge with the player ahead launches one dragon fireball" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-BALLS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 after the shot the charge is 0 and the phase left STRAFE_PLAYER" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-CHARGE = 0 AND DG-PHASE NOT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out of range (more than 64 blocks): the charge decays by one.
     MOVE 1 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     CALL "DRAGON-STRAFE-SET" USING WS-ROW WS-PLAYER
     MOVE -100 TO PL-Z(WS-PLAYER)
     MOVE 3 TO DG-CHARGE
     CALL "DRAGON-PHASE-TICK" USING WS-ROW
     MOVE "acceptance US16 21 6.4.3 a player beyond 64 blocks: the fireball charge decays by 1" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE DG-CHARGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The fireball's hit makes a cloud of radius 3 for 600 ticks (radius per tick (7 - 3) / 600, instant damage amplifier 1) and is gone.
     MOVE 0 TO WS-CLOUDS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS0
         END-IF
     END-PERFORM
     MOVE 0 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR EN-ID(WS-I) = WS-BALL-ROW
         CONTINUE
     END-PERFORM
     CALL "DFIRE-HIT" USING WS-I
     MOVE 0 TO WS-CLOUDS1
     MOVE 0 TO WS-SLOT
     MOVE 0 TO WS-COUNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 3
             ADD 1 TO WS-CLOUDS1
             MOVE WS-I TO WS-SLOT
         END-IF
         IF PJ-ENT(WS-I) = WS-BALL-ROW
             ADD 1 TO WS-COUNT2
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.3 the fireball hit spawns a cloud" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CLOUDS0 + 1
     MOVE WS-CLOUDS1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the cloud: radius 3, duration 600, instant damage amplifier 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100000 + 600 * 100 + 1 * 10 + 6
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-RADIUS(WS-SLOT) * 100000 + PJ-DUR(WS-SLOT) * 100 + PJ-FX-AMP(WS-SLOT, 1) * 10 + PJ-FX-ID(WS-SLOT, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the cloud grows 4 / 600 per tick toward 7 (rate 6.67 per thousand ticks)" TO TL-CASE
     MOVE 6667 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-RPT(WS-SLOT) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 and the fireball is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The holding pattern: from a fresh state the new target either is a ring node target (phase 0) or the landing approach (phase 2, one in c + 3); both seen over 200 ticks.
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
     MOVE 0 TO WS-SEEN2 WS-SEENH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO CW-TICKS
         MOVE 0 TO DG-PHASE DG-HAS-TARGET DG-HAS-PATH
         MOVE 60 TO EN-X(WS-ROW)
         MOVE 100 TO EN-Y(WS-ROW)
         MOVE 0 TO EN-Z(WS-ROW)
         MOVE 3 TO FR-CRYSTALS
         CALL "DRAGON-PHASE-TICK" USING WS-ROW
         IF DG-PHASE = 2
             ADD 1 TO WS-SEEN2
         END-IF
         IF DG-PHASE = 0 AND DG-HAS-TARGET = 1
             ADD 1 TO WS-SEENH
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.3 holding pattern: some new targets switch to LANDING_APPROACH (one in 6)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN2 > 5 AND WS-SEEN2 < 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 holding pattern: most new targets are ring nodes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEENH > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without crystals the ring wraps on the middle ring (nodes 12 to 19): a dragon at (28, 28) takes the next node.
     MOVE 0 TO FR-CRYSTALS
     MOVE 0 TO DG-PHASE DG-HAS-TARGET DG-HAS-PATH
     MOVE 28 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 1 TO CW-TICKS
     CALL "DRAGON-FIND-NEW" USING WS-ROW
     MOVE "acceptance US16 21 6.4.2 without crystals the pattern keeps to the middle and inner rings (target radius at most 41)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-HAS-TARGET = 1 AND DG-TX * DG-TX + DG-TZ * DG-TZ < 1700
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-DRAGON-PHASE.
 COPY CORETEST.
 COPY MOBSPTEST.
