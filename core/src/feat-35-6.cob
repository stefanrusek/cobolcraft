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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FX-OP.
*> USING op (1 add, 2 subtract, 3 multiply, 4 divide), a, b, r out (FLOAT-LONG): one Java float operation: the double result of the exact operands rounded to single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-OP L-A L-B L-R.
     EVALUATE L-OP
         WHEN 1
             CALL STATIC "cc_f64_add" USING BY REFERENCE L-A L-B WS-R
         WHEN 2
             CALL STATIC "cc_f64_sub" USING BY REFERENCE L-A L-B WS-R
         WHEN 3
             CALL STATIC "cc_f64_mul" USING BY REFERENCE L-A L-B WS-R
         WHEN OTHER
             CALL STATIC "cc_f64_div" USING BY REFERENCE L-A L-B WS-R
     END-EVALUATE
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-R L-R
     GOBACK.
 END PROGRAM FX-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FX-CLAMPED-MAP.
*> USING mode (0 float, 1 double), v, inLo, inHi, outLo, outHi, r out (all FLOAT-LONG; a float mode input is a single precision value): Mth.clampedMap = clampedLerp(inverseLerp(v, inLo, inHi), outLo, outHi),
*> every step in the precision of the mode (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 01 WS-OP4                 BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-V                    FLOAT-LONG.
 01 L-INLO                 FLOAT-LONG.
 01 L-INHI                 FLOAT-LONG.
 01 L-OUTLO                FLOAT-LONG.
 01 L-OUTHI                FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-MODE L-V L-INLO L-INHI L-OUTLO L-OUTHI L-R.
     IF L-MODE = 0
         CALL "FX-OP" USING WS-OP2 L-V L-INLO WS-A
         CALL "FX-OP" USING WS-OP2 L-INHI L-INLO WS-B
         CALL "FX-OP" USING WS-OP4 WS-A WS-B WS-T
     ELSE
         CALL STATIC "cc_f64_sub" USING BY REFERENCE L-V L-INLO WS-A
         CALL STATIC "cc_f64_sub" USING BY REFERENCE L-INHI L-INLO WS-B
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-B WS-T
     END-IF
     EVALUATE TRUE
         WHEN WS-T < WS-ZERO
             MOVE L-OUTLO TO L-R
         WHEN WS-T > WS-ONE
             MOVE L-OUTHI TO L-R
         WHEN L-MODE = 0
             CALL "FX-OP" USING WS-OP2 L-OUTHI L-OUTLO WS-A
             CALL "FX-OP" USING WS-OP3 WS-T WS-A WS-B
             CALL "FX-OP" USING WS-OP1 L-OUTLO WS-B L-R
         WHEN OTHER
             CALL STATIC "cc_f64_sub" USING BY REFERENCE L-OUTHI L-OUTLO WS-A
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-A WS-B
             CALL STATIC "cc_f64_add" USING BY REFERENCE L-OUTLO WS-B L-R
     END-EVALUATE
     GOBACK.
 END PROGRAM FX-CLAMPED-MAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FP.
*> USING doc, node, kind out, values out (4 FLOAT-LONG), ok out: a FloatProvider (23 section 7): a bare number (kind 1, value), uniform (kind 2: min_inclusive, max_exclusive) or clamped_normal
*> (kind 3: mean, deviation, min, max); anything else (or a missing member) is not ok.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-K-MAXEX             PIC X(40) VALUE "max_exclusive".
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUES.
    05 L-VAL               FLOAT-LONG OCCURS 4 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KIND L-VALUES L-OK.
     MOVE 0 TO L-KIND L-OK
     MOVE 0 TO L-VAL(1) L-VAL(2) L-VAL(3) L-VAL(4)
     IF L-NODE = 0
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) = JT-NUMBER
         MOVE 1 TO L-KIND
         CALL "FD-J-DOUBLE" USING JSON-DOC L-NODE L-VAL(1) L-OK
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     MOVE 1 TO L-OK
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:uniform"
         WHEN "uniform"
             MOVE 2 TO L-KIND
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN-INC WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(1) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MAXEX WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(2) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
         WHEN "minecraft:clamped_normal"
         WHEN "clamped_normal"
             MOVE 3 TO L-KIND
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MEAN WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(1) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-DEVIATION WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(2) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(3) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX WS-N
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-VAL(4) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
         WHEN OTHER
             MOVE 0 TO L-KIND L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-FP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FP.
