*> Implementation test of the shared enumerations and helpers of docs/protocol/35-worldgen-features-6-underground.md section 2 (T1254, T1256; core/src/feat-35-6-2.cob): the six directions in order with their unit
*> steps (2.1), clockwise of the four horizontal ones, the four rotations applied to a direction (vertical ones unchanged), Axis.getNegative, the random picks (nextInt(6), nextInt(4), nextInt(size): one draw each, even
*> for one element), Util.shuffle (size - 1 draws, the swap rule; F355-SHUFFLE), randomBetweenInclusive, clampedLerp, inverseLerp, clampedMap in both precisions, Mth.sin and Mth.cos as table lookups (2.2: the
*> table index of (long)(d * 10430.378350470453) and 16384 more for cos, masked to 16 bits, so negative arguments wrap), Mth.normal and ClampedNormalFloat, and Column.create with the four column kinds
*> and the range height (2.4). Section 3 (the position conventions: draw means a draw on the feature random) is covered by the draw-order cases: every random helper takes exactly the draws the document names, checked
*> against a second generator of the same seed. The level-bound helpers of 2.3 and the block entities of 2.5 need a chunk and are not part of this file.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 99.
 01 WS-S1                  BINARY-DOUBLE UNSIGNED.
 01 WS-S2                  BINARY-DOUBLE UNSIGNED.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-MEAN                FLOAT-LONG.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 10430.378350470453.
 01 WS-SHIFT               FLOAT-LONG VALUE 16384.
 01 WS-PI2                 FLOAT-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 16 TIMES.
 01 WS-REF.
    05 WS-RF               BINARY-LONG OCCURS 16 TIMES.
 01 WS-STEPS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-ST REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 6 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     COMPUTE WS-PI2 = FUNCTION PI * 2
*>   2.1 the six directions in order DOWN UP NORTH SOUTH WEST EAST with their unit steps
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         COMPUTE WS-J = WS-I + 1
         CALL "F356-DIR-STEP" USING WS-I WS-DX WS-DY WS-DZ
         IF WS-DX NOT = WS-SX(WS-J) OR WS-DY NOT = WS-SY(WS-J) OR WS-DZ NOT = WS-SZ(WS-J)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-6§2.1 the six directions DOWN UP NORTH SOUTH WEST EAST have their unit steps in that order" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   getClockWise: NORTH(2) to EAST(5), EAST to SOUTH(3), SOUTH to WEST(4), WEST to NORTH
     MOVE 2 TO WS-I
     CALL "F356-CLOCKWISE" USING WS-I WS-D
     MOVE 5 TO WS-I
     CALL "F356-CLOCKWISE" USING WS-I WS-E
     COMPUTE TL-OBSERVED-N = WS-D * 10 + WS-E
     MOVE "acceptance US12 35-6§2.1 getClockWise: NORTH to EAST, EAST to SOUTH" TO TL-CASE
     MOVE 53 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-I
     CALL "F356-CLOCKWISE" USING WS-I WS-D
     MOVE 4 TO WS-I
     CALL "F356-CLOCKWISE" USING WS-I WS-E
     COMPUTE TL-OBSERVED-N = WS-D * 10 + WS-E
     MOVE "acceptance US12 35-6§2.1 getClockWise: SOUTH to WEST, WEST to NORTH" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Axis.getNegative: X to WEST(4), Y to DOWN(0), Z to NORTH(2)
     MOVE 0 TO WS-I
     CALL "F356-AXIS-NEGATIVE" USING WS-I WS-D
     MOVE 1 TO WS-I
     CALL "F356-AXIS-NEGATIVE" USING WS-I WS-E
     MOVE 2 TO WS-I
     CALL "F356-AXIS-NEGATIVE" USING WS-I WS-V
     COMPUTE TL-OBSERVED-N = WS-D * 100 + WS-E * 10 + WS-V
     MOVE "acceptance US12 35-6§2.1 Axis.getNegative: X to WEST, Y to DOWN, Z to NORTH" TO TL-CASE
     MOVE 402 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rotation.rotate: NONE keeps; CLOCKWISE_90 the clockwise; CLOCKWISE_180 the opposite; COUNTERCLOCKWISE_90 the counter clockwise; vertical unchanged
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
             CALL "F356-ROTATE" USING WS-J WS-I WS-D
             MOVE WS-I TO WS-E
             IF WS-I >= 2
                 PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-J
