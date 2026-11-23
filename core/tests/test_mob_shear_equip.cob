*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.3.1 "Shearing", 25-3 section 5.1): shears used on a mob take off its equipment that can be
*> sheared (nautilus armor, horse armor, carpets, the saddle). The slots are walked in the order of EquipmentSlot.VALUES (BODY before SADDLE here); the first slot whose stack may be taken (no
*> prevent_armor_change unless the player is in creative mode) is sheared: the shears take 1 durability (none in creative mode), the slot is emptied and the stack (with its components) is dropped at the
*> mob's passenger attachment point. A player who sneaks does not shear, and a mob with a passenger (a vehicle) cannot be sheared.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-SHEAR-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY WCSTATE.
 COPY CITEMPHYS.
 01 WS-REGISTRY-DIR        PIC X(1100) VALUE "core/tests/fixtures/mount-registry".
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-IDKEY               PIC X(112).
 01 WS-IDOUT               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-SHEARS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-HELD-SLOT           BINARY-LONG.
 01 WS-CURSE-KEY           PIC X(112) VALUE "minecraft:binding_curse".
 01 WS-CURSE               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-DROP-ITEM           BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-DROP-ROW            BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
*>   The enchantment registry of the test: the ranged-weapon set plus the binding curse (effect prevent_armor_change).
     CALL "REGISTRY-LOAD-ALL" USING WS-REGISTRY-DIR WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE "saddle" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SADDLE
     MOVE "iron_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-ARMOR
     MOVE "shears" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SHEARS
     MOVE "cobblestone" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-STONE
     CALL "TOOL-ENCHANT-ID" USING WS-CURSE-KEY WS-CURSE
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-HELD-SLOT
     PERFORM HOLD-SHEARS

