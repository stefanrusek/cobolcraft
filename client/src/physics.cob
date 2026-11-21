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
*>   - movement along Y, then X, then Z against the replica: each axis moves as far as the collision shapes of the cells it
*>     sweeps allow (docs/protocol/51: slabs, stairs, doors, fences and the rest have their own boxes, torches and buttons none);
*>     a move stopped short is blocked; a blocked vertical move stops the vertical speed; a blocked X or Z move is the
*>     horizontal collision flag of Move Player, unless the step-up below carried the player over the obstacle;
*>   - step-up (13 section 1.4): on the ground, a blocked horizontal move is tried again from 0.6 higher and the player drops back
*>     to the floor it reaches, when that gets it further (a slab, a stair, a carpet edge); the rise is no higher than what hangs over
*>     the cells the move enters leaves (a 1/16 lip under a door lintel, a dirt_path before a door);
*>   - on the ground: the box 0.001 lower would touch a collision box;
*>   - an elytra glide (17 section 3.13; physics-glide.cob): Space pressed in the air with an elytra worn starts it (PHYS-GLIDE-START, from PHYS-INPUT, survival-like players without
*>     mayfly only: the double press of 1.4 is theirs), and while PL-GLIDING PHYS-GLIDE replaces the walking step of PHYS-TICK; Set Entity Motion of the local player is PLAYER-MOTION-SET.
*> The flying speeds, jump speed, gravity, flying toggle and mouse factor are recorded in standin
*> §11.4 with the walking speed. The box is the player's
*> collision box (PHYS-STAND-BOX: 0.6 wide and 1.8 high with a standard content set like the core's, the cobolcraft stand-in set's operator 0.7 x 1.75), centred on the feet position; it overlaps a cell when the
*> overlap exceeds 1e-7 in every axis (core/src/movement.cob counts touching faces the same way).
*> A cell's collision shape is the one of its state (CTBSHAPE.cpy; a full cube when no content set is open); a cell of a chunk the
*> client does not have is a full cube, as for mobs (standin §12.2); outside the dimension's height range nothing collides.

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
*>   A key repeat of the window system is not a press (13 section 1.4: a rising edge of Space).
     IF IN-KEY-PRESSED(WS-KJ + 1) = 1 AND IN-KEY-REPEAT(WS-KJ + 1) = 0
         MOVE 1 TO PL-JUMP
         IF WS-CAN-FLY = 1 AND PL-SPACE-MS > 0 AND CL-NOW-MS - PL-SPACE-MS <= 300
             COMPUTE PL-FLYING = 1 - PL-FLYING
             MOVE 0 TO PL-SPACE-MS PL-JUMP PL-VY
             CALL "CLP-SEND-ABILITIES" USING CLIENT-STATE WS-CONN
         ELSE
             MOVE CL-NOW-MS TO PL-SPACE-MS
         END-IF
         IF WS-CAN-FLY = 0
             CALL "PHYS-GLIDE-START" USING CLIENT-STATE
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
 01 WS-SNEAK               BINARY-LONG.
 01 WS-JUMP                BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-DRAG                FLOAT-LONG.
 01 WS-DEPTH               FLOAT-LONG.
 01 WS-RAISED              FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-LENGTH              FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-FRICTION            FLOAT-LONG.
 01 WS-ICE-SCALE           FLOAT-LONG.
 01 WS-ICE-HX              FLOAT-LONG.
 01 WS-ICE-HZ              FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-BELOW               FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-LOOK-Y              FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-REACH               FLOAT-LONG VALUE 0.6.
 01 WS-FALL                BINARY-LONG.
 01 WS-WAS-GROUND          BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-STEPPED             BINARY-LONG.
 01 WS-CLIMB               BINARY-LONG.
 01 WS-NEW-VY              FLOAT-LONG.
 01 WS-MOVED               FLOAT-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-FORWARD WS-LEFT WS-RISE WS-SNEAK
     MOVE PL-JUMP TO WS-JUMP
     MOVE 0 TO PL-JUMP
     CALL "PHYS-FLUID" USING CLIENT-STATE
*>   Gliding (17 section 3.13): the flight step replaces the walking step; it hands the tick back to the walking step when the glide ended.
     IF PL-GLIDING = 1
         CALL "PHYS-GLIDE" USING CLIENT-STATE
         IF PL-GLIDING = 1
             MOVE 0 TO WS-SNEAK
             CALL "PHYS-POSE" USING CLIENT-STATE WS-SNEAK
             CALL "PHYS-FOV" USING CLIENT-STATE
             GOBACK
         END-IF
     END-IF
*>   The swimming flag (53 section 4): kept while sprinting in water, set when sprinting with the eyes under water; never while flying.
     IF PL-SWIMMING = 1
         IF PL-SPRINTING = 0 OR PL-IN-WATER = 0 OR PL-FLYING = 1
             MOVE 0 TO PL-SWIMMING
         END-IF
     ELSE
         IF PL-SPRINTING = 1 AND PL-IN-WATER = 1 AND PL-EYE-WATER = 1 AND PL-FLYING = 0
             MOVE 1 TO PL-SWIMMING
         END-IF
     END-IF
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
         MOVE IN-KEY-DOWN(WS-KS + 1) TO WS-SNEAK
         IF IN-KEY-DOWN(WS-KJ + 1) = 1
             MOVE 1 TO WS-JUMP
         END-IF
     ELSE
         MOVE 0 TO WS-JUMP
     END-IF
