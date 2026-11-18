*> Elytra gliding and firework rockets (docs/protocol/17 section 3.13, 5.1 durability, 05c Player Command START_FALL_FLYING, 18 section 1.4 shared flag 7 and the pose; lane
*> 002-lane-p46e, T27016). The server side of the glide: Player Command 6 (MOVE-SPRINT) starts it (RANGED-GLIDE-START) when an elytra is worn in the chest slot that the next point of damage would
*> not break (TOOL-ELYTRA-CAN-GLIDE), the player is not gliding already, not in water and has no Levitation; TS-GLIDE-TICKS counts it (1 + the ticks flown: fallFlyTicks + 1 is the n of
*> TOOL-ELYTRA-DURABILITY), POSE-UPDATE shows the fall flying pose and the shared flag 0x80; RANGED-TICK (RANGED-GLIDE-TICK) ends the flight when the player is on the ground, rides, or no longer
*> has a usable elytra, and otherwise wears the elytra by 1 every 20 ticks (n 20, 40, ...). The flight step itself (gravity, lift, drag of section 3.13) replaces the normal travel step, which the
*> client simulates (the client sends its position); the server follows the position of each tick (TS-GLIDE-LAST-X to Z) to know the speed of the glider.
*> Rockets: Use Item with a firework rocket while gliding launches it attached to the player (FIREWORK-SPAWN with the attached id) and uses one up (a creative player keeps the stack); Use Item
*> On a block launches it unattached at the click point plus 0.15 along the face normal. The flight duration and the number of explosions come from the fireworks component of the stack
*> (type 71: VarInt flight duration, VarInt explosion count), duration 1 and no star without it. An attached rocket follows the player and every tick pushes the glider
*> (RANGED-ROCKET-BOOST, from FIREWORK-STEP): the new velocity is TOOL-FIREWORK-BOOST of the glider's speed and look vector, sent as Set Entity Motion.
*> Not done: the sounds, the rocket's own acceleration, the flight orientation and Entity Event of the client, the client's own flight step and the key that starts it (the client does not glide yet).
*>
*>   RANGED-CAN-GLIDE USING player row, can out        an elytra worn in the chest slot, unbroken by the next point, no Levitation, not in water
*>   RANGED-GLIDE-START USING player row               Player Command START_FALL_FLYING
*>   RANGED-GLIDE-TICK USING player row                one tick of a glide
*>   RANGED-ROCKET-LAUNCH USING player row, attached (1 or 0), x, y, z (FLOAT-LONG)   a rocket of the held stack
*>   RANGED-ROCKET-USE USING player row, done out      Use Item with a rocket
*>   RANGED-ROCKET-ON USING connection id, PLAY-SERVERBOUND, item id, done out   Use Item On with a rocket
*>   RANGED-ROCKET-BOOST USING rocket row, attached entity id

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-CAN-GLIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-KEY                 PIC X(48).
 01 WS-GLIDER              BINARY-LONG.
 01 WS-SLOT-OK             BINARY-LONG VALUE 1.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-BREAK               BINARY-LONG.
 01 WS-LEVITATION-ID       BINARY-LONG VALUE 24.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-LEVITATION          BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAN.
     MOVE 0 TO L-CAN WS-GLIDER
     IF MN-EQUIP-COUNT(L-ROW, 3) > 0
         CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(L-ROW, 3) WS-KEY
         IF WS-KEY = "elytra"
             MOVE 1 TO WS-GLIDER
         END-IF
     END-IF
     MOVE 0 TO WS-BREAK
     IF WS-GLIDER = 1
         CALL "SP-GET-DAMAGE" USING MN-EQUIP-ITEM(L-ROW, 3) MN-EQUIP-VAR(L-ROW, 3) WS-DAMAGE
         CALL "SP-GET-MAX-DAMAGE" USING MN-EQUIP-ITEM(L-ROW, 3) MN-EQUIP-VAR(L-ROW, 3) WS-MAX
         IF WS-DAMAGE + 1 >= WS-MAX
             MOVE 1 TO WS-BREAK
         END-IF
     END-IF
     CALL "EFFECT-LEVEL" USING L-ROW WS-LEVITATION-ID WS-LEVEL WS-TICKS
     MOVE 0 TO WS-LEVITATION
     IF WS-LEVEL > 0
         MOVE 1 TO WS-LEVITATION
     END-IF
     CALL "FLUID-TOUCHES-WATER" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-WATER
     CALL "TOOL-ELYTRA-CAN-GLIDE" USING WS-GLIDER WS-SLOT-OK WS-BREAK WS-LEVITATION WS-WATER L-CAN
     GOBACK.
 END PROGRAM RANGED-CAN-GLIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-GLIDE-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-CAN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "COMBAT-TS-CHECK" USING L-ROW
     IF TS-GLIDE-TICKS(L-ROW) > 0
         GOBACK
     END-IF
     CALL "RANGED-CAN-GLIDE" USING L-ROW WS-CAN
     IF WS-CAN = 1
         MOVE 1 TO TS-GLIDE-TICKS(L-ROW)
         MOVE PL-X(L-ROW) TO TS-GLIDE-LAST-X(L-ROW)
         MOVE PL-Y(L-ROW) TO TS-GLIDE-LAST-Y(L-ROW)
         MOVE PL-Z(L-ROW) TO TS-GLIDE-LAST-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM RANGED-GLIDE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-GLIDE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-CAN                 BINARY-LONG.
 01 WS-HURT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CHEST               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "RANGED-CAN-GLIDE" USING L-ROW WS-CAN
     IF PL-ON-GROUND(L-ROW) = 1 OR EN-VEHICLE(PL-ENTITY-ROW(L-ROW)) > 0
         MOVE 0 TO WS-CAN
     END-IF
     IF WS-CAN = 0
         MOVE 0 TO TS-GLIDE-TICKS(L-ROW)
         CALL "POSE-UPDATE" USING L-ROW
         GOBACK
     END-IF
