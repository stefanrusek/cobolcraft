*> Acceptance test (lane p49z; docs/protocol/30-redstone-8 sections 14.2 and 14.3.2): the projectile events of the fireball, shulker bullet, llama spit, snowball, ender pearl, egg, dragon fireball, fishing hook,
*> firework rocket and eye of ender, in a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped as a pass without it: projectile_shoot on the first tick (before or after the move by class,
*> the owner as the source), projectile_land at the hit location or the block centre with the block's state (the projectile as the source), a bullet's entity_damage, a rocket's explode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-EMITTERS2.
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
 01 WS-ROD                 BINARY-LONG.
 01 WS-ROD-ROW             PIC X(270).
 01 WS-HOOK                BINARY-LONG.
 01 WS-YAW-D               FLOAT-LONG VALUE 0.
 01 WS-PITCH-D             FLOAT-LONG VALUE 0.
 01 WS-TKEY                PIC X(112).
 01 WS-DAMAGE-F            FLOAT-LONG.
 01 WS-STAND               BINARY-LONG.
 01 WS-ITEMROW             BINARY-LONG.
 01 WS-TIME-SAVE           BINARY-DOUBLE.
 01 WS-LIST2               PIC X(400).
 01 WS-Z1                 BINARY-LONG VALUE 0.
 01 WS-Z2                 BINARY-LONG VALUE 0.
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

     COMPUTE WS-CX = WS-BX + 16
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-FY WS-BZ WS-FLOOR
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ROD WS-ROD-ROW WS-STATUS
     PERFORM CHECK-RESET

*>   1. A small fireball in the air (AbstractHurtingProjectile, 14.2.1): projectile_shoot on its first tick after the move, the owner as the source; the second tick posts nothing.
     PERFORM NEW-SCENE
     MOVE 2 TO WS-PK
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 205.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.6
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-F1 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 a fireball in the air posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 205500 TO WS-E-Y
     MOVE 790 TO WS-E-Z
     MOVE "14.2.1 the fireball's shoot (after the move, the owner)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE SPACES TO WS-EXPECT
     MOVE "14.2.1 the second tick posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-PJ
     PERFORM END-SCENE

*>   2. A small fireball into a stone block in its first tick: shoot at the hit location (after the move), then land at the block centre with the block's state, the fireball as the source.
     PERFORM NEW-SCENE
     COMPUTE WS-CX = WS-BX + 10
     MOVE 202 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-STONE2
     COMPUTE WS-PX2 = WS-BX + 10.5
     MOVE 202.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.9
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-F1 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot projectile_land" TO WS-EXPECT
     MOVE "14.2.1 14.2.2 a fireball hitting stone: shoot, then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 10500 TO WS-E-X
     MOVE 202500 TO WS-E-Y
     MOVE 995 TO WS-E-Z
     MOVE "14.2.1 the shoot at the hit point" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 10500 TO WS-E-X
     MOVE 202500 TO WS-E-Y
     MOVE 1500 TO WS-E-Z
     MOVE WS-STONE2 TO WS-E-STATE
     MOVE "14.2.2 the land at the block centre (the projectile, the block's state)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-AIR
     PERFORM END-SCENE

*>   3. A small fireball into a zombie in its first tick: shoot (the hit is resolved after Projectile.tick), the zombie's entity_damage, then land at the hit location (the fireball as the source).
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 12.5
     MOVE 201 TO EN-Y(WS-ZOMBIE)
     COMPUTE EN-Z(WS-ZOMBIE) = WS-BZ + 1.0
     COMPUTE WS-PX2 = WS-BX + 12.5
     MOVE 202 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.6
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-F1 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot entity_damage projectile_land" TO WS-EXPECT
     MOVE "14.2.2 14.3.2 a fireball hitting a zombie: shoot, the damage, then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE "14.2.1 the shoot's owner" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-ZOMBIE TO WS-E-SRC
     MOVE "14.3.1 the zombie's damage source is the victim" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 2 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 12500 TO WS-E-X
     MOVE 202000 TO WS-E-Y
     MOVE 790 TO WS-E-Z
     MOVE "14.2.2 the land at the hit location (the projectile)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>   4. A snowball (ThrowableProjectile) into stone: shoot at the hit point, then land at the block centre.
     PERFORM NEW-SCENE
     MOVE 3 TO WS-PK
     COMPUTE WS-CX = WS-BX + 14
     MOVE 202 TO WS-CY
     COMPUTE WS-CZ2 = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-STONE2
     COMPUTE WS-PX2 = WS-BX + 14.5
     MOVE 202.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.9
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-F1 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot projectile_land" TO WS-EXPECT
     MOVE "14.2.1 a snowball hitting stone: shoot, then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 999 TO WS-E-Z
     MOVE "14.2.1 the snowball's shoot at the hit point" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 14500 TO WS-E-X
     MOVE 1500 TO WS-E-Z
     MOVE WS-STONE2 TO WS-E-STATE
     MOVE "14.2.2 the snowball's land" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ2 WS-AIR
     PERFORM END-SCENE

