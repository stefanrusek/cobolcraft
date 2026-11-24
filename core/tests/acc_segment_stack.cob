*> Acceptance test, lane decals (operator report: leaf litter and pink petals must stack in one block, "each use on the same block adds one segment (1 to 4) in
*> the next quadrant of the facing direction; the 5th use does nothing"; 29b-4 section 10.4 FlowerBedBlock placement and canBeReplaced, 29b-3 section 5.8
*> LeafLitterBlock, 24 part 8 section 5.2 segmented blocks, 51 R-F38 the n quarter pads from facing): a standard world opened from the generated vanilla data
*> pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). A grass floor lies high above the terrain; the player holds the item
*> (survival) and sends Use Item On through the real packet handler. A use on a block of the same kind (not sneaking, amount below 4) adds one segment to that
*> block whatever face is clicked, keeps its facing and uses up one item; the first use on the ground sets facing to the opposite of the placer's horizontal
*> direction. A sneaking use, another item and a block of 4 segments place beside the clicked block as before.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SEGMENT-STACK.
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
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
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
 01 WS-WANT-AMOUNT         PIC X(2).
 01 WS-WANT-FACING         PIC X(5).
 01 WS-AMOUNT-NAME         PIC X(24).
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HAND-ITEM           PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-USES                BINARY-LONG.
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
         MOVE "acceptance segment stack no generated packs here, skipped" TO TL-CASE
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
     MOVE "Segments" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GRASS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 14
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 14
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-GRASS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 12.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 3
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 12.5
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-CY = WS-FLOOR + 1

*>   Pink petals: five uses on the same block, the top face each time (the player looks south, yaw 0, so the first sets facing north).
     MOVE "pink_petals" TO WS-HAND-ITEM
     MOVE "flower_amount" TO WS-AMOUNT-NAME
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "pink_petals" TO WS-WANT
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: the first pink petals on the ground make one segment, facing the opposite of the player's look (north)" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-UY = WS-FLOOR + 1
     PERFORM USE-ITEM-ON
     MOVE "2" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: the second use on the petals adds a segment to the same block (2), same facing" TO WS-CASE
     PERFORM CHECK-BLOCK
     PERFORM USE-ITEM-ON
     MOVE "3" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: the third use makes 3" TO WS-CASE
     PERFORM CHECK-BLOCK
     PERFORM USE-ITEM-ON
     MOVE "4" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: the fourth use makes 4" TO WS-CASE
     PERFORM CHECK-BLOCK
     PERFORM USE-ITEM-ON
     MOVE "acceptance segment stack: the fifth use does nothing: still 4 segments" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "air" TO WS-WANT
     MOVE "acceptance segment stack: the fifth use put no block above the petals" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE 1 TO WS-EXPECT
     PERFORM COUNT-HELD
     COMPUTE WS-OBSERVE = 10 - WS-COUNT
     MOVE 4 TO WS-EXPECT
     MOVE "acceptance segment stack: four items were used up, the fifth use kept its item" TO WS-CASE
     PERFORM CHECK-N

*>   Stacking from the side face of the same block (north face, 2): the block gains a segment and no block is put in the cell beside it.
     COMPUTE WS-CX = WS-BX + 5
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "pink_petals" TO WS-WANT
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: a second stack of petals starts with one segment" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 2 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE "2" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: a use on the north face of the petals adds a segment (2)" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE 5 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE "3" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: a use on the east face adds a segment (3)" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-CZ = WS-BZ + 1
     MOVE "air" TO WS-WANT
     MOVE "acceptance segment stack: no block was put north of the petals" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CX = WS-BX + 6
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE "acceptance segment stack: no block was put east of the petals" TO WS-CASE
     PERFORM CHECK-KEY

*>   Facing follows the player: looking west (yaw 90) the first petals face east.
     MOVE 90 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-CX = WS-BX + 8
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "pink_petals" TO WS-WANT
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "east" TO WS-WANT-FACING
     MOVE "acceptance segment stack: a player looking west places petals facing east" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE 180 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-UY = WS-FLOOR + 1
     PERFORM USE-ITEM-ON
     MOVE "2" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: stacking from another look direction keeps the facing (east)" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE 180 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-CX = WS-BX + 8
     COMPUTE WS-CZ = WS-BZ + 5
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM USE-ITEM-ON
     MOVE "south" TO WS-WANT-FACING
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: a player looking north places petals facing south" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE 270 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-CX = WS-BX + 8
     COMPUTE WS-CZ = WS-BZ + 8
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     PERFORM USE-ITEM-ON
     MOVE "west" TO WS-WANT-FACING
     MOVE "acceptance segment stack: a player looking east places petals facing west" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE 0 TO PL-YAW(WS-PLAYER)

