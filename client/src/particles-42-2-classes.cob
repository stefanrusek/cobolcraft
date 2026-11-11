*> Particles part 2, section 3 (docs/protocol/42-particles-2-effects-fire-smoke-magic.md): the per-class
*> records 3.1 to 3.23. Constructors take the PCL record (CLPCL), the extras where the class has any (PCLX of
*> CLPCLX, P2X of CLP2X), the position, the supplied velocity, a "kind" where several providers share a class,
*> and the random draws as a table in the document's draw order (see particles-42-2.cob). Provider sprite
*> draws are the caller's: the constructors set the sprite from age 0 or leave sprite 0.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-BASE7Z.
*> Base7(0, 0, 0): USING PCL, x, y, z, draws: the velocity constructor with a zero bias (draws 1 to 6) and
*> the quad size draw (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     GOBACK.
 END PROGRAM P2-BASE7Z.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-BASE2.
*> Base2: USING PCL, x, y, z, draws: the lifetime draw (1) and the quad size draw (2); velocity zero.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     GOBACK.
 END PROGRAM P2-BASE2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-HEART-NEW.
*> 3.1 HeartParticle: USING PCL, x, y, z, angry (1 adds 0.5 to y), draws (Base7 7). Friction 0.86, the
*> velocity * 0.01 plus 0.1 on y, quadSize * 1.5, lifetime 16, no collision, speedUp on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ANGRY                BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-ANGRY L-DRAWS.
     MOVE L-Y TO WS-Y
     IF L-ANGRY NOT = 0
         ADD 0.5 TO WS-Y
     END-IF
     CALL "P2-BASE7Z" USING PCL L-X WS-Y L-Z L-DRAWS
     MOVE 1 TO PC-SPEED-UP
     MOVE 0.86 TO PC-FRICTION
     COMPUTE PC-XD = PC-XD * 0.009999999776482582
     COMPUTE PC-YD = PC-YD * 0.009999999776482582
     COMPUTE PC-ZD = PC-ZD * 0.009999999776482582
     ADD 0.1 TO PC-YD
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 1.5
     MOVE 16 TO PC-LIFETIME
     MOVE 0 TO PC-HAS-PHYSICS
     GOBACK.
 END PROGRAM P2-HEART-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-TOWN-NEW.
*> 3.2 SuspendedTownParticle: USING PCL, x, y, z, vx, vy, vz, kind (0 happy_villager, 1 composter, 2 dolphin,
*> 3 egg_crack), draws: 1-7 Base7(v), 8 grey, 9 size, 10 lifetime, 11 the provider setter (composter
*> nextInt(5), dolphin alpha). Box 0.02, velocity * 0.02, no collision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S1                  FLOAT-LONG VALUE 0.02.
 01 WS-S2                  FLOAT-LONG VALUE 0.02.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     COMPUTE WS-C = L-DRAW(8) * 0.1 + 0.2
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(9) * 0.6 + 0.5)
     COMPUTE PC-XD = PC-XD * 0.019999999552965164
     COMPUTE PC-YD = PC-YD * 0.019999999552965164
     COMPUTE PC-ZD = PC-ZD * 0.019999999552965164
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(20 / (L-DRAW(10) * 0.8 + 0.2))
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 1.0 TO PC-RCOL PC-GCOL PC-BCOL
     EVALUATE L-KIND
         WHEN 1
             COMPUTE PC-LIFETIME = 3 + FUNCTION INTEGER-PART(L-DRAW(11) * 5)
         WHEN 2
             MOVE 0.3 TO PC-RCOL
             MOVE 0.5 TO PC-GCOL
             COMPUTE PC-ALPHA = 1 - L-DRAW(11) * 0.7
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(PC-LIFETIME / 2)
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-TOWN-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-TOWN-TICK.
*> 3.2 tick: USING PCL, PCL-COLLIDERS: old position = position; a lifetime of 0 or less removes it, else the
*> lifetime decrements (age stays 0); move without collision; velocity * 0.99.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-LIFETIME <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     SUBTRACT 1 FROM PC-LIFETIME
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-XD = PC-XD * 0.99
     COMPUTE PC-YD = PC-YD * 0.99
     COMPUTE PC-ZD = PC-ZD * 0.99
     GOBACK.
 END PROGRAM P2-TOWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CRIT-TICK.
*> 3.3 tick: USING PCL, PCL-COLLIDERS: the base tick, then green * 0.96 and blue * 0.9.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     COMPUTE PC-GCOL = PC-GCOL * 0.96
     COMPUTE PC-BCOL = PC-BCOL * 0.9
     GOBACK.
 END PROGRAM P2-CRIT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CRIT-NEW.
