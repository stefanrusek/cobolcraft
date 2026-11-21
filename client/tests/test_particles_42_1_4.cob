*> Acceptance test of docs/protocol/42-particles-1-shared-model-engine.md section 4 (Particle and
*> SingleQuadParticle): construction and the lifetime formula (E1, E2), velocity draws, setPower,
*> setSize, setPos, the base tick order, movement and the collision resolver (worked case), the quad
*> size rule, facing modes, roll, quad geometry and UV order, layers, transparency, light, sprite by age.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-1-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 6 TIMES.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-SCALE               BINARY-DOUBLE.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT2                BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-Q.
    05 WS-QV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-QOUT.
    05 WS-QO               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-P1                  FLOAT-LONG.
 01 WS-P2                  FLOAT-LONG.
 01 WS-P3                  FLOAT-LONG.
 01 WS-VERTS.
    05 WS-VERT             OCCURS 4 TIMES.
       10 WS-VC            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-UVS.
    05 WS-UV               OCCURS 4 TIMES.
       10 WS-UC            FLOAT-LONG OCCURS 2 TIMES.
 01 WS-ALPHAS               PIC X(8).
 01 WS-HAS-TRANSPARENT     BINARY-LONG.
 01 WS-HAS-TRANSLUCENT     BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-EMISSIVE            BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EMISSION            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
*>   E1: lifetime r 0.5; a b c = 0.75 0.5 0.25; d e = 0.5 0.5 -> lifetime 7, xd 0.08485, yd 0.1, zd -0.08485
     MOVE 0.5 TO WS-DRAW(1)
     MOVE 0.75 TO WS-DRAW(2)
     MOVE 0.5 TO WS-DRAW(3)
     MOVE 0.25 TO WS-DRAW(4)
     MOVE 0.5 TO WS-DRAW(5)
     MOVE 0.5 TO WS-DRAW(6)
     MOVE 1.0 TO WS-X
     MOVE 2.0 TO WS-Y
     MOVE 3.0 TO WS-Z
     MOVE 0 TO WS-VX WS-VY WS-VZ
     CALL "PCL-NEW-VEL" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE "E1: lifetime 7" TO WS-NAME
     MOVE 7 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "E1: xd 0.08485 (hundred thousandths)" TO WS-NAME
     MOVE 100000 TO WS-SCALE
     MOVE PC-XD TO WS-VAL
     MOVE 8485 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E1: yd 0.1 (the f32 constant 0.10000000149011612)" TO WS-NAME
     MOVE PC-YD TO WS-VAL
     MOVE 10000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "E1: zd -0.08485" TO WS-NAME
     MOVE PC-ZD TO WS-VAL
     MOVE -8485 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   Construction defaults.
     MOVE "construction: friction 0.98 and gravity 0" TO WS-NAME
     MOVE 1000000 TO WS-SCALE
     MOVE PC-FRICTION TO WS-VAL
     MOVE 980000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "construction: hasPhysics 1, speedUp 0, onGround 0, removed 0, age 0, gravity 0" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1000
     COMPUTE TL-OBSERVED-N = PC-HAS-PHYSICS * 1000 + PC-SPEED-UP * 100 + PC-ON-GROUND * 10
         + PC-REMOVED + PC-AGE + FUNCTION INTEGER(PC-GRAVITY)
     PERFORM ASSERT-NUMBER
     MOVE "construction: box 0.2 by 0.2 centred on x z, from y (thousandths: minx 900)" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-BB-MIN(1) TO WS-VAL
     MOVE 900 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "construction: box max y is y + 0.2" TO WS-NAME
     MOVE PC-BB-MAX(2) TO WS-VAL
     MOVE 2200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "construction: old position equals position" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1002003
     COMPUTE TL-OBSERVED-N = PC-XO * 1000000 + PC-YO * 1000 + PC-ZO
     PERFORM ASSERT-NUMBER
