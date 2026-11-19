*> Acceptance test, lane bugstackplace (operator report try18: "sea cucumbers don't place multiple in the block", read as the sea pickle; docs/protocol/24 part 6 section 6.14
*> SEA_PICKLE and section 6.15 TURTLE_EGG placement and canBeReplaced, 29b-4 section 10 SeaPickleBlock, 29b-7 candle placement and canBeReplaced, 24 part 3 SnowLayerBlock replacement,
*> 29 section 9.5 BlockPlaceContext): a standard world opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it).
*> A grass floor lies high above the terrain; the player holds the item (survival) and sends Use Item On through the real packet handler. A block that stacks (sea pickle: pickles 1 to 4,
*> turtle egg: eggs 1 to 4, candle of every colour: candles 1 to 4, snow: layers 1 to 8) gains one when its own item is used on it (not sneaking, count below the maximum; snow: the top
*> face when the clicked block is replaced, any face of the neighbour that holds it) and keeps all its other properties; at the maximum the item goes into the cell beside the clicked face.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-STACK-PLACE.
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
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-UX                  BINARY-LONG.
 01 WS-UY                  BINARY-LONG.
 01 WS-UZ                  BINARY-LONG.
 01 WS-WANT                PIC X(48).
 01 WS-WANT-N              PIC X(2).
 01 WS-PROP                PIC X(24).
 01 WS-PROP2               PIC X(24).
 01 WS-WANT2               PIC X(8).
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT-AREA           PIC X(1024).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HAND-ITEM           PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-UPDATE              PIC X(40).
 01 WS-ED-X                PIC -(9)9.
 01 WS-ED-Y                PIC -(9)9.
 01 WS-ED-Z                PIC -(9)9.
 01 WS-ED-S                PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-ZEROS               PIC X(8).
 01 WS-KINDS.
    05 FILLER              PIC X(24) VALUE "sea_pickle".
    05 FILLER              PIC X(24) VALUE "pickles".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              PIC X(24) VALUE "turtle_egg".
    05 FILLER              PIC X(24) VALUE "eggs".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              PIC X(24) VALUE "candle".
    05 FILLER              PIC X(24) VALUE "candles".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              PIC X(24) VALUE "red_candle".
    05 FILLER              PIC X(24) VALUE "candles".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              PIC X(24) VALUE "snow".
    05 FILLER              PIC X(24) VALUE "layers".
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-KIND-TABLE REDEFINES WS-KINDS.
    05 WS-KIND OCCURS 5 TIMES.
       10 WS-K-ITEM        PIC X(24).
       10 WS-K-PROP        PIC X(24).
       10 WS-K-MAX         BINARY-LONG.
       10 WS-K-SNOW        BINARY-LONG.
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
         MOVE "acceptance stack place no generated packs here, skipped" TO TL-CASE
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
     MOVE "Stacks" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GRASS
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 14
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 16
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-GRASS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 13.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 3
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 15.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-CY = WS-FLOOR + 1
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA

     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE WS-K-ITEM(WS-K) TO WS-HAND-ITEM
         MOVE WS-K-ITEM(WS-K) TO WS-WANT
         MOVE WS-K-PROP(WS-K) TO WS-PROP
         MOVE WS-K-MAX(WS-K) TO WS-MAX
         MOVE WS-K-SNOW(WS-K) TO WS-SNOW
         COMPUTE WS-CZ = WS-BZ + 2 + 3 * (WS-K - 1)
         PERFORM CHAIN-A
         PERFORM SIDE-B
         PERFORM NEIGHBOUR-C
         PERFORM SNEAK-D
     END-PERFORM

     PERFORM EXTRAS
     STOP RUN.

