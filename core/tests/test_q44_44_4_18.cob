*> Answers to the other scope questions (docs/protocol/44-residual-mob-questions-4-land-animals.md section 18; lane 002-lane-p49i, T22600; phase task T2734). The section holds no behaviour of its
*> own: it dispositions open questions of 19 by pointing at sections of this document (1.1 for the three LongJump* behaviours, 1.2 and 1.3 for the finders and Croak, 2 to 16 for the per-mob
*> values, 4 for the fox, 9 for the goat, 10 for the frog, 12 for the armadillo, 13 for the sniffer, 2.3 for the camel) and defers the rest to other parts. The test reads the document at run time
*> and checks that every section the answers point at exists as a heading and that the section has the ten answers; the rules behind the pointers are proven by test_q44_44_4_1, _2 and the
*> per-mob tests of the 44§ series.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-4-18.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT DOC-FILE ASSIGN TO "docs/protocol/44-residual-mob-questions-4-land-animals.md" ORGANIZATION LINE SEQUENTIAL FILE STATUS WS-FS.
 DATA DIVISION.
 FILE SECTION.
 FD DOC-FILE.
 01 DOC-LINE               PIC X(4000).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-FS                  PIC XX.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-BULLETS             BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HEADINGS.
    05 WS-HEAD             PIC X(8) OCCURS 80 TIMES.
 01 WS-HEAD-COUNT          BINARY-LONG VALUE 0.
 01 WS-WANT-DATA.
    05 FILLER              PIC X(8) VALUE "1.1".
    05 FILLER              PIC X(8) VALUE "1.2".
    05 FILLER              PIC X(8) VALUE "1.3".
    05 FILLER              PIC X(8) VALUE "1.4".
    05 FILLER              PIC X(8) VALUE "1.5".
    05 FILLER              PIC X(8) VALUE "2".
    05 FILLER              PIC X(8) VALUE "2.3".
    05 FILLER              PIC X(8) VALUE "4".
    05 FILLER              PIC X(8) VALUE "9".
    05 FILLER              PIC X(8) VALUE "10".
    05 FILLER              PIC X(8) VALUE "12".
    05 FILLER              PIC X(8) VALUE "13".
    05 FILLER              PIC X(8) VALUE "17".
    05 FILLER              PIC X(8) VALUE "19".
    05 FILLER              PIC X(8) VALUE "20".
 01 WS-WANT REDEFINES WS-WANT-DATA.
    05 WS-W                PIC X(8) OCCURS 15 TIMES.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TXT                 PIC X(8).
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
                 WHEN DOC-LINE(1:3) = "## " OR DOC-LINE(1:4) = "### "
                     MOVE SPACES TO WS-TXT
                     IF DOC-LINE(1:4) = "### "
                         UNSTRING DOC-LINE(5:) DELIMITED BY ALL SPACE INTO WS-TXT
                     ELSE
                         UNSTRING DOC-LINE(4:) DELIMITED BY ALL SPACE INTO WS-TXT
                     END-IF
                     IF WS-TXT(1:1) >= "0" AND WS-TXT(1:1) <= "9"
                         COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(WS-TXT))
                         IF WS-TXT(WS-N:1) = "."
                             MOVE SPACE TO WS-TXT(WS-N:1)
                         END-IF
                         ADD 1 TO WS-HEAD-COUNT
                         MOVE WS-TXT TO WS-HEAD(WS-HEAD-COUNT)
                     END-IF
                     IF DOC-LINE(1:6) = "## 18."
                         MOVE 1 TO WS-STATE
                     ELSE
                         IF WS-STATE = 1
                             MOVE 2 TO WS-STATE
                         END-IF
                     END-IF
                 WHEN WS-STATE = 1 AND DOC-LINE(1:3) = "- *"
                     ADD 1 TO WS-BULLETS
             END-EVALUATE
         END-IF
     END-PERFORM
     CLOSE DOC-FILE
     MOVE "acceptance US15 44-4§18 Answers to the other scope questions: the section holds ten answers" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-BULLETS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-HEAD-COUNT
             IF WS-HEAD(WS-N) = WS-W(WS-I)
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 44-4§18 Answers to the other scope questions: section " DELIMITED BY SIZE FUNCTION TRIM(WS-W(WS-I)) DELIMITED BY SIZE
             " that the answers point at exists" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-Q44-44-4-18.