*> 3.3 CritParticle: USING PCL, x, y, z, vx, vy, vz, kind (0 crit, 1 enchanted_hit, 2 damage_indicator),
*> draws (Base7(0,0,0) 7, 8 grey, 9 lifetime), PCL-COLLIDERS (for the tick the constructor runs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VY                  FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS PCL-COLLIDERS.
     MOVE L-VY TO WS-VY
     IF L-KIND = 2
         ADD 1.0 TO WS-VY
     END-IF
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 0.7 TO PC-FRICTION
     MOVE 0.5 TO PC-GRAVITY
     COMPUTE PC-XD = PC-XD * 0.10000000149011612
     COMPUTE PC-YD = PC-YD * 0.10000000149011612
     COMPUTE PC-ZD = PC-ZD * 0.10000000149011612
     COMPUTE PC-XD = PC-XD + L-VX * 0.4000000059604645
     COMPUTE PC-YD = PC-YD + WS-VY * 0.4000000059604645
     COMPUTE PC-ZD = PC-ZD + L-VZ * 0.4000000059604645
     COMPUTE WS-C = L-DRAW(8) * 0.3 + 0.6
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = FUNCTION MAX(FUNCTION INTEGER-PART(6 / (L-DRAW(9) * 0.8 + 0.6)), 1)
     MOVE 0 TO PC-HAS-PHYSICS
     CALL "P2-CRIT-TICK" USING PCL PCL-COLLIDERS
     EVALUATE L-KIND
         WHEN 1
             COMPUTE PC-RCOL = PC-RCOL * 0.3
             COMPUTE PC-GCOL = PC-GCOL * 0.8
         WHEN 2
             MOVE 20 TO PC-LIFETIME
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-CRIT-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SWEEP-NEW.
*> 3.4 AttackSweepParticle: USING PCL, x, y, z, scale, draws (Base7(0,0,0) 7, 8 grey): lifetime 4,
*> grey r * 0.6 + 0.4, quadSize 1 - scale * 0.5, sprite from age 0 (index 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-SCALE L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 4 TO PC-LIFETIME
     COMPUTE WS-C = L-DRAW(8) * 0.6 + 0.4
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = 1.0 - L-SCALE * 0.5
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P2-SWEEP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SWEEP-TICK.
*> 3.4 tick: USING PCL: old position = position; an old age of 4 or more removes it; else the age
*> increments and the sprite is the age index over 8 sprites. No motion.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
     ELSE
         ADD 1 TO PC-AGE
         CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     END-IF
     GOBACK.
 END PROGRAM P2-SWEEP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-POOF-NEW.
*> 3.5 ExplodeParticle and SpitParticle: USING PCL, x, y, z, vx, vy, vz, spit (0 poof, 1 spit), draws:
*> 1-2 Base2, 3-5 velocity noise, 6 grey, 7-8 size, 9 lifetime. Gravity -0.1 (spit 0.5), friction 0.9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SPIT                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SPIT L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE -0.1 TO PC-GRAVITY
     MOVE 0.9 TO PC-FRICTION
     COMPUTE PC-XD = L-VX + (L-DRAW(3) * 2 - 1) * 0.05
     COMPUTE PC-YD = L-VY + (L-DRAW(4) * 2 - 1) * 0.05
     COMPUTE PC-ZD = L-VZ + (L-DRAW(5) * 2 - 1) * 0.05
     COMPUTE WS-C = L-DRAW(6) * 0.3 + 0.7
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(7) * L-DRAW(8) * 6 + 1)
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(16 / (L-DRAW(9) * 0.8 + 0.2)) + 2
     MOVE 0 TO PC-SPRITE
     IF L-SPIT NOT = 0
         MOVE 0.5 TO PC-GRAVITY
     END-IF
     GOBACK.
 END PROGRAM P2-POOF-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-POOF-TICK.
*> 3.5 tick: USING PCL, PCL-COLLIDERS: the base tick (collision on), then the sprite from age (8 sprites).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     GOBACK.
 END PROGRAM P2-POOF-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CLOUD-NEW.
*> 3.6 PlayerCloudParticle: USING PCL, x, y, z, vx, vy, vz, sneeze (0 cloud, 1 sneeze), draws (Base7(0,0,0)
*> 7, 8 grey, 9 lifetime). friction 0.96, velocity * 0.1 plus the supplied one, quadSize * 1.875, no
*> collision. Sneeze: colour (0.22, 1.0, 0.53), alpha 0.4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SNEEZE               BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SNEEZE L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     COMPUTE PC-XD = PC-XD * 0.10000000149011612 + L-VX
     COMPUTE PC-YD = PC-YD * 0.10000000149011612 + L-VY
     COMPUTE PC-ZD = PC-ZD * 0.10000000149011612 + L-VZ
     COMPUTE WS-C = 1 - L-DRAW(8) * 0.3
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 1.875
     COMPUTE WS-I = FUNCTION INTEGER-PART(8 / (L-DRAW(9) * 0.8 + 0.3))
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(FUNCTION MAX(WS-I * 2.5, 1))
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     IF L-SNEEZE NOT = 0
         MOVE 0.22 TO PC-RCOL
         MOVE 1.0 TO PC-GCOL
         MOVE 0.53 TO PC-BCOL
         MOVE 0.4 TO PC-ALPHA
     END-IF
     GOBACK.
 END PROGRAM P2-CLOUD-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CLOUD-TICK.
*> 3.6 tick: USING PCL, PCL-COLLIDERS, has player (a player within 2.0 blocks, spectators excluded), the
*> player's y, the player's vertical velocity: the base tick; when not removed the sprite from age, and
*> with a player whose y is above: y += (py - y) * 0.2, yd += (pyd - yd) * 0.2, then setPos.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-HAS-PLAYER           BINARY-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PYD                  FLOAT-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-HAS-PLAYER L-PY L-PYD.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF PC-REMOVED = 0
         CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
         IF L-HAS-PLAYER NOT = 0 AND L-PY > PC-Y
             MOVE PC-X TO WS-X
             MOVE PC-Z TO WS-Z
             COMPUTE WS-Y = PC-Y + (L-PY - PC-Y) * 0.2
             COMPUTE PC-YD = PC-YD + (L-PYD - PC-YD) * 0.2
             CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P2-CLOUD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-SET-ALPHA.
*> 3.7 setAlpha: USING PCL, P2X, alpha: sets alpha and originalAlpha.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-ALPHA                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P2X L-ALPHA.
     MOVE L-ALPHA TO PC-ALPHA
     MOVE L-ALPHA TO X2-ORIG-ALPHA
     GOBACK.
 END PROGRAM P2-SPELL-SET-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-NEW.
*> 3.7 SpellParticle: USING PCL, P2X, x, y, z, xa, ya, za, r1, r2 (the two nextDouble draws of the shared
*> static source), scoping (1 when the spyglass test holds), draws (Base7 with velocity (0.5 - r1, ya,
*> 0.5 - r2) 7, 8 lifetime).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-XA                   FLOAT-LONG.
 01 L-YA                   FLOAT-LONG.
 01 L-ZA                   FLOAT-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-SCOPING              BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P2X L-X L-Y L-Z L-XA L-YA L-ZA L-R1 L-R2 L-SCOPING L-DRAWS.
     COMPUTE WS-BX = 0.5 - L-R1
     COMPUTE WS-BZ = 0.5 - L-R2
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-BX L-YA WS-BZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     MOVE 1.0 TO X2-ORIG-ALPHA
     MOVE 0.96 TO PC-FRICTION
     MOVE -0.1 TO PC-GRAVITY
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-YD = PC-YD * 0.20000000298023224
     IF L-XA = 0 AND L-ZA = 0
         COMPUTE PC-XD = PC-XD * 0.10000000149011612
         COMPUTE PC-ZD = PC-ZD * 0.10000000149011612
     END-IF
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8 / (L-DRAW(8) * 0.8 + 0.2))
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     IF L-SCOPING NOT = 0
         CALL "P2-SPELL-SET-ALPHA" USING PCL P2X WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM P2-SPELL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-TICK.
