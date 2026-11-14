*> Acceptance test of docs/protocol/36-structures-2 sections 3.2, 3.5 and 5 (placeInWorld into the chunk window of the feature stage), over the standard content set
*> of the generated packs (skipped as a pass without them): the entity position transform (example 11.1), the early exits of 5.1, the transform of states by mirror then
*> rotation (5.3 step 3, 24-9), the bounding box, the write window, the block entity hook, waterlogging (5.3 step 8, 5.4, example 11.10), the shape updates of 5.5 (the
*> face order of 5.5.1 as the updateShape hook sees it), the palette choice, the filtered views of 3.5, and the property helpers the placement uses.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 COPY STRUCTPLACE.
 COPY FEATLEVEL.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-LABEL               PIC X(150).
 01 WS-AT-TEXT             PIC X(200).
 01 WS-AT2                 PIC X(200).
 01 WS-PTR2                BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                 PIC -(8)9.
 01 WS-ED3                 PIC -(8)9.
 01 WS-ED4                 PIC -(8)9.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-FED                 PIC -(4)9.9.
 01 WS-FED2                PIC -(4)9.9.
 01 WS-FED3                PIC -(4)9.9.
 01 WS-MODE                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COPY-STATE          BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG.
 01 WS-NAMES               PIC X(80).
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-2§5 Placing a template: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO SHT-ON SBH-CALLS

*>   Section 3.2: the entity transform (example 11.1).
     MOVE 1.5 TO WS-FX
     MOVE 0 TO WS-FY
     MOVE 0.5 TO WS-FZ
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Z
     MOVE "entity at (1.5, 0, 0.5), clockwise 90, pivot origin: the middle of block (0, 0, 1)" TO WS-LABEL
     PERFORM TX-VEC
     MOVE "0.5 0.0 1.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "entity, clockwise 180" TO WS-LABEL
     MOVE 2 TO WS-B
     PERFORM TX-VEC
     MOVE "-0.5 0.0 0.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "entity, counterclockwise 90" TO WS-LABEL
     MOVE 3 TO WS-B
     PERFORM TX-VEC
     MOVE "0.5 0.0 -0.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "entity, clockwise 90 about the pivot (2, 2)" TO WS-LABEL
     MOVE 1 TO WS-B
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Z
     PERFORM TX-VEC
     MOVE "4.5 0.0 1.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "entity, mirror front_back (x to 1 - x), no rotation" TO WS-LABEL
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     PERFORM TX-VEC
     MOVE "-0.5 0.0 0.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "entity, mirror left_right (z to 1 - z), no rotation" TO WS-LABEL
     MOVE 1 TO WS-A
     PERFORM TX-VEC
     MOVE "1.5 0.0 0.5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The property helpers.
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=east,half=top,shape=outer_left,waterlogged=true" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE WS-STATE TO WS-STATE2
     MOVE 1 TO WS-MODE
     MOVE "facing" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-RESULT
     MOVE "property helper: facing of the stairs is east" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RESULT TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 east" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "nothing" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-RESULT
     MOVE "property helper: a property the block does not have reads as not found" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RESULT TO WS-ED
     STRING FUNCTION TRIM(WS-ED) "|" FUNCTION TRIM(WS-TEXT) "|" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0||" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 999999 TO WS-A
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-A WS-NAME WS-TEXT WS-RESULT
     MOVE 2 TO WS-MODE
     MOVE "facing" TO WS-NAME
     MOVE "south" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "property helper: set facing south" TO WS-LABEL
     MOVE "oak_stairs|facing=south,half=top,shape=outer_left,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "up" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-RESULT
     MOVE "property helper: a value the property does not have, a missing property and a state outside the table change nothing" TO WS-LABEL
     MOVE "nothing" TO WS-NAME
     MOVE "x" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-DEFAULT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-A WS-NAME WS-TEXT WS-BLOCK
     MOVE SPACES TO TL-OBSERVED
     IF WS-RESULT = WS-STATE2 AND WS-DEFAULT = WS-STATE2 AND WS-BLOCK = WS-A
         MOVE "unchanged" TO TL-OBSERVED
     END-IF
     MOVE "unchanged" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "waterlogged" TO WS-NAME
     MOVE "false" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE2 WS-NAME WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "property helper: a boolean property is set by text" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=top,shape=outer_left,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "water" TO WS-KEY
     MOVE "level=5" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE 1 TO WS-MODE
     MOVE "level" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE "property helper: a range property reads as its number" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 2 TO WS-MODE
     MOVE "12" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "property helper: a range property is set by number" TO WS-LABEL
     MOVE "water|level=12" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
