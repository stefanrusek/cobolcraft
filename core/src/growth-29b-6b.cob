*> Speleothems (docs/protocol/29b part 6, sections 4 and 5) as programs of plain numbers (GC6- prefix): the shared model of pointed_dripstone and sulfur_spike (the predicates,
*> placement, survival, shape update and thickness) and their growth. Helpers like those of growth-29b-6.cob. Tip directions: 1 down, 2 up. Thickness codes: 1 tip_merge, 2 tip,
*> 3 frustum, 4 middle, 5 base. A block kind is 1 pointed_dripstone, 2 sulfur_spike.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-CONST.
*> USING the selector (1 to 10) (BINARY-LONG), the value out (4.1): 1 DELAY_BEFORE_FALLING, 2 MIN_TRIDENT_VELOCITY_TO_BREAK_SPELEOTHEM x 100, 3 STALACTITE_DAMAGE_PER_FALL_DISTANCE_AND_SIZE
*> x 100, 4 STALACTITE_MAX_DAMAGE, 5 MAX_STALACTITE_HEIGHT_FOR_DAMAGE_CALCULATION, 6 GROWTH_PROBABILITY_PER_RANDOM_TICK x 1e9, 7 MAX_GROWTH_LENGTH, 8 MAX_STALAGMITE_SEARCH_RANGE_WHEN_GROWING,
*> 9 AVERAGE_DAYS_PER_GROWTH, 10 the sulfur spike MAX_GROWING_LENGTH (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 60.
    05 FILLER              BINARY-LONG VALUE 100.
    05 FILLER              BINARY-LONG VALUE 40.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 11377778.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 10 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC6-SPEL-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-STATE.
*> USING the state is in tag speleothems, its tip direction, its thickness, waterlogged, includeMerged (BINARY-LONG), isStalactite, isStalagmite, isTip, isFreeHangingStalactite out (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-THICK                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-MERGED               BINARY-LONG.
 01 L-STALACTITE           BINARY-LONG.
 01 L-STALAGMITE           BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-DIR L-THICK L-WATERLOGGED L-MERGED L-STALACTITE L-STALAGMITE L-TIP L-FREE.
     MOVE 0 TO L-STALACTITE L-STALAGMITE L-TIP L-FREE
     IF L-TAG = 1 AND L-DIR = 1
         MOVE 1 TO L-STALACTITE
     END-IF
     IF L-TAG = 1 AND L-DIR = 2
         MOVE 1 TO L-STALAGMITE
     END-IF
     IF L-TAG = 1 AND (L-THICK = 2 OR (L-MERGED = 1 AND L-THICK = 1))
         MOVE 1 TO L-TIP
     END-IF
     IF L-STALACTITE = 1 AND L-THICK = 2 AND L-WATERLOGGED = 0
         MOVE 1 TO L-FREE
     END-IF
     GOBACK.
 END PROGRAM GC6-SPEL-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-VALID.
*> USING the support is sturdy on its face toward the tip, the support is a speleothem of this block with that direction (BINARY-LONG), valid out (4.2 isValidSpeleothemPlacement; 4.4
*> canSurvive is the same test toward the state's tip direction).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-SPELEOTHEM           BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-SPELEOTHEM L-VALID.
     MOVE 0 TO L-VALID
     IF L-STURDY = 1 OR L-SPELEOTHEM = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC6-SPEL-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-TIPDIR.
*> USING T (1 down, 2 up), the placement toward T is valid, the placement toward the opposite is valid (BINARY-LONG), the tip direction out (0 for null) (4.2 calculateTipDirection).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-VALID-T              BINARY-LONG.
 01 L-VALID-O              BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-VALID-T L-VALID-O L-DIR.
     MOVE 0 TO L-DIR
     IF L-VALID-T = 1
         MOVE L-T TO L-DIR
     END-IF
     IF L-VALID-T = 0 AND L-VALID-O = 1
         COMPUTE L-DIR = 3 - L-T
     END-IF
     GOBACK.
 END PROGRAM GC6-SPEL-TIPDIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-STARTPOS.
*> USING the state is a stalactite, the block above is the same block (BINARY-LONG), start out (4.2 isStalactiteStartPos): the topmost piece of a stalactite.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STALACTITE           BINARY-LONG.
 01 L-SAME-ABOVE           BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-STALACTITE L-SAME-ABOVE L-START.
     MOVE 0 TO L-START
     IF L-STALACTITE = 1 AND L-SAME-ABOVE = 0
         MOVE 1 TO L-START
     END-IF
     GOBACK.
 END PROGRAM GC6-SPEL-STARTPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FIND-VERT.
*> USING maxIter, the cells met in order from the start (BINARY-LONG x 12: 1 the stop test holds, 2 pass holds, 0 neither or outside the build height), the index of the cell
*> where the search stops (0 for none) out (4.2 findBlockVertical): only maxIter - 1 cells are examined.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 12 TIMES.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-CELLS L-INDEX.
     MOVE 0 TO L-INDEX WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= L-MAX OR WS-DONE = 1
         IF L-CELL(WS-I) = 1
             MOVE WS-I TO L-INDEX
         END-IF
         IF L-CELL(WS-I) NOT = 2
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC6-FIND-VERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-FIND-TIP.
*> USING the state is a tip (merged ones counted as asked), maxIter, the cells below as GC6-FIND-VERT (BINARY-LONG x 12: 1 a tip, 2 the same block with the same tip direction
*> that is not a tip, 0 neither), found, the offset (0 the position itself) out (4.2 findTip).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIP                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 12 TIMES.
 01 L-FOUND                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-TIP L-MAX L-CELLS L-FOUND L-OFFSET.
     MOVE 0 TO L-FOUND L-OFFSET
     IF L-TIP = 1
         MOVE 1 TO L-FOUND
     ELSE
         CALL "GC6-FIND-VERT" USING L-MAX L-CELLS L-OFFSET
         IF L-OFFSET > 0
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-FIND-TIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-DRIP-THROUGH.
*> USING the state is air, it is a full opaque cube, it has a non-empty fluid, its collision shape meets the column Block.column(4, 0, 16) (BINARY-LONG), canDripThrough out (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-INTERSECTS           BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-SOLID L-FLUID L-INTERSECTS L-CAN.
     MOVE 0 TO L-CAN
     EVALUATE TRUE
         WHEN L-AIR = 1
             MOVE 1 TO L-CAN
         WHEN L-SOLID = 1 OR L-FLUID = 1
             CONTINUE
         WHEN L-INTERSECTS = 0
             MOVE 1 TO L-CAN
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-DRIP-THROUGH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-PLACE.
*> USING the view pitch (FLOAT-LONG), the placement toward D is valid, the placement toward the opposite is valid, the player is sneaking, the fluid at the clicked position is water
*> (BINARY-LONG), placed, tip direction, merge, waterlogged out (4.3): D is the opposite of the vertical look direction, which is up when the pitch is below 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PITCH                FLOAT-LONG.
 01 L-VALID-D              BINARY-LONG.
 01 L-VALID-O              BINARY-LONG.
 01 L-SNEAK                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-MERGE                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-PITCH L-VALID-D L-VALID-O L-SNEAK L-WATER L-PLACED L-T L-MERGE L-WATERLOGGED.
     MOVE 2 TO WS-D
     IF L-PITCH < 0
         MOVE 1 TO WS-D
     END-IF
     MOVE 0 TO L-PLACED L-MERGE L-WATERLOGGED
     CALL "GC6-SPEL-TIPDIR" USING WS-D L-VALID-D L-VALID-O L-T
     IF L-T > 0
         MOVE 1 TO L-PLACED
         MOVE L-WATER TO L-WATERLOGGED
         IF L-SNEAK = 0
             MOVE 1 TO L-MERGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-SPEL-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-SU.
*> USING waterlogged, the update direction (1 down, 2 up, 3 horizontal), the tip direction (1 down, 2 up), a block tick is already scheduled, the state can survive (BINARY-LONG),
*> a water tick is scheduled, the action (0 state returned, 1 a block tick is scheduled and the state returned, 2 the thickness is recomputed), the tick delay out (4.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPPOSITE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-WATER-TICK           BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-DIR L-T L-SCHEDULED L-SURVIVES L-WATER-TICK L-ACTION L-DELAY.
     MOVE L-WATERLOGGED TO L-WATER-TICK
     MOVE 0 TO L-ACTION L-DELAY
     COMPUTE WS-OPPOSITE = 3 - L-T
     EVALUATE TRUE
         WHEN L-DIR = 3
             CONTINUE
         WHEN L-T = 1 AND L-SCHEDULED = 1
             CONTINUE
         WHEN L-DIR = WS-OPPOSITE AND L-SURVIVES = 0
             MOVE 1 TO L-ACTION
             MOVE 2 TO L-DELAY
             IF L-T = 2
                 MOVE 1 TO L-DELAY
             END-IF
         WHEN OTHER
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-SPEL-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SPEL-THICK.
*> USING an opposing tip of this block is at pos + T, merge, that tip is tip_merge, the state at pos + T is a speleothem with direction T, its thickness is tip or tip_merge, the state at
*> pos + opposite is a speleothem with direction T (BINARY-LONG), the thickness out (4.5): the first rule that holds.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPPOSING             BINARY-LONG.
 01 L-MERGE                BINARY-LONG.
 01 L-N-MERGED             BINARY-LONG.
 01 L-N-SPEL               BINARY-LONG.
 01 L-N-TIP                BINARY-LONG.
 01 L-BEHIND               BINARY-LONG.
 01 L-THICK                BINARY-LONG.
 PROCEDURE DIVISION USING L-OPPOSING L-MERGE L-N-MERGED L-N-SPEL L-N-TIP L-BEHIND L-THICK.
     EVALUATE TRUE
         WHEN L-OPPOSING = 1 AND (L-MERGE = 1 OR L-N-MERGED = 1)
             MOVE 1 TO L-THICK
         WHEN L-OPPOSING = 1
             MOVE 2 TO L-THICK
         WHEN L-N-SPEL = 0
             MOVE 2 TO L-THICK
         WHEN L-N-TIP = 1
             MOVE 3 TO L-THICK
         WHEN L-BEHIND = 0
             MOVE 5 TO L-THICK
         WHEN OTHER
             MOVE 4 TO L-THICK
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-SPEL-THICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-GROW-RATE.
*> USING the growth probability per random tick x 1e9 out (5.1): 1 / (5 x 24000 x 3 / 4096).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RATE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RATE.
     COMPUTE L-RATE ROUNDED = 1000000000 * 4096 / (5 * 24000 * 3)
     GOBACK.
 END PROGRAM GC6-GROW-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-GROW-TICK.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike), the draw nextFloat() of the growth gate (FLOAT-LONG), the state is a stalactite start position (BINARY-LONG), proceeds,
*> the nextFloat draws made out (5.1): the pointed dripstone draws first for the fluid transfer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GATE                FLOAT-LONG VALUE 0.011377778.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-START                BINARY-LONG.
 01 L-PROCEEDS             BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DRAW L-START L-PROCEEDS L-DRAWS.
     MOVE 0 TO L-PROCEEDS
     MOVE 1 TO L-DRAWS
     IF L-KIND = 1
         MOVE 2 TO L-DRAWS
     END-IF
     IF L-DRAW < WS-GATE AND L-START = 1
         MOVE 1 TO L-PROCEEDS
     END-IF
     GOBACK.
 END PROGRAM GC6-GROW-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CAN-GROW.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike), the block above is blockToGrowOn, a water source is two above (BINARY-LONG), canGrow out (5.2 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ABOVE L-WATER L-CAN.
     MOVE L-ABOVE TO L-CAN
     IF L-KIND = 1 AND L-WATER = 0
         MOVE 0 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC6-CAN-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-MAX-LEN.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike) (BINARY-LONG), getMaxGrowthLength, the piece cap (a stalactite stops at that length plus one piece) out (5.2 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-CAP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-LENGTH L-CAP.
     MOVE 7 TO L-LENGTH
     IF L-KIND = 2
         MOVE 2 TO L-LENGTH
     END-IF
     COMPUTE L-CAP = L-LENGTH + 1
     GOBACK.
 END PROGRAM GC6-MAX-LEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-TIP-GROW.
*> USING the cell below the tip has a non-empty fluid, it is air, it is an unmerged tip of this block pointing up (BINARY-LONG), canTipGrow out (5.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-AIR L-TIP L-CAN.
     MOVE L-TIP TO L-CAN
     IF L-AIR = 1
         MOVE 1 TO L-CAN
     END-IF
     IF L-FLUID = 1
         MOVE 0 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC6-TIP-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-GROW-CHOICE.
*> USING the tip is a free-hanging stalactite, canTipGrow, the draw nextBoolean (BINARY-LONG), the action (0 stop, 1 grow(DOWN), 2 growStalagmiteBelow), the draws made out (5.2 steps 3, 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FREE                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-BOOLEAN              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FREE L-CAN L-BOOLEAN L-ACTION L-DRAWS.
     MOVE 0 TO L-ACTION L-DRAWS
     IF L-FREE = 1 AND L-CAN = 1
         MOVE 1 TO L-DRAWS
         MOVE 2 TO L-ACTION
         IF L-BOOLEAN = 1
             MOVE 1 TO L-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-GROW-CHOICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-STALAGMITE-SCAN.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike), 10 cells downward from the tip with six flags each (BINARY-LONG x 60: the state has a fluid, it is an unmerged tip
*> pointing up, canTipGrow for it, isValidSpeleothemPlacement toward up, the cell below is water, blocksStalagmiteScan holds for a pointed dripstone: not canDripThrough), the action
*> (0 nothing, 1 grow an existing tip, 2 write a new tip at the cell), the cell index out (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FLAGS.
    05 L-FLAG              BINARY-LONG OCCURS 60 TIMES.
 01 L-ACTION               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FLAGS L-ACTION L-INDEX.
     MOVE 0 TO L-ACTION L-INDEX WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR WS-DONE = 1
         COMPUTE WS-B = (WS-I - 1) * 6
         EVALUATE TRUE
             WHEN L-FLAG(WS-B + 1) = 1
                 MOVE 1 TO WS-DONE
             WHEN L-FLAG(WS-B + 2) = 1 AND L-FLAG(WS-B + 3) = 1
                 MOVE 1 TO WS-DONE
                 MOVE 1 TO L-ACTION
                 MOVE WS-I TO L-INDEX
             WHEN L-FLAG(WS-B + 4) = 1 AND L-FLAG(WS-B + 5) = 0
                 MOVE 1 TO WS-DONE
                 MOVE 2 TO L-ACTION
                 MOVE WS-I TO L-INDEX
             WHEN L-KIND = 1 AND L-FLAG(WS-B + 6) = 1
                 MOVE 1 TO WS-DONE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM GC6-STALAGMITE-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-GROW-TARGET.
*> USING the target is an opposing unmerged tip of this block, it is air, it is a water block (BINARY-LONG), the action out (5.4 grow): 1 merge the tips, 2 create a tip, else 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPPOSING             BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-OPPOSING L-AIR L-WATER L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE TRUE
         WHEN L-OPPOSING = 1
             MOVE 1 TO L-ACTION
         WHEN L-AIR = 1 OR L-WATER = 1
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-GROW-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CREATE.
*> USING the fluid at the position is water (BINARY-LONG), waterlogged, the setBlockAndUpdate flags out (5.4 createSpeleothem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-WATERLOGGED L-FLAGS.
     MOVE L-WATER TO L-WATERLOGGED
     MOVE 3 TO L-FLAGS
     GOBACK.
 END PROGRAM GC6-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-MERGE-TIPS.
*> USING the tip direction of the existing tip (1 down, 2 up) (BINARY-LONG), the y offset of the upper piece, of the lower piece (relative to its position), the thickness (tip_merge,
*> 1), the piece written first (1 the upper) out (5.4 createMergedTips).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-UPPER                BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-THICK                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-UPPER L-LOWER L-THICK L-FIRST.
     MOVE 0 TO L-UPPER L-LOWER
     MOVE 1 TO L-THICK L-FIRST
     IF L-DIR = 2
         MOVE 1 TO L-UPPER
     ELSE
         MOVE -1 TO L-LOWER
     END-IF
     GOBACK.
 END PROGRAM GC6-MERGE-TIPS.