*>   Horizontal velocity.
*>   In a fluid (not flying) the input accelerates by 0.02 a tick (13 section 1.3); the speed is kept in PL-VX and PL-VZ.
     MOVE 0 TO WS-FLUID
     IF PL-FLYING = 0
         IF PL-IN-WATER = 1
             MOVE 1 TO WS-FLUID
         END-IF
         IF PL-IN-LAVA = 1
             MOVE 2 TO WS-FLUID
         END-IF
     END-IF
     IF WS-FLUID = 0
         MOVE 0 TO PL-VX PL-VZ
     END-IF
     EVALUATE TRUE
         WHEN WS-FLUID > 0
             MOVE 0.02 TO WS-SPEED
         WHEN PL-FLYING = 1
             MOVE 0.5 TO WS-SPEED
         WHEN PL-SPRINTING = 1
             MOVE 0.28 TO WS-SPEED
         WHEN OTHER
             MOVE 0.2 TO WS-SPEED
     END-EVALUATE
*>   Moving slowly (53 section 6.1: the crouching flag of the keys of the tick before) takes 0.3 of the speed.
     IF PL-SNEAK-FLAG = 1
         COMPUTE WS-SPEED = WS-SPEED * 0.3
     END-IF
     MOVE 0 TO WS-HX WS-HZ
     COMPUTE WS-LENGTH = FUNCTION SQRT(WS-FORWARD ** 2 + WS-LEFT ** 2)
     IF WS-LENGTH > 0
         COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
         COMPUTE WS-HX = (0 - WS-FORWARD * FUNCTION SIN(WS-YAW) + WS-LEFT * FUNCTION COS(WS-YAW))
             * WS-SPEED / WS-LENGTH
         COMPUTE WS-HZ = (WS-FORWARD * FUNCTION COS(WS-YAW) + WS-LEFT * FUNCTION SIN(WS-YAW))
             * WS-SPEED / WS-LENGTH
     END-IF
*>   In a fluid: Space adds 0.04 of vertical speed in water deeper than 0.4 or off the ground (a jump from the ground in
*>   shallower water), in lava the same; sneaking in water takes 0.04 off (13 section 1.3).
     IF WS-FLUID > 0
         COMPUTE PL-VX = PL-VX + PL-PUSH-X + WS-HX
         COMPUTE PL-VZ = PL-VZ + PL-PUSH-Z + WS-HZ
         MOVE PL-WATER-H TO WS-DEPTH
         IF WS-FLUID = 2
             MOVE PL-LAVA-H TO WS-DEPTH
         END-IF
         IF WS-JUMP = 1
             IF WS-DEPTH > 0.4 OR PL-ON-GROUND = 0
                 COMPUTE PL-VY = PL-VY + 0.04
             ELSE
                 MOVE 0.42 TO PL-VY
             END-IF
         END-IF
         IF WS-SNEAK = 1 AND WS-FLUID = 1
             COMPUTE PL-VY = PL-VY - 0.04
         END-IF
         MOVE PL-VX TO WS-HX
         MOVE PL-VZ TO WS-HZ
     END-IF
*>   Vertical velocity and the move along Y.
     EVALUATE TRUE
         WHEN PL-FLYING = 1
             COMPUTE PL-VY = WS-RISE * 0.375
         WHEN WS-FLUID = 0 AND WS-JUMP = 1 AND PL-ON-GROUND = 1
             MOVE 0.42 TO PL-VY
*>           A sprint jump adds 0.2 forward on its tick (13 section 1.3 jumpFromGround).
             IF PL-SPRINTING = 1
                 COMPUTE WS-HX = WS-HX - FUNCTION SIN(WS-YAW) * 0.2
                 COMPUTE WS-HZ = WS-HZ + FUNCTION COS(WS-YAW) * 0.2
             END-IF
     END-EVALUATE
*>   On a climbable block (ladder, vines, scaffolding: 13 section 1.3) the speed is clamped: 0.15 sideways, no faster than 0.15 down
*>   and not down at all while sneaking.
     MOVE 0 TO WS-CLIMB
     IF PL-FLYING = 0 AND WS-FLUID = 0
         CALL "PHYS-CLIMBING" USING CLIENT-STATE WS-CLIMB
     END-IF
     IF WS-CLIMB = 1
         COMPUTE WS-HX = FUNCTION MIN(0.15, FUNCTION MAX(-0.15, WS-HX))
         COMPUTE WS-HZ = FUNCTION MIN(0.15, FUNCTION MAX(-0.15, WS-HZ))
         COMPUTE PL-VY = FUNCTION MAX(-0.15, PL-VY)
         IF WS-SNEAK = 1
             COMPUTE PL-VY = FUNCTION MAX(0, PL-VY)
         END-IF
     END-IF
*>   Swimming steers the vertical speed toward the look direction (53 section 9.1): k 0.085 looking down past -0.2, else 0.06; skipped looking
*>   up without Space when the point 0.9 above the feet is out of the water.
     IF PL-SWIMMING = 1
         COMPUTE WS-LOOK-Y = 0 - FUNCTION SIN(PL-PITCH * FUNCTION PI / 180)
         MOVE 0.06 TO WS-K
         IF WS-LOOK-Y < -0.2
             MOVE 0.085 TO WS-K
         END-IF
         IF NOT (WS-LOOK-Y > 0 AND WS-JUMP = 0 AND PL-WATER-H < 0.9)
             COMPUTE PL-VY = PL-VY + (WS-LOOK-Y - PL-VY) * WS-K
         END-IF
     END-IF
     MOVE PL-VY TO WS-DY
     MOVE PL-Y TO WS-SY
     MOVE 2 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS PL-VY WS-BLOCKED
