*> Helper of the aquatic mob tests (COPY after the test program, after MOBSPTEST; touch the test after changing it).
*>   AQ-TEST-TANK USING player row, dim out, x0 out, y0 out, z0 out: a tank of 10 x 10 x 8 cells far above the terrain beside the player (stone shell, water inside: the water
*>   cells are x0 + 1 to x0 + 8, y0 + 1 to y0 + 6, z0 + 1 to z0 + 8), and a stone block with four air cells above it at (x0 + 12, y0, z0 + 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQ-TEST-TANK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-DIM L-X0 L-Y0 L-Z0.
     MOVE PL-DIM(L-PLAYER) TO L-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE L-X0 = FUNCTION INTEGER(PL-X(L-PLAYER)) + 20
     COMPUTE L-Z0 = FUNCTION INTEGER(PL-Z(L-PLAYER))
     COMPUTE L-Y0 = FUNCTION INTEGER(PL-Y(L-PLAYER)) + 40
     PERFORM VARYING WS-BX FROM L-X0 BY 1 UNTIL WS-BX > L-X0 + 9
         PERFORM VARYING WS-BZ FROM L-Z0 BY 1 UNTIL WS-BZ > L-Z0 + 9
             PERFORM VARYING WS-BY FROM L-Y0 BY 1 UNTIL WS-BY > L-Y0 + 7
                 MOVE WS-WATER TO WS-J
                 IF WS-BX = L-X0 OR WS-BX = L-X0 + 9 OR WS-BZ = L-Z0 OR WS-BZ = L-Z0 + 9
                         OR WS-BY = L-Y0 OR WS-BY = L-Y0 + 7
                     MOVE WS-STONE TO WS-J
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-J
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-BX = L-X0 + 12
     COMPUTE WS-BZ = L-Z0 + 2
     MOVE L-Y0 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STONE
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
         COMPUTE WS-BY = L-Y0 + WS-J
         CALL "WORLD-SET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-AIR
     END-PERFORM
     GOBACK.
 END PROGRAM AQ-TEST-TANK.