*>   Block.withPropertiesOf and the list of 9.8.
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=west,half=top,shape=outer_left,waterlogged=true" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE WS-STATE TO WS-A
     MOVE "spruce_stairs" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     MOVE SPACES TO WS-NAMES
     CALL "BLOCK-STATE-COPY" USING WS-A WS-STATE WS-NAMES WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "withPropertiesOf: every property of the source that the target has" TO WS-LABEL
     MOVE "spruce_stairs|facing=west,half=top,shape=outer_left,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     MOVE "facing,half" TO WS-NAMES
     CALL "BLOCK-STATE-COPY" USING WS-A WS-STATE WS-NAMES WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "withPropertiesOf: only the listed properties (blackstone_replace copies facing and half)" TO WS-LABEL
     MOVE "spruce_stairs|facing=west,half=top,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     PERFORM STATE-OF
     MOVE WS-STATE TO WS-B
     MOVE SPACES TO WS-NAMES
     CALL "BLOCK-STATE-COPY" USING WS-A WS-B WS-NAMES WS-RESULT
     MOVE "withPropertiesOf: a target without those properties is unchanged" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-RESULT = WS-B
         MOVE "unchanged" TO TL-OBSERVED
     END-IF
     MOVE "unchanged" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Fluid states.
     MOVE "water" TO WS-KEY
     MOVE "level=0" TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: source water" TO WS-LABEL
     MOVE "2 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "level=5" TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: flowing water" TO WS-LABEL
     MOVE "2 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "lava" TO WS-KEY
     MOVE "level=0" TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: source lava" TO WS-LABEL
     MOVE "3 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "oak_stairs" TO WS-KEY
     MOVE "waterlogged=true" TO WS-PAIRS
     MOVE "facing=east,half=bottom,shape=straight,waterlogged=true" TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: a waterlogged block holds a water source" TO WS-LABEL
     MOVE "2 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "kelp" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: kelp is always full of water" TO WS-LABEL
     MOVE "2 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     PERFORM STATE-OF
     PERFORM FLUID-TEXT
     MOVE "fluid state: stone has none" TO WS-LABEL
     MOVE "0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 999999 TO WS-STATE
     PERFORM FLUID-TEXT
     MOVE "fluid state: a state outside the table has none" TO WS-LABEL
     MOVE "0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Placement without a transform (5.3).
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     PERFORM FRESH-SETTINGS
     MOVE "test:stairs" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE 3 TO WS-FLAGS
     PERFORM PLACE
     MOVE "placement runs and returns true" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE "no transform: the stone at the origin" TO WS-LABEL
     MOVE "stone|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 5 TO WS-X
     PERFORM AT-TEXT
     MOVE "no transform: the stairs keep their file state" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE "no transform: the chest" TO WS-LABEL
     MOVE "chest|facing=north,type=single,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the block entity hook ran once, for the chest (5.3 step 7)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE SBH-CALLS TO WS-ED
     MOVE SBH-X TO WS-ED2
     MOVE SBH-Z TO WS-ED3
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 4 5" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Rotation (state and position), mirror then rotation.
     PERFORM CLEAR-CHUNK
     MOVE 1 TO PS-ROTATION
     PERFORM PLACE
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE "clockwise 90: the stairs (1,0,0) go to (0,0,1) and face south" TO WS-LABEL
     MOVE "oak_stairs|facing=south,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 3 TO WS-X
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE "clockwise 90: the chest (0,0,1) goes to (-1,0,0) and faces east" TO WS-LABEL
     MOVE "chest|facing=east,type=single,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE "clockwise 90: the log along x lies along z" TO WS-LABEL
     MOVE "oak_log|axis=z" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     MOVE 0 TO PS-ROTATION
     MOVE 1 TO PS-MIRROR
     PERFORM PLACE
     MOVE 4 TO WS-X
     MOVE 3 TO WS-Z
     PERFORM AT-TEXT
     MOVE "mirror left_right: the chest (0,0,1) goes to (0,0,-1) and faces south" TO WS-LABEL
     MOVE "chest|facing=south,type=single,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 5 TO WS-X
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE "mirror left_right: stairs facing east are unchanged (24-9 3.8)" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     MOVE 3 TO PS-ROTATION
     MOVE 2 TO PS-MIRROR
     PERFORM PLACE
     MOVE "mirror front_back then counterclockwise 90 (stairs east to west to south)" TO WS-LABEL
