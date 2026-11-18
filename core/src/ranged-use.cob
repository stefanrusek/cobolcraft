*> Bows, crossbows and tridents through the play path (docs/protocol/17 sections 3.9 and 3.10, 5.1, 6.3; 25 part 7 sections 7 and 9; lane 002-lane-p46e, T27010 and on).
*> Use Item (0x43, main hand) starts the use of a bow (when ammunition exists or the player has infinite materials), a crossbow (charging, or firing when it is charged)
*> or a trident (when the next point of damage would not break it); the start tick is kept in TS-USE-START of CTOOLS.cpy. Player Action RELEASE_USE_ITEM (6) ends
*> the use: a bow shoots by the power of the ticks used, a trident is thrown after 10 ticks, a crossbow only stops charging (loading is done by the tick, ranged-cross.cob).
*> The arrow is a tracker row of arrows.cob (ARROW-SPAWN); its extra state is the EN-ARR-* fields of CORESTATE.cpy. The shooter's own motion that vanilla adds to the
*> arrow's velocity is not modelled (the server does not track a player's velocity); the sounds and the item_used statistic are not sent.
*>
*>   RANGED-IS-AMMO USING item key (PIC X(48)), crossbow (1: a firework rocket counts), ok out
*>   RANGED-AMMO USING player row, crossbow, where out (0 none, 1 off hand, 2 inventory slot, 3 the plain arrow of a creative player), slot out (1 based), item out
*>   RANGED-ENCHANT USING stack patch handle, enchantment key (PIC X(112)), level out
*>   RANGED-DIRECTION USING yaw, pitch (FLOAT-SHORT degrees), angle about the up vector (FLOAT-LONG degrees), dx dy dz out (unit look vector, FLOAT-LONG)
*>   RANGED-VELOCITY USING dx dy dz, speed, inaccuracy (FLOAT-LONG), vx vy vz out: (the unit direction + each component triangle(0, 0.0172275 x inaccuracy)) x speed
*>   RANGED-TAKE-AMMO USING player row, where, slot: one item of that ammunition is used up
*>   RANGED-ARROW-SHOT USING player row, ammo item, speed (thousandths), angle (degrees), crit, base damage (thousandths), pickup mode, pierce, punch, flame, row out:
*>     the arrow entity of one shot from the player's eye along the look direction turned by the angle
*>   RANGED-ITEM-USE USING connection id, PLAY-SERVERBOUND, done out    Use Item with a bow, crossbow or trident in the main hand
*>   RANGED-RELEASE USING player row                                    Player Action 6
*>   RANGED-BOW-SHOOT USING player row, ticks used

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-IS-AMMO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-CROSSBOW             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CROSSBOW L-OK.
     MOVE 0 TO L-OK
     IF L-KEY = "arrow" OR "tipped_arrow" OR "spectral_arrow"
         MOVE 1 TO L-OK
     END-IF
     IF L-KEY = "firework_rocket" AND L-CROSSBOW = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM RANGED-IS-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-AMMO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-KEY                 PIC X(48).
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ARROW-KEY           PIC X(112) VALUE "minecraft:arrow".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CROSSBOW             BINARY-LONG.
 01 L-WHERE                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CROSSBOW L-WHERE L-SLOT L-ITEM.
     MOVE 0 TO L-WHERE L-SLOT L-ITEM