*>   E2 and position-only construction: lifetime draw 0 -> 40, near 1 -> 4, 0.5 -> 7.
     MOVE 0.0 TO WS-DRAW(1)
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE "E2: draw 0 gives lifetime 40" TO WS-NAME
     MOVE 40 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.999 TO WS-DRAW(1)
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE "E2: draw near 1 gives lifetime 4" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "position-only construction: velocity is zero" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(PC-XD) + FUNCTION ABS(PC-YD) + FUNCTION ABS(PC-ZD)
     PERFORM ASSERT-NUMBER
*>   Supplied velocity biases before normalisation: (1, 0, 0) with a = b = c = 0.5 keeps direction +x.
     MOVE 0.5 TO WS-DRAW(1)
     MOVE 0.5 TO WS-DRAW(2) WS-DRAW(3) WS-DRAW(4)
     MOVE 0.5 TO WS-DRAW(5) WS-DRAW(6)
     MOVE 1.0 TO WS-VX
     CALL "PCL-NEW-VEL" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE "velocity: supplied (1,0,0) normalised: xd = 0.3 * 0.4 = 0.12, yd 0.1" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-XD TO WS-VAL
     MOVE 120 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
*>   setPower(2): xd *= 2, yd = (yd - 0.1) * 2 + 0.1, zd *= 2.
     MOVE 0.12 TO PC-XD
     MOVE 0.3 TO PC-YD
     MOVE -0.05 TO PC-ZD
     MOVE 2.0 TO WS-VAL
     CALL "PCL-SET-POWER" USING PCL WS-VAL
     MOVE "setPower: xd 0.24, yd 0.5, zd -0.1 (thousandths)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 240 * 1000000 + 500 * 1000 - 100
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 1000 + 0.5) * 1000000
         + FUNCTION INTEGER(PC-YD * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-ZD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   setSize keeps horizontal centre and minimum y; setPos centres on x z and extends from y.
     MOVE 10.0 TO WS-X
     MOVE 64.0 TO WS-Y
     MOVE 20.0 TO WS-Z
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     MOVE 0.5 TO WS-P1
     MOVE 0.4 TO WS-P2
     CALL "PCL-SET-SIZE" USING PCL WS-P1 WS-P2
     MOVE "setSize 0.5 by 0.4: box min x 9.75, max x 10.25, min y 64, max y 64.4 (hundredths)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 975 * 1000000 + 1025 * 1000 + 6400 + 6440
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-BB-MIN(1) * 100 + 0.5) * 1000000
         + FUNCTION INTEGER(PC-BB-MAX(1) * 100 + 0.5) * 1000 + FUNCTION INTEGER(PC-BB-MIN(2) * 100 + 0.5)
         + FUNCTION INTEGER(PC-BB-MAX(2) * 100 + 0.5) - 6400 * 0 - 6400 + 6400
     PERFORM ASSERT-NUMBER
     MOVE 2.0 TO WS-P1
     CALL "PCL-SCALE" USING PCL WS-P1
     MOVE "scale(2): box 0.4 by 0.4 (box width in hundredths)" TO WS-NAME
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-BB-MAX(1) - PC-BB-MIN(1)) * 100 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "setLocationFromBoundingbox: position from the box" TO WS-NAME
     MOVE 5.0 TO PC-BB-MIN(1)
     MOVE 6.0 TO PC-BB-MAX(1)
     MOVE 70.0 TO PC-BB-MIN(2)
     MOVE 7.0 TO PC-BB-MIN(3)
     MOVE 9.0 TO PC-BB-MAX(3)
     CALL "PCL-LOC-FROM-BOX" USING PCL
     COMPUTE TL-EXPECTED-N = 55 * 1000000 + 70 * 1000 + 8
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-X * 10 + 0.5) * 1000000 + PC-Y * 1000 + PC-Z
     PERFORM ASSERT-NUMBER
