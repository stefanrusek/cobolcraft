*> Blocks that hold several of their own item in one cell through a count property (lane bugstackplace, operator report try18 "sea cucumbers don't place multiple in the block", read as the sea pickle;
*> 24 part 6 sections 6.14 and 6.15 SEA_PICKLE and TURTLE_EGG getStateForPlacement and canBeReplaced, 29b-7 CandleBlock placement and canBeReplaced, 24 part 3 SnowLayerBlock replacement, 29 section 9.5
*> BlockPlaceContext): the item used on a block of its own kind adds one to the count instead of going in the neighbouring cell.
*>   STACK-RULE USING state, property out (PIC X(24), spaces when the block does not stack), maximum out, snow out (1 for the snow layer rule: the clicked block is replaced only through its top face, a block
*>     in the neighbour cell is always replaceable; 0 for the rule of the sea pickle, turtle egg and candles: the placer is not using secondary use)
*>     sea_pickle (pickles 1 to 4), turtle_egg (eggs 1 to 4), candle and the sixteen dyed candles (candles 1 to 4), snow (layers 1 to 8)
*>   STACK-PLACE USING connection id, PLAY-SERVERBOUND (Use Item On), placed state (the held item's default state), result out: 0 the item does not stack here (the caller places it as usual),
*>     1 the block of the clicked cell or of the cell on the clicked face gained one (every other property kept; the caller uses up the item), 2 the placement was refused because an entity is in the way
*>     (the player was told; nothing is placed and no item is used up)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-SUFFIX              PIC X(24) VALUE "_candle".
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-PROP                 PIC X(24).
 01 L-MAX                  BINARY-LONG.
 01 L-SNOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PROP L-MAX L-SNOW.
     MOVE SPACES TO L-PROP
     MOVE 0 TO L-MAX L-SNOW
     CALL "PS-NAME-OF" USING L-STATE WS-NAME
     CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-FLAG
     EVALUATE TRUE
         WHEN WS-NAME = "sea_pickle"
             MOVE "pickles" TO L-PROP
             MOVE 4 TO L-MAX
         WHEN WS-NAME = "turtle_egg"
             MOVE "eggs" TO L-PROP
             MOVE 4 TO L-MAX
         WHEN WS-NAME = "snow"
             MOVE "layers" TO L-PROP
             MOVE 8 TO L-MAX
             MOVE 1 TO L-SNOW
         WHEN WS-NAME = "candle" OR WS-FLAG = 1
             MOVE "candles" TO L-PROP
             MOVE 4 TO L-MAX
     END-EVALUATE
     GOBACK.
 END PROGRAM STACK-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-PROP                PIC X(24).
 01 WS-MAX                 BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-PLACED-STATE         BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-PLACED-STATE L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "STACK-RULE" USING L-PLACED-STATE WS-PROP WS-MAX WS-SNOW
     IF WS-PROP = SPACES
         GOBACK
     END-IF
     MOVE PL-DIM(CN-PLAYER(L-ID)) TO WS-DIM
     CALL "PS-DIR-STEP" USING PSB-FACE WS-DX WS-DY WS-DZ
*>   Try 1: the clicked block is replaced by the item (replaceClicked); try 2: the cell on the clicked face holds the block (canBeReplaced of the state there, replaceClicked false).
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 2 OR L-RESULT > 0
         MOVE PSB-BX TO WS-X
         MOVE PSB-BY TO WS-Y
         MOVE PSB-BZ TO WS-Z
         IF WS-TRY = 2
             ADD WS-DX TO WS-X
             ADD WS-DY TO WS-Y
             ADD WS-DZ TO WS-Z
         END-IF
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OLD
         IF CB-S-BLOCK(WS-OLD + 1) = CB-S-BLOCK(L-PLACED-STATE + 1)
             CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-OLD WS-PROP WS-TEXT WS-FOUND
             COMPUTE WS-COUNT = FUNCTION NUMVAL(WS-TEXT)
             MOVE 0 TO WS-CAN
             IF WS-COUNT < WS-MAX
                 EVALUATE TRUE
                     WHEN WS-SNOW = 0 AND PL-SNEAKING(CN-PLAYER(L-ID)) = 0
                         MOVE 1 TO WS-CAN
                     WHEN WS-SNOW = 1 AND (WS-TRY = 2 OR PSB-FACE = 1)
                         MOVE 1 TO WS-CAN
                 END-EVALUATE
             END-IF
             IF WS-CAN = 1
                 ADD 1 TO WS-COUNT
                 MOVE SPACES TO WS-TEXT
                 MOVE FUNCTION CHAR(WS-COUNT + 49) TO WS-TEXT(1:1)
                 CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-OLD WS-PROP WS-TEXT WS-NEW
*>               BlockItem.canPlace: the state's shape (taller with more of them) must not meet a blocking entity.
                 CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-X WS-Y WS-Z WS-NEW WS-HIT
                 IF WS-HIT = 1
                     CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
                     MOVE 2 TO L-RESULT
                 ELSE
                     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STACK-PLACE.
