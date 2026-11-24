*> The local player's elytra flight and the velocity packets (lane p46f, T27500 to T27502; docs/protocol/17 section 3.13 elytra and fireworks, 05c Player Command 6 START_FALL_FLYING,
*> 05b 0x67 Set Entity Motion, 53 section 2.1 the FALL_FLYING box and eye height):
*>   PHYS-GLIDER USING CLIENT-STATE, usable out   the chest slot (the inventory menu's slot IX 2, filled by Container Set Content and Set Slot) holds an elytra that the next point of
*>                                               damage would not break, and the player has no Levitation (canGlideUsing, canGlide of 3.13)
*>   PHYS-GLIDE-START USING CLIENT-STATE          Space pressed in the air (PHYS-INPUT): with a usable elytra, not already gliding, not flying and not in a fluid the glide starts
*>                                               with the horizontal step of the last walking tick as its velocity, and Player Command START_FALL_FLYING goes to the server
*>   PHYS-GLIDE USING CLIENT-STATE                one tick of a glide (PHYS-TICK): the glide ends (PL-GLIDING 0, the walking step runs) when the player stands on the ground, in a fluid,
*>                                               flies, or has no usable elytra; otherwise the five steps of 3.13 replace the walking step (TOOL-ELYTRA-STEP of the core's tool rules:
*>                                               velocity and look vector in millionths, pitch in thousandths of a degree, gravity 0.08) and the player moves by the new velocity
*>                                               (Y, then X, then Z against the replica; a blocked axis loses its speed)
*>   PLAYER-MOTION-SET USING CLIENT-STATE, vx, vy, vz   Set Entity Motion for the local player: while gliding the velocity of the glider (a firework rocket's boost, 3.13), otherwise the
*>                                               vertical speed and the horizontal push that decays on the ground and in the air like an Explode packet's knockback (physics.cob PHYS-TICK)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-GLIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-STATUS              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEVITATION          BINARY-LONG VALUE 24.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-USABLE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-USABLE.
     MOVE 0 TO L-USABLE
     IF IX-COUNT(2) > 0
         CALL "CONTENT-ITEM-BY-ID" USING IX-ITEM(2) WS-ROW WS-STATUS
         IF WS-STATUS = 0 AND WS-R-KEY = "elytra"
             CALL "ITEM-MAX-DAMAGE" USING CLIENT-STATE IX-ITEM(2) WS-MAX
             MOVE 1 TO L-USABLE
             IF WS-MAX > 0 AND IX-DAMAGE(2) + 1 >= WS-MAX
                 MOVE 0 TO L-USABLE
             END-IF
         END-IF
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-ID(WS-I) = WS-LEVITATION
             MOVE 0 TO L-USABLE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PHYS-GLIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-GLIDE-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-ACTION              BINARY-LONG VALUE 6.
 01 WS-USABLE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF PL-GLIDING = 1 OR PL-ON-GROUND = 1 OR PL-FLYING = 1 OR PL-IN-WATER = 1 OR PL-IN-LAVA = 1
         GOBACK
     END-IF
     CALL "PHYS-GLIDER" USING CLIENT-STATE WS-USABLE
     IF WS-USABLE = 0
         GOBACK
     END-IF
     MOVE 1 TO PL-GLIDING
     MOVE PL-MOVE-X TO PL-VX
     MOVE PL-MOVE-Z TO PL-VZ
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLAYER-COMMAND" USING PB-BUFFER PL-ENTITY-ID WS-ACTION
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM PHYS-GLIDE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PHYS-GLIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-USABLE              BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-LOOK-X              FLOAT-LONG.
 01 WS-LOOK-Y              FLOAT-LONG.
 01 WS-LOOK-Z              FLOAT-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-PITCH-MILLI         BINARY-LONG.
 01 WS-GRAVITY             BINARY-LONG VALUE 80000.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-BELOW               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "PHYS-GLIDER" USING CLIENT-STATE WS-USABLE
     IF PL-ON-GROUND = 1 OR PL-IN-WATER = 1 OR PL-IN-LAVA = 1 OR PL-FLYING = 1 OR WS-USABLE = 0
         MOVE 0 TO PL-GLIDING PL-VX PL-VZ
         GOBACK
     END-IF
*>   The look vector (yaw 0 faces +Z, pitch positive looks down) and the step of 3.13 on the velocity.
     COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH * FUNCTION PI / 180
     COMPUTE WS-LOOK-X = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-LOOK-Y = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-LOOK-Z = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-VX ROUNDED = PL-VX * 1000000
     COMPUTE WS-VY ROUNDED = PL-VY * 1000000
     COMPUTE WS-VZ ROUNDED = PL-VZ * 1000000
     COMPUTE WS-LX ROUNDED = WS-LOOK-X * 1000000
     COMPUTE WS-LY ROUNDED = WS-LOOK-Y * 1000000
     COMPUTE WS-LZ ROUNDED = WS-LOOK-Z * 1000000
     COMPUTE WS-PITCH-MILLI ROUNDED = PL-PITCH * 1000
     CALL "TOOL-ELYTRA-STEP" USING WS-VX WS-VY WS-VZ WS-LX WS-LY WS-LZ WS-PITCH-MILLI WS-GRAVITY WS-NX WS-NY WS-NZ
     COMPUTE PL-VX = WS-NX / 1000000
     COMPUTE PL-VY = WS-NY / 1000000
     COMPUTE PL-VZ = WS-NZ / 1000000
*>   The move: Y, then X, then Z; what a blocked axis stops loses its speed.
     MOVE 2 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS PL-VY WS-BLOCKED
     IF WS-BLOCKED = 1
         MOVE 0 TO PL-VY
     END-IF
     MOVE 1 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS PL-VX WS-BLOCKED
     IF WS-BLOCKED = 1
         MOVE 0 TO PL-VX
     END-IF
     MOVE 3 TO WS-AXIS
     CALL "PHYS-MOVE" USING CLIENT-STATE WS-AXIS PL-VZ WS-BLOCKED
     IF WS-BLOCKED = 1
         MOVE 0 TO PL-VZ
     END-IF
     MOVE 0 TO PL-COLLIDED
     COMPUTE WS-BELOW = PL-Y - 0.001
     CALL "PHYS-COLLIDES" USING CLIENT-STATE PL-X WS-BELOW PL-Z WS-HIT
     MOVE WS-HIT TO PL-ON-GROUND
     GOBACK.
 END PROGRAM PHYS-GLIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-MOTION-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-VX L-VY L-VZ.
     MOVE L-VY TO PL-VY
     IF PL-GLIDING = 1
         MOVE L-VX TO PL-VX
         MOVE L-VZ TO PL-VZ
     ELSE
         MOVE L-VX TO PL-KB-X
         MOVE L-VZ TO PL-KB-Z
     END-IF
     GOBACK.
 END PROGRAM PLAYER-MOTION-SET.
