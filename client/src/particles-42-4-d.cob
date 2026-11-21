*> Particles part 4 (docs/protocol/42-particles-4-block-item-dust-ambient.md), sections 10 to 15: the suspended particles, the
*> snowflake, the firefly, the glow family, the ambient-particle attribute and the emission helpers of 15. Draws are
*> passed in as tables (see particles-42-4.cob).
*>
*> Entry points for the integrator (inputs):
*>   P4-TOWN-NEW PCL x y z vx vy vz kind(0 mycelium, 1 egg_crack) draws(10), P4-TOWN-TICK PCL PCL-COLLIDERS;
*>   P4-SPORE-ARGS kind g1 g2 g3 then P4-SPORE-NEW PCL x y z vx vy vz draws(9) and P4-SPORE-FINISH PCL kind r;
*>   P4-SNOW-NEW PCL x y z vx vy vz draws(8), P4-SNOW-TICK PCL PCL-COLLIDERS sprite-count;
*>   P4-FIREFLY-ARGS, P4-FIREFLY-NEW PCL P4X x y z vx vy vz draws(7) lifetime-draw, P4-FIREFLY-TICK PCL air d0 d1 d2 d3
*>     PCL-COLLIDERS, P4-FIREFLY-LIGHT PCL partial light;
*>   P4-GLOW-NEW PCL x y z vx vy vz kind draws edraws, P4-GLOW-LIGHT PCL base-light partial light;
*>   P4-LEVEL-EVENT event data: particle id, mode, count range; P4-AMBIENT-LOOKUP biome: particle name, probability;
*>   P4-FACE-PARTICLE, P4-AXIS-PARTICLE, P4-SPAWN-PARTICLE, P4-UNIFORM-INT: the ParticleUtils helpers of 15.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TOWN-NEW.
*> Section 10.1 SuspendedTownParticle: USING PCL, x, y, z, vx, vy, vz, kind (0 mycelium, 1 egg_crack), draws (1-7 base
*> constructor with a velocity, 8 grey, 9 quad size, 10 lifetime). grey = f * 0.1 + 0.2, box 0.02, quadSize *
*> (draw * 0.6 + 0.5), velocity * 0.019999999552965164, lifetime (int)(20 / (draw * 0.8 + 0.2)), no collision;
*> egg_crack sets the colour 1, 1, 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S1                  FLOAT-LONG VALUE 0.02.
 01 WS-S2                  FLOAT-LONG VALUE 0.02.
 01 WS-20                  COMP-2 VALUE 20.
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
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     COMPUTE WS-C = L-DRAW(8) * 0.1 + 0.2
     MOVE WS-C TO PC-RCOL PC-GCOL PC-BCOL
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(9) * 0.6 + 0.5)
     COMPUTE PC-XD = PC-XD * 0.019999999552965164
     COMPUTE PC-YD = PC-YD * 0.019999999552965164
     COMPUTE PC-ZD = PC-ZD * 0.019999999552965164
     CALL "P4-LIFE-BASE" USING WS-20 L-DRAW(10) PC-LIFETIME
     MOVE 0 TO PC-HAS-PHYSICS
     IF L-KIND = 1
         MOVE 1.0 TO PC-RCOL PC-GCOL PC-BCOL
     END-IF
     GOBACK.
 END PROGRAM P4-TOWN-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TOWN-TICK.
*> Section 10.1 tick: USING PCL, PCL-COLLIDERS: old position = position, an old lifetime <= 0 removes, else lifetime - 1,
*> move without collision, velocity * 0.99 (the same tick as P2-TOWN-TICK; age is not used).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     CALL "P2-TOWN-TICK" USING PCL PCL-COLLIDERS
     GOBACK.
 END PROGRAM P4-TOWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPORE-NEW.
*> Section 10.2 SuspendedParticle with a velocity: USING PCL, x, y, z, vx, vy, vz, draws (1-7 base, 8 quad factor, 9
*> lifetime). Starts at y - 0.125, box 0.01, quadSize * (draw * 0.6 + 0.6), lifetime (int)(16 / (draw * 0.8 + 0.2)),
*> no physics, friction 1, gravity 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG VALUE 0.01.
 01 WS-S2                  FLOAT-LONG VALUE 0.01.
 01 WS-16                  COMP-2 VALUE 16.
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
     COMPUTE WS-Y = L-Y - 0.125
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X WS-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(8) * 0.6 + 0.6)
     CALL "P4-LIFE-BASE" USING WS-16 L-DRAW(9) PC-LIFETIME
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-GRAVITY
     GOBACK.
 END PROGRAM P4-SPORE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPORE-ARGS.
