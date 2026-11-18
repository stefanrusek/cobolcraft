*> Boats and rafts, with and without chest (docs/protocol/21 section 8.8; 44 part 8 section 3: 3.1 constants, 3.2 the tick, 3.3 the status, 3.4 floatBoat, 3.6 the seat, 2 and 3.9 hurt,
*> destroy and boarding). Each boat is a tracker row of its entity type (EN-BT-KIND 1 boat or raft, 2 chest boat or raft; EN-HEALTH 1 marks it alive for the damage entry points
*> and EN-SADDLE 1 that the rider's client moves it with Move Vehicle, see MOB-RIDE-MOVE). The rider is a player row (EN-RIDER of the boat, EN-VEHICLE of the player's entity).
*> Open (not built): a second passenger, the paddle input and animation, pushing and loading of other entities, bubble columns, leads, the ground friction scan (every solid cell under
*> the boat has friction 0.6), the dismount location search, the chest menu of a chest boat and the scattering of its contents, the boat item and the dispenser, explosions, saving.
*>   BOAT-KIND USING type, kind out                         0 not a boat, 1 boat or raft, 2 chest boat or chest raft
*>   BOAT-SPAWN USING dim, x, y, z, yaw (FLOAT-LONG), entity key (PIC X(112)), row out    a boat of that type (row 0 when the key is no boat)
*>   BOAT-STATUS USING row, status out                      3.3: 0 in water, 1 under water, 2 under flowing water, 3 on land, 4 in air; EN-BT-WLEVEL is the water level
*>   BOAT-FLOAT USING row                                   3.4 floatBoat
*>   BOAT-STEP USING row, BOAT-TICK                         3.2 the tick of one boat / of every boat (CORE-TICK, after the falling blocks)
*>   BOAT-SYNC USING row                                    the rider takes the seat of 3.6
*>   BOAT-USE USING player row, boat row, used out          boarding (3.9 interact)
*>   BOAT-HURT USING row, amount, attacker player row       2: hurtServer, destroy when the damage exceeds 40

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOB181.
 01 WS-KEY                 PIC X(24).
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TAIL5               PIC X(5).
 01 WS-TAIL11              PIC X(11).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND.
     MOVE 0 TO L-KIND
     COMPUTE WS-ROW = L-TYPE + 1
     MOVE M1-KEY(WS-ROW) TO WS-KEY
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     MOVE SPACES TO WS-TAIL5 WS-TAIL11
     IF WS-N >= 11
         MOVE WS-KEY(WS-N - 10:11) TO WS-TAIL11
     END-IF
     IF WS-N >= 5
         MOVE WS-KEY(WS-N - 4:5) TO WS-TAIL5
     END-IF
     IF WS-TAIL5 = "_boat" OR WS-TAIL5 = "_raft"
         MOVE 1 TO L-KIND
     END-IF
     IF WS-TAIL11 = "_chest_boat" OR WS-TAIL11 = "_chest_raft"
         MOVE 2 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM BOAT-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-KEY                  PIC X(112).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-YAW L-KEY L-ROW.
     MOVE 0 TO L-ROW
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     IF WS-KIND > 0
         CALL "ENTITY-ALLOC" USING L-ROW
         CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
         MOVE WS-TYPE TO EN-TYPE(L-ROW)
         CALL "ENTITY-SET-UUID" USING L-ROW
         MOVE L-DIM TO EN-DIM(L-ROW)
         MOVE L-X TO EN-X(L-ROW)
         MOVE L-Y TO EN-Y(L-ROW)
         MOVE L-Z TO EN-Z(L-ROW)
         MOVE L-YAW TO EN-YAW(L-ROW)
         MOVE WS-KIND TO EN-BT-KIND(L-ROW)
         MOVE 1 TO EN-HEALTH(L-ROW) EN-SADDLE(L-ROW) EN-BT-HDIR(L-ROW)
         MOVE 5 TO EN-BT-STATUS(L-ROW)
         CALL "ENTITY-TRACK" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM BOAT-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-FLUID.