*>   getProjectile (25 part 7 section 9.1): the off hand first (the main hand holds the weapon), then the inventory in slot order.
     IF MN-EQUIP-COUNT(L-ROW, 5) > 0
         CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(L-ROW, 5) WS-KEY
         CALL "RANGED-IS-AMMO" USING WS-KEY L-CROSSBOW WS-OK
         IF WS-OK = 1
             MOVE 1 TO L-WHERE
             MOVE MN-EQUIP-ITEM(L-ROW, 5) TO L-ITEM
         END-IF
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36 OR L-WHERE > 0
         IF PL-SLOT-COUNT(L-ROW, WS-I) > 0
             CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, WS-I) WS-KEY
             CALL "RANGED-IS-AMMO" USING WS-KEY WS-ZERO WS-OK
             IF WS-OK = 1
                 MOVE 2 TO L-WHERE
                 MOVE WS-I TO L-SLOT
                 MOVE PL-SLOT-ITEM(L-ROW, WS-I) TO L-ITEM
             END-IF
         END-IF
     END-PERFORM
     IF L-WHERE = 0 AND PL-MODE(L-ROW) = 1
         MOVE 3 TO L-WHERE
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ARROW-KEY L-ITEM WS-ITEM-ROW WS-STATUS
     END-IF
     GOBACK.
 END PROGRAM RANGED-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ENCHANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-KEY L-LEVEL.
     MOVE 0 TO L-LEVEL
     CALL "TOOL-ENCHANT-ID" USING L-KEY WS-ID
     IF WS-ID >= 0
         CALL "SP-ENCHANT-LEVEL" USING L-HANDLE WS-ID L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM RANGED-ENCHANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-DIRECTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-UX                  FLOAT-LONG.
 01 WS-UY                  FLOAT-LONG.
 01 WS-UZ                  FLOAT-LONG.
 01 WS-CROSS-X             FLOAT-LONG.
 01 WS-CROSS-Y             FLOAT-LONG.
 01 WS-CROSS-Z             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-DEGREES              FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-DEGREES L-DX L-DY L-DZ.
     COMPUTE WS-YAW = L-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = L-PITCH * FUNCTION PI / 180
     COMPUTE WS-ANGLE = L-DEGREES * FUNCTION PI / 180
*>   The view vector (yaw 0 faces +z, a positive pitch looks down) and the up vector of the same view (the view vector at pitch - 90).
     COMPUTE WS-FX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-FY = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-FZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-UX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION SIN(WS-PITCH)
     COMPUTE WS-UY = FUNCTION COS(WS-PITCH)
     COMPUTE WS-UZ = FUNCTION COS(WS-YAW) * FUNCTION SIN(WS-PITCH)
*>   Turned about the up vector u by the angle (u is perpendicular to the view vector f): f cos a + (u x f) sin a.
     COMPUTE WS-CROSS-X = WS-UY * WS-FZ - WS-UZ * WS-FY
     COMPUTE WS-CROSS-Y = WS-UZ * WS-FX - WS-UX * WS-FZ
     COMPUTE WS-CROSS-Z = WS-UX * WS-FY - WS-UY * WS-FX
     COMPUTE L-DX = WS-FX * FUNCTION COS(WS-ANGLE) + WS-CROSS-X * FUNCTION SIN(WS-ANGLE)
     COMPUTE L-DY = WS-FY * FUNCTION COS(WS-ANGLE) + WS-CROSS-Y * FUNCTION SIN(WS-ANGLE)
     COMPUTE L-DZ = WS-FZ * FUNCTION COS(WS-ANGLE) + WS-CROSS-Z * FUNCTION SIN(WS-ANGLE)
     GOBACK.
 END PROGRAM RANGED-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-VELOCITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                BINARY-LONG VALUE 6101.
 01 WS-BOUND               BINARY-LONG VALUE 1000000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-INACCURACY           FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-SPEED L-INACCURACY L-VX L-VY L-VZ.
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     COMPUTE WS-NX = L-DX / WS-LEN
     COMPUTE WS-NY = L-DY / WS-LEN
     COMPUTE WS-NZ = L-DZ / WS-LEN
     COMPUTE WS-SPREAD = 0.0172275 * L-INACCURACY
