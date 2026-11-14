*> The mineshaft, part 1: the start and the recursive assembly of its pieces (docs/protocol/36-structures-5-mineshaft-stronghold.md sections 2.1 to 2.4, 2.5 to 2.6, 2.11 and 2.12 for the boxes
*> and children; the blocks are in struct-ms-place.cob). Pieces go into the builder of struct-pieces.cob (STRUCTPIECE.cpy), the random is the Java LCG SP-RNG seeded as the generation context
*> of 36-1 5.1 (setLargeFeatureSeed). Piece types are the registry ids of 36-1 2.4: 0 mscorridor, 1 mscrossing, 2 msroom, 3 msstairs. Directions are data values: 0 south, 1 west, 2 north, 3 east.
*> Deviation: the builder holds 1024 pieces (SP-MAX); a piece that does not fit is a failed attempt (counted in SP-LOST); the mesa type (2.3, the base height of the terrain at the centre of the
*> structure, 37-2 section 6.5) is not built because the column query of the terrain density does not exist in the core: a mesa start is refused.
*>
*> Entry points:
*>   MS-FIND-POINT USING seed (BINARY-DOUBLE), chunk x, chunk z, mineshaft type (0 normal, 1 mesa), sea level, min y, stub x out, stub y out, stub z out, valid out (0 for the mesa type):
*>     findGenerationPoint (2.3): one nextDouble discarded, the root room at (16 cx + 2, 50, 16 cz + 2), its children, the vertical placement below the sea; the pieces are left in the builder
*>   MS-GEN-ADD USING parent row, x, y, z, direction, depth, row out (RECURSIVE): generateAndAddPiece (2.4)
*>   MS-CHILDREN USING row (RECURSIVE): addChildren of the piece in the row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-CREATE.
*> USING x, y, z, direction, genDepth, mineshaft type, row out: createRandomShaftPiece (2.4): one nextInt(100) picks crossing (80 to 99), stairs (70 to 79) or corridor; the candidate
*> box is built (the draws of findCrossing and findCorridorSize first), a collision with a piece of the builder or a full table gives row 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-R                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-COLL                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-MST                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-DEPTH L-MST L-ROW.
     MOVE 0 TO L-ROW
     MOVE 100 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-R
     EVALUATE TRUE
         WHEN WS-R >= 80
*>           findCrossing: h = 6 in a quarter of the cases, else 2; a 5 by 5 footprint
             MOVE 4 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             MOVE 2 TO WS-H
             IF WS-DRAW = 0
                 MOVE 6 TO WS-H
             END-IF
             EVALUATE L-DIR
                 WHEN 2
                     MOVE -1 TO WS-X0
                     MOVE -4 TO WS-Z0
                     MOVE 3 TO WS-X1
                     MOVE 0 TO WS-Z1
                 WHEN 1
                     MOVE -4 TO WS-X0
                     MOVE -1 TO WS-Z0
                     MOVE 0 TO WS-X1
                     MOVE 3 TO WS-Z1
                 WHEN 3
                     MOVE 0 TO WS-X0
                     MOVE -1 TO WS-Z0
                     MOVE 4 TO WS-X1
                     MOVE 3 TO WS-Z1
                 WHEN OTHER
                     MOVE -1 TO WS-X0
                     MOVE 0 TO WS-Z0
                     MOVE 3 TO WS-X1
                     MOVE 4 TO WS-Z1
             END-EVALUATE
             MOVE 0 TO WS-Y0
             MOVE WS-H TO WS-Y1
             MOVE 1 TO WS-TYPE
         WHEN WS-R >= 70
*>           findStairs: 3 wide, 8 high, 9 long
             EVALUATE L-DIR
                 WHEN 2
                     MOVE 0 TO WS-X0
                     MOVE -8 TO WS-Z0
                     MOVE 2 TO WS-X1
                     MOVE 0 TO WS-Z1
                 WHEN 1
                     MOVE -8 TO WS-X0
                     MOVE 0 TO WS-Z0
                     MOVE 0 TO WS-X1
                     MOVE 2 TO WS-Z1
                 WHEN 3
                     MOVE 0 TO WS-X0
                     MOVE 0 TO WS-Z0
                     MOVE 8 TO WS-X1
                     MOVE 2 TO WS-Z1
                 WHEN OTHER
                     MOVE 0 TO WS-X0
                     MOVE 0 TO WS-Z0
                     MOVE 2 TO WS-X1
                     MOVE 8 TO WS-Z1
             END-EVALUATE
             MOVE -5 TO WS-Y0
             MOVE 2 TO WS-Y1
             MOVE 3 TO WS-TYPE
         WHEN OTHER
