*> Acceptance test, lane bugkelpplace (operator report try18: "cant place kelp in flowing water, it should place and create a water source block"). Docs: 29a section 5.2 (kelp,
*> seagrass and tall seagrass are LiquidBlockContainers whose fluid state is always the water source) and 29b part 4 sections 3.2 and 9.2 (placement needs the fluid at the clicked
*> position in tag water AND full: FluidState.isFull is amount 8, which is a source and a falling cell (block levels 8 to 15), but not the flowing levels 1 to 7), 29a section 5.1
*> and 29b part 4 section 11.1 (waterlogged placement and sea pickle: Fluids.WATER the source only). A standard world from the generated vanilla set (CC_GENERATED_DIR; a skipped pass
*> without it): a pool of water on a stone floor; each cell of a row is set to one water level, the player uses an item on the floor below it through the real Use Item On handler,
*> and the cell is read back. Kelp that is placed is a water source afterwards (it holds the source for the fluid engine, the water above stays water).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-KELP-FLOWING-STANDARD.
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
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-TALL                BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-LEVEL-TEXT          PIC Z9.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-TICKS               BINARY-LONG VALUE 40.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-WANT-WL             PIC X(8).
 01 WS-ACCEPTS             BINARY-LONG.
 01 WS-WATER-STATE         BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-PROP                PIC X(24) VALUE "waterlogged".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LEVELS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 12.
 01 WS-LEVELS-R REDEFINES WS-LEVELS.
    05 WS-LV               BINARY-LONG OCCURS 6 TIMES.
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
         MOVE "acceptance kelp flowing standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Kelpflow" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "tall_seagrass" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-TALL
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
     COMPUTE WS-CY = WS-FLOOR + 1

*>   Rows: kelp, seagrass, sea pickle, slab (cell z = BZ + 1 + row); columns: the water level of the cell (x = BX + 1 + column).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         EVALUATE WS-K
             WHEN 1
                 MOVE "kelp" TO WS-ITEM-KEY
             WHEN 2
                 MOVE "seagrass" TO WS-ITEM-KEY
             WHEN 3
                 MOVE "sea_pickle" TO WS-ITEM-KEY
             WHEN 4
                 MOVE "oak_slab" TO WS-ITEM-KEY
         END-EVALUATE
         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 6
             MOVE WS-LV(WS-L) TO WS-LEVEL
             COMPUTE WS-CX = WS-BX + 1 + WS-L
             COMPUTE WS-CZ = WS-BZ + 1 + WS-K
             PERFORM SET-WATER-LEVEL
*>           Kelp and seagrass accept a full water (source, falling); a sea pickle and a slab always place and waterlog in a source only.
             MOVE 0 TO WS-ACCEPTS
             IF WS-LEVEL = 0 OR WS-LEVEL >= 8
                 MOVE 1 TO WS-ACCEPTS
             END-IF
             MOVE WS-ITEM-KEY TO WS-WANT
             MOVE "false" TO WS-WANT-WL
             IF WS-K >= 3
                 MOVE 1 TO WS-ACCEPTS
                 IF WS-LEVEL = 0
                     MOVE "true" TO WS-WANT-WL
                 END-IF
             END-IF
             IF WS-ACCEPTS = 0
                 MOVE "water" TO WS-WANT
             END-IF
             MOVE WS-CX TO WS-X
             MOVE WS-CZ TO WS-Z
             PERFORM USE-ON-FLOOR
             MOVE SPACES TO WS-CASE
             STRING "acceptance kelp flowing: " FUNCTION TRIM(WS-ITEM-KEY) " at water level " WS-LEVEL-TEXT " leaves " FUNCTION TRIM(WS-WANT) DELIMITED BY SIZE INTO WS-CASE
             PERFORM CHECK-KEY
             IF WS-K >= 3
                 MOVE SPACES TO WS-CASE
                 STRING "acceptance kelp flowing: " FUNCTION TRIM(WS-ITEM-KEY) " at water level " WS-LEVEL-TEXT " waterlogged is " FUNCTION TRIM(WS-WANT-WL) DELIMITED BY SIZE INTO WS-CASE
                 PERFORM CHECK-WATERLOGGED
             END-IF
         END-PERFORM
     END-PERFORM

