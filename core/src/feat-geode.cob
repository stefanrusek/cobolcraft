*> The geode feature (docs/protocol/35-worldgen-features-6-underground.md section 4; registry id 20, geode): FD-GEODE-NODE compiles the configuration into a row of FD-WA: WA-I(1 .. 5) the
*> providers of filling, inner layer, alternate inner layer, middle layer and outer layer (FD-PROV-NODE rows), WA-START(1) and WA-N(1) the states of inner_placements, the pool 2 cannot_replace and the
*> pool 3 invalid_blocks (block sets), WA-F(1 .. 4) the layer values filling, inner, middle, outer (1.7, 2.2, 3.2, 4.2), WA-G(1) generate_crack_chance (1.0), WA-G(2) base_crack_size (2.0),
*> WA-G(3) use_potential_placements_chance (0.35), WA-G(4) use_alternate_layer0_chance (0.0), WA-G(5) noise_multiplier (0.05), WA-I(6) crack_point_offset (2), WA-I(7)
*> placements_require_layer0_alternate (1), WA-I(8) and WA-I(9) min_gen_offset and max_gen_offset (-16, 16), WA-I(10) invalid_blocks_threshold, WA-I(11) the maximum of outer_wall_distance,
*> WA-IP(1) outer_wall_distance (uniform 4 to 5), WA-IP(2) distribution_points (uniform 3 to 4), WA-IP(3) point_offset (uniform 1 to 2). A missing required member makes the feature unsupported.
*> FR-GEODE places it (4.3): the point draws, the invalid-block test, the crack, the scan of the box of 33 x 33 x 33 positions (x fastest, then y, z slowest) with the shape noise
*> NormalNoise.createParity(-4, [1.0]) of the world seed CV-SEED (built once per seed: NOISE-CREATE-LEGACY with the layer amplitude set to 5/6 as 4.2 derives it), the layers, and the buds.
*> Deviations: the fluid ticks of the cracks (4.3 step 7.6) are not scheduled (the generation window has no tick queue); the cost is that of the document's full box scan (no cap: about
*> 36 000 noise values per geode, one geode in 24 chunks); writes outside the chunk column are refused by the level as everywhere (the draws of those positions are still made).
*>
*> Entry points: FD-GEODE-NODE USING doc, node, row out; FR-GEODE USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-GEODE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY FDCONST.
 01 WS-K-BLOCKS            PIC X(40) VALUE "blocks".
 01 WS-K-FILLING           PIC X(40) VALUE "filling_provider".
 01 WS-K-INNER             PIC X(40) VALUE "inner_layer_provider".
 01 WS-K-ALT               PIC X(40) VALUE "alternate_inner_layer_provider".
 01 WS-K-MIDDLE            PIC X(40) VALUE "middle_layer_provider".
 01 WS-K-OUTER             PIC X(40) VALUE "outer_layer_provider".
 01 WS-K-PLACEMENTS        PIC X(40) VALUE "inner_placements".
 01 WS-K-CANNOT            PIC X(40) VALUE "cannot_replace".
 01 WS-K-INVALID           PIC X(40) VALUE "invalid_blocks".
 01 WS-K-LAYERS            PIC X(40) VALUE "layers".
 01 WS-K-LFILL             PIC X(40) VALUE "filling".
 01 WS-K-LINNER            PIC X(40) VALUE "inner_layer".
 01 WS-K-LMIDDLE           PIC X(40) VALUE "middle_layer".
 01 WS-K-LOUTER            PIC X(40) VALUE "outer_layer".
 01 WS-K-CRACK             PIC X(40) VALUE "crack".
 01 WS-K-CHANCE            PIC X(40) VALUE "generate_crack_chance".
 01 WS-K-BASE              PIC X(40) VALUE "base_crack_size".
 01 WS-K-COFFSET           PIC X(40) VALUE "crack_point_offset".
 01 WS-K-POTENTIAL         PIC X(40) VALUE "use_potential_placements_chance".
 01 WS-K-ALTCHANCE         PIC X(40) VALUE "use_alternate_layer0_chance".
 01 WS-K-REQUIRE           PIC X(40) VALUE "placements_require_layer0_alternate".
 01 WS-K-WALL              PIC X(40) VALUE "outer_wall_distance".
 01 WS-K-POINTS            PIC X(40) VALUE "distribution_points".
 01 WS-K-POFFSET           PIC X(40) VALUE "point_offset".
 01 WS-K-MIN               PIC X(40) VALUE "min_gen_offset".
 01 WS-K-MAX               PIC X(40) VALUE "max_gen_offset".
 01 WS-K-NOISE             PIC X(40) VALUE "noise_multiplier".
 01 WS-K-THRESHOLD         PIC X(40) VALUE "invalid_blocks_threshold".
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-CRACK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-IP.
    05 WS-IPV              BINARY-LONG OCCURS 4 TIMES.
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
*>   defaults
     MOVE 1.7 TO WA-F(WS-ROW, 1)
     MOVE 2.2 TO WA-F(WS-ROW, 2)
     MOVE 3.2 TO WA-F(WS-ROW, 3)
     MOVE 4.2 TO WA-F(WS-ROW, 4)
     MOVE 1.0 TO WA-G(WS-ROW, 1)
     MOVE 2.0 TO WA-G(WS-ROW, 2)
     MOVE 0.35 TO WA-G(WS-ROW, 3)
     MOVE 0.0 TO WA-G(WS-ROW, 4)
     MOVE 0.05 TO WA-G(WS-ROW, 5)
     MOVE 2 TO WA-I(WS-ROW, 6)
     MOVE 1 TO WA-I(WS-ROW, 7)
     MOVE -16 TO WA-I(WS-ROW, 8)
     MOVE 16 TO WA-I(WS-ROW, 9)
