*> Acceptance test of docs/protocol/42-particles-3-fluid-drip-water.md section 1 (what this document needs
*> from the shared model): the field defaults, the four-argument constructor lifetime, the base tick, move,
*> light, SpriteSet.get(random) with one frame, LifetimeAlpha opacity, Mth.randomBetween and
*> addSmoothBlockEmission.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-SCALE               BINARY-DOUBLE.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-SA                  FLOAT-LONG.
 01 WS-EA                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO PK-COUNT
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "P3-PARTICLE-DEFAULTS" USING PCL WS-X WS-Y WS-Z
     MOVE "defaults: hasPhysics 1, onGround 0, speedUp 0" TO WS-NAME
     COMPUTE TL-EXPECTED-N = 100
     COMPUTE TL-OBSERVED-N = PC-HAS-PHYSICS * 100 + PC-ON-GROUND * 10 + PC-SPEED-UP
     PERFORM ASSERT-NUMBER
     MOVE "defaults: box 0.2 by 0.2 after setSize (thousandths of the width)" TO WS-NAME
     MOVE PC-BBW TO WS-V
     MOVE 1000 TO WS-SCALE
     MOVE 200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "defaults: friction 0.98 (thousandths)" TO WS-NAME
     MOVE PC-FRICTION TO WS-V
     MOVE 980 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "defaults: gravity 0 and velocity 0" TO WS-NAME
     COMPUTE WS-V = PC-GRAVITY + PC-XD + PC-YD + PC-ZD
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "defaults: previous position equals position (z)" TO WS-NAME
     MOVE PC-ZO TO WS-V
     MOVE 3000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0.5 TO WS-DRAW
     CALL "P3-LIFETIME-4ARG" USING WS-DRAW PC-LIFETIME
     MOVE "four-argument constructor: lifetime (int)(4 / (0.5 * 0.9 + 0.1)) = 7" TO WS-NAME
     MOVE 7 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.0 TO WS-DRAW
     CALL "P3-LIFETIME-4ARG" USING WS-DRAW PC-LIFETIME
     MOVE "four-argument constructor: draw 0 gives the maximum 40" TO WS-NAME
     MOVE 40 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.999999 TO WS-DRAW
     CALL "P3-LIFETIME-4ARG" USING WS-DRAW PC-LIFETIME
     MOVE "four-argument constructor: draw near 1 gives the minimum 4" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     MOVE PC-LIFETIME TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-LO
     MOVE 1.0 TO WS-HI
     MOVE 0.3 TO WS-DRAW
     CALL "P3-RANDOM-BETWEEN" USING WS-DRAW WS-LO WS-HI WS-V
     MOVE "Mth.randomBetween(0.3, 0.5, 1.0) = 0.3 * 0.5 + 0.5 = 0.65 (thousandths)" TO WS-NAME
     MOVE 650 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0.3 TO WS-LO
     MOVE 1.0 TO WS-HI
     MOVE 0.5 TO WS-DRAW
     CALL "P3-RANDOM-BETWEEN" USING WS-DRAW WS-LO WS-HI WS-V
     MOVE "Mth.randomBetween(0.5, 0.3, 1.0) = 0.65 (the volume of a honey landing)" TO WS-NAME
     MOVE 650 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0 TO WS-LIGHT
     MOVE 0.5 TO WS-V
     CALL "P3-LIGHT-ADD" USING WS-LIGHT WS-V WS-OUT
     MOVE "addSmoothBlockEmission(0, 0.5): block 120" TO WS-NAME
     MOVE 120 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 200 TO WS-LIGHT
     MOVE 0.5 TO WS-V
     CALL "P3-LIGHT-ADD" USING WS-LIGHT WS-V WS-OUT
     MOVE "addSmoothBlockEmission: the sum is capped at 240" TO WS-NAME
     MOVE 240 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 1.0 TO WS-SA
     MOVE 1.0 TO WS-EA
     CALL "P3-LIFETIME-ALPHA-OPAQUE" USING WS-SA WS-EA WS-OPAQUE
     MOVE "ALWAYS_OPAQUE (1, 1) is opaque" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OPAQUE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-EA
     CALL "P3-LIFETIME-ALPHA-OPAQUE" USING WS-SA WS-EA WS-OPAQUE
     MOVE "an end alpha below 1 is not opaque" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OPAQUE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Base tick order: age++ compared first, then gravity, move, friction.
     MOVE 10 TO PC-LIFETIME
     MOVE 0.04 TO PC-YD
     MOVE 1.0 TO PC-GRAVITY
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "base tick: yd = (0.04 - 0.04 * 1) * 0.98 = 0" TO WS-NAME
     MOVE PC-YD TO WS-V
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "base tick: the move used yd 0 (y stays 2)" TO WS-NAME
     MOVE PC-Y TO WS-V
     MOVE 2000 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§1 What this document needs from the shared model: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-V * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.
 END PROGRAM TEST-PARTICLES-42-3-1.