*> 3.7 tick: USING PCL, P2X, PCL-COLLIDERS, scoping: the base tick, the sprite from age (8 sprites), then
*> alpha 0 while scoping, else alpha += (originalAlpha - alpha) * 0.05.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-SCOPING              BINARY-LONG.
 PROCEDURE DIVISION USING PCL P2X PCL-COLLIDERS L-SCOPING.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     IF L-SCOPING NOT = 0
         MOVE 0 TO PC-ALPHA
     ELSE
         COMPUTE PC-ALPHA = PC-ALPHA + (X2-ORIG-ALPHA - PC-ALPHA) * 0.05
     END-IF
     GOBACK.
 END PROGRAM P2-SPELL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-EFFECT.
*> 3.7 effect and instant_effect providers: USING PCL, red, green, blue, power: setColor then setPower.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-POWER                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-R L-G L-B L-POWER.
     CALL "PCL-SET-COLOR" USING PCL L-R L-G L-B
     CALL "PCL-SET-POWER" USING PCL L-POWER
     GOBACK.
 END PROGRAM P2-SPELL-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-ENTITY.
*> 3.7 entity_effect provider: USING PCL, P2X, red, green, blue, alpha: setColor then setAlpha (both alphas).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P2X L-R L-G L-B L-A.
     CALL "PCL-SET-COLOR" USING PCL L-R L-G L-B
     CALL "P2-SPELL-SET-ALPHA" USING PCL P2X L-A
     GOBACK.
 END PROGRAM P2-SPELL-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPELL-WITCH.
*> 3.7 witch provider: USING PCL, draw (the engine's): m = r * 0.5 + 0.35, colour (m, 0, m).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-DRAW                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-DRAW.
     COMPUTE WS-M = L-DRAW * 0.5 + 0.35
     MOVE WS-M TO WS-M2
     CALL "PCL-SET-COLOR" USING PCL WS-M WS-ZERO WS-M2
     GOBACK.
 END PROGRAM P2-SPELL-WITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-DRAGON-NEW.
*> 3.8 DragonBreathParticle: USING PCL, x, y, z, vx, vy, vz, power, draws: 1-2 Base2, 3 red, 4 blue, 5
*> lifetime. Velocity exact, green 0, quadSize * 0.75, no collision, then setPower (the provider).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-POWER                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-POWER L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 0.96 TO PC-FRICTION
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     COMPUTE PC-RCOL = 0.7176471 + L-DRAW(3) * (0.8745098 - 0.7176471)
     MOVE 0 TO PC-GCOL
     COMPUTE PC-BCOL = 0.8235294 + L-DRAW(4) * (0.9764706 - 0.8235294)
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(20 / (L-DRAW(5) * 0.8 + 0.2))
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     CALL "PCL-SET-POWER" USING PCL L-POWER
     GOBACK.
 END PROGRAM P2-DRAGON-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-DRAGON-TICK.
*> 3.8 tick: USING PCL, PCL-COLLIDERS: previous position, age test and increment, sprite index age * 2 /
*> lifetime (3 sprites), one move, xd and zd * 1.1 when y did not change, then * friction. yd never damped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     ADD 1 TO PC-AGE
     CALL "PCL-SPRITE-INDEX" USING PC-AGE PC-LIFETIME WS-N PC-SPRITE
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     IF PC-Y = PC-YO
         COMPUTE PC-XD = PC-XD * 1.1
         COMPUTE PC-ZD = PC-ZD * 1.1
     END-IF
     COMPUTE PC-XD = PC-XD * PC-FRICTION
     COMPUTE PC-ZD = PC-ZD * PC-FRICTION
     GOBACK.
 END PROGRAM P2-DRAGON-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLY-NEW.
*> 3.9 FlyTowardsPositionParticle (short constructor): USING PCL, P2X, x, y, z, vx, vy, vz, draws: 1-2
*> Base2, 3 size, 4 colour, 5 lifetime. The particle starts at position + velocity and flies to the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P2X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 1.0 TO PC-ALPHA
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     MOVE L-X TO X2-XSTART
     MOVE L-Y TO X2-YSTART
     MOVE L-Z TO X2-ZSTART
     COMPUTE PC-XO = L-X + L-VX
     COMPUTE PC-YO = L-Y + L-VY
     COMPUTE PC-ZO = L-Z + L-VZ
     MOVE PC-XO TO PC-X
     MOVE PC-YO TO PC-Y
     MOVE PC-ZO TO PC-Z
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(3) * 0.5 + 0.2)
     COMPUTE WS-C = L-DRAW(4) * 0.6 + 0.4
     COMPUTE PC-RCOL = 0.9 * WS-C
     COMPUTE PC-GCOL = 0.9 * WS-C
     MOVE WS-C TO PC-BCOL
     MOVE 0 TO PC-HAS-PHYSICS
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(5) * 10) + 30
     GOBACK.
 END PROGRAM P2-FLY-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLY-TICK.
