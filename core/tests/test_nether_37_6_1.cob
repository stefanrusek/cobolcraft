*> Acceptance test of 37-nether-6 section 1 (structure and spawn data): the rows and values the section states, read back through the core's entry points. Written by lane p46 (FR-031).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-1.
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
     CALL "NETHER-STRUCTURE-SET" USING WS-A WS-B WS-C WS-D WS-E
     MOVE WS-B TO WS-ED
     MOVE WS-C TO WS-ED2
     MOVE WS-D TO WS-ED3
     MOVE WS-E TO WS-ED4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data nether_complexes: spacing 27 separation 4 salt 30084232 two entries" TO TL-CASE
     MOVE "27 4 30084232 2" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 2 TO WS-A
     CALL "NETHER-STRUCTURE-SET" USING WS-A WS-B WS-C WS-D WS-E
     MOVE WS-B TO WS-ED
     MOVE WS-C TO WS-ED2
     MOVE WS-D TO WS-ED3
     MOVE WS-E TO WS-ED4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data nether_fossils: spacing 2 separation 1 salt 14357921 one entry" TO TL-CASE
     MOVE "2 1 14357921 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-A
     CALL "NETHER-STRUCTURE-SET" USING WS-A WS-B WS-C WS-D WS-E
     MOVE WS-B TO WS-ED
     MOVE WS-C TO WS-ED2
     MOVE WS-D TO WS-ED3
     MOVE WS-E TO WS-ED4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data ruined_portals: spacing 40 separation 15 salt 34222645 seven entries" TO TL-CASE
     MOVE "40 15 34222645 7" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "NETHER-SPAWN-COUNT" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data nether_wastes has one creature entry (strider)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-SPAWN-COUNT" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data nether_wastes has five monster entries" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     CALL "NETHER-SPAWN-COUNT" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data warped_forest has one monster entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 5 TO WS-B
     CALL "NETHER-STRUCTURE-BIOME" USING WS-A WS-B WS-V
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data bastion_remnant is not in basalt_deltas" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "NETHER-FORTRESS-SPAWN" USING WS-A WS-ENT WS-LEN WS-D WS-E WS-F
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ENT) " " FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 37-6§1 What is in the Nether's structure and spawn data fortress monster override entry 1 is blaze" TO TL-CASE
     MOVE "blaze 10 2 3" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM TEST-NETHER-37-6-1.
