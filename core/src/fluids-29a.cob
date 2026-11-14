*> Fluids (docs/protocol/29a sections 1 and 2) as programs of plain numbers: the fluid states and their legacy liquid blocks, heights,
*> the flow vector, the tick delays and the fluid tick step with its search for a slope. A fluid state is (kind, amount, falling): kind
*> 0 empty, 1 flowing water, 2 water, 3 flowing lava, 4 lava (the registry order of 1.1). What lives in the world (neighbour fluids,
*> collision shapes, tags) is passed in as flags by the caller; single-precision values are rounded with cc_f64_f32_round.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SAME.
*> USING kind a, kind b (BINARY-LONG), result out: isSame: water with flowing water, lava with flowing lava, nothing else.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SAME.
     MOVE 0 TO L-SAME
     IF (L-A = 1 OR L-A = 2) AND (L-B = 1 OR L-B = 2)
         MOVE 1 TO L-SAME
     END-IF
     IF (L-A = 3 OR L-A = 4) AND (L-B = 3 OR L-B = 4)
         MOVE 1 TO L-SAME
     END-IF
     GOBACK.
 END PROGRAM FL-SAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-FROM-LEVEL.
*> USING fluid (1 water, 2 lava), block level 0 to 15 (BINARY-LONG), kind out, amount out, falling out: LiquidBlock.getFluidState
*> (1.2): index min(level, 8); 0 the source, 1 to 7 flowing with amount 8 - index, 8 flowing amount 8 falling.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-LEVEL L-KIND L-AMOUNT L-FALLING.
     COMPUTE WS-INDEX = FUNCTION MIN(L-LEVEL, 8)
     MOVE 0 TO L-FALLING
     EVALUATE TRUE
         WHEN WS-INDEX = 0
             COMPUTE L-KIND = L-FLUID * 2
             MOVE 8 TO L-AMOUNT
         WHEN WS-INDEX = 8
             COMPUTE L-KIND = L-FLUID * 2 - 1
             MOVE 8 TO L-AMOUNT
             MOVE 1 TO L-FALLING
         WHEN OTHER
             COMPUTE L-KIND = L-FLUID * 2 - 1
             COMPUTE L-AMOUNT = 8 - WS-INDEX
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-FROM-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LEGACY.
*> USING kind, amount, falling (BINARY-LONG), level out: createLegacyBlock (1.2): a source is level 0, a flowing state
*> (8 - min(amount, 8)) + 8 when falling; the empty fluid is air (-1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AMOUNT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-AMOUNT L-FALLING L-LEVEL.
     COMPUTE WS-AMOUNT = FUNCTION MIN(L-AMOUNT, 8)
     EVALUATE TRUE
         WHEN L-KIND = 0
             MOVE -1 TO L-LEVEL
         WHEN L-KIND = 2 OR L-KIND = 4
             MOVE 0 TO L-LEVEL
         WHEN OTHER
             COMPUTE L-LEVEL = 8 - WS-AMOUNT + 8 * L-FALLING
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-LEGACY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-BLOCK-ID.
*> USING fluid (1 water, 2 lava), block level (BINARY-LONG), block state id out: water is state ids 89 to 104, lava 105 to 120.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-LEVEL L-ID.
     COMPUTE L-ID = 73 + 16 * L-FLUID + L-LEVEL
     GOBACK.
 END PROGRAM FL-BLOCK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-OWN-HEIGHT.
*> USING amount (BINARY-LONG), height out (FLOAT-LONG): getOwnHeight (1.3): amount / 9 in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-A                   FLOAT-LONG.
 01 WS-NINE                FLOAT-LONG VALUE 9.0.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-HEIGHT.
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE L-AMOUNT WS-A
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-NINE WS-Q
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-Q L-HEIGHT
     GOBACK.
 END PROGRAM FL-OWN-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-HEIGHT.
*> USING amount, same fluid above (BINARY-LONG), height out (FLOAT-LONG): getHeight (1.3): 1.0 under the same fluid, else the own height.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-ABOVE L-HEIGHT.
     IF L-ABOVE = 1
         MOVE 1.0 TO L-HEIGHT
     ELSE
         CALL "FL-OWN-HEIGHT" USING L-AMOUNT L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM FL-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-CAMERA.
*> USING is a source, the block above has a sturdy DOWN face, amount, same fluid above (BINARY-LONG), height out (FLOAT-LONG):
*> getHeightForCamera (1.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-STURDY L-AMOUNT L-ABOVE L-HEIGHT.
     IF L-SOURCE = 1 AND L-STURDY = 1
         MOVE 1.0 TO L-HEIGHT
     ELSE
         CALL "FL-HEIGHT" USING L-AMOUNT L-ABOVE L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM FL-CAMERA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-FLOW-DELTA.
*> USING neighbour fluid is empty or the same (BINARY-LONG), its own height (FLOAT-LONG), block at the neighbour is in blocks_fluid_flow,
*> the fluid below the neighbour is empty or the same (BINARY-LONG), its own height, this state's own height (FLOAT-LONG), delta out
*> (FLOAT-LONG): steps 1.1 to 1.4 of getFlow (1.4) in single precision. An empty neighbour that does not block flow counts the drop to
*> the fluid below it (0.8888889 is the source height).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-H                   FLOAT-LONG.
 01 WS-BH                  FLOAT-LONG.
 01 WS-OWN                 FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-AFFECTS              BINARY-LONG.
 01 L-H                    FLOAT-LONG.
 01 L-BLOCKS               BINARY-LONG.
 01 L-BAFFECTS             BINARY-LONG.
 01 L-BH                   FLOAT-LONG.
 01 L-OWN                  FLOAT-LONG.
 01 L-DELTA                FLOAT-LONG.
 PROCEDURE DIVISION USING L-AFFECTS L-H L-BLOCKS L-BAFFECTS L-BH L-OWN L-DELTA.
     MOVE 0 TO L-DELTA
     IF L-AFFECTS = 0
         GOBACK
     END-IF
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-H WS-H
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-BH WS-BH
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-OWN WS-OWN
     EVALUATE TRUE
         WHEN WS-H > 0
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-OWN WS-H WS-T
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-DELTA
         WHEN L-BLOCKS = 0 AND L-BAFFECTS = 1 AND WS-BH > 0
             MOVE 0.8888889 TO WS-K
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-K WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-BH WS-T WS-U
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-U WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-OWN WS-T WS-U
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-U L-DELTA
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-FLOW-DELTA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-NORMALIZE.
*> USING x, y, z (FLOAT-LONG, in and out): Vec3.normalize: divided by the length; the zero vector stays zero.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-XX                  FLOAT-LONG.
 01 WS-YY                  FLOAT-LONG.
 01 WS-ZZ                  FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     MOVE L-X TO WS-QX
     MOVE L-Y TO WS-QY
     MOVE L-Z TO WS-QZ
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-X WS-QX WS-XX
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Y WS-QY WS-YY
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Z WS-QZ WS-ZZ
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-XX WS-YY WS-S1
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S1 WS-ZZ WS-S2
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-S2 WS-LEN
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-LEN WS-BITS
     IF WS-BITS NOT = 0
         CALL STATIC "cc_f64_div" USING BY REFERENCE L-X WS-LEN WS-QX
         CALL STATIC "cc_f64_div" USING BY REFERENCE L-Y WS-LEN WS-QY
         CALL STATIC "cc_f64_div" USING BY REFERENCE L-Z WS-LEN WS-QZ
         MOVE WS-QX TO L-X
         MOVE WS-QY TO L-Y
         MOVE WS-QZ TO L-Z
     END-IF
     GOBACK.
 END PROGRAM FL-NORMALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-FLOW.
*> USING sum x, sum z (FLOAT-LONG), falling, solid face beside the column or above it (BINARY-LONG), flow x, y, z out (FLOAT-LONG):
*> the end of getFlow (1.4 steps 2 to 4): (sum x, 0, sum z); a falling state next to a solid face normalises it and adds (0, -6, 0);
*> the result is normalised.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SX                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-SX L-SZ L-FALLING L-SOLID L-X L-Y L-Z.
     MOVE L-SX TO L-X
     MOVE 0 TO L-Y
     MOVE L-SZ TO L-Z
     IF L-FALLING = 1 AND L-SOLID = 1
         CALL "FL-NORMALIZE" USING L-X L-Y L-Z
         COMPUTE L-Y = L-Y - 6
     END-IF
     CALL "FL-NORMALIZE" USING L-X L-Y L-Z
     GOBACK.
 END PROGRAM FL-FLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SOLID-FACE.
*> USING same fluid at the position, direction is UP, the block is ice, the face is sturdy (BINARY-LONG), result out: isSolidFace (1.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-ICE                  BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-UP L-ICE L-STURDY L-OUT.
     EVALUATE TRUE
         WHEN L-SAME = 1
             MOVE 0 TO L-OUT
         WHEN L-UP = 1
             MOVE 1 TO L-OUT
         WHEN L-ICE = 1
             MOVE 0 TO L-OUT
         WHEN OTHER
             MOVE L-STURDY TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-SOLID-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-DELAY.
*> USING fluid (1 water, 2 lava), fast_lava (BINARY-LONG), tick delay out, slope find distance out, drop-off out: 2.1 table.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-FIND                 BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-FAST L-DELAY L-FIND L-DROP.
     EVALUATE TRUE
         WHEN L-FLUID = 1
             MOVE 5 TO L-DELAY
             MOVE 4 TO L-FIND
             MOVE 1 TO L-DROP
         WHEN L-FAST = 1
             MOVE 10 TO L-DELAY
             MOVE 4 TO L-FIND
             MOVE 1 TO L-DROP
         WHEN OTHER
             MOVE 30 TO L-DELAY
             MOVE 2 TO L-FIND
             MOVE 2 TO L-DROP
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SPREAD-DELAY.
*> USING fluid, fast_lava, both states non-empty, neither falling, the new height is greater, nextInt(4) draw (BINARY-LONG), delay
*> out: getSpreadDelay (2.1): the tick delay, times 4 for lava on 3 draws in 4 when it grows taller.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIND                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-BOTH                 BINARY-LONG.
 01 L-STILL                BINARY-LONG.
 01 L-TALLER               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-FAST L-BOTH L-STILL L-TALLER L-DRAW L-DELAY.
     CALL "FL-DELAY" USING L-FLUID L-FAST L-DELAY WS-FIND WS-DROP
     IF L-FLUID = 2 AND L-BOTH = 1 AND L-STILL = 1 AND L-TALLER = 1 AND L-DRAW NOT = 0
         COMPUTE L-DELAY = L-DELAY * 4
     END-IF
     GOBACK.
 END PROGRAM FL-SPREAD-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-TICK-DECIDE.
*> USING the state is a source, the new state is empty, the new state equals the old (BINARY-LONG), action out: FlowingFluid.tick
*> (2.2). 0 a source skips step 1, 1 set air, 2 write the new state and schedule, 3 unchanged; spread (2.4) follows in every case.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-EMPTY L-SAME L-ACTION.
     EVALUATE TRUE
         WHEN L-SOURCE = 1
             MOVE 0 TO L-ACTION
         WHEN L-EMPTY = 1
             MOVE 1 TO L-ACTION
         WHEN L-SAME = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-TICK-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-NEW-LIQUID.
*> USING highest amount of the passable same-fluid neighbours, number of passable source neighbours, source conversion rule, the block
*> below is solid, the fluid below is a source of this fluid, the same fluid passes in from above, drop-off (BINARY-LONG), code out
*> (0 empty, 1 source, 2 flowing), amount out, falling out: getNewLiquid (2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-SOURCES              BINARY-LONG.
 01 L-CONVERT              BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-BELOW-SOURCE         BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-SOURCES L-CONVERT L-SOLID L-BELOW-SOURCE L-ABOVE L-DROP L-CODE L-AMOUNT L-FALLING.
     MOVE 0 TO L-CODE L-AMOUNT L-FALLING
     EVALUATE TRUE
         WHEN L-SOURCES >= 2 AND L-CONVERT = 1 AND (L-SOLID = 1 OR L-BELOW-SOURCE = 1)
             MOVE 1 TO L-CODE
             MOVE 8 TO L-AMOUNT
         WHEN L-ABOVE = 1
             MOVE 2 TO L-CODE
             MOVE 8 TO L-AMOUNT
             MOVE 1 TO L-FALLING
         WHEN L-MAX - L-DROP > 0
             MOVE 2 TO L-CODE
             COMPUTE L-AMOUNT = L-MAX - L-DROP
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-NEW-LIQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SPREAD-DECIDE.
*> USING canMaybePassThrough down, the cell below can be replaced by the new fluid, it can hold it, number of horizontal source
*> neighbours, this state is a source, this cell is a water hole (BINARY-LONG), action out: spread (2.4). 1 spread down only, 2 down
*> and to the sides (3 or more source neighbours), 3 to the sides, 0 nothing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAY                  BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 01 L-HOLD                 BINARY-LONG.
 01 L-SOURCES              BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-HOLE                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-MAY L-REPLACE L-HOLD L-SOURCES L-SOURCE L-HOLE L-ACTION.
     EVALUATE TRUE
         WHEN L-MAY = 1 AND L-REPLACE = 1 AND L-HOLD = 1 AND L-SOURCES >= 3
             MOVE 2 TO L-ACTION
         WHEN L-MAY = 1 AND L-REPLACE = 1 AND L-HOLD = 1
             MOVE 1 TO L-ACTION
         WHEN L-SOURCE = 1 OR L-HOLE = 0
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 0 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-SPREAD-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SIDES.
*> USING amount, falling, drop-off (BINARY-LONG), amount out, go out: spreadToSides step 1 (2.5): amount minus the drop-off, 7 when
*> falling; nothing when it is not above 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-GO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AMOUNT L-FALLING L-DROP L-OUT L-GO.
     COMPUTE L-OUT = L-AMOUNT - L-DROP
     IF L-FALLING = 1
         MOVE 7 TO L-OUT
     END-IF
     MOVE 0 TO L-GO
     IF L-OUT > 0
         MOVE 1 TO L-GO
     END-IF
     GOBACK.
 END PROGRAM FL-SIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-IS-HOLE.
*> USING can pass the wall below, the fluid below is the same fluid, the cell below can hold the flowing fluid (BINARY-LONG), hole
*> out: isWaterHole (2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASS                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-HOLD                 BINARY-LONG.
 01 L-HOLE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PASS L-SAME L-HOLD L-HOLE.
     MOVE 0 TO L-HOLE
     IF L-PASS = 1 AND (L-SAME = 1 OR L-HOLD = 1)
         MOVE 1 TO L-HOLE
     END-IF
     GOBACK.
 END PROGRAM FL-IS-HOLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SPREAD-MAP.
*> USING inputs (twelve BINARY-LONG: the distance of each of four horizontal directions, then four valid flags, then four
*> replaceable flags), result out (four BINARY-LONG: 1 when the direction is in the map): the map of getSpread (2.5): a better
*> distance clears the map; a direction at least as good is added when valid and replaceable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-DIST              BINARY-LONG OCCURS 4 TIMES.
    05 L-VALID             BINARY-LONG OCCURS 4 TIMES.
    05 L-REPL              BINARY-LONG OCCURS 4 TIMES.
 01 L-OUT.
    05 L-MAPPED            BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1000 TO WS-MIN
     MOVE 0 TO L-MAPPED(1) L-MAPPED(2) L-MAPPED(3) L-MAPPED(4)
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         IF L-VALID(WS-D) = 1
             IF L-DIST(WS-D) < WS-MIN
                 MOVE 0 TO L-MAPPED(1) L-MAPPED(2) L-MAPPED(3) L-MAPPED(4)
             END-IF
             IF L-DIST(WS-D) <= WS-MIN
                 IF L-REPL(WS-D) = 1
                     MOVE 1 TO L-MAPPED(WS-D)
                 END-IF
                 MOVE L-DIST(WS-D) TO WS-MIN
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FL-SPREAD-MAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SLOPE RECURSIVE.
*> USING grid (PIC X(81), 9 by 9 cells row by row: "#" blocked, "." open, "H" a hole), x, z (0 to 8), dist, from (the direction not to
*> go back through, 0 north, 1 east, 2 south, 3 west, -1 none), find distance (BINARY-LONG), result out: getSlopeDistance (2.5) over a
*> grid; outside the grid is blocked. The first hole of a call returns its dist; otherwise the best of the deeper searches, 1000.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-DIST                BINARY-LONG.
 01 LS-FROM                BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-AT                  BINARY-LONG.
 01 LS-CELL                PIC X.
 01 LS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-GRID                 PIC X(81).
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-FIND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-GRID L-X L-Z L-DIST L-FROM L-FIND L-RESULT.
     MOVE 1000 TO L-RESULT
     MOVE 0 TO LS-DONE
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 3 OR LS-DONE = 1
         IF LS-D NOT = L-FROM
             MOVE L-X TO LS-NX
             MOVE L-Z TO LS-NZ
             EVALUATE LS-D
                 WHEN 0
                     SUBTRACT 1 FROM LS-NZ
                 WHEN 1
                     ADD 1 TO LS-NX
                 WHEN 2
                     ADD 1 TO LS-NZ
                 WHEN OTHER
                     SUBTRACT 1 FROM LS-NX
             END-EVALUATE
             MOVE "#" TO LS-CELL
             IF LS-NX >= 0 AND LS-NX <= 8 AND LS-NZ >= 0 AND LS-NZ <= 8
                 COMPUTE LS-AT = LS-NZ * 9 + LS-NX + 1
                 MOVE L-GRID(LS-AT:1) TO LS-CELL
             END-IF
             EVALUATE TRUE
                 WHEN LS-CELL = "H"
                     MOVE L-DIST TO L-RESULT
                     MOVE 1 TO LS-DONE
                 WHEN LS-CELL = "." AND L-DIST < L-FIND
                     COMPUTE LS-DIST = L-DIST + 1
                     COMPUTE LS-FROM = FUNCTION MOD(LS-D + 2, 4)
                     CALL "FL-SLOPE" USING L-GRID LS-NX LS-NZ LS-DIST LS-FROM L-FIND LS-SUB
                     IF LS-SUB < L-RESULT
                         MOVE LS-SUB TO L-RESULT
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FL-SLOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-REPLACEABLE.
*> USING existing fluid (0 empty, 1 water, 2 lava), direction is DOWN, the incoming fluid is in tag water, the existing amount
*> (BINARY-LONG), replaced out: canBeReplacedWith (2.7); lava is replaced from amount 4 (height 4/9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXISTING             BINARY-LONG.
 01 L-DOWN                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EXISTING L-DOWN L-WATER L-AMOUNT L-OK.
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-EXISTING = 0
             MOVE 1 TO L-OK
         WHEN L-EXISTING = 1 AND L-DOWN = 1 AND L-WATER = 0
             MOVE 1 TO L-OK
         WHEN L-EXISTING = 2 AND L-AMOUNT >= 4 AND L-WATER = 1
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-REPLACEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-PASS-WALL.
*> USING the target's collision shape is the full block, the origin's is the full block, both are empty, the faces occlude
*> (BINARY-LONG), ok out: canPassThroughWall (2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TO-FULL              BINARY-LONG.
 01 L-FROM-FULL            BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-OCCLUDES             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TO-FULL L-FROM-FULL L-EMPTY L-OCCLUDES L-OK.
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-TO-FULL = 1 OR L-FROM-FULL = 1
             CONTINUE
         WHEN L-EMPTY = 1
             MOVE 1 TO L-OK
         WHEN L-OCCLUDES = 0
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-PASS-WALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-HOLD-RULES.
*> USING the block is a liquid container, it is in tag washed_away_by_fluids, the container accepts the fluid (BINARY-LONG), can hold
*> any out, can hold the specific fluid out, can hold out: 2.6 table.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONTAINER            BINARY-LONG.
 01 L-WASHED               BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 01 L-SPECIFIC             BINARY-LONG.
 01 L-HOLD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTAINER L-WASHED L-PLACE L-ANY L-SPECIFIC L-HOLD.
     MOVE 0 TO L-ANY L-HOLD
     MOVE 1 TO L-SPECIFIC
     IF L-CONTAINER = 1 OR L-WASHED = 1
         MOVE 1 TO L-ANY
     END-IF
     IF L-CONTAINER = 1
         MOVE L-PLACE TO L-SPECIFIC
     END-IF
     IF L-ANY = 1 AND L-SPECIFIC = 1
         MOVE 1 TO L-HOLD
     END-IF
     GOBACK.
 END PROGRAM FL-HOLD-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-PASS-RULES.
*> USING the neighbour is a source of this fluid, can hold any, passes the wall, can hold the specific fluid (BINARY-LONG), can maybe
*> pass out, can pass out: canMaybePassThrough and canPassThrough (2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-ANY                  BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 01 L-SPECIFIC             BINARY-LONG.
 01 L-MAYBE                BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-ANY L-WALL L-SPECIFIC L-MAYBE L-PASS.
     MOVE 0 TO L-MAYBE L-PASS
     IF L-SOURCE = 0 AND L-ANY = 1 AND L-WALL = 1
         MOVE 1 TO L-MAYBE
     END-IF
     IF L-MAYBE = 1 AND L-SPECIFIC = 1
         MOVE 1 TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM FL-PASS-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SPREAD-TO.
*> USING fluid (1 water, 2 lava), the block is a liquid container, the block is air, direction is DOWN, the existing fluid is in tag
*> water, the block is a LiquidBlock (BINARY-LONG), action out, drops out, fizz (level event 1501) out, stone out: spreadTo (2.8).
*> Action 1 placeLiquid, 2 write the new state, 4 lava onto water makes stone (the new state is not written).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-DOWN                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-FIZZ                 BINARY-LONG.
 01 L-STONE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-CONTAINER L-AIR L-DOWN L-WATER L-LIQUID L-ACTION L-DROPS L-FIZZ L-STONE.
     MOVE 0 TO L-DROPS L-FIZZ L-STONE
     EVALUATE TRUE
         WHEN L-FLUID = 2 AND L-DOWN = 1 AND L-WATER = 1 AND L-LIQUID = 1
             MOVE 4 TO L-ACTION
             MOVE 1 TO L-FIZZ L-STONE
         WHEN L-CONTAINER = 1
             MOVE 1 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-ACTION
             IF L-AIR = 0 AND L-FLUID = 1
                 MOVE 1 TO L-DROPS
             END-IF
             IF L-AIR = 0 AND L-FLUID = 2
                 MOVE 1 TO L-FIZZ
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-SPREAD-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SHOULD-SPREAD.
*> USING the five neighbours m (UP, NORTH, SOUTH, WEST, EAST: the opposites of DOWN, SOUTH, NORTH, EAST, WEST) as two groups of five
*> BINARY-LONG flags, in order: the fluid at m is in tag water, then the block at m is blue_ice; the fluid (1 water, 2 lava), the block
*> below is soul_soil, the lava at the position is a source (BINARY-LONG), action out (0 none, 1 obsidian, 2 cobblestone, 3 basalt;
*> 1 to 3 are written with level event 1501), spread out (1 the caller schedules the fluid tick): LiquidBlock.shouldSpreadLiquid (3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-WATER             BINARY-LONG OCCURS 5 TIMES.
    05 L-ICE               BINARY-LONG OCCURS 5 TIMES.
 01 L-FLUID                BINARY-LONG.
 01 L-SOUL                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SPREAD               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-FLUID L-SOUL L-SOURCE L-ACTION L-SPREAD.
     MOVE 0 TO L-ACTION
     MOVE 1 TO L-SPREAD
     IF L-FLUID = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > 5 OR L-ACTION NOT = 0
         EVALUATE TRUE
             WHEN L-WATER(WS-M) = 1 AND L-SOURCE = 1
                 MOVE 1 TO L-ACTION
             WHEN L-WATER(WS-M) = 1
                 MOVE 2 TO L-ACTION
             WHEN L-SOUL = 1 AND L-ICE(WS-M) = 1
                 MOVE 3 TO L-ACTION
         END-EVALUATE
     END-PERFORM
     IF L-ACTION NOT = 0
         MOVE 0 TO L-SPREAD
     END-IF
     GOBACK.
 END PROGRAM FL-SHOULD-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-AXPB.
*> USING a, x, b (FLOAT-LONG), result out: the single-precision expression a * x + b (each operation rounded to float); the sound and
*> pitch formulas of 3.3, 4.2 and 4.3 are instances of it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-A                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-X L-B L-OUT.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-A WS-A
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-X WS-X
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-B WS-B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-X WS-P
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-Q
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-Q WS-B WS-S
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S L-OUT
     GOBACK.
 END PROGRAM FL-AXPB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-FIZZ-PITCH.
*> USING two nextFloat draws (FLOAT-LONG), pitch out: level event 1501 (3.3): 2.6 + (r1 - r2) * 0.8 in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-D                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-SLOPE               FLOAT-LONG VALUE 0.8.
 01 WS-BASE                FLOAT-LONG VALUE 2.6.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-PITCH.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-R1 L-R2 WS-D
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D WS-E
     CALL "FL-AXPB" USING WS-E WS-SLOPE WS-BASE L-PITCH
     GOBACK.
 END PROGRAM FL-FIZZ-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-FIZZ-PARTICLE.
*> USING block x, y, z (BINARY-LONG), x draw, z draw (FLOAT-LONG), particle x, y, z out (FLOAT-LONG): large_smoke at (x + nextDouble,
*> y + 1.2, z + nextDouble), eight times (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DX L-DZ L-PX L-PY L-PZ.
     COMPUTE L-PX = L-X + L-DX
     COMPUTE L-PY = L-Y + 1.2
     COMPUTE L-PZ = L-Z + L-DZ
     GOBACK.
 END PROGRAM FL-FIZZ-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-CAN-SPREAD-FIRE.
*> USING game rule fire_spread_radius_around_player, a player is close enough (BINARY-LONG), ok out: Level.canSpreadFireAround (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-CLOSE L-OK.
     MOVE 0 TO L-OK
     IF L-RULE = -1 OR L-CLOSE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM FL-CAN-SPREAD-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LAVA-STEP.
*> USING branch (1 for n > 0, 0 for n = 0), position x, y, z, x draw, z draw (nextInt(3), BINARY-LONG), new x, y, z out: one offset of
*> LavaFluid.randomTick (4.1): (draw - 1, branch, draw - 1) from the given position; with n > 0 each step starts from the last one.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BRANCH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BRANCH L-X L-Y L-Z L-DX L-DZ L-NX L-NY L-NZ.
     COMPUTE L-NX = L-X + L-DX - 1
     COMPUTE L-NY = L-Y + L-BRANCH
     COMPUTE L-NZ = L-Z + L-DZ - 1
     GOBACK.
 END PROGRAM FL-LAVA-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LAVA-DECIDE.
*> USING branch (1 n > 0, 0 n = 0), position loaded, the block is air, a neighbour of p is flammable by lava, the cell above p is
*> empty, p is flammable by lava, the block is in blocks_lava_fire_spread (BINARY-LONG), action out: 1 fire at p, 2 return, 3 fire at
*> the cell above p (its state is still taken from p), 0 go on (4.1). n > 0 uses the six-neighbour test; n = 0 does not.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BRANCH               BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-ABOVE-EMPTY          BINARY-LONG.
 01 L-FLAMMABLE            BINARY-LONG.
 01 L-BLOCKS               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-BRANCH L-LOADED L-AIR L-NEIGHBOUR L-ABOVE-EMPTY L-FLAMMABLE L-BLOCKS L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE TRUE
         WHEN L-LOADED = 0
             MOVE 2 TO L-ACTION
         WHEN L-BRANCH = 1 AND L-AIR = 1 AND L-NEIGHBOUR = 1
             MOVE 1 TO L-ACTION
         WHEN L-BRANCH = 1 AND L-AIR = 0 AND L-BLOCKS = 1
             MOVE 2 TO L-ACTION
         WHEN L-BRANCH = 0 AND L-ABOVE-EMPTY = 1 AND L-FLAMMABLE = 1
             MOVE 3 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM FL-LAVA-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-IGNITE.
*> USING fire-immune, current fire ticks (BINARY-LONG), new fire ticks out: lavaIgnite (4.2): igniteForSeconds(15) raises the fire
*> ticks to at least 300; nothing for a fire-immune entity.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMMUNE               BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IMMUNE L-CURRENT L-OUT.
     MOVE L-CURRENT TO L-OUT
     IF L-IMMUNE = 0 AND L-CURRENT < 300
         MOVE 300 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM FL-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LAVA-HURT.
*> USING fire-immune, server side, silent, shouldPlayLavaHurtSound (BINARY-LONG), damage in tenths out, play generic.burn out: lavaHurt
*> (4.2): lava damage 4.0 on the server to an entity that is not fire-immune; the sound when it was applied, the entity is not silent.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMMUNE               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-SILENT               BINARY-LONG.
 01 L-SOUND-OK             BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-IMMUNE L-SERVER L-SILENT L-SOUND-OK L-DAMAGE L-SOUND.
     MOVE 0 TO L-DAMAGE L-SOUND
     IF L-IMMUNE = 0 AND L-SERVER = 1
         MOVE 40 TO L-DAMAGE
         IF L-SILENT = 0 AND L-SOUND-OK = 1
             MOVE 1 TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FL-LAVA-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-BURN-PITCH.
*> USING a nextFloat draw (FLOAT-LONG), pitch out: the generic.burn pitch 2.0 + r * 0.4 (4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG VALUE 0.4.
 01 WS-B                   FLOAT-LONG VALUE 2.0.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-R L-PITCH.
     CALL "FL-AXPB" USING L-R WS-X WS-B L-PITCH
     GOBACK.
 END PROGRAM FL-BURN-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-EFFECTS.
*> USING requested effects (five BINARY-LONG flags: FREEZE, CLEAR_FREEZE, FIRE_IGNITE, LAVA_IGNITE, EXTINGUISH), the entity is still
*> alive after lavaHurt (BINARY-LONG), the applied sequence out (eight BINARY-LONG, 0 ends it): the collector order of 4.2; the numbers
*> are 1 to 5 for the effects and 6 for lavaHurt, which runs right after LAVA_IGNITE; the pass stops once the entity is not alive.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS.
    05 L-FLAG              BINARY-LONG OCCURS 5 TIMES.
 01 L-ALIVE                BINARY-LONG.
 01 L-OUT.
    05 L-STEP              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-FLAGS L-ALIVE L-OUT.
     MOVE 0 TO L-STEP(1) L-STEP(2) L-STEP(3) L-STEP(4) L-STEP(5) L-STEP(6) L-STEP(7) L-STEP(8)
     MOVE 0 TO WS-N WS-DONE
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5 OR WS-DONE = 1
         IF L-FLAG(WS-T) = 1
             ADD 1 TO WS-N
             MOVE WS-T TO L-STEP(WS-N)
             IF WS-T = 4
                 ADD 1 TO WS-N
                 MOVE 6 TO L-STEP(WS-N)
                 IF L-ALIVE = 0
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FL-EFFECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LAVA-TICK.
*> USING in lava (BINARY-LONG), fall distance (FLOAT-LONG), new fall distance out (FLOAT-LONG), skip the on_fire damage out: the lava
*> part of Entity.baseTick (4.2): the fall distance is halved each tick and the burning damage is skipped.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-LAVA              BINARY-LONG.
 01 L-FALL                 FLOAT-LONG.
 01 L-NEW                  FLOAT-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-LAVA L-FALL L-NEW L-SKIP.
     MOVE L-FALL TO L-NEW
     MOVE 0 TO L-SKIP
     IF L-IN-LAVA = 1
         COMPUTE L-NEW = L-FALL * 0.5
         MOVE 1 TO L-SKIP
     END-IF
     GOBACK.
 END PROGRAM FL-LAVA-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-LAVA-AMBIENCE.
*> USING air above and not a solid render block, nextInt(100) draw, nextInt(200) draw (BINARY-LONG), pop out (particle and lava.pop),
*> ambient out (lava.ambient at the integer block coordinates): lava animateTick (4.3). The ambient sound does not depend on the
*> block above ("independently", Open question).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-D100                 BINARY-LONG.
 01 L-D200                 BINARY-LONG.
 01 L-POP                  BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-D100 L-D200 L-POP L-AMBIENT.
     MOVE 0 TO L-POP L-AMBIENT
     IF L-ABOVE = 1 AND L-D100 = 0
         MOVE 1 TO L-POP
     END-IF
     IF L-D200 = 0
         MOVE 1 TO L-AMBIENT
     END-IF
     GOBACK.
 END PROGRAM FL-LAVA-AMBIENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-WATER-AMBIENCE.
*> USING source or falling state, nextInt(64) draw, nextInt(10) draw (BINARY-LONG), ambient.water sound out, underwater particle out:
*> water animateTick (4.3): a flowing non-falling state plays the sound on 1 in 64; a source or falling state spawns the particle
*> on 1 in 10.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STILL                BINARY-LONG.
 01 L-D64                  BINARY-LONG.
 01 L-D10                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-PARTICLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-STILL L-D64 L-D10 L-SOUND L-PARTICLE.
     MOVE 0 TO L-SOUND L-PARTICLE
     IF L-STILL = 0 AND L-D64 = 0
         MOVE 1 TO L-SOUND
     END-IF
     IF L-STILL = 1 AND L-D10 = 0
         MOVE 1 TO L-PARTICLE
     END-IF
     GOBACK.
 END PROGRAM FL-WATER-AMBIENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FL-SOUND-FORMULAS.
*> USING r1, r2 (FLOAT-LONG nextFloat draws), lava.pop volume, lava.pop pitch, ambient.water volume, ambient.water pitch out (FLOAT-LONG):
*> 4.3: 0.2 + r * 0.2, 0.9 + r * 0.15, r * 0.25 + 0.75 and r + 0.5 in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG VALUE 0.2.
 01 WS-A2                  FLOAT-LONG VALUE 0.2.
 01 WS-B                   FLOAT-LONG VALUE 0.15.
 01 WS-C                   FLOAT-LONG VALUE 0.9.
 01 WS-D                   FLOAT-LONG VALUE 0.25.
 01 WS-E                   FLOAT-LONG VALUE 0.75.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-POP-VOLUME           FLOAT-LONG.
 01 L-POP-PITCH            FLOAT-LONG.
 01 L-WATER-VOLUME         FLOAT-LONG.
 01 L-WATER-PITCH          FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-POP-VOLUME L-POP-PITCH L-WATER-VOLUME L-WATER-PITCH.
     CALL "FL-AXPB" USING L-R1 WS-A WS-A2 L-POP-VOLUME
     CALL "FL-AXPB" USING L-R2 WS-B WS-C L-POP-PITCH
     CALL "FL-AXPB" USING L-R1 WS-D WS-E L-WATER-VOLUME
     CALL "FL-AXPB" USING L-R2 WS-ONE WS-HALF L-WATER-PITCH
     GOBACK.
 END PROGRAM FL-SOUND-FORMULAS.
