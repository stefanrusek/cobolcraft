*> Particles part 3, sections 5 to 8 (docs/protocol/42-particles-3-fluid-drip-water.md): bubbles, splashes and
*> water currents, suspended, glow and flying particles, squid ink, GlowParticle. Draws are passed in as tables
*> (see particles-42-2.cob); the fluid checks are the caller's results (in water, in a water source, in air).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-BUBBLE-NEW.
*> 5.1 BubbleParticle: USING PCL, x, y, z, vx, vy, vz, draws (1-2 base, 3 size, 4-6 velocity noise, 7 lifetime).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.02.
 01 WS-H                   FLOAT-LONG VALUE 0.02.
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
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(3) * 0.6 + 0.2)
     COMPUTE PC-XD = L-VX * 0.20000000298023224 + (L-DRAW(4) * 2 - 1) * 0.02
     COMPUTE PC-YD = L-VY * 0.20000000298023224 + (L-DRAW(5) * 2 - 1) * 0.02
     COMPUTE PC-ZD = L-VZ * 0.20000000298023224 + (L-DRAW(6) * 2 - 1) * 0.02
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8.0 / (L-DRAW(7) * 0.8 + 0.2))
     GOBACK.
 END PROGRAM P3-BUBBLE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-BUBBLE-TICK.
*> 5.1 tick: USING PCL, PCL-COLLIDERS, in water: previous position; lifetime - 1 removes at 0; yd + 0.002; move;
*> velocity * 0.85; removed unless in water. No age counter.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-WATER.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     SUBTRACT 1 FROM PC-LIFETIME
     IF PC-LIFETIME <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     ADD 0.002 TO PC-YD
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-XD = PC-XD * 0.8500000238418579
     COMPUTE PC-YD = PC-YD * 0.8500000238418579
     COMPUTE PC-ZD = PC-ZD * 0.8500000238418579
     IF L-WATER = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-BUBBLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-POP-NEW.
*> 5.2 BubblePopParticle: USING PCL, x, y, z, vx, vy, vz, draws (1-2 base): lifetime 4, gravity 0.008 (f32),
*> velocity assigned, sprite from age 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
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
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE 4 TO PC-LIFETIME
     MOVE 0.008 TO WS-F32
     MOVE WS-F32 TO PC-GRAVITY
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P3-POP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-POP-TICK.
*> 5.2 tick: USING PCL, PCL-COLLIDERS: previous position; age + 1, removed at age >= lifetime; yd - gravity;
*> move; sprite from age (5 frames). No friction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     ADD 1 TO PC-AGE
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     GOBACK.
 END PROGRAM P3-POP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-DROP-NEW.
*> 5.3 WaterDropParticle and SplashParticle: USING PCL, x, y, z, vx, vy, vz, splash (0 rain, 1 splash), draws
*> (1-7 the zero-bias velocity constructor and size, 8 yd, 9 lifetime): xd, zd * 0.3, yd = r * 0.2 + 0.1, box
*> 0.01, gravity 0.06 (splash 0.04); a splash with vy 0 and vx or vz not 0 takes (vx, 0.1, vz).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.01.
 01 WS-H                   FLOAT-LONG VALUE 0.01.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SPLASH               BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-SPLASH L-DRAWS.
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     COMPUTE PC-XD = PC-XD * 0.3
     COMPUTE PC-ZD = PC-ZD * 0.3
     COMPUTE PC-YD = L-DRAW(8) * 0.2 + 0.1
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     MOVE 0.06 TO WS-F32
     MOVE WS-F32 TO PC-GRAVITY
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8.0 / (L-DRAW(9) * 0.8 + 0.2))
     IF L-SPLASH NOT = 0
         MOVE 0.04 TO WS-F32
         MOVE WS-F32 TO PC-GRAVITY
         IF L-VY = 0 AND (L-VX NOT = 0 OR L-VZ NOT = 0)
             MOVE L-VX TO PC-XD
             MOVE 0.1 TO PC-YD
             MOVE L-VZ TO PC-ZD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3-DROP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-DROP-TICK.