*>   updateFallFlying: n = fallFlyTicks + 1; the elytra takes 1 durability when n is a multiple of 10 and n / 10 is even.
     CALL "TOOL-ELYTRA-DURABILITY" USING TS-GLIDE-TICKS(L-ROW) WS-HURT
     IF WS-HURT = 1
         CALL "COMBAT-EQUIP-HURT" USING L-ROW WS-CHEST WS-ONE
     END-IF
     ADD 1 TO TS-GLIDE-TICKS(L-ROW)
     MOVE PL-X(L-ROW) TO TS-GLIDE-LAST-X(L-ROW)
     MOVE PL-Y(L-ROW) TO TS-GLIDE-LAST-Y(L-ROW)
     MOVE PL-Z(L-ROW) TO TS-GLIDE-LAST-Z(L-ROW)
     GOBACK.
 END PROGRAM RANGED-GLIDE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ROCKET-LAUNCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 71.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-STARS               BINARY-LONG.
 01 WS-ATTACHED            BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACH               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACH L-X L-Y L-Z.
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE 1 TO WS-DURATION
     MOVE 0 TO WS-STARS
     CALL "SP-GET-COMPONENT" USING PL-SLOT-VAR(L-ROW, WS-SLOT) WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-DURATION
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-STARS
     END-IF
     MOVE 0 TO WS-ATTACHED
     IF L-ATTACH = 1
         MOVE PL-ENTITY-ID(L-ROW) TO WS-ATTACHED
     END-IF
     CALL "FIREWORK-SPAWN" USING PL-DIM(L-ROW) L-X L-Y L-Z WS-DURATION WS-STARS WS-ATTACHED PL-ENTITY-ID(L-ROW) WS-NEW
     CALL "MOB-TAKE" USING L-ROW
     GOBACK.
 END PROGRAM RANGED-ROCKET-LAUNCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ROCKET-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-ATTACH              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 0 TO L-DONE
