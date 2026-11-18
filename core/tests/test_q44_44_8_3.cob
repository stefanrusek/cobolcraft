*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 3, boats (lane 002-lane-p49j-b, T24200 range): the ground friction scan of 3.3
*> (the drag of a boat on land is the average block friction under it: stone 0.6, ice 0.98, blue ice 0.989, a mix), 3.4 V1 (the buoyancy fixed point), and V4 (a damage of
*> exactly 40 does not destroy a boat, one more point does). The rest of section 3 is proven by test_mob_21_8_8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY RULES.
 01 WS-CASE                PIC X(200).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-BLUE                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FKIND
     MOVE "minecraft:ice" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-ICE
     MOVE "minecraft:blue_ice" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BLUE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 8
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PY = WS-FY + 1
     COMPUTE WS-PZ = WS-BZ + 0.5
     MOVE "minecraft:oak_boat" TO WS-KEY

*>   On a floor of stone: ON_LAND (3) and the drag of 0.6.
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     CALL "BOAT-STATUS" USING WS-ROW WS-STATUS
     MOVE "acceptance US15 44-8§3.3 a boat on stone is ON_LAND (3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-STATUS TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-OLD
     MOVE 1 TO EN-VX(WS-ROW)
     MOVE 3 TO WS-OLD
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-STATUS
     MOVE "acceptance US15 44-8§3.4 on stone the drag is the friction 0.6 (thousandths)" TO WS-CASE
     MOVE 600 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N

*>   A floor of ice under the whole boat: 0.98.
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM -2 BY 1 UNTIL WS-J > 2
             COMPUTE WS-FX = WS-BX + WS-I
             COMPUTE WS-FZ = WS-BZ + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-ICE
         END-PERFORM
     END-PERFORM
     MOVE 1 TO EN-VX(WS-ROW)
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-STATUS
     MOVE "acceptance US15 44-8§3.3 on ice the drag is 0.98 (thousandths)" TO WS-CASE
     MOVE 980 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N

*>   Blue ice under the whole boat: 0.989.
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM -2 BY 1 UNTIL WS-J > 2
             COMPUTE WS-FX = WS-BX + WS-I
             COMPUTE WS-FZ = WS-BZ + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-BLUE
         END-PERFORM
     END-PERFORM
     MOVE 1 TO EN-VX(WS-ROW)
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-STATUS
     MOVE "acceptance US15 44-8§3.3 on blue ice the drag is 0.989 (thousandths)" TO WS-CASE
     MOVE 989 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N

*>   The boat (1.375 wide) covers 3 x 3 cells; blocks x = BX and BX + 1 of the three columns are ice, the column BX - 1 is stone:
*>   (6 x 0.98 + 3 x 0.6) / 9 = 0.8533.
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM -2 BY 1 UNTIL WS-J > 2
             COMPUTE WS-FX = WS-BX + WS-I
             COMPUTE WS-FZ = WS-BZ + WS-J
             IF WS-I < 0
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
             ELSE
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-ICE
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO EN-VX(WS-ROW)
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-STATUS
     MOVE "acceptance US15 44-8§3.3 a mix of 6 ice and 3 stone cells averages to 0.8533 (ten-thousandths)" TO WS-CASE
     MOVE 8533 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   A boat whose east and south faces lie exactly on a cell edge (centre x, z = cell + 0.3125) covers 2 x 2 cells: stone in the cells that only touch it does not count.
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM -2 BY 1 UNTIL WS-J > 2
             COMPUTE WS-FX = WS-BX + WS-I
             COMPUTE WS-FZ = WS-BZ + WS-J
             IF WS-I > 0 OR WS-J > 0
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
             ELSE
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-ICE
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-PX = WS-BX + 0.3125
     COMPUTE WS-PZ = WS-BZ + 0.3125
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 1 TO EN-VX(WS-ROW)
     MOVE 3 TO WS-STATUS
     CALL "BOAT-FLOAT" USING WS-ROW WS-OLD WS-STATUS
     MOVE "acceptance US15 44-8§3.3 cells that only touch the boat's edge do not count (0.98, thousandths)" TO WS-CASE
     MOVE 980 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-PX = WS-BX + 0.5
     COMPUTE WS-PZ = WS-BZ + 0.5

*>   V4 a damage of exactly 4 points (40) does not destroy the boat (the test is strict), one more point does.
     MOVE 90 TO WS-YAW
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-ROW
     MOVE 4 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 44-8§3 V4 damage 40 does not destroy the boat" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 44-8§3 V4 damage 50 destroys it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-8-3.
 COPY CORETEST.
 COPY MOBSPTEST.
