*> Turtle (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 12): its home is the block it spawned in (MOB-BORN), seagrass is its food, two turtles make an egg
*> instead of a baby (MOB-BREED: hasEgg, metadata 18), a baby that grows up drops one scute (TURTLE-GROWN, the table gameplay/turtle_grow), and a turtle with an egg and its home within 9 blocks
*> walks home and digs there (TURTLE-TICK; the egg block hatches by core/src/mob-44-l.cob): layEggCounter counts up (layingEgg, metadata 19, while it is above 0) and beyond 200 ticks it puts a turtle egg block of 1 + nextInt(4) eggs on its
*> home block when that is air, clears the egg and the laying and gets love time 600. Open items: TurtleGoToWater, TurtleGoHome beyond 9 blocks, TurtleTravel (the docs give no numbers),
*> the lay sound and the dig particles, a home saved in the world, the choice of another laying spot.
*>
*> Entry points:
*>   TURTLE-TICK USING row, hx out, hz out, walk out    walk 1: hx and hz are the walk of this tick (to the home); walk 2: the turtle stands (digging)
*>   TURTLE-GROWN USING row                             the baby has grown up: one scute lands at it while the game rule mob_drops is true

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
 01 WS-EV-PLACE            PIC X(32) VALUE "block_place".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
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
*>           Turtle$TurtleLayEggGoal.tick: block_place at the centre of the egg's cell, the turtle as the source, the egg's state (30-8 14.3.4)
             CALL "GAME-EVENT-CELL" USING EN-DIM(L-ROW) EN-HOME-X(L-ROW) EN-HOME-Y(L-ROW) EN-HOME-Z(L-ROW) WS-EV-PLACE L-ROW WS-STATE
         END-IF
         MOVE 0 TO EN-TURTLE-EGG(L-ROW) EN-TURTLE-LAY(L-ROW)
         MOVE 600 TO EN-LOVE(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM TURTLE-TICK.
