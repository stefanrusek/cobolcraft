       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPIKE-COVERAGE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-X BINARY-LONG VALUE 1.
       PROCEDURE DIVISION.
           IF WS-X = 1
              DISPLAY "TAKEN"
           ELSE
              DISPLAY "NOT-TAKEN-LINE"
           END-IF
           PERFORM PARA-USED
           STOP RUN.
       PARA-USED.
           DISPLAY "USED".
       PARA-UNUSED.
           DISPLAY "UNUSED".
