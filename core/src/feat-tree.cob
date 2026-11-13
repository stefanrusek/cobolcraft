*> The tree feature of the feature stage (docs/protocol/35-worldgen-features-3-tree-placers.md sections 1 to 3, 4.1 and 5.2; feature type 51): FD-TREE-NODE compiles the data of a
*> tree feature into FD-TR (FEATDATA.cpy), FR-TREE places it. The supported tree is the straight trunk with the blob, spruce or pine foliage and the two layers feature size, which
*> is every oak, birch and spruce of the data except the fancy and the fallen variants; anything else (another placer, a root placer, a decorator other than the beehive) marks the
*> feature unsupported (FD-BAD).
*> Deviations (the lane's notes, docs/design/world-types.md "Trees"): the tree is built in the grid of TREEWORK.cpy and written only when every log, leaf and soil block lies in the chunk
*> being generated (the write window of the level is one chunk): a tree that would cross the border places nothing, after its draws, so the later draws are those of the vanilla order;
*> the beehive decorator is ignored (no bees, no nest); the leaf distances of section 2.4 are the breadth first distances from this tree's logs through its own leaves (the hash set
*> order of the layers is not reproduced, Open question 1 there) and neighbouring blocks outside the tree do not lower them; the shape update at the edge (2.5) only schedules leaf
*> ticks and is not run; leaves are written not persistent and not waterlogged; states are the default states of the blocks.
*>
*> Entry points: FD-TREE-NODE USING doc, node, row out; FR-TREE USING state, feature, x, y, z, result out (1 placed).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-STATE.
*> USING doc, node, state out, block index out, ok out: a block state object {"id": ..} (properties are the default ones and are not read).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-STATE L-BLOCK L-OK.
     MOVE 0 TO L-OK L-STATE L-BLOCK
     CALL "FD-J-STRING" USING JSON-DOC FK-ID L-NODE WS-TEXT WS-LEN
     IF WS-LEN = 0
         CALL "FD-J-STRING" USING JSON-DOC FK-NAME L-NODE WS-TEXT WS-LEN
     END-IF
     IF WS-LEN > 0
         CALL "FD-KEY" USING WS-TEXT WS-KEY
         MOVE WS-KEY TO WS-KEY48
         CALL "FD-BLOCK-INDEX" USING WS-KEY48 L-BLOCK
         IF L-BLOCK > 0
             CALL "GEN-BLOCK-STATE" USING WS-KEY48 L-STATE
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-IP.
*> USING doc, object node, member key (PIC X(40)), provider out (4 integers like FR-INT-SAMPLE): the int provider member; an absent member is the constant 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-P.
     MOVE 1 TO L-V(1)
     MOVE 0 TO L-V(2) L-V(3) L-V(4)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE L-KEY WS-N
     IF WS-N > 0
         CALL "FD-J-IP" USING JSON-DOC WS-N L-P WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-NODE.
