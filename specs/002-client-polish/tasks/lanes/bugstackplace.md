commit c33c0f6ae77c08ed6e38a77df9483f2fe0fc826b
Author: Stefan Rusek <stefan@rusek.org>
Date:   Thu Nov 19 14:12:56 2026 -0500

    fix(core): sea pickle, turtle egg, candle and snow used on their own block add one (24-6 6.14/6.15, 29b-7, 24-3 snow)
    
    BLOCK-PLACE put the item in the neighbouring cell; STACK-PLACE (place-stack.cob) adds one to the count of the clicked block or of the block in the cell on the clicked face, keeping every other property.
    
    Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
    Claude-Session: https://claude.ai/code/session_01XrVsM2eDRRo1xQapRd9Uam

diff --git a/core/src/blocks.cob b/core/src/blocks.cob
index 3424cee0..488342c8 100644
--- a/core/src/blocks.cob
+++ b/core/src/blocks.cob
@@ -319,6 +319,7 @@
  01 WS-WL-TEXT             PIC X(32).
  01 WS-WL-MODE             BINARY-LONG VALUE 2.
  01 WS-STACKED             BINARY-LONG.
+ 01 WS-COUNTED             BINARY-LONG.
  01 WS-MERGES              BINARY-LONG.
  LINKAGE SECTION.
  COPY PLAYPKT.
@@ -334,6 +335,14 @@
          MOVE 1 TO L-PLACED
          GOBACK
      END-IF
+*>   A sea pickle, turtle egg, candle or snow layer used on its own kind gains one (place-stack.cob; 1 placed, 2 refused with the player told).
+     CALL "STACK-PLACE" USING L-ID PLAY-SERVERBOUND L-PLACED-STATE WS-COUNTED
+     IF WS-COUNTED > 0
+         IF WS-COUNTED = 1
+             MOVE 1 TO L-PLACED
+         END-IF
+         GOBACK
+     END-IF
      MOVE L-PLACED-STATE TO WS-STATE
      IF CB-S-BLOCK(WS-STATE + 1) = CR-CARDSTACK
          EVALUATE PSB-FACE
