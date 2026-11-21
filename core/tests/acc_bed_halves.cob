*> Acceptance test, lane bugbed (operator report of try16: breaking the foot of a bed dropped nothing and left the head half, breaking the head left the foot,
*> and a bed item placed only a foot; 24 part 2 section 5 beds, 29 sections 2.2, 3.2, 9.5 and 10.4): a standard world opened from the generated vanilla data pack
*> (CC_GENERATED_DIR, skipped as a pass without it). For each of the 16 coloured beds and the straw bed: a bed item used on the top face of a stone block places the
*> foot there and the head one cell along the player's horizontal direction (the same facing, part foot and head); breaking either half in survival removes both and
*> leaves one bed item (the loot table's part = head condition); breaking either half in creative removes both and leaves no item. Edge cases (white bed): the head cell
*> taken stops the placement, water and grass in the head cell are replaced, a second bed beside a bed leaves the first alone, a second use on the placed bed places nothing,
*> and the clients get both halves (Block Update or Section Blocks Update) on the placement and on the break.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BED-HALVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-IID                 BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-IROW                PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-BED-ITEM            BINARY-LONG.
 01 WS-BED-STATE           BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 200.
 01 WS-Y1                  BINARY-LONG VALUE 201.
 01 WS-Y2                  BINARY-LONG VALUE 202.
 01 WS-Z                   BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-PROP-MODE           BINARY-LONG VALUE 1.
 01 WS-PROP-PART           PIC X(24) VALUE "part".
 01 WS-PROP-FACING         PIC X(24) VALUE "facing".
 01 WS-PROP-TEXT           PIC X(32).
 01 WS-PROP-RESULT         BINARY-LONG.
 01 WS-PART                PIC X(8).
 01 WS-FACING              PIC X(8).
 01 WS-DESC1               PIC X(24).
 01 WS-DESC2               PIC X(24).
 01 WS-DESC3               PIC X(24).
 01 WS-DESC4               PIC X(24).
 01 WS-HELD-COUNT          PIC 99.
 01 WS-ITEMS               PIC 99.
 01 WS-ITEMS-EXPECT        PIC 99.
 01 WS-TICK-COUNT          BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ID-TEXT        PIC 9(5).
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-GRASS-BLOCK         BINARY-LONG.
 01 WS-BORDER-X            FLOAT-LONG.
 01 WS-BORDER-Z            FLOAT-LONG.
 01 WS-BORDER-SIZE         FLOAT-LONG.
 01 WS-BORDER-DAMAGE       FLOAT-LONG.
 01 WS-BORDER-SAFE         FLOAT-LONG.
 01 WS-UPDATES             PIC X(2048).
 01 WS-UPTR                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-QUOT                BINARY-DOUBLE.
 01 WS-A                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-NEEDLE              PIC X(40).
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(16) VALUE "white_bed".
    05 FILLER PIC X(16) VALUE "orange_bed".
    05 FILLER PIC X(16) VALUE "magenta_bed".
    05 FILLER PIC X(16) VALUE "light_blue_bed".
    05 FILLER PIC X(16) VALUE "yellow_bed".
    05 FILLER PIC X(16) VALUE "lime_bed".
    05 FILLER PIC X(16) VALUE "pink_bed".
    05 FILLER PIC X(16) VALUE "gray_bed".
    05 FILLER PIC X(16) VALUE "light_gray_bed".
    05 FILLER PIC X(16) VALUE "cyan_bed".
    05 FILLER PIC X(16) VALUE "purple_bed".
    05 FILLER PIC X(16) VALUE "blue_bed".
    05 FILLER PIC X(16) VALUE "brown_bed".
    05 FILLER PIC X(16) VALUE "green_bed".
    05 FILLER PIC X(16) VALUE "red_bed".
    05 FILLER PIC X(16) VALUE "black_bed".
    05 FILLER PIC X(16) VALUE "straw_bed".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-BED-KEY          PIC X(16) OCCURS 17 TIMES.
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
         MOVE "acceptance bed halves no generated packs here, skipped" TO TL-CASE
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
     MOVE "Beds" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
*>   A column of the chunk the player stands in, at local x 4 and local z 4 (the head goes to local z 5), above any terrain.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(PL-ENTITY-ROW(WS-ROW)) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(PL-ENTITY-ROW(WS-ROW)) / 16)
     COMPUTE WS-X = WS-CX * 16 + 4
     COMPUTE WS-Z = WS-CZ * 16 + 4
     COMPUTE WS-Z2 = WS-Z + 1
     COMPUTE WS-X2 = WS-X + 1
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STONE
     MOVE "water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-WATER
     MOVE "short_grass" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-GRASS
     MOVE "grass_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-GRASS-BLOCK