*>   Tick: moves for lifetime ticks and is removed on the next one. lifetime 2, no gravity.
     MOVE 0.0 TO WS-DRAW(1)
     MOVE 0.8 TO WS-DRAW(1)
     MOVE 0 TO PK-COUNT
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 2 TO PC-LIFETIME
     MOVE 0.1 TO PC-XD
     MOVE 1.0 TO PC-FRICTION
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: after two ticks (lifetime 2) age is 2 and the particle is alive" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 2 * 10 + 1
     COMPUTE TL-OBSERVED-N = PC-AGE * 10 + (1 - PC-REMOVED)
     PERFORM ASSERT-NUMBER
     MOVE "tick: two moves of xd 0.1 shift x by 0.2 (hundredths)" TO WS-NAME
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-X - 10.0) * 100 + 0.5)
     PERFORM ASSERT-NUMBER
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: removed on the tick after lifetime, age not incremented" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 2
     COMPUTE TL-OBSERVED-N = PC-REMOVED * 1000 + PC-AGE
     PERFORM ASSERT-NUMBER
     MOVE "tick: the removing tick does not move the particle (x stays 10.2)" TO WS-NAME
     MOVE 1020 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-X * 100 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Tick physics: gravity 1.0 -> yd -= 0.04; friction 0.5 halves; ground factor.
     MOVE 0.8 TO WS-DRAW(1)
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 1.0 TO PC-GRAVITY
     MOVE 0.5 TO PC-FRICTION
     MOVE 0.0 TO PC-XD PC-YD PC-ZD
     MOVE 0 TO PK-COUNT
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: gravity 1 gives yd -0.04 before the move: y moves by -0.04 (thousandths)" TO WS-NAME
     MOVE -40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-Y - PC-YO) * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "tick: friction 0.5 leaves yd -0.02 (thousandths)" TO WS-NAME
     MOVE -20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-YD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Worked case of 4.4: falling dy -0.3, bottom 0.1 above a full block top.
     MOVE 5.0 TO WS-X
     MOVE 10.1 TO WS-Y
     MOVE 5.0 TO WS-Z
     MOVE 0.8 TO WS-DRAW(1)
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 1 TO PK-COUNT
     MOVE 4.0 TO PK-MIN(1, 1)
     MOVE 9.0 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 5.0 TO PK-MAX(1, 1)
     MOVE 10.0 TO PK-MAX(1, 2)
     MOVE 5.0 TO PK-MAX(1, 3)
     MOVE 6.0 TO PK-MAX(1, 1)
     MOVE 6.0 TO PK-MAX(1, 3)
     MOVE 0 TO WS-VX WS-VZ
     MOVE -0.3 TO WS-VY
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "move: falling case: bottom 0.1 above the block top, dy -0.3 resolves to -0.1 (y 10.0)" TO WS-NAME
     MOVE 10000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-Y * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "move: falling case sets onGround" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-ON-GROUND TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "move: falling case does not set stoppedByCollision (resolved dy is -0.1)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE PC-STOPPED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Collision with a wall: dx blocked sets xd to 0; Y first, then X when |dx| >= |dz|.
     MOVE 5.0 TO WS-X
     MOVE 11.0 TO WS-Y
     MOVE 5.0 TO WS-Z
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 1 TO PK-COUNT
     MOVE 5.5 TO PK-MIN(1, 1)
     MOVE 10.0 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 6.5 TO PK-MAX(1, 1)
     MOVE 12.0 TO PK-MAX(1, 2)
     MOVE 6.0 TO PK-MAX(1, 3)
     MOVE 0.5 TO PC-XD
     MOVE 0.2 TO PC-ZD
     MOVE 0.5 TO WS-VX
     MOVE 0.2 TO WS-VZ
     MOVE 0 TO WS-VY
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "move: wall at x 5.5 clips dx to 0.4 (box half 0.1): x 5.4, xd zeroed, z moved 0.2" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 5400 * 1000 + 5200
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-X * 1000 + 0.5) * 1000 + FUNCTION INTEGER(PC-Z * 1000 + 0.5)
         + FUNCTION INTEGER(PC-XD * 1000) * 1000
     PERFORM ASSERT-NUMBER
     MOVE "move: zd stays when z is not blocked" TO WS-NAME
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-ZD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   stoppedByCollision blocks all motion afterwards.
     MOVE 1 TO PC-STOPPED
     MOVE 0 TO PK-COUNT
     MOVE 1.0 TO WS-VX
     MOVE 0 TO WS-VY WS-VZ
     MOVE PC-X TO WS-P1
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "move: stoppedByCollision leaves the particle where it is" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-X - WS-P1) * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   No physics: motion is applied unresolved.
     MOVE 0 TO PC-STOPPED
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 1 TO PK-COUNT
     MOVE 3.0 TO WS-VX
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "move: hasPhysics false ignores colliders" TO WS-NAME
     MOVE 8400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-X * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Tiny dy blocked: intended |dy| >= 1e-5 resolved < 1e-5 sets stoppedByCollision.
     MOVE 1 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-STOPPED
     MOVE 5.0 TO WS-X
     MOVE 11.0 TO WS-Y
     MOVE 5.0 TO WS-Z
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 1 TO PK-COUNT
     MOVE 4.0 TO PK-MIN(1, 1)
     MOVE 10.9 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 6.0 TO PK-MAX(1, 1)
     MOVE 11.0 TO PK-MAX(1, 2)
     MOVE 6.0 TO PK-MAX(1, 3)
     MOVE 0 TO WS-VX
     MOVE -0.001 TO WS-VY
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "move: resting on a block, dy blocked entirely sets stoppedByCollision and onGround" TO WS-NAME
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-STOPPED * 10 + PC-ON-GROUND
     PERFORM ASSERT-NUMBER
