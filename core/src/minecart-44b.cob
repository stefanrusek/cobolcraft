*> Minecart riding, hurting and pushing (docs/protocol/44 part 8 sections 4.4.3, 4.6, 2, 5; lane 002-lane-mobsb8, T9720), PJ-KIND 10 (minecart-44.cob): PJ-I1 the kind, PJ-I4 hurt time, PJ-I5 hurt direction,
*> PJ-R3 the damage. The rider is a player row (EN-RIDER of the cart, EN-VEHICLE of the player's entity), taken to the seat by MINECART-SYNC.
*> Gaps: chest and hopper carts have no contents or menu (no entity container menu exists), spawner and command block carts run nothing, a mob does not board a fast cart (EN-RIDER is a player row)
*> and a plain entity is not pushed by the moving cart (only carts are), a player is not pushed, the item stack's components and a loot table, the hurt metadata.
*>
*>   MINECART-USE USING player row, cart row, used out: a standing player boards a plain minecart without a passenger
*>   MINECART-SYNC USING cart row: the rider at the seat (y + 0.1875 less 0.6)
*>   MINECART-HURT USING cart row, amount (points), attacker player row (0 none), handled out: hurt time 10, damage + amount x 10, break above 40 or at once for a creative player
*>   MINECART-PUSH USING pushed cart row, pusher entity row: AbstractMinecart.push(entity) and pushOtherMinecart
*>   MINECART-ENTITIES USING cart row: the carts in the box inflated by (0.2, 0, 0.2) are pushed by this cart

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-SYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RIDER               BINARY-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-RIDER(L-ROW) TO WS-RIDER
     IF WS-RIDER > 0
         MOVE EN-X(L-ROW) TO PL-X(WS-RIDER)
         COMPUTE PL-Y(WS-RIDER) = EN-Y(L-ROW) + 0.1875 - 0.6
         MOVE EN-Z(L-ROW) TO PL-Z(WS-RIDER)
         CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-RIDER) PL-X(WS-RIDER) PL-Y(WS-RIDER) PL-Z(WS-RIDER)
             PL-YAW(WS-RIDER) PL-PITCH(WS-RIDER) WS-GROUND
     END-IF
     GOBACK.
 END PROGRAM MINECART-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-USED.
     MOVE 0 TO L-USED
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-KIND(WS-SLOT) NOT = 10 OR PJ-I1(WS-SLOT) NOT = 1
         GOBACK
     END-IF
     IF PL-SNEAKING(L-PLAYER) = 0 AND EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) = 0 AND EN-RIDER(L-ROW) = 0
         MOVE L-PLAYER TO EN-RIDER(L-ROW)
         MOVE L-ROW TO EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER))
         CALL "MINECART-SYNC" USING L-ROW
         CALL "MOB-RIDE-SEND" USING L-ROW
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM MINECART-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-HURT-SRC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SPEED2              FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9112.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-IGNITES              BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-ATTACKER L-IGNITES L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-KIND(WS-SLOT) NOT = 10
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     COMPUTE PJ-I5(WS-SLOT) = 0 - PJ-I5(WS-SLOT)
     MOVE 10 TO PJ-I4(WS-SLOT)
     COMPUTE PJ-R3(WS-SLOT) = PJ-R3(WS-SLOT) + L-AMOUNT * 10
     MOVE 0 TO WS-CREATIVE
     IF L-ATTACKER > 0
         IF PL-MODE(L-ATTACKER) = 1
             MOVE 1 TO WS-CREATIVE
         END-IF
     END-IF
*>   shouldSourceDestroy (2 step 6): only the TNT cart overrides it, with the ignition test of the source.
     IF WS-CREATIVE = 0 AND PJ-R3(WS-SLOT) <= 40 AND (PJ-I1(WS-SLOT) NOT = 5 OR L-IGNITES = 0)
         GOBACK
     END-IF
*>   The TNT cart's destroy (4.6): an igniting source, or a horizontal speed squared of 0.01 or more, primes a cart that is not yet primed (fuse nextInt(20) + nextInt(20)) and the cart stays.
     IF WS-CREATIVE = 0 AND PJ-I1(WS-SLOT) = 5
         COMPUTE WS-SPEED2 = EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW)
         IF L-IGNITES = 1 OR WS-SPEED2 >= 0.01
             IF PJ-I3(WS-SLOT) < 0
                 CALL "MINECART-PRIME" USING L-ROW
                 CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R1
                 CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R2
                 COMPUTE PJ-I3(WS-SLOT) = WS-R1 + WS-R2
             END-IF
             GOBACK
         END-IF
     END-IF
     IF EN-RIDER(L-ROW) > 0
         CALL "MOB-RIDE-STOP" USING L-ROW
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE PJ-I1(WS-SLOT) TO WS-KIND
     CALL "PJ-DROP" USING L-ROW
     IF WS-CREATIVE = 0
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE NOT = 0
             EVALUATE WS-KIND
                 WHEN 2
                     MOVE "minecraft:chest_minecart" TO WS-KEY
                 WHEN 3
                     MOVE "minecraft:hopper_minecart" TO WS-KEY
                 WHEN 4
                     MOVE "minecraft:furnace_minecart" TO WS-KEY
                 WHEN 5
                     MOVE "minecraft:tnt_minecart" TO WS-KEY
                 WHEN 7
                     MOVE "minecraft:command_block_minecart" TO WS-KEY
                 WHEN OTHER
                     MOVE "minecraft:minecart" TO WS-KEY
             END-EVALUATE
             CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
             CALL "DECOR-DROP" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MINECART-HURT-SRC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-HURT.
