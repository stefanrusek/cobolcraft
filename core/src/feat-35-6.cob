*> The speleothem features (docs/protocol/35-worldgen-features-6-underground.md sections 5 to 7). This file holds the pointed dripstone feature `speleothem` (registry id 45, section 5).
*> FD-SPEL-NODE compiles the configuration into a row of FD-WA: WA-I(1) base_block, WA-I(2) pointed_block (block indices), the pool 1 replaceable_blocks, the pool 2 the 20 states of the pointed
*> block (index thickness * 4 + vertical direction * 2 + waterlogged, with thickness tip_merge 0, tip 1, frustum 2, middle 3, base 4, direction up 0, down 1, waterlogged true 1),
*> WA-F(1) chance_of_taller_generation (0.2), WA-F(2) chance_of_directional_spread (0.7), WA-F(3) chance_of_spread_radius2 (0.5), WA-F(4) chance_of_spread_radius3 (0.5). A block the content set lacks,
*> a pointed block without the three properties or an unknown set makes the feature unsupported.
*> FR-SPEL places it (5.2): the tip direction, the patch of base blocks, the height (one nextFloat always) and the column of pointed blocks (SP-GROW, 5.3).
*>
*> Deviation (the same as the other features of the stage): the fluid at a cell is read from its block, so "is water at" holds for the block minecraft:water only (a waterlogged block is no water);
*> every write has flag 2.
*>
*> Entry points: FD-SPEL-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-SPEL USING state, feature, x, y, z, result out;
*> SP-GROW USING row, x, y, z, tip (0 down, 1 up), height, merge (0 or 1): SpeleothemUtils.growSpeleothem; SP-BASE-PLACE USING row, x, y, z, flag out: placeBaseBlockIfPossible;
*> SP-IS-BASE USING row, state, flag out; SP-EMPTY-WATER USING state, flag out (1 air or water).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-EMPTY-WATER.
*> USING state, flag out: isEmptyOrWater (air, cave air, void air, or the block water).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FLAG.
     CALL "FL-CLASS" USING L-STATE WS-CLASS
     MOVE 0 TO L-FLAG
     IF WS-CLASS = 1 OR WS-CLASS = 2
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SP-EMPTY-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-IS-BASE.
*> USING row, state, flag out: isBase: the block of the state is the base block or in the replaceable set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE L-FLAG.
     CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
     MOVE 0 TO L-FLAG
     IF WS-BLOCK = WA-I(L-ROW, 1)
         MOVE 1 TO L-FLAG
     ELSE
         CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SP-IS-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-BASE-PLACE.
*> USING row, x, y, z, flag out: placeBaseBlockIfPossible (2.3): the cell is written with the base block when its state is in the replaceable set (a cell that already is the base block is not in the
*> set and is left alone); flag 1 when written.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FLAG.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK L-FLAG
     IF L-FLAG = 1
         MOVE CB-DEFAULT-STATE(WA-I(L-ROW, 1)) TO WS-STATE
         CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-STATE WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM SP-BASE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-GROW.
*> USING row, x, y, z, tip (0 down, 1 up), height, merge: growSpeleothem (5.3): nothing unless the cell behind the first piece (opposite the tip) is a base cell; then the column of
*> `height` pieces (base, middles, frustum, tip; tip_merge when merged) from the position in the direction of the tip, each the pointed block with that thickness and direction and
*> waterlogged where the cell holds water, written without any emptiness test.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-D1                  BINARY-LONG.
 01 WS-O1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-THICK               BINARY-LONG.
 01 WS-WL                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-MERGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-TIP L-HEIGHT L-MERGE.
     COMPUTE WS-D1 = L-TIP + 1
     COMPUTE WS-O1 = FDR-OPP(WS-D1) + 1
     COMPUTE WS-X = L-X + FDR-DX(WS-O1)
     COMPUTE WS-Y = L-Y + FDR-DY(WS-O1)
     COMPUTE WS-Z = L-Z + FDR-DZ(WS-O1)
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "SP-IS-BASE" USING L-ROW WS-STATE WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE L-X TO WS-X
     MOVE L-Y TO WS-Y
     MOVE L-Z TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-HEIGHT
         EVALUATE TRUE
             WHEN WS-I = L-HEIGHT AND L-MERGE = 1
                 MOVE 0 TO WS-THICK
             WHEN WS-I = L-HEIGHT
                 MOVE 1 TO WS-THICK
             WHEN WS-I = L-HEIGHT - 1
                 MOVE 2 TO WS-THICK
             WHEN WS-I = 1
                 MOVE 4 TO WS-THICK
             WHEN OTHER
                 MOVE 3 TO WS-THICK
         END-EVALUATE
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         MOVE 0 TO WS-WL
         IF WS-CLASS = 2
             MOVE 1 TO WS-WL
         END-IF