*>   the blocks
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCKS WS-BLOCKS
     IF WS-BLOCKS = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-FILLING WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-I(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-INNER WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-I(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-ALT WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-I(WS-ROW, 3)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-MIDDLE WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-I(WS-ROW, 4)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-OUTER WS-E
     CALL "FD-PROV-NODE" USING JSON-DOC WS-E WA-I(WS-ROW, 5)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-PLACEMENTS WS-E
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     MOVE 0 TO WA-N(WS-ROW, 1)
     IF WS-E = 0 OR JN-TYPE(WS-E) NOT = JT-ARRAY OR JN-COUNT(WS-E) < 1
         MOVE 1 TO FD-BAD
     ELSE
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             CALL "FD-J-STATE" USING JSON-DOC WS-N WS-STATE WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-POOL-ADD" USING WS-STATE WS-IDX
             ADD 1 TO WA-N(WS-ROW, 1)
         END-PERFORM
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-CANNOT WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 2) WA-N(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC WS-BLOCKS WS-K-INVALID WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 3) WA-N(WS-ROW, 3)
*>   the layers and the crack (objects that may be empty or absent)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-LAYERS WS-LAYERS
     IF WS-LAYERS > 0
         CALL "FD-J-MEMBER" USING JSON-DOC WS-LAYERS WS-K-LFILL WS-E
         PERFORM READ-LAYER-1
         CALL "FD-J-MEMBER" USING JSON-DOC WS-LAYERS WS-K-LINNER WS-E
         PERFORM READ-LAYER-2
         CALL "FD-J-MEMBER" USING JSON-DOC WS-LAYERS WS-K-LMIDDLE WS-E
         PERFORM READ-LAYER-3
         CALL "FD-J-MEMBER" USING JSON-DOC WS-LAYERS WS-K-LOUTER WS-E
         PERFORM READ-LAYER-4
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CRACK WS-CRACK
     IF WS-CRACK > 0
         CALL "FD-J-MEMBER" USING JSON-DOC WS-CRACK WS-K-CHANCE WS-E
         IF WS-E > 0
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-G(WS-ROW, 1) WS-OK
             PERFORM CHECK-OK
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-CRACK WS-K-BASE WS-E
         IF WS-E > 0
             CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-G(WS-ROW, 2) WS-OK
             PERFORM CHECK-OK
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-CRACK WS-K-COFFSET WS-E
         IF WS-E > 0
             CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 6) WS-OK
             PERFORM CHECK-OK
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-POTENTIAL WS-E
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-G(WS-ROW, 3) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ALTCHANCE WS-E
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-G(WS-ROW, 4) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-NOISE WS-E
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-G(WS-ROW, 5) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REQUIRE WS-E
     IF WS-E > 0
         IF JN-TYPE(WS-E) = JT-FALSE
             MOVE 0 TO WA-I(WS-ROW, 7)
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MIN WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 8) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MAX WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 9) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-THRESHOLD WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 10) WS-OK
     PERFORM CHECK-OK
