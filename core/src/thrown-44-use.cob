*> The throwing of items by players and the tick of the thrown entities of lane 002-lane-mobsb6 (17 section 3.15, 44 part 8 sections 6.1 and 6.5).
*> THROWN-ITEM-USE handles Use Item (0x43) for a held throwable (main hand only): splash_potion and lingering_potion (speed 0.5, pitch offset -20 degrees), ender_pearl, egg and snowball (speed 1.5) and fishing_rod (BOBBER-USE, thrown-44c.cob) and ender_eye (EYE-ITEM-USE, thrown-44g.cob) and experience_bottle (speed 0.7, offset -20, mob-21-8-13.cob). The projectile
*> starts at (x, eye y - 0.1, z) of the player, moves along (-sin(yaw) cos(pitch), -sin(pitch + offset), cos(yaw) cos(pitch)) normalised and scaled by the speed; a survival
*> player's stack loses one. Gaps: the inaccuracy (triangle noise), the thrower's own motion, the sound, the statistic and the item cooldown are not modelled;
*> a thrown potion has the contents of the thrown stack's potion_contents (POTION-LOAD, potion-load.cob; a stack without it is a water bottle).
*>
*>   THROWN-DIRECTION USING yaw, pitch, offset (degrees, FLOAT-LONG), speed (FLOAT-LONG), vx vy vz out (FLOAT-LONG)
*>   THROWN-ITEM-USE USING connection id, PLAY-SERVERBOUND, done out
*>   THROWN-TICK                                          every thrown entity (CORE-TICK, after the projectiles)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-DIRECTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-LIFT                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-OFFSET L-SPEED L-VX L-VY L-VZ.
     COMPUTE WS-YAW = L-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = L-PITCH * FUNCTION PI / 180
     COMPUTE WS-LIFT = (L-PITCH + L-OFFSET) * FUNCTION PI / 180
     COMPUTE WS-DX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DY = 0 - FUNCTION SIN(WS-LIFT)
     COMPUTE WS-DZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE L-VX = WS-DX / WS-LEN * L-SPEED
     COMPUTE L-VY = WS-DY / WS-LEN * L-SPEED
     COMPUTE L-VZ = WS-DZ / WS-LEN * L-SPEED
     GOBACK.
 END PROGRAM THROWN-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-LINGER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-OFFSET              FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EKEY                PIC X(112).
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR PSB-HAND NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     MOVE 0 TO WS-KIND
     MOVE 0 TO WS-LINGER
     MOVE 0.5 TO WS-SPEED
     MOVE 0 TO WS-OFFSET
     EVALUATE WS-KEY
         WHEN "splash_potion"
             MOVE 1 TO WS-KIND
             MOVE -20 TO WS-OFFSET
         WHEN "lingering_potion"
             MOVE 1 TO WS-KIND
             MOVE 1 TO WS-LINGER
             MOVE -20 TO WS-OFFSET
         WHEN "ender_pearl"
             MOVE 2 TO WS-KIND
             MOVE 1.5 TO WS-SPEED
         WHEN "egg"
             MOVE 3 TO WS-KIND
             MOVE 1.5 TO WS-SPEED
         WHEN "snowball"
             MOVE 4 TO WS-KIND
             MOVE 1.5 TO WS-SPEED
         WHEN "fishing_rod"
             MOVE 5 TO WS-KIND
         WHEN "ender_eye"
             MOVE 6 TO WS-KIND
         WHEN "experience_bottle"
             MOVE 7 TO WS-KIND
             MOVE -20 TO WS-OFFSET
             MOVE 0.7 TO WS-SPEED
     END-EVALUATE
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     IF WS-KIND = 5
         MOVE PSB-YAW TO WS-YAW
         MOVE PSB-PITCH TO WS-PITCH
         CALL "BOBBER-USE" USING L-ID WS-YAW WS-PITCH
         GOBACK
     END-IF
     IF WS-KIND = 6
         MOVE PSB-YAW TO WS-YAW
         MOVE PSB-PITCH TO WS-PITCH
         CALL "EYE-ITEM-USE" USING L-ID WS-YAW WS-PITCH L-DONE
         GOBACK
     END-IF
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE PL-X(WS-ROW) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-ROW) + 1.62 - 0.1
     MOVE PL-Z(WS-ROW) TO WS-Z
     MOVE PSB-YAW TO WS-YAW
     MOVE PSB-PITCH TO WS-PITCH
     CALL "THROWN-DIRECTION" USING WS-YAW WS-PITCH WS-OFFSET WS-SPEED WS-VX WS-VY WS-VZ
     EVALUATE WS-KIND
         WHEN 1
             CALL "POTION-SPAWN" USING WS-LINGER WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ PL-ENTITY-ID(WS-ROW) WS-NEW
             IF WS-NEW > 0
                 CALL "POTION-LOAD" USING WS-NEW PL-SLOT-VAR(WS-ROW, WS-SLOT) WS-LINGER
             END-IF
         WHEN 2
             MOVE 4 TO WS-PJ
             MOVE "minecraft:ender_pearl" TO WS-EKEY
             CALL "THROWN-SPAWN" USING WS-PJ WS-EKEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ PL-ENTITY-ID(WS-ROW) WS-NEW
         WHEN 3
             MOVE 6 TO WS-PJ
             MOVE "minecraft:egg" TO WS-EKEY
             CALL "THROWN-SPAWN" USING WS-PJ WS-EKEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ PL-ENTITY-ID(WS-ROW) WS-NEW
         WHEN 7
