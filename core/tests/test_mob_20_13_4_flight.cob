*> Acceptance test (lane p49r; docs/protocol/20 section 13.4 and 13.4.1): the flight of a vex.
*> The move control adds an acceleration of 0.05 x speedModifier towards the wanted point, the vex moves by its velocity through blocks, then the velocity is multiplied by 0.91 (horizontal) and
*> 0.98 (vertical) in air, 0.8 in water, 0.5 in lava; within 0.5333 of the wanted point it waits and halves its velocity; its yaw is -atan2(vx, vz) (no target) or toward its target; during its first tick
*> gravity applies once (vy = -0.0784). The expected displacements come from an independent Python series: v += a, x += v, v *= factor, from rest (charge 0.05, random move 0.0125).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-13-4-FLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY EVKSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WANT-X              FLOAT-LONG.
 01 WS-WANT-Y              FLOAT-LONG.
 01 WS-WANT-Z              FLOAT-LONG.
 01 WS-MOD                 FLOAT-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-TICKS-TEXT          PIC 99.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:vex" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 12
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 20
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 1 TO PL-MODE(WS-PLAYER)
*>   A box of air around the flight (x from -12 to +16 of the start, 6 high).
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 30
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 4
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-IX = WS-BX + WS-DX - 4
                 COMPUTE WS-IY = WS-BY + WS-DY
                 COMPUTE WS-IZ = WS-BZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-IY WS-IZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   1. The charge (modifier 1.0) along +x from rest: displacements after 1, 2, 3 and 10 ticks.
     MOVE 1.0 TO WS-MOD
     COMPUTE WS-WANT-X = WS-BX + 1000
     COMPUTE WS-WANT-Y = WS-BY + 0.5
     COMPUTE WS-WANT-Z = WS-BZ + 0.5
     MOVE "charge along x" TO WS-NAME
     PERFORM FLY-FROM-REST
     COMPUTE WS-EXPECT = 500
     MOVE 1 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     MOVE 1455 TO WS-EXPECT
     MOVE 2 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     MOVE 2824 TO WS-EXPECT
     MOVE 3 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     MOVE 21257 TO WS-EXPECT
     MOVE 10 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   1b. A wish without a speed modifier (0) acts as 1.0.
     MOVE 0 TO WS-MOD
     COMPUTE WS-WANT-X = WS-BX + 1000
     COMPUTE WS-WANT-Y = WS-BY + 0.5
     MOVE "no modifier" TO WS-NAME
     PERFORM FLY-FROM-REST
     MOVE 500 TO WS-EXPECT
     MOVE 1 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   2. The random move (modifier 0.25 gives 0.0125).
     MOVE 0.25 TO WS-MOD
     MOVE "random move along x" TO WS-NAME
     PERFORM FLY-FROM-REST
     MOVE 125 TO WS-EXPECT
     MOVE 1 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     MOVE 5314 TO WS-EXPECT
     MOVE 10 TO WS-TICKS
     PERFORM FLY-AND-CHECK-X
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   3. Straight up: the vertical damping is 0.98 (2.5 blocks a tick in the steady state).
     MOVE 1.0 TO WS-MOD
     COMPUTE WS-WANT-X = WS-BX + 0.5
     COMPUTE WS-WANT-Y = WS-BY + 1000
     MOVE "charge along y" TO WS-NAME
     PERFORM FLY-FROM-REST
     MOVE 500 TO WS-EXPECT
     MOVE 1 TO WS-TICKS
     PERFORM FLY-AND-CHECK-Y
     MOVE 2960 TO WS-EXPECT
     MOVE 3 TO WS-TICKS
     PERFORM FLY-AND-CHECK-Y
     MOVE 25914 TO WS-EXPECT
     MOVE 10 TO WS-TICKS
     PERFORM FLY-AND-CHECK-Y
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   4. Within the box size (0.5333) of the wanted point the vex waits: no acceleration, the velocity is halved, the wish is cleared.
     PERFORM SPAWN-VEX
     COMPUTE EN-FLY-X(WS-MOB) = WS-X + 0.3
     MOVE WS-Y TO EN-FLY-Y(WS-MOB)
     MOVE WS-Z TO EN-FLY-Z(WS-MOB)
     MOVE 1.0 TO EN-FLY-MOD(WS-MOB)
     MOVE 1 TO EN-FLY-ON(WS-MOB)
     MOVE 0.4 TO EN-VX(WS-MOB)
     MOVE 0.2 TO EN-VZ(WS-MOB)
     MOVE 0 TO EN-VY(WS-MOB)
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex within 0.5333 of its wanted point waits: wish cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLY-ON(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The halving comes first (0.4 to 0.2), the move uses 0.2 and the damping 0.91 leaves 0.182.
     MOVE "acceptance US15 20§13.4.1 Vex waiting: the velocity is halved, then damped by 0.91 (ten thousandths)" TO TL-CASE
     MOVE 1820 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   5. The yaw: no target, flying along +x the yaw is -90 (-atan2(vx, vz)); along +z 0.
     MOVE 1.0 TO WS-MOD
     COMPUTE WS-WANT-X = WS-BX + 1000
     COMPUTE WS-WANT-Y = WS-BY + 0.5
     COMPUTE WS-WANT-Z = WS-BZ + 0.5
     MOVE "yaw along x" TO WS-NAME
     PERFORM FLY-FROM-REST
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex without a target faces its velocity: flying along +x the yaw is -90" TO TL-CASE
     MOVE -90000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With a target the yaw faces the target (a player 10 blocks along +z of the vex) whatever the direction of the flight.
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE EN-X(WS-MOB) TO PL-X(WS-PLAYER)
     MOVE EN-Y(WS-MOB) TO PL-Y(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = EN-Z(WS-MOB) + 10
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex with a target faces it, not its velocity: yaw 0 for a target along +z" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   6. Blocks do not stop it: a wall of three stone blocks across the path, the vex passes (velocity 1.0 along +x for 8 ticks).
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 3
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-IX = WS-BX + 4 + WS-DX
                 COMPUTE WS-IY = WS-BY + WS-DY
                 COMPUTE WS-IZ = WS-BZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-IY WS-IZ WS-STONE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM SPAWN-VEX
     MOVE WS-X TO EN-X(WS-MOB)
     MOVE 1.0 TO EN-VX(WS-MOB)
     MOVE 0 TO EN-VY(WS-MOB) EN-VZ(WS-MOB) EN-FLY-ON(WS-MOB)
     MOVE 5 TO EN-WAKE(WS-MOB)
     PERFORM 8 TIMES
         CALL "VEX-FLY" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.4 Vex passes through a wall of stone blocks (ends deeper than its first cell)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-MOB) > WS-BX + 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   7. The first tick of a new vex: gravity applies once (vy -0.0784, then 0.98 of it on the second tick: -0.076832).
     PERFORM SPAWN-VEX
     MOVE 0 TO EN-FLY-ON(WS-MOB) EN-WAKE(WS-MOB)
     MOVE 0 TO EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex first tick: gravity once, vy = -0.0784 (hundred thousandths)" TO TL-CASE
     MOVE -7840 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-MOB) * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex second tick: no gravity, vy = 0.98 x -0.0784 = -0.076832" TO TL-CASE
     MOVE -7683 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-MOB) * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   8. Water multiplies all three axes by 0.8, lava by 0.5.
     COMPUTE WS-IX = WS-BX + 20
     COMPUTE WS-IZ = WS-BZ
     COMPUTE WS-DY = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-DY WS-IZ WS-WATER
     COMPUTE WS-X0 = WS-BX + 20.5
     COMPUTE WS-Y0 = WS-BY + 0.1
     COMPUTE WS-Z0 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y0 WS-Z0 WS-YAW WS-MOB
     MOVE 5 TO EN-WAKE(WS-MOB)
     MOVE 0 TO EN-FLY-ON(WS-MOB)
     MOVE 0.1 TO EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex in water: every axis x 0.8 (hundred thousandths)" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-MOB) * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-IX WS-DY WS-IZ WS-LAVA
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y0 WS-Z0 WS-YAW WS-MOB
     MOVE 5 TO EN-WAKE(WS-MOB)
     MOVE 0 TO EN-FLY-ON(WS-MOB)
     MOVE 0.1 TO EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     CALL "VEX-FLY" USING WS-MOB
     MOVE "acceptance US15 20§13.4.1 Vex in lava: every axis x 0.5 (hundred thousandths)" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-MOB) * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.

