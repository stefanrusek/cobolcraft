*> The mangrove parts of the tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md sections 4.8 and 6): FD-TREE-UP-NODE compiles the extra fields of the upwards branching trunk placer,
*> FD-TREE-ROOT-NODE the mangrove root placer, FR-ROOTS places the roots (6.1: the root path walk, simulate and potential with their draws, then placeRoot with the above root placement), and
*> FR-TRUNK-UP is the upwards branching trunk (4.8). The roots are written to the level at once, as the game does (they come before the trunk and a tree whose roots fail writes nothing);
*> the trunk and the foliage go through the work area of TREEWORK.cpy. canPlaceRoot is validTreePos (air or replaceable by trees) or a block of the root's can_grow_through.
*> A root block with two states is taken to have the single property waterlogged (true is the first state): it is waterlogged where the level holds water (the fluid in the tag water).
*>
*> Entry points: FD-TREE-FLOAT USING doc, object, key, default, value out; FD-TREE-UP-NODE and FD-TREE-ROOT-NODE USING doc, node, row; FR-ROOTS USING state, row, x, y, z (the ground origin),
*> trunk origin y, ok out; FR-TRUNK-UP USING state, row, x, y, z (the trunk origin), height.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-FLOAT.
*> USING doc, object node, member key (PIC X(40)), default (FLOAT-LONG), value out: the number of a member, or the default when it is absent or not a number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-DEFAULT              FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-DEFAULT L-VALUE.
     MOVE L-DEFAULT TO L-VALUE
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE L-KEY WS-N
     IF WS-N > 0
         IF JN-TYPE(WS-N) = JT-NUMBER
             MOVE JN-NUM(WS-N) TO L-VALUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-UP-NODE.
