*> Test of the named and the noise based block state providers (docs/protocol/35-worldgen-features-2 sections 4.1 and 5, worked examples 7 to 9; core/src/feat-prov-noise.cob and
*> feat-data.cob): a provider named by a string is read from worldgen/block_state_provider, the noise, dual_noise and noise_threshold providers are compiled and sampled
*> (the legacy random source seeding of 5.2, the index formula of 5.4, the sub-palette of 5.5, the draws of 5.6), and what the compiler cannot place whole is refused.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-PROV-NOISE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY NOISE.
 COPY XORO.
 COPY JSONDOC.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-KEY                 PIC X(80).
 01 WS-TEXT                PIC X(64).
 01 WS-DOC-TEXT            PIC X(512).
 01 WS-DOC-LEN             BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-PV2                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 2345.
 01 WS-OCT                 BINARY-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-HANDLE2             BINARY-LONG.
 01 WS-PERLIN              BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-SCALE-TEXT          PIC X(32) VALUE Z"0.02083333395421505".
 01 WS-ONE-F               FLOAT-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-EXPECTED            FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-THRESHOLD           FLOAT-LONG.
 01 WS-CHANCE-TEXT         PIC X(32) VALUE Z"0.33333334".
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-TEXT-OUT            PIC X(120).
 01 WS-DIGIT               PIC 9.
 01 WS-OBS                 PIC X(120).
 01 WS-SEED-X              BINARY-DOUBLE UNSIGNED VALUE 77.
 01 WS-NAMES.
    05 WS-NAME              PIC X(30) OCCURS 13 TIMES.
*> the states of the fixtures by index: the dual_noise palette, the high and the low states
 01 WS-DUAL-STATES.
    05 FILLER BINARY-LONG VALUE 113.
    05 FILLER BINARY-LONG VALUE 104.
    05 FILLER BINARY-LONG VALUE 103.
    05 FILLER BINARY-LONG VALUE 105.
    05 FILLER BINARY-LONG VALUE 102.
    05 FILLER BINARY-LONG VALUE 111.
    05 FILLER BINARY-LONG VALUE 110.
    05 FILLER BINARY-LONG VALUE 112.
 01 WS-DUAL-TABLE REDEFINES WS-DUAL-STATES.
    05 WS-DUAL              BINARY-LONG OCCURS 8 TIMES.
 01 WS-HIGH-STATES.
    05 FILLER BINARY-LONG VALUE 103.
    05 FILLER BINARY-LONG VALUE 105.
    05 FILLER BINARY-LONG VALUE 110.
    05 FILLER BINARY-LONG VALUE 111.
 01 WS-HIGH-TABLE REDEFINES WS-HIGH-STATES.
    05 WS-HIGH              BINARY-LONG OCCURS 4 TIMES.
 01 WS-LOW-STATES.
    05 FILLER BINARY-LONG VALUE 107.
    05 FILLER BINARY-LONG VALUE 106.
    05 FILLER BINARY-LONG VALUE 109.
    05 FILLER BINARY-LONG VALUE 108.
 01 WS-LOW-TABLE REDEFINES WS-LOW-STATES.
    05 WS-LOW               BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 15 TO CB-BLOCK-COUNT
     MOVE 400 TO CB-STATE-COUNT
     MOVE 11 TO CB-EPOCH
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "dandelion" TO WS-NAME(1)
     MOVE "poppy" TO WS-NAME(2)
     MOVE "allium" TO WS-NAME(3)
     MOVE "azure_bluet" TO WS-NAME(4)
     MOVE "red_tulip" TO WS-NAME(5)
     MOVE "orange_tulip" TO WS-NAME(6)
     MOVE "white_tulip" TO WS-NAME(7)
     MOVE "pink_tulip" TO WS-NAME(8)
     MOVE "oxeye_daisy" TO WS-NAME(9)
     MOVE "cornflower" TO WS-NAME(10)
     MOVE "lily_of_the_valley" TO WS-NAME(11)
     MOVE "short_grass" TO WS-NAME(12)
     MOVE "unused" TO WS-NAME(13)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         COMPUTE WS-J = WS-I + 2
         MOVE SPACES TO CB-KEY(WS-J)
         STRING "minecraft:" FUNCTION TRIM(WS-NAME(WS-I)) DELIMITED BY SIZE INTO CB-KEY(WS-J)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1 + 100
         MOVE 0 TO CB-SOLID(WS-I)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     CALL "NOISE-RESET"

