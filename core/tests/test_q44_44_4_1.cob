*> Shared Brain behaviours of the land animals (docs/protocol/44-residual-mob-questions-4-land-animals.md section 1, worked example 1 and checks 1 to 3 of section 20; lane 002-lane-p49i,
*> T22580; phase task T2730): the long jump family (the vector of core/src/mob-44-m.cob M44-JUMP-VECTOR, the rules of core/src/q44-44-4.cob), the land and liquid finders, croak, the frog tongue
*> and MobSensor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-G                   FLOAT-LONG VALUE 0.08.
 01 WS-MAX                 FLOAT-LONG VALUE 1.5.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-COLLIDE             BINARY-LONG VALUE 0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 2.
 01 WS-L3                  BINARY-LONG VALUE 3.
 01 WS-L4                  BINARY-LONG VALUE 4.
 01 WS-DX                  BINARY-LONG VALUE 3.
 01 WS-DY                  BINARY-LONG VALUE 0.
 01 WS-DZ                  BINARY-LONG VALUE 4.
 01 WS-FC                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-EAT                 BINARY-LONG.
 01 WS-WEIGHTS.
    05 WS-W                BINARY-LONG OCCURS 64 TIMES.
 01 WS-PREFS               PIC X(64) VALUE ALL "0".
 01 WS-DRAWS.
    05 WS-DR               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TAGS                PIC X(64) VALUE ALL "0".
 01 WS-AIRS                PIC X(64) VALUE ALL "0".
 01 WS-DISTS.
    05 WS-DS               FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
*>   1.1 and worked example 1: frog at (0, 64, 0), target block (4, 64, 0) so T = (4.5, 64.5, 0.5); jump_strength 0.42 x 3.5714288.
     MOVE 0 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 0 TO WS-PZ
     MOVE 4.5 TO WS-TX
     MOVE 64.5 TO WS-TY
     MOVE 0.5 TO WS-TZ
     MOVE 65 TO WS-ANGLE
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "worked example 1: the vector for 65 degrees exists (v = 0.668 is below 1.5)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
*>   Independent value: v^2 = 0.4465, v = 0.668, vh = v cos 65 = 0.2823, vy = v sin 65 = 0.6054, phi = atan2(0.4448, 4.0031) = 0.1106 rad; result 0.95 x (vh cos phi, vy, vh sin phi).
     MOVE "worked example 1: the launch vy is 0.95 x 0.6054 = 0.575" TO WS-CASE
     MOVE 575 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VY * 1000
     PERFORM CHECK-N
     MOVE "worked example 1: the launch vx is 0.95 x 0.2823 cos(phi) = 0.267" TO WS-CASE
     MOVE 267 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VX * 1000
     PERFORM CHECK-N
     MOVE "worked example 1: the launch vz is 0.95 x 0.2823 sin(phi) = 0.030" TO WS-CASE
     MOVE 30 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VZ * 1000
     PERFORM CHECK-N
*>   Check 1: a target too far for every angle gives no vector.
     MOVE 60.5 TO WS-TX
     MOVE 0 TO WS-N
     PERFORM VARYING WS-ANGLE FROM 65 BY 5 UNTIL WS-ANGLE > 80
         CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
         ADD WS-FOUND TO WS-N
     END-PERFORM
     MOVE "validation 1: a target beyond the maximum speed gives no vector for any of the four angles" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   Check 1: v squared below 0 (a target high above, close by) rejects.
     MOVE 1.5 TO WS-TX
     MOVE 90.5 TO WS-TY
     MOVE 65 TO WS-ANGLE
     CALL "M44-JUMP-VECTOR" USING WS-DIM WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE WS-COLLIDE WS-VX WS-VY WS-VZ WS-FOUND
     MOVE "validation 1: v squared below 0 (a target far above) rejects" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
