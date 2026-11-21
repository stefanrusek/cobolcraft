*> Acceptance test of 37-nether-5 section 1 (Read first: what is different in 26.3): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY NETHER.
 COPY NOISE.
 01 WS-CODE                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-TEXT                PIC X(40).
 01 WS-LEN                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-ROW.
    05 WS-R                BINARY-DOUBLE OCCURS 7 TIMES.
 01 WS-DEF.
    05 WS-D-NAME           PIC X(20).
    05 WS-D-NAME-LENGTH    BINARY-LONG.
    05 WS-D-TEMPERATURE    BINARY-LONG.
    05 WS-D-DOWNFALL       BINARY-LONG.
    05 WS-D-PRECIPITATION  BINARY-LONG.
    05 WS-D-WATER-COLOR    BINARY-LONG.
    05 WS-D-FOG-COLOR      BINARY-LONG.
    05 WS-D-PARTICLE       PIC X(20).
    05 WS-D-PARTICLE-LEN   BINARY-LONG.
    05 WS-D-PARTICLE-PROB  BINARY-LONG.
    05 WS-D-MOOD-DELAY     BINARY-LONG.
    05 WS-D-MOOD-EXTENT    BINARY-LONG.
    05 WS-D-MOOD-OFFSET    BINARY-LONG.
    05 WS-D-ADDITIONS      BINARY-LONG.
    05 WS-D-MUSIC-MIN      BINARY-LONG.
    05 WS-D-MUSIC-MAX      BINARY-LONG.
    05 WS-D-STEP-LISTS     BINARY-LONG.
    05 WS-D-FEATURES       BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-KEY                 PIC X(40).
 01 WS-ENT                 PIC X(20).
 01 WS-X1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-X3                  BINARY-LONG.
 01 WS-X4                  BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-ED3                 PIC -(9)9.
 01 WS-ED4                 PIC -(9)9.
 01 WS-KEY64               PIC X(64).
 01 WS-U20                 PIC 9(20).
 01 WS-KEY26               PIC X(26).
 01 WS-BIO                 PIC X(5).
 01 WS-STEPS               PIC X(12).
 01 WS-SPRING              BINARY-LONG.
 01 WS-SPRING-BIO          PIC X(5).
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FL                  FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 4. biome 1 has 10 decoration step lists" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-D-STEP-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 4. biome 2 has 10 decoration step lists" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-D-STEP-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 4. biome 3 has 10 decoration step lists" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-D-STEP-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 4. biome 4 has 10 decoration step lists" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-D-STEP-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 4. biome 5 has 8 decoration step lists" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-D-STEP-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. noise min_y 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. noise height 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. sea_level 32" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. default_block" TO TL-CASE
     MOVE "minecraft:netherrack 20" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 6 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. default_fluid" TO TL-CASE
     MOVE "minecraft:lava 14" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 23 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. legacy_random_source true" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. logical_height 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-5§1 Read first: what is different in 26.3, and what the Nether data contains 2. dimension height 256" TO TL-CASE
     MOVE 256 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-STEPS
     MOVE 0 TO WS-SPRING
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 37
         CALL "NETHER-FEATURE-ROW" USING WS-A WS-B WS-C WS-D WS-KEY26 WS-BIO
         COMPUTE WS-F = WS-B + 1
         MOVE "x" TO WS-STEPS(WS-F:1)
         IF WS-KEY26 = "spring_lava"
             MOVE WS-B TO WS-SPRING
             MOVE WS-BIO TO WS-SPRING-BIO
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-5§1 4. only steps 2, 4, 7 and 9 hold features (steps 0 1 3 5 6 8 10 are empty)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "..x.x..x.x." TO TL-EXPECTED
     MOVE WS-STEPS TO TL-OBSERVED
     INSPECT TL-OBSERVED REPLACING ALL " " BY "."
     MOVE SPACES TO TL-OBSERVED(12:)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 37-5§1 5. spring_lava is a step 9 feature" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-SPRING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-5§1 5. spring_lava is listed by four biomes and not by basalt_deltas" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "WSCP." TO TL-EXPECTED
     MOVE WS-SPRING-BIO TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-5-1.