*>   5. A shulker bullet (Projectile.tick first) that strikes the floor in its first tick: shoot at the position before the move, land at the floor block, then its entity_damage (destroy, the bullet as the source).
     PERFORM NEW-SCENE
     MOVE 4 TO WS-PK
     COMPUTE WS-PX2 = WS-BX + 16.5
     MOVE 201.03 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F1 WS-F00 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot projectile_land entity_damage" TO WS-EXPECT
     MOVE "14.2.1 14.2.4 a shulker bullet hitting the floor: shoot, land, entity_damage" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 16500 TO WS-E-X
     MOVE 201030 TO WS-E-Y
     MOVE 500 TO WS-E-Z
     MOVE "14.2.1 the bullet's shoot (position before the move)" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 200500 TO WS-E-Y
     MOVE WS-FLOOR TO WS-E-STATE
     MOVE "14.2.2 the bullet's land at the floor block" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 2 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 201030 TO WS-E-Y
     MOVE -2 TO WS-E-STATE
     MOVE "14.2.4 the bullet's entity_damage" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>   6. Llama spit (Projectile.tick first): shoot at the position before the move.
     PERFORM NEW-SCENE
     MOVE 5 TO WS-PK
     COMPUTE WS-PX2 = WS-BX + 18.5
     MOVE 205.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     CALL "PROJ-SPAWN" USING WS-PK WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-F1 WS-POWER PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PROJ-STEP" USING WS-PJ
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 llama spit posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-Z
     MOVE "14.2.1 the spit's shoot at the position before the move" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-PJ
     PERFORM END-SCENE

*>   7. An ender pearl in the air (ThrowableProjectile through THROWN-FLY2): shoot on the first tick after the move, the owner as the source; the second tick posts nothing.
     PERFORM NEW-SCENE
     MOVE 4 TO WS-PK
     MOVE "minecraft:ender_pearl" TO WS-TKEY
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 205.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     MOVE 0.5 TO WS-VZ
     CALL "THROWN-SPAWN" USING WS-PK WS-TKEY WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-F00 WS-VZ PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "PEARL-STEP" USING WS-PJ
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 an ender pearl posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 995 TO WS-E-Z
     MOVE "14.2.1 the pearl's shoot (after the move, the owner)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "PEARL-STEP" USING WS-PJ
     MOVE SPACES TO WS-EXPECT
     MOVE "14.2.1 the pearl's second tick posts nothing" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-PJ
     PERFORM END-SCENE

*>   8. A thrown egg into the floor in its first tick: shoot at the hit point (the last free point), then land at the floor block with its state.
     PERFORM NEW-SCENE
     MOVE 6 TO WS-PK
     MOVE "minecraft:egg" TO WS-TKEY
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 201.02 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 8.5
     MOVE -0.1 TO WS-VY
     CALL "THROWN-SPAWN" USING WS-PK WS-TKEY WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-VY WS-F00 PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "EGG-STEP" USING WS-PJ
     MOVE " projectile_shoot projectile_land" TO WS-EXPECT
     MOVE "14.2.1 14.2.2 an egg hitting the floor: shoot, then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 201020 TO WS-E-Y
     MOVE "14.2.1 the egg's shoot" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 200500 TO WS-E-Y
     MOVE 8500 TO WS-E-Z
     MOVE WS-FLOOR TO WS-E-STATE
     MOVE "14.2.2 the egg's land at the floor block" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>   9. A dragon fireball (AbstractHurtingProjectile through THROWN-FLY2) from a dispenser-like source (no owner) into the floor: shoot with no source, then land.
     PERFORM NEW-SCENE
     MOVE 18 TO WS-PK
     MOVE "minecraft:dragon_fireball" TO WS-TKEY
     COMPUTE WS-PX2 = WS-BX + 2.5
     MOVE 201.02 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 8.5
     MOVE -0.2 TO WS-VY
     MOVE 0 TO WS-OUT
     CALL "THROWN-SPAWN" USING WS-PK WS-TKEY WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-VY WS-F00 WS-OUT WS-PJ
     PERFORM SNAP
     CALL "DFIRE-STEP" USING WS-PJ
     MOVE " projectile_shoot projectile_land" TO WS-EXPECT
     MOVE "14.2.1 an owner-less dragon fireball: shoot with no source, then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE 0 TO WS-E-SRC
     MOVE "14.2.1 the shoot of a projectile without an owner" TO WS-WHY
     PERFORM CHECK-AT
     MOVE 1 TO WS-IDX
     MOVE WS-PJ TO WS-E-SRC
     MOVE 2500 TO WS-E-X
     MOVE WS-FLOOR TO WS-E-STATE
     MOVE "14.2.2 the fireball's land" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>  10. A fishing hook (Projectile.tick early): shoot on its first tick at the position before its move, the player as the source.
     PERFORM NEW-SCENE
     MOVE WS-ROD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW-D WS-PITCH-D WS-HOOK
     PERFORM SNAP
     CALL "BOBBER-STEP" USING WS-HOOK
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 a fishing hook posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 202620 TO WS-E-Y
     MOVE 800 TO WS-E-Z
     MOVE "14.2.1 the hook's shoot (before its move, the player)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-HOOK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM END-SCENE