*>   A downward move stopped by a floor: the speed becomes the bounce of the block (slime, a bed: physics-bounce.cob) or 0.
     IF WS-BLOCKED = 1
         MOVE 0 TO WS-NEW-VY
         IF WS-DY < 0 AND PL-FLYING = 0
             COMPUTE WS-MOVED = PL-Y - WS-SY
             CALL "PHYS-BOUNCE" USING CLIENT-STATE WS-DY WS-MOVED WS-SNEAK WS-NEW-VY
         END-IF
         MOVE WS-NEW-VY TO PL-VY
     END-IF
     IF PL-FLYING = 0 AND WS-FLUID = 0
         COMPUTE PL-VY = (PL-VY - 0.08) * 0.98
     END-IF
*>   Slippery ground (18 section 3.2, 13 section 1.3): over a block of friction F above 0.6 the walk only accelerates by speed x 0.21600002 / F^3
*>   (0.454 of the direct step) and the velocity is kept with a drag of F x 0.91 a tick (0.91 in the air, 0.546 on ordinary ground, where only
*>   what was carried over from ice remains); on ordinary ground nothing is carried and the step is direct as before.
     IF PL-FLYING = 1 OR WS-FLUID > 0
         MOVE 0 TO PL-SLIP-X PL-SLIP-Z
     ELSE
         CALL "PHYS-FRICTION" USING CLIENT-STATE WS-FRICTION
         MOVE 0 TO WS-ICE-HX WS-ICE-HZ
         IF PL-ON-GROUND = 1 AND WS-FRICTION > 0.6
             COMPUTE WS-ICE-SCALE = 0.454 * 0.21600002 / (WS-FRICTION ** 3)
             COMPUTE WS-ICE-HX = WS-HX * WS-ICE-SCALE
             COMPUTE WS-ICE-HZ = WS-HZ * WS-ICE-SCALE
             MOVE 0 TO WS-HX WS-HZ
         END-IF
         COMPUTE WS-HX = WS-HX + PL-SLIP-X + WS-ICE-HX
         COMPUTE WS-HZ = WS-HZ + PL-SLIP-Z + WS-ICE-HZ
         COMPUTE PL-SLIP-X = (PL-SLIP-X + WS-ICE-HX) * WS-FRICTION * 0.91
         COMPUTE PL-SLIP-Z = (PL-SLIP-Z + WS-ICE-HZ) * WS-FRICTION * 0.91
         IF FUNCTION ABS(PL-SLIP-X) < 0.003
             MOVE 0 TO PL-SLIP-X
         END-IF
         IF FUNCTION ABS(PL-SLIP-Z) < 0.003
             MOVE 0 TO PL-SLIP-Z
         END-IF
     END-IF
*>   The push of an Explode packet's knockback adds to the horizontal move and decays by 0.546 a tick on the ground, 0.91 in the air.
     COMPUTE WS-HX = WS-HX + PL-KB-X
     COMPUTE WS-HZ = WS-HZ + PL-KB-Z
     IF PL-ON-GROUND = 1
         COMPUTE PL-KB-X = PL-KB-X * 0.546
         COMPUTE PL-KB-Z = PL-KB-Z * 0.546
     ELSE
         COMPUTE PL-KB-X = PL-KB-X * 0.91
         COMPUTE PL-KB-Z = PL-KB-Z * 0.91
     END-IF
     IF FUNCTION ABS(PL-KB-X) < 0.003
         MOVE 0 TO PL-KB-X
     END-IF
     IF FUNCTION ABS(PL-KB-Z) < 0.003
         MOVE 0 TO PL-KB-Z
     END-IF
*>   Sneaking at an edge (53 section 5): not flying, not rising, above the ground (on it, or ground within 0.6 below).
     IF WS-SNEAK = 1 AND PL-FLYING = 0 AND WS-DY <= 0
         MOVE PL-ON-GROUND TO WS-ABOVE
         IF WS-ABOVE = 0
             CALL "PHYS-CAN-FALL" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-REACH WS-FALL
             COMPUTE WS-ABOVE = 1 - WS-FALL
         END-IF
         IF WS-ABOVE = 1
             CALL "PHYS-BACKOFF" USING CLIENT-STATE WS-HX WS-HZ
         END-IF
     END-IF
     MOVE PL-X TO WS-SX
     MOVE PL-Y TO WS-SY
     MOVE PL-Z TO WS-SZ
     MOVE 1 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-HX WS-BX
     MOVE 3 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-HZ WS-BLOCKED
     COMPUTE PL-COLLIDED = FUNCTION MAX(WS-BX, WS-BLOCKED)
     MOVE WS-HX TO PL-MOVE-X
     MOVE WS-HZ TO PL-MOVE-Z
*>   The step-up: a blocked move on the ground goes over a step of up to 0.6 (13 section 1.4).
     IF PL-COLLIDED = 1 AND PL-ON-GROUND = 1 AND PL-FLYING = 0 AND WS-FLUID = 0
         CALL "PHYS-STEP-UP" USING CLIENT-STATE WS-SX WS-SY WS-SZ WS-HX WS-HZ WS-STEPPED
         IF WS-STEPPED = 1
             MOVE 0 TO PL-COLLIDED WS-BX WS-BLOCKED
         END-IF
     END-IF
*>   Climbing: blocked sideways against the ladder, or Space held, the vertical speed becomes 0.2 before this tick's gravity (13 section 1.3).
     IF WS-CLIMB = 1 AND (PL-COLLIDED = 1 OR WS-JUMP = 1)
         COMPUTE PL-VY = (0.2 - 0.08) * 0.98
     END-IF
