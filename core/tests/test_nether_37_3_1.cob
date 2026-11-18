*> Acceptance test of 37-nether-3 section 1 (Pipeline at a glance): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY NETHER.
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
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FL                  FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 1173 TO WS-T
     MOVE -456 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.2 (1173, -456) is nether_wastes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2108 TO WS-T
     MOVE 4453 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.2 (-2108, 4453) is warped_forest" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -3000 TO WS-T
     MOVE 0 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.4 (-3000, 0) is basalt_deltas" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-T
     MOVE -2500 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 tie (0, -2500): nether_wastes first" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2000 TO WS-T
     MOVE 0 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 tie (2000, 0): nether_wastes first" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-T
     MOVE 3906 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 (0, 3906) is nether_wastes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-T
     MOVE 3907 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 (0, 3907) is warped_forest" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2806 TO WS-T
     MOVE 0 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 (-2806, 0) is nether_wastes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2807 TO WS-T
     MOVE 0 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-3§1 Pipeline at a glance 8.5 (-2807, 0) is basalt_deltas" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X1
     MOVE 0 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-3§1 Pipeline at a glance climate target T and H at quart (0, 0), C E D W stay 0" TO TL-CASE
     MOVE "1173 -456" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-3-1.
