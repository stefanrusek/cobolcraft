*> Acceptance test of Spawning (T0344; docs/protocol/41-item-entity-physics.md section 2; FR-037): popResource and its draw order
*> (the three draws precede the gate), popResourceFromFace, the player throw (position, f32 directional motion, delay 40,
*> thrower, stats), the creative drop throttle (increment 20, threshold 1480, 74 immediate drops), the death drop motion, the
*> dispenser and Entity.spawnAtLocation. The random sources are seeded by the test and replayed in parallel.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-T1                  PIC X(64).
 01 WS-T2                  PIC X(64).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 5.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-VAR                 BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 10.
 01 WS-BY                  BINARY-LONG VALUE 64.
 01 WS-BZ                  BINARY-LONG VALUE 10.
 01 WS-LS                  BINARY-DOUBLE.
 01 WS-PS                  BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-D4                  FLOAT-LONG.
 01 WS-D5                  FLOAT-LONG.
 01 WS-D6                  FLOAT-LONG.
 01 WS-D7                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-R4                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STAT                BINARY-LONG.
 01 WS-EDELAY              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   2.1 popResource at (10, 64, 10): x = 10.5 + r(-0.25, 0.25), y = 64.5 + r - 0.125, z = 10.5 + r, from the level source.
     PERFORM SEED-LEVEL
     CALL "GI-POP-RESOURCE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     COMPUTE WS-X = 10.5 - 0.25 + WS-D1 * 0.5
     COMPUTE WS-Y = 64.5 - 0.25 + WS-D2 * 0.5 - 0.125
     COMPUTE WS-Z = 10.5 - 0.25 + WS-D3 * 0.5
     MOVE "acceptance US2 41§2 Spawning popResource places the item at pos + 0.5 + r(-0.25, 0.25) per axis (y also - 0.125) "
         & "with the level draws in the order x, y, z, delay 10, no thrower, the patch handle" TO WS-CASE
     CALL "ITT-V3" USING WS-X WS-Y WS-Z WS-T1
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-T1) " delay 10 thrower 0 var 3 vy 0.20000" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-V3" USING EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-T1
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-B
     CALL "ITT-I" USING IP-I-VAR(WS-ROW) WS-C
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " delay " FUNCTION TRIM(WS-A) " thrower " FUNCTION TRIM(WS-B) " var "
         FUNCTION TRIM(WS-C) " vy " FUNCTION TRIM(WS-D) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   2.1 the three draws are consumed even when the gate fails (block_drops false, or an empty stack).
     MOVE "acceptance US2 41§2 Spawning popResource consumes its three level draws before the gate: with block_drops false or "
         & "an empty stack nothing is spawned and the next draw is the seventh" TO WS-CASE
     PERFORM SEED-LEVEL
     MOVE 1 TO IP-NO-BLOCK-DROPS
     CALL "GI-POP-RESOURCE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ITEM WS-COUNT WS-VAR WS-N
     MOVE 0 TO IP-NO-BLOCK-DROPS
     CALL "GI-POP-RESOURCE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ITEM WS-ZERO WS-VAR WS-ROW
     CALL "IP-LEVEL-DOUBLE" USING WS-D4
     PERFORM 6 TIMES
         CALL "IP-RNG-DOUBLE" USING WS-LS WS-D5
     END-PERFORM
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D5
     CALL "ITT-F" USING WS-D5 WS-A
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) " 0 0" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-F" USING WS-D4 WS-A
     CALL "ITT-I" USING WS-N WS-B
     CALL "ITT-I" USING WS-ROW WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   2.2 popResourceFromFace: face up (1) draws x and z of the position then x and z of the motion; y step 1 gives y = pos.y + 1
*>   and motion y 0.2, no draw.
     MOVE 1 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     COMPUTE WS-X = 10.5 - 0.25 + WS-D1 * 0.5
     MOVE 65 TO WS-Y
     COMPUTE WS-Z = 10.5 - 0.25 + WS-D2 * 0.5
     COMPUTE WS-VX = -0.1 + WS-D3 * 0.2
     MOVE 0.2 TO WS-VY
     COMPUTE WS-VZ = -0.1 + WS-D4 * 0.2
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace on the up face: position draws x and z, y = pos.y + 1.0, then motion "
         & "draws x and z, motion y 0.2, delay 10" TO WS-CASE
     MOVE 10 TO WS-EDELAY
     PERFORM CHECK-ROW