*> Section 10.2 providers: USING kind (0 crimson_spore, 1 warped_spore, 2 spore_blossom_air), three draws (the gaussians
*> g1 g2 g3 for crimson, the floats r1 r2 for warped), the velocity argument vx, vy, vz out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-G1                   FLOAT-LONG.
 01 L-G2                   FLOAT-LONG.
 01 L-G3                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-G1 L-G2 L-G3 L-VX L-VY L-VZ.
     EVALUATE L-KIND
         WHEN 0
             COMPUTE L-VX = L-G1 * 0.0000009999999974752427
             COMPUTE L-VY = L-G2 * 0.00009999999747378752
             COMPUTE L-VZ = L-G3 * 0.0000009999999974752427
         WHEN 1
             MOVE 0 TO L-VX L-VZ
             COMPUTE L-VY = (L-G1 * -1.9) * L-G2 * 0.1
         WHEN OTHER
             MOVE 0 TO L-VX L-VZ
             MOVE -0.800000011920929 TO L-VY
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-SPORE-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPORE-FINISH.
*> Section 10.2 after construction: USING PCL, kind (0 crimson, 1 warped, 2 spore_blossom_air), draw r (the blossom
*> lifetime nextInt: randomBetweenInclusive(500, 1000) = 500 + floor(r * 501)): colours, the warped box 0.001 and the
*> blossom lifetime and gravity 0.01.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S1                  FLOAT-LONG VALUE 0.001.
 01 WS-S2                  FLOAT-LONG VALUE 0.001.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-KIND                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-KIND L-R.
     EVALUATE L-KIND
         WHEN 0
             MOVE 0.9 TO PC-RCOL
             MOVE 0.4 TO PC-GCOL
             MOVE 0.5 TO PC-BCOL
         WHEN 1
             MOVE 0.1 TO PC-RCOL PC-GCOL
             MOVE 0.3 TO PC-BCOL
             CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
         WHEN OTHER
             COMPUTE PC-LIFETIME = 500 + FUNCTION INTEGER-PART(L-R * 501)
             MOVE 0.01 TO PC-GRAVITY
             MOVE 0.32 TO PC-RCOL
             MOVE 0.5 TO PC-GCOL
             MOVE 0.22 TO PC-BCOL
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-SPORE-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPORE-LIMIT.
*> Section 10.2: USING registry id, live-particle limit out (1000 for spore_blossom_air id 97, else 0: no limit of its own).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-LIMIT.
     MOVE 0 TO L-LIMIT
     IF L-ID = 97
         MOVE 1000 TO L-LIMIT
     END-IF
     GOBACK.
 END PROGRAM P4-SPORE-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SNOW-NEW.
*> Section 11 SnowflakeParticle: USING PCL, x, y, z, vx, vy, vz, draws (1 lifetime, 2 quad size, 3-5 velocity, 6-7 the
*> assigned quad size, 8 lifetime). gravity 0.225, friction 1, velocity = supplied + (draw * 2 - 1) * 0.05, quadSize =
*> 0.1 * (r1 * r2 + 1), lifetime (int)(16 / (draw * 0.8 + 0.2)) + 2, colour (0.923, 0.964, 0.999).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-16                  COMP-2 VALUE 16.
 01 WS-BASE                BINARY-LONG.
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
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     MOVE 0.225 TO PC-GRAVITY
     MOVE 1.0 TO PC-FRICTION
     COMPUTE PC-XD = L-VX + (L-DRAW(3) * 2 - 1) * 0.05
     COMPUTE PC-YD = L-VY + (L-DRAW(4) * 2 - 1) * 0.05
     COMPUTE PC-ZD = L-VZ + (L-DRAW(5) * 2 - 1) * 0.05
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-DRAW(6) * L-DRAW(7) * 1.0 + 1.0)
     CALL "P4-LIFE-BASE" USING WS-16 L-DRAW(8) WS-BASE
     COMPUTE PC-LIFETIME = WS-BASE + 2
     MOVE 0 TO PC-SPRITE
     MOVE 0.923 TO PC-RCOL
     MOVE 0.964 TO PC-GCOL
     MOVE 0.999 TO PC-BCOL
     GOBACK.
 END PROGRAM P4-SNOW-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SNOW-TICK.
