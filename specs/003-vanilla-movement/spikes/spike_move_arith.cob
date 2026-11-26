 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPIKE-MOVE-ARITH.
*> spike (throwaway, plan 003): can GnuCOBOL FLOAT-LONG reproduce the per-tick movement arithmetic of docs/protocol/13
*> section 1.3 closely enough (SC-001: 0.001 blocks at every step), how its comparisons behave near the movement
*> thresholds and for positions far from the origin, and what one tick of such arithmetic costs.
*> Prints one "S <series> <tick> <position>" line per tick (compared by spike_move_reference.py), then "C" lines
*> (comparisons) and "T" lines (timing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SERIES              PIC X(8).
 01 WS-ED                  PIC -(9)9.9(12).
 01 WS-T0                  PIC 9(8).
 01 WS-T1                  PIC 9(8).
 PROCEDURE DIVISION.
*>   Ordinary ground: forward held 40 ticks, then released 15 ticks.
     MOVE "ground" TO WS-SERIES
     MOVE 0.6 TO WS-F
     PERFORM DO-HORIZONTAL
*>   Ice: the same with friction 0.98 (60 held, 90 released).
     MOVE "ice" TO WS-SERIES
     MOVE 0.98 TO WS-F
     PERFORM DO-ICE
*>   A jump from standing: velocity 0.42, gravity 0.08, vertical drag 0.98.
     MOVE "jump" TO WS-SERIES
     MOVE 0.41999998688697815 TO WS-V
     MOVE 0 TO WS-P
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF FUNCTION ABS(WS-V) < 0.003
             MOVE 0 TO WS-V
         END-IF
         COMPUTE WS-P = WS-P + WS-V
         PERFORM DO-PRINT
         COMPUTE WS-V = (WS-V - 0.08) * 0.98
     END-PERFORM
*>   A diagonal walk at yaw 37.5 degrees (rotation through FUNCTION SIN and COS), 40 ticks, x printed.
     MOVE "yawx" TO WS-SERIES
     MOVE 0 TO WS-X WS-Z WS-VX WS-VZ
     MOVE 37.5 TO WS-YAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         COMPUTE WS-S = FUNCTION SIN(WS-YAW * FUNCTION PI / 180)
         COMPUTE WS-K = FUNCTION COS(WS-YAW * FUNCTION PI / 180)
         COMPUTE WS-VX = WS-VX - 0.098 * WS-S
         COMPUTE WS-VZ = WS-VZ + 0.098 * WS-K
         COMPUTE WS-X = WS-X + WS-VX
         COMPUTE WS-Z = WS-Z + WS-VZ
         MOVE WS-X TO WS-P
         PERFORM DO-PRINT
         COMPUTE WS-VX = WS-VX * 0.6 * 0.91
         COMPUTE WS-VZ = WS-VZ * 0.6 * 0.91
     END-PERFORM
*>   Comparisons near the thresholds of 13 section 1.3 step 2.
     MOVE 0.002999999 TO WS-L
     MOVE 0.003 TO WS-R
     PERFORM DO-LESS
     MOVE 0.0029999999999 TO WS-L
     PERFORM DO-LESS
     MOVE 0.00000899999 TO WS-L
     MOVE 0.000009 TO WS-R
     PERFORM DO-LESS
*>   Position changes far from the origin: is a small move seen as a change?
     MOVE 100.5 TO WS-R
     COMPUTE WS-L = WS-R + 0.000005
     PERFORM DO-DIFFERS
     MOVE 10000.5 TO WS-R
     COMPUTE WS-L = WS-R + 0.0005
     PERFORM DO-DIFFERS
     MOVE 100000.5 TO WS-R
     COMPUTE WS-L = WS-R + 0.005
     PERFORM DO-DIFFERS
     MOVE 1000000.5 TO WS-R
     COMPUTE WS-L = WS-R + 0.065
     PERFORM DO-DIFFERS
     MOVE 29999000.5 TO WS-R
     COMPUTE WS-L = WS-R + 0.28
     PERFORM DO-DIFFERS
*>   Timing: 200000 ticks of two-axis arithmetic with a sine and cosine each.
     MOVE 0 TO WS-X WS-Z WS-VX WS-VZ
     ACCEPT WS-T0 FROM TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200000
         COMPUTE WS-YAW = FUNCTION MOD(WS-I, 360) * FUNCTION PI / 180
         COMPUTE WS-S = FUNCTION SIN(WS-YAW)
         COMPUTE WS-K = FUNCTION COS(WS-YAW)
         IF WS-VX * WS-VX + WS-VZ * WS-VZ < 0.000009
             MOVE 0 TO WS-VX WS-VZ
         END-IF
         COMPUTE WS-VX = WS-VX - 0.098 * WS-S
         COMPUTE WS-VZ = WS-VZ + 0.098 * WS-K
         COMPUTE WS-X = WS-X + WS-VX
         COMPUTE WS-Z = WS-Z + WS-VZ
         COMPUTE WS-VX = WS-VX * 0.546
         COMPUTE WS-VZ = WS-VZ * 0.546
     END-PERFORM
     ACCEPT WS-T1 FROM TIME
     DISPLAY "T 200000 ticks HHMMSScc " WS-T0 " -> " WS-T1
     STOP RUN.

 DO-HORIZONTAL.
     MOVE 0 TO WS-V WS-P
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 55
         IF WS-V * WS-V < 0.000009
             MOVE 0 TO WS-V
         END-IF
         MOVE 0 TO WS-A
         IF WS-I <= 40
             COMPUTE WS-A = 0.98 * 0.1 * 0.21600002 / (WS-F * WS-F * WS-F)
         END-IF
         COMPUTE WS-V = WS-V + WS-A
         COMPUTE WS-P = WS-P + WS-V
         PERFORM DO-PRINT
         COMPUTE WS-V = WS-V * WS-F * 0.91
     END-PERFORM.

 DO-ICE.
     MOVE 0 TO WS-V WS-P
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         IF WS-V * WS-V < 0.000009
             MOVE 0 TO WS-V
         END-IF
         MOVE 0 TO WS-A
         IF WS-I <= 60
             COMPUTE WS-A = 0.98 * 0.1 * 0.21600002 / (WS-F * WS-F * WS-F)
         END-IF
         COMPUTE WS-V = WS-V + WS-A
         COMPUTE WS-P = WS-P + WS-V
         PERFORM DO-PRINT
         COMPUTE WS-V = WS-V * WS-F * 0.91
     END-PERFORM.

 DO-PRINT.
     COMPUTE WS-ED ROUNDED = WS-P
     DISPLAY "S " WS-SERIES " " WS-I " " WS-ED.

 DO-LESS.
     MOVE 0 TO WS-HAS
     IF WS-L < WS-R
         MOVE 1 TO WS-HAS
     END-IF
     COMPUTE WS-ED ROUNDED = WS-L * 1000000
     DISPLAY "C less a*1e6=" WS-ED " result=" WS-HAS.

 DO-DIFFERS.
     MOVE 0 TO WS-HAS
     IF WS-L NOT = WS-R
         MOVE 1 TO WS-HAS
     END-IF
     COMPUTE WS-ED ROUNDED = WS-R
     DISPLAY "C differs base=" WS-ED " seen=" WS-HAS
     COMPUTE WS-ED ROUNDED = WS-L - WS-R
     DISPLAY "C   delta=" WS-ED.