*> USING dim, cell x, y, z (BINARY-LONG), height out (FLOAT-LONG), kind out (0 no water, 1 flowing, 2 source): the water of a cell and its height: 1 when water is above it, else the
*> fluid amount over 9 (a source 8 / 9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-FLUID2              BINARY-LONG.
 01 WS-KIND2               BINARY-LONG.
 01 WS-AMOUNT2             BINARY-LONG.
 01 WS-FALLING2            BINARY-LONG.
 01 WS-SOLID2              BINARY-LONG.
 01 WS-HOLDS2              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HEIGHT L-KIND.
     MOVE 0 TO L-HEIGHT L-KIND
     CALL "FLUID-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-FLUID = 1
         MOVE 1 TO L-KIND
         IF WS-KIND = 2
             MOVE 2 TO L-KIND
         END-IF
         COMPUTE WS-ABOVE = L-Y + 1
         CALL "FLUID-CELL" USING L-DIM L-X WS-ABOVE L-Z WS-STATE2 WS-FLUID2 WS-KIND2 WS-AMOUNT2 WS-FALLING2 WS-SOLID2 WS-HOLDS2
         IF WS-FLUID2 = 1
             MOVE 1 TO L-HEIGHT
         ELSE
             COMPUTE L-HEIGHT = WS-AMOUNT / 9
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BOAT-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-STATUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-UNDER               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CELL-TOP            FLOAT-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-LAND                BINARY-LONG.
 01 WS-BELOW               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATUS.
     COMPUTE WS-MINX = EN-X(L-ROW) - 0.6875
     COMPUTE WS-MAXX = EN-X(L-ROW) + 0.6875
     MOVE EN-Y(L-ROW) TO WS-MINY
     COMPUTE WS-MAXY = EN-Y(L-ROW) + 0.5625
     COMPUTE WS-MINZ = EN-Z(L-ROW) - 0.6875
     COMPUTE WS-MAXZ = EN-Z(L-ROW) + 0.6875
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-MINX)
     COMPUTE WS-X1 = 0 - FUNCTION INTEGER(0 - WS-MAXX) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-MINZ)
     COMPUTE WS-Z1 = 0 - FUNCTION INTEGER(0 - WS-MAXZ) - 1
*>   3.3 step 1: under water.
     COMPUTE WS-TOP = WS-MAXY + 0.001
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-MAXY)
     COMPUTE WS-Y1 = 0 - FUNCTION INTEGER(0 - WS-TOP) - 1
     MOVE 0 TO WS-UNDER WS-DONE
     PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y1
         PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1
             PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1
                 CALL "BOAT-FLUID" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-H WS-WK
                 COMPUTE WS-CELL-TOP = WS-CY + WS-H
                 IF WS-WK > 0 AND WS-TOP < WS-CELL-TOP
                     IF WS-WK = 2
                         MOVE 1 TO WS-UNDER
                     ELSE
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-DONE = 1
             MOVE 2 TO L-STATUS
             MOVE WS-MAXY TO EN-BT-WLEVEL(L-ROW)
             GOBACK
         WHEN WS-UNDER = 1
             MOVE 1 TO L-STATUS
             MOVE WS-MAXY TO EN-BT-WLEVEL(L-ROW)
             GOBACK
     END-EVALUATE
*>   Step 2: in water.
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-MINY)
     COMPUTE WS-TOP = WS-MINY + 0.001
     COMPUTE WS-Y1 = 0 - FUNCTION INTEGER(0 - WS-TOP) - 1
     MOVE -1000000000 TO EN-BT-WLEVEL(L-ROW)
     MOVE 0 TO WS-IN
     PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y1
         PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1
             PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1
                 CALL "BOAT-FLUID" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-H WS-WK
                 COMPUTE WS-CELL-TOP = WS-CY + WS-H
                 IF WS-WK > 0
                     IF WS-CELL-TOP > EN-BT-WLEVEL(L-ROW)
                         MOVE WS-CELL-TOP TO EN-BT-WLEVEL(L-ROW)
                     END-IF
                     IF WS-MINY < WS-CELL-TOP
                         MOVE 1 TO WS-IN
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-IN = 1
         MOVE 0 TO L-STATUS
         GOBACK
     END-IF
