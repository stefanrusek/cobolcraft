*> Implementation test (superflat lane; docs/protocol/56-superflat-world.md sections 3, 4 and 7): a superflat world opened from the generated vanilla data
*> pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it), asked for chunks through the dispatch of the standard overworld
*> (WORLDGEN-DIM-CHUNK):
*>   - the default column from the bottom up (56 section 7.1: bedrock, dirt x2, grass_block) and the column of each of the nine presets (3.2 and 7);
*>   - the biome of every cell, the heightmap queries (OCEAN_FLOOR_WG, WORLD_SURFACE_WG) and the spawn height of each preset (4.6);
*>   - the world spawn of a new default world (7.1: (0, -60, 0));
*>   - no noise, climate, density, aquifer, surface, carver, ore or feature stage runs (GENSTAGE.cpy counters stay 0);
*>   - structures only where the settings allow (56 section 4.7): over 49 x 49 chunks every start of the default world is a village or a stronghold, a
*>     preset with no structure_overrides has none, a village start chunk holds structure blocks above the grass and none when generate_structures is 0;
*>   - a fresh chunk gets no creatures (56 section 4.9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLAT-COLUMN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FLATSET.
 COPY GENSTAGE.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-MEM                 PIC X(304640).
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LAST                PIC X(48).
 01 WS-RUN                 BINARY-LONG.
 01 WS-TEXT                PIC X(500).
 01 WS-PTR                 BINARY-LONG.
 01 WS-NUM                 PIC -(9)9.
 01 WS-NUM2                PIC -(9)9.
 01 WS-NUM3                PIC -(9)9.
 01 WS-NUM4                PIC -(9)9.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-FOLDER              PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-AREA                PIC X(4096).
 01 WS-DEFAULT-ID          BINARY-LONG.
 01 WS-SAVE-SEED           BINARY-DOUBLE.
 01 WS-RING-SET            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL-A              BINARY-LONG.
 01 WS-CELL-B              BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-H4                  BINARY-LONG.
 01 WS-SPAWN-Y             BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STARTS              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MOBS                BINARY-LONG.
 01 WS-KEY80               PIC X(80).
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-PRESET-NAMES.
    05 FILLER PIC X(40) VALUE "classic_flat".
    05 FILLER PIC X(40) VALUE "tunnelers_dream".
    05 FILLER PIC X(40) VALUE "water_world".
    05 FILLER PIC X(40) VALUE "overworld".
    05 FILLER PIC X(40) VALUE "snowy_kingdom".
    05 FILLER PIC X(40) VALUE "bottomless_pit".
    05 FILLER PIC X(40) VALUE "desert".
    05 FILLER PIC X(40) VALUE "redstone_ready".
    05 FILLER PIC X(40) VALUE "the_void".
 01 WS-NAMES REDEFINES WS-PRESET-NAMES.
    05 WS-PRESET           PIC X(40) OCCURS 9 TIMES.
*> the column from the bottom up as "block height" runs (56 section 3.2; the snow layer of snowy_kingdom is there after the fill_layer step)
 01 WS-COLUMN-TEXT.
    05 FILLER PIC X(150) VALUE "bedrock 1,dirt 2,grass_block 1".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 230,dirt 5,grass_block 1".
    05 FILLER PIC X(150) VALUE "bedrock 1,deepslate 64,stone 5,dirt 5,gravel 5,water 90".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 59,dirt 3,grass_block 1".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 59,dirt 3,grass_block 1,snow 1".
    05 FILLER PIC X(150) VALUE "cobblestone 2,dirt 3,grass_block 1".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 3,sandstone 52,sand 8".
    05 FILLER PIC X(150) VALUE "bedrock 1,stone 3,sandstone 116".
    05 FILLER PIC X(150) VALUE " ".
 01 WS-COLUMNS REDEFINES WS-COLUMN-TEXT.
    05 WS-COLUMN           PIC X(150) OCCURS 9 TIMES.
*> expected heights: OCEAN_FLOOR_WG, WORLD_SURFACE_WG, MOTION_BLOCKING, spawn height (56 section 3.2 and 7)
 01 WS-HEIGHT-TEXT.
    05 FILLER PIC X(40) VALUE "-60 -60 -60 -60".
    05 FILLER PIC X(40) VALUE "173 173 173 173".
    05 FILLER PIC X(40) VALUE "16 106 106 106".
    05 FILLER PIC X(40) VALUE "0 0 0 0".
    05 FILLER PIC X(40) VALUE "0 0 0 1".
    05 FILLER PIC X(40) VALUE "-58 -58 -58 -58".
    05 FILLER PIC X(40) VALUE "0 0 0 0".
    05 FILLER PIC X(40) VALUE "56 56 56 56".
    05 FILLER PIC X(40) VALUE "-64 -64 -64 -63".
 01 WS-HEIGHTS REDEFINES WS-HEIGHT-TEXT.
    05 WS-HEIGHT           PIC X(40) OCCURS 9 TIMES.
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
         MOVE "test flat column no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Flat" TO CS-NEW-WORLD-NAME
     MOVE 0 TO FS-PENDING
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "test flat column the world is open and of the superflat type" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING CW-OPEN " " FUNCTION TRIM(CW-WORLD-TYPE) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "Y superflat" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test flat column the spawn of a new default world is (0, -60, 0) (56 section 7.1)" TO TL-CASE
     MOVE CW-SPAWN-X TO WS-NUM
     MOVE CW-SPAWN-Y TO WS-NUM2
     MOVE CW-SPAWN-Z TO WS-NUM3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) " " FUNCTION TRIM(WS-NUM3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 -60 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CW-SEED TO WS-SEED
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-MEM
     INITIALIZE GEN-STAGES

*>   the default column and its biome
     CALL "FLAT-SETTINGS-DEFAULT"
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM DESCRIBE-COLUMN
     MOVE "test flat column the default column from min y up is bedrock, dirt x2, grass_block (56 section 7.1)" TO TL-CASE
     MOVE WS-COLUMN(1) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         IF CBI-KEY(WS-I)(1:16) = "minecraft:plains" AND CBI-KEY-LENGTH(WS-I) = 16
             COMPUTE WS-STATE = WS-I - 1
         END-IF
     END-PERFORM
     MOVE WS-STATE TO WS-DEFAULT-ID
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         IF CE-BIOME(WS-I) NOT = WS-STATE
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "test flat column every biome cell of the default world is minecraft:plains" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test flat column every column of the chunk is alike: cell (15, -61, 15) holds the grass state of cell (0, -61, 0)" TO TL-CASE
     MOVE 1024 TO WS-CELL-A
     MOVE 769 TO WS-CELL-B
     MOVE CE-STATE(WS-CELL-A) TO WS-NUM
     MOVE CE-STATE(WS-CELL-B) TO WS-NUM2
     MOVE WS-NUM TO TL-OBSERVED
     MOVE WS-NUM2 TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test flat column a chunk far from the origin is the same column" TO TL-CASE
     MOVE 1000 TO WS-CX
     MOVE -777 TO WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM DESCRIBE-COLUMN
     MOVE WS-COLUMN(1) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the nine presets
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-PRESET(WS-I) TO WS-NAME
         CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
         MOVE 0 TO WS-CX WS-CZ
         CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
         PERFORM DESCRIBE-COLUMN
         MOVE SPACES TO TL-CASE
         STRING "test flat column the column of preset " FUNCTION TRIM(WS-NAME) " from min y up (56 section 3.2)" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-COLUMN(WS-I) TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-ORD
         CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H0
         MOVE 2 TO WS-ORD
         CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H2
         MOVE 4 TO WS-ORD
         CALL "FLAT-BASE-HEIGHT" USING WS-ORD WS-H4
         CALL "FLAT-SPAWN-HEIGHT" USING WS-SPAWN-Y
         MOVE WS-H2 TO WS-NUM
         MOVE WS-H0 TO WS-NUM2
         MOVE WS-H4 TO WS-NUM3
         MOVE WS-SPAWN-Y TO WS-NUM4
         MOVE SPACES TO WS-TEXT
         STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) " " FUNCTION TRIM(WS-NUM3) " " FUNCTION TRIM(WS-NUM4)
             DELIMITED BY SIZE INTO WS-TEXT
         MOVE SPACES TO TL-CASE
         STRING "test flat column the heights of preset " FUNCTION TRIM(WS-NAME) ": ocean floor, world surface, motion blocking, spawn height"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-HEIGHT(WS-I) TO TL-EXPECTED
         MOVE WS-TEXT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE "test flat column no noise, climate, density, aquifer, surface, carver, ore or feature stage ran" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = GS-NOISE + GS-CLIMATE + GS-DENSITY + GS-AQUIFER + GS-SURFACE + GS-CARVER + GS-ORE + GS-FEATURE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   structures: the default world over 49 x 49 chunks
     MOVE "flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM SCAN-STARTS
     MOVE "test flat column the default world has village starts in 49 x 49 chunks and only villages or strongholds (56 section 4.7)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BAD
     IF WS-VILLAGES = 0
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "redstone_ready" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM SCAN-STARTS
     MOVE "test flat column a preset with an empty structure_overrides has no start in 49 x 49 chunks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-STARTS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "tunnelers_dream" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM SCAN-STARTS
     MOVE "test flat column tunnelers_dream has only mineshafts and strongholds (no village: not in its overrides)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-VILLAGES TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   a village start chunk of the default world holds structure blocks above the grass; with generate_structures 0 it holds none
     MOVE "flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     PERFORM SCAN-STARTS
     MOVE WS-VX TO WS-CX
     MOVE WS-VZ TO WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM COUNT-ABOVE-GRASS
     MOVE "test flat column a village start chunk holds structure blocks above the grass (y -60 and up)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OTHER > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 0 TO FS-GEN-STRUCT
     CALL "FLAT-STRUCT-RESET"
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM COUNT-ABOVE-GRASS
     MOVE "test flat column with generate_structures 0 the same chunk holds nothing above the grass" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-OTHER TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a biome the content does not have is plains (56 section 2.1)
     MOVE "flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE "minecraft:nope" TO FS-BIOME
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         IF CE-BIOME(WS-I) NOT = WS-DEFAULT-ID
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "test flat column an unknown biome in the settings gives plains in every cell" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   a stack taller than the dimension is cut at 384 layers (56 section 4.3): bedrock 1 and stone 399 fill y -64 to 319
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE 2 TO FS-LAYER-COUNT
     MOVE "minecraft:bedrock" TO FS-L-KEY(1)
     MOVE 1 TO FS-L-HEIGHT(1)
     MOVE "minecraft:stone" TO FS-L-KEY(2)
     MOVE 399 TO FS-L-HEIGHT(2)
     MOVE 400 TO FS-TOTAL
     MOVE -1 TO FS-STAMP
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM DESCRIBE-COLUMN
     MOVE "test flat column a stack of 400 layers is cut at the dimension height: bedrock 1, stone 383" TO TL-CASE
     MOVE "bedrock 1,stone 383" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS

