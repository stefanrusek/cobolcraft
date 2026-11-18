*> Acceptance test of 37-nether-1 section 7 (Shared model for parts 2 to 6): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-1-7.
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
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 6" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 1 column 7" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 2" TO TL-CASE
     MOVE -5000 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 6" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 2 column 7" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 1" TO TL-CASE
     MOVE 4000 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 6" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 3 column 7" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 2" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 6" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 4 column 7" TO TL-CASE
     MOVE 3750 TO TL-EXPECTED-N
     MOVE WS-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 1" TO TL-CASE
     MOVE -5000 TO TL-EXPECTED-N
     MOVE WS-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 6" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-PRESET-ROW" USING WS-A WS-ROW
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 climate point row 5 column 7" TO TL-CASE
     MOVE 1750 TO TL-EXPECTED-N
     MOVE WS-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 1 biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 1 biome 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 3 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 1 biome 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 1 biome 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 1 biome 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 2 biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 2 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 2 biome 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 3 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 2 biome 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 4 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 2 biome 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 2 biome 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 3 biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 2 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 3 biome 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 3 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 3 biome 3" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 4 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 3 biome 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 3 biome 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 4 biome 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 2 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 4 biome 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 3 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 4 biome 3" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 4 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 4 biome 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-1§7 Shared model for parts 2 to 6 7.2 structure-hook tag: structure 4 biome 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-NETHER-37-1-7.
