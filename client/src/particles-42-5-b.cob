*> Particles part 5 (docs/protocol/42-particles-5-sculk-trial-wind-geyser.md), section 2: the per-type records (constructors, ticks,
*> size and alpha rules) of the sculk, shriek, sonic boom, vibration, trail, gust, dust plume, trial spawner, vault,
*> ominous, noxious gas, geyser and sulfur bubble particles. Draws are passed in as tables (see particles-42-2.cob).
*> Extra fields live in P5X (client/copy/CLP5X.cpy). sculk_soul, pause/reset_mob_growth, raid/trial_omen and sulfur_cube_goo
*> use existing classes: PRISE-NEW then PCL-QUAD-SCALE 1.5 (2.1), PVERT-NEW (2.18), SPELL (42-2), P4-ITEM-CORE-NEW (2.20).
*>
*> Entry points for the integrator (inputs):
*>   P5-CHARGE-NEW PCL x y z vx vy vz roll draws(7) r; P5-POP-NEW PCL x y z vx vy vz draws(7) r;
*>   P5-SHRIEK-NEW PCL P5X x y z delay draws(7), P5-SHRIEK-TICK PCL P5X PCL-COLLIDERS, P5-SHRIEK-SIZE/ALPHA PCL partial;
*>   P5-SONIC-NEW PCL x y z size draws(9), P5-HUGE-TICK PCL sprites; P5-VIB-NEW PCL P5X x y z target present arrival draws(7),
*>   P5-VIB-TICK PCL P5X target present; P5-TRAIL-NEW PCL x y z vx vy vz colour draws(7) colour-draws(3), P5-TRAIL-TICK PCL target;
*>   P5-GUST-NEW PCL x y z small draws(3), P5-GUST-TICK PCL sprites; P5-PLUME-NEW PCL x y z vx vy vz draws(9) shade;
*>   P5-TRIAL-NEW PCL x y z vx vy vz scale draws(7) r; P5-VAULT-NEW / P5-VAULT-TICK / P5-VAULT-ALPHA; P5-OMINOUS-NEW /
*>   P5-OMINOUS-TICK; P5-GAS-NEW PCL PCLX x y z vx vy vz draws(9) r then fade = lifetime / 2.0, P5-GAS-TICK ... fade;
*>   P5-GBASE-NEW, P5-GPLUME-NEW, P5-GPLUME-TICK, P5-BUBBLE-NEW, P5-BUBBLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CHARGE-NEW.
*> Section 2.2 SculkChargeParticle: USING PCL, x, y, z, vx, vy, vz, roll, draws (1-6 burst, 7 quad size), lifetime draw
*> (nextInt(12) as r). friction 0.96, scale(1.5), no physics, alpha 1, velocity = the supplied one, roll = oRoll = roll,
*> lifetime 8 + nextInt(12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 1.5.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-ROLL                 FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-ROLL L-DRAWS L-R.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     MOVE 1.0 TO PC-ALPHA
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     MOVE L-ROLL TO PC-ROLL PC-OROLL
     COMPUTE PC-LIFETIME = 8 + FUNCTION INTEGER-PART(L-R * 12)
     GOBACK.
 END PROGRAM P5-CHARGE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-POP-NEW.
*> Section 2.3 SculkChargePopParticle: USING PCL, x, y, z, vx, vy, vz, draws (1-7), lifetime draw (nextInt(4) as r).
*> As the charge particle with no roll, scale(1.0) and lifetime 6 + nextInt(4).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS L-R.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     MOVE 1.0 TO PC-ALPHA
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     COMPUTE PC-LIFETIME = 6 + FUNCTION INTEGER-PART(L-R * 4)
     GOBACK.
 END PROGRAM P5-POP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-NEW.
*> Section 2.4 ShriekParticle: USING PCL, P5X, x, y, z, delay, draws (1-6 burst with zero velocity, 7 quad size). quadSize
*> 0.85, lifetime 30, gravity 0, velocity (0, 0.1, 0); friction 0.98 and physics stay.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-DELAY L-DRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     MOVE 0.85 TO PC-QUAD-SIZE
     MOVE L-DELAY TO X5-DELAY
     MOVE 30 TO PC-LIFETIME
     MOVE 0 TO PC-GRAVITY
     MOVE 0 TO PC-XD
     MOVE 0.1 TO PC-YD
     MOVE 0 TO PC-ZD
     GOBACK.
 END PROGRAM P5-SHRIEK-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-TICK.
*> Section 2.4 tick: USING PCL, P5X, PCL-COLLIDERS: while delay > 0 only delay - 1 (no age, no movement, nothing drawn);
*> at delay 0 the base tick.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 PROCEDURE DIVISION USING PCL P5X PCL-COLLIDERS.
     IF X5-DELAY > 0
         SUBTRACT 1 FROM X5-DELAY
     ELSE
         CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     END-IF
     GOBACK.
 END PROGRAM P5-SHRIEK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-SIZE.
*> Section 2.4 getQuadSize(partial): USING PCL, partial, size out = quadSize * clamp((age + partial) / lifetime * 0.75, 0, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-SIZE.
     COMPUTE WS-F = (PC-AGE + L-PARTIAL) / PC-LIFETIME * 0.75
     IF WS-F < 0
         MOVE 0 TO WS-F
     END-IF
     IF WS-F > 1
         MOVE 1 TO WS-F
     END-IF
     COMPUTE L-SIZE = PC-QUAD-SIZE * WS-F
     GOBACK.
 END PROGRAM P5-SHRIEK-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-ALPHA.
*> Section 2.4 extract: USING PCL, partial, alpha out = 1 - clamp((age + partial) / lifetime, 0, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-ALPHA                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-ALPHA.
     COMPUTE WS-F = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     IF WS-F > 1
         MOVE 1 TO WS-F
     END-IF
     COMPUTE L-ALPHA = 1 - WS-F
     GOBACK.
 END PROGRAM P5-SHRIEK-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-HUGE-NEW.
*> Section 2.5 HugeExplosionParticle: USING PCL, x, y, z, size, draws (1-6 burst with zero velocity, 7 quad size, 8 lifetime
*> nextInt(4) as r, 9 the colour). lifetime 6 + nextInt(4), grey = r * 0.6 + 0.4, quadSize = 2 * (1 - size * 0.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-SIZE L-DRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     COMPUTE PC-LIFETIME = 6 + FUNCTION INTEGER-PART(L-DRAW(8) * 4)
     COMPUTE WS-C = L-DRAW(9) * 0.6 + 0.4
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = 2 * (1 - L-SIZE * 0.5)
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P5-HUGE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SONIC-NEW.
*> Section 2.5 SonicBoomParticle: USING PCL, x, y, z, size (ignored), draws (the nine of P5-HUGE-NEW): lifetime 16, quadSize 1.5.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-SIZE L-DRAWS.
     CALL "P5-HUGE-NEW" USING PCL L-X L-Y L-Z L-SIZE L-DRAWS
     MOVE 16 TO PC-LIFETIME
     MOVE 1.5 TO PC-QUAD-SIZE
     GOBACK.
 END PROGRAM P5-SONIC-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-HUGE-TICK.
*> Section 2.5 tick: USING PCL, sprite count: old position = position, the old age compared with the lifetime then the age
*> incremented (removed when old age >= lifetime), the sprite from age. No movement.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-N.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
     ELSE
         CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     END-IF
     GOBACK.
 END PROGRAM P5-HUGE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-ANGLES.
*> Section 2.6 helper: USING PCL, target (x, y, z), rot out, pitch out: rot = atan2(dx, dz), pitch = atan2(dy,
*> sqrt(dx^2 + dz^2)) with d = current position - target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  COMP-2.
 01 WS-DY                  COMP-2.
 01 WS-DZ                  COMP-2.
 01 WS-H                   COMP-2.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-TARGET.
    05 L-T                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-ROT                  COMP-2.
 01 L-PITCH                COMP-2.
 PROCEDURE DIVISION USING PCL L-TARGET L-ROT L-PITCH.
     COMPUTE WS-DX = PC-X - L-T(1)
     COMPUTE WS-DY = PC-Y - L-T(2)
     COMPUTE WS-DZ = PC-Z - L-T(3)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL STATIC "cc_f64_atan2_lib" USING BY REFERENCE WS-DX WS-DZ L-ROT
     CALL STATIC "cc_f64_atan2_lib" USING BY REFERENCE WS-DY WS-H L-PITCH
     GOBACK.
 END PROGRAM P5-VIB-ANGLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-NEW.
*> Section 2.6 VibrationSignalParticle: USING PCL, P5X, x, y, z, target (x, y, z), target present (0/1), arrival ticks, draws
*> (1-6 burst with zero velocity, 7 quad size). quadSize 0.3, lifetime = arrival, the angles from the target position
*> when present (rotO = rot, pitchO = pitch), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TARGET.
    05 L-T                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-PRESENT              BINARY-LONG.
 01 L-ARRIVAL              BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-TARGET L-PRESENT L-ARRIVAL L-DRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     MOVE 0.3 TO PC-QUAD-SIZE
     MOVE L-ARRIVAL TO PC-LIFETIME
     MOVE 0 TO X5-ROT X5-PITCH
     IF L-PRESENT NOT = 0
         CALL "P5-VIB-ANGLES" USING PCL L-TARGET X5-ROT X5-PITCH
     END-IF
     MOVE X5-ROT TO X5-OROT
     MOVE X5-PITCH TO X5-OPITCH
     GOBACK.
 END PROGRAM P5-VIB-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-TICK.
*> Section 2.6 tick: USING PCL, P5X, target (x, y, z), target present (0/1): old position = position; the old age compared
*> then incremented (removed when old age >= lifetime); an absent target removes; remaining = lifetime - age, t = 1 /
*> remaining and each coordinate lerps to the target (on remaining 0 the position snaps to the target, which the document
*> allows); then rotO = rot, rot and pitch from the new position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-TARGET.
    05 L-T                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-PRESENT              BINARY-LONG.
 PROCEDURE DIVISION USING PCL P5X L-TARGET L-PRESENT.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME OR L-PRESENT = 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-REM = PC-LIFETIME - PC-AGE
     IF WS-REM <= 0
         MOVE L-T(1) TO WS-X
         MOVE L-T(2) TO WS-Y
         MOVE L-T(3) TO WS-Z
     ELSE
         COMPUTE WS-T = 1.0 / WS-REM
         COMPUTE WS-X = PC-X + WS-T * (L-T(1) - PC-X)
         COMPUTE WS-Y = PC-Y + WS-T * (L-T(2) - PC-Y)
         COMPUTE WS-Z = PC-Z + WS-T * (L-T(3) - PC-Z)
     END-IF
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     MOVE X5-ROT TO X5-OROT
     MOVE X5-PITCH TO X5-OPITCH
     CALL "P5-VIB-ANGLES" USING PCL L-TARGET X5-ROT X5-PITCH
     GOBACK.
 END PROGRAM P5-VIB-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-WOBBLE.
*> Section 2.6 draw: USING age, partial, s out = 2 * sin((age + partial - 6.2831855) * 0.05).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   COMP-2.
 01 WS-S                   COMP-2.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-PARTIAL L-S.
     COMPUTE WS-A = (L-AGE + L-PARTIAL - 6.2831855) * 0.05
     CALL STATIC "cc_f64_sin" USING BY REFERENCE WS-A WS-S
     COMPUTE L-S = 2 * WS-S
     GOBACK.
 END PROGRAM P5-VIB-WOBBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TRAIL-NEW.
*> Section 2.7 TrailParticle: USING PCL, x, y, z, vx, vy, vz, colour (RGB24 in an int), draws (1-7 base with velocity),
*> colour draws (a, b, c). Each channel is scaled by 0.875 + draw * 0.25 (scaleRGB), colours = bytes / 255, quadSize 0.26.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FR                  FLOAT-LONG.
 01 WS-FG                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-OUT                 BINARY-DOUBLE.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-CDRAWS.
    05 L-C                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-COLOR L-DRAWS L-CDRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     COMPUTE WS-FR = 0.875 + L-C(1) * 0.25
     COMPUTE WS-FG = 0.875 + L-C(2) * 0.25
     COMPUTE WS-FB = 0.875 + L-C(3) * 0.25
     CALL "P5-SCALE-RGB" USING L-COLOR WS-FR WS-FG WS-FB WS-OUT
     CALL "PART-RGB24" USING WS-OUT WS-R WS-G WS-B
     CALL "PCL-SET-COLOR" USING PCL WS-R WS-G WS-B
     MOVE 0.26 TO PC-QUAD-SIZE
     GOBACK.
 END PROGRAM P5-TRAIL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TRAIL-TICK.
*> Section 2.7 tick: USING PCL, target (x, y, z): old position = position; the old age compared then incremented (removed when
*> old age >= lifetime); remaining = lifetime - age, t = 1 / remaining, each coordinate lerps to the target (snapping on
*> remaining 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-TARGET.
    05 L-T                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING PCL L-TARGET.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-REM = PC-LIFETIME - PC-AGE
     IF WS-REM <= 0
         MOVE L-T(1) TO WS-X
         MOVE L-T(2) TO WS-Y
         MOVE L-T(3) TO WS-Z
     ELSE
         COMPUTE WS-T = 1.0 / WS-REM
         COMPUTE WS-X = PC-X + WS-T * (L-T(1) - PC-X)
         COMPUTE WS-Y = PC-Y + WS-T * (L-T(2) - PC-Y)
         COMPUTE WS-Z = PC-Z + WS-T * (L-T(3) - PC-Z)
     END-IF
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM P5-TRAIL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUST-NEW.
*> Section 2.8 GustParticle: USING PCL, x, y, z, small (0/1), draws (1 lifetime, 2 quad size, 3 the lifetime nextInt(4) as r):
*> lifetime 12 + nextInt(4), quadSize 1.0, box 1 by 1; small_gust then scale(0.15).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE-W               FLOAT-LONG VALUE 1.0.
 01 WS-ONE-H               FLOAT-LONG VALUE 1.0.
 01 WS-SCALE               FLOAT-LONG VALUE 0.15000000596046448.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SMALL                BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-SMALL L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE 0 TO PC-SPRITE
     COMPUTE PC-LIFETIME = 12 + FUNCTION INTEGER-PART(L-DRAW(3) * 4)
     MOVE 1.0 TO PC-QUAD-SIZE
     CALL "PCL-SET-SIZE" USING PCL WS-ONE-W WS-ONE-H
     IF L-SMALL NOT = 0
         CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     END-IF
     GOBACK.
 END PROGRAM P5-GUST-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUST-TICK.
*> Section 2.8 tick: USING PCL, sprite count: the old age compared then incremented (removed when old age >= lifetime), then
*> the sprite from age; no movement, no gravity.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-N.
     CALL "P5-HUGE-TICK" USING PCL L-N
     GOBACK.
 END PROGRAM P5-GUST-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUSTSEED-INFO.
*> Section 2.9 registrations: USING kind (0 gust_emitter_large, 1 gust_emitter_small), scale out, lifetime out, delay out:
*> large (3.0, 7, 0), small (1.0, 3, 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SCALE L-LIFETIME L-DELAY.
     IF L-KIND = 0
         MOVE 3.0 TO L-SCALE
         MOVE 7 TO L-LIFETIME
         MOVE 0 TO L-DELAY
     ELSE
         MOVE 1.0 TO L-SCALE
         MOVE 3 TO L-LIFETIME
         MOVE 2 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM P5-GUSTSEED-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUSTSEED-STEP.
*> Section 2.9 tick: USING age, delay, emit out: emits (three gusts) when age % (delay + 1) == 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-DELAY L-EMIT.
     MOVE 0 TO L-EMIT
     IF FUNCTION MOD(L-AGE, L-DELAY + 1) = 0
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM P5-GUSTSEED-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUSTSEED-TOTAL.
*> Section 2.9 counts: USING kind, gust particles over the whole life out (large 21, small 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-LIFE                BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-EMIT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TOTAL.
     CALL "P5-GUSTSEED-INFO" USING L-KIND WS-SCALE WS-LIFE WS-DELAY
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-AGE FROM 0 BY 1 UNTIL WS-AGE >= WS-LIFE
         CALL "P5-GUSTSEED-STEP" USING WS-AGE WS-DELAY WS-EMIT
         IF WS-EMIT NOT = 0
             ADD 3 TO L-TOTAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P5-GUSTSEED-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GUSTSEED-POS.
*> Section 2.9 tick: USING origin (x, y, z), scale, draws (six nextDouble: x pair, y pair, z pair), position out: origin +
*> (a - b) * scale on each axis.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O.
    05 L-OO                FLOAT-LONG OCCURS 3 TIMES.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-D                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-P                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-O L-SCALE L-DRAWS L-OUT.
     COMPUTE L-P(1) = L-OO(1) + (L-D(1) - L-D(2)) * L-SCALE
     COMPUTE L-P(2) = L-OO(2) + (L-D(3) - L-D(4)) * L-SCALE
     COMPUTE L-P(3) = L-OO(3) + (L-D(5) - L-D(6)) * L-SCALE
     GOBACK.
 END PROGRAM P5-GUSTSEED-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-LIFE-DIV.
*> Helper (float32): lifetime = (int)((numerator / denominator) * scale) with the quotient and the product each rounded to
*> binary32: USING numerator, denominator, scale, lifetime out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D32                 COMP-2.
 01 WS-Q                   COMP-2.
 01 WS-Q32                 COMP-2.
 01 WS-P                   COMP-2.
 01 WS-P32                 COMP-2.
 LINKAGE SECTION.
 01 L-NUM                  COMP-2.
 01 L-DEN                  COMP-2.
 01 L-SCALE                COMP-2.
 01 L-LIFE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NUM L-DEN L-SCALE L-LIFE.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-DEN WS-D32
     CALL STATIC "cc_f64_div" USING BY REFERENCE L-NUM WS-D32 WS-Q
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-Q WS-Q32
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Q32 L-SCALE WS-P
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-P32
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-P32 L-LIFE
     GOBACK.
 END PROGRAM P5-LIFE-DIV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-PLUME-NEW.
*> Section 2.10 DustPlumeParticle: USING PCL, x, y, z, vx, vy, vz, draws (the nine of PASH-NEW), shade draw. BaseAshSmoke
*> constructor with multipliers (0.7, 0.6, 0.7), add-ons (vx, vy + 0.15000000596046448, vz), scale 1, colour multiplier
*> 0.5, lifetime base 7, gravity 0.5, no physics; then colour = RGB24 12235202 minus shade * 0.2 on each channel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-VXM              FLOAT-LONG VALUE 0.7.
    05 WS-VYM              FLOAT-LONG VALUE 0.6.
    05 WS-VZM              FLOAT-LONG VALUE 0.7.
    05 WS-AX               FLOAT-LONG.
    05 WS-AY               FLOAT-LONG.
    05 WS-AZ               FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG VALUE 1.0.
    05 WS-COLOUR           FLOAT-LONG VALUE 0.5.
    05 WS-LIFE             FLOAT-LONG VALUE 7.
    05 WS-GRAVITY          FLOAT-LONG VALUE 0.5.
    05 WS-PHYSICS          BINARY-LONG VALUE 0.
 01 WS-RGB                 BINARY-DOUBLE VALUE 12235202.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-SHADE                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS L-SHADE.
     MOVE L-VX TO WS-AX
     COMPUTE WS-AY = L-VY + 0.15000000596046448
     MOVE L-VZ TO WS-AZ
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     CALL "PART-RGB24" USING WS-RGB WS-R WS-G WS-B
     COMPUTE PC-RCOL = WS-R - L-SHADE * 0.2
     COMPUTE PC-GCOL = WS-G - L-SHADE * 0.2
     COMPUTE PC-BCOL = WS-B - L-SHADE * 0.2
     GOBACK.
 END PROGRAM P5-PLUME-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-PLUME-TICK.
*> Section 2.10 tick: USING PCL, PCLX, PCL-COLLIDERS, sprite count: gravity * 0.88 and friction * 0.92 before the base tick
*> of BaseAshSmokeParticle.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS L-N.
     COMPUTE PC-GRAVITY = PC-GRAVITY * 0.88
     COMPUTE PC-FRICTION = PC-FRICTION * 0.92
     CALL "PASH-TICK" USING PCL PCLX PCL-COLLIDERS L-N
     GOBACK.
 END PROGRAM P5-PLUME-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TRIAL-NEW.
*> Section 2.11 TrialSpawnerDetectionParticle: USING PCL, x, y, z, vx, vy, vz, scale, draws (1-7 burst with zero velocity),
*> lifetime draw r. friction 0.96, gravity -0.1, speed-up, xd = 0, yd * 0.9, zd = 0, then plus the supplied velocity,
*> quadSize * 0.75 * scale, lifetime (int)(8 / randomBetween(0.5, 1.0) * scale) in float32 (at least 1), physics on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 01 WS-8                   COMP-2 VALUE 8.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-RB                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SCALE L-DRAWS L-R.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     MOVE -0.1 TO PC-GRAVITY
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-XD = 0 + L-VX
     COMPUTE PC-YD = PC-YD * 0.9 + L-VY
     COMPUTE PC-ZD = 0 + L-VZ
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75 * L-SCALE
     CALL "P3-RANDOM-BETWEEN" USING L-R WS-HALF WS-ONE WS-RB
     CALL "P5-LIFE-DIV" USING WS-8 WS-RB L-SCALE PC-LIFETIME
     IF PC-LIFETIME < 1
         MOVE 1 TO PC-LIFETIME
     END-IF
     MOVE 1 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P5-TRIAL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-NEW.
*> Section 2.12 FlyTowardsPositionParticle (vault_connection): USING PCL, P5X, x, y, z, vx, vy, vz, draws (1 lifetime, 2 quad
*> size, 3 size, 4 colour, 5 lifetime), then scale(1.5). alpha = 0, velocity = displacement, start = position, the
*> position = start + displacement, quadSize 0.1 * (r * 0.5 + 0.2), colour (0.9 f, 0.9 f, f) with f = r * 0.6 + 0.4,
*> no physics, lifetime (int)(r * 10) + 30.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 1.5.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE 0 TO PC-ALPHA
     MOVE L-VX TO PC-XD X5-DISP(1)
     MOVE L-VY TO PC-YD X5-DISP(2)
     MOVE L-VZ TO PC-ZD X5-DISP(3)
     MOVE L-X TO X5-START(1)
     MOVE L-Y TO X5-START(2)
     MOVE L-Z TO X5-START(3)
     COMPUTE WS-X = L-X + L-VX
     COMPUTE WS-Y = L-Y + L-VY
     COMPUTE WS-Z = L-Z + L-VZ
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(3) * 0.5 + 0.2)
     COMPUTE WS-F = L-DRAW(4) * 0.6 + 0.4
     COMPUTE PC-RCOL = 0.9 * WS-F
     COMPUTE PC-GCOL = 0.9 * WS-F
     MOVE WS-F TO PC-BCOL
     MOVE 0 TO PC-HAS-PHYSICS
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(5) * 10) + 30
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     GOBACK.
 END PROGRAM P5-VAULT-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-TICK.
*> Section 2.12 tick: USING PCL, P5X: old position = position; the old age compared then incremented (removed when old age >=
*> lifetime); q = age / lifetime, r = 1 - q, p4 = q^4; position = start + displacement * r, y also minus p4 * 1.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-P2                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 PROCEDURE DIVISION USING PCL P5X.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-Q = PC-AGE / PC-LIFETIME
     COMPUTE WS-R = 1 - WS-Q
     COMPUTE WS-P2 = WS-Q * WS-Q
     COMPUTE WS-X = X5-START(1) + X5-DISP(1) * WS-R
     COMPUTE WS-Y = X5-START(2) + X5-DISP(2) * WS-R - WS-P2 * WS-P2 * 1.2
     COMPUTE WS-Z = X5-START(3) + X5-DISP(3) * WS-R
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM P5-VAULT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-ALPHA.
*> Section 2.12 LifetimeAlpha(0.0, 0.6, 0.25, 1.0): USING PCL, partial, alpha out = clampedLerp(inverseLerp((age + partial) /
*> lifetime, 0.25, 1.0), 0.0, 0.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG VALUE 0.25.
 01 WS-E                   FLOAT-LONG VALUE 1.0.
 01 WS-A0                  FLOAT-LONG VALUE 0.0.
 01 WS-A1                  FLOAT-LONG VALUE 0.6.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-ALPHA                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-ALPHA.
     COMPUTE WS-P = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     CALL "P5-INVERSE-LERP" USING WS-P WS-S WS-E WS-T
     CALL "P5-CLAMPED-LERP" USING WS-T WS-A0 WS-A1 L-ALPHA
     GOBACK.
 END PROGRAM P5-VAULT-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-NEW.
*> Section 2.13 FlyStraightTowardsParticle (ominous_spawning): USING PCL, P5X, x, y, z, vx, vy, vz, draws (1 lifetime, 2 quad
*> size, 3 size, 4 lifetime), scale draw r (the level's randomBetween(3, 5)). Start = position, position = start +
*> displacement, quadSize 0.1 * (r * 0.5 + 0.2), no physics, lifetime (int)(r * 5) + 25, then scale(r * 2 + 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS L-R.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE L-VX TO PC-XD X5-DISP(1)
     MOVE L-VY TO PC-YD X5-DISP(2)
     MOVE L-VZ TO PC-ZD X5-DISP(3)
     MOVE L-X TO X5-START(1)
     MOVE L-Y TO X5-START(2)
     MOVE L-Z TO X5-START(3)
     COMPUTE WS-X = L-X + L-VX
     COMPUTE WS-Y = L-Y + L-VY
     COMPUTE WS-Z = L-Z + L-VZ
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(3) * 0.5 + 0.2)
     MOVE 0 TO PC-HAS-PHYSICS
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(4) * 5) + 25
     COMPUTE WS-SCALE = L-R * 2 + 3
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     GOBACK.
 END PROGRAM P5-OMINOUS-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-TICK.
*> Section 2.13 tick: USING PCL, P5X: old position = position; the old age compared then incremented; q = age / lifetime; position
*> = start + displacement * (1 - q); colour = srgbLerp(q, 0xFF45AEFE, 0xFFFFFFFF) as bytes / 255, alpha 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FROM                BINARY-DOUBLE VALUE 4282756862.
 01 WS-TO                  BINARY-DOUBLE VALUE 4294967295.
 01 WS-C                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 PROCEDURE DIVISION USING PCL P5X.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-Q = PC-AGE / PC-LIFETIME
     COMPUTE WS-R = 1 - WS-Q
     COMPUTE WS-X = X5-START(1) + X5-DISP(1) * WS-R
     COMPUTE WS-Y = X5-START(2) + X5-DISP(2) * WS-R
     COMPUTE WS-Z = X5-START(3) + X5-DISP(3) * WS-R
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     CALL "P5-SRGB-LERP" USING WS-Q WS-FROM WS-TO WS-C
     CALL "PART-COLOR-GET" USING WS-C PC-ALPHA PC-RCOL PC-GCOL PC-BCOL
     GOBACK.
 END PROGRAM P5-OMINOUS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GAS-NEW.
*> Section 2.14 NoxiousGasParticle: USING PCL, PCLX, x, y, z, vx, vy, vz, draws (the nine of PASH-NEW), lifetime draw r. Multipliers
*> 0.1, add-ons the supplied velocity, scale 3.0, colour multiplier 0.3, lifetime base 5, gravity -0.02, physics on; then
*> colour white and lifetime (int)(6 / (r * 0.5 + 0.5) * 3) in float32. The caller keeps fade = lifetime / 2.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-VXM              FLOAT-LONG VALUE 0.1.
    05 WS-VYM              FLOAT-LONG VALUE 0.1.
    05 WS-VZM              FLOAT-LONG VALUE 0.1.
    05 WS-AX               FLOAT-LONG.
    05 WS-AY               FLOAT-LONG.
    05 WS-AZ               FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG VALUE 3.0.
    05 WS-COLOUR           FLOAT-LONG VALUE 0.3.
    05 WS-LIFE             FLOAT-LONG VALUE 5.
    05 WS-GRAVITY          FLOAT-LONG VALUE -0.02.
    05 WS-PHYSICS          BINARY-LONG VALUE 1.
 01 WS-6                   COMP-2 VALUE 6.
 01 WS-DEN                 COMP-2.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS L-R.
     MOVE L-VX TO WS-AX
     MOVE L-VY TO WS-AY
     MOVE L-VZ TO WS-AZ
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     MOVE 1.0 TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE WS-DEN = L-R * 0.5 + 0.5
     CALL "P5-LIFE-DIV" USING WS-6 WS-DEN WS-SCALE PC-LIFETIME
     GOBACK.
 END PROGRAM P5-GAS-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GAS-TICK.
*> Section 2.14 tick: USING PCL, PCLX, PCL-COLLIDERS, sprite count, fadeOutStartingPoint (lifetime / 2.0): the base tick, then past
*> the fade start alpha = (lifetime - (age - fade)) / lifetime.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-N                    BINARY-LONG.
 01 L-FADE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS L-N L-FADE.
     CALL "PASH-TICK" USING PCL PCLX PCL-COLLIDERS L-N
     IF PC-AGE > L-FADE
         COMPUTE PC-ALPHA = (PC-LIFETIME - (PC-AGE - L-FADE)) / PC-LIFETIME
     END-IF
     GOBACK.
 END PROGRAM P5-GAS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CLOUD-POINT.
*> Section 2.15 pickRandomParticleSpawnPoint: USING block position (three integers), draws a, b, c (nextFloat), point out:
*> dir = normalize((a - 0.5, 0, b - 0.5)) (a zero vector gives a zero direction here: the document read no guard), dist =
*> c * 3.0, point = block centre + dir * dist - (0, 0.25, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-C                    FLOAT-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-A L-B L-C L-OUT.
     COMPUTE WS-DX = L-A - 0.5
     COMPUTE WS-DZ = L-B - 0.5
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-DIST = L-C * 3.0
     IF WS-LEN > 0
         COMPUTE L-O(1) = L-PP(1) + 0.5 + WS-DX / WS-LEN * WS-DIST
         COMPUTE L-O(3) = L-PP(3) + 0.5 + WS-DZ / WS-LEN * WS-DIST
     ELSE
         COMPUTE L-O(1) = L-PP(1) + 0.5
         COMPUTE L-O(3) = L-PP(3) + 0.5
     END-IF
     COMPUTE L-O(2) = L-PP(2) + 0.5 - 0.25
     GOBACK.
 END PROGRAM P5-CLOUD-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CLOUD-ATTEMPT.
*> Section 2.15 tick: USING age (after the increment), attempt out: only when the age is even.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-ATTEMPT.
     MOVE 0 TO L-ATTEMPT
     IF FUNCTION MOD(L-AGE, 2) = 0
         MOVE 1 TO L-ATTEMPT
     END-IF
     GOBACK.
 END PROGRAM P5-CLOUD-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GEYSER-ERUPT.
*> Section 2.16 eruption tick (acts on ages 1 to 21): USING age, w, base count out, plume count out, poof count out: 2 base at
*> even ages, w + 2 plume on every call, 20 poof when age % 10 == 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-PLUME                BINARY-LONG.
 01 L-POOF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-W L-BASE L-PLUME L-POOF.
     MOVE 0 TO L-BASE L-POOF
     IF FUNCTION MOD(L-AGE, 2) = 0
         MOVE 2 TO L-BASE
     END-IF
     COMPUTE L-PLUME = L-W + 2
     IF FUNCTION MOD(L-AGE, 10) = 0
         MOVE 20 TO L-POOF
     END-IF
     GOBACK.
 END PROGRAM P5-GEYSER-ERUPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GEYSER-TOTALS.
*> Section 2.16 totals over ages 1 to 21: USING w, base total out (20), plume total out (21 * (w + 2)), poof total out (40).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AGE                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-PLUME                BINARY-LONG.
 01 L-POOF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-BASE L-PLUME L-POOF.
     MOVE 0 TO L-BASE L-PLUME L-POOF
     PERFORM VARYING WS-AGE FROM 1 BY 1 UNTIL WS-AGE > 21
         CALL "P5-GEYSER-ERUPT" USING WS-AGE L-W WS-B WS-P WS-F
         ADD WS-B TO L-BASE
         ADD WS-P TO L-PLUME
         ADD WS-F TO L-POOF
     END-PERFORM
     GOBACK.
 END PROGRAM P5-GEYSER-TOTALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GBASE-NEW.
*> Section 2.16 GeyserBaseParticle: USING PCL, x, y, z, vx, vy, vz, w, burst impulse, draws (the nine of PASH-NEW), provider draws
*> (three nextFloat), level draw r. ux = vx + (p1 - 0.5) * 0.5, uy = vy + (p2 - 0.5) * 0.5 + 0.20000000298023224, uz likewise;
*> m = burst + 0.25 * w, s = 3 + 0.125 * w; multipliers m, add-ons u, scale s; then friction 0.725, white, yd = |yd|,
*> lifetime (int)(25 * (0.8 + 0.2 * r)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARGS.
    05 WS-VXM              FLOAT-LONG.
    05 WS-VYM              FLOAT-LONG.
    05 WS-VZM              FLOAT-LONG.
    05 WS-AX               FLOAT-LONG.
    05 WS-AY               FLOAT-LONG.
    05 WS-AZ               FLOAT-LONG.
    05 WS-SCALE            FLOAT-LONG.
    05 WS-COLOUR           FLOAT-LONG VALUE 0.
    05 WS-LIFE             FLOAT-LONG VALUE 0.
    05 WS-GRAVITY          FLOAT-LONG VALUE 0.
    05 WS-PHYSICS          BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-W                    BINARY-LONG.
 01 L-BURST                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-PDRAWS.
    05 L-P                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-W L-BURST L-DRAWS L-PDRAWS L-R.
     COMPUTE WS-AX = L-VX + (L-P(1) - 0.5) * 0.5
     COMPUTE WS-AY = L-VY + (L-P(2) - 0.5) * 0.5 + 0.20000000298023224
     COMPUTE WS-AZ = L-VZ + (L-P(3) - 0.5) * 0.5
     COMPUTE WS-VXM = L-BURST + 0.25 * L-W
     MOVE WS-VXM TO WS-VYM WS-VZM
     COMPUTE WS-SCALE = 3.0 + 0.125 * L-W
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     MOVE 0.725 TO PC-FRICTION
     MOVE 1.0 TO PC-RCOL PC-GCOL PC-BCOL
     IF PC-YD < 0
         COMPUTE PC-YD = 0 - PC-YD
     END-IF
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(25 * (0.8 + 0.2 * L-R))
     GOBACK.
 END PROGRAM P5-GBASE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GPLUME-NEW.
*> Section 2.16 GeyserPlumeParticle: USING PCL, P5X, x, y, z, vx, vy, vz, w, draws (1-7 base with velocity), spray draws h1, h2 (the
*> level's nextFloat). n = 5 * max(1, w), lifetime 5 * n, yd 0, maxY = y + n - 1, spray (h - 0.5) * 0.2, friction 1.0,
*> propulsion (1.5 if w = 1 else 1.0) * n * 1.45, gravity = -propulsion, sizes b * (2 + n / 8) and b * (3 + n / 8) with
*> b = quadSize * 0.75, quadSize = the minimum.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-W                    BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-H1                   FLOAT-LONG.
 01 L-H2                   FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-VX L-VY L-VZ L-W L-DRAWS L-H1 L-H2.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     COMPUTE WS-N = 5 * FUNCTION MAX(1, L-W)
     MOVE 1 TO PC-HAS-PHYSICS PC-SPEED-UP
     COMPUTE PC-LIFETIME = 5 * WS-N
     MOVE 0 TO PC-YD
     MOVE PC-Y TO X5-START-Y
     COMPUTE X5-MAX-Y = X5-START-Y + WS-N - 1
     COMPUTE X5-HSX = (L-H1 - 0.5) * 0.2
     COMPUTE X5-HSZ = (L-H2 - 0.5) * 0.2
     MOVE 1.0 TO PC-FRICTION
     IF L-W = 1
         MOVE 1.5 TO WS-K
     ELSE
         MOVE 1.0 TO WS-K
     END-IF
     COMPUTE X5-INIT-PROP = WS-K * WS-N * 1.45
     COMPUTE PC-GRAVITY = 0 - X5-INIT-PROP
     COMPUTE WS-B = PC-QUAD-SIZE * 0.75
     COMPUTE X5-MIN-SIZE = WS-B * (2.0 + WS-N / 8)
     COMPUTE X5-MAX-SIZE = WS-B * (3.0 + WS-N / 8)
     MOVE X5-MIN-SIZE TO PC-QUAD-SIZE
     MOVE 0 TO X5-DONE PC-SPRITE
     GOBACK.
 END PROGRAM P5-GPLUME-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GPLUME-TICK.
*> Section 2.16 tick: USING PCL, P5X, PCL-COLLIDERS, sprite count. The base tick; when not done and (yd < 0 or y > maxY or y == yo)
*> lifetime = min(lifetime, age + 5), friction 0, done; every tick t = clamp((y - startY) / (maxY - startY), 0, 1),
*> gravity = propulsion * t^3 * 0.12, xd = t * sprayX, zd = t * sprayZ, the sprite from age and quadSize = min + t *
*> (max - min).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIM                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL P5X PCL-COLLIDERS L-N.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF X5-DONE = 0
         IF PC-YD < 0 OR PC-Y > X5-MAX-Y OR PC-Y = PC-YO
             COMPUTE WS-LIM = PC-AGE + 5
             IF WS-LIM < PC-LIFETIME
                 MOVE WS-LIM TO PC-LIFETIME
             END-IF
             MOVE 0 TO PC-FRICTION
             MOVE 1 TO X5-DONE
         END-IF
     END-IF
     COMPUTE WS-T = (PC-Y - X5-START-Y) / (X5-MAX-Y - X5-START-Y)
     IF WS-T < 0
         MOVE 0 TO WS-T
     END-IF
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     COMPUTE PC-GRAVITY = X5-INIT-PROP * WS-T * WS-T * WS-T * 0.12
     COMPUTE PC-XD = WS-T * X5-HSX
     COMPUTE PC-ZD = WS-T * X5-HSZ
     CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     COMPUTE PC-QUAD-SIZE = X5-MIN-SIZE + WS-T * (X5-MAX-SIZE - X5-MIN-SIZE)
     GOBACK.
 END PROGRAM P5-GPLUME-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-BUBBLE-NEW.
*> Section 2.17 SulfurBubbleParticle: USING PCL, P5X, x, y, z, vx, vz (the provider passes vx and vy, read as x and z), draws (1
*> lifetime, 2 quad size, 3 x jitter, 4 z jitter, 5 size). gravity -0.04, friction 0.85, box 0.02, xd = vx * 0.2 +
*> (r * 2 - 1) * 0.02, zd likewise, sizeStart = 0.02 + r * 0.02, lifetime 2147483647, yStart = y, yEnd = y + 3, yPrev = y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S1                  FLOAT-LONG VALUE 0.02.
 01 WS-S2                  FLOAT-LONG VALUE 0.02.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P5X L-X L-Y L-Z L-VX L-VZ L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE -0.04 TO PC-GRAVITY
     MOVE 0.85 TO PC-FRICTION
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     COMPUTE PC-XD = L-VX * 0.2 + (L-DRAW(3) * 2 - 1) * 0.02
     COMPUTE PC-ZD = L-VZ * 0.2 + (L-DRAW(4) * 2 - 1) * 0.02
     COMPUTE X5-SIZE-START = 0.02 + L-DRAW(5) * 0.02
     MOVE X5-SIZE-START TO PC-QUAD-SIZE
     MOVE 2147483647 TO PC-LIFETIME
     MOVE L-Y TO X5-START-Y X5-Y-PREV
     COMPUTE X5-Y-END = L-Y + 3.0
     GOBACK.
 END PROGRAM P5-BUBBLE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-BUBBLE-TICK.
*> Section 2.17 tick: USING PCL, P5X, PCL-COLLIDERS, water source at the position (0/1), draws (1 float and 2 boolean of the x
*> wiggle, 3 float and 4 boolean of the z wiggle; a boolean draw of 0.5 or more is true). The base tick; not over a water
*> source, y >= yEnd or y <= yPrev removes; xd and zd gain float * 0.003 * (+1 or -1) * 0.5; an extra horizontal move; quadSize =
*> sizeStart + (y - yStart) / (yEnd - yStart) * (0.15 - sizeStart); yPrev = y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-SIGN                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP5X.
 01 L-WATER                BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P5X PCL-COLLIDERS L-WATER L-DRAWS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF PC-REMOVED NOT = 0
         GOBACK
     END-IF
     IF L-WATER = 0 OR PC-Y >= X5-Y-END OR PC-Y <= X5-Y-PREV
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     IF L-DRAW(2) >= 0.5
         MOVE 1 TO WS-SIGN
     ELSE
         MOVE -1 TO WS-SIGN
     END-IF
     COMPUTE PC-XD = PC-XD + L-DRAW(1) * 0.003 * WS-SIGN * 0.5
     IF L-DRAW(4) >= 0.5
         MOVE 1 TO WS-SIGN
     ELSE
         MOVE -1 TO WS-SIGN
     END-IF
     COMPUTE PC-ZD = PC-ZD + L-DRAW(3) * 0.003 * WS-SIGN * 0.5
     CALL "PCL-MOVE" USING PCL PC-XD WS-ZERO PC-ZD PCL-COLLIDERS
     COMPUTE PC-QUAD-SIZE = X5-SIZE-START + (PC-Y - X5-START-Y) / (X5-Y-END - X5-START-Y) * (0.15 - X5-SIZE-START)
     MOVE PC-Y TO X5-Y-PREV
     GOBACK.
 END PROGRAM P5-BUBBLE-TICK.
