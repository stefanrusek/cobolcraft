*> Implementation test (lane 002-lane-p49s, T38580; docs/protocol/44-residual-mob-questions-x1-continuation.md section 11.1, 10 section 16.4): MTH-ATAN2 is the table routine, not the libm
*> arc tangent: (1, 1) is 0x3FE921FB45E6D12F, about 1.7e-9 below pi/4; (0, -1) is pi and (0, 0) is 0; MTH-ATAN2-DEG multiplies by the float constant 57.2957763671875; the arrows' yaw and pitch
*> (ARROW-SPAWN) are atan2(vx, vz) and atan2(vy, horizontal speed) in those degrees.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MTH-ATAN2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-PLAYER              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-Y WS-X
     CALL "MTH-ATAN2" USING WS-Y WS-X WS-R
     COMPUTE WS-D = FUNCTION ATAN(1) - WS-R
     MOVE "acceptance US15 44-x1§11.1 atan2(1, 1) is below the libm value (the table routine)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D > 0.0000000001 AND WS-D < 0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.1 atan2(1, 1) is 0.7853981 to 7 places" TO TL-CASE
     MOVE 7853981 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-R * 10000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-Y
     MOVE -1 TO WS-X
     CALL "MTH-ATAN2" USING WS-Y WS-X WS-R
     MOVE "acceptance US15 44-x1§11.1 atan2(0, -1) is pi" TO TL-CASE
     MOVE 31415926 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-R * 10000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X
     CALL "MTH-ATAN2" USING WS-Y WS-X WS-R
     MOVE "acceptance US15 44-x1§11.1 atan2(0, 0) is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-R * 10000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-Y
     MOVE -4 TO WS-X
     CALL "MTH-ATAN2" USING WS-Y WS-X WS-R
     MOVE "acceptance US15 44-x1§11.1 atan2(3, -4) is 0x4003FC19CD3C7E4C = 2.4980960 (doc 10 16.8 vector)" TO TL-CASE
     MOVE 24980960 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-R * 10000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -2 TO WS-Y
     MOVE 0.5 TO WS-X
     CALL "MTH-ATAN2" USING WS-Y WS-X WS-R
     MOVE "acceptance US15 44-x1§11.1 atan2(-2, 0.5) is 0xBFF5368CCF5A6268 = -1.3258178 (doc 10 16.8 vector)" TO TL-CASE
     MOVE -13258178 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-R * 10000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-Y
     MOVE 0 TO WS-X
     CALL "MTH-ATAN2-DEG" USING WS-Y WS-X WS-D
     MOVE "acceptance US15 44-x1§11.1 atan2(1, 0) in degrees uses the float constant (89.999995)" TO TL-CASE
     MOVE 89999995 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-D * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An arrow shot east (+x) at a downward slope: yaw atan2(vx, vz) = 90 degrees, pitch atan2(vy, horizontal).
     MOVE 1 TO WS-VX
     MOVE -1 TO WS-VY
     MOVE 0 TO WS-VZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-ZERO WS-ZERO-Y WS-ZERO-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ROW
     MOVE "acceptance US15 44-x1§11.1 an arrow flying east has yaw 90 (within 0.0001)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-YAW(WS-ROW) > 89.9999 AND EN-YAW(WS-ROW) < 90.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x1§11.1 and pitch -45" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PITCH(WS-ROW) > -45.0001 AND EN-PITCH(WS-ROW) < -44.9999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MTH-ATAN2.

 COPY CORETEST.
 COPY MOBSPTEST.