*>   East face (5): x = pos.x + 0.5 + 0.625 without a draw, y and z drawn, motion x 0.1, y = r(0, 0.1), z = r(-0.1, 0.1).
     MOVE 5 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     COMPUTE WS-X = 10.5 + 0.625
     COMPUTE WS-Y = 64.5 - 0.25 + WS-D1 * 0.5 - 0.125
     COMPUTE WS-Z = 10.5 - 0.25 + WS-D2 * 0.5
     MOVE 0.1 TO WS-VX
     COMPUTE WS-VY = WS-D3 * 0.1
     COMPUTE WS-VZ = -0.1 + WS-D4 * 0.2
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace on the east face: x = pos.x + 0.5 + 0.625 without a draw, motion x "
         & "0.1, y = r(0, 0.1)" TO WS-CASE
     PERFORM CHECK-ROW

*>   West (4), down (0) and north (2) faces: the signs of the steps (down: y = pos.y + 0.5 - 0.625 - 0.125, motion y -0.1 + 0.1).
     MOVE 0 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     COMPUTE WS-X = 10.5 - 0.25 + WS-D1 * 0.5
     COMPUTE WS-Y = 64.5 - 0.625 - 0.125
     COMPUTE WS-Z = 10.5 - 0.25 + WS-D2 * 0.5
     COMPUTE WS-VX = -0.1 + WS-D3 * 0.2
     MOVE 0 TO WS-VY
     COMPUTE WS-VZ = -0.1 + WS-D4 * 0.2
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace on the down face: y = pos.y - 0.25, motion y = -0.1 + 0.1 = 0"
         TO WS-CASE
     PERFORM CHECK-ROW
     MOVE 4 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     COMPUTE WS-X = 10.5 - 0.625
     COMPUTE WS-Y = 64.5 - 0.25 + WS-D1 * 0.5 - 0.125
     COMPUTE WS-Z = 10.5 - 0.25 + WS-D2 * 0.5
     MOVE -0.1 TO WS-VX
     COMPUTE WS-VY = WS-D3 * 0.1
     COMPUTE WS-VZ = -0.1 + WS-D4 * 0.2
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace on the west face: x = pos.x - 0.125, motion x -0.1" TO WS-CASE
     PERFORM CHECK-ROW
     MOVE 2 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-ROW
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     COMPUTE WS-X = 10.5 - 0.25 + WS-D1 * 0.5
     COMPUTE WS-Y = 64.5 - 0.25 + WS-D2 * 0.5 - 0.125
     COMPUTE WS-Z = 10.5 - 0.625
     COMPUTE WS-VX = -0.1 + WS-D3 * 0.2
     COMPUTE WS-VY = WS-D4 * 0.1
     MOVE -0.1 TO WS-VZ
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace on the north face: z = pos.z - 0.125, motion z -0.1" TO WS-CASE
     PERFORM CHECK-ROW

*>   The face gate also consumes the draws first (south face: y and x position draws, x and y motion draws: four... the z axis
*>   has a step, so x, y, then motion x and y).
     MOVE "acceptance US2 41§2 Spawning popResourceFromFace consumes its draws before the gate: block_drops false spawns nothing"
         TO WS-CASE
     MOVE 3 TO WS-FACE
     PERFORM SEED-LEVEL
     MOVE 1 TO IP-NO-BLOCK-DROPS
     CALL "GI-POP-FACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-COUNT WS-VAR WS-N
     MOVE 0 TO IP-NO-BLOCK-DROPS
     PERFORM 4 TIMES
         CALL "IP-RNG-DOUBLE" USING WS-LS WS-D5
     END-PERFORM
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D5
     CALL "IP-LEVEL-DOUBLE" USING WS-D4
     CALL "ITT-F" USING WS-D5 WS-A
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) " 0" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-F" USING WS-D4 WS-A
     CALL "ITT-I" USING WS-N WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   2.3 the thrown motion (validation case 5 and others with the table functions).
     MOVE "acceptance US2 41§2 Spawning throw motion at yaw 0, pitch 0 with the draws 0.25, 0.5, 0.5, 0.5 is (0, 0.1, 0.31)"
         TO WS-CASE
     MOVE 0 TO WS-YAW WS-PITCH
     MOVE 0.25 TO WS-R1
     MOVE 0.5 TO WS-R2 WS-R3 WS-R4
     PERFORM THROW-MOTION
     MOVE "0.00000,0.10000,0.31000" TO WS-EXPECTED
     PERFORM CHECK-MOTION
     MOVE "acceptance US2 41§2 Spawning throw motion at yaw 90, pitch 0 with the draws 0, 1, 0.75, 0.25 is (-0.28, 0.15, 0)"
         TO WS-CASE
     MOVE 90 TO WS-YAW
     MOVE 0 TO WS-R1
     MOVE 1 TO WS-R2
     MOVE 0.75 TO WS-R3
     MOVE 0.25 TO WS-R4
     PERFORM THROW-MOTION
     MOVE "-0.28000,0.15000,0.00000" TO WS-EXPECTED
     PERFORM CHECK-MOTION
     MOVE "acceptance US2 41§2 Spawning throw motion looking straight down (pitch 90) is vy = -0.3 + 0.1 with no sideways part"
         TO WS-CASE
     MOVE 0 TO WS-YAW
     MOVE 90 TO WS-PITCH
     MOVE 0.5 TO WS-R1 WS-R3 WS-R4
     MOVE 0 TO WS-R2
     PERFORM THROW-MOTION
     MOVE "0.00000,-0.20000,0.00000" TO WS-EXPECTED
     PERFORM CHECK-MOTION