*>   Tick: onGround halves horizontal velocity by 0.699999988079071; speedUp x1.1 when y did not change.
     MOVE 0 TO PK-COUNT
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 1 TO PC-ON-GROUND
     MOVE 1 TO PC-LIFETIME
     MOVE 1.0 TO PC-XD PC-ZD
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 100 TO PC-LIFETIME
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: move resets onGround (intended dy 0), so xd stays 1.0 (hundredths 100)" TO WS-NAME
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 100 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO PC-SPEED-UP
     MOVE 1.0 TO PC-XD PC-ZD
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: speedUpWhenYMotionIsBlocked multiplies xd and zd by 1.1 when y == yo" TO WS-NAME
     MOVE 110 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 100 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPEED-UP
     MOVE 1 TO PK-COUNT
     MOVE 0.0 TO PC-YD
     MOVE 1.0 TO PC-XD
     MOVE 0.0 TO PC-ZD
     COMPUTE PK-MIN(1, 1) = 100.0
     COMPUTE PK-MAX(1, 1) = 101.0
     COMPUTE PK-MIN(1, 2) = 0.0
     COMPUTE PK-MAX(1, 2) = 1.0
     COMPUTE PK-MIN(1, 3) = 0.0
     COMPUTE PK-MAX(1, 3) = 1.0
     MOVE 5.0 TO WS-X
     MOVE 5.0 TO WS-Z
     MOVE 11.0 TO WS-Y
     MOVE 0 TO PK-COUNT