*> USING doc, node, row out (0 and FD-BAD when unsupported): compiles {"type": "minecraft:tree", ...} into a row of FD-TR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-TRUNK-PLACER      PIC X(40) VALUE "trunk_placer".
 01 WS-K-FOLIAGE-PLACER    PIC X(40) VALUE "foliage_placer".
 01 WS-K-TRUNK-PROVIDER    PIC X(40) VALUE "trunk_provider".
 01 WS-K-FOLIAGE-PROVIDER  PIC X(40) VALUE "foliage_provider".
 01 WS-K-MINIMUM-SIZE      PIC X(40) VALUE "minimum_size".
 01 WS-K-DECORATORS        PIC X(40) VALUE "decorators".
 01 WS-K-ROOT-PLACER       PIC X(40) VALUE "root_placer".
 01 WS-K-BELOW             PIC X(40) VALUE "below_trunk_provider".
 01 WS-K-BASE              PIC X(40) VALUE "base_height".
 01 WS-K-RAND-A            PIC X(40) VALUE "height_rand_a".
 01 WS-K-RAND-B            PIC X(40) VALUE "height_rand_b".
 01 WS-K-RADIUS            PIC X(40) VALUE "radius".
 01 WS-K-OFFSET            PIC X(40) VALUE "offset".
 01 WS-K-TRUNK-HEIGHT      PIC X(40) VALUE "trunk_height".
 01 WS-K-LIMIT             PIC X(40) VALUE "limit".
 01 WS-K-LOWER             PIC X(40) VALUE "lower_size".
 01 WS-K-UPPER             PIC X(40) VALUE "upper_size".
 01 WS-K-CLIPPED           PIC X(40) VALUE "min_clipped_height".
 01 WS-TAG-REPL            PIC X(112) VALUE "minecraft:replaceable_by_trees".
 01 WS-TAG-LOGS            PIC X(112) VALUE "minecraft:logs".
 01 WS-TAG-CANT            PIC X(112) VALUE "minecraft:cannot_replace_below_tree_trunk".
 01 WS-DIRT                PIC X(48) VALUE "minecraft:dirt".
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-IP.
    05 WS-IPV              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-TR-COUNT >= 256
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-TR-COUNT
     MOVE FD-TR-COUNT TO WS-ROW
     INITIALIZE FD-TR(WS-ROW)
     MOVE WS-ROW TO L-ROW
*>   no root placer
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ROOT-PLACER WS-E
     IF WS-E > 0
         MOVE 1 TO FD-BAD
     END-IF
*>   the decorators: only the beehive, which is ignored
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DECORATORS WS-E
     IF WS-E > 0
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-N WS-TEXT WS-LEN
             IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:beehive"
                 MOVE 1 TO FD-BAD
             END-IF
         END-PERFORM
     END-IF
*>   the soil under the trunk
     CALL "FD-J-STRING" USING JSON-DOC WS-K-BELOW L-NODE WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:soil_beneath_tree"
         MOVE 1 TO FD-BAD
     END-IF
     CALL "GEN-BLOCK-STATE" USING WS-DIRT TR-SOIL-STATE(WS-ROW)
