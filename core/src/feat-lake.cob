*> The lake feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 3; registry id 25, lake): FD-LAKE-NODE compiles the configuration into a row of FD-WA (WA-PV(1) the
*> fluid provider, WA-PV(2) the barrier provider, WA-PR(1) can_place_feature, WA-PR(2) can_replace_with_air_or_fluid, WA-PR(3) can_replace_with_barrier, WA-I(1) the block index of
*> cave_air), FR-LAKE places it: a lumpy pool of 4 to 7 ellipsoids in a 16 x 8 x 16 window whose lower four layers are the fluid and the upper four cave air, lined with the barrier.
*> The blobs use the doubles of the document in the decimal arithmetic of the compiler (deterministic, as the fancy trunk); the per-axis squares of an ellipsoid are computed once per
*> axis, and the sums are added in the order nx, ny, nz. Deviations: the cave_air tick and the post-processing marks of steps 6 and 7 are not made (the generator has no tick queue and
*> no post-processing list); the window of the level is the chunk and the terrain of a neighbour is not known: the cells of the pool outside the chunk are not tested (the
*> validity pass skips a border cell outside), not written and draw nothing in the barrier pass (the pool is cut at the chunk border, no overflow entry). The freeze pass of step 8 (water lakes only) is FR-LAKE-FREEZE: it tests the cells of layer 4 as the document says, and the temperature is FR-TEMPERATURE of
*> core/src/feat-freeze.cob (WA-I(2) is the block index of ice, 0 when the block table has none: no freeze pass).
*>
*> Entry points: FD-LAKE-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-LAKE-MASK USING state, mask out (PIC X(2048): the digits 0 and 1, cell
*> ((x * 16) + z) * 8 + y + 1: steps 2 and 3); FR-LAKE USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-LAKE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-KEY48               PIC X(48) VALUE "minecraft:cave_air".
 01 WS-ICE                 PIC X(48) VALUE "minecraft:ice".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FLUID WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-BARRIER WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CAN-PLACE WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CAN-REPLACE-AF WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CAN-REPLACE-B WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 3)
     CALL "FD-BLOCK-INDEX" USING WS-KEY48 WA-I(WS-ROW, 1)
     IF WA-I(WS-ROW, 1) = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-BLOCK-INDEX" USING WS-ICE WA-I(WS-ROW, 2)
     GOBACK.
 END PROGRAM FD-LAKE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-LAKE-MASK.