*>   The weights of the candidates.
     CALL "Q4-LJ-WEIGHT" USING WS-DX WS-DY WS-DZ WS-N
     MOVE "a candidate at (3, 0, 4) has the weight ceil(25) = 25" TO WS-CASE
     MOVE 25 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   Start conditions and the cooldowns (check 3).
     MOVE 61 TO WS-A
     CALL "Q4-LJ-START" USING WS-L0 WS-L0 WS-L0 WS-A WS-B WS-C
     MOVE "start condition failing (not on the ground): the cooldown is half the sample, integer division (61 gives 30)" TO WS-CASE
     MOVE 30 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-START" USING WS-L1 WS-L0 WS-L1 WS-A WS-B WS-C
     MOVE "start condition failing (standing in honey): not started" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-START" USING WS-L1 WS-L1 WS-L0 WS-A WS-B WS-C
     MOVE "start condition failing (in water or lava): not started" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-START" USING WS-L1 WS-L0 WS-L0 WS-A WS-B WS-C
     MOVE "start condition met: starts and the cooldown is not touched" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-B * 10 + WS-C
     PERFORM CHECK-N
     MOVE 3.5 TO WS-FA
     MOVE 0.5 TO WS-FB
     CALL "Q4-LJ-LAUNCH" USING WS-FA WS-FB WS-FC
     MOVE "launch: the motion is the vector scaled by (|v| + jump boost power) / |v| (|v| 3.5, boost 0.5: 1.1428)" TO WS-CASE
     MOVE 11429 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FC * 10000
     PERFORM CHECK-N
     MOVE 0 TO WS-FA
     MOVE 0.5 TO WS-FB
     CALL "Q4-LJ-LAUNCH" USING WS-FA WS-FB WS-FC
     MOVE "launch: a zero vector keeps scale 1" TO WS-CASE
     MOVE 10000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FC * 10000
     PERFORM CHECK-N
*>   Continue and end.
     CALL "Q4-LJ-CONTINUE" USING WS-L1 WS-A WS-L0 WS-L0 WS-L1 WS-F
     MOVE "continue: start unchanged, tries left, not in water, candidates remain" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-CONTINUE" USING WS-L1 WS-A WS-L0 WS-L1 WS-L0 WS-F
     MOVE "continue: a chosen jump keeps it going with no candidates left" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-CONTINUE" USING WS-L1 WS-A WS-L0 WS-L0 WS-L0 WS-F
     MOVE "continue: no jump chosen and no candidates left ends it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-CONTINUE" USING WS-L0 WS-A WS-L0 WS-L1 WS-L1 WS-F
     MOVE "continue: a changed start position ends it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-D
     CALL "Q4-LJ-CONTINUE" USING WS-L1 WS-D WS-L0 WS-L1 WS-L1 WS-F
     MOVE "continue: no tries left ends it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-CONTINUE" USING WS-L1 WS-A WS-L1 WS-L1 WS-L1 WS-F
     MOVE "continue: being in water ends it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     MOVE 100 TO WS-A
     CALL "Q4-LJ-END" USING WS-L0 WS-A WS-B WS-C
     MOVE "end without a mid jump: the cooldown is half the sample (50) and LOOK_TARGET is erased" TO WS-CASE
     MOVE 501 TO WS-E
     COMPUTE WS-O = WS-B * 10 + WS-C
     PERFORM CHECK-N
     CALL "Q4-LJ-END" USING WS-L1 WS-A WS-B WS-C
     MOVE "end with LONG_JUMP_MID_JUMP present: no cooldown and the look target stays" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-B * 10 + WS-C
     PERFORM CHECK-N
     MOVE 1.0 TO WS-FA
     MOVE -2.0 TO WS-FB
     CALL "Q4-LJ-MID-STOP" USING WS-L1 WS-FA WS-FB WS-A WS-VX WS-VZ WS-B
     MOVE "mid jump stop on the ground: vx 1.0 becomes 0.1" TO WS-CASE
     MOVE 1000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VX * 10000
     PERFORM CHECK-N
     MOVE "mid jump stop on the ground: vz -2.0 becomes -0.2" TO WS-CASE
     MOVE -2000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VZ * 10000
     PERFORM CHECK-N
     MOVE "mid jump stop: the cooldown is the full sample (check 3: a landing is a full sample, the prepare path half)" TO WS-CASE
     MOVE 100 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LJ-MID-STOP" USING WS-L0 WS-FA WS-FB WS-A WS-VX WS-VZ WS-B
     MOVE "mid jump stop in the air leaves the motion" TO WS-CASE
     MOVE 1000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-VX * 1000
     PERFORM CHECK-N
