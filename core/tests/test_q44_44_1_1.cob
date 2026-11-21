*> Conventions shared by every part of RS26 (docs/protocol/44-residual-mob-questions-1-shared-model-framework.md section 1; lane 002-lane-p49i, T22620; phase task T2686). The section holds no game
*> behaviour: it fixes the evidence classes (1.1), the answer-row schema (1.2), the numbering of answer ids (1.3) and the random-number rule (1.4). The test reads the document at run time and checks
*> each convention against the document's own tables: the five classes B, C, D, I, R in order, the six columns of the schema, the 40 answer rows RQ-1.1 to RQ-1.40 in order with six columns each, and that the
 *> weighted shuffle is the one place that names its generator (the program of 1.4 is Q1-SHUFFLE-ORDER, proven by test_q44_44_1_3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-1-1.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT DOC-FILE ASSIGN TO "docs/protocol/44-residual-mob-questions-1-shared-model-framework.md" ORGANIZATION LINE SEQUENTIAL FILE STATUS WS-FS.
 DATA DIVISION.
 FILE SECTION.
 FD DOC-FILE.
 01 DOC-LINE               PIC X(3000).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-FS                  PIC XX.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-SECTION             BINARY-LONG VALUE 0.
 01 WS-CLASSES             PIC X(8) VALUE SPACES.
 01 WS-CLASS-N             BINARY-LONG VALUE 0.
 01 WS-COLS                PIC X(60) VALUE SPACES.
 01 WS-COL-N               BINARY-LONG VALUE 0.
 01 WS-ROWS                BINARY-LONG VALUE 0.
 01 WS-BAD-ID              BINARY-LONG VALUE 0.
 01 WS-BAD-COLS            BINARY-LONG VALUE 0.
 01 WS-PIPES               BINARY-LONG.
 01 WS-EXPECT              PIC X(12).
 01 WS-ID-N                PIC ZZ9.
 01 WS-CELL                PIC X(16).
 01 WS-REST                PIC X(60).
 01 WS-HAS-RANGE           BINARY-LONG VALUE 0.
 01 WS-CLASS-LETTER        PIC X.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     OPEN INPUT DOC-FILE
     IF WS-FS NOT = "00"
         DISPLAY "cannot open the document: " WS-FS
         STOP RUN RETURNING 1
     END-IF
     PERFORM UNTIL WS-STATE = 9
         READ DOC-FILE
             AT END
                 MOVE 9 TO WS-STATE
         END-READ
         IF WS-STATE NOT = 9
             EVALUATE TRUE
                 WHEN DOC-LINE(1:5) = "### 1"
                     MOVE 1 TO WS-SECTION
                     IF DOC-LINE(1:7) = "### 1.1"
                         MOVE 11 TO WS-SECTION
                     END-IF
                     IF DOC-LINE(1:7) = "### 1.2"
                         MOVE 12 TO WS-SECTION
                     END-IF
                     IF DOC-LINE(1:7) = "### 1.3"
                         MOVE 13 TO WS-SECTION
                     END-IF
                 WHEN DOC-LINE(1:8) = "### 4.15"
                     MOVE 415 TO WS-SECTION
                 WHEN DOC-LINE(1:3) = "## " OR DOC-LINE(1:4) = "### "
                     MOVE 0 TO WS-SECTION
                 WHEN WS-SECTION = 11 AND DOC-LINE(1:4) = "| **"
                     ADD 1 TO WS-CLASS-N
                     MOVE DOC-LINE(5:1) TO WS-CLASS-LETTER
                     MOVE WS-CLASS-LETTER TO WS-CLASSES(WS-CLASS-N:1)
                 WHEN WS-SECTION = 12 AND DOC-LINE(1:2) = "| " AND DOC-LINE(1:8) NOT = "| Column" AND DOC-LINE(1:4) NOT = "|---"
                     ADD 1 TO WS-COL-N
                     MOVE SPACES TO WS-CELL
                     UNSTRING DOC-LINE(3:) DELIMITED BY " | " INTO WS-CELL
                     EVALUATE WS-COL-N
                         WHEN 1
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(1:10)
                         WHEN 2
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(11:10)
                         WHEN 3
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(21:10)
                         WHEN 4
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(31:10)
                         WHEN 5
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(41:10)
                         WHEN 6
                             MOVE FUNCTION TRIM(WS-CELL) TO WS-COLS(51:10)
                     END-EVALUATE
                 WHEN WS-SECTION = 13 AND DOC-LINE(1:25) = "`RQ-<part>.<n>` where the"
                     MOVE 1 TO WS-HAS-RANGE
                 WHEN WS-SECTION = 415 AND DOC-LINE(1:7) = "| RQ-1."
                     ADD 1 TO WS-ROWS
                     MOVE WS-ROWS TO WS-ID-N
                     MOVE SPACES TO WS-EXPECT
                     STRING "| RQ-1." DELIMITED BY SIZE FUNCTION TRIM(WS-ID-N) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-EXPECT
                     COMPUTE WS-PIPES = 8 + FUNCTION LENGTH(FUNCTION TRIM(WS-ID-N))
                     IF DOC-LINE(1:WS-PIPES) NOT = WS-EXPECT(1:WS-PIPES)
                         ADD 1 TO WS-BAD-ID
                     END-IF
                     MOVE 0 TO WS-PIPES
                     INSPECT DOC-LINE TALLYING WS-PIPES FOR ALL "|"
                     IF WS-PIPES NOT = 7
                         ADD 1 TO WS-BAD-COLS
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     CLOSE DOC-FILE
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: five evidence classes B, C, D, I, R in that order" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CLASS-N = 5 AND WS-CLASSES = "BCDIR"
         MOVE 5 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: the answer-row schema has six columns" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-COL-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: the columns are Id, Source doc, Item, Answer, Evidence, Replaces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COLS(1:2) = "Id" AND WS-COLS(11:10) = "Source doc" AND WS-COLS(21:4) = "Item" AND WS-COLS(31:6) = "Answer" AND WS-COLS(41:8) = "Evidence"
             AND WS-COLS(51:8) = "Replaces"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: 1.3 states the ids RQ-<part>.<n>" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS-RANGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: part 1 has the answer rows RQ-1.1 to RQ-1.40 (40 rows)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-ROWS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: the rows are numbered consecutively from RQ-1.1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§1 Conventions shared by every part of RS26: every answer row has the six columns of the schema" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-COLS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-1-1.