*>   A tame adult nautilus with the armor and the saddle: a right click with shears takes the armor first (BODY comes before SADDLE) and drops it at the passenger attachment point 1.1375 above.
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-NAU
     PERFORM WEAR-ALL
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3.1 shears take the nautilus armor off (BODY first)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-BODY(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 only one slot is sheared: the saddle stays" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-SADDLE(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-ARMOR TO WS-DROP-ITEM
     PERFORM FIND-DROP
     MOVE "implementation 44-7 10.3.1 the armor lies on the ground as one item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DROPS TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 dropped at the attachment point: 1.1375 above the nautilus (thousandths)" TO WS-CASE
     MOVE 1138 TO WS-EXPECT
     MOVE -1 TO WS-OBSERVE
     IF WS-DROP-ROW > 0
         COMPUTE WS-OBSERVE = FUNCTION INTEGER((EN-Y(WS-DROP-ROW) - EN-Y(WS-NAU)) * 1000 + 0.5)
     END-IF
     PERFORM CHECK
     PERFORM SHEARS-DAMAGE
     MOVE "implementation 44-7 10.3.1 the shears lose 1 durability" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the shearing does not make the player ride" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-RIDER(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   The second click shears the saddle.
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.3.1 the next click takes the saddle" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SADDLE(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-SADDLE TO WS-DROP-ITEM
     PERFORM FIND-DROP
     MOVE "implementation 44-7 10.3.1 the saddle lies on the ground" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DROPS TO WS-OBSERVE
     PERFORM CHECK
     PERFORM SHEARS-DAMAGE
     MOVE "implementation 44-7 10.3.1 two shearings cost 2 durability" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK

*>   Not sneaking: a sneaking player shears nothing; a mob with a passenger (a vehicle) is not sheared; anything but shears does not shear.
     PERFORM WEAR-ALL
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a sneaking player does not shear" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE WS-NAU TO EN-PASS(WS-NAU)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a mob with a mob passenger cannot be sheared (canShearEquipment)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     MOVE 0 TO EN-PASS(WS-NAU)
     MOVE WS-PLAYER TO EN-RIDER(WS-NAU)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a ridden nautilus cannot be sheared" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     MOVE 0 TO EN-RIDER(WS-NAU)
     MOVE WS-PLAYER TO EN-RIDER2(WS-NAU)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a second rider makes it a vehicle too" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     MOVE 0 TO EN-RIDER2(WS-NAU)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 an item that is not the shears does not shear" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     PERFORM HOLD-SHEARS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 an empty hand does not shear" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + EN-SADDLE(WS-NAU) - 1
     PERFORM CHECK
     PERFORM HOLD-SHEARS

*>   The binding curse (prevent_armor_change) on the worn armor: a survival player cannot shear it, so the walk goes on to the saddle; a creative player can, and the shears are not damaged.
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-CURSE WS-ONE
     MOVE WS-HANDLE TO WC-BODY-VAR(WS-NAU)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 cursed armor is skipped in survival: the saddle is sheared instead" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + (WS-ARMOR - WC-BODY(WS-NAU))
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the cursed armor stays on" TO WS-CASE
     MOVE WS-ARMOR TO WS-EXPECT
     MOVE WC-BODY(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 with only cursed armor left nothing is sheared in survival" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM SHEARS-DAMAGE
     MOVE WS-DAMAGE TO WS-BEFORE
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a creative player shears the cursed armor" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-BODY(WS-NAU) + WC-BODY-VAR(WS-NAU) + 1 - WS-HANDLED
     PERFORM CHECK
     MOVE WS-ARMOR TO WS-DROP-ITEM
     PERFORM FIND-DROP
     MOVE "implementation 44-7 10.3.1 the dropped armor keeps its components (the curse)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-DROP-ROW > 0
         CALL "SP-ENCHANT-LEVEL" USING IP-I-VAR(WS-DROP-ROW) WS-CURSE WS-DAMAGE
         MOVE WS-DAMAGE TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     PERFORM SHEARS-DAMAGE
     MOVE "implementation 44-7 10.3.1 hurtAndBreak does nothing in creative mode" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   Nothing to shear (the saddle is gone, no armor): not handled, so the click goes on (a pig with a saddle gives it up: the rule is generic).
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-NAU WS-HANDLED
     MOVE "implementation 44-7 10.3.1 a mob with nothing to shear is not handled" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
     MOVE "pig" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE 1 TO EN-SADDLE(WS-M)
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-M WS-HANDLED
     MOVE "implementation 44-7 10.3.1 shears take the saddle off a pig as well" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED * (1 - EN-SADDLE(WS-M))
     PERFORM CHECK
*>   A species without a passenger attachment of its own (the strider) drops the stack at the top of its box (the default attachment is the height 1.7).
     MOVE "strider" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE 1 TO EN-SADDLE(WS-M)
     MOVE WS-SADDLE TO WS-DROP-ITEM
     PERFORM FIND-DROP
     MOVE WS-DROPS TO WS-BEFORE
     CALL "MOB-SHEAR-EQUIP" USING WS-PLAYER WS-M WS-HANDLED
     PERFORM FIND-DROP
     MOVE "implementation 44-7 10.3.1 a strider's saddle is dropped at its height 1.7 (thousandths)" TO WS-CASE
     MOVE 1700 TO WS-EXPECT
     MOVE -1 TO WS-OBSERVE
     IF WS-DROPS = WS-BEFORE + 1
         COMPUTE WS-OBSERVE = FUNCTION INTEGER((EN-Y(WS-DROP-ROW) - EN-Y(WS-M)) * 1000 + 0.5)
     END-IF
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-MOUNT: a tame adult mob of the key WS-KEY24 two blocks in front of the player, its tracker row in WS-M and its entity id in WS-ID
 SPAWN-MOUNT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M)
     MOVE EN-ID(WS-M) TO WS-ID.
*> HOLD-SHEARS: one pair of shears (no components) in the main hand
 HOLD-SHEARS.
     MOVE WS-SHEARS TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT).
*> WEAR-ALL: the nautilus WS-NAU wears iron nautilus armor and a saddle
 WEAR-ALL.
     CALL "WC-ROW-OPEN" USING WS-NAU
     MOVE WS-ARMOR TO WC-BODY(WS-NAU)
     MOVE 0 TO WC-BODY-VAR(WS-NAU)
     MOVE 1 TO EN-SADDLE(WS-NAU).
*> FIND-DROP: the loose items of the item WS-DROP-ITEM: their count in WS-DROPS and the last row in WS-DROP-ROW
 FIND-DROP.
     MOVE 0 TO WS-DROPS WS-DROP-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-DROP-ITEM
             ADD 1 TO WS-DROPS
             MOVE WS-I TO WS-DROP-ROW
         END-IF
     END-PERFORM.
*> SHEARS-DAMAGE: the damage of the shears in the main hand in WS-DAMAGE
 SHEARS-DAMAGE.
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT) PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT) WS-DAMAGE.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-SHEAR-EQUIP.
 COPY CORETEST.
 COPY MOBSPTEST.
