*> Implementation test (wrap I2 round 2, T52093; docs/protocol/40-menus-6-mount-inventories.md sections 2 to 4, 7; 19 section 3.5 steps 2 and 3): the mount screen of a tamed horse family mob. A sneaking
*> player's Interact on a tamed adult opens it (Mount Screen Open 0x2A: container id, chest columns, entity id; then Container Set Content), a baby, an untamed or a ridden mount refuses. Own slots 0 the
*> saddle, 1 the body slot, 2.. the chest (3 x columns); the slots take only what 2.3 and 5.1 allow (a saddle never on a llama, horse armor only on a horse or zombie horse, carpets only on llamas, nautilus
*> armor only on a nautilus), one item each in the saddle and body slots; quick move follows 2.6; the chest, the saddle and the body item land on the ground when the mount dies; a non-food item on an
*> untamed horse is makeMad (SUCCESS); a tamed horse puts one horse armor on; the rider's OPEN_INVENTORY opens the screen.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-MOUNT-SCREEN.
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
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
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
 01 WS-IDS                 PIC X(1024).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-IRON                BINARY-LONG.
 01 WS-CARPET              BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-IDKEY               PIC X(112).
 01 WS-IDOUT               BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-LLAMA               BINARY-LONG.
 01 WS-DONKEY              BINARY-LONG.
 01 WS-SKEL                BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-SEEN42              BINARY-LONG.
 01 WS-SEEN104             BINARY-LONG.
 01 WS-SEEN18              BINARY-LONG.
 01 WS-F-CONTAINER         BINARY-LONG.
 01 WS-F-COLUMNS           BINARY-LONG.
 01 WS-F-ENTITY            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-PICKUP              BINARY-LONG VALUE 0.
 01 WS-QUICK               BINARY-LONG VALUE 1.
 01 WS-RET-ITEM            BINARY-LONG.
 01 WS-RET-COUNT           BINARY-LONG.
 01 WS-LOOSE-BEFORE        BINARY-LONG.
 01 WS-LOOSE-AFTER         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
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
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE "saddle" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SADDLE
     MOVE "diamond_horse_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-DIAMOND
     MOVE "iron_horse_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-IRON
     MOVE "white_carpet" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-CARPET
     MOVE "moss_carpet" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-MOSS
     MOVE "iron_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-NAUTILUS
     MOVE "cobblestone" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-STONE
     MOVE "chest" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-CHEST
     MOVE "implementation 40-6 2.5 the items of the test exist in the content set" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-SADDLE > 0 AND WS-DIAMOND > 0 AND WS-IRON > 0 AND WS-CARPET > 0 AND WS-MOSS > 0 AND WS-NAUTILUS > 0 AND WS-STONE > 0 AND WS-CHEST > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 40-6 2.5 item kinds: saddle 1, carpet 2, moss carpet 0, horse armor 3, nautilus armor 4" TO WS-CASE
     CALL "MNT-ITEM-KIND" USING WS-SADDLE WS-M
     COMPUTE WS-OBSERVE = WS-M * 10000
     CALL "MNT-ITEM-KIND" USING WS-CARPET WS-M
     COMPUTE WS-OBSERVE = WS-OBSERVE + WS-M * 1000
     CALL "MNT-ITEM-KIND" USING WS-MOSS WS-M
     COMPUTE WS-OBSERVE = WS-OBSERVE + WS-M * 100
     CALL "MNT-ITEM-KIND" USING WS-DIAMOND WS-M
     COMPUTE WS-OBSERVE = WS-OBSERVE + WS-M * 10
     CALL "MNT-ITEM-KIND" USING WS-NAUTILUS WS-M
     COMPUTE WS-OBSERVE = WS-OBSERVE + WS-M
     MOVE 12034 TO WS-EXPECT
     PERFORM CHECK
     CALL "MNT-ITEM-KIND" USING WS-STONE WS-M
     MOVE "implementation 40-6 2.5 a stack that is no equippable has no kind" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-M TO WS-OBSERVE
     PERFORM CHECK

