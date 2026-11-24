*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 8 (shared base-class
*> physics): RisingParticle, SimpleAnimatedParticle (E7), SimpleVerticalParticle, FallingParticle (E12)
*> and BaseAshSmokeParticle with their constructor draws and tick rules.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-SCALE               BINARY-DOUBLE.
 01 WS-N                   BINARY-LONG.
 01 WS-RGB                 BINARY-DOUBLE.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-ARGS.
    05 WS-GRAVITY-SCALE    FLOAT-LONG.
    05 WS-WIND-BIG         FLOAT-LONG.
    05 WS-SWIRL            BINARY-LONG.
    05 WS-FLOW-AWAY        BINARY-LONG.
    05 WS-SIZE-SCALE       FLOAT-LONG.
    05 WS-FALL-SPEED       FLOAT-LONG.
 01 WS-ASH.
    05 WS-A-VXM            FLOAT-LONG.
    05 WS-A-VYM            FLOAT-LONG.
    05 WS-A-VZM            FLOAT-LONG.
    05 WS-A-AX             FLOAT-LONG.
    05 WS-A-AY             FLOAT-LONG.
    05 WS-A-AZ             FLOAT-LONG.
    05 WS-A-SCALE          FLOAT-LONG.
    05 WS-A-COLOUR         FLOAT-LONG.
    05 WS-A-LIFE           FLOAT-LONG.
    05 WS-A-GRAVITY        FLOAT-LONG.
    05 WS-A-PHYSICS        BINARY-LONG.
 01 WS-PARTIAL             FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO PK-COUNT
     MOVE 10.0 TO WS-X
     MOVE 20.0 TO WS-Y
     MOVE 30.0 TO WS-Z
*>   8.1 RisingParticle: draws 1-6 base velocity, 7 quad size, 8-13 position jitter (a, b per axis), 14 lifetime.
     MOVE 0.5 TO WS-D(1)
     MOVE 0.75 TO WS-D(2)
     MOVE 0.5 TO WS-D(3)
     MOVE 0.25 TO WS-D(4)
     MOVE 0.5 TO WS-D(5) WS-D(6)
     MOVE 1.0 TO WS-D(7)
     MOVE 0.9 TO WS-D(8)
     MOVE 0.5 TO WS-D(9)
     MOVE 0.5 TO WS-D(10) WS-D(11)
     MOVE 0.2 TO WS-D(12)
     MOVE 0.8 TO WS-D(13)
     MOVE 1.0 TO WS-D(14)
     MOVE 0 TO WS-VX WS-VZ
     MOVE 0.05 TO WS-VY
     CALL "PRISE-NEW" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE 1000 TO WS-SCALE
     MOVE "rising: friction 0.96" TO WS-NAME
     MOVE PC-FRICTION TO WS-VAL
     MOVE 960 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: supplied (0, 0.05, 0) biases the base xd to 0.08356; times 0.01 gives 0.000836 (hundred thousandths 84)" TO WS-NAME
     MOVE 100000 TO WS-SCALE
     MOVE PC-XD TO WS-VAL
     MOVE 84 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: yd = base yd 0.12089 * 0.01 + supplied 0.05 = 0.051209" TO WS-NAME
     MOVE PC-YD TO WS-VAL
     MOVE 5121 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: x jitter (0.9 - 0.5) * 0.05 = 0.02 added to 10 (not re-centred: old position kept)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-X TO WS-VAL
     MOVE 10020 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: y jitter 0, z jitter (0.2 - 0.8) * 0.05 = -0.03" TO WS-NAME
     MOVE PC-Z TO WS-VAL
     MOVE 29970 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: xo stays at the original position 10" TO WS-NAME
     MOVE PC-XO TO WS-VAL
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "rising: lifetime (int)(8 / (1.0 * 0.8 + 0.2)) + 4 = 12" TO WS-NAME
     MOVE 12 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.0 TO WS-D(14)
     CALL "PRISE-NEW" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE "rising: lifetime for r = 0 is (int)(8 / 0.2) + 4 = 44" TO WS-NAME
     MOVE 44 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   8.2 SimpleAnimatedParticle: draws lifetime, quad size. friction 0.91, gravity stored, sprite first.
     MOVE 0.5 TO WS-D(1)
     MOVE 1.0 TO WS-D(2)
     MOVE 0.25 TO WS-VAL
     CALL "PSA-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-VAL WS-DRAWS
     MOVE "simple animated: friction 0.91, gravity 0.25, sprite index 0" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     COMPUTE TL-EXPECTED-N = 910 * 1000000 + 250 * 1000 + 0
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-FRICTION * 1000 + 0.5) * 1000000
         + FUNCTION INTEGER(PC-GRAVITY * 1000 + 0.5) * 1000 + PC-SPRITE
     PERFORM ASSERT-NUMBER
     CALL "PSA-CONSTANTS" USING WS-LIGHT WS-LAYER
     MOVE "simple animated: light 15728880 and layer TRANSLUCENT (1)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 15728880 + 1
     COMPUTE TL-OBSERVED-N = WS-LIGHT + WS-LAYER
     PERFORM ASSERT-NUMBER
