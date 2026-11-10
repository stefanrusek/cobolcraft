*> Particles part 5 (docs/protocol/42-particles-5-sculk-trial-wind-geyser.md), section 3: the emitter rules (level events 3006, 3007,
*> 3013 to 3021 and the block, block-entity and entity emitters as pure functions of their draws and positions). Draws are
*> passed in as values (a nextFloat as a FLOAT-LONG in [0, 1), a nextInt(n) as the float r with floor(r * n), a nextGaussian as
*> the gaussian itself); positions are integers for block positions and FLOAT-LONG triples for world positions.
*>
*> Entry points for the integrator (inputs): one program per emitter rule, named P5-<EMITTER>; each header line below states its
*> inputs and outputs. The level event dispatch is in 42-7 section 8; these are the rules those cases call.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CHARGE-DECODE.
*> Section 3.1 data layout of event 3006: USING data, charge out (data >> 6), faces out (data & 63).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DATA                 BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 01 L-FACES                BINARY-LONG.
 PROCEDURE DIVISION USING L-DATA L-CHARGE L-FACES.
     COMPUTE L-CHARGE = FUNCTION INTEGER-PART(L-DATA / 64)
     COMPUTE L-FACES = FUNCTION MOD(L-DATA, 64)
     GOBACK.
 END PROGRAM P5-CHARGE-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CHARGE-FACE.
*> Section 3.1 charge > 0: USING face mask, face (0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST), roll out, offset
*> out, emit out. Mask 0: every face, roll pi for DOWN, offset 0.65 on the Y axis and 0.57 on X or Z; else the faces
*> in the mask, roll pi for UP, offset 0.35.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MASK                 BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-ROLL                 FLOAT-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MASK L-FACE L-ROLL L-OFFSET L-EMIT.
     MOVE 0 TO L-ROLL
     MOVE 0 TO L-EMIT
     IF L-MASK = 0
         MOVE 1 TO L-EMIT
         IF L-FACE = 0
             MOVE 3.1415927 TO L-ROLL
         END-IF
         IF L-FACE < 2
             MOVE 0.65 TO L-OFFSET
         ELSE
             MOVE 0.57 TO L-OFFSET
         END-IF
     ELSE
         MOVE 0.35 TO L-OFFSET
         IF FUNCTION MOD(FUNCTION INTEGER-PART(L-MASK / 2 ** L-FACE), 2) = 1
             MOVE 1 TO L-EMIT
         END-IF
         IF L-FACE = 1
             MOVE 3.1415927 TO L-ROLL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P5-CHARGE-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CHARGE-SOUND.
