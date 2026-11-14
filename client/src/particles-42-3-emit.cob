*> Particles part 3, sections 4 and 9 (docs/protocol/42-particles-3-fluid-drip-water.md): how the client emits
*> drip particles and the server and entity emitters of the scope types. Every program is a pure decision
*> function: the caller passes the world facts (fluid, shapes, flags) and the random draws in the document's
*> order (nextInt(n) is the integer part of draw * n); the answer is a P3ER record (CLP3E.cpy).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SCAN-COUNTS.
*> 4.1: USING passes out (667), samples out (two shells: 1334).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASSES               BINARY-LONG.
 01 L-SAMPLES              BINARY-LONG.
 PROCEDURE DIVISION USING L-PASSES L-SAMPLES.
     MOVE 667 TO L-PASSES
     COMPUTE L-SAMPLES = L-PASSES * 2
     GOBACK.
 END PROGRAM P3E-SCAN-COUNTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SCAN-AXIS.
*> 4.1 doAnimateTick: USING centre, radius, draw plus, draw minus, position out = c + nextInt(r) - nextInt(r).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-R L-D1 L-D2 L-OUT.
     COMPUTE L-OUT = L-C + FUNCTION INTEGER-PART(L-D1 * L-R) - FUNCTION INTEGER-PART(L-D2 * L-R)
     GOBACK.
 END PROGRAM P3E-SCAN-AXIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DRIP-ID.
*> 4.1 step 3: USING fluid (0 other, 1 water, 2 lava), particle id out: dripping_water 19, dripping_lava 16, else 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-ID.
     EVALUATE L-FLUID
         WHEN 1 MOVE 19 TO L-ID
         WHEN 2 MOVE 16 TO L-ID
         WHEN OTHER MOVE 0 TO L-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM P3E-DRIP-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DRIP-ROLL.
*> 4.1 step 3: USING draw, hit out: nextInt(10) == 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-HIT.
     MOVE 0 TO L-HIT
     IF FUNCTION INTEGER-PART(L-DRAW * 10) = 0
         MOVE 1 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM P3E-DRIP-ROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-WATER.