*>   The fluid's drag (18 section 3.2): water 0.8 on every axis (0.9 horizontally while sprinting) then, falling, 0.005 off the
*>   vertical speed; lava 0.5 (0.5, 0.8, 0.5 in lava not deeper than 0.4, then the falling adjustment) and 0.02 off the vertical
*>   speed. A blocked horizontal axis stops; a horizontal collision with the box 0.6 higher free sets the vertical speed to 0.3.
     IF WS-FLUID > 0
         IF WS-BX = 1
             MOVE 0 TO PL-VX
         END-IF
         IF WS-BLOCKED = 1
             MOVE 0 TO PL-VZ
         END-IF
         EVALUATE TRUE
             WHEN WS-FLUID = 1
                 MOVE 0.8 TO WS-DRAG
                 IF PL-SPRINTING = 1
                     MOVE 0.9 TO WS-DRAG
                 END-IF
                 COMPUTE PL-VX = PL-VX * WS-DRAG
                 COMPUTE PL-VZ = PL-VZ * WS-DRAG
                 COMPUTE PL-VY = PL-VY * 0.8
                 IF PL-VY <= 0 AND PL-SPRINTING = 0
                     COMPUTE PL-VY = PL-VY - 0.005
                 END-IF
             WHEN PL-LAVA-H > 0.4
                 COMPUTE PL-VX = PL-VX * 0.5
                 COMPUTE PL-VZ = PL-VZ * 0.5
                 COMPUTE PL-VY = PL-VY * 0.5 - 0.02
             WHEN OTHER
                 COMPUTE PL-VX = PL-VX * 0.5
                 COMPUTE PL-VZ = PL-VZ * 0.5
                 COMPUTE PL-VY = PL-VY * 0.8
                 IF PL-VY <= 0
                     COMPUTE PL-VY = PL-VY - 0.005
                 END-IF
                 COMPUTE PL-VY = PL-VY - 0.02
         END-EVALUATE
         IF PL-COLLIDED = 1
             COMPUTE WS-RAISED = PL-Y + 0.6
             COMPUTE WS-RX = PL-X + PL-VX
             COMPUTE WS-RZ = PL-Z + PL-VZ
             CALL "PHYS-COLLIDES" USING CLIENT-STATE WS-RX WS-RAISED WS-RZ WS-HIT
             IF WS-HIT = 0
                 MOVE 0.3 TO PL-VY
             END-IF
         END-IF
     END-IF
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
     CALL "PHYS-POSE" USING CLIENT-STATE WS-SNEAK
     CALL "PHYS-FOV" USING CLIENT-STATE
     GOBACK.
 END PROGRAM PHYS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-FOV.
*> USING CLIENT-STATE: the field of view modifier of a client tick (docs/protocol/53 section 8): the speed ratio is 1.3 while sprinting, the factor
*> (ratio + 1) / 2 (1.15), times 1.1 while flying, mixed with 1 by the fovEffectScale (CL-FOV-EFFECT), then half the gap a tick,
*> clamped to 0.1 .. 1.5. The first tick takes the target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 1 TO WS-RATIO
     IF PL-SPRINTING = 1
         MOVE 1.3 TO WS-RATIO
     END-IF
     COMPUTE WS-F = (WS-RATIO + 1) / 2
     IF PL-FLYING = 1
         COMPUTE WS-F = WS-F * 1.1
     END-IF
     COMPUTE WS-F = 1 + CL-FOV-EFFECT * (WS-F - 1)
     IF PL-FOV-MOD = 0
         MOVE WS-F TO PL-FOV-MOD
     ELSE
         COMPUTE PL-FOV-MOD = PL-FOV-MOD + (WS-F - PL-FOV-MOD) * 0.5
     END-IF
     COMPUTE PL-FOV-MOD = FUNCTION MIN(1.5, FUNCTION MAX(0.1, PL-FOV-MOD))
     GOBACK.
 END PROGRAM PHYS-FOV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-MOVE.
*> USING CLIENT-STATE, axis (1 x, 2 y, 3 z), distance (FLOAT-LONG), blocked out (1 = stopped short of the distance by a collision
*> box). The player moves along the axis as far as the collision shapes of the cells its box sweeps allow (BSH-CLIP of each).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIST                FLOAT-LONG.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-SBOX.
    05 WS-SB               FLOAT-LONG OCCURS 6 TIMES.
 01 WS-OFFS.
    05 WS-OFF              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-LO-CELL             BINARY-LONG OCCURS 3 TIMES.
 01 WS-HI-CELL             BINARY-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-AXIS                 BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-BLOCKED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-AXIS L-DISTANCE L-BLOCKED.
     MOVE 0 TO L-BLOCKED
     MOVE L-DISTANCE TO WS-DIST
     CALL "PHYS-BOX" USING CLIENT-STATE WS-HALF WS-HEIGHT
     COMPUTE WS-B(1) = PL-X - WS-HALF
     MOVE PL-Y TO WS-B(2)
     COMPUTE WS-B(3) = PL-Z - WS-HALF
     COMPUTE WS-B(4) = PL-X + WS-HALF
     COMPUTE WS-B(5) = PL-Y + WS-HEIGHT
     COMPUTE WS-B(6) = PL-Z + WS-HALF