*> Cell A (x + 2): the item on the grass, then on the top face of the stack until the maximum, the fifth use beside the stack (and for snow above it, the stack at 8 layers being full).
 CHAIN-A.
     COMPUTE WS-CX = WS-BX + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "1" TO WS-WANT-N
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: the first " FUNCTION TRIM(WS-HAND-ITEM) " on the grass places one (count 1)" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-UY = WS-FLOOR + 1
     PERFORM VARYING WS-N FROM 2 BY 1 UNTIL WS-N > WS-MAX
         PERFORM USE-ITEM-ON
         MOVE SPACES TO WS-WANT-N
         MOVE FUNCTION CHAR(WS-N + 49) TO WS-WANT-N(1:1)
         MOVE SPACES TO WS-CASE
         STRING "acceptance stack place: use number " WS-WANT-N " of " FUNCTION TRIM(WS-HAND-ITEM) " on its top face adds one to the same block"
             DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-COUNT
     END-PERFORM
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "air" TO WS-WANT
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: the stack of " FUNCTION TRIM(WS-HAND-ITEM) " put nothing in the cell above" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE WS-K-ITEM(WS-K) TO WS-WANT
*>   The fifth use (ninth for snow) on the north face of the full stack goes in the cell north of it.
     MOVE 2 TO WS-FACE
     PERFORM USE-ITEM-ON
     COMPUTE WS-CZ = WS-CZ - 1
     MOVE "1" TO WS-WANT-N
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: a use on the side of a full " FUNCTION TRIM(WS-HAND-ITEM) " stack places a new one beside it (count 1)"
         DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-CZ = WS-CZ + 1
     MOVE WS-MAX TO WS-N
     MOVE SPACES TO WS-WANT-N
     MOVE FUNCTION CHAR(WS-N + 49) TO WS-WANT-N(1:1)
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: the full " FUNCTION TRIM(WS-HAND-ITEM) " stack keeps its maximum" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-EXPECT = WS-MAX + 1
     COMPUTE WS-OBSERVE = 30 - PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: " FUNCTION TRIM(WS-HAND-ITEM) " each successful use used up one item" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-N
     IF WS-SNOW = 1
         MOVE 1 TO WS-FACE
         PERFORM USE-ITEM-ON
         COMPUTE WS-CY = WS-FLOOR + 2
         MOVE "1" TO WS-WANT-N
         MOVE "acceptance stack place: snow on the top of an 8-layer snow block goes in the cell above (layer 1)" TO WS-CASE
         PERFORM CHECK-COUNT
         COMPUTE WS-CY = WS-FLOOR + 1
     END-IF.

*> Cell B (x + 5): the item on the grass, then on the north face of the block: the count rises (snow: the side click is not a replacement, a layer goes beside it).
 SIDE-B.
     COMPUTE WS-CX = WS-BX + 5
     MOVE WS-CX TO WS-UX
     COMPUTE WS-CZ = WS-BZ + 2 + 3 * (WS-K - 1)
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 2 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE WS-K-ITEM(WS-K) TO WS-WANT
     IF WS-SNOW = 1
         MOVE "1" TO WS-WANT-N
         MOVE "acceptance stack place: a snow use on the side of a snow block does not stack on it (still 1)" TO WS-CASE
         PERFORM CHECK-COUNT
         COMPUTE WS-CZ = WS-CZ - 1
         MOVE "acceptance stack place: it puts a new snow layer in the cell beside the clicked face" TO WS-CASE
         PERFORM CHECK-COUNT
     ELSE
         MOVE "2" TO WS-WANT-N
         MOVE SPACES TO WS-CASE
         STRING "acceptance stack place: a use of " FUNCTION TRIM(WS-HAND-ITEM) " on the side face of the block adds one (2)" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-COUNT
         COMPUTE WS-CZ = WS-CZ - 1
         MOVE "air" TO WS-WANT
         MOVE SPACES TO WS-CASE
         STRING "acceptance stack place: " FUNCTION TRIM(WS-HAND-ITEM) " stacked from the side put nothing in the cell beside it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-KEY
     END-IF.

*> Cell C (x + 8): a stone block east of the block; its west face is clicked, the cell that face looks into holds the stack, which gains one.
 NEIGHBOUR-C.
     COMPUTE WS-CX = WS-BX + 8
     MOVE WS-CX TO WS-UX
     COMPUTE WS-CZ = WS-BZ + 2 + 3 * (WS-K - 1)
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     COMPUTE WS-X = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-CY WS-CZ WS-STONE
     MOVE WS-X TO WS-UX
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 4 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE WS-K-ITEM(WS-K) TO WS-WANT
     MOVE "2" TO WS-WANT-N
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: " FUNCTION TRIM(WS-HAND-ITEM) " used on the face of a neighbouring block adds to the stack in the cell it opens on (2)"
         DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT.

