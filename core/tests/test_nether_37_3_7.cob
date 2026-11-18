*> Acceptance test of 37-nether-3 section 7 (Fog, sky and ambient particles): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-3-7.
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
     MOVE 1 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog colour of biome 1" TO TL-CASE
     MOVE -13432824 TO TL-EXPECTED-N
     MOVE WS-D-FOG-COLOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog colour of biome 2" TO TL-CASE
     MOVE -14989499 TO TL-EXPECTED-N
     MOVE WS-D-FOG-COLOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog colour of biome 3" TO TL-CASE
     MOVE -13434109 TO TL-EXPECTED-N
     MOVE WS-D-FOG-COLOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog colour of biome 4" TO TL-CASE
     MOVE -15071974 TO TL-EXPECTED-N
     MOVE WS-D-FOG-COLOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog colour of biome 5" TO TL-CASE
     MOVE -9937040 TO TL-EXPECTED-N
     MOVE WS-D-FOG-COLOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-PARTICLE TO TL-OBSERVED
     MOVE "" TO TL-EXPECTED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 ambient particle of biome 1" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 particle probability of biome 1 (x1e9)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-D-PARTICLE-PROB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-PARTICLE TO TL-OBSERVED
     MOVE "ash" TO TL-EXPECTED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 ambient particle of biome 2" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 2 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 particle probability of biome 2 (x1e9)" TO TL-CASE
     MOVE 6250000 TO TL-EXPECTED-N
     MOVE WS-D-PARTICLE-PROB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-PARTICLE TO TL-OBSERVED
     MOVE "crimson_spore" TO TL-EXPECTED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 ambient particle of biome 3" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 particle probability of biome 3 (x1e9)" TO TL-CASE
     MOVE 25000000 TO TL-EXPECTED-N
     MOVE WS-D-PARTICLE-PROB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-PARTICLE TO TL-OBSERVED
     MOVE "warped_spore" TO TL-EXPECTED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 ambient particle of biome 4" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 4 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 particle probability of biome 4 (x1e9)" TO TL-CASE
     MOVE 14280000 TO TL-EXPECTED-N
     MOVE WS-D-PARTICLE-PROB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-PARTICLE TO TL-OBSERVED
     MOVE "white_ash" TO TL-EXPECTED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 ambient particle of biome 5" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 5 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.3 particle probability of biome 5 (x1e9)" TO TL-CASE
     MOVE 118093334 TO TL-EXPECTED-N
     MOVE WS-D-PARTICLE-PROB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog_start_distance 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.1 fog_end_distance 96" TO TL-CASE
     MOVE 96 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-3§7 Fog, sky and ambient particles 7.2 skybox none" TO TL-CASE
     MOVE "none 4" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-3-7.
