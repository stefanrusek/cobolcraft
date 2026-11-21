*> Implementation test (002-lane-mobs3, T4210; docs/protocol/28 section 9.4 repair_with_xp, 17 section 5.3 Mending, 21 section 8.2 pickup): an orb
*> picked up first repairs one damaged item that carries Mending (chosen uniformly among the main hand, the off hand and the armor), xp x 2
*> durability, repaired = min(durability, damage), the remainder xp - repaired x xp / durability goes on to the next candidate and what is left
*> is the player's experience. Worked example of 28 section 11 item 5: xp 5 on an item with 4 damage repairs 4 and leaves 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-XP-MENDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CMENU.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/mending-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-ENCH                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-HELD-SLOT           BINARY-LONG.
 01 WS-XP                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-DAMAGE2             BINARY-LONG.
 01 WS-DAMAGE-SET          BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     CALL "TEST-STANDARD-TABLES"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:iron_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PICK WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-HELMET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:mending" TO WS-KEY
     CALL "LOOT-ENCH-ID" USING WS-KEY WS-ENCH
     MOVE "N" TO TL-MODE
*>   The pickaxe in the main hand: Mending, 4 damage.
     COMPUTE WS-HELD-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-PICK TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 4 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT)
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     CALL "SP-GET-DAMAGE" USING WS-PICK PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT) WS-DAMAGE
     MOVE "test xp mending: xp 5 on 4 damage repairs all 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test xp mending: and leaves 5 - (4 x 5) / 10 = 3 points" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Undamaged: the item is no candidate, the points are untouched.
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     MOVE "test xp mending: an undamaged item takes nothing, all 5 points remain" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A big wear: 30 damage, 5 points repair 10 and use up everything.
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 30 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT)
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     CALL "SP-GET-DAMAGE" USING WS-PICK PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT) WS-DAMAGE
     MOVE "test xp mending: xp 5 on 30 damage repairs 10" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test xp mending: and nothing is left over" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without Mending a damaged item is no candidate.
     MOVE 0 TO WS-HANDLE
     MOVE 20 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT)
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     MOVE "test xp mending: a damaged item without Mending takes nothing" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The remainder passes to a second candidate: a worn helmet with Mending (damage 100) after the pickaxe (damage 2): 5 points give the
*>   pickaxe 2 (use 1) and 3 points, whose candidates are then the helmet alone (the pickaxe is whole): 3 x 2 = 6 repair, 0 left.
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 2 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT)
     MOVE WS-HELMET TO MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 100 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO MN-EQUIP-VAR(WS-PLAYER, 4)
*>   A helmet and a pickaxe, both candidates: the pick is random, so the sum is what is certain: 5 points either way give
*>   2 x 5 = 10 durability in all, so the two damages together fall by 10 when the helmet is first and by 2 + 6 = 8 when the pickaxe is.
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     CALL "SP-GET-DAMAGE" USING WS-PICK PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT) WS-DAMAGE
     CALL "SP-GET-DAMAGE" USING WS-HELMET MN-EQUIP-VAR(WS-PLAYER, 4) WS-DAMAGE2
     COMPUTE TL-OBSERVED-N = 102 - WS-DAMAGE - WS-DAMAGE2
     MOVE "test xp mending: with a pickaxe and a helmet 8 or 10 durability are repaired in all" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO WS-BEFORE
     IF TL-OBSERVED-N = 8 OR TL-OBSERVED-N = 10
         MOVE 1 TO WS-BEFORE
     END-IF
     MOVE WS-BEFORE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Only an armour piece is a candidate (the main hand is empty): the helmet, damage 100, takes 5 x 2 = 10 and its handle is stored back in
*>   armour slot 4 (the window is closed, so the slot is sent to the player).
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
     MOVE WS-HELMET TO MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 100 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO MN-EQUIP-VAR(WS-PLAYER, 4)
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     CALL "SP-GET-DAMAGE" USING WS-HELMET MN-EQUIP-VAR(WS-PLAYER, 4) WS-DAMAGE2
     MOVE "test xp mending: a worn helmet alone is mended: 100 - 5 x 2 = 90 damage left" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     MOVE WS-DAMAGE2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 4) MN-EQUIP-VAR(WS-PLAYER, 4)
*>   The off-hand (slot 5, menu slot 45) holds the only damaged Mending item.
     MOVE WS-PICK TO MN-EQUIP-ITEM(WS-PLAYER, 5)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 30 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO MN-EQUIP-VAR(WS-PLAYER, 5)
     MOVE 5 TO WS-XP
     CALL "XP-MEND" USING WS-PLAYER WS-XP WS-LEFT
     CALL "SP-GET-DAMAGE" USING WS-PICK MN-EQUIP-VAR(WS-PLAYER, 5) WS-DAMAGE2
     MOVE "test xp mending: an off-hand pickaxe is mended: 30 - 10 = 20 damage left" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-DAMAGE2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5) MN-EQUIP-VAR(WS-PLAYER, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD-SLOT)
*>   The pickup: an orb of 5 on a pickaxe with 4 damage gives the player the remaining 3.
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 4) MN-EQUIP-VAR(WS-PLAYER, 4)
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
     MOVE 4 TO WS-DAMAGE-SET
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE-SET
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT)
     MOVE PL-XP-TOTAL(WS-PLAYER) TO WS-BEFORE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "XP-ORB-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-FIVE WS-ROW-A
     MOVE 0 TO PL-XP-DELAY(WS-PLAYER)
     CALL "XP-ORBS-TICK"
     COMPUTE TL-OBSERVED-N = PL-XP-TOTAL(WS-PLAYER) - WS-BEFORE
     MOVE "test xp mending: picking up an orb of 5 with a 4-damage Mending pickaxe gives 3 points" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-GET-DAMAGE" USING WS-PICK PL-SLOT-VAR(WS-PLAYER, WS-HELD-SLOT) WS-DAMAGE
     MOVE "test xp mending: and the pickaxe is whole" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-XP-MENDING.
 COPY CORETEST.
