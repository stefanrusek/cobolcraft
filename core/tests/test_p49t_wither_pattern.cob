*> The wither pattern (docs/protocol/21 section 7.1 and 7.1.1; lane p49t, T39110): WITHER-BUILD finds the pattern like BlockPattern.find (origins pos to pos + 2, forwards and up over DOWN, UP, NORTH, SOUTH, WEST, EAST,
*> the cell (column c, row r) at origin + c x (forwards x up) - r x up), clears all nine cells (level event 2001 each, the two air cells included), and puts the wither at the middle cell of the bottom row + (0.5, 0.55, 0.5)
*> with yaw 90 when the axis of forwards is Z (arms along X) and 0 when it is X (arms along Z). WITHER-CAN-SPAWN is canSpawnMob: the base pattern (row 1 blank), y at least the minimum + 2, not Peaceful.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-WITHER-PATTERN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY DIMENSIONS.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WITHER-T            BINARY-LONG.
 01 WS-SOIL                BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SKULL               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 60.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-AIR                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 14
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 30
     COMPUTE WS-FZ = WS-Z0 - 30
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:soul_soil" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SOIL
     MOVE "minecraft:soul_sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     MOVE "minecraft:wither_skeleton_skull" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SKULL
     MOVE "minecraft:wither" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WITHER-T WS-ENTITY-ROW WS-STATUS
*>   Arms along X (east-west): skulls at y0 + 2, soul soil at y0 + 1, the base at y0 under the middle.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CX = WS-X0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SOIL
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SKULL
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SAND
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     COMPUTE WS-CX = WS-X0 + 1
     COMPUTE WS-CY = WS-Y0 + 2
     CALL "WITHER-BUILD" USING WS-DIM WS-CX WS-CY WS-Z0
     PERFORM FIND-WITHER
     MOVE "acceptance US15 21§7.1 arms along X make one wither" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§7.1.1 arms along X: the axis of forwards is Z, yaw 90" TO WS-CASE
     MOVE 90 TO WS-E
     COMPUTE WS-O ROUNDED = EN-YAW(WS-ROW)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§7.1 the wither stands at the middle base cell + 0.5 (x, thousandths)" TO WS-CASE
     COMPUTE WS-E = WS-X0 * 1000 + 500
     COMPUTE WS-O ROUNDED = EN-X(WS-ROW) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 21§7.1 and at the base block's Y + 0.55 (thousandths)" TO WS-CASE
     COMPUTE WS-E = WS-Y0 * 1000 + 550
     COMPUTE WS-O ROUNDED = EN-Y(WS-ROW) * 1000
     PERFORM CHECK-N
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CX = WS-X0 + WS-I
         PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y0 + 2
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-STATE
             ADD WS-STATE TO WS-SUM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 21§7.1 all nine cells of the pattern are air" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-O
     INSPECT WS-TEXT TALLYING WS-O FOR ALL " 47"
     MOVE "acceptance US15 21§7.1 nine block break level events (2001), one per cell, the air cells too" TO WS-CASE
     MOVE 9 TO WS-E
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A pattern with a missing air cell (a block beside the base): no wither.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CX = WS-X0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SOIL
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-SKULL
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-SAND
     COMPUTE WS-CX = WS-X0 - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-SAND
     COMPUTE WS-CX = WS-X0 + 1
     CALL "WITHER-BUILD" USING WS-DIM WS-CX WS-CY WS-Z0
     PERFORM FIND-WITHER
     MOVE "acceptance US15 21§7.1 a non-air cell beside the base: no wither" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   The base pattern (canSpawnMob): ### over ~#~ with no skulls, the final skull going on the middle top cell.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-CX = WS-X0 + WS-I
         COMPUTE WS-CY = WS-Y0 + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-Z0 WS-AIR
     END-PERFORM
     COMPUTE WS-CX = WS-X0 - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-AIR
     COMPUTE WS-CY = WS-Y0 + 2
     CALL "WITHER-CAN-SPAWN" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-CAN
     MOVE "acceptance US15 21§7.1.1 the base pattern (### over ~#~, top row blank) lets a dispenser place a skull" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CX = WS-X0 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-SAND
     CALL "WITHER-CAN-SPAWN" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-CAN
     MOVE "acceptance US15 21§7.1.1 a solid block in an air cell of the base: no" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-AIR
     MOVE 0 TO BW-DIFFICULTY
     CALL "WITHER-CAN-SPAWN" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-CAN
     MOVE "acceptance US15 21§7.1.1 Peaceful: no" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-CY = DM-MIN-Y(WS-DIM) + 1
     CALL "WITHER-CAN-SPAWN" USING WS-DIM WS-X0 WS-CY WS-Z0 WS-CAN
     MOVE "acceptance US15 21§7.1.1 y below the minimum + 2: no" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 FIND-WITHER.
     MOVE 0 TO WS-COUNT WS-ROW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-WITHER-T
             ADD 1 TO WS-COUNT
             MOVE WS-J TO WS-ROW
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-P49T-WITHER-PATTERN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