*> 5.3 tick: USING PCL, PCL-COLLIDERS, r (the on-ground draw), d (max of the collision shape top at the
*> particle's local x and z and the fluid height, 0 for none), block y (int): previous position; lifetime - 1
*> removes at 0; yd - gravity; move; velocity * 0.98; on ground: removed when r < 0.5 and xd, zd * 0.7; then
*> removed when d > 0 and y < block y + d.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-BLOCK-Y              BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-R L-D L-BLOCK-Y.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     SUBTRACT 1 FROM PC-LIFETIME
     IF PC-LIFETIME <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-XD = PC-XD * 0.98
     COMPUTE PC-YD = PC-YD * 0.98
     COMPUTE PC-ZD = PC-ZD * 0.98
     IF PC-ON-GROUND NOT = 0
         IF L-R < 0.5
             MOVE 1 TO PC-REMOVED
         END-IF
         COMPUTE PC-XD = PC-XD * 0.7
         COMPUTE PC-ZD = PC-ZD * 0.7
     END-IF
     IF L-D > 0 AND PC-Y < L-BLOCK-Y + L-D
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-DROP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-WAKE-NEW.
*> 5.4 WakeParticle: USING PCL, x, y, z, vx, vy, vz, draws (as the water drop): box 0.01, lifetime (int)(8 / (r *
*> 0.8 + 0.2)), gravity 0, then the supplied velocity assigned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.01.
 01 WS-H                   FLOAT-LONG VALUE 0.01.
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
     CALL "P2-BASE7Z" USING PCL L-X L-Y L-Z L-DRAWS
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8.0 / (L-DRAW(9) * 0.8 + 0.2))
     MOVE 0 TO PC-SPRITE
     MOVE 0 TO PC-GRAVITY
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     GOBACK.
 END PROGRAM P3-WAKE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-WAKE-TICK.
*> 5.4 tick: USING PCL, PCL-COLLIDERS: i = 60 - lifetime; lifetime - 1 removes at 0; yd - gravity; move;
*> velocity * 0.98; the box i * 0.001; sprite (i % 4) * (n - 1) / 4 over 4 frames.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG VALUE 4.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     COMPUTE WS-I = 60 - PC-LIFETIME
     SUBTRACT 1 FROM PC-LIFETIME
     IF PC-LIFETIME <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-XD = PC-XD * 0.98
     COMPUTE PC-YD = PC-YD * 0.98
     COMPUTE PC-ZD = PC-ZD * 0.98
     COMPUTE WS-S1 = WS-I * 0.001
     MOVE WS-S1 TO WS-S2
     CALL "PCL-SET-SIZE" USING PCL WS-S1 WS-S2
     CALL "P3-FISHING-SPRITE" USING WS-I WS-N PC-SPRITE
     GOBACK.
 END PROGRAM P3-WAKE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-COLUMN-NEW.
*> 5.5 BubbleColumnUpParticle: USING PCL, x, y, z, vx, vy, vz, draws (1-2 base, 3 size, 4-6 noise, 7 lifetime):
*> gravity -0.125, friction 0.85, box 0.02, lifetime (int)(40 / (r * 0.8 + 0.2)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.02.
 01 WS-H                   FLOAT-LONG VALUE 0.02.
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
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     MOVE -0.125 TO PC-GRAVITY
     MOVE 0.85 TO PC-FRICTION
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(3) * 0.6 + 0.2)
     COMPUTE PC-XD = L-VX * 0.20000000298023224 + (L-DRAW(4) * 2 - 1) * 0.02
     COMPUTE PC-YD = L-VY * 0.20000000298023224 + (L-DRAW(5) * 2 - 1) * 0.02
     COMPUTE PC-ZD = L-VZ * 0.20000000298023224 + (L-DRAW(6) * 2 - 1) * 0.02
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(40.0 / (L-DRAW(7) * 0.8 + 0.2))
     GOBACK.
 END PROGRAM P3-COLUMN-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-COLUMN-TICK.
