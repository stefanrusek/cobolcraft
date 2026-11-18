*> Acceptance test of 37-nether-4 section 3 (Generation context numbers for the Nether): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-4-3.
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
     MOVE 18 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether minGenY = max(0, 0) = 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether genDepth = min(256, 128) = 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether sea level 32" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether above_bottom 0 is y 0: floor gradient true (always bedrock)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether above_bottom 5 is y 5: floor gradient false" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 127 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether below_top 0 is y 127: roof gradient false (bedrock always)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 122 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-4§3 Generation context numbers for the Nether below_top 5 is y 122: roof gradient true (no bedrock)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-NETHER-37-4-3.