*>   the trunk placer
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRUNK-PLACER WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:straight_trunk_placer"
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-BASE WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-BASE(WS-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-RAND-A WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-RA(WS-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-RAND-B WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-RB(WS-ROW) WS-OK
*>   the states
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRUNK-PROVIDER WS-E
     CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-LOG-STATE(WS-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FOLIAGE-PROVIDER WS-E
     CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-LEAF-STATE(WS-ROW) TR-LEAF-BLOCK(WS-ROW) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
*>   the feature size
     MOVE 1 TO TR-SZ-LIMIT(WS-ROW)
     MOVE 0 TO TR-SZ-LOWER(WS-ROW)
     MOVE 1 TO TR-SZ-UPPER(WS-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MINIMUM-SIZE WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:two_layers_feature_size"
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-LIMIT WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-LIMIT(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-LOWER WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-LOWER(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-UPPER WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-UPPER(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-CLIPPED WS-N
     IF WS-N > 0
         MOVE 1 TO FD-BAD
     END-IF
*>   the foliage placer
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FOLIAGE-PLACER WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:blob_foliage_placer"
             MOVE 1 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:spruce_foliage_placer"
             MOVE 2 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:pine_foliage_placer"
             MOVE 3 TO TR-FKIND(WS-ROW)
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     MOVE 0 TO WS-N
     CALL "FD-TREE-IP" USING JSON-DOC WS-E FK-HEIGHT TR-FH(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-RADIUS TR-RAD(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-OFFSET TR-OFF(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-TRUNK-HEIGHT TR-TH(WS-ROW)
*>   the block tags
     COMPUTE TR-REPL-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-REPL TR-REPL-N(WS-ROW)
     COMPUTE TR-LOGS-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-LOGS TR-LOGS-N(WS-ROW)
     COMPUTE TR-CANT-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-CANT TR-CANT-N(WS-ROW)
     GOBACK.
 END PROGRAM FD-TREE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-OK.
*> USING pool start, pool count, state, ok out: the state at a position is air (class 1) or a block of the pool (a tag): validTreePos / isFree (section 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-N L-STATE L-OK.
     MOVE 0 TO L-OK
     CALL "FL-CLASS" USING L-STATE WS-CLASS
     IF WS-CLASS = 1
         MOVE 1 TO L-OK
     ELSE
         CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING L-START L-N WS-BLOCK L-OK
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-CELL.
*> USING x, y, z (absolute), cell out: the grid index of TREEWORK.cpy, 0 when the position is outside the grid (which marks the tree as not fitting).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CELL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CELL.
     COMPUTE WS-GX = L-X - TW-X0 + 7
     COMPUTE WS-GY = L-Y - TW-Y0 + 1
     COMPUTE WS-GZ = L-Z - TW-Z0 + 7
     MOVE 0 TO L-CELL
     IF WS-GX >= 0 AND WS-GX < TW-GX AND WS-GY >= 0 AND WS-GY < TW-GY AND WS-GZ >= 0 AND WS-GZ < TW-GZ
         COMPUTE L-CELL = (WS-GX * TW-GY + WS-GY) * TW-GZ + WS-GZ + 1
     ELSE
         MOVE 1 TO TW-OUT
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-LEAF.
*> USING x, y, z (absolute): tryPlaceLeaf (section 5.1): not on a log of this tree, and the position is valid tree space in the level; the leaf is recorded once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 COPY CELLS.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "FR-TREE-CELL" USING L-X L-Y L-Z WS-CELL
     IF WS-CELL > 0
         IF TW-GRID(WS-CELL) = 0
             CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
             CALL "FR-TREE-OK" USING TW-REPL-START TW-REPL-N WS-STATE WS-OK
             IF WS-OK = 1 AND TW-NLEAF < 1536
                 ADD 1 TO TW-NLEAF
                 MOVE L-X TO TW-LEAF-X(TW-NLEAF)
                 MOVE L-Y TO TW-LEAF-Y(TW-NLEAF)
                 MOVE L-Z TO TW-LEAF-Z(TW-NLEAF)
                 MOVE 2 TO TW-GRID(WS-CELL)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-LEAF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-ROW.
*> USING state, centre x, y, z, radius, dy, kind (1 blob, 2 spruce and pine): placeLeavesRow (section 5.1) with the skip test of 5.2: blob skips a corner (ax and az equal the
*> radius) when nextInt(2) is 0 (drawn at every such position) or dy is 0; spruce and pine skip a corner of a radius above 0 without a draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-RADIUS L-DY L-KIND.
     COMPUTE WS-LO = 0 - L-RADIUS
     COMPUTE WS-PY = L-Y + L-DY
     PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > L-RADIUS
         PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > L-RADIUS
             COMPUTE WS-AX = FUNCTION ABS(WS-DX)
             COMPUTE WS-AZ = FUNCTION ABS(WS-DZ)
             MOVE 0 TO WS-SKIP
             IF WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                 IF L-KIND = 1
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
                     IF WS-DRAW = 0 OR L-DY = 0
                         MOVE 1 TO WS-SKIP
                     END-IF
                 ELSE
                     IF L-RADIUS > 0
                         MOVE 1 TO WS-SKIP
                     END-IF
                 END-IF
             END-IF
             IF WS-SKIP = 0
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FR-TREE-LEAF" USING WS-PX WS-PY WS-PZ
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TREE-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-COMMIT.
*> USING feature row, leaf block, log state: gives every leaf its distance (section 2.4: the breadth first distance from the logs through the leaves, 7 for a leaf no log reaches
*> within 6) and writes the soil, the logs and the leaves to the level.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-STRIDE              BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-HEAD WS-TAIL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9000
         MOVE 7 TO TW-DIST(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         CALL "FR-TREE-CELL" USING TW-LOG-X(WS-I) TW-LOG-Y(WS-I) TW-LOG-Z(WS-I) WS-CELL
         MOVE 0 TO TW-DIST(WS-CELL)
         ADD 1 TO WS-TAIL
         MOVE WS-CELL TO TW-QUEUE(WS-TAIL)
     END-PERFORM
*>   the stride of the distance property in the state numbering of the leaves (distance, persistent, waterlogged: 28 states = 7 x 4)
     MOVE TR-LEAF-BLOCK(L-ROW) TO WS-I
     COMPUTE WS-REST = FUNCTION MOD(CB-STATES(WS-I), 7)
     MOVE 0 TO WS-STRIDE
     IF CB-STATES(WS-I) > 0 AND WS-REST = 0
         COMPUTE WS-STRIDE = CB-STATES(WS-I) / 7
     END-IF
     PERFORM UNTIL WS-HEAD >= WS-TAIL
         ADD 1 TO WS-HEAD
         MOVE TW-QUEUE(WS-HEAD) TO WS-CELL
         COMPUTE WS-D = TW-DIST(WS-CELL) + 1
         IF WS-D < 7
*>           the six neighbours: x +-1 (cells GY * GZ apart), y +-1 (GZ apart), z +-1
             PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 6
                 EVALUATE WS-DIR
                     WHEN 1
                         COMPUTE WS-NB = WS-CELL - TW-GY * TW-GZ
                     WHEN 2
                         COMPUTE WS-NB = WS-CELL + TW-GY * TW-GZ
                     WHEN 3
                         COMPUTE WS-NB = WS-CELL - TW-GZ
                     WHEN 4
                         COMPUTE WS-NB = WS-CELL + TW-GZ
                     WHEN 5
                         COMPUTE WS-NB = WS-CELL - 1
                     WHEN 6
                         COMPUTE WS-NB = WS-CELL + 1
                 END-EVALUATE
                 IF WS-NB >= 1 AND WS-NB <= 9000
                     IF TW-GRID(WS-NB) = 2 AND TW-DIST(WS-NB) > WS-D
                         MOVE WS-D TO TW-DIST(WS-NB)
                         ADD 1 TO WS-TAIL
                         MOVE WS-NB TO TW-QUEUE(WS-TAIL)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF TW-SOIL = 1
         MOVE TR-SOIL-STATE(L-ROW) TO WS-STATE
         CALL "FL-SET-STATE" USING TW-SOIL-X TW-SOIL-Y TW-SOIL-Z WS-STATE WS-FLAGS WS-OK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         CALL "FL-SET-STATE" USING TW-LOG-X(WS-I) TW-LOG-Y(WS-I) TW-LOG-Z(WS-I) TR-LOG-STATE(L-ROW) WS-FLAGS WS-OK
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         CALL "FR-TREE-CELL" USING TW-LEAF-X(WS-I) TW-LEAF-Y(WS-I) TW-LEAF-Z(WS-I) WS-CELL
         MOVE TR-LEAF-STATE(L-ROW) TO WS-STATE
         IF WS-STRIDE > 0
             COMPUTE WS-STEP = 7 - TW-DIST(WS-CELL)
             COMPUTE WS-STATE = TR-LEAF-STATE(L-ROW) - WS-STEP * WS-STRIDE
         END-IF
         CALL "FL-SET-STATE" USING TW-LEAF-X(WS-I) TW-LEAF-Y(WS-I) TW-LEAF-Z(WS-I) WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TREE-COMMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE.
*> USING state, feature, x, y, z (the origin: the block above the ground), result out (1 placed, 0 refused): TreeFeature.place (section 2) for the straight trunk with the blob,
*> spruce or pine foliage. The draws are those of 2.2 in their order (tree height, foliage height, radius, the foliage offset, the foliage rows), made whether or not the tree is
*> then refused.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY TREEWORK.
 01 WS-ROW                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FH                  BINARY-LONG.
 01 WS-LR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK2                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
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
*>   2.2 steps 1 to 3: the heights and the radius
     CALL "F353-TREE-HEIGHT" USING L-STATE TR-BASE(WS-ROW) TR-RA(WS-ROW) TR-RB(WS-ROW) WS-H
     EVALUATE TR-FKIND(WS-ROW)
         WHEN 2
             CALL "FR-INT-SAMPLE" USING L-STATE TR-TH(WS-ROW) WS-T
             COMPUTE WS-FH = FUNCTION MAX(4, WS-H - WS-T)
         WHEN OTHER
             CALL "FR-INT-SAMPLE" USING L-STATE TR-FH(WS-ROW) WS-FH
     END-EVALUATE
     CALL "FR-INT-SAMPLE" USING L-STATE TR-RAD(WS-ROW) WS-LR
     IF TR-FKIND(WS-ROW) = 3
         COMPUTE WS-BOUND = FUNCTION MAX(WS-H - WS-FH + 1, 1)
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         ADD WS-DRAW TO WS-LR
     END-IF
*>   step 5: the build height
     COMPUTE WS-MAXY = L-Y + WS-H + 1
     IF L-Y < FL-MIN-Y + 1 OR WS-MAXY > FL-MIN-Y + FL-HEIGHT
         GOBACK
     END-IF
*>   2.3: the free height
     MOVE WS-H TO WS-FREE
     COMPUTE WS-END = WS-H + 1
     PERFORM VARYING WS-YY FROM 0 BY 1 UNTIL WS-YY > WS-END OR WS-FREE < WS-H
         IF WS-YY < TR-SZ-LIMIT(WS-ROW)
             MOVE TR-SZ-LOWER(WS-ROW) TO WS-S
         ELSE
             MOVE TR-SZ-UPPER(WS-ROW) TO WS-S
         END-IF
         COMPUTE WS-LO = 0 - WS-S
         PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-S OR WS-FREE < WS-H
             PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-S OR WS-FREE < WS-H
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PY = L-Y + WS-YY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
                 CALL "FR-TREE-OK" USING TR-REPL-START(WS-ROW) TR-REPL-N(WS-ROW) WS-STATE WS-OK
                 IF WS-OK = 0
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     CALL "FR-POOL-HAS" USING TR-LOGS-START(WS-ROW) TR-LOGS-N(WS-ROW) WS-BLOCK WS-OK
                 END-IF
                 IF WS-OK = 0
                     COMPUTE WS-FREE = WS-YY - 2
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-FREE < WS-H
         GOBACK
     END-IF
*>   the work area
     MOVE L-X TO TW-X0
     MOVE L-Y TO TW-Y0
     MOVE L-Z TO TW-Z0
     MOVE 0 TO TW-OUT TW-NLOG TW-NLEAF TW-SOIL
     MOVE TR-REPL-START(WS-ROW) TO TW-REPL-START
     MOVE TR-REPL-N(WS-ROW) TO TW-REPL-N
     MOVE TR-LOGS-START(WS-ROW) TO TW-LOGS-START
     MOVE TR-LOGS-N(WS-ROW) TO TW-LOGS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9000
         MOVE 0 TO TW-GRID(WS-I)
     END-PERFORM
*>   4.1: the block under the trunk (soil_beneath_tree: dirt unless the block is in cannot_replace_below_tree_trunk), then the logs
     COMPUTE WS-PY = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-PY L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING TR-CANT-START(WS-ROW) TR-CANT-N(WS-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO TW-SOIL
         MOVE L-X TO TW-SOIL-X
         MOVE WS-PY TO TW-SOIL-Y
         MOVE L-Z TO TW-SOIL-Z
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-FREE
         COMPUTE WS-PY = L-Y + WS-I
         CALL "FL-GET-STATE" USING L-X WS-PY L-Z WS-STATE
         CALL "FR-TREE-OK" USING TR-REPL-START(WS-ROW) TR-REPL-N(WS-ROW) WS-STATE WS-OK
         IF WS-OK = 1
             ADD 1 TO TW-NLOG
             MOVE L-X TO TW-LOG-X(TW-NLOG)
             MOVE WS-PY TO TW-LOG-Y(TW-NLOG)
             MOVE L-Z TO TW-LOG-Z(TW-NLOG)
             CALL "FR-TREE-CELL" USING L-X WS-PY L-Z WS-CELL
             MOVE 1 TO TW-GRID(WS-CELL)
         END-IF
     END-PERFORM
*>   2.2 step 9 and 5.2: the foliage around the attachment (x, y + free, z)
     CALL "FR-INT-SAMPLE" USING L-STATE TR-OFF(WS-ROW) WS-OFF
     COMPUTE WS-PY = L-Y + WS-FREE
     EVALUATE TR-FKIND(WS-ROW)
         WHEN 1
             COMPUTE WS-END = WS-OFF - WS-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 COMPUTE WS-HALF = WS-YY / 2
                 COMPUTE WS-RAD = FUNCTION MAX(WS-LR - 1 - WS-HALF, 0)
                 MOVE 1 TO WS-KIND
                 CALL "FR-TREE-ROW" USING L-STATE L-X WS-PY L-Z WS-RAD WS-YY WS-KIND
             END-PERFORM
         WHEN 2
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-RAD
             MOVE 1 TO WS-HI
             MOVE 0 TO WS-LOW
             COMPUTE WS-END = 0 - WS-FH
             MOVE 2 TO WS-KIND
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 CALL "FR-TREE-ROW" USING L-STATE L-X WS-PY L-Z WS-RAD WS-YY WS-KIND
                 IF WS-RAD >= WS-HI
                     MOVE WS-LOW TO WS-RAD
                     MOVE 1 TO WS-LOW
                     COMPUTE WS-HI = FUNCTION MIN(WS-HI + 1, WS-LR)
                 ELSE
                     ADD 1 TO WS-RAD
                 END-IF
             END-PERFORM
         WHEN 3
             MOVE 0 TO WS-RAD
             COMPUTE WS-END = WS-OFF - WS-FH
             MOVE 2 TO WS-KIND
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 CALL "FR-TREE-ROW" USING L-STATE L-X WS-PY L-Z WS-RAD WS-YY WS-KIND
                 COMPUTE WS-HALF = WS-END + 1
                 IF WS-RAD >= 1 AND WS-YY = WS-HALF
                     SUBTRACT 1 FROM WS-RAD
                 ELSE
                     IF WS-RAD < WS-LR
                         ADD 1 TO WS-RAD
                     END-IF
                 END-IF
             END-PERFORM
     END-EVALUATE
     IF TW-OUT = 1 OR (TW-NLOG = 0 AND TW-NLEAF = 0)
         GOBACK
     END-IF
*>   the whole tree must lie in the chunk being generated
     COMPUTE WS-CX0 = FL-CX * 16
     COMPUTE WS-CZ0 = FL-CZ * 16
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         IF TW-LEAF-X(WS-I) < WS-CX0 OR TW-LEAF-X(WS-I) > WS-CX0 + 15 OR TW-LEAF-Z(WS-I) < WS-CZ0 OR TW-LEAF-Z(WS-I) > WS-CZ0 + 15
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     IF L-X < WS-CX0 OR L-X > WS-CX0 + 15 OR L-Z < WS-CZ0 OR L-Z > WS-CZ0 + 15
         MOVE 0 TO WS-OK
     END-IF
     IF WS-OK = 1
         CALL "FR-TREE-COMMIT" USING WS-ROW
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FR-TREE.
