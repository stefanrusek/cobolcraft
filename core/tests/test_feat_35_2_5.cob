*> Acceptance test of docs/protocol/35-worldgen-features-2 section 5 (noise-based providers: shared setup and seeding): the noise index formula in float arithmetic (example 7 values and edges), the dual_noise window size (example 8), the noise_threshold draws (example 9), the normalization factors (10 section 3.3 and 5.1.1), and the legacy seeding: the keys of seed 2345, String.hashCode and the octave source seeds of example 7.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-2-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIST2.
    05 WS-L2               BINARY-LONG OCCURS 64 TIMES.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CH                  FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-S3                  BINARY-DOUBLE.
 01 WS-SEED2               BINARY-DOUBLE UNSIGNED.
 01 WS-EDIT                PIC -(19)9.
 01 WS-TEXT                PIC X(64).
 01 WS-NAME32              PIC X(32).
 01 WS-TXT16               PIC X(16).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE -1.0 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: v -1 gives index 0 is 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.0 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: v 0 gives index 5 is 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: v 1 gives index 10 is 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3.0 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: v above 1 gives index 10 is 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -3.0 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: v below -1 gives index 0 is 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.0683039128780365 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: example 7 (0, 64, 0) is 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.4049070477485657 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: example 7 (100, 70, -50) is 7" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.22272339463233948 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: example 7 (-37, 65, 812) is 6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.048405203968286514 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: example 7 (12, 63, 12) is 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.10368889570236206 TO WS-V
     MOVE 11 TO WS-A
     CALL "F352-NOISE-INDEX" USING WS-V WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the index of 11 states: example 7 (1000, 80, -1000) is 6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value -1.0 is 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value 0.0 is 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.5 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value 0.5 is 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.9999 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value 0.9999 is 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value 1.0 is 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: dual_noise window of variety [1, 3] at slow value 2.0 is 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -0.8 TO WS-T
     MOVE 4 TO WS-A
     MOVE 4 TO WS-B
     MOVE -0.9 TO WS-V
     MOVE 0.33333334 TO WS-CH
     CALL "F352-THRESHOLD" USING XR-STATE WS-V WS-T WS-CH WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: noise_threshold below the threshold draws one nextInt(4) (2 for seed 1000, so the 3rd low state) and no float" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 100 + WS-D
     MOVE 103 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -0.8 TO WS-T
     MOVE 4 TO WS-A
     MOVE 4 TO WS-B
     MOVE 0.2101 TO WS-V
     MOVE 0.33333334 TO WS-CH
     CALL "F352-THRESHOLD" USING XR-STATE WS-V WS-T WS-CH WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: noise_threshold at or above the threshold with float 0.617 over chance 0.333 gives the default after one draw" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 100 + WS-D
     MOVE 300 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -0.8 TO WS-T
     MOVE 4 TO WS-A
     MOVE 4 TO WS-B
     MOVE 0.2101 TO WS-V
     MOVE 0.7 TO WS-CH
     CALL "F352-THRESHOLD" USING XR-STATE WS-V WS-T WS-CH WS-A WS-B WS-C WS-D
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: noise_threshold with float 0.617 under chance 0.7 draws the high index too (nextInt(4) = 2 after the float)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-C * 100 + WS-D
     MOVE 203 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: normal factor of one octave, amplitude 1, enabled is 0.8722451644522289" TO TL-CASE
     COMPUTE WS-DIFF = (WS-NF - 0.8722451644522289) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the amplitude sum of one octave enabled is 1" TO TL-CASE
     COMPUTE WS-DIFF = (WS-SUM - 1) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: legacy normalization: the rescaled sum is 0.955388882960065" TO TL-CASE
     COMPUTE WS-DIFF = (WS-SUM - 0.955388882960065) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: legacy normalization: nf is p = 0.8333333333" TO TL-CASE
     COMPUTE WS-DIFF = (WS-NF - 0.8333333333333333) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: disabled normalization: the sum is the base amplitude 2" TO TL-CASE
     COMPUTE WS-DIFF = (WS-SUM - 2) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2345 TO WS-SEED2
     CALL "F352-LEGACY-KEYS" USING WS-SEED2 WS-S1 WS-S2
     MOVE WS-S1 TO WS-EDIT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: legacy key A of seed 2345" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-1223197305642693068" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2345 TO WS-SEED2
     CALL "F352-LEGACY-KEYS" USING WS-SEED2 WS-S1 WS-S2
     MOVE WS-S2 TO WS-EDIT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: legacy key B of seed 2345" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-8087649459364435462" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "octave_0" TO WS-TEXT
     MOVE 8 TO WS-A
     CALL "F352-JAVA-HASH" USING WS-TEXT WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: String.hashCode of octave_0 is 1261148513" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 1261148513 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1261148513 TO WS-A
     MOVE -1223197305642693068 TO WS-S1
     CALL "F352-OCTAVE-SEED" USING WS-A WS-S1 WS-S2
     MOVE WS-S2 TO WS-EDIT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the seed of the first octave source (hash xor key A) is -1223197304453310635" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-1223197304453310635" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1261148513 TO WS-A
     MOVE -8087649459364435462 TO WS-S1
     CALL "F352-OCTAVE-SEED" USING WS-A WS-S1 WS-S2
     MOVE WS-S2 TO WS-EDIT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: the seed of the second noise's octave source (hash xor key B) is -8087649458443489125" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-8087649458443489125" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "N" TO TL-MODE
     MOVE -3.0 TO WS-V
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "F352-DUAL-N" USING WS-V WS-A WS-B WS-C
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: a slow value below -1 clamps to the variety minimum" TO TL-CASE
     MOVE WS-C TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.0 TO WS-V
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "F352-NORMAL-FACTOR" USING WS-A WS-V WS-B WS-NF WS-SUM
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: two octaves of amplitude 1 give the normal factor 1.1702396884564004" TO TL-CASE
     COMPUTE WS-DIFF = (WS-NF - 1.1702396884564004) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: two octaves start at 2/3 and 1/3 (the amplitude sum is 1)" TO TL-CASE
     COMPUTE WS-DIFF = (WS-SUM - 1) * 1000000000
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4096 TO WS-SEED2
     CALL "F352-LEGACY-KEYS" USING WS-SEED2 WS-S1 WS-S2
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: a positive legacy key A (seed 4096)" TO TL-CASE
     MOVE WS-S1 TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1805805761979175391" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED2
     CALL "F352-LEGACY-KEYS" USING WS-SEED2 WS-S1 WS-S2
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: a positive legacy key B (seed 0, first key -4962768465676381896)" TO TL-CASE
     MOVE WS-S2 TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "4437113781045784766" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:overworld/continents" TO WS-TEXT
     MOVE 30 TO WS-A
     CALL "F352-JAVA-HASH" USING WS-TEXT WS-A WS-B
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: a negative String.hashCode (minecraft:overworld/continents)" TO TL-CASE
     MOVE WS-B TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-367712163" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1223197305642693068 TO WS-S1
     CALL "F352-OCTAVE-SEED" USING WS-B WS-S1 WS-S2
     MOVE "acceptance US12 35-2§5 Noise-based providers: shared setup and seeding: a negative hash is widened with sign before the xor" TO TL-CASE
     MOVE WS-S2 TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1223197305304704617" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