*>  10b. A fishing hook that reaches the floor: land once at the floor block (the hook model runs the flight every tick, so a resting hook does not land again).
     PERFORM NEW-SCENE
     MOVE WS-ROD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 7 TO WS-PK
     MOVE "minecraft:fishing_bobber" TO WS-TKEY
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 201.02 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 8.5
     MOVE -0.1 TO WS-VY
     CALL "THROWN-SPAWN" USING WS-PK WS-TKEY WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-F0 WS-VY WS-F00 PL-ENTITY-ID(WS-PLAYER) WS-HOOK
     PERFORM SNAP
     CALL "BOBBER-STEP" USING WS-HOOK
     MOVE " projectile_shoot projectile_land" TO WS-EXPECT
     MOVE "14.2.2 a fishing hook reaching the floor posts shoot then land" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 1 TO WS-IDX
     MOVE WS-HOOK TO WS-E-SRC
     MOVE 200500 TO WS-E-Y
     MOVE 8500 TO WS-E-Z
     MOVE WS-FLOOR TO WS-E-STATE
     MOVE "14.2.2 the hook's land at the floor block" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM SNAP
     CALL "BOBBER-STEP" USING WS-HOOK
     MOVE SPACES TO WS-EXPECT
     MOVE "14.2.2 a hook lying on the floor does not land again" TO WS-WHY
     PERFORM CHECK-EVENTS
     CALL "ENTITY-REMOVE" USING WS-HOOK
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM END-SCENE

*>  11. A firework rocket (Projectile.tick first): shoot at its position with the owner; when it flies out, explode at the rocket's position with the owner as the source (14.2.4).
     PERFORM NEW-SCENE
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 205.5 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 10.5
     MOVE 1 TO WS-K
     MOVE 0 TO WS-Z1 WS-Z2
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-K WS-Z1 WS-Z2 PL-ENTITY-ID(WS-PLAYER) WS-PJ
     PERFORM SNAP
     CALL "FIREWORK-STEP" USING WS-PJ
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 a firework rocket posts projectile_shoot on its first tick" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 205500 TO WS-E-Y
     MOVE 10500 TO WS-E-Z
     MOVE "14.2.1 the rocket's shoot (position before its move)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "PJ-FIND" USING EN-ID(WS-PJ) WS-SLOT
     MOVE PJ-I2(WS-SLOT) TO PJ-I1(WS-SLOT)
     PERFORM SNAP
     CALL "FIREWORK-STEP" USING WS-PJ
     MOVE " explode" TO WS-EXPECT
     MOVE "14.2.4 a rocket at the end of its flight posts explode" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 205550 TO WS-E-Y
     MOVE 10500 TO WS-E-Z
     MOVE "14.2.4 the explode at the rocket's position (the owner)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     PERFORM END-SCENE

*>  12. An eye of ender (not a Projectile: EnderEyeItem.use posts projectile_shoot itself at the spawn position, the player as the source).
     PERFORM NEW-SCENE
     COMPUTE WS-PX2 = WS-BX + 0.5
     MOVE 201.9 TO WS-PY2
     COMPUTE WS-PZ2 = WS-BZ + 0.5
     COMPUTE WS-VX = WS-BX + 100
     MOVE 70 TO WS-VY
     COMPUTE WS-VZ = WS-BZ + 0.5
     MOVE 1 TO WS-STARTED
     PERFORM SNAP
     CALL "EYE-SPAWN" USING WS-DIM WS-PX2 WS-PY2 WS-PZ2 WS-VX WS-VY WS-VZ WS-STARTED PL-ENTITY-ID(WS-PLAYER) WS-PJ
     MOVE " projectile_shoot" TO WS-EXPECT
     MOVE "14.2.1 an eye of ender posts projectile_shoot when it is made" TO WS-WHY
     PERFORM CHECK-EVENTS
     MOVE 0 TO WS-IDX
     MOVE WS-PROW TO WS-E-SRC
     MOVE 500 TO WS-E-X
     MOVE 201900 TO WS-E-Y
     MOVE 500 TO WS-E-Z
     MOVE "14.2.1 the eye's shoot at its spawn position (the player)" TO WS-WHY
     PERFORM CHECK-AT
     PERFORM CHECK-RESET
     CALL "ENTITY-REMOVE" USING WS-PJ
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

 END PROGRAM ACC-US15-EMITTERS2.
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
