*> Implementation test of lane bugviewbob (T62430-T62432; docs/protocol/12 section 6.1: the hurt tilt and view bobbing are the first frames of the hand's pose stack): the
*> held item's mesh is the one built at rest transformed by the pose (v' = R v + T, R and T the 12 numbers of scratchpad/models/view_pose.py for the scenario), it is built
*> again when only the pose changed and kept while the pose stays the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-VIEW-BOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SCENARIO            PIC X(160).
 01 WS-REST.
    05 WS-RV               OCCURS 12 TIMES.
       10 WS-RX            FLOAT-LONG.
       10 WS-RY            FLOAT-LONG.
       10 WS-RZ            FLOAT-LONG.
 01 WS-POSE-TABLE.
    05 WS-POSE-R           FLOAT-LONG OCCURS 9 TIMES.
    05 WS-POSE-T           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 1 TO CL-HAND-NOCULL
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 0 TO CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1 TO CL-PARTIAL
     MOVE 30 TO PL-HEALTH
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "hand pose: at rest the first mesh is built (not reused)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-HAND-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE RL-HAND-X(WS-I) TO WS-RX(WS-I)
         MOVE RL-HAND-Y(WS-I) TO WS-RY(WS-I)
         MOVE RL-HAND-Z(WS-I) TO WS-RZ(WS-I)
     END-PERFORM
*>   Scenario: walking at partial 0.5.
     MOVE "walking at partial 0.5" TO WS-SCENARIO
     MOVE 0.5 TO CL-PARTIAL
     MOVE 0.06 TO PL-BOB-O
     MOVE 0.1 TO PL-BOB
     MOVE 9.8 TO PL-WALK-O
     MOVE 10.0 TO PL-WALK
     MOVE 30 TO PL-HEALTH
     MOVE 0 TO PL-DEATH-TIME
     MOVE 0 TO PL-HURT-UNTIL
     MOVE 0 TO PL-HURT-DIR
     MOVE 0.999999 TO WS-POSE-R(1)
     MOVE 0.001294 TO WS-POSE-R(2)
     MOVE -0.000008 TO WS-POSE-R(3)
     MOVE -0.001294 TO WS-POSE-R(4)
     MOVE 0.999981 TO WS-POSE-R(5)
     MOVE -0.006079 TO WS-POSE-R(6)
     MOVE 0.000000 TO WS-POSE-R(7)
     MOVE 0.006079 TO WS-POSE-R(8)
     MOVE 0.999982 TO WS-POSE-R(9)
     MOVE -0.012361 TO WS-POSE-T(1)
     MOVE -0.076085 TO WS-POSE-T(2)
     MOVE 0.000000 TO WS-POSE-T(3)
     PERFORM CHECK-HAND
*>   Scenario: hurt 0.5 direction 90 alive, no walking.
     MOVE "hurt 0.5 direction 90 alive, no walking" TO WS-SCENARIO
     MOVE 1.0 TO CL-PARTIAL
     MOVE 0 TO PL-BOB-O
     MOVE 0 TO PL-BOB
     MOVE 0 TO PL-WALK-O
     MOVE 0 TO PL-WALK
     MOVE 30 TO PL-HEALTH
     MOVE 0 TO PL-DEATH-TIME
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 250
     MOVE 90 TO PL-HURT-DIR
     MOVE 1.000000 TO WS-POSE-R(1)
     MOVE 0.000000 TO WS-POSE-R(2)
     MOVE 0.000000 TO WS-POSE-R(3)
     MOVE 0.000000 TO WS-POSE-R(4)
     MOVE 0.998864 TO WS-POSE-R(5)
     MOVE -0.047652 TO WS-POSE-R(6)
     MOVE 0.000000 TO WS-POSE-R(7)
     MOVE 0.047652 TO WS-POSE-R(8)
     MOVE 0.998864 TO WS-POSE-R(9)
     MOVE 0.000000 TO WS-POSE-T(1)
     MOVE 0.000000 TO WS-POSE-T(2)
     MOVE 0.000000 TO WS-POSE-T(3)
     PERFORM CHECK-HAND
*>   Scenario: dying (deathTime 10 + 0.5) with a hurt 0.5 direction 90 and bobbing: the hurt tilt stays.
     MOVE "dying (deathTime 10 + 0.5) with a hurt 0.5 direction 90 and bobbing: the hurt tilt stays" TO WS-SCENARIO
     MOVE 0.5 TO CL-PARTIAL
     MOVE 0.04 TO PL-BOB-O
     MOVE 0.08 TO PL-BOB
     MOVE 1.0 TO PL-WALK-O
     MOVE 1.3 TO PL-WALK
     MOVE 0 TO PL-HEALTH
     MOVE 10 TO PL-DEATH-TIME
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 250
     MOVE 90 TO PL-HURT-DIR
     MOVE 0.999281 TO WS-POSE-R(1)
     MOVE -0.037878 TO WS-POSE-R(2)
     MOVE 0.001668 TO WS-POSE-R(3)
     MOVE 0.037914 TO WS-POSE-R(4)
     MOVE 0.998135 TO WS-POSE-R(5)
     MOVE -0.047847 TO WS-POSE-R(6)
     MOVE 0.000148 TO WS-POSE-R(7)
     MOVE 0.047876 TO WS-POSE-R(8)
     MOVE 0.998853 TO WS-POSE-R(9)
     MOVE 0.029939 TO WS-POSE-T(1)
     MOVE -0.008338 TO WS-POSE-T(2)
     MOVE -0.000447 TO WS-POSE-T(3)
     PERFORM CHECK-HAND
*>   The same state again: the mesh already uploaded is kept.
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "hand pose: the same pose again keeps the mesh already uploaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-HAND.
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE SPACES TO TL-CASE
     STRING "hand pose, " DELIMITED BY SIZE WS-SCENARIO DELIMITED BY "  " ": the mesh was built again for the new pose" DELIMITED BY SIZE
         INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         COMPUTE WS-X = WS-POSE-R(1) * WS-RX(WS-I) + WS-POSE-R(2) * WS-RY(WS-I) + WS-POSE-R(3) * WS-RZ(WS-I) + WS-POSE-T(1)
         COMPUTE WS-Y = WS-POSE-R(4) * WS-RX(WS-I) + WS-POSE-R(5) * WS-RY(WS-I) + WS-POSE-R(6) * WS-RZ(WS-I) + WS-POSE-T(2)
         COMPUTE WS-Z = WS-POSE-R(7) * WS-RX(WS-I) + WS-POSE-R(8) * WS-RY(WS-I) + WS-POSE-R(9) * WS-RZ(WS-I) + WS-POSE-T(3)
         IF FUNCTION ABS(RL-HAND-X(WS-I) - WS-X) > 0.00005 OR FUNCTION ABS(RL-HAND-Y(WS-I) - WS-Y) > 0.00005
                 OR FUNCTION ABS(RL-HAND-Z(WS-I) - WS-Z) > 0.00005
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "hand pose, " DELIMITED BY SIZE WS-SCENARIO DELIMITED BY "  " ": the first 12 vertices are the rest mesh moved by the pose" DELIMITED BY SIZE
         INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HAND-VIEW-BOB.
 COPY CLTEST.