*>   setColor(int) splits an RGB24: 0xFF0080 -> (1.0, 0, 128/255); alpha untouched.
     MOVE 16711808 TO WS-RGB
     CALL "PSA-SET-COLOR" USING PCL WS-RGB
     MOVE "setColor(int): red 1.0, green 0, blue 128/255 (thousandths 502), alpha untouched" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1000 * 1000000 + 0 * 1000 + 502 + 0
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-RCOL * 1000 + 0.5) * 1000000
         + FUNCTION INTEGER(PC-GCOL * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-BCOL * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "setColor(int): alpha stays 1.0" TO WS-NAME
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-ALPHA * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   E7: lifetime 20, age 15 (after the tick), fade (1, 0, 0), colour (0, 0, 1): alpha 0.75, colour (0.2, 0, 0.8).
     MOVE 20 TO PC-LIFETIME
     MOVE 14 TO PC-AGE
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-GRAVITY
     MOVE 0 TO PC-RCOL PC-GCOL
     MOVE 1.0 TO PC-BCOL
     MOVE 16711680 TO WS-RGB
     CALL "PSA-SET-FADE" USING PCLX WS-RGB
     MOVE 8 TO WS-N
     CALL "PSA-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     MOVE "E7: age 15 > 10: alpha 1 - (15 - 10) / 20 = 0.75" TO WS-NAME
     MOVE PC-ALPHA TO WS-VAL
     MOVE 750 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E7: colour moves 20 percent to the fade colour: r 0.2" TO WS-NAME
     MOVE PC-RCOL TO WS-VAL
     MOVE 200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E7: b 0.8" TO WS-NAME
     MOVE PC-BCOL TO WS-VAL
     MOVE 800 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E7: sprite from age 15 of 20 with 8 sprites is 15 * 7 / 20 = 5" TO WS-NAME
     MOVE 5 TO TL-EXPECTED-N
     MOVE PC-SPRITE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   At age 10 exactly nothing changes (strict greater-than).
     MOVE 1.0 TO PC-ALPHA
     MOVE 0 TO PC-RCOL
     MOVE 1.0 TO PC-BCOL
     MOVE 9 TO PC-AGE
     CALL "PSA-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     MOVE "E7: at age 10 exactly the alpha stays 1.0 and the colour is unchanged" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1000 * 1000 + 1000
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-ALPHA * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-BCOL * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Without a fade colour only the alpha changes.
     MOVE 0 TO PX-HAS-FADE
     MOVE 0 TO PC-RCOL
     MOVE 14 TO PC-AGE
     CALL "PSA-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     MOVE "no fade colour: the colour stays, alpha 0.75" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 750 * 1000 + 0
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-ALPHA * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-RCOL * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   8.3 SimpleVerticalParticle: draws 1-6 base velocity, 7 quad, 8 size multiplier.
     MOVE 0.5 TO WS-D(1)
     MOVE 0.5 TO WS-D(2) WS-D(3) WS-D(4) WS-D(5) WS-D(6)
     MOVE 1.0 TO WS-D(7)
     MOVE 0.5 TO WS-D(8)
     MOVE 0.1 TO WS-VX
     MOVE 0.2 TO WS-VY
     MOVE -0.3 TO WS-VZ
     MOVE 1 TO WS-UP
     CALL "PVERT-NEW" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-UP WS-DRAWS
     MOVE "vertical up: velocity (0.1, 0.23, -0.3), gravity 0, lifetime 8" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 100 * 1000000000 + 230 * 100000 - 300 * 0 + 8
     MOVE 1000 TO WS-SCALE
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 1000 + 0.5) * 1000000000
         + FUNCTION INTEGER(PC-YD * 1000 + 0.5) * 100000 + PC-LIFETIME + FUNCTION INTEGER(PC-GRAVITY)
     PERFORM ASSERT-NUMBER
     MOVE "vertical: zd = supplied -0.3 exactly (overwrites the random part)" TO WS-NAME
     MOVE PC-ZD TO WS-VAL
     MOVE -300 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "vertical: quadSize = 0.2 * (0.5 * 0.6 + 0.5) = 0.16" TO WS-NAME
     MOVE 100 TO WS-SCALE
     MOVE PC-QUAD-SIZE TO WS-VAL
     MOVE 16 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0 TO WS-UP
     CALL "PVERT-NEW" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-UP WS-DRAWS
     MOVE "vertical down: yd = 0.2 - 0.03 = 0.17" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-YD TO WS-VAL
     MOVE 170 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   8.4 FallingParticle (E12): gravityScale 1.0, windBig 2, flowAway, sizeScale 1, fallSpeed 0.5.
     MOVE 1.0 TO WS-GRAVITY-SCALE
     MOVE 2.0 TO WS-WIND-BIG
     MOVE 0 TO WS-SWIRL
     MOVE 1 TO WS-FLOW-AWAY
     MOVE 1.0 TO WS-SIZE-SCALE
     MOVE 0.5 TO WS-FALL-SPEED
     MOVE 0.5 TO WS-D(1) WS-D(2)
     MOVE 1 TO WS-D(3)
     MOVE 0 TO WS-D(4)
     MOVE 1 TO WS-D(5)
     MOVE 0.0 TO WS-D(6)
     CALL "PFALL-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-ARGS WS-DRAWS
     MOVE 1000000 TO WS-SCALE
     MOVE "E12: first boolean true: rotSpeed -30 degrees = -0.5236 rad" TO WS-NAME
     MOVE PX-ROT-SPEED TO WS-VAL
     MOVE -523599 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "second boolean false: spin acceleration +5 degrees = 0.0873 rad" TO WS-NAME
     MOVE PX-SPIN-ACC TO WS-VAL
     MOVE 87266 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E12: gravity = gravityScale * 1.2 * 0.0025 = 0.003 (thousandths)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-GRAVITY TO WS-VAL
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E12: third boolean true: quadSize 0.05 and box 0.05" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     COMPUTE TL-EXPECTED-N = 50 * 1000 + 50
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-QUAD-SIZE * 1000 + 0.5) * 1000
         + FUNCTION INTEGER((PC-BB-MAX(1) - PC-BB-MIN(1)) * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "falling: lifetime 300, friction 1.0, yd = -fallSpeed (thousandths 300 / 1000 / -500)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 300 * 1000000 + 1000 * 1000 - 500
     COMPUTE TL-OBSERVED-N = PC-LIFETIME * 1000000 + FUNCTION INTEGER(PC-FRICTION * 1000 + 0.5) * 1000
         + FUNCTION INTEGER(PC-YD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "E12: f = 0: xaFlowScale = cos(0) * 2 = 2, zaFlowScale 0, swirl period 1000 degrees" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 2000 * 100000 + 0 * 100 + 17
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PX-XA-FLOW * 1000 + 0.5) * 100000
         + FUNCTION INTEGER(PX-ZA-FLOW * 1000 + 0.5) * 100 + FUNCTION INTEGER(PX-SWIRL-PERIOD + 0.5)
     PERFORM ASSERT-NUMBER
*>   Second set of booleans: false, true, false -> +30 degrees, -5 degrees, quadSize 0.075.
     MOVE 0 TO WS-D(3)
     MOVE 1 TO WS-D(4)
     MOVE 0 TO WS-D(5)
     CALL "PFALL-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-ARGS WS-DRAWS
     MOVE "falling: false/true/false gives +0.5236, -0.0873 and quadSize 0.075" TO WS-NAME
     MOVE 1000000 TO WS-SCALE
     COMPUTE TL-EXPECTED-N = 523599 + 0 * 0
     MOVE PX-ROT-SPEED TO WS-VAL
     PERFORM ASSERT-SCALED
     MOVE PX-SPIN-ACC TO WS-VAL
     MOVE -87266 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 1000 TO WS-SCALE
     MOVE PC-QUAD-SIZE TO WS-VAL
     MOVE 75 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   E12 tick: lifetime 151 -> 150 gives t = 0.5; dx = 2 * 0.5^1.25 = 0.8409; xd gains 0.0021.
     MOVE 1 TO WS-FLOW-AWAY
     MOVE 1 TO WS-D(3)
     MOVE 0 TO WS-D(4)
     MOVE 1 TO WS-D(5)
     CALL "PFALL-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-ARGS WS-DRAWS
     MOVE 151 TO PC-LIFETIME
     MOVE 0 TO PC-XD PC-ZD PC-YD
     MOVE 0 TO PC-HAS-PHYSICS
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "E12 tick: xd gains 0.8409 * 0.0025 = 0.0021 (ten thousandths)" TO WS-NAME
     MOVE 10000 TO WS-SCALE
     MOVE PC-XD TO WS-VAL
     MOVE 21 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "falling tick: lifetime counts down to 150 and age is not used" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 150 * 10 + 0
     COMPUTE TL-OBSERVED-N = PC-LIFETIME * 10 + PC-AGE
     PERFORM ASSERT-NUMBER
     MOVE "falling tick: yd -= gravity: -0.003 (thousandths)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-YD TO WS-VAL
     MOVE -3 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "falling tick: rotSpeed -0.5236 + 0.0873 / 20, roll += rotSpeed / 20 = -0.025962 (millionths)" TO WS-NAME
     MOVE 1000000 TO WS-SCALE
     MOVE PC-ROLL TO WS-VAL
     MOVE -25962 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   Tick with a swirl: dx and dz also gain t * cos / sin(t * swirlPeriod) * windBig.
     MOVE 0 TO WS-FLOW-AWAY
     MOVE 1 TO WS-SWIRL
     CALL "PFALL-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-ARGS WS-DRAWS
     MOVE 151 TO PC-LIFETIME
     MOVE 0 TO PC-XD PC-ZD PC-YD
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0.0 TO PX-SWIRL-PERIOD
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "swirl with period 0: dx = t * cos(0) * windBig = 0.5 * 2 = 1, xd 0.0025 (ten thousandths 25)" TO WS-NAME
     MOVE 10000 TO WS-SCALE
     MOVE PC-XD TO WS-VAL
     MOVE 25 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "swirl with period 0: dz = t * sin(0) * windBig = 0" TO WS-NAME
     MOVE PC-ZD TO WS-VAL
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   Neither flag: the xd and zd update runs with dx = dz = 0.
     MOVE 0 TO PX-SWIRL PX-FLOW-AWAY
     MOVE 151 TO PC-LIFETIME
     MOVE 0 TO PC-XD PC-ZD
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "no flag: xd and zd stay 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 10000 + 0.5) + FUNCTION INTEGER(PC-ZD * 10000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Removal: old lifetime <= 0 removes; onGround removes; lifetime < 299 with xd = 0 removes.
     MOVE 0 TO PC-LIFETIME
     MOVE 0 TO PC-REMOVED
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "falling tick: an old lifetime of 0 removes the particle" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-REMOVED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 200 TO PC-LIFETIME
     MOVE 0 TO PC-REMOVED
     MOVE 0 TO PC-XD PC-ZD
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "falling tick: lifetime below 299 and xd = 0 removes the particle" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-REMOVED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO PC-HAS-PHYSICS
     MOVE 1 TO PK-COUNT
     MOVE 9.0 TO PK-MIN(1, 1)
     MOVE 19.0 TO PK-MIN(1, 2)
     MOVE 29.0 TO PK-MIN(1, 3)
     MOVE 11.0 TO PK-MAX(1, 1)
     MOVE 20.0 TO PK-MAX(1, 2)
     MOVE 31.0 TO PK-MAX(1, 3)
     MOVE 1 TO PX-SWIRL
     MOVE 0.1 TO PC-XD
     MOVE 0.1 TO PC-ZD
     MOVE 0 TO PC-REMOVED
     MOVE 298 TO PC-LIFETIME
     MOVE 20.2 TO PC-BB-MIN(2)
     MOVE 20.6 TO PC-BB-MAX(2)
     MOVE 20.2 TO PC-Y
     MOVE -0.5 TO PC-YD
     MOVE 0.0 TO PX-SWIRL-PERIOD
     MOVE 0 TO PX-SWIRL
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "falling tick: landing on a block (onGround) removes the particle" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-REMOVED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO PK-COUNT
     MOVE 0 TO PC-REMOVED
     MOVE 299 TO PC-LIFETIME
     MOVE 0.1 TO PC-XD PC-ZD
     MOVE 0 TO PC-YD
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-GRAVITY
     CALL "PFALL-TICK" USING PCL PCLX PCL-COLLIDERS
     MOVE "falling tick: friction 1.0 leaves xd unchanged (hundredths 10), not removed" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 10 * 10 + 0
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 100 + 0.5) * 10 + PC-REMOVED
     PERFORM ASSERT-NUMBER