*>   The player throw: at the player's x, eye y - 0.3 (eye 1.62 above the feet) and z; delay 40; thrower the player; motion from the
*>   player's own source (a, b, then the two draws of vy); stats item_dropped (count passed in) and drop.
     MOVE 4.5 TO PL-X(WS-PLAYER)
     MOVE 54 TO PL-Y(WS-PLAYER)
     MOVE 8.5 TO PL-Z(WS-PLAYER)
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     CALL "IP-RNG-SEED" USING IP-P-RNG(WS-PLAYER) WS-SEED
     MOVE 1 TO IP-P-SEEDED(WS-PLAYER)
     CALL "IP-RNG-SEED" USING WS-PS WS-SEED
     CALL "GI-THROW-STACK-X" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM FIND-LAST-ITEM
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R1
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R2
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R3
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R4
     MOVE 0 TO WS-YAW WS-PITCH
     PERFORM THROW-MOTION
     MOVE 4.5 TO WS-X
     COMPUTE WS-Y = 54 + 1.62 - 0.3
     MOVE 8.5 TO WS-Z
     MOVE 40 TO WS-EDELAY
     MOVE "acceptance US2 41§2 Spawning a player throw is at (x, eye y - 0.3, z) with the directional motion of the player's draws "
         & "and delay 40" TO WS-CASE
     PERFORM CHECK-ROW
     MOVE "acceptance US2 41§2 Spawning a thrown item names the thrower, keeps the count and the patch handle" TO WS-CASE
     MOVE SPACES TO WS-EXPECTED WS-OBSERVED
     CALL "ITT-I" USING PL-ENTITY-ID(WS-PLAYER) WS-A
     STRING "thrower " FUNCTION TRIM(WS-A) " count 5 var 3" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-B
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-C
     CALL "ITT-I" USING IP-I-VAR(WS-ROW) WS-D
     STRING "thrower " FUNCTION TRIM(WS-B) " count " FUNCTION TRIM(WS-C) " var " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

     MOVE "acceptance US2 41§2 Spawning a thrown drop awards item_dropped with the count and the custom stat drop by 1; an empty "
         & "stack spawns nothing and awards nothing" TO WS-CASE
     MOVE EN-COUNT TO WS-N
     CALL "GI-THROW-STACK-X" USING WS-PLAYER WS-ITEM WS-ZERO WS-VAR
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROPPED WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-A
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROP WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-B
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-PICKED WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-C
     CALL "ITT-I" USING EN-COUNT WS-D
     MOVE SPACES TO WS-OBSERVED WS-EXPECTED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     CALL "ITT-I" USING WS-N WS-A
     STRING "5 1 0 " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM CHECK

*>   An item that does not fit (handleExtraItemsCreatedOnUse): thrown from the same place with delay 40, but no thrower and no statistics.
     MOVE "acceptance US2 41§2 Spawning an item that did not fit is dropped like a throw with delay 40, with no thrower and no new "
         & "item_dropped or drop statistic" TO WS-CASE
     CALL "GI-DROP-EXTRA" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM FIND-LAST-ITEM
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROPPED WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-A
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROP WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-B
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-C
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING "dropped " FUNCTION TRIM(WS-A) " drop " FUNCTION TRIM(WS-B) " thrower " FUNCTION TRIM(WS-C) " delay "
         FUNCTION TRIM(WS-D) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "dropped 5 drop 1 thrower 0 delay 40" TO WS-EXPECTED
     PERFORM CHECK

