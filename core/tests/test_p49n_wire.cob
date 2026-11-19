*> Integration test (002-lane-p49n): the p49n programs are reached from the ticks of the world, not only called by name. CORE-TICK runs the warden trackers, a step packet onto a sculk
*> shrieker sets it off and the scheduled block tick (BT-TICK-LEVEL) ends the shriek, MOB-STEP runs a spider, a cow pair (push and jump control), a snow golem (water), a sulfur cube (the fuse),
*> an enderman and a pillager (its inventory); the loot predicate type_specific/raider is evaluated for has_raid, an unknown member and a mob that is no raider; and the guards of the
*> programs that the other tests do not reach.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-WIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY CITEMS.
 COPY P49NSTATE.
 COPY KKEEP.
 COPY CBLOCKS.
 COPY RAIDSTATE.
 COPY BRWORLD.
 COPY DIMENSIONS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PLAYER2             BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-NAME2               PIC X(16) VALUE "Alex".
 01 WS-NAME2-LENGTH        BINARY-LONG VALUE 4.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-K1                  BINARY-LONG.
 01 WS-SHRIEKER            BINARY-LONG.
 01 WS-SHRIEKER-DEF        BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-MODE                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-COW2                BINARY-LONG.
 01 WS-GOLEM               BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 01 WS-ENDER               BINARY-LONG.
 01 WS-PILLAGER            BINARY-LONG.
 01 WS-WITCH               BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-BONE                BINARY-LONG.
 01 WS-TNT                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZF1                 FLOAT-LONG VALUE 0.
 01 WS-ZF2                 FLOAT-LONG VALUE 0.
 01 WS-ZF3                 FLOAT-LONG VALUE 0.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-SPLIT               BINARY-LONG.
 01 WS-TNT-RULE            PIC X(40) VALUE "tnt_explodes".
 01 WS-TNT-ROW             BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112).
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-PLAYER-ID           BINARY-LONG.
 01 WS-30                  BINARY-LONG VALUE 30.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIRT WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:diamond" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIAMOND WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:bone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BONE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TNT WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:sulfur_cube_archetype/explosive" TO WS-TAG
     MOVE WS-TNT TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TAG-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS

