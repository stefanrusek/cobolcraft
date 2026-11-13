*> The local player's contact with fluids (29a-fluids.md section 8.2, the client half of Entity.updateFluidInteraction): PHYS-FLUID looks
*> at the cells of the box (deflated by 0.001 on every side) that hold water or lava (ST-FLUID of the state tables; a block that is always
*> wet counts as water): a cell whose fluid top (y + 1 under the same fluid, else amount / 9) is not below the feet counts, the height
*> is the highest top above the feet, and the eye is inside a fluid when it is in the cell of the Player's column between the cell's
*> floor and its top. The current (8.3) is the flow vector of each such cell (CELL-FLOW, 1.4), scaled by the running height while that is
*> below 0.4, averaged over the cells and multiplied by 0.014 (water) or 0.0023333 (lava), lifted to 0.0045 when weaker and the Player
*> is nearly at rest (CURRENT-PUSH). The movement through the fluid is in physics.cob (PHYS-TICK).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-FLUID.
*> USING CLIENT-STATE: sets PL-EYES-WATER (the HUD's air row, hearts.cob) with PL-EYE-WATER, PL-IN-WATER, PL-IN-LAVA, PL-EYE-WATER, PL-EYE-LAVA, PL-WATER-H and PL-LAVA-H of the Player's position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ABOVE-KIND          BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-E                   FLOAT-LONG VALUE 0.001.
 01 WS-FALLING             BINARY-LONG.
 01 WS-ACC                 FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SUMS.
    05 WS-SUM OCCURS 2 TIMES.
       10 WS-SX            FLOAT-LONG.
       10 WS-SZ            FLOAT-LONG.
       10 WS-SC            BINARY-LONG.
 01 WS-STRENGTH-WATER      FLOAT-LONG VALUE 0.014.
 01 WS-STRENGTH-LAVA       FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0.0023333333333333335 TO WS-STRENGTH-LAVA
     MOVE 0 TO PL-IN-WATER PL-IN-LAVA PL-EYE-WATER PL-EYE-LAVA PL-WATER-H PL-LAVA-H PL-PUSH-X PL-PUSH-Z
     INITIALIZE WS-SUMS
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X - 0.35 + WS-E)
     COMPUTE WS-X1 = FUNCTION INTEGER(PL-X + 0.35 - WS-E)
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y + WS-E)
     COMPUTE WS-Y1 = FUNCTION INTEGER(PL-Y + 1.75 - WS-E)
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z - 0.35 + WS-E)
     COMPUTE WS-Z1 = FUNCTION INTEGER(PL-Z + 0.35 - WS-E)
     COMPUTE WS-EYE = PL-Y + 1.6
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z)
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
                 MOVE ST-FLUID(WS-STATE + 1) TO WS-KIND
                 IF WS-KIND > 0
                     IF WS-KIND > 2
                         MOVE 1 TO WS-KIND
                     END-IF
                     MOVE ST-LEVEL(WS-STATE + 1) TO WS-LEVEL
                     MOVE 8 TO WS-AMOUNT
                     IF WS-LEVEL > 0 AND WS-LEVEL < 8
                         COMPUTE WS-AMOUNT = 8 - WS-LEVEL
                     END-IF
                     COMPUTE WS-HEIGHT = WS-AMOUNT / 9
                     COMPUTE WS-YA = WS-Y + 1
                     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-YA WS-Z WS-STATE WS-SKY WS-BLOCK
                     MOVE ST-FLUID(WS-STATE + 1) TO WS-ABOVE-KIND
                     IF WS-ABOVE-KIND > 2
                         MOVE 1 TO WS-ABOVE-KIND
                     END-IF
                     IF WS-ABOVE-KIND = WS-KIND
                         MOVE 1 TO WS-HEIGHT
                     END-IF
                     COMPUTE WS-TOP = WS-Y + WS-HEIGHT
                     IF WS-TOP >= PL-Y + WS-E
                         IF WS-KIND = 1
                             MOVE 1 TO PL-IN-WATER
                             COMPUTE PL-WATER-H = FUNCTION MAX(PL-WATER-H, WS-TOP - PL-Y)
                         ELSE
                             MOVE 1 TO PL-IN-LAVA
                             COMPUTE PL-LAVA-H = FUNCTION MAX(PL-LAVA-H, WS-TOP - PL-Y)
                         END-IF
                         MOVE 0 TO WS-FALLING
                         IF WS-LEVEL >= 8
                             MOVE 1 TO WS-FALLING
                         END-IF
                         CALL "CELL-FLOW" USING CLIENT-STATE WS-X WS-Y WS-Z WS-KIND WS-AMOUNT WS-FALLING WS-FX WS-FZ
                         MOVE PL-WATER-H TO WS-ACC
                         IF WS-KIND = 2
                             MOVE PL-LAVA-H TO WS-ACC
                         END-IF
                         IF WS-ACC < 0.4
                             COMPUTE WS-FX = WS-FX * WS-ACC
                             COMPUTE WS-FZ = WS-FZ * WS-ACC
                         END-IF
                         COMPUTE WS-SX(WS-KIND) = WS-SX(WS-KIND) + WS-FX
                         COMPUTE WS-SZ(WS-KIND) = WS-SZ(WS-KIND) + WS-FZ
                         ADD 1 TO WS-SC(WS-KIND)
                         IF WS-X = WS-CX AND WS-Z = WS-CZ AND WS-EYE >= WS-Y AND WS-EYE <= WS-TOP
                             IF WS-KIND = 1
                                 MOVE 1 TO PL-EYE-WATER
                             ELSE
                                 MOVE 1 TO PL-EYE-LAVA
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE PL-EYE-WATER TO PL-EYES-WATER
     CALL "CURRENT-PUSH" USING CLIENT-STATE WS-SX(1) WS-SZ(1) WS-SC(1) WS-STRENGTH-WATER
