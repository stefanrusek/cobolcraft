*> Equivalence test (002-lane-bugvlag): MOB-YAW-TOWARD takes the arctangent from libm (cc_f64_atan2_lib) where it took FUNCTION ATAN (libcob's multiple precision series, 150 microseconds a call).
*> The reference is the replaced statement (2 x ATAN(-dx / den) x 180 / PI into a FLOAT-SHORT) run in this program: 40000 random directions (every quadrant, lengths from 0.001 to 60
*> blocks), the axes, the diagonals, the direction exactly -Z and a nearly -Z one, and the zero direction (the yaw stays) must give the same single precision yaw, bit for bit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-YAW-TOWARD-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-NEW                 FLOAT-SHORT.
 01 WS-OLD                 FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 20261120.
 01 WS-PICK                BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-RUNS                BINARY-LONG VALUE 0.
 01 WS-BAD                 PIC -(4)9.99999999.
 01 WS-EXTRA.
    05 WS-X                FLOAT-LONG OCCURS 12 TIMES.
    05 WS-Z                FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-X(1) MOVE 1 TO WS-Z(1)
     MOVE 0 TO WS-X(2) MOVE -1 TO WS-Z(2)
     MOVE 1 TO WS-X(3) MOVE 0 TO WS-Z(3)
     MOVE -1 TO WS-X(4) MOVE 0 TO WS-Z(4)
     MOVE 1 TO WS-X(5) MOVE 1 TO WS-Z(5)
     MOVE -1 TO WS-X(6) MOVE 1 TO WS-Z(6)
     MOVE 1 TO WS-X(7) MOVE -1 TO WS-Z(7)
     MOVE -1 TO WS-X(8) MOVE -1 TO WS-Z(8)
     MOVE 0.000000001 TO WS-X(9) MOVE -1 TO WS-Z(9)
     MOVE -0.000000001 TO WS-X(10) MOVE -1 TO WS-Z(10)
     MOVE 0 TO WS-X(11) MOVE 0 TO WS-Z(11)
     MOVE 0.3 TO WS-X(12) MOVE 0.4 TO WS-Z(12)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-X(WS-I) TO WS-DX
         MOVE WS-Z(WS-I) TO WS-DZ
         PERFORM COMPARE-ONE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40000
         PERFORM DRAW
         COMPUTE WS-DX = (WS-PICK - 16384) / 16384
         PERFORM DRAW
         COMPUTE WS-DZ = (WS-PICK - 16384) / 16384
         PERFORM DRAW
         COMPUTE WS-SCALE = FUNCTION MOD(WS-PICK, 5)
         EVALUATE WS-SCALE
             WHEN 0
                 COMPUTE WS-DX = WS-DX * 0.001
                 COMPUTE WS-DZ = WS-DZ * 0.001
             WHEN 1
                 COMPUTE WS-DX = WS-DX * 0.1
                 COMPUTE WS-DZ = WS-DZ * 0.1
             WHEN 2
                 COMPUTE WS-DX = WS-DX * 10
                 COMPUTE WS-DZ = WS-DZ * 10
             WHEN 3
                 COMPUTE WS-DX = WS-DX * 60
                 COMPUTE WS-DZ = WS-DZ * 60
         END-EVALUATE
         PERFORM COMPARE-ONE
     END-PERFORM
     MOVE "bugvlag the yaw of MOB-YAW-TOWARD is bit for bit the yaw of the FUNCTION ATAN statement on 40012 directions" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugvlag the comparison ran on every direction" TO TL-CASE
     MOVE 40012 TO TL-EXPECTED-N
     MOVE WS-RUNS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COMPARE-ONE.
     MOVE 123.5 TO WS-NEW
     MOVE 123.5 TO WS-OLD
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-NEW
     COMPUTE WS-DEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) + WS-DZ
     EVALUATE TRUE
         WHEN WS-DEN NOT = 0
             COMPUTE WS-OLD = 2 * FUNCTION ATAN(- WS-DX / WS-DEN) * 180 / FUNCTION PI
         WHEN WS-DZ < 0
             MOVE 180 TO WS-OLD
     END-EVALUATE
     ADD 1 TO WS-RUNS
     IF WS-NEW NOT = WS-OLD
         ADD 1 TO WS-DIFFER
         MOVE WS-DX TO WS-BAD
         DISPLAY "DIFF dx " WS-BAD " dz " WS-DZ " new " WS-NEW " old " WS-OLD
     END-IF.

 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768).
 END PROGRAM TEST-MOB-YAW-TOWARD-EQUIV.