*> Section 3.1 step 1: USING charge, r, r2, r3, play out (r < 0.3 + charge * 0.1), volume out (0.15 + 0.02 * charge^2
*> * r2), pitch out (0.4 + 0.3 * charge * r3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHARGE               BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-PLAY                 BINARY-LONG.
 01 L-VOLUME               FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-CHARGE L-R L-R2 L-R3 L-PLAY L-VOLUME L-PITCH.
     MOVE 0 TO L-PLAY
     IF L-R < 0.3 + L-CHARGE * 0.1
         MOVE 1 TO L-PLAY
     END-IF
     COMPUTE L-VOLUME = 0.15 + 0.02 * L-CHARGE * L-CHARGE * L-R2
     COMPUTE L-PITCH = 0.4 + 0.3 * L-CHARGE * L-R3
     GOBACK.
 END PROGRAM P5-CHARGE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-POP-INFO.
*> Section 3.1 charge == 0: USING full block (0/1), particle count out (40 or 20), spread out (0.45 or 0.25), speed
*> factor out (0.07).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FULL                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SPREAD               FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-FULL L-COUNT L-SPREAD L-SPEED.
     MOVE 0.07 TO L-SPEED
     IF L-FULL NOT = 0
         MOVE 40 TO L-COUNT
         MOVE 0.45 TO L-SPREAD
     ELSE
         MOVE 20 TO L-COUNT
         MOVE 0.25 TO L-SPREAD
     END-IF
     GOBACK.
 END PROGRAM P5-POP-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-POP-POS.
*> Section 3.1 charge == 0, one particle: USING block position (three integers), draws a, b, c (each nextFloat * 2 -
*> 1), spread, position out (block + 0.5 + a * spread), velocity out (a * 0.07).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-SPREAD               FLOAT-LONG.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-V.
    05 L-V-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-SPREAD L-O L-V.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O-E(WS-A) = L-P-E(WS-A) + 0.5 + L-U-E(WS-A) * L-SPREAD
         COMPUTE L-V-E(WS-A) = L-U-E(WS-A) * 0.07
     END-PERFORM
     GOBACK.
 END PROGRAM P5-POP-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-EMIT.
*> Section 3.2: USING block position (three integers), i (0 to 9), delay out (i * 5), x, y, z out (x + 0.5, y + TOP_Y
*> = 0.5, z + 0.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-I                    BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-P L-I L-DELAY L-X L-Y L-Z.
     COMPUTE L-DELAY = L-I * 5
     COMPUTE L-X = L-P-E(1) + 0.5
     COMPUTE L-Y = L-P-E(2) + 0.5
     COMPUTE L-Z = L-P-E(3) + 0.5
     GOBACK.
 END PROGRAM P5-SHRIEK-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SHRIEK-COUNT.
*> Section 3.2: USING count out (ten shriek particles per event, delays 0, 5, ..., 45).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 10 TO L-COUNT
     GOBACK.
 END PROGRAM P5-SHRIEK-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-DETECT-COUNT.
*> Section 3.3 addDetectPlayerParticles: USING player count n, particle count out = 30 + min(n, 10) * 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-COUNT.
     COMPUTE L-COUNT = 30 + FUNCTION MIN(L-N, 10) * 5
     GOBACK.
 END PROGRAM P5-DETECT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-DETECT-POS.
*> Section 3.3 one detect particle: USING block position, draws (dx, dz, y: nextFloat), position out: x + 0.5 + (r *
*> 2 - 1) * 0.65, y + 0.1 + r * 0.8, z likewise.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-O.
     COMPUTE L-O-E(1) = L-P-E(1) + 0.5 + (L-U-E(1) * 2 - 1) * 0.65
     COMPUTE L-O-E(3) = L-P-E(3) + 0.5 + (L-U-E(2) * 2 - 1) * 0.65
     COMPUTE L-O-E(2) = L-P-E(2) + 0.1 + L-U-E(3) * 0.8
     GOBACK.
 END PROGRAM P5-DETECT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-BURST.
*> Section 3.3 addBecomeOminousParticles, one of 20: USING block position, draws (three nextDouble), gaussians
*> (three), position out (centre + (r - 0.5) * 2), velocity out (gaussian * 0.02); a trial_omen then a
*> soul_fire_flame particle share both.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-G.
    05 L-G-E                FLOAT-LONG OCCURS 6 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-V.
    05 L-V-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-G L-O L-V.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O-E(WS-A) = L-P-E(WS-A) + 0.5 + (L-U-E(WS-A) - 0.5) * 2
         COMPUTE L-V-E(WS-A) = L-G-E(WS-A) * 0.02
     END-PERFORM
     GOBACK.
 END PROGRAM P5-OMINOUS-BURST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-EJECT-POS.
*> Section 3.3 addEjectItemParticles, one of 20: USING block position, draws (three nextDouble), gaussians (three),
*> position out (corner + 0.4 + r * 0.2), small_flame velocity out (gaussian * 0.02 * 0.25), smoke velocity out
*> (gaussian * 0.02).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-G.
    05 L-G-E                FLOAT-LONG OCCURS 6 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-VF.
    05 L-VF-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-VS.
    05 L-VS-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-G L-O L-VF L-VS.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O-E(WS-A) = L-P-E(WS-A) + 0.4 + L-U-E(WS-A) * 0.2
         COMPUTE L-VS-E(WS-A) = L-G-E(WS-A) * 0.02
         COMPUTE L-VF-E(WS-A) = L-VS-E(WS-A) * 0.25
     END-PERFORM
     GOBACK.
 END PROGRAM P5-EJECT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-KEYHOLE.
*> Section 3.4: USING block position (three integers), facing step x, step z, keyhole out = bottom centre + (stepX *
*> 0.5, 1.75, stepZ * 0.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-SX L-SZ L-O.
     COMPUTE L-O-E(1) = L-P-E(1) + 0.5 + L-SX * 0.5
     COMPUTE L-O-E(2) = L-P-E(2) + 1.75
     COMPUTE L-O-E(3) = L-P-E(3) + 0.5 + L-SZ * 0.5
     GOBACK.
 END PROGRAM P5-VAULT-KEYHOLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-IN-RANGE.
*> Section 3.4: USING squared distance between the block positions, range, in range out (distSqr <= range^2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIST2                FLOAT-LONG.
 01 L-RANGE                FLOAT-LONG.
 01 L-IN                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIST2 L-RANGE L-IN.
     MOVE 0 TO L-IN
     IF L-DIST2 <= L-RANGE * L-RANGE
         MOVE 1 TO L-IN
     END-IF
     GOBACK.
 END PROGRAM P5-VAULT-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-RANGE.
*> Section 3.4: USING range out (the default connected particles range, the deactivation range 4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANGE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-RANGE.
     MOVE 4.5 TO L-RANGE
     GOBACK.
 END PROGRAM P5-VAULT-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-COUNT.
*> Section 3.4: USING draw r (nextInt as r), connection particles per player out = Mth.nextInt(2, 5) = 2 + floor(r *
*> 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-COUNT.
     COMPUTE L-COUNT = 2 + FUNCTION INTEGER-PART(L-R * 4)
     GOBACK.
 END PROGRAM P5-VAULT-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-FLAME.
*> Section 3.4 callers: USING event data, flame particle name out (X(32)): data 0 small_flame, else soul_fire_flame.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DATA                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-DATA L-NAME.
     IF L-DATA = 0
         MOVE "small_flame" TO L-NAME
     ELSE
         MOVE "soul_fire_flame" TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM P5-VAULT-FLAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-IDLE.
*> Section 3.4 idle: USING nextFloat draw, emit out (draw <= 0.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-EMIT.
     MOVE 0 TO L-EMIT
     IF L-R <= 0.5
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM P5-VAULT-IDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-IDLE-POS.
*> Section 3.4 idle: USING block corner (three integers), draws (three nextDouble), position out = corner +
*> nextDouble(0.1, 0.9), (0.25, 0.75), (0.1, 0.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-O.
     COMPUTE L-O-E(1) = L-P-E(1) + 0.1 + L-U-E(1) * 0.8
     COMPUTE L-O-E(2) = L-P-E(2) + 0.25 + L-U-E(2) * 0.5
     COMPUTE L-O-E(3) = L-P-E(3) + 0.1 + L-U-E(3) * 0.8
     GOBACK.
 END PROGRAM P5-VAULT-IDLE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-DEACT-POS.
*> Section 3.4 deactivation: USING block corner, draws (three nextDouble), gaussians (three), position out = corner +
*> nextDouble(0.4, 0.6), velocity out (gaussian * 0.02).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-G.
    05 L-G-E                FLOAT-LONG OCCURS 6 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-V.
    05 L-V-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-G L-O L-V.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O-E(WS-A) = L-P-E(WS-A) + 0.4 + L-U-E(WS-A) * 0.2
         COMPUTE L-V-E(WS-A) = L-G-E(WS-A) * 0.02
     END-PERFORM
     GOBACK.
 END PROGRAM P5-VAULT-DEACT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VAULT-DELTA.
*> Section 3.4 connection: USING player position, player bounding box height, keyhole position, delta out = player +
*> (0, height / 2, 0) - keyhole.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PL.
    05 L-PL-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-H                    FLOAT-LONG.
 01 L-K.
    05 L-K-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-PL L-H L-K L-O.
     COMPUTE L-O-E(1) = L-PL-E(1) - L-K-E(1)
     COMPUTE L-O-E(2) = L-PL-E(2) + L-H / 2 - L-K-E(2)
     COMPUTE L-O-E(3) = L-PL-E(3) - L-K-E(3)
     GOBACK.
 END PROGRAM P5-VAULT-DELTA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-POT-EMIT.
*> Section 3.5: USING block position (three integers), count out (7 dust_plume particles), x, y, z out (x + 0.5, y +
*> 1.2, z + 0.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-P L-COUNT L-X L-Y L-Z.
     MOVE 7 TO L-COUNT
     COMPUTE L-X = L-P-E(1) + 0.5
     COMPUTE L-Y = L-P-E(2) + 1.2
     COMPUTE L-Z = L-P-E(3) + 0.5
     GOBACK.
 END PROGRAM P5-POT-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-ITEM-COUNT.
*> Section 3.6: USING draw r (nextInt as r), particles per burst out = nextIntBetweenInclusive(1, 3) = 1 + floor(r *
*> 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-COUNT.
     COMPUTE L-COUNT = 1 + FUNCTION INTEGER-PART(L-R * 3)
     GOBACK.
 END PROGRAM P5-OMINOUS-ITEM-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-ITEM-VEL.
*> Section 3.6: USING six gaussians (x pair, y pair, z pair), velocity out = q - p = 0.4 * (g1 - g2) and so on.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-G.
    05 L-G-E                FLOAT-LONG OCCURS 6 TIMES.
 01 L-V.
    05 L-V-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-G L-V.
     COMPUTE L-V-E(1) = 0.4 * (L-G-E(1) - L-G-E(2))
     COMPUTE L-V-E(2) = 0.4 * (L-G-E(3) - L-G-E(4))
     COMPUTE L-V-E(3) = 0.4 * (L-G-E(5) - L-G-E(6))
     GOBACK.
 END PROGRAM P5-OMINOUS-ITEM-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-OMINOUS-CADENCE.
*> Section 3.6: USING game time, emit out (game time % 5 == 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-EMIT.
     MOVE 0 TO L-EMIT
     IF FUNCTION MOD(L-TIME, 5) = 0
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM P5-OMINOUS-CADENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-WIND-RADIUS.
*> Section 3.7: USING kind (0 wind charge 1.2, 1 breeze wind charge 3.0, 2 wind charged kill 3.0 + 2 * r), draw r,
*> radius out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-R L-RADIUS.
     EVALUATE L-KIND
         WHEN 0
             MOVE 1.2 TO L-RADIUS
         WHEN 1
             MOVE 3.0 TO L-RADIUS
         WHEN OTHER
             COMPUTE L-RADIUS = 3.0 + 2 * L-R
     END-EVALUATE
     GOBACK.
 END PROGRAM P5-WIND-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-SONIC-COUNT.
*> Section 3.8: USING distance to the target, sonic_boom particles out = floor(length) + 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEN                  FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEN L-COUNT.
     COMPUTE L-COUNT = FUNCTION INTEGER-PART(L-LEN) + 6
     GOBACK.
 END PROGRAM P5-SONIC-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-RELOAD.
*> Section 3.9: USING total travel ticks, remaining ticks, factor out = 1 - remaining / total.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-REMAINING            BINARY-LONG.
 01 L-FACTOR               FLOAT-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-REMAINING L-FACTOR.
     COMPUTE L-FACTOR = 1 - L-REMAINING / L-TOTAL
     GOBACK.
 END PROGRAM P5-VIB-RELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-VIB-LERP.
*> Section 3.9: USING factor, origin, destination, position out = lerp(factor, origin, destination) on each axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A BINARY-LONG.
 LINKAGE SECTION.
 01 L-F                    FLOAT-LONG.
 01 L-A.
    05 L-A-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-B.
    05 L-B-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-F L-A L-B L-O.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O-E(WS-A) = L-A-E(WS-A) + L-F * (L-B-E(WS-A) - L-A-E(WS-A))
     END-PERFORM
     GOBACK.
 END PROGRAM P5-VIB-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-TRAIL-COLOR.
*> Sections 3.10 and 3.11: USING active / open flag (0/1), colour out: 16545810 (0xFC7812) when set, else 6250335
*> (0x5F5F5F).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-COLOR.
     IF L-ACTIVE NOT = 0
         MOVE 16545810 TO L-COLOR
     ELSE
         MOVE 6250335 TO L-COLOR
     END-IF
     GOBACK.
 END PROGRAM P5-TRAIL-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CREAKING-DURATION.
*> Section 3.10: USING draw r (nextInt(40) as r), trail duration out = 10 + floor(r * 40).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-DURATION.
     COMPUTE L-DURATION = 10 + FUNCTION INTEGER-PART(L-R * 40)
     GOBACK.
 END PROGRAM P5-CREAKING-DURATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-EYEBLOSSOM.
*> Section 3.11: USING nextDouble draw, s out (0.5 + draw), trail duration out ((int)(20 * s)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-S L-DURATION.
     COMPUTE L-S = 0.5 + L-R
     COMPUTE L-DURATION = FUNCTION INTEGER-PART(20 * L-S)
     GOBACK.
 END PROGRAM P5-EYEBLOSSOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-BUBBLE-EMIT.
*> Section 3.12: USING state is DRY (0/1), water source in the block above (0/1), sulfur_bubbles per call out (2,
*> else 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRY                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRY L-WATER L-COUNT.
     MOVE 0 TO L-COUNT
     IF L-DRY = 0 AND L-WATER NOT = 0
         MOVE 2 TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM P5-BUBBLE-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-BUBBLE-POS.
*> Section 3.12: USING block position (three integers), draws (three nextFloat), position out (x + r, y + 1 + r, z +
*> r).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-U.
    05 L-U-E                FLOAT-LONG OCCURS 3 TIMES.
 01 L-O.
    05 L-O-E                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-U L-O.
     COMPUTE L-O-E(1) = L-P-E(1) + L-U-E(1)
     COMPUTE L-O-E(2) = L-P-E(2) + 1 + L-U-E(2)
     COMPUTE L-O-E(3) = L-P-E(3) + L-U-E(3)
     GOBACK.
 END PROGRAM P5-BUBBLE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GAS-SOURCE-STEP.
*> Section 3.12 findNoxiousGasSource: USING water source fluid (0/1), block is water or passable (0/1), block is air
*> or passable (0/1), action out: 0 continue upward, 1 this position is the source, 2 none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-WATER L-AIR L-ACTION.
     EVALUATE TRUE
         WHEN L-FLUID NOT = 0 AND L-WATER NOT = 0
             MOVE 0 TO L-ACTION
         WHEN L-AIR NOT = 0
             MOVE 1 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM P5-GAS-SOURCE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GEYSER-CADENCE.
*> Section 3.12 geyser ticker: USING elapsed ticks since the eruption tick, spawn out (elapsed % 20 == 0), sound out
*> (elapsed % 40 == 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ELAPSED              BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ELAPSED L-SPAWN L-SOUND.
     MOVE 0 TO L-SPAWN L-SOUND
     IF FUNCTION MOD(L-ELAPSED, 20) = 0
         MOVE 1 TO L-SPAWN
     END-IF
     IF FUNCTION MOD(L-ELAPSED, 40) = 0
         MOVE 1 TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM P5-GEYSER-CADENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GEYSER-WATER.
*> Section 3.12: USING source y, block y, w out = source y - block y - 1 (the water blocks between).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SY                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SY L-BY L-W.
     COMPUTE L-W = L-SY - L-BY - 1
     GOBACK.
 END PROGRAM P5-GEYSER-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CLOUD-CADENCE.
*> Section 3.12 noxious gas ticker: USING game time, spawn out (every 20 game ticks).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-SPAWN.
     MOVE 0 TO L-SPAWN
     IF FUNCTION MOD(L-TIME, 20) = 0
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM P5-CLOUD-CADENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GROWTH-POS.
*> Section 3.13: USING feet y, bounding box height, draw r (nextDouble), pause (0/1), y out = feet + h * (2r - 1) *
*> 0.2 + h + (0.2 for pause, else 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FEET                 FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-PAUSE                BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-FEET L-H L-R L-PAUSE L-Y.
     COMPUTE L-Y = L-FEET + L-H * (2 * L-R - 1) * 0.2 + L-H
     IF L-PAUSE NOT = 0
         COMPUTE L-Y = L-Y + 0.2
     END-IF
     GOBACK.
 END PROGRAM P5-GROWTH-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-GROWTH-EMIT.
*> Section 3.13: USING age, emit out: a positive even age.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-EMIT.
     MOVE 0 TO L-EMIT
     IF L-AGE > 0 AND FUNCTION MOD(L-AGE, 2) = 0
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM P5-GROWTH-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P5-CATALYST-EMIT.
*> Section 3.14: USING block position (three integers), count out (2), x, y, z out (x + 0.5, y + 1.15, z + 0.5),
*> horizontal distance out (0.2; the y distance and the speed are 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P.
    05 L-P-E                BINARY-LONG OCCURS 3 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-P L-COUNT L-X L-Y L-Z L-DX.
     MOVE 2 TO L-COUNT
     COMPUTE L-X = L-P-E(1) + 0.5
     COMPUTE L-Y = L-P-E(2) + 1.15
     COMPUTE L-Z = L-P-E(3) + 0.5
     MOVE 0.2 TO L-DX
     GOBACK.
 END PROGRAM P5-CATALYST-EMIT.