*>   Lava pushes with 0.007 in a dimension with gameplay/fast_lava (the Nether), else 0.007 / 3 (29a 8.3).
     IF PL-DIM-NAME = "minecraft:the_nether"
         MOVE 0.007 TO WS-STRENGTH-LAVA
     END-IF
     CALL "CURRENT-PUSH" USING CLIENT-STATE WS-SX(2) WS-SZ(2) WS-SC(2) WS-STRENGTH-LAVA
     GOBACK.
 END PROGRAM PHYS-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CURRENT-PUSH.
*> USING CLIENT-STATE, summed flow x and z (FLOAT-LONG), cell count, strength (FLOAT-LONG): applyCurrentTo (29a 8.3) for a Player:
*> nothing for no cells or a summed flow of squared length under 0.00001; else the flow averaged times the strength, lifted to
*> length 0.0045 when shorter and the speed (PL-VX, PL-VZ) is under 0.003 on both axes; added to PL-PUSH-X and PL-PUSH-Z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SX                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SX L-SZ L-COUNT L-STRENGTH.
     IF L-COUNT > 0 AND L-SX * L-SX + L-SZ * L-SZ >= 0.00001
         COMPUTE WS-CX = L-SX / L-COUNT * L-STRENGTH
         COMPUTE WS-CZ = L-SZ / L-COUNT * L-STRENGTH
         COMPUTE WS-LEN = FUNCTION SQRT(WS-CX * WS-CX + WS-CZ * WS-CZ)
         IF FUNCTION ABS(PL-VX) < 0.003 AND FUNCTION ABS(PL-VZ) < 0.003 AND WS-LEN < 0.0045
             COMPUTE WS-CX = WS-CX / WS-LEN * 0.0045
             COMPUTE WS-CZ = WS-CZ / WS-LEN * 0.0045
         END-IF
         COMPUTE PL-PUSH-X = PL-PUSH-X + WS-CX
         COMPUTE PL-PUSH-Z = PL-PUSH-Z + WS-CZ
     END-IF
     GOBACK.
 END PROGRAM CURRENT-PUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CELL-FLOW.
