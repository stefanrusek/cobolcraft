*> Acceptance test (lane p49z; docs/protocol/30-redstone-8 sections 14.3.1 to 14.3.10): the remaining emission sites of the entity, item and block events, in a standard world of the generated vanilla data pack
*> (CC_GENERATED_DIR), skipped as a pass without it: entity_damage and entity_die of armor stands, items, boats, minecarts and hanging entities, equip and unequip, item_interact_start and finish of releasing and
*> casting, entity_interact of mob interactions, entity_action (knot, wolf, ravager, camel, armadillo), entity_place (chicken, armadillo, evoker, end crystal), block_place of a turtle's egg, prime_fuse of a chain.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-EMITTERS3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WARDENSTATE.
 COPY GAMEEVENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZCODE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-IDS                 PIC X(1024).
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-MTYPE               BINARY-LONG.
 01 WS-BATTYPE             BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-LADDER              BINARY-LONG.
 01 WS-THING               BINARY-LONG VALUE 0.
 01 WS-THING-TYPE          BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-EXPECT              PIC X(400).
 01 WS-WHY                 PIC X(150).
 01 WS-AX                  FLOAT-LONG.
 01 WS-LIST                PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-CHICKEN             BINARY-LONG.
 01 WS-HTYPE2              BINARY-LONG.
 01 WS-CHTYPE              BINARY-LONG.
 01 WS-STONE2              BINARY-LONG.
 01 WS-TNT                 BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-APPLE               BINARY-LONG.
 01 WS-APPLE-ROW           PIC X(270).
 01 WS-CHEST               BINARY-LONG.
 01 WS-CHEST-ROW           PIC X(270).
 01 WS-BEFORE-N            BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-PX2                 FLOAT-LONG.
 01 WS-PY2                 FLOAT-LONG.
 01 WS-PZ2                 FLOAT-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-DMG                 BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-CAUSE2              BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-IDS2                PIC X(1024).
 01 WS-CZ2                 BINARY-LONG.
 01 WS-TNTTYPE             BINARY-LONG.
 01 WS-SHTYPE              BINARY-LONG.
 01 WS-SHEEP               BINARY-LONG.
 01 WS-EGG-ITEM            BINARY-LONG.
 01 WS-FLINT               BINARY-LONG.
 01 WS-SHEARS              BINARY-LONG.
 01 WS-ITEM-ROW2           PIC X(270).
 01 WS-N2                  BINARY-LONG.
 01 WS-CHEST-STATE         BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-BORDER-CX           FLOAT-LONG.
 01 WS-BORDER-CZ           FLOAT-LONG.
 01 WS-BORDER-SIZE         FLOAT-LONG.
 01 WS-BORDER-ZERO         FLOAT-LONG VALUE 0.
 01 WS-BORDER-WIDE         FLOAT-LONG.
 COPY CITEMS.
 COPY PROJSTATE.
 COPY CITEMPHYS.
 01 WS-PK                  BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-F0                  FLOAT-LONG VALUE 0.
 01 WS-F00                 FLOAT-LONG VALUE 0.
 01 WS-F1                  FLOAT-LONG VALUE 1.
 01 WS-POWER               BINARY-LONG VALUE 1.
 01 WS-IDX                 BINARY-LONG.
 01 WS-E-SRC               BINARY-LONG.
 01 WS-E-X                 BINARY-LONG.
 01 WS-E-Y                 BINARY-LONG.
 01 WS-E-Z                 BINARY-LONG.
 01 WS-E-STATE             BINARY-LONG.
 01 WS-CASE-BUF            PIC X(240).
 01 WS-SLOT                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-FX2                 FLOAT-LONG.
 01 WS-OUT                 BINARY-LONG.
 COPY CMENU.
 01 WS-I-HELM              BINARY-LONG.
 01 WS-I-BOOTS             BINARY-LONG.
 01 WS-I-CHEST             BINARY-LONG.
 01 WS-I-SHIELD            BINARY-LONG.
 01 WS-I-POTION            BINARY-LONG.
 01 WS-I-BONE              BINARY-LONG.
 01 WS-I-LEAD              BINARY-LONG.
 01 WS-I-BUCKET            BINARY-LONG.
 01 WS-I-SHEARS            BINARY-LONG.
 01 WS-I-CRYSTAL           BINARY-LONG.
 01 WS-I-ROD               BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-VAR0                BINARY-LONG VALUE 0.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-SAVE-BORN           BINARY-DOUBLE.
 01 WS-MOB                 BINARY-LONG.
 01 WS-MOB2                BINARY-LONG.
 01 WS-MTYPE2              BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-SAPLING             BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-HX2                 BINARY-LONG.
 01 WS-HZ2                 BINARY-LONG.
 01 WS-STATE-NOW           BINARY-LONG.
 01 WS-ITEMROW             BINARY-LONG.
 01 WS-DMG-F               FLOAT-LONG.
 01 WS-YAW-D               FLOAT-LONG VALUE 0.
 01 WS-PITCH-D             FLOAT-LONG VALUE 0.
 01 WS-BKEY                PIC X(112).
 01 WS-CAND-W.
    05 WS-CW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-CAND-H.
    05 WS-CH               BINARY-LONG OCCURS 64 TIMES.
 01 WS-FACE-N              BINARY-LONG VALUE 2.
 01 WS-NOT                 BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-STAND              BINARY-LONG.
 01 WS-COWTYPE            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WBD-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US15 20§15 warden body: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     MOVE 201 TO PL-Y(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 201 TO WS-BY
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE 12001 TO CW-TIME
     MOVE 1000 TO CW-TICKS


     MOVE "minecraft:horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE2 WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CHTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE2
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-TNT
     MOVE "minecraft:apple" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-APPLE WS-APPLE-ROW WS-STATUS
     MOVE "minecraft:chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-CHEST-ROW WS-STATUS
     MOVE 0 TO WS-VX WS-VY
     MOVE 0.6 TO WS-VZ
     MOVE 201 TO WS-CY
     MOVE "T" TO TL-MODE

     MOVE "minecraft:iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-HELM WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:iron_boots" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-BOOTS WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-CHEST WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:shield" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-SHIELD WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:potion" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-POTION WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:bone_meal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-BONE WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:lead" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-LEAD WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-BUCKET WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:shears" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-SHEARS WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:end_crystal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-CRYSTAL WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-I-ROD WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:oak_sapling" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAPLING
     MOVE "minecraft:obsidian" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-OBSIDIAN
     PERFORM CHECK-RESET

*>   1. An armor stand (14.3.2): the first hit wobbles it (entity_damage, the player as the source), a second hit within 5 ticks breaks it (entity_die, the player as the killer), a creative player's hit kills it at once.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-PX2 = WS-BX + 3.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 3.5
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-STAND
     PERFORM SNAP
     CALL "ARMOR-STAND-HIT" USING WS-STAND WS-PLAYER WS-DONE
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 the first hit on an armor stand posts entity_damage" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 3500 TO WS-E-X
     MOVE 201000 TO WS-E-Y
     MOVE 3500 TO WS-E-Z
     MOVE "14.3.1 the stand's damage: the causing player, not the victim" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "ARMOR-STAND-HIT" USING WS-STAND WS-PLAYER WS-DONE
     MOVE " entity_die" TO WS-EXPECT
     MOVE "14.3.2 the second hit within 5 ticks posts entity_die" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 3500 TO WS-E-X
     MOVE "14.3.2 the stand's entity_die: the killer" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-STAND
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM SNAP
     CALL "ARMOR-STAND-HIT" USING WS-STAND WS-PLAYER WS-DONE
     MOVE " entity_die" TO WS-EXPECT
     MOVE "14.3.2 a creative player's hit kills the stand: entity_die only" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM END-SCENE

*>   2. An item entity (14.3.2): entity_damage at the item with no causing entity, after its health dropped and also when it is destroyed.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-PX2 = WS-BX + 4.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 4.5
     MOVE 1 TO WS-K
     CALL "IP-AT-LOCATION" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-APPLE WS-K WS-VAR0 WS-ITEMROW
     MOVE 0 TO IP-I-INVULN(WS-ITEMROW)
     MOVE 1 TO WS-DMG-F
     PERFORM SNAP
     CALL "IP-HURT" USING WS-ITEMROW IP-DT-EXPLOSION WS-DMG-F IP-SRC-OTHER WS-OUT
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 an item hurt but alive posts entity_damage" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE 0 TO WS-E-SRC
     MOVE 4500 TO WS-E-X
     MOVE "14.3.2 the item's damage has no causing entity here" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 100 TO WS-DMG-F
     PERFORM SNAP
     CALL "IP-HURT" USING WS-ITEMROW IP-DT-EXPLOSION WS-DMG-F IP-SRC-OTHER WS-OUT
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 a destroyed item posts entity_damage before it goes" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM END-SCENE

*>   3. A boat and a minecart (14.3.2): entity_damage at the vehicle with the attacking player as the source (none without an attacker).
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE "minecraft:oak_boat" TO WS-BKEY
     COMPUTE WS-PX2 = WS-BX + 6.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 4.5
     CALL "BOAT-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-BKEY WS-MOB
     MOVE 1 TO WS-K
     PERFORM SNAP
     CALL "BOAT-HURT" USING WS-MOB WS-K WS-PLAYER
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 a boat hit by a player posts entity_damage" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 6500 TO WS-E-X
     MOVE "14.3.1 the boat's damage: the attacking player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 0 TO WS-Z1
     PERFORM SNAP
     CALL "BOAT-HURT" USING WS-MOB WS-K WS-Z1
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 a boat hit by nothing posts entity_damage too" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE 0 TO WS-E-SRC
     MOVE "14.3.1 and its source is none" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE 1 TO WS-K
     COMPUTE WS-PX2 = WS-BX + 8.5
     CALL "MINECART-SPAWN" USING WS-K WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-MOB
     PERFORM SNAP
     CALL "MINECART-HURT" USING WS-MOB WS-K WS-PLAYER WS-HANDLED
     MOVE " entity_damage" TO WS-EXPECT
     MOVE "14.3.2 a minecart hit by a player posts entity_damage" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 8500 TO WS-E-X
     MOVE "14.3.1 the cart's damage: the attacking player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM END-SCENE

*>   4. A hanging entity killed (14.3.2): a creative player's hit on an item frame and on a painting posts entity_die with the player as the killer; an explosion has no player: the frame is its own source.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-CX = WS-BX + 2
     MOVE 201 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-STONE2
     COMPUTE WS-CX = WS-BX + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-STONE2
     MOVE 0 TO WS-K
     COMPUTE WS-CX = WS-BX + 2
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-CX WS-CY WS-CZ2 WS-FACE-N WS-K WS-MOB
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM SNAP
     CALL "ITEM-FRAME-HURT" USING WS-MOB WS-PLAYER WS-NOT WS-DONE
     MOVE " entity_die" TO WS-EXPECT
     MOVE "14.3.2 a creative player breaking an empty item frame posts entity_die" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 2500 TO WS-E-X
     MOVE "14.3.2 the frame's entity_die: the killer" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-CX WS-CY WS-CZ2 WS-FACE-N WS-K WS-MOB
     MOVE 0 TO WS-Z1
     MOVE 1 TO WS-Z2
     PERFORM SNAP
     CALL "ITEM-FRAME-HURT" USING WS-MOB WS-Z1 WS-Z2 WS-DONE
     MOVE " entity_die" TO WS-EXPECT
     MOVE "14.3.2 an exploded frame posts entity_die with no killer" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE "14.3.2 the frame is its own source" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 1 TO WS-CW(1)
     MOVE 1 TO WS-CH(1)
     MOVE 1 TO WS-K
     COMPUTE WS-CX = WS-BX + 4
     CALL "PAINTING-PLACE" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-FACE-N WS-K WS-CAND-W WS-CAND-H WS-MOB
     PERFORM SNAP
     CALL "PAINTING-HURT" USING WS-MOB WS-PLAYER WS-DONE
     MOVE " entity_die" TO WS-EXPECT
     MOVE "14.3.2 a painting broken by a player posts entity_die" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 4500 TO WS-E-X
     MOVE "14.3.2 the painting's entity_die: the killer" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>   5. Equip and unequip (14.3.8): a worn armor slot changing posts equip (an equippable new stack) or unequip at the player; the same stack, a hand slot, a spectator and the first tick post nothing.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE 5 TO WS-MS
     MOVE 1 TO WS-K
     PERFORM SNAP
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-HELM WS-K WS-VAR0
     MOVE " equip" TO WS-EXPECT
     MOVE "14.3.8 putting on a helmet posts equip" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 201000 TO WS-E-Y
     MOVE 500 TO WS-E-Z
     MOVE "14.3.8 the equip: at the player, the player as the source" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-HELM WS-TWO WS-VAR0
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 the same item with another count posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     MOVE 36 TO WS-MS
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-HELM WS-K WS-Z3
     MOVE 45 TO WS-MS
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-SHIELD WS-K WS-Z3
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 the hotbar and the off-hand post nothing for a player" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     MOVE 5 TO WS-MS
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-Z1 WS-Z2 WS-Z3
     MOVE " unequip" TO WS-EXPECT
     MOVE "14.3.8 taking the helmet off posts unequip" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM SNAP
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-HELM WS-K WS-Z3
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 a spectator posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-Z1 WS-Z2 WS-Z3
     MOVE EN-BORN(WS-PROW) TO WS-SAVE-BORN
     MOVE CW-TICKS TO EN-BORN(WS-PROW)
     PERFORM SNAP
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-I-HELM WS-K WS-Z3
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 the entity's first tick posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE WS-SAVE-BORN TO EN-BORN(WS-PROW)
     CALL "MENU-SET-X" USING WS-PLAYER WS-MS WS-Z1 WS-Z2 WS-Z3
     MOVE 36 TO WS-MS
     PERFORM SNAP
     CALL "MENU-PLAYER-SET-X" USING WS-PLAYER WS-MS WS-I-BOOTS WS-K WS-Z3
     MOVE 40 TO WS-MS
     CALL "MENU-PLAYER-SET-X" USING WS-PLAYER WS-MS WS-I-SHIELD WS-K WS-Z3
     MOVE " equip" TO WS-EXPECT
     MOVE "14.3.8 boots by the slot writer post equip, the off-hand shield nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 36 TO WS-MS
     CALL "MENU-PLAYER-SET-X" USING WS-PLAYER WS-MS WS-Z1 WS-Z2 WS-Z3
     MOVE 40 TO WS-MS
     CALL "MENU-PLAYER-SET-X" USING WS-PLAYER WS-MS WS-Z1 WS-Z2 WS-Z3
     MOVE WS-I-CHEST TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM SNAP
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE " equip" TO WS-EXPECT
     MOVE "14.3.8 putting on a held chestplate with use posts equip" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM END-SCENE

*>   6. Releasing items (14.3.8): eating and drinking cancelled, a raised shield lowered and a fishing rod reeled in post item_interact_finish; raising a shield and casting a rod post item_interact_start; bone meal posts the finish.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE WS-APPLE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 6 TO PL-FOOD(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM SNAP
     CALL "HUNGER-CANCEL" USING WS-PLAYER
     MOVE " item_interact_finish" TO WS-EXPECT
     MOVE "14.3.8 releasing an apple posts item_interact_finish" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE "14.3.8 the finish: at the user, the user as the source" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "HUNGER-CANCEL" USING WS-PLAYER
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 releasing with nothing in use posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE WS-I-POTION TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM SNAP
     CALL "HUNGER-CANCEL" USING WS-PLAYER
     MOVE " item_interact_finish" TO WS-EXPECT
     MOVE "14.3.8 cancelling a drink posts item_interact_finish" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "COMBAT-BLOCK-RAISE" USING WS-PLAYER WS-Z1
     MOVE " item_interact_start" TO WS-EXPECT
     MOVE "14.3.8 raising a shield posts item_interact_start" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     CALL "COMBAT-BLOCK-RAISE" USING WS-PLAYER WS-Z1
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 raising it again posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "COMBAT-BLOCK-LOWER" USING WS-PLAYER
     PERFORM SNAP
     CALL "COMBAT-BLOCK-LOWER" USING WS-PLAYER
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.8 lowering it again posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "COMBAT-BLOCK-RAISE" USING WS-PLAYER WS-Z1
     PERFORM SNAP
     CALL "COMBAT-BLOCK-LOWER" USING WS-PLAYER
     MOVE " item_interact_finish" TO WS-EXPECT
     MOVE "14.3.8 lowering a raised shield posts item_interact_finish" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE WS-I-ROD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "BOBBER-USE" USING WS-CONN WS-YAW-D WS-PITCH-D
     MOVE " item_interact_start" TO WS-EXPECT
     MOVE "14.3.8 casting a fishing rod posts item_interact_start" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     CALL "BOBBER-USE" USING WS-CONN WS-YAW-D WS-PITCH-D
     MOVE " item_interact_finish" TO WS-EXPECT
     MOVE "14.3.8 reeling the line in posts item_interact_finish" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     COMPUTE WS-CX = WS-BX + 8
     MOVE 201 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-SAPLING
     MOVE WS-I-BONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "GB-BONEMEAL-USE" USING WS-CONN WS-CX WS-CY WS-CZ2 WS-HANDLED
     MOVE " item_interact_finish" TO WS-EXPECT
     MOVE "14.3.8 applying bone meal posts item_interact_finish" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-AIR
     PERFORM END-SCENE

*>   7. Interacting with mobs (14.3.7, 14.3.9): shearing a mooshroom posts shear then entity_interact, milking a cow and leashing and unleashing post entity_interact (the player as the source, at the mob).
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE "minecraft:mooshroom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COWTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE WS-I-SHEARS TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM SNAP
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-MOB) WS-Z1 WS-Z2
     MOVE " shear entity_interact" TO WS-EXPECT
     MOVE "14.3.9 14.3.7 shearing a mooshroom posts shear then entity_interact" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 2500 TO WS-E-Z
     MOVE "14.3.9 the mooshroom's shear: at the mob, the player" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE "14.3.7 the mooshroom's entity_interact: at the mob, the player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-TYPE(WS-I) = WS-COWTYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     CALL "MOB-SPAWN" USING WS-DIM WS-COWTYPE WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE WS-I-BUCKET TO PL-SLOT-ITEM(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-MOB) WS-Z1 WS-Z2
     MOVE " entity_interact" TO WS-EXPECT
     MOVE "14.3.7 milking a cow posts entity_interact" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE WS-I-LEAD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-MOB) WS-Z1 WS-Z2
     MOVE " entity_interact" TO WS-EXPECT
     MOVE "14.3.7 leashing a cow posts entity_interact" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 2500 TO WS-E-Z
     MOVE "14.3.7 the leash interaction: at the cow, the player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-MOB) WS-Z1 WS-Z2
     MOVE " entity_interact" TO WS-EXPECT
     MOVE "14.3.7 untying it posts entity_interact" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-MOB) WS-Z1 WS-Z2
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.7 an empty hand on a cow does nothing (no entity_interact)" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM END-SCENE