*> Section 11 tick: USING PCL, PCL-COLLIDERS, sprite count: the base tick, the sprite from age, then the drag
*> xd * 0.949999988079071, yd * 0.8999999761581421, zd * 0.949999988079071.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-N.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     COMPUTE PC-XD = PC-XD * 0.949999988079071
     COMPUTE PC-YD = PC-YD * 0.8999999761581421
     COMPUTE PC-ZD = PC-ZD * 0.949999988079071
     GOBACK.
 END PROGRAM P4-SNOW-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FADE.
*> Section 12 fade(p, a, b): USING p, a, b, result out: p >= 1 - a gives (1 - p) / a, else p <= b gives p / b, else 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-P L-A L-B L-OUT.
     EVALUATE TRUE
         WHEN L-P >= 1 - L-A
             COMPUTE L-OUT = (1 - L-P) / L-A
         WHEN L-P <= L-B
             COMPUTE L-OUT = L-P / L-B
         WHEN OTHER
             MOVE 1.0 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-FADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FIREFLY-ARGS.
*> Section 12 provider steps 1 to 3: USING nextDouble r1, nextBoolean b (0/1), call vy, nextDouble r2, xArg, yArg, zArg out:
*> xArg = 0.5 - r1, yArg = vy or -vy, zArg = 0.5 - r2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-B                    BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-B L-VY L-R2 L-X L-Y L-Z.
     COMPUTE L-X = 0.5 - L-R1
     IF L-B NOT = 0
         MOVE L-VY TO L-Y
     ELSE
         COMPUTE L-Y = 0 - L-VY
     END-IF
     COMPUTE L-Z = 0.5 - L-R2
     GOBACK.
 END PROGRAM P4-FIREFLY-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FIREFLY-NEW.
*> Section 12 constructor and provider steps 6 to 8: USING PCL, P4X, x, y, z, vx, vy, vz, draws (1-7 the velocity base),
*> lifetime draw (nextIntBetweenInclusive(200, 300) = 200 + floor(r * 101)). speedUp, friction 0.96, quadSize * 0.75,
*> velocity * 0.800000011920929, layer TRANSLUCENT, scale(1.5), alpha 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 1.5.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS L-R.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 1 TO PC-SPEED-UP
     MOVE 0.96 TO PC-FRICTION
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     COMPUTE PC-YD = PC-YD * 0.800000011920929
     COMPUTE PC-XD = PC-XD * 0.800000011920929
     COMPUTE PC-ZD = PC-ZD * 0.800000011920929
     MOVE 1 TO X4-LAYER
     COMPUTE PC-LIFETIME = 200 + FUNCTION INTEGER-PART(L-R * 101)
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     MOVE 0 TO PC-ALPHA
     GOBACK.
 END PROGRAM P4-FIREFLY-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FIREFLY-LIGHT.