*>   A tamed adult horse: a sneaking player's Interact opens the screen (3.1, 3.2, 7.1: 38 slots, saddle 0, body 1).
     MOVE "horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-HORSE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     PERFORM SCAN-PACKETS
     MOVE "implementation 40-6 3.1 a sneaking Interact on a tamed adult horse opens the screen: window 1, family 15, own slots 2" TO WS-CASE
     MOVE 1152 TO WS-EXPECT
     COMPUTE WS-OBSERVE = MN-WINDOW(WS-PLAYER) * 1000 + MN-CFAMILY(WS-PLAYER) * 10 + MN-CSIZE(WS-PLAYER)
     MOVE 1152 TO WS-EXPECT
     PERFORM CHECK
     MOVE "implementation 40-6 3.2 one Mount Screen Open (0x2A): container id 1, columns 0, the horse's entity id" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-SEEN42 = 1 AND WS-F-CONTAINER = 1 AND WS-F-COLUMNS = 0 AND WS-F-ENTITY = WS-ID
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 40-6 3.1 Container Set Content (0x12) follows the open packet" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-SEEN18 TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 40-6 2.1 the menu has 2 + 36 = 38 slots" TO WS-CASE
     MOVE 38 TO WS-EXPECT
     CALL "MENU-SLOT-COUNT" USING WS-PLAYER WS-OBSERVE
     PERFORM CHECK

*>   The slots take what 2.3 and 5.1 allow, one item each. A saddle goes into slot 0; stone is refused; a second saddle stack of 2 puts one.
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE WS-STONE TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 5 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 0 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 2.3 stone is refused by the saddle slot" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE PL-CARRIED-COUNT(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-SADDLE TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 2 TO PL-CARRIED-COUNT(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     PERFORM SCAN-PACKETS
     MOVE "implementation 40-6 2.3 a stack of 2 saddles puts one into the saddle slot (max stack 1) and the horse wears it" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-HORSE) * 10 + PL-CARRIED-COUNT(WS-PLAYER)
     PERFORM CHECK
     MOVE "implementation 40-6 2.3 the viewers get Set Equipment (0x68) for the saddle" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-SEEN104 TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO WS-SLOT
     MOVE WS-CARPET TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 5.1 a horse's body slot refuses a carpet" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE WC-BODY(WS-HORSE) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-NAUTILUS TO PL-CARRIED-ITEM(WS-PLAYER)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 5.1 a horse's body slot refuses nautilus armor" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-BODY(WS-HORSE) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-DIAMOND TO PL-CARRIED-ITEM(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     PERFORM SCAN-PACKETS
     MOVE "implementation 40-6 5.1 a horse's body slot takes horse armor and the viewers get Set Equipment" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-BODY(WS-HORSE) = WS-DIAMOND AND WS-SEEN104 = 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 the slots read back: saddle, body, then the player's slots (menu slot 2 is player slot 10)" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     MOVE 0 TO WS-SLOT
     CALL "MENU-GET-X" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE 1 TO WS-OBSERVE
     IF WS-ITEM = WS-SADDLE AND WS-COUNT = 1
         ADD 10 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-SLOT
     CALL "MENU-GET-X" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-ITEM NOT = WS-DIAMOND OR WS-COUNT NOT = 1
         SUBTRACT 1 FROM WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   Quick move (2.6, 7.2): a saddle in the main inventory goes to the saddle slot when it is empty, else (no chest) it moves between main and hotbar.
     MOVE 0 TO EN-SADDLE(WS-HORSE)
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE WS-SADDLE TO PL-SLOT-ITEM(WS-PLAYER, 10)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 10)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 10)
     MOVE 2 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 7.2 case 1 quick move of a saddle from the main inventory fills the empty saddle slot" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-HORSE) * 10 + PL-SLOT-COUNT(WS-PLAYER, 10)
     PERFORM CHECK
     MOVE WS-SADDLE TO PL-SLOT-ITEM(WS-PLAYER, 10)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 10)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 7.2 case 2 with the saddle slot full the saddle moves to the hotbar (main slot 10 empty, hotbar slot 1 holds it)" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + PL-SLOT-COUNT(WS-PLAYER, 10)
     IF PL-SLOT-ITEM(WS-PLAYER, 1) NOT = WS-SADDLE
         MOVE 99 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