*>   CORE-TICK runs the warden trackers: the counter of the player's tracker rises by 1.
     CALL "WT-KNOWN" USING WS-PLAYER WS-K1
     MOVE 5 TO KK-WARD-TICKS(WS-K1)
     CALL "CORE-TICK"
     MOVE "acceptance US15 44x2§2.1 CORE-TICK ticks the warden trackers" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE KK-WARD-TICKS(WS-K1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   A step packet onto a shrieker (can_summon false, the default) sets it off; 90 ticks later the block tick ends the shriek.
     MOVE "minecraft:sculk_shrieker" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SHRIEKER
     COMPUTE WS-FX = WS-BX + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-SHRIEKER
     COMPUTE WS-X1 = WS-FX + 0.5
     COMPUTE WS-Z1 = WS-BZ + 0.5
     COMPUTE WS-Y1 = WS-FY + 0.5
     CALL "TEST-MOVE" USING WS-CONN WS-30 WS-X1 WS-Y1 WS-Z1 WS-YAW WS-PITCH WS-ONE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STATE
     MOVE 1 TO WS-MODE
     MOVE "shrieking" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 A step packet onto a shrieker sets it off" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     ADD 90 TO CW-TICKS
     CALL "BT-TICK-LEVEL" USING WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US15 44x2§2.3 The scheduled block tick ends the shriek" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TEXT = "true"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Guards: no player, a trigger player without a known row, a trigger player far away, the level slot cleared.
     CALL "SHRIEKER-TRY" USING WS-DIM WS-FX WS-FY WS-BZ WS-ZERO
     CALL "TEST-JOIN" USING WS-NAME2 WS-NAME2-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-PLAYER2
     MOVE 0 TO PL-MODE(WS-PLAYER2)
     COMPUTE PL-X(WS-PLAYER2) = WS-BX + 100.5
     MOVE PL-Y(WS-PLAYER) TO PL-Y(WS-PLAYER2)
     MOVE PL-Z(WS-PLAYER) TO PL-Z(WS-PLAYER2)
     CALL "WT-KNOWN" USING WS-PLAYER2 WS-K1
     MOVE 0 TO KK-WARD-LEVEL(WS-K1) KK-WARD-COOL(WS-K1)
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-FX WS-FY WS-BZ WS-PLAYER2 WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 A trigger player 100 blocks away still counts (added to the list)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WT-KNOWN" USING WS-PLAYER WS-K1
     MOVE 0 TO KK-WARD-COOL(WS-K1)
     MOVE "Stranger" TO PL-UUID(WS-PLAYER2)(1:8)
     CALL "WARDEN-TRY-WARN" USING WS-DIM WS-FX WS-FY WS-BZ WS-PLAYER2 WS-LEVEL
     MOVE "acceptance US15 44x2§2.2 A trigger player with no tracker gives no level" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-LEVEL
     CALL "SHRIEKER-LEVEL" USING WS-DIM WS-FX WS-FY WS-BZ WS-TWO WS-LEVEL
     MOVE 3 TO WS-MODE
     CALL "SHRIEKER-LEVEL" USING WS-DIM WS-FX WS-FY WS-BZ WS-MODE WS-LEVEL
     MOVE 1 TO WS-MODE
     CALL "SHRIEKER-LEVEL" USING WS-DIM WS-FX WS-FY WS-BZ WS-MODE WS-LEVEL
     MOVE "acceptance US15 44x2§2.3 A cleared shrieker level reads 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-LEVEL TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING PL-ENTITY-ROW(WS-PLAYER2)
     MOVE 3 TO PL-MODE(WS-PLAYER2)

*>   MOB-STEP: a spider, a cow pair, a snow golem in water, a sulfur cube, an enderman, a pillager.
     COMPUTE WS-X = WS-X + 6.5
     COMPUTE WS-Z = WS-Z + 6.5
     MOVE "minecraft:spider" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z WS-SPIDER
     CALL "MOB-STEP" USING WS-SPIDER
     MOVE "minecraft:cow" TO WS-KEY
     COMPUTE WS-X1 = WS-X + 4
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-COW
     COMPUTE WS-X1 = WS-X + 4.3
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-COW2
     MOVE 0 TO EN-VX(WS-COW) EN-VX(WS-COW2)
     CALL "MOB-STEP" USING WS-COW
     MOVE "acceptance US15 18§3.3 Stepping a cow pushes the cow it overlaps (it moves east)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VX(WS-COW2) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "minecraft:snow_golem" TO WS-KEY
     COMPUTE WS-Z1 = WS-Z + 3
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z1 WS-GOLEM
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z1)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     MOVE EN-HEALTH(WS-GOLEM) TO WS-HEALTH
     CALL "MOB-STEP" USING WS-GOLEM
     MOVE "acceptance US15 18§2.6 Stepping a snow golem in water hurts it" TO WS-CASE
     COMPUTE WS-EXP = WS-HEALTH - 1
     MOVE EN-HEALTH(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR
*>   A snow golem with 1 health left dies of the water in its step.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     MOVE 1 TO EN-HEALTH(WS-GOLEM)
     MOVE 0 TO EN-HURT(WS-GOLEM)
     CALL "MOB-STEP" USING WS-GOLEM
     MOVE "acceptance US15 18§2.6 A snow golem with 1 health dies of the water in a step" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-HEALTH(WS-GOLEM) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 4 TO EN-HEALTH(WS-GOLEM)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR
*>   Rain with the sky open also hurts a snow golem (the sky light of the test floor is 15 above it, or the case is dropped).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR
     MOVE 1 TO DM-WEATHER(WS-DIM)
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     MOVE 0 TO EN-HURT(WS-GOLEM)
     MOVE EN-HEALTH(WS-GOLEM) TO WS-HEALTH
     CALL "STDMOB-WATER-HURT" USING WS-GOLEM
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM)
     MOVE "acceptance US15 18§2.6 In rain a snow golem takes 1 (or nothing where the sky light is below 15)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-HEALTH(WS-GOLEM) = WS-HEALTH - 1 OR EN-HEALTH(WS-GOLEM) = WS-HEALTH
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Not a standard mob: a ground item is never water-sensitive.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZF1 WS-ZF2 WS-ZF3 WS-DIRT WS-ONE WS-ZERO WS-GROUND
     CALL "STDMOB-WATER-HURT" USING WS-GROUND
     CALL "SULFUR-HURT" USING WS-GROUND WS-CAUSE WS-HANDLED
     MOVE "acceptance US15 20§18.2 SULFUR-HURT handles nothing for a ground item" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-HANDLED TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-GROUND
     MOVE CAUSE-IN-FIRE TO WS-CAUSE
     CALL "SULFUR-HURT" USING WS-COW WS-CAUSE WS-HANDLED
     MOVE "acceptance US15 20§18.2 SULFUR-HURT handles nothing for a cow" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-HANDLED TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Shallow water: a cow in the air with only its feet in the water that jumps gets the 0.04 push (the water is not 0.4 above the feet).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-WATER
     COMPUTE EN-X(WS-COW) = WS-FX + 0.5
     COMPUTE EN-Z(WS-COW) = WS-FZ + 0.5
     COMPUTE EN-Y(WS-COW) = WS-BY + 0.8
     MOVE 0 TO EN-ON-GROUND(WS-COW) EN-VY(WS-COW)
     CALL "MOB-JUMP-REQUEST" USING WS-COW
     CALL "MOB-JUMP-TICK" USING WS-COW
     COMPUTE WS-MILLI ROUNDED = EN-VY(WS-COW) * 1000
     MOVE "acceptance US15 18§2.6 Jumping in the air with the feet in shallow water gives +0.04" TO WS-CASE
     MOVE 40 TO WS-EXP
     MOVE WS-MILLI TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-BY WS-FZ WS-AIR