*> Section 12 light: USING PCL, partial, light out = (int)(255 * fade(progress, 0.1, 0.3)), progress = clamp((age +
*> partial) / lifetime, 0, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG VALUE 0.1.
 01 WS-B                   FLOAT-LONG VALUE 0.3.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-LIGHT.
     COMPUTE WS-P = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     IF WS-P < 0
         MOVE 0 TO WS-P
     END-IF
     IF WS-P > 1
         MOVE 1 TO WS-P
     END-IF
     CALL "P4-FADE" USING WS-P WS-A WS-B WS-F
     COMPUTE L-LIGHT = FUNCTION INTEGER-PART(255 * WS-F)
     GOBACK.
 END PROGRAM P4-FIREFLY-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FIREFLY-TICK.
*> Section 12 tick: USING PCL, block at the position is air (0/1), draws d0 (nextFloat) and d1, d2, d3 (the three velocity
*> floats), PCL-COLLIDERS. The base tick; a non-air block removes; alpha = fade(age / lifetime, 0.3, 0.5); a draw above
*> 0.95 or age 1 sets the velocity to (-0.05 + 0.1 * d).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG VALUE 0.3.
 01 WS-B                   FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-AIR                  BINARY-LONG.
 01 L-D0                   FLOAT-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-AIR L-D0 L-D1 L-D2 L-D3 PCL-COLLIDERS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF PC-REMOVED NOT = 0
         GOBACK
     END-IF
     IF L-AIR = 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-P = PC-AGE / PC-LIFETIME
     CALL "P4-FADE" USING WS-P WS-A WS-B PC-ALPHA
     IF L-D0 > 0.95 OR PC-AGE = 1
         COMPUTE PC-XD = -0.05 + 0.1 * L-D1
         COMPUTE PC-YD = -0.05 + 0.1 * L-D2
         COMPUTE PC-ZD = -0.05 + 0.1 * L-D3
     END-IF
     GOBACK.
 END PROGRAM P4-FIREFLY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-GLOW-NEW.
*> Section 13 GlowParticle and the providers of 13.2: USING PCL, x, y, z, vx, vy, vz, kind (0 glow, 1 wax_on, 2 wax_off,
*> 3 electric_spark, 4 scrape), draws, engine draws (the layout of P2-GLOW-NEW).
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
 01 L-EDRAWS.
    05 L-E                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS L-EDRAWS.
     CALL "P2-GLOW-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-KIND L-DRAWS L-EDRAWS
     GOBACK.
 END PROGRAM P4-GLOW-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-GLOW-LIGHT.
*> Section 13.1 getLightCoords: USING PCL, base smooth light, partial, light out: addSmoothBlockEmission(base, (age +
*> partial) / lifetime): the block part grows to at most 240, the sky part is unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-BASE                 BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-BASE L-PARTIAL L-LIGHT.
     COMPUTE WS-T = (PC-AGE + L-PARTIAL) / PC-LIFETIME
     CALL "P2-LIGHT-EMIT" USING L-BASE WS-T L-LIGHT
     GOBACK.
 END PROGRAM P4-GLOW-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-LEVEL-EVENT.
*> Section 13.3: USING level event id, event data, particle registry id out, mode out (0 on the block faces, 1 along an
*> axis), minimum and maximum count out (UniformInt), found out (0/1). 3002 along an axis (spread 0.125) when the data is
*> 0 to 2, else the faces; 3003 wax_on, 3004 wax_off, 3005 scrape, 3009 egg_crack.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-DATA L-ID L-MODE L-MIN L-MAX L-FOUND.
     MOVE 1 TO L-FOUND
     MOVE 0 TO L-MODE
     MOVE 3 TO L-MIN
     MOVE 5 TO L-MAX
     EVALUATE L-EVENT
         WHEN 3003
             MOVE 111 TO L-ID
         WHEN 3004
             MOVE 112 TO L-ID
         WHEN 3005
             MOVE 114 TO L-ID
         WHEN 3002
             MOVE 113 TO L-ID
             IF L-DATA >= 0 AND L-DATA < 3
                 MOVE 1 TO L-MODE
                 MOVE 10 TO L-MIN
                 MOVE 19 TO L-MAX
             END-IF
         WHEN 3009
             MOVE 116 TO L-ID
             MOVE 6 TO L-MAX
         WHEN OTHER
             MOVE 0 TO L-FOUND L-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-LEVEL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-COUNT.
*> Section 14: USING count out (the four biomes of the shipped data that set the attribute).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 4 TO L-COUNT
     GOBACK.
 END PROGRAM P4-AMBIENT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-LOOKUP.
*> Section 14 table: USING biome name (PIC X(32), no namespace), particle name out, probability out, found out (0 for any
*> other biome: the empty list).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BIOME                PIC X(32).
 01 L-PARTICLE             PIC X(32).
 01 L-PROBABILITY          FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-PARTICLE L-PROBABILITY L-FOUND.
     MOVE SPACES TO L-PARTICLE
     MOVE 0 TO L-PROBABILITY
     MOVE 1 TO L-FOUND
     EVALUATE L-BIOME
         WHEN "soul_sand_valley"
             MOVE "ash" TO L-PARTICLE
             MOVE 0.00625 TO L-PROBABILITY
         WHEN "basalt_deltas"
             MOVE "white_ash" TO L-PARTICLE
             MOVE 0.118093334 TO L-PROBABILITY
         WHEN "crimson_forest"
             MOVE "crimson_spore" TO L-PARTICLE
             MOVE 0.025 TO L-PROBABILITY
         WHEN "warped_forest"
             MOVE "warped_spore" TO L-PARTICLE
             MOVE 0.01428 TO L-PROBABILITY
         WHEN OTHER
             MOVE 0 TO L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-AMBIENT-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-CAN-SPAWN.
*> Section 14 step 1: USING nextFloat draw, probability, spawn out: true when draw <= probability.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PROBABILITY          FLOAT-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PROBABILITY L-SPAWN.
     MOVE 0 TO L-SPAWN
     IF L-DRAW <= L-PROBABILITY
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM P4-AMBIENT-CAN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-APPLIES.
*> Section 14: USING collision shape is a full block (0/1), applies out: only cells that are not full blocks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FULL                 BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 PROCEDURE DIVISION USING L-FULL L-APPLIES.
     MOVE 1 TO L-APPLIES
     IF L-FULL NOT = 0
         MOVE 0 TO L-APPLIES
     END-IF
     GOBACK.
 END PROGRAM P4-AMBIENT-APPLIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-POS.
*> Section 14 step 2: USING block position (three integers), three nextDouble draws (x, y, z), position out = pos + draw.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-OUT.
     COMPUTE L-O(1) = L-PP(1) + L-UU(1)
     COMPUTE L-O(2) = L-PP(2) + L-UU(2)
     COMPUTE L-O(3) = L-PP(3) + L-UU(3)
     GOBACK.
 END PROGRAM P4-AMBIENT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-RATE.
*> Section 14: USING probability, expected spawns per tick out = 1334 * probability (all samples in non-full cells).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROBABILITY          FLOAT-LONG.
 01 L-RATE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-PROBABILITY L-RATE.
     COMPUTE L-RATE = 1334 * L-PROBABILITY
     GOBACK.
 END PROGRAM P4-AMBIENT-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AMBIENT-ID.
*> Section 14: USING id out (PIC X(40): minecraft:visual/ambient_particles).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   PIC X(40).
 PROCEDURE DIVISION USING L-ID.
     MOVE "minecraft:visual/ambient_particles" TO L-ID
     GOBACK.
 END PROGRAM P4-AMBIENT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPAWN-BELOW-INT.
*> Section 15.2 spawnParticleBelow with an integer block position: USING block position (three integers), nextDouble x,
*> nextDouble z, position out (x + rx, y - 0.05, z + rz).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-RX                   FLOAT-LONG.
 01 L-RZ                   FLOAT-LONG.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-RX L-RZ L-OUT.
     COMPUTE L-O(1) = L-PP(1) + L-RX
     COMPUTE L-O(2) = L-PP(2) - 0.05
     COMPUTE L-O(3) = L-PP(3) + L-RZ
     GOBACK.
 END PROGRAM P4-SPAWN-BELOW-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SPAWN-PARTICLE.
*> Section 15.3 one particle of spawnParticles: USING block position (three integers), spread, yExtent, allowInAir (0/1), the
*> block below the particle position is air (0/1), gaussians (three), nextDouble draws (x, y, z), position out, velocity
*> out, added out (0 when skipped: not in the air and air below; the draws were taken). velocity = gaussian * 0.02, x =
*> pos.x + (0.5 - spread) + draw * spread * 2, y = pos.y + draw * yExtent, z likewise.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-SPREAD               FLOAT-LONG.
 01 L-YEXT                 FLOAT-LONG.
 01 L-ALLOW                BINARY-LONG.
 01 L-AIR-BELOW            BINARY-LONG.
 01 L-G.
    05 L-GG                FLOAT-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-VEL.
    05 L-V                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-ADDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-SPREAD L-YEXT L-ALLOW L-AIR-BELOW L-G L-U L-POS L-VEL L-ADDED.
     COMPUTE L-V(1) = L-GG(1) * 0.02
     COMPUTE L-V(2) = L-GG(2) * 0.02
     COMPUTE L-V(3) = L-GG(3) * 0.02
     COMPUTE L-O(1) = L-PP(1) + (0.5 - L-SPREAD) + L-UU(1) * L-SPREAD * 2.0
     COMPUTE L-O(2) = L-PP(2) + L-UU(2) * L-YEXT
     COMPUTE L-O(3) = L-PP(3) + (0.5 - L-SPREAD) + L-UU(3) * L-SPREAD * 2.0
     MOVE 1 TO L-ADDED
     IF L-ALLOW = 0 AND L-AIR-BELOW NOT = 0
         MOVE 0 TO L-ADDED
     END-IF
     GOBACK.
 END PROGRAM P4-SPAWN-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-IN-BLOCK-EXTENT.
*> Section 15.3 spawnParticleInBlock: USING block at pos is air (0/1), the maximum y of the block shape, yExtent out (1.0
*> for air, else the maximum y).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-AIR L-MAXY L-OUT.
     IF L-AIR NOT = 0
         MOVE 1.0 TO L-OUT
     ELSE
         MOVE L-MAXY TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM P4-IN-BLOCK-EXTENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FACE-STEP.
*> Section 15.4 Direction.values() order (0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST): USING face, step out (x, y, z).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-STEP.
    05 L-S                 BINARY-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-FACE L-STEP.
     MOVE 0 TO L-S(1) L-S(2) L-S(3)
     EVALUATE L-FACE
         WHEN 0
             MOVE -1 TO L-S(2)
         WHEN 1
             MOVE 1 TO L-S(2)
         WHEN 2
             MOVE -1 TO L-S(3)
         WHEN 3
             MOVE 1 TO L-S(3)
         WHEN 4
             MOVE -1 TO L-S(1)
         WHEN OTHER
             MOVE 1 TO L-S(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-FACE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-FACE-PARTICLE.
*> Section 15.4 spawnParticleOnBlockFace and spawnParticleOnFace: USING block position (three integers), face, speed draws
*> (three nextDouble, each Mth.nextDouble(-0.5, 0.5) = draw - 0.5), position draws (nextDouble, consumed in the order
*> x, y, z only on the axes whose step is 0), position out, velocity out (the speed on the axes with step 0, else 0),
*> draws consumed out. The position is the block centre plus the offset, or step * 0.55 on the face axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-FACE                 BINARY-LONG.
 01 L-SPEED.
    05 L-SD                FLOAT-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-VEL.
    05 L-V                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-FACE L-SPEED L-U L-POS L-VEL L-USED.
     CALL "P4-FACE-STEP" USING L-FACE WS-STEP
     MOVE 0 TO L-USED
     MOVE 0 TO WS-K
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         IF WS-S(WS-A) = 0
             ADD 1 TO WS-K
             ADD 1 TO L-USED
             COMPUTE L-O(WS-A) = L-PP(WS-A) + 0.5 + (L-UU(WS-K) - 0.5)
             COMPUTE L-V(WS-A) = L-SD(WS-A) - 0.5
         ELSE
             COMPUTE L-O(WS-A) = L-PP(WS-A) + 0.5 + WS-S(WS-A) * 0.55
             MOVE 0 TO L-V(WS-A)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P4-FACE-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-AXIS-PARTICLE.
*> Section 15.4 spawnParticlesAlongAxis, one particle: USING block position (three integers), chosen axis (0 x, 1 y, 2 z),
*> spread, position draws (three nextDouble x, y, z), velocity draw (nextDouble), position out, velocity out. Each draw is
*> Mth.nextDouble(-1, 1) = 2 * draw - 1; the coordinate is the centre + u * k (k = 0.5 on the axis, else the spread); only
*> the chosen axis has a velocity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-K                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                BINARY-LONG OCCURS 3 TIMES.
 01 L-AXIS                 BINARY-LONG.
 01 L-SPREAD               FLOAT-LONG.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-VD                   FLOAT-LONG.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-VEL.
    05 L-V                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-AXIS L-SPREAD L-U L-VD L-POS L-VEL.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         IF WS-A = L-AXIS + 1
             MOVE 0.5 TO WS-K
             COMPUTE L-V(WS-A) = 2 * L-VD - 1
         ELSE
             MOVE L-SPREAD TO WS-K
             MOVE 0 TO L-V(WS-A)
         END-IF
         COMPUTE L-O(WS-A) = L-PP(WS-A) + 0.5 + (2 * L-UU(WS-A) - 1) * WS-K
     END-PERFORM
     GOBACK.
 END PROGRAM P4-AXIS-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-UNIFORM-INT.
*> Section 15.4 UniformInt(min, max).sample: USING minimum, maximum, draw r (nextInt(max - min + 1) as r), value out =
*> min + floor(r * (max - min + 1)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN L-MAX L-R L-VALUE.
     COMPUTE L-VALUE = L-MIN + FUNCTION INTEGER-PART(L-R * (L-MAX - L-MIN + 1))
     GOBACK.
 END PROGRAM P4-UNIFORM-INT.