*>           findCorridorSize: len = nextInt(3) + 2 sections, shortened until the box is free
             MOVE 3 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
             COMPUTE WS-LEN = WS-DRAW + 2
             MOVE 0 TO WS-TYPE
     END-EVALUATE
     IF WS-TYPE = 0
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-LEN < 1 OR WS-DONE = 1
             CALL "MS-CORRIDOR-BOX" USING L-X L-Y L-Z L-DIR WS-LEN WS-BOX
             CALL "SPB-FIND-COLLISION" USING WS-BOX WS-COLL
             IF WS-COLL = 0
                 MOVE 1 TO WS-DONE
             ELSE
                 SUBTRACT 1 FROM WS-LEN
             END-IF
         END-PERFORM
         IF WS-DONE = 0
             GOBACK
         END-IF
     ELSE
         COMPUTE WS-X0 = WS-X0 + L-X
         COMPUTE WS-Y0 = WS-Y0 + L-Y
         COMPUTE WS-Z0 = WS-Z0 + L-Z
         COMPUTE WS-X1 = WS-X1 + L-X
         COMPUTE WS-Y1 = WS-Y1 + L-Y
         COMPUTE WS-Z1 = WS-Z1 + L-Z
         CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
         CALL "SPB-FIND-COLLISION" USING WS-BOX WS-COLL
         IF WS-COLL > 0
             GOBACK
         END-IF
     END-IF
     EVALUATE WS-TYPE
         WHEN 1
             CALL "SPB-ADD" USING WS-TYPE WS-NONE L-DEPTH L-MST WS-BOX L-ROW
             IF L-ROW > 0
                 IF B-Y1 - B-Y0 + 1 > 3
                     MOVE 1 TO SP-F1(L-ROW)
                 END-IF
                 MOVE L-DIR TO SP-F2(L-ROW)
             END-IF
         WHEN 3
             CALL "SPB-ADD" USING WS-TYPE L-DIR L-DEPTH L-MST WS-BOX L-ROW
         WHEN OTHER
             CALL "SPB-ADD" USING WS-TYPE L-DIR L-DEPTH L-MST WS-BOX L-ROW
             IF L-ROW > 0
*>               the corridor constructor's draws (2.6): has rails 1 in 3, else a spider corridor 1 in 23; the section count is the length over 5
                 MOVE 3 TO WS-BOUND
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
                 IF WS-DRAW = 0
                     MOVE 1 TO SP-F1(L-ROW)
                 ELSE
                     MOVE 23 TO WS-BOUND
                     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
                     IF WS-DRAW = 0
                         MOVE 1 TO SP-F2(L-ROW)
                     END-IF
                 END-IF
                 MOVE WS-LEN TO SP-F4(L-ROW)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MS-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-CORRIDOR-BOX.
*> USING x, y, z, direction, sections, box out: the corridor candidate of findCorridorSize (2.6): 3 wide, 3 high, 5 * sections long, extending from the anchor against the direction
*> for north and west and along it for south and east.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-LEN                  BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-LEN L-BOX.
     COMPUTE WS-LENGTH = 5 * L-LEN
     COMPUTE WS-Y1 = L-Y + 2
     EVALUATE L-DIR
         WHEN 2
             COMPUTE WS-X0 = L-X
             COMPUTE WS-Z0 = L-Z - (WS-LENGTH - 1)
             COMPUTE WS-X1 = L-X + 2
             COMPUTE WS-Z1 = L-Z
         WHEN 1
             COMPUTE WS-X0 = L-X - (WS-LENGTH - 1)
             COMPUTE WS-Z0 = L-Z
             COMPUTE WS-X1 = L-X
             COMPUTE WS-Z1 = L-Z + 2
         WHEN 3
             COMPUTE WS-X0 = L-X
             COMPUTE WS-Z0 = L-Z
             COMPUTE WS-X1 = L-X + WS-LENGTH - 1
             COMPUTE WS-Z1 = L-Z + 2
         WHEN OTHER
             COMPUTE WS-X0 = L-X
             COMPUTE WS-Z0 = L-Z
             COMPUTE WS-X1 = L-X + 2
             COMPUTE WS-Z1 = L-Z + WS-LENGTH - 1
     END-EVALUATE
     CALL "SPB-BOX-NEW" USING WS-X0 L-Y WS-Z0 WS-X1 WS-Y1 WS-Z1 L-BOX
     GOBACK.
 END PROGRAM MS-CORRIDOR-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-GEN-ADD IS RECURSIVE.