*>   the int providers: outer_wall_distance (4 to 5), distribution_points (3 to 4), point_offset (1 to 2)
     MOVE 2 TO WA-IPV(WS-ROW, 1, 1)
     MOVE 4 TO WA-IPV(WS-ROW, 1, 2)
     MOVE 5 TO WA-IPV(WS-ROW, 1, 3)
     MOVE 2 TO WA-IPV(WS-ROW, 2, 1)
     MOVE 3 TO WA-IPV(WS-ROW, 2, 2)
     MOVE 4 TO WA-IPV(WS-ROW, 2, 3)
     MOVE 2 TO WA-IPV(WS-ROW, 3, 1)
     MOVE 1 TO WA-IPV(WS-ROW, 3, 2)
     MOVE 2 TO WA-IPV(WS-ROW, 3, 3)
     MOVE 5 TO WA-I(WS-ROW, 11)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-WALL WS-E
     IF WS-E > 0
         CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(WS-ROW, 1) WS-OK
         PERFORM CHECK-OK
         PERFORM WALL-MAXIMUM
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-POINTS WS-E
     IF WS-E > 0
         CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(WS-ROW, 2) WS-OK
         PERFORM CHECK-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-POFFSET WS-E
     IF WS-E > 0
         CALL "FD-J-IP" USING JSON-DOC WS-E WA-IP(WS-ROW, 3) WS-OK
         PERFORM CHECK-OK
     END-IF
     GOBACK.
 CHECK-OK.
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     .
*> WALL-MAXIMUM: WA-I(11) the largest value of the outer_wall_distance provider (a constant is its value, the other kinds their second integer)
 WALL-MAXIMUM.
     IF WA-IPV(WS-ROW, 1, 1) = 1
         MOVE WA-IPV(WS-ROW, 1, 2) TO WA-I(WS-ROW, 11)
     ELSE
         MOVE WA-IPV(WS-ROW, 1, 3) TO WA-I(WS-ROW, 11)
     END-IF
     IF WA-I(WS-ROW, 11) < 1
         MOVE 1 TO FD-BAD
     END-IF
     .
 READ-LAYER-1.
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 1) WS-OK
         PERFORM CHECK-OK
     END-IF
     .
 READ-LAYER-2.
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 2) WS-OK
         PERFORM CHECK-OK
     END-IF
     .
 READ-LAYER-3.
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 3) WS-OK
         PERFORM CHECK-OK
     END-IF
     .
 READ-LAYER-4.
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 4) WS-OK
         PERFORM CHECK-OK
     END-IF
     .
 END PROGRAM FD-GEODE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-GEODE.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 COPY CARVER.
 COPY NOISE.
 01 WS-ROW                 BINARY-LONG.