*>   (x, z) -> (-x, z) -> (z, x): the stairs (1,0,0) go to (0,0,1) -> world (4,70,5).
     MOVE 4 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE "oak_stairs|facing=south,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The bounding box and the window.
     PERFORM CLEAR-CHUNK
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-BOX-SET
     MOVE 4 TO PS-BOX(1)
     MOVE 70 TO PS-BOX(2)
     MOVE 4 TO PS-BOX(3)
     MOVE 4 TO PS-BOX(4)
     MOVE 71 TO PS-BOX(5)
     MOVE 4 TO PS-BOX(6)
     PERFORM PLACE
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE TL-OBSERVED TO WS-AT-TEXT
     MOVE 5 TO WS-X
     PERFORM AT-TEXT
     MOVE SPACES TO WS-AT2
     STRING FUNCTION TRIM(WS-AT-TEXT) " " FUNCTION TRIM(TL-OBSERVED) DELIMITED BY SIZE INTO WS-AT2
     MOVE WS-AT2 TO TL-OBSERVED
     MOVE "bounding box: only the cells inside it are written" TO WS-LABEL
     MOVE "stone| air|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     PERFORM FRESH-SETTINGS
     MOVE 15 TO WS-OX
     MOVE 0 TO FL-DISCARDED
     PERFORM PLACE
     MOVE 15 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE FL-DISCARDED TO WS-ED
     MOVE SPACES TO WS-AT2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-AT2
     MOVE WS-AT2 TO TL-OBSERVED
     MOVE "the write window is the chunk: records at x = 16 (the stairs and the log) are refused and counted" TO WS-LABEL
     MOVE "stone| 2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-OX

*>   Early exits (5.1).
     PERFORM FRESH-SETTINGS
     PERFORM CLEAR-CHUNK
     MOVE "minecraft:empty" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM PLACE
     MOVE "early exit: a template without palettes places nothing" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:nothing" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM PLACE
     MOVE "early exit: no blocks and no entities" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:onlyent" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM PLACE
     MOVE "early exit: entities but a size component below 1" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:onlyent1" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM PLACE
     MOVE "an entity-only template of a valid size is placed (true, no block written)" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO PS-IGNORE-ENTITIES
     PERFORM PLACE
     MOVE "early exit: no blocks and the entities ignored" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:none-such" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM PLACE
     MOVE "early exit: an absent template" TO WS-LABEL
     MOVE WS-RESULT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The palette choice (4.3, example 11.5) with and without a shared random.
     PERFORM FRESH-SETTINGS
     PERFORM CLEAR-CHUNK
     MOVE "test:two" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE 10 TO WS-OX
     MOVE 64 TO WS-OY
     MOVE 10 TO WS-OZ
     PERFORM PLACE
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10 TO WS-Z
     PERFORM AT-TEXT
     MOVE "palette: two palettes at (10,64,10) choose palette 0 (example 11.5)" TO WS-LABEL
     MOVE "stone|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 12345 TO WS-SEED
     CALL "JRAND-SET-SEED" USING PS-RANDOM WS-SEED
     MOVE 1 TO PS-RANDOM-SET
     MOVE PS-RANDOM TO WS-COPY-STATE
     MOVE 2 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-COPY-STATE WS-BOUND WS-DRAW
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "palette: a shared random in the settings picks the palette with its own draw" TO WS-LABEL
     IF WS-DRAW = 0
         MOVE "stone|" TO TL-EXPECTED
     ELSE
         MOVE "cobblestone|" TO TL-EXPECTED
     END-IF
     PERFORM ASSERT-TEXT
     MOVE "palette: the settings' random advanced by exactly that draw" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE "same" TO TL-EXPECTED
     IF PS-RANDOM = WS-COPY-STATE
         MOVE "same" TO TL-OBSERVED
     END-IF
     PERFORM ASSERT-TEXT
     MOVE 0 TO PS-RANDOM-SET
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ

