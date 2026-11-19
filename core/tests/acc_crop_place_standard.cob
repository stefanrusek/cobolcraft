*> Acceptance test, lane bugcrop (operator report, db901a9a play: using a potato on a block plants a potato crop on any block): a block item may only place its block where the block's
*> survival rule holds (29b part 2 section 12 and 24 part 2 section 7.3: BlockItem.canPlace asks canSurvive). A standard world opened from the generated vanilla data pack (CC_GENERATED_DIR,
*> default /tmp/cc-test/generated; skipped as a pass without it). A stone platform lies high above the terrain; the player holds each item in turn and sends Use Item On through the real
*> packet handler on six grounds (stone, grass block, sand, a water source over stone, farmland, soul sand), in survival and in creative. The items that need farmland (potato, carrot, the seeds,
*> the pitch pod), soul sand (nether wart) or a vegetation block (sweet berries, a sapling, a flower) must be placed only on their ground, nothing may be placed elsewhere, and a
*> survival stack shrinks by one only when the block was placed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-CROP-PLACE-STANDARD.
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
 01 WS-G                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
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
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-TICKS               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-UX                  BINARY-LONG.
 01 WS-UY                  BINARY-LONG.
 01 WS-UZ                  BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-TEXT                PIC X(32).
 01 WS-PROP                PIC X(24) VALUE "facing".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-GROUND-STATES.
    05 WS-GROUND           BINARY-LONG OCCURS 6 TIMES.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-SHORT-GRASS         BINARY-LONG.
 01 WS-JUNGLE-LOG          BINARY-LONG.
 01 WS-OAK-LOG             BINARY-LONG.
 01 WS-PLACED-LINE         PIC X(6).
 01 WS-COUNT-LINE          PIC X(6).
 01 WS-EXPECT-COUNTS       PIC X(6).
 01 WS-EXPECT-LINE         PIC X(6).
 01 WS-HAVE                BINARY-LONG.
 01 WS-LABEL               PIC X(40).
 01 WS-OK                  BINARY-LONG.
 01 WS-HANGING-STATE       BINARY-LONG.
*> item key, block key, then one flag per ground (stone, grass block, sand, water over stone, farmland, soul sand): 1 placed, 0 refused, ? not specified here
 01 WS-ROWS.
    05 FILLER PIC X(60) VALUE "potato                  potatoes                000010".
    05 FILLER PIC X(60) VALUE "carrot                  carrots                 000010".
    05 FILLER PIC X(60) VALUE "wheat_seeds             wheat                   000010".
    05 FILLER PIC X(60) VALUE "beetroot_seeds          beetroots               000010".
    05 FILLER PIC X(60) VALUE "melon_seeds             melon_stem              000010".
    05 FILLER PIC X(60) VALUE "pumpkin_seeds           pumpkin_stem            000010".
    05 FILLER PIC X(60) VALUE "torchflower_seeds       torchflower_crop        000010".
    05 FILLER PIC X(60) VALUE "pitcher_pod             pitcher_crop            000010".
    05 FILLER PIC X(60) VALUE "nether_wart             nether_wart             000001".
    05 FILLER PIC X(60) VALUE "sweet_berries           sweet_berry_bush        010010".
    05 FILLER PIC X(60) VALUE "oak_sapling             oak_sapling             010010".
    05 FILLER PIC X(60) VALUE "poppy                   poppy                   010010".
    05 FILLER PIC X(60) VALUE "mangrove_propagule      mangrove_propagule      010010".
    05 FILLER PIC X(60) VALUE "azalea                  azalea                  010010".
    05 FILLER PIC X(60) VALUE "wither_rose             wither_rose             010011".
    05 FILLER PIC X(60) VALUE "cactus                  cactus                  001000".
    05 FILLER PIC X(60) VALUE "sugar_cane              sugar_cane              000000".
    05 FILLER PIC X(60) VALUE "lily_pad                lily_pad                000000".
    05 FILLER PIC X(60) VALUE "torch                   torch                   111??1".
    05 FILLER PIC X(60) VALUE "stone_pressure_plate    stone_pressure_plate    111??1".
    05 FILLER PIC X(60) VALUE "rail                    rail                    111??1".
    05 FILLER PIC X(60) VALUE "redstone                redstone_wire           111??1".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 22 TIMES.
       10 WS-ROW-ITEM      PIC X(24).
       10 WS-ROW-BLOCK     PIC X(24).
       10 WS-ROW-FLAGS     PIC X(6).
       10 FILLER           PIC X(6).
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
         MOVE "acceptance crop place standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "Cropplace" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE WS-FOUND-STATE TO WS-GROUND(1)
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GROUND(2)
     MOVE "sand" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GROUND(3)
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GROUND(4)
     MOVE "minecraft:farmland" TO WS-KEY112
     MOVE "moisture=7" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-GROUND(5)
     MOVE "soul_sand" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GROUND(6)
     MOVE "water" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-WATER
     MOVE "short_grass" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SHORT-GRASS
     MOVE "jungle_log" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-JUNGLE-LOG
     MOVE "oak_log" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-OAK-LOG
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
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 1.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 1.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     COMPUTE WS-CX = WS-BX + 6
     COMPUTE WS-CZ = WS-BZ + 6
     COMPUTE WS-CY = WS-FLOOR + 1