*> the noise of the world seed, kept while the store holds it
 01 WS-HANDLE              BINARY-LONG VALUE 0.
 01 WS-HSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-HPERLIN             BINARY-LONG.
 01 WS-BASEAMP             FLOAT-LONG VALUE 1.0.
 01 WS-FIVE                FLOAT-LONG VALUE 5.0.
 01 WS-SIX                 FLOAT-LONG VALUE 6.0.
 01 WS-A                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ZERO-D              FLOAT-LONG VALUE 0.
 01 WS-ONE-SCALE           FLOAT-LONG VALUE 1.0.
 01 WS-NMODE               BINARY-LONG VALUE 0.
 01 WS-PCOUNT              BINARY-LONG.
 01 WS-IP4.
    05 WS-IPV              BINARY-LONG OCCURS 4 TIMES.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-INVALID             BINARY-LONG.
 01 WS-CRACK-FLAG          BINARY-LONG.
 01 WS-RR                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-DD                  FLOAT-LONG.
 01 WS-FILL-T              FLOAT-LONG.
 01 WS-INNER-T             FLOAT-LONG.
 01 WS-MIDDLE-T            FLOAT-LONG.
 01 WS-OUTER-T             FLOAT-LONG.
 01 WS-CRACK-T             FLOAT-LONG.
 01 WS-X-ADD               FLOAT-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-T3                  FLOAT-LONG.
 01 WS-T4                  FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-SG                  BINARY-LONG.
 01 WS-D-OFFSET            FLOAT-LONG.
 01 WS-NPOINTS             BINARY-LONG.
 01 WS-POINTS.
    05 WS-PT OCCURS 20 TIMES.
       10 WS-PX            BINARY-LONG.
       10 WS-PY            BINARY-LONG.
       10 WS-PZ            BINARY-LONG.
       10 WS-POFF          FLOAT-LONG.
 01 WS-CPOINTS.
    05 WS-CP OCCURS 3 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CY            BINARY-LONG.
       10 WS-CZ            BINARY-LONG.
 01 WS-NCRACK              BINARY-LONG.
 01 WS-COFF                FLOAT-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DSQ                 BINARY-LONG.
 01 WS-DSQD                FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-NZ-VALUE            FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-MULT                FLOAT-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-NEWSTATE            BINARY-LONG.
 01 WS-USE-ALT             BINARY-LONG.
 01 WS-POTENTIAL           BINARY-LONG.
 01 WS-NPOT                BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-M4                  BINARY-LONG VALUE -4.
 01 WS-TWO-D               FLOAT-LONG VALUE 2.0.
 01 WS-POT.
    05 WS-PO OCCURS 4096 TIMES.
       10 WS-POX           BINARY-LONG.
       10 WS-POY           BINARY-LONG.
       10 WS-POZ           BINARY-LONG.
 01 WS-D6                  BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-BSTATE              BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TRUE-TEXT           PIC X(40) VALUE "true".
 01 WS-FALSE-TEXT          PIC X(40) VALUE "false".
 01 WS-FACING-KEY          PIC X(40) VALUE "facing".
 01 WS-WATERLOG-KEY        PIC X(40) VALUE "waterlogged".
 01 WS-DIRNAMES.
    05 FILLER              PIC X(40) VALUE "down".
    05 FILLER              PIC X(40) VALUE "up".
    05 FILLER              PIC X(40) VALUE "north".
    05 FILLER              PIC X(40) VALUE "south".
    05 FILLER              PIC X(40) VALUE "west".
    05 FILLER              PIC X(40) VALUE "east".
 01 WS-DIRNAME-TABLE REDEFINES WS-DIRNAMES.
    05 WS-DIRNAME          PIC X(40) OCCURS 6 TIMES.
 01 WS-DIRS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR OCCURS 6 TIMES.
       10 WS-DDX           BINARY-LONG.
       10 WS-DDY           BINARY-LONG.
       10 WS-DDZ           BINARY-LONG.
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
*>   1. the number of points
     MOVE WA-IPV(WS-ROW, 2, 1) TO WS-IPV(1)
     MOVE WA-IPV(WS-ROW, 2, 2) TO WS-IPV(2)
     MOVE WA-IPV(WS-ROW, 2, 3) TO WS-IPV(3)
     MOVE WA-IPV(WS-ROW, 2, 4) TO WS-IPV(4)
     CALL "FR-INT-SAMPLE" USING L-STATE WS-IP4 WS-PCOUNT
     IF WS-PCOUNT < 1 OR WS-PCOUNT > 20
         GOBACK
     END-IF
     PERFORM OPEN-NOISE
