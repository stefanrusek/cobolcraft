*> The trident (docs/protocol/17 section 3.10, 5.1, 6.3; 25 part 7 section 7; lane 002-lane-p46e, T27013). Use Item with a trident starts the use unless the next point of damage
*> would break it or Riptide is on it and the player is neither in water nor under open rain. Player Action 6 after at least 10 ticks of use (TOOL-TRIDENT-RELEASE) throws it
*> without Riptide: the trident takes 1 durability (hurtWithoutBreaking), leaves the hand (a creative player keeps it) and flies as a tracker row of the type trident at velocity
*> 2.5 with the 1.0 inaccuracy, the owner and the pickup mode (1, or 2 for a creative thrower) in the EN-ARR-* fields, the stack (damage, enchantments) behind EN-TR-VAR and EN-IS-TRIDENT 1.
*> The flight is ARROW-STEP of arrows.cob (gravity 0.05, drag 0.99 in air and water): the hit (TRIDENT-HIT) does 8.0, plus 2.5 per Impaling level against the aquatic mobs
*> of 17 section 6.3, whatever the speed, once (EN-TR-DEALT), then the trident is deflected (its velocity times (-0.02, -0.2, -0.02): section 3.10 gives the vector (0.02, 0.2, 0.02) for
*> the reversing deflection), and after 4 ticks stuck in a block it counts as having dealt damage too. A trident with Loyalty L that has dealt damage flies home without collisions
*> (EN-ON-GROUND 2: TRIDENT-RETURN, the velocity x 0.95 plus the unit vector to the owner's eye x 0.05 L, the height raised by 0.015 L of the vertical distance); a stuck or returned
*> trident is picked up by a player that touches it after 7 ticks (TRIDENT-PICKUP, with its damage; mode 2 only creative players; the owner gone or dead: it drops as an item).
*> With Riptide in water or rain the release launches the player along the look vector by 1.5 + 0.75 (L - 1) (Set Entity Motion), 1 durability, no throw, and a spin of 20 ticks in
*> which every mob touching the player's box takes 8.0 (RANGED-SPIN, the hurt window of the mob lets one hit through). Not done: Channeling's lightning, the sounds, moving a
*> grounded player up 1.2 blocks (the client moves the player), the damage type trident of the death message (CAUSE-ARROW stands in), the Loyalty void rule.
*>
*>   RANGED-WET USING player row, wet out                    1 in water or under open rain
*>   RANGED-TRIDENT-USE USING player row, done out
*>   RANGED-TRIDENT-THROW USING player row, ticks used      the release
*>   TRIDENT-SPAWN USING player row, item, stack handle, row out
*>   TRIDENT-HIT USING trident row, entity row, player row (one of the last two 0)
*>   TRIDENT-RETURN USING trident row                       one tick of the flight home
*>   TRIDENT-PICKUP USING trident row                       a player touching a stuck or returning trident
*>   RANGED-SPIN USING player row                           one tick of a Riptide spin

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-WET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RAIN                BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 1800.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WET.
     CALL "FLUID-TOUCHES-WATER" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) L-WET
     IF L-WET = 0
         CALL "WEATHER-RAINING" USING PL-DIM(L-ROW) WS-RAIN
         IF WS-RAIN = 1
             CALL "WEATHER-EXPOSED" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-HEIGHT L-WET
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RANGED-WET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-TRIDENT-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-RIPTIDE             BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 0 TO L-DONE
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-HANDLE
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(L-ROW, WS-SLOT) WS-HANDLE WS-DAMAGE
     CALL "SP-GET-MAX-DAMAGE" USING PL-SLOT-ITEM(L-ROW, WS-SLOT) WS-HANDLE WS-MAX