*>   2.3.1 the creative drop throttle: 74 drops in a row are allowed (count 1480), the 75th is lost, each tick lowers the count by 1.
     MOVE "acceptance US2 41§2 Spawning the creative drop throttle allows 74 immediate drops (count 20 each, limit 1480), ignores "
         & "the 75th and allows one more after the count has fallen below 1480" TO WS-CASE
     MOVE 0 TO IP-P-THROTTLE(WS-PLAYER)
     PERFORM COUNT-ITEMS
     MOVE WS-I TO WS-BASE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 75
         CALL "GI-CREATIVE-DROP" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     END-PERFORM
     PERFORM COUNT-ITEMS
     COMPUTE WS-I = WS-I - WS-BASE
     CALL "ITT-I" USING WS-I WS-A
     CALL "ITT-I" USING IP-P-THROTTLE(WS-PLAYER) WS-B
     CALL "TEST-TICKS" USING WS-ONE
     CALL "ITT-I" USING IP-P-THROTTLE(WS-PLAYER) WS-C
     CALL "GI-CREATIVE-DROP" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM COUNT-ITEMS
     COMPUTE WS-I = WS-I - WS-BASE
     CALL "ITT-I" USING WS-I WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "74 1480 1479 75" TO WS-EXPECTED
     PERFORM CHECK