*>   a negative world seed generates the same flat column, structures included (the seed only seeds the structure placement)
     MOVE CW-SEED TO WS-SAVE-SEED
     MOVE -5 TO CW-SEED
     CALL "FLAT-STRUCT-RESET"
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM DESCRIBE-COLUMN
     MOVE WS-SAVE-SEED TO CW-SEED
     MOVE "test flat column a world with a negative seed generates the default column" TO TL-CASE
     MOVE WS-COLUMN(1) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the one clock of a superflat world is minecraft:overworld (a standard-set world, 16 section 4.5)
     MOVE 1000 TO CW-TIME
     MOVE Z"time set 5000" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE SPACES TO WS-AREA
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-AREA(1:CB-LENGTH) TO TL-OBSERVED
     INSPECT TL-OBSERVED REPLACING ALL X"0A" BY SPACE
     MOVE "test flat column the time command of a superflat world names the clock minecraft:overworld" TO TL-CASE
     MOVE "Set minecraft:overworld to 5000 tick(s)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the column query of the structure code answers from the flat settings (STRUCT-BASE-HEIGHT: kind 0 WORLD_SURFACE_WG, kind 1 OCEAN_FLOOR_WG)
     MOVE "water_world" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE 12345 TO WS-CX
     MOVE -321 TO WS-CZ
     MOVE 0 TO WS-ORD
     CALL "STRUCT-BASE-HEIGHT" USING WS-CX WS-CZ WS-ORD WS-H0
     MOVE 1 TO WS-ORD
     CALL "STRUCT-BASE-HEIGHT" USING WS-CX WS-CZ WS-ORD WS-H2
     MOVE WS-H0 TO WS-NUM
     MOVE WS-H2 TO WS-NUM2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test flat column STRUCT-BASE-HEIGHT in a water world: surface 106, ocean floor 16, in any column" TO TL-CASE
     MOVE "106 16" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   settings nobody filled: the structure code's own entry points ask for the default (plains, strongholds and villages)
     MOVE 0 TO FS-LOADED
     MOVE 0 TO WS-I
     CALL "STRUCT-BIOME-AT" USING WS-CX WS-CZ WS-I WS-J WS-KEY80
     MOVE "test flat column STRUCT-BIOME-AT with no settings loaded answers the default biome, minecraft:plains" TO TL-CASE
     MOVE WS-KEY80(1:16) TO TL-OBSERVED
     MOVE "minecraft:plains" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FS-LOADED
     MOVE "minecraft:villages" TO WS-KEY80
     CALL "FLAT-STRUCT-SET-OK" USING WS-KEY80 WS-OK
     MOVE WS-OK TO WS-NUM
     MOVE 0 TO FS-LOADED
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "minecraft:igloos" TO WS-KEY80
     CALL "FLAT-STRUCT-SET-OK" USING WS-KEY80 WS-OK
     MOVE WS-OK TO WS-NUM2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test flat column with no settings loaded the default allows villages and not igloos" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the stronghold rings are made from seed 0 in a flat world: the first positions are the same for two world seeds (56 section 4.7)
     MOVE "flat" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     MOVE 0 TO WS-RING-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         IF SS-KEY(WS-I) = "minecraft:strongholds"
             MOVE WS-I TO WS-RING-SET
         END-IF
     END-PERFORM
     CALL "STRUCT-RINGS-ALL" USING WS-RING-SET WS-SEED
     MOVE SS-RING-ROW(WS-RING-SET) TO WS-ROW
     MOVE SR-X(WS-ROW, 1) TO WS-NUM
     MOVE SR-Z(WS-ROW, 1) TO WS-NUM2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) DELIMITED BY SIZE INTO WS-TEXT
     COMPUTE WS-SEED = WS-SEED + 777
     CALL "STRUCT-RINGS-ALL" USING WS-RING-SET WS-SEED
     MOVE SS-RING-ROW(WS-RING-SET) TO WS-ROW
     MOVE SR-X(WS-ROW, 1) TO WS-NUM
     MOVE SR-Z(WS-ROW, 1) TO WS-NUM2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(WS-NUM2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test flat column the first stronghold position does not depend on the world seed in a superflat world" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test flat column the first stronghold position is far from the origin (ring 1: 1408 to 2432 blocks)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(SR-X(WS-ROW, 1)) + FUNCTION ABS(SR-Z(WS-ROW, 1))
     IF TL-OBSERVED-N > 64
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   save and reopen: the folder keeps the type and the settings (tunnelers_dream), whatever type the host asks for
     MOVE "tunnelers_dream" TO WS-NAME
     CALL "FLAT-PRESET-SET" USING WS-NAME WS-STATUS
     CALL "CORE-SAVE"
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE 0 TO FS-PENDING FS-TOTAL FS-LAYER-COUNT
     MOVE SPACES TO FS-BIOME
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE FS-TOTAL TO WS-NUM
     MOVE WS-CREATED TO WS-NUM2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CW-WORLD-TYPE) " " FUNCTION TRIM(WS-NUM2) " " FUNCTION TRIM(WS-NUM) " " FUNCTION TRIM(FS-BIOME)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "test flat column a saved superflat world reopens as superflat with its preset (237 layers, windswept_hills), not created" TO TL-CASE
     MOVE "superflat 0 237 minecraft:windswept_hills" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   no creatures at chunk generation
     CALL "MS6-CHUNK-GEN-TICK" USING WS-MOBS
     MOVE "test flat column a fresh chunk of a superflat world is given no creatures" TO TL-CASE
     MOVE WS-MOBS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The column (0, 0) of the chunk in WS-MEM from y -64 up as "block height" runs, air left out.
 DESCRIBE-COLUMN.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE SPACES TO WS-LAST
     MOVE 0 TO WS-RUN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 384
         MOVE SPACES TO WS-BARE
         IF WS-Y < 384
             COMPUTE WS-CELL = WS-Y * 256 + 1
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             IF WS-STATE NOT = 0
                 COMPUTE WS-B = CB-S-BLOCK(WS-STATE + 1) + 1
                 MOVE CB-KEY(WS-B) TO WS-KEY
                 CALL "KEY-BARE" USING WS-KEY WS-BARE
             END-IF
         END-IF
         IF WS-BARE NOT = WS-LAST
             IF WS-RUN > 0
                 MOVE WS-RUN TO WS-NUM
                 IF WS-PTR > 1
                     STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING FUNCTION TRIM(WS-LAST) " " FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
             MOVE WS-BARE TO WS-LAST
             MOVE 0 TO WS-RUN
         END-IF
         IF WS-BARE NOT = SPACES
             ADD 1 TO WS-RUN
         END-IF
     END-PERFORM.