*>   8.5 BaseAshSmokeParticle: draws 1-6 base velocity (zero bias), 7 quad size, 8 grey, 9 lifetime.
     MOVE 0.5 TO WS-D(1)
     MOVE 0.5 TO WS-D(2) WS-D(3) WS-D(4)
     MOVE 0.5 TO WS-D(5) WS-D(6)
     MOVE 1.0 TO WS-D(7)
     MOVE 0.5 TO WS-D(8)
     MOVE 1.0 TO WS-D(9)
     MOVE 2.0 TO WS-A-VXM WS-A-VYM WS-A-VZM
     MOVE 0.1 TO WS-A-AX
     MOVE 0.2 TO WS-A-AY
     MOVE 0.3 TO WS-A-AZ
     MOVE 2.0 TO WS-A-SCALE
     MOVE 0.8 TO WS-A-COLOUR
     MOVE 10.0 TO WS-A-LIFE
     MOVE 0.1 TO WS-A-GRAVITY
     MOVE 0 TO WS-A-PHYSICS
     CALL "PASH-NEW" USING PCL WS-X WS-Y WS-Z WS-ASH WS-DRAWS
     MOVE "ash: friction 0.96, speedUp on, hasPhysics stored (0), gravity 0.1 (thousandths)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     COMPUTE TL-EXPECTED-N = 960 * 1000000 + 1 * 100000 + 0 * 10000 + 100
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-FRICTION * 1000 + 0.5) * 1000000 + PC-SPEED-UP * 100000
         + PC-HAS-PHYSICS * 10000 + FUNCTION INTEGER(PC-GRAVITY * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "ash: grey = r * colourMul = 0.5 * 0.8 = 0.4 on all three channels" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 400400400
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-RCOL * 1000 + 0.5) * 1000000
         + FUNCTION INTEGER(PC-GCOL * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-BCOL * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "ash: quadSize = 0.2 * 0.75 * 2 = 0.3" TO WS-NAME
     MOVE PC-QUAD-SIZE TO WS-VAL
     MOVE 300 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "ash: lifetime = (int)(10 / (1.0 * 0.8 + 0.2) * 2) = 20" TO WS-NAME
     MOVE 20 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "ash: velocity = base * multiplier + add-on: yd = 0.1 * 2 + 0.2 = 0.4" TO WS-NAME
     MOVE PC-YD TO WS-VAL
     MOVE 400 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "ash: xd = 0 * 2 + 0.1 = 0.1 (zero bias, the 0.8 / 0.8 normalisation cancels)" TO WS-NAME
     MOVE PC-XD TO WS-VAL
     MOVE 100 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   Lifetime at least 1.
     MOVE 1.0 TO WS-D(9)
     MOVE 0.0 TO WS-A-LIFE
     CALL "PASH-NEW" USING PCL WS-X WS-Y WS-Z WS-ASH WS-DRAWS
     MOVE "ash: lifetime is at least 1" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   getQuadSize(partial) = quadSize * clamp((age + partial) / lifetime * 32, 0, 1).
     MOVE 0.3 TO PC-QUAD-SIZE
     MOVE 64 TO PC-LIFETIME
     MOVE 0 TO PC-AGE
     MOVE 0.5 TO WS-PARTIAL
     CALL "PASH-QUAD-SIZE" USING PCL WS-PARTIAL WS-VAL
     MOVE "ash getQuadSize: age 0.5 of 64: factor 0.25, size 0.075 (thousandths)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE 75 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 10 TO PC-AGE
     CALL "PASH-QUAD-SIZE" USING PCL WS-PARTIAL WS-VAL
     MOVE "ash getQuadSize: after the first 1/32 of the life the full size 0.3" TO WS-NAME
     MOVE 300 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   tick: base tick then setSpriteFromAge.
     MOVE 8 TO WS-N
     MOVE 40 TO PC-LIFETIME
     MOVE 19 TO PC-AGE
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-REMOVED
     CALL "PASH-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     MOVE "ash tick: age 20 of 40 with 8 sprites gives sprite 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE PC-SPRITE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§8 Shared base-class physics: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VAL * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.
 END PROGRAM TEST-PARTICLES-42-1-8.