*>                   one clockwise step per quarter turn: CLOCKWISE_90 once, 180 twice, COUNTERCLOCKWISE_90 three times (the same turn)
                     CALL "F356-CLOCKWISE" USING WS-E WS-V
                     MOVE WS-V TO WS-E
                 END-PERFORM
             END-IF
             IF WS-D NOT = WS-E
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 35-6§2.1 Rotation.rotate turns a horizontal direction by j quarter turns and leaves DOWN and UP unchanged (ordinal order NONE, 90, 180, counter 90)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-J
     MOVE 2 TO WS-I
     CALL "F356-ROTATE" USING WS-J WS-I WS-D
     MOVE "acceptance US12 35-6§2.1 COUNTERCLOCKWISE_90 of NORTH is WEST (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   random picks: one draw each; Direction.getRandom nextInt(6), Rotation.getRandom nextInt(4), Util.getRandom nextInt(size), also for a size of one
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "F356-RANDOM-DIR" USING XR-STATE WS-D
         MOVE 6 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-E
         IF WS-D NOT = WS-E
             ADD 1 TO WS-BAD
         END-IF
         CALL "F356-RANDOM-ROTATION" USING XR-STATE WS-D
         MOVE 4 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-E
         IF WS-D NOT = WS-E
             ADD 1 TO WS-BAD
         END-IF
         MOVE 1 TO WS-N
         CALL "F356-RANDOM-INDEX" USING XR-STATE WS-N WS-D
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-E
         IF WS-D NOT = WS-E OR WS-D NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-6§2.1 Direction.getRandom, Rotation.getRandom and Util.getRandom are one nextInt draw each in sequence (a list of one still draws)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-6§3 the helpers drew on the feature random only: both generators are at the same point after 24 draws" TO TL-CASE
     MOVE 6 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-D
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-E
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Util.shuffle: for i from size down to 2: j = nextInt(i), swap the items i - 1 and j (0-based); size - 1 draws
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-L(WS-I) = WS-I - 1
         COMPUTE WS-RF(WS-I) = WS-I - 1
     END-PERFORM
     MOVE 6 TO WS-N
     CALL "F355-SHUFFLE" USING WS-LIST WS-N WS-S1
     PERFORM VARYING WS-I FROM 6 BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-I WS-J
         COMPUTE WS-V = WS-RF(WS-I)
         COMPUTE WS-RF(WS-I) = WS-RF(WS-J + 1)
         MOVE WS-V TO WS-RF(WS-J + 1)
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-L(WS-I) NOT = WS-RF(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-6§2.1 Util.shuffle of six items swaps item i - 1 with nextInt(i) for i = 6 down to 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S1 WS-N WS-D
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-E
     MOVE "acceptance US12 35-6§2.1 a shuffle of six takes exactly five draws (the generators agree afterwards)" TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   2.2 randomBetweenInclusive(random, lo, hi) = nextInt(hi - lo + 1) + lo, one draw
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE -3 TO WS-LO
     MOVE 4 TO WS-HI
     CALL "F356-BETWEEN-INCL" USING XR-STATE WS-LO WS-HI WS-D
     MOVE 8 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-E
     COMPUTE TL-EXPECTED-N = WS-E - 3
     MOVE WS-D TO TL-OBSERVED-N
     MOVE "acceptance US12 35-6§2.2 randomBetweenInclusive(-3, 4) is nextInt(8) - 3" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   clampedLerp(t, a, b): a for t < 0, b for t > 1, else a + t (b - a); inverseLerp
     MOVE 0.25 TO WS-T
     MOVE 10 TO WS-A
     MOVE 20 TO WS-B
     CALL "F356-CLAMPED-LERP" USING WS-T WS-A WS-B WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 100
     MOVE 1250 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedLerp(0.25, 10, 20) = 12.5" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.5 TO WS-T
     CALL "F356-CLAMPED-LERP" USING WS-T WS-A WS-B WS-R
     MOVE WS-R TO TL-OBSERVED-N
     MOVE 10 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedLerp below 0 is a" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.5 TO WS-T
     CALL "F356-CLAMPED-LERP" USING WS-T WS-A WS-B WS-R
     MOVE WS-R TO TL-OBSERVED-N
     MOVE 20 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedLerp above 1 is b" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-T
     CALL "F356-CLAMPED-LERP" USING WS-T WS-A WS-B WS-R
     MOVE WS-R TO TL-OBSERVED-N
     MOVE 20 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedLerp at exactly 1 is b (not above 1: a + 1 (b - a))" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 0 TO WS-LOW
     MOVE 20 TO WS-HIGH
     CALL "F356-INVERSE-LERP" USING WS-X WS-LOW WS-HIGH WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 100
     MOVE 25 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 inverseLerp(5, 0, 20) = 0.25" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   clampedMap(v, inLo, inHi, outLo, outHi) = clampedLerp(inverseLerp(v, inLo, inHi), outLo, outHi), double and float versions (the existing FX-CLAMPED-MAP)
     MOVE 5 TO WS-X
     MOVE 10 TO WS-LOW
     MOVE 30 TO WS-HIGH
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-D
     CALL "FX-CLAMPED-MAP" USING WS-D WS-X WS-LOW WS-HIGH WS-A WS-B WS-R
     MOVE WS-R TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedMap(5, 10..30 to 0..1) clamps to 0" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-X
     CALL "FX-CLAMPED-MAP" USING WS-D WS-X WS-LOW WS-HIGH WS-A WS-B WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 100
     MOVE 50 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 clampedMap(20, 10..30 to 0..1) is 0.5" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-D
     CALL "FX-CLAMPED-MAP" USING WS-D WS-X WS-LOW WS-HIGH WS-A WS-B WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 100
     MOVE "acceptance US12 35-6§2.2 the float version of clampedMap(20, 10..30 to 0..1) is 0.5" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mth.sin / Mth.cos: the 65536-entry table of f32(sin(i / 10430.378350470453)) at (long)(d * 10430.378350470453) & 65535; cos at the argument + 16384 in the scaled domain
     MOVE 0 TO WS-BAD
     MOVE 0.7 TO WS-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1 MOVE 0 TO WS-X
             WHEN 2 MOVE 1 TO WS-X
             WHEN 3 MOVE 100.5 TO WS-X
             WHEN 4 MOVE -1 TO WS-X
             WHEN 5 MOVE -7.25 TO WS-X
             WHEN OTHER MOVE 3.14159265 TO WS-X
         END-EVALUATE
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-X WS-R
         COMPUTE WS-SCALED = WS-X * WS-SCALE
         COMPUTE WS-N = FUNCTION INTEGER-PART(WS-SCALED)
         COMPUTE WS-N = FUNCTION MOD(WS-N, 65536)
         COMPUTE WS-M = FUNCTION SIN(WS-N / WS-SCALE)
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-F
         IF FUNCTION ABS(WS-R - WS-F) > 0.0000000001
             ADD 1 TO WS-BAD
         END-IF
         CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE WS-X WS-R
         COMPUTE WS-SCALED = WS-X * WS-SCALE + WS-SHIFT
         COMPUTE WS-N = FUNCTION INTEGER-PART(WS-SCALED)
         COMPUTE WS-N = FUNCTION MOD(WS-N, 65536)
         COMPUTE WS-M = FUNCTION SIN(WS-N / WS-SCALE)
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-F
         IF FUNCTION ABS(WS-R - WS-F) > 0.0000000001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-6§2.2 Mth.sin and Mth.cos of six arguments (0, 1, 100.5, -1, -7.25, pi) are the table entries, negative indexes wrapped by the 16 bit mask" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X
     CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE WS-X WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 1000
     MOVE 1000 TO TL-EXPECTED-N
     MOVE "acceptance US12 35-6§2.2 Mth.cos(0) is 1 (index 16384 of the sine table)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Mth.normal(random, mean, deviation) = mean + (float) nextGaussian * deviation in single precision; ClampedNormalFloat clamps it
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     MOVE 3 TO WS-MEAN
     MOVE 0.5 TO WS-DEV
*>   (F351-NEXT-GAUSSIAN keeps the second value of a pair in its own storage, shared by all states: the model takes the pair first and drops its spare)
     CALL "F351-NEXT-GAUSSIAN" USING XR2-STATE WS-G
     CALL "F351-NEXT-GAUSSIAN" USING XR2-STATE WS-X
     CALL "F356-NORMAL" USING XR-STATE WS-MEAN WS-DEV WS-R
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-G WS-F
     COMPUTE WS-M = WS-F * WS-DEV
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-G
     COMPUTE WS-M = WS-MEAN + WS-G
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-F
     MOVE "acceptance US12 35-6§2.2 Mth.normal(3, 0.5) is 3 + (float) nextGaussian * 0.5 in single precision" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-R - WS-F) < 0.000000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1000 TO WS-LOW
     MOVE 1000 TO WS-HIGH
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F356-CLAMPED-NORMAL" USING XR-STATE WS-MEAN WS-DEV WS-LOW WS-HIGH WS-R
     MOVE "acceptance US12 35-6§2.2 ClampedNormalFloat.sample inside min and max is the normal value itself (within 5 deviations of the mean)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-R >= 0.5 AND WS-R <= 5.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 100 TO WS-LOW
     MOVE 200 TO WS-HIGH
     CALL "F356-CLAMPED-NORMAL" USING XR-STATE WS-MEAN WS-DEV WS-LOW WS-HIGH WS-R
     MOVE "acceptance US12 35-6§2.2 ClampedNormalFloat.sample below min is min" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -200 TO WS-LOW
     MOVE -100 TO WS-HIGH
     CALL "F356-CLAMPED-NORMAL" USING XR-STATE WS-MEAN WS-DEV WS-LOW WS-HIGH WS-R
     MOVE "acceptance US12 35-6§2.2 ClampedNormalFloat.sample above max is max" TO TL-CASE
     MOVE -100 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   2.4 Column.create: both ends a range, only the floor a ray up, only the ceiling a ray down, neither a line; the range height is ceiling - floor - 1; a negative height is refused
     MOVE 1 TO WS-FLOOR
     MOVE 1 TO WS-CEIL
     PERFORM VARYING WS-SIG FROM 1 BY 1 UNTIL WS-SIG > 4
         EVALUATE WS-SIG
             WHEN 1 MOVE 10 TO WS-LO MOVE 15 TO WS-HI MOVE 1 TO WS-FLOOR MOVE 1 TO WS-CEIL
             WHEN 2 MOVE 10 TO WS-LO MOVE 15 TO WS-HI MOVE 1 TO WS-FLOOR MOVE 0 TO WS-CEIL
             WHEN 3 MOVE 10 TO WS-LO MOVE 15 TO WS-HI MOVE 0 TO WS-FLOOR MOVE 1 TO WS-CEIL
             WHEN OTHER MOVE 10 TO WS-LO MOVE 15 TO WS-HI MOVE 0 TO WS-FLOOR MOVE 0 TO WS-CEIL
         END-EVALUATE
         CALL "F356-COLUMN-CREATE" USING WS-FLOOR WS-LO WS-CEIL WS-HI WS-KIND WS-HEIGHT WS-OK
         MOVE WS-SIG TO WS-D
         EVALUATE WS-SIG
             WHEN 1
                 MOVE "acceptance US12 35-6§2.4 Column.create(10, 15) is a range of height 4" TO TL-CASE
                 COMPUTE TL-EXPECTED-N = 1 * 10 + 4
                 COMPUTE TL-OBSERVED-N = WS-KIND * 10 + WS-HEIGHT
             WHEN 2
                 MOVE "acceptance US12 35-6§2.4 Column.create with only a floor is a ray up (kind 2, no height)" TO TL-CASE
                 MOVE 20 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-KIND * 10 + WS-HEIGHT + 1
                 SUBTRACT 1 FROM TL-OBSERVED-N
             WHEN 3
                 MOVE "acceptance US12 35-6§2.4 Column.create with only a ceiling is a ray down (kind 3, no height)" TO TL-CASE
                 MOVE 30 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-KIND * 10 + WS-HEIGHT + 1
                 SUBTRACT 1 FROM TL-OBSERVED-N
             WHEN OTHER
                 MOVE "acceptance US12 35-6§2.4 Column.create with neither is a line (kind 4, no height)" TO TL-CASE
                 MOVE 40 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-KIND * 10 + WS-HEIGHT + 1
                 SUBTRACT 1 FROM TL-OBSERVED-N
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 1 TO WS-FLOOR WS-CEIL
     MOVE 10 TO WS-LO
     MOVE 10 TO WS-HI
     CALL "F356-COLUMN-CREATE" USING WS-FLOOR WS-LO WS-CEIL WS-HI WS-KIND WS-HEIGHT WS-OK
     MOVE "acceptance US12 35-6§2.4 a range with ceiling = floor has height -1: refused (IllegalArgumentException)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-HI
     CALL "F356-COLUMN-CREATE" USING WS-FLOOR WS-LO WS-CEIL WS-HI WS-KIND WS-HEIGHT WS-OK
     MOVE "acceptance US12 35-6§2.4 a range with ceiling = floor + 1 has height 0 and is accepted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OK * (1 - WS-HEIGHT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-35-6-2.