*> 5.5 tick: USING PCL, PCL-COLLIDERS, in water: the base tick, then removed unless in water.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS L-WATER.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF L-WATER = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-COLUMN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-CURRENT-NEW.
*> 5.6 WaterCurrentDownParticle: USING PCL, P3X, x, y, z, draws (1-2 base, 3 lifetime, 4 size): lifetime (int)(r *
*> 60) + 30, no collision, velocity (0, -0.05, 0), box 0.02, gravity 0.002 (stored), angle 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.02.
 01 WS-H                   FLOAT-LONG VALUE 0.02.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P3X L-X L-Y L-Z L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     INITIALIZE P3X
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-DRAW(3) * 60) + 30
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-XD
     MOVE -0.05 TO PC-YD
     MOVE 0 TO PC-ZD
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(4) * 0.6 + 0.2)
     MOVE 0.002 TO WS-F32
     MOVE WS-F32 TO PC-GRAVITY
     GOBACK.
 END PROGRAM P3-CURRENT-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-CURRENT-TICK.
*> 5.6 tick: USING PCL, P3X, in water: previous position; age + 1 (removed at age >= lifetime); xd += 0.6 cos(angle),
*> zd += 0.6 sin(angle) with the table functions; xd, zd * 0.07; move without collision; removed when not in water
*> or on the ground; angle + 0.08 (f32).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING PCL P3X L-WATER.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     ADD 1 TO PC-AGE
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
     END-IF
     CALL "P2-MTH-COS" USING X3-ANGLE WS-COS
     CALL "PENG-MTH-SIN" USING X3-ANGLE WS-SIN
     COMPUTE PC-XD = PC-XD + 0.6 * WS-COS
     COMPUTE PC-ZD = PC-ZD + 0.6 * WS-SIN
     COMPUTE PC-XD = PC-XD * 0.07
     COMPUTE PC-ZD = PC-ZD * 0.07
     COMPUTE WS-X = PC-X + PC-XD
     COMPUTE WS-Y = PC-Y + PC-YD
     COMPUTE WS-Z = PC-Z + PC-ZD
     CALL "PCL-SET-POS" USING PCL WS-X WS-Y WS-Z
     IF L-WATER = 0 OR PC-ON-GROUND NOT = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     MOVE X3-ANGLE TO WS-F32
     COMPUTE WS-F32 = WS-F32 + 0.08
     MOVE WS-F32 TO X3-ANGLE
     GOBACK.
 END PROGRAM P3-CURRENT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-UNDERWATER-NEW.
*> 6.1 SuspendedParticle (underwater): USING PCL, x, y, z, draws (1-2 base, 3 size, 4 lifetime): placed at y -
*> 0.125, box 0.01, lifetime (int)(16 / (r * 0.8 + 0.2)), no collision, friction 1.0, colour (0.4, 0.4, 0.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG VALUE 0.01.
 01 WS-H                   FLOAT-LONG VALUE 0.01.
 01 WS-R                   FLOAT-LONG VALUE 0.4.
 01 WS-G                   FLOAT-LONG VALUE 0.4.
 01 WS-B                   FLOAT-LONG VALUE 0.7.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     COMPUTE WS-Y = L-Y - 0.125
     CALL "P2-BASE2" USING PCL L-X WS-Y L-Z L-DRAWS
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(3) * 0.6 + 0.2)
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(16.0 / (L-DRAW(4) * 0.8 + 0.2))
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 1.0 TO PC-FRICTION
     MOVE 0 TO PC-GRAVITY
     CALL "PCL-SET-COLOR" USING PCL WS-R WS-G WS-B
     GOBACK.
 END PROGRAM P3-UNDERWATER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-DOLPHIN-NEW.
