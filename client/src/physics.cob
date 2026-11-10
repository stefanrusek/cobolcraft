*> The local player's controls and physics (client-surface §3; standin-content §3 operator box,
*> §11.4 walking and sprint speeds; plan "client: physics"). PHYS-INPUT runs every frame on the world screen:
*> the captured cursor's delta turns (yaw += 0.15 x dx) and looks (pitch += 0.15 x dy, from -90 up
*> to 90 down) in degrees per pixel; a Space press is kept for the next tick (jump), and two Space
*> presses within 0.3 s toggle flying when the server's abilities allow flying (0x04), telling
*> the server with Player Abilities (0x28). PHYS-TICK runs every client tick once the player is
*> loaded:
*>   - wanted horizontal velocity: forward (W) and back (S) along the facing, left (A) and right
*>     (D) across it (yaw 0 faces +Z, its left is +X), normalised, times 0.2 blocks per tick
*>     walking (standin §11.4), 0.28 sprinting (§11.4; controls.cob CONTROLS-SPRINT) or 0.5
*>     flying; keys count only on the world screen;
*>   - vertical: flying, 0.375 blocks per tick up while Space is held and down while Left Shift
*>     is; otherwise a jump (Space on the ground) sets 0.42, the player moves by the vertical
*>     speed, then the speed becomes (speed - 0.08) x 0.98 (gravity and drag);
*>   - movement along Y, then X, then Z against the replica: each axis moves in steps of at most
*>     0.5 block; a step into a solid cell stops at that cell's face (the move along that axis is
*>     blocked); a blocked vertical move stops the vertical speed; a blocked X or Z move is the
*>     horizontal collision flag of Move Player;
*>   - on the ground: the box 0.001 lower would touch a solid cell.
*> The flying speeds, jump speed, gravity, flying toggle and mouse factor are recorded in standin
*> §11.4 with the walking speed. The box is the operator's
*> collision box: 0.7 wide, 1.75 high, centred on the feet position; it overlaps a cell when the
*> overlap exceeds 1e-7 in every axis (core/src/movement.cob counts touching faces the same way).
*> Solid: every block except void (standin §1.1); a cell of a chunk the client does not have is
*> solid, as for mobs (standin §12.2); outside the dimension's height range nothing is solid.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-INPUT.
*> USING CLIENT-STATE (world screen): look and the Space presses of this frame; a spectator with
*> mayfly flies at once (13 section 1.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAN-FLY             BINARY-LONG.
 01 WS-KJ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     COMPUTE PL-YAW = PL-YAW + IN-DELTA-X * CL-TURN
     COMPUTE PL-PITCH = FUNCTION MIN(90, FUNCTION MAX(-90, PL-PITCH + IN-DELTA-Y * CL-TURN))
     COMPUTE WS-CAN-FLY = PL-ABILITIES / 4
     COMPUTE WS-CAN-FLY = FUNCTION MOD(WS-CAN-FLY, 2)
*>   Spectator (13 section 1.4): with mayfly set the Player flies at once, no double tap.
     IF PL-MODE = 3 AND WS-CAN-FLY = 1 AND PL-FLYING = 0
         MOVE 1 TO PL-FLYING
         CALL "CLP-SEND-ABILITIES" USING CLIENT-STATE WS-CONN
     END-IF
     MOVE KB-CODE(KB-JUMP) TO WS-KJ
     IF IN-KEY-PRESSED(WS-KJ + 1) = 1
         MOVE 1 TO PL-JUMP
         IF WS-CAN-FLY = 1 AND PL-SPACE-MS > 0 AND CL-NOW-MS - PL-SPACE-MS <= 300
             COMPUTE PL-FLYING = 1 - PL-FLYING
             MOVE 0 TO PL-SPACE-MS PL-JUMP PL-VY
             CALL "CLP-SEND-ABILITIES" USING CLIENT-STATE WS-CONN
         ELSE
             MOVE CL-NOW-MS TO PL-SPACE-MS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PHYS-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-TICK.
*> USING CLIENT-STATE: one client tick of the local player's movement.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-KJ                  BINARY-LONG.
 01 WS-KF                  BINARY-LONG.
 01 WS-KB                  BINARY-LONG.
 01 WS-KL                  BINARY-LONG.
 01 WS-KR                  BINARY-LONG.
 01 WS-KS                  BINARY-LONG.
 01 WS-FORWARD             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RISE                BINARY-LONG.
 01 WS-JUMP                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-LENGTH              FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-BELOW               FLOAT-LONG.
 01 WS-WAS-GROUND          BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-FORWARD WS-LEFT WS-RISE
     MOVE PL-JUMP TO WS-JUMP
     MOVE 0 TO PL-JUMP
     IF SM-SCREEN = SCR-WORLD
         MOVE KB-CODE(KB-JUMP) TO WS-KJ
         MOVE KB-CODE(KB-FORWARD) TO WS-KF
         MOVE KB-CODE(KB-BACK) TO WS-KB
         COMPUTE WS-FORWARD = IN-KEY-DOWN(WS-KF + 1) - IN-KEY-DOWN(WS-KB + 1)
         MOVE KB-CODE(KB-LEFT) TO WS-KL
         MOVE KB-CODE(KB-RIGHT) TO WS-KR
         COMPUTE WS-LEFT = IN-KEY-DOWN(WS-KL + 1) - IN-KEY-DOWN(WS-KR + 1)
         MOVE KB-CODE(KB-SNEAK) TO WS-KS
         COMPUTE WS-RISE = IN-KEY-DOWN(WS-KJ + 1) - IN-KEY-DOWN(WS-KS + 1)
         IF IN-KEY-DOWN(WS-KJ + 1) = 1
             MOVE 1 TO WS-JUMP
         END-IF
     ELSE
         MOVE 0 TO WS-JUMP
     END-IF
*>   Horizontal velocity.
     EVALUATE TRUE
         WHEN PL-FLYING = 1
             MOVE 0.5 TO WS-SPEED
         WHEN PL-SPRINTING = 1
             MOVE 0.28 TO WS-SPEED
         WHEN OTHER
             MOVE 0.2 TO WS-SPEED
     END-EVALUATE
     MOVE 0 TO WS-HX WS-HZ
     COMPUTE WS-LENGTH = FUNCTION SQRT(WS-FORWARD ** 2 + WS-LEFT ** 2)
     IF WS-LENGTH > 0
         COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
         COMPUTE WS-HX = (0 - WS-FORWARD * FUNCTION SIN(WS-YAW) + WS-LEFT * FUNCTION COS(WS-YAW))
             * WS-SPEED / WS-LENGTH
         COMPUTE WS-HZ = (WS-FORWARD * FUNCTION COS(WS-YAW) + WS-LEFT * FUNCTION SIN(WS-YAW))
             * WS-SPEED / WS-LENGTH
     END-IF
*>   Vertical velocity and the move along Y.
     EVALUATE TRUE
         WHEN PL-FLYING = 1
             COMPUTE PL-VY = WS-RISE * 0.375
         WHEN WS-JUMP = 1 AND PL-ON-GROUND = 1
             MOVE 0.42 TO PL-VY
     END-EVALUATE
     MOVE 2 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS PL-VY WS-BLOCKED
     IF WS-BLOCKED = 1
         MOVE 0 TO PL-VY
     END-IF
     IF PL-FLYING = 0
         COMPUTE PL-VY = (PL-VY - 0.08) * 0.98
     END-IF
     MOVE 1 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-HX WS-BX
     MOVE 3 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-HZ WS-BLOCKED
     COMPUTE PL-COLLIDED = FUNCTION MAX(WS-BX, WS-BLOCKED)
     COMPUTE WS-BELOW = PL-Y - 0.001
     MOVE PL-ON-GROUND TO WS-WAS-GROUND
     CALL "PHYS-COLLIDES" USING CLIENT-STATE PL-X WS-BELOW PL-Z WS-HIT
     MOVE WS-HIT TO PL-ON-GROUND
*>   Landing (13 section 1.4): a flying Player that comes down onto the ground stops flying (a spectator
*>   keeps flying) and Player Abilities is sent.
     IF PL-FLYING = 1 AND WS-WAS-GROUND = 0 AND PL-ON-GROUND = 1 AND PL-MODE NOT = 3
         MOVE 0 TO PL-FLYING
         CALL "CLP-SEND-ABILITIES" USING CLIENT-STATE WS-CONN
     END-IF
     GOBACK.
 END PROGRAM PHYS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-MOVE.
*> USING CLIENT-STATE, axis (1 x, 2 y, 3 z), distance (FLOAT-LONG), blocked out (1 = stopped at a
*> cell face).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEFT                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-POS.
    05 WS-P                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
*> Box extent below and above the feet position along each axis.
 01 WS-LOW-TABLE.
    05 WS-LOW              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HIGH-TABLE.
    05 WS-HIGH             FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-AXIS                 BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-BLOCKED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-AXIS L-DISTANCE L-BLOCKED.
     MOVE 0.35 TO WS-LOW(1) WS-LOW(3) WS-HIGH(1) WS-HIGH(3)
     MOVE 0 TO WS-LOW(2)
     MOVE 1.75 TO WS-HIGH(2)
     MOVE PL-X TO WS-P(1)
     MOVE PL-Y TO WS-P(2)
     MOVE PL-Z TO WS-P(3)
     MOVE L-DISTANCE TO WS-LEFT
     MOVE 0 TO L-BLOCKED
     PERFORM UNTIL WS-LEFT = 0 OR L-BLOCKED = 1
         COMPUTE WS-STEP = FUNCTION MIN(0.5, FUNCTION MAX(-0.5, WS-LEFT))
         COMPUTE WS-P(L-AXIS) = WS-P(L-AXIS) + WS-STEP
         MOVE WS-P(1) TO WS-PX
         MOVE WS-P(2) TO WS-PY
         MOVE WS-P(3) TO WS-PZ
         CALL "PHYS-COLLIDES" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-HIT
         IF WS-HIT = 0
             COMPUTE WS-LEFT = WS-LEFT - WS-STEP
         ELSE
*>           Stop at the face of the cell the box's leading edge entered.
             MOVE 1 TO L-BLOCKED
             IF WS-STEP > 0
                 COMPUTE WS-P(L-AXIS) = FUNCTION INTEGER(WS-P(L-AXIS) + WS-HIGH(L-AXIS))
                     - WS-HIGH(L-AXIS)
             ELSE
                 COMPUTE WS-P(L-AXIS) = FUNCTION INTEGER(WS-P(L-AXIS) - WS-LOW(L-AXIS)) + 1
                     + WS-LOW(L-AXIS)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-P(1) TO PL-X
     MOVE WS-P(2) TO PL-Y
     MOVE WS-P(3) TO PL-Z
     GOBACK.
 END PROGRAM PHYS-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-COLLIDES.
*> USING CLIENT-STATE, feet x, y, z (FLOAT-LONG), hit out (1 = the box overlaps a solid cell).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-HIT.
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - 0.35 + WS-EPSILON)
     COMPUTE WS-X1 = FUNCTION INTEGER(L-X + 0.35 - WS-EPSILON)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + WS-EPSILON)
     COMPUTE WS-Y1 = FUNCTION INTEGER(L-Y + 1.75 - WS-EPSILON)
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - 0.35 + WS-EPSILON)
     COMPUTE WS-Z1 = FUNCTION INTEGER(L-Z + 0.35 - WS-EPSILON)
     MOVE 0 TO L-HIT
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1 OR L-HIT = 1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1 OR L-HIT = 1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1 OR L-HIT = 1
                 CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
                 MOVE WS-SOLID TO L-HIT
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PHYS-COLLIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-SOLID.
*> USING CLIENT-STATE, block x, y, z, solid out (1 or 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-SOLID.
     MOVE 0 TO L-SOLID
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     EVALUATE TRUE
         WHEN L-Y < PL-MIN-Y OR L-Y >= PL-MIN-Y + PL-HEIGHT
             CONTINUE
         WHEN WS-ROW = 0
             MOVE 1 TO L-SOLID
         WHEN OTHER
             CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
             IF WS-STATE NOT = 0
                 MOVE 1 TO L-SOLID
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PHYS-SOLID.
