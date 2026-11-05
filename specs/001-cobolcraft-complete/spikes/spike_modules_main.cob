       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPIKE-MODULES-MAIN.
      * spike (throwaway): multi-module static linking, LINKAGE tables,
      * and a rough feel for COBOL loop cost over one 16x16x384 column.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COLUMN.
          05 WS-STATE BINARY-SHORT UNSIGNED OCCURS 98304.
       01 WS-COUNT    BINARY-LONG.
       01 WS-ROUNDS   BINARY-LONG.
       01 WS-T1       PIC X(21).
       01 WS-T2       PIC X(21).
       PROCEDURE DIVISION.
           MOVE FUNCTION CURRENT-DATE TO WS-T1
           PERFORM 100 TIMES
              CALL STATIC "SPIKE-COUNT-SOLID" USING WS-COLUMN WS-COUNT
              ADD 1 TO WS-ROUNDS
           END-PERFORM
           MOVE FUNCTION CURRENT-DATE TO WS-T2
           DISPLAY "ROUNDS=" WS-ROUNDS " SOLID=" WS-COUNT
           DISPLAY "T1=" WS-T1(9:8) " T2=" WS-T2(9:8)
           STOP RUN.
