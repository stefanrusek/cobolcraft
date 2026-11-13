*> Candles, candle cakes, cakes, soul sand, magma block and lightning rod of docs/protocol/29b part 7 (sections 9 and 10) as programs of plain numbers (GC7- prefix).
*> Candle kinds: 1 to 4 candles, 5 candle cake. Boxes are in pixels (x0 y0 z0 x1 y1 z1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-LIGHT.
*> USING lit, candles (1 to 4), light emission out (9.2): 3 per candle when lit.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-CANDLES              BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-CANDLES L-LIGHT.
     MOVE 0 TO L-LIGHT
     IF L-LIT = 1
         COMPUTE L-LIGHT = 3 * L-CANDLES
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-SHAPE.
*> USING candles (1 to 4), the box x0 y0 z0 x1 y1 z1 in pixels out (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CANDLES              BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CANDLES L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 0 TO L-Y0
     MOVE 6 TO L-Y1
     EVALUATE L-CANDLES
         WHEN 1
             MOVE 7 TO L-X0 L-Z0
             MOVE 9 TO L-X1 L-Z1
         WHEN 2
             MOVE 5 TO L-X0
             MOVE 6 TO L-Z0
             MOVE 11 TO L-X1
             MOVE 9 TO L-Z1
         WHEN 3
             MOVE 5 TO L-X0
             MOVE 6 TO L-Z0
             MOVE 10 TO L-X1
             MOVE 11 TO L-Z1
         WHEN OTHER
             MOVE 5 TO L-X0 L-Z0
             MOVE 11 TO L-X1
             MOVE 10 TO L-Z1
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CANDLE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-PLACE.
*> USING the clicked position holds the same candle block, its candles, the fluid is water, then the candles and waterlogged of the placed state out (9.2 Placement).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-CANDLES-IN           BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CANDLES              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-CANDLES-IN L-WATER L-CANDLES L-WATERLOGGED.
     MOVE 1 TO L-CANDLES
     MOVE L-WATER TO L-WATERLOGGED
     IF L-SAME = 1
         COMPUTE L-CANDLES = FUNCTION MOD(L-CANDLES-IN, 4) + 1
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-REPLACE.
*> USING secondary use, the held item is this block's item, candles, replaceable out (1; 0 leaves the default rule) (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SECONDARY            BINARY-LONG.
 01 L-HELD                 BINARY-LONG.
 01 L-CANDLES              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SECONDARY L-HELD L-CANDLES L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SECONDARY = 0 AND L-HELD = 1 AND L-CANDLES < 4
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-USE.
*> USING the hand is empty, abilities.mayBuild, lit, then the candle is extinguished, the result (1 success, 0 the base) out (9.2 useItemOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-MAY-BUILD            BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-EXTINGUISH           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-MAY-BUILD L-LIT L-EXTINGUISH L-RESULT.
     MOVE 0 TO L-EXTINGUISH L-RESULT
     IF L-EMPTY = 1 AND L-MAY-BUILD = 1 AND L-LIT = 1
         MOVE 1 TO L-EXTINGUISH L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-TEST.
*> USING the test (1 isLit, 2 canBeLit of AbstractCandleBlock, 3 canBeLit of CandleBlock, 4 static CandleBlock.canLight, 5 static CandleCakeBlock.canLight), the state is in the tag
*> (candles or candle_cakes), it has lit, it has waterlogged, lit, waterlogged, the answer out (9.1, 9.2, 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEST                 BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-HAS-LIT              BINARY-LONG.
 01 L-HAS-WATERLOGGED      BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEST L-TAG L-HAS-LIT L-HAS-WATERLOGGED L-LIT L-WATERLOGGED L-ANSWER.
     MOVE 0 TO L-ANSWER
     EVALUATE L-TEST
         WHEN 1
             IF L-HAS-LIT = 1 AND L-TAG = 1 AND L-LIT = 1
                 MOVE 1 TO L-ANSWER
             END-IF
         WHEN 2
             IF L-LIT = 0
                 MOVE 1 TO L-ANSWER
             END-IF
         WHEN 3
             IF L-WATERLOGGED = 0 AND L-LIT = 0
                 MOVE 1 TO L-ANSWER
             END-IF
         WHEN 4
             IF L-TAG = 1 AND L-HAS-LIT = 1 AND L-HAS-WATERLOGGED = 1 AND L-LIT = 0 AND L-WATERLOGGED = 0
                 MOVE 1 TO L-ANSWER
             END-IF
         WHEN 5
             IF L-TAG = 1 AND L-HAS-LIT = 1 AND L-LIT = 0
                 MOVE 1 TO L-ANSWER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CANDLE-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-LIQUID.
*> USING waterlogged, the fluid is water, lit, then placed, the action (1 extinguish, which writes the unlit state with flags 11, 2 setBlockAndUpdate), the new waterlogged,
*> a fluid tick is scheduled out (9.2 placeLiquid).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED-IN       BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED-IN L-WATER L-LIT L-PLACED L-ACTION L-WATERLOGGED L-TICK.
     MOVE 0 TO L-PLACED L-ACTION L-TICK
     MOVE L-WATERLOGGED-IN TO L-WATERLOGGED
     IF L-WATERLOGGED-IN = 0 AND L-WATER = 1
         MOVE 1 TO L-PLACED L-WATERLOGGED L-TICK
         MOVE 2 TO L-ACTION
         IF L-LIT = 1
             MOVE 1 TO L-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-LIQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-EXTINGUISH.
*> USING the kind (1 to 4 candles, 5 candle cake), then the smoke particles (one per particle offset), the setBlock flags, the smoke velocity y x 10 (0.1), the game event block_change out (9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-VELOCITY             BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PARTICLES L-FLAGS L-VELOCITY L-EVENT.
     MOVE L-KIND TO L-PARTICLES
     IF L-KIND = 5
         MOVE 1 TO L-PARTICLES
     END-IF
     MOVE 11 TO L-FLAGS
     MOVE 1 TO L-VELOCITY L-EVENT
     GOBACK.
 END PROGRAM GC7-CANDLE-EXTINGUISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-OFFSET.
*> USING the kind (1 to 4 candles, 5 candle cake), the index of the offset (1 to the particle count), the offset x y z in pixels out (9.2, 9.3; each is times 0.0625).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFFSETS.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 16.
    05 FILLER              BINARY-LONG VALUE 8.
 01 WS-OFFSET-T REDEFINES WS-OFFSETS.
    05 WS-OFFSET           BINARY-LONG OCCURS 33 TIMES.
 01 WS-FIRST.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 10.
 01 WS-FIRST-T REDEFINES WS-FIRST.
    05 WS-BASE             BINARY-LONG OCCURS 5 TIMES.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-INDEX L-X L-Y L-Z.
     COMPUTE WS-AT = (WS-BASE(L-KIND) + L-INDEX - 1) * 3
     MOVE WS-OFFSET(WS-AT + 1) TO L-X
     MOVE WS-OFFSET(WS-AT + 2) TO L-Y
     MOVE WS-OFFSET(WS-AT + 3) TO L-Z
     GOBACK.
 END PROGRAM GC7-CANDLE-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-EXPLOSION.
*> USING explosion.canTriggerBlocks, lit, then the candle is extinguished out (9.1 onExplosionHit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-EXTINGUISH           BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-LIT L-EXTINGUISH.
     MOVE 0 TO L-EXTINGUISH
     IF L-TRIGGER = 1 AND L-LIT = 1
         MOVE 1 TO L-EXTINGUISH
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-PROJECTILE.
*> USING server level, the projectile is on fire, canBeLit, then the candle is lit out (9.1 onProjectileHit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-FIRE L-CAN L-LIGHT.
     MOVE 0 TO L-LIGHT
     IF L-SERVER = 1 AND L-FIRE = 1 AND L-CAN = 1
         MOVE 1 TO L-LIGHT
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-PROJECTILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-ST.
*> USING waterlogged, a fluid tick is scheduled out (9.2 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-TICK.
     MOVE L-WATERLOGGED TO L-TICK
     GOBACK.
 END PROGRAM GC7-CANDLE-ST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-CLIENT.
*> USING the per-offset float f (FLOAT-LONG), then a smoke particle (f < 0.3), the candle_ambient sound (f < 0.17), the small_flame particle (always) out (9.1 animateTick).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SMOKE               FLOAT-LONG.
 01 WS-AMBIENT             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-SMOKE                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-FLAME                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-SMOKE L-SOUND L-FLAME.
     COMPUTE WS-SMOKE = 0.3
     COMPUTE WS-AMBIENT = 0.17
     CALL "FCMP-GT" USING WS-SMOKE L-DRAW L-SMOKE
     CALL "FCMP-GT" USING WS-AMBIENT L-DRAW L-SOUND
     MOVE 1 TO L-FLAME
     GOBACK.
 END PROGRAM GC7-CANDLE-CLIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CANDLE-SURVIVE.
*> USING the trigger (1 placement, 2 updateShape), canSupportCenter below, allowed out (9.2: no survive test in updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-SUPPORT              BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-SUPPORT L-ALLOWED.
     MOVE 1 TO L-ALLOWED
     IF L-TRIGGER = 1
         MOVE L-SUPPORT TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM GC7-CANDLE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CCAKE-USE.
*> USING the held (1 flint and steel or fire charge, 2 other item, 3 empty stack), the hit y over the block (FLOAT-LONG), lit, then the result (1 success, 2 the base, 3 pass),
*> the candle is extinguished out (9.3 useItemOn).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-HIT-Y                FLOAT-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-EXTINGUISH           BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-HIT-Y L-LIT L-RESULT L-EXTINGUISH.
     MOVE 0 TO L-EXTINGUISH
     MOVE 2 TO L-RESULT
     COMPUTE WS-HALF = 0.5
     CALL "FCMP-GT" USING L-HIT-Y WS-HALF WS-HIT
     EVALUATE TRUE
         WHEN L-ITEM = 1
             MOVE 3 TO L-RESULT
         WHEN WS-HIT = 1 AND L-ITEM = 3 AND L-LIT = 1
             MOVE 1 TO L-RESULT L-EXTINGUISH
     END-EVALUATE
     GOBACK.
 END PROGRAM GC7-CCAKE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CCAKE-EAT.
*> USING the player can eat, then the result (1 success, 0 pass), the candle item drops, the bites of the cake that replaces the block out (9.3 useWithoutItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-EAT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-BITES                BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-EAT L-RESULT L-DROP L-BITES.
     MOVE L-CAN-EAT TO L-RESULT L-DROP L-BITES
     GOBACK.
 END PROGRAM GC7-CCAKE-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-SHAPE.
*> USING bites (0 to 6), the box x0 y0 z0 x1 y1 z1 in pixels out (9.4): box(1 + 2 x bites, 0, 1, 15, 8, 15).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BITES                BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BITES L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     COMPUTE L-X0 = 1 + 2 * L-BITES
     MOVE 0 TO L-Y0
     MOVE 1 TO L-Z0
     MOVE 15 TO L-X1 L-Z1
     MOVE 8 TO L-Y1
     GOBACK.
 END PROGRAM GC7-CAKE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CCAKE-SHAPE.
*> USING the part (1 the candle column(2, 8, 14), 2 the cake body column(14, 0, 8)), the box x0 y0 z0 x1 y1 z1 in pixels out (9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PART L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     IF L-PART = 1
         MOVE 7 TO L-X0 L-Z0
         MOVE 8 TO L-Y0
         MOVE 9 TO L-X1 L-Z1
         MOVE 14 TO L-Y1
     ELSE
         MOVE 1 TO L-X0 L-Z0
         MOVE 0 TO L-Y0
         MOVE 15 TO L-X1 L-Z1
         MOVE 8 TO L-Y1
     END-IF
     GOBACK.
 END PROGRAM GC7-CCAKE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-SIGNAL.
*> USING the kind (1 cake, 2 candle cake), bites, the comparator output out (9.3, 9.4): (7 - bites) x 2 for a cake, 14 for a candle cake.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BITES                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BITES L-SIGNAL.
     MOVE 14 TO L-SIGNAL
     IF L-KIND = 1
         COMPUTE L-SIGNAL = (7 - L-BITES) * 2
     END-IF
     GOBACK.
 END PROGRAM GC7-CAKE-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-SUPPORT.
*> USING the block below is solid, the update comes from below, then canSurvive and air returned out (9.3, 9.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOLID                BINARY-LONG.
 01 L-DOWN                 BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SOLID L-DOWN L-SURVIVE L-AIR.
     MOVE L-SOLID TO L-SURVIVE
     MOVE 0 TO L-AIR
     IF L-DOWN = 1 AND L-SOLID = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GC7-CAKE-SUPPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-ADD-CANDLE.
*> USING the held item is in the tag candles, bites, Block.byItem is a CandleBlock, then one item consumed, cake_add_candle played, the unlit candle cake written, the game event block_change,
*> the item_used statistic, the result (1 success, 0 try with the empty hand) out (9.4 useItemOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-BITES                BINARY-LONG.
 01 L-CANDLE               BINARY-LONG.
 01 L-CONSUME              BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-BITES L-CANDLE L-CONSUME L-SOUND L-WRITE L-EVENT L-STAT L-RESULT.
     MOVE 0 TO L-CONSUME L-SOUND L-WRITE L-EVENT L-STAT L-RESULT
     IF L-TAG = 1 AND L-BITES = 0 AND L-CANDLE = 1
         MOVE 1 TO L-CONSUME L-SOUND L-WRITE L-EVENT L-STAT L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-CAKE-ADD-CANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-USE-EMPTY.
*> USING client level, the eat result consumes the action, the main hand is empty, the result out (1 success, 2 consume, 0 pass) (9.4 useWithoutItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-EAT                  BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-EAT L-EMPTY L-RESULT.
     MOVE L-EAT TO L-RESULT
     IF L-CLIENT = 1 AND L-EAT = 0 AND L-EMPTY = 1
         MOVE 2 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC7-CAKE-USE-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-CAKE-EAT.
*> USING the player can eat, bites, then the result (1 success, 0 pass), the food points, the saturation modifier x 100, the bites after, the block removed, the game event block_destroy out (9.4 eat).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-EAT              BINARY-LONG.
 01 L-BITES                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-FOOD                 BINARY-LONG.
 01 L-MODIFIER             BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-EAT L-BITES L-RESULT L-FOOD L-MODIFIER L-AFTER L-REMOVED L-EVENT.
     MOVE 0 TO L-RESULT L-FOOD L-REMOVED L-EVENT
     MOVE 10 TO L-MODIFIER
     MOVE L-BITES TO L-AFTER
     IF L-CAN-EAT = 1
         MOVE 1 TO L-RESULT
         MOVE 2 TO L-FOOD
         IF L-BITES < 6
             COMPUTE L-AFTER = L-BITES + 1
         ELSE
             MOVE 1 TO L-REMOVED L-EVENT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC7-CAKE-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-SOUL-SAND.
*> USING the selector (1 collision height in pixels, 2 outline height, 3 shade brightness x 10, 4 ticks, 5 updateShape or bubble column hooks), the value out (10.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 16.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC7-SOUL-SAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-MAGMA-STEP.
*> USING stepping carefully, the entity is a LivingEntity, the hot_floor damage x 10 out (10.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAREFUL              BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAREFUL L-LIVING L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     IF L-CAREFUL = 0 AND L-LIVING = 1
         MOVE 10 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GC7-MAGMA-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC7-ROD-DELTA.
*> USING the fluid is water, the clicked face, then the facing, waterlogged, a water fluid tick is scheduled out (10.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-FACE L-FACING L-WATERLOGGED L-TICK.
     MOVE L-FACE TO L-FACING
     MOVE L-WATER TO L-WATERLOGGED L-TICK
     GOBACK.
 END PROGRAM GC7-ROD-DELTA.
