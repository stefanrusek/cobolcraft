*> Implementation test (lane p46f, T27500; docs/protocol/05b 0x67 Set Entity Motion, 00 section 4.6 LpVec3, 13 section 1.3 travel): a Set Entity Motion packet whose entity id
*> is the local player's sets the player's velocity (knockback, a Riptide launch, a Lunge push): the horizontal part carries the player along and decays by 0.546 a tick on the
*> ground and 0.91 in the air, the vertical part lifts it, gravity and drag bring it down. A packet for another entity does not move the player. Expected positions come from the
*> independent model client/tests/fixtures/glide_model.py (knock): the packet (0.4, 0.36, -0.2) as an LpVec3 decodes to (0.39998779, 0.36000732, -0.20002442) and the player
*> stands on the floor at (0.5, 10, 0.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOTION-LOCAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG VALUE 1.
 01 WS-OTHER               BINARY-LONG VALUE 77.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-STEPS               BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-NX                  PIC X(12).
 01 WS-NY                  PIC X(12).
 01 WS-NZ                  PIC X(12).
 01 WS-TEXT-X              PIC -(3)9.999.
 01 WS-TEXT-Y              PIC -(3)9.999.
 01 WS-TEXT-Z              PIC -(3)9.999.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
*>   A packet for another entity: the player stays on the floor.
     MOVE 0.4 TO WS-VX
     MOVE 0.36 TO WS-VY
     MOVE -0.2 TO WS-VZ
     CALL "TEST-MOTION" USING CLIENT-STATE WS-CONN WS-OTHER WS-VX WS-VY WS-VZ
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE "test motion local: a packet for another entity does not move the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(PL-X - 0.5) < 0.0001 AND FUNCTION ABS(PL-Z - 0.5) < 0.0001 AND FUNCTION ABS(PL-Y - 10) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Knockback for the player: after 1, 2, 5, 12 and 40 ticks (the model's table).
     CALL "TEST-MOTION" USING CLIENT-STATE WS-CONN WS-ID WS-VX WS-VY WS-VZ
     MOVE 1 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "0.900 10.360 0.300" TO TL-EXPECTED
     MOVE "test motion local: tick 1 of a knockback" TO TL-CASE
     PERFORM CHECK-POSITION
     CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
     MOVE "1.118 10.634 0.191" TO TL-EXPECTED
     MOVE "test motion local: tick 2 of a knockback" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 3 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "1.663 10.961 -0.081" TO TL-EXPECTED
     MOVE "test motion local: tick 5 of a knockback" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 7 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "2.433 10.000 -0.466" TO TL-EXPECTED
     MOVE "test motion local: tick 12 of a knockback (landed)" TO TL-CASE
     PERFORM CHECK-POSITION
     MOVE 28 TO WS-STEPS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-STEPS
     MOVE "2.489 10.000 -0.492" TO TL-EXPECTED
     MOVE "test motion local: tick 40 of a knockback (the push is spent)" TO TL-CASE
     PERFORM CHECK-POSITION
     STOP RUN.

*> The position to three decimals, or the expected text when it is within 0.0015 of it (so that rounding at the last digit does not decide).
 CHECK-POSITION.
     MOVE "T" TO TL-MODE
     COMPUTE WS-TEXT-X ROUNDED = PL-X
     COMPUTE WS-TEXT-Y ROUNDED = PL-Y
     COMPUTE WS-TEXT-Z ROUNDED = PL-Z
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT-X) " " FUNCTION TRIM(WS-TEXT-Y) " " FUNCTION TRIM(WS-TEXT-Z)
         DELIMITED BY SIZE INTO TL-OBSERVED
     UNSTRING TL-EXPECTED DELIMITED BY SPACE INTO WS-NX WS-NY WS-NZ
     MOVE FUNCTION NUMVAL(WS-NX) TO WS-EX
     MOVE FUNCTION NUMVAL(WS-NY) TO WS-EY
     MOVE FUNCTION NUMVAL(WS-NZ) TO WS-EZ
     IF FUNCTION ABS(PL-X - WS-EX) < 0.0015 AND FUNCTION ABS(PL-Y - WS-EY) < 0.0015 AND FUNCTION ABS(PL-Z - WS-EZ) < 0.0015
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     .
 END PROGRAM TEST-MOTION-LOCAL.
 COPY CLTEST.