*>   the 32 bit Java string hash of the octave names (5.2)
     MOVE SPACES TO WS-TEXT
     MOVE "octave_0" TO WS-TEXT
     MOVE 8 TO WS-LEN
     CALL "FP-HASH" USING WS-TEXT WS-LEN WS-HASH
     MOVE "acceptance 35-2§5.2 hash(octave_0) is 1261148513" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE 1261148513 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE "octave_-3" TO WS-TEXT
     MOVE 9 TO WS-LEN
     CALL "FP-HASH" USING WS-TEXT WS-LEN WS-HASH
     MOVE "acceptance 35-2§5.2 hash(octave_-3) wraps to a negative int (Java String.hashCode)" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE 440898197 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-TEXT
     MOVE "polygenelubricants" TO WS-TEXT
     MOVE 18 TO WS-LEN
     CALL "FP-HASH" USING WS-TEXT WS-LEN WS-HASH
     MOVE "acceptance 35-2§5.2 hash(polygenelubricants) is the smallest int (the 32 bit wrap goes negative)" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE -2147483648 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Example 7: the noise of flower_flower_forest: one octave, two layers of amplitude 5/6
     MOVE 0 TO WS-OCT
     MOVE 0.955388882960065 TO WS-AMP
     CALL "NOISE-CREATE-LEGACY" USING WS-SEED WS-OCT WS-AMP WS-HANDLE
     MOVE "acceptance 35-2§5.2 the noise has one octave: two layers" TO TL-CASE
     MOVE NZ-LAYER-N(WS-HANDLE) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE NZ-L-PERLIN(NZ-FIRST(WS-HANDLE)) TO WS-PERLIN
     MOVE "acceptance 35-2§5.2 example 7 first octave offsets and permutation" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-DIFF = FUNCTION ABS(NZ-OX(WS-PERLIN) - 194.48694237469968)
         + FUNCTION ABS(NZ-OY(WS-PERLIN) - 162.67908262575148) + FUNCTION ABS(NZ-OZ(WS-PERLIN) - 181.1821062694335)
     IF WS-DIFF < 0.000001 AND NZ-PERM(WS-PERLIN, 1) = 133 AND NZ-PERM(WS-PERLIN, 2) = 15 AND NZ-PERM(WS-PERLIN, 3) = 31
             AND NZ-PERM(WS-PERLIN, 4) = 153 AND NZ-PERM(WS-PERLIN, 5) = 13 AND NZ-PERM(WS-PERLIN, 6) = 119
             AND NZ-PERM(WS-PERLIN, 7) = 73 AND NZ-PERM(WS-PERLIN, 8) = 111
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-J = NZ-FIRST(WS-HANDLE) + 1
     MOVE NZ-L-PERLIN(WS-J) TO WS-PERLIN
     MOVE "acceptance 35-2§5.2 example 7 second octave (the B factory) offsets and permutation" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-DIFF = FUNCTION ABS(NZ-OX(WS-PERLIN) - 253.42363124452393)
         + FUNCTION ABS(NZ-OY(WS-PERLIN) - 215.92054525757948) + FUNCTION ABS(NZ-OZ(WS-PERLIN) - 28.676999837367106)
     IF WS-DIFF < 0.000001 AND NZ-PERM(WS-PERLIN, 1) = 250 AND NZ-PERM(WS-PERLIN, 2) = 128 AND NZ-PERM(WS-PERLIN, 3) = 186
             AND NZ-PERM(WS-PERLIN, 4) = 9 AND NZ-PERM(WS-PERLIN, 5) = 5 AND NZ-PERM(WS-PERLIN, 6) = 13
             AND NZ-PERM(WS-PERLIN, 7) = 64 AND NZ-PERM(WS-PERLIN, 8) = 209
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 35-2§5.2 example 7 the layer amplitude is 5/6 (float) and the second layer is 1.0181268882175227 times faster" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-DIFF = FUNCTION ABS(NZ-L-AMP(NZ-FIRST(WS-HANDLE)) - 0.8333333) + FUNCTION ABS(NZ-L-FREQ(NZ-FIRST(WS-HANDLE)) - 1)
         + FUNCTION ABS(NZ-L-FREQ(WS-J) - 1.0181268882175227)
     IF WS-DIFF < 0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the noise values and the indexes of example 7 (scale 0.020833334 widened to 0.02083333395421505, 11 states)
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-SCALE-TEXT WS-SCALE
     MOVE 0 TO WS-MODE
     MOVE 11 TO WS-SIZE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE 0 TO WS-X
                 MOVE 64 TO WS-Y
                 MOVE 0 TO WS-Z
                 MOVE -0.0683039128780365 TO WS-EXPECTED
                 MOVE 5 TO WS-N
             WHEN 2
                 MOVE 100 TO WS-X
                 MOVE 70 TO WS-Y
                 MOVE -50 TO WS-Z
                 MOVE 0.4049070477485657 TO WS-EXPECTED
                 MOVE 7 TO WS-N
             WHEN 3
                 MOVE -37 TO WS-X
                 MOVE 65 TO WS-Y
                 MOVE 812 TO WS-Z
                 MOVE 0.22272339463233948 TO WS-EXPECTED
                 MOVE 6 TO WS-N
             WHEN 4
                 MOVE 12 TO WS-X
                 MOVE 63 TO WS-Y
                 MOVE 12 TO WS-Z
                 MOVE 0.048405203968286514 TO WS-EXPECTED
                 MOVE 5 TO WS-N
             WHEN OTHER
                 MOVE 1000 TO WS-X
                 MOVE 80 TO WS-Y
                 MOVE -1000 TO WS-Z
                 MOVE 0.10368889570236206 TO WS-EXPECTED
                 MOVE 6 TO WS-N
         END-EVALUATE
         CALL "FP-NOISE-AT" USING WS-HANDLE WS-SCALE WS-MODE WS-X WS-Y WS-Z WS-V
         MOVE WS-I TO WS-DIGIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance 35-2§6 example 7 noise value of position " WS-DIGIT DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         COMPUTE WS-DIFF = FUNCTION ABS(WS-V - WS-EXPECTED)
         IF WS-DIFF < 0.000001
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
         MOVE SPACES TO TL-CASE
         STRING "acceptance 35-2§5.4 example 7 state index of position " WS-DIGIT DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-INDEX TO TL-OBSERVED-N
         MOVE WS-N TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the index edges: -1 gives 0, 0 gives 5, 1 and above give size - 1
     MOVE -1.0 TO WS-V
     CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
     MOVE WS-INDEX TO WS-N
     MOVE 0.0 TO WS-V
     CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
     COMPUTE WS-N = WS-N * 100 + WS-INDEX
     MOVE 3.0 TO WS-V
     CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
     COMPUTE WS-N = WS-N * 100 + WS-INDEX
     MOVE "acceptance 35-2§5.4 example 7 index edges: -1 gives 0, 0 gives 5, 1 and above give 10" TO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 510 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the named provider compiled from the registry: the state of each position of example 7
     MOVE "minecraft:noise_flower_forest" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§4.1 a named provider compiles whole (provider row, no bad flag)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV > 0 AND FD-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     MOVE 100 TO WS-X
     MOVE 70 TO WS-Y
     MOVE -50 TO WS-Z
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
     MOVE "acceptance 35-2§6 example 7 the provider at (100, 70, -50) is pink_tulip (the eighth state)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 10 + WS-OK
     MOVE 1091 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a provider named inside a provider (rule_based fallback) is compiled in its own document
     MOVE "minecraft:nested" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV2
     MOVE 0 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV2 WS-X WS-Y WS-Z WS-STATE WS-OK
     MOVE "acceptance 35-2§4.1 a named provider inside a named provider: the fallback gives orange_tulip at the origin" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 10 + WS-OK
     MOVE 1071 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a name that is no provider, a provider that names itself, and bad fields are refused
     CALL "FD-RESET"
     MOVE "minecraft:no_such_provider" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§4.1 an unknown provider name is refused with the bad flag" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-PV * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     CALL "FD-RESET"
     MOVE "minecraft:broken" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§4.1 a provider file that is not valid JSON is refused with the bad flag" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-PV * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE "minecraft:loop_a" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§4.1 a provider that names itself ends at the depth limit with the bad flag" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "FD-RESET"
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:bad_octaves" TO WS-KEY
             WHEN 2
                 MOVE "minecraft:bad_scale" TO WS-KEY
             WHEN 3
                 MOVE "minecraft:bad_states" TO WS-KEY
             WHEN 4
                 MOVE "minecraft:bad_state_name" TO WS-KEY
             WHEN OTHER
                 MOVE "minecraft:bad_variety" TO WS-KEY
         END-EVALUATE
         CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
         MOVE SPACES TO TL-CASE
         STRING "acceptance 35-2§5.1 a noise provider the compiler cannot place whole sets the bad flag: " FUNCTION TRIM(WS-KEY)
             DELIMITED BY SIZE INTO TL-CASE
         MOVE FD-BAD TO TL-OBSERVED-N
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   dual_noise (example 8): the slow noise of octave -10 at the three positions, n = 2 in all of them
     CALL "FD-RESET"
     CALL "NOISE-RESET"
     MOVE -10 TO WS-OCT
     CALL "NOISE-CREATE-LEGACY" USING WS-SEED WS-OCT WS-AMP WS-HANDLE
     MOVE 1 TO WS-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1
                 MOVE 0 TO WS-X
                 MOVE 64 TO WS-Y
                 MOVE 0 TO WS-Z
                 MOVE 0.0908 TO WS-EXPECTED
             WHEN 2
                 MOVE 100 TO WS-X
                 MOVE 70 TO WS-Y
                 MOVE -50 TO WS-Z
                 MOVE 0.0540 TO WS-EXPECTED
             WHEN OTHER
                 MOVE -37 TO WS-X
                 MOVE 65 TO WS-Y
                 MOVE 812 TO WS-Z
                 MOVE 0.0364 TO WS-EXPECTED
         END-EVALUATE
         CALL "FP-NOISE-AT" USING WS-HANDLE WS-ONE-F WS-MODE WS-X WS-Y WS-Z WS-V
         MOVE WS-I TO WS-DIGIT
         MOVE SPACES TO TL-CASE
         STRING "acceptance 35-2§6 example 8 slow noise value of position " WS-DIGIT DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         COMPUTE WS-DIFF = FUNCTION ABS(WS-V - WS-EXPECTED)
         IF WS-DIFF < 0.00006
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "minecraft:dual_meadow" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE 0 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
*>   the oracle of 5.5 over the same noises: n = 2, L = [states[index(slow(pos))], states[index(slow(pos + (54545, 0, 34234)))]], the main noise picks
     MOVE 8 TO WS-SIZE
     CALL "FP-NOISE-AT" USING WS-HANDLE WS-ONE-F WS-MODE WS-X WS-Y WS-Z WS-V
     CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
     MOVE WS-INDEX TO WS-N
     MOVE 54545 TO WS-X
     MOVE 34234 TO WS-Z
     CALL "FP-NOISE-AT" USING WS-HANDLE WS-ONE-F WS-MODE WS-X WS-Y WS-Z WS-V
     CALL "FP-INDEX" USING WS-V WS-SIZE WS-INDEX
     MOVE "acceptance 35-2§5.5 dual_noise: the state is one of the two sub-palette entries the slow noise chose (short_grass .. lily_of_the_valley)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OK = 1 AND (WS-STATE = WS-DUAL(WS-N + 1) OR WS-STATE = WS-DUAL(WS-INDEX + 1))
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   noise_threshold (example 9): the noise value of the two positions, the draws of the three branches
     CALL "NOISE-RESET"
     CALL "FD-RESET"
     MOVE "minecraft:threshold_plain" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§5.6 a noise_threshold provider compiles whole" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV > 0 AND FD-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-CHANCE-TEXT WS-CHANCE
     MOVE 0 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