*> USING CLIENT-STATE, x, y, z of a cell holding the fluid, kind (1 water, 2 lava), amount, falling (1 or 0), flow x and z out
*> (FLOAT-LONG): the flow vector of 1.4, horizontal part: each side that is empty or the same fluid adds (step) x (own height less the
*> side's own height), or, for an empty side that does not block, own height less (the height of the same fluid below it less 0.8888889);
*> normalised; a falling cell beside a solid face (a side, or the cell above it, opaque) keeps 1 / sqrt(37) of that (normalised, 6 down,
*> normalised again). A neighbour is solid when its state is opaque.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-AMT                 BINARY-LONG.
 01 WS-OWN                 FLOAT-LONG.
 01 WS-NH                  FLOAT-LONG.
 01 WS-DELTA               FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-STEPX.
    05 WS-SXV              BINARY-LONG OCCURS 4 TIMES.
 01 WS-STEPZ.
    05 WS-SZV              BINARY-LONG OCCURS 4 TIMES.
 01 WS-SUMX                FLOAT-LONG.
 01 WS-SUMZ                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-KIND L-AMOUNT L-FALLING L-FX L-FZ.
*>   The four sides: north (0, -1), south (0, 1), east (1, 0), west (-1, 0).
     MOVE 0 TO WS-SXV(1) WS-SXV(2)
     MOVE 1 TO WS-SXV(3)
     MOVE -1 TO WS-SXV(4)
     MOVE -1 TO WS-SZV(1)
     MOVE 1 TO WS-SZV(2)
     MOVE 0 TO WS-SZV(3) WS-SZV(4)
     COMPUTE WS-OWN = L-AMOUNT / 9
     MOVE 0 TO WS-SUMX WS-SUMZ WS-SOLID L-FX L-FZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-NX = L-X + WS-SXV(WS-I)
         COMPUTE WS-NZ = L-Z + WS-SZV(WS-I)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-NX L-Y WS-NZ WS-STATE WS-SKY WS-BLOCK
         MOVE ST-FLUID(WS-STATE + 1) TO WS-KIND
         IF WS-KIND > 2
             MOVE 1 TO WS-KIND
         END-IF
         IF WS-KIND = 0 AND ST-OPAQUE(WS-STATE + 1) = 1
             MOVE 1 TO WS-SOLID
         END-IF
         IF WS-KIND = 0 OR WS-KIND = L-KIND
             MOVE 0 TO WS-NH WS-DELTA
             IF WS-KIND = L-KIND
                 MOVE ST-LEVEL(WS-STATE + 1) TO WS-LEVEL
                 MOVE 8 TO WS-AMT
                 IF WS-LEVEL > 0 AND WS-LEVEL < 8
                     COMPUTE WS-AMT = 8 - WS-LEVEL
                 END-IF
                 COMPUTE WS-NH = WS-AMT / 9
                 COMPUTE WS-DELTA = WS-OWN - WS-NH
             END-IF
             IF WS-KIND = 0 AND ST-OPAQUE(WS-STATE + 1) = 0
                 COMPUTE WS-NY = L-Y - 1
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-NX WS-NY WS-NZ WS-STATE WS-SKY WS-BLOCK
                 MOVE ST-FLUID(WS-STATE + 1) TO WS-KIND
                 IF WS-KIND > 2
                     MOVE 1 TO WS-KIND
                 END-IF
                 IF WS-KIND = L-KIND
                     MOVE ST-LEVEL(WS-STATE + 1) TO WS-LEVEL
                     MOVE 8 TO WS-AMT
                     IF WS-LEVEL > 0 AND WS-LEVEL < 8
                         COMPUTE WS-AMT = 8 - WS-LEVEL
                     END-IF
                     COMPUTE WS-DELTA = WS-OWN - (WS-AMT / 9 - 0.8888889)
                 END-IF
             END-IF
             COMPUTE WS-SUMX = WS-SUMX + WS-SXV(WS-I) * WS-DELTA
             COMPUTE WS-SUMZ = WS-SUMZ + WS-SZV(WS-I) * WS-DELTA
         END-IF
         IF L-FALLING = 1
             COMPUTE WS-NY = L-Y + 1
             CALL "WORLD-CELL" USING CLIENT-STATE WS-NX WS-NY WS-NZ WS-STATE WS-SKY WS-BLOCK
             IF ST-FLUID(WS-STATE + 1) = 0 AND ST-OPAQUE(WS-STATE + 1) = 1
                 MOVE 1 TO WS-SOLID
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-SUMX * WS-SUMX + WS-SUMZ * WS-SUMZ)
     IF WS-LEN > 0.00001
         COMPUTE L-FX = WS-SUMX / WS-LEN
         COMPUTE L-FZ = WS-SUMZ / WS-LEN
         IF L-FALLING = 1 AND WS-SOLID = 1
             COMPUTE L-FX = L-FX / FUNCTION SQRT(37)
             COMPUTE L-FZ = L-FZ / FUNCTION SQRT(37)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CELL-FLOW.