*> USING state, kind, values (4 FLOAT-LONG), result out: the sample of a float provider, in single precision: a constant (no draw); uniform = Mth.randomBetween: nextFloat() * (max - min) + min;
*> clamped_normal = clamp(mean + (float) nextGaussian() * deviation, min, max) (ClampedNormalFloat, 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUES.
    05 L-VAL               FLOAT-LONG OCCURS 4 TIMES.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-KIND L-VALUES L-R.
     MOVE L-VAL(1) TO WS-A
     CALL "FR-F32" USING WS-A
     MOVE WS-A TO L-R
     EVALUATE L-KIND
         WHEN 2
             MOVE L-VAL(2) TO WS-B
             CALL "FR-F32" USING WS-B
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             CALL "FX-OP" USING WS-OP2 WS-B WS-A WS-C
             CALL "FX-OP" USING WS-OP3 WS-F WS-C WS-D
             CALL "FX-OP" USING WS-OP1 WS-D WS-A L-R
         WHEN 3
             CALL "F351-NEXT-GAUSSIAN" USING L-STATE WS-F
             CALL "FR-F32" USING WS-F
             MOVE L-VAL(2) TO WS-B
             CALL "FR-F32" USING WS-B
             CALL "FX-OP" USING WS-OP3 WS-F WS-B WS-C
             CALL "FX-OP" USING WS-OP1 WS-A WS-C L-R
             MOVE L-VAL(3) TO WS-C
             CALL "FR-F32" USING WS-C
             MOVE L-VAL(4) TO WS-D
             CALL "FR-F32" USING WS-D
             IF L-R < WS-C
                 MOVE WS-C TO L-R
             ELSE
                 IF L-R > WS-D
                     MOVE WS-D TO L-R
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-FP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-LMEMBER.
*> USING doc, object node, member key (PIC X(64)), node out (0 when absent): FD-J-MEMBER for the keys longer than 40 characters.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-OUT.
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE L-KEY WS-LEN L-OUT
     GOBACK.
 END PROGRAM FD-J-LMEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-CLUSTER-NODE.
*> speleothem_cluster (registry id 46, section 6): the row of FD-SPEL-NODE (base, pointed, replaceable pool 1, states pool 2) with WA-I(3) floor_to_ceiling_search_range, WA-I(4)
*> max_stalagmite_stalactite_height_diff, WA-I(5) height_deviation, WA-I(6) max_distance_from_edge_affecting_chance_of_speleothem, WA-I(7) max_distance_from_center_affecting_height_bias,
*> WA-I(8) and WA-G(1 .. 4) the density float provider (FD-FP), WA-I(9) and WA-G(5 .. 8) the wetness float provider, WA-F(1) chance_of_speleothem_at_max_distance_from_center,
*> WA-IP(1) height, WA-IP(2) radius, WA-IP(3) speleothem_block_layer_thickness (int providers), the pool 3 the tag base_stone_overworld (the blocks that can be adjacent to water).
*> A missing or unsupported member makes the feature unsupported.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-RANGE             PIC X(64) VALUE "floor_to_ceiling_search_range".
 01 WS-K-DIFF              PIC X(64) VALUE "max_stalagmite_stalactite_height_diff".
 01 WS-K-DEV               PIC X(64) VALUE "height_deviation".
 01 WS-K-EDGE              PIC X(64) VALUE "max_distance_from_edge_affecting_chance_of_speleothem".
 01 WS-K-CENTER            PIC X(64) VALUE "max_distance_from_center_affecting_height_bias".
 01 WS-K-DENSITY           PIC X(64) VALUE "density".
 01 WS-K-WETNESS           PIC X(64) VALUE "wetness".
 01 WS-K-CHANCE            PIC X(64) VALUE "chance_of_speleothem_at_max_distance_from_center".
 01 WS-K-LAYER             PIC X(64) VALUE "speleothem_block_layer_thickness".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:base_stone_overworld".
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUES.
    05 WS-VAL              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-SPEL-NODE" USING JSON-DOC L-NODE L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-RANGE WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 3) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-DIFF WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 4) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-DEV WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 5) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-EDGE WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 6) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-CENTER WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(L-ROW, 7) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-CHANCE WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-DENSITY WS-E
     CALL "FD-FP" USING JSON-DOC WS-E WA-I(L-ROW, 8) WS-VALUES WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-VAL(WS-I) TO WA-G(L-ROW, WS-I)
     END-PERFORM
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-WETNESS WS-E
     CALL "FD-FP" USING JSON-DOC WS-E WA-I(L-ROW, 9) WS-VALUES WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-VAL(WS-I) TO WA-G(L-ROW, WS-I + 4)
     END-PERFORM
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-HEIGHT WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-RADIUS WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-LMEMBER" USING JSON-DOC L-NODE WS-K-LAYER WS-E
     CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(L-ROW, 3) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     COMPUTE WA-START(L-ROW, 3) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG WA-N(L-ROW, 3)
     GOBACK.
 END PROGRAM FD-CLUSTER-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-SCAN.
*> USING row, x, y, z, direction (0 down, 1 up), max steps, found out (0 none, 1 the target found), y out: Column.scan's scanDirection (2.4): from the position, move while fewer than
*> maxSteps - 1 moves are made and the cell is air or water; then, when the cell reached is a base block (or in the replaceable set) or lava, its y is the answer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-D1                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-DIR L-STEPS L-FOUND L-OUT.
     MOVE 0 TO L-FOUND
     COMPUTE WS-D1 = L-DIR + 1
     MOVE L-Y TO WS-Y
     MOVE 1 TO WS-I
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0
         CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
         CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
         IF WS-I < L-STEPS AND WS-FLAG = 1
             ADD FDR-DY(WS-D1) TO WS-Y
             ADD 1 TO WS-I
         ELSE
             MOVE 0 TO WS-GO
         END-IF
     END-PERFORM
     CALL "SP-IS-BASE" USING L-ROW WS-STATE WS-FLAG
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-FLAG = 1 OR WS-CLASS = 3
         MOVE 1 TO L-FOUND
         MOVE WS-Y TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM SC-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-POOL-OK.
*> USING row, x, y, z, flag out: canPlacePool (6.2 step 2): false when the cell is water, the base block or the pointed block, or when the cell above holds water; otherwise true only
*> when the four horizontal neighbours and the cell below are base stone (the tag base_stone_overworld) or water.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-DIRS.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 5 TIMES.
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
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 2 OR WS-BLOCK = WA-I(L-ROW, 1) OR WS-BLOCK = WA-I(L-ROW, 2)
         GOBACK
     END-IF
     COMPUTE WS-Y = L-Y + 1
     CALL "FL-GET-STATE" USING L-X WS-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 2
         GOBACK
     END-IF
     MOVE 1 TO L-FLAG
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
         COMPUTE WS-D1 = WS-DIR(WS-D) + 1
         COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
         COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
         COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
         CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FR-POOL-HAS" USING WA-START(L-ROW, 3) WA-N(L-ROW, 3) WS-BLOCK WS-IN
         IF WS-IN = 0 AND WS-CLASS NOT = 2
             MOVE 0 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SC-POOL-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-HEIGHT.
*> USING state, row, dx, dz, density (single precision), cap, result out: getSpeleothemHeight(random, dx, dz, density, cap) (6.2): nextFloat, 0 when it is above the density; else the height
*> of a clamped normal (one Gaussian) with the mean (float) clampedMap((double) (|dx| + |dz|), 0, center distance, cap / 2.0, 0.0), the deviation height_deviation, over 0 to cap, truncated.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-F                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-CAPF                FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-MEAN                FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-MODE1               BINARY-LONG VALUE 1.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-DENSITY              FLOAT-LONG.
 01 L-CAP                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-DX L-DZ L-DENSITY L-CAP L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F > L-DENSITY
         GOBACK
     END-IF
     COMPUTE WS-D = FUNCTION ABS(L-DX) + FUNCTION ABS(L-DZ)
     MOVE WS-D TO WS-DIST
     MOVE WA-I(L-ROW, 7) TO WS-HI
     MOVE L-CAP TO WS-CAPF
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-CAPF WS-TWO WS-HALF
     CALL "FX-CLAMPED-MAP" USING WS-MODE1 WS-DIST WS-ZERO WS-HI WS-HALF WS-ZERO2 WS-MEAN
     CALL "FR-F32" USING WS-MEAN
     CALL "F351-NEXT-GAUSSIAN" USING L-STATE WS-G
     CALL "FR-F32" USING WS-G
     MOVE WA-I(L-ROW, 5) TO WS-DEV
     CALL "FX-OP" USING WS-OP3 WS-G WS-DEV WS-T
     CALL "FX-OP" USING WS-OP1 WS-MEAN WS-T WS-G
     IF WS-G < WS-ZERO
         MOVE WS-ZERO TO WS-G
     ELSE
         IF WS-G > WS-CAPF
             MOVE WS-CAPF TO WS-G
         END-IF
     END-IF
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-G L-RESULT
     GOBACK.
 END PROGRAM SC-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-COLUMN.
*> USING state, row, x, y, z (the column position), dx, dz, chance (double), height (the cluster's), density and wetness (single precision floats): placeColumn (6.2): the scan, the pool, the two
*> stalactite and stalagmite flags with their layers and heights, the meeting, the merge flag and the two columns of pointed blocks. The draws are those of the section in its order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-HAS-C               BINARY-LONG.
 01 WS-HAS-F               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-HAS-F2              BINARY-LONG.
 01 WS-SCAN-N              BINARY-LONG.
 01 WS-FRND                FLOAT-LONG.
 01 WS-DRND                FLOAT-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-HA                  BINARY-LONG.
 01 WS-HB                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-MEET                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MERGE               BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-UP                  BINARY-LONG VALUE 1.
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-TIP-UP              BINARY-LONG VALUE 1.
 01 WS-TIP-DOWN            BINARY-LONG VALUE 0.
 01 WS-DIFF                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-DENSITY              FLOAT-LONG.
 01 L-WETNESS              FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-DX L-DZ L-CHANCE L-HEIGHT L-DENSITY L-WETNESS.
*>   1. the scan: nothing when the cell is not air or water; then the ceiling above and the floor below (each present only when a base block or lava ends the walk)
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE WA-I(L-ROW, 3) TO WS-SCAN-N
     CALL "SC-SCAN" USING L-ROW L-X L-Y L-Z WS-UP WS-SCAN-N WS-HAS-C WS-C
     CALL "SC-SCAN" USING L-ROW L-X L-Y L-Z WS-DOWN WS-SCAN-N WS-HAS-F WS-F
     IF WS-HAS-C = 0 AND WS-HAS-F = 0
         GOBACK
     END-IF
*>   2. the pool: one nextFloat below the wetness; the water goes to the floor cell and the working floor is the cell below it
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-FRND
     MOVE WS-HAS-F TO WS-HAS-F2
     MOVE WS-F TO WS-F2
     IF WS-FRND < L-WETNESS AND WS-HAS-F = 1
         CALL "SC-POOL-OK" USING L-ROW L-X WS-F L-Z WS-FLAG
         IF WS-FLAG = 1
             MOVE CB-DEFAULT-STATE(FL-B-WATER) TO WS-STATE
             CALL "FL-SET-STATE" USING L-X WS-F L-Z WS-STATE WS-FLAGS WS-OK
             COMPUTE WS-F2 = WS-F - 1
         END-IF
     END-IF
*>   3. the stalactite flag, 4. its layer of base blocks and its height
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-DRND
     MOVE 0 TO WS-HA
     IF WS-HAS-C = 1 AND WS-DRND < L-CHANCE
         CALL "FL-GET-STATE" USING L-X WS-C L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS NOT = 3
             CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(L-ROW, 3) WS-T
             MOVE WS-C TO WS-YY
             MOVE 0 TO WS-STOP
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-T OR WS-STOP = 1
                 CALL "SP-BASE-PLACE" USING L-ROW L-X WS-YY L-Z WS-FLAG
                 IF WS-FLAG = 0
                     MOVE 1 TO WS-STOP
                 END-IF
                 ADD 1 TO WS-YY
             END-PERFORM
             MOVE L-HEIGHT TO WS-CAP
             IF WS-HAS-F2 = 1
                 COMPUTE WS-BOUND = WS-C - WS-F2
                 IF WS-BOUND < WS-CAP
                     MOVE WS-BOUND TO WS-CAP
                 END-IF
             END-IF
             CALL "SC-HEIGHT" USING L-STATE L-ROW L-DX L-DZ L-DENSITY WS-CAP WS-HA
         END-IF
     END-IF
*>   5. the stalagmite flag (always drawn), 6. its layer and height
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-DRND
     MOVE 0 TO WS-HB
     IF WS-HAS-F2 = 1 AND WS-DRND < L-CHANCE
         CALL "FL-GET-STATE" USING L-X WS-F2 L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS NOT = 3
             CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(L-ROW, 3) WS-T
             MOVE WS-F2 TO WS-YY
             MOVE 0 TO WS-STOP
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-T OR WS-STOP = 1
                 CALL "SP-BASE-PLACE" USING L-ROW L-X WS-YY L-Z WS-FLAG
                 IF WS-FLAG = 0
                     MOVE 1 TO WS-STOP
                 END-IF
                 SUBTRACT 1 FROM WS-YY
             END-PERFORM
             IF WS-HAS-C = 1
                 MOVE WA-I(L-ROW, 4) TO WS-DIFF
                 COMPUTE WS-BOUND = 2 * WS-DIFF + 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
                 COMPUTE WS-HB = WS-HA + WS-DRAW - WS-DIFF
                 IF WS-HB < 0
                     MOVE 0 TO WS-HB
                 END-IF
             ELSE
                 CALL "SC-HEIGHT" USING L-STATE L-ROW L-DX L-DZ L-DENSITY L-HEIGHT WS-HB
             END-IF
         END-IF
     END-IF
*>   7. the meeting of the two columns
     IF WS-HAS-C = 1 AND WS-HAS-F2 = 1
         COMPUTE WS-LO = WS-C - WS-HA
         COMPUTE WS-HI = WS-F2 + WS-HB
         IF WS-LO <= WS-HI
             IF WS-F2 + 1 > WS-LO
                 COMPUTE WS-LO = WS-F2 + 1
             END-IF
             IF WS-C - 1 < WS-HI
                 COMPUTE WS-HI = WS-C - 1
             END-IF
             COMPUTE WS-BOUND = WS-HI + 1 - WS-LO + 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             COMPUTE WS-MEET = WS-DRAW + WS-LO
             COMPUTE WS-HA = WS-C - WS-MEET
             COMPUTE WS-HB = WS-MEET - 1 - WS-F2
         END-IF
     END-IF
*>   8. the merge flag: one nextBoolean always; it holds for two columns that fill the whole space between floor and ceiling
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
     MOVE 0 TO WS-MERGE
     IF WS-DRAW = 1 AND WS-HA > 0 AND WS-HB > 0 AND WS-HAS-C = 1 AND WS-HAS-F2 = 1
         IF WS-HA + WS-HB = WS-C - WS-F2 - 1
             MOVE 1 TO WS-MERGE
         END-IF
     END-IF
*>   9. and 10. the columns of pointed blocks
     IF WS-HAS-C = 1
         COMPUTE WS-YY = WS-C - 1
         CALL "SP-GROW" USING L-ROW L-X WS-YY L-Z WS-TIP-DOWN WS-HA WS-MERGE
     END-IF
     IF WS-HAS-F2 = 1
         COMPUTE WS-YY = WS-F2 + 1
         CALL "SP-GROW" USING L-ROW L-X WS-YY L-Z WS-TIP-UP WS-HB WS-MERGE
     END-IF
     GOBACK.
 END PROGRAM SC-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CLUSTER.
*> USING state, feature, x, y, z, result out (1 when the origin is air or water: the feature then returns true): 6.2 steps 1 to 4. The draws: the height, the wetness, the density, the two
*> radii; then for every column dx from -rx to rx (outer) and dz from -rz to rz the chance of a speleothem (float clampedMap of the distance to the edge) and SC-COLUMN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-WETNESS             FLOAT-LONG.
 01 WS-DENSITY             FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-EDGE                FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-MODE0               BINARY-LONG VALUE 0.
 01 WS-CHANCE-MAX          FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUES.
    05 WS-VAL              FLOAT-LONG OCCURS 4 TIMES.
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
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "SP-EMPTY-WATER" USING WS-STATE WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 1) WS-HEIGHT
     MOVE WA-I(WS-ROW, 9) TO WS-KIND
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > 4
         COMPUTE WS-E2 = WS-E + 4
         MOVE WA-G(WS-ROW, WS-E2) TO WS-VAL(WS-E)
     END-PERFORM
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-WETNESS
     MOVE WA-I(WS-ROW, 8) TO WS-KIND
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > 4
         MOVE WA-G(WS-ROW, WS-E) TO WS-VAL(WS-E)
     END-PERFORM
     CALL "FR-FP" USING L-STATE WS-KIND WS-VALUES WS-DENSITY
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-RX
     CALL "FR-INT-SAMPLE" USING L-STATE WA-IP(WS-ROW, 2) WS-RZ
     MOVE WA-F(WS-ROW, 1) TO WS-CHANCE-MAX
     CALL "FR-F32" USING WS-CHANCE-MAX
     MOVE WA-I(WS-ROW, 6) TO WS-EDGE
     COMPUTE WS-LX = 0 - WS-RX
     COMPUTE WS-LZ = 0 - WS-RZ
     PERFORM VARYING WS-DX FROM WS-LX BY 1 UNTIL WS-DX > WS-RX
         PERFORM VARYING WS-DZ FROM WS-LZ BY 1 UNTIL WS-DZ > WS-RZ
             COMPUTE WS-E = WS-RX - FUNCTION ABS(WS-DX)
             COMPUTE WS-E2 = WS-RZ - FUNCTION ABS(WS-DZ)
             IF WS-E2 < WS-E
                 MOVE WS-E2 TO WS-E
             END-IF
             MOVE WS-E TO WS-V
             CALL "FX-CLAMPED-MAP" USING WS-MODE0 WS-V WS-ZERO WS-EDGE WS-CHANCE-MAX WS-ONE WS-CHANCE
             COMPUTE WS-X = L-X + WS-DX
             COMPUTE WS-Z = L-Z + WS-DZ
             CALL "SC-COLUMN" USING L-STATE WS-ROW WS-X L-Y WS-Z WS-DX WS-DZ WS-CHANCE WS-HEIGHT WS-DENSITY WS-WETNESS
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-CLUSTER.