*>   The candidate draw of LongJumpToPreferredBlock: weights 4 3 2 1 (total 10), preferred flag only on candidate 3.
     MOVE 4 TO WS-W(1)
     MOVE 3 TO WS-W(2)
     MOVE 2 TO WS-W(3)
     MOVE 1 TO WS-W(4)
     MOVE "0010" TO WS-PREFS(1:4)
     MOVE 0 TO WS-DR(1)
     MOVE 0 TO WS-DR(2)
     MOVE 0 TO WS-DR(3)
     MOVE 0 TO WS-DR(4)
     MOVE 4 TO WS-N
     CALL "Q4-LJ-PICK" USING WS-N WS-WEIGHTS WS-PREFS WS-DRAWS WS-L0 WS-F
     MOVE "not wanting a preferred block: the first draw's candidate (draw 0 of weights 4 3 2 1 is the first)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO WS-DR(1)
     CALL "Q4-LJ-PICK" USING WS-N WS-WEIGHTS WS-PREFS WS-DRAWS WS-L0 WS-F
     MOVE "a draw of 9 of weights 4 3 2 1 (running 4 7 9 10) is candidate 4 (farther is likelier)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
*>   Wanting preferred: draws 0 (candidate 1, not preferred), then 0 of the rest (candidate 2), then 0 (candidate 3, preferred): returns 3.
     MOVE 0 TO WS-DR(1)
     CALL "Q4-LJ-PICK" USING WS-N WS-WEIGHTS WS-PREFS WS-DRAWS WS-L1 WS-F
     MOVE "wanting preferred: not preferred candidates are set aside until the preferred one (3) is drawn" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
     MOVE "0000" TO WS-PREFS(1:4)
     CALL "Q4-LJ-PICK" USING WS-N WS-WEIGHTS WS-PREFS WS-DRAWS WS-L1 WS-F
     MOVE "wanting preferred with none in range: the first not-preferred candidate drawn (1) is returned when the list is exhausted" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-F TO WS-O
     PERFORM CHECK-N