*> 3.9 tick: USING PCL, P2X: previous position, old age test, increment; with t = age / lifetime, f = 1 - t,
*> u = t^4: x = xStart + xd * f, y = yStart + yd * f - u * 1.2, z likewise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 PROCEDURE DIVISION USING PCL P2X.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     ADD 1 TO PC-AGE
     COMPUTE WS-T = PC-AGE / PC-LIFETIME
     COMPUTE WS-F = 1 - WS-T
     COMPUTE WS-U = WS-T * WS-T * WS-T * WS-T
     COMPUTE PC-X = X2-XSTART + PC-XD * WS-F
     COMPUTE PC-Y = X2-YSTART + PC-YD * WS-F - WS-U * 1.2
     COMPUTE PC-Z = X2-ZSTART + PC-ZD * WS-F
     GOBACK.
 END PROGRAM P2-FLY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLY-LIGHT.
*> 3.9 and 3.20 light: USING default light (smooth form), age, lifetime, light out: E(L, t^4), t = age /
*> lifetime without the partial tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-AGE L-LIFETIME L-OUT.
     COMPUTE WS-T = L-AGE / L-LIFETIME
     COMPUTE WS-F = WS-T * WS-T * WS-T * WS-T
     CALL "P2-LIGHT-EMIT" USING L-LIGHT WS-F L-OUT
     GOBACK.
 END PROGRAM P2-FLY-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LIFE-ALPHA.
