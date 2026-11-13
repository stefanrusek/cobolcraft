*> Fluids in the world (docs/protocol/29a sections 1 to 3): the fluid tick of a water or lava cell run against the block table and the world,
*> with the decisions of fluids-29a.cob, and the hooks that schedule it (FLUID-HOOK, called by BU-HOOK of blockupd-29.cob for onPlace, neighborChanged,
*> updateShape and the scheduled fluid tick). The liquid blocks are found by key in the core block tables (CBLOCKS.cpy: "minecraft:water" and
*> "minecraft:lava", 16 states each, the state's index being the level), so a world without them (the cobolcraft world type) never runs any of this.
*> Approximations, each named where it is made: a block "can hold any fluid" and "passes the wall" when it has no collision (the tag
*> washed_away_by_fluids and the collision shapes are not in the core tables), the draw of getSpreadDelay is a hash of the game time and the
*> position (the core has no level random), and the drops of a destroyed block are not made. Lava's random tick (fire) and entity effects are
*> not wired (they need fire and entity hooks).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-ROLES.
*> USING water block id, lava block id, water first state, lava first state (BINARY-LONG out): the liquid blocks of the open block tables, -1 when a
*> table has none; searched once per CB-EPOCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-WATER               BINARY-LONG VALUE -1.
 01 WS-LAVA                BINARY-LONG VALUE -1.
 01 WS-WATER-FIRST         BINARY-LONG VALUE 0.
 01 WS-LAVA-FIRST          BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-LAVA                 BINARY-LONG.
 01 L-WATER-FIRST          BINARY-LONG.
 01 L-LAVA-FIRST           BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-LAVA L-WATER-FIRST L-LAVA-FIRST.
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE CB-EPOCH TO WS-EPOCH
         MOVE -1 TO WS-WATER WS-LAVA
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
             IF CB-KEY(WS-I) = "minecraft:water"
                 COMPUTE WS-WATER = WS-I - 1
                 MOVE CB-FIRST-STATE(WS-I) TO WS-WATER-FIRST
             END-IF
             IF CB-KEY(WS-I) = "minecraft:lava"
                 COMPUTE WS-LAVA = WS-I - 1
                 MOVE CB-FIRST-STATE(WS-I) TO WS-LAVA-FIRST
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-WATER TO L-WATER
     MOVE WS-LAVA TO L-LAVA
     MOVE WS-WATER-FIRST TO L-WATER-FIRST
     MOVE WS-LAVA-FIRST TO L-LAVA-FIRST
     GOBACK.
 END PROGRAM FLUID-ROLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-OF-STATE.
*> USING block state, fluid out (0 none, 1 water, 2 lava), kind out (0 empty, 1 flowing water, 2 water, 3 flowing lava, 4 lava), amount out,
*> falling out (BINARY-LONG): the fluid state of a block state (1.2): a liquid block's level to its fluid state (FL-FROM-LEVEL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLUID L-KIND L-AMOUNT L-FALLING.
     MOVE 0 TO L-FLUID L-KIND L-AMOUNT L-FALLING
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     IF WS-WATER >= 0 AND WS-BLOCK = WS-WATER
         MOVE 1 TO L-FLUID
         COMPUTE WS-LEVEL = L-STATE - WS-WATER-FIRST
     END-IF
     IF WS-LAVA >= 0 AND WS-BLOCK = WS-LAVA
         MOVE 2 TO L-FLUID
         COMPUTE WS-LEVEL = L-STATE - WS-LAVA-FIRST
     END-IF
     IF L-FLUID > 0
         CALL "FL-FROM-LEVEL" USING L-FLUID WS-LEVEL L-KIND L-AMOUNT L-FALLING
     END-IF
     GOBACK.
 END PROGRAM FLUID-OF-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-STATE-ID.
*> USING fluid (1 water, 2 lava), kind, amount, falling (BINARY-LONG), block state out (0, air, for the empty fluid): createLegacyBlock (1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-KIND L-AMOUNT L-FALLING L-STATE.
     MOVE 0 TO L-STATE
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     CALL "FL-LEGACY" USING L-KIND L-AMOUNT L-FALLING WS-LEVEL
     IF WS-LEVEL >= 0
         IF L-FLUID = 1
             COMPUTE L-STATE = WS-WATER-FIRST + WS-LEVEL
         ELSE
             COMPUTE L-STATE = WS-LAVA-FIRST + WS-LEVEL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FLUID-STATE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-KEY-IS.
*> USING block state, key (PIC X(48)), flag out (BINARY-LONG): 1 when the state's block has that key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-KEY L-FLAG.
     MOVE 0 TO L-FLAG
     IF CB-KEY(CB-S-BLOCK(L-STATE + 1) + 1) = L-KEY
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FLUID-KEY-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-CELL.
*> USING dimension row, x, y, z (BINARY-LONG), block state out, fluid out (0 none, 1 water, 2 lava), kind out, amount out, falling out, solid out
*> (1 when the block has a collision shape: the cached isSolid and the full-block shape of this approximation), holds out (canHoldAnyFluid: air, a
*> block without collision): the cell the fluid rules read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-HOLDS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-FLUID L-KIND L-AMOUNT L-FALLING L-SOLID L-HOLDS.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     CALL "FLUID-OF-STATE" USING L-STATE L-FLUID L-KIND L-AMOUNT L-FALLING
     MOVE 0 TO L-SOLID L-HOLDS
     IF L-STATE NOT = 0
         MOVE CB-SOLID(CB-S-BLOCK(L-STATE + 1) + 1) TO L-SOLID
     END-IF
     IF L-SOLID = 0
         MOVE 1 TO L-HOLDS
     END-IF
     GOBACK.
 END PROGRAM FLUID-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-NEW.
*> USING dimension row, x, y, z, fluid (1 water, 2 lava) (BINARY-LONG), code out (0 empty, 1 source, 2 flowing), amount out, falling out:
*> getNewLiquid (2.3) of the cell at the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRS                PIC X(4) VALUE "2534".
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SOURCES             BINARY-LONG.
 01 WS-BELOW-SOLID         BINARY-LONG.
 01 WS-BELOW-SOURCE        BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-CONVERT             BINARY-LONG.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-FIND                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLUID L-CODE L-AMOUNT L-FALLING.
     MOVE 0 TO WS-MAX WS-SOURCES WS-ABOVE WS-BELOW-SOLID WS-BELOW-SOURCE
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE WS-DIRS(WS-D:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-DIR
         CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "FLUID-CELL" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-F = L-FLUID
             IF WS-KIND = 2 OR WS-KIND = 4
                 ADD 1 TO WS-SOURCES
             END-IF
             IF WS-AMOUNT > WS-MAX
                 MOVE WS-AMOUNT TO WS-MAX
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-NY = L-Y - 1
     CALL "FLUID-CELL" USING L-DIM L-X WS-NY L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     MOVE WS-SOLID TO WS-BELOW-SOLID
     IF WS-F = L-FLUID AND (WS-KIND = 2 OR WS-KIND = 4)
         MOVE 1 TO WS-BELOW-SOURCE
     END-IF
     COMPUTE WS-NY = L-Y + 1
     CALL "FLUID-CELL" USING L-DIM L-X WS-NY L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-F = L-FLUID AND WS-SOLID = 0
         MOVE 1 TO WS-ABOVE
     END-IF
     MOVE 0 TO WS-CONVERT
     IF L-FLUID = 1
         MOVE 1 TO WS-CONVERT
     END-IF
     CALL "FL-DELAY" USING L-FLUID WS-FAST WS-DELAY WS-FIND WS-DROP
     CALL "FL-NEW-LIQUID" USING WS-MAX WS-SOURCES WS-CONVERT WS-BELOW-SOLID WS-BELOW-SOURCE WS-ABOVE WS-DROP L-CODE L-AMOUNT L-FALLING
     GOBACK.
 END PROGRAM FLUID-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-PUT.
*> USING dimension row, x, y, z, fluid, code (0 empty, 1 source, 2 flowing), amount, falling (BINARY-LONG): setBlockAndUpdate of a fluid state's legacy
*> block (flags 3, LEVEL-SET-BLOCK); the empty fluid writes air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLUID L-CODE L-AMOUNT L-FALLING.
     MOVE 0 TO WS-KIND
     IF L-CODE = 1
         COMPUTE WS-KIND = L-FLUID * 2
     END-IF
     IF L-CODE = 2
         COMPUTE WS-KIND = L-FLUID * 2 - 1
     END-IF
     CALL "FLUID-STATE-ID" USING L-FLUID WS-KIND L-AMOUNT L-FALLING WS-STATE
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE WS-FLAGS WS-BUDGET WS-RESULT
     GOBACK.
 END PROGRAM FLUID-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-SCHEDULE.
*> USING dimension row, x, y, z, fluid, delay (BINARY-LONG): a scheduled fluid tick of that fluid (29 section 4.1, type 2, normal priority).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-PRIORITY            BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLUID L-DELAY.
     CALL "BT-SCHEDULE" USING L-DIM WS-TYPE L-FLUID L-X L-Y L-Z L-DELAY WS-PRIORITY WS-RESULT
     GOBACK.
 END PROGRAM FLUID-SCHEDULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-SLOPE RECURSIVE.
*> USING dimension row, x, y, z (the cell), dist, the direction not to go back through (2 north, 3 south, 4 west, 5 east, 0 none), fluid, slope find
*> distance (BINARY-LONG), best out: getSlopeDistance (2.5) over the world; a neighbour is passable when it is not a source of the fluid and holds
*> any fluid; it is a hole when the cell below it is passable and holds the fluid or can hold it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRS                PIC X(4) VALUE "2534".
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DIGIT               PIC 9.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-BY                  BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-F                   BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-AMOUNT              BINARY-LONG.
 01 LS-FALLING             BINARY-LONG.
 01 LS-SOLID               BINARY-LONG.
 01 LS-HOLDS               BINARY-LONG.
 01 LS-B-F                 BINARY-LONG.
 01 LS-B-HOLDS             BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-FIND                 BINARY-LONG.
 01 L-BEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIST L-FROM L-FLUID L-FIND L-BEST.
     MOVE 1000 TO L-BEST
     PERFORM VARYING LS-D FROM 1 BY 1 UNTIL LS-D > 4
         MOVE WS-DIRS(LS-D:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-DIR
         IF LS-DIR NOT = L-FROM
             CALL "BU-DIRECTION" USING LS-DIR LS-DX LS-DY LS-DZ
             COMPUTE LS-NX = L-X + LS-DX
             COMPUTE LS-NZ = L-Z + LS-DZ
             CALL "FLUID-CELL" USING L-DIM LS-NX L-Y LS-NZ LS-STATE LS-F LS-KIND LS-AMOUNT LS-FALLING LS-SOLID LS-HOLDS
             IF LS-HOLDS = 1 AND NOT (LS-F = L-FLUID AND (LS-KIND = 2 OR LS-KIND = 4))
                 COMPUTE LS-BY = L-Y - 1
                 CALL "FLUID-CELL" USING L-DIM LS-NX LS-BY LS-NZ LS-STATE LS-B-F LS-KIND LS-AMOUNT LS-FALLING LS-SOLID LS-B-HOLDS
                 IF LS-B-HOLDS = 1 OR LS-B-F = L-FLUID
                     MOVE L-DIST TO L-BEST
                     GOBACK
                 END-IF
                 IF L-DIST < L-FIND
                     EVALUATE LS-DIR
                         WHEN 2
                             MOVE 3 TO LS-OPP
                         WHEN 3
                             MOVE 2 TO LS-OPP
                         WHEN 4
                             MOVE 5 TO LS-OPP
                         WHEN OTHER
                             MOVE 4 TO LS-OPP
                     END-EVALUATE
                     COMPUTE LS-NEXT = L-DIST + 1
                     CALL "FLUID-SLOPE" USING L-DIM LS-NX L-Y LS-NZ LS-NEXT LS-OPP L-FLUID L-FIND LS-SUB
                     IF LS-SUB < L-BEST
                         MOVE LS-SUB TO L-BEST
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLUID-SLOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-SPREAD-TO.
*> USING dimension row, x, y, z (the target cell), direction (0 down, others horizontal), fluid, code, amount, falling (the new state) (BINARY-LONG):
*> spreadTo (2.8): lava falling onto water that is a liquid block makes stone when the table has "minecraft:stone"; otherwise the new state is written
*> (flags 3, which schedules its tick through onPlace). The block it replaces drops nothing in this core.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIRECTION L-FLUID L-CODE L-AMOUNT L-FALLING.
     CALL "FLUID-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF L-FLUID = 2 AND L-DIRECTION = 0 AND WS-F = 1
         MOVE 0 TO WS-STONE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
             IF CB-KEY(WS-I) = "minecraft:stone"
                 MOVE CB-DEFAULT-STATE(WS-I) TO WS-STONE
             END-IF
         END-PERFORM
         IF WS-STONE > 0
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STONE WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
         GOBACK
     END-IF
     CALL "FLUID-PUT" USING L-DIM L-X L-Y L-Z L-FLUID L-CODE L-AMOUNT L-FALLING
     GOBACK.
 END PROGRAM FLUID-SPREAD-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-SPREAD.
*> USING dimension row, x, y, z, fluid (BINARY-LONG), kind, amount, falling of the cell (BINARY-LONG): spread (2.4), spreadToSides and getSpread (2.5)
*> of the cell at the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRS                PIC X(4) VALUE "2534".
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-FIND                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-B-F                 BINARY-LONG.
 01 WS-B-KIND              BINARY-LONG.
 01 WS-B-AMOUNT            BINARY-LONG.
 01 WS-B-HOLDS             BINARY-LONG.
 01 WS-SOURCES             BINARY-LONG.
 01 WS-MAY                 BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-HOLE                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-NEW-AMOUNT          BINARY-LONG.
 01 WS-NEW-FALLING         BINARY-LONG.
 01 WS-WATER-IN            BINARY-LONG.
 01 WS-SIDE-AMOUNT         BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE 1000.
 01 WS-DIST                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OPP                 BINARY-LONG.
 01 WS-SLOPE-FROM          BINARY-LONG.
 01 WS-MAP.
    05 WS-M OCCURS 4 TIMES.
       10 WS-M-ON          BINARY-LONG.
       10 WS-M-X           BINARY-LONG.
       10 WS-M-Z           BINARY-LONG.
       10 WS-M-CODE        BINARY-LONG.
       10 WS-M-AMOUNT      BINARY-LONG.
       10 WS-M-FALLING     BINARY-LONG.
       10 WS-M-DIR         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-FALLING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLUID L-KIND L-AMOUNT L-FALLING.
     IF L-KIND = 0
         GOBACK
     END-IF
     CALL "FL-DELAY" USING L-FLUID WS-FAST WS-DELAY WS-FIND WS-DROP
     MOVE 0 TO WS-SOURCES
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE WS-DIRS(WS-D:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-DIR
         CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "FLUID-CELL" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-F = L-FLUID AND (WS-KIND = 2 OR WS-KIND = 4)
             ADD 1 TO WS-SOURCES
         END-IF
     END-PERFORM
*>   The cell below.
     COMPUTE WS-BY = L-Y - 1
     CALL "FLUID-CELL" USING L-DIM L-X WS-BY L-Z WS-STATE WS-B-F WS-B-KIND WS-B-AMOUNT WS-FALLING WS-SOLID WS-B-HOLDS
     MOVE 0 TO WS-MAY
     IF WS-B-HOLDS = 1 AND NOT (WS-B-F = L-FLUID AND (WS-B-KIND = 2 OR WS-B-KIND = 4))
         MOVE 1 TO WS-MAY
     END-IF
     MOVE 0 TO WS-WATER-IN
     IF L-FLUID = 1
         MOVE 1 TO WS-WATER-IN
     END-IF
     MOVE 0 TO WS-REPLACE
     IF WS-MAY = 1
         CALL "FL-REPLACEABLE" USING WS-B-F WS-ONE WS-WATER-IN WS-B-AMOUNT WS-REPLACE
     END-IF
     MOVE 1 TO WS-HOLD
     MOVE 0 TO WS-HOLE
     IF WS-B-HOLDS = 1 OR WS-B-F = L-FLUID
         MOVE 1 TO WS-HOLE
     END-IF
     MOVE 0 TO WS-SOURCE
     IF L-KIND = 2 OR L-KIND = 4
         MOVE 1 TO WS-SOURCE
     END-IF
     CALL "FL-SPREAD-DECIDE" USING WS-MAY WS-REPLACE WS-HOLD WS-SOURCES WS-SOURCE WS-HOLE WS-ACTION
     IF WS-ACTION = 1 OR WS-ACTION = 2
         CALL "FLUID-NEW" USING L-DIM L-X WS-BY L-Z L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
         CALL "FLUID-SPREAD-TO" USING L-DIM L-X WS-BY L-Z WS-DOWN L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
     END-IF
     IF WS-ACTION = 1
         GOBACK
     END-IF
     IF WS-ACTION = 0
         GOBACK
     END-IF
*>   spreadToSides.
     CALL "FL-SIDES" USING L-AMOUNT L-FALLING WS-DROP WS-SIDE-AMOUNT WS-GO
     IF WS-GO = 0
         GOBACK
     END-IF
     MOVE 1000 TO WS-MIN
     INITIALIZE WS-MAP
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE WS-DIRS(WS-D:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-DIR
         CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "FLUID-CELL" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-HOLDS = 1 AND NOT (WS-F = L-FLUID AND (WS-KIND = 2 OR WS-KIND = 4))
             CALL "FLUID-NEW" USING L-DIM WS-NX L-Y WS-NZ L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
             COMPUTE WS-BY = L-Y - 1
             CALL "FLUID-CELL" USING L-DIM WS-NX WS-BY WS-NZ WS-STATE WS-B-F WS-B-KIND WS-B-AMOUNT WS-FALLING WS-SOLID WS-B-HOLDS
             IF WS-B-HOLDS = 1 OR WS-B-F = L-FLUID
                 MOVE 0 TO WS-DIST
             ELSE
                 EVALUATE WS-DIR
                     WHEN 2
                         MOVE 3 TO WS-OPP
                     WHEN 3
                         MOVE 2 TO WS-OPP
                     WHEN 4
                         MOVE 5 TO WS-OPP
                     WHEN OTHER
                         MOVE 4 TO WS-OPP
                 END-EVALUATE
                 CALL "FLUID-SLOPE" USING L-DIM WS-NX L-Y WS-NZ WS-ONE WS-OPP L-FLUID WS-FIND WS-DIST
             END-IF
             IF WS-DIST < WS-MIN
                 INITIALIZE WS-MAP
             END-IF
             IF WS-DIST <= WS-MIN
                 CALL "FL-REPLACEABLE" USING WS-F WS-DOWN WS-WATER-IN WS-AMOUNT WS-REPLACE
                 IF WS-REPLACE = 1
                     MOVE 1 TO WS-M-ON(WS-D)
                     MOVE WS-NX TO WS-M-X(WS-D)
                     MOVE WS-NZ TO WS-M-Z(WS-D)
                     MOVE WS-CODE TO WS-M-CODE(WS-D)
                     MOVE WS-NEW-AMOUNT TO WS-M-AMOUNT(WS-D)
                     MOVE WS-NEW-FALLING TO WS-M-FALLING(WS-D)
                     MOVE WS-DIR TO WS-M-DIR(WS-D)
                 END-IF
                 MOVE WS-DIST TO WS-MIN
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         IF WS-M-ON(WS-D) = 1
             CALL "FLUID-SPREAD-TO" USING L-DIM WS-M-X(WS-D) L-Y WS-M-Z(WS-D) WS-M-DIR(WS-D) L-FLUID WS-M-CODE(WS-D)
                 WS-M-AMOUNT(WS-D) WS-M-FALLING(WS-D)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FLUID-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-TICK.
*> USING dimension row, x, y, z, fluid (1 water, 2 lava) (BINARY-LONG): FlowingFluid.tick (2.2) for the cell at the position when it still holds that
*> fluid: a flowing cell takes its new state (air, a changed state with the next tick scheduled at getSpreadDelay, or nothing), then it spreads.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-NEW-AMOUNT          BINARY-LONG.
 01 WS-NEW-FALLING         BINARY-LONG.
 01 WS-NEW-KIND            BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-FIND                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-BOTH                BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 01 WS-TALLER              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SPREAD-DELAY        BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLUID.
     CALL "FLUID-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-F NOT = L-FLUID
         GOBACK
     END-IF
     MOVE 0 TO WS-SOURCE
     IF WS-KIND = 2 OR WS-KIND = 4
         MOVE 1 TO WS-SOURCE
     END-IF
     IF WS-SOURCE = 0
         CALL "FLUID-NEW" USING L-DIM L-X L-Y L-Z L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
         MOVE 0 TO WS-EMPTY WS-SAME
         IF WS-CODE = 0
             MOVE 1 TO WS-EMPTY
         END-IF
         IF WS-CODE = 2 AND WS-NEW-AMOUNT = WS-AMOUNT AND WS-NEW-FALLING = WS-FALLING
             MOVE 1 TO WS-SAME
         END-IF
         CALL "FL-TICK-DECIDE" USING WS-SOURCE WS-EMPTY WS-SAME WS-ACTION
         CALL "FL-DELAY" USING L-FLUID WS-FAST WS-DELAY WS-FIND WS-DROP
         MOVE 1 TO WS-BOTH
         MOVE 0 TO WS-STILL WS-TALLER
         IF WS-FALLING = 0 AND WS-NEW-FALLING = 0
             MOVE 1 TO WS-STILL
         END-IF
         IF WS-NEW-AMOUNT > WS-AMOUNT
             MOVE 1 TO WS-TALLER
         END-IF
*>       The core has no level random: nextInt(4) is a hash of the game time and the position.
         COMPUTE WS-HASH = CW-TICKS * 7 + L-X * 3 + L-Z * 5 + L-Y
         COMPUTE WS-DRAW = FUNCTION MOD(WS-HASH, 4)
         CALL "FL-SPREAD-DELAY" USING L-FLUID WS-FAST WS-BOTH WS-STILL WS-TALLER WS-DRAW WS-SPREAD-DELAY
         EVALUATE WS-ACTION
             WHEN 1
                 CALL "FLUID-PUT" USING L-DIM L-X L-Y L-Z L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
                 MOVE 0 TO WS-KIND WS-AMOUNT WS-FALLING
             WHEN 2
                 CALL "FLUID-PUT" USING L-DIM L-X L-Y L-Z L-FLUID WS-CODE WS-NEW-AMOUNT WS-NEW-FALLING
                 CALL "FLUID-SCHEDULE" USING L-DIM L-X L-Y L-Z L-FLUID WS-SPREAD-DELAY
                 COMPUTE WS-KIND = L-FLUID * 2 - 1
                 MOVE WS-NEW-AMOUNT TO WS-AMOUNT
                 MOVE WS-NEW-FALLING TO WS-FALLING
         END-EVALUATE
     END-IF
     CALL "FLUID-SPREAD" USING L-DIM L-X L-Y L-Z L-FLUID WS-KIND WS-AMOUNT WS-FALLING
     GOBACK.
 END PROGRAM FLUID-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-HOOK RECURSIVE.
*> USING hook kind (1 onPlace, 3 neighborChanged, 4 updateShape, 9 scheduled fluid tick), dimension row, x, y, z, state, a, b (BINARY-LONG; as BU-HOOK
*> passes them), out state: the liquid block's hooks (2.1): onPlace and neighborChanged schedule the fluid's tick after shouldSpreadLiquid (water
*> always; lava reacts with water by writing obsidian, cobblestone or basalt when the table has them, 3.1); updateShape schedules the tick when this
*> state or the changing neighbour's state holds a source; the scheduled tick runs FLUID-TICK. Anything that is not a liquid block is left alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-N-F                 BINARY-LONG.
 01 WS-N-KIND              BINARY-LONG.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-FIND                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-S-FLUID             BINARY-LONG.
 01 WS-S-KIND              BINARY-LONG.
 01 WS-S-AMOUNT            BINARY-LONG.
 01 WS-S-FALLING           BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-IN.
    05 WS-WATER-FLAG       BINARY-LONG OCCURS 5 TIMES.
    05 WS-ICE-FLAG         BINARY-LONG OCCURS 5 TIMES.
 01 WS-BELOW-SOIL          BINARY-LONG VALUE 0.
 01 WS-SOIL-KEY            PIC X(48) VALUE "minecraft:soul_soil".
 01 WS-ICE-KEY             PIC X(48) VALUE "minecraft:blue_ice".
 01 WS-LAVA-SOURCE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-FIZZ                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ORDER               PIC X(5) VALUE "15324".
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     IF L-KIND = 9
         CALL "FLUID-TICK" USING L-DIM L-X L-Y L-Z L-STATE
         GOBACK
     END-IF
     CALL "FLUID-OF-STATE" USING L-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
     IF WS-FLUID = 0
         GOBACK
     END-IF
     CALL "FL-DELAY" USING WS-FLUID WS-FAST WS-DELAY WS-FIND WS-DROP
     EVALUATE TRUE
         WHEN L-KIND = 4
             CALL "FLUID-OF-STATE" USING L-B WS-N-F WS-N-KIND WS-AMOUNT WS-FALLING
             IF WS-KIND = 2 OR WS-KIND = 4 OR WS-N-KIND = 2 OR WS-N-KIND = 4
                 CALL "FLUID-SCHEDULE" USING L-DIM L-X L-Y L-Z WS-FLUID WS-DELAY
             END-IF
         WHEN L-KIND = 1 OR L-KIND = 3
             MOVE 1 TO WS-SPREAD
             IF WS-FLUID = 2
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
                     MOVE WS-ORDER(WS-D:1) TO WS-DIGIT
                     MOVE WS-DIGIT TO WS-I
                     CALL "BU-DIRECTION" USING WS-I WS-DX WS-DY WS-DZ
                     COMPUTE WS-NX = L-X + WS-DX
                     COMPUTE WS-NY = L-Y + WS-DY
                     COMPUTE WS-NZ = L-Z + WS-DZ
                     CALL "FLUID-CELL" USING L-DIM WS-NX WS-NY WS-NZ WS-STATE WS-S-FLUID WS-S-KIND WS-S-AMOUNT WS-S-FALLING WS-SOLID
                         WS-HOLDS
                     MOVE 0 TO WS-WATER-FLAG(WS-D)
                     CALL "FLUID-KEY-IS" USING WS-STATE WS-ICE-KEY WS-ICE-FLAG(WS-D)
                     IF WS-S-FLUID = 1
                         MOVE 1 TO WS-WATER-FLAG(WS-D)
                     END-IF
                 END-PERFORM
                 COMPUTE WS-NY = L-Y - 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-NY L-Z WS-STATE
                 CALL "FLUID-KEY-IS" USING WS-STATE WS-SOIL-KEY WS-BELOW-SOIL
                 MOVE 0 TO WS-LAVA-SOURCE
                 IF WS-KIND = 4
                     MOVE 1 TO WS-LAVA-SOURCE
                 END-IF
                 CALL "FL-SHOULD-SPREAD" USING WS-IN WS-FLUID WS-BELOW-SOIL WS-LAVA-SOURCE WS-ACTION WS-SPREAD
                 IF WS-ACTION > 0
                     EVALUATE WS-ACTION
                         WHEN 1
                             MOVE "minecraft:obsidian" TO WS-KEY
                         WHEN 2
                             MOVE "minecraft:cobblestone" TO WS-KEY
                         WHEN OTHER
                             MOVE "minecraft:basalt" TO WS-KEY
                     END-EVALUATE
                     MOVE 0 TO WS-STONE
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
                         IF CB-KEY(WS-I) = WS-KEY
                             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STONE
                         END-IF
                     END-PERFORM
                     IF WS-STONE > 0
                         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STONE WS-FLAGS WS-BUDGET WS-RESULT
                     END-IF
                 END-IF
             END-IF
             IF WS-SPREAD = 1
                 CALL "FLUID-SCHEDULE" USING L-DIM L-X L-Y L-Z WS-FLUID WS-DELAY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FLUID-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLUID-FLOW-AT.
*> USING dimension row, x, y, z (BINARY-LONG), flow x, y, z out (FLOAT-LONG): FluidState.getFlow of the fluid in the cell (1.4) over the core tables: each
*> horizontal side (north, east, south, west) that is empty or the same fluid adds its step times the delta of FL-FLOW-DELTA (the sides' own heights,
*> the same fluid below an empty side, the drop of 0.8888889); a side blocks the flow when its block has a collision (the tag blocks_fluid_flow is the set of
*> blocks that block motion: an approximation named here); a falling cell beside a solid face (a side, or the cell above a side; ice is not one) is
*> turned down (FL-FLOW). The cell without a fluid has no flow.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DXT.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DXV REDEFINES WS-DXT.
    05 WS-DX               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZT.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZV REDEFINES WS-DZT.
    05 WS-DZ               BINARY-LONG OCCURS 4 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-N-STATE             BINARY-LONG.
 01 WS-N-FLUID             BINARY-LONG.
 01 WS-N-KIND              BINARY-LONG.
 01 WS-N-AMOUNT            BINARY-LONG.
 01 WS-N-FALLING           BINARY-LONG.
 01 WS-N-SOLID             BINARY-LONG.
 01 WS-N-HOLDS             BINARY-LONG.
 01 WS-A-STATE             BINARY-LONG.
 01 WS-A-FLUID             BINARY-LONG.
 01 WS-A-KIND              BINARY-LONG.
 01 WS-A-AMOUNT            BINARY-LONG.
 01 WS-A-FALLING           BINARY-LONG.
 01 WS-A-SOLID             BINARY-LONG.
 01 WS-A-HOLDS             BINARY-LONG.
 01 WS-AFFECTS             BINARY-LONG.
 01 WS-BAFFECTS            BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-ICE2                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-ANY-SOLID           BINARY-LONG.
 01 WS-UP                  BINARY-LONG VALUE 0.
 01 WS-KEY-ICE             PIC X(48) VALUE "minecraft:ice".
 01 WS-KEY-FROSTED         PIC X(48) VALUE "minecraft:frosted_ice".
 01 WS-OWN                 FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-BH                  FLOAT-LONG.
 01 WS-DELTA               FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FX L-FY L-FZ.
     MOVE 0 TO L-FX L-FY L-FZ
     CALL "FLUID-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-FLUID = 0
         GOBACK
     END-IF
     CALL "FL-OWN-HEIGHT" USING WS-AMOUNT WS-OWN
     MOVE 0 TO WS-SX WS-SZ WS-ANY-SOLID
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         COMPUTE WS-NX = L-X + WS-DX(WS-D)
         COMPUTE WS-NZ = L-Z + WS-DZ(WS-D)
         CALL "FLUID-CELL" USING L-DIM WS-NX L-Y WS-NZ WS-N-STATE WS-N-FLUID WS-N-KIND WS-N-AMOUNT WS-N-FALLING
             WS-N-SOLID WS-N-HOLDS
         MOVE 0 TO WS-AFFECTS WS-SAME WS-H
         IF WS-N-FLUID = 0 OR WS-N-FLUID = WS-FLUID
             MOVE 1 TO WS-AFFECTS
         END-IF
         IF WS-N-FLUID = WS-FLUID
             MOVE 1 TO WS-SAME
             CALL "FL-OWN-HEIGHT" USING WS-N-AMOUNT WS-H
         END-IF
*>       The fluid below the side (for a side that holds none).
         COMPUTE WS-NY = L-Y - 1
         CALL "FLUID-CELL" USING L-DIM WS-NX WS-NY WS-NZ WS-A-STATE WS-A-FLUID WS-A-KIND WS-A-AMOUNT WS-A-FALLING
             WS-A-SOLID WS-A-HOLDS
         MOVE 0 TO WS-BAFFECTS WS-BH
         IF WS-A-FLUID = 0 OR WS-A-FLUID = WS-FLUID
             MOVE 1 TO WS-BAFFECTS
         END-IF
         IF WS-A-FLUID = WS-FLUID
             CALL "FL-OWN-HEIGHT" USING WS-A-AMOUNT WS-BH
         END-IF
         CALL "FL-FLOW-DELTA" USING WS-AFFECTS WS-H WS-N-SOLID WS-BAFFECTS WS-BH WS-OWN WS-DELTA
         COMPUTE WS-SX = WS-SX + WS-DX(WS-D) * WS-DELTA
         COMPUTE WS-SZ = WS-SZ + WS-DZ(WS-D) * WS-DELTA
         IF WS-FALLING = 1
*>           isSolidFace of the side and of the cell above it (a horizontal direction, so never the UP case).
             CALL "FLUID-KEY-IS" USING WS-N-STATE WS-KEY-ICE WS-ICE
             CALL "FLUID-KEY-IS" USING WS-N-STATE WS-KEY-FROSTED WS-ICE2
             COMPUTE WS-ICE = FUNCTION MAX(WS-ICE, WS-ICE2)
             CALL "FL-SOLID-FACE" USING WS-SAME WS-UP WS-ICE WS-N-SOLID WS-OUT
             IF WS-OUT = 1
                 MOVE 1 TO WS-ANY-SOLID
             END-IF
             COMPUTE WS-NY = L-Y + 1
             CALL "FLUID-CELL" USING L-DIM WS-NX WS-NY WS-NZ WS-A-STATE WS-A-FLUID WS-A-KIND WS-A-AMOUNT
                 WS-A-FALLING WS-A-SOLID WS-A-HOLDS
             MOVE 0 TO WS-SAME
             IF WS-A-FLUID = WS-FLUID
                 MOVE 1 TO WS-SAME
             END-IF
             CALL "FLUID-KEY-IS" USING WS-A-STATE WS-KEY-ICE WS-ICE
             CALL "FLUID-KEY-IS" USING WS-A-STATE WS-KEY-FROSTED WS-ICE2
             COMPUTE WS-ICE = FUNCTION MAX(WS-ICE, WS-ICE2)
             CALL "FL-SOLID-FACE" USING WS-SAME WS-UP WS-ICE WS-A-SOLID WS-OUT
             IF WS-OUT = 1
                 MOVE 1 TO WS-ANY-SOLID
             END-IF
         END-IF
     END-PERFORM
     CALL "FL-FLOW" USING WS-SX WS-SZ WS-FALLING WS-ANY-SOLID L-FX L-FY L-FZ
     GOBACK.
 END PROGRAM FLUID-FLOW-AT.

