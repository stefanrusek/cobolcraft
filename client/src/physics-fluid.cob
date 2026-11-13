*> The local player's contact with fluids (29a-fluids.md section 8.2, the client half of Entity.updateFluidInteraction): PHYS-FLUID looks
*> at the cells of the box (deflated by 0.001 on every side) that hold water or lava (ST-FLUID of the state tables; a block that is always
*> wet counts as water): a cell whose fluid top (y + 1 under the same fluid, else amount / 9) is not below the feet counts, the height
*> is the highest top above the feet, and the eye is inside a fluid when it is in the cell of the Player's column between the cell's
*> floor and its top. The movement through the fluid is in physics.cob (PHYS-TICK).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-FLUID.
*> USING CLIENT-STATE: sets PL-IN-WATER, PL-IN-LAVA, PL-EYE-WATER, PL-EYE-LAVA, PL-WATER-H and PL-LAVA-H of the Player's position.
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
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO PL-IN-WATER PL-IN-LAVA PL-EYE-WATER PL-EYE-LAVA PL-WATER-H PL-LAVA-H
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
                     IF WS-KIND = 3
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
                     IF WS-ABOVE-KIND = 3
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
     GOBACK.
 END PROGRAM PHYS-FLUID.
