*> The ocean monument's room graph and child piece list (docs/protocol/36-structures-6-ocean.md sections 5.1 to 5.5; the geometry of the pieces, 5.6 to 5.9, is not built here).
*> Entry points (state in STRUCT-MONUMENT, copybook STRUCTMON.cpy):
*>   MON-START USING rng (the Java LCG state, BINARY-DOUBLE UNSIGNED), seed (BINARY-DOUBLE UNSIGNED), chunk x, chunk z: setLargeFeatureSeed, then the start's draws of 5.1 step 5 and MON-LAYOUT.
*>   MON-LAYOUT USING rng, direction (0 north to 3 west), x0, z0: the constructor of MonumentBuilding (5.4): the building box, the room graph, the fitted rooms and the wings and penthouse.
*>   MON-GRAPH USING rng: generateRoomGraph (5.3), filling the definitions, MO-CORE and MO-ORDER.
*> The biome test of 5.1 steps 2 to 4 belongs to the caller.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-STEP.
*> USING direction (3-D data value), dx, dy, dz out: the step of a Direction (5.3 and section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     EVALUATE L-D
         WHEN 0
             MOVE -1 TO L-DY
         WHEN 1
             MOVE 1 TO L-DY
         WHEN 2
             MOVE -1 TO L-DZ
         WHEN 3
             MOVE 1 TO L-DZ
         WHEN 4
             MOVE -1 TO L-DX
         WHEN OTHER
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM MON-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-CONNECT.
*> USING direction, slot a, slot b: setConnection (5.3): a.connections[d] = b and b.connections[opposite(d)] = a.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-A L-B.
     COMPUTE WS-D1 = L-D + 1
     COMPUTE WS-D2 = L-D + 2 - 2 * FUNCTION MOD(L-D, 2)
     MOVE L-B TO MD-CONN(L-A, WS-D1)
     MOVE L-A TO MD-CONN(L-B, WS-D2)
     GOBACK.
 END PROGRAM MON-CONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-FIND IS RECURSIVE.
*> USING slot, scan, result out (1 or 0): RoomDefinition.findSource (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-SCAN                BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-C                   BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-SCAN                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-SCAN L-RESULT.
     MOVE L-SLOT TO LS-SLOT
     MOVE L-SCAN TO LS-SCAN
     MOVE 1 TO L-RESULT
     IF MD-SOURCE(LS-SLOT) = 1
         GOBACK
     END-IF
     MOVE LS-SCAN TO MD-SCAN(LS-SLOT)
     MOVE 0 TO LS-FOUND
     PERFORM VARYING LS-D FROM 1 BY 1 UNTIL LS-D > 6 OR LS-FOUND = 1
         MOVE MD-CONN(LS-SLOT, LS-D) TO LS-C
         IF LS-C > 0 AND MD-OPEN(LS-SLOT, LS-D) = 1
             IF MD-SCAN(LS-C) NOT = LS-SCAN
                 CALL "MON-FIND" USING LS-C LS-SCAN LS-SUB
                 MOVE LS-SUB TO LS-FOUND
             END-IF
         END-IF
     END-PERFORM
     MOVE LS-FOUND TO L-RESULT
     GOBACK.
 END PROGRAM MON-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-GRAPH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DD                  BINARY-LONG.
 01 WS-OPP-SUB             BINARY-LONG.
 01 WS-SCAN                BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-NORTH               BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-EN                  BINARY-LONG.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-6                   BINARY-LONG VALUE 6.
 01 WS-U-UP                BINARY-LONG VALUE 1.
 01 WS-U-SOUTH             BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-RNG.
*>   step 1: the definitions; a grid cell has a room on layers 0 and 1 for x 0..4, z 0..3, on layer 2 for x 1..3, z 0..1
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > MO-SLOTS
         MOVE -1 TO MD-INDEX(WS-SLOT)
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             MOVE 0 TO MD-CONN(WS-SLOT, WS-D)
             MOVE 0 TO MD-OPEN(WS-SLOT, WS-D)
         END-PERFORM
         MOVE 0 TO MD-CLAIMED(WS-SLOT) MD-SOURCE(WS-SLOT) MD-SCAN(WS-SLOT)
     END-PERFORM
     PERFORM VARYING WS-INDEX FROM 0 BY 1 UNTIL WS-INDEX > 74
         COMPUTE WS-Y = WS-INDEX / 25
         COMPUTE WS-Z = FUNCTION MOD(WS-INDEX / 5, 5)
         COMPUTE WS-X = FUNCTION MOD(WS-INDEX, 5)
         COMPUTE WS-SLOT = WS-INDEX + 1
         EVALUATE TRUE
             WHEN WS-Y < 2 AND WS-Z < 4
                 MOVE WS-INDEX TO MD-INDEX(WS-SLOT)
             WHEN WS-Y = 2 AND WS-Z < 2 AND WS-X >= 1 AND WS-X <= 3
                 MOVE WS-INDEX TO MD-INDEX(WS-SLOT)
         END-EVALUATE
     END-PERFORM
*>   step 2: the connections; the slots of the z axis are mirrored
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 4
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 2
                 COMPUTE WS-SLOT = WS-Y * 25 + WS-Z * 5 + WS-X + 1
                 IF MD-INDEX(WS-SLOT) >= 0
                     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 5
                         CALL "MON-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
                         COMPUTE WS-NX = WS-X + WS-DX
                         COMPUTE WS-NY = WS-Y + WS-DY
                         COMPUTE WS-NZ = WS-Z + WS-DZ
                         IF WS-NX >= 0 AND WS-NX <= 4 AND WS-NY >= 0 AND WS-NY <= 2 AND WS-NZ >= 0 AND WS-NZ <= 4
                             COMPUTE WS-NB = WS-NY * 25 + WS-NZ * 5 + WS-NX + 1
                             IF MD-INDEX(WS-NB) >= 0
                                 MOVE WS-DIR TO WS-DD
                                 IF WS-NZ NOT = WS-Z
                                     COMPUTE WS-DD = WS-DIR + 1 - 2 * FUNCTION MOD(WS-DIR, 2)
                                 END-IF
                                 CALL "MON-CONNECT" USING WS-DD WS-SLOT WS-NB
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   step 3: the penthouse (slot 78) above room 52, the wings (76, 77) south of rooms 25 and 29 (index(0,1,0) and index(4,1,0); the values 5 and 9 printed in 5.2 contradict its formula and the 98 links); the source is room 2
     MOVE 1003 TO MD-INDEX(78)
     MOVE 1001 TO MD-INDEX(76)
     MOVE 1002 TO MD-INDEX(77)
     MOVE 53 TO WS-A
     MOVE 78 TO WS-B
     CALL "MON-CONNECT" USING WS-U-UP WS-A WS-B
     MOVE 26 TO WS-A
     MOVE 76 TO WS-B
     CALL "MON-CONNECT" USING WS-U-SOUTH WS-A WS-B
     MOVE 30 TO WS-A
     MOVE 77 TO WS-B
     CALL "MON-CONNECT" USING WS-U-SOUTH WS-A WS-B
     MOVE 1 TO MD-CLAIMED(76) MD-CLAIMED(77) MD-CLAIMED(78)
     MOVE 1 TO MD-SOURCE(3)
*>   step 4: the core room at (x, 0, 2) and the seven cells that complete a 2 by 2 by 2 block with it
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-4 WS-X
     COMPUTE MO-CORE = 10 + WS-X + 1
     MOVE 1 TO MD-CLAIMED(MO-CORE)
     MOVE MD-CONN(MO-CORE, 6) TO WS-EAST
     MOVE MD-CONN(MO-CORE, 3) TO WS-NORTH
     MOVE MD-CONN(MO-CORE, 2) TO WS-UP
     MOVE MD-CONN(WS-EAST, 3) TO WS-EN
     MOVE 1 TO MD-CLAIMED(WS-EAST) MD-CLAIMED(WS-NORTH) MD-CLAIMED(WS-UP) MD-CLAIMED(WS-EN)
     MOVE MD-CONN(WS-EAST, 2) TO WS-T
     MOVE 1 TO MD-CLAIMED(WS-T)
     MOVE MD-CONN(WS-NORTH, 2) TO WS-T
     MOVE 1 TO MD-CLAIMED(WS-T)
     MOVE MD-CONN(WS-EN, 2) TO WS-T
     MOVE 1 TO MD-CLAIMED(WS-T)
*>   step 5: the 46 grid definitions in index order, their openings (and the penthouse's), shuffled
     MOVE 0 TO WS-N
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 75
         IF MD-INDEX(WS-SLOT) >= 0
             ADD 1 TO WS-N
             MOVE WS-SLOT TO MO-ORDER(WS-N)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 75
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             IF MD-CONN(WS-SLOT, WS-D) > 0
                 MOVE 1 TO MD-OPEN(WS-SLOT, WS-D)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO MD-OPEN(78, 1)
     PERFORM VARYING WS-I FROM 46 BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-I WS-J
         COMPUTE WS-J = WS-J + 1
         MOVE MO-ORDER(WS-I) TO WS-T
         MOVE MO-ORDER(WS-J) TO MO-ORDER(WS-I)
         MOVE WS-T TO MO-ORDER(WS-J)
     END-PERFORM
*>   step 6: pruning; every try draws a direction
     MOVE 1 TO WS-SCAN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 46
         MOVE MO-ORDER(WS-I) TO WS-SLOT
         MOVE 0 TO WS-REMOVED WS-TRIES
         PERFORM UNTIL WS-REMOVED >= 2 OR WS-TRIES >= 5
             ADD 1 TO WS-TRIES
             CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-6 WS-DIR
             COMPUTE WS-D = WS-DIR + 1
             IF MD-OPEN(WS-SLOT, WS-D) = 1
                 COMPUTE WS-OPP-SUB = WS-DIR + 2 - 2 * FUNCTION MOD(WS-DIR, 2)
                 MOVE MD-CONN(WS-SLOT, WS-D) TO WS-NB
                 MOVE 0 TO MD-OPEN(WS-SLOT, WS-D)
                 MOVE 0 TO MD-OPEN(WS-NB, WS-OPP-SUB)
                 CALL "MON-FIND" USING WS-SLOT WS-SCAN WS-A
                 ADD 1 TO WS-SCAN
                 MOVE 0 TO WS-B
                 IF WS-A = 1
                     CALL "MON-FIND" USING WS-NB WS-SCAN WS-B
                     ADD 1 TO WS-SCAN
                 END-IF
                 IF WS-A = 1 AND WS-B = 1
                     ADD 1 TO WS-REMOVED
                 ELSE
                     MOVE 1 TO MD-OPEN(WS-SLOT, WS-D)
                     MOVE 1 TO MD-OPEN(WS-NB, WS-OPP-SUB)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   step 7: the penthouse, the left and the right wing close the list
     MOVE 78 TO MO-ORDER(47)
     MOVE 76 TO MO-ORDER(48)
     MOVE 77 TO MO-ORDER(49)
     GOBACK.
 END PROGRAM MON-GRAPH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-WORLD.
*> USING x, y, z (building-local), wx, wy, wz out: getWorldPos of the building (36-1 section 6.4 over the building box MO-B* and the direction MO-DIR).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-WX                   BINARY-LONG.
 01 L-WY                   BINARY-LONG.
 01 L-WZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-WX L-WY L-WZ.
     COMPUTE L-WY = MO-BY0 + L-Y
     EVALUATE MO-DIR
         WHEN 0
             COMPUTE L-WX = MO-BX0 + L-X
             COMPUTE L-WZ = MO-BZ1 - L-Z
         WHEN 2
             COMPUTE L-WX = MO-BX0 + L-X
             COMPUTE L-WZ = MO-BZ0 + L-Z
         WHEN 3
             COMPUTE L-WX = MO-BX1 - L-Z
             COMPUTE L-WZ = MO-BZ0 + L-X
         WHEN OTHER
             COMPUTE L-WX = MO-BX0 + L-Z
             COMPUTE L-WZ = MO-BZ0 + L-X
     END-EVALUATE
     GOBACK.
 END PROGRAM MON-WORLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-ADD-ROOM.
*> USING kind, slot, width, height, depth (cells), design: the child piece of a room definition (5.5): the box made by makeBoundingBox, moved by the grid position and by v (5.4 step 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-IDX                 BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-DESIGN               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SLOT L-W L-H L-D L-DESIGN.
     MOVE MD-INDEX(L-SLOT) TO WS-IDX
     COMPUTE WS-GY = WS-IDX / 25
     COMPUTE WS-GZ = FUNCTION MOD(WS-IDX / 5, 5)
     COMPUTE WS-GX = FUNCTION MOD(WS-IDX, 5)
     ADD 1 TO MO-COUNT
     MOVE L-KIND TO MC-KIND(MO-COUNT)
     MOVE WS-IDX TO MC-INDEX(MO-COUNT)
     MOVE L-DESIGN TO MC-DESIGN(MO-COUNT)
     IF MO-DIR = 0 OR MO-DIR = 2
         COMPUTE WS-EX = 8 * L-W - 1
         COMPUTE WS-EZ = 8 * L-D - 1
     ELSE
         COMPUTE WS-EX = 8 * L-D - 1
         COMPUTE WS-EZ = 8 * L-W - 1
     END-IF
     EVALUATE MO-DIR
         WHEN 0
             COMPUTE WS-MX = WS-GX * 8
             COMPUTE WS-MZ = 1 - (WS-GZ + L-D) * 8
         WHEN 2
             COMPUTE WS-MX = WS-GX * 8
             COMPUTE WS-MZ = WS-GZ * 8
         WHEN 3
             COMPUTE WS-MX = 1 - (WS-GZ + L-D) * 8
             COMPUTE WS-MZ = WS-GX * 8
         WHEN OTHER
             COMPUTE WS-MX = WS-GZ * 8
             COMPUTE WS-MZ = WS-GX * 8
     END-EVALUATE
     COMPUTE MC-X0(MO-COUNT) = WS-MX + MO-VX
     COMPUTE MC-X1(MO-COUNT) = WS-MX + WS-EX + MO-VX
     COMPUTE MC-Z0(MO-COUNT) = WS-MZ + MO-VZ
     COMPUTE MC-Z1(MO-COUNT) = WS-MZ + WS-EZ + MO-VZ
     COMPUTE MC-Y0(MO-COUNT) = WS-GY * 4 + MO-BY0
     COMPUTE MC-Y1(MO-COUNT) = WS-GY * 4 + 4 * L-H - 1 + MO-BY0
     GOBACK.
 END PROGRAM MON-ADD-ROOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-ADD-BOX.
*> USING kind, index, design, local x1, y1, z1, local x2, y2, z2: a child made from two building-local corners (fromCorners of getWorldPos, 5.4 step 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DESIGN               BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-INDEX L-DESIGN L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2.
     CALL "MON-WORLD" USING L-X1 L-Y1 L-Z1 WS-AX WS-AY WS-AZ
     CALL "MON-WORLD" USING L-X2 L-Y2 L-Z2 WS-BX WS-BY WS-BZ
     ADD 1 TO MO-COUNT
     MOVE L-KIND TO MC-KIND(MO-COUNT)
     MOVE L-INDEX TO MC-INDEX(MO-COUNT)
     MOVE L-DESIGN TO MC-DESIGN(MO-COUNT)
     MOVE FUNCTION MIN(WS-AX, WS-BX) TO MC-X0(MO-COUNT)
     MOVE FUNCTION MAX(WS-AX, WS-BX) TO MC-X1(MO-COUNT)
     MOVE FUNCTION MIN(WS-AY, WS-BY) TO MC-Y0(MO-COUNT)
     MOVE FUNCTION MAX(WS-AY, WS-BY) TO MC-Y1(MO-COUNT)
     MOVE FUNCTION MIN(WS-AZ, WS-BZ) TO MC-Z0(MO-COUNT)
     MOVE FUNCTION MAX(WS-AZ, WS-BZ) TO MC-Z1(MO-COUNT)
     GOBACK.
 END PROGRAM MON-ADD-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-LAYOUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-EU                  BINARY-LONG.
 01 WS-NU                  BINARY-LONG.
 01 WS-FE                  BINARY-LONG.
 01 WS-FN                  BINARY-LONG.
 01 WS-FU                  BINARY-LONG.
 01 WS-FEU                 BINARY-LONG.
 01 WS-FNU                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DESIGN              BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-3                   BINARY-LONG VALUE 3.
 01 WS-32                  BINARY-LONG VALUE 32.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-L9                  BINARY-LONG VALUE 9.
 01 WS-L22                 BINARY-LONG VALUE 22.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-P1                 BINARY-LONG.
 01 WS-P2                 BINARY-LONG.
 01 WS-P3                 BINARY-LONG.
 01 WS-P4                 BINARY-LONG.
 01 WS-P5                 BINARY-LONG.
 01 WS-P6                 BINARY-LONG.
 01 WS-K-WING              BINARY-LONG VALUE 10.
 01 WS-K-PENT              BINARY-LONG VALUE 11.
 01 WS-I-LEFT              BINARY-LONG VALUE 1001.
 01 WS-I-RIGHT             BINARY-LONG VALUE 1002.
 01 WS-I-PENT              BINARY-LONG VALUE 1003.
 LINKAGE SECTION.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-DIR                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RNG L-DIR L-X0 L-Z0.
*>   step 1: the box and the grid origin v = getWorldPos(9, 0, 22)
     MOVE L-DIR TO MO-DIR
     MOVE L-X0 TO MO-BX0
     MOVE 39 TO MO-BY0
     MOVE L-Z0 TO MO-BZ0
     COMPUTE MO-BX1 = L-X0 + 57
     MOVE 61 TO MO-BY1
     COMPUTE MO-BZ1 = L-Z0 + 57
     CALL "MON-WORLD" USING WS-L9 WS-ZERO WS-L22 MO-VX WS-WY MO-VZ
     MOVE 0 TO MO-COUNT
*>   step 2 and 3: the graph, the entry room and the core room
     CALL "MON-GRAPH" USING L-RNG
     MOVE 1 TO MD-CLAIMED(3)
     MOVE 1 TO WS-KIND
     MOVE 3 TO WS-SLOT
     MOVE 1 TO WS-W WS-H WS-D
     MOVE 0 TO WS-DESIGN
     CALL "MON-ADD-ROOM" USING WS-KIND WS-SLOT WS-W WS-H WS-D WS-DESIGN
     MOVE 2 TO WS-KIND
     MOVE 2 TO WS-W WS-H WS-D
     CALL "MON-ADD-ROOM" USING WS-KIND MO-CORE WS-W WS-H WS-D WS-DESIGN
*>   steps 4 and 5: the first fitter that fits takes each unclaimed room
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 49
         MOVE MO-ORDER(WS-I) TO WS-SLOT
         IF MD-CLAIMED(WS-SLOT) = 0
             MOVE 0 TO WS-FE WS-FN WS-FU WS-FEU WS-FNU
             MOVE MD-CONN(WS-SLOT, 6) TO WS-E
             MOVE MD-CONN(WS-SLOT, 3) TO WS-N
             MOVE MD-CONN(WS-SLOT, 2) TO WS-U
             IF MD-OPEN(WS-SLOT, 6) = 1 AND MD-CLAIMED(WS-E) = 0
                 MOVE 1 TO WS-FE
             END-IF
             IF MD-OPEN(WS-SLOT, 3) = 1 AND MD-CLAIMED(WS-N) = 0
                 MOVE 1 TO WS-FN
             END-IF
             IF MD-OPEN(WS-SLOT, 2) = 1 AND MD-CLAIMED(WS-U) = 0
                 MOVE 1 TO WS-FU
             END-IF
             IF WS-FE = 1 AND WS-FU = 1
                 MOVE MD-CONN(WS-E, 2) TO WS-EU
                 IF MD-OPEN(WS-E, 2) = 1 AND MD-CLAIMED(WS-EU) = 0
                     MOVE 1 TO WS-FEU
                 END-IF
             END-IF
             IF WS-FN = 1 AND WS-FU = 1
                 MOVE MD-CONN(WS-N, 2) TO WS-NU
                 IF MD-OPEN(WS-N, 2) = 1 AND MD-CLAIMED(WS-NU) = 0
                     MOVE 1 TO WS-FNU
                 END-IF
             END-IF
             MOVE 0 TO WS-DESIGN
             EVALUATE TRUE
                 WHEN WS-FEU = 1
                     MOVE 8 TO WS-KIND
                     MOVE 2 TO WS-W WS-H
                     MOVE 1 TO WS-D
                     MOVE 1 TO MD-CLAIMED(WS-E) MD-CLAIMED(WS-U) MD-CLAIMED(WS-EU)
                 WHEN WS-FNU = 1
                     MOVE 9 TO WS-KIND
                     MOVE 1 TO WS-W
                     MOVE 2 TO WS-H WS-D
                     MOVE 1 TO MD-CLAIMED(WS-N) MD-CLAIMED(WS-U) MD-CLAIMED(WS-NU)
                 WHEN WS-FN = 1
                     MOVE 7 TO WS-KIND
                     MOVE 1 TO WS-W WS-H
                     MOVE 2 TO WS-D
                     MOVE 1 TO MD-CLAIMED(WS-N)
                 WHEN WS-FE = 1
                     MOVE 5 TO WS-KIND
                     MOVE 2 TO WS-W
                     MOVE 1 TO WS-H WS-D
                     MOVE 1 TO MD-CLAIMED(WS-E)
                 WHEN WS-FU = 1
                     MOVE 6 TO WS-KIND
                     MOVE 1 TO WS-W
                     MOVE 2 TO WS-H
                     MOVE 1 TO WS-D
                     MOVE 1 TO MD-CLAIMED(WS-U)
                 WHEN MD-OPEN(WS-SLOT, 5) = 0 AND MD-OPEN(WS-SLOT, 6) = 0 AND MD-OPEN(WS-SLOT, 3) = 0
                     AND MD-OPEN(WS-SLOT, 4) = 0 AND MD-OPEN(WS-SLOT, 2) = 0
                     MOVE 4 TO WS-KIND
                     MOVE 1 TO WS-W WS-H WS-D
                 WHEN OTHER
                     MOVE 3 TO WS-KIND
                     MOVE 1 TO WS-W WS-H WS-D
                     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-3 WS-DESIGN
             END-EVALUATE
             MOVE 1 TO MD-CLAIMED(WS-SLOT)
             CALL "MON-ADD-ROOM" USING WS-KIND WS-SLOT WS-W WS-H WS-D WS-DESIGN
         END-IF
     END-PERFORM
*>   step 7: the wings (one nextInt() seeds both) and the penthouse
     CALL "JRAND-NEXT" USING L-RNG WS-32 WS-SEED
     COMPUTE MO-WING-SEED = WS-SEED
     COMPUTE WS-DESIGN = FUNCTION MOD(WS-SEED, 2)
     MOVE 1 TO WS-P1
     MOVE 1 TO WS-P2
     MOVE 1 TO WS-P3
     MOVE 23 TO WS-P4
     MOVE 8 TO WS-P5
     MOVE 21 TO WS-P6
     CALL "MON-ADD-BOX" USING WS-K-WING WS-I-LEFT WS-DESIGN WS-P1 WS-P2 WS-P3 WS-P4 WS-P5 WS-P6
     COMPUTE WS-DESIGN = 1 - WS-DESIGN
     MOVE 34 TO WS-P1
     MOVE 1 TO WS-P2
     MOVE 1 TO WS-P3
     MOVE 56 TO WS-P4
     MOVE 8 TO WS-P5
     MOVE 21 TO WS-P6
     CALL "MON-ADD-BOX" USING WS-K-WING WS-I-RIGHT WS-DESIGN WS-P1 WS-P2 WS-P3 WS-P4 WS-P5 WS-P6
     MOVE 0 TO WS-DESIGN
     MOVE 22 TO WS-P1
     MOVE 13 TO WS-P2
     MOVE 22 TO WS-P3
     MOVE 35 TO WS-P4
     MOVE 17 TO WS-P5
     MOVE 35 TO WS-P6
     CALL "MON-ADD-BOX" USING WS-K-PENT WS-I-PENT WS-DESIGN WS-P1 WS-P2 WS-P3 WS-P4 WS-P5 WS-P6
     GOBACK.
 END PROGRAM MON-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-DIR                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RNG L-SEED L-CX L-CZ.
     CALL "JRAND-LARGE-FEATURE-SEED" USING L-RNG L-SEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-4 WS-DIR
     COMPUTE WS-X0 = L-CX * 16 - 29
     COMPUTE WS-Z0 = L-CZ * 16 - 29
     CALL "MON-LAYOUT" USING L-RNG WS-DIR WS-X0 WS-Z0
     GOBACK.
 END PROGRAM MON-START.
