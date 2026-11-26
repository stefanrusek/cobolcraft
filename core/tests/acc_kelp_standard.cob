*> Acceptance test, lane kelpfix (operator report try7: kelp placed under water appeared and broke at once without a drop, "in water it should have just placed"; 29a section 5 waterlogged blocks and
*> water plants hold a water source, 2.8 spreadTo drops the resources of a block that water washes away): a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default
*> /tmp/cc-test/generated; skipped as a pass without it). A pool of water sources four deep lies on a stone floor high above the terrain; the player holds each item in turn and sends Use Item On
*> through the real packet handler, then the world runs (CORE-TICK) so that the fluid and the support updates that follow the placement have happened.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-KELP-STANDARD.
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

 01 WS-TICKS               BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-UX                  BINARY-LONG.
 01 WS-UY                  BINARY-LONG.
 01 WS-UZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-WL-WANT             PIC X(8).
 01 WS-TEXT                PIC X(32).
 01 WS-PROP                PIC X(24) VALUE "waterlogged".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
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
         MOVE "acceptance kelp standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Kelpfix" TO CS-NEW-WORLD-NAME
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
     MOVE "kelp" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-KELP
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "minecraft:water" TO WS-KEY112
     MOVE "level=3" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-WATER-FLOW
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 IF WS-X > WS-BX AND WS-X < WS-BX + 11 AND WS-Z > WS-BZ AND WS-Z < WS-BZ + 11 AND WS-I <= 4
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-WATER
                 ELSE
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 6
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     MOVE 80 TO WS-TICKS

*>   Kelp on the top face of the seabed: placed, and still there after the world ran; nothing dropped
     MOVE "kelp" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT-ITEM TO WS-N0
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 2
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE "kelp" TO WS-WANT
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE
     MOVE "acceptance kelp standard: kelp is placed in a water source (top face of the seabed)" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance kelp standard: the kelp is still there after the fluid updates" TO WS-CASE
     PERFORM CHECK-KEY
     PERFORM COUNT-ITEMS
     COMPUTE WS-OBSERVE = WS-COUNT-ITEM - WS-N0
     MOVE 0 TO WS-EXPECT
     MOVE "acceptance kelp standard: no kelp item was dropped" TO WS-CASE
     PERFORM CHECK-N
     MOVE "water" TO WS-WANT
     COMPUTE WS-CY = WS-FLOOR + 4
     MOVE "acceptance kelp standard: water above the kelp stays water" TO WS-CASE
     PERFORM CHECK-KEY

*>   Kelp on the top face of that kelp (the water cell above it)
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "kelp" TO WS-WANT
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE-AT
     MOVE "acceptance kelp standard: kelp is placed on the top face of kelp" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance kelp standard: the upper kelp is still there after the fluid updates" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE "kelp_plant" TO WS-WANT
     MOVE "acceptance kelp standard: the kelp under the new kelp became a kelp_plant (29b part 4 section 3.2 step 7)" TO WS-CASE
     PERFORM CHECK-KEY

*>   Kelp on the side of a kelp: the cell beside it, on the seabed
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 5
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE "kelp" TO WS-WANT
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE
     MOVE 5 TO WS-FACE
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-CY TO WS-UY
     COMPUTE WS-CX = WS-CX + 1
     PERFORM GIVE-AND-USE-AT
     MOVE "acceptance kelp standard: kelp is placed beside a kelp" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance kelp standard: the kelp beside a kelp is still there" TO WS-CASE
     PERFORM CHECK-KEY

*>   Seagrass
     COMPUTE WS-CX = WS-BX + 3
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE "seagrass" TO WS-ITEM-KEY
     MOVE "seagrass" TO WS-WANT
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE
     MOVE "acceptance kelp standard: seagrass is placed in a water source" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance kelp standard: the seagrass is still there after the fluid updates" TO WS-CASE
     PERFORM CHECK-KEY