*> generateAndAddPiece (2.4): nothing beyond depth 8, nothing more than 80 blocks in x or z from the parent's minimum corner; else the piece of createRandomShaftPiece (genDepth + 1,
*> the parent's type) is added to the builder and its children are generated at once, depth first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-MST                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PARENT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PARENT L-X L-Y L-Z L-DIR L-DEPTH L-ROW.
     MOVE 0 TO L-ROW
     IF L-DEPTH > 8
         GOBACK
     END-IF
     COMPUTE LS-DX = FUNCTION ABS(L-X - SP-X0(L-PARENT))
     COMPUTE LS-DZ = FUNCTION ABS(L-Z - SP-Z0(L-PARENT))
     IF LS-DX > 80 OR LS-DZ > 80
         GOBACK
     END-IF
     COMPUTE LS-DEPTH = L-DEPTH + 1
     MOVE SP-MST(L-PARENT) TO LS-MST
     CALL "MS-CREATE" USING L-X L-Y L-Z L-DIR LS-DEPTH LS-MST L-ROW
     IF L-ROW > 0
         CALL "MS-CHILDREN" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MS-GEN-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-CHILDREN IS RECURSIVE.
*> addChildren of the room (2.5: four sweeps north, south, west, east), the corridor (2.6: one forward or lateral child, then side branches while the depth is below 8), the crossing (2.11)
*> and the stairs (2.12), in the order of the draws of the document.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 LOCAL-STORAGE SECTION.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-H                   BINARY-LONG.
 01 LS-SIDE                BINARY-LONG.
 01 LS-SPAN                BINARY-LONG.
 01 LS-GO                  BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-BOUND               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-DEP1                BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-BX0                 BINARY-LONG.
 01 LS-BY0                 BINARY-LONG.
 01 LS-BZ0                 BINARY-LONG.
 01 LS-BX1                 BINARY-LONG.
 01 LS-BZ1                 BINARY-LONG.
 01 LS-NORTH               BINARY-LONG VALUE 2.
 01 LS-SOUTH               BINARY-LONG VALUE 0.
 01 LS-WEST                BINARY-LONG VALUE 1.
 01 LS-EAST                BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-DEPTH(L-ROW) TO LS-DEPTH
     MOVE SP-X0(L-ROW) TO LS-BX0
     MOVE SP-Y0(L-ROW) TO LS-BY0
     MOVE SP-Z0(L-ROW) TO LS-BZ0
     MOVE SP-X1(L-ROW) TO LS-BX1
     MOVE SP-Z1(L-ROW) TO LS-BZ1
     EVALUATE SP-TYPE(L-ROW)
         WHEN 2
