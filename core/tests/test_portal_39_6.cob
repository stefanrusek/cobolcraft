*> Implementation test (T1755, T1756; docs/protocol/39-portals.md section 6 and 2.2a; core/src/portal-39c.cob): the teleport transition model.
*> Mth.sin and Mth.cos from the 65536 table (6.3 worked values for 90, 45 and -90 degrees); PositionMoveRotation.calculateAbsolute (6.3: relative
*> position, yaw without wrapping, pitch clamped to -90..90, the velocity rotated about X then Y by the angle differences, each component relative or
*> absolute; worked examples E4 (nether portal, axis change) and E10 (end portal entry)); the collision-free placement of 6.8 (a body wider or
*> taller than 4 stays, free air stays, a solid block at a side or under the body pushes it to the nearest free place, a block above does not
*> move it, a body inside a solid block stays), with the cobolcraft stand-in solids and with the shapes of the standard set; and the inside-block
*> sweep of 2.2a (a player who crosses a portal cell between two ticks sets the portal process, a path beside it does not, a move of more than
*> 16 blocks is a teleport and tests only the end position; needs the generated packs, a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY PORTAL.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==WS-BASE== LEADING ==PMR-== BY ==B-==.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==WS-CHANGE== LEADING ==PMR-== BY ==C-==.
 COPY PORTALPMR REPLACING ==PORTAL-PMR== BY ==WS-RESULT== LEADING ==PMR-== BY ==R-==.
 01 WS-REL                 BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-F1                  PIC -(3)9.999999.
 01 WS-F2                  PIC -(3)9.999999.
 01 WS-F3                  PIC -(3)9.999999.
 01 WS-F4                  PIC -(3)9.999999.
 01 WS-F5                  PIC -(3)9.999999.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SOLID               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FRAME-AXIS          BINARY-LONG VALUE 0.
 01 WS-FRAME-W             BINARY-LONG VALUE 2.
 01 WS-FRAME-H             BINARY-LONG VALUE 3.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

*>   6.3 the tables: the angle is the float of the degree value (1.5707964 for 90).
     MOVE 1.57079637050628662 TO WS-A
     CALL "PORTAL-TRIG" USING WS-A WS-S WS-C
     PERFORM SHOW-TWO
     MOVE "acceptance US12 39§6 The teleport transition model: sin and cos of 90 degrees from the table are 1.0 and the float of sin(pi), not 0"
         TO TL-CASE
     MOVE "1.000000 0.000000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0.78539818525314331 TO WS-A
     CALL "PORTAL-TRIG" USING WS-A WS-S WS-C
     PERFORM SHOW-TWO
     MOVE "acceptance US12 39§6 The teleport transition model: sin and cos of 45 degrees from the table are both 0.7071068" TO TL-CASE
     MOVE "0.707107 0.707107" TO TL-EXPECTED
     PERFORM CHECK
     MOVE -1.57079637050628662 TO WS-A
     CALL "PORTAL-TRIG" USING WS-A WS-S WS-C
     PERFORM SHOW-TWO
     MOVE "acceptance US12 39§6 The teleport transition model: sin and cos of -90 degrees are -1 and exactly 0 (the mask wraps a negative index)"
         TO TL-CASE
     MOVE "-1.000000 0.000000" TO TL-EXPECTED
     PERFORM CHECK

*>   6.3 calculateAbsolute. E4: a nether portal with an axis change, relatives DELTA + ROTATION (504).
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 0.2 TO B-DX
     MOVE 0.1 TO B-DZ
     MOVE 100.3 TO C-X
     MOVE 70.5 TO C-Y
     MOVE -4.1 TO C-Z
     MOVE 90 TO C-YAW
     MOVE 504 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     PERFORM SHOW-RESULT
     MOVE "acceptance US12 39§6 The teleport transition model: E4 the velocity (0.2, 0, 0.1) rotated by -90 degrees is (-0.1, 0, 0.2), "
         & "the position and the yaw 90 are the change's" TO TL-CASE
     MOVE "100.300000 70.500000 -4.100000 yaw 90.000000 pitch 0.000000 v -0.100000 0.000000 0.200000" TO TL-EXPECTED
     PERFORM CHECK

*>   E10: the end portal, relatives DELTA + X_ROT (496), yaw 90 absolute, the pitch kept.
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 135 TO B-YAW
     MOVE 20 TO B-PITCH
     MOVE 0.3 TO B-DX
     MOVE 100.5 TO C-X
     MOVE 49.0 TO C-Y
     MOVE 0.5 TO C-Z
     MOVE 90 TO C-YAW
     MOVE 496 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     PERFORM SHOW-RESULT
     MOVE "acceptance US12 39§6 The teleport transition model: E10 yaw 135 and velocity (0.3, 0, 0) entering the end portal give yaw 90, "
         & "pitch 20 and velocity (0.212132, 0, -0.212132)" TO TL-CASE
     MOVE "100.500000 49.000000 0.500000 yaw 90.000000 pitch 20.000000 v 0.212132 0.000000 -0.212132" TO TL-EXPECTED
     PERFORM CHECK

*>   The pitch is clamped to -90..90, the yaw is not wrapped, relative position adds the base.
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 80 TO B-PITCH
     MOVE 30 TO C-PITCH
     MOVE 16 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     COMPUTE WS-F1 ROUNDED = R-PITCH
     MOVE -80 TO B-PITCH
     MOVE -30 TO C-PITCH
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     COMPUTE WS-F2 ROUNDED = R-PITCH
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§6 The teleport transition model: a relative pitch is clamped to 90 and to -90" TO TL-CASE
     MOVE "90.000000 -90.000000" TO TL-EXPECTED
     PERFORM CHECK
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 350 TO B-YAW
     MOVE 20 TO C-YAW
     MOVE 1 TO B-X
     MOVE 2 TO B-Y
     MOVE 3 TO B-Z
     MOVE 10 TO C-X
     MOVE 20 TO C-Y
     MOVE 30 TO C-Z
     MOVE 15 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     PERFORM SHOW-RESULT
     MOVE "acceptance US12 39§6 The teleport transition model: relative X Y Z and Y_ROT add the base, the yaw 370 is not wrapped" TO TL-CASE
     MOVE "11.000000 22.000000 33.000000 yaw 370.000000 pitch 0.000000 v 0.000000 0.000000 0.000000" TO TL-EXPECTED
     PERFORM CHECK
*>   Without ROTATE_DELTA the base velocity is not rotated; DELTA_X alone adds it to x only; the other components are the change's.
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 45 TO B-YAW
     MOVE 1 TO B-DX
     MOVE 2 TO B-DY
     MOVE 3 TO B-DZ
     MOVE 0.5 TO C-DX
     MOVE 0.25 TO C-DY
     MOVE 0.125 TO C-DZ
     MOVE 32 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     PERFORM SHOW-RESULT
     MOVE "acceptance US12 39§6 The teleport transition model: DELTA_X alone gives 1.5 for x, the change's 0.25 and 0.125 for y and z, unrotated" TO TL-CASE
     MOVE "0.000000 0.000000 0.000000 yaw 0.000000 pitch 0.000000 v 1.500000 0.250000 0.125000" TO TL-EXPECTED
     PERFORM CHECK
*>   DELTA_Y and DELTA_Z with ROTATE_DELTA: the pitch difference turns y and z about X first (E: base pitch 90, result pitch 0).
     INITIALIZE WS-BASE WS-CHANGE WS-RESULT
     MOVE 90 TO B-PITCH
     MOVE 1 TO B-DY
     MOVE 448 TO WS-REL
     CALL "PORTAL-RESOLVE" USING WS-BASE WS-CHANGE WS-REL WS-RESULT
     PERFORM SHOW-RESULT
     MOVE "acceptance US12 39§6 The teleport transition model: ROTATE_DELTA turns the velocity (0, 1, 0) about X by the pitch difference 90 to (0, 0, -1)" TO TL-CASE
     MOVE "0.000000 0.000000 0.000000 yaw 0.000000 pitch 0.000000 v 0.000000 0.000000 -1.000000" TO TL-EXPECTED
     PERFORM CHECK

*>   6.8 collision-free placement: the cobolcraft stand-in world, solids by CB-SOLID.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-SOLID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT OR WS-SOLID > 0
         IF CB-SOLID(WS-I) = 1
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-SOLID
         END-IF
     END-PERFORM
     MOVE 0.6 TO WS-W
     MOVE 1.8 TO WS-H
     PERFORM FREE-CASES

*>   The standard set's collision shapes: the same cases with stone, and a bottom slab that does not push a body standing on it.
     CALL "TEST-STANDARD-TABLES"
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-SOLID
     PERFORM FREE-CASES
     MOVE 210 TO WS-BX MOVE 70 TO WS-BY MOVE 200 TO WS-BZ
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 210.5 TO WS-X MOVE 70.5 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body standing on a bottom slab (feet at 70.5) is already free and stays" TO TL-CASE
     MOVE "210.500000 70.500000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR

*>   2.2a the sweep, in the standard world with the generated packs.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§6 The teleport transition model: no generated packs here, the sweep is skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 10 TO WS-FX MOVE 100 TO WS-FY MOVE 10 TO WS-FZ
     CALL "PT-FRAME" USING DIM-STANDARD-OVERWORLD WS-FX WS-FY WS-FZ WS-FRAME-AXIS WS-FRAME-W WS-FRAME-H
     MOVE "nether_portal" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-PORTAL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-BX = 10 - WS-I
             COMPUTE WS-BY = 100 + WS-J
             MOVE 10 TO WS-BZ
             CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-BX WS-BY WS-BZ WS-PORTAL
         END-PERFORM
     END-PERFORM
*>   A path beside the portal (x 14): nothing.
     MOVE 14.0 TO PL-X(WS-ROW) MOVE 100.0 TO PL-Y(WS-ROW) MOVE 7.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE 12.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE PQ-PL-PROCESS(WS-ROW) TO TL-OBSERVED-N
     MOVE "acceptance US12 39§6 The teleport transition model: a move from z 7.5 to 12.5 beside the portal (x 14) sets no portal process" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   A move of more than 16 blocks is a teleport: only the end position is tested, so crossing the portal does not count.
     MOVE 10.0 TO PL-X(WS-ROW) MOVE -8.0 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE 28.0 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE PQ-PL-PROCESS(WS-ROW) TO TL-OBSERVED-N
     MOVE "acceptance US12 39§6 The teleport transition model: a move of 36 blocks across the portal is a teleport and sets no process" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   Crossing the portal cell between two ticks, starting and ending outside it, sets the process.
     MOVE 7.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE 12.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE PQ-PL-PROCESS(WS-ROW) TO TL-OBSERVED-N
     MOVE "acceptance US12 39§6 The teleport transition model: a move from z 7.5 to 12.5 through the portal at z 10 sets the process although "
         & "neither end is inside it (2.2a, the swept path)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     STOP RUN.

*> The free-position cases of 6.8 with the solid state WS-SOLID, the body WS-W x WS-H, round (200, 70, 200).
 FREE-CASES.
     MOVE 200 TO WS-BX MOVE 70 TO WS-BY MOVE 200 TO WS-BZ
     MOVE 200.5 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body in free air keeps its position" TO TL-CASE
     MOVE "200.500000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
*>   a solid cell east at (201, 70..71, 200): the body at x 200.9 is pushed west to 200.7
     MOVE 201 TO WS-BX MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.9 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body overlapping a wall to the east is moved to the nearest free place, x 200.7" TO TL-CASE
     MOVE "200.700000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   a wall to the west at (199, 70..71, 200): the body at x 200.1 goes east to 200.3
     MOVE 199 TO WS-BX MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.1 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body overlapping a wall to the west is moved east, x 200.3" TO TL-CASE
     MOVE "200.300000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   a wall to the south at (200, 70..71, 201): z 200.9 goes to 200.7
     MOVE 200 TO WS-BX MOVE 201 TO WS-BZ MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.5 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.9 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body overlapping a wall to the south is moved to z 200.7" TO TL-CASE
     MOVE "200.500000 70.000000 200.700000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   a floor at (200, 69, 200): feet at 69.5 are inside it and are lifted to 70.0
     MOVE 200 TO WS-BX MOVE 200 TO WS-BZ MOVE 69 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.5 TO WS-X MOVE 69.5 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body sunk half a block into a floor is lifted to the floor's top, y 70.0" TO TL-CASE
     MOVE "200.500000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 69 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   a block above the head does not move the body
     MOVE 72 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.5 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a block above the body (the ceiling at 72) leaves it where it is" TO TL-CASE
     MOVE "200.500000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 72 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
*>   a body inside a solid block with no free place round it stays; a body wider than 4 stays whatever is round it
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-SOLID
     MOVE 200.5 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-W WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body wholly inside a two-block pillar has no free place and keeps its position" TO TL-CASE
     MOVE "200.500000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 5.0 TO WS-A
     MOVE 200.9 TO WS-X MOVE 70.0 TO WS-Y MOVE 200.5 TO WS-Z
     CALL "PORTAL-FREE-POS" USING WS-DIM WS-X WS-Y WS-Z WS-A WS-H
     PERFORM SHOW-XYZ
     MOVE "acceptance US12 39§6 The teleport transition model: a body wider than 4.0 keeps its position unchanged (6.8 step 1)" TO TL-CASE
     MOVE "200.900000 70.000000 200.500000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 70 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 71 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR.

 SHOW-TWO.
     COMPUTE WS-F1 ROUNDED = WS-S
     COMPUTE WS-F2 ROUNDED = WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) DELIMITED BY SIZE INTO TL-OBSERVED.

 SHOW-XYZ.
     COMPUTE WS-F1 ROUNDED = WS-X
     COMPUTE WS-F2 ROUNDED = WS-Y
     COMPUTE WS-F3 ROUNDED = WS-Z
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3) DELIMITED BY SIZE INTO TL-OBSERVED.

 SHOW-RESULT.
     COMPUTE WS-F1 ROUNDED = R-X
     COMPUTE WS-F2 ROUNDED = R-Y
     COMPUTE WS-F3 ROUNDED = R-Z
     COMPUTE WS-F4 ROUNDED = R-YAW
     COMPUTE WS-F5 ROUNDED = R-PITCH
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3) " yaw " FUNCTION TRIM(WS-F4) " pitch " FUNCTION TRIM(WS-F5)
         " v " DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-F1 ROUNDED = R-DX
     COMPUTE WS-F2 ROUNDED = R-DY
     COMPUTE WS-F3 ROUNDED = R-DZ
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-KEY
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 END PROGRAM TEST-PORTAL-39-6.

 COPY CORETEST.
 COPY PORTALTEST.