*>   Steps 3 and 4: on land when a solid cell is under the boat (friction 0.6, the block friction scan is open), else in air.
     MOVE 4 TO L-STATUS
     COMPUTE WS-BELOW = WS-MINY - 0.001
     COMPUTE WS-CY = FUNCTION INTEGER(WS-BELOW)
     PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1
         PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1
             CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
             IF WS-SOLID = 1
                 MOVE 3 TO L-STATUS
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BOAT-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-LEVEL-ABOVE.
*> USING row, level out (FLOAT-LONG): getWaterLevelAbove (3.3): from y = floor(maxY) up to ceil(maxY - lastYd) - 1 the largest water height f of the columns; the first y with f < 1 gives y + f;
*> else ceil(maxY - lastYd) + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEVEL                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEVEL.
     COMPUTE WS-MAXY = EN-Y(L-ROW) + 0.5625
     COMPUTE WS-X0 = FUNCTION INTEGER(EN-X(L-ROW) - 0.6875)
     COMPUTE WS-X1 = 0 - FUNCTION INTEGER(0 - (EN-X(L-ROW) + 0.6875)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(EN-Z(L-ROW) - 0.6875)
     COMPUTE WS-Z1 = 0 - FUNCTION INTEGER(0 - (EN-Z(L-ROW) + 0.6875)) - 1
     COMPUTE WS-LIMIT = WS-MAXY - EN-BT-LASTYD(L-ROW)
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-MAXY)
     COMPUTE WS-Y1 = 0 - FUNCTION INTEGER(0 - WS-LIMIT) - 1
     COMPUTE L-LEVEL = WS-Y1 + 2
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y1 OR WS-FOUND = 1
         MOVE 0 TO WS-F
         PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1
             PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1
                 CALL "BOAT-FLUID" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-H WS-WK
                 IF WS-H > WS-F
                     MOVE WS-H TO WS-F
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-F < 1
             COMPUTE L-LEVEL = WS-CY + WS-F
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOAT-LEVEL-ABOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-FRICTION.
*> USING row, friction out (FLOAT-LONG), cells out (BINARY-LONG): 44 part 8 section 3.3 getGroundFriction, the average block friction under the boat: the cells that the thin slab
*> (minX, minY - 0.001, minZ) to (maxX, minY, maxZ) overlaps and whose block is solid. The margin cells of the doc's scan (one more column and row all round, corners left out) can never
*> overlap the slab with a full-cell shape, so only the overlapped cells are visited; an empty count gives 0 (the status is then IN_AIR).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FRICTION             FLOAT-LONG.
 01 L-CELLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FRICTION L-CELLS.
     MOVE 0 TO L-FRICTION L-CELLS WS-SUM
     COMPUTE WS-LOW = EN-X(L-ROW) - 0.6875
     COMPUTE WS-MINX = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-HIGH = EN-X(L-ROW) + 0.6875
     COMPUTE WS-MAXX = FUNCTION INTEGER(WS-HIGH)
     IF WS-MAXX = WS-HIGH
         SUBTRACT 1 FROM WS-MAXX
     END-IF
     COMPUTE WS-LOW = EN-Z(L-ROW) - 0.6875
     COMPUTE WS-MINZ = FUNCTION INTEGER(WS-LOW)
     COMPUTE WS-HIGH = EN-Z(L-ROW) + 0.6875
     COMPUTE WS-MAXZ = FUNCTION INTEGER(WS-HIGH)
     IF WS-MAXZ = WS-HIGH
         SUBTRACT 1 FROM WS-MAXZ
     END-IF
     COMPUTE WS-PY = EN-Y(L-ROW) - 0.001
     COMPUTE WS-CY = FUNCTION INTEGER(WS-PY)
     COMPUTE WS-PY = WS-CY + 1
     PERFORM VARYING WS-CZ FROM WS-MINZ BY 1 UNTIL WS-CZ > WS-MAXZ
         PERFORM VARYING WS-CX FROM WS-MINX BY 1 UNTIL WS-CX > WS-MAXX
             CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
             IF WS-SOLID = 1
                 COMPUTE WS-PX = WS-CX + 0.5
                 COMPUTE WS-PZ = WS-CZ + 0.5
                 CALL "IP-FRICTION" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-F
                 ADD WS-F TO WS-SUM
                 ADD 1 TO L-CELLS
             END-IF
         END-PERFORM
     END-PERFORM
     IF L-CELLS > 0
         COMPUTE L-FRICTION = WS-SUM / L-CELLS
     END-IF
     GOBACK.
 END PROGRAM BOAT-FRICTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-FLOAT.