*>   The table: every item on every ground, survival (mode 0) then creative (mode 1)
     PERFORM VARYING WS-M FROM 0 BY 1 UNTIL WS-M > 1
         MOVE WS-M TO PL-MODE(WS-PLAYER)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
             MOVE WS-ROW-ITEM(WS-I) TO WS-ITEM-KEY
             PERFORM FIND-ITEM
             MOVE SPACES TO WS-PLACED-LINE WS-COUNT-LINE
             PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 6
                 PERFORM PREPARE-GROUND
                 MOVE WS-CX TO WS-UX
                 MOVE WS-CY TO WS-UY
                 MOVE WS-CZ TO WS-UZ
                 IF WS-G NOT = 4
                     COMPUTE WS-UY = WS-FLOOR
                 END-IF
                 MOVE 1 TO WS-FACE
                 PERFORM GIVE-AND-USE-AT
*>               what the cell holds afterwards: the wanted block (1), the ground's own content (0)
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
                 MOVE "0" TO WS-PLACED-LINE(WS-G:1)
                 IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-ROW-BLOCK(WS-I))
                     MOVE "1" TO WS-PLACED-LINE(WS-G:1)
                 END-IF
                 IF WS-ROW-FLAGS(WS-I)(WS-G:1) = "?"
                     MOVE "?" TO WS-PLACED-LINE(WS-G:1)
                 END-IF
                 MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-E
                 MOVE FUNCTION CHAR(WS-E + 49) TO WS-COUNT-LINE(WS-G:1)
*>               a refused placement leaves the ground cell as the setup made it (air, or the water source)
                 IF WS-PLACED-LINE(WS-G:1) = "0"
                     PERFORM CHECK-CELL-UNTOUCHED
                     IF WS-OBSERVE = 0
                         MOVE "x" TO WS-PLACED-LINE(WS-G:1)
                     END-IF
                 END-IF
             END-PERFORM
             MOVE SPACES TO WS-CASE
             IF WS-M = 0
                 MOVE "survival" TO WS-LABEL
             ELSE
                 MOVE "creative" TO WS-LABEL
             END-IF
             STRING "acceptance crop place standard: " FUNCTION TRIM(WS-ROW-ITEM(WS-I)) " in " FUNCTION TRIM(WS-LABEL)
                 " is placed only on its ground (stone, grass, sand, water, farmland, soul sand)" DELIMITED BY SIZE INTO WS-CASE
             MOVE WS-ROW-FLAGS(WS-I) TO WS-EXPECT-LINE
             MOVE WS-CASE TO TL-CASE
             MOVE "T" TO TL-MODE
             MOVE WS-EXPECT-LINE TO TL-EXPECTED
             MOVE WS-PLACED-LINE TO TL-OBSERVED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>           the survival stack of 5 shrinks to 4 exactly where the block was placed; creative keeps 5 everywhere
             MOVE "555555" TO WS-EXPECT-COUNTS
             PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 6
                 IF WS-M = 0 AND WS-ROW-FLAGS(WS-I)(WS-G:1) = "1"
                     MOVE "4" TO WS-EXPECT-COUNTS(WS-G:1)
                 END-IF
                 IF WS-ROW-FLAGS(WS-I)(WS-G:1) = "?"
                     MOVE WS-COUNT-LINE(WS-G:1) TO WS-EXPECT-COUNTS(WS-G:1)
                 END-IF
             END-PERFORM
             MOVE SPACES TO WS-CASE
             STRING "acceptance crop place standard: " FUNCTION TRIM(WS-ROW-ITEM(WS-I)) " in " FUNCTION TRIM(WS-LABEL)
                 " is used up only when the block was placed (survival)" DELIMITED BY SIZE INTO WS-CASE
             MOVE WS-CASE TO TL-CASE
             MOVE "T" TO TL-MODE
             MOVE WS-EXPECT-COUNTS TO TL-EXPECTED
             MOVE WS-COUNT-LINE TO TL-OBSERVED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   A replaceable block above the farmland (short grass) is replaced by the crop
     MOVE 5 TO WS-G
     PERFORM PREPARE-GROUND
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-SHORT-GRASS
     MOVE "potato" TO WS-ITEM-KEY
     MOVE WS-CX TO WS-UX
     COMPUTE WS-UY = WS-FLOOR
     MOVE WS-CZ TO WS-UZ
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE-AT
     MOVE "potatoes" TO WS-WANT
     MOVE "acceptance crop place standard: a potato used on farmland under short grass replaces the grass with the crop" TO WS-CASE
     PERFORM CHECK-KEY

