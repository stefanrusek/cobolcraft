*> Acceptance test, the ender dragon entity and its movement (docs/protocol/21 section 6.4, 6.4.1, 44 part 9 section 1; lane 002-lane-mobsb8, T9701): the spawn (health 200, phase 0), setPhase and its begin
*> rules, one tick of the steering rules with a worked example (turn 50 degrees limit x 0.7, velocity update and damping), the flight history and the eight part positions (body, wings, head, neck, tails;
*> the sitting head offset), block breaking by the head, neck and body (obsidian is immune and marks "in wall"), and navigateToNextPathNode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-DRAGON-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-WALL                BINARY-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HYAW                FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   Spawn: 200 health, phase 0 (holding pattern), the PROJSTATE entry of kind 17.
     MOVE 0 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 21 6.4 a spawned dragon has 200 health" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 it is a PROJSTATE entity of kind 17 remembered as the dragon" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     IF DG-ENT = EN-ID(WS-ROW)
         MOVE PJ-KIND(WS-SLOT) TO TL-OBSERVED-N
     ELSE
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.3 the initial phase is HOLDING_PATTERN (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   setPhase: begin rules, a request for the current phase is ignored.
     MOVE 5 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE "acceptance US16 21 6.4.3 setPhase(SITTING_FLAMING) twice begins it once (flame count 1)" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = DG-PHASE * 10 + DG-FLAMES
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-PHASE
     MOVE 77 TO DG-SCAN
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE "acceptance US16 21 6.4.3 beginning SITTING_SCANNING resets the scanning time" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-SCAN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE 1 TO DG-HAS-TARGET
     MOVE 1 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE "acceptance US16 21 6.4.3 beginning STRAFE_PLAYER clears the target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-HAS-TARGET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   One tick of steering (holding pattern, speeds 0.6, turn 0.7): target 50 blocks east at the same height.
     MOVE 0 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE 0 TO EN-YAW(WS-ROW) EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE 0 TO DG-YROT-A DG-WALL
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 1 TO DG-HAS-TARGET
     MOVE 50 TO DG-TX
     MOVE 100 TO DG-TY
     MOVE 0 TO DG-TZ
     CALL "DRAGON-MOVE" USING WS-ROW
     MOVE "acceptance US16 21 6.4.1 the turn is limited to 50 degrees x 0.7 x 0.1: yaw 3.5 after one tick" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-ROW) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.1 moveRelative adds 0.0599 along the new heading: x 0.0037 after one tick" TO TL-CASE
     MOVE 37 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.1 and z -0.0599" TO TL-CASE
     MOVE -599 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Z(WS-ROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.1 the velocity is damped by 0.8 + 0.15 x (v.g + 1) / 2 = 0.9499: vz -0.0569" TO TL-CASE
     MOVE -569 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No target: no steering, the position still moves by the (damped) velocity.
     MOVE 0 TO DG-HAS-TARGET
     MOVE 0 TO EN-YAW(WS-ROW) EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE 0.5 TO EN-VX(WS-ROW)
     CALL "DRAGON-MOVE" USING WS-ROW
     MOVE "acceptance US16 21 6.4.1 without a target the dragon does not steer: yaw stays 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-ROW) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.1 but it moves by its velocity (x 0.5)" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   In a wall the movement is x 0.8.
     MOVE 0 TO EN-X(WS-ROW)
     MOVE 0.5 TO EN-VX(WS-ROW)
     MOVE 1 TO DG-WALL
     CALL "DRAGON-MOVE" USING WS-ROW
     MOVE "acceptance US16 21 6.4.1 in a wall the movement is x 0.8 (x 0.4)" TO TL-CASE
     MOVE 4000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The flight history and the parts at yaw 0, level flight: body (0, 0, -0.5), wings (+-4.5, 2, 0), head (0, 0, -6.5), neck (0, 0, -5.5), tails (0, 1.5, 3.5 / 5.5 / 7.5).
     MOVE 0 TO DG-WALL
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW) EN-YAW(WS-ROW) DG-YROT-A
     MOVE 100 TO EN-Y(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "DRAGON-HIST-PUSH" USING WS-ROW
     END-PERFORM
     MOVE 5 TO WS-I
     CALL "DRAGON-HIST-GET" USING WS-I WS-HY WS-HYAW
     MOVE "acceptance US16 21 6.4 the history holds the pushed sample (y 100)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-HY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE "acceptance US16 21 6.4 the body is 0.5 behind the centre (z -0.5)" TO TL-CASE
     MOVE -5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-Z(3) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 wing 1 is 4.5 east" TO TL-CASE
     MOVE 45000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-X(7) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 and 2 up" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (DG-PART-Y(7) - 100) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 wing 2 is 4.5 west" TO TL-CASE
     MOVE -45000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-X(8) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 the head is 6.5 ahead (z -6.5)" TO TL-CASE
     MOVE -65000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-Z(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 level flight keeps the head at the centre height" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (DG-PART-Y(1) - 100) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 the neck is 5.5 ahead" TO TL-CASE
     MOVE -55000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-Z(2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 the tails trail at z 3.5, 5.5 and 7.5 (sum 16.5)" TO TL-CASE
     MOVE 16500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (DG-PART-Z(4) + DG-PART-Z(5) + DG-PART-Z(6)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 the tails are 1.5 up (sum 4.5)" TO TL-CASE
     MOVE 4500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (DG-PART-Y(4) + DG-PART-Y(5) + DG-PART-Y(6) - 300) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Facing east (yaw 90): the head is 6.5 east. Sitting: the head is 1 lower.
     MOVE 90 TO EN-YAW(WS-ROW)
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE "acceptance US16 21 6.4 at yaw 90 the head is 6.5 east" TO TL-CASE
     MOVE 65000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PART-X(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE "acceptance US16 21 6.4 a sitting dragon (hover) carries its head 1 block lower" TO TL-CASE
     MOVE -1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (DG-PART-Y(1) - 100) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Block breaking: the head box (1 x 1 at the head position) breaks stone, obsidian stays and marks the wall; the neck cell is air.
     MOVE 0 TO WS-PHASE
     CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
     MOVE 0 TO EN-YAW(WS-ROW)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:obsidian" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-OBSIDIAN
     CALL "DRAGON-PARTS" USING WS-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(DG-PART-X(1))
     COMPUTE WS-CY = FUNCTION INTEGER(DG-PART-Y(1))
     COMPUTE WS-CZ = FUNCTION INTEGER(DG-PART-Z(1))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
     CALL "DRAGON-WALLS" USING WS-ROW WS-WALL
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US16 21 6.4 the head breaks stone in its box" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 a broken block is not a wall (in wall 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-OBSIDIAN
     CALL "DRAGON-WALLS" USING WS-ROW WS-WALL
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US16 21 6.4 obsidian (dragon_immune) is kept" TO TL-CASE
     MOVE WS-OBSIDIAN TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 and marks the dragon in a wall" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WALL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   navigateToNextPathNode: the next path node becomes the target (node 1 at (51, 30), a height 0 to 20 above the node).
     MOVE 1 TO DG-HAS-PATH
     MOVE 2 TO DG-PATH-N
     MOVE 1 TO DG-PATH-I
     MOVE 0 TO DG-PATH-NODE(1)
     MOVE 1 TO DG-PATH-NODE(2)
     CALL "DRAGON-NAV"
     MOVE "acceptance US16 21 6.4.2 the first path node (60, 0) becomes the target and the path advances" TO TL-CASE
     MOVE 60002 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = DG-TX * 1000 + DG-TZ + DG-PATH-I
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4.2 the target height is node y + a random 0 to 20" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-TY >= DG-NODE-Y(1) AND DG-TY <= DG-NODE-Y(1) + 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-DRAGON-MOVE.
 COPY CORETEST.
 COPY MOBSPTEST.
