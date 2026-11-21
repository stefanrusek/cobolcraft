*> The block drawing of the ocean monument (docs/protocol/36-structures-6-ocean.md sections 5.6, 5.8 and 5.9; 36-1 6.5): the common helpers of OceanMonumentPiece (generateBox, placeBlock,
*> generateWaterBox, generateBoxOnFillOnly, generateDefaultFloor, chunkIntersects, spawnElder) and the interpreter of the geometry rows (MONGEO.cpy, generated from the tables of the document
*> by core/tests/fixtures/gen_monument.py). The frame of every helper is the piece row MP-ROW (STRUCT-MONUMENT, STRUCTMON.cpy): its box and orientation turn a piece-local position into a world
*> position (SPB-WORLD), and a cell outside the write box of the chunk pass (SP-WBOX) is skipped, so the whole piece is rebuilt by every chunk it touches and each pass writes its own part. The level is
*> the feature level (FEATLEVEL.cpy). No block of the monument is directional, so the mirror and rotation of 36-1 6.5 change no state and placeBlock needs no canBeReplaced.
*>
*> Entry points (every argument a BINARY-LONG field; a block code is 1 prismarine bricks, 2 prismarine, 3 dark prismarine, 4 sea lantern, 5 gold block, 6 wet sponge):
*>   MONP-BLOCKS: resolves MB-STATE and MB-KEEP for the block table epoch
*>   MONP-PUT USING x y z, code: PUT;  MONP-OP USING op (B box, W water box, F fill on water only), x0 y0 z0 x1 y1 z1, code: BOX, WATER or FILL (order y, then x, then z)
*>   MONP-BH USING x0 y z0 x1 z1, code: a box of one layer;  MONP-BC USING x y0 z y1, code: a box of one column
*>   MONP-WATER-CELL USING x y z;  MONP-FILL-CELL USING x y z, code: one cell of WATER and of FILL
*>   MONP-FLOOR USING x z, hasOpening: generateDefaultFloor;  MONP-CHUNK-INT USING x0 z0 x1 z1, flag out: chunkIntersects;  MONP-ELDER USING x y z: spawnElder
*>   MONP-ROWS USING class, first row, last row: the rows of the class with those numbers whose design and condition hold

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY STRUCTMON.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-STATE               BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(32) VALUE "minecraft:prismarine_bricks".
    05 FILLER              PIC X(32) VALUE "minecraft:prismarine".
    05 FILLER              PIC X(32) VALUE "minecraft:dark_prismarine".
    05 FILLER              PIC X(32) VALUE "minecraft:sea_lantern".
    05 FILLER              PIC X(32) VALUE "minecraft:gold_block".
    05 FILLER              PIC X(32) VALUE "minecraft:wet_sponge".
    05 FILLER              PIC X(32) VALUE "minecraft:water".
    05 FILLER              PIC X(32) VALUE "minecraft:ice".
    05 FILLER              PIC X(32) VALUE "minecraft:packed_ice".
    05 FILLER              PIC X(32) VALUE "minecraft:blue_ice".
 01 WS-KEY-TAB REDEFINES WS-KEYS.
    05 WS-KEY-OF           PIC X(32) OCCURS 10 TIMES.
 PROCEDURE DIVISION.
     IF MB-EPOCH = CB-EPOCH + 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-KEY-OF(WS-I) TO WS-KEY
         CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
         EVALUATE WS-I
             WHEN 8
                 CALL "FL-BLOCK-OF" USING WS-STATE MB-KEEP(1)
             WHEN 9
                 CALL "FL-BLOCK-OF" USING WS-STATE MB-KEEP(2)
             WHEN 10
                 CALL "FL-BLOCK-OF" USING WS-STATE MB-KEEP(3)
             WHEN OTHER
                 MOVE WS-STATE TO MB-STATE(WS-I)
         END-EVALUATE
     END-PERFORM
     CALL "FL-BLOCK-OF" USING MB-STATE(7) MB-KEEP(4)
     COMPUTE MB-EPOCH = CB-EPOCH + 1
     GOBACK.
 END PROGRAM MONP-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-PUT.
*> USING x y z (piece-local), block code: placeBlock (36-1 6.5): the state written with flags 2 when the world position lies inside the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CODE.
     CALL "SPB-WORLD" USING MP-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ MB-STATE(L-CODE) WS-FLAGS WS-OK
     END-IF
     GOBACK.
 END PROGRAM MONP-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-WATER-CELL.
*> USING x y z: one cell of generateWaterBox (5.6): ice, packed ice, blue ice and water stay; anything else becomes air at or above the sea level and water below it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "SPB-WORLD" USING MP-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         IF WS-BLOCK NOT = MB-KEEP(1) AND WS-BLOCK NOT = MB-KEEP(2) AND WS-BLOCK NOT = MB-KEEP(3) AND WS-BLOCK NOT = MB-KEEP(4)
             IF WS-WY >= FL-SEA
                 CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ FL-S-AIR WS-FLAGS WS-OK
             ELSE
                 CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ MB-STATE(7) WS-FLAGS WS-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MONP-WATER-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-FILL-CELL.