*>   The cells the box covers, widened along the axis by the move (a superset: a cell it only touches clips nothing).
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         MOVE WS-B(WS-A) TO WS-LOW
         MOVE WS-B(WS-A + 3) TO WS-HIGH
         IF WS-A = L-AXIS
             COMPUTE WS-LOW = FUNCTION MIN(WS-LOW, WS-LOW + L-DISTANCE)
             COMPUTE WS-HIGH = FUNCTION MAX(WS-HIGH, WS-HIGH + L-DISTANCE)
         END-IF
         COMPUTE WS-LO-CELL(WS-A) = FUNCTION INTEGER(WS-LOW)
         COMPUTE WS-HI-CELL(WS-A) = FUNCTION INTEGER(WS-HIGH)
     END-PERFORM
     PERFORM VARYING WS-Y FROM WS-LO-CELL(2) BY 1 UNTIL WS-Y > WS-HI-CELL(2)
         PERFORM VARYING WS-Z FROM WS-LO-CELL(3) BY 1 UNTIL WS-Z > WS-HI-CELL(3)
             PERFORM VARYING WS-X FROM WS-LO-CELL(1) BY 1 UNTIL WS-X > WS-HI-CELL(1)
                 CALL "PHYS-CELL-SHAPE" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SHAPE
                 IF WS-SHAPE NOT = 0
                     CALL "PHYS-CELL-OFFSET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-OFFS
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         COMPUTE WS-SB(WS-A) = WS-B(WS-A) - WS-OFF(WS-A)
                         COMPUTE WS-SB(WS-A + 3) = WS-B(WS-A + 3) - WS-OFF(WS-A)
                     END-PERFORM
                     CALL "BSH-CLIP" USING WS-SHAPE WS-X WS-Y WS-Z WS-SBOX L-AXIS WS-DIST
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF FUNCTION ABS(WS-DIST - L-DISTANCE) > 0.000000001
         MOVE 1 TO L-BLOCKED
     END-IF
     EVALUATE L-AXIS
         WHEN 1
             COMPUTE PL-X = PL-X + WS-DIST
         WHEN 2
             COMPUTE PL-Y = PL-Y + WS-DIST
         WHEN OTHER
             COMPUTE PL-Z = PL-Z + WS-DIST
     END-EVALUATE
     GOBACK.
 END PROGRAM PHYS-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-CLIMBING.
*> USING CLIENT-STATE, climbing out (1 when the cell of the feet holds a climbable state: CTBSHAPE.cpy BSH-CLIMB).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CLIMBING             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CLIMBING.
     MOVE 0 TO L-CLIMBING
     COMPUTE WS-X = FUNCTION INTEGER(PL-X)
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     IF BSH-READY = 1 AND WS-STATE > 0 AND WS-STATE < BSH-MAX-STATES
         MOVE BSH-CLIMB(WS-STATE + 1) TO L-CLIMBING
     END-IF
     GOBACK.
 END PROGRAM PHYS-CLIMBING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-FRICTION.
