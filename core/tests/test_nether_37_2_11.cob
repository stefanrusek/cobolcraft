*> Acceptance test of 37-nether-2 section 11 (Noise definitions used by the Nether): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-2-11.
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
     MOVE 2 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether nether_state_selector: -4, 1 octave: 2 layers (two stacks)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether netherrack: -3, 4 octaves with modifiers [1, 0, 0, 0.35]: octaves 1 and 4 stay, 4 layers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether nether_wart: -3, 4 octaves with modifiers [1, 0, 0, 0.9]: 4 layers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether surface: -6, 3 octaves: 6 layers" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether soul_sand_layer: -8, 9 octaves, modifiers 1 1 1 1 0 0 0 0 and 0.0133: 5 octaves, 10 layers" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether gravel_layer: the same parameters as soul_sand_layer: 10 layers" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     CALL "NETHER-NOISE-DEF" USING WS-A WS-B
     MOVE "acceptance US12 37-2§11 Noise definitions used by the Nether patch: -5, 6 octaves, first and last modifier set: 4 layers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE NZ-LAYER-N(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-NETHER-37-2-11.