*>   the oracle: the same draws from a second state with the same seed: nextFloat, then nextInt(4) when the float is under the chance
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     MOVE "acceptance 35-2§5.6 example 9 the threshold provider at the origin is a high state or the default, by the draws" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-F
     IF WS-F < WS-CHANCE
         MOVE 4 TO WS-SIZE
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-SIZE WS-N
         MOVE WS-HIGH(WS-N + 1) TO WS-INDEX
     ELSE
         MOVE 102 TO WS-INDEX
     END-IF
     IF WS-OK = 1 AND WS-STATE = WS-INDEX
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the low branch (threshold 1.0): one nextInt(4), the tulips
     CALL "FD-RESET"
     MOVE "minecraft:threshold_low" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     MOVE 4 TO WS-SIZE
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-SIZE WS-N
     MOVE WS-LOW(WS-N + 1) TO WS-INDEX
     MOVE "acceptance 35-2§5.6 below the threshold: low_states[nextInt(4)], one draw" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-INDEX TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   high_chance 0: the float is drawn and the default state is the answer
     CALL "FD-RESET"
     MOVE "minecraft:threshold_default" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
     MOVE "acceptance 35-2§5.6 high_chance 0 above the threshold: the default state (dandelion), one float draw" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 102 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   high_chance 1: always the high branch, two draws (the float, then the int)
     CALL "FD-RESET"
     MOVE "minecraft:threshold_high" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     CALL "FR-PROV-STATE" USING XR-STATE WS-PV WS-X WS-Y WS-Z WS-STATE WS-OK
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED-X
     CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-F
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-SIZE WS-N
     MOVE WS-HIGH(WS-N + 1) TO WS-INDEX
     MOVE "acceptance 35-2§5.6 high_chance 1: a high state after the float and the int draw" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-INDEX TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a block id string is a state (BlockState.CODEC): weighted entries by bare id and by {"id"}
     CALL "FD-RESET"
     MOVE "minecraft:weighted_named" TO WS-KEY
     CALL "FD-PROV-NAMED" USING WS-KEY WS-PV
     MOVE "acceptance 35-2§4.1 a weighted provider with a bare block id and an id object compiles whole" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV > 0 AND FD-BAD = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a provider node that is a string inside a feature document: FD-PROV-NODE reads the named one
     CALL "FD-RESET"
     MOVE '"minecraft:noise_flower_forest"' TO WS-DOC-TEXT
     MOVE 31 TO WS-DOC-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-DOC-TEXT WS-DOC-LEN
     MOVE 1 TO WS-N
     CALL "FD-PROV-NODE" USING JSON-DOC WS-N WS-PV
     MOVE "acceptance 35-2§4.1 FD-PROV-NODE on a string node reads the named provider" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV > 0 AND FD-BAD = 0 AND PV-TYPE(WS-PV) = 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-PROV-NOISE.
