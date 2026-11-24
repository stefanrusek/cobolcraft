*> The flight of a firework rocket (docs/protocol/21 section 8.7; lane p49t, T39010): each tick a rocket that is not attached to an entity and was not shot at an angle takes
*> velocity = (vx x 1.15, vy x 1.0 + 0.04, vz x 1.15), then moves by that velocity and keeps it. An attached rocket or one shot at an angle (PJ-I5 1, the crossbow and the dispenser) does not accelerate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-7B.
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
 01 WS-SLOT                BINARY-LONG.
 01 WS-DURATION            BINARY-LONG VALUE 20.
 01 WS-STARS               BINARY-LONG VALUE 0.
 01 WS-ATTACHED            BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-OLD-X               FLOAT-LONG.
 01 WS-OLD-Y               FLOAT-LONG.
 01 WS-OLD-Z               FLOAT-LONG.
 01 WS-MICRO               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = PL-X(WS-PLAYER) + 12
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 10
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     MOVE 0.01 TO EN-VX(WS-ROW)
     MOVE 0.05 TO EN-VY(WS-ROW)
     MOVE -0.02 TO EN-VZ(WS-ROW)
     MOVE EN-X(WS-ROW) TO WS-OLD-X
     MOVE EN-Y(WS-ROW) TO WS-OLD-Y
     MOVE EN-Z(WS-ROW) TO WS-OLD-Z
     CALL "FIREWORK-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.7 Firework rocket: the first tick multiplies vx by 1.15 (11500 millionths)" TO TL-CASE
     MOVE 11500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: the first tick adds 0.04 to vy (90000 millionths)" TO TL-CASE
     MOVE 90000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: the first tick multiplies vz by 1.15 (-23000 millionths)" TO TL-CASE
     MOVE -23000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: it moved by the accelerated velocity (y, millionths)" TO TL-CASE
     MOVE 90000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-Y(WS-ROW) - WS-OLD-Y) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FIREWORK-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.7 Firework rocket: the second tick vy is 0.13 (130000 millionths)" TO TL-CASE
     MOVE 130000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: the second tick vx is 0.013225 (13225 millionths)" TO TL-CASE
     MOVE 13225 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Shot at an angle: no acceleration.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 1 TO PJ-I5(WS-SLOT)
     MOVE 0.01 TO EN-VX(WS-ROW)
     MOVE 0.05 TO EN-VY(WS-ROW)
     CALL "FIREWORK-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.7 Firework rocket: a rocket shot at an angle keeps its velocity (vy 50000 millionths)" TO TL-CASE
     MOVE 50000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§8.7 Firework rocket: a rocket shot at an angle keeps its velocity (vx 10000 millionths)" TO TL-CASE
     MOVE 10000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-ROW
*>   Attached to an entity (the player): no acceleration either.
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-ATTACHED
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-OWNER WS-ROW
     MOVE 0.01 TO EN-VX(WS-ROW)
     MOVE 0.05 TO EN-VY(WS-ROW)
     CALL "FIREWORK-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.7 Firework rocket: a rocket attached to an entity keeps its velocity (vy 50000 millionths)" TO TL-CASE
     MOVE 50000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-8-7B.
 COPY CORETEST.
 COPY MOBSPTEST.