*> 3.9 LifetimeAlpha.currentAlphaForAge: USING start alpha, end alpha, start age, end age (normalised),
*> age, lifetime, partial, alpha out: equal alphas give that alpha; else clampedLerp(start, end,
*> inverseLerp((age + partial) / lifetime, startAge, endAge)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-INV                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SA                   FLOAT-LONG.
 01 L-EA                   FLOAT-LONG.
 01 L-SAGE                 FLOAT-LONG.
 01 L-EAGE                 FLOAT-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SA L-EA L-SAGE L-EAGE L-AGE L-LIFETIME L-PARTIAL L-OUT.
     IF FUNCTION ABS(L-SA - L-EA) < 0.00001
         MOVE L-SA TO L-OUT
     ELSE
         COMPUTE WS-T = (L-AGE + L-PARTIAL) / L-LIFETIME
         COMPUTE WS-INV = (WS-T - L-SAGE) / (L-EAGE - L-SAGE)
         COMPUTE WS-INV = FUNCTION MAX(0, FUNCTION MIN(1, WS-INV))
         COMPUTE L-OUT = L-SA + (L-EA - L-SA) * WS-INV
     END-IF
     GOBACK.
 END PROGRAM P2-LIFE-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LIFE-LAYER.
*> 3.9 layer: USING start alpha, end alpha, layer out: OPAQUE (0) when both are 1 or more, else TRANSLUCENT (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SA                   FLOAT-LONG.
 01 L-EA                   FLOAT-LONG.
 01 L-LAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-SA L-EA L-LAYER.
     IF L-SA >= 1 AND L-EA >= 1
         MOVE 0 TO L-LAYER
     ELSE
         MOVE 1 TO L-LAYER
     END-IF
     GOBACK.
 END PROGRAM P2-LIFE-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-ENDROD-NEW.
*> 3.10 EndRodParticle: USING PCL, PCLX, x, y, z, vx, vy, vz, draws (1-2 the animated base, 3 nextInt(12)):
*> gravity 0.0125, velocity exact, quadSize * 0.75, lifetime 60 + n, fade colour 0xF2DEC9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.0125.
 01 WS-FADE                BINARY-DOUBLE VALUE 15916745.
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
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PSA-NEW" USING PCL PCLX L-X L-Y L-Z WS-GRAVITY L-DRAWS
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = 60 + FUNCTION INTEGER-PART(L-DRAW(3) * 12)
     CALL "PSA-SET-FADE" USING PCLX WS-FADE
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P2-ENDROD-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-TOTEM-NEW.
*> 3.11 TotemParticle: USING PCL, PCLX, x, y, z, vx, vy, vz, draws (1-2 base, 3 nextInt(12), 4 nextInt(4), 5-7
*> colour): gravity 1.25, friction 0.6, velocity exact, quadSize * 0.75, lifetime 60 + n; selector 0 gives a
*> yellow-gold, else a green. Collision stays on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 1.25.
 01 WS-K                   BINARY-LONG.
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
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PSA-NEW" USING PCL PCLX L-X L-Y L-Z WS-GRAVITY L-DRAWS
     MOVE 0.6 TO PC-FRICTION
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-LIFETIME = 60 + FUNCTION INTEGER-PART(L-DRAW(3) * 12)
     MOVE 0 TO PC-SPRITE
     COMPUTE WS-K = FUNCTION INTEGER-PART(L-DRAW(4) * 4)
     IF WS-K = 0
         COMPUTE PC-RCOL = 0.6 + L-DRAW(5) * 0.2
         COMPUTE PC-GCOL = 0.6 + L-DRAW(6) * 0.3
     ELSE
         COMPUTE PC-RCOL = 0.1 + L-DRAW(5) * 0.2
         COMPUTE PC-GCOL = 0.4 + L-DRAW(6) * 0.3
     END-IF
     COMPUTE PC-BCOL = L-DRAW(7) * 0.2
     GOBACK.
 END PROGRAM P2-TOTEM-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-EXPLOSION-NEW.
*> 3.12 HugeExplosionParticle: USING PCL, x, y, z, scale, draws (Base7(0,0,0) 7, 8 nextInt(4), 9 grey):
*> lifetime 6 + n, grey r * 0.6 + 0.4, quadSize 2 * (1 - scale * 0.5), sprite 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-SCALE L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     COMPUTE PC-LIFETIME = 6 + FUNCTION INTEGER-PART(L-DRAW(8) * 4)
     COMPUTE WS-C = L-DRAW(9) * 0.6 + 0.4
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = 2.0 * (1.0 - L-SCALE * 0.5)
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P2-EXPLOSION-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-EXPLOSION-TICK.
*> 3.12 tick: USING PCL: previous position, old age test, increment, sprite index age * 15 / lifetime (16
*> sprites). No motion.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
     ELSE
         ADD 1 TO PC-AGE
         CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     END-IF
     GOBACK.
 END PROGRAM P2-EXPLOSION-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SEED-NEW.
*> 3.12 HugeExplosionSeedParticle: USING PCL, x, y, z, draws (the six draws of the position-only chain):
*> lifetime 8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Z1                  FLOAT-LONG VALUE 0.
 01 WS-Z2                  FLOAT-LONG VALUE 0.
 01 WS-Z3                  FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-Z1 WS-Z2 WS-Z3 L-DRAWS
     MOVE 8 TO PC-LIFETIME
     GOBACK.
 END PROGRAM P2-SEED-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SEED-TICK.
*> 3.12 tick: USING PCL, P2SP (the spawns out), draws (36 nextDouble: per spawn the x pair, y pair, z pair):
*> six explosion particles at (d1 - d2) * 4 per axis with scale age / lifetime (before the increment); then
*> age + 1, removed when the age equals the lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 36 TIMES.
 PROCEDURE DIVISION USING PCL P2SP L-DRAWS.
     MOVE 6 TO SP-COUNT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         COMPUTE WS-BASE = (WS-J - 1) * 6
         COMPUTE SP-X(WS-J) = PC-X + (L-DRAW(WS-BASE + 1) - L-DRAW(WS-BASE + 2)) * 4.0
         COMPUTE SP-Y(WS-J) = PC-Y + (L-DRAW(WS-BASE + 3) - L-DRAW(WS-BASE + 4)) * 4.0
         COMPUTE SP-Z(WS-J) = PC-Z + (L-DRAW(WS-BASE + 5) - L-DRAW(WS-BASE + 6)) * 4.0
         COMPUTE SP-SCALE(WS-J) = PC-AGE / PC-LIFETIME
     END-PERFORM
     ADD 1 TO PC-AGE
     IF PC-AGE = PC-LIFETIME
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P2-SEED-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLAME-NEW.
*> 3.14 FlameParticle: USING PCL, x, y, z, vx, vy, vz, small (1 for small_flame), draws (the 14 of the rising
*> base 42-1 section 8.1). No collision; small_flame scales by 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SMALL                BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SMALL L-DRAWS.
     CALL "PRISE-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 0 TO PC-HAS-PHYSICS
     IF L-SMALL NOT = 0
         CALL "PCL-QUAD-SCALE" USING PCL WS-HALF
     END-IF
     GOBACK.
 END PROGRAM P2-FLAME-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLAME-SIZE.
*> 3.14 getQuadSize: USING PCL, partial, size out: quadSize * (1 - s * s * 0.5), s = (age + partial) / lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-SIZE.
     COMPUTE WS-S = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     COMPUTE L-SIZE = PC-QUAD-SIZE * (1 - WS-S * WS-S * 0.5)
     GOBACK.
 END PROGRAM P2-FLAME-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FLAME-LIGHT.
*> 3.14 and 3.23 light: USING PCL, partial, default light (smooth form), light out: E(L, (age + partial) /
*> lifetime).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-LIGHT L-OUT.
     COMPUTE WS-F = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     CALL "P2-LIGHT-EMIT" USING L-LIGHT WS-F L-OUT
     GOBACK.
 END PROGRAM P2-FLAME-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SOUL-NEW.
*> 3.15 EmissiveRisingParticle: USING PCL, x, y, z, vx, vy, vz, draws (the 14 of the rising base): scale 1.5,
*> sprite from age 0, alpha 1, collision on.
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
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PRISE-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     MOVE 0 TO PC-SPRITE
     MOVE 1.0 TO PC-ALPHA
     GOBACK.
 END PROGRAM P2-SOUL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SOUL-TICK.
*> 3.15 tick: USING PCL, PCL-COLLIDERS: the base tick, then the sprite from age (11 sprites).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 11.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     GOBACK.
 END PROGRAM P2-SOUL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SMOKE-NEW.
*> 3.16 smoke family: USING PCL, x, y, z, vx, vy, vz, kind (0 smoke, 1 large_smoke, 2 white_smoke), draws
*> (9 of the ash base 42-1 section 8.5): multipliers 0.1, add-on the supplied velocity, grey multiplier 0.3,
*> lifetime base 8, gravity -0.1, collision on, scale 1.0 / 2.5 / 1.0; white smoke ends with its fixed colour.
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
    05 WS-COLOUR           FLOAT-LONG.
    05 WS-LIFE             FLOAT-LONG.
    05 WS-GRAVITY          FLOAT-LONG.
    05 WS-PHYSICS          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS.
     MOVE 0.1 TO WS-VXM WS-VYM WS-VZM
     MOVE L-VX TO WS-AX
     MOVE L-VY TO WS-AY
     MOVE L-VZ TO WS-AZ
     MOVE 1.0 TO WS-SCALE
     IF L-KIND = 1
         MOVE 2.5 TO WS-SCALE
     END-IF
     MOVE 0.3 TO WS-COLOUR
     MOVE 8 TO WS-LIFE
     MOVE -0.1 TO WS-GRAVITY
     MOVE 1 TO WS-PHYSICS
     CALL "PASH-NEW" USING PCL L-X L-Y L-Z WS-ARGS L-DRAWS
     IF L-KIND = 2
         MOVE 0.7294118 TO PC-RCOL
         MOVE 0.69411767 TO PC-GCOL
         MOVE 0.7607843 TO PC-BCOL
     END-IF
     GOBACK.
 END PROGRAM P2-SMOKE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CAMPFIRE-NEW.
*> 3.17 CampfireSmokeParticle: USING PCL, P2X, x, y, z, vx, vy, vz, signal, draws (1-2 Base2, 3 nextInt(50),
*> 4 the yd noise): scale 3 then box 0.25, lifetime 280 / 80 + n, gravity 3.0E-6, alpha 0.95 / 0.9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THREE               FLOAT-LONG VALUE 3.0.
 01 WS-S1                  FLOAT-LONG VALUE 0.25.
 01 WS-S2                  FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P2X L-X L-Y L-Z L-VX L-VY L-VZ L-SIGNAL L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     CALL "PCL-QUAD-SCALE" USING PCL WS-THREE
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     IF L-SIGNAL NOT = 0
         COMPUTE PC-LIFETIME = 280 + FUNCTION INTEGER-PART(L-DRAW(3) * 50)
         MOVE 0.95 TO PC-ALPHA
     ELSE
         COMPUTE PC-LIFETIME = 80 + FUNCTION INTEGER-PART(L-DRAW(3) * 50)
         MOVE 0.9 TO PC-ALPHA
     END-IF
     MOVE 0.000003 TO PC-GRAVITY
     MOVE L-VX TO PC-XD
     COMPUTE PC-YD = L-VY + L-DRAW(4) / 500
     MOVE L-VZ TO PC-ZD
     GOBACK.
 END PROGRAM P2-CAMPFIRE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-CAMPFIRE-TICK.
*> 3.17 tick: USING PCL, PCL-COLLIDERS, noise (nextFloat, nextBoolean, nextFloat, nextBoolean; a boolean
*> draw of 0.5 or more is true): previous position; old age compared, age incremented; removed when the old
*> age reached the lifetime or alpha is 0 or less; xd and zd drift by float / 5000 with a random sign;
*> yd -= gravity; move; with the (incremented) age within 60 of the lifetime and alpha above 0.01,
*> alpha -= 0.015.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-NOISES.
    05 L-NOISE             FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-NOISES.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-AGE TO WS-OLD
     ADD 1 TO PC-AGE
     IF WS-OLD >= PC-LIFETIME OR PC-ALPHA <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     MOVE -1 TO WS-SIGN
     IF L-NOISE(2) >= 0.5
         MOVE 1 TO WS-SIGN
     END-IF
     COMPUTE PC-XD = PC-XD + L-NOISE(1) / 5000 * WS-SIGN
     MOVE -1 TO WS-SIGN
     IF L-NOISE(4) >= 0.5
         MOVE 1 TO WS-SIGN
     END-IF
     COMPUTE PC-ZD = PC-ZD + L-NOISE(3) / 5000 * WS-SIGN
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     IF PC-AGE >= PC-LIFETIME - 60 AND PC-ALPHA > 0.01
         COMPUTE PC-ALPHA = PC-ALPHA - 0.015
     END-IF
     GOBACK.
 END PROGRAM P2-CAMPFIRE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-NOTE-NEW.
*> 3.18 NoteParticle: USING PCL, x, y, z, note, draws (Base7(0,0,0) 7): friction 0.66, speedUp, velocity *
*> 0.01, yd + 0.2, colour from three phases of the table sine, quadSize * 1.5, lifetime 6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-TWO-PI              FLOAT-LONG VALUE 6.2831855.
 01 WS-THIRD               FLOAT-LONG VALUE 0.33333334.
 01 WS-TWO-THIRDS          FLOAT-LONG VALUE 0.6666667.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-NOTE                 FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-NOTE L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 0.66 TO PC-FRICTION
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-XD = PC-XD * 0.009999999776482582
     COMPUTE PC-YD = PC-YD * 0.009999999776482582
     COMPUTE PC-ZD = PC-ZD * 0.009999999776482582
     ADD 0.2 TO PC-YD
     COMPUTE WS-ARG = WS-TWO-PI * L-NOTE
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE PC-RCOL = FUNCTION MAX(0, WS-SIN * 0.65 + 0.35)
     COMPUTE WS-ARG = WS-TWO-PI * (L-NOTE + WS-THIRD)
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE PC-GCOL = FUNCTION MAX(0, WS-SIN * 0.65 + 0.35)
     COMPUTE WS-ARG = WS-TWO-PI * (L-NOTE + WS-TWO-THIRDS)
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE PC-BCOL = FUNCTION MAX(0, WS-SIN * 0.65 + 0.35)
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 1.5
     MOVE 6 TO PC-LIFETIME
     GOBACK.
 END PROGRAM P2-NOTE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-ELDER-NEW.
*> 3.19 ElderGuardianParticle: USING PCL, x, y, z, draw (the lifetime draw of the position-only chain):
*> gravity 0, lifetime 30, velocity zero.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAW.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW
     MOVE 0 TO PC-GRAVITY
     MOVE 30 TO PC-LIFETIME
     GOBACK.
 END PROGRAM P2-ELDER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-PORTAL-NEW.
*> 3.20 PortalParticle and ReversePortalParticle: USING PCL, P2X, x, y, z, vx, vy, vz, reverse, draws (1-2
*> Base2, 3 size, 4 colour, 5 lifetime, 6 the reverse lifetime). The velocity is the starting offset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-REVERSE              BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P2X L-X L-Y L-Z L-VX L-VY L-VZ L-REVERSE L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     MOVE L-X TO PC-X X2-XSTART
     MOVE L-Y TO PC-Y X2-YSTART
     MOVE L-Z TO PC-Z X2-ZSTART
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(3) * 0.2 + 0.5)
     COMPUTE WS-C = L-DRAW(4) * 0.6 + 0.4
     COMPUTE PC-RCOL = WS-C * 0.9
     COMPUTE PC-GCOL = WS-C * 0.3
     MOVE WS-C TO PC-BCOL
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(5) * 10) + 40
     MOVE 0 TO PC-HAS-PHYSICS
     IF L-REVERSE NOT = 0
         COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 1.5
         COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(6) * 2) + 60
     END-IF
     GOBACK.
 END PROGRAM P2-PORTAL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-PORTAL-TICK.