*>   2.4 death drop: motion (-sin(g) * f, 0.2, cos(g) * f) with f = r1 * 0.5 and g = r2 * 2 pi (table functions); the y component
*>   is the f32 value of 0.2.
     MOVE "acceptance US2 41§2 Spawning the death drop motion with the draws 1 and 0.25 is (-0.5, 0.2, 0) and with 0.5 and 0 is "
         & "(0, 0.2, 0.25)" TO WS-CASE
     MOVE 1 TO WS-R1
     MOVE 0.25 TO WS-R2
     CALL "IP-DEATH-MOTION" USING WS-R1 WS-R2 WS-VX WS-VY WS-VZ
     CALL "ITT-V3" USING WS-VX WS-VY WS-VZ WS-T1
     MOVE 0.5 TO WS-R1
     MOVE 0 TO WS-R2
     CALL "IP-DEATH-MOTION" USING WS-R1 WS-R2 WS-VX WS-VY WS-VZ
     CALL "ITT-V3" USING WS-VX WS-VY WS-VZ WS-T2
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " " FUNCTION TRIM(WS-T2) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "-0.50000,0.20000,0.00000 0.00000,0.20000,0.25000" TO WS-EXPECTED
     PERFORM CHECK
     CALL "IP-RNG-SEED" USING IP-P-RNG(WS-PLAYER) WS-SEED
     CALL "IP-RNG-SEED" USING WS-PS WS-SEED
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R1
     CALL "IP-RNG-FLOAT" USING WS-PS WS-R2
     CALL "IP-DEATH-MOTION" USING WS-R1 WS-R2 WS-VX WS-VY WS-VZ
     CALL "GI-DEATH-DROP" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM FIND-LAST-ITEM
     MOVE 4.5 TO WS-X
     COMPUTE WS-Y = 54 + 1.62 - 0.3
     MOVE 8.5 TO WS-Z
     MOVE 40 TO WS-EDELAY
     MOVE "acceptance US2 41§2 Spawning a death drop is placed like a throw with the circle motion of the player's two draws and "
         & "delay 40" TO WS-CASE
     PERFORM CHECK-ROW
     MOVE "acceptance US2 41§2 Spawning a death drop has no thrower and awards no statistic, and keeps the patch handle" TO WS-CASE
     CALL "ITT-I" USING IP-I-THROWER(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-VAR(WS-ROW) WS-B
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROPPED WS-ITEM WS-STAT
     CALL "ITT-I" USING WS-STAT WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0 3 380" TO WS-EXPECTED
     PERFORM CHECK

*>   2.5 dispenser: position block centre + facing * 0.7 (y lowered by 0.15625, or 0.125 for a vertical facing), delay 0, speed =
*>   r * 0.1 + 0.2, spread 0.103365, triangle(c, d) = c + d * (r1 - r2) with the draws x, y, z.
     MOVE 5 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-DISPENSE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-ROW
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D1
     COMPUTE WS-SPEED = WS-D1 * 0.1 + 0.2
     PERFORM DRAW-D1-D3
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D4
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D5
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D6
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D7
     COMPUTE WS-VX = WS-SPEED + 0.103365 * (WS-D1 - WS-D2)
     COMPUTE WS-VY = 0.2 + 0.103365 * (WS-D3 - WS-D4)
     COMPUTE WS-VZ = 0.103365 * (WS-D5 - WS-D6)
     COMPUTE WS-X = 10.5 + 0.7
     COMPUTE WS-Y = 64.5 - 0.15625
     MOVE 10.5 TO WS-Z
     MOVE 0 TO WS-EDELAY
     MOVE "acceptance US2 41§2 Spawning a dispenser spawns one item at the block centre + facing * 0.7 (y - 0.15625), delay 0, "
         & "motion from speed r * 0.1 + 0.2 and the triangle spread" TO WS-CASE
     PERFORM CHECK-ROW
     MOVE 1 TO WS-FACE
     PERFORM SEED-LEVEL
     CALL "GI-DISPENSE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE WS-ITEM WS-ROW
     COMPUTE WS-Y = 64.5 + 0.7 - 0.125
     MOVE 10.5 TO WS-X
     MOVE "acceptance US2 41§2 Spawning a dispenser facing up lowers y by 0.125 only" TO WS-CASE
     CALL "ITT-F" USING WS-Y WS-A
     CALL "ITT-F" USING EN-Y(WS-ROW) WS-B
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-C
     MOVE SPACES TO WS-EXPECTED WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " 1" DELIMITED BY SIZE INTO WS-EXPECTED
     STRING FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   The entity drop spawnAtLocation: position + (0, y offset, 0), the constructor's random motion, delay 10, nothing for an empty
*>   stack.
     MOVE 20.5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE 0.5 TO WS-VY
     CALL "IP-AT-LOCATION" USING WS-DIM WS-X WS-Y WS-Z WS-VY WS-ITEM WS-COUNT WS-VAR WS-ROW
     MOVE "acceptance US2 41§2 Spawning Entity.spawnAtLocation adds the y offset to the position, delay 10, random motion with "
         & "y 0.2, and an empty stack spawns nothing" TO WS-CASE
     CALL "ITT-V3" USING EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-T1
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-B
     CALL "IP-AT-LOCATION" USING WS-DIM WS-X WS-Y WS-Z WS-VY WS-ITEM WS-ZERO WS-VAR WS-N
     CALL "ITT-I" USING WS-N WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "20.50000,70.50000,20.50000 10 0.20000 0" TO WS-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SEED-LEVEL.
     CALL "IP-RNG-SEED" USING IP-LEVEL-RNG WS-SEED
     MOVE 1 TO IP-LEVEL-SEEDED
     CALL "IP-RNG-SEED" USING WS-LS WS-SEED.

 DRAW-D1-D3.
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D1
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D2
     CALL "IP-RNG-DOUBLE" USING WS-LS WS-D3.

*> WS-VX, WS-VY, WS-VZ from the throw formula of WS-YAW, WS-PITCH and the draws WS-R1 to WS-R4.
 THROW-MOTION.
     CALL "IP-THROW-MOTION" USING WS-YAW WS-PITCH WS-R1 WS-R2 WS-R3 WS-R4 WS-VX WS-VY WS-VZ.

 CHECK-MOTION.
     CALL "ITT-V3" USING WS-VX WS-VY WS-VZ WS-OBSERVED
     PERFORM CHECK.

*> The row WS-ROW against WS-X to WS-VZ and the delay WS-EDELAY.
 CHECK-ROW.
     CALL "ITT-V3" USING WS-X WS-Y WS-Z WS-T1
     CALL "ITT-V3" USING WS-VX WS-VY WS-VZ WS-T2
     CALL "ITT-I" USING WS-EDELAY WS-A
     MOVE SPACES TO WS-EXPECTED
     STRING FUNCTION TRIM(WS-T1) " v " FUNCTION TRIM(WS-T2) " d " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "ITT-V3" USING EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-T1
     CALL "ITT-V3" USING EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW) WS-T2
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-T1) " v " FUNCTION TRIM(WS-T2) " d " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK.

 FIND-LAST-ITEM.
     MOVE EN-COUNT TO WS-ROW
     PERFORM UNTIL EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
         SUBTRACT 1 FROM WS-ROW
     END-PERFORM.

*> WS-I = the number of ground items in the tracker.
 COUNT-ITEMS.
     MOVE 0 TO WS-I
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
             ADD 1 TO WS-I
         END-IF
     END-PERFORM.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-2.

 COPY CORETEST.
 COPY ITEMTEST.