*>   The body slot holds armour: a quick move of it (index 1 < N) goes to the player's part from the end.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1) PL-SLOT-COUNT(WS-PLAYER, 10)
     MOVE 1 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 7.2 case 5 quick move of the body slot returns the armour to the inventory from the end (hotbar first)" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     CALL "WC-ROW-OPEN" USING WS-HORSE
     COMPUTE WS-OBSERVE = WC-BODY(WS-HORSE) * 10
     IF PL-SLOT-ITEM(WS-PLAYER, 9) = WS-DIAMOND AND PL-SLOT-COUNT(WS-PLAYER, 9) = 1
         ADD 10 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 9)

*>   Refusals: an untamed horse, a baby and a ridden horse do not open the screen.
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     MOVE 0 TO EN-TAMED(WS-HORSE)
     CALL "MNT-OPEN" USING WS-CONN WS-HORSE WS-HANDLED
     MOVE "implementation 40-6 3.1 an untamed horse does not open the screen" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + MN-WINDOW(WS-PLAYER)
     PERFORM CHECK
     MOVE 1 TO EN-TAMED(WS-HORSE)
     MOVE 5 TO EN-RIDER(WS-HORSE)
     CALL "MNT-OPEN" USING WS-CONN WS-HORSE WS-HANDLED
     MOVE "implementation 40-6 3.1 a horse that carries another player does not open the screen" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED + MN-WINDOW(WS-PLAYER)
     PERFORM CHECK
     MOVE 0 TO EN-RIDER(WS-HORSE)
     MOVE -24000 TO EN-MOBAGE(WS-HORSE)
     MOVE EN-ID(WS-HORSE) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.5 a tamed baby takes the animal path, no screen" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE MN-WINDOW(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-HORSE)
     MOVE "implementation 40-6 3.3 an entity that is no mount does not open the screen" TO WS-CASE
     MOVE "sheep" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     CALL "MNT-OPEN" USING WS-CONN WS-M WS-HANDLED
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK

*>   The rider's OPEN_INVENTORY (Player Command 5) opens the screen; stillValid fails when the mount is dead or the player is far.
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-M
     MOVE WS-HORSE TO EN-VEHICLE(WS-M)
     MOVE WS-PLAYER TO EN-RIDER(WS-HORSE)
     MOVE 5 TO WS-I
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-I
     MOVE "implementation 40-6 3.1 OPEN_INVENTORY of the rider opens the mount screen" TO WS-CASE
     MOVE 15 TO WS-EXPECT
     MOVE MN-CFAMILY(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MNT-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 40-6 2.1 the screen is valid while the horse lives within reach" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-VALID TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-HEALTH(WS-HORSE)
     CALL "MNT-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 40-6 2.1 the screen is invalid when the mount is dead" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-VALID TO WS-OBSERVE
     PERFORM CHECK
     MOVE 20 TO EN-HEALTH(WS-HORSE)
     MOVE 0 TO EN-VEHICLE(WS-M) EN-RIDER(WS-HORSE)
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     MOVE "implementation 40-6 3.4 closing the menu leaves no own slots" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE MN-CSIZE(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MNT-RIDER-OPEN" USING WS-PLAYER WS-HANDLED
     MOVE "implementation 40-6 3.1 OPEN_INVENTORY of a player who rides nothing opens nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK

*>   A chested llama of strength 4: 4 columns, 12 chest slots, N = 14 (7.1, 7.3); the chest holds items and a llama's body slot takes a carpet but never a saddle.
     MOVE "llama" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-LLAMA
     MOVE 4 TO EN-STRENGTH(WS-LLAMA)
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1) PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-LLAMA
     MOVE "implementation 40-6 4 a tamed llama takes a chest from the hand (equipChest): the chest flag is set and one chest is used" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-CHEST(WS-LLAMA) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     PERFORM SCAN-PACKETS
     MOVE "implementation 40-6 7.3 a llama with a chest and strength 4: columns 4, own slots 14, entity id in the packet" TO WS-CASE
     MOVE 414 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-F-COLUMNS * 100 + MN-CSIZE(WS-PLAYER)
     IF WS-F-ENTITY NOT = WS-ID
         MOVE 0 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE WS-SADDLE TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 0 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 5.2 a llama never takes a saddle" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SADDLE(WS-LLAMA) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-CARPET TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 5 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 1 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 2.3 a llama's body slot takes one carpet of a stack of 5" TO WS-CASE
     MOVE 14 TO WS-EXPECT
     COMPUTE WS-OBSERVE = 10 * (WC-BODY(WS-LLAMA) - WS-CARPET + 1) + PL-CARRIED-COUNT(WS-PLAYER)
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE WS-STONE TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 64 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 13 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 2.6 the last of 12 chest slots (menu slot 13) takes cobblestone and reads back" TO WS-CASE
     MOVE 64 TO WS-EXPECT
     CALL "MENU-GET-X" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE 0 TO WS-OBSERVE
     IF WS-ITEM = WS-STONE
         MOVE WS-COUNT TO WS-OBSERVE
     END-IF
     PERFORM CHECK
*>   Quick move of the chest slot sends the stack to the player's slots from the end, the hotbar first; a stack of the main inventory then goes to the chest (no saddle/body match).
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 9)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 7.2 case 5 a chest stack goes to the last free player slot (hotbar slot 9)" TO WS-CASE
     MOVE 640 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 9) * 10
     IF PL-SLOT-ITEM(WS-PLAYER, 9) NOT = WS-STONE
         MOVE 0 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 9)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 12)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 12)
     COMPUTE WS-SLOT = 14 + 2
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 7.2 case 4 a main inventory stack goes to the chest (merging into the first free chest slot 2)" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE 2 TO WS-SLOT
     CALL "MENU-GET-X" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE 0 TO WS-OBSERVE
     IF WS-ITEM = WS-STONE
         MOVE WS-COUNT TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 12)
     MOVE 0 TO WS-SLOT