*>   Quad: construction r -> quadSize 0.1 * (r * 0.5 + 0.5) * 2; colours 1.0, alpha 1.0.
     MOVE 1.0 TO WS-P1
     CALL "PCL-QUAD-NEW" USING PCL WS-P1
     MOVE "quad: r 1.0 gives quadSize 0.2; r 0 gives 0.1" TO WS-NAME
     MOVE 1000 TO WS-SCALE
     MOVE PC-QUAD-SIZE TO WS-VAL
     MOVE 200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0.0 TO WS-P1
     CALL "PCL-QUAD-NEW" USING PCL WS-P1
     MOVE PC-QUAD-SIZE TO WS-VAL
     MOVE 100 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "quad: colours and alpha start at 1.0, roll 0" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-RCOL + PC-GCOL + PC-BCOL + PC-ALPHA + PC-ROLL + PC-OROLL
     PERFORM ASSERT-NUMBER
     MOVE 2.0 TO WS-P1
     CALL "PCL-QUAD-SCALE" USING PCL WS-P1
     MOVE "quad scale(2): quadSize doubles to 0.2 and the box becomes 0.4 wide" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 200 * 1000 + 400
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-QUAD-SIZE * 1000 + 0.5) * 1000
         + FUNCTION INTEGER((PC-BB-MAX(1) - PC-BB-MIN(1)) * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0.1 TO WS-P1
     MOVE 0.2 TO WS-P2
     MOVE 0.3 TO WS-P3
     CALL "PCL-SET-COLOR" USING PCL WS-P1 WS-P2 WS-P3
     MOVE 0.4 TO WS-P1
     CALL "PCL-SET-ALPHA" USING PCL WS-P1
     MOVE "setColor and setAlpha assign the channels" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1234
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-RCOL * 10 + 0.5) * 1000
         + FUNCTION INTEGER(PC-GCOL * 10 + 0.5) * 100 + FUNCTION INTEGER(PC-BCOL * 10 + 0.5) * 10
         + FUNCTION INTEGER(PC-ALPHA * 10 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Sprite by age: setSpriteFromAge does nothing when removed.
     MOVE 8 TO WS-N
     MOVE 20 TO PC-LIFETIME
     MOVE 10 TO PC-AGE
     MOVE 0 TO PC-REMOVED
     MOVE 99 TO PC-SPRITE
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     MOVE "setSpriteFromAge: 8 sprites, age 10 of 20 gives index 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE PC-SPRITE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO PC-REMOVED
     MOVE 99 TO PC-SPRITE
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     MOVE "setSpriteFromAge: removed particle keeps its sprite" TO WS-NAME
     MOVE 99 TO TL-EXPECTED-N
     MOVE PC-SPRITE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Facing: LOOKAT_XYZ copies the camera quaternion; LOOKAT_Y zeroes x and z, no renormalisation.
     MOVE 0.1 TO WS-QV(1)
     MOVE 0.2 TO WS-QV(2)
     MOVE 0.3 TO WS-QV(3)
     MOVE 0.9 TO WS-QV(4)
     MOVE 0 TO PC-ROLL PC-OROLL
     MOVE 0.5 TO WS-P1
     MOVE 0 TO WS-MODE
     CALL "PCL-FACING" USING WS-MODE WS-Q PC-ROLL PC-OROLL WS-P1 WS-QOUT
     MOVE "facing LOOKAT_XYZ: quaternion copied" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 1239
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-QO(1) * 10 + 0.5) * 1000
         + FUNCTION INTEGER(WS-QO(2) * 10 + 0.5) * 100 + FUNCTION INTEGER(WS-QO(3) * 10 + 0.5) * 10
         + FUNCTION INTEGER(WS-QO(4) * 10 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-MODE
     CALL "PCL-FACING" USING WS-MODE WS-Q PC-ROLL PC-OROLL WS-P1 WS-QOUT
     MOVE "facing LOOKAT_Y: x and z zeroed, y and w kept" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 29
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-QO(1) * 10 + 0.5) * 1000
         + FUNCTION INTEGER(WS-QO(2) * 10 + 0.5) * 10 + FUNCTION INTEGER(WS-QO(3) * 10 + 0.5) * 100
         + FUNCTION INTEGER(WS-QO(4) * 10 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Roll: rotate about local Z by lerp(partial, oRoll, roll): identity quaternion, roll pi/2 -> z=sin(pi/4).
     MOVE 0 TO WS-QV(1) WS-QV(2) WS-QV(3)
     MOVE 1.0 TO WS-QV(4)
     MOVE 0 TO PC-OROLL
     MOVE 3.141592653589793 TO PC-ROLL
     MOVE 0.5 TO WS-P1
     MOVE 0 TO WS-MODE
     CALL "PCL-FACING" USING WS-MODE WS-Q PC-ROLL PC-OROLL WS-P1 WS-QOUT
     MOVE "roll: lerp 0.5 of pi is pi/2, quaternion z and w are sin(pi/4) = 0.7071 (ten thousandths)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 7071 * 10000 + 7071
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-QO(3) * 10000 + 0.5) * 10000
         + FUNCTION INTEGER(WS-QO(4) * 10000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Quad geometry with the identity facing: size 0.2 -> side 0.4; offsets (1,-1),(1,1),(-1,1),(-1,-1).
     MOVE 0 TO WS-QV(3)
     MOVE 0 TO WS-P1 WS-P2 WS-P3
     MOVE 0.2 TO WS-VAL
     CALL "PCL-QUAD-VERTS" USING WS-Q WS-P1 WS-P2 WS-P3 WS-VAL WS-VERTS
     MOVE "quad vertices: order (+,-), (+,+), (-,+), (-,-) of the local plane, scaled by the size (hundredths)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 20 * 1000000 + -20 * 10000 + 20 * 100 + 20
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VC(1, 1) * 100 + 0.5) * 1000000
         + FUNCTION INTEGER(WS-VC(1, 2) * 100 + 0.5) * 10000 + FUNCTION INTEGER(WS-VC(2, 1) * 100 + 0.5) * 100
         + FUNCTION INTEGER(WS-VC(2, 2) * 100 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "quad vertices: the fourth is (-,-)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = -2020
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VC(4, 1) * 100 + 0.5) * 100
         + FUNCTION INTEGER(WS-VC(4, 2) * 100 + 0.5)
     PERFORM ASSERT-NUMBER