*> USING CLIENT-STATE, friction out (FLOAT-LONG): 1.0 in the air; on the ground the friction of the block 0.500001 below the feet (BSH-SLIP of its
*> state in thousandths, ice 0.98, blue ice 0.989, slime 0.8), 0.6 for any other block (18 section 3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FRICTION             FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FRICTION.
     MOVE 1 TO L-FRICTION
     IF PL-ON-GROUND = 1
         MOVE 0.6 TO L-FRICTION
         COMPUTE WS-X = FUNCTION INTEGER(PL-X)
         COMPUTE WS-Y = FUNCTION INTEGER(PL-Y - 0.500001)
         COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
         CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
         IF WS-STATE > 0 AND WS-STATE < BSH-MAX-STATES
             IF BSH-SLIP(WS-STATE + 1) > 0
                 COMPUTE L-FRICTION = BSH-SLIP(WS-STATE + 1) / 1000
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PHYS-FRICTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-STEP-UP.
*> USING CLIENT-STATE, start x, y, z (FLOAT-LONG: where the horizontal move began), wanted dx, dz (FLOAT-LONG), stepped out (1 when the
*> step-up was taken): the player was stopped by a horizontal collision; from the start it rises by up to 0.6, makes the wanted move
*> and drops back down by the height it rose. When that gets it further along the ground than the plain move did, the player
*> keeps that position (stepped 1); otherwise the plain move is restored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AXIS                BINARY-LONG.
 01 WS-UP                  FLOAT-LONG.
 01 WS-DOWN                FLOAT-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-P1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PLAIN               FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-CEILING             FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-STEPPED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SX L-SY L-SZ L-DX L-DZ L-STEPPED.
     MOVE 0 TO L-STEPPED
     MOVE PL-X TO WS-P1(1)
     MOVE PL-Y TO WS-P1(2)
     MOVE PL-Z TO WS-P1(3)
     COMPUTE WS-PLAIN = (PL-X - L-SX) ** 2 + (PL-Z - L-SZ) ** 2
     MOVE L-SX TO PL-X
     MOVE L-SY TO PL-Y
     MOVE L-SZ TO PL-Z
     MOVE 2 TO WS-AXIS
     MOVE 0.6 TO WS-UP
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-UP WS-BLOCKED
     COMPUTE WS-UP = PL-Y - L-SY
*>   The rise is also held down by what hangs over the cells the move enters (the box swept toward the wanted move): a 1/16 lip under a
*>   door lintel is stepped over by the rise the lintel leaves, not refused for the full 0.6 (51 section 6: passable if the entity rises by at most the step height).
     COMPUTE PL-X = L-SX + L-DX
     MOVE L-SY TO PL-Y
     COMPUTE PL-Z = L-SZ + L-DZ
     MOVE 2 TO WS-AXIS
     MOVE 0.6 TO WS-CEILING
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-CEILING WS-BLOCKED
     COMPUTE WS-CEILING = PL-Y - L-SY
     MOVE L-SX TO PL-X
     MOVE L-SZ TO PL-Z
     COMPUTE WS-UP = FUNCTION MIN(WS-UP, WS-CEILING)
     COMPUTE PL-Y = L-SY + WS-UP
     MOVE 1 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS L-DX WS-BLOCKED
     MOVE 3 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS L-DZ WS-BLOCKED
     MOVE 2 TO WS-AXIS
     COMPUTE WS-DOWN = 0 - WS-UP
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS WS-DOWN WS-BLOCKED
     COMPUTE WS-STEP = (PL-X - L-SX) ** 2 + (PL-Z - L-SZ) ** 2
     IF WS-STEP > WS-PLAIN + 0.000000001
         MOVE 1 TO L-STEPPED
     ELSE
         MOVE WS-P1(1) TO PL-X
         MOVE WS-P1(2) TO PL-Y
         MOVE WS-P1(3) TO PL-Z
     END-IF
     GOBACK.
 END PROGRAM PHYS-STEP-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-BOX.
*> USING CLIENT-STATE, half width out, height out (FLOAT-LONG): the box of the Player's pose (docs/protocol/53 sections 1 and 2.1):
*> standing (0) the operator's box 0.7 x 1.75, crouching (5) 1.5 high, swimming or crawling (3) and fall flying (1) 0.6 x 0.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HALF L-HEIGHT.
     CALL "PHYS-STAND-BOX" USING L-HALF L-HEIGHT
     EVALUATE PL-POSE
         WHEN 5
             MOVE 1.5 TO L-HEIGHT
         WHEN 3
             MOVE 0.3 TO L-HALF
             MOVE 0.6 TO L-HEIGHT
         WHEN 1
             MOVE 0.3 TO L-HALF
             MOVE 0.6 TO L-HEIGHT
     END-EVALUATE
     GOBACK.
 END PROGRAM PHYS-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-STAND-BOX.
*> USING half width out, height out (FLOAT-LONG): the standing box of the Player: the one the core's movement check uses (core/src/movement.cob reads
*> the width and height of the set's player entity): 0.6 x 1.8 for a standard (or debug) content set (docs/protocol/53 section 2.1), 0.7 x 1.75 for
*> the cobolcraft stand-in set (standin-content section 3) and while no set is open. A narrower or taller box than the core's is how a step onto a carpet
*> or a slab was taken by the client and refused by the core (Player Position, every frame: the shake).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-HALF L-HEIGHT.
     MOVE 0.35 TO L-HALF
     MOVE 1.75 TO L-HEIGHT
     IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         MOVE 0.3 TO L-HALF
         MOVE 1.8 TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM PHYS-STAND-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-COLLIDES.
*> USING CLIENT-STATE, feet x, y, z (FLOAT-LONG), hit out (1 = the box of the Player's pose overlaps a collision box of a cell).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-HIT.
     CALL "PHYS-BOX" USING CLIENT-STATE WS-HALF WS-HEIGHT
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE L-X L-Y L-Z WS-HALF WS-HEIGHT L-HIT
     GOBACK.
 END PROGRAM PHYS-COLLIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-COLLIDES-BOX.
*> USING CLIENT-STATE, feet x, y, z, half width, height (FLOAT-LONG), hit out (1 = a box of that size at that position overlaps a
*> collision box of a cell).
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
 01 WS-SHAPE               BINARY-LONG.
 01 WS-BOX.
    05 WS-B                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-SBOX.
    05 WS-SB               FLOAT-LONG OCCURS 6 TIMES.
 01 WS-OFFS.
    05 WS-OFF              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-HALF L-HEIGHT L-HIT.
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - L-HALF + WS-EPSILON)
     COMPUTE WS-X1 = FUNCTION INTEGER(L-X + L-HALF - WS-EPSILON)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + WS-EPSILON)
     COMPUTE WS-Y1 = FUNCTION INTEGER(L-Y + L-HEIGHT - WS-EPSILON)
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - L-HALF + WS-EPSILON)
     COMPUTE WS-Z1 = FUNCTION INTEGER(L-Z + L-HALF - WS-EPSILON)
     COMPUTE WS-B(1) = L-X - L-HALF
     MOVE L-Y TO WS-B(2)
     COMPUTE WS-B(3) = L-Z - L-HALF
     COMPUTE WS-B(4) = L-X + L-HALF
     COMPUTE WS-B(5) = L-Y + L-HEIGHT
     COMPUTE WS-B(6) = L-Z + L-HALF
     MOVE 0 TO L-HIT
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1 OR L-HIT = 1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1 OR L-HIT = 1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1 OR L-HIT = 1
                 CALL "PHYS-CELL-SHAPE" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SHAPE
                 IF WS-SHAPE NOT = 0
                     CALL "PHYS-CELL-OFFSET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-OFFS
                     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                         COMPUTE WS-SB(WS-A) = WS-B(WS-A) - WS-OFF(WS-A)
                         COMPUTE WS-SB(WS-A + 3) = WS-B(WS-A + 3) - WS-OFF(WS-A)
                     END-PERFORM
                     CALL "BSH-OVERLAPS" USING WS-SHAPE WS-X WS-Y WS-Z WS-SBOX L-HIT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PHYS-COLLIDES-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-CAN-FALL.