*>   The llama dies: the chest, the carpet and no saddle land on the ground (2.2 guaranteed drops, 3.4).
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     PERFORM COUNT-LOOSE
     MOVE WS-LOOSE-AFTER TO WS-LOOSE-BEFORE
     CALL "STDMOB-DIE" USING WS-LLAMA
     PERFORM COUNT-LOOSE
     MOVE "implementation 40-6 2.2 a dead llama drops its carpet and its chest stack: at least two item entities more" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LOOSE-AFTER >= WS-LOOSE-BEFORE + 2 AND WC-BODY(WS-LLAMA) = 0 AND WC-INV-COUNT(WS-LLAMA, 12) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   A donkey with a chest has 5 columns, 15 chest slots (own slots 17); a skeleton horse takes a saddle but no horse armor; a nautilus has no chest.
     MOVE "donkey" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-DONKEY
     CALL "WC-ROW-OPEN" USING WS-DONKEY
     MOVE 1 TO WC-CHEST(WS-DONKEY)
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 40-6 4 a chested donkey: 5 columns, own slots 17" TO WS-CASE
     MOVE 17 TO WS-EXPECT
     MOVE MN-CSIZE(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-DIAMOND TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 1 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 5.2 a donkey's body slot refuses horse armor" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-BODY(WS-DONKEY) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     MOVE "skeleton_horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-SKEL
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE WS-DIAMOND TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 5.2 a skeleton horse shows only the saddle slot: horse armor is refused" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-BODY(WS-SKEL) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER)
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-NAU
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 40-6 4 a tamed nautilus opens a screen without chest slots (own slots 2)" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE MN-CSIZE(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-NAUTILUS TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 1 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 2.5 a nautilus's body slot takes nautilus armor" TO WS-CASE
     MOVE WS-NAUTILUS TO WS-EXPECT
     MOVE WC-BODY(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MENU-FORCE-CLOSE" USING WS-PLAYER
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)

*>   19 section 3.5 step 3: a non-food item on an untamed horse is makeMad (SUCCESS, nothing is used); stick on a tamed horse does nothing; one horse armor is put on, a second is not.
     MOVE "horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-HORSE
     MOVE 0 TO EN-TAMED(WS-HORSE)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MNT-HELD" USING WS-PLAYER WS-HORSE WS-HANDLED
     MOVE "implementation 19 3.5 step 3 a non-food item on an untamed horse: makeMad, the action succeeds and the stack stays" TO WS-CASE
     MOVE 13 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HANDLED * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK
     MOVE "wheat" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MNT-HELD" USING WS-PLAYER WS-HORSE WS-HANDLED
     MOVE "implementation 19 3.5 step 3 wheat is food: the feeding path takes it, not makeMad" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO EN-TAMED(WS-HORSE)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MNT-HELD" USING WS-PLAYER WS-HORSE WS-HANDLED
     MOVE "implementation 19 3.5 step 3 a stone on a tamed horse is not equippable: nothing happens" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-DIAMOND TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE EN-ID(WS-HORSE) TO WS-ID
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     PERFORM SCAN-PACKETS
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE "implementation 19 3.5 step 3 a tamed horse is given one horse armor from the hand (stack 2 to 1) and the viewers see it" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WC-BODY(WS-HORSE) = WS-DIAMOND AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1 AND WS-SEEN104 = 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE WS-IRON TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.5 step 3 a horse that wears armour takes no second one" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1)
     IF WC-BODY(WS-HORSE) NOT = WS-DIAMOND
         MOVE 0 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
*>   The horse's saddle and armour land on the ground when it dies.
     MOVE 1 TO EN-SADDLE(WS-HORSE)
     PERFORM COUNT-LOOSE
     MOVE WS-LOOSE-AFTER TO WS-LOOSE-BEFORE
     CALL "STDMOB-DIE" USING WS-HORSE
     PERFORM COUNT-LOOSE
     MOVE "implementation 40-6 2.2 a dead horse drops its saddle and its armour (guaranteed drops)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-LOOSE-AFTER >= WS-LOOSE-BEFORE + 2 AND EN-SADDLE(WS-HORSE) = 0 AND WC-BODY(WS-HORSE) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
*>   The other mounts and the remaining rules: kinds, tick validity, baby slots, quick move edges, a second screen replacing the first.
     MOVE "trader_llama" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     CALL "MNT-KIND" USING WS-M WS-OBSERVE
     MOVE "implementation 40-6 5.2 mount numbers: trader llama 5" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     PERFORM CHECK
     MOVE "zombie_horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-SKEL
     CALL "MNT-KIND" USING WS-M WS-OBSERVE
     MOVE "implementation 40-6 5.2 mount numbers: zombie horse 7" TO WS-CASE
     MOVE 7 TO WS-EXPECT
     PERFORM CHECK
     MOVE "red_mushroom" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MNT-HELD" USING WS-PLAYER WS-SKEL WS-HANDLED
     MOVE "implementation 19 3.4 red mushroom is zombie horse food: the feeding path takes it" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     CALL "MNT-KIND" USING WS-M WS-OBSERVE
     MOVE "implementation 40-6 5.2 mount numbers: zombie nautilus 9" TO WS-CASE
     MOVE 9 TO WS-EXPECT
     PERFORM CHECK
     MOVE 0 TO WS-I
     CALL "MNT-ITEM-KIND" USING WS-I WS-OBSERVE
     MOVE "implementation 40-6 2.5 item 0 (air) has no kind" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK
*>   A llama is given a non-food item by a player: untamed makeMad, the llama's food kind is 1.
     MOVE "llama" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE 0 TO EN-TAMED(WS-M)
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MNT-HELD" USING WS-PLAYER WS-M WS-HANDLED
     MOVE "implementation 19 3.5 step 3 a non-food item on an untamed llama is makeMad too" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HANDLED TO WS-OBSERVE
     PERFORM CHECK
*>   A sneaking Interact on a sheep (no mount) and on a ridden tamed horse opens nothing.
     MOVE "sheep" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-HORSE
     MOVE 5 TO EN-RIDER(WS-HORSE)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.5 step 1 a horse that carries a rider takes the animal path: no screen" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE MN-WINDOW(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-RIDER(WS-HORSE)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
*>   The horse's screen is open: its saddle goes in and comes out again (the viewers are told), a baby's slots are closed, an empty slot moves nothing, the body slot ignores an unchanged write.
     MOVE WS-SADDLE TO PL-CARRIED-ITEM(WS-PLAYER)
     MOVE 1 TO PL-CARRIED-COUNT(WS-PLAYER)
     MOVE 0 TO WS-SLOT
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     PERFORM SCAN-PACKETS
     MOVE "implementation 40-6 2.3 taking the saddle out of the slot empties it, the cursor holds it and the viewers get Set Equipment" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-SADDLE(WS-HORSE) = 0 AND WS-SEEN104 = 1 AND PL-CARRIED-COUNT(WS-PLAYER) = 1 AND PL-CARRIED-ITEM(WS-PLAYER) = WS-SADDLE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE -24000 TO EN-MOBAGE(WS-HORSE)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-PICKUP
     MOVE "implementation 40-6 2.4 a baby cannot use the saddle slot: the saddle is refused" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SADDLE(WS-HORSE) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT(WS-PLAYER) EN-MOBAGE(WS-HORSE)
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     CALL "MENU-GET-X" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE "implementation 40-6 2.6 a quick move of an empty slot moves nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK
     MOVE 1 TO WS-SLOT
     MOVE 0 TO WS-ITEM WS-COUNT WS-VAR
     CALL "MNT-SET" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE WS-CARPET TO WS-ITEM
     MOVE 1 TO WS-COUNT
     CALL "MNT-SET" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     CALL "MNT-SET" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     MOVE 0 TO WS-COUNT
     CALL "MNT-SET" USING WS-PLAYER WS-SLOT WS-ITEM WS-COUNT WS-VAR
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE "implementation 40-6 2.2 the body slot written with the same stack changes nothing, an empty stack clears it" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-BODY(WS-HORSE) TO WS-OBSERVE
     PERFORM CHECK
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 2)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 2)
     COMPUTE WS-SLOT = MN-CSIZE(WS-PLAYER) + 27 + 1
     CALL "MENU-CLICK" USING WS-PLAYER WS-SLOT WS-BUTTON WS-QUICK
     MOVE "implementation 40-6 2.6 a hotbar stone moves to the main inventory (hotbar slot 2 empty)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 2) TO WS-OBSERVE
     PERFORM CHECK
