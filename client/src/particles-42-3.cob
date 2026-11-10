*> Particles part 3 (docs/protocol/42-particles-3-fluid-drip-water.md): section 1 the shared facts, section 2 the
*> registry table, section 3 the drip family. Draws are passed in as tables (see particles-42-2.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-PARTICLE-DEFAULTS.
*> Section 1: USING PCL, x, y, z: the field defaults of Particle (hasPhysics, 0.2 box, friction 0.98, gravity 0).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z.
     CALL "PCL-INIT" USING PCL L-X L-Y L-Z
     GOBACK.
 END PROGRAM P3-PARTICLE-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LIFETIME-4ARG.
*> Section 1: USING draw, lifetime out: (int)(4.0f / (r * 0.9f + 0.1f)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-LIFETIME             BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-LIFETIME.
     CALL "PCL-LIFETIME" USING L-DRAW L-LIFETIME
     GOBACK.
 END PROGRAM P3-LIFETIME-4ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-RANDOM-BETWEEN.
*> Section 1 and 3.5: Mth.randomBetween in f32: USING draw (nextFloat), a, b, result out = r * (b - a) + a.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DRAW L-A L-B L-OUT.
     COMPUTE WS-F32 = L-DRAW * (L-B - L-A) + L-A
     MOVE WS-F32 TO L-OUT
     GOBACK.
 END PROGRAM P3-RANDOM-BETWEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LIGHT-ADD.
*> Section 1 and 6.3 addSmoothBlockEmission: USING smooth light, t, light out: the block channel + floor(clamp(t) * 240),
*> capped at 240, the sky unchanged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-T                    FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-T L-OUT.
     CALL "P2-LIGHT-EMIT" USING L-LIGHT L-T L-OUT
     GOBACK.
 END PROGRAM P3-LIGHT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LIFETIME-ALPHA-OPAQUE.
*> Section 1: USING start alpha, end alpha, opaque out: opaque when both are 1 or more.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LAYER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SA                   FLOAT-LONG.
 01 L-EA                   FLOAT-LONG.
 01 L-OPAQUE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SA L-EA L-OPAQUE.
     CALL "P2-LIFE-LAYER" USING L-SA L-EA WS-LAYER
     MOVE 0 TO L-OPAQUE
     IF WS-LAYER = 0
         MOVE 1 TO L-OPAQUE
     END-IF
     GOBACK.
 END PROGRAM P3-LIFETIME-ALPHA-OPAQUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-SPRITE-GET.
*> Section 2: get(random): USING frame count, draw, index out: one nextInt(n) draw even when n is 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-DRAW L-INDEX.
     CALL "PSET-RANDOM" USING L-N L-DRAW L-INDEX
     GOBACK.
 END PROGRAM P3-SPRITE-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-FISHING-SPRITE.
*> Section 2 and 5.4: USING i (60 - lifetime), frame count, index out = (i % 4) * (n - 1) / 4 (integer).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-N L-INDEX.
     COMPUTE WS-M = FUNCTION MOD(L-I, 4)
     CALL "PCL-SPRITE-INDEX" USING WS-M WS-FOUR L-N L-INDEX
     GOBACK.
 END PROGRAM P3-FISHING-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INDEX-COUNT.
*> Section 2: USING count out (31 rows).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 31 TO L-COUNT
     GOBACK.
 END PROGRAM P3-INDEX-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INDEX-ROW.
*> Section 2: USING row (1 to 31), P3IX out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP3TAB.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY CLP3IX.
 PROCEDURE DIVISION USING L-ROW P3IX.
     INITIALIZE P3IX
     IF L-ROW >= 1 AND L-ROW <= 31
         MOVE 1 TO P3-FOUND
         MOVE R-ID(L-ROW) TO P3-ID
         MOVE R-LAYER(L-ROW) TO P3-LAYER
         MOVE R-PICK(L-ROW) TO P3-PICK
         MOVE R-OVR(L-ROW) TO P3-OVR
         MOVE R-FRAMES(L-ROW) TO P3-FRAMES
         MOVE R-PROVIDER(L-ROW) TO P3-PROVIDER
         MOVE R-CLASS(L-ROW) TO P3-CLASS
         MOVE R-SECTION(L-ROW) TO P3-SECTION
     END-IF
     GOBACK.
 END PROGRAM P3-INDEX-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-INDEX.
*> Section 2: USING type name, P3IX out (P3-FOUND 0 when unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP3TAB.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 COPY CLP3IX.
 PROCEDURE DIVISION USING L-TYPE P3IX.
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31 OR WS-HIT NOT = 0
         IF R-NAME(WS-I) = L-TYPE
             MOVE WS-I TO WS-HIT
         END-IF
     END-PERFORM
     IF WS-HIT = 0
         INITIALIZE P3IX
     ELSE
         CALL "P3-INDEX-ROW" USING WS-HIT P3IX
     END-IF
     GOBACK.
 END PROGRAM P3-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-DRIP-BASE.
*> 3.1 DripParticle: USING PCL, x, y, z, draws (the lifetime draw and the quadSize draw): box 0.01, gravity
*> 0.06 (f32), velocity zero (never taken from the emitter).
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
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-DRAWS.
     CALL "P2-BASE2" USING PCL L-X L-Y L-Z L-DRAWS
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     MOVE 0.06 TO WS-F32
     MOVE WS-F32 TO PC-GRAVITY
     GOBACK.
 END PROGRAM P3-DRIP-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-SET-DRIP-COLOR.
*> 3.3 helper: USING PCL, red, green, blue.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-R L-G L-B.
     CALL "PCL-SET-COLOR" USING PCL L-R L-G L-B
     GOBACK.
 END PROGRAM P3-SET-DRIP-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-HANG-NEW.
*> 3.2 and 3.3 DripHangParticle and its providers: USING PCL, P3X, kind (0 dripping_lava, 1 dripping_water, 2
*> dripping_honey, 3 dripping_obsidian_tear, 4 dripping_dripstone_lava, 5 dripping_dripstone_water), x, y, z,
*> draws: gravity * 0.02 (f32), lifetime 40; honey and obsidian also gravity * 0.01 and lifetime 100.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P3X L-KIND L-X L-Y L-Z L-DRAWS.
     CALL "P3-DRIP-BASE" USING PCL L-X L-Y L-Z L-DRAWS
     INITIALIZE P3X
     MOVE PC-GRAVITY TO WS-F32
     COMPUTE WS-F32 = WS-F32 * 0.02
     MOVE WS-F32 TO PC-GRAVITY
     MOVE 40 TO PC-LIFETIME
     EVALUATE L-KIND
         WHEN 0
             MOVE 2 TO X3-FLUID
             MOVE 17 TO X3-NEXT
         WHEN 1
             MOVE 1 TO X3-FLUID
             MOVE 20 TO X3-NEXT
             MOVE 0.2 TO WS-C1
             MOVE 0.3 TO WS-C2
             MOVE 1.0 TO WS-C3
             CALL "P3-SET-DRIP-COLOR" USING PCL WS-C1 WS-C2 WS-C3
         WHEN 2
             MOVE 90 TO X3-NEXT
             MOVE PC-GRAVITY TO WS-F32
             COMPUTE WS-F32 = WS-F32 * 0.01
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 100 TO PC-LIFETIME
             MOVE 0.622 TO WS-C1
             MOVE 0.508 TO WS-C2
             MOVE 0.082 TO WS-C3
             CALL "P3-SET-DRIP-COLOR" USING PCL WS-C1 WS-C2 WS-C3
         WHEN 3
             MOVE 99 TO X3-NEXT
             MOVE 1 TO X3-GLOWING
             MOVE PC-GRAVITY TO WS-F32
             COMPUTE WS-F32 = WS-F32 * 0.01
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 100 TO PC-LIFETIME
             MOVE 0.51171875 TO WS-C1
             MOVE 0.03125 TO WS-C2
             MOVE 0.890625 TO WS-C3
             CALL "P3-SET-DRIP-COLOR" USING PCL WS-C1 WS-C2 WS-C3
         WHEN 4
             MOVE 2 TO X3-FLUID
             MOVE 106 TO X3-NEXT
         WHEN OTHER
             MOVE 1 TO X3-FLUID
             MOVE 108 TO X3-NEXT
             MOVE 0.2 TO WS-C1
             MOVE 0.3 TO WS-C2
             MOVE 1.0 TO WS-C3
             CALL "P3-SET-DRIP-COLOR" USING PCL WS-C1 WS-C2 WS-C3
     END-EVALUATE
     GOBACK.
 END PROGRAM P3-HANG-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-FLUID-INSIDE.
*> 3.1 step 7: USING y, block y (int), fluid height (f32), inside out: y < (float)(blockY + height).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOP                 FLOAT-SHORT.
 01 WS-BY                  FLOAT-SHORT.
 01 WS-H                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-BLOCK-Y              BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-BLOCK-Y L-HEIGHT L-INSIDE.
     MOVE L-BLOCK-Y TO WS-BY
     MOVE L-HEIGHT TO WS-H
     COMPUTE WS-TOP = WS-BY + WS-H
     MOVE 0 TO L-INSIDE
     IF L-Y < WS-TOP
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM P3-FLUID-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-HANG-TICK.
*> 3.1 tick with the DripHangParticle hooks: USING PCL, P3X, PCL-COLLIDERS, inside (the caller's step 7 fluid
*> test result), spawn out (the follow-up particle id when the hang time ends, else 0). The cooling variants
*> (fluid lava) set the colour from the lifetime before the decrement.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-INSIDE               BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING PCL P3X PCL-COLLIDERS L-INSIDE L-SPAWN.
     MOVE 0 TO L-SPAWN
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF X3-FLUID = 2
         MOVE 1.0 TO PC-RCOL
         COMPUTE PC-GCOL = 16.0 / (40 - PC-LIFETIME + 16)
         COMPUTE PC-BCOL = 4.0 / (40 - PC-LIFETIME + 8)
     END-IF
     SUBTRACT 1 FROM PC-LIFETIME
     IF PC-LIFETIME <= 0
         MOVE 1 TO PC-REMOVED
         MOVE X3-NEXT TO L-SPAWN
         GOBACK
     END-IF
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     COMPUTE PC-XD = PC-XD * 0.02
     COMPUTE PC-YD = PC-YD * 0.02
     COMPUTE PC-ZD = PC-ZD * 0.02
     COMPUTE PC-XD = PC-XD * 0.9800000190734863
     COMPUTE PC-YD = PC-YD * 0.9800000190734863
     COMPUTE PC-ZD = PC-ZD * 0.9800000190734863
     IF X3-FLUID NOT = 0 AND L-INSIDE NOT = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-HANG-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-FALL-NEW.
*> 3.4 to 3.7 fall providers: USING PCL, P3X, kind (0 falling_lava, 1 falling_water, 2 falling_honey, 3
*> falling_obsidian_tear, 4 falling_nectar, 5 falling_spore_blossom, 6 falling_dripstone_lava, 7
*> falling_dripstone_water), x, y, z, draws (1-2 base, 3 the lifetime draw of FallAndLandParticle or the
*> spore blossom's randomBetween draw), provider draw (the nectar lifetime). Landing ids: 18 landing_lava, 80
*> splash, 91 landing_honey, 100 landing_obsidian_tear.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-LO                  FLOAT-LONG VALUE 0.1.
 01 WS-HI                  FLOAT-LONG VALUE 0.9.
 01 WS-B                   FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-PDRAW                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P3X L-KIND L-X L-Y L-Z L-DRAWS L-PDRAW.
     CALL "P3-DRIP-BASE" USING PCL L-X L-Y L-Z L-DRAWS
     INITIALIZE P3X
     IF L-KIND < 4 OR L-KIND > 5
         COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(64.0 / (L-DRAW(3) * 0.8 + 0.2))
     END-IF
     EVALUATE L-KIND
         WHEN 0
             MOVE 2 TO X3-FLUID
             MOVE 18 TO X3-NEXT
             MOVE 1.0 TO WS-C1
             MOVE 0.2857143 TO WS-C2
             MOVE 0.083333336 TO WS-C3
         WHEN 1
             MOVE 1 TO X3-FLUID
             MOVE 80 TO X3-NEXT
             MOVE 0.2 TO WS-C1
             MOVE 0.3 TO WS-C2
             MOVE 1.0 TO WS-C3
         WHEN 2
             MOVE 91 TO X3-NEXT
             MOVE 0.01 TO WS-F32
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 0.582 TO WS-C1
             MOVE 0.448 TO WS-C2
             MOVE 0.082 TO WS-C3
         WHEN 3
             MOVE 100 TO X3-NEXT
             MOVE 1 TO X3-GLOWING
             MOVE 0.01 TO WS-F32
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 0.51171875 TO WS-C1
             MOVE 0.03125 TO WS-C2
             MOVE 0.890625 TO WS-C3
         WHEN 4
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(16.0 / (L-PDRAW * 0.8 + 0.2))
             MOVE 0.007 TO WS-F32
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 0.92 TO WS-C1
             MOVE 0.782 TO WS-C2
             MOVE 0.72 TO WS-C3
         WHEN 5
             CALL "P3-RANDOM-BETWEEN" USING L-DRAW(3) WS-LO WS-HI WS-B
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(64.0 / WS-B)
             MOVE 0.005 TO WS-F32
             MOVE WS-F32 TO PC-GRAVITY
             MOVE 0.32 TO WS-C1
             MOVE 0.5 TO WS-C2
             MOVE 0.22 TO WS-C3
         WHEN 6
             MOVE 2 TO X3-FLUID
             MOVE 18 TO X3-NEXT
             MOVE 1.0 TO WS-C1
             MOVE 0.2857143 TO WS-C2
             MOVE 0.083333336 TO WS-C3
         WHEN OTHER
             MOVE 1 TO X3-FLUID
             MOVE 80 TO X3-NEXT
             MOVE 0.2 TO WS-C1
             MOVE 0.3 TO WS-C2
             MOVE 1.0 TO WS-C3
     END-EVALUATE
     CALL "PCL-SET-COLOR" USING PCL WS-C1 WS-C2 WS-C3
     MOVE L-KIND TO X3-KIND
     GOBACK.
 END PROGRAM P3-FALL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-FALL-TICK.
*> 3.1 tick with the falling hooks: USING PCL, P3X, PCL-COLLIDERS, inside (step 7 fluid test result), volume
*> draw (the landing sound's randomBetween draw), spawn out (landing particle id, 0 for none), sound out (0
*> none, 1 BEEHIVE_DRIP, 2 POINTED_DRIPSTONE_DRIP_LAVA, 3 POINTED_DRIPSTONE_DRIP_WATER), volume out. The kind
*> was kept in X3-KIND by P3-FALL-NEW (2 honey, 4 and 5 FallingParticle, 6 and 7 dripstone).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO                  FLOAT-LONG VALUE 0.3.
 01 WS-HI                  FLOAT-LONG VALUE 1.0.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-INSIDE               BINARY-LONG.
 01 L-VDRAW                FLOAT-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-VOLUME               FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P3X PCL-COLLIDERS L-INSIDE L-VDRAW L-SPAWN L-SOUND L-VOLUME.
     MOVE 0 TO L-SPAWN L-SOUND
     MOVE 0 TO L-VOLUME
     MOVE X3-KIND TO WS-KIND
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
     IF PC-ON-GROUND NOT = 0
         MOVE 1 TO PC-REMOVED
         IF WS-KIND NOT = 4 AND WS-KIND NOT = 5
             MOVE X3-NEXT TO L-SPAWN
             EVALUATE WS-KIND
                 WHEN 2
                     MOVE 1 TO L-SOUND
                 WHEN 6
                     MOVE 2 TO L-SOUND
                 WHEN 7
                     MOVE 3 TO L-SOUND
             END-EVALUATE
             IF L-SOUND NOT = 0
                 CALL "P3-RANDOM-BETWEEN" USING L-VDRAW WS-LO WS-HI L-VOLUME
             END-IF
         END-IF
         GOBACK
     END-IF
     COMPUTE PC-XD = PC-XD * 0.9800000190734863
     COMPUTE PC-YD = PC-YD * 0.9800000190734863
     COMPUTE PC-ZD = PC-ZD * 0.9800000190734863
     IF X3-FLUID NOT = 0 AND L-INSIDE NOT = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-FALL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LAND-NEW.
*> 3.5 landing providers: USING PCL, P3X, kind (0 landing_lava, 1 landing_honey, 2 landing_obsidian_tear), x, y,
*> z, draws (1-2 base, 3 the DripLandParticle lifetime draw), provider draw (the replacement lifetime of honey
*> and obsidian). Gravity stays 0.06.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-PDRAW                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL P3X L-KIND L-X L-Y L-Z L-DRAWS L-PDRAW.
     CALL "P3-DRIP-BASE" USING PCL L-X L-Y L-Z L-DRAWS
     INITIALIZE P3X
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(16.0 / (L-DRAW(3) * 0.8 + 0.2))
     EVALUATE L-KIND
         WHEN 0
             MOVE 2 TO X3-FLUID
             MOVE 1.0 TO WS-C1
             MOVE 0.2857143 TO WS-C2
             MOVE 0.083333336 TO WS-C3
         WHEN 1
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(128.0 / (L-PDRAW * 0.8 + 0.2))
             MOVE 0.522 TO WS-C1
             MOVE 0.408 TO WS-C2
             MOVE 0.082 TO WS-C3
         WHEN OTHER
             MOVE 1 TO X3-GLOWING
             COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(28.0 / (L-PDRAW * 0.8 + 0.2))
             MOVE 0.51171875 TO WS-C1
             MOVE 0.03125 TO WS-C2
             MOVE 0.890625 TO WS-C3
     END-EVALUATE
     CALL "PCL-SET-COLOR" USING PCL WS-C1 WS-C2 WS-C3
     GOBACK.
 END PROGRAM P3-LAND-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3-LAND-TICK.
*> 3.1 default tick (DripLandParticle): USING PCL, P3X, PCL-COLLIDERS, inside: lifetime - 1 removes at 0; gravity;
*> move; friction 0.98; the fluid test of step 7.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP3X.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING PCL P3X PCL-COLLIDERS L-INSIDE.
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
     COMPUTE PC-XD = PC-XD * 0.9800000190734863
     COMPUTE PC-YD = PC-YD * 0.9800000190734863
     COMPUTE PC-ZD = PC-ZD * 0.9800000190734863
     IF X3-FLUID NOT = 0 AND L-INSIDE NOT = 0
         MOVE 1 TO PC-REMOVED
     END-IF
     GOBACK.
 END PROGRAM P3-LAND-TICK.