*>   8. Entity actions (14.3.7): the leash knot a player ties its mobs to (the knot's block centre), a wolf shaking off water, a ravager's roar, a camel's dash and sit, an armadillo rolling up and out.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-CX = WS-BX + 3
     MOVE 201 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 3
     CALL "MOB-KNOT-GET" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-KNOT WS-CREATED
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COWTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 3.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COWTYPE WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE WS-PLAYER TO EN-LEASH(WS-MOB)
     PERFORM SNAP
     CALL "MOB-KNOT-INTERACT" USING WS-PLAYER WS-KNOT WS-Z1 WS-OUT
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 tying a held mob to a leash knot posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 3500 TO WS-E-X
     MOVE 201500 TO WS-E-Y
     MOVE 3500 TO WS-E-Z
     MOVE "14.3.7 the knot's entity_action: the block centre, the player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENTITY-REMOVE" USING WS-KNOT
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE "minecraft:wolf" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 10.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE 1 TO EN-WOLF-WET(WS-MOB)
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     MOVE 0 TO EN-WOLF-SHAKE(WS-MOB)
     PERFORM SNAP
     CALL "WOLF-WET-STEP" USING WS-MOB WS-Z1 WS-Z2
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 a wet wolf starting to shake posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 10500 TO WS-E-X
     MOVE "14.3.7 the wolf's entity_action: itself" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "WOLF-WET-STEP" USING WS-MOB WS-Z1 WS-Z2
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.7 a wolf already shaking posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE "minecraft:ravager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 16.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     PERFORM SNAP
     CALL "RAVAGER-ROAR" USING WS-MOB
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 a ravager's roar posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 16500 TO WS-E-X
     MOVE "14.3.7 the roar's entity_action: the ravager" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE "minecraft:camel" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 12.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE 0 TO EN-CAMEL-DASH(WS-MOB)
     PERFORM SNAP
     CALL "M44-CAMEL-DASH" USING WS-MOB WS-OUT
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 a camel's dash posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 12500 TO WS-E-X
     MOVE "14.3.7 the dash's entity_action: the camel" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "M44-CAMEL-DASH" USING WS-MOB WS-OUT
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.7 a dash on cooldown posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO EN-CAMEL-POSE-T(WS-MOB)
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     MOVE 400 TO WS-NOW
     PERFORM SNAP
     CALL "M44-CAMEL-SIT" USING WS-MOB WS-NOW WS-Z1 WS-Z2 WS-OUT
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 a camel sitting down posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     PERFORM SNAP
     CALL "M44-CAMEL-SIT" USING WS-MOB WS-NOW WS-Z1 WS-Z2 WS-OUT
     MOVE SPACES TO WS-EXPECT
     MOVE "14.3.7 no pose change posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE "minecraft:armadillo" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 14.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE 1 TO EN-SCUTE(WS-MOB)
     MOVE 0 TO EN-DANGER(WS-MOB) EN-ARMA(WS-MOB) EN-VARIANT(WS-MOB)
     PERFORM SNAP
     CALL "ARMADILLO-TICK" USING WS-MOB WS-WALK
     MOVE " entity_place" TO WS-EXPECT
     MOVE "14.3.3 an armadillo dropping a scute posts entity_place" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 14500 TO WS-E-X
     MOVE "14.3.3 the scute's entity_place: itself" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     MOVE 100000 TO EN-SCUTE(WS-MOB)
     MOVE 100 TO EN-DANGER(WS-MOB)
     PERFORM SNAP
     CALL "ARMADILLO-TICK" USING WS-MOB WS-WALK
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 an armadillo rolling up posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 2 TO EN-ARMA(WS-MOB)
     MOVE 0 TO EN-DANGER(WS-MOB)
     PERFORM SNAP
     CALL "ARMADILLO-TICK" USING WS-MOB WS-WALK
     MOVE " entity_action" TO WS-EXPECT
     MOVE "14.3.7 an armadillo rolling out posts entity_action" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM END-SCENE

*>   9. Other entity_place and block_place (14.3.3, 14.3.4): an egg-laying chicken, an evoker's three vexes (at the cells they appear in), a turtle's egg block, an end crystal item (the cell above the clicked block).
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 5.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 9.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE 1 TO EN-EGG(WS-MOB)
     MOVE 0 TO EN-VARIANT(WS-MOB) EN-JOCKEY(WS-MOB)
     MOVE 0 TO EN-MOBAGE(WS-MOB)
     PERFORM SNAP
     CALL "MOB-LIFE-TICK" USING WS-MOB WS-HX WS-HZ WS-WALK
     MOVE " entity_place" TO WS-EXPECT
     MOVE "14.3.3 a chicken laying an egg posts entity_place" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 5500 TO WS-E-X
     MOVE "14.3.3 the egg's entity_place: the chicken" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE "minecraft:evoker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX2 = WS-BX + 10.5
     COMPUTE WS-PZ2 = WS-BZ + 9.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     PERFORM SNAP
     CALL "EVK-SUMMON" USING WS-MOB
     MOVE " entity_place entity_place entity_place" TO WS-EXPECT
     MOVE "14.3.3 an evoker summoning three vexes posts three entity_place" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE "14.3.3 the first vex's entity_place: the evoker" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 2 TO WS-IDX
     MOVE "14.3.3 the third vex's entity_place: the evoker" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND WS-I > WS-MOB
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-MOB
     MOVE "minecraft:turtle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE2 WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-HX2 = WS-BX + 12
     MOVE 201 TO WS-CY
     COMPUTE WS-HZ2 = WS-BZ + 12
     COMPUTE WS-PX2 = WS-HX2 + 0.5
     COMPUTE WS-PZ2 = WS-HZ2 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-MTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-MOB
     MOVE 1 TO EN-TURTLE-EGG(WS-MOB)
     MOVE WS-HX2 TO EN-HOME-X(WS-MOB)
     MOVE WS-CY TO EN-HOME-Y(WS-MOB)
     MOVE WS-HZ2 TO EN-HOME-Z(WS-MOB)
     MOVE 200 TO EN-TURTLE-LAY(WS-MOB)
     PERFORM SNAP
     CALL "TURTLE-TICK" USING WS-MOB WS-HX WS-HZ WS-WALK
     MOVE " block_place" TO WS-EXPECT
     MOVE "14.3.4 a turtle laying its egg posts block_place" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-HX2 WS-CY WS-HZ2 WS-STATE-NOW
     MOVE 0 TO WS-IDX
     MOVE WS-MOB TO WS-E-SRC
     MOVE 12500 TO WS-E-X
     MOVE 201500 TO WS-E-Y
     MOVE 12500 TO WS-E-Z
     MOVE WS-STATE-NOW TO WS-E-STATE
     MOVE "14.3.4 the egg's block_place: the cell centre, the turtle, the egg's state" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX2 WS-CY WS-HZ2 WS-AIR
     CALL "ENTITY-REMOVE" USING WS-MOB
     PERFORM END-SCENE

     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-CX = WS-BX + 9
     MOVE 200 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-OBSIDIAN
     MOVE WS-I-CRYSTAL TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-FACE
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-CZ2 WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     MOVE " entity_place" TO WS-EXPECT
     MOVE "14.3.3 an end crystal item used on obsidian posts entity_place" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 9500 TO WS-E-X
     MOVE 201500 TO WS-E-Y
     MOVE 3500 TO WS-E-Z
     MOVE "14.3.3 the crystal's entity_place: the cell above the clicked block, the player" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
                 IF EN-USED(WS-K) = 1 AND EN-ID(WS-K) = PJ-ENT(WS-I)
                     CALL "ENTITY-REMOVE" USING WS-K
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM END-SCENE

*>  10. A TNT block blown up by an explosion chain (14.3.1, 14.3.10): prime_fuse at the block centre with no igniter.
     PERFORM NEW-SCENE
     MOVE 0 TO WS-Z1 WS-Z2 WS-Z3
     COMPUTE WS-CX = WS-BX + 5
     MOVE 201 TO WS-CY
     PERFORM SNAP
     CALL "TNT-WAS-EXPLODED" USING WS-DIM WS-CX WS-CY WS-BZ
     MOVE " prime_fuse" TO WS-EXPECT
     MOVE "14.3.10 a TNT block caught by an explosion posts prime_fuse" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE 0 TO WS-E-SRC
     MOVE 5500 TO WS-E-X
     MOVE 201500 TO WS-E-Y
     MOVE 500 TO WS-E-Z
     MOVE "14.3.1 the chain's prime_fuse: the block centre, no source" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-TYPE(WS-I) = WS-TNTTYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     PERFORM END-SCENE

     STOP RUN.


*> A thing of type WS-THING-TYPE (row WS-THING) at the warden's place with health 0 (set it for a mob), in the warden's dimension.
 NEW-THING.
     CALL "ENTITY-ALLOC" USING WS-THING
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-THING)
     MOVE WS-THING-TYPE TO EN-TYPE(WS-THING)
     MOVE WS-DIM TO EN-DIM(WS-THING)
     MOVE EN-X(WS-WARDEN) TO EN-X(WS-THING)
     MOVE EN-Y(WS-WARDEN) TO EN-Y(WS-THING)
     MOVE EN-Z(WS-WARDEN) TO EN-Z(WS-THING)
     .


