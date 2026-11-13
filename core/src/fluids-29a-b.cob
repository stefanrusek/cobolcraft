*> Fluids, second part (docs/protocol/29a sections 5 to 10) as programs of plain numbers: liquid containers (LC-), bubble columns (BB-),
*> buckets (FB-), entity fluid interaction (EF-), the tags, rules and attributes the fluid rules read (FT-) and the client fluid mesh
*> arithmetic (FM-). Fluid kinds are those of fluids-29a.cob: 0 empty, 1 flowing water, 2 water, 3 flowing lava, 4 lava. What lives in the
*> world is passed in as flags by the caller. Floating-point values are FLOAT-LONG (the entity numbers are doubles in the artifact; the mesh
*> numbers are single precision there and are compared to four decimals).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-CAN-PLACE.
*> USING fluid kind, double slab (BINARY-LONG), ok out: SimpleWaterloggedBlock.canPlaceLiquid (5.1): true exactly for the water source;
*> a double slab refuses.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-DOUBLE               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-DOUBLE L-OK.
     MOVE 0 TO L-OK
     IF L-FLUID = 2 AND L-DOUBLE = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM LC-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-PLACE.
*> USING waterlogged, incoming fluid kind, double slab, server side (BINARY-LONG), new waterlogged out, fluid tick delay out (0 none),
*> result out: placeLiquid (5.1): an unwaterlogged block given the water source becomes waterlogged on the server, with a water tick
*> (delay 5); the client side returns true without a change; anything else is false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-DOUBLE               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-FLUID L-DOUBLE L-SERVER L-NEW L-DELAY L-RESULT.
     MOVE L-WATERLOGGED TO L-NEW
     MOVE 0 TO L-DELAY L-RESULT
     IF L-WATERLOGGED = 0 AND L-FLUID = 2 AND L-DOUBLE = 0
         MOVE 1 TO L-RESULT
         IF L-SERVER = 1
             MOVE 1 TO L-NEW
             MOVE 5 TO L-DELAY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LC-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-FLUID-STATE.
*> USING waterlogged (BINARY-LONG), kind out, amount out, falling out: getFluidState of a waterlogged block (5.1): the water source
*> (kind 2, amount 8, not falling), else empty.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-KIND L-AMOUNT L-FALLING.
     MOVE 0 TO L-KIND L-AMOUNT L-FALLING
     IF L-WATERLOGGED = 1
         MOVE 2 TO L-KIND
         MOVE 8 TO L-AMOUNT
     END-IF
     GOBACK.
 END PROGRAM LC-FLUID-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-PICKUP.