*>   Air: kelp is refused.
     COMPUTE WS-CX = WS-BX + 1
     COMPUTE WS-CZ = WS-BZ + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     MOVE "kelp" TO WS-ITEM-KEY
     MOVE "air" TO WS-WANT
     MOVE WS-CX TO WS-X
     MOVE WS-CZ TO WS-Z
     PERFORM USE-ON-FLOOR
     MOVE "acceptance kelp flowing: kelp in air is refused" TO WS-CASE
     PERFORM CHECK-KEY

*>   Tall seagrass (no item: the survive and place rule of its lower half, 29b part 4 section 9.3).
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 6
         MOVE WS-LV(WS-L) TO WS-LEVEL
         COMPUTE WS-CX = WS-BX + 1 + WS-L
         COMPUTE WS-CZ = WS-BZ + 7
         PERFORM SET-WATER-LEVEL
         MOVE 0 TO WS-OK
         CALL "SUP-PLACE-OK" USING WS-DIM WS-CX WS-CY WS-CZ WS-TALL WS-OK
         MOVE 0 TO WS-EXPECT
         IF WS-LEVEL = 0 OR WS-LEVEL >= 8
             MOVE 1 TO WS-EXPECT
         END-IF
         MOVE WS-OK TO WS-OBSERVE
         MOVE SPACES TO WS-CASE
         STRING "acceptance kelp flowing: tall seagrass may be placed at water level " WS-LEVEL-TEXT DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-N
     END-PERFORM

*>   The kelp in a falling cell (level 8) and in a source cell hold a water source after the world ran, and the water above stays water.
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-K
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 6
         MOVE WS-LV(WS-L) TO WS-LEVEL
         IF WS-LEVEL = 0 OR WS-LEVEL >= 8
             COMPUTE WS-CX = WS-BX + 1 + WS-L
             COMPUTE WS-CZ = WS-BZ + 2
             MOVE "kelp" TO WS-WANT
             PERFORM SET-LEVEL-TEXT
             MOVE SPACES TO WS-CASE
             STRING "acceptance kelp flowing: kelp placed at water level " WS-LEVEL-TEXT " is still kelp after the fluid updates" DELIMITED BY SIZE INTO WS-CASE
             PERFORM CHECK-KEY
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
             CALL "FLUID-OF-STATE" USING WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
             MOVE WS-KIND TO WS-OBSERVE
             MOVE 2 TO WS-EXPECT
             MOVE SPACES TO WS-CASE
             STRING "acceptance kelp flowing: kelp placed at water level " WS-LEVEL-TEXT " holds a water source" DELIMITED BY SIZE INTO WS-CASE
             PERFORM CHECK-N
             COMPUTE WS-E = WS-CY + 1
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-E WS-CZ WS-STATE
             MOVE 0 TO WS-OBSERVE
             IF CB-S-BLOCK(WS-STATE + 1) = CB-S-BLOCK(WS-WATER + 1)
                 MOVE 1 TO WS-OBSERVE
             END-IF
             MOVE 1 TO WS-EXPECT
             MOVE SPACES TO WS-CASE
             STRING "acceptance kelp flowing: the cell above kelp at water level " WS-LEVEL-TEXT " is water" DELIMITED BY SIZE INTO WS-CASE
             PERFORM CHECK-N
         END-IF
     END-PERFORM
     STOP RUN.

*> WS-FOUND-STATE: the default state of the block WS-KEY, 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

 SET-LEVEL-TEXT.
     MOVE WS-LEVEL TO WS-LEVEL-TEXT.

*> The water block of level WS-LEVEL goes into the cell WS-CX, WS-CY, WS-CZ.
 SET-WATER-LEVEL.
     PERFORM SET-LEVEL-TEXT
     MOVE "minecraft:water" TO WS-KEY112
     MOVE SPACES TO WS-PAIRS
     STRING "level=" FUNCTION TRIM(WS-LEVEL-TEXT LEADING) DELIMITED BY SIZE INTO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-WATER-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER-STATE.

*> The player holds WS-ITEM-KEY in the first hotbar slot and uses it on the top face of the floor block below the cell WS-X, WS-Z.
 USE-ON-FLOOR.
     MOVE WS-ITEM-KEY TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     ADD 1 TO WS-SEQ
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-FLOOR WS-Z WS-FACE WS-SEQ.

*> 1 when the block at WS-CX, WS-CY, WS-CZ has the key WS-WANT.
 CHECK-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

*> The waterlogged property of the block at WS-CX, WS-CY, WS-CZ is WS-WANT-WL.
 CHECK-WATERLOGGED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WANT-WL)
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
 END PROGRAM ACC-KELP-FLOWING-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
