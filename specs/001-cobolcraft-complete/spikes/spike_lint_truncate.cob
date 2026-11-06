       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPIKE-LINT.
      * spike (throwaway): which cobc warning sets reject a truncating MOVE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-A PIC 9(2).
       01 WS-B PIC 9(4) VALUE 1234.
       PROCEDURE DIVISION.
           MOVE WS-B TO WS-A
           STOP RUN.
