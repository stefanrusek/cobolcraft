*> Firework rocket initial velocity (docs/protocol/21 section 8.7; lane 002-lane-p49e, T18530): (triangle(0, 0.002297), 0.05, triangle(0, 0.002297)): over thirty rockets every
*> horizontal component stays within 0.002297 in magnitude, some are not zero, they differ and the vertical component is always 0.05.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DURATION            BINARY-LONG VALUE 2.
 01 WS-STARS               BINARY-LONG VALUE 1.
 01 WS-ATTACHED            BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-MICRO               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG VALUE 0.
 01 WS-NONZERO             BINARY-LONG VALUE 0.
 01 WS-VYBAD               BINARY-LONG VALUE 0.
 01 WS-FIRST               BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-VY                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = PL-X(WS-PLAYER) + 12
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 10
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
         COMPUTE WS-MICRO ROUNDED = EN-VX(WS-ROW) * 1000000
         IF WS-I = 1
             MOVE WS-MICRO TO WS-FIRST
         END-IF
         IF WS-MICRO NOT = WS-FIRST
             MOVE 1 TO WS-DIFFER
         END-IF
         IF WS-MICRO > 2297 OR WS-MICRO < -2297
             ADD 1 TO WS-OUT
         END-IF
         IF WS-MICRO NOT = 0
             ADD 1 TO WS-NONZERO
         END-IF
         COMPUTE WS-MICRO ROUNDED = EN-VZ(WS-ROW) * 1000000
         IF WS-MICRO > 2297 OR WS-MICRO < -2297
             ADD 1 TO WS-OUT
         END-IF
         IF WS-MICRO NOT = 0
             ADD 1 TO WS-NONZERO
         END-IF
         COMPUTE WS-VY ROUNDED = EN-VY(WS-ROW) * 1000
         IF WS-VY NOT = 50
             ADD 1 TO WS-VYBAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§8.7 Firework rocket: no horizontal component exceeds 0.002297" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: most horizontal components are not zero" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NONZERO >= 50
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: the rockets do not all start alike" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: the vertical component is 0.05" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VYBAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-8-7.
 COPY CORETEST.
 COPY MOBSPTEST.