*> USING row, old status, status (BINARY-LONG): floatBoat (3.4): the re-entry from the air (old status 4, status in water), else the drag, the gravity term and the buoyancy of the status.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-BUOYANCY            FLOAT-LONG.
 01 WS-DRAG                FLOAT-LONG.
 01 WS-GRAVITY             FLOAT-LONG.
 01 WS-LEVEL               FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OLD L-STATUS.
*>   3.4 step 1: the re-entry from the air.
     IF L-OLD = 4 AND L-STATUS NOT = 4 AND L-STATUS NOT = 3
         COMPUTE EN-BT-WLEVEL(L-ROW) = EN-Y(L-ROW) + 0.5625
         CALL "BOAT-LEVEL-ABOVE" USING L-ROW WS-LEVEL
         COMPUTE WS-Y = WS-LEVEL - 0.5625 + 0.101
         CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) EN-X(L-ROW) WS-Y EN-Z(L-ROW) WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-Y TO EN-Y(L-ROW)
             MOVE 0 TO EN-VY(L-ROW) EN-BT-LASTYD(L-ROW)
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO WS-BUOYANCY
     MOVE 0.9 TO WS-DRAG
     MOVE -0.04 TO WS-GRAVITY
     EVALUATE L-STATUS
         WHEN 0
             COMPUTE WS-BUOYANCY = (EN-BT-WLEVEL(L-ROW) - EN-Y(L-ROW)) / 0.5625
         WHEN 2
             MOVE -0.0007 TO WS-GRAVITY
         WHEN 1
             MOVE 0.01 TO WS-BUOYANCY
             MOVE 0.45 TO WS-DRAG
         WHEN 3
             CALL "BOAT-FRICTION" USING L-ROW WS-DRAG WS-CELLS
     END-EVALUATE
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * WS-DRAG
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * WS-DRAG
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-GRAVITY
     IF WS-BUOYANCY > 0
         COMPUTE EN-VY(L-ROW) = (EN-VY(L-ROW) + WS-BUOYANCY * 0.0615385) * 0.75
     END-IF
     GOBACK.
 END PROGRAM BOAT-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-MOVE.