*> USING cart row, amount (points), attacker player row (0 none), handled out: MINECART-HURT-SRC for a source that does not ignite TNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IGNITES             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-ATTACKER L-HANDLED.
     CALL "MINECART-HURT-SRC" USING L-ROW L-AMOUNT L-ATTACKER WS-IGNITES L-HANDLED
     GOBACK.
 END PROGRAM MINECART-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-PUSH-OTHER.
*> USING this cart row, other cart row, dx, dz (FLOAT-LONG): pushOtherMinecart of 44 part 8 section 4.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OSLOT               BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-ALIGN               FLOAT-LONG.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-OTHER L-DX L-DZ.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "PJ-FIND" USING EN-ID(L-OTHER) WS-OSLOT
     COMPUTE WS-AX = EN-X(L-OTHER) - EN-X(L-ROW)
     COMPUTE WS-AZ = EN-Z(L-OTHER) - EN-Z(L-ROW)
     COMPUTE WS-L = FUNCTION SQRT(WS-AX * WS-AX + WS-AZ * WS-AZ)
     IF WS-L = 0
         GOBACK
     END-IF
     COMPUTE WS-RAD = EN-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE WS-ALIGN = FUNCTION ABS((WS-AX * FUNCTION COS(WS-RAD) + WS-AZ * FUNCTION SIN(WS-RAD)) / WS-L)
     IF WS-ALIGN < 0.8
         GOBACK
     END-IF
     MOVE EN-VX(L-ROW) TO WS-MX
     MOVE EN-VZ(L-ROW) TO WS-MZ
     MOVE EN-VX(L-OTHER) TO WS-TX
     MOVE EN-VZ(L-OTHER) TO WS-TZ
     EVALUATE TRUE
         WHEN PJ-I1(WS-OSLOT) = 4 AND PJ-I1(WS-SLOT) NOT = 4
             COMPUTE EN-VX(L-ROW) = WS-MX * 0.2 + WS-TX - L-DX
             COMPUTE EN-VZ(L-ROW) = WS-MZ * 0.2 + WS-TZ - L-DZ
             COMPUTE EN-VX(L-OTHER) = WS-TX * 0.95
             COMPUTE EN-VZ(L-OTHER) = WS-TZ * 0.95
         WHEN PJ-I1(WS-SLOT) = 4 AND PJ-I1(WS-OSLOT) NOT = 4
             COMPUTE EN-VX(L-OTHER) = WS-TX * 0.2 + WS-MX + L-DX
             COMPUTE EN-VZ(L-OTHER) = WS-TZ * 0.2 + WS-MZ + L-DZ
             COMPUTE EN-VX(L-ROW) = WS-MX * 0.95
             COMPUTE EN-VZ(L-ROW) = WS-MZ * 0.95
         WHEN OTHER
             COMPUTE WS-VX = (WS-TX + WS-MX) / 2
             COMPUTE WS-VZ = (WS-TZ + WS-MZ) / 2
             COMPUTE EN-VX(L-ROW) = WS-MX * 0.2 + WS-VX - L-DX
             COMPUTE EN-VZ(L-ROW) = WS-MZ * 0.2 + WS-VZ - L-DZ
             COMPUTE EN-VX(L-OTHER) = WS-TX * 0.2 + WS-VX + L-DX
             COMPUTE EN-VZ(L-OTHER) = WS-TZ * 0.2 + WS-VZ + L-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM MINECART-PUSH-OTHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-PUSH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-OSLOT               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OTHER.
     COMPUTE WS-DX = EN-X(L-OTHER) - EN-X(L-ROW)
     COMPUTE WS-DZ = EN-Z(L-OTHER) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
     IF WS-D2 < 0.0001
         GOBACK
     END-IF
     COMPUTE WS-D = FUNCTION SQRT(WS-D2)
     COMPUTE WS-S = FUNCTION MIN(1 / WS-D, 1)
     COMPUTE WS-DX = WS-DX / WS-D * WS-S * 0.05
     COMPUTE WS-DZ = WS-DZ / WS-D * WS-S * 0.05
     CALL "PJ-FIND" USING EN-ID(L-OTHER) WS-OSLOT
     IF WS-OSLOT > 0 AND PJ-KIND(WS-OSLOT) = 10
         CALL "MINECART-PUSH-OTHER" USING L-ROW L-OTHER WS-DX WS-DZ
     ELSE
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - WS-DX
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) - WS-DZ
         COMPUTE EN-VX(L-OTHER) = EN-VX(L-OTHER) + WS-DX / 4
         COMPUTE EN-VZ(L-OTHER) = EN-VZ(L-OTHER) + WS-DZ / 4
     END-IF
     GOBACK.
 END PROGRAM MINECART-PUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MINECART-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             CALL "PJ-FIND" USING EN-ID(WS-E) WS-SLOT
             IF WS-SLOT > 0
                 IF PJ-KIND(WS-SLOT) = 10
                     IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) <= 1.18 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) <= 1.18
                             AND FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW)) < 0.7
                         CALL "MINECART-PUSH" USING WS-E L-ROW
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MINECART-ENTITIES.
