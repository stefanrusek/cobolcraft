*> Acceptance test (lane p49y; docs/protocol/30-redstone-8 sections 14.2 and 14.3): the emission sites of the other game events, in a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped
*> as a pass without it. The expected orders, positions, sources and states are the document's: projectile_shoot on the first tick after a land of that tick, a land at the hit location or the block centre with the
*> arrow as the source, no entity_damage for a damage of 0, entity_mount and entity_dismount at the vehicle's position with the rider as the source, prime_fuse of a primed TNT block (igniter or none),
*> lightning_strike on the first tick of a bolt, item_interact_start, eat and item_interact_finish of eating, container_open and container_close of a chest.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-EMITTERS.
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
 01 WS-GRASS               BINARY-LONG.
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
     MOVE "minecraft:short_grass" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GRASS
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TNTTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:apple" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-APPLE WS-APPLE-ROW WS-STATUS
     MOVE "minecraft:chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-CHEST-ROW WS-STATUS
     MOVE 0 TO WS-VX WS-VY
     MOVE 0.6 TO WS-VZ
     MOVE 201 TO WS-CY
     MOVE "T" TO TL-MODE

*>   1. An arrow in the air: projectile_shoot on its first tick only, at its position with the owner (the player's entity row) as the source; the second tick posts nothing.
     PERFORM NEW-SCENE
     COMPUTE WS-PX2 = WS-BX + 8.5
     MOVE 205.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "ARROW-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-VY WS-VZ WS-BASE PL-ENTITY-ID(WS-PLAYER) WS-ARROW
     PERFORM SNAP
     CALL "ARROW-STEP" USING WS-ARROW
     PERFORM LIST
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "an arrow in the air posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "its source is the owner's entity row" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "its position is the arrow's x" TO TL-CASE
     MOVE 8500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (GE-L-X(WS-LOG) - WS-BX) * 1000 + 0.5
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM SNAP
     CALL "ARROW-STEP" USING WS-ARROW
     PERFORM LIST
     MOVE SPACES TO WS-EXPECT
     MOVE "the second tick posts nothing" TO WS-WHY
     PERFORM CHECK-LIST
     CALL "ENTITY-REMOVE" USING WS-ARROW
     PERFORM END-SCENE

*>   2. An arrow that hits a zombie in its first tick: the zombie's entity_damage, then projectile_land at the hit (the arrow as the source), then projectile_shoot (the owner as the source).
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 12.5
     MOVE 201 TO EN-Y(WS-ZOMBIE)
     COMPUTE EN-Z(WS-ZOMBIE) = WS-BZ + 1.0
     COMPUTE WS-PX2 = WS-BX + 12.5
     MOVE 202 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "ARROW-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-VY WS-VZ WS-BASE PL-ENTITY-ID(WS-PLAYER) WS-ARROW
     PERFORM SNAP
     CALL "ARROW-STEP" USING WS-ARROW
     PERFORM LIST
     MOVE " entity_damage projectile_land projectile_shoot" TO WS-EXPECT
     MOVE "an arrow hitting a zombie in its first tick: damage, land, then shoot" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "the damage source is the victim itself" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE + 1, 128) + 1
     MOVE "the land's source is the arrow itself" TO TL-CASE
     MOVE WS-ARROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE + 2, 128) + 1
     MOVE "the shoot's source is the owner" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-DMG
     PERFORM SNAP
     CALL "HEALTH-MOB-DAMAGE" USING WS-ZOMBIE WS-DMG WS-CAUSE2 WS-NO-ATTACKER
     PERFORM LIST
     MOVE SPACES TO WS-EXPECT
     MOVE "a damage of 0 posts no entity_damage" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM END-SCENE

*>   3. An arrow that sticks in a block in its first tick: projectile_land at the block's centre with the block's state, then projectile_shoot.
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 16
     MOVE 202 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-STONE2
     COMPUTE WS-PX2 = WS-BX + 16.5
     MOVE 202.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     MOVE 0.8 TO WS-VZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-VY WS-VZ WS-BASE PL-ENTITY-ID(WS-PLAYER) WS-ARROW
     PERFORM SNAP
     CALL "ARROW-STEP" USING WS-ARROW
     PERFORM LIST
     MOVE " projectile_land projectile_shoot" TO WS-EXPECT
     MOVE "an arrow sticking in stone in its first tick: land at the block, then shoot" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "the land is at the block centre z" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (GE-L-Z(WS-LOG) - WS-BZ) * 1000 + 0.5
     PERFORM CASE-LINE
     MOVE "and carries the state of the block" TO TL-CASE
     MOVE WS-STONE2 TO TL-EXPECTED-N
     MOVE GE-L-STATE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-ARROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-AIR
     PERFORM END-SCENE