*>   A sulfur cube: an un-primed one does nothing in a step; a primed one with the fuse at 1 explodes in the step (the cube is gone).
     MOVE "minecraft:sulfur_cube" TO WS-KEY
     COMPUTE WS-X1 = WS-X - 4
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-CUBE
     CALL "MOB-STEP" USING WS-CUBE
     MOVE "acceptance US15 20§18.2 A step of an un-primed cube leaves it alone" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-CUBE) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "SULFUR-EQUIP" USING WS-CUBE WS-TNT WS-COUNT
     MOVE 0 TO WS-SPLIT
     CALL "SULFUR-PRIME" USING WS-CUBE WS-SPLIT WS-HANDLED
     MOVE 1 TO PN-FUSE(WS-CUBE)
     MOVE EN-ID(WS-CUBE) TO WS-PLAYER-ID
     MOVE 3 TO WS-COUNT
     CALL "SULFUR-SPLIT" USING WS-CUBE WS-COUNT
     MOVE "acceptance US15 20§18.2 A primed cube's split count is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-STEP" USING WS-CUBE
     MOVE "acceptance US15 20§18.2 The step with fuse 1 explodes the cube" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-USED(WS-CUBE) = 1 AND EN-ID(WS-CUBE) = WS-PLAYER-ID
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   An enderman step: the take and leave goals and the flags run (nothing observable beyond the entity staying).
     MOVE "minecraft:enderman" TO WS-KEY
     COMPUTE WS-Z1 = WS-Z - 4
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X WS-Y WS-Z1 WS-ENDER
     CALL "MOB-STEP" USING WS-ENDER
     MOVE "acceptance US15 20§8.1 An enderman step keeps the enderman" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-ENDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A ray through water to a holdable block, and taking an air cell.
     COMPUTE WS-FX = FUNCTION INTEGER(EN-X(WS-ENDER))
     COMPUTE WS-FZ = FUNCTION INTEGER(EN-Z(WS-ENDER))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-ENDER))
     COMPUTE WS-I = WS-FX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-BY WS-FZ WS-WATER
     COMPUTE WS-I = WS-FX + 2
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GRASS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-BY WS-FZ WS-GRASS
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-E WS-BLOCK-ROW WS-STATUS
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:enderman_holdable" TO WS-TAG
     MOVE WS-E TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TAG-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE 0 TO PN-CARRY(WS-ENDER)
     CALL "ENDER-TAKE" USING WS-ENDER WS-I WS-BY WS-FZ WS-HANDLED
     MOVE "acceptance US15 20§8.1 The ray passes through water to the holdable block (taken)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-HANDLED TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO PN-CARRY(WS-ENDER)
     COMPUTE WS-I = WS-FX + 3
     CALL "ENDER-TAKE" USING WS-ENDER WS-I WS-BY WS-FZ WS-HANDLED
     MOVE "acceptance US15 20§8.1 Taking an air cell takes nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-HANDLED TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A carrying enderman is persistent for the despawn rule (MS6-DESPAWN-TICK reads ENDER-CARRIES); a step of a non-hostile row passes it too.
     MOVE 1 TO PN-CARRY(WS-ENDER)
     CALL "MS6-DESPAWN-TICK" USING WS-ENDER
     MOVE "acceptance US15 20§8.1 The despawn check of a carrying enderman leaves it" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-ENDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO PN-CARRY(WS-ENDER)

