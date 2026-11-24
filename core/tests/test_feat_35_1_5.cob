*> Acceptance test of docs/protocol/35-worldgen-features-1 section 5 (random sources, draw conventions and per-feature seeding): the draws of the
*> Xoroshiro-wrapped source seeded with 1000 (the vectors of section 11.3: floats, booleans, nextInt(16), nextInt(3), nextInt(), nextLong, nextInt(100),
*> the Gaussian and its spare that survives a reseed), nextInt of a power of two consuming exactly one draw, and the decoration and feature seeds
*> of section 5.1 (the rows of section 11.1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FEATURE             BINARY-DOUBLE UNSIGNED.
 01 WS-STATE-2.
    05 WS-LO2              BINARY-DOUBLE UNSIGNED.
    05 WS-HI2              BINARY-DOUBLE UNSIGNED.
 01 WS-INT                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-EDIT                PIC -(19)9.
 01 WS-EDIT-U              PIC Z(19)9.
 01 WS-TEXT                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 01 WS-STEP                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 1000 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM 3 TIMES
         CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-F
         COMPUTE WS-DIFF = WS-F * 100000000
         MOVE WS-DIFF TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: three nextFloat of seed 1000 (times 1e8, truncated)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "61734074 64006274 74027782" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM 6 TIMES
         CALL "F351-NEXT-BOOLEAN" USING XR-STATE WS-INT
         MOVE WS-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: six nextBoolean (the top bit)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 1 1 0 1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 16 TO WS-BOUND
     PERFORM 6 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-INT
         MOVE WS-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: six nextInt(16), one draw each" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "9 10 11 7 11 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 3 TO WS-BOUND
     PERFORM 6 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-INT
         MOVE WS-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: six nextInt(3)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 0 2 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM 3 TIMES
         CALL "F351-NEXT-INT" USING XR-STATE WS-INT
         MOVE WS-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: three nextInt() (the top 32 bits)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-1643508961 -1545918627 -1115498129" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-LONG" USING XR-STATE WS-LONG
     MOVE WS-LONG TO WS-EDIT
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: nextLong is two draws with a sign-extended low word" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "-7058817239723858083" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 100 TO WS-BOUND
     PERFORM 2 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-INT
         MOVE WS-INT TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: two nextInt(100)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "67 34" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the Gaussian: the first value, then the spare on the next call, which a reseed does not clear
     MOVE "N" TO TL-MODE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-GAUSSIAN" USING XR-STATE WS-F
     COMPUTE WS-DIFF = (WS-F - 0.6943196185721859) * 1000000000000
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: the first nextGaussian is 0.6943196185721859 (within 1e-12)" TO TL-CASE
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-NEXT-GAUSSIAN" USING XR-STATE WS-F
     COMPUTE WS-DIFF = (WS-F - 1.4217534803646787) * 1000000000000
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: the spare 1.4217534803646787 survives the reseed" TO TL-CASE
     IF WS-DIFF < 1 AND WS-DIFF > -1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the seeds of 5.1 (rows of 11.1)
     MOVE "T" TO TL-MODE
     MOVE 12345 TO WS-SEED-U
     MOVE 48 TO WS-X
     COMPUTE WS-Z = -32
     CALL "ORE-DECOR-SEED" USING WS-SEED-U WS-X WS-Z XR-STATE WS-DECOR
     MOVE WS-DECOR TO WS-EDIT-U
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: decorationSeed of world seed 12345, chunk (3, -2), unsigned bits" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT-U) TO TL-OBSERVED
     MOVE "12668124045142540233" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-INDEX
     MOVE 9 TO WS-STEP
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FEATURE
     MOVE WS-FEATURE TO WS-EDIT-U
     MOVE "acceptance US12 35-1§5 Random sources, draw conventions and per-feature seeding: the feature seed is decorationSeed + index + 10000 * step" TO TL-CASE
     MOVE FUNCTION TRIM(WS-EDIT-U) TO TL-OBSERVED
     MOVE "12668124045142630236" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