*>   Waterlogged on placement and after the world ran: slab, fence, sea pickle, coral plant
     MOVE 4 TO WS-K
     PERFORM VARYING WS-K FROM 4 BY 1 UNTIL WS-K > 7
         EVALUATE WS-K
             WHEN 4
                 MOVE "oak_slab" TO WS-ITEM-KEY
                 MOVE "oak_slab" TO WS-WANT
             WHEN 5
                 MOVE "oak_fence" TO WS-ITEM-KEY
                 MOVE "oak_fence" TO WS-WANT
             WHEN 6
                 MOVE "sea_pickle" TO WS-ITEM-KEY
                 MOVE "sea_pickle" TO WS-WANT
             WHEN 7
                 MOVE "tube_coral" TO WS-ITEM-KEY
                 MOVE "tube_coral" TO WS-WANT
         END-EVALUATE
         COMPUTE WS-CX = WS-BX + WS-K
         COMPUTE WS-CZ = WS-BZ + 2
         MOVE 1 TO WS-FACE
         PERFORM GIVE-AND-USE
         MOVE SPACES TO WS-CASE
         STRING "acceptance kelp standard: " FUNCTION TRIM(WS-WANT) " is placed" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-KEY
         MOVE SPACES TO WS-CASE
         STRING "acceptance kelp standard: " FUNCTION TRIM(WS-WANT) " in a water source is waterlogged" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-WATERLOGGED-TRUE
     END-PERFORM
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM VARYING WS-K FROM 4 BY 1 UNTIL WS-K > 7
         COMPUTE WS-CX = WS-BX + WS-K
         EVALUATE WS-K
             WHEN 4
                 MOVE "oak_slab" TO WS-WANT
             WHEN 5
                 MOVE "oak_fence" TO WS-WANT
             WHEN 6
                 MOVE "sea_pickle" TO WS-WANT
             WHEN 7
                 MOVE "tube_coral" TO WS-WANT
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         STRING "acceptance kelp standard: " FUNCTION TRIM(WS-WANT) " is still there and waterlogged after the fluid updates" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-KEY
         PERFORM CHECK-WATERLOGGED-TRUE
     END-PERFORM

*>   A slab placed into flowing water is not waterlogged (only a source waterlogs)
     COMPUTE WS-CX = WS-BX + 9
     COMPUTE WS-CZ = WS-BZ + 4
     COMPUTE WS-CY = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER-FLOW
     MOVE "oak_slab" TO WS-ITEM-KEY
     MOVE "oak_slab" TO WS-WANT
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE
     MOVE "acceptance kelp standard: a slab in flowing water is placed" TO WS-CASE
     PERFORM CHECK-KEY
     MOVE "acceptance kelp standard: a slab in flowing water is not waterlogged" TO WS-CASE
     PERFORM CHECK-WATERLOGGED-FALSE

*>   A torch in a water source: water washes it away and it drops as an item
     COMPUTE WS-CX = WS-BX + 8
     COMPUTE WS-CZ = WS-BZ + 2
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE "torch" TO WS-ITEM-KEY
     PERFORM FIND-ITEM
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT-ITEM TO WS-N0
     MOVE "torch" TO WS-WANT
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "water" TO WS-WANT
     MOVE "acceptance kelp standard: the cell of a torch placed in water holds water again" TO WS-CASE
     PERFORM CHECK-KEY
     PERFORM COUNT-ITEMS
     COMPUTE WS-OBSERVE = WS-COUNT-ITEM - WS-N0
     MOVE 1 TO WS-EXPECT
     MOVE "acceptance kelp standard: the torch washed away dropped as an item" TO WS-CASE
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

*> The player holds WS-ITEM-KEY in the first hotbar slot and uses it on the seabed (the floor) below the cell WS-CX, WS-CZ.
 GIVE-AND-USE.
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     PERFORM GIVE-AND-USE-AT.

*> The same item used on the block WS-UX, WS-UY, WS-UZ, face WS-FACE.
 GIVE-AND-USE-AT.
     PERFORM FIND-ITEM
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-UX WS-UY WS-UZ WS-FACE WS-SEQ.

*> 1 when the block at WS-CX, WS-CY, WS-CZ has the key WS-WANT.
 CHECK-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

 CHECK-WATERLOGGED-TRUE.
     MOVE "true" TO WS-WL-WANT
     PERFORM CHECK-WATERLOGGED.

 CHECK-WATERLOGGED-FALSE.
     MOVE "false" TO WS-WL-WANT
     PERFORM CHECK-WATERLOGGED.

*> The waterlogged property of the block at WS-CX, WS-CY, WS-CZ is WS-WL-WANT.
 CHECK-WATERLOGGED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WL-WANT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-KELP-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