*> USING row: Entity.move(SELF, velocity) of a boat: the box (ENTITY-BOX-HITS) against the solid cells, axis by axis (x, z, then y: a blocked axis keeps its position and loses its
*> speed; falling onto a block stands the boat on it). The viewers are told by GI-SEND-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EN-ON-GROUND(L-ROW)
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X EN-Y(L-ROW) EN-Z(L-ROW) WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE EN-X(L-ROW) TO WS-X
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X EN-Y(L-ROW) WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 1
         IF EN-VY(L-ROW) < 0
             MOVE 1 TO EN-ON-GROUND(L-ROW)
             COMPUTE WS-Y = WS-TOP + 1
         ELSE
             MOVE EN-Y(L-ROW) TO WS-Y
         END-IF
         MOVE 0 TO EN-VY(L-ROW)
     END-IF
     CALL "IP-ENSURE" USING L-ROW
     CALL "GI-SEND-MOVE" USING L-ROW WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM BOAT-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OLD                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-BT-STATUS(L-ROW) TO WS-OLD
     CALL "BOAT-STATUS" USING L-ROW WS-STATUS
     IF WS-STATUS = 1 OR WS-STATUS = 2
         ADD 1 TO EN-BT-OOC(L-ROW)
     ELSE
         MOVE 0 TO EN-BT-OOC(L-ROW)
     END-IF
     IF EN-BT-OOC(L-ROW) >= 60 AND EN-RIDER(L-ROW) > 0
         CALL "MOB-RIDE-STOP" USING L-ROW
     END-IF
     IF EN-BT-HURT(L-ROW) > 0
         SUBTRACT 1 FROM EN-BT-HURT(L-ROW)
     END-IF
     IF EN-BT-DAMAGE(L-ROW) > 0
         SUBTRACT 1 FROM EN-BT-DAMAGE(L-ROW)
     END-IF
*>   A boat with a rider is moved by the rider's client (Move Vehicle); alone it is the server's.
     IF EN-RIDER(L-ROW) = 0
         CALL "BOAT-FLOAT" USING L-ROW WS-OLD WS-STATUS
         CALL "BOAT-MOVE" USING L-ROW
         MOVE EN-VY(L-ROW) TO EN-BT-LASTYD(L-ROW)
     ELSE
         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
     END-IF
     MOVE WS-STATUS TO EN-BT-STATUS(L-ROW)
     GOBACK.
 END PROGRAM BOAT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-TICK.
*> No parameters: BOAT-STEP of every boat (CORE-TICK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-BT-KIND(WS-I) > 0
             CALL "BOAT-STEP" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOAT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-SYNC.
*> USING row: the rider takes the seat of 3.6: (0, rideHeight, zOffset) turned by the boat's yaw about the vertical axis, the ride height being height / 3 = 0.1875 for a boat and
*> 0.5 for a raft, less the player's own attachment 0.6, and the offset 0.15 for a chest boat or raft. The rider's entity is moved for the other viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOB181.
 01 WS-RIDER               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-OFFSET              FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-N                   BINARY-LONG.
 01 WS-TAIL5               PIC X(5).
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-RIDER(L-ROW) TO WS-RIDER
     COMPUTE WS-ROW = EN-TYPE(L-ROW) + 1
     MOVE M1-KEY(WS-ROW) TO WS-KEY
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     MOVE WS-KEY(WS-N - 4:5) TO WS-TAIL5
     MOVE 0.1875 TO WS-HEIGHT
     IF WS-TAIL5 = "_raft"
         MOVE 0.5 TO WS-HEIGHT
     END-IF
     MOVE 0 TO WS-OFFSET
     IF EN-BT-KIND(L-ROW) = 2
         MOVE 0.15 TO WS-OFFSET
     END-IF
     COMPUTE WS-ANGLE = EN-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE PL-X(WS-RIDER) = EN-X(L-ROW) - WS-OFFSET * FUNCTION SIN(WS-ANGLE)
     COMPUTE PL-Y(WS-RIDER) = EN-Y(L-ROW) + WS-HEIGHT - 0.6
     COMPUTE PL-Z(WS-RIDER) = EN-Z(L-ROW) + WS-OFFSET * FUNCTION COS(WS-ANGLE)
     CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-RIDER) PL-X(WS-RIDER) PL-Y(WS-RIDER) PL-Z(WS-RIDER)
         PL-YAW(WS-RIDER) PL-PITCH(WS-RIDER) WS-GROUND
     GOBACK.
 END PROGRAM BOAT-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-USE.
