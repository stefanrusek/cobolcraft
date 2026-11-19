*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.6 with 44 part 7 sections 7 and 7.2): the dolphin's swim-with-player and jump goals. Swim with player: the nearest player
*> within 10 blocks who is swimming gets Dolphin's Grace for 100 ticks at once, the dolphin follows at modifier 4.0 (stopping within 2.5 blocks) and, while the player swims, renews the effect with
*> chance 1 / 6 a tick; a player who is not swimming or is beyond 10 blocks starts nothing; the goal ends when the player stops swimming. Jump goal: the clear-water test (water and no motion-blocking
*> block at the offsets 0, 1, 4, 5, 6 and 7 ahead, air in the two blocks above each), the start (velocity + (dx x 0.6, 0.7, dz x 0.6)) and the pitch (atan2(-vy, horizontal speed) x 57.2957763671875).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-DOLPHIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-DOLPHIN             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-GRACE               BINARY-LONG VALUE 29.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 5.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-JUMPED              BINARY-LONG.
 01 WS-ENDED               BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:dolphin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DOLPHIN WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
*>   Swim with player: the dolphin at (x0 + 2.5), the swimming survival player 5 blocks east.
     COMPUTE WS-X = WS-X0 + 2.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 7.5
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     MOVE 0 TO PL-SWIMMING(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-GRACE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§7.2 a player who is not swimming starts nothing: no Dolphin's Grace" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO PL-SWIMMING(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-GRACE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§7.2 a swimming player within 10 blocks gets Dolphin's Grace (level 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§7.2 for 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 1000 + 0.5
     MOVE "acceptance US15 44-7§7.2 the dolphin follows at modifier 4.0 (move speed 0.125 x 1.2 x 4 = 0.6 after one tick)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Renewed with chance 1 / 6 a tick while the player swims: the effect set to 5 ticks is 100 again after 120 ticks.
     MOVE 5 TO WS-DUR
     CALL "EFFECT-ADD" USING WS-PLAYER WS-GRACE WS-AMP WS-DUR WS-FLAGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE EN-X(WS-ROW) = WS-X
     END-PERFORM
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-GRACE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§7.2 while the player swims the grace is renewed to 100 (1 in 6 a tick)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   Within 2.5 blocks it stops moving: the player 2 blocks from the dolphin gives move speed 0.
     COMPUTE PL-X(WS-PLAYER) = WS-X + 2
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     COMPUTE WS-MILLI = EN-SWIM-SPEED(WS-ROW) * 1000 + 0.5
     MOVE "acceptance US15 44-7§7.2 within 2.5 blocks the dolphin stops (move speed 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The goal ends when the player stops swimming.
     MOVE 0 TO PL-SWIMMING(WS-PLAYER)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§7.2 the goal ends when the player stops swimming (no player kept)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   A swimming player 12 blocks away starts nothing.
     MOVE 1 TO PL-SWIMMING(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X + 12
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-GRACE
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-GRACE WS-LEVEL WS-LEFT
     MOVE "acceptance US15 44-7§7.2 a swimming player 12 blocks away starts nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO PL-SWIMMING(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   The jump goal's water test: a strip of water at sea level - 12 along z (offsets 0 to 7 ahead of a dolphin facing +z), air above it, stone below.
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BZ = WS-Z0 + 24
     COMPUTE WS-BY = WS-SEA - 12
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 7
         COMPUTE WS-CELL = WS-BZ + WS-S
         COMPUTE WS-Y = WS-BY - 1
         MOVE WS-Y TO WS-CELL-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL-Y WS-CELL WS-STONE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CELL WS-WATER
         COMPUTE WS-CELL-Y = WS-BY + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL-Y WS-CELL WS-AIR
         COMPUTE WS-CELL-Y = WS-BY + 2
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL-Y WS-CELL WS-AIR
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.1
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "DOLPHIN-JUMP-CLEAR" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§7 open water and two air blocks above at the offsets 0, 1, 4, 5, 6 and 7 ahead: the jump may start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   An offset that fails each way: stone for the water at 4 (or air for the water at 1 would do the same), a block in the air above at 6.
     COMPUTE WS-CELL = WS-BZ + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CELL WS-STONE
     CALL "DOLPHIN-JUMP-CLEAR" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§7 a block instead of water at offset 4: no jump" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CELL WS-WATER
     COMPUTE WS-CELL = WS-BZ + 6
     COMPUTE WS-CELL-Y = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL-Y WS-CELL WS-STONE
     CALL "DOLPHIN-JUMP-CLEAR" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§7 a block in the second air cell at offset 6: no jump" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL-Y WS-CELL WS-AIR
     COMPUTE WS-CELL = WS-BZ + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CELL WS-STONE
     CALL "DOLPHIN-JUMP-CLEAR" USING WS-ROW WS-OK
     MOVE "acceptance US15 44-7§7 offsets 2 and 3 are not tested (stone there still jumps)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   The start: velocity + (dx x 0.6, 0.7, dz x 0.6) with the facing +z (yaw 0), then the pitch from the velocity: atan2(-0.7, 0.6) = -49.4 degrees.
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "DOLPHIN-JUMP-START" USING WS-ROW
     MOVE "acceptance US15 44-7§7 the jump start adds 0.6 along the facing (vz 0.6)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VZ(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§7 and 0.7 up" TO TL-CASE
     MOVE 700 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VY(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
     CALL "DOLPHIN-JUMP-PITCH" USING WS-ROW
     MOVE EN-PITCH(WS-ROW) TO WS-PITCH
     MOVE "acceptance US15 44-7§7 the nose follows the velocity: pitch -49.4 degrees (tenths)" TO TL-CASE
     MOVE -494 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-PITCH * 10 - 0.5
     PERFORM CHECK-N
*>   The other three facings: yaw 90 faces -x, 180 faces -z, 270 faces +x.
     MOVE 90 TO EN-YAW(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "DOLPHIN-JUMP-START" USING WS-ROW
     MOVE "acceptance US15 44-7§7 facing yaw 90: vx -0.6" TO TL-CASE
     MOVE -600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VX(WS-ROW) * 1000 - 0.5
     PERFORM CHECK-N
     MOVE 180 TO EN-YAW(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "DOLPHIN-JUMP-START" USING WS-ROW
     MOVE "acceptance US15 44-7§7 facing yaw 180: vz -0.6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-VZ(WS-ROW) * 1000 - 0.5
     PERFORM CHECK-N
     MOVE 270 TO EN-YAW(WS-ROW)
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "DOLPHIN-JUMP-START" USING WS-ROW
     MOVE "acceptance US15 44-7§7 facing yaw 270: vx 0.6" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VX(WS-ROW) * 1000 + 0.5
     PERFORM CHECK-N
*>   The pitch: a level velocity eases the pitch 20 % toward 0; straight up the nose is -90, straight down 90.
     MOVE 0 TO EN-VX(WS-ROW) EN-VZ(WS-ROW)
     MOVE 0.1 TO EN-VY(WS-ROW)
     MOVE -20 TO EN-PITCH(WS-ROW)
     CALL "DOLPHIN-JUMP-PITCH" USING WS-ROW
     MOVE "acceptance US15 44-7§7 a level velocity eases the pitch 20 percent toward 0 (-20 to -16)" TO TL-CASE
     MOVE -160 TO TL-EXPECTED-N
     MOVE EN-PITCH(WS-ROW) TO WS-PITCH
     COMPUTE TL-OBSERVED-N = WS-PITCH * 10 - 0.5
     PERFORM CHECK-N
     MOVE 0.7 TO EN-VY(WS-ROW)
     CALL "DOLPHIN-JUMP-PITCH" USING WS-ROW
     MOVE "acceptance US15 44-7§7 straight up the nose is -90" TO TL-CASE
     MOVE -90 TO TL-EXPECTED-N
     MOVE EN-PITCH(WS-ROW) TO WS-PITCH
     COMPUTE TL-OBSERVED-N = WS-PITCH
     PERFORM CHECK-N
     MOVE -0.7 TO EN-VY(WS-ROW)
     CALL "DOLPHIN-JUMP-PITCH" USING WS-ROW
     MOVE "acceptance US15 44-7§7 straight down the nose is 90" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     MOVE EN-PITCH(WS-ROW) TO WS-PITCH
     COMPUTE TL-OBSERVED-N = WS-PITCH
     PERFORM CHECK-N
*>   A whole jump in the strip (clear water ahead again): within 600 ticks the dolphin starts one (EN-PH-SET 1) and the jump ends (EN-PH-SET 0, pitch 0).
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-CELL = WS-BZ + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CELL WS-WATER
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 0.1
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-SWIMMING(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X + 100
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-JUMPED WS-ENDED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600 OR WS-ENDED = 1
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         IF EN-PH-SET(WS-ROW) = 1
             MOVE 1 TO WS-JUMPED
         END-IF
         IF WS-JUMPED = 1 AND EN-PH-SET(WS-ROW) = 0
             MOVE 1 TO WS-ENDED
         END-IF
         MOVE WS-Z TO EN-Z(WS-ROW)
         IF WS-JUMPED = 0
             MOVE 0 TO EN-VX(WS-ROW)
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§7 a dolphin with clear water ahead starts a jump (a 1 in 5 draw a tick) within 600 ticks and it ends again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ENDED TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 44-7§7 the pitch is 0 when the jump has ended" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PITCH(WS-ROW) TO WS-PITCH
     COMPUTE TL-OBSERVED-N = WS-PITCH
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-DOLPHIN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