*>   TridentItem.use: the next point of damage must not break it, and Riptide needs water or rain.
     IF WS-DAMAGE + 1 >= WS-MAX
         GOBACK
     END-IF
     MOVE "minecraft:riptide" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-RIPTIDE
     CALL "RANGED-WET" USING L-ROW WS-WET
     IF WS-RIPTIDE > 0 AND WS-WET = 0
         GOBACK
     END-IF
     COMPUTE TS-USE-START(L-ROW) = CW-TICKS + 1
     MOVE PL-SLOT-ITEM(L-ROW, WS-SLOT) TO TS-USE-ITEM(L-ROW)
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM RANGED-TRIDENT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIDENT-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:trident".
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-SPEED               FLOAT-LONG VALUE 2.5.
 01 WS-INACCURACY          FLOAT-LONG VALUE 1.0.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-HANDLE L-NEW.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW WS-STATUS
     CALL "RANGED-DIRECTION" USING PL-YAW(L-ROW) PL-PITCH(L-ROW) WS-ZERO WS-DX WS-DY WS-DZ
     CALL "RANGED-VELOCITY" USING WS-DX WS-DY WS-DZ WS-SPEED WS-INACCURACY WS-VX WS-VY WS-VZ
     CALL "ENTITY-ALLOC" USING WS-NEW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-NEW)
     MOVE WS-TYPE TO EN-TYPE(WS-NEW)
     CALL "ENTITY-SET-UUID" USING WS-NEW
     MOVE PL-DIM(L-ROW) TO EN-DIM(WS-NEW)
     MOVE PL-X(L-ROW) TO EN-X(WS-NEW) EN-WAY-X(WS-NEW)
     COMPUTE EN-Y(WS-NEW) = PL-Y(L-ROW) + 1.62 - 0.1
     MOVE EN-Y(WS-NEW) TO EN-FLEE-X(WS-NEW)
     MOVE PL-Z(L-ROW) TO EN-Z(WS-NEW) EN-WAY-Z(WS-NEW)
     MOVE WS-VX TO EN-VX(WS-NEW)
     MOVE WS-VY TO EN-VY(WS-NEW)
     MOVE WS-VZ TO EN-VZ(WS-NEW)
     MOVE PL-ENTITY-ID(L-ROW) TO EN-TARGET-ID(WS-NEW)
     MOVE L-ITEM TO EN-ITEM(WS-NEW)
     MOVE L-HANDLE TO EN-TR-VAR(WS-NEW)
     MOVE 1 TO EN-IS-TRIDENT(WS-NEW) EN-ARR-PICKUP(WS-NEW)
     IF PL-MODE(L-ROW) = 1
         MOVE 2 TO EN-ARR-PICKUP(WS-NEW)
     END-IF
     MOVE "minecraft:loyalty" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING L-HANDLE WS-LEVEL-KEY EN-TR-LOYALTY(WS-NEW)
     MOVE EN-YAW(L-ROW) TO EN-YAW(WS-NEW)
     COMPUTE WS-H = FUNCTION SQRT(WS-VX * WS-VX + WS-VZ * WS-VZ)
     IF WS-VZ = 0
         MOVE 90 TO EN-YAW(WS-NEW)
         IF WS-VX < 0
             MOVE -90 TO EN-YAW(WS-NEW)
         END-IF
     ELSE
         COMPUTE EN-YAW(WS-NEW) = FUNCTION ATAN(WS-VX / WS-VZ) * 180 / FUNCTION PI
         IF WS-VZ < 0
             COMPUTE EN-YAW(WS-NEW) = EN-YAW(WS-NEW) + 180
         END-IF
     END-IF
     IF WS-H > 0
         COMPUTE EN-PITCH(WS-NEW) = FUNCTION ATAN(WS-VY / WS-H) * 180 / FUNCTION PI
     END-IF
     CALL "ENTITY-TRACK" USING WS-NEW
     MOVE WS-NEW TO L-NEW
     GOBACK.
 END PROGRAM TRIDENT-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-TRIDENT-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-RIPTIDE             BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-RIDING              BINARY-LONG.
 01 WS-BREAKS              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-SPIN                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 COPY CTOOLS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE PL-SLOT-VAR(L-ROW, WS-SLOT) TO WS-HANDLE
     MOVE PL-SLOT-ITEM(L-ROW, WS-SLOT) TO WS-ITEM
     CALL "SP-GET-DAMAGE" USING WS-ITEM WS-HANDLE WS-DAMAGE
     CALL "SP-GET-MAX-DAMAGE" USING WS-ITEM WS-HANDLE WS-MAX
     MOVE 0 TO WS-BREAKS
     IF WS-DAMAGE + 1 >= WS-MAX
         MOVE 1 TO WS-BREAKS
     END-IF
     MOVE "minecraft:riptide" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING WS-HANDLE WS-LEVEL-KEY WS-RIPTIDE
     CALL "RANGED-WET" USING L-ROW WS-WET
     MOVE 0 TO WS-RIDING
     IF EN-VEHICLE(PL-ENTITY-ROW(L-ROW)) > 0
         MOVE 1 TO WS-RIDING
     END-IF
     CALL "TOOL-TRIDENT-RELEASE" USING L-TICKS WS-BREAKS WS-RIPTIDE WS-WET WS-RIDING WS-ACTION WS-DURABILITY WS-STRENGTH
         WS-SPIN
     IF WS-ACTION = 0
         GOBACK
     END-IF
