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
