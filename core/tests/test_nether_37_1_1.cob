*> Acceptance test of 37-nether-1 section 1 (What the Nether is in this version): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-1-1.
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
     MOVE 1 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version dimension type key" TO TL-CASE
     MOVE "minecraft:the_nether 20" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 9 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version level key folder" TO TL-CASE
     MOVE "dimensions/minecraft/the_nether 31" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 23 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version noise settings use the legacy random source" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version noise min_y 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version noise height 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version sea level 32" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version coordinate_scale 8.0 (x1000)" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version has_ceiling" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version no skylight" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-1§1 What the Nether is in this version the attribute map has 15 rows (the old flags are attributes)" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version default fluid" TO TL-CASE
     MOVE "minecraft:lava 14" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 7 TO WS-CODE
     CALL "NETHER-DIM-TEXT" USING WS-CODE WS-TEXT WS-LEN
     MOVE WS-LEN TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version default block" TO TL-CASE
     MOVE "minecraft:netherrack 20" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-NAME TO TL-OBSERVED
     MOVE "nether_wastes" TO TL-EXPECTED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version preset biome 1 is nether_wastes" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 2 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-NAME TO TL-OBSERVED
     MOVE "soul_sand_valley" TO TL-EXPECTED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version preset biome 2 is soul_sand_valley" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-NAME TO TL-OBSERVED
     MOVE "crimson_forest" TO TL-EXPECTED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version preset biome 3 is crimson_forest" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 4 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-NAME TO TL-OBSERVED
     MOVE "warped_forest" TO TL-EXPECTED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version preset biome 4 is warped_forest" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 5 TO WS-A
     CALL "NETHER-BIOME-DEF" USING WS-A WS-DEF
     MOVE WS-D-NAME TO TL-OBSERVED
     MOVE "basalt_deltas" TO TL-EXPECTED
     MOVE "acceptance US12 37-1§1 What the Nether is in this version preset biome 5 is basalt_deltas" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-1-1.