*>   Waterlogging (5.3 step 8, 5.4, example 11.10).
     MOVE "test:wet" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM CLEAR-CHUNK
     MOVE "water" TO WS-KEY
     MOVE "level=3" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM SET-STATE
     MOVE "level=0" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE 71 TO WS-Y
     PERFORM SET-STATE
     MOVE 70 TO WS-Y
     PERFORM FRESH-SETTINGS
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "example 11.10: stairs over flowing water with a source above become waterlogged by the pass" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     MOVE "level=3" TO WS-PAIRS
     MOVE "water" TO WS-KEY
     PERFORM STATE-OF
     PERFORM SET-STATE
     MOVE "level=0" TO WS-PAIRS
     PERFORM STATE-OF
     MOVE 71 TO WS-Y
     PERFORM SET-STATE
     MOVE 70 TO WS-Y
     MOVE 1 TO PS-LIQUID
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "ignore_waterlogging: no fluid is read and the stairs stay dry" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     PERFORM FRESH-SETTINGS
     MOVE "level=0" TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM SET-STATE
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "placed over a source water cell: waterlogged at once (placeLiquid)" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=true" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "placed in the dry: no fluid, not waterlogged" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:pool" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM CLEAR-CHUNK
     MOVE "level=3" TO WS-PAIRS
     MOVE 5 TO WS-X
     PERFORM STATE-OF
     PERFORM SET-STATE
     PERFORM PLACE
     PERFORM AT-TEXT
     MOVE "a source the template itself wrote is in fluidDone: it does not waterlog the next block" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-X
     PERFORM AT-TEXT
     MOVE "the water block of the template is placed" TO WS-LABEL
     MOVE "water|level=0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Shape updates (5.5, 5.5.1).
     MOVE "test:cube" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM CLEAR-CHUNK
     PERFORM FRESH-SETTINGS
     MOVE 1 TO SHT-ON
     MOVE 0 TO SHT-COUNT
     MOVE 3 TO WS-FLAGS
     PERFORM PLACE
     MOVE "shape updates: 24 exposed faces of the 2x2x2 cube, two hook calls each, and six neighbour shapes for each of the 8 cells" TO WS-LABEL
     MOVE SHT-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "96" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "shape updates: pass 1 meets the faces along z for x then y: north of (4,70,4), the south neighbour of its far end, then y 71" TO WS-LABEL
     MOVE SPACES TO WS-AT-TEXT
     MOVE 1 TO WS-PTR2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         PERFORM TRACE-ENTRY
     END-PERFORM
     MOVE WS-AT-TEXT TO TL-OBSERVED
     MOVE "4,70,4,2 4,70,3,3 4,70,5,3 4,70,6,2 4,71,4,2 4,71,3,3" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "shape updates: pass 2 along y (z then x), pass 3 along x (y then z)" TO WS-LABEL
     MOVE SPACES TO WS-AT-TEXT
     MOVE 1 TO WS-PTR2
     MOVE 17 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE 18 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE 25 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE 29 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE 33 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE 41 TO WS-I
     PERFORM TRACE-ENTRY
     MOVE WS-AT-TEXT TO TL-OBSERVED
     MOVE "4,70,4,0 4,69,4,1 4,70,5,0 5,70,5,0 4,70,4,4 4,71,4,4" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "shape updates: the neighbour shapes of the first cell in the order west, east, north, south, down, up" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR2
     PERFORM VARYING WS-I FROM 49 BY 1 UNTIL WS-I > 54
         MOVE SHT-DIR(WS-I) TO WS-ED4
         STRING FUNCTION TRIM(WS-ED4) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR2
     END-PERFORM
     MOVE "452301" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "shape updates: the first neighbour call is the cell itself at (4,70,4)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE SHT-X(49) TO WS-ED
     MOVE SHT-Y(49) TO WS-ED2
     MOVE SHT-Z(49) TO WS-ED3
     STRING FUNCTION TRIM(WS-ED) "," FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4,70,4" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CLEAR-CHUNK
     MOVE 1 TO PS-KNOWN-SHAPE
     MOVE 0 TO SHT-COUNT
     PERFORM PLACE
     MOVE "known shape: no shape update at all" TO WS-LABEL
     MOVE SHT-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO SHT-ON