*>   hurtWithoutBreaking(1): the stack is worn (never broken by this call); a creative player takes no damage.
     IF PL-MODE(L-ROW) NOT = 1
         ADD 1 TO WS-DAMAGE
         CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
         MOVE WS-HANDLE TO PL-SLOT-VAR(L-ROW, WS-SLOT)
     END-IF
     IF WS-ACTION = 1
         CALL "TRIDENT-SPAWN" USING L-ROW WS-ITEM WS-HANDLE WS-NEW
         IF PL-MODE(L-ROW) NOT = 1
             CALL "INV-REMOVE" USING L-ROW PL-HELD(L-ROW) WS-ONE
             MOVE PL-HELD(L-ROW) TO WS-HELD
         END-IF
         MOVE PL-HELD(L-ROW) TO WS-HELD
         CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-HELD
     ELSE
*>       Riptide: the look vector scaled to the strength pushes the player; the spin attack runs 20 ticks (the damage 8.0 is RANGED-SPIN's constant).
         CALL "RANGED-DIRECTION" USING PL-YAW(L-ROW) PL-PITCH(L-ROW) WS-ZERO WS-DX WS-DY WS-DZ
         COMPUTE WS-VX = WS-DX * WS-STRENGTH
         COMPUTE WS-VY = WS-DY * WS-STRENGTH
         COMPUTE WS-VZ = WS-DZ * WS-STRENGTH
         CALL "COMBAT-MOTION-SEND" USING L-ROW WS-VX WS-VY WS-VZ
         MOVE 20 TO TS-SPIN-TICKS(L-ROW)
         MOVE PL-HELD(L-ROW) TO WS-HELD
         CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-HELD
     END-IF
     GOBACK.
 END PROGRAM RANGED-TRIDENT-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIDENT-HIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-LEVEL-KEY           PIC X(112).
 01 WS-IMPALING            BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-SENSITIVE           BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-ARROW.
 01 WS-OWNER-ID            BINARY-LONG.
 01 WS-OWNER-PLAYER        BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-HIT-ID              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TRIDENT              BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIDENT L-ENTITY L-PLAYER.
*>   Base damage 8.0; Impaling adds 2.5 a level against the mobs that are sensitive to it (17 section 6.3).
     MOVE 8000 TO WS-AMOUNT
     MOVE 0 TO WS-SENSITIVE
     IF L-PLAYER = 0
         CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
         IF WS-KEY = "turtle" OR "axolotl" OR "guardian" OR "elder_guardian" OR "cod" OR "pufferfish" OR "salmon"
                 OR "tropical_fish" OR "dolphin" OR "squid" OR "glow_squid" OR "tadpole"
             MOVE 1 TO WS-SENSITIVE
         END-IF
     END-IF
     MOVE "minecraft:impaling" TO WS-LEVEL-KEY
     CALL "RANGED-ENCHANT" USING EN-TR-VAR(L-TRIDENT) WS-LEVEL-KEY WS-IMPALING
     IF WS-SENSITIVE = 1
         COMPUTE WS-AMOUNT = WS-AMOUNT + 2500 * WS-IMPALING
     END-IF
     MOVE EN-TARGET-ID(L-TRIDENT) TO WS-OWNER-ID
     MOVE 0 TO WS-OWNER-PLAYER
     PERFORM VARYING WS-O FROM 1 BY 1 UNTIL WS-O > CORE-MAX-PLAYERS
         IF PL-USED(WS-O) = 1 AND PL-ENTITY-ID(WS-O) = WS-OWNER-ID AND WS-OWNER-ID > 0
             MOVE WS-O TO WS-OWNER-PLAYER
         END-IF
     END-PERFORM
     IF L-PLAYER > 0
         CALL "HEALTH-HURT" USING L-PLAYER WS-AMOUNT WS-CAUSE WS-OWNER-ID WS-OWNER-PLAYER WS-RESULT
         MOVE PL-ENTITY-ID(L-PLAYER) TO WS-HIT-ID
     ELSE
         COMPUTE WS-POINTS = FUNCTION INTEGER(WS-AMOUNT / 1000 + 0.5)
         MOVE 0 TO EN-HURT(L-ENTITY)
         CALL "HEALTH-MOB-DAMAGE" USING L-ENTITY WS-POINTS WS-CAUSE WS-OWNER-PLAYER
         MOVE EN-ID(L-ENTITY) TO WS-HIT-ID
     END-IF
*>   The trident has dealt its damage and is deflected: reversed and slowed by the vector (0.02, 0.2, 0.02); the victim cannot be hit again.
     MOVE 1 TO EN-TR-DEALT(L-TRIDENT)
     MOVE 1 TO EN-ARR-NHIT(L-TRIDENT)
     MOVE WS-HIT-ID TO EN-ARR-HIT(L-TRIDENT, 1)
     COMPUTE EN-VX(L-TRIDENT) = EN-VX(L-TRIDENT) * -0.02
     COMPUTE EN-VY(L-TRIDENT) = EN-VY(L-TRIDENT) * -0.2
     COMPUTE EN-VZ(L-TRIDENT) = EN-VZ(L-TRIDENT) * -0.02
     GOBACK.
 END PROGRAM TRIDENT-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIDENT-PICKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-BEFORE.
    05 WS-B-ITEM           BINARY-LONG OCCURS 36 TIMES.
    05 WS-B-COUNT          BINARY-LONG OCCURS 36 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-ARR-PICKUP(L-ROW) = 0 OR EN-AGE(L-ROW) < 7
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS OR WS-DONE = 1
         CALL "GI-IN-REACH" USING WS-PLAYER L-ROW WS-OK
         IF EN-ARR-PICKUP(L-ROW) = 2 AND PL-MODE(WS-PLAYER) NOT = 1
             MOVE 0 TO WS-OK
         END-IF
         IF WS-OK = 1
             PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
                 MOVE PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) TO WS-B-ITEM(WS-SLOT)
                 MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO WS-B-COUNT(WS-SLOT)
             END-PERFORM