*>   3. the thresholds (doubles): D = P / max(outer_wall_distance)
     MOVE WS-PCOUNT TO WS-T1
     MOVE WA-I(WS-ROW, 11) TO WS-T2
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T1 WS-T2 WS-DD
     MOVE WA-F(WS-ROW, 1) TO WS-T1
     PERFORM INV-SQRT-T1
     MOVE WS-T3 TO WS-FILL-T
     MOVE WA-F(WS-ROW, 2) TO WS-T1
     PERFORM INV-SQRT-PLUS-D
     MOVE WS-T3 TO WS-INNER-T
     MOVE WA-F(WS-ROW, 3) TO WS-T1
     PERFORM INV-SQRT-PLUS-D
     MOVE WS-T3 TO WS-MIDDLE-T
     MOVE WA-F(WS-ROW, 4) TO WS-T1
     PERFORM INV-SQRT-PLUS-D
     MOVE WS-T3 TO WS-OUTER-T
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-R
     MOVE WS-ZERO-D TO WS-X-ADD
     IF WS-PCOUNT > 3
         MOVE WS-DD TO WS-X-ADD
     END-IF
*>   crackT = 1 / sqrt(base + r / 2 + X)
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-R WS-TWO-D WS-T1
     MOVE WA-G(WS-ROW, 2) TO WS-T2
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T2 WS-T1 WS-T3
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T3 WS-X-ADD WS-T1
     PERFORM INV-SQRT-T1
     MOVE WS-T3 TO WS-CRACK-T
*>   4. the crack flag: nextFloat() < generate_crack_chance
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
     MOVE WS-NF TO WS-U1
     MOVE WA-G(WS-ROW, 1) TO WS-U2
     PERFORM SIGN-OF-DIFF
     MOVE 0 TO WS-CRACK-FLAG
     IF WS-SG < 0
         MOVE 1 TO WS-CRACK-FLAG
     END-IF
*>   5. the points
     MOVE 0 TO WS-INVALID WS-NPOINTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PCOUNT
         PERFORM SAMPLE-WALL
         COMPUTE WS-PX(WS-I) = L-X + WS-DX
         PERFORM SAMPLE-WALL
         COMPUTE WS-PY(WS-I) = L-Y + WS-DX
         PERFORM SAMPLE-WALL
         COMPUTE WS-PZ(WS-I) = L-Z + WS-DX
         MOVE WS-PX(WS-I) TO WS-QX
         MOVE WS-PY(WS-I) TO WS-QY
         MOVE WS-PZ(WS-I) TO WS-QZ
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         MOVE WS-CLASS TO WS-FLAG
         IF WS-FLAG NOT = 1
             MOVE 0 TO WS-FLAG
             CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 3) WA-N(WS-ROW, 3) WS-BLOCK WS-FLAG
         END-IF
         IF WS-FLAG = 1
             ADD 1 TO WS-INVALID
             IF WS-INVALID > WA-I(WS-ROW, 10)
                 GOBACK
             END-IF
         END-IF
         MOVE WA-IPV(WS-ROW, 3, 1) TO WS-IPV(1)
         MOVE WA-IPV(WS-ROW, 3, 2) TO WS-IPV(2)
         MOVE WA-IPV(WS-ROW, 3, 3) TO WS-IPV(3)
         MOVE WA-IPV(WS-ROW, 3, 4) TO WS-IPV(4)
         CALL "FR-INT-SAMPLE" USING L-STATE WS-IP4 WS-DRAW
         MOVE WS-DRAW TO WS-POFF(WS-I)
     END-PERFORM
     MOVE WS-PCOUNT TO WS-NPOINTS