*>   The writes of 5.5: a state the hook changes is written back at the face, in the neighbour, and for a cell no face reached.
     MOVE "test:cube3" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM CLEAR-CHUNK
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     MOVE WS-STATE TO SHT-FROM
     MOVE 3 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM SET-STATE
     MOVE "cobblestone" TO WS-KEY
     PERFORM STATE-OF
     MOVE WS-STATE TO SHT-TO
     PERFORM FRESH-SETTINGS
     MOVE 1 TO SHT-ON
     PERFORM PLACE
     MOVE 0 TO SHT-ON
     MOVE 0 TO WS-A
     PERFORM VARYING WS-X FROM 4 BY 1 UNTIL WS-X > 6
         PERFORM VARYING WS-Y FROM 70 BY 1 UNTIL WS-Y > 72
             PERFORM VARYING WS-Z FROM 4 BY 1 UNTIL WS-Z > 6
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE = SHT-TO
                     ADD 1 TO WS-A
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 3 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "shape updates: faces rewrite the cells (26), the unexposed centre is rewritten by the last pass, the neighbour of a face is rewritten (27 + 1)" TO WS-LABEL
     MOVE WS-A TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     IF WS-STATE = SHT-TO
         STRING FUNCTION TRIM(WS-ED) " neighbour" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-ED) " no neighbour" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "27 neighbour" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO SHT-FROM SHT-TO

