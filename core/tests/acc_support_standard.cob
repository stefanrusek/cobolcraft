*> Acceptance test, lane bugsw (operator report: snow layers, kelp and sugar cane stayed when the block under them was broken; kelp placed on dry land and not under water; 29 section 3.2
*> updateShape, 29 section 9.5 canPlace): a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). On a stone
*> floor high above the terrain each case is built with WORLD-SET-BLOCK and then the support is taken away with BLOCK-CHANGE (Level.setBlock with flags 3): the blocks that lost their support are
*> destroyed with their drops, water plants leave water, and the placement of kelp is tried with Use Item On.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SUPPORT-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
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
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-WATER-FLOW          BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-CANE                BINARY-LONG.
 01 WS-KELP                BINARY-LONG.
 01 WS-KELP-PLANT          BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-POPPY               BINARY-LONG.
 01 WS-GRASS-BLOCK         BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-PLACED              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-TEXT-AREA           PIC X(4096).
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
         MOVE "acceptance support standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Support" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "dirt" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-DIRT
     MOVE "sand" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SAND
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "minecraft:water" TO WS-KEY112
     MOVE "level=3" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-WATER-FLOW
     MOVE "snow" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SNOW
     MOVE "sugar_cane" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-CANE
     MOVE "kelp" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-KELP
     MOVE "kelp_plant" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-KELP-PLANT
     MOVE "torch" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-TORCH
     MOVE "poppy" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-POPPY
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GRASS-BLOCK
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

*>   A snow layer on dirt: the dirt breaks, the snow goes.
     COMPUTE WS-X = WS-BX + 1
     COMPUTE WS-Z = WS-BZ + 1
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-DIRT
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SNOW
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: a snow layer breaks when the dirt under it is broken" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Sugar cane, three high, on sand beside water: the bottom one broken, the two above go and drop cane
     COMPUTE WS-X = WS-BX + 3
     COMPUTE WS-Z = WS-BZ + 1
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SAND
     COMPUTE WS-X = WS-BX + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     COMPUTE WS-X = WS-BX + 3
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-CANE
     END-PERFORM
     MOVE "sugar_cane" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT-ITEM TO WS-N
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 0 TO WS-OBSERVE
     PERFORM VARYING WS-I FROM 3 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         ADD WS-STATE TO WS-OBSERVE
     END-PERFORM
     MOVE "acceptance support standard: breaking the bottom sugar cane breaks the two above it" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-N
     PERFORM COUNT-ITEMS
     COMPUTE WS-OBSERVE = WS-COUNT-ITEM - WS-N
     MOVE "acceptance support standard: the two sugar canes that lost their support dropped sugar cane" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     PERFORM CHECK-N

*>   Kelp in water on stone: the stone goes, the kelp goes and water stays
     COMPUTE WS-X = WS-BX + 6
     COMPUTE WS-Z = WS-BZ + 1
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-DIRT
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 5
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     END-PERFORM
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-KELP-PLANT
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-KELP-PLANT
     COMPUTE WS-Y = WS-FLOOR + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-KELP
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 0 TO WS-OBSERVE
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = WS-WATER
             ADD 1 TO WS-OBSERVE
         END-IF
     END-PERFORM
     MOVE "acceptance support standard: kelp whose ground was broken is gone and the cells hold water" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     PERFORM CHECK-N

*>   A torch on stone, a poppy on grass: the support removed, the item drops
     COMPUTE WS-X = WS-BX + 8
     COMPUTE WS-Z = WS-BZ + 1
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-TORCH
     MOVE "torch" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT-ITEM TO WS-N
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: a torch falls off when its block is broken" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-ITEMS
     COMPUTE WS-OBSERVE = WS-COUNT-ITEM - WS-N
     MOVE "acceptance support standard: the torch dropped as an item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N
     COMPUTE WS-X = WS-BX + 10
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GRASS-BLOCK
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-POPPY
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: a poppy breaks when the grass block under it is broken" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
*>   A poppy on a block that stays does not break when a block beside it changes
     COMPUTE WS-X = WS-BX + 10
     COMPUTE WS-Z = WS-BZ + 3
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GRASS-BLOCK
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-POPPY
     COMPUTE WS-X = WS-BX + 9
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     COMPUTE WS-X = WS-BX + 10
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: a poppy on its grass block stays when a block beside it is placed" TO WS-CASE
     MOVE WS-POPPY TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
*>   Kelp placed with Use Item On: refused on dry land and in flowing water, placed in a water source
     MOVE "kelp" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     COMPUTE WS-X = WS-BX + 2
     COMPUTE WS-Z = WS-BZ + 5
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-FLOOR WS-Z WS-FACE WS-SEQ
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: kelp is not placed on dry land" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE WS-X = WS-BX + 6
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER-FLOW
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-FLOOR WS-Z WS-FACE WS-SEQ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: kelp is not placed in flowing water (only a water source holds it)" TO WS-CASE
     MOVE WS-WATER-FLOW TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE WS-X = WS-BX + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-FLOOR WS-Z WS-FACE WS-SEQ
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
*>   A placed kelp is a head with a random age of 0 to 24 (29b part 4 section 3.2 step 3; the states of the block run age 0 to 24 from WS-KELP).
     MOVE "acceptance support standard: kelp is placed under water in a water source" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-STATE >= WS-KELP AND WS-STATE <= WS-KELP + 24
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
*>   Ice broken by a survival player over water leaves a water source (29b 7.1 playerDestroy), not a hole the neighbouring water flows into
     MOVE "ice" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-ICE
     COMPUTE WS-X = WS-BX + 8
     COMPUTE WS-Z = WS-BZ + 5
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ICE
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "BREAK-FINISH" USING WS-PLAYER WS-DIM WS-X WS-Y WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: ice broken over water becomes a water source" TO WS-CASE
     MOVE WS-WATER TO WS-EXPECT
     MOVE WS-STATE TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE WS-X = WS-BX + 10
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ICE
     CALL "BREAK-FINISH" USING WS-PLAYER WS-DIM WS-X WS-Y WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance support standard: ice broken over a solid block becomes a water source too" TO WS-CASE
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

 FIND-ITEM.
     MOVE WS-ITEM-KEY TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS.

 COUNT-ITEMS.
     MOVE 0 TO WS-COUNT-ITEM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-ITEM(WS-E) = WS-ITEM-ID
             ADD EN-ITEM-COUNT(WS-E) TO WS-COUNT-ITEM
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SUPPORT-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
