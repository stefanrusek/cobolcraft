*> Acceptance test of 37-nether-4 section 2 (Random sources in the Nether): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-4-2.
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
     MOVE "minecraft:netherrack" TO WS-KEY64
     MOVE 20 TO WS-LEN
     CALL "NETHER-JHASH" USING WS-KEY64 WS-LEN WS-V
     MOVE "acceptance US12 37-4§2 Random sources in the Nether P.fromHashOf hashes the full name: Java hash of minecraft:netherrack" TO TL-CASE
     MOVE 303935260 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nether_wart" TO WS-KEY64
     MOVE 21 TO WS-LEN
     CALL "NETHER-JHASH" USING WS-KEY64 WS-LEN WS-V
     MOVE "acceptance US12 37-4§2 Random sources in the Nether Java hash of minecraft:nether_wart" TO TL-CASE
     MOVE 815165382 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nether_state_selector" TO WS-KEY64
     MOVE 31 TO WS-LEN
     CALL "NETHER-JHASH" USING WS-KEY64 WS-LEN WS-V
     MOVE "acceptance US12 37-4§2 Random sources in the Nether Java hash of minecraft:nether_state_selector (32-bit wrap)" TO TL-CASE
     MOVE -1772810105 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nether/temperature" TO WS-KEY64
     MOVE 28 TO WS-LEN
     CALL "NETHER-JHASH" USING WS-KEY64 WS-LEN WS-V
     MOVE "acceptance US12 37-4§2 Random sources in the Nether Java hash of minecraft:nether/temperature" TO TL-CASE
     MOVE -662671062 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE NH-FS TO WS-U20
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-U20 TO TL-OBSERVED
     MOVE "acceptance US12 37-4§2 root factory of world seed 0: F = -4962768465676381896 (as u64)" TO TL-CASE
     MOVE "13483975608033169720" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-X1 WS-X2 WS-X3
     CALL "NETHER-AT" USING NH-FS WS-X1 WS-X3 WS-X2 WS-STATE
     CALL "NETHER-RAND-DOUBLE" USING WS-STATE WS-FL
     COMPUTE WS-SC = WS-FL * 1000000000000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SC
     MOVE "acceptance US12 37-4§2 P.at(0, 0, 0) first nextDouble 0.26044200501959935 (1e-15, +-1)" TO TL-CASE
     MOVE 260442005019599 TO TL-EXPECTED-N
     IF TL-OBSERVED-N = 260442005019600 OR TL-OBSERVED-N = 260442005019598
         MOVE 260442005019599 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-CODE
     CALL "NETHER-DIM-SCALAR" USING WS-CODE WS-V
     MOVE "acceptance US12 37-4§2 Random sources in the Nether legacy_random_source is true in the Nether" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-NETHER-37-4-2.