*>           The experience bottle (21 section 8.13, 25-6 section 10.1): PJ-KIND 40, offset -20 degrees, power 0.7.
             MOVE 40 TO WS-PJ
             MOVE "minecraft:experience_bottle" TO WS-EKEY
             CALL "THROWN-SPAWN" USING WS-PJ WS-EKEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ PL-ENTITY-ID(WS-ROW) WS-NEW
         WHEN OTHER
*>           The snowball is the projectile of mob-21-proj.cob (PROJ-SPAWN starts it at 1.6; the thrown speed is 1.5).
             MOVE 3 TO WS-PJ
             CALL "PROJ-SPAWN" USING WS-PJ WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-NONE PL-ENTITY-ID(WS-ROW) WS-NEW
             IF WS-NEW > 0
                 COMPUTE EN-VX(WS-NEW) = WS-VX
                 COMPUTE EN-VY(WS-NEW) = WS-VY
                 COMPUTE EN-VZ(WS-NEW) = WS-VZ
             END-IF
     END-EVALUATE
     IF WS-NEW > 0
         CALL "MOB-TAKE" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM THROWN-ITEM-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. THROWN-TICK.
*> No parameters: every entity with a PROJSTATE entry steps by its kind; an entry whose entity is gone is freed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0
             MOVE 0 TO WS-ROW
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-ROW > 0
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I)
                     MOVE WS-E TO WS-ROW
                 END-IF
             END-PERFORM
             IF WS-ROW = 0
                 INITIALIZE PJ-ENTRY(WS-I)
             ELSE
                 MOVE PJ-KIND(WS-I) TO WS-KIND
                 EVALUATE WS-KIND
                     WHEN 1 WHEN 2
                         CALL "POTION-STEP" USING WS-ROW
                     WHEN 3
                         CALL "CLOUD-STEP" USING WS-ROW
                     WHEN 4
                         CALL "PEARL-STEP" USING WS-ROW
                     WHEN 5
                         CALL "EYE-STEP" USING WS-ROW
                     WHEN 6
                         CALL "EGG-STEP" USING WS-ROW
                     WHEN 7
                         CALL "BOBBER-STEP" USING WS-ROW
                     WHEN 8
                         CALL "FIREWORK-STEP" USING WS-ROW
                     WHEN 9
                         CALL "LIGHTNING-STEP" USING WS-ROW
                     WHEN 10
                         CALL "MINECART-STEP" USING WS-ROW
                     WHEN 14
                         CALL "WITHER-STEP" USING WS-ROW
                     WHEN 15
                         CALL "WSKULL-STEP" USING WS-ROW
                     WHEN 17
                         CALL "DRAGON-STEP" USING WS-ROW
                     WHEN 18
                         CALL "DFIRE-STEP" USING WS-ROW
                     WHEN 40
                         CALL "XP-BOTTLE-STEP" USING WS-ROW
                     WHEN 41
                         CALL "OIS-STEP" USING WS-ROW
                     WHEN 42
                         CALL "WIND-STEP" USING WS-ROW
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM THROWN-TICK.