*>   6. the crack points
     MOVE 0 TO WS-NCRACK
     IF WS-CRACK-FLAG = 1
         MOVE 4 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-DRAW WS-RR
         COMPUTE WS-S = 2 * WS-PCOUNT + 1
         MOVE 3 TO WS-NCRACK
         EVALUATE WS-RR
             WHEN 0
                 MOVE WS-S TO WS-DX
                 MOVE 0 TO WS-DZ
             WHEN 1
                 MOVE 0 TO WS-DX
                 MOVE WS-S TO WS-DZ
             WHEN 2
                 MOVE WS-S TO WS-DX
                 MOVE WS-S TO WS-DZ
             WHEN OTHER
                 MOVE 0 TO WS-DX
                 MOVE 0 TO WS-DZ
         END-EVALUATE
         COMPUTE WS-CX(1) = L-X + WS-DX
         COMPUTE WS-CZ(1) = L-Z + WS-DZ
         COMPUTE WS-CY(1) = L-Y + 7
         COMPUTE WS-CX(2) = L-X + WS-DX
         COMPUTE WS-CZ(2) = L-Z + WS-DZ
         COMPUTE WS-CY(2) = L-Y + 5
         COMPUTE WS-CX(3) = L-X + WS-DX
         COMPUTE WS-CZ(3) = L-Z + WS-DZ
         COMPUTE WS-CY(3) = L-Y + 1
     END-IF
     MOVE WA-I(WS-ROW, 6) TO WS-COFF
*>   7. the box
     MOVE 0 TO WS-NPOT
     MOVE WA-G(WS-ROW, 5) TO WS-MULT
     COMPUTE WS-SPAN = WA-I(WS-ROW, 9) - WA-I(WS-ROW, 8)
     PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > WS-SPAN
         PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > WS-SPAN
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > WS-SPAN
                 PERFORM VISIT
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   8. the buds
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NPOT
         MOVE WA-N(WS-ROW, 1) TO WS-D6
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-D6 WS-PICK
         MOVE FD-POOL(WA-START(WS-ROW, 1) + WS-PICK) TO WS-BSTATE
         MOVE 0 TO WS-STOP
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6 OR WS-STOP = 1
             MOVE WS-BSTATE TO WS-SRC
             CALL "FD-STATE-SET" USING WS-SRC WS-FACING-KEY WS-DIRNAME(WS-J) WS-BSTATE WS-FOUND
             COMPUTE WS-NX = WS-POX(WS-I) + WS-DDX(WS-J)
             COMPUTE WS-NY = WS-POY(WS-I) + WS-DDY(WS-J)
             COMPUTE WS-NZ = WS-POZ(WS-I) + WS-DDZ(WS-J)
             CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
*>           waterlogged = the neighbour holds a source fluid (the water block at level 0)
             MOVE 0 TO WS-FLAG
             IF WS-CLASS = 2 AND WS-STATE = CB-DEFAULT-STATE(FL-B-WATER)
                 MOVE 1 TO WS-FLAG
             END-IF
             MOVE WS-BSTATE TO WS-SRC
             IF WS-FLAG = 1
                 CALL "FD-STATE-SET" USING WS-SRC WS-WATERLOG-KEY WS-TRUE-TEXT WS-BSTATE WS-FOUND
             ELSE
                 CALL "FD-STATE-SET" USING WS-SRC WS-WATERLOG-KEY WS-FALSE-TEXT WS-BSTATE WS-FOUND
             END-IF
             IF WS-CLASS = 1 OR WS-FLAG = 1
                 MOVE WS-BSTATE TO WS-NEWSTATE
                 MOVE WS-NX TO WS-QX
                 MOVE WS-NY TO WS-QY
                 MOVE WS-NZ TO WS-QZ
                 PERFORM SAFE-SET
                 MOVE 1 TO WS-STOP
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
*> OPEN-NOISE: the shape noise of the world seed (4.2): NormalNoise.createParity(-4, [1.0]) is the legacy noise of octave -4 whose two layer amplitudes are 5/6 as a float32
 OPEN-NOISE.
     IF WS-HANDLE > 0 AND WS-HANDLE <= NZ-NOISE-COUNT AND WS-HSEED = CV-SEED
         IF NZ-L-PERLIN(NZ-FIRST(WS-HANDLE)) = WS-HPERLIN
             EXIT PARAGRAPH
         END-IF
     END-IF
     CALL "NOISE-CREATE-LEGACY" USING CV-SEED WS-M4 WS-BASEAMP WS-HANDLE
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FIVE WS-SIX WS-T1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T1 WS-A
     MOVE WS-A TO NZ-L-AMP(NZ-FIRST(WS-HANDLE))
     COMPUTE WS-J = NZ-FIRST(WS-HANDLE) + 1
     MOVE WS-A TO NZ-L-AMP(WS-J)
     MOVE CV-SEED TO WS-HSEED
     MOVE NZ-L-PERLIN(NZ-FIRST(WS-HANDLE)) TO WS-HPERLIN
     .