*> USING x y z, block code: one cell of generateBoxOnFillOnly (5.6): written only where the block state is exactly a water source block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CODE.
     CALL "SPB-WORLD" USING MP-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
         IF WS-STATE = MB-STATE(7)
             CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ MB-STATE(L-CODE) WS-FLAGS WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MONP-FILL-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-OP.
*> USING op (PIC X: B generateBox with one block, W generateWaterBox, F generateBoxOnFillOnly), x0 y0 z0 x1 y1 z1 (piece-local, both ends inclusive), block code: the cells in the order y, x, z (skipAir
*> is false in every call, 5.6); nothing when the box lies outside the write box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-C.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   PIC X.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-CODE.
     MOVE L-X0 TO WS-V(1)
     MOVE L-Y0 TO WS-V(2)
     MOVE L-Z0 TO WS-V(3)
     MOVE L-X1 TO WS-V(4)
     MOVE L-Y1 TO WS-V(5)
     MOVE L-Z1 TO WS-V(6)
     CALL "SHP-TOUCH" USING MP-ROW WS-C WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             PERFORM VARYING WS-Z FROM L-Z0 BY 1 UNTIL WS-Z > L-Z1
                 EVALUATE L-OP
                     WHEN "B"
                         CALL "MONP-PUT" USING WS-X WS-Y WS-Z L-CODE
                     WHEN "W"
                         CALL "MONP-WATER-CELL" USING WS-X WS-Y WS-Z
                     WHEN OTHER
                         CALL "MONP-FILL-CELL" USING WS-X WS-Y WS-Z L-CODE
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-BH.
*> USING x0 y z0 x1 z1, block code: a box of one layer (generateBox from (x0, y, z0) to (x1, y, z1)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y L-Z0 L-X1 L-Z1 L-CODE.
     MOVE L-Y TO WS-Y1
     CALL "MONP-OP" USING "B" L-X0 L-Y L-Z0 L-X1 WS-Y1 L-Z1 L-CODE
     GOBACK.
 END PROGRAM MONP-BH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-BC.
*> USING x y0 z y1, block code: a box of one column (generateBox from (x, y0, z) to (x, y1, z)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y0 L-Z L-Y1 L-CODE.
     MOVE L-X TO WS-X1
     MOVE L-Z TO WS-Z1
     CALL "MONP-OP" USING "B" L-X L-Y0 L-Z WS-X1 L-Y1 WS-Z1 L-CODE
     GOBACK.
 END PROGRAM MONP-BC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-FLOOR.
*> USING x z, hasOpening: generateDefaultFloor (5.6) at piece-local y 0 for the cell whose local offset is (x, z): with the opening an 8 x 8 floor with a 2 x 2 hole at x + 3..4, z + 3..4 edged with bricks,
*> else one prismarine box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-OPEN.
     MOVE 0 TO W-Y0
     MOVE 0 TO W-Y1
     IF L-OPEN = 1
         MOVE 2 TO W-B
         COMPUTE W-X0 = L-X + 0
         COMPUTE W-Z0 = L-Z + 0
         COMPUTE W-X1 = L-X + 2
         COMPUTE W-Z1 = L-Z + 7
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = L-X + 5
         COMPUTE W-X1 = L-X + 7
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = L-X + 3
         COMPUTE W-X1 = L-X + 4
         COMPUTE W-Z1 = L-Z + 2
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-Z0 = L-Z + 5
         COMPUTE W-Z1 = L-Z + 7
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 1 TO W-B
         COMPUTE W-Z0 = L-Z + 2
         COMPUTE W-Z1 = L-Z + 2
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-Z0 = L-Z + 5
         COMPUTE W-Z1 = L-Z + 5
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = L-X + 2
         COMPUTE W-X1 = L-X + 2
         COMPUTE W-Z0 = L-Z + 3
         COMPUTE W-Z1 = L-Z + 4
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = L-X + 5
         COMPUTE W-X1 = L-X + 5
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     ELSE
         MOVE 2 TO W-B
         MOVE L-X TO W-X0
         MOVE L-Z TO W-Z0
         COMPUTE W-X1 = L-X + 7
         COMPUTE W-Z1 = L-Z + 7
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-IF
     GOBACK.
 END PROGRAM MONP-FLOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-CHUNK-INT.
*> USING x0 z0 x1 z1 (piece-local), flag out: chunkIntersects (5.6): 1 when the write box meets the rectangle between the two corners, converted to the world, in x and z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==C-==.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Z0 L-X1 L-Z1 L-FLAG.
     CALL "SPB-WORLD" USING MP-ROW L-X0 WS-ZERO L-Z0 WS-AX WS-AY WS-AZ
     CALL "SPB-WORLD" USING MP-ROW L-X1 WS-ZERO L-Z1 WS-BX WS-BY WS-BZ
     CALL "SPB-BOX-NEW" USING WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ WS-BOX
     CALL "SPB-BOX-INTERSECTS-XZ" USING WS-BOX SP-WBOX L-FLAG
     GOBACK.
 END PROGRAM MONP-CHUNK-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ELDER.
*> USING x y z (piece-local): spawnElder (5.10): when the world position lies inside the chunk write box an elder guardian (no persistence) is asked of the entity channel at the block centre
*> (x + 0.5, y, z + 0.5), once, because the position is one block; the spawn details (health, finalizeSpawn) belong to the mob.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-ID                  PIC X(32) VALUE "minecraft:elder_guardian".
 01 WS-PERSISTENT          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "SPB-WORLD" USING MP-ROW L-X L-Y L-Z WS-WX WS-WY WS-WZ
     CALL "SPB-BOX-INSIDE" USING SP-WBOX WS-WX WS-WY WS-WZ WS-IN
     IF WS-IN = 1
         COMPUTE WS-FX = WS-WX + 0.5
         MOVE WS-WY TO WS-FY
         COMPUTE WS-FZ = WS-WZ + 0.5
         CALL "GENT-ADD-MOB" USING WS-FX WS-FY WS-FZ WS-ID WS-PERSISTENT
     END-IF
     GOBACK.
 END PROGRAM MONP-ELDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ROWS.
*> USING class, first row, last row: the rows of the geometry table (MONGEO.cpy) of the class whose number lies in the range, in table order: a row whose design is set is skipped unless it is the
*> piece's MP-DESIGN, a row with a condition is skipped unless it holds for the cells MP-CELL (a cell opening of a direction slot, or no up link; 1000 is the pillar flag), then the op is done at the
*> coordinates (x moved by MP-XOFF for the wings of the building).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONGEO.
 COPY MONWS.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DSUB                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OP                  PIC X.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-FROM L-TO.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > MG-ROWS
         IF MG-CLASS(WS-R) = L-CLASS AND MG-N(WS-R) >= L-FROM AND MG-N(WS-R) <= L-TO
             MOVE 1 TO WS-OK
             IF MG-DESIGN(WS-R) >= 0 AND MG-DESIGN(WS-R) NOT = MP-DESIGN
                 MOVE 0 TO WS-OK
             END-IF
             MOVE MG-COND(WS-R) TO WS-C
             IF WS-C = 1000
                 MOVE MP-PILLAR TO WS-OK
             END-IF
             IF WS-C NOT = 0 AND WS-C NOT = 1000
                 COMPUTE WS-CELL = FUNCTION ABS(WS-C) / 10
                 MOVE MP-CELL(WS-CELL) TO WS-CELL
                 COMPUTE WS-KIND = FUNCTION MOD(FUNCTION ABS(WS-C), 10)
                 EVALUATE WS-KIND
                     WHEN 1
                         MOVE 4 TO WS-DSUB
                     WHEN 2
                         MOVE 3 TO WS-DSUB
                     WHEN 3
                         MOVE 5 TO WS-DSUB
                     WHEN OTHER
                         MOVE 6 TO WS-DSUB
                 END-EVALUATE
                 IF WS-KIND = 5
                     IF MD-CONN(WS-CELL, 2) NOT = 0
                         MOVE 0 TO WS-OK
                     END-IF
                 ELSE
                     IF WS-C > 0 AND MD-OPEN(WS-CELL, WS-DSUB) = 0
                         MOVE 0 TO WS-OK
                     END-IF
                     IF WS-C < 0 AND MD-OPEN(WS-CELL, WS-DSUB) = 1
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
             END-IF
             IF WS-OK = 1
                 COMPUTE W-X0 = MG-C(WS-R, 1) + MP-XOFF
                 MOVE MG-C(WS-R, 2) TO W-Y0
                 MOVE MG-C(WS-R, 3) TO W-Z0
                 COMPUTE W-X1 = MG-C(WS-R, 4) + MP-XOFF
                 MOVE MG-C(WS-R, 5) TO W-Y1
                 MOVE MG-C(WS-R, 6) TO W-Z1
                 MOVE MG-BLOCK(WS-R) TO W-B
                 MOVE MG-OP(WS-R) TO WS-OP
                 EVALUATE WS-OP
                     WHEN "P"
                         CALL "MONP-PUT" USING W-X0 W-Y0 W-Z0 W-B
                     WHEN "E"
                         CALL "MONP-ELDER" USING W-X0 W-Y0 W-Z0
                     WHEN OTHER
                         CALL "MONP-OP" USING WS-OP W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-ROWS.