*>   Alice faces south (yaw 0): the head goes to +z of the foot.
     MOVE 0 TO PL-YAW(WS-ROW)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 17
         MOVE SPACES TO WS-KEY
         MOVE WS-BED-KEY(WS-K) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
         MOVE 0 TO CB-BREAK-MS(WS-BID + 1)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 17
         PERFORM BED-SET-UP
         PERFORM CASE-PLACE
         PERFORM CASE-SURVIVAL-FOOT
         PERFORM CASE-SURVIVAL-HEAD
         PERFORM CASE-CREATIVE-FOOT
         PERFORM CASE-CREATIVE-HEAD
     END-PERFORM
     MOVE 1 TO WS-K
     PERFORM BED-SET-UP
     PERFORM CASE-EDGES
     PERFORM CASE-PACKETS
     STOP RUN.

*> The bed WS-K: its key, item and five of the item in slot 1.
 BED-SET-UP.
     MOVE SPACES TO WS-KEY
     MOVE WS-BED-KEY(WS-K) TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BED-ITEM WS-IROW WS-STATUS
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-BED-STATE
     MOVE WS-BED-ITEM TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     PERFORM CLEAR-AREA.

*> A stone floor at y 200 under the two cells (and the neighbour column at x + 1), air above, no ground items, Alice survival with 5 beds held.
 CLEAR-AREA.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z2 WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z2 WS-STONE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z2 WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y1 WS-Z WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y1 WS-Z2 WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-VOID
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z2 WS-VOID
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 5 TO PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-PLAYER(WS-I) = 0
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM.

*> The bed item used on the top face of the stone block at (x + WS-CY, z).
 PLACE-BED.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 SET-FULL-BED.
*>   A whole bed written the way a village or a command leaves it: the foot at (x, 201, z), the head at (x, 201, z + 1), both facing south.
     MOVE WS-BED-STATE TO WS-STATE
     MOVE "south" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-FACING WS-PROP-TEXT
     MOVE "head" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-PART WS-PROP-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z2 WS-STATE
     MOVE "foot" TO WS-PROP-TEXT
     CALL "PS-PUT" USING WS-STATE WS-PROP-PART WS-PROP-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE.

 PLACE-BED-NEXT.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X2 WS-Y WS-Z WS-FACE WS-SEQ.

*> Start Digging on the cell (WS-CX2 = x, WS-CY, WS-CZ).
 START-DIG.
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-LX WS-CY WS-LZ WS-FACE WS-SEQ.

 DIG-FOOT.
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     MOVE WS-Y1 TO WS-CY
     PERFORM START-DIG.

 DIG-HEAD.
     MOVE WS-X TO WS-LX
     MOVE WS-Z2 TO WS-LZ
     MOVE WS-Y1 TO WS-CY
     PERFORM START-DIG.

*> The state at (WS-LX, WS-CY, WS-LZ) as "void", "<part>/<facing>" or "other" in WS-DESC4 (the caller moves it).
 DESCRIBE-CELL.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-LX WS-CY WS-LZ WS-STATE
     MOVE "void" TO WS-DESC4
     IF WS-STATE NOT = 0
         MOVE "other" TO WS-DESC4
         MOVE SPACES TO WS-PROP-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-PROP-MODE WS-STATE WS-PROP-PART WS-PROP-TEXT WS-PROP-RESULT
         IF WS-PROP-RESULT = 1
             MOVE WS-PROP-TEXT TO WS-PART
             MOVE SPACES TO WS-PROP-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-PROP-MODE WS-STATE WS-PROP-FACING WS-PROP-TEXT WS-PROP-RESULT
             MOVE WS-PROP-TEXT TO WS-FACING
             MOVE SPACES TO WS-DESC4
             STRING FUNCTION TRIM(WS-PART) "/" FUNCTION TRIM(WS-FACING) DELIMITED BY SIZE INTO WS-DESC4
         END-IF
     END-IF.