diff --git a/core/src/place-stack.cob b/core/src/place-stack.cob
new file mode 100644
index 00000000..0270e607
--- /dev/null
+++ b/core/src/place-stack.cob
@@ -0,0 +1,126 @@
+*> Blocks that hold several of their own item in one cell through a count property (lane bugstackplace, operator report try18 "sea cucumbers don't place multiple in the block", read as the sea pickle;
+*> 24 part 6 sections 6.14 and 6.15 SEA_PICKLE and TURTLE_EGG getStateForPlacement and canBeReplaced, 29b-7 CandleBlock placement and canBeReplaced, 24 part 3 SnowLayerBlock replacement, 29 section 9.5
+*> BlockPlaceContext): the item used on a block of its own kind adds one to the count instead of going in the neighbouring cell.
+*>   STACK-RULE USING state, property out (PIC X(24), spaces when the block does not stack), maximum out, snow out (1 for the snow layer rule: the clicked block is replaced only through its top face, a block
+*>     in the neighbour cell is always replaceable; 0 for the rule of the sea pickle, turtle egg and candles: the placer is not using secondary use)
+*>     sea_pickle (pickles 1 to 4), turtle_egg (eggs 1 to 4), candle and the sixteen dyed candles (candles 1 to 4), snow (layers 1 to 8)
+*>   STACK-PLACE USING connection id, PLAY-SERVERBOUND (Use Item On), placed state (the held item's default state), result out: 0 the item does not stack here (the caller places it as usual),
+*>     1 the block of the clicked cell or of the cell on the clicked face gained one (every other property kept; the caller uses up the item), 2 the placement was refused because an entity is in the way
+*>     (the player was told; nothing is placed and no item is used up)
+
+ IDENTIFICATION DIVISION.
+ PROGRAM-ID. STACK-RULE.
+ DATA DIVISION.
+ WORKING-STORAGE SECTION.
+ 01 WS-NAME                PIC X(48).
+ 01 WS-SUFFIX              PIC X(24) VALUE "_candle".
+ 01 WS-FLAG                BINARY-LONG.
+ LINKAGE SECTION.
+ 01 L-STATE                BINARY-LONG.
+ 01 L-PROP                 PIC X(24).
+ 01 L-MAX                  BINARY-LONG.
+ 01 L-SNOW                 BINARY-LONG.
+ PROCEDURE DIVISION USING L-STATE L-PROP L-MAX L-SNOW.
+     MOVE SPACES TO L-PROP
+     MOVE 0 TO L-MAX L-SNOW
+     CALL "PS-NAME-OF" USING L-STATE WS-NAME
+     CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-FLAG
+     EVALUATE TRUE
+         WHEN WS-NAME = "sea_pickle"
+             MOVE "pickles" TO L-PROP
+             MOVE 4 TO L-MAX
+         WHEN WS-NAME = "turtle_egg"
+             MOVE "eggs" TO L-PROP
+             MOVE 4 TO L-MAX
+         WHEN WS-NAME = "snow"
+             MOVE "layers" TO L-PROP
+             MOVE 8 TO L-MAX
+             MOVE 1 TO L-SNOW
+         WHEN WS-NAME = "candle" OR WS-FLAG = 1
+             MOVE "candles" TO L-PROP
+             MOVE 4 TO L-MAX
+     END-EVALUATE
+     GOBACK.
+ END PROGRAM STACK-RULE.
+
+ IDENTIFICATION DIVISION.
+ PROGRAM-ID. STACK-PLACE.
+ DATA DIVISION.
+ WORKING-STORAGE SECTION.
+ COPY CORESTATE.
+ COPY CBLOCKS.
+ 01 WS-PROP                PIC X(24).
+ 01 WS-MAX                 BINARY-LONG.
+ 01 WS-SNOW                BINARY-LONG.
+ 01 WS-MODE-GET            BINARY-LONG VALUE 1.
+ 01 WS-MODE-SET            BINARY-LONG VALUE 2.
+ 01 WS-DIM                 BINARY-LONG.
+ 01 WS-TRY                 BINARY-LONG.
+ 01 WS-X                   BINARY-LONG.
+ 01 WS-Y                   BINARY-LONG.
+ 01 WS-Z                   BINARY-LONG.
+ 01 WS-DX                  BINARY-LONG.
+ 01 WS-DY                  BINARY-LONG.
+ 01 WS-DZ                  BINARY-LONG.
+ 01 WS-OLD                 BINARY-LONG.
+ 01 WS-NEW                 BINARY-LONG.
+ 01 WS-TEXT                PIC X(32).
+ 01 WS-FOUND               BINARY-LONG.
+ 01 WS-COUNT               BINARY-LONG.
+ 01 WS-CAN                 BINARY-LONG.
+ 01 WS-HIT                 BINARY-LONG.
+ LINKAGE SECTION.
+ COPY PLAYPKT.
+ 01 L-ID                   BINARY-LONG.
+ 01 L-PLACED-STATE         BINARY-LONG.
+ 01 L-RESULT               BINARY-LONG.
+ PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-PLACED-STATE L-RESULT.
+     MOVE 0 TO L-RESULT
+     CALL "STACK-RULE" USING L-PLACED-STATE WS-PROP WS-MAX WS-SNOW
+     IF WS-PROP = SPACES
+         GOBACK
+     END-IF
+     MOVE PL-DIM(CN-PLAYER(L-ID)) TO WS-DIM
+     CALL "PS-DIR-STEP" USING PSB-FACE WS-DX WS-DY WS-DZ
+*>   Try 1: the clicked block is replaced by the item (replaceClicked); try 2: the cell on the clicked face holds the block (canBeReplaced of the state there, replaceClicked false).
+     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 2 OR L-RESULT > 0
+         MOVE PSB-BX TO WS-X
+         MOVE PSB-BY TO WS-Y
+         MOVE PSB-BZ TO WS-Z
+         IF WS-TRY = 2
+             ADD WS-DX TO WS-X
+             ADD WS-DY TO WS-Y
+             ADD WS-DZ TO WS-Z
+         END-IF
+         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OLD
+         IF CB-S-BLOCK(WS-OLD + 1) = CB-S-BLOCK(L-PLACED-STATE + 1)
+             CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-OLD WS-PROP WS-TEXT WS-FOUND
+             COMPUTE WS-COUNT = FUNCTION NUMVAL(WS-TEXT)
+             MOVE 0 TO WS-CAN
+             IF WS-COUNT < WS-MAX
+                 EVALUATE TRUE
+                     WHEN WS-SNOW = 0 AND PL-SNEAKING(CN-PLAYER(L-ID)) = 0
+                         MOVE 1 TO WS-CAN
+                     WHEN WS-SNOW = 1 AND (WS-TRY = 2 OR PSB-FACE = 1)
+                         MOVE 1 TO WS-CAN
+                 END-EVALUATE
+             END-IF
+             IF WS-CAN = 1
+                 ADD 1 TO WS-COUNT
+                 MOVE SPACES TO WS-TEXT
+                 MOVE FUNCTION CHAR(WS-COUNT + 49) TO WS-TEXT(1:1)
+                 CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-OLD WS-PROP WS-TEXT WS-NEW
+*>               BlockItem.canPlace: the state's shape (taller with more of them) must not meet a blocking entity.
+                 CALL "BLOCK-OVERLAPS-BODY" USING WS-DIM WS-X WS-Y WS-Z WS-NEW WS-HIT
+                 IF WS-HIT = 1
+                     CALL "BLOCK-TELL" USING L-ID WS-X WS-Y WS-Z
+                     MOVE 2 TO L-RESULT
+                 ELSE
+                     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-NEW
+                     MOVE 1 TO L-RESULT
+                 END-IF
+             END-IF
+         END-IF
+     END-PERFORM
+     GOBACK.
+ END PROGRAM STACK-PLACE.
diff --git a/core/tests/acc_stack_place.cob b/core/tests/acc_stack_place.cob
index bdc51b04..c04b7568 100644
--- a/core/tests/acc_stack_place.cob
+++ b/core/tests/acc_stack_place.cob
@@ -346,6 +346,7 @@
      PERFORM GIVE-ITEMS
      CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA
      PERFORM USE-ITEM-ON
+     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT-AREA
      MOVE "sea_pickle" TO WS-WANT
      MOVE "pickles" TO WS-PROP
      MOVE "2" TO WS-WANT-N
@@ -400,7 +401,7 @@
      MOVE "lit" TO WS-PROP2
      MOVE "true" TO WS-TEXT
      CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP2 WS-TEXT WS-NEW
-     COMPUTE WS-CX = WS-BX + 5
+     COMPUTE WS-CX = WS-BX + 12
      COMPUTE WS-CZ = WS-BZ + 16
      CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-NEW
      MOVE WS-CX TO WS-UX
@@ -461,7 +462,52 @@
      MOVE "1" TO WS-WANT2
      MOVE "hatch" TO WS-PROP2
      MOVE "acceptance stack place: the hatch stage is kept" TO WS-CASE
-     PERFORM CHECK-PROP2.
+     PERFORM CHECK-PROP2
+*>   A player standing in the cell blocks the taller state (29 section 9.6): nothing changes, no item is used up; once the player has left, the use stacks.
+     MOVE "candle" TO WS-KEY
+     PERFORM FIND-STATE
+     COMPUTE WS-CX = WS-BX + 14
+     COMPUTE WS-CZ = WS-BZ + 12
+     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-FOUND-STATE
+     MOVE WS-CX TO WS-UX
+     MOVE WS-CZ TO WS-UZ
+     MOVE WS-CY TO WS-UY
+     MOVE "candle" TO WS-HAND-ITEM
+     MOVE "candle" TO WS-WANT
+     MOVE "candles" TO WS-PROP
+     PERFORM GIVE-ITEMS
+     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
+     MOVE WS-CY TO PL-Y(WS-PLAYER)
+     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
+     MOVE 4 TO WS-FACE
+     PERFORM USE-ITEM-ON
+     MOVE "1" TO WS-WANT-N
+     MOVE "acceptance stack place: a candle is not stacked while the player stands in its cell (still 1)" TO WS-CASE
+     PERFORM CHECK-COUNT
+     COMPUTE WS-EXPECT = 30
+     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
+     MOVE "acceptance stack place: the refused use kept the item" TO WS-CASE
+     PERFORM CHECK-N
+     COMPUTE PL-X(WS-PLAYER) = WS-BX + 13.5
+     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 3
+     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 15.5
+     PERFORM USE-ITEM-ON
+     MOVE "2" TO WS-WANT-N
+     MOVE "acceptance stack place: with the player gone the use makes 2 candles" TO WS-CASE
+     PERFORM CHECK-COUNT
+*>   A block without a count is placed as before (dirt on the grass).
+     MOVE "dirt" TO WS-HAND-ITEM
+     COMPUTE WS-UX = WS-BX + 14
+     COMPUTE WS-UZ = WS-BZ + 3
+     MOVE WS-FLOOR TO WS-UY
+     MOVE 1 TO WS-FACE
+     PERFORM GIVE-ITEMS
+     PERFORM USE-ITEM-ON
+     MOVE WS-UX TO WS-CX
+     MOVE WS-UZ TO WS-CZ
+     MOVE "dirt" TO WS-WANT
+     MOVE "acceptance stack place: a block without a count is placed as before" TO WS-CASE
+     PERFORM CHECK-KEY.
 
  FIND-STATE.
      MOVE 0 TO WS-FOUND-STATE
diff --git a/specs/002-client-polish/tasks/lanes/bugstackplace.md b/specs/002-client-polish/tasks/lanes/bugstackplace.md
new file mode 100644
index 00000000..52328cbb
--- /dev/null
+++ b/specs/002-client-polish/tasks/lanes/bugstackplace.md
@@ -0,0 +1,8 @@
+## Phase bugstackplace (lane bugstackplace, operator report of try18: "sea cucumbers don't place multiple in the block"; T61400-T61499)
+
+Operator report: "sea cucumbers don't place multiple in the block". The generated pack and the docs hold no block or item named sea cucumber (grep of docs/, core and the generated data); the report is read as the SEA PICKLE (24 part 6 section 6.14: using a sea pickle item on a sea pickle block adds a pickle, `pickles` 1 to 4). The same rule is documented for the turtle egg, the candles and snow layers, and all four were broken the same way.
+
+- [x] T61400 [bugstackplace] Root cause (core, `BLOCK-PLACE`): the item was placed at the cell on the clicked face with its default state (the clicked cell is replaced only for replaceable blocks, slabs and multiface blocks: `PS-CLICK-REPLACES`), so a sea pickle, turtle egg, candle or snow item used on its own block went in the neighbouring cell or was refused (a pickle on a pickle needs a sturdy top below it: the one under it has none). No stacking rule existed for the count properties (`SEG-STACK` covers only the petals, wildflowers and leaf litter).
+- [x] T61401 [bugstackplace] `core/src/place-stack.cob` (new): `STACK-RULE` (sea_pickle pickles 4, turtle_egg eggs 4, candle and the 16 dyed candles candles 4, snow layers 8) and `STACK-PLACE`: 24-6 sections 6.14 and 6.15 and 29b-7 (`getStateForPlacement` takes the existing state with the count plus one, `canBeReplaced` true when the placer is not sneaking, the held item is the block's own item and the count is below the maximum), 24-3 snow (replacement by a placing item: the clicked snow block through its top face only, a snow block in the cell on the clicked face always; no secondary-use test). All other properties (waterlogged, lit, hatch) are kept; the state's shape must not meet a blocking entity (29 section 9.6). `BLOCK-PLACE` (blocks.cob) calls it first; the clicked cell is tried first, then the cell on the clicked face.
+- [x] T61402 [bugstackplace] Test `core/tests/acc_stack_place.cob` (standard world of the generated vanilla pack, skipped as a pass without CC_GENERATED_DIR): sea pickle, turtle egg, candle, red candle and snow through Use Item On: the count goes 1 to the maximum on top-face clicks, the next use goes beside (snow: above), side-face stacking, stacking from the face of a neighbouring block, sneaking places beside, snow stacks while sneaking, items used up one per success, creative keeps the item, waterlogged, lit and hatch kept, another candle colour does not join, one Block Update to the viewer, block light 9 and 12 for two and three waterlogged pickles and 6 for two lit candles. Red before (57 of 85 failed: nothing stacked), green after.
+- [ ] T61410 [bugstackplace] Not done, same family: scaffolding is documented to stack onto scaffolding through `ScaffoldingBlockItem.updatePlacementContext` (a column walk of up to 7 steps, 25 part 1 section 5.3); `BLOCK-PLACE` still places it on the clicked face like any block. Snow of any layer count is replaced by any item through the `replaceable` tag (the docs say only a 1-layer snow block is).
