*> Acceptance test of 37-nether-2 section 13 (Behaviour summary for implementers): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-2-13.
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
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FL                  FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 18 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. min_y 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. height 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. sea_level 32" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. lava default fluid" TO TL-CASE
     MOVE "minecraft:lava 14" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 7 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. netherrack default block" TO TL-CASE
     MOVE "minecraft:netherrack 20" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 23 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 1. legacy random on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X1
     MOVE 0 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 2. temperature and vegetation from the legacy construction (seed 0, quart (0, 0))" TO TL-CASE
     MOVE "1173 -456" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 5. bedrock at y 0 always (floor gradient true)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 5. no bedrock from y 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 127 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 5. bedrock at y 127 always (roof gradient false)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 122 TO WS-B
     MOVE 3 TO WS-X1
     MOVE 5 TO WS-X2
     CALL "NETHER-GRADIENT-AT" USING WS-A WS-X1 WS-B WS-X2 WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 5. no bedrock at y 122" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1173 TO WS-T
     MOVE -456 TO WS-H
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-V
     MOVE "acceptance US12 37-2§13 Behaviour summary for implementers 6. biome of the climate point (1173, -456) is nether_wastes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-NETHER-37-2-13.