*>   1.2 the finders.
     MOVE 100 TO WS-A
     MOVE 120 TO WS-B
     CALL "Q4-FINDER-TIMER" USING WS-L1 WS-A WS-B WS-C WS-D
     MOVE "TryFindLand called before the time: no scan, the counter is pushed to now + 60 (160)" TO WS-CASE
     MOVE 160 TO WS-E
     MOVE WS-D TO WS-O
     PERFORM CHECK-N
     MOVE "TryFindLand called before the time does not scan" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 130 TO WS-A
     CALL "Q4-FINDER-TIMER" USING WS-L1 WS-A WS-B WS-C WS-D
     MOVE "TryFindLand at the time scans and sets the counter to now + 60 (190)" TO WS-CASE
     MOVE 1190 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D
     PERFORM CHECK-N
     MOVE 100 TO WS-A
     CALL "Q4-FINDER-TIMER" USING WS-L2 WS-A WS-B WS-C WS-D
     MOVE "TryFindLandNearLiquid suppressed: counter now + 40 (140), no scan" TO WS-CASE
     MOVE 140 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D
     PERFORM CHECK-N
     CALL "Q4-FINDER-TIMER" USING WS-L3 WS-A WS-B WS-C WS-D
     MOVE "TryFindLiquid suppressed: now + 20 + 2 (122), no scan" TO WS-CASE
     MOVE 122 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D
     PERFORM CHECK-N
     MOVE 130 TO WS-A
     CALL "Q4-FINDER-TIMER" USING WS-L3 WS-A WS-B WS-C WS-D
     MOVE "TryFindLiquid after a search: now + 40 (170) and a scan" TO WS-CASE
     MOVE 1170 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D
     PERFORM CHECK-N
     CALL "Q4-FINDER-TIMER" USING WS-L2 WS-A WS-B WS-C WS-D
     MOVE "TryFindLandNearLiquid after a search: now + 40 (170) and a scan" TO WS-CASE
     MOVE 1170 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D
     PERFORM CHECK-N
     CALL "Q4-FINDER-START" USING WS-L0 WS-L0 WS-A
     MOVE "the finders need ATTACK_TARGET and WALK_TARGET absent: both absent starts" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-START" USING WS-L1 WS-L0 WS-A
     MOVE "an attack target stops the finders" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-START" USING WS-L0 WS-L1 WS-A
     MOVE "a walk target stops the finders" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-N
     CALL "Q4-FINDER-PARAMS" USING WS-L1 WS-L0 WS-A WS-FA WS-B
     MOVE "TryFindLand idle: radius 6, speed 1.0, completion range 1" TO WS-CASE
     MOVE 6101 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A * 1000 + WS-FA * 100 + WS-B
     PERFORM CHECK-N
     CALL "Q4-FINDER-PARAMS" USING WS-L1 WS-L1 WS-A WS-FA WS-B
     MOVE "TryFindLand swim: radius 8, speed 1.5, completion range 1" TO WS-CASE
     MOVE 8151 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A * 1000 + WS-FA * 100 + WS-B
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     CALL "Q4-FINDER-PARAMS" USING WS-N WS-L0 WS-A WS-FA WS-B
     MOVE "TryFindLandNearLiquid: radius 8, speed 1.0, completion range 0" TO WS-CASE
     MOVE 8100 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A * 1000 + WS-FA * 100 + WS-B
     PERFORM CHECK-N
     MOVE 3 TO WS-N
     CALL "Q4-FINDER-PARAMS" USING WS-N WS-L0 WS-A WS-FA WS-B
     MOVE "TryFindLiquid: completion range 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-RUNS" USING WS-L1 WS-L1 WS-A
     MOVE "TryFindLand runs when the block fluid is in tag water" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-RUNS" USING WS-L1 WS-L0 WS-A
     MOVE "TryFindLand does not run on dry land" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-RUNS" USING WS-L2 WS-L0 WS-A
     MOVE "TryFindLandNearLiquid runs when the block fluid is not in its tag" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FINDER-RUNS" USING WS-L3 WS-L1 WS-A
     MOVE "TryFindLiquid does not run when the block fluid is in its tag" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LAND-OK" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "a land candidate differing horizontally, with empty fluid, free of collision and a sturdy block below is accepted" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LAND-OK" USING WS-L1 WS-L1 WS-L1 WS-L0 WS-A
     MOVE "a land candidate without a sturdy block below is rejected" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LAND-NEAR-OK" USING WS-L1 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "a land-near-liquid candidate with a liquid-adjacent air neighbour is accepted" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-LAND-NEAR-OK" USING WS-L1 WS-L1 WS-L1 WS-L0 WS-A
     MOVE "a land-near-liquid candidate without such a neighbour is rejected" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Liquid: the first with air above, else the first at least 1.5 away.
     MOVE "110" TO WS-TAGS(1:3)
     MOVE "010" TO WS-AIRS(1:3)
     MOVE 1.0 TO WS-DS(1)
     MOVE 2.0 TO WS-DS(2)
     MOVE 3.0 TO WS-DS(3)
     MOVE 3 TO WS-N
     CALL "Q4-LIQUID-PICK" USING WS-N WS-TAGS WS-AIRS WS-DISTS WS-A
     MOVE "TryFindLiquid: the first liquid block of the tag with air above (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "000" TO WS-AIRS(1:3)
     CALL "Q4-LIQUID-PICK" USING WS-N WS-TAGS WS-AIRS WS-DISTS WS-A
     MOVE "TryFindLiquid with no air above any: the first liquid at least 1.5 away (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "000" TO WS-TAGS(1:3)
     CALL "Q4-LIQUID-PICK" USING WS-N WS-TAGS WS-AIRS WS-DISTS WS-A
     MOVE "TryFindLiquid with no liquid of the tag finds nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   1.3 croak.
     CALL "Q4-CROAK-START" USING WS-L1 WS-L0 WS-A
     MOVE "croak starts when the pose is STANDING and there is no walk target" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CROAK-START" USING WS-L0 WS-L0 WS-A
     MOVE "croak does not start in another pose" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CROAK-START" USING WS-L1 WS-L1 WS-A
     MOVE "croak needs WALK_TARGET absent" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CROAK-BEGIN" USING WS-L0 WS-A WS-B
     MOVE "croak start out of a liquid: pose CROAKING and counter 0" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = WS-A * 10 + WS-B
     PERFORM CHECK-N
     CALL "Q4-CROAK-BEGIN" USING WS-L1 WS-A WS-B
     MOVE "croak start in a liquid does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A * 10 + WS-B
     PERFORM CHECK-N
     MOVE 59 TO WS-A
     CALL "Q4-CROAK-TICK" USING WS-A WS-B WS-C
     MOVE "croak at counter 59 continues, the counter becomes 60" TO WS-CASE
     MOVE 160 TO WS-E
     COMPUTE WS-O = WS-B * 100 + WS-C
     PERFORM CHECK-N
     MOVE 60 TO WS-A
     CALL "Q4-CROAK-TICK" USING WS-A WS-B WS-C
     MOVE "croak at counter 60 stops" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
