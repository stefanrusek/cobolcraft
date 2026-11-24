*> Implementation test (wrap C round 6, T24205; docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 3.9, 44-x2 section 5, 44-6 section 2.9): the chest boat and
*> chest raft menu. A chest boat opens its generic_9x3 menu (27 own slots, menu family 14 of container-entity.cob) when the player sneaks or when it cannot take a passenger (a rider
*> aboard or the boat under water), else the player boards; a boat without a chest never opens one; the menu moves stacks, is valid while the boat lasts, and a destroyed boat scatters its
*> contents (also with entity_drops off, then without the boat item and without angering). Opening it and a player's hit angers the piglins that see the player (also for a chest minecart).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-CHEST-BOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 COPY ECVSTATE.
 COPY PROTO.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alex".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 48.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-SYAW                FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BOAT                BINARY-LONG.
 01 WS-RAFT                BINARY-LONG.
 01 WS-PLAIN               BINARY-LONG.
 01 WS-CART                BINARY-LONG.
 01 WS-HOPPER              BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SZ                  BINARY-LONG.
 01 WS-MT                  BINARY-LONG.
 01 WS-MNAME               PIC X(48).
 01 WS-NL                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BTN                 BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 5.
 01 WS-STONES              BINARY-LONG.
 01 WS-STICKS              BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-D2                  PIC 99.
 01 WS-D2B                 PIC 99.
 01 WS-D2C                 PIC 99.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-P1
     MOVE PL-DIM(WS-P1) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-P1)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-P1)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-P1)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE PL-CONN(WS-P1) TO WS-CONN
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-P2
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-MODE(WS-P1) PL-MODE(WS-P2) PL-SNEAKING(WS-P1) PL-SNEAKING(WS-P2) PL-YAW(WS-P1) PL-YAW(WS-P2)
     COMPUTE PL-X(WS-P2) = PL-X(WS-P1) + 1
     MOVE PL-Y(WS-P1) TO PL-Y(WS-P2)
     MOVE PL-Z(WS-P1) TO PL-Z(WS-P2)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX = PL-X(WS-P1) + 1.5
     COMPUTE WS-PY = WS-FY + 1
     MOVE PL-Z(WS-P1) TO WS-PZ
     MOVE PL-Y(WS-P1) TO WS-Y
     COMPUTE WS-X = PL-X(WS-P1) + 6
     MOVE PL-Z(WS-P1) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-SYAW WS-PIG
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A free chest boat takes a player who does not sneak (the base riding rule) and opens nothing.
     MOVE "minecraft:oak_chest_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-BOAT
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     MOVE "implementation 44-8 3.9 a free chest boat boards a player who does not sneak and opens no menu" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 1000 + MN-WINDOW(WS-P1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 3.9 the rider is the player" TO TL-CASE
     MOVE WS-P1 TO TL-EXPECTED-N
     MOVE EN-RIDER(WS-BOAT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A second player cannot board (the chest boat takes one passenger): the click opens the menu, generic_9x3, 27 own slots, family 14, container id 1; one Open Screen goes out.
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     CALL "BOAT-USE" USING WS-P2 WS-BOAT WS-USED
     MOVE "implementation 44-8 3.9 a chest boat with a rider opens its menu for another player who does not sneak" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 3.9 the menu is generic_9x3 with 27 own slots, family 14, container id 1" TO TL-CASE
     MOVE 2271401 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MN-TYPE(WS-P2) * 1000000 + MN-CSIZE(WS-P2) * 10000 + MN-CFAMILY(WS-P2) * 100 + MN-WINDOW(WS-P2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 3.9 the menu is bound to the boat (its row and its id) and the rider stays alone" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BOAT * 1000000 + EN-ID(WS-BOAT)
     COMPUTE TL-OBSERVED-N = MN-BENCH-X(WS-P2) * 1000000 + MN-BENCH-Y(WS-P2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 3.9 the second player did not board" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-RIDER2(WS-BOAT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN2 WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 60 "
     MOVE "implementation 44-8 3.9 Open Screen (60) went out once to the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-TALLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN2
     COMPUTE PL-X(WS-P2) = PL-X(WS-P1) - 10

*>   The menu moves stacks through the generic click engine: a quick move of the first hotbar stack lands in the boat's first own slot.
     MOVE 0 TO PL-SNEAKING(WS-P1)
     CALL "MOB-RIDE-STOP" USING WS-BOAT
     MOVE 1 TO PL-SNEAKING(WS-P1)
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     MOVE 0 TO PL-SNEAKING(WS-P1)
     MOVE "implementation 44-8 3.9 a sneaking player opens the menu of a free chest boat and does not board" TO TL-CASE
     MOVE 1001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 1000 + MN-WINDOW(WS-P1) + EN-RIDER(WS-BOAT) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-P1, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-P1, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-P1, 1)
     MOVE 54 TO WS-S
     MOVE 0 TO WS-BTN
     MOVE 1 TO WS-CTYPE
     CALL "MENU-CLICK" USING WS-P1 WS-S WS-BTN WS-CTYPE
     MOVE "implementation 40-1 7.3 a quick move of a hotbar stack fills the boat's own slot 0 (5 stone) and empties the hotbar slot" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = ECV-COUNT(WS-BOAT, 1) * 10 + PL-SLOT-COUNT(WS-P1, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-x2 5 the stack that went in is stone" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE ECV-ITEM(WS-BOAT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-STILL-VALID" USING WS-P1 WS-VALID
     MOVE "implementation 44-x2 5 the menu is valid while the boat lasts and the player is within reach" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     MOVE "implementation 44-x2 5 the contents stay with the boat when the menu closes" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE ECV-COUNT(WS-BOAT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A boat under water cannot take a passenger either: the click opens the menu.
     MOVE 1 TO EN-BT-STATUS(WS-BOAT)
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     MOVE "implementation 44-8 3.1 a chest boat under water opens its menu for a player who does not sneak" TO TL-CASE
     MOVE 1002 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 1000 + MN-WINDOW(WS-P1) + EN-RIDER(WS-BOAT) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     MOVE 0 TO EN-BT-STATUS(WS-BOAT)

*>   The menu closes when the boat is gone.
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     CALL "ENTITY-REMOVE" USING WS-BOAT
     CALL "MENU-STILL-VALID" USING WS-P1 WS-VALID
     MOVE "implementation 44-x2 5 the menu is no longer valid once the boat is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN

*>   The title is the entity's name: entity.minecraft.<key> of the chest boat and the chest raft.
     MOVE "minecraft:bamboo_chest_raft" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-RAFT
     CALL "ECV-KIND" USING WS-RAFT WS-SZ WS-MT WS-MNAME WS-NL
     MOVE "implementation 44-8 3.9 a chest raft's menu is generic_9x3 titled entity.minecraft.bamboo_chest_raft" TO TL-CASE
     MOVE "02/27/34/entity.minecraft.bamboo_chest_raft" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-MT TO WS-D2
     MOVE WS-SZ TO WS-D2B
     MOVE WS-NL TO WS-D2C
     STRING WS-D2 "/" WS-D2B "/" WS-D2C "/" WS-MNAME(1:WS-NL) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   A boat without a chest never opens a menu, sneaking or not (it keeps its riding rules).
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-PLAIN
     CALL "ECV-KIND" USING WS-PLAIN WS-SZ WS-MT WS-MNAME WS-NL
     MOVE "implementation 44-8 3.9 a boat without a chest holds no container" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SZ TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SNEAKING(WS-P1)
     CALL "BOAT-USE" USING WS-P1 WS-PLAIN WS-USED
     MOVE 0 TO PL-SNEAKING(WS-P1)
     MOVE "implementation 44-8 3.9 a sneaking player gets neither a menu nor a seat on a boat without a chest" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 1000 + MN-WINDOW(WS-P1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-PLAIN
     CALL "ENTITY-REMOVE" USING WS-RAFT

*>   Opening a chest boat angers the idle piglin that sees the player (600 ticks, target the player; the earlier menus calmed it down below); a creative player angers nobody.
     PERFORM CALM-PIGLIN
     MOVE "minecraft:oak_chest_boat" TO WS-KEY
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-BOAT
     MOVE 1 TO PL-SNEAKING(WS-P1)
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     MOVE 0 TO PL-SNEAKING(WS-P1)
     MOVE "implementation 44-6 2.9 opening a chest boat angers the piglin that sees the player for 600 ticks" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-6 2.9 and its target is the player" TO TL-CASE
     MOVE WS-P1 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     PERFORM CALM-PIGLIN

*>   A chest minecart does the same when it opens; a hopper minecart does not.
     MOVE 2 TO WS-KIND
     COMPUTE WS-X = PL-X(WS-P1) + 1.5
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-PY WS-PZ WS-CART
     CALL "MINECART-USE" USING WS-P1 WS-CART WS-USED
     MOVE "implementation 44-6 2.9 opening a chest minecart angers the piglin that sees the player" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     PERFORM CALM-PIGLIN
     MOVE 3 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-PY WS-PZ WS-HOPPER
     CALL "MINECART-USE" USING WS-P1 WS-HOPPER WS-USED
     MOVE "implementation 44-6 2.9 opening a hopper minecart angers nobody (only the chest minecart is stated)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN
     CALL "ENTITY-REMOVE" USING WS-CART
     CALL "ENTITY-REMOVE" USING WS-HOPPER
     MOVE 1 TO PL-MODE(WS-P1)
     MOVE 1 TO PL-SNEAKING(WS-P1)
     CALL "BOAT-USE" USING WS-P1 WS-BOAT WS-USED
     MOVE 0 TO PL-SNEAKING(WS-P1)
     MOVE 0 TO PL-MODE(WS-P1)
     MOVE "implementation 44-6 2.9 a creative player angers nobody" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MENU-CLOSE" USING WS-CONN

*>   A broken chest boat scatters its contents (64 stone, 6 sticks) and drops the boat item; a player's hit (entity_drops on) angers the piglin that sees him.
     CALL "ECV-ROW-OPEN" USING WS-BOAT
     MOVE WS-STONE TO ECV-ITEM(WS-BOAT, 1)
     MOVE 64 TO ECV-COUNT(WS-BOAT, 1)
     MOVE WS-STICK TO ECV-ITEM(WS-BOAT, 20)
     MOVE 6 TO ECV-COUNT(WS-BOAT, 20)
     PERFORM CLEAR-DROPS
     CALL "BOAT-HURT" USING WS-BOAT WS-AMOUNT WS-P1
     PERFORM COUNT-DROPS
     MOVE "implementation 44-8 3.9 a broken chest boat drops 64 stone, 6 sticks and the boat's item" TO TL-CASE
     MOVE 64061 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 3.9 the boat is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-BOAT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-x2 5 the player's hit that destroyed it angers the piglin that sees him (entity_drops on)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CALM-PIGLIN

*>   Without a player (no attacker) the contents scatter and nobody is angered; with entity_drops off the contents still scatter but there is no boat item and no anger.
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-BOAT
     CALL "ECV-ROW-OPEN" USING WS-BOAT
     MOVE WS-STONE TO ECV-ITEM(WS-BOAT, 1)
     MOVE 7 TO ECV-COUNT(WS-BOAT, 1)
     PERFORM CLEAR-DROPS
     CALL "BOAT-HURT" USING WS-BOAT WS-AMOUNT WS-ZERO
     PERFORM COUNT-DROPS
     MOVE "implementation 44-x2 5 a boat broken without a player scatters 7 stone, drops the boat item and angers nobody" TO TL-CASE
     MOVE 7001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-x2 5 and no piglin is angered" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity_drops" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-BOAT
     CALL "ECV-ROW-OPEN" USING WS-BOAT
     MOVE WS-STONE TO ECV-ITEM(WS-BOAT, 1)
     MOVE 9 TO ECV-COUNT(WS-BOAT, 1)
     PERFORM CLEAR-DROPS
     CALL "BOAT-HURT" USING WS-BOAT WS-AMOUNT WS-P1
     PERFORM COUNT-DROPS
     MOVE "implementation 44-x2 5 with entity_drops off the 9 stone still scatter but no boat item drops" TO TL-CASE
     MOVE 9000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STONES * 1000 + WS-STICKS * 10 + WS-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-x2 5 and with entity_drops off nobody is angered" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative hit removes the boat without the item, the contents still scatter.
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-YAW WS-KEY WS-BOAT
     CALL "ECV-ROW-OPEN" USING WS-BOAT
     MOVE WS-STICK TO ECV-ITEM(WS-BOAT, 3)
     MOVE 4 TO ECV-COUNT(WS-BOAT, 3)
     PERFORM CLEAR-DROPS
     MOVE 1 TO PL-MODE(WS-P1)
     CALL "BOAT-HURT" USING WS-BOAT WS-AMOUNT WS-P1
     MOVE 0 TO PL-MODE(WS-P1)
     PERFORM COUNT-DROPS
     MOVE "implementation 44-8 3.9 a creative hit removes the chest boat and its 4 sticks still scatter" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-STICKS * 10 + WS-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     STOP RUN.
 CALM-PIGLIN.
     MOVE 0 TO EN-ANGER(WS-PIG) EN-TARGET(WS-PIG) EN-TARGET-ID(WS-PIG).
 CLEAR-DROPS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 COUNT-DROPS.
     MOVE 0 TO WS-STONES WS-STICKS WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             EVALUATE TRUE
                 WHEN EN-ITEM(WS-I) = WS-STONE
                     ADD EN-ITEM-COUNT(WS-I) TO WS-STONES
                 WHEN EN-ITEM(WS-I) = WS-STICK
                     ADD EN-ITEM-COUNT(WS-I) TO WS-STICKS
                 WHEN OTHER
                     ADD EN-ITEM-COUNT(WS-I) TO WS-ITEMS
             END-EVALUATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-CHEST-BOAT.
 COPY CORETEST.
 COPY MOBSPTEST.
