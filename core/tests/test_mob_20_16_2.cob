*> Implementation test (lane p49r; docs/protocol/20 section 16.2, 16.4, 16.5): the breeze's numbers. The expected values are the document's worked tables (the jump vectors for L = 8 and 16 and
*> for a target 3 blocks higher at L = 10, checked independently in Python against the formulas of 16.4) and Python evaluations of the formulas of 16.2 and 16.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW             FLOAT-LONG OCCURS 6 TIMES.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG VALUE 0.
 01 WS-PY                  FLOAT-LONG VALUE 64.
 01 WS-PZ                  FLOAT-LONG VALUE 0.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG VALUE 0.
 01 WS-FOLLOW              FLOAT-LONG VALUE 24.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.08.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PICKS.
    05 WS-PICK             BINARY-LONG OCCURS 4 TIMES.
 01 WS-PICKED              BINARY-LONG.
 01 WS-GAUSS               FLOAT-LONG.
 01 WS-UNIT                FLOAT-LONG.
 01 WS-HEAD                FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-NAME                PIC X(60).
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-YD                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
*> The document's table: horizontal and vertical component after 0.95, thousandths per row (L 8 then L 16, angles 40 55 60 75 80); -1 is a rejected angle.
 01 WS-DATA.
    05 FILLER BINARY-LONG VALUE 587.
    05 FILLER BINARY-LONG VALUE 492.
    05 FILLER BINARY-LONG VALUE 450.
    05 FILLER BINARY-LONG VALUE 642.
    05 FILLER BINARY-LONG VALUE 408.
    05 FILLER BINARY-LONG VALUE 707.
    05 FILLER BINARY-LONG VALUE 278.
    05 FILLER BINARY-LONG VALUE 1038.
    05 FILLER BINARY-LONG VALUE 226.
    05 FILLER BINARY-LONG VALUE 1280.
    05 FILLER BINARY-LONG VALUE 830.
    05 FILLER BINARY-LONG VALUE 696.
    05 FILLER BINARY-LONG VALUE 636.
    05 FILLER BINARY-LONG VALUE 908.
    05 FILLER BINARY-LONG VALUE 578.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-ENTRY OCCURS 10 TIMES.
       10 WS-HORIZONTAL    BINARY-LONG.
       10 WS-VERTICAL      BINARY-LONG.
 01 WS-LTEXT               PIC 99.
 01 WS-ATEXT               PIC 99.
 01 WS-DIFF                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   16.2: the shot at Normal (uncertainty -3), aim (3, 0, 4), draws 0.9 0.3 0.2 0.7 0.5 0.5.
     MOVE 3 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 4 TO WS-DZ
     MOVE -3 TO WS-U
     MOVE 0.9 TO WS-DRAW(1)
     MOVE 0.3 TO WS-DRAW(2)
     MOVE 0.2 TO WS-DRAW(3)
     MOVE 0.7 TO WS-DRAW(4)
     MOVE 0.5 TO WS-DRAW(5)
     MOVE 0.5 TO WS-DRAW(6)
     CALL "BREEZE-AIM-VECTOR" USING WS-DX WS-DY WS-DZ WS-U WS-DRAWS WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: the shot x component (millionths): (0.6 - 0.0310095) x 0.699999988" TO TL-CASE
     MOVE 398293 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: the shot y component (millionths): 0.0258413 x 0.699999988" TO TL-CASE
     MOVE 18089 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VY * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: the shot z component (millionths): 0.8 x 0.699999988" TO TL-CASE
     MOVE 560000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VZ * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The jump vector of one angle against the table of 16.4 (L is after the 0.5 reduction: the target's x is L + 0.5).
     PERFORM VARYING WS-L FROM 8 BY 8 UNTIL WS-L > 16
         COMPUTE WS-QX = WS-L + 0.5
         MOVE 64 TO WS-QY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             EVALUATE WS-I
                 WHEN 1 MOVE 40 TO WS-ANGLE
                 WHEN 2 MOVE 55 TO WS-ANGLE
                 WHEN 3 MOVE 60 TO WS-ANGLE
                 WHEN 4 MOVE 75 TO WS-ANGLE
                 WHEN OTHER MOVE 80 TO WS-ANGLE
             END-EVALUATE
             CALL "BREEZE-JUMP-VECTOR" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-ANGLE WS-OK WS-VX WS-VY WS-VZ
             PERFORM CHECK-ROW
         END-PERFORM
     END-PERFORM
*>   A target 3 blocks higher at L = 10: 40 (0.8183, 0.6867), 55 (0.5657, 0.8079), 60 (0.5021, 0.8696), 75 (0.3243, 1.2104), 80 rejected.
     MOVE 10.5 TO WS-QX
     MOVE 67 TO WS-QY
     MOVE 40 TO WS-ANGLE
     CALL "BREEZE-JUMP-VECTOR" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-ANGLE WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: 3 blocks higher at L 10, 40 degrees: horizontal 0.8183 (thousandths)" TO TL-CASE
     MOVE 818 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION SQRT(WS-VX * WS-VX + WS-VZ * WS-VZ) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: and vertical 0.6867 (thousandths)" TO TL-CASE
     MOVE 687 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VY * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 80 TO WS-ANGLE
     CALL "BREEZE-JUMP-VECTOR" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-ANGLE WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: 3 blocks higher at L 10, 80 degrees is rejected (1.5715 > 1.4)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The shuffled pick: all draws 0 gives [55 60 75 80 40], the identity draws (4 3 2 1) [40 55 60 75 80], draws (0 3 2 1) [80 55 60 75 40].
     MOVE 8.5 TO WS-QX
     MOVE 64 TO WS-QY
     MOVE 0 TO WS-PICK(1) WS-PICK(2) WS-PICK(3) WS-PICK(4)
     CALL "BREEZE-JUMP-PICK" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-PICKS WS-PICKED WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: the shuffle with draws 0 0 0 0 starts with 55 degrees" TO TL-CASE
     MOVE 55 TO TL-EXPECTED-N
     MOVE WS-PICKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-PICK(1)
     MOVE 3 TO WS-PICK(2)
     MOVE 2 TO WS-PICK(3)
     MOVE 1 TO WS-PICK(4)
     CALL "BREEZE-JUMP-PICK" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-PICKS WS-PICKED WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: the draws 4 3 2 1 leave the list as it is: 40 degrees" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-PICKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16.5 TO WS-QX
     MOVE 0 TO WS-PICK(1)
     MOVE 3 TO WS-PICK(2)
     MOVE 2 TO WS-PICK(3)
     MOVE 1 TO WS-PICK(4)
     CALL "BREEZE-JUMP-PICK" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-PICKS WS-PICKED WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: at L 16 the list starting with 80 (rejected) falls through to 55" TO TL-CASE
     MOVE 55 TO TL-EXPECTED-N
     MOVE WS-PICKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: and its horizontal component is the 55 degree row (0.636)" TO TL-CASE
     MOVE 636 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   16.5: the point behind the target. A target facing +z (head yaw 0), deviation 0, unit 0.5: 6 blocks along -z.
     MOVE 10 TO WS-TX
     MOVE 64 TO WS-TY
     MOVE 10 TO WS-TZ
     MOVE 0 TO WS-HEAD WS-GAUSS
     MOVE 0.5 TO WS-UNIT
     CALL "BREEZE-POINT-BEHIND" USING WS-TX WS-TY WS-TZ WS-HEAD WS-GAUSS WS-UNIT WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: behind a target facing +z: x stays (hundredths)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: and z is 6 blocks behind (hundredths)" TO TL-CASE
     MOVE 400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VZ * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Facing -x (head yaw 90), unit 0: 4 blocks along +x.
     MOVE 90 TO WS-HEAD
     MOVE 0 TO WS-UNIT
     CALL "BREEZE-POINT-BEHIND" USING WS-TX WS-TY WS-TZ WS-HEAD WS-GAUSS WS-UNIT WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: behind a target facing -x: 4 blocks along +x (hundredths)" TO TL-CASE
     MOVE 1400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Deviation 1.0 (45 degrees), unit 0.25 (5 blocks), facing +z: (+3.5355, -3.5355).
     MOVE 0 TO WS-HEAD
     MOVE 1.0 TO WS-GAUSS
     MOVE 0.25 TO WS-UNIT
     CALL "BREEZE-POINT-BEHIND" USING WS-TX WS-TY WS-TZ WS-HEAD WS-GAUSS WS-UNIT WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: a deviation of 1 sigma turns the point 45 degrees: x (hundredths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (10 + 3.5355339) * 100
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: and z (hundredths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (10 - 3.5355339) * 100
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VZ * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The middle circle point: the target 20 blocks away, unit 0.5 (6 short of it): 14 along the line; a target 5 away, unit 0 (8 short): 3 behind the breeze.
     MOVE 0 TO WS-TX
     MOVE 64 TO WS-TY
     MOVE 20 TO WS-TZ
     MOVE 0.5 TO WS-UNIT
     CALL "BREEZE-POINT-MIDDLE" USING WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-UNIT WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: the middle point is 14 along the line to a target 20 away (hundredths)" TO TL-CASE
     MOVE 1400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VZ * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-TZ
     MOVE 0 TO WS-UNIT
     CALL "BREEZE-POINT-MIDDLE" USING WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-UNIT WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: a target 5 away: the point is 3 behind the breeze (hundredths)" TO TL-CASE
     MOVE -300 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-VZ * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The jump vector refuses a target straight above the breeze (no horizontal distance) and one too high for the angle (the denominator of v2 is negative).
     MOVE 0.5 TO WS-QX
     MOVE 64 TO WS-QY
     MOVE 0 TO WS-QZ
     MOVE 40 TO WS-ANGLE
     CALL "BREEZE-JUMP-VECTOR" USING WS-PX WS-PY WS-PZ WS-PX WS-QY WS-PZ WS-FOLLOW WS-GRAVITY WS-ANGLE WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: a jump target straight above the breeze gives no vector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8.5 TO WS-QX
     MOVE 84 TO WS-QY
     CALL "BREEZE-JUMP-VECTOR" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-ANGLE WS-OK WS-VX WS-VY WS-VZ
     MOVE "test mob 20 16: a target 20 blocks higher at L 8 and 40 degrees gives no vector (v2 below 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   getPosAway in the four quadrants and on the axes: with the angle draw 0.5 the point lies along (mob - from) at dist = 0.5 x 5 x sqrt 2 = 3.5355 (draw 0.25).
     MOVE 0.5 TO WS-MX
     MOVE 64 TO WS-MY
     MOVE 0.5 TO WS-MZ
     MOVE 5 TO WS-H WS-V
     MOVE 0.5 TO WS-D1
     MOVE 0.25 TO WS-D2
     MOVE 5 TO WS-YD
     COMPUTE WS-AX = WS-MX - 3
     COMPUTE WS-AZ = WS-MZ - 4
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: getPosAway with the target to the south-west: the point is away, x 2 and z 3" TO TL-CASE
     MOVE 203 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BX * 100 + WS-BZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AX = WS-MX + 3
     COMPUTE WS-AZ = WS-MZ - 4
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: target to the south-east: the point is x -2, z 3" TO TL-CASE
     MOVE -197 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BX * 100 + WS-BZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-AX = WS-MX + 3
     COMPUTE WS-AZ = WS-MZ + 4
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: target to the north-east: the point is x -2, z -3" TO TL-CASE
     MOVE -203 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BX * 100 + WS-BZ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-MX TO WS-AX
     COMPUTE WS-AZ = WS-MZ - 5
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: target due north of the mob (dx 0, dz positive): the point is z 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-BZ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-MX TO WS-AX
     MOVE WS-MZ TO WS-AZ
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: mob and target at the same spot (atan2 0): the point is x 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-BX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   getPosAway (16.5): the mob at (0.5, 64, 0.5), the target at (0.5, 5.5): away is -z. Angle draw 0.5, dist draw 0.25: dist = 0.5 x 5 x sqrt 2 = 3.5355, the block (0, 64, -4).
     MOVE 0.5 TO WS-MX
     MOVE 64 TO WS-MY
     MOVE 0.5 TO WS-MZ
     MOVE 0.5 TO WS-AX
     MOVE 5.5 TO WS-AZ
     MOVE 5 TO WS-H WS-V
     MOVE 0.5 TO WS-D1
     MOVE 0.25 TO WS-D2
     MOVE 5 TO WS-YD
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: getPosAway straight away: z of the block is -4" TO TL-CASE
     MOVE -4 TO TL-EXPECTED-N
     MOVE WS-BZ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test mob 20 16: and x stays 0 and y 64 (the y draw 5 is the offset 0)" TO TL-CASE
     MOVE 6400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BY * 100 + WS-BX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The angle draw 0 turns the direction 90 degrees: x = -3.5355 (block -4), z = 0 (block 0).
     MOVE 0 TO WS-D1
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: getPosAway with the angle draw 0 is 90 degrees to the side: x -4, z 0" TO TL-CASE
     MOVE -4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A distance draw of 0.81 gives 6.36 blocks: beyond h = 5, rejected; the y draw 0 gives the offset -5.
     MOVE 0.5 TO WS-D1
     MOVE 0.81 TO WS-D2
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: getPosAway beyond the horizontal range is rejected" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.25 TO WS-D2
     MOVE 0 TO WS-YD
     CALL "BREEZE-POS-AWAY" USING WS-MX WS-MY WS-MZ WS-AX WS-AZ WS-H WS-V WS-D1 WS-D2 WS-YD WS-OK WS-BX WS-BY WS-BZ
     MOVE "test mob 20 16: the y draw 0 gives the offset -5" TO TL-CASE
     MOVE 59 TO TL-EXPECTED-N
     MOVE WS-BY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> One row of the table: WS-L (8 then 16) and WS-I (the angle) pick the entry of WS-TABLE; the components agree within a thousandth.
 CHECK-ROW.
     COMPUTE WS-ROW = ((WS-L / 8) - 1) * 5 + WS-I
     MOVE WS-L TO WS-LTEXT
     MOVE WS-ANGLE TO WS-ATEXT
     MOVE SPACES TO WS-NAME
     STRING "test mob 20 16: jump vector L " DELIMITED BY SIZE WS-LTEXT DELIMITED BY SIZE " angle " DELIMITED BY SIZE WS-ATEXT DELIMITED BY SIZE
         " " DELIMITED BY SIZE INTO WS-NAME
     IF WS-HORIZONTAL(WS-ROW) < 0
         MOVE WS-NAME TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ELSE
         MOVE WS-NAME TO TL-CASE
         MOVE WS-HORIZONTAL(WS-ROW) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = WS-VX * 1000
         COMPUTE WS-DIFF = FUNCTION ABS(TL-OBSERVED-N - TL-EXPECTED-N)
         IF WS-DIFF <= 1
             MOVE TL-EXPECTED-N TO TL-OBSERVED-N
         END-IF
         STRING "horizontal" DELIMITED BY SIZE INTO WS-NAME(40:10)
         MOVE WS-NAME TO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE WS-VERTICAL(WS-ROW) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = WS-VY * 1000
         COMPUTE WS-DIFF = FUNCTION ABS(TL-OBSERVED-N - TL-EXPECTED-N)
         IF WS-DIFF <= 1
             MOVE TL-EXPECTED-N TO TL-OBSERVED-N
         END-IF
         STRING "vertical  " DELIMITED BY SIZE INTO WS-NAME(40:10)
         MOVE WS-NAME TO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF
     .
 END PROGRAM TEST-MOB-20-16-2.