*>   Wildflowers stack like petals; leaf litter does with segment_amount.
     MOVE "wildflowers" TO WS-HAND-ITEM
     COMPUTE WS-CX = WS-BX + 11
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     COMPUTE WS-UY = WS-FLOOR + 1
     PERFORM USE-ITEM-ON
     PERFORM USE-ITEM-ON
     MOVE "wildflowers" TO WS-WANT
     MOVE "3" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: three uses of wildflowers on one block make 3 segments" TO WS-CASE
     PERFORM CHECK-BLOCK
     MOVE "leaf_litter" TO WS-HAND-ITEM
     MOVE "segment_amount" TO WS-AMOUNT-NAME
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 11
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     COMPUTE WS-UY = WS-FLOOR + 1
     PERFORM VARYING WS-USES FROM 1 BY 1 UNTIL WS-USES > 4
         PERFORM USE-ITEM-ON
     END-PERFORM
     MOVE "leaf_litter" TO WS-WANT
     MOVE "4" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: five uses of leaf litter on one block leave 4 segments" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-CY = WS-FLOOR + 2
     MOVE "air" TO WS-WANT
     MOVE "acceptance segment stack: no leaf litter above the full block" TO WS-CASE
     PERFORM CHECK-KEY
     COMPUTE WS-CY = WS-FLOOR + 1

*>   A sneaking use places beside the clicked block instead: a new single petal east of a stack, the stack unchanged.
     MOVE "pink_petals" TO WS-HAND-ITEM
     MOVE "flower_amount" TO WS-AMOUNT-NAME
     COMPUTE WS-CX = WS-BX + 5
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 5 TO WS-FACE
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE "pink_petals" TO WS-WANT
     MOVE "3" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: a sneaking use leaves the stack of 3 as it is" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-CX = WS-BX + 6
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "acceptance segment stack: a sneaking use puts a new single petal beside it" TO WS-CASE
     PERFORM CHECK-BLOCK

*>   Another item does not stack on petals: leaf litter beside the petals' side goes to the neighbour cell.
     MOVE "leaf_litter" TO WS-HAND-ITEM
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-CZ = WS-BZ + 2
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     COMPUTE WS-UY = WS-FLOOR + 1
     MOVE 3 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "pink_petals" TO WS-WANT
     MOVE "flower_amount" TO WS-AMOUNT-NAME
     MOVE "4" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: leaf litter does not join a block of petals" TO WS-CASE
     PERFORM CHECK-BLOCK
     COMPUTE WS-CZ = WS-BZ + 3
     MOVE "leaf_litter" TO WS-WANT
     MOVE "segment_amount" TO WS-AMOUNT-NAME
     MOVE "1" TO WS-WANT-AMOUNT
     MOVE "north" TO WS-WANT-FACING
     MOVE "acceptance segment stack: it is placed in the cell beside the clicked face (south)" TO WS-CASE
     PERFORM CHECK-BLOCK

*>   A block without an amount is placed as before (a dirt block on the floor).
     MOVE "dirt" TO WS-HAND-ITEM
     COMPUTE WS-CX = WS-BX + 13
     COMPUTE WS-CZ = WS-BZ + 13
     MOVE WS-CX TO WS-UX
     MOVE WS-CZ TO WS-UZ
     MOVE WS-FLOOR TO WS-UY
     MOVE 1 TO WS-FACE
     PERFORM GIVE-ITEMS
     PERFORM USE-ITEM-ON
     MOVE "dirt" TO WS-WANT
     MOVE "acceptance segment stack: a block without segments is placed as before" TO WS-CASE
     PERFORM CHECK-KEY
     STOP RUN.

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.

*> The player holds ten of WS-HAND-ITEM in the first hotbar slot.
 GIVE-ITEMS.
     MOVE WS-HAND-ITEM TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 10 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

*> The held item used on the block WS-UX, WS-UY, WS-UZ, face WS-FACE.
 USE-ITEM-ON.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-UX WS-UY WS-UZ WS-FACE WS-SEQ.

 COUNT-HELD.
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-COUNT.

*> 1 when the block at WS-CX, WS-CY, WS-CZ has the key WS-WANT.
 CHECK-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE 1 TO WS-OBSERVE
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

*> The block at WS-CX, WS-CY, WS-CZ is WS-WANT with the amount WS-WANT-AMOUNT and the facing WS-WANT-FACING.
 CHECK-BLOCK.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE 0 TO WS-OBSERVE
     IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-WANT)
         MOVE SPACES TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-AMOUNT-NAME WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WANT-AMOUNT)
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-FACING-NAME WS-TEXT WS-FOUND
             IF FUNCTION TRIM(WS-TEXT) = FUNCTION TRIM(WS-WANT-FACING)
                 MOVE 1 TO WS-OBSERVE
             END-IF
         END-IF
     END-IF
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SEGMENT-STACK.
 COPY CORETEST.
 COPY CMDTEST.