*>   RandomSource.triangle(0, spread) = spread x (nextDouble - nextDouble), once for each component (17 section 3.9).
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VX = (WS-NX + WS-SPREAD * (WS-A - WS-B) / 1000000) * L-SPEED
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VY = (WS-NY + WS-SPREAD * (WS-A - WS-B) / 1000000) * L-SPEED
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VZ = (WS-NZ + WS-SPREAD * (WS-A - WS-B) / 1000000) * L-SPEED
     GOBACK.
 END PROGRAM RANGED-VELOCITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-TAKE-AMMO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT0               BINARY-LONG.
 01 WS-MENU-SLOT           BINARY-LONG VALUE 45.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WHERE                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WHERE L-SLOT.
     EVALUATE L-WHERE
         WHEN 1
             SUBTRACT 1 FROM MN-EQUIP-COUNT(L-ROW, 5)
             IF MN-EQUIP-COUNT(L-ROW, 5) = 0
                 MOVE 0 TO MN-EQUIP-ITEM(L-ROW, 5) MN-EQUIP-VAR(L-ROW, 5)
             END-IF
             IF MN-WINDOW(L-ROW) = 0
                 CALL "MENU-SLOT-SEND" USING PL-CONN(L-ROW) WS-MENU-SLOT
             END-IF
         WHEN 2
             COMPUTE WS-SLOT0 = L-SLOT - 1
             CALL "INV-REMOVE" USING L-ROW WS-SLOT0 WS-ONE
             CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-SLOT0
     END-EVALUATE
     GOBACK.
 END PROGRAM RANGED-TAKE-AMMO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ARROW-SHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-INACCURACY          FLOAT-LONG VALUE 1.0.
 01 WS-DEGREES             FLOAT-LONG.
 01 WS-ARROW-ROW           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMMO                 BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-ANGLE                BINARY-LONG.
 01 L-CRIT                 BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-PIERCE               BINARY-LONG.
 01 L-PUNCH                BINARY-LONG.
 01 L-FLAME                BINARY-LONG.
 01 L-ARROW                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMMO L-SPEED L-ANGLE L-CRIT L-BASE L-PICKUP L-PIERCE L-PUNCH L-FLAME L-ARROW.
     MOVE L-ANGLE TO WS-DEGREES
     CALL "RANGED-DIRECTION" USING PL-YAW(L-ROW) PL-PITCH(L-ROW) WS-DEGREES WS-DX WS-DY WS-DZ
     COMPUTE WS-SPEED = L-SPEED / 1000
     CALL "RANGED-VELOCITY" USING WS-DX WS-DY WS-DZ WS-SPEED WS-INACCURACY WS-VX WS-VY WS-VZ
*>   A projectile spawned by a player starts at the eye less 0.1 (the eye is 1.62 above the feet).
     MOVE PL-X(L-ROW) TO WS-X
     COMPUTE WS-Y = PL-Y(L-ROW) + 1.62 - 0.1
     MOVE PL-Z(L-ROW) TO WS-Z
     CALL "ARROW-SPAWN" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ L-BASE PL-ENTITY-ID(L-ROW) WS-ARROW-ROW
     MOVE L-CRIT TO EN-ARR-CRIT(WS-ARROW-ROW)
     MOVE L-PIERCE TO EN-ARR-PIERCE(WS-ARROW-ROW)
     MOVE L-PUNCH TO EN-ARR-PUNCH(WS-ARROW-ROW)
     MOVE L-PICKUP TO EN-ARR-PICKUP(WS-ARROW-ROW)
     MOVE L-AMMO TO EN-ARR-ITEM(WS-ARROW-ROW)
     IF L-FLAME = 1
         MOVE 100 TO EN-BURN(WS-ARROW-ROW)
     END-IF
     MOVE WS-ARROW-ROW TO L-ARROW
     GOBACK.
 END PROGRAM RANGED-ARROW-SHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-BOW-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-POWER-LEVEL         BINARY-LONG.
 01 WS-PUNCH-LEVEL         BINARY-LONG.
 01 WS-FLAME-LEVEL         BINARY-LONG.
 01 WS-INF-LEVEL           BINARY-LONG.
 01 WS-INFINITE            BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-SHOOTS              BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-CRIT                BINARY-LONG.
 01 WS-WHERE               BINARY-LONG.
 01 WS-AMMO-SLOT           BINARY-LONG.
 01 WS-AMMO                BINARY-LONG.
 01 WS-AMMO-KEY            PIC X(48).
 01 WS-ARROW-ITEM          PIC X(48) VALUE "arrow".
 01 WS-POWER               BINARY-LONG.
 01 WS-VELOCITY            BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-PICKUP              BINARY-LONG.
 01 WS-ANGLE               BINARY-LONG VALUE 0.
 01 WS-NO-PIERCE           BINARY-LONG VALUE 0.
 01 WS-ARROW               BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG VALUE 0.
 01 WS-BROKE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-HANDLE
     MOVE PL-MODE(L-ROW) TO WS-CREATIVE
     CALL "RANGED-AMMO" USING L-ROW WS-CROSSBOW WS-WHERE WS-AMMO-SLOT WS-AMMO
     IF WS-WHERE = 0
         GOBACK
     END-IF
     IF WS-WHERE = 1
         CALL "TOOLUSE-KEY" USING MN-EQUIP-ITEM(L-ROW, 5) WS-AMMO-KEY
     ELSE
         CALL "TOOLUSE-KEY" USING WS-AMMO WS-AMMO-KEY
     END-IF
     MOVE "minecraft:infinity" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-INF-LEVEL