*> 3.20 tick: USING PCL, P2X, reverse: previous position, old age test, increment, t = age / lifetime.
*> Portal: f = 1 + t - 2 t^2, x = xStart + xd * f, y = yStart + yd * f + (1 - t), z likewise. Reverse: the
*> velocity is added to the position scaled by t.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 01 L-REVERSE              BINARY-LONG.
 PROCEDURE DIVISION USING PCL P2X L-REVERSE.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     ADD 1 TO PC-AGE
     COMPUTE WS-T = PC-AGE / PC-LIFETIME
     IF L-REVERSE = 0
         COMPUTE WS-F = 1 + WS-T - 2 * WS-T * WS-T
         COMPUTE PC-X = X2-XSTART + PC-XD * WS-F
         COMPUTE PC-Y = X2-YSTART + PC-YD * WS-F + (1 - WS-T)
         COMPUTE PC-Z = X2-ZSTART + PC-ZD * WS-F
     ELSE
         COMPUTE PC-X = PC-X + PC-XD * WS-T
         COMPUTE PC-Y = PC-Y + PC-YD * WS-T
         COMPUTE PC-Z = PC-Z + PC-ZD * WS-T
     END-IF
     GOBACK.
 END PROGRAM P2-PORTAL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-PORTAL-SIZE.