*>           IP-INV-ADD counts the stack down: a fresh count for each try.
             MOVE 1 TO WS-COUNT
             CALL "IP-INV-ADD" USING WS-PLAYER EN-ITEM(L-ROW) WS-COUNT EN-TR-VAR(L-ROW) WS-RESULT
             IF WS-RESULT = 1
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(L-ROW) PL-ENTITY-ID(WS-PLAYER) WS-ONE PB-BUFFER
                 CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
                 PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
                     IF PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) NOT = WS-B-ITEM(WS-SLOT)
                             OR PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) NOT = WS-B-COUNT(WS-SLOT)
                         COMPUTE WS-SENT = WS-SLOT - 1
                         CALL "INV-SLOT-SEND" USING PL-CONN(WS-PLAYER) WS-SENT
                     END-IF
                 END-PERFORM
                 CALL "ENTITY-REMOVE" USING L-ROW
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TRIDENT-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIDENT-RETURN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OWNER               BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-RAISE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-OWNER
     PERFORM VARYING WS-O FROM 1 BY 1 UNTIL WS-O > CORE-MAX-PLAYERS
         IF PL-USED(WS-O) = 1 AND PL-ENTITY-ID(WS-O) = EN-TARGET-ID(L-ROW) AND PL-STATE(WS-O) = PS-ALIVE
                 AND PL-DIM(WS-O) = EN-DIM(L-ROW) AND PL-MODE(WS-O) NOT = 3
             MOVE WS-O TO WS-OWNER
         END-IF
     END-PERFORM
