*> Implementation test (wrap I2 round 4, T52093; docs/protocol/40-menus-6-mount-inventories.md section 2.3, 28 section 4 effect component 29): prevent_armor_change on the body slot of a mount. The worn
*> armor keeps its data components (WC-BODY-VAR): a tame horse that is given an armor stack with the binding curse keeps the stack's patch; the body slot's mayPickup is false for a survival player
*> (pickup, quick move, swap and throw leave the item on the horse), true for a creative player and for armor without the curse; the patch survives the save of the mob (equipment.body.components),
*> the drop at death (the item entity keeps it) and the sweep of the patch pool.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-PREVENT-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY CMENU.
 COPY WCSTATE.
 COPY CITEMPHYS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
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
 01 WS-ARMOR               BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CURSE-KEY           PIC X(112) VALUE "minecraft:binding_curse".
 01 WS-CURSE               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE-CLICK          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LOOSE-VAR           BINARY-LONG.
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
     MOVE "diamond_horse_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-ARMOR
     CALL "TOOL-ENCHANT-ID" USING WS-CURSE-KEY WS-CURSE
     MOVE "horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-HORSE
     MOVE EN-ID(WS-HORSE) TO WS-ID

*>   A tame horse is given armor with the binding curse: the stack's patch goes with it.
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-CURSE WS-ONE
     MOVE WS-ARMOR TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE "implementation 40-6 2.3 the horse wears the armor and keeps the stack's components (WC-BODY-VAR)" TO WS-CASE
     MOVE WS-ARMOR TO WS-EXPECT
     IF WC-BODY-VAR(WS-HORSE) = WS-HANDLE AND WS-HANDLE > 0
         MOVE WC-BODY(WS-HORSE) TO WS-OBSERVE
     ELSE
         MOVE -1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 28 4 the worn stack has the binding curse (effect component 29)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     CALL "SP-ENCHANT-LEVEL" USING WC-BODY-VAR(WS-HORSE) WS-CURSE WS-LEVEL
     MOVE WS-LEVEL TO WS-OBSERVE
     PERFORM CHECK

*>   The mount screen: a survival player cannot take the cursed armor out (pickup, quick move, swap, throw); nothing leaves the slot.
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE 1 TO WS-SLOT
     MOVE 0 TO WS-BUTTON
     MOVE 0 TO WS-TYPE-CLICK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 mayPickup: a survival player's pickup of cursed body armor takes nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-CARRIED-COUNT(WS-PLAYER) + (WS-ARMOR - WC-BODY(WS-HORSE))
     PERFORM CHECK
     MOVE 1 TO WS-TYPE-CLICK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 mayPickup: quick move leaves the cursed armor on the horse" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-ARMOR - WC-BODY(WS-HORSE)
     PERFORM CHECK
     MOVE 2 TO WS-TYPE-CLICK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 mayPickup: a swap with the hotbar leaves the cursed armor on the horse" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-ARMOR - WC-BODY(WS-HORSE)
     PERFORM CHECK
     MOVE 4 TO WS-TYPE-CLICK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 mayPickup: a throw leaves the cursed armor on the horse" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-ARMOR - WC-BODY(WS-HORSE)
     PERFORM CHECK

*>   A creative player takes it, with its components; putting it back keeps them.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-TYPE-CLICK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 mayPickup is true for a creative player: the armor is on the cursor with its patch" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-CARRIED-ITEM(WS-PLAYER) = WS-ARMOR AND PL-CARRIED-VAR(WS-PLAYER) = WS-HANDLE AND WC-BODY(WS-HORSE) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 the armor put back keeps its components" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-BODY(WS-HORSE) = WS-ARMOR AND WC-BODY-VAR(WS-HORSE) = WS-HANDLE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   Armor without the curse can be taken by a survival player.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WC-BODY-VAR(WS-HORSE)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-TYPE-CLICK
     MOVE "implementation 40-6 2.3 armor without prevent_armor_change is taken by a survival player" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-CARRIED-ITEM(WS-PLAYER) = WS-ARMOR AND WC-BODY(WS-HORSE) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER) PL-CARRIED-ITEM(WS-PLAYER) PL-CARRIED-VAR(WS-PLAYER)
     MOVE WS-ARMOR TO WC-BODY(WS-HORSE)
     MOVE WS-HANDLE TO WC-BODY-VAR(WS-HORSE)

*>   The sweep of the patch pool keeps the stack of a worn armor (nothing else holds the handle).
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "SP-SWEEP"
     CALL "SP-ENCHANT-LEVEL" USING WC-BODY-VAR(WS-HORSE) WS-CURSE WS-LEVEL
     MOVE "implementation 40-6 2.3 the sweep keeps the components of a worn body armor" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-LEVEL TO WS-OBSERVE
     PERFORM CHECK

*>   The save: the mob's chunk written, every mob removed, the compound read back; the body keeps its components.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-HORSE) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-HORSE) / 16)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "MNT-KIND" USING WS-I WS-TYPE
             IF WS-TYPE = 1
                 MOVE WS-I TO WS-FOUND
             END-IF
         END-IF
     END-PERFORM
     MOVE "implementation 45-2 2.4 the saved horse comes back wearing the armor" TO WS-CASE
     MOVE WS-ARMOR TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-FOUND > 0
         CALL "WC-ROW-OPEN" USING WS-FOUND
         MOVE WC-BODY(WS-FOUND) TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 45-2 2.4 equipment.body.components survives the save: the curse is still there" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-FOUND > 0
         CALL "SP-ENCHANT-LEVEL" USING WC-BODY-VAR(WS-FOUND) WS-CURSE WS-LEVEL
         MOVE WS-LEVEL TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   Death drops the armor with its components.
     MOVE WC-BODY-VAR(WS-FOUND) TO WS-HANDLE
     CALL "STDMOB-DIE" USING WS-FOUND
     MOVE 0 TO WS-LOOSE-VAR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             IF IP-I-VAR(WS-I) = WS-HANDLE AND WS-HANDLE > 0
                 MOVE 1 TO WS-LOOSE-VAR
             END-IF
         END-IF
     END-PERFORM
     MOVE "implementation 40-6 2.2 the armor dropped at death keeps its components" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-LOOSE-VAR TO WS-OBSERVE
     PERFORM CHECK

*>   A tame nautilus given nautilus armor with the curse keeps the patch as well.
     MOVE "iron_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-ARMOR
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-CURSE WS-ONE
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-HORSE
     MOVE EN-ID(WS-HORSE) TO WS-ID
     MOVE 0 TO PL-SNEAKING(WS-PLAYER) PL-MODE(WS-PLAYER)
     MOVE WS-ARMOR TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE "implementation 40-6 2.3 nautilus armor given by interact keeps its components" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-BODY(WS-HORSE) = WS-ARMOR AND WC-BODY-VAR(WS-HORSE) = WS-HANDLE AND WS-HANDLE > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 5 TO WS-SLOT
     CALL "MNT-MAYPICKUP" USING WS-PLAYER WS-SLOT WS-OUTCOME
     MOVE "implementation 40-6 2.3 only the saddle and body slots are armor slots: a chest slot may always be picked up" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OUTCOME TO WS-OBSERVE
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-MOUNT: a tamed adult mob of the key WS-KEY24 two blocks in front of the player, its tracker row in WS-M
 SPAWN-MOUNT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M).
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-PREVENT-ARMOR.
 COPY CORETEST.
 COPY MOBSPTEST.