*> The log counter before a case.
 SNAP.
     MOVE GE-COUNT TO WS-BEFORE
     .

*> WS-LIST: " <event>" for every event posted since SNAP, in order.
 LIST.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     COMPUTE WS-K = WS-BEFORE
     PERFORM UNTIL WS-K >= GE-COUNT
         ADD 1 TO WS-K
         COMPUTE WS-LOG = FUNCTION MOD(WS-K - 1, 128) + 1
         STRING " " DELIMITED BY SIZE FUNCTION TRIM(GE-L-NAME(WS-LOG)) DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     .

 CHECK-LIST.
     MOVE WS-WHY TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CASE-LINE
     .

 CASE-LINE.
     MOVE SPACES TO WS-CASE-BUF
     STRING "acceptance US15 30-8 emitters: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-CASE-BUF
     MOVE WS-CASE-BUF TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The ids a viewer received hold exactly one Set Entity Data (101) (the warden may have moved too).
 CASE-IDS-101.
     MOVE 0 TO WS-K
     INSPECT WS-IDS TALLYING WS-K FOR ALL "101"
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     .

*> A warden 10 blocks west of the player (survival, alive) and a zombie at the player's place: no cooldowns, the dig cooldown running, the sensor scan in 5 ticks.
 NEW-SCENE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         INITIALIZE WD-ENTRY(WS-I)
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-X0 = WS-BX + 0.5 - 10
     MOVE 201 TO WS-Y
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-ZCODE = CORE-MAX-PLAYERS + WS-ZOMBIE
     MOVE EN-X(WS-ZOMBIE) TO WS-X0
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 100
     MOVE 0 TO WS-STATE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     .

 END-SCENE.
     IF EN-USED(WS-WARDEN) = 1
         CALL "ENTITY-REMOVE" USING WS-WARDEN
     END-IF
     IF EN-USED(WS-ZOMBIE) = 1
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-IF
     IF WS-THING > 0
         IF EN-USED(WS-THING) = 1
             CALL "ENTITY-REMOVE" USING WS-THING
         END-IF
         MOVE 0 TO WS-THING
     END-IF
     .