*>   The stare: a survival player looking at the enderman 10 blocks to the south makes it take him as its target and sets the stared-at flag (metadata 18).
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-ENDER)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-ENDER)
     COMPUTE EN-Z(WS-ENDER) = PL-Z(WS-PLAYER) + 10
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE PL-PITCH(WS-PLAYER) = - FUNCTION ATAN(0.93 / 10) * 180 / FUNCTION PI
     MOVE 0 TO EN-TARGET(WS-ENDER)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ENDER) WS-M
     CALL "STDMOB-ENDER-AIM" USING WS-ENDER WS-M
     CALL "ENDER-FLAGS-TICK" USING WS-ENDER
     MOVE "acceptance US15 20§8.1 A player staring at the enderman becomes its target and 18 is set" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS = PN-STARED(WS-ENDER) * 10 + PN-CREEPY(WS-ENDER)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO PL-MODE(WS-PLAYER)

*>   A pillager step: the loot pickup runs through the step.
     MOVE "minecraft:pillager" TO WS-KEY
     COMPUTE WS-X1 = WS-X - 8
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-PILLAGER
     COMPUTE WS-X1 = WS-X - 7.5
     CALL "GI-SPAWN" USING WS-DIM WS-X1 WS-Y WS-Z WS-ZF1 WS-ZF2 WS-ZF3 WS-DIRT WS-ONE WS-ZERO WS-GROUND
     MOVE 0 TO EN-DELAY(WS-GROUND)
     CALL "MOB-STEP" USING WS-PILLAGER
     MOVE "acceptance US15 20§13.2 A pillager step picks the dirt up into its inventory" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE PN-INV-COUNT(WS-PILLAGER, 1) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The loot predicate raider: a witch in a raid wave drops the has_raid emerald and not the diamond of the unknown member; a skeleton (no raider) drops no bone.
     MOVE "minecraft:witch" TO WS-KEY
     COMPUTE WS-X1 = WS-X + 8
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-WITCH
     MOVE WS-EMERALD TO WS-I
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT TO WS-BEFORE
     MOVE EN-ID(WS-WITCH) TO RR-ID(1)
     MOVE 1 TO RR-RAID(1)
     MOVE 0 TO RR-LEADER(1)
     CALL "STDMOB-DIE" USING WS-WITCH
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 26 A witch in a raid wave drops the has_raid emerald" TO WS-CASE
     COMPUTE WS-EXP = WS-BEFORE + 1
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-DIAMOND TO WS-I
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 26 An unknown raider member never matches (no diamond)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO RR-ID(1) RR-RAID(1)
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-X1 WS-Y WS-Z WS-SKELETON
     MOVE WS-BONE TO WS-I
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-DIE" USING WS-SKELETON
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 26 A skeleton is no raider: the captain predicate is false" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.

*> WS-COUNT: the item entities of item id WS-I.
 COUNT-ITEMS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-ITEM(WS-E) = WS-I
             ADD EN-ITEM-COUNT(WS-E) TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-P49N-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     IF L-KEY = "minecraft:sulfur_cube"
         CALL "SULFUR-CUBE-INIT" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.

 COPY CORETEST.
 COPY MOBSPTEST.