*>           the room: h = ySpan - 4, at least 1
             COMPUTE LS-H = SP-Y1(L-ROW) - SP-Y0(L-ROW) + 1 - 3 - 1
             IF LS-H <= 0
                 MOVE 1 TO LS-H
             END-IF
             COMPUTE SP-ENT-FIRST(L-ROW) = SP-ENT-COUNT + 1
             PERFORM VARYING LS-SIDE FROM 0 BY 1 UNTIL LS-SIDE > 3
                 IF LS-SIDE < 2
                     COMPUTE LS-SPAN = LS-BX1 - LS-BX0 + 1
                 ELSE
                     COMPUTE LS-SPAN = LS-BZ1 - LS-BZ0 + 1
                 END-IF
                 MOVE 0 TO LS-I
                 MOVE 1 TO LS-GO
                 PERFORM UNTIL LS-GO = 0
                     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-SPAN LS-DRAW
                     ADD LS-DRAW TO LS-I
                     IF LS-I + 3 > LS-SPAN
                         MOVE 0 TO LS-GO
                     ELSE
                         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-H LS-DRAW
                         COMPUTE LS-Y = LS-BY0 + LS-DRAW + 1
                         EVALUATE LS-SIDE
                             WHEN 0
                                 COMPUTE LS-X = LS-BX0 + LS-I
                                 COMPUTE LS-Z = LS-BZ0 - 1
                                 MOVE LS-NORTH TO LS-DIR
                             WHEN 1
                                 COMPUTE LS-X = LS-BX0 + LS-I
                                 COMPUTE LS-Z = LS-BZ1 + 1
                                 MOVE LS-SOUTH TO LS-DIR
                             WHEN 2
                                 COMPUTE LS-X = LS-BX0 - 1
                                 COMPUTE LS-Z = LS-BZ0 + LS-I
                                 MOVE LS-WEST TO LS-DIR
                             WHEN OTHER
                                 COMPUTE LS-X = LS-BX1 + 1
                                 COMPUTE LS-Z = LS-BZ0 + LS-I
                                 MOVE LS-EAST TO LS-DIR
                         END-EVALUATE
                         CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-DIR LS-DEPTH LS-CHILD
                         IF LS-CHILD > 0