*>   An owner that is gone, dead or a spectator (or in another dimension): the trident is discarded and drops its item.
     IF WS-OWNER = 0
         IF EN-ARR-PICKUP(L-ROW) = 1
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET EN-ITEM(L-ROW) WS-ONE
                 EN-TR-VAR(L-ROW) WS-DROPPED
         END-IF
         CALL "ENTITY-REMOVE" USING L-ROW
         GOBACK
     END-IF
     COMPUTE WS-VX ROUNDED = EN-VX(L-ROW) * 1000000
     COMPUTE WS-VY ROUNDED = EN-VY(L-ROW) * 1000000
     COMPUTE WS-VZ ROUNDED = EN-VZ(L-ROW) * 1000000
     COMPUTE WS-TX ROUNDED = (PL-X(WS-OWNER) - EN-X(L-ROW)) * 1000000
     COMPUTE WS-TY ROUNDED = (PL-Y(WS-OWNER) + 1.62 - EN-Y(L-ROW)) * 1000000
     COMPUTE WS-TZ ROUNDED = (PL-Z(WS-OWNER) - EN-Z(L-ROW)) * 1000000
     CALL "TOOL-TRIDENT-RETURN" USING EN-TR-LOYALTY(L-ROW) WS-VX WS-VY WS-VZ WS-TX WS-TY WS-TZ WS-NX WS-NY WS-NZ WS-RAISE
     COMPUTE EN-VX(L-ROW) = WS-NX / 1000000
     COMPUTE EN-VY(L-ROW) = WS-NY / 1000000
     COMPUTE EN-VZ(L-ROW) = WS-NZ / 1000000
     COMPUTE EN-X(L-ROW) = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + WS-RAISE / 1000000 + EN-VY(L-ROW)
     COMPUTE EN-Z(L-ROW) = EN-Z(L-ROW) + EN-VZ(L-ROW)
*>   A returning trident has no physics: it can be picked up at once.
     MOVE 7 TO EN-AGE(L-ROW)
     CALL "TRIDENT-PICKUP" USING L-ROW
     IF EN-USED(L-ROW) = 1
         CALL "ARROW-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM TRIDENT-RETURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RANGED-SPIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CTOOLS.
 COPY RULES.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 8.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SUBTRACT 1 FROM TS-SPIN-TICKS(L-ROW)
*>   doAutoAttackOnTouch: every living mob whose box meets the player's box (0.6 wide, 1.8 high) takes 8.0 (the mob's hurt window lets one hit through).
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-DIM(WS-E) = PL-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-W = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000 + 0.3
                 COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 IF FUNCTION ABS(EN-X(WS-E) - PL-X(L-ROW)) < WS-W AND FUNCTION ABS(EN-Z(WS-E) - PL-Z(L-ROW)) < WS-W
                         AND EN-Y(WS-E) < PL-Y(L-ROW) + 1.8 AND EN-Y(WS-E) + WS-H > PL-Y(L-ROW)
                     CALL "HEALTH-MOB-DAMAGE" USING WS-E WS-AMOUNT WS-CAUSE L-ROW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RANGED-SPIN.