*> A new vex in the air of the box at (WS-BX + 0.5, WS-BY + 0.5, WS-BZ + 0.5), its wish and velocity cleared, no gravity left.
 SPAWN-VEX.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 5 TO EN-WAKE(WS-MOB)
     MOVE 0 TO EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB) EN-TARGET(WS-MOB)
     MOVE 0 TO EN-FLY-ON(WS-MOB)
     .

*> The vex at rest with the wish WS-WANT-X/Y/Z at modifier WS-MOD; WS-X0 the start x, WS-Y0 the start y; WS-I the ticks flown.
 FLY-FROM-REST.
     PERFORM SPAWN-VEX
     MOVE WS-WANT-X TO EN-FLY-X(WS-MOB)
     MOVE WS-WANT-Y TO EN-FLY-Y(WS-MOB)
     MOVE WS-WANT-Z TO EN-FLY-Z(WS-MOB)
     MOVE WS-MOD TO EN-FLY-MOD(WS-MOB)
     MOVE 1 TO EN-FLY-ON(WS-MOB)
     MOVE EN-X(WS-MOB) TO WS-X0
     MOVE EN-Y(WS-MOB) TO WS-Y0
     MOVE 0 TO WS-I
     .

*> Flies on until WS-TICKS ticks have passed since the start and checks the x travelled against WS-EXPECT (ten thousandths of a block).
 FLY-AND-CHECK-X.
     PERFORM UNTIL WS-I >= WS-TICKS
         CALL "VEX-FLY" USING WS-MOB
         ADD 1 TO WS-I
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 20§13.4.1 Vex " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE
         ": the x travelled is the series v += a, x += v, v *= 0.91 (ten thousandths)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-MOB) - WS-X0) * 10000
     PERFORM NOTE-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 FLY-AND-CHECK-Y.
     PERFORM UNTIL WS-I >= WS-TICKS
         CALL "VEX-FLY" USING WS-MOB
         ADD 1 TO WS-I
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 20§13.4.1 Vex " DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE
         ": the y travelled is the series v += a, y += v, v *= 0.98 (ten thousandths)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-Y(WS-MOB) - WS-Y0) * 10000
     PERFORM NOTE-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The tick count goes into the case name (a PIC 99 copy), so each check has its own line.
 NOTE-TICKS.
     MOVE SPACES TO WS-IDS
     MOVE WS-TICKS TO WS-TICKS-TEXT
     STRING FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE " after ticks " DELIMITED BY SIZE WS-TICKS-TEXT DELIMITED BY SIZE INTO WS-IDS
     MOVE WS-IDS TO TL-CASE
     .
 END PROGRAM TEST-MOB-20-13-4-FLIGHT.
 COPY CORETEST.
 COPY MOBSPTEST.
