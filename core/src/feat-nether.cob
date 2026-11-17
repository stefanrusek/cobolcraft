*> The Nether features of docs/protocol/35-worldgen-features-7-nether-end-misc.md sections 3 to 5 and 35-4 section 7: delta_feature (registry id 9, FD-DELTA-NODE and FR-DELTA), stepped_column_cluster (49,
*> FD-STEP-NODE and FR-STEP: the basalt columns), single_block_pillar (44, FD-PILLAR-NODE and FR-PILLAR), random_neighbor_spread (35, FD-NSPREAD-NODE and FR-NSPREAD) and
*> projected_random_patchy_square (33, FD-PATCHY-NODE and FR-PATCHY). Each takes a row of FD-WA (the generic row of FEATDATA.cpy; the fields are named in each node's header). Compile
*> failures (a missing member, a provider or predicate the compiler cannot read, a block table without the blocks) make the feature unsupported (FD-BAD, the caller sets type -1).
*> replace_single_block (35-4 7.5) is not compiled: its rule tests are not read (no element of the data uses it).
*>
*> Entry points: F* NODE USING doc, node, row out; FR-* USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-NETHER-ROW.
*> USING row out: a new cleared row of FD-WA, 0 and FD-BAD when the table is full.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO L-ROW
     INITIALIZE FD-WA(L-ROW)
     GOBACK.
 END PROGRAM FD-NETHER-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-DELTA-NODE.
*> USING doc, node, row out: WA-I(1) the state of contents, WA-I(2) of rim, WA-I(3) the block of contents, WA-IP(1) size, WA-IP(2) rim_size (ranges 0 to 16), pool 1 the blocks of CANNOT_REPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-CONTENTS          PIC X(40) VALUE "contents".
 01 WS-K-RIM               PIC X(40) VALUE "rim".
 01 WS-K-SIZE              PIC X(40) VALUE "size".
 01 WS-K-RIM-SIZE          PIC X(40) VALUE "rim_size".
 01 WS-CANNOT.
    05 FILLER              PIC X(48) VALUE "minecraft:bedrock".
    05 FILLER              PIC X(48) VALUE "minecraft:nether_bricks".
    05 FILLER              PIC X(48) VALUE "minecraft:nether_brick_fence".
    05 FILLER              PIC X(48) VALUE "minecraft:nether_brick_stairs".
    05 FILLER              PIC X(48) VALUE "minecraft:nether_wart".
    05 FILLER              PIC X(48) VALUE "minecraft:chest".
    05 FILLER              PIC X(48) VALUE "minecraft:spawner".
 01 WS-CANNOT-T REDEFINES WS-CANNOT.
    05 WS-CN               PIC X(48) OCCURS 7 TIMES.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-NETHER-ROW" USING L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CONTENTS WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     MOVE WA-I(L-ROW, 1) TO WS-ST
     CALL "FL-BLOCK-OF" USING WS-ST WS-BL
     MOVE WS-BL TO WA-I(L-ROW, 3)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RIM WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(L-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SIZE WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RIM-SIZE WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     COMPUTE WA-START(L-ROW, 1) = FD-POOL-COUNT + 1
     MOVE 0 TO WA-N(L-ROW, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "FD-BLOCK-INDEX" USING WS-CN(WS-I) WS-B
         IF WS-B > 0
             CALL "FD-POOL-ADD" USING WS-B WS-IDX
             ADD 1 TO WA-N(L-ROW, 1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FD-DELTA-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DELTA-CLEAR.
*> USING row, x, y, z, flag out: isClear (3): the block at the cell is not the block of contents nor one of CANNOT_REPLACE, and the horizontal and down neighbours are not air while the one above is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = WA-I(L-ROW, 3)
         GOBACK
     END-IF
     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-HAS
     IF WS-HAS = 1
         GOBACK
     END-IF
     MOVE 1 TO L-FLAG
*>   the six directions DOWN, UP, NORTH, SOUTH, WEST, EAST
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         CALL "F353-STEP" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-D = 1
             IF WS-CLASS NOT = 1
                 MOVE 0 TO L-FLAG
             END-IF
         ELSE
             IF WS-CLASS = 1
                 MOVE 0 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-DELTA-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-DELTA.
*> USING state, feature, x, y, z, result out: delta_feature (3): useRim = nextDouble() < 0.9; rimX then rimZ (rim_size draws, only when useRim); sizeX, sizeZ; the diamond walk of 2.3 over
*> (sizeX, 0, sizeZ) stopping at distances above max(sizeX, sizeZ): at a clear cell the rim goes there when the rim is active (useRim and both rim offsets non-zero), then the contents at the cell shifted
*> by (rimX, 0, rimZ) when that is clear; true when something was placed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-USE                 BINARY-LONG.
 01 WS-RIMX                BINARY-LONG.
 01 WS-RIMZ                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LIM                 BINARY-LONG.
 01 WS-LIMX                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-NINETY              FLOAT-LONG VALUE 0.9.
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
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-F
     MOVE 0 TO WS-USE WS-RIMX WS-RIMZ
     IF WS-F < WS-NINETY
         MOVE 1 TO WS-USE
         CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-RIMX
         CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-RIMZ
     END-IF
     MOVE 0 TO WS-ACTIVE
     IF WS-USE = 1 AND WS-RIMX NOT = 0 AND WS-RIMZ NOT = 0
         MOVE 1 TO WS-ACTIVE
     END-IF
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-SX
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-SZ
     COMPUTE WS-MAX = FUNCTION MAX(WS-SX, WS-SZ)
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > WS-MAX
         COMPUTE WS-LIMX = FUNCTION MIN(WS-SX, WS-D)
         PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2 * WS-LIMX
             COMPUTE WS-PX = WS-DX - WS-LIMX
             COMPUTE WS-LIM = WS-D - FUNCTION ABS(WS-PX)
             IF WS-LIM <= WS-SZ
                 PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 1
*>                   the offset (x, +dz) first, then (x, -dz) when dz is not 0
                     IF WS-S = 0
                         MOVE WS-LIM TO WS-DZ
                     ELSE
                         COMPUTE WS-DZ = 0 - WS-LIM
                     END-IF
                     IF WS-S = 0 OR WS-LIM NOT = 0
                         COMPUTE WS-QX = L-X + WS-PX
                         COMPUTE WS-QZ = L-Z + WS-DZ
                         PERFORM VISIT
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GO TO MAIN-EXIT.
 VISIT.
     CALL "FR-DELTA-CLEAR" USING WS-ROW WS-QX L-Y WS-QZ WS-FLAG
     IF WS-FLAG = 1
         IF WS-ACTIVE = 1
             CALL "FL-SET-STATE" USING WS-QX L-Y WS-QZ WA-I(WS-ROW, 2) WS-FLAGS WS-OK
             MOVE 1 TO L-RESULT
         END-IF
         COMPUTE WS-TX = WS-QX + WS-RIMX
         COMPUTE WS-TZ = WS-QZ + WS-RIMZ
         CALL "FR-DELTA-CLEAR" USING WS-ROW WS-TX L-Y WS-TZ WS-FLAG
         IF WS-FLAG = 1
             CALL "FL-SET-STATE" USING WS-TX L-Y WS-TZ WA-I(WS-ROW, 1) WS-FLAGS WS-OK
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-DELTA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-STEP-NODE.
*> USING doc, node, row out: stepped_column_cluster: WA-PV(1) block, WA-PR(1) continue_through, WA-PR(2) can_replace, pool 1 cannot_place_on, WA-IP(1) cluster_reach, WA-IP(2) column_count,
*> WA-IP(3) column_reach, and height in WA-IP(4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-BLOCK             PIC X(40) VALUE "block".
 01 WS-K-CONT              PIC X(40) VALUE "continue_through".
 01 WS-K-REPL              PIC X(40) VALUE "can_replace".
 01 WS-K-CANNOT            PIC X(40) VALUE "cannot_place_on".
 01 WS-K-CLUSTER           PIC X(40) VALUE "cluster_reach".
 01 WS-K-COUNT             PIC X(40) VALUE "column_count".
 01 WS-K-REACH             PIC X(40) VALUE "column_reach".
 01 WS-K-HEIGHT            PIC X(40) VALUE "height".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-NETHER-ROW" USING L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCK WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CONT WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPL WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(L-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CANNOT WS-E
     IF WS-E = 0
         MOVE 1 TO FD-BAD
     ELSE
         CALL "FD-J-BLOCKS" USING JSON-DOC WS-E WS-MODE WA-START(L-ROW, 1) WA-N(L-ROW, 1)
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CLUSTER WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-COUNT WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REACH WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 3) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-HEIGHT WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 4) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-STEP-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-STEP-CAN.
*> USING row, predicate slot (1 continue_through, 2 can_replace), x, y, z, flag out: the predicate holds at the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-X L-Y L-Z L-FLAG.
     CALL "FR-PRED-TEST" USING WA-PR(L-ROW, L-SLOT) L-X L-Y L-Z L-FLAG
     GOBACK.
 END PROGRAM FR-STEP-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-STEP-CPA.
*> USING row, x, y, z, flag out: canPlaceAt (4): can_replace holds at the cell and the block below is neither air nor in cannot_place_on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-BY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     CALL "FR-STEP-CAN" USING L-ROW WS-TWO L-X L-Y L-Z L-FLAG
     IF L-FLAG = 1
         COMPUTE WS-BY = L-Y - 1
         CALL "FL-GET-STATE" USING L-X WS-BY L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-HAS
         IF WS-CLASS = 1 OR WS-HAS = 1
             MOVE 0 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-STEP-CPA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-STEP-COLUMN.
*> USING state, row, center x, y, z, h, r, placed out: placeColumn (4): the cells of the (2 r + 1) square at the centre's y, z outer and x inner; with dist the Manhattan distance to the centre, the
*> start is findSurface (the cell is replaceable) or findAir; n = h - dist div 2 blocks go up from it while the cursor is replaceable (the provider's state) or continue_through lets it pass.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-DIST                BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-MAXY                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-LZ0                 BINARY-LONG.
 01 WS-LZ1                 BINARY-LONG.
 01 WS-LX0                 BINARY-LONG.
 01 WS-LX1                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-CX L-CY L-CZ L-H L-R L-PLACED.
     MOVE 0 TO L-PLACED
     MOVE L-CY TO WS-CY
     COMPUTE WS-MAXY = FL-MIN-Y + FL-HEIGHT - 1
     COMPUTE WS-LZ0 = L-CZ - L-R
     COMPUTE WS-LZ1 = L-CZ + L-R
     COMPUTE WS-LX0 = L-CX - L-R
     COMPUTE WS-LX1 = L-CX + L-R
     PERFORM VARYING WS-QZ FROM WS-LZ0 BY 1 UNTIL WS-QZ > WS-LZ1
         PERFORM VARYING WS-QX FROM WS-LX0 BY 1 UNTIL WS-QX > WS-LX1
             COMPUTE WS-DIST = FUNCTION ABS(WS-QX - L-CX) + FUNCTION ABS(WS-QZ - L-CZ)
             CALL "FR-STEP-CAN" USING L-ROW WS-TWO WS-QX WS-CY WS-QZ WS-CAN
             MOVE 0 TO WS-HAVE
             MOVE WS-CY TO WS-START
             IF WS-CAN = 1
*>               findSurface: down, at most dist cells, while y is above minY + 1
                 MOVE WS-CY TO WS-START
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-DIST OR WS-HAVE = 1 OR WS-START <= FL-MIN-Y + 1
                     CALL "FR-STEP-CPA" USING L-ROW WS-QX WS-START WS-QZ WS-OK
                     IF WS-OK = 1
                         MOVE 1 TO WS-HAVE
                     ELSE
                         SUBTRACT 1 FROM WS-START
                     END-IF
                 END-PERFORM
             ELSE
*>               findAir: up, at most dist cells, while y is not above the build height
                 MOVE 0 TO WS-STOP
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-DIST OR WS-HAVE = 1 OR WS-STOP = 1 OR WS-START > WS-MAXY
                     CALL "FL-GET-STATE" USING WS-QX WS-START WS-QZ WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-HAS
                     IF WS-HAS = 1
                         MOVE 1 TO WS-STOP
                     ELSE
                         IF WS-CLASS = 1
                             MOVE 1 TO WS-HAVE
                         ELSE
                             ADD 1 TO WS-START
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
             IF WS-HAVE = 1
                 DIVIDE WS-DIST BY 2 GIVING WS-HALF
                 COMPUTE WS-N = L-H - WS-HALF
                 MOVE 0 TO WS-STOP
                 PERFORM UNTIL WS-N < 0 OR WS-STOP = 1
                     CALL "FR-STEP-CAN" USING L-ROW WS-TWO WS-QX WS-START WS-QZ WS-CAN
                     IF WS-CAN = 1
                         CALL "FR-PROV-STATE" USING L-STATE WA-PV(L-ROW, 1) WS-QX WS-START WS-QZ WS-NEW WS-OK
                         IF WS-OK = 1
                             CALL "FL-SET-STATE" USING WS-QX WS-START WS-QZ WS-NEW WS-FLAGS WS-OK
                         END-IF
                         ADD 1 TO WS-START
                         MOVE 1 TO L-PLACED
                     ELSE
                         CALL "FR-STEP-CAN" USING L-ROW WS-ONE WS-QX WS-START WS-QZ WS-CAN
                         IF WS-CAN = 1
                             ADD 1 TO WS-START
                         ELSE
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                     SUBTRACT 1 FROM WS-N
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-STEP-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-STEP.
*> USING state, feature, x, y, z, result out: stepped_column_cluster (4): canPlaceAt(origin) or false; height, then reach = min(height, cluster_reach), then count are drawn; for each of count positions
*> drawn lazily as x, y (one value), z over the origin's reach square: remaining = height - Manhattan distance to the origin; when it is not negative column_reach is drawn and the column placed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-REACH               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
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
     CALL "FR-STEP-CPA" USING WS-ROW L-X L-Y L-Z WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 4) WS-H
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-T
     COMPUTE WS-REACH = FUNCTION MIN(WS-H, WS-T)
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-COUNT
     COMPUTE WS-SPAN = 2 * WS-REACH + 1
     PERFORM WS-COUNT TIMES
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-D
         COMPUTE WS-PX = L-X - WS-REACH + WS-D
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-ONE WS-D
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-D
         COMPUTE WS-PZ = L-Z - WS-REACH + WS-D
         COMPUTE WS-REM = WS-H - FUNCTION ABS(WS-PX - L-X) - FUNCTION ABS(WS-PZ - L-Z)
         IF WS-REM >= 0
             CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 3) WS-R
             CALL "FR-STEP-COLUMN" USING L-STATE WS-ROW WS-PX L-Y WS-PZ WS-REM WS-R WS-PLACED
             IF WS-PLACED = 1
                 MOVE 1 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PILLAR-NODE.
*> USING doc, node, row out: single_block_pillar: WA-PV(1) block, WA-PR(1) can_replace (0: always), WA-I(1) direction (1 up, -1 down), WA-F(1) chance_to_continue (default 1), WA-I(2) the cap placed feature (0 none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-BLOCK             PIC X(40) VALUE "block".
 01 WS-K-REPL              PIC X(40) VALUE "can_replace".
 01 WS-K-DIR               PIC X(40) VALUE "direction".
 01 WS-K-CHANCE            PIC X(40) VALUE "chance_to_continue".
 01 WS-K-CAP               PIC X(40) VALUE "cap_feature".
 01 WS-TEXT                PIC X(120).
 01 WS-ONE-F               FLOAT-LONG VALUE 1.0.
 01 WS-LEN                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-NETHER-ROW" USING L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCK WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPL WS-E
     IF WS-E > 0
         CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(L-ROW, 1)
     END-IF
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-TEXT
     CALL "FD-J-STRING" USING JSON-DOC WS-K-DIR L-NODE WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "up"
             MOVE 1 TO WA-I(L-ROW, 1)
         WHEN "down"
             MOVE -1 TO WA-I(L-ROW, 1)
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-CHANCE WS-ONE-F WA-F(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CAP WS-E
     IF WS-E > 0
         CALL "FD-PFREF-NODE" USING JSON-DOC WS-E WA-I(L-ROW, 2)
         IF WA-I(L-ROW, 2) = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-PILLAR-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PILLAR.
*> USING state, feature, x, y, z, result out: single_block_pillar (35-4 7.2): while can_replace holds at the cursor, nextFloat() (drawn only then) must be below chance_to_continue and the cursor inside the
*> build height, the provider's state is set (flags 2) and the cursor steps in the direction; then one step back and the cap placed feature there. Always true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE WA-I(WS-ROW, 1) TO WS-DIR
     MOVE WA-F(WS-ROW, 1) TO WS-P
     CALL "FR-F32" USING WS-P
     MOVE L-Y TO WS-Y
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1
         MOVE 1 TO WS-CAN
         IF WA-PR(WS-ROW, 1) > 0
             CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) L-X WS-Y L-Z WS-CAN
         END-IF
         IF WS-CAN = 0
             MOVE 1 TO WS-STOP
         ELSE
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F >= WS-P OR WS-Y < FL-MIN-Y OR WS-Y >= FL-MIN-Y + FL-HEIGHT
                 MOVE 1 TO WS-STOP
             ELSE
                 CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) L-X WS-Y L-Z WS-NEW WS-OK
                 IF WS-OK = 1
                     CALL "FL-SET-STATE" USING L-X WS-Y L-Z WS-NEW WS-FLAGS WS-OK
                 END-IF
                 ADD WS-DIR TO WS-Y
             END-IF
         END-IF
     END-PERFORM
     SUBTRACT WS-DIR FROM WS-Y
     IF WA-I(WS-ROW, 2) > 0
         MOVE WA-I(WS-ROW, 2) TO WS-PF
         CALL "FR-PLACE-PF" USING L-STATE WS-PF WS-TOP L-X WS-Y L-Z WS-OK
     END-IF
     GOBACK.
 END PROGRAM FR-PILLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-NSPREAD-NODE.
*> USING doc, node, row out: random_neighbor_spread: WA-PV(1) block, pool 1 accepted_neighbors, WA-PR(1) can_replace, WA-IP(1) attempts, WA-IP(2) xz_offset, WA-IP(3) y_offset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-BLOCK             PIC X(40) VALUE "block".
 01 WS-K-ACC               PIC X(40) VALUE "accepted_neighbors".
 01 WS-K-REPL              PIC X(40) VALUE "can_replace".
 01 WS-K-ATT               PIC X(40) VALUE "attempts".
 01 WS-K-XZ                PIC X(40) VALUE "xz_offset".
 01 WS-K-Y                 PIC X(40) VALUE "y_offset".
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-NETHER-ROW" USING L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCK WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ACC WS-E
     IF WS-E = 0
         MOVE 1 TO FD-BAD
     ELSE
         CALL "FD-J-BLOCKS" USING JSON-DOC WS-E WS-MODE WA-START(L-ROW, 1) WA-N(L-ROW, 1)
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPL WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ATT WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-XZ WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-Y WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 3) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-NSPREAD-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-NSPREAD.
*> USING state, feature, x, y, z, result out: random_neighbor_spread (35-4 7.3): the provider's state at the origin; then attempts times q = origin + (xz, y, xz) (drawn in that order); when can_replace
*> holds at q and exactly one of the six neighbours is an accepted block, the state goes there. Always true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) L-X L-Y L-Z WS-NEW WS-OK
     IF WS-OK = 1
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-OK
     END-IF
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-N
     PERFORM WS-N TIMES
         CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-DX
         CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 3) WS-DY
         CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-DZ
         COMPUTE WS-QX = L-X + WS-DX
         COMPUTE WS-QY = L-Y + WS-DY
         COMPUTE WS-QZ = L-Z + WS-DZ
         CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) WS-QX WS-QY WS-QZ WS-CAN
         IF WS-CAN = 1
             MOVE 0 TO WS-COUNT
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5 OR WS-COUNT > 1
                 CALL "F353-STEP" USING WS-D WS-NX WS-NY WS-NZ
                 COMPUTE WS-NX = WS-QX + WS-NX
                 COMPUTE WS-NY = WS-QY + WS-NY
                 COMPUTE WS-NZ = WS-QZ + WS-NZ
                 CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 MOVE 0 TO WS-HAS
                 IF WS-BLOCK > 0
                     CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 1) WA-N(WS-ROW, 1) WS-BLOCK WS-HAS
                 END-IF
                 IF WS-HAS = 1
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
             IF WS-COUNT = 1
                 CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-QX WS-QY WS-QZ WS-NEW WS-OK
                 IF WS-OK = 1
                     CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-NEW WS-FLAGS WS-OK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-NSPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PATCHY-NODE.