*>   A 90 degree rotation about Z (quaternion z = w = 0.7071) turns (1, -1) into (1, 1).
     MOVE 0 TO WS-QV(1) WS-QV(2)
     MOVE 0.7071067811865476 TO WS-QV(3) WS-QV(4)
     MOVE 1.0 TO WS-VAL
     MOVE 5.0 TO WS-P1
     CALL "PCL-QUAD-VERTS" USING WS-Q WS-P1 WS-P2 WS-P3 WS-VAL WS-VERTS
     MOVE "quad vertices: rotation about Z by 90 degrees and the relative position added" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 6 * 100 + 1
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VC(1, 1) + 0.5) * 100
         + FUNCTION INTEGER(WS-VC(1, 2) + 0.5)
     PERFORM ASSERT-NUMBER
*>   UV order (u1,v1), (u1,v0), (u0,v0), (u0,v1).
     MOVE 0.25 TO WS-P1
     MOVE 0.5 TO WS-P2
     MOVE 0.125 TO WS-P3
     MOVE 0.375 TO WS-VAL
     CALL "PCL-QUAD-UV" USING WS-P1 WS-P2 WS-P3 WS-VAL WS-UVS
     MOVE "quad UV: order (u1,v1), (u1,v0), (u0,v0), (u0,v1)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 50 * 1000000 + 37 * 10000 + 50 * 100 + 12
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-UC(1, 1) * 100 + 0.5) * 1000000
         + FUNCTION INTEGER(WS-UC(1, 2) * 100) * 10000 + FUNCTION INTEGER(WS-UC(2, 1) * 100 + 0.5) * 100
         + FUNCTION INTEGER(WS-UC(2, 2) * 100)
     PERFORM ASSERT-NUMBER
     MOVE "quad UV: the last vertex is (u0, v1)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 25 * 100 + 37
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-UC(4, 1) * 100 + 0.5) * 100
         + FUNCTION INTEGER(WS-UC(4, 2) * 100)
     PERFORM ASSERT-NUMBER
*>   Layer by sprite: atlas 0 particles, 1 blocks, 2 items; translucent adds 1.
     PERFORM VARYING WS-INT FROM 0 BY 1 UNTIL WS-INT > 2
         PERFORM VARYING WS-INT2 FROM 0 BY 1 UNTIL WS-INT2 > 1
             CALL "PCL-LAYER-BY-SPRITE" USING WS-INT WS-INT2 WS-N
             MOVE "layer by sprite: atlas and translucency select one of six layers" TO WS-NAME
             COMPUTE TL-EXPECTED-N = WS-INT * 2 + WS-INT2
             MOVE WS-N TO TL-OBSERVED-N
             PERFORM ASSERT-NUMBER
         END-PERFORM
     END-PERFORM
