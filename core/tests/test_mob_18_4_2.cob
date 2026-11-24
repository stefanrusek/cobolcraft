*> Implementation test (002-lane-mobsfull-h2, T2216; docs/protocol/18 section 4.2 Shared goal catalogue; doc 44 x2 section 10): the goal
*> catalogue (flags, interruptable, every-tick per goal class) and the pure decisions of the shared goals: melee path
*> recomputation and range, the zombie raised arms, ranged attack timing, stroll trigger, leap, swell, ocelot speed, sit,
*> breeding, follow parent, tempt, door interaction, restriction and the random position helpers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(32).
 01 WS-SPEC                PIC X(6).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DIST2               FLOAT-LONG.
 01 WS-FROLL               FLOAT-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-OUT2                BINARY-LONG.
 01 WS-OUT3                BINARY-LONG.
 01 WS-X10                 BINARY-LONG.
 PROCEDURE DIVISION.
     *> Catalogue: flags MOVE LOOK JUMP TARGET, interruptable, every tick.
     MOVE "FloatGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§4.2 Shared goal catalogue FloatGoal has the JUMP flag and updates every tick" TO TL-CASE
     MOVE "001011" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "MeleeAttackGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "acceptance US15 18§4.2 Shared goal catalogue MeleeAttackGoal has MOVE and LOOK and updates every tick" TO TL-CASE
     MOVE "110011" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "BreathAirGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "acceptance US15 18§4.2 Shared goal catalogue BreathAirGoal is not interruptable" TO TL-CASE
     MOVE "110000" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "SitWhenOrderedToGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "acceptance US15 18§4.2 Shared goal catalogue SitWhenOrderedToGoal has JUMP and MOVE (44 x2 10.1)" TO TL-CASE
     MOVE "101010" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "FollowParentGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "acceptance US15 18§4.2 Shared goal catalogue FollowParentGoal has no flags" TO TL-CASE
     MOVE "000010" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "HurtByTargetGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "acceptance US15 18§4.2 Shared goal catalogue HurtByTargetGoal has the TARGET flag" TO TL-CASE
     MOVE "000110" TO TL-EXPECTED
     MOVE WS-SPEC TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "NoSuchGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§4.2 Shared goal catalogue an unknown goal is not found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Melee recalculation delay: 4 + roll, +10 beyond 32 blocks, +5 beyond 16, +15 when moveTo fails, adjusted (halved up).
     MOVE 3 TO WS-ROLL
     MOVE 100 TO WS-DIST
     MOVE 1 TO WS-A
     CALL "MELEE-RECALC-DELAY" USING WS-ROLL WS-DIST WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee recalculation delay near target is 4 + roll" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 300 TO WS-DIST
     CALL "MELEE-RECALC-DELAY" USING WS-ROLL WS-DIST WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee recalculation delay adds 5 beyond 16 blocks" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1100 TO WS-DIST
     MOVE 0 TO WS-A
     CALL "MELEE-RECALC-DELAY" USING WS-ROLL WS-DIST WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee recalculation delay adds 10 beyond 32 and 15 for a failed moveTo" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Melee path recomputation due: timer 0, seen, and (no stored position, or moved >= 1 squared, or roll < 0.05).
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0.5 TO WS-DIST
     MOVE 0.9 TO WS-FROLL
     CALL "MELEE-RECALC-DUE" USING WS-A WS-B WS-C WS-DIST WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee: no recomputation when the target has not moved" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-DIST
     CALL "MELEE-RECALC-DUE" USING WS-A WS-B WS-C WS-DIST WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee: recomputation when the target moved a block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-DIST
     MOVE 0.04 TO WS-FROLL
     CALL "MELEE-RECALC-DUE" USING WS-A WS-B WS-C WS-DIST WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee: recomputation with probability 0.05" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.9 TO WS-FROLL
     MOVE 1 TO WS-C
     CALL "MELEE-RECALC-DUE" USING WS-A WS-B WS-C WS-DIST WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee: recomputation when no target position is stored" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "MELEE-RECALC-DUE" USING WS-A WS-B WS-C WS-DIST WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee: a running timer blocks recomputation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Zombie arms: aggressive when raiseArmTicks >= 5 and the attack timer is below half the interval (20 / 2).
     MOVE 5 TO WS-A
     MOVE 9 TO WS-B
     CALL "ZOMBIE-ARMS" USING WS-A WS-B WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue zombie raises its arms after 5 ticks when the attack timer is below 10" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-B
     CALL "ZOMBIE-ARMS" USING WS-A WS-B WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue zombie arms stay down at a timer of 10" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Ranged attack: power = clamp(distance / radius, 0.1, 1), timer = floor(distance / radius * (max - min) + min).
     MOVE 8 TO WS-DIST
     MOVE 16 TO WS-DIST2
     MOVE 20 TO WS-A
     MOVE 60 TO WS-B
     CALL "RANGED-ATTACK-SHOT" USING WS-DIST WS-DIST2 WS-A WS-B WS-POWER WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ranged attack at half radius: power 0.5 and timer 40" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-POWER * 1000 + WS-OUT
     MOVE 540 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-DIST
     CALL "RANGED-ATTACK-SHOT" USING WS-DIST WS-DIST2 WS-A WS-B WS-POWER WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ranged attack power is at least 0.1" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-POWER * 1000 + WS-OUT
     MOVE 122 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-DIST
     CALL "RANGED-ATTACK-SHOT" USING WS-DIST WS-DIST2 WS-A WS-B WS-POWER WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ranged attack power is at most 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-POWER * 1000 + WS-OUT
     MOVE 1120 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Stroll trigger: roll 0 of reducedTickDelay(interval) and no controlling passenger and noActionTime < 100.
     MOVE 120 TO WS-A
     MOVE 0 TO WS-ROLL
     MOVE 0 TO WS-B
     MOVE 50 TO WS-C
     CALL "STROLL-TRIGGER" USING WS-A WS-ROLL WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue stroll triggers on roll 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ROLL
     CALL "STROLL-TRIGGER" USING WS-A WS-ROLL WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue stroll does not trigger on another roll" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROLL
     MOVE 100 TO WS-C
     CALL "STROLL-TRIGGER" USING WS-A WS-ROLL WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue stroll is suppressed by noActionTime of 100" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     CALL "STROLL-TRIGGER" USING WS-A WS-ROLL WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue stroll is suppressed by a controlling passenger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Leap: no controlling passenger, target between 2 and 4 blocks (squared 4 to 16 exclusive), on ground, roll 0 of reduced(5).
     MOVE 0 TO WS-A
     MOVE 9 TO WS-DIST
     MOVE 1 TO WS-B
     MOVE 0 TO WS-ROLL
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap starts at 3 blocks on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-DIST
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap needs a squared distance above 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-DIST
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap needs a squared distance below 16" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-DIST
     MOVE 0 TO WS-B
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap needs the ground" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 1 TO WS-A
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap needs no controlling passenger" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 2 TO WS-ROLL
     CALL "LEAP-CAN-USE" USING WS-A WS-DIST WS-B WS-ROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue leap needs the 1 in 3 roll" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Swell: direction +1 with a visible target within 7 blocks, else -1.
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 25 TO WS-DIST
     MOVE 1 TO WS-D
     CALL "SWELL-DIRECTION" USING WS-B WS-C WS-DIST WS-D WS-OUT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell grows with a visible target within 7 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-DIST
     CALL "SWELL-DIRECTION" USING WS-B WS-C WS-DIST WS-D WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell shrinks beyond 7 blocks" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-DIST
     MOVE 0 TO WS-D
     CALL "SWELL-DIRECTION" USING WS-B WS-C WS-DIST WS-D WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell shrinks without line of sight" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     CALL "SWELL-DIRECTION" USING WS-B WS-C WS-DIST WS-D WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell shrinks when the target is dead" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     CALL "SWELL-DIRECTION" USING WS-B WS-C WS-DIST WS-D WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell shrinks without a target" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Swell canUse: direction above 0 or a target within 3 blocks (squared 9).
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 9 TO WS-DIST
     CALL "SWELL-CAN-USE" USING WS-B WS-C WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell canUse with a growing fuse" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 8 TO WS-DIST
     CALL "SWELL-CAN-USE" USING WS-B WS-C WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell canUse with a target within 3 blocks" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-DIST
     CALL "SWELL-CAN-USE" USING WS-B WS-C WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue swell canUse is false at squared 9 without a fuse" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Ocelot speed: 0.8, or 1.33 when squared distance is above (2 x width)^2 and below 16, or 0.6 when below 225 (1.33 first).
     MOVE 0.6 TO WS-WIDTH
     MOVE 9 TO WS-DIST
     CALL "OCELOT-SPEED" USING WS-DIST WS-WIDTH WS-SPEED
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ocelot approaches at 1.33 in the middle band" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 133
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-DIST
     CALL "OCELOT-SPEED" USING WS-DIST WS-WIDTH WS-SPEED
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ocelot approaches at 0.6 within 15 blocks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 60
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 400 TO WS-DIST
     CALL "OCELOT-SPEED" USING WS-DIST WS-WIDTH WS-SPEED
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ocelot approaches at 0.8 far away" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 80
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-DIST
     CALL "OCELOT-SPEED" USING WS-DIST WS-WIDTH WS-SPEED
     MOVE "acceptance US15 18§4.2 Shared goal catalogue ocelot at point blank uses 0.6" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 60
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Sit canUse, in the doc order of 44 x2 10.1: sit flag, tame, water, ground, owner missing, owner near and hurt.
     *> args: ordered, tame, in-water, on-ground, owner-present, owner-dist-sq (float), owner-has-last-hurt-by, out
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     MOVE 25 TO WS-DIST
     MOVE 0 TO WS-X10
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tame pet ordered to sit sits (44 x2 10.1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a wild animal not ordered to sit does not sit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue an untame animal ordered to sit passes check 1 (44 x2 10.1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a pet in water does not sit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a pet off the ground does not sit" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-X10
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a pet without an owner sits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-E
     MOVE 100 TO WS-DIST
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a pet stands when its owner within 12 blocks was attacked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 144 TO WS-DIST
     CALL "SIT-CAN-USE" USING WS-A WS-B WS-C WS-D WS-E WS-DIST WS-X10 WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a pet sits when its attacked owner is 12 blocks away" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Breeding: the counter reaches adjusted(60) = 30 and the partner is within 3 blocks (squared 9).
     MOVE 30 TO WS-A
     MOVE 8 TO WS-DIST
     CALL "BREED-SPAWN-DUE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue breeding spawns the child at counter 30 within 3 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 29 TO WS-A
     CALL "BREED-SPAWN-DUE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue breeding waits for the counter" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO WS-A
     MOVE 9 TO WS-DIST
     CALL "BREED-SPAWN-DUE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue breeding needs the partner within 3 blocks" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Follow parent: a baby (age < 0) follows an adult at least 3 blocks away; it ends within 3 or beyond 16 blocks.
     MOVE -5 TO WS-A
     MOVE 16 TO WS-DIST
     CALL "FOLLOW-PARENT-CAN-USE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a baby follows an adult 4 blocks away" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-DIST
     CALL "FOLLOW-PARENT-CAN-USE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a baby ignores an adult within 3 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 16 TO WS-DIST
     CALL "FOLLOW-PARENT-CAN-USE" USING WS-A WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue an adult follows nobody" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-DIST
     CALL "FOLLOW-PARENT-KEEP" USING WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a follower keeps going between 3 and 16 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 300 TO WS-DIST
     CALL "FOLLOW-PARENT-KEEP" USING WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a follower stops beyond 16 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-DIST
     CALL "FOLLOW-PARENT-KEEP" USING WS-DIST WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a follower stops within 3 blocks" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Tempt scare: ends when the player is within 6 blocks (squared 36) and moved more than 0.1 (squared 0.01) or turned more than 5.
     *> args: squared distance, squared movement, rotation change in degrees (float), out
     MOVE 30 TO WS-DIST
     MOVE 0.02 TO WS-DIST2
     MOVE 0 TO WS-FROLL
     CALL "TEMPT-SCARED" USING WS-DIST WS-DIST2 WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tempt goal is scared by a player who moved more than 0.1 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.005 TO WS-DIST2
     MOVE 6 TO WS-FROLL
     CALL "TEMPT-SCARED" USING WS-DIST WS-DIST2 WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tempt goal is scared by a player who turned more than 5 degrees" TO TL-CASE
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-FROLL
     CALL "TEMPT-SCARED" USING WS-DIST WS-DIST2 WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tempt goal ignores a slow steady player" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-DIST
     MOVE 0.02 TO WS-DIST2
     CALL "TEMPT-SCARED" USING WS-DIST WS-DIST2 WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tempt goal is not scared beyond 6 blocks" TO TL-CASE
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 36 TO WS-DIST
     CALL "TEMPT-SCARED" USING WS-DIST WS-DIST2 WS-FROLL WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a tempt goal is not scared at exactly 6 blocks" TO TL-CASE
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Search sequence 0, 1, -1, 2, -2 (MoveToBlockGoal): next = 1 - v when v <= 0, -v when v > 0.
     MOVE 0 TO WS-A
     CALL "SEQUENCE-NEXT" USING WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue search sequence after 0 is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "SEQUENCE-NEXT" USING WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue search sequence after 1 is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-A
     CALL "SEQUENCE-NEXT" USING WS-A WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue search sequence after -1 is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Random direction (h, v, three draws of nextInt(2h+1), nextInt(2v+1), nextInt(2h+1)): (rx - h, ry - v, rz - h).
     MOVE 10 TO WS-A
     MOVE 7 TO WS-B
     MOVE 3 TO WS-C
     MOVE 14 TO WS-D
     MOVE 20 TO WS-E
     CALL "RANDOM-DIRECTION" USING WS-A WS-B WS-C WS-D WS-E WS-OUT WS-OUT2 WS-OUT3
     MOVE "acceptance US15 18§4.2 Shared goal catalogue random direction offsets the draws by the ranges" TO TL-CASE
     COMPUTE TL-EXPECTED-N = -70000 + 700 + 10
     COMPUTE TL-OBSERVED-N = WS-OUT * 10000 + WS-OUT2 * 100 + WS-OUT3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Restriction: restricted when the squared distance to the home is not below (radius + hRange + 1)^2.
     *> args: has home, squared distance (float), radius, hRange, out
     MOVE 1 TO WS-A
     MOVE 99 TO WS-DIST
     MOVE 3 TO WS-B
     MOVE 6 TO WS-C
     CALL "MOB-RESTRICTED" USING WS-A WS-DIST WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a mob close to its home is not restricted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-DIST
     CALL "MOB-RESTRICTED" USING WS-A WS-DIST WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a mob at radius + range + 1 from its home is restricted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "MOB-RESTRICTED" USING WS-A WS-DIST WS-B WS-C WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a mob without a home is never restricted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Door interaction (44 x2 10.4): passed once the offset to the door centre has crossed the plane of the start offset.
     MOVE 1 TO WS-DIST
     MOVE 0 TO WS-DIST2
     MOVE 1 TO WS-SPEED
     MOVE 0 TO WS-WIDTH
     CALL "DOOR-PASSED" USING WS-DIST WS-DIST2 WS-SPEED WS-WIDTH WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a mob before the door has not passed it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.5 TO WS-DIST
     CALL "DOOR-PASSED" USING WS-DIST WS-DIST2 WS-SPEED WS-WIDTH WS-OUT
     MOVE "acceptance US15 18§4.2 Shared goal catalogue a mob beyond the door has passed it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Melee range R = sqrt(2.0399999618530273) - 0.6000000238418579 ~ 0.8283.
     CALL "MELEE-RANGE" USING WS-SPEED
     MOVE "acceptance US15 18§4.2 Shared goal catalogue melee range is about 0.8283 blocks" TO TL-CASE
     MOVE 8283 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-2.
