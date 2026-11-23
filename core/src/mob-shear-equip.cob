*> Shearing equipment off a mob (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.3.1 "Shearing", Mob.attemptToShearEquipment; 25-3 section 5.1 for the
*> items that can be sheared). The held item is the shears, the player does not sneak (secondary use) and the mob is not a vehicle (no passenger of either kind: canShearEquipment). The slots
*> are walked in the order of EquipmentSlot.VALUES (MAINHAND, OFFHAND, FEET, LEGS, CHEST, HEAD, BODY, SADDLE); the core keeps shearable stacks only in BODY (WC-BODY of WCSTATE.cpy: horse armor, a llama carpet,
*> nautilus armor) and SADDLE (EN-SADDLE), so the walk is BODY then SADDLE. The first slot whose stack may be taken (no prevent_armor_change, or a creative player: MN6-MAYPICKUP) is sheared: the shears lose
*> 1 durability (TOOL-HURT-STACK: none in creative mode), the slot is emptied, the viewers get Set Equipment, the stack with its components is dropped at the average passenger attachment point of the mob
*> (MOB-RIDE-SEAT plus the rider's 0.6, else the height) and the game event shear is posted with the player as the source. The advancement, the sound and the dispenser (which shears no equipment) are not here.
*> Not built: the wolf armor (EN-WOLF-ARM keeps no components, so a damaged armor could not be dropped as it is) and the happy ghast's harness (HG-INTERACT), the slots of a mob's hands and armor
*> (no stack there can be sheared).
*>   MOB-SHEAR-EQUIP USING player row, mob row, handled out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SHEAR-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY CITEMS.
 01 WS-HELD                PIC X(24).
 01 WS-KEY48               PIC X(48).
 01 WS-KEY24               PIC X(24).
 01 WS-CURSE-KEY           PIC X(112) VALUE "minecraft:binding_curse".
 01 WS-CURSE               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-NONEMPTY            BINARY-LONG VALUE 1.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-PREVENT             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-SEAT                FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-SADDLE-KEY          PIC X(24) VALUE "saddle".
 01 WS-DROPPED             BINARY-LONG.
 01 WS-EV-SHEAR            PIC X(32) VALUE "shear".
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF PL-SNEAKING(L-PLAYER) = 1 OR PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) WS-KEY48
     MOVE WS-KEY48 TO WS-HELD
     IF WS-HELD NOT = "shears"
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING L-ENTITY
     IF EN-RIDER(L-ENTITY) > 0 OR EN-RIDER2(L-ENTITY) > 0 OR EN-PASS(L-ENTITY) > 0 OR WC-PASS2(L-ENTITY) > 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SLOT
*>   BODY: a worn stack that the player may take (prevent_armor_change blocks a survival player).
     IF WC-BODY(L-ENTITY) > 0
         MOVE 0 TO WS-CREATIVE WS-PREVENT
         IF PL-MODE(L-PLAYER) = 1
             MOVE 1 TO WS-CREATIVE
         END-IF
         IF WC-BODY-VAR(L-ENTITY) > 0
             CALL "TOOL-ENCHANT-ID" USING WS-CURSE-KEY WS-CURSE
             CALL "SP-ENCHANT-LEVEL" USING WC-BODY-VAR(L-ENTITY) WS-CURSE WS-LEVEL
             IF WS-LEVEL > 0
                 MOVE 1 TO WS-PREVENT
             END-IF
         END-IF
         CALL "MN6-MAYPICKUP" USING WS-NONEMPTY WS-CREATIVE WS-PREVENT WS-OK
         IF WS-OK = 1
             MOVE 6 TO WS-SLOT
             MOVE WC-BODY(L-ENTITY) TO WS-ITEM
             MOVE WC-BODY-VAR(L-ENTITY) TO WS-VAR
             MOVE 0 TO WC-BODY(L-ENTITY) WC-BODY-VAR(L-ENTITY)
         END-IF
     END-IF
*>   SADDLE: a saddle is a plain item.
     IF WS-SLOT = 0 AND EN-SADDLE(L-ENTITY) = 1
         MOVE 7 TO WS-SLOT
         CALL "MOB-ITEM-ID" USING WS-SADDLE-KEY WS-ITEM
         MOVE 0 TO WS-VAR
         MOVE 0 TO EN-SADDLE(L-ENTITY)
     END-IF
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     CALL "TOOL-HURT-STACK" USING PL-CONN(L-PLAYER) PL-HELD(L-PLAYER) WS-COST WS-BROKE
     CALL "MNT-EQUIP-SEND" USING L-ENTITY WS-SLOT WS-ZERO WS-ZERO2
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY24
     CALL "MOB-RIDE-SEAT" USING WS-KEY24 WS-SEAT
*>   MOB-RIDE-SEAT answers the attachment less the rider's 0.6 (0 for a species it does not know): the attachment is that plus 0.6; none (or 0, the strider) leaves the height.
     IF WS-SEAT NOT = 0
         COMPUTE WS-SEAT = WS-SEAT + 0.6
     END-IF
     IF WS-SEAT < 0.001
         COMPUTE WS-SEAT = ET-HEIGHT-MILLI(EN-TYPE(L-ENTITY) + 1) / 1000
     END-IF
     CALL "IP-AT-LOCATION" USING EN-DIM(L-ENTITY) EN-X(L-ENTITY) EN-Y(L-ENTITY) EN-Z(L-ENTITY) WS-SEAT WS-ITEM WS-ONE WS-VAR WS-DROPPED
     CALL "GAME-EVENT-BY" USING WS-EV-SHEAR L-ENTITY PL-ENTITY-ROW(L-PLAYER)
     GOBACK.
 END PROGRAM MOB-SHEAR-EQUIP.