*> Cell D (x + 11): a sneaking player places a new one beside the stack (side face) instead of adding to it; snow, which has no secondary-use test, still stacks on the top face.
 SNEAK-D.
     COMPUTE WS-CX = WS-BX + 11
     MOVE WS-CX TO WS-UX
     COMPUTE WS-CZ = WS-BZ + 2 + 3 * (WS-K - 1)
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 2 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE WS-K-ITEM(WS-K) TO WS-WANT
     MOVE "1" TO WS-WANT-N
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: a sneaking use of " FUNCTION TRIM(WS-HAND-ITEM) " on the side leaves the block at 1" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-CZ = WS-CZ - 1
     MOVE SPACES TO WS-CASE
     STRING "acceptance stack place: a sneaking use of " FUNCTION TRIM(WS-HAND-ITEM) " places a new one beside it" DELIMITED BY SIZE INTO WS-CASE
     PERFORM CHECK-COUNT
     IF WS-SNOW = 1
         COMPUTE WS-CZ = WS-CZ + 1
         MOVE 1 TO PL-SNEAKING(WS-PLAYER)
         MOVE 1 TO WS-FACE
         PERFORM USE-ITEM-ON
         MOVE 0 TO PL-SNEAKING(WS-PLAYER)
         MOVE "2" TO WS-WANT-N
         MOVE "acceptance stack place: a sneaking snow use on the top face still adds a layer (2)" TO WS-CASE
         PERFORM CHECK-COUNT
     END-IF.

*> Other properties are kept; creative does not use items up; another colour of candle does not join; Block Update and light follow.
 EXTRAS.
*>   Sea pickle: a waterlogged one (the default state) stays waterlogged and gives 6 + 3 per added pickle of light.
     MOVE "sea_pickle" TO WS-HAND-ITEM
     MOVE "sea_pickle" TO WS-KEY
     PERFORM FIND-STATE
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 16
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-FOUND-STATE
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA
     PERFORM USE-ITEM-ON
     MOVE "sea_pickle" TO WS-WANT
     MOVE "pickles" TO WS-PROP
     MOVE "2" TO WS-WANT-N
     MOVE "acceptance stack place: a waterlogged pickle used on becomes 2 pickles" TO WS-CASE
     PERFORM CHECK-COUNT
     MOVE "waterlogged" TO WS-PROP2
     MOVE "true" TO WS-WANT2
     MOVE "acceptance stack place: the stacked pickle stays waterlogged" TO WS-CASE
     PERFORM CHECK-PROP2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-UPDATE
     MOVE WS-CX TO WS-ED-X
     MOVE WS-CY TO WS-ED-Y
     MOVE WS-CZ TO WS-ED-Z
     MOVE WS-STATE TO WS-ED-S
     STRING "8(" FUNCTION TRIM(WS-ED-X) "," FUNCTION TRIM(WS-ED-Y) "," FUNCTION TRIM(WS-ED-Z) "=" FUNCTION TRIM(WS-ED-S) ")"
         DELIMITED BY SIZE INTO WS-UPDATE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT-AREA TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-UPDATE)
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     MOVE "acceptance stack place: the viewer got one Block Update with the new state" TO WS-CASE
     PERFORM CHECK-N
     MOVE WS-CX TO WS-X
     MOVE WS-CZ TO WS-Z
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-CY WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 9 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "acceptance stack place: two waterlogged pickles give block light 9" TO WS-CASE
     PERFORM CHECK-N
     PERFORM USE-ITEM-ON
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-CY WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 12 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "acceptance stack place: three waterlogged pickles give block light 12" TO WS-CASE
     PERFORM CHECK-N