*> USING CLIENT-STATE, dx, dz (FLOAT-LONG: the offset of the Player's footprint), h (the depth), fall out (1 when the offset footprint could
*> fall at least h: docs/protocol/53 section 5.2): the slab under the feet, h + 1e-7 thick, is free of collision boxes. The probe is the
*> footprint of the pose shrunk by 1e-7 horizontally, from feet y - h - 1e-7 up to the feet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-PROBE-HALF          FLOAT-LONG.
 01 WS-PROBE-HEIGHT        FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-FALL                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DX L-DZ L-H L-FALL.
     CALL "PHYS-BOX" USING CLIENT-STATE WS-HALF WS-HEIGHT
     COMPUTE WS-PROBE-HALF = WS-HALF - 0.0000001
     COMPUTE WS-PROBE-HEIGHT = L-H + 0.0000001
     COMPUTE WS-PX = PL-X + L-DX
     COMPUTE WS-PY = PL-Y - WS-PROBE-HEIGHT
     COMPUTE WS-PZ = PL-Z + L-DZ
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-PROBE-HALF WS-PROBE-HEIGHT WS-HIT
     MOVE 1 TO L-FALL
     IF WS-HIT = 1
         MOVE 0 TO L-FALL
     END-IF
     GOBACK.
 END PROGRAM PHYS-CAN-FALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-BACKOFF.