*>                           the entrance box of the child (2.5): the strip of the room wall the child opens into
                             ADD 1 TO SP-ENT-COUNT
                             ADD 1 TO SP-ENT-N(L-ROW)
                             MOVE SP-X0(LS-CHILD) TO SE-X0(SP-ENT-COUNT)
                             MOVE SP-Y0(LS-CHILD) TO SE-Y0(SP-ENT-COUNT)
                             MOVE SP-Z0(LS-CHILD) TO SE-Z0(SP-ENT-COUNT)
                             MOVE SP-X1(LS-CHILD) TO SE-X1(SP-ENT-COUNT)
                             MOVE SP-Y1(LS-CHILD) TO SE-Y1(SP-ENT-COUNT)
                             MOVE SP-Z1(LS-CHILD) TO SE-Z1(SP-ENT-COUNT)
                             EVALUATE LS-SIDE
                                 WHEN 0
                                     MOVE LS-BZ0 TO SE-Z0(SP-ENT-COUNT)
                                     COMPUTE SE-Z1(SP-ENT-COUNT) = LS-BZ0 + 1
                                 WHEN 1
                                     COMPUTE SE-Z0(SP-ENT-COUNT) = LS-BZ1 - 1
                                     MOVE LS-BZ1 TO SE-Z1(SP-ENT-COUNT)
                                 WHEN 2
                                     MOVE LS-BX0 TO SE-X0(SP-ENT-COUNT)
                                     COMPUTE SE-X1(SP-ENT-COUNT) = LS-BX0 + 1
                                 WHEN OTHER
                                     COMPUTE SE-X0(SP-ENT-COUNT) = LS-BX1 - 1
                                     MOVE LS-BX1 TO SE-X1(SP-ENT-COUNT)
                             END-EVALUATE
                         END-IF
                         ADD 4 TO LS-I
                         IF LS-I >= LS-SPAN
                             MOVE 0 TO LS-GO
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN 0
*>           the corridor: r = nextInt(4); a forward child (0, 1) or one on the side (2: left, 3: right), each at y = minY - 1 + nextInt(3)
             MOVE 4 TO LS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-R
             MOVE SP-ORIENT(L-ROW) TO LS-D
             MOVE 3 TO LS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
             COMPUTE LS-Y = LS-BY0 - 1 + LS-DRAW
             MOVE LS-D TO LS-DIR
             EVALUATE LS-D ALSO TRUE
                 WHEN 2 ALSO LS-R <= 1
                     MOVE LS-BX0 TO LS-X
                     COMPUTE LS-Z = LS-BZ0 - 1
                 WHEN 2 ALSO LS-R = 2
                     COMPUTE LS-X = LS-BX0 - 1
                     MOVE LS-BZ0 TO LS-Z
                     MOVE LS-WEST TO LS-DIR
                 WHEN 2 ALSO ANY
                     COMPUTE LS-X = LS-BX1 + 1
                     MOVE LS-BZ0 TO LS-Z
                     MOVE LS-EAST TO LS-DIR
                 WHEN 0 ALSO LS-R <= 1
                     MOVE LS-BX0 TO LS-X
                     COMPUTE LS-Z = LS-BZ1 + 1
                 WHEN 0 ALSO LS-R = 2
                     COMPUTE LS-X = LS-BX0 - 1
                     COMPUTE LS-Z = LS-BZ1 - 3
                     MOVE LS-WEST TO LS-DIR
                 WHEN 0 ALSO ANY
                     COMPUTE LS-X = LS-BX1 + 1
                     COMPUTE LS-Z = LS-BZ1 - 3
                     MOVE LS-EAST TO LS-DIR
                 WHEN 1 ALSO LS-R <= 1
                     COMPUTE LS-X = LS-BX0 - 1
                     MOVE LS-BZ0 TO LS-Z
                 WHEN 1 ALSO LS-R = 2
                     MOVE LS-BX0 TO LS-X
                     COMPUTE LS-Z = LS-BZ0 - 1
                     MOVE LS-NORTH TO LS-DIR
                 WHEN 1 ALSO ANY
                     MOVE LS-BX0 TO LS-X
                     COMPUTE LS-Z = LS-BZ1 + 1
                     MOVE LS-SOUTH TO LS-DIR
                 WHEN OTHER
                     COMPUTE LS-Z = LS-BZ0
                     IF LS-R <= 1
                         COMPUTE LS-X = LS-BX1 + 1
                     ELSE
                         COMPUTE LS-X = LS-BX1 - 3
                         COMPUTE LS-Z = LS-BZ0 - 1
                         MOVE LS-NORTH TO LS-DIR
                         IF LS-R = 3
                             COMPUTE LS-Z = LS-BZ1 + 1
                             MOVE LS-SOUTH TO LS-DIR
                         END-IF
                     END-IF
             END-EVALUATE
             CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-DIR LS-DEPTH LS-CHILD
             IF LS-DEPTH < 8
                 COMPUTE LS-DEP1 = LS-DEPTH + 1
                 IF LS-D = 2 OR LS-D = 0
                     COMPUTE LS-I = LS-BZ0 + 3
                     PERFORM UNTIL LS-I + 3 > LS-BZ1
                         MOVE 5 TO LS-BOUND
                         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                         IF LS-DRAW = 0
                             COMPUTE LS-X = LS-BX0 - 1
                             MOVE LS-WEST TO LS-DIR
                             CALL "MS-GEN-ADD" USING L-ROW LS-X LS-BY0 LS-I LS-DIR LS-DEP1 LS-CHILD
                         END-IF
                         IF LS-DRAW = 1
                             COMPUTE LS-X = LS-BX1 + 1
                             MOVE LS-EAST TO LS-DIR
                             CALL "MS-GEN-ADD" USING L-ROW LS-X LS-BY0 LS-I LS-DIR LS-DEP1 LS-CHILD
                         END-IF
                         ADD 5 TO LS-I
                     END-PERFORM
                 ELSE
                     COMPUTE LS-I = LS-BX0 + 3
                     PERFORM UNTIL LS-I + 3 > LS-BX1
                         MOVE 5 TO LS-BOUND
                         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                         IF LS-DRAW = 0
                             COMPUTE LS-Z = LS-BZ0 - 1
                             MOVE LS-NORTH TO LS-DIR
                             CALL "MS-GEN-ADD" USING L-ROW LS-I LS-BY0 LS-Z LS-DIR LS-DEP1 LS-CHILD
                         END-IF
                         IF LS-DRAW = 1
                             COMPUTE LS-Z = LS-BZ1 + 1
                             MOVE LS-SOUTH TO LS-DIR
                             CALL "MS-GEN-ADD" USING L-ROW LS-I LS-BY0 LS-Z LS-DIR LS-DEP1 LS-CHILD
                         END-IF
                         ADD 5 TO LS-I
                     END-PERFORM
                 END-IF
             END-IF
         WHEN 1