*> USING player row, boat row, used out: the main hand of an alive player on a boat (3.9 interact): within the interaction reach of the boat's box, the player not sneaking, riding
*> nothing, the boat free (one passenger here), not out of control (EN-BT-OOC below 60) and not under water: the player boards (Set Passengers to the viewers). A chest boat opens its menu
*> when the player sneaks (open: it does nothing). used is 1 when the player boarded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-X                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-USED.
     MOVE 0 TO L-USED
     IF EN-BT-KIND(L-ROW) = 0
         GOBACK
     END-IF
     COMPUTE WS-EYE = PL-Y(L-PLAYER) + RULE-ATTACK-EYE-MILLI / 1000
     COMPUTE WS-DX = PL-X(L-PLAYER) - FUNCTION MAX(EN-X(L-ROW) - 0.6875, FUNCTION MIN(PL-X(L-PLAYER), EN-X(L-ROW) + 0.6875))
     COMPUTE WS-DY = WS-EYE - FUNCTION MAX(EN-Y(L-ROW), FUNCTION MIN(WS-EYE, EN-Y(L-ROW) + 0.5625))
     COMPUTE WS-DZ = PL-Z(L-PLAYER) - FUNCTION MAX(EN-Z(L-ROW) - 0.6875, FUNCTION MIN(PL-Z(L-PLAYER), EN-Z(L-ROW) + 0.6875))
     COMPUTE WS-REACH = RULE-ATTACK-REACH-MILLI / 1000
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ > WS-REACH * WS-REACH
         GOBACK
     END-IF
     IF PL-SNEAKING(L-PLAYER) = 0 AND EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) = 0 AND EN-RIDER(L-ROW) = 0
             AND EN-BT-OOC(L-ROW) < 60 AND EN-BT-STATUS(L-ROW) NOT = 1 AND EN-BT-STATUS(L-ROW) NOT = 2
         MOVE L-PLAYER TO EN-RIDER(L-ROW)
         MOVE L-ROW TO EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER))
         CALL "BOAT-SYNC" USING L-ROW
         CALL "MOB-RIDE-SEND" USING L-ROW
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM BOAT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-DATA-SEND.
*> USING row: Set Entity Data of a hurt boat to its viewers: hurt time (8), hurt direction (9) and damage (10, Float) (44 part 8 section 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 8 TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE EN-BT-HURT(L-ROW) TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE 9 TO MD-MD-INDEX
     MOVE EN-BT-HDIR(L-ROW) TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE 10 TO MD-MD-INDEX
     MOVE MD-MDS-FLOAT TO MD-MD-SERIALIZER
     MOVE EN-BT-DAMAGE(L-ROW) TO MD-MD-FLOAT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BOAT-DATA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-HURT.
*> USING row, amount (whole points), attacker player row (0 none): VehicleEntity.hurtServer (44 part 8 section 2): the hurt direction flips, the hurt time is 10, the damage grows by
*> 10 x amount and the viewers get the metadata; a non-creative attacker with the damage above 40 destroys the boat (rider off, entity gone, one boat item with the rule entity_drops);
*> a creative attacker removes it without a drop. The game event, custom names and chest contents are open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOB181.
 COPY CONTENT.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO-D              FLOAT-LONG VALUE 0.
 01 WS-ZERO-E              FLOAT-LONG VALUE 0.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 01 WS-ONE-B               BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-ATTACKER.
     COMPUTE EN-BT-HDIR(L-ROW) = 0 - EN-BT-HDIR(L-ROW)
     MOVE 10 TO EN-BT-HURT(L-ROW)
     COMPUTE EN-BT-DAMAGE(L-ROW) = EN-BT-DAMAGE(L-ROW) + L-AMOUNT * 10
     MOVE 0 TO WS-CREATIVE
     IF L-ATTACKER > 0
         IF PL-MODE(L-ATTACKER) = 1
             MOVE 1 TO WS-CREATIVE
         END-IF
     END-IF
     IF WS-CREATIVE = 0 AND EN-BT-DAMAGE(L-ROW) > 40
         IF EN-RIDER(L-ROW) > 0
             CALL "MOB-RIDE-STOP" USING L-ROW
         END-IF
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE NOT = 0
             COMPUTE WS-ROW = EN-TYPE(L-ROW) + 1
             MOVE SPACES TO WS-ITEM-KEY
             STRING "minecraft:" FUNCTION TRIM(M1-KEY(WS-ROW)) DELIMITED BY SIZE INTO WS-ITEM-KEY
             CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
             CALL "GI-SPAWN" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-ZERO-D WS-ZERO-E WS-ZERO-F
                 WS-ITEM WS-ONE WS-ONE-B WS-ITEM-ENTITY
         END-IF
         CALL "ENTITY-REMOVE" USING L-ROW
         GOBACK
     END-IF
     IF WS-CREATIVE = 1
         IF EN-RIDER(L-ROW) > 0
             CALL "MOB-RIDE-STOP" USING L-ROW
         END-IF
         CALL "ENTITY-REMOVE" USING L-ROW
         GOBACK
     END-IF
     CALL "BOAT-DATA-SEND" USING L-ROW
     GOBACK.
 END PROGRAM BOAT-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOAT-ITEM-USE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Use Item 0x43), done out: a boat item in the main hand (3.10 BoatItem.use): the pick ray from the eye (reach 5, yaw 0 faces +z,
*> sampled every 0.02) stops at the first solid cell or the first water cell whose top is above the point; the boat of the item's type (the entity key is the item key) is placed there
*> facing the player's yaw, unless its box collides with a solid cell (nothing happens then); a survival player's stack loses one. A ray that hits nothing does nothing. done is 1 for a boat item
*> (pickable entities in the ray, the statistic and the game event are open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ENTITY-KEY          PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-CELL-TOP            FLOAT-LONG.
 01 WS-BOX-HIT             BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FACING              FLOAT-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR MN-WINDOW(WS-ROW) NOT = 0 OR PSB-HAND NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     MOVE SPACES TO WS-ENTITY-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ENTITY-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-ENTITY-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO WS-KIND
     IF WS-STATUS = 0
         CALL "BOAT-KIND" USING WS-TYPE WS-KIND
     END-IF
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     COMPUTE WS-YAW = PSB-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PSB-PITCH * FUNCTION PI / 180
     COMPUTE WS-DX = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DY = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-DZ = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     MOVE 0 TO WS-HIT WS-T
     PERFORM UNTIL WS-T > 5 OR WS-HIT = 1
         COMPUTE WS-PX = PL-X(WS-ROW) + WS-DX * WS-T
         COMPUTE WS-PY = PL-Y(WS-ROW) + 1.62 + WS-DY * WS-T
         COMPUTE WS-PZ = PL-Z(WS-ROW) + WS-DZ * WS-T
         COMPUTE WS-CX = FUNCTION INTEGER(WS-PX)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-PY)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-PZ)
         CALL "GI-SOLID-CELL" USING WS-DIM WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE 1 TO WS-HIT
         END-IF
         CALL "BOAT-FLUID" USING WS-DIM WS-CX WS-CY WS-CZ WS-H WS-WK
         COMPUTE WS-CELL-TOP = WS-CY + WS-H
         IF WS-WK > 0 AND WS-PY < WS-CELL-TOP
             MOVE 1 TO WS-HIT
         END-IF
         ADD 0.02 TO WS-T
     END-PERFORM
     IF WS-HIT = 1
         CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-BOX-HIT WS-TOP
         IF WS-BOX-HIT = 0
             MOVE PL-YAW(WS-ROW) TO WS-FACING
             CALL "BOAT-SPAWN" USING WS-DIM WS-PX WS-PY WS-PZ WS-FACING WS-ENTITY-KEY WS-NEW
             CALL "MOB-TAKE" USING WS-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BOAT-ITEM-USE.