*>   Infinity's ammo_use effect matches only the item arrow itself (tipped and spectral arrows are used up).
     MOVE 0 TO WS-INFINITE
     IF WS-INF-LEVEL > 0 AND WS-AMMO-KEY = WS-ARROW-ITEM
         MOVE 1 TO WS-INFINITE
     END-IF
     CALL "TOOL-BOW-SHOT" USING L-TICKS WS-INFINITE WS-CREATIVE WS-SHOOTS WS-CONSUMED WS-DURABILITY WS-CRIT
     IF WS-SHOOTS = 0
         GOBACK
     END-IF
     CALL "TOOL-BOW-POWER" USING L-TICKS WS-POWER WS-VELOCITY
     MOVE "minecraft:power" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-POWER-LEVEL
     MOVE "minecraft:punch" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-PUNCH-LEVEL
     MOVE "minecraft:flame" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-FLAME-LEVEL
*>   Base damage 2.0, Power adds 1 + 0.5 (L - 1) (17 section 6.3); the arrow of a spent-free shot can only be picked up by a creative player.
     MOVE 2000 TO WS-BASE
     IF WS-POWER-LEVEL > 0
         COMPUTE WS-BASE = 2000 + 1000 + 500 * (WS-POWER-LEVEL - 1)
     END-IF
     MOVE 1 TO WS-PICKUP
     IF WS-CONSUMED = 0
         MOVE 2 TO WS-PICKUP
     END-IF
     IF WS-FLAME-LEVEL > 0
         MOVE 1 TO WS-FLAME-LEVEL
     END-IF
     IF WS-CONSUMED = 1
         CALL "RANGED-TAKE-AMMO" USING L-ROW WS-WHERE WS-AMMO-SLOT
     END-IF
     MOVE 0 TO WS-ARROW
     CALL "RANGED-ARROW-SHOT" USING L-ROW WS-AMMO WS-VELOCITY WS-ANGLE WS-CRIT WS-BASE WS-PICKUP WS-NO-PIERCE WS-PUNCH-LEVEL
         WS-FLAME-LEVEL WS-ARROW
     MOVE PL-HELD(L-ROW) TO WS-HELD
     CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) WS-HELD WS-DURABILITY WS-BROKE
     GOBACK.
 END PROGRAM RANGED-BOW-SHOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-USED                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "COMBAT-TS-CHECK" USING L-ROW
     IF TS-USE-START(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-USED = CW-TICKS + 1 - TS-USE-START(L-ROW)
     MOVE TS-USE-ITEM(L-ROW) TO WS-ITEM
     MOVE 0 TO TS-USE-START(L-ROW) TS-USE-ITEM(L-ROW)
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
*>   Changing the held slot ends a use: the item in the hand must be the one that was used.
     IF PL-SLOT-COUNT(L-ROW, WS-SLOT) = 0 OR PL-SLOT-ITEM(L-ROW, WS-SLOT) NOT = WS-ITEM
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING WS-ITEM WS-KEY
     EVALUATE WS-KEY
         WHEN "bow"
             CALL "RANGED-BOW-SHOOT" USING L-ROW WS-USED
         WHEN "trident"
             CALL "RANGED-TRIDENT-THROW" USING L-ROW WS-USED
     END-EVALUATE
     GOBACK.
 END PROGRAM RANGED-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-WHERE               BINARY-LONG.
 01 WS-AMMO-SLOT           BINARY-LONG.
 01 WS-AMMO                BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR PSB-HAND NOT = 0 OR MN-WINDOW(WS-ROW) NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     CALL "COMBAT-TS-CHECK" USING WS-ROW
     EVALUATE WS-KEY
         WHEN "bow"
             CALL "RANGED-AMMO" USING WS-ROW WS-CROSSBOW WS-WHERE WS-AMMO-SLOT WS-AMMO
             IF WS-WHERE > 0
                 COMPUTE TS-USE-START(WS-ROW) = CW-TICKS + 1
                 MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT) TO TS-USE-ITEM(WS-ROW)
                 MOVE 1 TO L-DONE
             END-IF
         WHEN "crossbow"
             CALL "RANGED-CROSSBOW-USE" USING WS-ROW L-DONE
         WHEN "trident"
             CALL "RANGED-TRIDENT-USE" USING WS-ROW L-DONE
     END-EVALUATE
     GOBACK.
 END PROGRAM RANGED-ITEM-USE.