*>   FireworkRocketItem.use: only while gliding, the rocket starts at the player.
     IF TS-GLIDE-TICKS(L-ROW) > 0
         CALL "RANGED-ROCKET-LAUNCH" USING L-ROW WS-ATTACH PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW)
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM RANGED-ROCKET-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ROCKET-ON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DETACHED            BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-ITEM L-DONE.
     MOVE 0 TO L-DONE
     IF L-ITEM = 0 OR PSB-HAND NOT = 0
         GOBACK
     END-IF
     IF IT-KEY(L-ITEM + 1) NOT = "firework_rocket"
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
*>   The click point (the block plus the cursor) moved 0.15 along the face normal (0 down, 1 up, 2 north, 3 south, 4 west, 5 east).
     COMPUTE WS-X = PSB-BX + PSB-CURSOR-X
     COMPUTE WS-Y = PSB-BY + PSB-CURSOR-Y
     COMPUTE WS-Z = PSB-BZ + PSB-CURSOR-Z
     EVALUATE PSB-FACE
         WHEN 0
             COMPUTE WS-Y = WS-Y - 0.15
         WHEN 1
             COMPUTE WS-Y = WS-Y + 0.15
         WHEN 2
             COMPUTE WS-Z = WS-Z - 0.15
         WHEN 3
             COMPUTE WS-Z = WS-Z + 0.15
         WHEN 4
             COMPUTE WS-X = WS-X - 0.15
         WHEN OTHER
             COMPUTE WS-X = WS-X + 0.15
     END-EVALUATE
     CALL "RANGED-ROCKET-LAUNCH" USING WS-ROW WS-DETACHED WS-X WS-Y WS-Z
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM RANGED-ROCKET-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ROCKET-BOOST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-P                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROCKET               BINARY-LONG.
 01 L-ATTACHED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROCKET L-ATTACHED.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = L-ATTACHED AND L-ATTACHED > 0
             MOVE WS-P TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW = 0
         GOBACK
     END-IF
*>   The rocket rides along with its player.
     MOVE PL-X(WS-ROW) TO EN-X(L-ROCKET)
     MOVE PL-Y(WS-ROW) TO EN-Y(L-ROCKET)
     MOVE PL-Z(WS-ROW) TO EN-Z(L-ROCKET)
     IF TS-GLIDE-TICKS(WS-ROW) = 0
         GOBACK
     END-IF
*>   The glider's velocity is the step since the last tick; the push is look x 0.1 + (look x 1.5 - velocity) x 0.5 added to it (3.13).
     COMPUTE WS-VX ROUNDED = (PL-X(WS-ROW) - TS-GLIDE-LAST-X(WS-ROW)) * 1000000
     COMPUTE WS-VY ROUNDED = (PL-Y(WS-ROW) - TS-GLIDE-LAST-Y(WS-ROW)) * 1000000
     COMPUTE WS-VZ ROUNDED = (PL-Z(WS-ROW) - TS-GLIDE-LAST-Z(WS-ROW)) * 1000000
     CALL "RANGED-DIRECTION" USING PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ZERO WS-DX WS-DY WS-DZ
     COMPUTE WS-LX ROUNDED = WS-DX * 1000000
     COMPUTE WS-LY ROUNDED = WS-DY * 1000000
     COMPUTE WS-LZ ROUNDED = WS-DZ * 1000000
     CALL "TOOL-FIREWORK-BOOST" USING WS-VX WS-VY WS-VZ WS-LX WS-LY WS-LZ WS-NX WS-NY WS-NZ
     COMPUTE WS-MX ROUNDED = WS-NX / 1000
     COMPUTE WS-MY ROUNDED = WS-NY / 1000
     COMPUTE WS-MZ ROUNDED = WS-NZ / 1000
     CALL "COMBAT-MOTION-SEND" USING WS-ROW WS-MX WS-MY WS-MZ
     GOBACK.
 END PROGRAM RANGED-ROCKET-BOOST.