*> The checks of one logged event (WS-IDX counts from the first event after SNAP): source row WS-E-SRC, position WS-E-X (relative to the player's block x), WS-E-Y (absolute), WS-E-Z (relative to the block z)
*> in thousandths, state WS-E-STATE; a value of -1 (state -2) is not checked. WS-WHY names the event.
 CHECK-AT.
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE + WS-IDX, 128) + 1
     MOVE "N" TO TL-MODE
     IF WS-E-SRC >= 0
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-WHY) " source" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E-SRC TO TL-EXPECTED-N
         MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
         PERFORM CASE-LINE
     END-IF
     IF WS-E-X >= 0
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-WHY) " x" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E-X TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = (GE-L-X(WS-LOG) - WS-BX) * 1000 + 0.5
         PERFORM CASE-LINE
     END-IF
     IF WS-E-Y >= 0
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-WHY) " y" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E-Y TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = GE-L-Y(WS-LOG) * 1000 + 0.5
         PERFORM CASE-LINE
     END-IF
     IF WS-E-Z >= 0
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-WHY) " z" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E-Z TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = (GE-L-Z(WS-LOG) - WS-BZ) * 1000 + 0.5
         PERFORM CASE-LINE
     END-IF
     IF WS-E-STATE >= -1
         MOVE SPACES TO TL-CASE
         STRING FUNCTION TRIM(WS-WHY) " state" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-E-STATE TO TL-EXPECTED-N
         MOVE GE-L-STATE(WS-LOG) TO TL-OBSERVED-N
         PERFORM CASE-LINE
     END-IF
     MOVE "T" TO TL-MODE
     .

*> Everything checked becomes "not checked" again.
 CHECK-RESET.
     MOVE -1 TO WS-E-SRC WS-E-X WS-E-Y WS-E-Z
     MOVE -2 TO WS-E-STATE
     .

*> The list of events since SNAP must be WS-EXPECT.
 CHECK-EVENTS.
     PERFORM LIST
     PERFORM CHECK-LIST
     .

 END PROGRAM ACC-US15-EMITTERS3.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY BETEST.

*> WBD-OPEN USING skip out: 1 and nothing opened when the generated packs are missing; else a standard world (view distance 2, hostile mobs on: a warden is a hostile mob and is removed when they are off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WBD-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 LINKAGE SECTION.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SKIP.
     MOVE 0 TO L-SKIP
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE 1 TO L-SKIP
         GOBACK
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE 0 TO CS-WEATHER-CHANGES
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     GOBACK.
 END PROGRAM WBD-OPEN.