*>   Creative: the stack grows, the item stays.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM USE-ITEM-ON
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "4" TO WS-WANT-N
     MOVE "acceptance stack place: a creative use adds the fourth pickle" TO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-EXPECT = 2
     COMPUTE WS-OBSERVE = 30 - PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE "acceptance stack place: only the two survival uses used up items, the creative use kept its item" TO WS-CASE
     PERFORM CHECK-N
*>   A lit waterlogged-false candle keeps lit.
     MOVE "candle" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STATE
     MOVE "lit" TO WS-PROP2
     MOVE "true" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP2 WS-TEXT WS-NEW
     COMPUTE WS-CX = WS-BX + 5
     COMPUTE WS-CZ = WS-BZ + 16
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-NEW
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE "candle" TO WS-HAND-ITEM
     MOVE "candle" TO WS-WANT
     MOVE "candles" TO WS-PROP
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "2" TO WS-WANT-N
     MOVE "acceptance stack place: a use on a lit candle makes 2 candles" TO WS-CASE
     PERFORM CHECK-COUNT
     MOVE "true" TO WS-WANT2
     MOVE "acceptance stack place: the stacked candles stay lit" TO WS-CASE
     PERFORM CHECK-PROP2
     MOVE WS-CX TO WS-X
     MOVE WS-CZ TO WS-Z
     CALL "LIGHT-RAW" USING WS-DIM WS-X WS-CY WS-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     MOVE 6 TO WS-EXPECT
     MOVE WS-BLOCK-LIGHT TO WS-OBSERVE
     MOVE "acceptance stack place: two lit candles give block light 6" TO WS-CASE
     PERFORM CHECK-N
*>   Another colour does not join: a red candle on the white one goes beside it.
     MOVE "red_candle" TO WS-HAND-ITEM
     PERFORM GIVE-ITEMS
     MOVE 2 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE "candle" TO WS-WANT
     MOVE "2" TO WS-WANT-N
     MOVE "acceptance stack place: a red candle does not join white candles (still 2)" TO WS-CASE
     PERFORM CHECK-COUNT
     COMPUTE WS-CZ = WS-CZ - 1
     MOVE "red_candle" TO WS-WANT
     MOVE "1" TO WS-WANT-N
     MOVE "acceptance stack place: it is placed in the cell beside the clicked face instead" TO WS-CASE
     PERFORM CHECK-COUNT
*>   A turtle egg keeps its hatch stage.
     MOVE "turtle_egg" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STATE
     MOVE "hatch" TO WS-PROP2
     MOVE "1" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP2 WS-TEXT WS-NEW
     COMPUTE WS-CX = WS-BX + 8
     COMPUTE WS-CZ = WS-BZ + 16
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-NEW
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE "turtle_egg" TO WS-HAND-ITEM
     MOVE "turtle_egg" TO WS-WANT
     MOVE "eggs" TO WS-PROP
     PERFORM GIVE-ITEMS
     MOVE 1 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE "2" TO WS-WANT-N
     MOVE "acceptance stack place: a use on a turtle egg at hatch stage 1 makes 2 eggs" TO WS-CASE
     PERFORM CHECK-COUNT
     MOVE "1" TO WS-WANT2
     MOVE "hatch" TO WS-PROP2
     MOVE "acceptance stack place: the hatch stage is kept" TO WS-CASE
     PERFORM CHECK-PROP2.

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

*> The player holds thirty of WS-HAND-ITEM in the first hotbar slot (survival).
 GIVE-ITEMS.
     MOVE WS-HAND-ITEM TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 30 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

*> The held item used on the block WS-UX, WS-UY, WS-UZ, face WS-FACE.
 USE-ITEM-ON.
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

*> The block at WS-CX, WS-CY, WS-CZ is WS-WANT with the property WS-PROP equal to WS-WANT-N.
 CHECK-COUNT.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WANT-N)
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

*> The block at WS-CX, WS-CY, WS-CZ has the property WS-PROP2 equal to WS-WANT2.
 CHECK-PROP2.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     MOVE SPACES TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-PROP2 WS-TEXT WS-FOUND
     IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WANT2)
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
 END PROGRAM ACC-STACK-PLACE.
 COPY CORETEST.
 COPY CMDTEST.
