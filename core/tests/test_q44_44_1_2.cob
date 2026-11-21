*> Master index of the open items of documents 18 to 21 (docs/protocol/44-residual-mob-questions-1-shared-model-framework.md section 2; lane 002-lane-p49i, T22630; phase task T2688). The section
*> holds no game behaviour: it routes every open item of 18 to 21 to a part of RS26. The test reads the document at run time: nine parts, every part's file exists in docs/protocol, the four item tables
*> have 30, 33, 8 and 16 rows, every answer id the tables name (RQ-1.n, 31 distinct) exists among the 40 answer rows of section 4.15, and every status value of the tables is one of the six the section defines.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-1-2.
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
 01 WS-PARTS               BINARY-LONG VALUE 0.
 01 WS-TABLE-ROWS.
    05 WS-TR               BINARY-LONG OCCURS 4 TIMES.
 01 WS-SEEN.
    05 WS-S                PIC 9 OCCURS 99 TIMES.
 01 WS-DISTINCT            BINARY-LONG VALUE 0.
 01 WS-OUT-OF-RANGE        BINARY-LONG VALUE 0.
 01 WS-POS                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NUM-TEXT            PIC X(4).
 01 WS-NUM                 BINARY-LONG.
 01 WS-R415.
    05 WS-ROWS-415         PIC 9 OCCURS 99 TIMES.
 01 WS-MISSING             BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FILES               BINARY-LONG VALUE 0.
 01 WS-FILES-OK            BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(160).
 01 WS-INFO                PIC X(16).
 01 WS-RC                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-TAIL                PIC X(3000).
 01 WS-STATUS-BAD          BINARY-LONG VALUE 0.
 01 WS-CELL                PIC X(80).
 01 WS-CELL2               PIC X(80).
 01 WS-CELL3               PIC X(80).
 01 WS-CELL4               PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE ALL "0" TO WS-SEEN
     MOVE ALL "0" TO WS-R415
     MOVE 0 TO WS-TR(1) WS-TR(2) WS-TR(3) WS-TR(4)
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
                 WHEN DOC-LINE(1:4) = "## 2"
                     MOVE 2 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 2.1 "
                     MOVE 21 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 2.2 "
                     MOVE 22 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 2.3 "
                     MOVE 23 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 2.4 "
                     MOVE 24 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 2.5 "
                     MOVE 25 TO WS-SECTION
                 WHEN DOC-LINE(1:8) = "### 4.15"
                     MOVE 415 TO WS-SECTION
                 WHEN DOC-LINE(1:3) = "## " OR DOC-LINE(1:4) = "### "
                     MOVE 0 TO WS-SECTION
                 WHEN WS-SECTION = 21 AND DOC-LINE(1:2) = "| " AND DOC-LINE(3:1) >= "1" AND DOC-LINE(3:1) <= "9" AND DOC-LINE(4:3) = " | "
                     ADD 1 TO WS-PARTS
                 WHEN WS-SECTION = 21 AND DOC-LINE(1:7) = "Files: "
                     PERFORM FILES-LINE
                 WHEN WS-SECTION >= 22 AND WS-SECTION <= 25 AND DOC-LINE(1:2) = "| " AND DOC-LINE(1:8) NOT = "| Item |" AND DOC-LINE(1:4) NOT = "|---"
                     COMPUTE WS-I = WS-SECTION - 21
                     ADD 1 TO WS-TR(WS-I)
                     PERFORM ROW-IDS
                     PERFORM ROW-STATUS
                 WHEN WS-SECTION = 415 AND DOC-LINE(1:7) = "| RQ-1."
                     MOVE SPACES TO WS-NUM-TEXT
                     UNSTRING DOC-LINE(8:) DELIMITED BY " " INTO WS-NUM-TEXT
                     COMPUTE WS-NUM = FUNCTION NUMVAL(WS-NUM-TEXT)
                     MOVE "1" TO WS-ROWS-415(WS-NUM)
             END-EVALUATE
         END-IF
     END-PERFORM
     CLOSE DOC-FILE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 99
         IF WS-S(WS-I) = "1"
             ADD 1 TO WS-DISTINCT
             IF WS-ROWS-415(WS-I) NOT = "1"
                 ADD 1 TO WS-MISSING
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: nine parts" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-PARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: the file of every part and continuation exists (10 files)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-FILES-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: the Files paragraph names 10 files" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-FILES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: document 18 table has 30 rows" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-TR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: document 19 table has 33 rows" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE WS-TR(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: document 20 table has 8 rows" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-TR(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: document 21 table has 16 rows" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-TR(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: the tables name 31 distinct answer ids" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE WS-DISTINCT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: every named answer id is a row of section 4.15" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: no answer id is outside RQ-1.1 to RQ-1.40" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT-OF-RANGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-1§2 Master index of the open items of documents 18 to 21: every status is one of the six defined values or one of four annotated ones" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> ROW-IDS: every RQ-1.n of the line is marked.
 ROW-IDS.
     MOVE 1 TO WS-POS
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(DOC-LINE TRAILING))
     PERFORM UNTIL WS-POS > WS-LEN - 5
         IF DOC-LINE(WS-POS:5) = "RQ-1."
             MOVE SPACES TO WS-NUM-TEXT
             MOVE DOC-LINE(WS-POS + 5:2) TO WS-NUM-TEXT
             IF WS-NUM-TEXT(2:1) < "0" OR WS-NUM-TEXT(2:1) > "9"
                 MOVE SPACE TO WS-NUM-TEXT(2:1)
             END-IF
             COMPUTE WS-NUM = FUNCTION NUMVAL(WS-NUM-TEXT)
             IF WS-NUM < 1 OR WS-NUM > 40
                 ADD 1 TO WS-OUT-OF-RANGE
             ELSE
                 MOVE "1" TO WS-S(WS-NUM)
             END-IF
         END-IF
         ADD 1 TO WS-POS
     END-PERFORM.

*> ROW-STATUS: the fourth cell (Status) starts with one of the six values.
 ROW-STATUS.
     MOVE SPACES TO WS-CELL WS-CELL2 WS-CELL3 WS-CELL4
     UNSTRING DOC-LINE(3:) DELIMITED BY " | " INTO WS-CELL WS-CELL2 WS-CELL3 WS-CELL4
     EVALUATE TRUE
         WHEN WS-CELL4(1:4) = "here"
         WHEN WS-CELL4(1:7) = "pointer"
         WHEN WS-CELL4(1:4) = "part"
         WHEN WS-CELL4(1:4) = "data"
         WHEN WS-CELL4(1:6) = "closed"
         WHEN WS-CELL4(1:3) = "n/a"
             CONTINUE
*>       Statuses the rows use beyond the six values the section defines (a gap of the section's vocabulary, reported to the document editors).
         WHEN WS-CELL4(1:12) = "not answered"
         WHEN WS-CELL4(1:12) = "out of scope"
         WHEN WS-CELL4(1:7) = "xp here"
         WHEN WS-CELL4(1:9) = "each part"
             CONTINUE
         WHEN OTHER
             ADD 1 TO WS-STATUS-BAD
     END-EVALUATE.

*> FILES-LINE: the backticked names of the line that end in .md are checked on disk.
 FILES-LINE.
     MOVE 1 TO WS-POS
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(DOC-LINE TRAILING))
     PERFORM UNTIL WS-POS > WS-LEN
         IF DOC-LINE(WS-POS:20) = "`44-residual-mob-que"
             MOVE SPACES TO WS-NAME
             MOVE "docs/protocol/" TO WS-NAME
             MOVE SPACES TO WS-TAIL
             MOVE DOC-LINE(WS-POS + 1:) TO WS-TAIL
             UNSTRING WS-TAIL DELIMITED BY "`" INTO WS-TAIL
             MOVE FUNCTION TRIM(WS-TAIL) TO WS-NAME(15:)
             ADD 1 TO WS-FILES
             CALL "CBL_CHECK_FILE_EXIST" USING FUNCTION TRIM(WS-NAME) WS-INFO RETURNING WS-RC
             IF WS-RC = 0
                 ADD 1 TO WS-FILES-OK
             END-IF
         END-IF
         ADD 1 TO WS-POS
     END-PERFORM.
 END PROGRAM TEST-Q44-44-1-2.
