*> Segmented blocks (pink_petals, wildflowers: property flower_amount; leaf_litter: segment_amount; 29b-4 section 10.4 FlowerBedBlock, 29b-3 section 5.8,
*> 24 part 8 section 5.2 SegmentableBlock): the amount (1 to 4) counts the quarter pads of the block, and the shape of 51 R-F38 takes the first n of them from facing.
*>   SEG-STACK USING connection id, PLAY-SERVERBOUND (Use Item On), placed state (the held item's default state), handled out
*>     SegmentableBlock.getStateForPlacement and canBeReplaced: when the held item's block has an amount, the player is not sneaking and the block at the clicked
*>     position is that block with an amount below 4, the clicked block becomes the same state with the amount one higher (whatever face was clicked; handled 1,
*>     the caller places nothing else); otherwise handled 0 and the item is placed beside the clicked face as for any block.
*>   SEG-FACING USING connection id, state in and out
*>     a segmented block placed fresh takes facing = the opposite of the placer's horizontal direction (yaw 0 looks south); other states are not changed.
*>   SEG-AMOUNT-NAME USING state, name out (PIC X(24); spaces when the block has no amount)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEG-AMOUNT-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-FLOWER              PIC X(24) VALUE "flower_amount".
 01 WS-SEGMENT             PIC X(24) VALUE "segment_amount".
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-STATE L-NAME.
     MOVE SPACES TO L-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-FLOWER WS-TEXT WS-FOUND
     IF WS-FOUND = 1
         MOVE WS-FLOWER TO L-NAME
         GOBACK
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-SEGMENT WS-TEXT WS-FOUND
     IF WS-FOUND = 1
         MOVE WS-SEGMENT TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM SEG-AMOUNT-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEG-STACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(24).
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-PLACED-STATE         BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-PLACED-STATE L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "SEG-AMOUNT-NAME" USING L-PLACED-STATE WS-NAME
     IF WS-NAME = SPACES OR PL-SNEAKING(CN-PLAYER(L-ID)) = 1
         GOBACK
     END-IF
     MOVE PL-DIM(CN-PLAYER(L-ID)) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-OLD
     IF CB-S-BLOCK(WS-OLD + 1) NOT = CB-S-BLOCK(L-PLACED-STATE + 1)
         GOBACK
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-OLD WS-NAME WS-TEXT WS-FOUND
     COMPUTE WS-AMOUNT = FUNCTION NUMVAL(WS-TEXT)
     IF WS-AMOUNT >= 4
         GOBACK
     END-IF
     ADD 1 TO WS-AMOUNT
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION CHAR(WS-AMOUNT + 49) TO WS-TEXT(1:1)
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-OLD WS-NAME WS-TEXT WS-NEW
     CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-NEW
     MOVE 1 TO L-HANDLED
     GOBACK.
 END PROGRAM SEG-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEG-FACING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-NAME                PIC X(24).
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-QUARTER             BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-STATE.
     CALL "SEG-AMOUNT-NAME" USING L-STATE WS-NAME
     IF WS-NAME = SPACES
         GOBACK
     END-IF
     COMPUTE WS-QUARTER = FUNCTION MOD(FUNCTION INTEGER(PL-YAW(CN-PLAYER(L-ID)) / 90 + 0.5), 4)
     EVALUATE WS-QUARTER
         WHEN 0
             MOVE "north" TO WS-TEXT
         WHEN 1
             MOVE "east" TO WS-TEXT
         WHEN 2
             MOVE "south" TO WS-TEXT
         WHEN OTHER
             MOVE "west" TO WS-TEXT
     END-EVALUATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET L-STATE WS-FACING WS-TEXT WS-NEW
     MOVE WS-NEW TO L-STATE
     GOBACK.
 END PROGRAM SEG-FACING.