*> USING waterlogged, the block can still survive without the water (BINARY-LONG), new waterlogged out, destroy with drops out, bucket
*> out (1 a water bucket, 0 the empty stack): pickupBlock (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-BUCKET               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-SURVIVES L-NEW L-DESTROY L-BUCKET.
     MOVE L-WATERLOGGED TO L-NEW
     MOVE 0 TO L-DESTROY L-BUCKET
     IF L-WATERLOGGED = 1
         MOVE 0 TO L-NEW
         MOVE 1 TO L-BUCKET
         IF L-SURVIVES = 0
             MOVE 1 TO L-DESTROY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LC-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-SLAB-WATERLOGGED.
*> USING the fluid kind at the clicked position, the placement merges into a double slab (BINARY-LONG), waterlogged out: only a water
*> source waterlogs a placed slab; a merge into a double slab is never waterlogged (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-MERGE                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-MERGE L-WATERLOGGED.
     MOVE 0 TO L-WATERLOGGED
     IF L-MERGE = 0 AND L-FLUID = 2
         MOVE 1 TO L-WATERLOGGED
     END-IF
     GOBACK.
 END PROGRAM LC-SLAB-WATERLOGGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-PLANT.
*> USING fluid kind (BINARY-LONG), can place out, place out, fluid kind out, can hold the specific fluid out, picked up out: kelp,
*> seagrass and tall seagrass (5.2): canPlaceLiquid and placeLiquid always false, the fluid state is always the water source, flow stops
*> at them and a bucket cannot take them.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-CAN-PLACE            BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-HOLD                 BINARY-LONG.
 01 L-PICKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-CAN-PLACE L-PLACE L-KIND L-HOLD L-PICKED.
     MOVE 0 TO L-CAN-PLACE L-PLACE L-HOLD L-PICKED
     MOVE 2 TO L-KIND
     GOBACK.
 END PROGRAM LC-PLANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-PLANT-PLACEMENT.
*> USING the fluid kind at the clicked position, its amount (BINARY-LONG), ok out: kelp and seagrass placement (5.2): the clicked fluid is
*> in tag water and full (amount 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-AMOUNT L-OK.
     MOVE 0 TO L-OK
     IF (L-FLUID = 1 OR L-FLUID = 2) AND L-AMOUNT = 8
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM LC-PLANT-PLACEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LC-SEAGRASS.
*> USING the neighbour is air, the block above is the water block, tall half (0 lower, 1 upper), the lower half is below, normal plant support,
*> the fluid here is a full water (BINARY-LONG), schedule water tick out, bone meal valid out, survives out, kelp may grow into out (the
*> block above is the water block): the seagrass rules of 5.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-WATER-ABOVE          BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-BONE                 BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-GROW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-WATER-ABOVE L-HALF L-LOWER L-SUPPORT L-FULL L-SCHEDULE L-BONE L-SURVIVES L-GROW.
     MOVE 0 TO L-SCHEDULE L-SURVIVES
     IF L-AIR = 0
         MOVE 1 TO L-SCHEDULE
     END-IF
     MOVE L-WATER-ABOVE TO L-BONE L-GROW
     IF L-HALF = 1
         MOVE L-LOWER TO L-SURVIVES
     END-IF
     IF L-HALF = 0 AND L-SUPPORT = 1 AND L-FULL = 1
         MOVE 1 TO L-SURVIVES
     END-IF
     GOBACK.
 END PROGRAM LC-SEAGRASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BB-SCHEDULE.
*> USING the fluid kind, its amount, the block below (0 other, 1 magma block, 2 soul sand) (BINARY-LONG), delay out (0 none): the block tick
*> a full water source schedules on itself (6 step 1, BUBBLE_COLUMN_CHECK_DELAY 20).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-AMOUNT L-BELOW L-DELAY.
     MOVE 0 TO L-DELAY
     IF L-FLUID = 2 AND L-AMOUNT = 8 AND L-BELOW NOT = 0
         MOVE 20 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM BB-SCHEDULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BB-COLUMN.
*> USING the block below (0 other, 1 soul sand, 2 magma block, 3 a bubble column that pushes up, 4 a bubble column that drags) (BINARY-LONG),
*> column out (1 a bubble column, 0 plain water), drag out: the column state of 6 step 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-COLUMN               BINARY-LONG.
 01 L-DRAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-COLUMN L-DRAG.
     MOVE 0 TO L-COLUMN L-DRAG
     IF L-BELOW NOT = 0
         MOVE 1 TO L-COLUMN
     END-IF
     IF L-BELOW = 2 OR L-BELOW = 4
         MOVE 1 TO L-DRAG
     END-IF
     GOBACK.
 END PROGRAM BB-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BB-SURFACE.
*> USING the cell above has an empty collision shape, it holds a fluid (BINARY-LONG), surface out: the entity is at the top of the column
*> (6 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-SURFACE              BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-FLUID L-SURFACE.
     MOVE 0 TO L-SURFACE
     IF L-EMPTY = 1 AND L-FLUID = 0
         MOVE 1 TO L-SURFACE
     END-IF
     GOBACK.
 END PROGRAM BB-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BB-VELOCITY.
*> USING where (1 above the column, 2 inside it), drag, entity kind (0 default, 1 player, 2 projectile), flying, owns the movement, server
*> side (BINARY-LONG), vy in (FLOAT-LONG), vy out (FLOAT-LONG), reset the fall distance out, particle rounds out: the velocity change of
*> the bubble column (6 table). A flying player is skipped entirely; the change acts only for the side that owns the movement; the reset of
*> the inside case is not gated by that; the particles follow the above case on the server.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-WHERE                BINARY-LONG.
 01 L-DRAG                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-FLYING               BINARY-LONG.
 01 L-OWNS                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-ROUNDS               BINARY-LONG.
 PROCEDURE DIVISION USING L-WHERE L-DRAG L-KIND L-FLYING L-OWNS L-SERVER L-VY L-OUT L-RESET L-ROUNDS.
     MOVE L-VY TO L-OUT
     MOVE 0 TO L-RESET L-ROUNDS
     IF L-KIND = 1 AND L-FLYING = 1
         GOBACK
     END-IF
     IF L-OWNS = 1
         EVALUATE TRUE
             WHEN L-WHERE = 1 AND L-DRAG = 1 AND L-KIND = 2
                 COMPUTE L-OUT = L-VY - 0.03
             WHEN L-WHERE = 1 AND L-DRAG = 0 AND L-KIND = 2
                 COMPUTE L-OUT = L-VY + 0.1
             WHEN L-WHERE = 1 AND L-DRAG = 1
                 COMPUTE WS-T = L-VY - 0.03
                 COMPUTE L-OUT = FUNCTION MAX(-0.9, WS-T)
             WHEN L-WHERE = 1
                 COMPUTE WS-T = L-VY + 0.1
                 COMPUTE L-OUT = FUNCTION MIN(1.8, WS-T)
             WHEN L-DRAG = 1 AND L-KIND = 2
                 COMPUTE L-OUT = L-VY - 0.03
             WHEN L-DRAG = 0 AND L-KIND = 2
                 COMPUTE L-OUT = L-VY + 0.06
             WHEN L-DRAG = 1
                 COMPUTE WS-T = L-VY - 0.03
                 COMPUTE L-OUT = FUNCTION MAX(-0.3, WS-T)
             WHEN OTHER
                 COMPUTE WS-T = L-VY + 0.06
                 COMPUTE L-OUT = FUNCTION MIN(0.7, WS-T)
         END-EVALUATE
     END-IF
     IF L-WHERE = 2
         MOVE 1 TO L-RESET
     END-IF
     IF L-WHERE = 1 AND L-SERVER = 1
         MOVE 2 TO L-ROUNDS
     END-IF
     GOBACK.
 END PROGRAM BB-VELOCITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-CONTEXT.
*> USING content (0 empty, 1 water, 2 lava), mob bucket (BINARY-LONG), context out (1 SOURCE_ONLY, 0 NONE): BucketItem.getFluidContext
*> (7.1): the ray hits only fluid sources for an empty bucket; a mob bucket is NONE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONTENT              BINARY-LONG.
 01 L-MOB                  BINARY-LONG.
 01 L-CONTEXT              BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTENT L-MOB L-CONTEXT.
     MOVE 0 TO L-CONTEXT
     IF L-CONTENT = 0 AND L-MOB = 0
         MOVE 1 TO L-CONTEXT
     END-IF
     GOBACK.
 END PROGRAM FB-CONTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-USE-GATE.
*> USING the ray result (0 miss, 1 block, 2 anything else), may interact, may use the item at the place position (BINARY-LONG), target
*> position out (0 the hit block, 1 the position beside the hit face), outcome out (0 pass, 1 fail, 2 go on), needs the block is a liquid
*> container and the content is water (BINARY-LONG): BucketItem.use steps 1 to 3 (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAY                  BINARY-LONG.
 01 L-INTERACT             BINARY-LONG.
 01 L-USE-AT               BINARY-LONG.
 01 L-CONTAINER-WATER      BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-RAY L-INTERACT L-USE-AT L-CONTAINER-WATER L-TARGET L-OUTCOME.
     MOVE 1 TO L-TARGET
     IF L-CONTAINER-WATER = 1
         MOVE 0 TO L-TARGET
     END-IF
     EVALUATE TRUE
         WHEN L-RAY NOT = 1
             MOVE 0 TO L-OUTCOME
         WHEN L-INTERACT = 0 OR L-USE-AT = 0
             MOVE 1 TO L-OUTCOME
         WHEN OTHER
             MOVE 2 TO L-OUTCOME
     END-EVALUATE
     GOBACK.
 END PROGRAM FB-USE-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-CAN-PLACE.
*> USING content (1 water, 2 lava, 0 anything else), the block is air, it can be replaced by the fluid, it is a liquid container, the
*> container accepts the fluid, the player sneaks, a hit exists (BINARY-LONG), action out (0 false, 1 place here, 2 retry once at the hit
*> position beside the face with no hit): emptyContents steps 1 to 3 (7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CONTAIN             BINARY-LONG.
 LINKAGE SECTION.
 01 L-CONTENT              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-ACCEPTS              BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTENT L-AIR L-REPLACEABLE L-CONTAINER L-ACCEPTS L-SHIFT L-HIT L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-CONTENT = 0
         GOBACK
     END-IF
     MOVE L-REPLACEABLE TO WS-CONTAIN
     IF L-CONTAINER = 1 AND L-ACCEPTS = 1
         MOVE 1 TO WS-CONTAIN
     END-IF
     EVALUATE TRUE
         WHEN L-AIR = 1
             MOVE 1 TO L-ACTION
         WHEN WS-CONTAIN = 1 AND (L-SHIFT = 0 OR L-HIT = 0)
             MOVE 1 TO L-ACTION
         WHEN L-HIT = 1
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM FB-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-EMPTY-STEP.
*> USING water_evaporates at the position, the content is in tag water, the block is a liquid container, the content is water, the block
*> can be replaced, the block is a liquid (BINARY-LONG), action out (1 evaporate: the sound and eight large_smoke, nothing placed; 2
*> placeLiquid into the container; 3 write the fluid's source block), destroy with drops out: emptyContents steps 4 to 6 (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-WATER-TAG            BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 PROCEDURE DIVISION USING L-EVAPORATES L-WATER-TAG L-CONTAINER L-WATER L-REPLACEABLE L-LIQUID L-ACTION L-DESTROY.
     MOVE 0 TO L-DESTROY
     EVALUATE TRUE
         WHEN L-EVAPORATES = 1 AND L-WATER-TAG = 1
             MOVE 1 TO L-ACTION
         WHEN L-CONTAINER = 1 AND L-WATER = 1
             MOVE 2 TO L-ACTION
         WHEN OTHER
             MOVE 3 TO L-ACTION
             IF L-REPLACEABLE = 1 AND L-LIQUID = 0
                 MOVE 1 TO L-DESTROY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FB-EMPTY-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-EMPTY-RESULT.
*> USING the write changed the block, the state held a fluid source before, the content is in tag lava (BINARY-LONG), result out, sound
*> out (0 none, 1 bucket.empty, 2 bucket.empty_lava): the end of emptyContents step 6 and playEmptySound (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANGED              BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-LAVA                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANGED L-SOURCE L-LAVA L-RESULT L-SOUND.
     MOVE 0 TO L-RESULT L-SOUND
     IF L-CHANGED = 1 OR L-SOURCE = 1
         MOVE 1 TO L-RESULT L-SOUND
         IF L-LAVA = 1
             MOVE 2 TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FB-EMPTY-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-AFTER-USE.
*> USING emptyContents succeeded, the content is empty, the block is a pickup, the pickup returned a bucket, creative (BINARY-LONG),
*> result out (0 fail, 1 success), held out (0 unchanged, 1 an empty bucket, 2 the filled bucket): BucketItem.use steps 4 to 6 (7.2);
*> creative players keep the stack when placing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLACED               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-HELD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACED L-EMPTY L-PICKUP L-RETURNED L-CREATIVE L-RESULT L-HELD.
     MOVE 0 TO L-RESULT L-HELD
     EVALUATE TRUE
         WHEN L-PLACED = 1
             MOVE 1 TO L-RESULT
             IF L-CREATIVE = 0
                 MOVE 1 TO L-HELD
             END-IF
         WHEN L-EMPTY = 1 AND L-PICKUP = 1 AND L-RETURNED = 1
             MOVE 1 TO L-RESULT
             MOVE 2 TO L-HELD
     END-EVALUATE
     GOBACK.
 END PROGRAM FB-AFTER-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-LIQUID-PICKUP.
*> USING fluid (1 water, 2 lava), block level 0 to 15 (BINARY-LONG), bucket out (0 the empty stack, 1 water bucket, 2 lava bucket), the
*> block becomes air out: LiquidBlock.pickupBlock (7.2): only the source (level 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-BUCKET               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-LEVEL L-BUCKET L-AIR.
     MOVE 0 TO L-BUCKET L-AIR
     IF L-LEVEL = 0
         MOVE L-FLUID TO L-BUCKET
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM FB-LIQUID-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-SOLID.
*> USING the position is inside the world border, the block there is air, server side (BINARY-LONG), placed out: SolidBucketItem.emptyContents
*> (7.5): powder snow is placed (on a server) only into an empty block inside the border; the result is true either side.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BORDER               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BORDER L-AIR L-SERVER L-RESULT L-PLACED.
     MOVE 0 TO L-RESULT L-PLACED
     IF L-BORDER = 1 AND L-AIR = 1
         MOVE 1 TO L-RESULT
         IF L-SERVER = 1
             MOVE 1 TO L-PLACED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FB-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-DISPENSE.
*> USING kind (1 a filled bucket, 2 an empty bucket), emptyContents succeeded, the block in front is a pickup, the pickup returned a
*> filled item (BINARY-LONG), action out (0 dispense as an ordinary item, 1 replace the stack by an empty bucket, 2 replace it by the
*> filled item), hit passed to emptyContents out (always no hit and no entity): the dispenser of 7.6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EMPTIED              BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-RETURNED             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-EMPTIED L-PICKUP L-RETURNED L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-KIND = 1 AND L-EMPTIED = 1
         MOVE 1 TO L-ACTION
     END-IF
     IF L-KIND = 2 AND L-PICKUP = 1 AND L-RETURNED = 1
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM FB-DISPENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-RANGE.
*> USING box minimum, box maximum (FLOAT-LONG), first cell out, last cell out (BINARY-LONG): the cell range of one axis (8.2 step 3): floor
*> of the minimum to ceil of the maximum minus one; the box is the bounding box deflated by 0.001 on every side (EF-DEFLATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN L-MAX L-FIRST L-LAST.
     COMPUTE WS-FLOOR = FUNCTION INTEGER(L-MIN)
     COMPUTE WS-CEIL = FUNCTION INTEGER(L-MAX)
     IF WS-CEIL < L-MAX
         ADD 1 TO WS-CEIL
     END-IF
     MOVE WS-FLOOR TO L-FIRST
     COMPUTE L-LAST = WS-CEIL - 1
     GOBACK.
 END PROGRAM EF-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-DEFLATE.
*> USING value, is the maximum side (BINARY-LONG), deflated out (FLOAT-LONG): getFluidInteractionBox (8.2 step 2): 0.001 off each side.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE L-MAX L-OUT.
     IF L-MAX = 1
         COMPUTE L-OUT = L-VALUE - 0.001
     ELSE
         COMPUTE L-OUT = L-VALUE + 0.001
     END-IF
     GOBACK.
 END PROGRAM EF-DEFLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-IDLE.
*> USING tracker height (FLOAT-LONG), eyes inside (BINARY-LONG), removed out: Tracker.reset (8.2 step 1): true exactly when the tracker was
*> already idle (height 0 and not eyes-inside); the others are reset and stay.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-EYES                 BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-EYES L-REMOVED.
     MOVE 0 TO L-REMOVED
     IF L-HEIGHT = 0 AND L-EYES = 0
         MOVE 1 TO L-REMOVED
     END-IF
     GOBACK.
 END PROGRAM EF-IDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-CELL.
*> USING cell y (BINARY-LONG), the fluid's height, its camera height, the box minimum y, the entity's bounding box minimum y, the eye y
*> (FLOAT-LONG), the cell is in the entity's block column (BINARY-LONG), tracker height in and out (FLOAT-LONG), eyes inside in and out,
*> counted out (BINARY-LONG): one cell of 8.2 step 6. The cell counts unless its fluid top is below the box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-REL                 FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-CAMERA               FLOAT-LONG.
 01 L-BOX-MIN              FLOAT-LONG.
 01 L-ENTITY-MIN           FLOAT-LONG.
 01 L-EYE                  FLOAT-LONG.
 01 L-COLUMN               BINARY-LONG.
 01 L-TRACKER              FLOAT-LONG.
 01 L-EYES                 BINARY-LONG.
 01 L-COUNTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-HEIGHT L-CAMERA L-BOX-MIN L-ENTITY-MIN L-EYE L-COLUMN L-TRACKER L-EYES L-COUNTED.
     MOVE 0 TO L-COUNTED
     COMPUTE WS-TOP = L-Y + L-HEIGHT
     IF WS-TOP < L-BOX-MIN
         GOBACK
     END-IF
     MOVE 1 TO L-COUNTED
     COMPUTE WS-REACH = L-Y + L-CAMERA
     IF L-COLUMN = 1 AND L-EYE >= L-Y AND L-EYE <= WS-REACH
         MOVE 1 TO L-EYES
     END-IF
     COMPUTE WS-REL = WS-TOP - L-ENTITY-MIN
     IF WS-REL > L-TRACKER
         MOVE WS-REL TO L-TRACKER
     END-IF
     GOBACK.
 END PROGRAM EF-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-ACCUM.
*> USING tracker height (FLOAT-LONG), accumulator height in and out, the cell's flow x, y, z, the summed flow x, y, z in and out
*> (FLOAT-LONG), count in and out (BINARY-LONG): the accumulator part of 8.2 step 6: the accumulator height is the larger of the two; below
*> 0.4 the flow is scaled by it; the flow is added and counted.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRACKER              FLOAT-LONG.
 01 L-ACC                  FLOAT-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRACKER L-ACC L-FX L-FY L-FZ L-SX L-SY L-SZ L-COUNT.
     IF L-TRACKER > L-ACC
         MOVE L-TRACKER TO L-ACC
     END-IF
     IF L-ACC < 0.4
         COMPUTE L-FX = L-FX * L-ACC
         COMPUTE L-FY = L-FY * L-ACC
         COMPUTE L-FZ = L-FZ * L-ACC
     END-IF
     ADD L-FX TO L-SX
     ADD L-FY TO L-SY
     ADD L-FZ TO L-SZ
     ADD 1 TO L-COUNT
     GOBACK.
 END PROGRAM EF-ACCUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-CURRENT.
*> USING summed flow x, y, z (FLOAT-LONG), count, is a player (BINARY-LONG), strength, delta movement x, z (FLOAT-LONG), push x, y, z out
*> (FLOAT-LONG): applyCurrentTo (8.3). Nothing for count 0 or a squared length below 9.999999747378752E-6; a player takes the average, any
*> other entity the normalised flow; times the strength; a slow entity (|vx| and |vz| below 0.003) is given at least 0.0045.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN2                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-INV                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-COUNT L-PLAYER L-STRENGTH L-VX L-VZ L-PX L-PY L-PZ.
     MOVE 0 TO L-PX L-PY L-PZ
     COMPUTE WS-LEN2 = L-SX * L-SX + L-SY * L-SY + L-SZ * L-SZ
     IF L-COUNT = 0 OR WS-LEN2 < 0.00000999999974737875
         GOBACK
     END-IF
     IF L-PLAYER = 1
         COMPUTE WS-INV = 1 / L-COUNT
     ELSE
         COMPUTE WS-LEN = FUNCTION SQRT(WS-LEN2)
         COMPUTE WS-INV = 1 / WS-LEN
     END-IF
     COMPUTE L-PX = L-SX * WS-INV * L-STRENGTH
     COMPUTE L-PY = L-SY * WS-INV * L-STRENGTH
     COMPUTE L-PZ = L-SZ * WS-INV * L-STRENGTH
     COMPUTE WS-AX = FUNCTION ABS(L-VX)
     COMPUTE WS-AZ = FUNCTION ABS(L-VZ)
     COMPUTE WS-LEN2 = L-PX * L-PX + L-PY * L-PY + L-PZ * L-PZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-LEN2)
     IF WS-AX < 0.003 AND WS-AZ < 0.003 AND WS-LEN < 0.0045000000000000005
         COMPUTE WS-INV = 0.0045000000000000005 / WS-LEN
         COMPUTE L-PX = L-PX * WS-INV
         COMPUTE L-PY = L-PY * WS-INV
         COMPUTE L-PZ = L-PZ * WS-INV
     END-IF
     GOBACK.
 END PROGRAM EF-CURRENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-STRENGTH.
*> USING fluid (1 water, 2 lava), the dimension's gameplay/fast_lava (BINARY-LONG), strength out (FLOAT-LONG): the push strength of 8.3:
*> 0.014 in water; in lava 0.007 with fast_lava, else 0.007 / 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING L-FLUID L-FAST L-STRENGTH.
     EVALUATE TRUE
         WHEN L-FLUID = 1
             MOVE 0.014 TO L-STRENGTH
         WHEN L-FAST = 1
             MOVE 0.007 TO L-STRENGTH
         WHEN OTHER
             COMPUTE L-STRENGTH = 0.007 / 3
     END-EVALUATE
     GOBACK.
 END PROGRAM EF-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-PUSHED.
*> USING entity kind (0 default, 1 turtle, 2 water animal, 3 frog, 4 axolotl, 5 nautilus, 6 swimming drowned, 7 arrow stuck in the ground,
*> 8 arrow in flight, 9 player flying, 10 player not flying) (BINARY-LONG), pushed out: isPushedByFluid (8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PUSHED               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PUSHED.
     MOVE 1 TO L-PUSHED
     IF (L-KIND >= 1 AND L-KIND <= 7) OR L-KIND = 9
         MOVE 0 TO L-PUSHED
     END-IF
     GOBACK.
 END PROGRAM EF-PUSHED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-FLAGS.
*> USING in water (the fluid height in tag water is above 0), was touching water, first tick (BINARY-LONG), reset the fall distance out,
*> splash out, new was touching out: updateFluidInteraction steps 1 to 3 (8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-WATER             BINARY-LONG.
 01 L-WAS                  BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-SPLASH               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-WATER L-WAS L-FIRST L-RESET L-SPLASH L-NEW.
     MOVE 0 TO L-RESET L-SPLASH
     MOVE L-IN-WATER TO L-NEW
     IF L-IN-WATER = 1
         MOVE 1 TO L-RESET
         IF L-WAS = 0 AND L-FIRST = 0
             MOVE 1 TO L-SPLASH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-SWIM.
*> USING swimming, sprinting, in water (the flag of the previous update), passenger, under water (eyes in water at the start of the tick and
*> in water), the fluid at the block position is in tag water (BINARY-LONG), swimming out: updateSwimming (8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SWIMMING             BINARY-LONG.
 01 L-SPRINTING            BINARY-LONG.
 01 L-IN-WATER             BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-UNDER                BINARY-LONG.
 01 L-AT-BLOCK             BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SWIMMING L-SPRINTING L-IN-WATER L-PASSENGER L-UNDER L-AT-BLOCK L-NEW.
     MOVE 0 TO L-NEW
     IF L-SWIMMING = 1
         IF L-SPRINTING = 1 AND L-IN-WATER = 1 AND L-PASSENGER = 0
             MOVE 1 TO L-NEW
         END-IF
     ELSE
         IF L-SPRINTING = 1 AND L-UNDER = 1 AND L-PASSENGER = 0 AND L-AT-BLOCK = 1
             MOVE 1 TO L-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF-SWIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-STATE.
*> USING the water tracker's height, its eyes-inside flag (BINARY-LONG), the lava tracker's height (FLOAT-LONG), wasEyeInWater, wasTouchingWater,
*> first tick (BINARY-LONG), in water out, in lava out, in liquid out, under water out, in shallow water out, eye in water out: the queries of
*> 8.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER-HEIGHT         FLOAT-LONG.
 01 L-WATER-EYES           BINARY-LONG.
 01 L-LAVA-HEIGHT          FLOAT-LONG.
 01 L-WAS-EYE              BINARY-LONG.
 01 L-WAS-TOUCHING         BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-IN-WATER             BINARY-LONG.
 01 L-IN-LAVA              BINARY-LONG.
 01 L-IN-LIQUID            BINARY-LONG.
 01 L-UNDER                BINARY-LONG.
 01 L-SHALLOW              BINARY-LONG.
 01 L-EYE-IN               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER-HEIGHT L-WATER-EYES L-LAVA-HEIGHT L-WAS-EYE L-WAS-TOUCHING L-FIRST L-IN-WATER L-IN-LAVA
         L-IN-LIQUID L-UNDER L-SHALLOW L-EYE-IN.
     MOVE L-WAS-TOUCHING TO L-IN-WATER
     MOVE 0 TO L-IN-LAVA L-IN-LIQUID L-UNDER L-SHALLOW
     MOVE L-WATER-EYES TO L-EYE-IN
     IF L-FIRST = 0 AND L-LAVA-HEIGHT > 0
         MOVE 1 TO L-IN-LAVA
     END-IF
     IF L-IN-WATER = 1 OR L-IN-LAVA = 1
         MOVE 1 TO L-IN-LIQUID
     END-IF
     IF L-WAS-EYE = 1 AND L-IN-WATER = 1
         MOVE 1 TO L-UNDER
     END-IF
     IF L-IN-WATER = 1 AND L-UNDER = 0
         MOVE 1 TO L-SHALLOW
     END-IF
     GOBACK.
 END PROGRAM EF-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-JUMP-THRESHOLD.
*> USING eye height (FLOAT-LONG), threshold out (FLOAT-LONG): getFluidJumpThreshold (8.5): 0.0 below an eye height of 0.4, else 0.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EYE                  FLOAT-LONG.
 01 L-THRESHOLD            FLOAT-LONG.
 PROCEDURE DIVISION USING L-EYE L-THRESHOLD.
     IF L-EYE < 0.4
         MOVE 0 TO L-THRESHOLD
     ELSE
         MOVE 0.4 TO L-THRESHOLD
     END-IF
     GOBACK.
 END PROGRAM EF-JUMP-THRESHOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF-SPLASH.
*> USING delta movement x, y, z, the hitbox width, the two nextFloat draws (FLOAT-LONG), the entity is its own controller (BINARY-LONG),
*> volume out, pitch out (FLOAT-LONG), sound out (1 swim splash, 2 high speed splash), particle count out: doWaterSplashEffect (8.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-VOLUME               FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-WIDTH L-R1 L-R2 L-OWN L-VOLUME L-PITCH L-SOUND L-COUNT.
     IF L-OWN = 1
         MOVE 0.2 TO WS-K
     ELSE
         MOVE 0.9 TO WS-K
     END-IF
     COMPUTE WS-S = FUNCTION SQRT(0.2 * L-VX * L-VX + L-VY * L-VY + 0.2 * L-VZ * L-VZ) * WS-K
     IF WS-S > 1.0
         MOVE 1.0 TO WS-S
     END-IF
     MOVE WS-S TO L-VOLUME
     IF WS-S < 0.25
         MOVE 1 TO L-SOUND
     ELSE
         MOVE 2 TO L-SOUND
     END-IF
     COMPUTE L-PITCH = 1.0 + (L-R1 - L-R2) * 0.4
     *>   The width is a single-precision float in the artifact, so a product that is whole in double precision is never below it.
     COMPUTE L-COUNT = FUNCTION INTEGER(1 + L-WIDTH * 20 + 0.000001)
     GOBACK.
 END PROGRAM EF-SPLASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FT-FLUID-TAG.
*> USING tag (1 water, 2 lava, 3 bubble_column_can_occupy, 4 entity_floatable, 5 supports_lily_pad, 6 supports_frogspawn,
*> 7 supports_sugar_cane_adjacently), fluid kind (0 empty, 1 flowing water, 2 water, 3 flowing lava, 4 lava) (BINARY-LONG), member out:
*> the fluid tags of 29a section 9 (the tags written `#water` hold both water fluids, the ones written `water` the water source only).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-KIND L-MEMBER.
     MOVE 0 TO L-MEMBER
     EVALUATE TRUE
         WHEN L-TAG = 1 OR L-TAG = 4 OR L-TAG = 7
             IF L-KIND = 1 OR L-KIND = 2
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN L-TAG = 2
             IF L-KIND = 3 OR L-KIND = 4
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN OTHER
             IF L-KIND = 2
                 MOVE 1 TO L-MEMBER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FT-FLUID-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FT-RULE.
*> USING rule (1 water_source_conversion, 2 lava_source_conversion, 3 fire_spread_radius_around_player, 4 gameplay/fast_lava, 5
*> gameplay/water_evaporates) (BINARY-LONG), default out: the game rules and environment attributes of 29a section 9 with their defaults.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-DEFAULT.
     EVALUATE L-RULE
         WHEN 1
             MOVE 1 TO L-DEFAULT
         WHEN 3
             MOVE 128 TO L-DEFAULT
         WHEN OTHER
             MOVE 0 TO L-DEFAULT
     END-EVALUATE
     GOBACK.
 END PROGRAM FT-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FT-WATER-EVAPORATES.
*> USING dimension type key (PIC X(32)), value out: the positional attribute gameplay/water_evaporates is true in the nether dimension type
*> and false (the default) elsewhere (29a section 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-VALUE.
     MOVE 0 TO L-VALUE
     IF L-KEY = "minecraft:the_nether"
         MOVE 1 TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM FT-WATER-EVAPORATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FT-BUBBLE-DRIVER.
*> USING block key (PIC X(32)), driver out (0 none, 1 drags down: tag enables_bubble_column_drag_down = magma_block, 2 pushes up: tag
*> enables_bubble_column_push_up = soul_sand) (BINARY-LONG): the block tags of 29a section 9 read by the bubble column.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-DRIVER               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-DRIVER.
     MOVE 0 TO L-DRIVER
*>   The standard set's keys have no namespace ("magma_block").
     IF L-KEY = "minecraft:magma_block" OR L-KEY = "magma_block"
         MOVE 1 TO L-DRIVER
     END-IF
     IF L-KEY = "minecraft:soul_sand" OR L-KEY = "soul_sand"
         MOVE 2 TO L-DRIVER
     END-IF
     GOBACK.
 END PROGRAM FT-BUBBLE-DRIVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FT-BLOCK-TAG-UNION.
*> USING tag (1 blocks_fluid_flow = blocks_motion or all_signs, 2 blocks_lava_fire_spread = blocks_motion), the block is in blocks_motion,
*> the block is a sign (BINARY-LONG), member out: the block tags of 29a section 9 that are unions.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-MOTION               BINARY-LONG.
 01 L-SIGN                 BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-MOTION L-SIGN L-MEMBER.
     MOVE L-MOTION TO L-MEMBER
     IF L-TAG = 1 AND L-SIGN = 1
         MOVE 1 TO L-MEMBER
     END-IF
     GOBACK.
 END PROGRAM FT-BLOCK-TAG-UNION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-DRAW-FACE.
*> USING direction is UP (BINARY-LONG), the neighbour in that direction is the same fluid, this block's own state occludes the face with a
*> full-height box, the neighbour block occludes the face (BINARY-LONG), draw out: face selection of 10.1: the top face is a candidate when
*> the fluid above is not the same fluid; a side or bottom face is drawn when the neighbour is not the same fluid and is not occluded by the
*> block itself; either is dropped when the neighbouring block occludes it.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UP                   BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-SELF                 BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-UP L-SAME L-SELF L-NEIGHBOUR L-DRAW.
     MOVE 0 TO L-DRAW
     IF L-SAME = 0 AND (L-UP = 1 OR L-SELF = 0) AND L-NEIGHBOUR = 0
         MOVE 1 TO L-DRAW
     END-IF
     GOBACK.
 END PROGRAM FM-DRAW-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-OCCLUDES.
*> USING direction is UP, the neighbour's occlusion shape (0 empty, 1 full block face, 2 other), the fluid height tested (FLOAT-LONG; 1
*> unless it is the top face of a lower fluid), blockOccludes result for another shape (BINARY-LONG), occluded out: isFaceOccludedByState
*> (10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UP                   BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-UP L-SHAPE L-HEIGHT L-OTHER L-OCCLUDED.
     MOVE 0 TO L-OCCLUDED
     EVALUATE TRUE
         WHEN L-SHAPE = 1
             MOVE 1 TO L-OCCLUDED
             IF L-UP = 1 AND L-HEIGHT NOT = 1
                 MOVE 0 TO L-OCCLUDED
             END-IF
         WHEN L-SHAPE = 2
             MOVE L-OTHER TO L-OCCLUDED
     END-EVALUATE
     GOBACK.
 END PROGRAM FM-OCCLUDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-NEIGHBOUR-HEIGHT.
*> USING the neighbour holds fluid, the neighbour is another fluid than this one, its render height, the block is solid (BINARY-LONG/FLOAT-LONG),
*> height out (FLOAT-LONG): a neighbour height of 10.2: the fluid's own render height (1.0 under the same fluid above), 0.0 for a non-solid
*> block without fluid and -1.0 (ignored) for a solid one.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-HEIGHT-IN            FLOAT-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-FLUID L-HEIGHT-IN L-SOLID L-HEIGHT.
     EVALUATE TRUE
         WHEN L-FLUID = 1
             MOVE L-HEIGHT-IN TO L-HEIGHT
         WHEN L-SOLID = 1
             MOVE -1.0 TO L-HEIGHT
         WHEN OTHER
             MOVE 0.0 TO L-HEIGHT
     END-EVALUATE
     GOBACK.
 END PROGRAM FM-NEIGHBOUR-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-AVERAGE.
*> USING centre, a, b, the diagonal height (FLOAT-LONG), result out (FLOAT-LONG): average(center, a, b, diagonalPos) of 10.2. The diagonal
*> cell is read (and its height of 1 or more wins) only when a or b is above 0, so the caller passes it always and the program uses it then.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-WEIGHT              FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CENTRE               FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-DIAGONAL             FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-CENTRE L-A L-B L-DIAGONAL L-RESULT.
     IF L-A >= 1 OR L-B >= 1
         MOVE 1.0 TO L-RESULT
         GOBACK
     END-IF
     MOVE 0 TO WS-SUM WS-WEIGHT WS-DONE
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 4
         MOVE 0 TO WS-V
         EVALUATE WS-STEP
             WHEN 1
                 IF L-A > 0 OR L-B > 0
                     MOVE L-DIAGONAL TO WS-V
                     IF WS-V >= 1
                         MOVE 1 TO WS-DONE
                     END-IF
                 ELSE
                     MOVE -1.0 TO WS-V
                 END-IF
             WHEN 2
                 MOVE L-CENTRE TO WS-V
             WHEN 3
                 MOVE L-B TO WS-V
             WHEN OTHER
                 MOVE L-A TO WS-V
         END-EVALUATE
         IF WS-DONE = 0
             IF WS-V >= 0.8
                 COMPUTE WS-SUM = WS-SUM + WS-V * 10
                 ADD 10 TO WS-WEIGHT
             END-IF
             IF WS-V >= 0 AND WS-V < 0.8
                 ADD WS-V TO WS-SUM
                 ADD 1 TO WS-WEIGHT
             END-IF
         END-IF
     END-PERFORM
     IF WS-DONE = 1
         MOVE 1.0 TO L-RESULT
     ELSE
         COMPUTE L-RESULT = WS-SUM / WS-WEIGHT
     END-IF
     GOBACK.
 END PROGRAM FM-AVERAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-CORNERS.
*> USING the centre height, the heights of the north, south, east and west neighbours, then of the NE, NW, SE and SW diagonals (nine
*> FLOAT-LONG), NE, NW, SE, SW corner heights out (four FLOAT-LONG): corner heights of 10.2; a centre of 1 or more makes all four 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-H                    FLOAT-LONG.
 01 L-N                    FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-E                    FLOAT-LONG.
 01 L-W                    FLOAT-LONG.
 01 L-DNE                  FLOAT-LONG.
 01 L-DNW                  FLOAT-LONG.
 01 L-DSE                  FLOAT-LONG.
 01 L-DSW                  FLOAT-LONG.
 01 L-NE                   FLOAT-LONG.
 01 L-NW                   FLOAT-LONG.
 01 L-SE                   FLOAT-LONG.
 01 L-SW                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-H L-N L-S L-E L-W L-DNE L-DNW L-DSE L-DSW L-NE L-NW L-SE L-SW.
     IF L-H >= 1
         MOVE 1.0 TO L-NE L-NW L-SE L-SW
         GOBACK
     END-IF
     CALL "FM-AVERAGE" USING L-H L-N L-E L-DNE L-NE
     CALL "FM-AVERAGE" USING L-H L-N L-W L-DNW L-NW
     CALL "FM-AVERAGE" USING L-H L-S L-E L-DSE L-SE
     CALL "FM-AVERAGE" USING L-H L-S L-W L-DSW L-SW
     GOBACK.
 END PROGRAM FM-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-TOP-UV.
*> USING the flow vector x, z (FLOAT-LONG), still out (1 when the flow is zero, the whole still sprite), the four (u, v) fractions of the flowing
*> sprite out (eight FLOAT-LONG): the top face texture of 10.3: angle = atan2(z, x) - pi / 2, s = sin(angle) * 0.25, c = cos(angle) * 0.25 and
*> (0.5 - c - s, 0.5 - c + s), (0.5 - c + s, 0.5 + c + s), (0.5 + c + s, 0.5 + c - s), (0.5 + c - s, 0.5 - c - s).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-HALF-PI             FLOAT-LONG VALUE 1.5707963267948966.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STILL                BINARY-LONG.
 01 L-UV.
    05 L-U1                FLOAT-LONG.
    05 L-V1                FLOAT-LONG.
    05 L-U2                FLOAT-LONG.
    05 L-V2                FLOAT-LONG.
    05 L-U3                FLOAT-LONG.
    05 L-V3                FLOAT-LONG.
    05 L-U4                FLOAT-LONG.
    05 L-V4                FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-STILL L-UV.
     MOVE 0 TO L-STILL
     IF L-X = 0 AND L-Z = 0
         MOVE 1 TO L-STILL
         INITIALIZE L-UV
         GOBACK
     END-IF
     COMPUTE WS-ANGLE = FUNCTION ATAN(L-Z / L-X)
     IF L-X < 0
         IF L-Z < 0
             COMPUTE WS-ANGLE = WS-ANGLE - 3.141592653589793
         ELSE
             COMPUTE WS-ANGLE = WS-ANGLE + 3.141592653589793
         END-IF
     END-IF
     IF L-X = 0
         IF L-Z > 0
             MOVE WS-HALF-PI TO WS-ANGLE
         ELSE
             COMPUTE WS-ANGLE = 0 - WS-HALF-PI
         END-IF
     END-IF
     COMPUTE WS-ANGLE = WS-ANGLE - WS-HALF-PI
     COMPUTE WS-S = FUNCTION SIN(WS-ANGLE) * 0.25
     COMPUTE WS-C = FUNCTION COS(WS-ANGLE) * 0.25
     COMPUTE L-U1 = 0.5 - WS-C - WS-S
     COMPUTE L-V1 = 0.5 - WS-C + WS-S
     COMPUTE L-U2 = 0.5 - WS-C + WS-S
     COMPUTE L-V2 = 0.5 + WS-C + WS-S
     COMPUTE L-U3 = 0.5 + WS-C + WS-S
     COMPUTE L-V3 = 0.5 + WS-C - WS-S
     COMPUTE L-U4 = 0.5 + WS-C - WS-S
     COMPUTE L-V4 = 0.5 - WS-C - WS-S
     GOBACK.
 END PROGRAM FM-TOP-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-GEOMETRY.
*> USING the bottom face is drawn, a corner height, the side's two corner heights (FLOAT-LONG), top y out, side bottom out, side v range out
*> (v from, v to), 10.3: the top vertices sit 0.001 below the corner height, a side face runs from 0.001 (the bottom face is drawn) or 0 up to
*> its corner heights, and its v goes from (1 - corner height) * 0.5 down to 0.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOTTOM               BINARY-LONG.
 01 L-CORNER               FLOAT-LONG.
 01 L-TOP                  FLOAT-LONG.
 01 L-FLOOR                FLOAT-LONG.
 01 L-V-FROM               FLOAT-LONG.
 01 L-V-TO                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-BOTTOM L-CORNER L-TOP L-FLOOR L-V-FROM L-V-TO.
     COMPUTE L-TOP = L-CORNER - 0.001
     MOVE 0 TO L-FLOOR
     IF L-BOTTOM = 1
         MOVE 0.001 TO L-FLOOR
     END-IF
     COMPUTE L-V-FROM = (1 - L-CORNER) * 0.5
     MOVE 0.5 TO L-V-TO
     GOBACK.
 END PROGRAM FM-GEOMETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-BACKWARD-UP.
*> USING nine flags (3 x 3 horizontal neighbourhood of the cell above, row by row) each 1 when that cell is neither the same fluid nor a solid
*> render block (the nine BINARY-LONG in one group), draw out: shouldRenderBackwardUpFace (10.3): the second, reverse-winding top face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 9 TIMES.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-DRAW.
     MOVE 0 TO L-DRAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-CELL(WS-I) = 1
             MOVE 1 TO L-DRAW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FM-BACKWARD-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-SHADE.
*> USING face (0 top, 1 bottom, 2 north or south, 3 west or east), the cardinal factors up, down, north, west (FLOAT-LONG), the overlay sprite
*> replaces the flowing one (BINARY-LONG), brightness out (FLOAT-LONG), double sided out: the brightness of 10.4 (a side is the product of its
*> factor and up) and the sidedness of the side faces of 10.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-UP                   FLOAT-LONG.
 01 L-DOWN                 FLOAT-LONG.
 01 L-NORTH                FLOAT-LONG.
 01 L-WEST                 FLOAT-LONG.
 01 L-OVERLAY              BINARY-LONG.
 01 L-BRIGHTNESS           FLOAT-LONG.
 01 L-DOUBLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-UP L-DOWN L-NORTH L-WEST L-OVERLAY L-BRIGHTNESS L-DOUBLE.
     MOVE 1 TO L-DOUBLE
     IF L-OVERLAY = 1
         MOVE 0 TO L-DOUBLE
     END-IF
     EVALUATE L-FACE
         WHEN 0
             MOVE L-UP TO L-BRIGHTNESS
         WHEN 1
             MOVE L-DOWN TO L-BRIGHTNESS
         WHEN 2
             COMPUTE L-BRIGHTNESS = L-NORTH * L-UP
         WHEN OTHER
             COMPUTE L-BRIGHTNESS = L-WEST * L-UP
     END-EVALUATE
     GOBACK.
 END PROGRAM FM-SHADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-LIGHT.
*> USING sky light and block light of the cell, sky light and block light of the cell above (BINARY-LONG), sky out, block out: the light
*> coordinates of 10.4: the maximum per channel of the cell and the cell above.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY-A                BINARY-LONG.
 01 L-BLOCK-A              BINARY-LONG.
 01 L-SKY-B                BINARY-LONG.
 01 L-BLOCK-B              BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY-A L-BLOCK-A L-SKY-B L-BLOCK-B L-SKY L-BLOCK.
     COMPUTE L-SKY = FUNCTION MAX(L-SKY-A, L-SKY-B)
     COMPUTE L-BLOCK = FUNCTION MAX(L-BLOCK-A, L-BLOCK-B)
     GOBACK.
 END PROGRAM FM-LIGHT.