*> 4.2 WaterFluid.animateTick: USING flowing, falling, draws 1-4, P3ER: a flowing fluid that is not falling plays
*> WATER_AMBIENT (act 1, volume d2 * 0.25 + 0.75, pitch d3 + 0.5) when nextInt(64) == 0; otherwise an
*> underwater particle (act 2, offsets d2, d3, d4) when nextInt(10) == 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLOWING              BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-D4                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-FLOWING L-FALLING L-D1 L-D2 L-D3 L-D4 P3ER.
     INITIALIZE P3ER
     IF L-FLOWING NOT = 0 AND L-FALLING = 0
         IF FUNCTION INTEGER-PART(L-D1 * 64) = 0
             MOVE 1 TO ER-ACT
             COMPUTE ER-VOL = L-D2 * 0.25 + 0.75
             COMPUTE ER-PITCH = L-D3 + 0.5
         END-IF
     ELSE
         IF FUNCTION INTEGER-PART(L-D1 * 10) = 0
             MOVE 2 TO ER-ACT
             MOVE L-D2 TO ER-X
             MOVE L-D3 TO ER-Y
             MOVE L-D4 TO ER-Z
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3E-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-LAVA.
*> 4.2 LavaFluid.animateTick: USING air above (open air, not solid-render), draws 1-8, P3ER: when nextInt(100) == 0
*> (d1): act 1, the lava particle at offsets (d2, 1.0, d3) with LAVA_POP volume 0.2 + d4 * 0.2 and pitch 0.9 + d5 *
*> 0.15; independently when nextInt(200) == 0 (d6): act2 2, LAVA_AMBIENT with volume 0.2 + d7 * 0.2, pitch 0.9 + d8 *
*> 0.15.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-D4                   FLOAT-LONG.
 01 L-D5                   FLOAT-LONG.
 01 L-D6                   FLOAT-LONG.
 01 L-D7                   FLOAT-LONG.
 01 L-D8                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-AIR L-D1 L-D2 L-D3 L-D4 L-D5 L-D6 L-D7 L-D8 P3ER.
     INITIALIZE P3ER
     IF L-AIR NOT = 0
         IF FUNCTION INTEGER-PART(L-D1 * 100) = 0
             MOVE 1 TO ER-ACT
             MOVE L-D2 TO ER-X
             MOVE 1.0 TO ER-Y
             MOVE L-D3 TO ER-Z
             COMPUTE ER-VOL = 0.2 + L-D4 * 0.2
             COMPUTE ER-PITCH = 0.9 + L-D5 * 0.15
         END-IF
         IF FUNCTION INTEGER-PART(L-D6 * 200) = 0
             MOVE 2 TO ER-ACT2
             COMPUTE ER-VOL2 = 0.2 + L-D7 * 0.2
             COMPUTE ER-PITCH2 = 0.9 + L-D8 * 0.15
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3E-LAVA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-LEAVES.
*> 4.3 LeavesBlock: USING raining above, draw 1 (nextInt(15) == 1), draws 2 and 3 (the x and z offsets), sturdy
*> occluding block below, P3ER: act 19 (dripping_water) at offsets (d2, -0.05, d3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAINING              BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-STURDY               BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-RAINING L-D1 L-D2 L-D3 L-STURDY P3ER.
     INITIALIZE P3ER
     IF L-RAINING NOT = 0 AND FUNCTION INTEGER-PART(L-D1 * 15) = 1 AND L-STURDY = 0
         MOVE 19 TO ER-ACT
         MOVE L-D2 TO ER-X
         MOVE -0.05 TO ER-Y
         MOVE L-D3 TO ER-Z
     END-IF
     GOBACK.
 END PROGRAM P3E-LEAVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DIRECTION.
*> 4.3 Direction.getRandom: USING draw, index out = nextInt(6): 0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-DIR.
     COMPUTE L-DIR = FUNCTION INTEGER-PART(L-DRAW * 6)
     GOBACK.
 END PROGRAM P3E-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SPONGE.
*> 4.3 WetSpongeBlock: USING direction, draws 1 and 2, occluded (the block occludes and the neighbour face is
*> sturdy), P3ER: act 19 at the offset of the table (UP and occluded stop).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-DIR L-D1 L-D2 L-OCCLUDED P3ER.
     INITIALIZE P3ER
     IF L-DIR NOT = 1 AND L-OCCLUDED = 0
         MOVE 19 TO ER-ACT
         EVALUATE L-DIR
             WHEN 0
                 MOVE L-D1 TO ER-X
                 MOVE -0.05 TO ER-Y
                 MOVE L-D2 TO ER-Z
             WHEN 5
                 MOVE 1.1 TO ER-X
                 COMPUTE ER-Y = L-D1 * 0.8
                 MOVE L-D2 TO ER-Z
             WHEN 4
                 MOVE 0.05 TO ER-X
                 COMPUTE ER-Y = L-D1 * 0.8
                 MOVE L-D2 TO ER-Z
             WHEN 3
                 COMPUTE ER-Y = L-D1 * 0.8
                 MOVE L-D2 TO ER-X
                 MOVE 1.1 TO ER-Z
             WHEN OTHER
                 COMPUTE ER-Y = L-D1 * 0.8
                 MOVE L-D2 TO ER-X
                 MOVE 0.05 TO ER-Z
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM P3E-SPONGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-TRY-DRIP.
*> 4.4 trySpawnDripParticles: USING block below has fluid, shape max y, sturdy (the sampled block's down face),
*> impermeable, shape min y, max y of the block two below, that block's fluid is empty, shape x0, x1, z0, z1,
*> draws 1 and 2, block y, P3ER: act 1 with the position (x = lerp(d1, x0, x1), y, z = lerp(d2, z0, z1)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HAS-FLUID            BINARY-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-IMPERMEABLE          BINARY-LONG.
 01 L-MINY                 FLOAT-LONG.
 01 L-B2-MAXY              FLOAT-LONG.
 01 L-B2-EMPTY             BINARY-LONG.
 01 L-SX0                  FLOAT-LONG.
 01 L-SX1                  FLOAT-LONG.
 01 L-SZ0                  FLOAT-LONG.
 01 L-SZ1                  FLOAT-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-PY                   BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-HAS-FLUID L-MAXY L-STURDY L-IMPERMEABLE L-MINY L-B2-MAXY L-B2-EMPTY
         L-SX0 L-SX1 L-SZ0 L-SZ1 L-D1 L-D2 L-PY P3ER.
     INITIALIZE P3ER
     MOVE L-SX0 TO WS-X0
     MOVE L-SX1 TO WS-X1
     MOVE L-SZ0 TO WS-Z0
     MOVE L-SZ1 TO WS-Z1
     IF L-HAS-FLUID = 0
         IF L-MAXY < 1.0
             IF L-STURDY NOT = 0
                 MOVE 0 TO WS-X0 WS-Z0
                 MOVE 1 TO WS-X1 WS-Z1
                 COMPUTE ER-Y = L-PY + 1 - 0.05
                 MOVE 1 TO ER-ACT
             END-IF
         ELSE
             IF L-IMPERMEABLE = 0
                 IF L-MINY > 0
                     COMPUTE ER-Y = L-PY + L-MINY - 0.05
                     MOVE 1 TO ER-ACT
                 ELSE
                     IF L-B2-MAXY < 1.0 AND L-B2-EMPTY NOT = 0
                         COMPUTE ER-Y = L-PY - 0.05
                         MOVE 1 TO ER-ACT
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     IF ER-ACT NOT = 0
         COMPUTE ER-X = WS-X0 + L-D1 * (WS-X1 - WS-X0)
         COMPUTE ER-Z = WS-Z0 + L-D2 * (WS-Z1 - WS-Z0)
     END-IF
     GOBACK.
 END PROGRAM P3E-TRY-DRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-CRYING.
*> 4.3 CryingObsidianBlock: USING draw 1 (nextInt(5) == 0), direction, occluded, draws 2-4 (nextDouble for the
*> axes whose step is 0, in x, y, z order), P3ER: act 99 at the offsets (0.5 + step * 0.6 on the stepped axis).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP-X              BINARY-LONG.
 01 WS-STEP-Y              BINARY-LONG.
 01 WS-STEP-Z              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-D0                   FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D0 L-DIR L-OCCLUDED L-D1 L-D2 L-D3 P3ER.
     INITIALIZE P3ER
     IF FUNCTION INTEGER-PART(L-D0 * 5) = 0 AND L-DIR NOT = 1 AND L-OCCLUDED = 0
         MOVE 99 TO ER-ACT
         MOVE 0 TO WS-STEP-X WS-STEP-Y WS-STEP-Z
         EVALUATE L-DIR
             WHEN 0 MOVE -1 TO WS-STEP-Y
             WHEN 2 MOVE -1 TO WS-STEP-Z
             WHEN 3 MOVE 1 TO WS-STEP-Z
             WHEN 4 MOVE -1 TO WS-STEP-X
             WHEN OTHER MOVE 1 TO WS-STEP-X
         END-EVALUATE
         MOVE 1 TO WS-K
         IF WS-STEP-X = 0
             MOVE L-D1 TO ER-X
             MOVE 2 TO WS-K
         ELSE
             COMPUTE ER-X = 0.5 + WS-STEP-X * 0.6
         END-IF
         IF WS-STEP-Y = 0
             IF WS-K = 1
                 MOVE L-D1 TO ER-Y
             ELSE
                 MOVE L-D2 TO ER-Y
             END-IF
             ADD 1 TO WS-K
         ELSE
             COMPUTE ER-Y = 0.5 + WS-STEP-Y * 0.6
         END-IF
         IF WS-STEP-Z = 0
*>           A zero z step only happens with one other zero axis (the stepped axis is x or y), so it is the second draw.
             MOVE L-D2 TO ER-Z
         ELSE
             COMPUTE ER-Z = 0.5 + WS-STEP-Z * 0.6
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3E-CRYING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SPORE.
*> 4.3 SporeBlossomBlock: USING draws 1 and 2 (nextDouble), P3ER: act 93 (falling_spore_blossom) at (d1, 0.7, d2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 P3ER.
     INITIALIZE P3ER
     MOVE 93 TO ER-ACT
     MOVE L-D1 TO ER-X
     MOVE 0.7 TO ER-Y
     MOVE L-D2 TO ER-Z
     GOBACK.
 END PROGRAM P3E-SPORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-MTH-NEXTINT.
*> 4.3 Mth.nextInt(min, max): USING min, max, draw, result out = min + nextInt(max - min + 1) (inclusive bounds).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN L-MAX L-DRAW L-OUT.
     COMPUTE L-OUT = L-MIN + FUNCTION INTEGER-PART(L-DRAW * (L-MAX - L-MIN + 1))
     GOBACK.
 END PROGRAM P3E-MTH-NEXTINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DRIPSTONE-KEEP.
*> 4.3 PointedDripstoneBlock: USING f (the first nextFloat), fluid above (0 none, 1 water, 2 lava), keep out: dropped
*> above 0.12; kept below 0.02; between them kept only for water or lava.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    FLOAT-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-FLUID L-KEEP.
     MOVE 0 TO L-KEEP
     IF L-F <= 0.12
         IF L-F < 0.02 OR L-FLUID NOT = 0
             MOVE 1 TO L-KEEP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3E-DRIPSTONE-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DRIPSTONE-POS.
*> 4.3 spawnDripParticle: USING offset x, offset z, P3ER: act 1 at (0.5 + ox, 0.3125 - 0.0625, 0.5 + oz) from the tip.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OX                   FLOAT-LONG.
 01 L-OZ                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-OX L-OZ P3ER.
     INITIALIZE P3ER
     MOVE 1 TO ER-ACT
     COMPUTE ER-X = 0.5 + L-OX
     COMPUTE ER-Y = 0.3125 - 0.0625
     COMPUTE ER-Z = 0.5 + L-OZ
     GOBACK.
 END PROGRAM P3E-DRIPSTONE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-BEE-PASSES.
*> 4.3 Bee.tick: USING draws (the nextInt(2) draw of each loop test), passes out: the bound nextInt(2) + 1 is redrawn
*> before every pass and before the test that ends the run.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAWS L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE 1 TO WS-K
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0 OR WS-K > 16
         COMPUTE WS-BOUND = FUNCTION INTEGER-PART(L-DRAW(WS-K) * 2) + 1
         IF L-COUNT < WS-BOUND
             ADD 1 TO L-COUNT
             ADD 1 TO WS-K
         ELSE
             MOVE 0 TO WS-GO
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P3E-BEE-PASSES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RAIN-COUNT.
*> 9.1 step 3: USING weather radius R, rain level, DECREASED (0/1), count out: (int)(0.225f * N * rain * rain) with N =
*> (2R + 1)^2, integer-halved when DECREASED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-RAIN                 FLOAT-LONG.
 01 L-DECREASED            BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-RAIN L-DECREASED L-COUNT.
     COMPUTE WS-N = (2 * L-R + 1) * (2 * L-R + 1)
     COMPUTE WS-F32 = 0.225 * WS-N * L-RAIN * L-RAIN
     COMPUTE L-COUNT = FUNCTION INTEGER-PART(WS-F32)
     IF L-DECREASED NOT = 0
         COMPUTE L-COUNT = FUNCTION INTEGER-PART(L-COUNT / 2)
     END-IF
     GOBACK.
 END PROGRAM P3E-RAIN-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RAIN-OFFSET.
*> 9.1 step 4: USING R, draw, offset out = nextInt(2R + 1) - R.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-DRAW L-OUT.
     COMPUTE L-OUT = FUNCTION INTEGER-PART(L-DRAW * (2 * L-R + 1)) - L-R
     GOBACK.
 END PROGRAM P3E-RAIN-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RAIN-ACCEPT.
*> 9.1 step 4: USING heightmap top y, minimum y, camera y, precipitation is RAIN, particle status (0 ALL, 1
*> DECREASED, 2 MINIMAL), act out: 0 skip, 1 spawn, 2 remember the ground and stop the whole loop (MINIMAL).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOP                  BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-CAM                  BINARY-LONG.
 01 L-IS-RAIN              BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TOP L-MIN L-CAM L-IS-RAIN L-STATUS L-ACT.
     MOVE 0 TO L-ACT
     IF L-TOP > L-MIN AND L-TOP <= L-CAM + 10 AND L-TOP >= L-CAM - 10 AND L-IS-RAIN NOT = 0
         MOVE 1 TO L-ACT
         IF L-STATUS = 2
             MOVE 2 TO L-ACT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P3E-RAIN-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RAIN-PARTICLE.
*> 9.1 step 4: USING hot ground (lava fluid, magma or a lit campfire), u, v, h, ground x, y, z, P3ER: act 72 (smoke)
*> or 71 (rain) at (gx + u, gy + h, gz + v).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOT                  BINARY-LONG.
 01 L-U                    FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-GX                   BINARY-LONG.
 01 L-GY                   BINARY-LONG.
 01 L-GZ                   BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-HOT L-U L-V L-H L-GX L-GY L-GZ P3ER.
     INITIALIZE P3ER
     MOVE 71 TO ER-ACT
     IF L-HOT NOT = 0
         MOVE 72 TO ER-ACT
     END-IF
     COMPUTE ER-X = L-GX + L-U
     COMPUTE ER-Y = L-GY + L-H
     COMPUTE ER-Z = L-GZ + L-V
     GOBACK.
 END PROGRAM P3E-RAIN-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-COLUMN-DOWN.
*> 9.2 drag_down: USING draws 1-3, P3ER: act 83 (current_down) at (0.5, 0.8, 0); the whirlpool sound (act2 1, volume 0.2 +
*> d2 * 0.2, pitch 0.9 + d3 * 0.15) when nextInt(200) == 0 (d1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 P3ER.
     INITIALIZE P3ER
     MOVE 83 TO ER-ACT
     MOVE 0.5 TO ER-X
     MOVE 0.8 TO ER-Y
     MOVE 0 TO ER-Z
     IF FUNCTION INTEGER-PART(L-D1 * 200) = 0
         MOVE 1 TO ER-ACT2
         COMPUTE ER-VOL2 = 0.2 + L-D2 * 0.2
         COMPUTE ER-PITCH2 = 0.9 + L-D3 * 0.15
     END-IF
     GOBACK.
 END PROGRAM P3E-COLUMN-DOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-COLUMN-UP.
*> 9.2 not drag_down: USING draws 1-6, P3ER: act 84 (bubble_column_up) twice, the first at (0.5, 0, 0.5) with velocity
*> (0, 0.04, 0), the second at (d1, d2, d3) (returned in x, y, z); then the upwards sound (act2 2) when nextInt(200)
*> == 0 (d4), volume 0.2 + d5 * 0.2, pitch 0.9 + d6 * 0.15.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-D4                   FLOAT-LONG.
 01 L-D5                   FLOAT-LONG.
 01 L-D6                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-D4 L-D5 L-D6 P3ER.
     INITIALIZE P3ER
     MOVE 84 TO ER-ACT
     MOVE L-D1 TO ER-X
     MOVE L-D2 TO ER-Y
     MOVE L-D3 TO ER-Z
     IF FUNCTION INTEGER-PART(L-D4 * 200) = 0
         MOVE 2 TO ER-ACT2
         COMPUTE ER-VOL2 = 0.2 + L-D5 * 0.2
         COMPUTE ER-PITCH2 = 0.9 + L-D6 * 0.15
     END-IF
     GOBACK.
 END PROGRAM P3E-COLUMN-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-CONDUIT-BOB.
*> 9.3 step 1: USING tick count, b out = (b * b + b) * 0.3 with b = Mth.sin((tick + 35) * 0.1) / 2 + 0.5; the anchor is
*> (x + 0.5, y + 1.5 + b, z + 0.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TICK L-OUT.
     COMPUTE WS-ARG = (L-TICK + 35) * 0.1
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE WS-B = WS-SIN / 2 + 0.5
     COMPUTE L-OUT = (WS-B * WS-B + WS-B) * 0.3
     GOBACK.
 END PROGRAM P3E-CONDUIT-BOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-CONDUIT-FRAME.
*> 9.3 step 2: USING draw 1 (nextInt(50) == 0), draws 2-4, offset dx, dy, dz of the frame block, P3ER: act 85 (nautilus)
*> with the velocity (-0.5 + d2 + dx, -2.0 + d3 + dy, -0.5 + d4 + dz) in x, y, z.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-D4                   FLOAT-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-D4 L-DX L-DY L-DZ P3ER.
     INITIALIZE P3ER
     IF FUNCTION INTEGER-PART(L-D1 * 50) = 0
         MOVE 85 TO ER-ACT
         COMPUTE ER-X = -0.5 + L-D2 + L-DX
         COMPUTE ER-Y = -2.0 + L-D3 + L-DY
         COMPUTE ER-Z = -0.5 + L-D4 + L-DZ
     END-IF
     GOBACK.
 END PROGRAM P3E-CONDUIT-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-CONDUIT-TARGET.
*> 9.3 step 3: USING draws 1-3, target bbWidth, bbHeight, P3ER: act 85 with the velocity ((d1 - 0.5) * (3 + w), -1 + d2 * h,
*> (d3 - 0.5) * (3 + w)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 L-W L-H P3ER.
     INITIALIZE P3ER
     MOVE 85 TO ER-ACT
     COMPUTE ER-X = (-0.5 + L-D1) * (3.0 + L-W)
     COMPUTE ER-Y = -1.0 + L-D2 * L-H
     COMPUTE ER-Z = (-0.5 + L-D3) * (3.0 + L-W)
     GOBACK.
 END PROGRAM P3E-CONDUIT-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-INK-COUNT.
*> 9.4: USING count out: 30 ink particles per burst.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 30 TO L-COUNT
     GOBACK.
 END PROGRAM P3E-INK-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-INK-DIR.
*> 9.4: USING r1, r2, x, y, z out: the direction before the body rotation (r1 * 0.6 - 0.3, -1.0, r2 * 0.6 - 0.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-X L-Y L-Z.
     COMPUTE L-X = L-R1 * 0.6 - 0.3
     MOVE -1.0 TO L-Y
     COMPUTE L-Z = L-R2 * 0.6 - 0.3
     GOBACK.
 END PROGRAM P3E-INK-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-INK-VEL.
*> 9.4: USING baby (0/1), r3, direction x, y, z, velocity x, y, z out, speed out (0.1): the sent velocity is dir * (k + r3 *
*> 2) with k 0.3 (baby 0.1), and the client's count-0 velocity is that times the speed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-BABY L-R3 L-DX L-DY L-DZ L-VX L-VY L-VZ L-SPEED.
     MOVE 0.1 TO L-SPEED
     MOVE 0.3 TO WS-K
     IF L-BABY NOT = 0
         MOVE 0.1 TO WS-K
     END-IF
     COMPUTE L-VX = L-SPEED * L-DX * (WS-K + L-R3 * 2)
     COMPUTE L-VY = L-SPEED * L-DY * (WS-K + L-R3 * 2)
     COMPUTE L-VZ = L-SPEED * L-DZ * (WS-K + L-R3 * 2)
     GOBACK.
 END PROGRAM P3E-INK-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-FISH-STEP.
*> 9.5 preamble: USING draw 1, raining at the block above, draw 2, can see sky, step out: s = 1, + 1 when draw 1 < 0.25
*> and raining, - 1 when draw 2 < 0.5 and the sky is blocked.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-RAIN                 BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-RAIN L-D2 L-SKY L-STEP.
     MOVE 1 TO L-STEP
     IF L-D1 < 0.25 AND L-RAIN NOT = 0
         ADD 1 TO L-STEP
     END-IF
     IF L-D2 < 0.5 AND L-SKY = 0
         SUBTRACT 1 FROM L-STEP
     END-IF
     GOBACK.
 END PROGRAM P3E-FISH-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-FISH-LURE-P.
*> 9.5 lure: USING timeUntilLured t, probability out: 0.15, + (20 - t) * 0.05 when t < 20, else + (40 - t) * 0.02 when
*> t < 40, else + (60 - t) * 0.01 when t < 60.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-P.
     MOVE 0.15 TO L-P
     EVALUATE TRUE
         WHEN L-T < 20
             COMPUTE L-P = L-P + (20 - L-T) * 0.05
         WHEN L-T < 40
             COMPUTE L-P = L-P + (40 - L-T) * 0.02
         WHEN L-T < 60
             COMPUTE L-P = L-P + (60 - L-T) * 0.01
     END-EVALUATE
     GOBACK.
 END PROGRAM P3E-FISH-LURE-P.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-FISH-BITE-COUNT.
*> 9.5 bite: USING bbWidth, count out = (int)(1 + bbWidth * 20).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-COUNT.
     COMPUTE L-COUNT = FUNCTION INTEGER-PART(1 + L-W * 20)
     GOBACK.
 END PROGRAM P3E-FISH-BITE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-FISH-APPROACH.
*> 9.5 approaching fish: USING fishAngle (degrees), timeUntilHooked, hook x, y, z, P3ER: a = angle * 0.017453292, (px, py,
*> pz) = (x + sin a * t * 0.1, floor(y) + 1, z + cos a * t * 0.1) in x, y, z; sin in vol, cos in pitch (the offsets).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ANGLE                FLOAT-LONG.
 01 L-T                    BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-ANGLE L-T L-X L-Y L-Z P3ER.
     INITIALIZE P3ER
     COMPUTE WS-A = L-ANGLE * 0.017453292
     MOVE 1 TO ER-ACT
     COMPUTE ER-VOL = FUNCTION SIN(WS-A)
     COMPUTE ER-PITCH = FUNCTION COS(WS-A)
     COMPUTE ER-X = L-X + ER-VOL * L-T * 0.1
     COMPUTE ER-Y = FUNCTION INTEGER(L-Y) + 1
     COMPUTE ER-Z = L-Z + ER-PITCH * L-T * 0.1
     GOBACK.
 END PROGRAM P3E-FISH-APPROACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-DOLPHIN.
*> 9.6 Dolphin.tick: USING x, y, z, view vector x, y, z, yaw (degrees), draw, sign (+1 first, -1 second), P3ER: act 86
*> (dolphin) at (x - vx * d + sign * a, y - vy, z - vz * d + sign * b), a = cos(yaw * 0.017453292) * 0.3, b = sin(...) *
*> 0.3, d = 1.2 - r * 0.7, with the table functions.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-SIGN                 BINARY-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-VX L-VY L-VZ L-YAW L-R L-SIGN P3ER.
     INITIALIZE P3ER
     COMPUTE WS-ARG = L-YAW * 0.017453292
     CALL "P2-MTH-COS" USING WS-ARG WS-COS
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE WS-D = 1.2 - L-R * 0.7
     MOVE 86 TO ER-ACT
     COMPUTE ER-X = L-X - L-VX * WS-D + L-SIGN * WS-COS * 0.3
     COMPUTE ER-Y = L-Y - L-VY
     COMPUTE ER-Z = L-Z - L-VZ * WS-D + L-SIGN * WS-SIN * 0.3
     GOBACK.
 END PROGRAM P3E-DOLPHIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SULFUR-EMIT.
*> 9.8: USING draws 1-3, P3ER: act 4 (sulfur_bubbles) at (d1, d2, d3) from the block, zero velocity.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 COPY CLP3E.
 PROCEDURE DIVISION USING L-D1 L-D2 L-D3 P3ER.
     INITIALIZE P3ER
     MOVE 4 TO ER-ACT
     MOVE L-D1 TO ER-X
     MOVE L-D2 TO ER-Y
     MOVE L-D3 TO ER-Z
     GOBACK.
 END PROGRAM P3E-SULFUR-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-SULFUR-SOUND.
*> 9.8: USING draw, play out: nextInt(10) == 0 plays NOXIOUS_GAS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PLAY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PLAY.
     MOVE 0 TO L-PLAY
     IF FUNCTION INTEGER-PART(L-DRAW * 10) = 0
         MOVE 1 TO L-PLAY
     END-IF
     GOBACK.
 END PROGRAM P3E-SULFUR-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RANDOM-X.
*> 9.9 Entity.getRandomX(s) (and getRandomZ): USING x, bbWidth, s, draw, result out = x + bbWidth * ((2 * r - 1) * s).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-W L-S L-DRAW L-OUT.
     COMPUTE L-OUT = L-X + L-W * ((2 * L-DRAW - 1) * L-S)
     GOBACK.
 END PROGRAM P3E-RANDOM-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P3E-RANDOM-Y.
*> 9.9 Entity.getRandomY(): USING y, bbHeight, draw, result out = y + bbHeight * r.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-H L-DRAW L-OUT.
     COMPUTE L-OUT = L-Y + L-H * L-DRAW
     GOBACK.
 END PROGRAM P3E-RANDOM-Y.