*> USING state, mask out (PIC X(2048)): steps 2 and 3 of section 3.2: blobs = nextInt(4) + 4 ellipsoids; per blob a, b, c, cx, cy, cz in this order, then every cell (x, z in 1 to 14, y in
*> 1 to 6, x outermost) with nx^2 + ny^2 + nz^2 < 1 is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-BLOBS               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-HA                  FLOAT-LONG.
 01 WS-HB                  FLOAT-LONG.
 01 WS-HC                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-XZ                  FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-SQUARES.
    05 WS-XS               FLOAT-LONG OCCURS 14 TIMES.
    05 WS-YS               FLOAT-LONG OCCURS 6 TIMES.
    05 WS-ZS               FLOAT-LONG OCCURS 14 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-MASK                 PIC X(2048).
 PROCEDURE DIVISION USING L-STATE L-MASK.
     MOVE ALL "0" TO L-MASK
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-BLOBS
     ADD 4 TO WS-BLOBS
     PERFORM WS-BLOBS TIMES
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-A = WS-D * 6 + 3
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-B = WS-D * 4 + 2
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-C = WS-D * 6 + 3
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-CX = WS-D * (16 - WS-A - 2) + 1 + WS-A / 2
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-CY = WS-D * (8 - WS-B - 4) + 2 + WS-B / 2
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-CZ = WS-D * (16 - WS-C - 2) + 1 + WS-C / 2
         COMPUTE WS-HA = WS-A / 2
         COMPUTE WS-HB = WS-B / 2
         COMPUTE WS-HC = WS-C / 2
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 14
             COMPUTE WS-T = (WS-N - WS-CX) / WS-HA
             COMPUTE WS-XS(WS-N) = WS-T * WS-T
             COMPUTE WS-T = (WS-N - WS-CZ) / WS-HC
             COMPUTE WS-ZS(WS-N) = WS-T * WS-T
         END-PERFORM
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6
             COMPUTE WS-T = (WS-N - WS-CY) / WS-HB
             COMPUTE WS-YS(WS-N) = WS-T * WS-T
         END-PERFORM
         PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 14
             PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 14
                 COMPUTE WS-XZ = WS-XS(WS-X) + WS-ZS(WS-Z)
                 IF WS-XZ < WS-ONE
                     PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 6
                         COMPUTE WS-SUM = WS-XS(WS-X) + WS-YS(WS-Y) + WS-ZS(WS-Z)
                         IF WS-SUM < WS-ONE
                             COMPUTE WS-INDEX = (WS-X * 16 + WS-Z) * 8 + WS-Y + 1
                             MOVE "1" TO L-MASK(WS-INDEX:1)
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-LAKE-MASK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-LAKE.
*> USING state, feature, x, y, z, result out (1 when the lake was placed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MASK                PIC X(2048).
 01 WS-BORDER              PIC X(2048).
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NINDEX              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-BARRIER             BINARY-LONG.
 01 WS-CAVE-AIR            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-FAIL                BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-DIRS.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR OCCURS 6 TIMES.
       10 WS-DX            BINARY-LONG.
       10 WS-DY            BINARY-LONG.
       10 WS-DZ            BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
*>   1. too close to the bottom
     IF L-Y <= FL-MIN-Y + 4
         GOBACK
     END-IF
     COMPUTE WS-OX = L-X - 8
     COMPUTE WS-OY = L-Y - 4
     COMPUTE WS-OZ = L-Z - 8
     CALL "FR-LAKE-MASK" USING L-STATE WS-MASK
*>   4. the fluid state, from the provider (a plain state in the data, so no draw)
     CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-OX WS-OY WS-OZ WS-FLUID WS-OK
     MOVE WA-I(WS-ROW, 1) TO WS-K
     MOVE CB-DEFAULT-STATE(WS-K) TO WS-CAVE-AIR
*>   the border cells: not in the mask, with a neighbour inside the window that is
     MOVE ALL "0" TO WS-BORDER
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 7
                 COMPUTE WS-INDEX = (WS-X * 16 + WS-Z) * 8 + WS-Y + 1
                 IF WS-MASK(WS-INDEX:1) = "0"
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         COMPUTE WS-NX = WS-X + WS-DX(WS-K)
                         COMPUTE WS-NY = WS-Y + WS-DY(WS-K)
                         COMPUTE WS-NZ = WS-Z + WS-DZ(WS-K)
                         IF WS-NX >= 0 AND WS-NX <= 15 AND WS-NY >= 0 AND WS-NY <= 7 AND WS-NZ >= 0 AND WS-NZ <= 15
                             COMPUTE WS-NINDEX = (WS-NX * 16 + WS-NZ) * 8 + WS-NY + 1
                             IF WS-MASK(WS-NINDEX:1) = "1"
                                 MOVE "1" TO WS-BORDER(WS-INDEX:1)
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   5. the validity pass: nothing is written before it passes
     MOVE 0 TO WS-FAIL
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15 OR WS-FAIL = 1
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15 OR WS-FAIL = 1
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 7 OR WS-FAIL = 1
                 COMPUTE WS-INDEX = (WS-X * 16 + WS-Z) * 8 + WS-Y + 1
                 MOVE 0 TO WS-IN
                 IF WS-BORDER(WS-INDEX:1) = "1"
                     COMPUTE WS-PX = WS-OX + WS-X
                     COMPUTE WS-PY = WS-OY + WS-Y
                     COMPUTE WS-PZ = WS-OZ + WS-Z
                     COMPUTE WS-LX = WS-PX - FL-CX * 16
                     COMPUTE WS-LZ = WS-PZ - FL-CZ * 16
                     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
                         MOVE 1 TO WS-IN
                     END-IF
                 END-IF
*>               a border cell outside the chunk is not known (the neighbour's terrain is not generated yet): it is not tested
                 IF WS-IN = 1
                     CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     IF WS-Y >= 4 AND (WS-CLASS = 2 OR WS-CLASS = 3)
                         MOVE 1 TO WS-FAIL
                     END-IF
                     MOVE 0 TO WS-SOLID
                     IF WS-CLASS = 0 AND WS-BLOCK > 0
                         MOVE CB-SOLID(WS-BLOCK) TO WS-SOLID
                     END-IF
                     IF WS-Y < 4 AND WS-STATE NOT = WS-FLUID AND WS-SOLID = 0
                         MOVE 1 TO WS-FAIL
                     END-IF
                     IF WS-FAIL = 0
                         MOVE WA-PR(WS-ROW, 1) TO WS-K
                         CALL "FR-PRED-TEST" USING WS-K WS-PX WS-PY WS-PZ WS-TEST
                         IF WS-TEST = 0
                             MOVE 1 TO WS-FAIL
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-FAIL = 1
         GOBACK
     END-IF
*>   6. the fill pass: cave air above, the fluid below
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 7
                 COMPUTE WS-INDEX = (WS-X * 16 + WS-Z) * 8 + WS-Y + 1
                 MOVE 0 TO WS-IN
                 IF WS-MASK(WS-INDEX:1) = "1"
                     COMPUTE WS-PX = WS-OX + WS-X
                     COMPUTE WS-PY = WS-OY + WS-Y
                     COMPUTE WS-PZ = WS-OZ + WS-Z
                     COMPUTE WS-LX = WS-PX - FL-CX * 16
                     COMPUTE WS-LZ = WS-PZ - FL-CZ * 16
                     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
                         MOVE 1 TO WS-IN
                     END-IF
                 END-IF
*>               the pool is cut at the chunk border: the cells of the neighbour are left to its terrain
                 IF WS-IN = 1
                     MOVE WA-PR(WS-ROW, 2) TO WS-K
                     CALL "FR-PRED-TEST" USING WS-K WS-PX WS-PY WS-PZ WS-TEST
                     IF WS-TEST = 1
                         IF WS-Y >= 4
                             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-CAVE-AIR WS-FLAGS WS-OK
                         ELSE
                             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-FLUID WS-FLAGS WS-OK
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   7. the barrier pass: a block that is not air is laid around the pool; the upper half of the wall is laid on one in two cells
     CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 2) WS-OX WS-OY WS-OZ WS-BARRIER WS-OK
     CALL "FL-CLASS" USING WS-BARRIER WS-CLASS
     IF WS-CLASS NOT = 1
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 7
                     COMPUTE WS-INDEX = (WS-X * 16 + WS-Z) * 8 + WS-Y + 1
                     IF WS-BORDER(WS-INDEX:1) = "1"
                         MOVE 1 TO WS-DRAW
                         IF WS-Y >= 4
                             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
                         END-IF
                         COMPUTE WS-PX = WS-OX + WS-X
                         COMPUTE WS-PZ = WS-OZ + WS-Z
                         COMPUTE WS-LX = WS-PX - FL-CX * 16
                         COMPUTE WS-LZ = WS-PZ - FL-CZ * 16
                         IF WS-LX < 0 OR WS-LX > 15 OR WS-LZ < 0 OR WS-LZ > 15
                             MOVE 0 TO WS-DRAW
                         END-IF
                         IF WS-DRAW = 1
                             COMPUTE WS-PY = WS-OY + WS-Y
                             CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
                             CALL "FL-CLASS" USING WS-STATE WS-CLASS
                             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                             MOVE 0 TO WS-SOLID
                             IF WS-CLASS = 0 AND WS-BLOCK > 0
                                 MOVE CB-SOLID(WS-BLOCK) TO WS-SOLID
                             END-IF
                             IF WS-SOLID = 1
                                 MOVE WA-PR(WS-ROW, 3) TO WS-K
                                 CALL "FR-PRED-TEST" USING WS-K WS-PX WS-PY WS-PZ WS-TEST
                                 IF WS-TEST = 1
                                     CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-BARRIER WS-FLAGS WS-OK
                                 END-IF
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
*>   8. water freezes in the cold: the cells of layer 4
     CALL "FL-BLOCK-OF" USING WS-FLUID WS-BLOCK
     IF WS-BLOCK = FL-B-WATER AND WA-I(WS-ROW, 2) > 0
         CALL "FR-LAKE-FREEZE" USING WS-ROW WS-OX WS-OY WS-OZ
     END-IF
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-LAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-LAKE-FREEZE.
*> USING feature row, origin x, y, z: step 8 of section 3.2: for x, z in 0 to 15, the cell at layer 4 becomes ice when it holds a source of water, the temperature there is under 0.15 and
*> can_replace_with_air_or_fluid holds.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-T                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.15.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OX L-OY L-OZ.
     MOVE FL-B-WATER TO WS-K
     MOVE CB-DEFAULT-STATE(WS-K) TO WS-WATER
     MOVE WA-I(L-ROW, 2) TO WS-K
     MOVE CB-DEFAULT-STATE(WS-K) TO WS-ICE
     COMPUTE WS-PY = L-OY + 4
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             COMPUTE WS-PX = L-OX + WS-X
             COMPUTE WS-PZ = L-OZ + WS-Z
             CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
             IF WS-STATE = WS-WATER
                 CALL "FL-BIOME-ID" USING WS-PX WS-PY WS-PZ WS-BIOME
                 CALL "FR-TEMPERATURE" USING WS-BIOME WS-PX WS-PY WS-PZ FL-SEA WS-T
                 MOVE WA-PR(L-ROW, 2) TO WS-K
                 CALL "FR-PRED-TEST" USING WS-K WS-PX WS-PY WS-PZ WS-TEST
                 IF WS-T < WS-LIMIT AND WS-TEST = 1
                     CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-ICE WS-FLAGS WS-OK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-LAKE-FREEZE.