*> USING doc, trunk placer node, row: extra_branch_steps, extra_branch_length (int providers), place_branch_per_log_probability and can_grow_through (4.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-STEPS             PIC X(40) VALUE "extra_branch_steps".
 01 WS-K-LENGTH            PIC X(40) VALUE "extra_branch_length".
 01 WS-K-PROB              PIC X(40) VALUE "place_branch_per_log_probability".
 01 WS-K-CGT               PIC X(40) VALUE "can_grow_through".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-STEPS TR-EBS(L-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-LENGTH TR-EBL(L-ROW)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-PROB WS-ZERO TR-PROB(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CGT WS-N
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-N WS-MODE TR-CGT-START(L-ROW) TR-CGT-N(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-UP-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-ROOT-NODE.
*> USING doc, root placer node, row: the mangrove root placer (6, 6.1): trunk_offset_y, root_provider, the optional above_root_placement, and mangrove_root_placement (can_grow_through,
*> muddy_roots_in, muddy_roots_provider, max_root_width, max_root_length, random_skew_chance). Another root placer type, or a state that is not a block id, marks the feature unsupported.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-OFFSET-Y          PIC X(40) VALUE "trunk_offset_y".
 01 WS-K-ROOT              PIC X(40) VALUE "root_provider".
 01 WS-K-ABOVE             PIC X(40) VALUE "above_root_placement".
 01 WS-K-ABOVE-PROV        PIC X(40) VALUE "above_root_provider".
 01 WS-K-ABOVE-CHANCE      PIC X(40) VALUE "above_root_placement_chance".
 01 WS-K-MANGROVE          PIC X(40) VALUE "mangrove_root_placement".
 01 WS-K-CGT               PIC X(40) VALUE "can_grow_through".
 01 WS-K-MUD-IN            PIC X(40) VALUE "muddy_roots_in".
 01 WS-K-MUD-PROV          PIC X(40) VALUE "muddy_roots_provider".
 01 WS-K-MAXW              PIC X(40) VALUE "max_root_width".
 01 WS-K-MAXL              PIC X(40) VALUE "max_root_length".
 01 WS-K-SKEW              PIC X(40) VALUE "random_skew_chance".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 1 TO TR-ROOT(L-ROW)
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:mangrove_root_placer"
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-OFFSET-Y TR-TOY(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ROOT WS-N
     CALL "FD-TREE-STATE" USING JSON-DOC WS-N TR-ROOT-STATE(L-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ABOVE WS-N
     IF WS-N > 0
         MOVE 1 TO TR-ABOVE-ON(L-ROW)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-ABOVE-PROV WS-M
         CALL "FD-TREE-STATE" USING JSON-DOC WS-M TR-ABOVE-STATE(L-ROW) WS-BLOCK WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
         CALL "FD-TREE-FLOAT" USING JSON-DOC WS-N WS-K-ABOVE-CHANCE WS-ZERO TR-ABOVE-CHANCE(L-ROW)
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MANGROVE WS-N
     CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-CGT WS-M
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-M WS-MODE TR-RCG-START(L-ROW) TR-RCG-N(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-MUD-IN WS-M
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-M WS-MODE TR-MUD-START(L-ROW) TR-MUD-N(L-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-MUD-PROV WS-M
     CALL "FD-TREE-STATE" USING JSON-DOC WS-M TR-MUD-STATE(L-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-MAXW WS-M
     CALL "FD-J-INT" USING JSON-DOC WS-M TR-MAXW(L-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC WS-N WS-K-MAXL WS-M
     CALL "FD-J-INT" USING JSON-DOC WS-M TR-MAXL(L-ROW) WS-OK
     CALL "FD-TREE-FLOAT" USING JSON-DOC WS-N WS-K-SKEW WS-ZERO TR-SKEW(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-ROOT-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOT-CAN.
*> USING row, x, y, z, ok out: canPlaceRoot (6.1): air or replaceable by trees (validTreePos) or a block of the root can_grow_through. A cell outside the chunk being generated is not
*> placeable (the level holds one chunk, deviation: a root path ends at the chunk border instead of walking on through air).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-LX = L-X - FL-CX * 16
     COMPUTE WS-LZ = L-Z - FL-CZ * 16
     IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "FR-TREE-OK" USING TR-REPL-START(L-ROW) TR-REPL-N(L-ROW) WS-STATE L-OK
         IF L-OK = 0
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             CALL "FR-POOL-HAS" USING TR-RCG-START(L-ROW) TR-RCG-N(L-ROW) WS-BLOCK L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-ROOT-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOT-SET.
*> USING x, y, z, state: sets a root block state at the position; a block of two states is waterlogged (its first state) where the level holds water.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-OLD                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     MOVE L-STATE TO WS-STATE
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-OLD
     CALL "FL-CLASS" USING WS-OLD WS-CLASS
     CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
     IF WS-CLASS = 2 AND CB-STATES(WS-BLOCK) = 2
         MOVE CB-FIRST-STATE(WS-BLOCK) TO WS-STATE
     END-IF
     CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
     GOBACK.
 END PROGRAM FR-ROOT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOT-PLACE.
*> USING state, row, x, y, z: placeRoot (6, 6.1): a position in muddy_roots_in becomes muddy roots (no canPlaceRoot test); else, when canPlaceRoot, it becomes root, and with the above root
*> placement one nextFloat is drawn (whether or not it is below the chance) and the air above gets the above root block when it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING TR-MUD-START(L-ROW) TR-MUD-N(L-ROW) WS-BLOCK WS-OK
     IF WS-OK = 1
         CALL "FR-ROOT-SET" USING L-X L-Y L-Z TR-MUD-STATE(L-ROW)
     ELSE
         CALL "FR-ROOT-CAN" USING L-ROW L-X L-Y L-Z WS-OK
         IF WS-OK = 1
             CALL "FR-ROOT-SET" USING L-X L-Y L-Z TR-ROOT-STATE(L-ROW)
             IF TR-ABOVE-ON(L-ROW) = 1
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 MOVE TR-ABOVE-CHANCE(L-ROW) TO WS-C
                 CALL "FR-F32" USING WS-C
                 COMPUTE WS-UP = L-Y + 1
                 CALL "FL-GET-STATE" USING L-X WS-UP L-Z WS-STATE
                 CALL "FL-CLASS" USING WS-STATE WS-CLASS
                 IF WS-F < WS-C AND WS-CLASS = 1
                     CALL "FR-ROOT-SET" USING L-X WS-UP L-Z TR-ABOVE-STATE(L-ROW)
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-ROOT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOT-SIM IS RECURSIVE.
*> USING state, row, trunk origin x, y, z, cur x, y, z, direction step x, z, depth, list base, ok out: simulate (6.1) with potential: the candidates of the cell (the cell below; the cell
*> beside it in the direction; the cell below that) by the distance to the trunk origin, W the root width: from W - 2 to W the cell below and, on nextFloat() < skew, the one below the side
*> cell; beyond W only the cell below; inside, the cell below on nextFloat() < skew, else the side cell on a true nextBoolean, else the cell below. Each candidate that canPlaceRoot is
*> appended to the list (TW-RL, from the base of this direction) and walked on; a depth of max_root_length, or a list of more than that many, fails (ok 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 LOCAL-STORAGE SECTION.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-M                   BINARY-LONG.
 01 LS-W                   BINARY-LONG.
 01 LS-CAN                 BINARY-LONG.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-BOOL                BINARY-LONG.
 01 LS-F                   FLOAT-LONG.
 01 LS-SK                  FLOAT-LONG.
 01 LS-CAND.
    05 LS-C OCCURS 2 TIMES.
       10 LS-CX            BINARY-LONG.
       10 LS-CY            BINARY-LONG.
       10 LS-CZ            BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-OX L-OY L-OZ L-X L-Y L-Z L-DX L-DZ L-DEPTH L-BASE L-OK.
     MOVE 1 TO L-OK
     COMPUTE LS-N = TW-NRL - L-BASE
     IF L-DEPTH >= TR-MAXL(L-ROW) OR LS-N > TR-MAXL(L-ROW) OR TW-NRL >= 150
         MOVE 0 TO L-OK
         GOBACK
     END-IF
     COMPUTE LS-M = FUNCTION ABS(L-X - L-OX) + FUNCTION ABS(L-Y - L-OY) + FUNCTION ABS(L-Z - L-OZ)
     MOVE TR-MAXW(L-ROW) TO LS-W
     MOVE TR-SKEW(L-ROW) TO LS-SK
     CALL "FR-F32" USING LS-SK
     MOVE 1 TO LS-N
     MOVE L-X TO LS-CX(1)
     COMPUTE LS-CY(1) = L-Y - 1
     MOVE L-Z TO LS-CZ(1)
     EVALUATE TRUE
         WHEN LS-M > LS-W - 3 AND LS-M <= LS-W
             CALL "WGR-NEXT-FLOAT" USING L-STATE LS-F
             IF LS-F < LS-SK
                 MOVE 2 TO LS-N
                 COMPUTE LS-CX(2) = L-X + L-DX
                 COMPUTE LS-CY(2) = L-Y - 1
                 COMPUTE LS-CZ(2) = L-Z + L-DZ
             END-IF
         WHEN LS-M > LS-W
             CONTINUE
         WHEN OTHER
             CALL "WGR-NEXT-FLOAT" USING L-STATE LS-F
             IF LS-F >= LS-SK
                 CALL "F351-NEXT-BOOLEAN" USING L-STATE LS-BOOL
                 IF LS-BOOL = 1
                     COMPUTE LS-CX(1) = L-X + L-DX
                     MOVE L-Y TO LS-CY(1)
                     COMPUTE LS-CZ(1) = L-Z + L-DZ
                 END-IF
             END-IF
     END-EVALUATE
     COMPUTE LS-DEPTH = L-DEPTH + 1
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N OR L-OK = 0
         CALL "FR-ROOT-CAN" USING L-ROW LS-CX(LS-I) LS-CY(LS-I) LS-CZ(LS-I) LS-CAN
         IF LS-CAN = 1
             ADD 1 TO TW-NRL
             MOVE LS-CX(LS-I) TO TW-RL-X(TW-NRL)
             MOVE LS-CY(LS-I) TO TW-RL-Y(TW-NRL)
             MOVE LS-CZ(LS-I) TO TW-RL-Z(TW-NRL)
             CALL "FR-ROOT-SIM" USING L-STATE L-ROW L-OX L-OY L-OZ LS-CX(LS-I) LS-CY(LS-I) LS-CZ(LS-I) L-DX L-DZ LS-DEPTH L-BASE L-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-ROOT-SIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ROOTS.
*> USING state, row, x, y, z (the ground origin), trunk origin y, ok out: placeRoots (6.1): every cell from the origin up to the one below the trunk origin must be canPlaceRoot; the root list is the
*> cell below the trunk origin, then for each horizontal direction (north, east, south, west) the cells the walk of that direction gives and the cell beside the trunk origin; the roots are
*> placed in list order (a position can be listed twice). Fails (ok 0) when a cell is blocked or a walk fails.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 01 WS-TY2                 BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-TY L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO TW-NRL
     PERFORM VARYING WS-Y FROM L-Y BY 1 UNTIL WS-Y >= L-TY OR L-OK = 0
         CALL "FR-ROOT-CAN" USING L-ROW L-X WS-Y L-Z WS-CAN
         IF WS-CAN = 0
             MOVE 0 TO L-OK
         END-IF
     END-PERFORM
     IF L-OK = 1
         ADD 1 TO TW-NRL
         MOVE L-X TO TW-RL-X(TW-NRL)
         COMPUTE TW-RL-Y(TW-NRL) = L-TY - 1
         MOVE L-Z TO TW-RL-Z(TW-NRL)
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4 OR L-OK = 0
         MOVE 0 TO WS-DX WS-DZ
         EVALUATE WS-D
             WHEN 1 MOVE -1 TO WS-DZ
             WHEN 2 MOVE 1 TO WS-DX
             WHEN 3 MOVE 1 TO WS-DZ
             WHEN OTHER MOVE -1 TO WS-DX
         END-EVALUATE
         COMPUTE WS-SX = L-X + WS-DX
         COMPUTE WS-SZ = L-Z + WS-DZ
         MOVE TW-NRL TO WS-BASE
         MOVE L-TY TO WS-TY2
         CALL "FR-ROOT-SIM" USING L-STATE L-ROW L-X L-TY L-Z WS-SX WS-TY2 WS-SZ WS-DX WS-DZ WS-DEPTH WS-BASE L-OK
         IF L-OK = 1
             ADD 1 TO TW-NRL
             MOVE WS-SX TO TW-RL-X(TW-NRL)
             MOVE L-TY TO TW-RL-Y(TW-NRL)
             MOVE WS-SZ TO TW-RL-Z(TW-NRL)
         END-IF
     END-PERFORM
     IF L-OK = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NRL
             CALL "FR-ROOT-PLACE" USING L-STATE L-ROW TW-RL-X(WS-I) TW-RL-Y(WS-I) TW-RL-Z(WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FR-ROOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-UP-BRANCH.
*> USING state, row, ox, oy, oz (the trunk origin), height, log y, direction, start, steps: placeBranch (4.8): a staircase leaving the trunk along the direction, one cell out and one up per
*> acting iteration, of min(steps, H - start) iterations; an iteration with k < 1 only consumes a step; each acting iteration adds an attachment; when the branch rose above log y + 1 two
*> more attachments are added at the last cell and two below it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-LOGY                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-OX L-OZ L-H L-LOGY L-DIR L-START L-STEPS.
     CALL "F353-STEP" USING L-DIR WS-DX WS-DY WS-DZ
     COMPUTE WS-LAST = L-LOGY + L-START
     MOVE L-OX TO WS-X
     MOVE L-OZ TO WS-Z
     MOVE L-START TO WS-K
     COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(L-STEPS, L-H - L-START), 0)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         IF WS-K >= 1
             COMPUTE WS-Y = L-LOGY + WS-K
             ADD WS-DX TO WS-X
             ADD WS-DZ TO WS-Z
             MOVE WS-Y TO WS-LAST
             CALL "FR-TREE-LOG" USING WS-X WS-Y WS-Z WS-ZERO WS-PLACED
             IF WS-PLACED = 1
                 ADD 1 TO WS-LAST
             END-IF
             CALL "FR-TREE-ATT" USING WS-X WS-Y WS-Z WS-ZERO WS-ZERO2
         END-IF
         ADD 1 TO WS-K
     END-PERFORM
     IF WS-LAST - L-LOGY > 1
         CALL "FR-TREE-ATT" USING WS-X WS-LAST WS-Z WS-ZERO WS-ZERO2
         COMPUTE WS-Y = WS-LAST - 2
         CALL "FR-TREE-ATT" USING WS-X WS-Y WS-Z WS-ZERO WS-ZERO2
     END-IF
     GOBACK.
 END PROGRAM FR-UP-BRANCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-UP.
*> USING state, row, x, y, z (the trunk origin), height: 4.8: per layer a log in the origin column (the position must be valid or can_grow_through); when one was placed below the top
*> layer a nextFloat below the probability gives a branch: direction, two extra_branch_length draws (start = max(0, first - second - 1)) and extra_branch_steps; the top layer adds the
*> attachment above it (placed or not). There is no soil under the trunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     MOVE TR-PROB(L-ROW) TO WS-P
     CALL "FR-F32" USING WS-P
     COMPUTE WS-LAST = L-H - 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FR-TREE-LOG" USING L-X WS-Y L-Z WS-ZERO WS-PLACED
         IF WS-PLACED = 1 AND WS-I < WS-LAST
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-P
                 CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
                 CALL "FR-INT-SAMPLE" USING L-STATE TR-EBL(L-ROW) WS-L1
                 CALL "FR-INT-SAMPLE" USING L-STATE TR-EBL(L-ROW) WS-L2
                 COMPUTE WS-START = FUNCTION MAX(0, WS-L1 - WS-L2 - 1)
                 CALL "FR-INT-SAMPLE" USING L-STATE TR-EBS(L-ROW) WS-STEPS
                 CALL "FR-UP-BRANCH" USING L-X L-Z L-H WS-Y WS-DIR WS-START WS-STEPS
             END-IF
         END-IF
         IF WS-I = WS-LAST
             COMPUTE WS-Y = WS-Y + 1
             CALL "FR-TREE-ATT" USING L-X WS-Y L-Z WS-ZERO WS-ZERO2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TRUNK-UP.
