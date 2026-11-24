*> Acceptance test of 40-menus-2 section 1 (conventions shared by every menu): the container frame of 1.1, the standard inventory block of 1.2 and the quick-move tail and loop of 1.3, through MN2-FRAME, MN2-STD-INV, MN2-QUICK-TAIL and MN2-QUICK-LOOP. Written by lane p46 (FR-038).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MENU-40-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.


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
 01 WS-ED5                 PIC -(9)9.
 01 WS-KEY64               PIC X(64).
 01 WS-U20                 PIC 9(20).
 01 WS-KEY26               PIC X(26).
 01 WS-BIO                 PIC X(5).
 01 WS-STEPS               PIC X(12).
 01 WS-SPRING              BINARY-LONG.
 01 WS-SPRING-BIO          PIC X(5).
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-FL                  FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 854 TO WS-A
     MOVE 480 TO WS-B
     MOVE 60 TO WS-C
     CALL "MN2-FRAME" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-X1 WS-X2
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE WS-X1 TO WS-ED4
     MOVE WS-X2 TO WS-ED5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(WS-ED5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.1 a 854 x 480 screen: leftPos 339, topPos 157; title x (176 - 60) / 2 = 58 at y 6; inventory label y 72" TO TL-CASE
     MOVE "339 157 58 6 72" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 176 TO WS-A
     MOVE 166 TO WS-B
     MOVE 0 TO WS-C
     CALL "MN2-FRAME" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-X1 WS-X2
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE WS-X1 TO WS-ED4
     MOVE WS-X2 TO WS-ED5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(WS-ED5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.1 a screen exactly the image size has leftPos 0 and topPos 0; an empty title is at 88" TO TL-CASE
     MOVE "0 0 88 6 72" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 427 TO WS-A
     MOVE 240 TO WS-B
     MOVE 33 TO WS-C
     CALL "MN2-FRAME" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-X1 WS-X2
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE WS-X1 TO WS-ED4
     MOVE WS-X2 TO WS-ED5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(WS-ED5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.1 integer division: (427 - 176) / 2 = 125, (240 - 166) / 2 = 37, (176 - 33) / 2 = 71" TO TL-CASE
     MOVE "125 37 71 6 72" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 main inventory first slot (8, 84)" TO TL-CASE
     MOVE "8 84" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 8 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 main inventory row 0 column 8 (152, 84)" TO TL-CASE
     MOVE "152 84" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 9 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 main inventory row 1 column 0 (8, 102)" TO TL-CASE
     MOVE "8 102" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 26 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 main inventory last slot (152, 120)" TO TL-CASE
     MOVE "152 120" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 27 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 hotbar slot 0 at (8, 142): y is 84 + 58" TO TL-CASE
     MOVE "8 142" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 35 TO WS-A
     CALL "MN2-STD-INV" USING WS-A WS-D WS-E
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.2 hotbar slot 8 at (152, 142)" TO TL-CASE
     MOVE "152 142" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-A
     MOVE 5 TO WS-B
     CALL "MN2-QUICK-TAIL" USING WS-A WS-B WS-D WS-E WS-F
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 an emptied source is written back empty; the count changed: return the copy and call onTake" TO TL-CASE
     MOVE "1 1 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     CALL "MN2-QUICK-TAIL" USING WS-A WS-B WS-D WS-E WS-F
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 a partly moved source stays and the slot is marked changed; the count changed: return the copy" TO TL-CASE
     MOVE "0 1 1" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     CALL "MN2-QUICK-TAIL" USING WS-A WS-B WS-D WS-E WS-F
     MOVE WS-D TO WS-ED
     MOVE WS-E TO WS-ED2
     MOVE WS-F TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 the count did not change: return empty, no onTake" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "MN2-QUICK-LOOP" USING WS-A WS-B WS-V
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 the quick-move click calls again while the returned stack is non-empty and the slot holds the same item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "MN2-QUICK-LOOP" USING WS-A WS-B WS-V
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 the loop ends when the slot no longer holds the same item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "MN2-QUICK-LOOP" USING WS-A WS-B WS-V
     MOVE "acceptance US12 40-2§1 Conventions shared by every menu in this document 1.3 the loop ends when quickMoveStack returned the empty stack" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-MENU-40-2-1.
