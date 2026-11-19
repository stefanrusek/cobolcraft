*> Turtle (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 12): its home is the block it spawned in (MOB-BORN), seagrass is its food, two turtles make an egg
*> instead of a baby (MOB-BREED: hasEgg, metadata 18), a baby that grows up drops one scute (TURTLE-GROWN, the table gameplay/turtle_grow), and a turtle with an egg and its home within 9 blocks
*> walks home and digs there (TURTLE-TICK; the egg block hatches by core/src/mob-44-l.cob): layEggCounter counts up (layingEgg, metadata 19, while it is above 0) and beyond 200 ticks it puts a turtle egg block of 1 + nextInt(4) eggs on its
*> home block when that is air, clears the egg and the laying and gets love time 600. Panic (a hurt turtle runs to the water within 7 blocks, TURTLE-LOOK-FOR-WATER) and the walk-target value (TURTLE-WALK-VALUE) are lane p49s. Open items: TurtleGoToWater, TurtleGoHome beyond 9 blocks, TurtleTravel (the docs give no numbers),
*> the lay sound and the dig particles, a home saved in the world, the choice of another laying spot.
*>
*> Entry points:
*>   TURTLE-TICK USING row, hx out, hz out, walk out    walk 1: hx and hz are the walk of this tick (to the home); walk 2: the turtle stands (digging)
*>   TURTLE-GROWN USING row                             the baby has grown up: one scute lands at it while the game rule mob_drops is true
*>   TURTLE-WALK-VALUE USING row, x, y, z (BINARY-LONG cell), going home (0/1), value out (FLOAT-LONG)   Turtle.getWalkTargetValue (44 part 4 section 11.1): 10 for a water block unless it is going
*>                                                     home, 10 over sand, else the light cost lightMagic - 0.5 (Overworld ambient light 0)
*>   TURTLE-LOOK-FOR-WATER USING row, range, found out, x, y, z out (BINARY-LONG)   PanicGoal.lookForWater (11.1): none inside a block with a collision shape, else the first water block of the
*>                                                     ordered box (range, 1, range) by Manhattan distance, nearest first (BlockPos.withinBoxByManhattanDistance, 35-7 section 2.3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TURTLE-GROWN.
*> USING row: the table gameplay/turtle_grow is one turtle scute (19 section 12 names it "a scute"; the file itself is not in the content set, like gameplay/chicken_lay in 19 section 2.5),
*> dropped at the turtle while the game rule mob_drops is true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:turtle_scute".
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 1
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE
             WS-PATCH WS-ITEM-ENTITY
     END-IF
     GOBACK.
 END PROGRAM TURTLE-GROWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TURTLE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 52.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-DRAW                BINARY-LONG.
 01 WS-EGGS                PIC 9.
 01 WS-KEY                 PIC X(112) VALUE "turtle_egg".
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-HERE                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-SET                 BINARY-LONG.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-FOUND               BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
*>   TurtlePanicGoal (44 part 4 section 11): a panicking turtle runs to the water block within 7 blocks (lookForWater) at the panic speed: the flee point is mirrored through the turtle so that
*>   the ordinary flee walk leads to the block; without water the flee from the attacker goes on.
     IF EN-FLEE(L-ROW) > 0
         CALL "TURTLE-LOOK-FOR-WATER" USING L-ROW WS-SEVEN WS-FOUND WS-WX WS-WY WS-WZ
         IF WS-FOUND = 1
             MOVE 0 TO EN-FLEE-ID(L-ROW)
             COMPUTE EN-FLEE-X(L-ROW) = 2 * EN-X(L-ROW) - WS-WX
             COMPUTE EN-FLEE-Z(L-ROW) = 2 * EN-Z(L-ROW) - WS-WZ
         END-IF
     END-IF
     IF EN-TURTLE-EGG(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-DX = EN-HOME-X(L-ROW) + 0.5 - EN-X(L-ROW)
     COMPUTE WS-DY = EN-HOME-Y(L-ROW) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-HOME-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
*>   The laying goal needs the home within 9 blocks.
     IF WS-D2 >= 81
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-DX * WS-DX + WS-DZ * WS-DZ >= 1 OR FUNCTION ABS(WS-DY) >= 1
         CALL "STDMOB-HEAD" USING L-ROW WS-M EN-HOME-X(L-ROW) EN-HOME-Y(L-ROW) EN-HOME-Z(L-ROW) L-HX L-HZ WS-ARRIVED
         MOVE 1 TO L-WALK
         GOBACK
     END-IF
*>   At home: dig. The first tick starts the laying (metadata 19), beyond 200 ticks the egg is laid.
     MOVE 2 TO L-WALK
     ADD 1 TO EN-TURTLE-LAY(L-ROW)
     IF EN-TURTLE-LAY(L-ROW) = 1
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     IF EN-TURTLE-LAY(L-ROW) > 200
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE WS-EGGS = WS-DRAW + 1
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) EN-HOME-X(L-ROW) EN-HOME-Y(L-ROW) EN-HOME-Z(L-ROW) WS-HERE
         IF WS-HERE = 0
             MOVE SPACES TO WS-PAIRS
             STRING "eggs=" WS-EGGS ",hatch=0" DELIMITED BY SIZE INTO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
*>           LEVEL-SET-BLOCK runs the onPlace hook of the egg (the sand particles, core/src/mob-44-l.cob).
             CALL "LEVEL-SET-BLOCK" USING EN-DIM(L-ROW) EN-HOME-X(L-ROW) EN-HOME-Y(L-ROW) EN-HOME-Z(L-ROW) WS-STATE WS-FLAGS WS-BUDGET WS-SET
         END-IF
         MOVE 0 TO EN-TURTLE-EGG(L-ROW) EN-TURTLE-LAY(L-ROW)
         MOVE 600 TO EN-LOVE(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM TURTLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TURTLE-IS-WATER.
*> USING dim, x, y, z (BINARY-LONG), water out (1/0): the block at the cell is the water block (a fluid state in tag water; a waterlogged block is not tested).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-WATER.
     MOVE 0 TO L-WATER
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
     IF CB-KEY(WS-BLK + 1) = "water" OR CB-KEY(WS-BLK + 1) = "minecraft:water"
         MOVE 1 TO L-WATER
     END-IF
     GOBACK.
 END PROGRAM TURTLE-IS-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TURTLE-WALK-VALUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-WATER               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HOME                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-HOME L-VALUE.
     CALL "TURTLE-IS-WATER" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-WATER
     IF L-HOME = 0 AND WS-WATER = 1
         MOVE 10 TO L-VALUE
         GOBACK
     END-IF
     COMPUTE WS-BELOW = L-Y - 1
*>   TurtleEggBlock.onSand: the block below is in the tag sand (EGG-IS-SAND, mob-44-l.cob: the stand-in is sand and red sand).
     CALL "EGG-IS-SAND" USING EN-DIM(L-ROW) L-X WS-BELOW L-Z WS-SAND
     IF WS-SAND = 1
         MOVE 10 TO L-VALUE
         GOBACK
     END-IF
*>   getPathfindingCostFromLightLevels: b = brightness / 15, m = b / (4 - 3 b), the cost m - 0.5 (ambient light 0); the brightness is the larger of the block light and the sky light less the night's darkening.
     CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-SKY WS-BLOCK-LIGHT
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-BLOCK-LIGHT, WS-SKY - WS-DARK)
     COMPUTE WS-B = WS-LIGHT / 15
     COMPUTE WS-M = WS-B / (4 - 3 * WS-B)
     COMPUTE L-VALUE = WS-M - 0.5
     GOBACK.
 END PROGRAM TURTLE-WALK-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TURTLE-LOOK-FOR-WATER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DMAX                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-XLIM                BINARY-LONG.
 01 WS-YLIM                BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RANGE L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
*>   A turtle inside a block that has a collision shape looks for nothing.
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-SOLID
     IF WS-SOLID = 1
         GOBACK
     END-IF
     COMPUTE WS-DMAX = L-RANGE + WS-ONE + L-RANGE
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > WS-DMAX OR L-FOUND = 1
         COMPUTE WS-XLIM = FUNCTION MIN(L-RANGE, WS-D)
         PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2 * WS-XLIM OR L-FOUND = 1
             COMPUTE WS-CX = WS-DX - WS-XLIM
             COMPUTE WS-YLIM = FUNCTION MIN(1, WS-D - FUNCTION ABS(WS-CX))
             PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 2 * WS-YLIM OR L-FOUND = 1
                 COMPUTE WS-CY = WS-DY - WS-YLIM
                 COMPUTE WS-DZ = WS-D - FUNCTION ABS(WS-CX) - FUNCTION ABS(WS-CY)
                 IF WS-DZ >= 0 AND WS-DZ <= L-RANGE
                     COMPUTE WS-CZ = WS-DZ
                     PERFORM VARYING WS-SIDE FROM 0 BY 1 UNTIL WS-SIDE > 1 OR L-FOUND = 1
                         IF WS-SIDE = 1
                             COMPUTE WS-CZ = 0 - WS-DZ
                         END-IF
                         IF WS-SIDE = 0 OR WS-DZ NOT = 0
                             COMPUTE L-X = WS-PX + WS-CX
                             COMPUTE L-Y = WS-PY + WS-CY
                             COMPUTE L-Z = WS-PZ + WS-CZ
                             CALL "TURTLE-IS-WATER" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-WATER
                             IF WS-WATER = 1
                                 MOVE 1 TO L-FOUND
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM TURTLE-LOOK-FOR-WATER.