*>   Cocoa: placed on the side of a jungle log, facing it; refused on the side of an oak log
     MOVE "cocoa_beans" TO WS-ITEM-KEY
     MOVE 5 TO WS-G
     PERFORM PREPARE-GROUND
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-JUNGLE-LOG
     MOVE WS-CX TO WS-UX
     MOVE WS-CY TO WS-UY
     MOVE WS-CZ TO WS-UZ
     MOVE 5 TO WS-FACE
     PERFORM GIVE-AND-USE-AT
     COMPUTE WS-CX = WS-CX + 1
     MOVE "cocoa" TO WS-WANT
     MOVE "acceptance crop place standard: cocoa beans used on the east side of a jungle log place a cocoa pod" TO WS-CASE
     PERFORM CHECK-KEY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
     MOVE "acceptance crop place standard: the cocoa pod faces the log" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "west" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CX = WS-CX - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-OAK-LOG
     COMPUTE WS-CX = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     COMPUTE WS-CX = WS-CX - 1
     MOVE WS-CX TO WS-UX
     MOVE 5 TO WS-FACE
     PERFORM GIVE-AND-USE-AT
     COMPUTE WS-CX = WS-CX + 1
     MOVE "air" TO WS-WANT
     MOVE "acceptance crop place standard: cocoa beans used on the side of an oak log place nothing" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CX = WS-CX - 1

*>   A hanging mangrove propagule survives under a mangrove leaves block (supports_hanging_mangrove_propagule) and not under stone
     MOVE "minecraft:mangrove_propagule" TO WS-KEY112
     MOVE "age=0,hanging=true,stage=0,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-HANGING-STATE
     MOVE 5 TO WS-G
     PERFORM PREPARE-GROUND
     COMPUTE WS-Y = WS-CY + 1
     MOVE "mangrove_leaves" TO WS-KEY
     PERFORM FIND-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-FOUND-STATE
     CALL "SUP-SURVIVES" USING WS-DIM WS-CX WS-CY WS-CZ WS-HANGING-STATE WS-OK
     MOVE "acceptance crop place standard: a hanging mangrove propagule survives under mangrove leaves" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-STONE
     CALL "SUP-SURVIVES" USING WS-DIM WS-CX WS-CY WS-CZ WS-HANGING-STATE WS-OK
     MOVE "acceptance crop place standard: a hanging mangrove propagule does not survive under stone" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-AIR

*>   A crop on farmland whose farmland goes away breaks and drops its item
     MOVE 5 TO WS-G
     PERFORM PREPARE-GROUND
     MOVE "potato" TO WS-ITEM-KEY
     MOVE WS-CX TO WS-UX
     COMPUTE WS-UY = WS-FLOOR
     MOVE WS-CZ TO WS-UZ
     MOVE 1 TO WS-FACE
     PERFORM GIVE-AND-USE-AT
     MOVE "potatoes" TO WS-WANT
     MOVE "acceptance crop place standard: a potato crop is planted on farmland" TO WS-CASE
     PERFORM CHECK-KEY
     PERFORM COUNT-ITEMS
     MOVE WS-COUNT-ITEM TO WS-N0
     CALL "BLOCK-CHANGE" USING WS-DIM WS-CX WS-UY WS-CZ WS-AIR
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "air" TO WS-WANT
     MOVE "acceptance crop place standard: the crop breaks when the farmland under it is removed" TO WS-CASE
     PERFORM CHECK-KEY
     PERFORM COUNT-ITEMS
     COMPUTE WS-OBSERVE = WS-COUNT-ITEM - WS-N0
     IF WS-OBSERVE > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     MOVE "acceptance crop place standard: the broken crop dropped its item" TO WS-CASE
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

*> The test site WS-CX, WS-CY, WS-CZ with ground number WS-G: the ground block under it (the stone floor for the water ground, whose source fills the site cell), air above.
 PREPARE-GROUND.
     PERFORM VARYING WS-Y FROM WS-CY BY 1 UNTIL WS-Y > WS-CY + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-AIR
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-FLOOR WS-CZ WS-GROUND(WS-G)
     IF WS-G = 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER
     END-IF.

*> 1 in WS-OBSERVE when the site cell is as PREPARE-GROUND left it (air, or the water source).
 CHECK-CELL-UNTOUCHED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF WS-G = 4
         IF WS-STATE = WS-WATER
             MOVE 1 TO WS-OBSERVE
         END-IF
     ELSE
         IF WS-STATE = 0
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF.

*> The player holds 5 of WS-ITEM-KEY in the first hotbar slot and uses it on the block WS-UX, WS-UY, WS-UZ, face WS-FACE.
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

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-CROP-PLACE-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
