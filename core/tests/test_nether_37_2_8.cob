*> Acceptance test of 37-nether-2 section 8 (Climate wiring for the biome lookup): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-2-8.
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
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 1 continentalness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 1 erosion is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 1 depth is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 1 weirdness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 2 continentalness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 2 erosion is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 2 depth is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 2 weirdness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 3 continentalness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 3 erosion is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 3 depth is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 3 weirdness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 4 continentalness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 4 erosion is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 4 depth is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 4 weirdness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 5 continentalness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 5 erosion is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 5 depth is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup preset row 5 weirdness is the constant 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 0 TO WS-X1
     MOVE 0 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup 8.2 quart (0, 0) seed 0 quantised (T, H)" TO TL-CASE
     MOVE "1173 -456" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 25 TO WS-X1
     MOVE -50 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup 8.2 quart (25, -50) seed 0 quantised (T, H)" TO TL-CASE
     MOVE "-1046 -220" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 250 TO WS-X1
     MOVE 250 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup 8.2 quart (250, 250) seed 0 quantised (T, H)" TO TL-CASE
     MOVE "-623 -2383" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE -84 TO WS-X1
     MOVE 128 TO WS-X2
     CALL "NETHER-CLIMATE-AT" USING WS-X1 WS-X2 WS-T WS-H
     MOVE WS-T TO WS-ED
     MOVE WS-H TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-2§8 Climate wiring for the biome lookup 8.2 quart (-84, 128) seed 0 quantised (T, H)" TO TL-CASE
     MOVE "-2108 4453" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-2-8.