*> USING CLIENT-STATE, dx, dz (FLOAT-LONG, in and out): the sneak edge clamp (docs/protocol/53 section 5.3), H = 0.6, steps of 0.05:
*> x alone while the footprint shifted by x could fall at least H, then z alone, then both together.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   FLOAT-LONG VALUE 0.6.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-FALL                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DX L-DZ.
     MOVE 1 TO WS-FALL
     PERFORM UNTIL L-DX = 0 OR WS-FALL = 0
         CALL "PHYS-CAN-FALL" USING CLIENT-STATE L-DX WS-ZERO WS-H WS-FALL
         IF WS-FALL = 1
             IF FUNCTION ABS(L-DX) <= 0.05
                 MOVE 0 TO L-DX
             ELSE
                 COMPUTE L-DX = L-DX - FUNCTION SIGN(L-DX) * 0.05
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO WS-FALL
     PERFORM UNTIL L-DZ = 0 OR WS-FALL = 0
         CALL "PHYS-CAN-FALL" USING CLIENT-STATE WS-ZERO L-DZ WS-H WS-FALL
         IF WS-FALL = 1
             IF FUNCTION ABS(L-DZ) <= 0.05
                 MOVE 0 TO L-DZ
             ELSE
                 COMPUTE L-DZ = L-DZ - FUNCTION SIGN(L-DZ) * 0.05
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO WS-FALL
     PERFORM UNTIL L-DX = 0 OR L-DZ = 0 OR WS-FALL = 0
         CALL "PHYS-CAN-FALL" USING CLIENT-STATE L-DX L-DZ WS-H WS-FALL
         IF WS-FALL = 1
             IF FUNCTION ABS(L-DX) <= 0.05
                 MOVE 0 TO L-DX
             ELSE
                 COMPUTE L-DX = L-DX - FUNCTION SIGN(L-DX) * 0.05
             END-IF
             IF FUNCTION ABS(L-DZ) <= 0.05
                 MOVE 0 TO L-DZ
             ELSE
                 COMPUTE L-DZ = L-DZ - FUNCTION SIGN(L-DZ) * 0.05
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PHYS-BACKOFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-POSE.
*> USING CLIENT-STATE, shift (1 when the sneak key is down): the end of the tick's pose choice (docs/protocol/53 section 3.2) and the
*> crouching flag of the next tick (53 section 3.3), the camera eye height (53 section 7). The swimming box must fit or nothing changes;
*> desired pose crouching with shift (not flying) else standing; a pose whose box does not fit becomes crouching, then swimming (3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DESIRED             BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-STAND-FITS          BINARY-LONG.
 01 WS-CROUCH-FITS         BINARY-LONG.
 01 WS-SWIM-FITS           BINARY-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-HALF-S              FLOAT-LONG.
 01 WS-HEIGHT-STAND        FLOAT-LONG.
 01 WS-HEIGHT-CROUCH       FLOAT-LONG VALUE 1.5.
 01 WS-HALF-SWIM           FLOAT-LONG VALUE 0.3.
 01 WS-HEIGHT-SWIM         FLOAT-LONG VALUE 0.6.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SHIFT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SHIFT.
     CALL "PHYS-STAND-BOX" USING WS-HALF-S WS-HEIGHT-STAND
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE PL-X PL-Y PL-Z WS-HALF-SWIM WS-HEIGHT-SWIM WS-HIT
     MOVE 1 TO WS-SWIM-FITS
     IF WS-HIT = 1
         MOVE 0 TO WS-SWIM-FITS
     END-IF
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE PL-X PL-Y PL-Z WS-HALF-S WS-HEIGHT-CROUCH WS-HIT
     MOVE 1 TO WS-CROUCH-FITS
     IF WS-HIT = 1
         MOVE 0 TO WS-CROUCH-FITS
     END-IF
     CALL "PHYS-COLLIDES-BOX" USING CLIENT-STATE PL-X PL-Y PL-Z WS-HALF-S WS-HEIGHT-STAND WS-HIT
     MOVE 1 TO WS-STAND-FITS
     IF WS-HIT = 1
         MOVE 0 TO WS-STAND-FITS
     END-IF
     IF WS-SWIM-FITS = 1
         MOVE 0 TO WS-DESIRED
         IF L-SHIFT = 1 AND PL-FLYING = 0
             MOVE 5 TO WS-DESIRED
         END-IF
         IF PL-GLIDING = 1
             MOVE 1 TO WS-DESIRED
         END-IF
         IF PL-SWIMMING = 1
             MOVE 3 TO WS-DESIRED
         END-IF
         EVALUATE TRUE
             WHEN PL-MODE = 3
                 CONTINUE
             WHEN WS-DESIRED = 0 AND WS-STAND-FITS = 0
                 MOVE 5 TO WS-DESIRED
                 IF WS-CROUCH-FITS = 0
                     MOVE 3 TO WS-DESIRED
                 END-IF
             WHEN WS-DESIRED = 5 AND WS-CROUCH-FITS = 0
                 MOVE 3 TO WS-DESIRED
         END-EVALUATE
         MOVE WS-DESIRED TO PL-POSE
     END-IF
*>   The crouching flag of the next tick: not flying, the crouching box fits and (shift, or the standing box does not fit).
     MOVE 0 TO PL-SNEAK-FLAG
     IF PL-FLYING = 0 AND WS-CROUCH-FITS = 1 AND (L-SHIFT = 1 OR WS-STAND-FITS = 0)
         MOVE 1 TO PL-SNEAK-FLAG
     END-IF
*>   Moving slowly is also visual crawling: the swimming pose out of the water (53 section 3.3).
     IF PL-POSE = 3 AND PL-IN-WATER = 0
         MOVE 1 TO PL-SNEAK-FLAG
     END-IF
*>   The own model's swim amount (53 section 12.2).
     IF PL-POSE = 3
         COMPUTE PL-SWIM-AMOUNT = FUNCTION MIN(1, PL-SWIM-AMOUNT + 0.09)
     ELSE
         COMPUTE PL-SWIM-AMOUNT = FUNCTION MAX(0, PL-SWIM-AMOUNT - 0.09)
     END-IF
*>   The camera eye: half the gap to the pose's eye height each tick; the first tick takes it.
     EVALUATE PL-POSE
         WHEN 5
             MOVE 1.25 TO WS-TARGET
         WHEN 3
             MOVE 0.4 TO WS-TARGET
         WHEN 1
             MOVE 0.4 TO WS-TARGET
         WHEN OTHER
             MOVE 1.6 TO WS-TARGET
     END-EVALUATE
     IF PL-EYE = 0
         MOVE WS-TARGET TO PL-EYE
     ELSE
         COMPUTE PL-EYE = PL-EYE + (WS-TARGET - PL-EYE) * 0.5
     END-IF
     GOBACK.
 END PROGRAM PHYS-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-CELL-SHAPE.
*> USING CLIENT-STATE, block x, y, z, collision shape id out (CTBSHAPE.cpy: 0 none, 1 the full cube): a cell of a chunk the client
*> does not have is a full cube, a cell outside the height range has none, and a fluid cell has none (29a section 1.2; a waterlogged
*> block (4) keeps its own).
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
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-SHAPE.
     MOVE 0 TO L-SHAPE
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     EVALUATE TRUE
         WHEN L-Y < PL-MIN-Y OR L-Y >= PL-MIN-Y + PL-HEIGHT
             CONTINUE
         WHEN WS-ROW = 0
             MOVE 1 TO L-SHAPE
         WHEN OTHER
             CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
             IF WS-STATE NOT = 0
                 CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
                 IF ST-FLUID(WS-STATE + 1) = 0 OR ST-FLUID(WS-STATE + 1) = 4
                     CALL "BSH-COLL-ID" USING WS-STATE L-SHAPE
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PHYS-CELL-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-CELL-OFFSET.
*> USING CLIENT-STATE, block x, y, z, offset out (3 FLOAT-LONG, blocks): the model offset of the block in the cell (BSH-OFFSET, 51 section 1.4) that moves its collision
*> shape; 0 for a cell with no offset block or none in the replica.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OFFS.
    05 L-OFF               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-OFFS.
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
     CALL "BSH-OFFSET" USING WS-STATE L-X L-Y L-Z WS-OX WS-OY WS-OZ
     MOVE WS-OX TO L-OFF(1)
     MOVE WS-OY TO L-OFF(2)
     MOVE WS-OZ TO L-OFF(3)
     GOBACK.
 END PROGRAM PHYS-CELL-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-SOLID.
*> USING CLIENT-STATE, block x, y, z, solid out (1 or 0): 1 when the cell has a collision shape (PHYS-CELL-SHAPE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHAPE               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-SOLID.
     CALL "PHYS-CELL-SHAPE" USING CLIENT-STATE L-X L-Y L-Z WS-SHAPE
     MOVE 0 TO L-SOLID
     IF WS-SHAPE NOT = 0
         MOVE 1 TO L-SOLID
     END-IF
     GOBACK.
 END PROGRAM PHYS-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXPLODE-READ.
*> USING CLIENT-STATE, packet (PROTO-PACKET reader): Explode 0x24 (05a): centre (3 doubles), radius (float), block count (Int), the optional knockback
*> (Boolean, then 3 doubles); the particle, sound and block particles after it are not read. A knockback adds its x and z to the horizontal push (PL-KB-X,
*> PL-KB-Z, spent by PHYS-TICK) and its y to the vertical speed (PL-VY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-RADIUS              FLOAT-SHORT.
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-KX                  FLOAT-LONG.
 01 WS-KY                  FLOAT-LONG.
 01 WS-KZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-RADIUS
     CALL "PB-GET-INT" USING PB-BUFFER WS-BLOCKS
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-KX
         CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-KY
         CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-KZ
         COMPUTE PL-KB-X = PL-KB-X + WS-KX
         COMPUTE PL-KB-Z = PL-KB-Z + WS-KZ
         COMPUTE PL-VY = PL-VY + WS-KY
         MOVE 0 TO PL-ON-GROUND
     END-IF
     GOBACK.
 END PROGRAM EXPLODE-READ.