*> 3.20 getQuadSize: USING PCL, reverse, partial, size out. Portal: quadSize * (1 - (1 - t')^2); reverse:
*> quadSize * (1 - (age + partial) / (lifetime * 1.5)); t' = (age + partial) / lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-REVERSE              BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-REVERSE L-PARTIAL L-SIZE.
     COMPUTE WS-T = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     IF L-REVERSE = 0
         COMPUTE L-SIZE = PC-QUAD-SIZE * (1 - (1 - WS-T) * (1 - WS-T))
     ELSE
         COMPUTE L-SIZE = PC-QUAD-SIZE * (1 - (PC-AGE + L-PARTIAL) / (PC-LIFETIME * 1.5))
     END-IF
     GOBACK.
 END PROGRAM P2-PORTAL-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LAVA-NEW.
*> 3.21 LavaParticle: USING PCL, x, y, z, draws (Base7(0,0,0) 7, 8 yd, 9 size, 10 lifetime): gravity 0.75,
*> friction 0.999, velocity * 0.8, yd = r * 0.4 + 0.05, quadSize * (r * 2 + 0.2).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 0.75 TO PC-GRAVITY
     MOVE 0.999 TO PC-FRICTION
     COMPUTE PC-XD = PC-XD * 0.800000011920929
     COMPUTE PC-YD = PC-YD * 0.800000011920929
     COMPUTE PC-ZD = PC-ZD * 0.800000011920929
     COMPUTE PC-YD = L-DRAW(8) * 0.4 + 0.05
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(9) * 2 + 0.2)
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(16 / (L-DRAW(10) * 0.8 + 0.2))
     GOBACK.
 END PROGRAM P2-LAVA-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LAVA-TICK.
*> 3.21 tick: USING PCL, PCL-COLLIDERS, r (one draw), smoke out (1 when a smoke particle is spawned at the
*> current position with the current velocity): the base tick, then when not removed r > age / lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 01 L-SMOKE                BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-R L-SMOKE.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE 0 TO L-SMOKE
     IF PC-REMOVED = 0
         COMPUTE WS-T = PC-AGE / PC-LIFETIME
         IF L-R > WS-T
             MOVE 1 TO L-SMOKE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P2-LAVA-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LAVA-SIZE.
*> 3.21 getQuadSize: USING PCL, partial, size out: quadSize * (1 - s * s), s = (age + partial) / lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-SIZE.
     COMPUTE WS-S = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     COMPUTE L-SIZE = PC-QUAD-SIZE * (1 - WS-S * WS-S)
     GOBACK.
 END PROGRAM P2-LAVA-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-VERT-NEW.
*> 3.22 SimpleVerticalParticle providers: USING PCL, x, y, z, vx, vy, vz, kind (0 pause_mob_growth: the sprite
*> floats down; 1 reset_mob_growth: up), draws (42-1 section 8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS.
     CALL "PVERT-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS
     GOBACK.
 END PROGRAM P2-VERT-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-GLOW-NEW.
*> 3.23 GlowParticle: USING PCL, x, y, z, vx, vy, vz, kind (0 glow, 1 wax_on, 2 wax_off, 3 electric_spark, 4
*> scrape), draws (Base7 7), engine draws E (glow: 1 and 2 the nextDouble pair, 3 the boolean, 4 the
*> lifetime double; wax: 1 the nextInt(30); electric_spark: 1 the nextInt(2); scrape: 1 the boolean, 2 the
*> nextInt(30); a boolean draw of 0.5 or more is true). Friction 0.96, speedUp, quadSize * 0.75, no collision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-ZERO-1              FLOAT-LONG VALUE 0.
 01 WS-ZERO-2              FLOAT-LONG VALUE 0.
 01 WS-ZERO-3              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-EDRAWS.
    05 L-E                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS L-EDRAWS.
     IF L-KIND = 0
         COMPUTE WS-BX = 0.5 - L-E(1)
         COMPUTE WS-BZ = 0.5 - L-E(2)
         CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-BX L-VY WS-BZ L-DRAWS
         CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     ELSE
         CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-ZERO-1 WS-ZERO-2 WS-ZERO-3 L-DRAWS
         CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     END-IF
     MOVE 0.96 TO PC-FRICTION
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     EVALUATE L-KIND
         WHEN 0
             IF L-E(3) >= 0.5
                 MOVE 0.6 TO PC-RCOL
                 MOVE 1.0 TO PC-GCOL
                 MOVE 0.8 TO PC-BCOL
             ELSE
                 MOVE 0.08 TO PC-RCOL
                 MOVE 0.4 TO PC-GCOL
                 MOVE 0.4 TO PC-BCOL
             END-IF
             COMPUTE PC-YD = PC-YD * 0.20000000298023224
             IF L-VX = 0 AND L-VZ = 0
                 COMPUTE PC-XD = PC-XD * 0.10000000149011612
                 COMPUTE PC-ZD = PC-ZD * 0.10000000149011612
             END-IF
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8 / (L-E(4) * 0.8 + 0.2))
         WHEN 1
             MOVE 0.91 TO PC-RCOL
             MOVE 0.55 TO PC-GCOL
             MOVE 0.08 TO PC-BCOL
             COMPUTE PC-XD = L-VX * 0.01 / 2
             COMPUTE PC-YD = L-VY * 0.01
             COMPUTE PC-ZD = L-VZ * 0.01 / 2
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-E(1) * 30) + 10
         WHEN 2
             MOVE 1.0 TO PC-RCOL
             MOVE 0.9 TO PC-GCOL
             MOVE 1.0 TO PC-BCOL
             COMPUTE PC-XD = L-VX * 0.01 / 2
             COMPUTE PC-YD = L-VY * 0.01
             COMPUTE PC-ZD = L-VZ * 0.01 / 2
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-E(1) * 30) + 10
         WHEN 3
             MOVE 1.0 TO PC-RCOL
             MOVE 0.9 TO PC-GCOL
             MOVE 1.0 TO PC-BCOL
             COMPUTE PC-XD = L-VX * 0.25
             COMPUTE PC-YD = L-VY * 0.25
             COMPUTE PC-ZD = L-VZ * 0.25
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-E(1) * 2) + 2
         WHEN OTHER
             IF L-E(1) >= 0.5
                 MOVE 0.29 TO PC-RCOL
                 MOVE 0.58 TO PC-GCOL
                 MOVE 0.51 TO PC-BCOL
             ELSE
                 MOVE 0.43 TO PC-RCOL
                 MOVE 0.77 TO PC-GCOL
                 MOVE 0.62 TO PC-BCOL
             END-IF
             COMPUTE PC-XD = L-VX * 0.01
             COMPUTE PC-YD = L-VY * 0.01
             COMPUTE PC-ZD = L-VZ * 0.01
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-E(2) * 30) + 10
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-GLOW-NEW.
