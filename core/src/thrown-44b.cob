*> The ender pearl and the thrown egg of lane 002-lane-mobsb6 (17 section 3.15, 44 part 8 sections 6.5, 10 and 10.4), kinds 4 and 6 of PROJSTATE.cpy. Both fly as THROWN-FLY with
*> gravity 0.03. A pearl that hits anything teleports its owner (a living player of the pearl's dimension; the pearl keeps no other check) to the impact point, resets the fall
*> distance (CMD-MOVE-PLAYER), costs 5.0 (HEALTH-HURT, CAUSE-FALL: a fall type source that bypasses armor) and on a roll under 50 of 1000 spawns an endermite there when the level
*> spawns monsters. An egg hatches 1 baby chicken (age -24000) on nextInt(8) = 0 and 4 on nextInt(32) = 0 as well, then Entity Event 3 goes to the viewers.
*> Gaps: pearl vanishing when the owner dies offline and the chunk ticket, the End to Overworld portal rule, the End gateway, 32 portal particles and the teleport sound, a pearl
*> hitting an entity hurts it for 0, the chicken variant of the egg stack, the break particles, the throw cooldown of 20 ticks (no item cooldown store exists).
*>
*>   PEARL-ARRIVE USING owner player row (0 none), dim, x, y, z (FLOAT-LONG), roll 0 to 999
*>   PEARL-STEP USING tracker row
*>   EGG-HATCH USING dim, x, y, z (FLOAT-LONG), roll 8 (nextInt(8)), roll 32 (nextInt(32))
*>   EGG-STEP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PEARL-ARRIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:endermite".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MONSTERS            BINARY-LONG.
 01 WS-TELEPORTS           BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ENDERMITE           BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-FALL.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-OWNER                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROLL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-DIM L-X L-Y L-Z L-ROLL.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO WS-VALID WS-MONSTERS
     IF L-OWNER > 0
         IF PL-USED(L-OWNER) = 1 AND PL-STATE(L-OWNER) = PS-ALIVE AND PL-DIM(L-OWNER) = L-DIM
             MOVE 1 TO WS-VALID
         END-IF
     END-IF
     IF BW-DIFFICULTY > 0 AND CS-HOSTILE-MOBS = 1
         MOVE 1 TO WS-MONSTERS
     END-IF
     CALL "TOOL-PEARL-LAND" USING WS-VALID L-ROLL WS-MONSTERS WS-TELEPORTS WS-DAMAGE WS-ENDERMITE
     IF WS-TELEPORTS = 1
         CALL "CMD-MOVE-PLAYER" USING L-OWNER L-DIM L-X L-Y L-Z
         CALL "HEALTH-HURT" USING L-OWNER WS-DAMAGE WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
     END-IF
     IF WS-ENDERMITE = 1
         CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
         IF WS-TYPE > 0
             CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW WS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PEARL-ARRIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PEARL-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9004.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     MOVE 0 TO WS-OWNER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = PJ-OWNER(WS-SLOT)
             MOVE WS-P TO WS-OWNER
         END-IF
     END-PERFORM
     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-ROLL
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PJ-DROP" USING L-ROW
     CALL "PEARL-ARRIVE" USING WS-OWNER WS-DIM WS-X WS-Y WS-Z WS-ROLL
     GOBACK.
 END PROGRAM PEARL-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-HATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:chicken".
 01 WS-TYPE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R8                   BINARY-LONG.
 01 L-R32                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-R8 L-R32.
     CALL "TOOL-EGG-HATCH" USING L-R8 L-R32 WS-COUNT
     IF WS-COUNT = 0
         GOBACK
     END-IF
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW WS-NEW
         MOVE 1 TO EN-VARIANT(WS-NEW)
         MOVE -24000 TO EN-MOBAGE(WS-NEW)
     END-PERFORM
     GOBACK.
 END PROGRAM EGG-HATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-R8                  BINARY-LONG.
 01 WS-R32                 BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9006.
 01 WS-SALT2               BINARY-LONG VALUE 9007.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-THIRTY-TWO          BINARY-LONG VALUE 32.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-EIGHT WS-R8
     CALL "XP-RANDOM" USING WS-SALT2 WS-THIRTY-TWO WS-R32
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PJ-DROP" USING L-ROW
     CALL "EGG-HATCH" USING WS-DIM WS-X WS-Y WS-Z WS-R8 WS-R32
     GOBACK.
 END PROGRAM EGG-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EYE-SPAWN.
*> USING dim, x, y, z, target x, y, z (FLOAT-LONG), survives (1 = nextInt(5) > 0), owner entity id, row out (21 section 8.12 signalTo): an eye of ender at rest; a target farther than 12
*> blocks horizontally is replaced by the position + (dx / h x 12, 8.0, dz / h x 12). PJ-R1 to PJ-R3 are the target, PJ-I1 the life, PJ-I2 the survives flag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:eye_of_ender".
 01 WS-KIND                BINARY-LONG VALUE 5.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TX L-TY L-TZ L-SURVIVES L-OWNER L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 L-OWNER L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     COMPUTE WS-DX = L-TX - L-X
     COMPUTE WS-DZ = L-TZ - L-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     MOVE L-TX TO PJ-R1(WS-SLOT)
     MOVE L-TY TO PJ-R2(WS-SLOT)
     MOVE L-TZ TO PJ-R3(WS-SLOT)
     IF WS-H > 12
         COMPUTE PJ-R1(WS-SLOT) = L-X + WS-DX / WS-H * 12
         COMPUTE PJ-R2(WS-SLOT) = L-Y + 8.0
         COMPUTE PJ-R3(WS-SLOT) = L-Z + WS-DZ / WS-H * 12
     END-IF
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE L-SURVIVES TO PJ-I2(WS-SLOT)
*>   EnderEyeItem.use: the eye is not a Projectile, so the item posts projectile_shoot itself, at the spawn position with the player as the source (30-8 14.2.1)
     CALL "GAME-EVENT-SHOOT" USING L-ROW L-OWNER
     GOBACK.
 END PROGRAM EYE-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EYE-STEP.
*> USING tracker row: one tick (21 section 8.12): newPos = position + velocity, the velocity update toward the target, the move, life + 1; above 80 the eye is discarded and
*> either dropped as an ender_eye item (survives) or shattered (level event 2003).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:ender_eye".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-HS                  FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-DIR                 FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-ONE-ZERO            BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-DROP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 2003.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-SURVIVES            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     COMPUTE WS-NX = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-NY = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE WS-NZ = EN-Z(L-ROW) + EN-VZ(L-ROW)
     COMPUTE WS-DX = PJ-R1(WS-SLOT) - WS-NX
     COMPUTE WS-DZ = PJ-R3(WS-SLOT) - WS-NZ
     COMPUTE WS-L = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-HS = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     COMPUTE WS-S = WS-HS + 0.0025 * (WS-L - WS-HS)
     MOVE EN-VY(L-ROW) TO WS-VY
     IF WS-L < 1
         COMPUTE WS-S = WS-S * 0.8
         COMPUTE WS-VY = WS-VY * 0.8
     END-IF
     COMPUTE WS-DIR = -1
     IF WS-NY - EN-VY(L-ROW) < PJ-R2(WS-SLOT)
         COMPUTE WS-DIR = 1
     END-IF
     MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW)
     IF WS-L > 0
         COMPUTE EN-VX(L-ROW) = WS-DX * (WS-S / WS-L)
         COMPUTE EN-VZ(L-ROW) = WS-DZ * (WS-S / WS-L)
     END-IF
     COMPUTE EN-VY(L-ROW) = WS-VY + (WS-DIR - WS-VY) * 0.015
     MOVE WS-NX TO EN-X(L-ROW)
     MOVE WS-NY TO EN-Y(L-ROW)
     MOVE WS-NZ TO EN-Z(L-ROW)
     CALL "THROWN-SYNC" USING L-ROW
     ADD 1 TO PJ-I1(WS-SLOT)
     IF PJ-I1(WS-SLOT) > 80
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE PJ-I2(WS-SLOT) TO WS-SURVIVES
         COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
         IF WS-SURVIVES = 1
             CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
             CALL "GI-SPAWN" USING WS-DIM EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-ZERO WS-ZERO2 WS-ZERO3 WS-ITEM WS-ONE-ZERO WS-DELAY WS-DROP
         ELSE
             CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT WS-CX WS-CY WS-CZ WS-NONE WS-NONE2
         END-IF
         CALL "PJ-DROP" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM EYE-STEP.
