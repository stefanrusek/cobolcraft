 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-WORLD.
*> spike (throwaway, plan 003): the caller's side of spike_motion_callback.cob. SPIKE-WORLD (the main program) takes
*> a pointer to SPIKE-CELL, a program of this file that nothing calls by name, and times 1,000,000 callbacks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELL                USAGE PROGRAM-POINTER.
 01 WS-CALLS               BINARY-LONG VALUE 1000000.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 PROCEDURE DIVISION.
     SET WS-CELL TO ENTRY "SPIKE-CELL"
     IF WS-CELL = NULL
         DISPLAY "entry not resolved"
         STOP RUN
     END-IF
     ACCEPT WS-T0 FROM TIME
     CALL "SPIKE-ENGINE" USING WS-CELL WS-CALLS WS-SUM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "sum " WS-SUM " (expected 1000000)"
     DISPLAY "1000000 callbacks HHMMSScc " WS-T0 " -> " WS-T1
     STOP RUN.
 END PROGRAM SPIKE-WORLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-CELL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-STATE.
     MOVE 1 TO L-STATE
     GOBACK.
 END PROGRAM SPIKE-CELL.