*>       vertical direction: up 0, down 1 (the tip direction)
         COMPUTE WS-INDEX = WS-THICK * 4 + (1 - L-TIP) * 2 + WS-WL
         COMPUTE WS-INDEX = WA-START(L-ROW, 2) + WS-INDEX
         MOVE FD-POOL(WS-INDEX) TO WS-STATE
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
         COMPUTE WS-X = WS-X + FDR-DX(WS-D1)
         COMPUTE WS-Y = WS-Y + FDR-DY(WS-D1)
         COMPUTE WS-Z = WS-Z + FDR-DZ(WS-D1)
     END-PERFORM
     GOBACK.
 END PROGRAM SP-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-STATES.
*> USING row, block index of the pointed block, flag out: fills the pool 2 of the row with the 20 states of the pointed block (see the header); flag 0 when the block does not have 20 states
*> (a block without the three properties).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 01 WS-T                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-THICKNESSES.
    05 FILLER PIC X(9) VALUE "tip_merge".
    05 FILLER PIC X(9) VALUE "tip      ".
    05 FILLER PIC X(9) VALUE "frustum  ".
    05 FILLER PIC X(9) VALUE "middle   ".
    05 FILLER PIC X(9) VALUE "base     ".
 01 WS-THICK-TABLE REDEFINES WS-THICKNESSES.
    05 WS-THICK            PIC X(9) OCCURS 5 TIMES.
 01 WS-DIRS.
    05 FILLER PIC X(4) VALUE "up  ".
    05 FILLER PIC X(4) VALUE "down".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              PIC X(4) OCCURS 2 TIMES.
 01 WS-WLS.
    05 FILLER PIC X(5) VALUE "false".
    05 FILLER PIC X(5) VALUE "true ".
 01 WS-WL-TABLE REDEFINES WS-WLS.
    05 WS-WL               PIC X(5) OCCURS 2 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BLOCK L-FLAG.
     MOVE 1 TO L-FLAG
     COMPUTE WA-START(L-ROW, 2) = FD-POOL-COUNT + 1
     MOVE 20 TO WA-N(L-ROW, 2)
     IF FD-POOL-COUNT + 20 > FD-MAX-POOL
         MOVE 1 TO FD-BAD
         MOVE 0 TO L-FLAG
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE CB-KEY-LENGTH(L-BLOCK) TO WS-LEN
     MOVE CB-KEY(L-BLOCK)(1:WS-LEN) TO WS-KEY
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 2
             PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > 2
                 MOVE SPACES TO WS-PAIRS
                 MOVE 1 TO WS-POINTER
                 STRING "thickness=" FUNCTION TRIM(WS-THICK(WS-T)) ",vertical_direction=" FUNCTION TRIM(WS-DIR(WS-D))
                     ",waterlogged=" FUNCTION TRIM(WS-WL(WS-W))
                     DELIMITED BY SIZE INTO WS-PAIRS WITH POINTER WS-POINTER
                 CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
                 COMPUTE WS-INDEX = WA-START(L-ROW, 2) + (WS-T - 1) * 4 + (WS-D - 1) * 2 + (WS-W - 1)
                 MOVE WS-STATE TO FD-POOL(WS-INDEX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     ADD 20 TO FD-POOL-COUNT
     IF CB-STATES(L-BLOCK) NOT = 20
         MOVE 0 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SP-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SPEL-BLOCK.
*> USING doc, node, member key (PIC X(40)), block index out: the block of a member given as an id string (0 and FD-BAD when absent or unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-E                   BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-BLOCK.
     MOVE 0 TO L-BLOCK
     CALL "FD-J-STRING" USING JSON-DOC L-KEY L-NODE WS-TEXT WS-E
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO WS-KEY48
     CALL "FD-BLOCK-INDEX" USING WS-KEY48 L-BLOCK
     IF L-BLOCK = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-SPEL-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SPEL-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 01 WS-K-BASE              PIC X(40) VALUE "base_block".
 01 WS-K-POINTED           PIC X(40) VALUE "pointed_block".
 01 WS-K-SET               PIC X(40) VALUE "replaceable_blocks".
 01 WS-K-TALLER            PIC X(40) VALUE "chance_of_taller_generation".
 01 WS-K-SPREAD            PIC X(40) VALUE "chance_of_directional_spread".
 01 WS-K-R2                PIC X(40) VALUE "chance_of_spread_radius2".
 01 WS-K-R3                PIC X(40) VALUE "chance_of_spread_radius3".
 01 WS-D-TALLER            FLOAT-LONG VALUE 0.2.
 01 WS-D-SPREAD            FLOAT-LONG VALUE 0.7.
 01 WS-D-HALF              FLOAT-LONG VALUE 0.5.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
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
     CALL "FD-SPEL-BLOCK" USING JSON-DOC L-NODE WS-K-BASE WA-I(WS-ROW, 1)
     CALL "FD-SPEL-BLOCK" USING JSON-DOC L-NODE WS-K-POINTED WA-I(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SET WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 1) WA-N(WS-ROW, 1)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-TALLER WS-D-TALLER WA-F(WS-ROW, 1)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-SPREAD WS-D-SPREAD WA-F(WS-ROW, 2)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-R2 WS-D-HALF WA-F(WS-ROW, 3)
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-R3 WS-D-HALF WA-F(WS-ROW, 4)
     IF WA-I(WS-ROW, 2) > 0
         CALL "SP-STATES" USING WS-ROW WA-I(WS-ROW, 2) WS-FLAG
         IF WS-FLAG = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-SPEL-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SPEL.
*> USING state, feature, x, y, z, result out (1 when a tip direction was found: the feature then returns true even when it wrote nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-TIP                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DIRS.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 4 TIMES.
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
*>   1. the tip direction: a base cell above (a stalactite, DOWN), below (UP) or both (one nextBoolean: true is DOWN)
     COMPUTE WS-Y = L-Y + 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "SP-IS-BASE" USING WS-ROW WS-STATE WS-ABOVE
     COMPUTE WS-Y = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "SP-IS-BASE" USING WS-ROW WS-STATE WS-BELOW
     EVALUATE TRUE
         WHEN WS-ABOVE = 1 AND WS-BELOW = 1
             CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
             IF WS-DRAW = 1
                 MOVE 0 TO WS-TIP
             ELSE
                 MOVE 1 TO WS-TIP
             END-IF
         WHEN WS-ABOVE = 1
             MOVE 0 TO WS-TIP
         WHEN WS-BELOW = 1
             MOVE 1 TO WS-TIP
         WHEN OTHER
             GOBACK
     END-EVALUATE
     MOVE 1 TO L-RESULT
*>   2. the base cell, 3. the patch of base blocks
     COMPUTE WS-H1 = WS-TIP + 1
     COMPUTE WS-H1 = FDR-OPP(WS-H1) + 1
     COMPUTE WS-BX = L-X + FDR-DX(WS-H1)
     COMPUTE WS-BY = L-Y + FDR-DY(WS-H1)
     COMPUTE WS-BZ = L-Z + FDR-DZ(WS-H1)
     CALL "SP-BASE-PLACE" USING WS-ROW WS-BX WS-BY WS-BZ WS-FLAG
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 4
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         MOVE WA-F(WS-ROW, 2) TO WS-P
         CALL "FR-F32" USING WS-P
         IF NOT WS-F > WS-P
             COMPUTE WS-H1 = WS-DIR(WS-H) + 1
             COMPUTE WS-PX = WS-BX + FDR-DX(WS-H1)
             COMPUTE WS-PY = WS-BY + FDR-DY(WS-H1)
             COMPUTE WS-PZ = WS-BZ + FDR-DZ(WS-H1)
             CALL "SP-BASE-PLACE" USING WS-ROW WS-PX WS-PY WS-PZ WS-FLAG
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             MOVE WA-F(WS-ROW, 3) TO WS-P
             CALL "FR-F32" USING WS-P
             IF NOT WS-F > WS-P
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SIX WS-DRAW
                 COMPUTE WS-H1 = WS-DRAW + 1
                 COMPUTE WS-PX = WS-PX + FDR-DX(WS-H1)
                 COMPUTE WS-PY = WS-PY + FDR-DY(WS-H1)
                 COMPUTE WS-PZ = WS-PZ + FDR-DZ(WS-H1)
                 CALL "SP-BASE-PLACE" USING WS-ROW WS-PX WS-PY WS-PZ WS-FLAG
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 MOVE WA-F(WS-ROW, 4) TO WS-P
                 CALL "FR-F32" USING WS-P
                 IF NOT WS-F > WS-P
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SIX WS-DRAW
                     COMPUTE WS-H1 = WS-DRAW + 1
                     COMPUTE WS-PX = WS-PX + FDR-DX(WS-H1)
                     COMPUTE WS-PY = WS-PY + FDR-DY(WS-H1)
                     COMPUTE WS-PZ = WS-PZ + FDR-DZ(WS-H1)
                     CALL "SP-BASE-PLACE" USING WS-ROW WS-PX WS-PY WS-PZ WS-FLAG
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   4. the height: one nextFloat always, and 2 when it is under the taller chance and the cell next to the origin in the tip direction is air or water
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     MOVE WA-F(WS-ROW, 1) TO WS-P
     CALL "FR-F32" USING WS-P
     MOVE 1 TO WS-HEIGHT
     IF WS-F < WS-P
         COMPUTE WS-H1 = WS-TIP + 1
         COMPUTE WS-PX = L-X + FDR-DX(WS-H1)
         COMPUTE WS-PY = L-Y + FDR-DY(WS-H1)
         COMPUTE WS-PZ = L-Z + FDR-DZ(WS-H1)
         CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
         CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
         IF WS-FLAG = 1
             MOVE 2 TO WS-HEIGHT
         END-IF
     END-IF
*>   5. the column
     CALL "SP-GROW" USING WS-ROW L-X L-Y L-Z WS-TIP WS-HEIGHT WS-ZERO
     GOBACK.
 END PROGRAM FR-SPEL.