*> 6.2 dolphin: USING PCL, x, y, z, vx, vy, vz, draws (as the suspended-town class of part 2, kind 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 2.
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
     CALL "P2-TOWN-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ WS-KIND L-DRAWS
     GOBACK.
 END PROGRAM P3-DOLPHIN-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-NAUTILUS-NEW.
*> 6.3 nautilus: USING PCL, P2X, x, y, z, vx, vy, vz, draws (the short fly-towards constructor of part 2).
 DATA DIVISION.
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
     CALL "P2-FLY-NEW" USING PCL P2X L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     GOBACK.
 END PROGRAM P3-NAUTILUS-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-NAUTILUS-TICK.
*> 6.3 tick: USING PCL, P2X: t = 1 - age / lifetime, u = (1 - t)^4: the fly-towards tick of part 2.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP2X.
 PROCEDURE DIVISION USING PCL P2X.
     CALL "P2-FLY-TICK" USING PCL P2X
     GOBACK.
 END PROGRAM P3-NAUTILUS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LIGHT-ADD-T4.
*> 6.3 light: USING smooth light, age, lifetime, light out: addSmoothBlockEmission(light, (age / lifetime)^4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-AGE L-LIFETIME L-OUT.
     CALL "P2-FLY-LIGHT" USING L-LIGHT L-AGE L-LIFETIME L-OUT
     GOBACK.
 END PROGRAM P3-LIGHT-ADD-T4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-SULFUR-NEW.
*> 6.4 SulfurBubbleParticle: USING PCL, P3X, x, y, z, hx, hz (the packet's vx and vy), draws (1-2 base, 3-4 noise, 5
*> size): gravity -0.04, friction 0.85, box 0.02, xd, zd from the horizontal values, sizeStart 0.02 + 0.02 r,
*> lifetime the int maximum, yEnd = y + 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG VALUE 0.02.
 01 WS-H                   FLOAT-LONG VALUE 0.02.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P3X L-X L-Y L-Z L-HX L-HZ L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     INITIALIZE P3X
     MOVE -0.04 TO PC-GRAVITY
     MOVE 0.85 TO PC-FRICTION
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     COMPUTE PC-XD = L-HX * 0.20000000298023224 + (L-DRAW(3) * 2 - 1) * 0.02
     COMPUTE PC-ZD = L-HZ * 0.20000000298023224 + (L-DRAW(4) * 2 - 1) * 0.02
     COMPUTE X3-SIZE-START = 0.02 + 0.02 * L-DRAW(5)
     MOVE X3-SIZE-START TO PC-QUAD-SIZE
     MOVE 2147483647 TO PC-LIFETIME
     MOVE L-Y TO X3-Y-START
     COMPUTE X3-Y-END = L-Y + 3.0
     MOVE L-Y TO X3-Y-PREV
     GOBACK.
 END PROGRAM P3-SULFUR-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-SULFUR-TICK.
*> 6.4 tick: USING PCL, P3X, PCL-COLLIDERS, in a water source, noise (float, boolean, float, boolean; a boolean
*> of 0.5 or more is true): the base tick; removed unless in a water source, at y >= yEnd, at y <= yPrev; then
*> xd, zd += r * 0.003 * sign * 0.5; a horizontal move; quadSize grows to 0.15; yPrev = y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W1                  FLOAT-LONG.
 01 WS-W2                  FLOAT-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-SOURCE               BINARY-LONG.
 01 L-NOISES.
    05 L-NOISE             FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING PCL P3X PCL-COLLIDERS L-SOURCE L-NOISES.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     IF PC-REMOVED = 0 AND L-SOURCE = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     IF PC-REMOVED = 0 AND PC-Y >= X3-Y-END
         MOVE 1 TO PC-REMOVED
     END-IF
     IF PC-REMOVED = 0 AND PC-Y <= X3-Y-PREV
         MOVE 1 TO PC-REMOVED
     END-IF
     IF PC-REMOVED = 0
         MOVE -1 TO WS-SIGN
         IF L-NOISE(2) >= 0.5
             MOVE 1 TO WS-SIGN
         END-IF
         COMPUTE WS-W1 = L-NOISE(1) * 0.003 * WS-SIGN * 0.5
         MOVE -1 TO WS-SIGN
         IF L-NOISE(4) >= 0.5
             MOVE 1 TO WS-SIGN
         END-IF
         COMPUTE WS-W2 = L-NOISE(3) * 0.003 * WS-SIGN * 0.5
         COMPUTE PC-XD = PC-XD + WS-W1
         COMPUTE PC-ZD = PC-ZD + WS-W2
         CALL "PCL-MOVE" USING PCL PC-XD WS-ZERO PC-ZD PCL-COLLIDERS
         COMPUTE WS-T = (PC-Y - X3-Y-START) / (X3-Y-END - X3-Y-START)
         COMPUTE PC-QUAD-SIZE = X3-SIZE-START + WS-T * (0.15 - X3-SIZE-START)
         MOVE PC-Y TO X3-Y-PREV
     END-IF
     GOBACK.
 END PROGRAM P3-SULFUR-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INK-ARGB.
*> 7 providers: USING kind (0 squid_ink, 1 glow_squid_ink), argb out: 0xFF000000, or
*> ARGB.colorFromFloat(1.0, 0.2, 0.8, 0.6) through PART-COLOR-PACK (255, 51, 204, 153).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   COMP-2.
 01 WS-R                   COMP-2.
 01 WS-G                   COMP-2.
 01 WS-B                   COMP-2.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-KIND L-ARGB.
     IF L-KIND = 0
         COMPUTE L-ARGB = 255 * 16777216
     ELSE
         MOVE 1.0 TO WS-A
         MOVE 0.2 TO WS-R
         MOVE 0.8 TO WS-G
         MOVE 0.6 TO WS-B
         CALL "PART-COLOR-PACK" USING WS-A WS-R WS-G WS-B L-ARGB
     END-IF
     GOBACK.
 END PROGRAM P3-INK-ARGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INK-NEW.
*> 7 SquidInkParticle: USING PCL, PCLX, x, y, z, vx, vy, vz, argb, draws (1-2 the animated base, 3 lifetime):
*> friction 0.92, quadSize 0.5, alpha 1, colour from the argb channels, lifetime (int)(6 / (r * 0.8 + 0.2)), no
*> collision, velocity assigned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.
 01 WS-RGB                 BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-VX L-VY L-VZ L-ARGB L-DRAWS.
     CALL "PSA-NEW" USING PCL PCLX L-X L-Y L-Z WS-GRAVITY L-DRAWS
     MOVE 0.92 TO PC-FRICTION
     MOVE 0.5 TO PC-QUAD-SIZE
     MOVE 1.0 TO PC-ALPHA
     COMPUTE WS-RGB = FUNCTION MOD(L-ARGB, 16777216)
     CALL "PSA-SET-COLOR" USING PCL WS-RGB
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(6.0 / (L-DRAW(3) * 0.8 + 0.2))
     MOVE 0 TO PC-SPRITE
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     GOBACK.
 END PROGRAM P3-INK-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INK-TICK.
*> 7 tick: USING PCL, PCLX, PCL-COLLIDERS, in air: the animated tick (8 sprites); when not removed, and the block
*> at the particle is air, yd - 0.0074.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS L-AIR.
     CALL "PSA-TICK" USING PCL PCLX PCL-COLLIDERS WS-N
     IF PC-REMOVED = 0 AND L-AIR NOT = 0
         COMPUTE PC-YD = PC-YD - 0.007400000002235174
     END-IF
     GOBACK.
 END PROGRAM P3-INK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-GLOWCLASS-NEW.
*> 8 GlowParticle: USING PCL, x, y, z, vx, vy, vz, draws (Base7 with the supplied velocity): friction 0.96,
*> speedUp, quadSize * 0.75, no collision, sprite from age 0.
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
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     MOVE 0.96 TO PC-FRICTION
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75
     MOVE 0 TO PC-HAS-PHYSICS
     MOVE 0 TO PC-SPRITE
     GOBACK.
 END PROGRAM P3-GLOWCLASS-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-GLOW-LIGHT.
*> 8 light: USING PCL, partial, smooth light, light out: addSmoothBlockEmission(light, (age + partial) / lifetime).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-LIGHT L-OUT.
     CALL "P2-FLAME-LIGHT" USING PCL L-PARTIAL L-LIGHT L-OUT
     GOBACK.
 END PROGRAM P3-GLOW-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-GLOW-TICK.
*> 8 tick: USING PCL, PCL-COLLIDERS: the base tick, then the sprite from age (one frame).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL WS-N
     GOBACK.
 END PROGRAM P3-GLOW-TICK.