*> INV-SQRT-T1: WS-T3 = 1 / sqrt(WS-T1); INV-SQRT-PLUS-D: WS-T3 = 1 / sqrt(WS-T1 + D)
 INV-SQRT-PLUS-D.
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T1 WS-DD WS-T2
     MOVE WS-T2 TO WS-T1
     PERFORM INV-SQRT-T1
     .
 INV-SQRT-T1.
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-T1 WS-T4
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE WS-T4 WS-T3
     .
*> SIGN-OF-DIFF: WS-SG = the sign of WS-U1 - WS-U2
 SIGN-OF-DIFF.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U1 WS-U2 WS-T4
     CALL STATIC "cc_f64_signum" USING BY REFERENCE WS-T4 WS-T1
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-T1 WS-SG
     .
*> SAMPLE-WALL: WS-DX = one sample of outer_wall_distance
 SAMPLE-WALL.
     MOVE WA-IPV(WS-ROW, 1, 1) TO WS-IPV(1)
     MOVE WA-IPV(WS-ROW, 1, 2) TO WS-IPV(2)
     MOVE WA-IPV(WS-ROW, 1, 3) TO WS-IPV(3)
     MOVE WA-IPV(WS-ROW, 1, 4) TO WS-IPV(4)
     CALL "FR-INT-SAMPLE" USING L-STATE WS-IP4 WS-DX
     .
*> SAFE-SET: the state WS-NEWSTATE at (WS-QX, WS-QY, WS-QZ) unless the block there is in cannot_replace
 SAFE-SET.
     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING WA-START(WS-ROW, 2) WA-N(WS-ROW, 2) WS-BLOCK WS-FLAG
     IF WS-FLAG = 0
         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-NEWSTATE WS-FLAGS WS-WRITTEN
     END-IF
     .
*> PROVIDER-SET: the state of the provider WA-I(WS-ROW, WS-LAYER) at the position written by SAFE-SET
 PROVIDER-SET.
     MOVE WA-I(WS-ROW, WS-LAYER) TO WS-SRC
     CALL "FR-PROV-STATE" USING L-STATE WS-SRC WS-QX WS-QY WS-QZ WS-NEWSTATE WS-OK
     IF WS-OK = 1
         PERFORM SAFE-SET
     END-IF
     .
*> SUM-POINTS: WS-S1 = the sum over the points, in list order, of invSqrt(distSqr(q, point) + (double) offset) + n
 SUM-POINTS.
     MOVE WS-ZERO-D TO WS-S1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NPOINTS
         COMPUTE WS-DSQ = (WS-QX - WS-PX(WS-I)) * (WS-QX - WS-PX(WS-I)) + (WS-QY - WS-PY(WS-I)) * (WS-QY - WS-PY(WS-I))
             + (WS-QZ - WS-PZ(WS-I)) * (WS-QZ - WS-PZ(WS-I))
         MOVE WS-DSQ TO WS-T1
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T1 WS-POFF(WS-I) WS-T2
         MOVE WS-T2 TO WS-T1
         PERFORM INV-SQRT-T1
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T3 WS-N WS-T2
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S1 WS-T2 WS-T1
         MOVE WS-T1 TO WS-S1
     END-PERFORM
     .
*> SUM-CRACK: WS-S2 the same over the crack points with the offset crack_point_offset
 SUM-CRACK.
     MOVE WS-ZERO-D TO WS-S2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NCRACK
         COMPUTE WS-DSQ = (WS-QX - WS-CX(WS-I)) * (WS-QX - WS-CX(WS-I)) + (WS-QY - WS-CY(WS-I)) * (WS-QY - WS-CY(WS-I))
             + (WS-QZ - WS-CZ(WS-I)) * (WS-QZ - WS-CZ(WS-I))
         MOVE WS-DSQ TO WS-T1
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T1 WS-COFF WS-T2
         MOVE WS-T2 TO WS-T1
         PERFORM INV-SQRT-T1
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T3 WS-N WS-T2
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S2 WS-T2 WS-T1
         MOVE WS-T1 TO WS-S2
     END-PERFORM
     .