*> WS-DESC1 the foot cell, WS-DESC2 the head cell, WS-DESC3 the cell beside the foot.
 DESCRIBE-ALL.
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     MOVE WS-Y1 TO WS-CY
     PERFORM DESCRIBE-CELL
     MOVE WS-DESC4 TO WS-DESC1
     MOVE WS-Z2 TO WS-LZ
     PERFORM DESCRIBE-CELL
     MOVE WS-DESC4 TO WS-DESC2
     MOVE WS-X2 TO WS-LX
     MOVE WS-Z TO WS-LZ
     PERFORM DESCRIBE-CELL
     MOVE WS-DESC4 TO WS-DESC3
     MOVE 0 TO WS-ITEMS WS-ITEM-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-ITEMS
             MOVE EN-ITEM(WS-I) TO WS-ITEM-ID
         END-IF
     END-PERFORM
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-HELD-COUNT.

*> "<foot> <head> <items on the ground>:<their item id, 0 for none>".
 CHECK-BREAK.
     PERFORM DESCRIBE-ALL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-ITEM-ID TO WS-ITEM-ID-TEXT
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-ITEMS ":" WS-ITEM-ID-TEXT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-BREAK.
     MOVE WS-BED-ITEM TO WS-ITEM-ID-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "void void " WS-ITEMS-EXPECT ":" WS-ITEM-ID-TEXT DELIMITED BY SIZE INTO TL-EXPECTED.

 CASE-PLACE.
     PERFORM PLACE-BED
     PERFORM DESCRIBE-ALL
     MOVE SPACES TO TL-CASE
     STRING "acceptance bed halves: " FUNCTION TRIM(WS-BED-KEY(WS-K)) " used on the floor places foot and head facing south, one item less"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "foot/south head/south 04" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CASE-SURVIVAL-FOOT.
     PERFORM CLEAR-AREA
     PERFORM SET-FULL-BED
     PERFORM DIG-FOOT
     MOVE SPACES TO TL-CASE
     STRING "acceptance bed halves: " FUNCTION TRIM(WS-BED-KEY(WS-K)) " foot broken in survival, both halves gone, one bed item"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO WS-ITEMS-EXPECT
     PERFORM EXPECT-BREAK
     PERFORM CHECK-BREAK.

 CASE-SURVIVAL-HEAD.
     PERFORM CLEAR-AREA
     PERFORM SET-FULL-BED
     PERFORM DIG-HEAD
     MOVE SPACES TO TL-CASE
     STRING "acceptance bed halves: " FUNCTION TRIM(WS-BED-KEY(WS-K)) " head broken in survival, both halves gone, one bed item"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO WS-ITEMS-EXPECT
     PERFORM EXPECT-BREAK
     PERFORM CHECK-BREAK.

 CASE-CREATIVE-FOOT.
     PERFORM CLEAR-AREA
     PERFORM SET-FULL-BED
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM DIG-FOOT
     MOVE SPACES TO TL-CASE
     STRING "acceptance bed halves: " FUNCTION TRIM(WS-BED-KEY(WS-K)) " foot broken in creative, both halves gone, no item"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO WS-ITEMS-EXPECT
     PERFORM EXPECT-BREAK-NONE
     PERFORM CHECK-BREAK.

 CASE-CREATIVE-HEAD.
     PERFORM CLEAR-AREA
     PERFORM SET-FULL-BED
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM DIG-HEAD
     MOVE SPACES TO TL-CASE
     STRING "acceptance bed halves: " FUNCTION TRIM(WS-BED-KEY(WS-K)) " head broken in creative, both halves gone, no item"
         DELIMITED BY SIZE INTO TL-CASE
     PERFORM EXPECT-BREAK-NONE
     PERFORM CHECK-BREAK.

 EXPECT-BREAK-NONE.
     MOVE "void void 00:00000" TO TL-EXPECTED.

 CASE-EDGES.