*>   4. Riding: a player mounts a horse (entity_mount at the horse's position, the player as the source), dismounts (entity_dismount, same), a camel's second rider leaves; a zombie mounts a chicken and drops off.
     PERFORM NEW-SCENE
     COMPUTE WS-PX2 = WS-BX + 3.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-HTYPE2 WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-HORSE
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     PERFORM SNAP
     CALL "MOB-RIDE-START" USING WS-PLAYER WS-HORSE WS-STARTED
     PERFORM LIST
     MOVE " entity_mount" TO WS-EXPECT
     MOVE "a player mounts a horse: entity_mount" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "its source is the rider" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its position is the vehicle's x" TO TL-CASE
     MOVE 3500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (GE-L-X(WS-LOG) - WS-BX) * 1000 + 0.5
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM SNAP
     CALL "MOB-RIDE-STOP" USING WS-HORSE
     PERFORM LIST
     MOVE " entity_dismount" TO WS-EXPECT
     MOVE "the rider dismounts: entity_dismount" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE WS-PLAYER TO EN-RIDER2(WS-HORSE)
     MOVE WS-HORSE TO EN-VEHICLE(WS-PROW)
     PERFORM SNAP
     CALL "MOB-RIDE-LEAVE2" USING WS-HORSE
     PERFORM LIST
     MOVE " entity_dismount" TO WS-EXPECT
     MOVE "a second rider leaves: entity_dismount" TO WS-WHY
     PERFORM CHECK-LIST
     CALL "ENTITY-REMOVE" USING WS-HORSE
     CALL "MOB-SPAWN" USING WS-DIM WS-CHTYPE WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-CHICKEN
     PERFORM SNAP
     CALL "MOB-MOUNT" USING WS-ZOMBIE WS-CHICKEN WS-MOUNTED
     PERFORM LIST
     MOVE " entity_mount" TO WS-EXPECT
     MOVE "a zombie mounts a chicken: entity_mount" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "its source is the mob rider" TO TL-CASE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM SNAP
     CALL "MOB-MOUNT-DROP" USING WS-ZOMBIE
     PERFORM LIST
     MOVE " entity_dismount" TO WS-EXPECT
     MOVE "and drops off: entity_dismount" TO WS-WHY
     PERFORM CHECK-LIST
     CALL "ENTITY-REMOVE" USING WS-CHICKEN
     PERFORM END-SCENE

*>   5. A TNT block set alight: prime_fuse at the block centre with the igniter as the source (none for redstone, fire and chains).
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 5
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-TNT
     PERFORM SNAP
     CALL "TNT-IGNITE-BY" USING WS-DIM WS-CX WS-CY WS-BZ WS-PROW
     PERFORM LIST
     MOVE " prime_fuse" TO WS-EXPECT
     MOVE "a TNT block ignited by a player posts prime_fuse" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "its source is the igniter" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its position the block centre y" TO TL-CASE
     MOVE 201500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GE-L-Y(WS-LOG) * 1000 + 0.5
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-TNT
     PERFORM SNAP
     CALL "TNT-IGNITE" USING WS-DIM WS-CX WS-CY WS-BZ
     PERFORM LIST
     MOVE " prime_fuse" TO WS-EXPECT
     MOVE "a TNT block ignited by redstone or fire posts prime_fuse too" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "with no source" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM END-SCENE

*>   6. A lightning bolt posts lightning_strike on its first tick only, the bolt as the source.
     PERFORM NEW-SCENE
     COMPUTE WS-PX2 = WS-BX + 16.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 16.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VISUAL WS-BOLT
     PERFORM SNAP
     CALL "LIGHTNING-STEP" USING WS-BOLT
     PERFORM LIST
     MOVE " lightning_strike" TO WS-EXPECT
     MOVE "a bolt posts lightning_strike on its first tick" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "its source is the bolt" TO TL-CASE
     MOVE WS-BOLT TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM SNAP
     CALL "LIGHTNING-STEP" USING WS-BOLT
     PERFORM LIST
     MOVE SPACES TO WS-EXPECT
     MOVE "the second tick posts none" TO WS-WHY
     PERFORM CHECK-LIST
     CALL "ENTITY-REMOVE" USING WS-BOLT
     PERFORM END-SCENE

*>   7. Eating: item_interact_start when the use starts, eat then item_interact_finish when the apple is eaten, all at the player.
     PERFORM NEW-SCENE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 6 TO PL-FOOD(WS-PLAYER)
     MOVE WS-APPLE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM SNAP
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM LIST
     MOVE " item_interact_start" TO WS-EXPECT
     MOVE "starting to eat posts item_interact_start" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM SNAP
     MOVE 40 TO WS-K
     CALL "TEST-TICKS" USING WS-K
     PERFORM LIST
     MOVE 0 TO WS-K
     INSPECT WS-LIST TALLYING WS-K FOR ALL " eat item_interact_finish"
     MOVE "finishing the apple posts eat then item_interact_finish" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM END-SCENE

*>   8. A chest: the first opener posts container_open at the chest's centre with the player as the source, the last closer container_close.
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 6
     MOVE 200 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-STONE2
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 201 TO WS-CY
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE " container_open" TO WS-EXPECT
     MOVE "opening a chest posts container_open" TO WS-WHY
     PERFORM CHECK-LIST
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "N" TO TL-MODE
     MOVE "its source is the player" TO TL-CASE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM SNAP
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE " container_close" TO WS-EXPECT
     MOVE "closing it posts container_close" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM END-SCENE

*>   8b. A hand with nothing in it places nothing: a click on the floor posts no block_place and leaves the cell above alone, short grass there (a replaceable block) stays too.
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 6
     MOVE 200 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-STONE2
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-FACE
     MOVE 200 TO WS-CY
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE SPACES TO WS-EXPECT
     MOVE "an empty hand on the floor posts no event" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-GRASS
     MOVE 200 TO WS-CY
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     MOVE 201 TO WS-CY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-N2
     MOVE "N" TO TL-MODE
     MOVE "an empty hand leaves the short grass above the floor" TO TL-CASE
     MOVE WS-GRASS TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     PERFORM END-SCENE

*>   9. A spawn egg, flint and steel and shears: entity_place at the target cell, block_place at the fire cell, prime_fuse with the player as the igniter, shear at the sheep (the player as the source).
     MOVE "minecraft:sheep" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SHTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:sheep_spawn_egg" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EGG-ITEM WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:flint_and_steel" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-FLINT WS-ITEM-ROW2 WS-STATUS
     MOVE "minecraft:shears" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHEARS WS-ITEM-ROW2 WS-STATUS
     PERFORM NEW-SCENE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     COMPUTE WS-CX = WS-BX + 4
     MOVE 200 TO WS-CY
     MOVE 1 TO WS-FACE
     MOVE WS-EGG-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE 0 TO WS-N2
     INSPECT WS-LIST TALLYING WS-N2 FOR ALL " entity_place"
     MOVE "N" TO TL-MODE
     MOVE "a spawn egg used on the floor posts entity_place" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-SHTYPE AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE WS-FLINT TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE 0 TO WS-N2
     INSPECT WS-LIST TALLYING WS-N2 FOR ALL " block_place"
     MOVE "N" TO TL-MODE
     MOVE "flint and steel on the floor posts block_place for the fire" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-TNT
     MOVE WS-FLINT TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM SNAP
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-BZ WS-FACE WS-SEQ
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS2
     PERFORM LIST
     MOVE 0 TO WS-N2
     INSPECT WS-LIST TALLYING WS-N2 FOR ALL " prime_fuse"
     MOVE "N" TO TL-MODE
     MOVE "flint and steel on a TNT block posts prime_fuse" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-LOG = FUNCTION MOD(WS-BEFORE, 128) + 1
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-TYPE(WS-I) = WS-TNTTYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     COMPUTE WS-PX2 = WS-BX + 8.5
     MOVE 201 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SHTYPE WS-PX2 WS-PY2 WS-PZ2 WS-YAW WS-SHEEP
     MOVE WS-SHEARS TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO EN-WOOL(WS-SHEEP) EN-VARIANT(WS-SHEEP)
     PERFORM SNAP
     CALL "MOB-SHEAR-USE" USING WS-PLAYER WS-SHEEP
     PERFORM LIST
     MOVE 0 TO WS-N2
     INSPECT WS-LIST TALLYING WS-N2 FOR ALL " shear"
     MOVE "N" TO TL-MODE
     MOVE "shearing a sheep posts shear" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "T" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-SHEEP
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
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 30-8 emitters: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
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
*>   A primed TNT left standing (scene 5 lights two) would block the placements of the scenes after it (a primed TNT blocks building).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-TYPE(WS-I) = WS-TNTTYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     .
 END PROGRAM ACC-US15-EMITTERS.
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
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     GOBACK.
 END PROGRAM WBD-OPEN.
