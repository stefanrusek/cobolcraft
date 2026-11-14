*> Test of the biome info noise and the two placement counts that read it (docs/protocol/10 section 3.5 SimplexNoise(r, true) with the LegacyRandomSource of seed 2345,
*> 35-1 sections 7.9 and 7.10): F351-SIMPLEX against an independent evaluation of the formula of 10 section 3.5 over the permutation the construction of 3.1 gives, and the counts
*> noise_threshold_count (below_noise when the noise at (x / 200, z / 200) is below noise_level, else above_noise) and noise_based_count (ceil((noise + offset) * ratio))
*> compiled from JSON and run by FR-MODIFY.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-NOISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat-veg".
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-PERM.
    05 WS-P                BINARY-LONG OCCURS 256 TIMES.
 01 WS-JSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED-2345           BINARY-DOUBLE UNSIGNED VALUE 2345.
 01 WS-BITS                BINARY-LONG.
 01 WS-DUMMY               BINARY-DOUBLE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-EXPECT              FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG VALUE 0.3660254037844386.
 01 WS-G2                  FLOAT-LONG VALUE 0.21132486540518713.
 01 WS-S                   FLOAT-LONG.
 01 WS-FI                  FLOAT-LONG.
 01 WS-FJ                  FLOAT-LONG.
 01 WS-II                  BINARY-LONG.
 01 WS-JJ                  BINARY-LONG.
 01 WS-TT                  FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-Y2                  FLOAT-LONG.
 01 WS-I1                  BINARY-LONG.
 01 WS-J1                  BINARY-LONG.
 01 WS-N0                  FLOAT-LONG.
 01 WS-N1                  FLOAT-LONG.
 01 WS-N2                  FLOAT-LONG.
 01 WS-CC                  FLOAT-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POS.
    05 WS-O OCCURS 4096 TIMES.
       10 WS-OX            BINARY-LONG.
       10 WS-OY            BINARY-LONG.
       10 WS-OZ            BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-NOISE               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TWO-HUNDRED         FLOAT-LONG VALUE 200.
 01 WS-LEVEL               FLOAT-LONG VALUE -0.8.
 01 WS-CEIL                FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG VALUE 160.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.3.
 01 WS-FACTOR              FLOAT-LONG VALUE 80.
 01 WS-WANT-N              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the permutation of the construction: three nextDouble draws (next(26), next(27) each), then for i = 0..255 j = nextInt(256 - i) and a swap of i and i + j
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-P(WS-I) = WS-I - 1
     END-PERFORM
     CALL "JRAND-SET-SEED" USING WS-JSEED WS-SEED-2345
     PERFORM 3 TIMES
         MOVE 26 TO WS-BITS
         CALL "JRAND-NEXT" USING WS-JSEED WS-BITS WS-DUMMY
         MOVE 27 TO WS-BITS
         CALL "JRAND-NEXT" USING WS-JSEED WS-BITS WS-DUMMY
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-BOUND = 256 - WS-I
         CALL "JRAND-NEXT-INT-BOUND" USING WS-JSEED WS-BOUND WS-J
         COMPUTE WS-K = WS-I + WS-J + 1
         MOVE WS-P(WS-I + 1) TO WS-T
         MOVE WS-P(WS-K) TO WS-P(WS-I + 1)
         MOVE WS-T TO WS-P(WS-K)
     END-PERFORM
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 39
         COMPUTE WS-X = (WS-I * 37 - 700) / 53.0
         COMPUTE WS-Y = (WS-I * 91 - 1500) / 71.0 + WS-I / 7.0
         PERFORM EVALUATE-SIMPLEX
         CALL "F351-SIMPLEX" USING WS-X WS-Y WS-R
         COMPUTE WS-DIFF = FUNCTION ABS(WS-R - WS-EXPECT)
         IF WS-DIFF > 0.000001
             ADD 1 TO WS-BAD
         END-IF
         IF FUNCTION ABS(WS-R) > WS-MAX
             MOVE FUNCTION ABS(WS-R) TO WS-MAX
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-1§7.9 biome info noise: 40 samples (negative coordinates included) equal the formula of 10 section 3.5 over the permutation of 3.1" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-1§7.9 biome info noise: no sample reaches 1 in magnitude" TO TL-CASE
     IF WS-MAX < 1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-1§7.9 biome info noise: the noise at the origin is 0" TO TL-CASE
     MOVE 0 TO WS-X WS-Y
     CALL "F351-SIMPLEX" USING WS-X WS-Y WS-R
     COMPUTE TL-OBSERVED-N = WS-R * 1000000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the counts, compiled from JSON
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 7 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 1 TO CB-SOLID(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE "minecraft:noise_threshold" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-1§7.10 noise_threshold_count: the placed feature compiles (status 1)" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 29
         COMPUTE WS-LX = WS-I * 173 - 2500
         COMPUTE WS-LZ = 4100 - WS-I * 211
         COMPUTE WS-DX = WS-LX / 200.0
         COMPUTE WS-DZ = WS-LZ / 200.0
         MOVE WS-DX TO WS-X
         MOVE WS-DZ TO WS-Y
         PERFORM EVALUATE-SIMPLEX
         MOVE WS-EXPECT TO WS-NOISE
         MOVE 4 TO WS-WANT-N
         IF WS-NOISE < WS-LEVEL
             MOVE 15 TO WS-WANT-N
         END-IF
         MOVE 64 TO WS-T
         CALL "FR-MODIFY" USING XR-STATE WS-M WS-TOP WS-LX WS-T WS-LZ WS-COUNT WS-POS
         IF WS-COUNT NOT = WS-WANT-N
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-1§7.10 noise_threshold_count: 30 positions get below_noise 15 or above_noise 4 by the noise at (x / 200, z / 200), no draw" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:noise_based" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-1§7.9 noise_based_count: the placed feature compiles (status 1)" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 29
         COMPUTE WS-LX = WS-I * 173 - 2500
         COMPUTE WS-LZ = 4100 - WS-I * 211
         COMPUTE WS-DX = WS-LX / 80.0
         COMPUTE WS-DZ = WS-LZ / 80.0
         MOVE WS-DX TO WS-X
         MOVE WS-DZ TO WS-Y
         PERFORM EVALUATE-SIMPLEX
         COMPUTE WS-NOISE = (WS-EXPECT + WS-OFFSET) * WS-RATIO
         COMPUTE WS-WANT-N = FUNCTION INTEGER(WS-NOISE)
         IF WS-NOISE > WS-WANT-N
             ADD 1 TO WS-WANT-N
         END-IF
         IF WS-WANT-N < 0
             MOVE 0 TO WS-WANT-N
         END-IF
         MOVE 64 TO WS-T
         CALL "FR-MODIFY" USING XR-STATE WS-M WS-TOP WS-LX WS-T WS-LZ WS-COUNT WS-POS
         COMPUTE WS-K = WS-COUNT - WS-WANT-N
         IF WS-K > 1 OR WS-K < -1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-1§7.9 noise_based_count: 30 positions repeat ceil((noise + 0.3) * 160) times (within one of the decimal reference), none for a count at or below 0" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> the formula of 10 section 3.5 in decimal arithmetic over WS-PERM: noise at (WS-X, WS-Y) in WS-EXPECT
 EVALUATE-SIMPLEX.
     COMPUTE WS-S = (WS-X + WS-Y) * WS-F2
     COMPUTE WS-FI = FUNCTION INTEGER(WS-X + WS-S)
     COMPUTE WS-FJ = FUNCTION INTEGER(WS-Y + WS-S)
     MOVE WS-FI TO WS-II
     MOVE WS-FJ TO WS-JJ
     COMPUTE WS-TT = (WS-FI + WS-FJ) * WS-G2
     COMPUTE WS-X0 = WS-X - (WS-FI - WS-TT)
     COMPUTE WS-Y0 = WS-Y - (WS-FJ - WS-TT)
     IF WS-X0 > WS-Y0
         MOVE 1 TO WS-I1
         MOVE 0 TO WS-J1
     ELSE
         MOVE 0 TO WS-I1
         MOVE 1 TO WS-J1
     END-IF
     COMPUTE WS-X1 = WS-X0 - WS-I1 + WS-G2
     COMPUTE WS-Y1 = WS-Y0 - WS-J1 + WS-G2
     COMPUTE WS-X2 = WS-X0 - 1 + 2 * WS-G2
     COMPUTE WS-Y2 = WS-Y0 - 1 + 2 * WS-G2
     COMPUTE WS-K = FUNCTION MOD(WS-II, 256)
     COMPUTE WS-T = FUNCTION MOD(WS-JJ, 256)
     COMPUTE WS-G = FUNCTION MOD(WS-P(FUNCTION MOD(WS-K + WS-P(WS-T + 1), 256) + 1), 12)
     MOVE WS-X0 TO WS-QX
     MOVE WS-Y0 TO WS-QY
     PERFORM CORNER
     MOVE WS-CC TO WS-N0
     COMPUTE WS-T = FUNCTION MOD(WS-JJ + WS-J1, 256)
     COMPUTE WS-G = FUNCTION MOD(WS-P(FUNCTION MOD(WS-K + WS-I1 + WS-P(WS-T + 1), 256) + 1), 12)
     MOVE WS-X1 TO WS-QX
     MOVE WS-Y1 TO WS-QY
     PERFORM CORNER
     MOVE WS-CC TO WS-N1
     COMPUTE WS-T = FUNCTION MOD(WS-JJ + 1, 256)
     COMPUTE WS-G = FUNCTION MOD(WS-P(FUNCTION MOD(WS-K + 1 + WS-P(WS-T + 1), 256) + 1), 12)
     MOVE WS-X2 TO WS-QX
     MOVE WS-Y2 TO WS-QY
     PERFORM CORNER
     MOVE WS-CC TO WS-N2
     COMPUTE WS-EXPECT = 70 * (WS-N0 + WS-N1 + WS-N2).

*> the contribution of the corner (WS-QX, WS-QY) with the gradient WS-G: 0 below c = 0, else c^4 * (gx x + gy y)
 CORNER.
     COMPUTE WS-CC = 0.5 - WS-QX * WS-QX - WS-QY * WS-QY
     IF WS-CC < 0
         MOVE 0 TO WS-CC
     ELSE
         PERFORM GRADIENT
         COMPUTE WS-CC = WS-CC * WS-CC * WS-CC * WS-CC * (WS-GX * WS-QX + WS-GY * WS-QY)
     END-IF.

*> the first twelve entries of the gradient table of 10 section 3.1, x and y components
 GRADIENT.
     EVALUATE WS-G
         WHEN 0 MOVE 1 TO WS-GX MOVE 1 TO WS-GY
         WHEN 1 MOVE -1 TO WS-GX MOVE 1 TO WS-GY
         WHEN 2 MOVE 1 TO WS-GX MOVE -1 TO WS-GY
         WHEN 3 MOVE -1 TO WS-GX MOVE -1 TO WS-GY
         WHEN 4 MOVE 1 TO WS-GX MOVE 0 TO WS-GY
         WHEN 5 MOVE -1 TO WS-GX MOVE 0 TO WS-GY
         WHEN 6 MOVE 1 TO WS-GX MOVE 0 TO WS-GY
         WHEN 7 MOVE -1 TO WS-GX MOVE 0 TO WS-GY
         WHEN 8 MOVE 0 TO WS-GX MOVE 1 TO WS-GY
         WHEN 9 MOVE 0 TO WS-GX MOVE -1 TO WS-GY
         WHEN 10 MOVE 0 TO WS-GX MOVE 1 TO WS-GY
         WHEN OTHER MOVE 0 TO WS-GX MOVE -1 TO WS-GY
     END-EVALUATE.
 END PROGRAM TEST-FEAT-NOISE.
 COPY CORETEST.
