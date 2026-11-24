*> Implementation test (wrap C round 5, T24208; docs/protocol/44-residual-mob-questions-x2-continuation.md section 5 and 44-8 section 4.6): the container minecarts. A chest cart opens generic_9x3 (27
*> slots, type 2) and a hopper cart the hopper menu (5 slots, type 16) on interact, the menu is the player's container menu (family 14) and moves stacks through the generic click engine, the contents stay
*> with the cart when the menu closes, the menu closes when the cart is gone or the player is out of reach (3.0 + 4.0 blocks to the cart's box); the comparator signal of the contents slows the cart
*> (0.98 + (15 - signal) x 0.001); a hopper cart pulls one item a tick from the container above, else the item entities above it or in its box (one that does not fit whole stays); a broken cart scatters its
*> contents (also with entity_drops off) and a hitting player angers the piglins that see him.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-CART-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROJSTATE.
 COPY BESTATE.
 COPY CITEMS.
 COPY ECVSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 20.
 01 WS-FLOOR-KIND          BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-HOPPER              BINARY-LONG.
 01 WS-FURNACE             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SLOT2               BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-BTN                 BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SIGNAL              BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-ITEM-E              BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-MX                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-STONES              BINARY-LONG.
 01 WS-STICKS              BINARY-LONG.
 01 WS-CARTS               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FLOOR-KIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A chest cart opens generic_9x3 on interact (a sneaking player too) and the packets are Open Screen and Container Set Content.
     MOVE 2 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CHEST
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "MINECART-USE" USING WS-PLAYER WS-CHEST WS-USED
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE "implementation 44-8 4.6 a chest minecart opens its menu on interact" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 4.6 the chest cart's menu is generic_9x3 with 27 own slots, family 14, container id 1" TO TL-CASE
     MOVE 2271401 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MN-TYPE(WS-PLAYER) * 1000000 + MN-CSIZE(WS-PLAYER) * 10000 + MN-CFAMILY(WS-PLAYER) * 100 + MN-WINDOW(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 4.6 the menu is bound to the cart (its row and its id)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CHEST * 1000000 + EN-ID(WS-CHEST)
     COMPUTE TL-OBSERVED-N = MN-BENCH-X(WS-PLAYER) * 1000000 + MN-BENCH-Y(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 4.6 Open Screen (60) goes out once" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 60 "
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quick move of the first hotbar stack goes into the cart's first own slot; two picks move a stack to another slot.
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 54 TO WS-S
     MOVE 0 TO WS-BTN
     MOVE 1 TO WS-CTYPE
     CALL "MENU-CLICK" USING WS-PLAYER WS-S WS-BTN WS-CTYPE
     MOVE "implementation 40-1 7.3 a quick move of a hotbar stack fills the cart's own slot 0 (5 stone) and empties the hotbar slot" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-CHEST, 1) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 40-1 3.4 the item that went in is stone" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE ECV-ITEM(WS-CHEST, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-S WS-CTYPE
     CALL "MENU-CLICK" USING WS-PLAYER WS-S WS-BTN WS-CTYPE
     MOVE 1 TO WS-S
     CALL "MENU-CLICK" USING WS-PLAYER WS-S WS-BTN WS-CTYPE
     MOVE "implementation 40-1 3.4 pick up slot 0 and put down on slot 1: the stack is in own slot 1" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-CHEST, 1) * 10 + ECV-COUNT(WS-CHEST, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Closing the menu leaves the contents with the cart; the menu is the inventory menu again.
     CALL "MENU-CLOSE" USING WS-CONN
     MOVE "implementation 44-8 4.6 closing the menu keeps the contents with the cart and ends the container menu" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-CHEST, 2) + MN-WINDOW(WS-PLAYER) * 100 + MN-CSIZE(WS-PLAYER) * 10 + MN-CFAMILY(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MINECART-USE" USING WS-PLAYER WS-CHEST WS-USED
     MOVE 1 TO WS-S
     CALL "MENU-GET-X" USING WS-PLAYER WS-S WS-ITEM WS-COUNT WS-VAR
     MOVE "implementation 44-8 4.6 opened again, the menu shows the stack of own slot 1" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Reach: valid within 3.0 + 4.0 blocks of the box, closed by the tick when the player is further, or the cart is removed.
     CALL "MENU-STILL-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 44-8 4.6 the menu of a cart two blocks away is valid" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) + 8
     CALL "MENU-STILL-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 44-8 4.6 a player 8 blocks away from the cart's box is out of reach" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-TICK"
     MOVE "implementation 44-8 4.6 the tick closes the menu of a player out of reach" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-WINDOW(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) - 8
     CALL "MINECART-USE" USING WS-PLAYER WS-CHEST WS-USED
     CALL "ENTITY-REMOVE" USING WS-CHEST
     CALL "MENU-STILL-VALID" USING WS-PLAYER WS-VALID
     MOVE "implementation 44-8 4.6 a removed cart ends the menu" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN

*>   The hopper cart: the hopper menu with 5 slots (type 16).
     MOVE 3 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-HOPPER
     CALL "MINECART-USE" USING WS-PLAYER WS-HOPPER WS-USED
     MOVE "implementation 44-8 4.6 a hopper cart opens the hopper menu (type 16, 5 own slots)" TO TL-CASE
     MOVE 1605 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MN-TYPE(WS-PLAYER) * 100 + MN-CSIZE(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     MOVE 1 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-SLOT2
     CALL "ECV-OPEN" USING WS-CONN WS-SLOT2 WS-USED
     MOVE "implementation 44-8 4.6 a plain cart holds no container: ECV-OPEN refuses and the menu stays closed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 10 + MN-WINDOW(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cart menu replaces a menu that is open: the first window is closed, the counter moves on (container id 3 after the two opens above and this one).
     MOVE 2 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CHEST
     CALL "ECV-OPEN" USING WS-CONN WS-HOPPER WS-USED
     MOVE MN-WINDOW(WS-PLAYER) TO WS-S
     CALL "ECV-OPEN" USING WS-CONN WS-CHEST WS-USED
     MOVE "implementation 40-1 4.1 opening a second cart's menu closes the first and takes the next container id" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION MOD(WS-S, 100) + 1
     MOVE MN-WINDOW(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     CALL "ENTITY-REMOVE" USING WS-CHEST
*>   MINECART-USE on an entity that is no cart (the player's own tracker row) does nothing.
     CALL "MINECART-USE" USING WS-PLAYER WS-PROW WS-USED
     MOVE "implementation 44-8 4.6 interact on an entity that is no cart is not handled by MINECART-USE" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 10 + MN-WINDOW(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A furnace cart (kind 4) is neither boarded nor opened by an interact: no rider, no menu, not used.
     MOVE 4 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-FURNACE
     CALL "MINECART-USE" USING WS-PLAYER WS-FURNACE WS-USED
     MOVE "implementation 44-8 4.4.3 an interact on a furnace cart boards nobody and opens no menu" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 100 + EN-RIDER(WS-FURNACE) * 10 + MN-WINDOW(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-FURNACE
*>   The comparator signal and the slowdown factor of the contents.
     CALL "ECV-SIGNAL" USING WS-SLOT2 WS-SIGNAL
     MOVE "implementation 44-8 4.6 a plain cart holds no container: signal 0 whatever its row holds" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SIGNAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ECV-ROW-OPEN" USING WS-HOPPER
     CALL "ECV-SIGNAL" USING WS-HOPPER WS-SIGNAL
     MOVE "implementation 44-8 4.6 an empty hopper cart gives signal 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SIGNAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ECV-FACTOR" USING WS-HOPPER WS-F
     MOVE "implementation 44-8 4.6 an empty cart slows at 0.995" TO TL-CASE
     MOVE 995 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-F * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-STONE TO ECV-ITEM(WS-HOPPER, 1)
     MOVE 64 TO ECV-COUNT(WS-HOPPER, 1)
     CALL "ECV-SIGNAL" USING WS-HOPPER WS-SIGNAL
     MOVE "implementation 44-8 4.6 one full stack of the 5 slots gives signal floor(14 x 0.2) + 1 = 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-SIGNAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ECV-FACTOR" USING WS-HOPPER WS-F
     MOVE "implementation 44-8 4.6 signal 3 slows at 0.98 + 12 x 0.001 = 0.992" TO TL-CASE
     MOVE 992 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-F * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.3 TO EN-VX(WS-HOPPER)
     MOVE 0.1 TO EN-VY(WS-HOPPER)
     MOVE 0 TO EN-VZ(WS-HOPPER)
     CALL "PJ-FIND" USING EN-ID(WS-HOPPER) WS-SLOT
     CALL "MC-SLOWDOWN" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.4.1 step 11 the natural slowdown of the cart multiplies the speed by the container's factor (0.3 x 0.992) and zeroes y" TO TL-CASE
     MOVE 29760 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-HOPPER) * 100000 + EN-VY(WS-HOPPER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-STONE TO ECV-ITEM(WS-HOPPER, WS-I)
         MOVE 64 TO ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     CALL "ECV-SIGNAL" USING WS-HOPPER WS-SIGNAL
     CALL "ECV-FACTOR" USING WS-HOPPER WS-F
     MOVE "implementation 44-8 4.6 a full cart gives signal 15 and slows at 0.98" TO TL-CASE
     MOVE 15980 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SIGNAL * 1000 + WS-F * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO ECV-ITEM(WS-HOPPER, WS-I) ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM

*>   The hopper cart pulls one item a tick from the container above (a chest in the cell above the cart).
     MOVE "minecraft:chest" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = WS-FY + 2
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 2)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 2)
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 5)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 5)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 5)
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 the hopper cart pulls ONE item from the first stocked slot of the chest above" TO TL-CASE
     MOVE 1101 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 1000 + BE-SLOT-COUNT(WS-BE, 2) * 100 + BE-SLOT-COUNT(WS-BE, 5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 the next pulls empty slot 2 (the stack is cleared) and take slot 5" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 1000 + BE-SLOT-COUNT(WS-BE, 2) * 100 + BE-SLOT-COUNT(WS-BE, 5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 every chest slot is empty at last: the cart keeps its 3 stone" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE ECV-COUNT(WS-HOPPER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 3 TO BE-SLOT-COUNT(WS-BE, 3)
     MOVE 0 TO PJ-I6(WS-SLOT)
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 an activator rail that is powered disables the hopper cart: nothing is pulled" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 10 + BE-SLOT-COUNT(WS-BE, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PJ-I6(WS-SLOT)
*>   A container the cart does not take from: the chest's items stay when a stick no slot accepts fills the cart (a slot holding another item is not merged).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-STICK TO ECV-ITEM(WS-HOPPER, WS-I)
         MOVE 64 TO ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 a full cart takes nothing and the chest keeps its 3 stone" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO ECV-ITEM(WS-HOPPER, WS-I) ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     MOVE 62 TO ECV-COUNT(WS-HOPPER, 1)
     MOVE WS-STONE TO ECV-ITEM(WS-HOPPER, 1)
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 a pulled item merges into a stack of the same item (62 + 1)" TO TL-CASE
     MOVE 6302 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 100 + BE-SLOT-COUNT(WS-BE, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Without a container above: an item entity in the pickup column above the cart is taken whole and removed.
     MOVE 0 TO BE-SLOT-COUNT(WS-BE, 3) BE-SLOT-ITEM(WS-BE, 3)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO ECV-ITEM(WS-HOPPER, WS-I) ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     COMPUTE WS-MY = WS-Y + 1.2
     MOVE 3 TO WS-COUNT
     MOVE 0 TO WS-VAR
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-MY WS-Z WS-VX WS-VY WS-VZ WS-STONE WS-COUNT WS-DELAY WS-ITEM-E WS-VAR
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 an item entity above the cart is taken whole and discarded" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 100 + EN-USED(WS-ITEM-E)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An item that does not fit whole stays with the remainder (the cart has 62 of 64 in slot 1 and the other slots hold sticks).
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 5
         MOVE WS-STICK TO ECV-ITEM(WS-HOPPER, WS-I)
         MOVE 64 TO ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     MOVE 62 TO ECV-COUNT(WS-HOPPER, 1)
     MOVE 5 TO WS-COUNT
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-MY WS-Z WS-VX WS-VY WS-VZ WS-STONE WS-COUNT WS-DELAY WS-ITEM-E WS-VAR
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 five stone that do not fit whole: 2 go in, the entity keeps 3" TO TL-CASE
     MOVE 6403 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 100 + EN-ITEM-COUNT(WS-ITEM-E) * 1 + EN-USED(WS-ITEM-E) * 0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ITEM-E
*>   Beside the cart (inside its box inflated by 0.25, outside the pickup column): taken as well.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO ECV-ITEM(WS-HOPPER, WS-I) ECV-COUNT(WS-HOPPER, WS-I)
     END-PERFORM
     COMPUTE WS-MX = WS-X + 0.8
     COMPUTE WS-MY = WS-Y + 0.2
     MOVE 4 TO WS-COUNT
     CALL "GI-SPAWN-X" USING WS-DIM WS-MX WS-MY WS-Z WS-VX WS-VY WS-VZ WS-STONE WS-COUNT WS-DELAY WS-ITEM-E WS-VAR
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 an item entity at the cart's side (box inflated by 0.25) is taken too" TO TL-CASE
     MOVE 400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 100 + EN-USED(WS-ITEM-E)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second item further away is not taken.
     COMPUTE WS-MX = WS-X + 1.5
     CALL "GI-SPAWN-X" USING WS-DIM WS-MX WS-MY WS-Z WS-VX WS-VY WS-VZ WS-STONE WS-COUNT WS-DELAY WS-ITEM-E WS-VAR
     CALL "MC-HOPPER" USING WS-HOPPER WS-SLOT
     MOVE "implementation 44-8 4.6 an item entity 1.5 blocks away is left alone" TO TL-CASE
     MOVE 401 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-HOPPER, 1) * 100 + EN-USED(WS-ITEM-E)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ITEM-E

*>   A broken chest cart scatters its contents; a hit by a player (entity_drops on) also asks the piglins that see him; with entity_drops off the contents still scatter but the cart's item is not dropped.
     PERFORM CLEAR-DROPS
     MOVE 2 TO WS-KIND
     COMPUTE WS-X = PL-X(WS-PLAYER) + 4
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CHEST
     CALL "ECV-ROW-OPEN" USING WS-CHEST
     MOVE WS-STONE TO ECV-ITEM(WS-CHEST, 1)
     MOVE 64 TO ECV-COUNT(WS-CHEST, 1)
     MOVE WS-STICK TO ECV-ITEM(WS-CHEST, 20)
     MOVE 6 TO ECV-COUNT(WS-CHEST, 20)
     MOVE 5 TO WS-AMOUNT
     CALL "MINECART-HURT" USING WS-CHEST WS-AMOUNT WS-NONE WS-HANDLED
     PERFORM COUNT-DROPS
     MOVE "implementation 44-8 4.6 a broken chest cart drops 64 stone, 6 sticks and the cart's item" TO TL-CASE
     MOVE 64061 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-CARTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-DROPS
     MOVE 3 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CHEST
     CALL "ECV-ROW-OPEN" USING WS-CHEST
     MOVE WS-STONE TO ECV-ITEM(WS-CHEST, 1)
     MOVE 2 TO ECV-COUNT(WS-CHEST, 1)
     CALL "MINECART-HURT" USING WS-CHEST WS-AMOUNT WS-PLAYER WS-HANDLED
     PERFORM COUNT-DROPS
     MOVE "implementation 44-8 4.6 a player's hit breaks a hopper cart: its 2 stone and the cart's item drop" TO TL-CASE
     MOVE 2001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-CARTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity_drops" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM CLEAR-DROPS
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CHEST
     CALL "ECV-ROW-OPEN" USING WS-CHEST
     MOVE WS-STONE TO ECV-ITEM(WS-CHEST, 1)
     MOVE 7 TO ECV-COUNT(WS-CHEST, 1)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MINECART-HURT" USING WS-CHEST WS-AMOUNT WS-PLAYER WS-HANDLED
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM COUNT-DROPS
     MOVE "implementation 44-8 4.6 with entity_drops off a creative hit still scatters the 7 stone but drops no cart" TO TL-CASE
     MOVE 7000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-CARTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     STOP RUN.
 CLEAR-DROPS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 COUNT-DROPS.
     MOVE 0 TO WS-STONES WS-STICKS WS-CARTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             EVALUATE TRUE
                 WHEN EN-ITEM(WS-I) = WS-STONE
                     ADD EN-ITEM-COUNT(WS-I) TO WS-STONES
                 WHEN EN-ITEM(WS-I) = WS-STICK
                     ADD EN-ITEM-COUNT(WS-I) TO WS-STICKS
                 WHEN OTHER
                     ADD EN-ITEM-COUNT(WS-I) TO WS-CARTS
             END-EVALUATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-CART-BOX.
 COPY CORETEST.
 COPY MOBSPTEST.
