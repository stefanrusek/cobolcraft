 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-FLOAT-OPS.
*> spike (throwaway): cost per arithmetic statement in GnuCOBOL 3.2 for FLOAT-LONG (IEEE double),
*> COMP-2 and BINARY-DOUBLE operands (docs/protocol/10 needs IEEE double results). 2,000,000 statements each.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-FA                  FLOAT-LONG VALUE 1.0000001.
 01 WS-FB                  FLOAT-LONG VALUE 0.9999999.
 01 WS-FC                  FLOAT-LONG VALUE 0.
 01 WS-DA                  USAGE COMP-2 VALUE 1.0000001.
 01 WS-DB                  USAGE COMP-2 VALUE 0.9999999.
 01 WS-DC                  USAGE COMP-2 VALUE 0.
 01 WS-IA                  BINARY-DOUBLE VALUE 3.
 01 WS-IB                  BINARY-DOUBLE VALUE 5.
 01 WS-IC                  BINARY-DOUBLE VALUE 0.
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 PROCEDURE DIVISION.
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 2000000
         COMPUTE WS-FC = WS-FA * WS-FB + WS-FC
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "FLOAT-LONG compute a*b+c  " WS-T0 " -> " WS-T1
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 2000000
         COMPUTE WS-DC = WS-DA * WS-DB + WS-DC
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "COMP-2 compute a*b+c      " WS-T0 " -> " WS-T1
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 2000000
         COMPUTE WS-IC = WS-IA * WS-IB + WS-IC
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "BINARY-DOUBLE a*b+c       " WS-T0 " -> " WS-T1
     STOP RUN.