*>   The head cell is taken (stone): nothing is placed and the item stays.
     PERFORM CLEAR-AREA
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z2 WS-STONE
     PERFORM PLACE-BED
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: the head cell taken, nothing is placed, five beds still held" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "void other 05" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Water in the head cell is replaced (a bed cannot be waterlogged), so is grass.
     PERFORM CLEAR-AREA
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z2 WS-WATER
     PERFORM PLACE-BED
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: water in the head cell is replaced by the head" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "foot/south head/south 04" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-AREA
*>   (the grass stands on a grass block: on stone it would not survive the foot's neighbour update, which would take the foot with it)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z2 WS-GRASS-BLOCK
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z2 WS-GRASS
     PERFORM PLACE-BED
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: grass in the head cell is replaced by the head" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second click on the placed foot (its top face is not free) places nothing more.
     PERFORM CLEAR-AREA
     PERFORM PLACE-BED
     PERFORM PLACE-BED
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: a second use on the placed bed places no more, four beds held" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "foot/south head/south 04" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second bed beside the first: both complete, the first one untouched; breaking the first leaves the second.
     PERFORM PLACE-BED-NEXT
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: a bed placed beside a bed leaves the first alone and is whole itself" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-X2 TO WS-LX
     MOVE WS-Z2 TO WS-LZ
     MOVE WS-Y1 TO WS-CY
     PERFORM DESCRIBE-CELL
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " FUNCTION TRIM(WS-DESC3) " " FUNCTION TRIM(WS-DESC4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "foot/south head/south foot/south head/south" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DIG-FOOT
     PERFORM DESCRIBE-ALL
     MOVE WS-X2 TO WS-LX
     MOVE WS-Z2 TO WS-LZ
     PERFORM DESCRIBE-CELL
     MOVE "acceptance bed halves: breaking the first of two neighbouring beds leaves the second whole" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " FUNCTION TRIM(WS-DESC3) " " FUNCTION TRIM(WS-DESC4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "void void foot/south head/south" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A creative player breaking a stone block: no bed rule touches it (the bed hooks leave other blocks alone).
     PERFORM CLEAR-AREA
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STONE
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM DIG-FOOT
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: a creative player breaks a stone block as before" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "void void" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The head cell outside the world border (a border one block wide round the foot cell): nothing is placed.
     PERFORM CLEAR-AREA
     COMPUTE WS-BORDER-X = WS-X + 0.5
     COMPUTE WS-BORDER-Z = WS-Z + 0.5
     MOVE 1.0 TO WS-BORDER-SIZE
     MOVE 0.2 TO WS-BORDER-DAMAGE
     MOVE 5.0 TO WS-BORDER-SAFE
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-BORDER-X WS-BORDER-Z WS-BORDER-SIZE WS-BORDER-DAMAGE WS-BORDER-SAFE
     PERFORM PLACE-BED
     MOVE 0.0 TO WS-BORDER-X
     MOVE 0.0 TO WS-BORDER-Z
     MOVE 59999968 TO WS-BORDER-SIZE
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-BORDER-X WS-BORDER-Z WS-BORDER-SIZE WS-BORDER-DAMAGE WS-BORDER-SAFE
     PERFORM DESCRIBE-ALL
     MOVE "acceptance bed halves: a head cell outside the world border stops the placement, five beds held" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-DESC1) " " FUNCTION TRIM(WS-DESC2) " " WS-HELD-COUNT DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "void void 05" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The clients: the packets of the placement name both cells with their states, those of the break name both cells as air.
 CASE-PACKETS.
     PERFORM CLEAR-AREA
     MOVE 1 TO WS-TICK-COUNT
     CALL "TEST-TICKS" USING WS-TICK-COUNT
     PERFORM DRAIN-UPDATES
     PERFORM PLACE-BED
     CALL "TEST-TICKS" USING WS-TICK-COUNT
     PERFORM DRAIN-UPDATES
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     MOVE WS-Y1 TO WS-CY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-LX WS-CY WS-LZ WS-STATE
     PERFORM TOKEN-FOR-STATE
     MOVE "acceptance bed halves: the placement is sent to the clients for the foot cell" TO TL-CASE
     PERFORM CHECK-TOKEN
     MOVE WS-Z2 TO WS-LZ
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-LX WS-CY WS-LZ WS-STATE
     PERFORM TOKEN-FOR-STATE
     MOVE "acceptance bed halves: the placement is sent to the clients for the head cell" TO TL-CASE
     PERFORM CHECK-TOKEN
     PERFORM DIG-FOOT
     CALL "TEST-TICKS" USING WS-TICK-COUNT
     PERFORM DRAIN-UPDATES
     MOVE 0 TO WS-STATE
     MOVE WS-X TO WS-LX
     MOVE WS-Z TO WS-LZ
     PERFORM TOKEN-FOR-STATE
     MOVE "acceptance bed halves: the break is sent to the clients for the foot cell" TO TL-CASE
     PERFORM CHECK-TOKEN
     MOVE WS-Z2 TO WS-LZ
     PERFORM TOKEN-FOR-STATE
     MOVE "acceptance bed halves: the break is sent to the clients for the head cell" TO TL-CASE
     PERFORM CHECK-TOKEN.

 TOKEN-FOR-STATE.
     COMPUTE WS-TX = FUNCTION MOD(WS-LX, 16)
     COMPUTE WS-TZ = FUNCTION MOD(WS-LZ, 16)
     COMPUTE WS-TY = FUNCTION MOD(WS-CY, 16)
     MOVE WS-TX TO WS-E1
     MOVE WS-TY TO WS-E2
     MOVE WS-TZ TO WS-E3
     MOVE WS-STATE TO WS-E4
     MOVE SPACES TO WS-NEEDLE
     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ")"
         DELIMITED BY SIZE INTO WS-NEEDLE.

 CHECK-TOKEN.
     MOVE 0 TO WS-FOUND
     INSPECT WS-UPDATES TALLYING WS-FOUND FOR ALL FUNCTION TRIM(WS-NEEDLE)
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-FOUND > 0
         MOVE 1 TO WS-FOUND
     END-IF
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Everything the connection has queued, as the block changes of Block Update (8) and Section Blocks Update (86):
*> "(local x,local y,local z=state)" for each, in WS-UPDATES.
 DRAIN-UPDATES.
     MOVE SPACES TO WS-UPDATES
     MOVE 1 TO WS-UPTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 8
                     CALL "PB-GET-POSITION" USING PK-BUFFER WS-LX WS-CY WS-LZ
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     COMPUTE WS-LX = FUNCTION MOD(WS-LX, 16)
                     COMPUTE WS-LZ = FUNCTION MOD(WS-LZ, 16)
                     COMPUTE WS-LY = FUNCTION MOD(WS-CY, 16)
                     PERFORM ADD-UPDATE
                 WHEN 86
                     CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-COUNT
                     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT
                         CALL "PB-GET-VARLONG" USING PK-BUFFER WS-LONG
                         DIVIDE WS-LONG BY 4096 GIVING WS-QUOT REMAINDER WS-LOW
                         MOVE WS-QUOT TO WS-A
                         DIVIDE WS-LOW BY 256 GIVING WS-QUOT REMAINDER WS-LOW
                         MOVE WS-QUOT TO WS-LX
                         DIVIDE WS-LOW BY 16 GIVING WS-QUOT REMAINDER WS-LOW
                         MOVE WS-QUOT TO WS-LZ
                         MOVE WS-LOW TO WS-LY
                         PERFORM ADD-UPDATE
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

 ADD-UPDATE.
     MOVE WS-LX TO WS-E1
     MOVE WS-LY TO WS-E2
     MOVE WS-LZ TO WS-E3
     MOVE WS-A TO WS-E4
     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ")"
         DELIMITED BY SIZE INTO WS-UPDATES POINTER WS-UPTR.
 END PROGRAM ACC-BED-HALVES.

 COPY CORETEST.