*>           the crossing: three children on the lower level by the entry direction, then four upper children each behind its own nextBoolean when two floored
             MOVE SP-F2(L-ROW) TO LS-D
             MOVE LS-BY0 TO LS-Y
             EVALUATE LS-D
                 WHEN 2
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ0 - 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-NORTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX0 - 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-WEST LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX1 + 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-EAST LS-DEPTH LS-CHILD
                 WHEN 0
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ1 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-SOUTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX0 - 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-WEST LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX1 + 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-EAST LS-DEPTH LS-CHILD
                 WHEN 1
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ0 - 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-NORTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ1 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-SOUTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX0 - 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-WEST LS-DEPTH LS-CHILD
                 WHEN OTHER
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ0 - 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-NORTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ1 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-SOUTH LS-DEPTH LS-CHILD
                     COMPUTE LS-X = LS-BX1 + 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-EAST LS-DEPTH LS-CHILD
             END-EVALUATE
             IF SP-F1(L-ROW) = 1
                 COMPUTE LS-Y = LS-BY0 + 4
                 MOVE 2 TO LS-BOUND
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                 IF LS-DRAW = 1
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ0 - 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-NORTH LS-DEPTH LS-CHILD
                 END-IF
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                 IF LS-DRAW = 1
                     COMPUTE LS-X = LS-BX0 - 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-WEST LS-DEPTH LS-CHILD
                 END-IF
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                 IF LS-DRAW = 1
                     COMPUTE LS-X = LS-BX1 + 1
                     COMPUTE LS-Z = LS-BZ0 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-EAST LS-DEPTH LS-CHILD
                 END-IF
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG LS-BOUND LS-DRAW
                 IF LS-DRAW = 1
                     COMPUTE LS-X = LS-BX0 + 1
                     COMPUTE LS-Z = LS-BZ1 + 1
                     CALL "MS-GEN-ADD" USING L-ROW LS-X LS-Y LS-Z LS-SOUTH LS-DEPTH LS-CHILD
                 END-IF
             END-IF
         WHEN OTHER
*>           the stairs: one child in the piece's own direction
             MOVE SP-ORIENT(L-ROW) TO LS-D
             MOVE LS-BX0 TO LS-X
             MOVE LS-BZ0 TO LS-Z
             EVALUATE LS-D
                 WHEN 2
                     COMPUTE LS-Z = LS-BZ0 - 1
                 WHEN 0
                     COMPUTE LS-Z = LS-BZ1 + 1
                 WHEN 1
                     COMPUTE LS-X = LS-BX0 - 1
                 WHEN OTHER
                     COMPUTE LS-X = LS-BX1 + 1
             END-EVALUATE
             CALL "MS-GEN-ADD" USING L-ROW LS-X LS-BY0 LS-Z LS-D LS-DEPTH LS-CHILD
     END-EVALUATE
     GOBACK.
 END PROGRAM MS-CHILDREN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-DISCARD             FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG VALUE 50.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-OFFSET              BINARY-LONG VALUE 10.
 01 WS-DY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-MST                  BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-MST L-SEA L-MIN-Y L-X L-Y L-Z L-VALID.
     MOVE 0 TO L-VALID
     MOVE 0 TO L-X L-Y L-Z
     IF L-MST NOT = 0
         GOBACK
     END-IF
     CALL "SPB-RESET"
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
     CALL "STRUCT-NEXT-DOUBLE" USING SP-RNG WS-DISCARD
     COMPUTE WS-X0 = L-CX * 16 + 2
     COMPUTE WS-Z0 = L-CZ * 16 + 2
     MOVE 6 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE WS-X1 = WS-X0 + 7 + WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE WS-Y1 = 54 + WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     COMPUTE WS-Z1 = WS-Z0 + 7 + WS-DRAW
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-ADD" USING WS-TYPE WS-NONE WS-DEPTH L-MST WS-BOX WS-ROW
     CALL "MS-CHILDREN" USING WS-ROW
     CALL "SPB-MOVE-BELOW-SEA" USING L-SEA L-MIN-Y WS-OFFSET WS-DY
     COMPUTE L-X = L-CX * 16 + 8
     COMPUTE L-Y = 50 + WS-DY
     COMPUTE L-Z = L-CZ * 16
     MOVE 1 TO L-VALID
     GOBACK.
 END PROGRAM MS-FIND-POINT.
