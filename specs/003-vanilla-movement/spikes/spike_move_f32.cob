 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-MOVE-F32.
*> spike (throwaway, plan 003): the single-precision points of docs/protocol/59 under GnuCOBOL. Prints the bits of
*> (a) a FLOAT-LONG moved or computed into FLOAT-SHORT, (b) the 65536-entry sine table of 59 / 39 section 6.3 built
*> in COBOL (checksum of the bit patterns), (c) the table index of negative and positive angles.
*> spike_move_f32.py computes the same values with C float conversion and compares.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-F                   FLOAT-SHORT.
 01 WS-FB REDEFINES WS-F   BINARY-LONG UNSIGNED.
 01 WS-G                   FLOAT-SHORT.
 01 WS-GB REDEFINES WS-G   BINARY-LONG UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-L                   BINARY-DOUBLE.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ED                  PIC -(7)9.9(9).
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 PROCEDURE DIVISION.
*>   Values whose nearest float differs from the truncated one.
     MOVE 0.1 TO WS-D
     PERFORM DO-NARROW
     MOVE 0.98 TO WS-D
     PERFORM DO-NARROW
     MOVE 0.6 TO WS-D
     PERFORM DO-NARROW
     MOVE 0.91 TO WS-D
     PERFORM DO-NARROW
     MOVE 0.21600002 TO WS-D
     PERFORM DO-NARROW
     COMPUTE WS-D = 1 / 3
     PERFORM DO-NARROW
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 65535
         COMPUTE WS-D = WS-I / 10430.378350470453
         COMPUTE WS-E = FUNCTION SIN(WS-D)
         MOVE WS-E TO WS-F
         COMPUTE WS-SUM = FUNCTION MOD(WS-SUM * 31 + WS-FB, 1000000007)
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "T " WS-SUM
     DISPLAY "t table HHMMSScc " WS-T0 " -> " WS-T1
     MOVE 1.5707964 TO WS-D
     PERFORM DO-INDEX
     MOVE -1.5707964 TO WS-D
     PERFORM DO-INDEX
     MOVE -0.00001 TO WS-D
     PERFORM DO-INDEX
     STOP RUN.

 DO-NARROW.
     MOVE WS-D TO WS-F
     COMPUTE WS-G = WS-D
     COMPUTE WS-ED ROUNDED = WS-D
     DISPLAY "N " FUNCTION TRIM(WS-ED) " " WS-FB " " WS-GB.

*>   index = (long)(x * 10430.378350470453) & 65535, the conversion truncating toward zero.
 DO-INDEX.
     COMPUTE WS-L = FUNCTION INTEGER-PART(WS-D * 10430.378350470453)
     COMPUTE WS-INDEX = FUNCTION MOD(WS-L, 65536)
     COMPUTE WS-ED ROUNDED = WS-D
     DISPLAY "I " FUNCTION TRIM(WS-ED) " " WS-INDEX.