*>   1.4 the tongue.
     CALL "Q4-FROG-CAN-EAT" USING WS-L1 WS-L1 WS-L1 WS-A
     MOVE "canEat: a size-1 cube in frog_food is edible" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     CALL "Q4-FROG-CAN-EAT" USING WS-L1 WS-N WS-L1 WS-A
     MOVE "canEat: a cube of size 2 is never edible" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FROG-CAN-EAT" USING WS-L0 WS-L0 WS-L1 WS-A
     MOVE "canEat: a non-cube in the tag is edible" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-FROG-CAN-EAT" USING WS-L0 WS-L0 WS-L0 WS-A
     MOVE "canEat: an entity outside the tag (a pig) is not edible" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L1 WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "tongue start: no walk target, an attack target, not panicking, reachable, not croaking, edible" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L1 WS-L1 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "tongue start: panicking stops it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L1 WS-L0 WS-L0 WS-L0 WS-L1 WS-A
     MOVE "tongue start: an unreachable target stops it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L1 WS-L0 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "tongue start: a croaking frog does not start" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L1 WS-L0 WS-L1 WS-L0 WS-L0 WS-A
     MOVE "tongue start: a target that cannot be eaten does not start" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L1 WS-L1 WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "tongue start: a walk target stops it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-TONGUE-START" USING WS-L0 WS-L0 WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "tongue start: needs an attack target" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   The tongue tick (state, distance, path counter, timer -> new state, new timer, new counter, pull, walk, eat).
     MOVE 1.7 TO WS-FA
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L1 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue MOVE below 1.75: the target is pulled, the timer is 0 and the state CATCH (2)" TO WS-CASE
     MOVE 102 TO WS-E
     COMPUTE WS-O = WS-F * 100 + WS-D * 10 + WS-C
     PERFORM CHECK-N
     MOVE 2.0 TO WS-FA
     MOVE 0 TO WS-A
     CALL "Q4-TONGUE-TICK" USING WS-L1 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue MOVE at 2.0 with the path counter at 0: the walk target is set and the counter becomes 10" TO WS-CASE
     MOVE 110 TO WS-E
     COMPUTE WS-O = WS-WALK * 100 + WS-N
     PERFORM CHECK-N
     MOVE 5 TO WS-A
     CALL "Q4-TONGUE-TICK" USING WS-L1 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue MOVE at 2.0 with the path counter 5: the counter drops to 4, the state stays MOVE and no walk target is set" TO WS-CASE
     MOVE 41 TO WS-E
     COMPUTE WS-O = WS-N * 10 + WS-C + WS-WALK * 1000
     PERFORM CHECK-N
     MOVE 5 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L2 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue CATCH at timer 5: the timer becomes 6 first, then the state is EAT (3) and eatEntity runs" TO WS-CASE
     MOVE 631 TO WS-E
     COMPUTE WS-O = WS-D * 100 + WS-C * 10 + WS-EAT
     PERFORM CHECK-N
     MOVE 4 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L2 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue CATCH at timer 4: the timer is 5, the state stays CATCH and nothing is eaten" TO WS-CASE
     MOVE 520 TO WS-E
     COMPUTE WS-O = WS-D * 100 + WS-C * 10 + WS-EAT
     PERFORM CHECK-N
     MOVE 9 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L3 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue EAT at timer 9: the timer becomes 10 and the state stays EAT" TO WS-CASE
     MOVE 1030 TO WS-E
     COMPUTE WS-O = WS-D * 100 + WS-C * 10
     PERFORM CHECK-N
     MOVE 10 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L3 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue EAT at timer 10: the state becomes DONE (4)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 99 TO WS-B
     CALL "Q4-TONGUE-TICK" USING WS-L4 WS-FA WS-A WS-B WS-C WS-D WS-N WS-F WS-WALK WS-EAT
     MOVE "tongue DONE does nothing" TO WS-CASE
     MOVE 4990 TO WS-E
     COMPUTE WS-O = WS-C * 1000 + WS-D * 10 + WS-WALK + WS-EAT + WS-F
     PERFORM CHECK-N
*>   1.5 MobSensor.
     CALL "Q4-MOB-SENSOR" USING WS-L0 WS-L1 WS-A
     MOVE "MobSensor: when the ready test fails the memory is erased" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-MOB-SENSOR" USING WS-L1 WS-L1 WS-A
     MOVE "MobSensor: ready and a matching entity: the memory is set true (for 80 ticks)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-MOB-SENSOR" USING WS-L1 WS-L0 WS-A
     MOVE "MobSensor: ready without a match leaves the memory as it is" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-4§1 Shared Brain behaviours: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-4-1.