*>   Transparency: any alpha 0 sets hasTransparent; any other than 0 or 255 sets hasTranslucent.
     MOVE SPACES TO WS-ALPHAS
     MOVE FUNCTION CHAR(256) TO WS-ALPHAS(1:1)
     MOVE FUNCTION CHAR(1) TO WS-ALPHAS(2:1)
     MOVE FUNCTION CHAR(256) TO WS-ALPHAS(3:1)
     MOVE 3 TO WS-N
     MOVE 1 TO WS-INT
     CALL "PCL-TRANSPARENCY" USING WS-INT WS-N WS-ALPHAS WS-HAS-TRANSPARENT WS-HAS-TRANSLUCENT
     MOVE "transparency: an alpha 0 pixel is transparent, not translucent" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HAS-TRANSPARENT * 10 + WS-HAS-TRANSLUCENT
     PERFORM ASSERT-NUMBER
     MOVE FUNCTION CHAR(129) TO WS-ALPHAS(3:1)
     CALL "PCL-TRANSPARENCY" USING WS-INT WS-N WS-ALPHAS WS-HAS-TRANSPARENT WS-HAS-TRANSLUCENT
     MOVE "transparency: alpha 128 is translucent" TO WS-NAME
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HAS-TRANSPARENT * 10 + WS-HAS-TRANSLUCENT
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-INT
     CALL "PCL-TRANSPARENCY" USING WS-INT WS-N WS-ALPHAS WS-HAS-TRANSPARENT WS-HAS-TRANSLUCENT
     MOVE "transparency: a non-RGBA image has none" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HAS-TRANSPARENT * 10 + WS-HAS-TRANSLUCENT
     PERFORM ASSERT-NUMBER