*>   A second screen replaces the first and takes the next container id; the tick closes a screen whose mount died.
     MOVE MN-WINDOW(WS-PLAYER) TO WS-PREV
     MOVE "llama" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-LLAMA
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 40-6 3.1 a second screen closes the first and takes the next container id" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION MOD(WS-PREV, 100) + 1
     MOVE MN-WINDOW(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     CALL "MENU-STILL-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 40-6 2.1 MENU-STILL-VALID of an open mount screen is true" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-VALID TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-HEALTH(WS-LLAMA)
     CALL "MENU-TICK"
     MOVE "implementation 40-6 2.1 the tick closes the screen of a dead mount" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE MN-WINDOW(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 a mob that is no mount drops nothing through the mount rule" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE "sheep" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     PERFORM COUNT-LOOSE
     MOVE WS-LOOSE-AFTER TO WS-LOOSE-BEFORE
     CALL "MNT-DROP" USING WS-M
     PERFORM COUNT-LOOSE
     COMPUTE WS-OBSERVE = WS-LOOSE-AFTER - WS-LOOSE-BEFORE
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-MOUNT: a tamed adult mob of the key WS-KEY24 two blocks in front of the player, its row in WS-M and its id in WS-ID
 SPAWN-MOUNT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M)
     MOVE EN-ID(WS-M) TO WS-ID.
*> SCAN-PACKETS: drains the player's connection; WS-SEEN42 / 104 / 18 count the packets, WS-F-* hold the fields of the last Mount Screen Open
 SCAN-PACKETS.
     MOVE 0 TO WS-SEEN42 WS-SEEN104 WS-SEEN18 WS-F-CONTAINER WS-F-COLUMNS WS-F-ENTITY
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 42
                     ADD 1 TO WS-SEEN42
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-F-CONTAINER
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-F-COLUMNS
                     CALL "PB-GET-INT" USING PK-BUFFER WS-F-ENTITY
                 WHEN 104
                     ADD 1 TO WS-SEEN104
                 WHEN 18
                     ADD 1 TO WS-SEEN18
             END-EVALUATE
         END-IF
     END-PERFORM.
*> COUNT-LOOSE: the item entities on the ground in WS-LOOSE-AFTER
 COUNT-LOOSE.
     MOVE 0 TO WS-LOOSE-AFTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD 1 TO WS-LOOSE-AFTER
         END-IF
     END-PERFORM.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-MOUNT-SCREEN.
 COPY CORETEST.
 COPY MOBSPTEST.