*> SGE: WS-FLAG 1 when WS-U1 >= WS-U2
 SGE.
     PERFORM SIGN-OF-DIFF
     MOVE 0 TO WS-FLAG
     IF WS-SG >= 0
         MOVE 1 TO WS-FLAG
     END-IF
     .
*> VISIT (7): the position (origin + min + (WS-LX, WS-LY, WS-LZ)), the sums over the points and the layer rules
 VISIT.
     COMPUTE WS-QX = L-X + WA-I(WS-ROW, 8) + WS-LX
     COMPUTE WS-QY = L-Y + WA-I(WS-ROW, 8) + WS-LY
     COMPUTE WS-QZ = L-Z + WA-I(WS-ROW, 8) + WS-LZ
     MOVE WS-QX TO WS-FX
     MOVE WS-QY TO WS-FY
     MOVE WS-QZ TO WS-FZ
     CALL "NOISE-GET" USING WS-HANDLE WS-FX WS-FY WS-FZ WS-NZ-VALUE
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-NZ-VALUE WS-MULT WS-N
     PERFORM SUM-POINTS
*>   S1 < outerT: nothing
     MOVE WS-S1 TO WS-U1
     MOVE WS-OUTER-T TO WS-U2
     PERFORM SGE
     IF WS-FLAG = 0
         EXIT PARAGRAPH
     END-IF
     MOVE WS-FILL-T TO WS-U2
     PERFORM SGE
     IF WS-FLAG = 1
         MOVE 1 TO WS-LAYER
         PERFORM PROVIDER-SET
         EXIT PARAGRAPH
     END-IF
     IF WS-NCRACK > 0
         PERFORM SUM-CRACK
         MOVE WS-S2 TO WS-U1
         MOVE WS-CRACK-T TO WS-U2
         PERFORM SGE
         IF WS-FLAG = 1
             MOVE FL-S-AIR TO WS-NEWSTATE
             PERFORM SAFE-SET
             EXIT PARAGRAPH
         END-IF
     END-IF
     MOVE WS-S1 TO WS-U1
     MOVE WS-INNER-T TO WS-U2
     PERFORM SGE
     IF WS-FLAG = 1
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
         MOVE WS-NF TO WS-U1
         MOVE WA-G(WS-ROW, 4) TO WS-U2
         PERFORM SIGN-OF-DIFF
         MOVE 0 TO WS-USE-ALT
         IF WS-SG < 0
             MOVE 1 TO WS-USE-ALT
         END-IF
         IF WS-USE-ALT = 1
             MOVE 3 TO WS-LAYER
         ELSE
             MOVE 2 TO WS-LAYER
         END-IF
         PERFORM PROVIDER-SET
         IF WA-I(WS-ROW, 7) = 0 OR WS-USE-ALT = 1
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
             MOVE WS-NF TO WS-U1
             MOVE WA-G(WS-ROW, 3) TO WS-U2
             PERFORM SIGN-OF-DIFF
             IF WS-SG < 0 AND WS-NPOT < 4096
                 ADD 1 TO WS-NPOT
                 MOVE WS-QX TO WS-POX(WS-NPOT)
                 MOVE WS-QY TO WS-POY(WS-NPOT)
                 MOVE WS-QZ TO WS-POZ(WS-NPOT)
             END-IF
         END-IF
         EXIT PARAGRAPH
     END-IF
     MOVE WS-S1 TO WS-U1
     MOVE WS-MIDDLE-T TO WS-U2
     PERFORM SGE
     IF WS-FLAG = 1
         MOVE 4 TO WS-LAYER
     ELSE
         MOVE 5 TO WS-LAYER
     END-IF
     PERFORM PROVIDER-SET
     .
 END PROGRAM FR-GEODE.