*>   Section 3.5: the filtered views.
     MOVE "test:stairs" TO WS-ID
     PERFORM LOAD-TEMPLATE
     PERFORM FRESH-SETTINGS
     MOVE 1 TO PS-ROTATION
     MOVE "minecraft:oak_stairs" TO WS-KEY48
     MOVE 1 TO WS-A
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE SF-STATE(1) TO WS-STATE
     PERFORM STATE-TEXT
     MOVE SPACES TO WS-AT-TEXT
     MOVE SF-X(1) TO WS-ED
     MOVE SF-Y(1) TO WS-ED2
     MOVE SF-Z(1) TO WS-ED3
     MOVE SF-COUNT TO WS-ED4
     STRING FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(WS-ED) "," FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(TL-OBSERVED)
         DELIMITED BY SIZE INTO WS-AT-TEXT
     MOVE "filterBlocks: the stairs, position transformed and state rotated clockwise 90" TO WS-LABEL
     MOVE WS-AT-TEXT TO TL-OBSERVED
     MOVE "1 4,70,5 oak_stairs|facing=south,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-A
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE SF-X(1) TO WS-ED
     MOVE SF-Y(1) TO WS-ED2
     MOVE SF-Z(1) TO WS-ED3
     STRING FUNCTION TRIM(WS-ED) "," FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "filterBlocks with relative false keeps the template-local position" TO WS-LABEL
     MOVE "1,0,0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-A
     MOVE 0 TO PS-ROTATION
     MOVE 1 TO PS-MIRROR
     MOVE "minecraft:oak_stairs" TO WS-KEY48
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE SF-STATE(1) TO WS-STATE
     PERFORM STATE-TEXT
     MOVE "filterBlocks rotates the state but does not mirror it" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "chest" TO WS-KEY48
     MOVE 0 TO PS-MIRROR
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE "filterBlocks passes the nbt flag through (the key may lack the namespace)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE SF-COUNT TO WS-ED
     MOVE SF-NBT(1) TO WS-ED2
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO PS-BOX-SET
     MOVE 100 TO PS-BOX(1)
     MOVE 100 TO PS-BOX(2)
     MOVE 100 TO PS-BOX(3)
     MOVE 110 TO PS-BOX(4)
     MOVE 110 TO PS-BOX(5)
     MOVE 110 TO PS-BOX(6)
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE "filterBlocks drops the records outside the settings' box" TO WS-LABEL
     MOVE SF-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO PS-BOX-SET
     MOVE "minecraft:no_such_block" TO WS-KEY48
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE "filterBlocks of a block the content set does not have is empty" TO WS-LABEL
     MOVE SF-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "minecraft:none-such" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE "stone" TO WS-KEY48
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE "filterBlocks of an absent template is empty" TO WS-LABEL
     MOVE SF-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:two" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE 12345 TO WS-SEED
     CALL "JRAND-SET-SEED" USING PS-RANDOM WS-SEED
     MOVE 1 TO PS-RANDOM-SET
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW WS-OX WS-OY WS-OZ STRUCT-SETTINGS WS-KEY48 WS-A
     MOVE "filterBlocks with a shared random draws the palette like placeInWorld" TO WS-LABEL
     MOVE SF-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     IF WS-DRAW = 0
         MOVE "1" TO TL-EXPECTED
     ELSE
         MOVE "0" TO TL-EXPECTED
     END-IF
     PERFORM ASSERT-TEXT
     GOBACK.

 TRACE-ENTRY.
     MOVE SHT-X(WS-I) TO WS-ED
     MOVE SHT-Y(WS-I) TO WS-ED2
     MOVE SHT-Z(WS-I) TO WS-ED3
     MOVE SHT-DIR(WS-I) TO WS-ED4
     IF WS-PTR2 > 1
         STRING " " DELIMITED BY SIZE INTO WS-AT-TEXT WITH POINTER WS-PTR2
     END-IF
     STRING FUNCTION TRIM(WS-ED) "," FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) "," FUNCTION TRIM(WS-ED4)
         DELIMITED BY SIZE INTO WS-AT-TEXT WITH POINTER WS-PTR2.

 TX-VEC.
     CALL "STRUCT-TX-VEC" USING WS-FX WS-FY WS-FZ WS-A WS-B WS-X WS-Z WS-GX WS-GY WS-GZ
     MOVE WS-GX TO WS-FED
     MOVE WS-GY TO WS-FED2
     MOVE WS-GZ TO WS-FED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-FED) " " FUNCTION TRIM(WS-FED2) " " FUNCTION TRIM(WS-FED3) DELIMITED BY SIZE INTO TL-OBSERVED.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-2§5 Placing a template: " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> STATE-OF: WS-STATE of the block WS-KEY with the properties WS-PAIRS (all of them, or none for the default state).
 STATE-OF.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE.

*> STATE-TEXT: TL-OBSERVED is "key|properties" of WS-STATE.
 STATE-TEXT.
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CB-KEY(WS-BLOCK + 1)) "|" FUNCTION TRIM(WS-PROPS) DELIMITED BY SIZE INTO TL-OBSERVED.

 AT-TEXT.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     PERFORM STATE-TEXT.

 SET-STATE.
     MOVE 0 TO WS-FLAGS
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 3 TO WS-FLAGS.

 FLUID-TEXT.
     CALL "STRUCT-FLUID-OF" USING WS-STATE WS-FLUID WS-SOURCE
     MOVE WS-FLUID TO WS-ED
     MOVE WS-SOURCE TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED.

 FRESH-SETTINGS.
     INITIALIZE STRUCT-SETTINGS
     MOVE 3 TO WS-FLAGS.

 CLEAR-CHUNK.
     MOVE LOW-VALUES TO CE-STATES
     MOVE 0 TO FL-DISCARDED.

 LOAD-TEMPLATE.
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW.

 PLACE.
     MOVE WS-OX TO WS-AX
     MOVE WS-OY TO WS-AY
     MOVE WS-OZ TO WS-AZ
     CALL "STRUCT-PLACE" USING WS-ROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT.