*>   Light: unloaded chunk full sky, emissive block full bright, else packed with the emission raise.
     MOVE 0 TO WS-LOADED WS-EMISSIVE
     MOVE 3 TO WS-SKY
     MOVE 4 TO WS-BLOCK
     MOVE 0 TO WS-EMISSION
     CALL "PCL-LIGHT" USING WS-LOADED WS-EMISSIVE WS-SKY WS-BLOCK WS-EMISSION WS-LIGHT
     MOVE "light: chunk not loaded gives 15728640" TO WS-NAME
     MOVE 15728640 TO TL-EXPECTED-N
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-LOADED WS-EMISSIVE
     CALL "PCL-LIGHT" USING WS-LOADED WS-EMISSIVE WS-SKY WS-BLOCK WS-EMISSION WS-LIGHT
     MOVE "light: emissive-rendering block gives 15728880" TO WS-NAME
     MOVE 15728880 TO TL-EXPECTED-N
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-EMISSIVE
     CALL "PCL-LIGHT" USING WS-LOADED WS-EMISSIVE WS-SKY WS-BLOCK WS-EMISSION WS-LIGHT
     MOVE "light: packed brightness (block 4, sky 3) is 4*16 + 3*1048576" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 4 * 16 + 3 * 1048576
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 14 TO WS-EMISSION
     CALL "PCL-LIGHT" USING WS-LOADED WS-EMISSIVE WS-SKY WS-BLOCK WS-EMISSION WS-LIGHT
     MOVE "light: emission 14 above the block level 4 raises the block bits, sky kept" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 14 * 16 + 3 * 1048576
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-EMISSION
     CALL "PCL-LIGHT" USING WS-LOADED WS-EMISSIVE WS-SKY WS-BLOCK WS-EMISSION WS-LIGHT
     MOVE "light: emission 2 below the block level changes nothing" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 4 * 16 + 3 * 1048576
     MOVE WS-LIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Zero-length velocity sum (a = b = c = 0.5, supplied velocity 0): velocity 0 plus the y constant.
     MOVE 0.5 TO WS-DRAW(1) WS-DRAW(2) WS-DRAW(3) WS-DRAW(4) WS-DRAW(5) WS-DRAW(6)
     MOVE 0 TO WS-VX WS-VY WS-VZ
     CALL "PCL-NEW-VEL" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE "velocity: all three sums zero leaves xd 0, yd 0.1, zd 0 (no division)" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 100
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-YD * 1000 + 0.5) + FUNCTION INTEGER(PC-XD * 1000 + 0.5)
         + FUNCTION INTEGER(PC-ZD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Resolver order: |dx| < |dz| clips Z first. A wall in x at 5.5 and one in z at 5.5; dx 0.3, dz 0.5.
     MOVE 5.0 TO WS-X
     MOVE 11.0 TO WS-Y
     MOVE 5.0 TO WS-Z
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 2 TO PK-COUNT
     MOVE 5.5 TO PK-MIN(1, 1)
     MOVE 10.0 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 6.5 TO PK-MAX(1, 1)
     MOVE 12.0 TO PK-MAX(1, 2)
     MOVE 5.45 TO PK-MAX(1, 3)
     MOVE 4.0 TO PK-MIN(2, 1)
     MOVE 10.0 TO PK-MIN(2, 2)
     MOVE 5.5 TO PK-MIN(2, 3)
     MOVE 6.0 TO PK-MAX(2, 1)
     MOVE 12.0 TO PK-MAX(2, 2)
     MOVE 6.5 TO PK-MAX(2, 3)
     MOVE 0.3 TO WS-VX
     MOVE 0 TO WS-VY
     MOVE 0.5 TO WS-VZ
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "resolver: Z before X when |dx| < |dz|: z clipped to 0.4 then x moves the full 0.3" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 5300 * 10000 + 5400
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-X * 1000 + 0.5) * 10000 + FUNCTION INTEGER(PC-Z * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   Upward motion clipped by a ceiling, then a second collider sees a running delta of zero.
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 2 TO PK-COUNT
     MOVE 4.0 TO PK-MIN(1, 1)
     MOVE 11.2 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 6.0 TO PK-MAX(1, 1)
     MOVE 12.0 TO PK-MAX(1, 2)
     MOVE 6.0 TO PK-MAX(1, 3)
     MOVE 4.0 TO PK-MIN(2, 1)
     MOVE 11.4 TO PK-MIN(2, 2)
     MOVE 4.0 TO PK-MIN(2, 3)
     MOVE 6.0 TO PK-MAX(2, 1)
     MOVE 12.0 TO PK-MAX(2, 2)
     MOVE 6.0 TO PK-MAX(2, 3)
     MOVE 11.2 TO PK-MIN(1, 2)
     MOVE 0 TO WS-VX WS-VZ
     MOVE 0.5 TO WS-VY
     MOVE 5.0 TO PC-X
     MOVE 11.0 TO WS-Y
     CALL "PCL-MOVE" USING PCL WS-VX WS-VY WS-VZ PCL-COLLIDERS
     MOVE "resolver: upward dy 0.5 against a ceiling at 11.2 (box top 11.2 already): resolved 0, stopped" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE PC-STOPPED TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Tick on the ground: a particle landing on a block this tick has xd and zd * 0.7 (after friction 1.0).
     MOVE 5.0 TO WS-X
     MOVE 10.1 TO WS-Y
     MOVE 5.0 TO WS-Z
     CALL "PCL-NEW" USING PCL WS-X WS-Y WS-Z WS-DRAW(1)
     MOVE 100 TO PC-LIFETIME
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-GRAVITY
     MOVE -0.3 TO PC-YD
     MOVE 0.1 TO PC-XD PC-ZD
     MOVE 1 TO PK-COUNT
     MOVE 4.0 TO PK-MIN(1, 1)
     MOVE 9.0 TO PK-MIN(1, 2)
     MOVE 4.0 TO PK-MIN(1, 3)
     MOVE 6.0 TO PK-MAX(1, 1)
     MOVE 10.0 TO PK-MAX(1, 2)
     MOVE 6.0 TO PK-MAX(1, 3)
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: onGround multiplies xd and zd by 0.7 (thousandths 70)" TO WS-NAME
     MOVE 70 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(PC-XD * 1000 + 0.5)
     PERFORM ASSERT-NUMBER
*>   getQuadSize clamps a negative factor to 0 is covered by the ash test; quad factor above is 1.
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-1§4 `Particle` and `SingleQuadParticle`: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-VAL * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.
 END PROGRAM TEST-PARTICLES-42-1-4.
