*> Implementation test (coverage lane A; docs/protocol/44 part 8 section 4): the rail shape exits, the rail point on every shape, a rail block with a prefixed key and the
*> shapes of the slope, the furnace cart's push and fuel, the hopper cart on an activator rail, the rider's 0.75 factor, the derailed hit and the TNT cart that hits a wall.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MINECART44.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY CBLOCKS.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SHAPE-TEXT          PIC X(16).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-POWERED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY-SAVED           PIC X(48).
 01 WS-EXPECTED-EXITS      PIC X(60) VALUE "110112011211001211011201110102100112112211112011110011110211".
 01 WS-V1                 BINARY-LONG.
 01 WS-V2                 BINARY-LONG.
 01 WS-V3                 BINARY-LONG.
 01 WS-V4                 BINARY-LONG.
 01 WS-V5                 BINARY-LONG.
 01 WS-V6                 BINARY-LONG.
 01 WS-EXIT-VALUES.
    05 WS-EV               BINARY-LONG OCCURS 6 TIMES.
 01 WS-SIG                 BINARY-LONG.
 01 WS-EXP-SIG             BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-J                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SLOT2               BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-NONE-ROW            BINARY-LONG VALUE 0.
 01 WS-VY0                 FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 30
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The exits of every shape (a digit is the value plus 1: first x y z, second x y z), shape 9 being the default.
     PERFORM VARYING WS-SHAPE FROM 0 BY 1 UNTIL WS-SHAPE > 9
         CALL "MC-EXITS" USING WS-SHAPE WS-V1 WS-V2 WS-V3 WS-V4 WS-V5 WS-V6
         MOVE WS-V1 TO WS-EV(1)
         MOVE WS-V2 TO WS-EV(2)
         MOVE WS-V3 TO WS-EV(3)
         MOVE WS-V4 TO WS-EV(4)
         MOVE WS-V5 TO WS-EV(5)
         MOVE WS-V6 TO WS-EV(6)
         MOVE 0 TO WS-SIG WS-EXP-SIG
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             COMPUTE WS-SIG = WS-SIG * 3 + WS-EV(WS-J) + 1
             COMPUTE WS-I = WS-SHAPE * 6 + WS-J
             MOVE WS-EXPECTED-EXITS(WS-I:1) TO WS-DIGIT
             COMPUTE WS-EXP-SIG = WS-EXP-SIG * 3 + WS-DIGIT
         END-PERFORM
         MOVE WS-SHAPE TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "test cova minecart rail shape " WS-DIGIT " has its two exits" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-EXP-SIG TO WS-E
         MOVE WS-SIG TO WS-O
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   A block whose key carries the namespace is read as that rail kind (detector 4) and a block without the shape property has shape 0.
     COMPUTE WS-CX = WS-X0 + 2
     COMPUTE WS-CZ = WS-Z0 - 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     MOVE CB-KEY(CB-S-BLOCK(WS-STONE + 1) + 1) TO WS-KEY-SAVED
     MOVE "minecraft:detector_rail" TO CB-KEY(CB-S-BLOCK(WS-STONE + 1) + 1)
     CALL "MC-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-KIND WS-SHAPE WS-POWERED
     MOVE WS-KEY-SAVED TO CB-KEY(CB-S-BLOCK(WS-STONE + 1) + 1)
     MOVE "test cova minecart a namespaced detector_rail key is rail kind 4" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-KIND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova minecart a rail block without a shape property has shape 0 and is unpowered" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-SHAPE + WS-POWERED
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The rail point: no rail, a north_south track, a curve, a descending slope.
     COMPUTE WS-X = WS-X0 + 20.5
     COMPUTE WS-Y = WS-Y0 + 0.1
     COMPUTE WS-Z = WS-Z0 + 0.5
     CALL "MC-RAILPOINT" USING WS-DIM WS-X WS-Y WS-Z WS-FOUND WS-PX WS-PY WS-PZ
     MOVE "test cova minecart no rail at the point: not found" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     COMPUTE WS-CX = WS-X0 + 10
     MOVE "north_south" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-X0 + 10.5
     COMPUTE WS-Z = WS-Z0 + 0.3
     CALL "MC-RAILPOINT" USING WS-DIM WS-X WS-Y WS-Z WS-FOUND WS-PX WS-PY WS-PZ
     MOVE "test cova minecart north_south point: z follows the point, x the block centre, y the rail (mm)" TO WS-CASE
     COMPUTE WS-E = (WS-Z0 * 1000 + 300) * 1000000 + (WS-X0 + 10) * 1000 + 500
     COMPUTE WS-O ROUNDED = WS-PZ * 1000 * 1000000 + WS-PX * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova minecart north_south point: height is the rail top 0.0625 (mm)" TO WS-CASE
     COMPUTE WS-E = WS-Y0 * 1000 + 63
     COMPUTE WS-O ROUNDED = WS-PY * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     COMPUTE WS-CX = WS-X0 + 12
     MOVE "south_east" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Z = WS-Z0 + 0.5
     CALL "MC-RAILPOINT" USING WS-DIM WS-X WS-Y WS-Z WS-FOUND WS-PX WS-PY WS-PZ
     MOVE "test cova minecart curve point: the centre of a south_east curve maps to 0.75 of both axes (mm)" TO WS-CASE
     COMPUTE WS-E = (WS-Z0 * 1000 + 750) * 1000000 + (WS-X0 + 12) * 1000 + 750
     COMPUTE WS-O ROUNDED = WS-PZ * 1000 * 1000000 + WS-PX * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     COMPUTE WS-CX = WS-X0 + 14
     MOVE "ascending_west" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-X0 + 14.5
     CALL "MC-RAILPOINT" USING WS-DIM WS-X WS-Y WS-Z WS-FOUND WS-PX WS-PY WS-PZ
     MOVE "test cova minecart ascending_west point: the middle of the slope is half a block above the rail (mm)" TO WS-CASE
     COMPUTE WS-E = WS-Y0 * 1000 + 563
     COMPUTE WS-O ROUNDED = WS-PY * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   MC-MOVE into a wall: the velocity of the blocked axis is zero and the hit is reported.
     COMPUTE WS-CX = WS-X0 + 30
     COMPUTE WS-CZ = WS-Z0 - 12
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Y = WS-Y0
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "CA-CART" USING WS-ONE WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     COMPUTE WS-CX = WS-X0 + 32
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     COMPUTE WS-CX = WS-X0 + 30
     COMPUTE WS-CZ = WS-Z0 - 10
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     MOVE 0.5 TO EN-VX(WS-ROW)
     MOVE 1.5 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-DZ
     CALL "MC-MOVE" USING WS-ROW WS-DX WS-DY WS-DZ WS-HIT
     MOVE "test cova minecart a step into a wall in x reports a hit and zeroes vx" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-HIT + EN-VX(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0.5 TO EN-VZ(WS-ROW)
     MOVE 0 TO WS-DX
     MOVE 1.5 TO WS-DZ
     CALL "MC-MOVE" USING WS-ROW WS-DX WS-DY WS-DZ WS-HIT
     MOVE "test cova minecart a step into a wall in z reports a hit and zeroes vz" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-HIT + EN-VZ(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The furnace cart: max speed 0.2, the push follows the velocity, the other kinds' slowdown factors.
     MOVE 4 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW2 WS-SLOT2
     MOVE 0 TO WS-DX
     CALL "MC-MAXSPEED" USING WS-SLOT2 WS-DX
     MOVE "test cova minecart a furnace cart is capped at 0.2 (mm)" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O ROUNDED = WS-DX * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0.05 TO PJ-R1(WS-SLOT2)
     MOVE 0 TO PJ-R2(WS-SLOT2)
     MOVE 0.1 TO EN-VX(WS-ROW2)
     MOVE 0 TO EN-VZ(WS-ROW2)
     CALL "MC-SLOWDOWN" USING WS-ROW2 WS-SLOT2
     MOVE "test cova minecart a pushed furnace cart: (0.1 x 0.8 + 0.05) x 0.96 = 0.1248 (1e-5)" TO WS-CASE
     MOVE 12480 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova minecart the push is re-aimed along the velocity (0.1 x 0.5 = 0.05, 1e-5)" TO WS-CASE
     MOVE 5000 TO WS-E
     COMPUTE WS-O ROUNDED = PJ-R1(WS-SLOT2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0.05 TO PJ-R1(WS-SLOT2)
     MOVE -0.1 TO EN-VX(WS-ROW2)
     CALL "MC-SLOWDOWN" USING WS-ROW2 WS-SLOT2
     MOVE "test cova minecart a furnace cart against its push: push flips with the velocity, (-0.08 + 0.05) x 0.96 = -0.0288 (1e-5)" TO WS-CASE
     MOVE -2880 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO PJ-R1(WS-SLOT2)
     MOVE 0.1 TO EN-VX(WS-ROW2)
     CALL "MC-SLOWDOWN" USING WS-ROW2 WS-SLOT2
     MOVE "test cova minecart an unfuelled furnace cart slows by 0.98 x 0.96 = 0.09408 (1e-5)" TO WS-CASE
     MOVE 9408 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW2
     MOVE 2 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW2 WS-SLOT2
     MOVE 0.1 TO EN-VX(WS-ROW2)
     CALL "MC-SLOWDOWN" USING WS-ROW2 WS-SLOT2
     MOVE "test cova minecart a chest cart keeps 0.995 (1e-5)" TO WS-CASE
     MOVE 9950 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW2
     MOVE 1 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW2 WS-SLOT2
     MOVE 0.1 TO EN-VX(WS-ROW2)
     MOVE WS-PROW TO EN-RIDER(WS-ROW2)
     CALL "MC-SLOWDOWN" USING WS-ROW2 WS-SLOT2
     MOVE 0 TO EN-RIDER(WS-ROW2)
     MOVE "test cova minecart a cart with a rider keeps 0.997 (1e-5)" TO WS-CASE
     MOVE 9970 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW2) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW2
     CALL "PJ-DROP" USING WS-ROW
*>   The slopes at rest roll downhill by the same amount as ascending_east does (-0.007890625 west).
     COMPUTE WS-CZ = WS-Z0 + 20
     COMPUTE WS-CX = WS-X0 + 40
     MOVE "ascending_west" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Y = WS-Y0 + 0.0625
     COMPUTE WS-Z = WS-CZ + 0.5
     MOVE 1 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart at rest on ascending_west rolls east: vx = 0.007890625 (nano-blocks)" TO WS-CASE
     MOVE 7890625 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW) * 1000000000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 42
     MOVE "ascending_north" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart at rest on ascending_north rolls south: vz = 0.007890625 (nano-blocks)" TO WS-CASE
     MOVE 7890625 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VZ(WS-ROW) * 1000000000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 44
     MOVE "ascending_south" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart at rest on ascending_south rolls north: vz = -0.007890625 (nano-blocks)" TO WS-CASE
     MOVE -7890625 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VZ(WS-ROW) * 1000000000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A north_south track: a cart moving south snaps to the line and its yaw is -90, moving north 90, moving west about 180, and a flipped cart turns the other way.
     COMPUTE WS-CZ = WS-Z0 + 24
     COMPUTE WS-CX = WS-X0 + 50
     MOVE "north_south" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0.2 TO EN-VZ(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart on a north_south rail snaps x to the centre and moves 0.2 south (mm)" TO WS-CASE
     COMPUTE WS-E = (WS-CX * 1000 + 500) * 1000000 + WS-CZ * 1000 + 700
     COMPUTE WS-O ROUNDED = EN-X(WS-ROW) * 1000 * 1000000 + EN-Z(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova minecart moving south the yaw is 270 (-90)" TO WS-CASE
     MOVE 270 TO WS-E
     COMPUTE WS-O ROUNDED = EN-YAW(WS-ROW)
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE -0.2 TO EN-VZ(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart moving north the yaw is 90" TO WS-CASE
     MOVE 90 TO WS-E
     COMPUTE WS-O ROUNDED = EN-YAW(WS-ROW)
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 1 TO PJ-I2(WS-SLOT)
     MOVE 0.2 TO EN-VZ(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a flipped cart moving south turns its yaw by 180 (90, or its reversal)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-YAW(WS-ROW) = 90 OR EN-YAW(WS-ROW) = 270
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 52
     MOVE "east_west" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE -0.2 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart moving west the yaw is 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = EN-YAW(WS-ROW)
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A curve: the cart on a south_east curve is placed on the curve line.
     COMPUTE WS-CX = WS-X0 + 54
     MOVE "south_east" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0.1 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart at the centre of a curve is moved onto the curve line (x 0.75 + move)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) > WS-CX + 0.6 AND EN-X(WS-ROW) < WS-CX + 1.0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   Crossing a block edge on a slope lowers the cart by the exit's height and aims the speed along the step.
     COMPUTE WS-CX = WS-X0 + 56
     MOVE "ascending_east" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.05
     COMPUTE WS-Y = WS-Y0 + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE -0.4 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart leaving an ascending_east block westwards puts the cart in the next block (x below the block)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) < WS-CX
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova minecart the speed is aimed along the step west (vx negative, vz zero)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VX(WS-ROW) < 0 AND EN-VZ(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 58
     MOVE "ascending_west" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.95
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0.4 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart leaving an ascending_west block eastwards puts the cart in the next block (x past the block)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) >= WS-CX + 1
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A cart in the cell above a rail finds the rail below and settles on it.
     COMPUTE WS-CX = WS-X0 + 60
     MOVE "east_west" TO WS-SHAPE-TEXT
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Y = WS-Y0 + 1.2
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0.1 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a cart one cell above a rail settles on the rail (y 0.0625 above the block, mm)" TO WS-CASE
     COMPUTE WS-E = WS-Y0 * 1000 + 63
     COMPUTE WS-O ROUNDED = EN-Y(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A rail cart against a block flags the hit (PJ-I7).
     COMPUTE WS-CX = WS-X0 + 62
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-CX = WS-X0 + 63
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     COMPUTE WS-X = WS-X0 + 62.9
     COMPUTE WS-Y = WS-Y0 + 0.0625
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0.4 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a rail cart that runs into a block sets its hit flag" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I7(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A rider slows the cart's move to 0.75 of its speed: 0.4 gives 0.3.
     COMPUTE WS-CX = WS-X0 + 66
     MOVE "east_west" TO WS-SHAPE-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-CX = WS-X0 + 66 + WS-I
         CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-ONE WS-SHAPE-TEXT WS-ZERO
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 66.1
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "MINECART-USE" USING WS-PLAYER WS-ROW WS-USED
     MOVE 0.4 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a loaded cart moves 0.75 of 0.4 = 0.3 (mm)" TO WS-CASE
     COMPUTE WS-E = (WS-X0 + 66) * 1000 + 400
     COMPUTE WS-O ROUNDED = EN-X(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   Powered rails start a stopped cart away from a solid block: east neighbour only, and on a north_south rail either neighbour.
     MOVE "east_west" TO WS-SHAPE-TEXT
     COMPUTE WS-CX = WS-X0 + 70
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-TWO WS-SHAPE-TEXT WS-ONE
     COMPUTE WS-CX = WS-X0 + 71
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     COMPUTE WS-X = WS-X0 + 70.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a stopped cart with a solid block only to the east starts west at -0.02 (1e-5)" TO WS-CASE
     MOVE -2000 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     MOVE "north_south" TO WS-SHAPE-TEXT
     COMPUTE WS-CX = WS-X0 + 74
     COMPUTE WS-CZ = WS-Z0 + 30
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-TWO WS-SHAPE-TEXT WS-ONE
     COMPUTE WS-CZ = WS-Z0 + 29
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     COMPUTE WS-X = WS-X0 + 74.5
     COMPUTE WS-Z = WS-Z0 + 30.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a stopped cart with a solid block to the north starts south at 0.02 (1e-5)" TO WS-CASE
     MOVE 2000 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VZ(WS-ROW) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 76
     COMPUTE WS-CZ = WS-Z0 + 30
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-TWO WS-SHAPE-TEXT WS-ONE
     COMPUTE WS-CZ = WS-Z0 + 31
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     COMPUTE WS-X = WS-X0 + 76.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a stopped cart with a solid block to the south starts north at -0.02 (1e-5)" TO WS-CASE
     MOVE -2000 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VZ(WS-ROW) * 100000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   The hopper cart on an activator rail: powered it is disabled, unpowered enabled.
     MOVE "east_west" TO WS-SHAPE-TEXT
     MOVE 3 TO WS-KIND
     COMPUTE WS-CX = WS-X0 + 80
     COMPUTE WS-CZ = WS-Z0 + 8
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-THREE WS-SHAPE-TEXT WS-ONE
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Z = WS-CZ + 0.5
     COMPUTE WS-Y = WS-Y0 + 0.0625
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a hopper cart on a powered activator rail is disabled" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE PJ-I6(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-CX = WS-X0 + 82
     CALL "CA-RAIL" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-THREE WS-SHAPE-TEXT WS-ZERO
     COMPUTE WS-X = WS-CX + 0.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 0 TO PJ-I6(WS-SLOT)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a hopper cart on an unpowered activator rail is enabled" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I6(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   The tick of an entity without a projectile slot does nothing; a hurt cart counts its hurt time and damage down.
     MOVE EN-VY(WS-PROW) TO WS-VY0
     CALL "MINECART-STEP" USING WS-PROW
     MOVE "test cova minecart a tick of a row that is no cart leaves it alone (no gravity step)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VY(WS-PROW) = WS-VY0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 1 TO WS-KIND
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 3 TO WS-AMOUNT
     CALL "MINECART-HURT" USING WS-ROW WS-AMOUNT WS-NONE-ROW WS-HANDLED
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a tick counts the hurt time down from 10 to 9 and the damage from 30 to 29" TO WS-CASE
     MOVE 929 TO WS-E
     COMPUTE WS-O = PJ-I4(WS-SLOT) * 100 + PJ-R3(WS-SLOT)
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A furnace cart burns its fuel one tick at a time and loses its push when it is spent.
     MOVE 4 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 2 TO PJ-I3(WS-SLOT)
     MOVE 0.05 TO PJ-R1(WS-SLOT)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a furnace cart's fuel falls by one each tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I3(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart spent fuel clears the push" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = PJ-I3(WS-SLOT) * 10 + PJ-R1(WS-SLOT) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
*>   A derailed cart that meets a wall is flagged; a TNT cart that meets one at speed explodes.
     MOVE 1 TO WS-KIND
     COMPUTE WS-CX = WS-X0 + 6
     COMPUTE WS-CZ = WS-Z0 + 14
     COMPUTE WS-X = WS-CX - 0.5
     COMPUTE WS-Z = WS-CZ + 0.5
     COMPUTE WS-Y = WS-Y0
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-CZ WS-STONE
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 0.3 TO EN-VX(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a derailed cart that runs into a block sets its hit flag" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I7(WS-SLOT) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PJ-DROP" USING WS-ROW
     MOVE 5 TO WS-KIND
     CALL "CA-CART" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 0.3 TO EN-VX(WS-ROW)
     MOVE 0.4 TO EN-VZ(WS-ROW)
     CALL "MINECART-STEP" USING WS-ROW
     MOVE "test cova minecart a TNT cart that hits a wall at speed explodes and is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MINECART44.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
 COPY COVARAIL.