*> The structure starts of the 49 x 49 chunks around the origin (STRUCT-CHUNK-STARTS with the world's seed): WS-STARTS all, WS-VILLAGES the villages
*> (first one at WS-VX, WS-VZ), WS-BAD the starts of a family the default settings do not allow (neither village nor stronghold).
 SCAN-STARTS.
     MOVE 0 TO WS-STARTS WS-BAD WS-VILLAGES WS-VX WS-VZ
     IF SD-POSS-DONE = 0
         CALL "STRUCT-POSSIBLE-BUILD"
     END-IF
     PERFORM VARYING WS-CX FROM -24 BY 1 UNTIL WS-CX > 24
         PERFORM VARYING WS-CZ FROM -24 BY 1 UNTIL WS-CZ > 24
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                 ADD 1 TO WS-STARTS
                 MOVE SDT-KEY(SC-STRUCT(WS-J)) TO WS-KEY80
                 EVALUATE TRUE
                     WHEN WS-KEY80(1:18) = "minecraft:village_"
                         IF WS-VILLAGES = 0
                             MOVE WS-CX TO WS-VX
                             MOVE WS-CZ TO WS-VZ
                         END-IF
                         ADD 1 TO WS-VILLAGES
                     WHEN WS-KEY80 = "minecraft:stronghold"
                         CONTINUE
                     WHEN OTHER
                         ADD 1 TO WS-BAD
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> WS-OTHER: the cells of the chunk in WS-MEM above y -61 (the grass of the default stack) that are not air.
 COUNT-ABOVE-GRASS.
     MOVE 0 TO WS-OTHER
     MOVE 1025 TO WS-FIRST
     PERFORM VARYING WS-CELL FROM WS-FIRST BY 1 UNTIL WS-CELL > 98304
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-OTHER
         END-IF
     END-PERFORM.
 END PROGRAM TEST-FLAT-COLUMN.

 COPY CORETEST.
