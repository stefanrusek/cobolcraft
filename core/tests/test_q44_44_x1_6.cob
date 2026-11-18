*> Acceptance test of docs/protocol/44-residual-mob-questions-x1-continuation.md section 6 (and 8.8 for the stroll aim) as rule functions (lane 002-lane-p49j-b, T24300 range): the phantom
*> touching test, the vex move control step and yaw (a standard atan, Open question 6), the patrol aim point with its 90 radian rotation (worked example about (9.57, 2.91)), the leader draw,
*> removeWhenFarAway and canUse. The patrol code of mob-20-patrol.cob does not call these functions (lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X1-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 3.99 TO WS-A
     CALL "X1-PHANTOM-TOUCH" USING WS-A WS-N1
     MOVE "acceptance US15 44-x1§6 6.1 touchingTarget at squared distance 3.99" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4.0 TO WS-A
     CALL "X1-PHANTOM-TOUCH" USING WS-A WS-N1
     MOVE "acceptance US15 44-x1§6 6.1 not touching at squared distance 4.0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.5 TO WS-A
     MOVE 0.8 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0.5 TO WS-D
     MOVE 0 TO WS-E WS-F
     CALL "X1-VEX-MOVE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-N1 WS-G WS-H WS-J
     MOVE "acceptance US15 44-x1§6 6.2 closer than the box size: WAIT" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-A
     MOVE 0.8 TO WS-B
     MOVE 1 TO WS-C
     MOVE 2 TO WS-D
     MOVE 0 TO WS-E WS-F
     CALL "X1-VEX-MOVE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-N1 WS-G WS-H WS-J
     MOVE "acceptance US15 44-x1§6 6.2 farther: the velocity grows by v / len x speed x 0.05 (x, thousandths)" TO WS-CASE
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-G * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§6 6.2 the move is not a wait" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-A
     MOVE 0.8 TO WS-B
     MOVE 2 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "X1-VEX-MOVE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-N1 WS-G WS-H WS-J
     MOVE "acceptance US15 44-x1§6 6.2 speed modifier 2 with v.y 1 of len 2: y step 0.05 (thousandths)" TO WS-CASE
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-H * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (1, 1) is -45 degrees" TO WS-CASE
     MOVE -45 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (0, 1) is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (1, 0) is -90" TO WS-CASE
     MOVE -90 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -1 TO WS-A
     MOVE 0 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (-1, 0) is +90" TO WS-CASE
     MOVE 90 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE -1 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (0, -1) is -180" TO WS-CASE
     MOVE -180 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -1 TO WS-A
     MOVE -1 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of delta (-1, -1) is +135" TO WS-CASE
     MOVE 135 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "X1-VEX-YAW" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-x1§6 6.2 yaw of a zero delta is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 400 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-PATROL-AIM" USING WS-A WS-B WS-N1 WS-N2 WS-C WS-D
     MOVE "acceptance US15 44-x1§6 6.3 worked example: leader at (0, 0), patrol block (400, 0): aim x about 9.57 (thousandths)" TO WS-CASE
     MOVE 9566 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§6 6.3 worked example: aim z about 2.91 (thousandths)" TO WS-CASE
     MOVE 2914 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.5 TO WS-A
     MOVE 0.5 TO WS-B
     MOVE 30 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X1-STROLL-AIM" USING WS-A WS-B WS-N1 WS-N2 WS-C WS-D
     MOVE "acceptance US15 44-x1§6 8.8 stroll worked example: aim x 10.5" TO WS-CASE
     MOVE 10500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x1§6 8.8 stroll worked example: aim z 0.5" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-A
     CALL "X1-PATROL-REMOVE" USING WS-N1 WS-A WS-N2
     MOVE "acceptance US15 44-x1§6 6.3 not patrolling: removed when far away" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 16384 TO WS-A
     CALL "X1-PATROL-REMOVE" USING WS-N1 WS-A WS-N2
     MOVE "acceptance US15 44-x1§6 6.3 patrolling at exactly 128 blocks (16384): kept" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 16385 TO WS-A
     CALL "X1-PATROL-REMOVE" USING WS-N1 WS-A WS-N2
     MOVE "acceptance US15 44-x1§6 6.3 patrolling beyond 128 blocks: removed" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.059 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X1-PATROL-LEADER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§6 6.3 a natural spawn with nextFloat 0.059 that can lead is the leader" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.06 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X1-PATROL-LEADER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§6 6.3 nextFloat 0.06 is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0.0 TO WS-A
     MOVE 1 TO WS-N2
     CALL "X1-PATROL-LEADER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§6 6.3 a PATROL, EVENT or STRUCTURE spawn is never the leader" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.0 TO WS-A
     MOVE 0 TO WS-N2
     CALL "X1-PATROL-LEADER" USING WS-N1 WS-A WS-N2 WS-N3
     MOVE "acceptance US15 44-x1§6 6.3 a mob that cannot lead (witch, ravager) is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: time at the cooldown, patrolling, no target, no passenger, has a patrol target" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 99 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: before the cooldown ends" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: not patrolling" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: with an attack target" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 1 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: with a controlling passenger" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 100 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     CALL "X1-PATROL-CAN-USE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7
     MOVE "acceptance US15 44-x1§6 6.3 canUse: without a patrol target" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N7
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X1-6.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