*> USING doc, node, row out: projected_random_patchy_square: WA-PV(1) block, WA-PR(1) project_through, WA-IP(1) size, WA-I(1) max_projection_height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-BLOCK             PIC X(40) VALUE "block".
 01 WS-K-THROUGH           PIC X(40) VALUE "project_through".
 01 WS-K-SIZE              PIC X(40) VALUE "size".
 01 WS-K-MAX               PIC X(40) VALUE "max_projection_height".
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-NETHER-ROW" USING L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCK WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-PV(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-THROUGH WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(L-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SIZE WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MAX WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-PATCHY-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PATCHY.
*> USING state, feature, x, y, z, result out: projected_random_patchy_square (35-4 7.6): s = size, cap = s * s + 1; for dx, dz in -s .. s (x outer) one nextInt(cap) per cell, kept when below cap - |dx dz|;
*> the cell goes down while project_through holds on the cell below (at most max_projection_height steps, at least one when it holds); the provider's optional state is set there. Always true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-S
     COMPUTE WS-CAP = WS-S * WS-S + 1
     COMPUTE WS-LO = 0 - WS-S
     PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-S
         PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-S
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-CAP WS-V
             IF WS-V < WS-CAP - FUNCTION ABS(WS-DX) * FUNCTION ABS(WS-DZ)
                 COMPUTE WS-PX = L-X + WS-DX
                 MOVE L-Y TO WS-PY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 MOVE WA-I(WS-ROW, 1) TO WS-K
                 MOVE 0 TO WS-STOP
                 PERFORM UNTIL WS-STOP = 1
                     COMPUTE WS-BY = WS-PY - 1
                     CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) WS-PX WS-BY WS-PZ WS-CAN
                     IF WS-CAN = 0
                         MOVE 1 TO WS-STOP
                     ELSE
                         SUBTRACT 1 FROM WS-PY
                         SUBTRACT 1 FROM WS-K
                         IF WS-K <= 0
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                 END-PERFORM
                 CALL "FR-PROV-STATE" USING L-STATE WA-PV(WS-ROW, 1) WS-PX WS-PY WS-PZ WS-NEW WS-OK
                 IF WS-OK = 1
                     CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-OK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-PATCHY.
