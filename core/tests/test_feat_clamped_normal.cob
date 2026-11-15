*> Test of the clamped_normal int provider (docs/protocol/23 section 7: (int) clamp(mean + (float) nextGaussian * deviation, min, max), one Gaussian draw, single precision; core/src/feat-data.cob
*> FD-J-IP and feat-run.cob FR-INT-SAMPLE) as the offset modifier of pointed_dripstone uses it, and of F351-GAUSSIAN-RESET (the spare of the Gaussian source is dropped, so that a chunk's draws do
*> not depend on the chunks generated before it in the process). The samples of 60 seeds equal a model in this test: the Gaussian of a second source, the three float steps rounded to single
*> precision one by one, the clamp, and the truncation toward zero (FUNCTION INTEGER-PART), for a provider that clamps at both ends and one that rarely does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-CLAMPED-NORMAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY JSONDOC.
 01 WS-TEXT                PIC X(512).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-P.
    05 WS-V                BINARY-LONG OCCURS 4 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-G2                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-MEANS.
    05 FILLER FLOAT-LONG VALUE 0.5.
    05 FILLER FLOAT-LONG VALUE 0.6.
 01 WS-MEAN-T REDEFINES WS-MEANS.
    05 WS-MEAN             FLOAT-LONG OCCURS 2 TIMES.
 01 WS-DEVS.
    05 FILLER FLOAT-LONG VALUE 6.
    05 FILLER FLOAT-LONG VALUE 3.
 01 WS-DEV-T REDEFINES WS-DEVS.
    05 WS-DEVIATION        FLOAT-LONG OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "FD-RESET"
     MOVE '{"type": "minecraft:clamped_normal", "mean": 0.5, "deviation": 6.0, "min_inclusive": -3, "max_inclusive": 3}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7 a clamped_normal provider compiles: kind 8, the bounds, mean and deviation (millionths) in the pool" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OK * 1000000 + WS-V(1) * 100000 + (WS-V(2) + 10) * 1000 + (WS-V(3) + 10) * 10 + FD-POOL-COUNT
     COMPUTE TL-EXPECTED-N = 1000000 + 800000 + 7000 + 130 + 2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 23§7 the pool holds 500000 and 6000000" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FD-POOL(WS-V(4)) + FD-POOL(WS-V(4) + 1) / 1000
     COMPUTE TL-EXPECTED-N = 500000 + 6000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         IF WS-K = 1
             MOVE '{"type": "minecraft:clamped_normal", "mean": 0.5, "deviation": 6.0, "min_inclusive": -3, "max_inclusive": 3}' TO WS-TEXT
             MOVE -3 TO WS-MIN
             MOVE 3 TO WS-MAX
         ELSE
             MOVE '{"type": "minecraft:clamped_normal", "mean": 0.6, "deviation": 3.0, "min_inclusive": -10, "max_inclusive": 10}' TO WS-TEXT
             MOVE -10 TO WS-MIN
             MOVE 10 TO WS-MAX
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
         CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
         MOVE 0 TO WS-BAD WS-LOW WS-HIGH WS-NEG
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
             MOVE WS-I TO WS-SEED
             CALL "F351-GAUSSIAN-RESET"
             CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
             CALL "FR-INT-SAMPLE" USING XR-STATE WS-P WS-VALUE
             CALL "F351-GAUSSIAN-RESET"
             CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
             CALL "F351-NEXT-GAUSSIAN" USING XR2-STATE WS-G
*>           the model: (float) g, times the deviation, plus the mean, each rounded to single precision; the literals of the provider are floats
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-G WS-G2
             MOVE WS-DEVIATION(WS-K) TO WS-D
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D WS-T
             COMPUTE WS-T = WS-G2 * WS-T
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-G2
             MOVE WS-MEAN(WS-K) TO WS-M
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-T
             COMPUTE WS-G = WS-T + WS-G2
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-G WS-G2
             IF WS-G2 < WS-MIN
                 MOVE WS-MIN TO WS-G2
             END-IF
             IF WS-G2 > WS-MAX
                 MOVE WS-MAX TO WS-G2
             END-IF
             COMPUTE WS-EXPECT = FUNCTION INTEGER-PART(WS-G2)
             IF WS-VALUE NOT = WS-EXPECT OR XR-LO NOT = X2-LO OR XR-HI NOT = X2-HI
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-VALUE = WS-MIN
                 ADD 1 TO WS-LOW
             END-IF
             IF WS-VALUE = WS-MAX
                 ADD 1 TO WS-HIGH
             END-IF
             IF WS-VALUE < 0 AND WS-G2 NOT = WS-MIN
                 ADD 1 TO WS-NEG
             END-IF
         END-PERFORM
         IF WS-K = 1
             MOVE "acceptance 23§7 clamped_normal mean 0.5 deviation 6 over -3 to 3: sixty samples and random states equal the model" TO TL-CASE
         ELSE
             MOVE "acceptance 23§7 clamped_normal mean 0.6 deviation 3 over -10 to 10: sixty samples and random states equal the model" TO TL-CASE
         END-IF
         MOVE WS-BAD TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-K = 1
             MOVE "acceptance 23§7 the narrow clamp reached both of its ends and truncated negative values toward zero" TO TL-CASE
             MOVE 0 TO TL-OBSERVED-N
             IF WS-LOW > 0 AND WS-HIGH > 0 AND WS-NEG > 0
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             MOVE 1 TO TL-EXPECTED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
*>   the reset: the second sample after a reset is the first of a fresh pair, not the spare
     MOVE 5 TO WS-SEED
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-GAUSSIAN" USING XR-STATE WS-G
     CALL "F351-GAUSSIAN-RESET"
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-GAUSSIAN" USING XR-STATE WS-G2
     MOVE "acceptance 35-1§5.3 F351-GAUSSIAN-RESET drops the spare: the next Gaussian of the same seed repeats the first" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-G = WS-G2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-GAUSSIAN" USING XR-STATE WS-G2
     MOVE "acceptance 35-1§5.3 without a reset the next draw is the spare of the pair (the spare survives a reseed)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-G NOT = WS-G2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a maximum below the minimum and a missing mean are refused
     MOVE '{"type": "minecraft:clamped_normal", "mean": 0.5, "deviation": 6.0, "min_inclusive": 3, "max_inclusive": -3}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7 a clamped_normal provider whose maximum is below its minimum is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:clamped_normal", "deviation": 6.0, "min_inclusive": -3, "max_inclusive": 3}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7 a clamped_normal provider without a mean is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:clamped_normal", "mean": 0.5, "min_inclusive": -3, "max_inclusive": 3}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7 a clamped_normal provider without a deviation is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-CLAMPED-NORMAL.
