*> The bending and cherry trunks and the cherry and random spread foliage of the tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md 4.7, 4.9, 5.1 and 5.2): FD-TREE-BEND-NODE,
*> FD-TREE-CHERRY-NODE and FD-TREE-CHERRYF-NODE compile their fields, FR-TRUNK-BEND and FR-TRUNK-CHERRY place the trunks into the work area of TREEWORK.cpy, FR-CHERRY-FOLIAGE and FR-SPREAD
*> the foliage of one attachment. The bush foliage is a variant of the blob one and lives with it (feat-tree-foliage.cob).
*> The hanging leaves (5.1) test whether the cell above holds a leaf of this tree (the foliage set) and whether the extension cell can take a leaf; a cell already holding a leaf of this tree
*> counts as a success, as it does in the game, where a leaf is a valid tree position and is set again.
*>
*> Entry points: FD-TREE-BEND-NODE, FD-TREE-CHERRY-NODE, FD-TREE-CHERRYF-NODE USING doc, node, row; FR-TRUNK-BEND, FR-TRUNK-CHERRY USING state, row, x, y, z, height;
*> FR-CHERRY-FOLIAGE USING state, row, attachment, foliage height, leaf radius, offset; FR-SPREAD likewise.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-BEND-NODE.
*> USING doc, trunk placer node, row: min_height_for_leaves (default 1) and bend_length (4.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-MHL               PIC X(40) VALUE "min_height_for_leaves".
 01 WS-K-BEND              PIC X(40) VALUE "bend_length".
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 1 TO TR-MHL(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MHL WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-MHL(L-ROW) WS-OK
     END-IF
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-BEND TR-BEND(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-BEND-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-CHERRY-NODE.
*> USING doc, trunk placer node, row: branch_count, branch_horizontal_length, branch_start_offset_from_top (a uniform range: the second start is drawn from the same range with its maximum
*> one lower, 4.9) and branch_end_offset_from_top. A start offset that is not a uniform range marks the feature unsupported.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-COUNT             PIC X(40) VALUE "branch_count".
 01 WS-K-LENGTH            PIC X(40) VALUE "branch_horizontal_length".
 01 WS-K-START             PIC X(40) VALUE "branch_start_offset_from_top".
 01 WS-K-END               PIC X(40) VALUE "branch_end_offset_from_top".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-COUNT TR-BC(L-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-LENGTH TR-BHL(L-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-START TR-BSO(L-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-END TR-BEO(L-ROW)
     IF TR-BSO-V(L-ROW, 1) NOT = 2
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-CHERRY-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-CHERRYF-NODE.
*> USING doc, foliage placer node, row: the four chances of the cherry foliage (5.2): wide_bottom_layer_hole_chance, corner_hole_chance, hanging_leaves_chance and
*> hanging_leaves_extension_chance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K1                  PIC X(40) VALUE "wide_bottom_layer_hole_chance".
 01 WS-K2                  PIC X(40) VALUE "corner_hole_chance".
 01 WS-K3                  PIC X(40) VALUE "hanging_leaves_chance".
 01 WS-K4                  PIC X(40) VALUE "hanging_leaves_extension_chance".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K1 WS-ZERO TR-CF1(L-ROW)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K2 WS-ZERO TR-CF2(L-ROW)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K3 WS-ZERO TR-CF3(L-ROW)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K4 WS-ZERO TR-CF4(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-CHERRYF-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-BEND.
*> USING state, row, x, y, z, height: 4.7: the soil under the origin, a random horizontal direction; H layers, each drawing nextInt(2) and moving the column one cell along the direction when
*> layer + 1 reaches H - 1 plus the draw; a log per layer, an attachment from layer min_height_for_leaves on; then bend_length + 1 more cells along the direction (bend_length drawn after the
*> layers), each with a log and an attachment.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-LIM                 BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 COPY FEATDATA.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
     CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
     COMPUTE WS-N = L-H - 1
     MOVE L-X TO WS-CX
     MOVE L-Y TO WS-CY
     MOVE L-Z TO WS-CZ
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
         COMPUTE WS-LIM = WS-N + WS-DRAW
         IF WS-I + 1 >= WS-LIM
             ADD WS-DX TO WS-CX
             ADD WS-DZ TO WS-CZ
         END-IF
         CALL "FR-TREE-LOG" USING WS-CX WS-CY WS-CZ WS-ZERO WS-PLACED
         IF WS-I >= TR-MHL(L-ROW)
             CALL "FR-TREE-ATT" USING WS-CX WS-CY WS-CZ WS-ZERO WS-ZERO2
         END-IF
         ADD 1 TO WS-CY
     END-PERFORM
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BEND(L-ROW) WS-LEN
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-LEN
         CALL "FR-TREE-LOG" USING WS-CX WS-CY WS-CZ WS-ZERO WS-PLACED
         CALL "FR-TREE-ATT" USING WS-CX WS-CY WS-CZ WS-ZERO WS-ZERO2
         ADD WS-DX TO WS-CX
         ADD WS-DZ TO WS-CZ
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TRUNK-BEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CHERRY-BRANCH.
*> USING state, row, ox, oy, oz, height, direction, start layer, flag: generateBranch (4.9): the end layer H - 1 + branch_end_offset and the length branch_horizontal_length (+ 1 when the flag is
*> set or the end is below the start) are drawn in that order; the branch moves once (twice when long) along the direction placing a log after each move (axis of the direction), then until it
*> reaches the end moves up or down with the probability vertical distance / manhattan distance (nextFloat below it) and along the direction otherwise, a log after each move; the attachment
*> sits above the end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-ENDY                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-LONG                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MOVES               BINARY-LONG.
 01 WS-VD                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-OX L-OY L-OZ L-H L-DIR L-START L-FLAG.
     CALL "F353-STEP" USING L-DIR WS-DX WS-DY WS-DZ
     MOVE 1 TO WS-AXIS
     IF WS-DX NOT = 0
         MOVE -1 TO WS-AXIS
     END-IF
     MOVE L-OX TO WS-CX
     COMPUTE WS-CY = L-OY + L-START
     MOVE L-OZ TO WS-CZ
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BEO(L-ROW) WS-OFFSET
     COMPUTE WS-ENDY = L-H - 1 + WS-OFFSET
     MOVE L-FLAG TO WS-LONG
     IF WS-ENDY < L-START
         MOVE 1 TO WS-LONG
     END-IF
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BHL(L-ROW) WS-LEN
     ADD WS-LONG TO WS-LEN
     COMPUTE WS-EX = L-OX + WS-DX * WS-LEN
     COMPUTE WS-EY = L-OY + WS-ENDY
     COMPUTE WS-EZ = L-OZ + WS-DZ * WS-LEN
     COMPUTE WS-MOVES = 1 + WS-LONG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MOVES
         ADD WS-DX TO WS-CX
         ADD WS-DZ TO WS-CZ
         CALL "FR-TREE-LOG" USING WS-CX WS-CY WS-CZ WS-AXIS WS-PLACED
     END-PERFORM
     COMPUTE WS-M = FUNCTION ABS(WS-EX - WS-CX) + FUNCTION ABS(WS-EY - WS-CY) + FUNCTION ABS(WS-EZ - WS-CZ)
     PERFORM UNTIL WS-M = 0
         MOVE -1 TO WS-VD
         IF WS-EY > WS-CY
             MOVE 1 TO WS-VD
         END-IF
         COMPUTE WS-V = FUNCTION ABS(WS-EY - WS-CY)
         COMPUTE WS-P = WS-V / WS-M
         CALL "FR-F32" USING WS-P
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < WS-P
             ADD WS-VD TO WS-CY
             CALL "FR-TREE-LOG" USING WS-CX WS-CY WS-CZ WS-ZERO WS-PLACED
         ELSE
             ADD WS-DX TO WS-CX
             ADD WS-DZ TO WS-CZ
             CALL "FR-TREE-LOG" USING WS-CX WS-CY WS-CZ WS-AXIS WS-PLACED
         END-IF
         COMPUTE WS-M = FUNCTION ABS(WS-EX - WS-CX) + FUNCTION ABS(WS-EY - WS-CY) + FUNCTION ABS(WS-EZ - WS-CZ)
     END-PERFORM
     COMPUTE WS-CY = WS-EY + 1
     CALL "FR-TREE-ATT" USING WS-EX WS-CY WS-EZ WS-ZERO WS-ZERO2
     GOBACK.
 END PROGRAM FR-CHERRY-BRANCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-CHERRY.
*> USING state, row, x, y, z, height: 4.9: the soil under the origin; the first branch start H - 1 + branch_start_offset (at least 0), the second from the range with its maximum one lower
*> (moved up by one when it reaches the first), then branch_count; the trunk is H high for three branches, else one above the higher start of the branches there are; three branches add the
*> attachment above the trunk; a random direction, the first branch that way and, for two or more, the second the opposite way.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIR2                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-SECOND.
    05 WS-SECOND-V         BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BSO(L-ROW) WS-V
     COMPUTE WS-S1 = FUNCTION MAX(0, L-H - 1 + WS-V)
     MOVE TR-BSO(L-ROW) TO WS-SECOND
     COMPUTE WS-SECOND-V(3) = WS-SECOND-V(3) - 1
     CALL "FR-INT-SAMPLE" USING L-STATE WS-SECOND WS-V
     COMPUTE WS-S2 = FUNCTION MAX(0, L-H - 1 + WS-V)
     IF WS-S2 >= WS-S1
         ADD 1 TO WS-S2
     END-IF
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BC(L-ROW) WS-COUNT
     EVALUATE TRUE
         WHEN WS-COUNT = 3
             MOVE L-H TO WS-T
         WHEN WS-COUNT >= 2
             COMPUTE WS-T = FUNCTION MAX(WS-S1, WS-S2) + 1
         WHEN OTHER
             COMPUTE WS-T = WS-S1 + 1
     END-EVALUATE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-T
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FR-TREE-LOG" USING L-X WS-Y L-Z WS-ZERO WS-PLACED
     END-PERFORM
     IF WS-COUNT = 3
         COMPUTE WS-Y = L-Y + WS-T
         CALL "FR-TREE-ATT" USING L-X WS-Y L-Z WS-ZERO WS-ZERO2
     END-IF
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
     MOVE 0 TO WS-FLAG
     IF WS-S1 < WS-T - 1
         MOVE 1 TO WS-FLAG
     END-IF
     CALL "FR-CHERRY-BRANCH" USING L-STATE L-ROW L-X L-Y L-Z L-H WS-DIR WS-S1 WS-FLAG
     IF WS-COUNT >= 2
         COMPUTE WS-DIR2 = WS-DIR + 1
         IF FUNCTION MOD(WS-DIR, 2) = 1
             COMPUTE WS-DIR2 = WS-DIR - 1
         END-IF
         MOVE 0 TO WS-FLAG
         IF WS-S2 < WS-T - 1
             MOVE 1 TO WS-FLAG
         END-IF
         CALL "FR-CHERRY-BRANCH" USING L-STATE L-ROW L-X L-Y L-Z L-H WS-DIR2 WS-S2 WS-FLAG
     END-IF
     GOBACK.
 END PROGRAM FR-TRUNK-CHERRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CHERRY-ROW.
*> USING state, row, centre x, y, z, radius, dy: placeLeavesRow (5.1) at layer y + dy with the cherry skip test (5.2), draws in the order the doc gives: at dy = -1 a cell on the rim (ax or
*> az equals the radius) is skipped on nextFloat() below wide_bottom_layer_hole_chance; else a radius above 2 skips the corners and, beyond ax + az > 2 radius - 2, a cell on
*> nextFloat() below corner_hole_chance; a radius of 2 or less skips a corner on that draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-LIM                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-WIDE                FLOAT-LONG.
 01 WS-CORNER              FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-RADIUS L-DY.
     MOVE TR-CF1(L-ROW) TO WS-WIDE
     CALL "FR-F32" USING WS-WIDE
     MOVE TR-CF2(L-ROW) TO WS-CORNER
     CALL "FR-F32" USING WS-CORNER
     COMPUTE WS-LO = 0 - L-RADIUS
     COMPUTE WS-PY = L-Y + L-DY
     COMPUTE WS-LIM = L-RADIUS * 2 - 2
     PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > L-RADIUS
         PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > L-RADIUS
             COMPUTE WS-AX = FUNCTION ABS(WS-DX)
             COMPUTE WS-AZ = FUNCTION ABS(WS-DZ)
             MOVE 0 TO WS-SKIP
             IF L-DY = -1 AND (WS-AX = L-RADIUS OR WS-AZ = L-RADIUS)
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 IF WS-F < WS-WIDE
                     MOVE 1 TO WS-SKIP
                 END-IF
             END-IF
             IF WS-SKIP = 0
                 EVALUATE TRUE
                     WHEN L-RADIUS > 2 AND WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                         MOVE 1 TO WS-SKIP
                     WHEN L-RADIUS > 2 AND WS-AX + WS-AZ > WS-LIM
                         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                         IF WS-F < WS-CORNER
                             MOVE 1 TO WS-SKIP
                         END-IF
                     WHEN L-RADIUS <= 2 AND WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                         IF WS-F < WS-CORNER
                             MOVE 1 TO WS-SKIP
                         END-IF
                 END-EVALUATE
             END-IF
             IF WS-SKIP = 0
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FR-TREE-LEAF" USING WS-PX WS-PY WS-PZ L-STATE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-CHERRY-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CHERRY-EXT.
*> USING state, x, y, z, ref x, y, z, chance, ok out: tryPlaceExtension (5.1): false at a manhattan distance of 7 or more from the reference cell, else one nextFloat, false when it is above the
*> chance, else tryPlaceLeaf (a cell that already holds a leaf of this tree is a success).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-CELL                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-RX L-RY L-RZ L-CHANCE L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-M = FUNCTION ABS(L-X - L-RX) + FUNCTION ABS(L-Y - L-RY) + FUNCTION ABS(L-Z - L-RZ)
     IF WS-M < 7
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         MOVE L-CHANCE TO WS-P
         CALL "FR-F32" USING WS-P
         IF WS-F <= WS-P
             CALL "FR-TREE-CELL" USING L-X L-Y L-Z WS-CELL
             MOVE TW-NLEAF TO WS-BEFORE
             CALL "FR-TREE-LEAF" USING L-X L-Y L-Z L-STATE
             IF TW-NLEAF > WS-BEFORE
                 MOVE 1 TO L-OK
             END-IF
             IF WS-CELL > 0
                 IF TW-GRID(WS-CELL) = 2
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-CHERRY-EXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CHERRY-HANG.
*> USING state, row, centre x, y, z, radius, dy: placeLeavesRowWithHangingLeavesBelow (5.1): the row, then along each side of the square of the radius around the centre (the four sides in the order
*> north, east, south, west, each from its clockwise corner) one cell below the row: where the cell above holds a leaf, an extension leaf with the hanging_leaves_chance and, when that
*> was placed, another below it with the extension chance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CWX                 BINARY-LONG.
 01 WS-CWZ                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK2                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-RADIUS L-DY.
     CALL "FR-CHERRY-ROW" USING L-STATE L-ROW L-X L-Y L-Z L-RADIUS L-DY
     COMPUTE WS-RY = L-Y - 1
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE 0 TO WS-DX WS-DZ WS-CWX WS-CWZ
         EVALUATE WS-D
             WHEN 1
                 MOVE -1 TO WS-DZ
                 MOVE 1 TO WS-CWX
             WHEN 2
                 MOVE 1 TO WS-DX
                 MOVE 1 TO WS-CWZ
             WHEN 3
                 MOVE 1 TO WS-DZ
                 MOVE -1 TO WS-CWX
             WHEN OTHER
                 MOVE -1 TO WS-DX
                 MOVE -1 TO WS-CWZ
         END-EVALUATE
         COMPUTE WS-X = L-X + WS-CWX * L-RADIUS - WS-DX * L-RADIUS
         COMPUTE WS-Y = L-Y + L-DY - 1
         COMPUTE WS-Z = L-Z + WS-CWZ * L-RADIUS - WS-DZ * L-RADIUS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-RADIUS * 2
             COMPUTE WS-UP = WS-Y + 1
             CALL "FR-TREE-CELL" USING WS-X WS-UP WS-Z WS-CELL
             IF WS-CELL > 0
                 IF TW-GRID(WS-CELL) = 2
                     CALL "FR-CHERRY-EXT" USING L-STATE WS-X WS-Y WS-Z L-X WS-RY L-Z TR-CF3(L-ROW) WS-OK
                     IF WS-OK = 1
                         COMPUTE WS-DOWN = WS-Y - 1
                         CALL "FR-CHERRY-EXT" USING L-STATE WS-X WS-DOWN WS-Z L-X WS-RY L-Z TR-CF4(L-ROW) WS-OK2
                     END-IF
                 END-IF
             END-IF
             ADD WS-DX TO WS-X
             ADD WS-DZ TO WS-Z
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-CHERRY-HANG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CHERRY-FOLIAGE.
*> USING state, row, attachment, foliage height, leaf radius, offset: createFoliage of the cherry placer (5.2): centre = the attachment raised by the offset, r0 = radius + radius offset - 1,
*> hh = foliage height; the rows (r0 - 2, hh - 3) and (r0 - 1, hh - 4), then (r0, y) for y = hh - 5 down to 0, then the two hanging rows (r0, -1) and (r0 - 1, -2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-CY                  BINARY-LONG.
 01 WS-R0                  BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-ATT                  BINARY-LONG.
 01 L-FH                   BINARY-LONG.
 01 L-LR                   BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-ATT L-FH L-LR L-OFF.
     COMPUTE WS-CY = TW-ATT-Y(L-ATT) + L-OFF
     COMPUTE WS-R0 = L-LR + TW-ATT-R(L-ATT) - 1
     COMPUTE WS-RAD = WS-R0 - 2
     COMPUTE WS-Y = L-FH - 3
     CALL "FR-CHERRY-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y
     COMPUTE WS-RAD = WS-R0 - 1
     COMPUTE WS-Y = L-FH - 4
     CALL "FR-CHERRY-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y
     COMPUTE WS-FROM = L-FH - 5
     PERFORM VARYING WS-Y FROM WS-FROM BY -1 UNTIL WS-Y < 0
         CALL "FR-CHERRY-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-R0 WS-Y
     END-PERFORM
     MOVE -1 TO WS-Y
     CALL "FR-CHERRY-HANG" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-R0 WS-Y
     COMPUTE WS-RAD = WS-R0 - 1
     MOVE -2 TO WS-Y
     CALL "FR-CHERRY-HANG" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y
     GOBACK.
 END PROGRAM FR-CHERRY-FOLIAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SPREAD.
*> USING state, row, attachment, foliage height, leaf radius: createFoliage of the random spread placer (5.2): leaf_placement_attempts times a cell around the attachment is drawn as
*> (nextInt(radius) - nextInt(radius), nextInt(height) - nextInt(height), nextInt(radius) - nextInt(radius)), in that order, and gets a leaf when it is valid tree space.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-HB                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-ATT                  BINARY-LONG.
 01 L-FH                   BINARY-LONG.
 01 L-LR                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-ATT L-FH L-LR.
     COMPUTE WS-RB = FUNCTION MAX(L-LR, 1)
     COMPUTE WS-HB = FUNCTION MAX(L-FH, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TR-ATTEMPTS(L-ROW)
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-RB WS-A
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-RB WS-B
         COMPUTE WS-PX = TW-ATT-X(L-ATT) + WS-A - WS-B
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-HB WS-A
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-HB WS-B
         COMPUTE WS-PY = TW-ATT-Y(L-ATT) + WS-A - WS-B
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-RB WS-A
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-RB WS-B
         COMPUTE WS-PZ = TW-ATT-Z(L-ATT) + WS-A - WS-B
         CALL "FR-TREE-LEAF" USING WS-PX WS-PY WS-PZ L-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM FR-SPREAD.
