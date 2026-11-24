*> Coverage test, group B (support rules of lane bugsw, core/src/support-29.cob): on a standard world (generated vanilla data pack, CC_GENERATED_DIR, skipped as a pass without it) SUP-FACING
*> reads the facing property of a dispenser that faces up and one that faces down (the vertical directions of a facing), and ICE-AFTER-BREAK is asked for the state 0 (nothing was broken: no
*> change), for a broken block that is no ice, for an ice broken with a silk touch pickaxe in the main hand (the ice does not melt: the cell stays air) and for an ice broken over lava (the broken ice becomes water, as over a
*> liquid).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-B-SUPPORT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-DISPENSER-UP        BINARY-LONG.
 01 WS-DISPENSER-DOWN      BINARY-LONG.
 01 WS-NAME-FACING         PIC X(24) VALUE "facing".
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "test cove b support no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "CoveBSupport" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "lava" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-LAVA
     MOVE "ice" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-ICE
     MOVE "minecraft:dispenser" TO WS-KEY112
     MOVE "facing=up,triggered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-DISPENSER-UP
     MOVE "facing=down,triggered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-DISPENSER-DOWN
     MOVE "N" TO TL-MODE

*>   The vertical directions of a facing property.
     CALL "SUP-FACING" USING WS-DISPENSER-UP WS-NAME-FACING WS-DX WS-DZ WS-DY WS-FOUND
     MOVE "test cove b support: a dispenser facing up has the facing up (dy +1, found)" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-FOUND * 100 + WS-DY + 10 + WS-DX + WS-DZ
     MOVE 111 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "SUP-FACING" USING WS-DISPENSER-DOWN WS-NAME-FACING WS-DX WS-DZ WS-DY WS-FOUND
     MOVE "test cove b support: a dispenser facing down has the facing down (dy -1, found)" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-FOUND * 100 + WS-DY + 10 + WS-DX + WS-DZ
     MOVE 109 TO WS-EXPECT
     PERFORM CHECK-N

*>   A stone platform high above the terrain with air over it.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 6
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 6
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>   Nothing was broken (state 0): nothing happens.
     COMPUTE WS-X = WS-BX + 1
     COMPUTE WS-Z = WS-BZ + 1
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     MOVE 0 TO WS-STATE
     CALL "ICE-AFTER-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test cove b support: the state 0 is no broken ice, the cell is left as it is" TO WS-CASE
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N

*>   A broken block that is no ice (stone) leaves nothing.
     CALL "ICE-AFTER-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test cove b support: a broken block that is no ice leaves the cell as it is" TO WS-CASE
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Silk touch in the main hand: the ice does not melt, the cell stays air.
     MOVE "minecraft:diamond_pickaxe" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:silk_touch" TO WS-KEY112
     CALL "LOOT-ENCH-ID" USING WS-KEY112 WS-ENCH-ID
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-LEVEL
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     COMPUTE WS-X = WS-BX + 2
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "ICE-AFTER-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-ICE WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test cove b support: an ice broken with silk touch does not melt, the cell stays air" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N

*>   The same ice broken by a hand without enchantments melts over the stone.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1) PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "ICE-AFTER-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-ICE WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test cove b support: an ice broken by an empty hand over stone becomes a water source" TO WS-CASE
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Over lava the broken ice becomes water as well (the block below is a liquid).
     COMPUTE WS-X = WS-BX + 3
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LAVA
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "ICE-AFTER-BREAK" USING WS-DIM WS-X WS-Y WS-Z WS-ICE WS-PLAYER
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "test cove b support: an ice broken over lava becomes a water source" TO WS-CASE
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> WS-FOUND-STATE: the default state of the block WS-KEY (a key without namespace in the generated set), 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-COVE-B-SUPPORT.
 COPY CORETEST.
