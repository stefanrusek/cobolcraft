*> Implementation test of speleothem (docs/protocol/35-worldgen-features-6-underground.md section 5; core/src/feat-35-6.cob): the data features compile (type 45; defaults 0.2, 0.7, 0.5, 0.5; an
*> unknown block, a missing block, a block without the three properties of the pointed block, an unknown set or a full feature table make the feature unsupported); placements in a hand made cave
*> (stone y 40 to 62 and 70 to 80, air between) change exactly the cells the rules of 5.2 and 5.3 give, replayed by a model of this test on a second random source seeded alike: the tip direction
*> (one nextBoolean when both neighbours are base, none when neither), the patch of base blocks (four horizontal directions, the float against the spread chance, the radius 2 and 3 steps with
*> nextInt(6)), the height float (always drawn), waterlogged pieces in water, a base cell that already is the base block (not replaced). The random state after every placement equals the model's.
*> SP-GROW is tested for every height 1 to 4, merged or not, up and down, and without a base cell.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-C3                  FLOAT-LONG.
 01 WS-C4                  FLOAT-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-HZ.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
 01 WS-HZ-T REDEFINES WS-HZ.
    05 WS-HD               BINARY-LONG OCCURS 4 TIMES.
 01 WS-TALL                BINARY-LONG.
 01 WS-DV                  BINARY-LONG.
 01 WS-TOTAL-POINTED       BINARY-LONG.
 01 WS-TOTAL-BASE          BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
*>   the tag dripstone_replaceable_blocks: stone, granite, diorite, andesite
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE WS-WANT TO WS-SETB(1)
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "granite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(2)
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE "diorite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(3)
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE "andesite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(4)
     COMPUTE WS-ID(4) = WS-WANT - 1
     MOVE 4 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "dripstone_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BASE
     MOVE "pointed_dripstone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-POINTED
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   the data features compile
     MOVE "minecraft:speleothem" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: the data feature speleothem compiles as type 45" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 45 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.1: the base and pointed blocks are dripstone_block and pointed_dripstone" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-I(FT-A(WS-FT), 1) = WS-B-BASE
         ADD 10 TO WS-OBS
     END-IF
     IF WA-I(FT-A(WS-FT), 2) = WS-B-POINTED
         ADD 1 TO WS-OBS
     END-IF
     MOVE 11 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.1: the replaceable set is the four blocks of the tag" TO WS-CASE
     MOVE WA-N(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 4 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.1: the chances default to 0.2, 0.7, 0.5, 0.5" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-F(FT-A(WS-FT), 1) = 0.2 AND WA-F(FT-A(WS-FT), 2) = 0.7 AND WA-F(FT-A(WS-FT), 3) = 0.5 AND WA-F(FT-A(WS-FT), 4) = 0.5
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.3: the twenty states of the pointed block are distinct and the tip down, not waterlogged, is the default thickness tip (index 1 * 4 + 1 * 2 + 0)" TO WS-CASE
     MOVE 0 TO WS-OBS
     MOVE 1 TO WS-HT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 19
         PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > 19
             IF WS-I NOT = WS-J
                 IF FD-POOL(WA-START(FT-A(WS-FT), 2) + WS-I) = FD-POOL(WA-START(FT-A(WS-FT), 2) + WS-J)
                     MOVE 0 TO WS-HT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "pointed_dripstone" TO WS-KEY
     MOVE "thickness=tip,vertical_direction=down,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     IF WS-HT = 1 AND FD-POOL(WA-START(FT-A(WS-FT), 2) + 6) = WS-STATE
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:pointed_dripstone" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§5.1: the gate admits the placed feature pointed_dripstone" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:speleothem_chances" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: the four chances are read (0.6, 0.9, 0.8, 0.3)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-F(FT-A(WS-FT), 1) = 0.6 AND WA-F(FT-A(WS-FT), 2) = 0.9 AND WA-F(FT-A(WS-FT), 3) = 0.8 AND WA-F(FT-A(WS-FT), 4) = 0.3
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:speleothem_nobase" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: an unknown base block makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:speleothem_nopointed" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: a missing pointed block makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:speleothem_plainpointed" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: a pointed block without the three properties (stone) makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:speleothem_notag" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.1: an unknown replaceable set makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:speleothem" TO WS-FTKEY
     MOVE 0 TO FD-BAD
     CALL "FD-RESET"
     MOVE FD-MAX-WA TO FD-WA-COUNT
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-6§5.1: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FD-RESET"
     COMPUTE FD-POOL-COUNT = FD-MAX-POOL - 10
     MOVE "minecraft:speleothem" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§5.3: a block pool without room for the twenty states makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FD-RESET"
     MOVE 0.2 TO WS-C1
     MOVE 0.7 TO WS-C2
     MOVE 0.5 TO WS-C3
     MOVE 0.5 TO WS-C4
     PERFORM F32-CHANCES

*>   placements: the ceiling cell (24, 69, 40) (stone above: a stalactite), the floor cell (24, 63, 40) (a stalagmite), a one cell pocket (24, 50, 40) (both: one nextBoolean),
*>   the middle of the cave (24, 66, 40) (neither: false and no draw)
     MOVE "minecraft:speleothem" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE 0 TO WS-TOTAL-POINTED WS-TOTAL-BASE WS-TALL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 40
             PERFORM NEW-WORLD
             EVALUATE WS-K
                 WHEN 1
                     MOVE 69 TO WS-OY
                 WHEN 2
                     MOVE 63 TO WS-OY
                 WHEN 3
                     MOVE 50 TO WS-OY
                     MOVE 24 TO WS-X
                     MOVE 50 TO WS-Y
                     MOVE 40 TO WS-Z
                     MOVE "air" TO WS-KEY
                     PERFORM PUT-AT
                     PERFORM SNAPSHOT
                 WHEN OTHER
                     MOVE 66 TO WS-OY
             END-EVALUATE
             MOVE 24 TO WS-OX
             MOVE 40 TO WS-OZ
             PERFORM RUN-BOTH
         END-PERFORM
         MOVE SPACES TO WS-CASE
         EVALUATE WS-K
             WHEN 1
                 MOVE "35-6§5.2: a stalactite from the ceiling equals the model (cells and random state), forty seeds" TO WS-CASE
             WHEN 2
                 MOVE "35-6§5.2: a stalagmite from the floor equals the model (cells and random state), forty seeds" TO WS-CASE
             WHEN 3
                 MOVE "35-6§5.2: a pocket with a base cell above and below draws one nextBoolean for the tip direction, as modelled, forty seeds" TO WS-CASE
             WHEN OTHER
                 MOVE "35-6§5.2: no base cell above or below returns false without a draw, as modelled, forty seeds" TO WS-CASE
         END-EVALUATE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-6§5.2: the forty seeds wrote pointed dripstone blocks in the three placing cases" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-TOTAL-POINTED > 60
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.2: the patch of base blocks wrote dripstone blocks beyond the first cell" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-TOTAL-BASE > 150
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§5.2: some of the stalactites and stalagmites were taller (height 2)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-TALL > 10
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   other chances, and the same in water (the pieces are waterlogged where the cell holds water)
     MOVE "minecraft:speleothem_chances" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE 0.6 TO WS-C1
     MOVE 0.9 TO WS-C2
     MOVE 0.8 TO WS-C3
     MOVE 0.3 TO WS-C4
     PERFORM F32-CHANCES
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 40
         PERFORM NEW-WORLD
         MOVE 63 TO WS-Y0
         MOVE 69 TO WS-Y1
         MOVE 22 TO WS-X0
         MOVE 26 TO WS-X1
         MOVE 38 TO WS-Z0
         MOVE 42 TO WS-Z1
         MOVE "water" TO WS-KEY
         PERFORM FILL-BOX
         PERFORM SNAPSHOT
         MOVE 24 TO WS-OX
         MOVE 40 TO WS-OZ
         MOVE 69 TO WS-OY
         PERFORM RUN-BOTH
     END-PERFORM
     MOVE "35-6§5.2: with chances 0.6, 0.9, 0.8, 0.3 in water the cells (waterlogged pieces) and the random state equal the model, forty seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a base cell that already is dripstone is not replaced and gives no patch cell; the pieces still stand
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "dripstone_block" TO WS-KEY
     PERFORM PUT-AT
     PERFORM SNAPSHOT
     MOVE 0 TO WS-BAD
     MOVE 3 TO WS-SEED
     MOVE 24 TO WS-OX
     MOVE 69 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE 0.2 TO WS-C1
     MOVE 0.7 TO WS-C2
     MOVE 0.5 TO WS-C3
     MOVE 0.5 TO WS-C4
     PERFORM F32-CHANCES
     MOVE "minecraft:speleothem" TO WS-FTKEY
     PERFORM COMPILE-FT
     PERFORM RUN-BOTH
     MOVE "35-6§2.3: a base block already dripstone is left alone (placeBaseBlockIfPossible false) and the placement equals the model" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   SP-GROW: every height 1 to 4, merged or not, up and down: the column of thicknesses
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-DV FROM 0 BY 1 UNTIL WS-DV > 1
         PERFORM VARYING WS-MERGE FROM 0 BY 1 UNTIL WS-MERGE > 1
             PERFORM VARYING WS-HT FROM 1 BY 1 UNTIL WS-HT > 4
                 PERFORM NEW-WORLD
                 IF WS-DV = 0
                     MOVE 69 TO WS-OY
                 ELSE
                     MOVE 63 TO WS-OY
                 END-IF
                 MOVE 24 TO WS-OX
                 MOVE 40 TO WS-OZ
                 MOVE WS-DV TO WS-TIP
                 MOVE FT-A(WS-FT) TO WS-J
                 CALL "SP-GROW" USING WS-J WS-OX WS-OY WS-OZ WS-TIP WS-HT WS-MERGE
                 MOVE WS-OX TO WS-GX
                 MOVE WS-OY TO WS-GY
                 MOVE WS-OZ TO WS-GZ
                 PERFORM MODEL-GROW
                 PERFORM COMPARE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-6§5.3: growSpeleothem for the heights 1 to 4, up and down, merged and not equals the piece list tip / frustum, tip / base, frustum, tip / base, middle, frustum, tip" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 66 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE 0 TO WS-TIP
     MOVE 2 TO WS-HT
     MOVE FT-A(WS-FT) TO WS-J
     CALL "SP-GROW" USING WS-J WS-OX WS-OY WS-OZ WS-TIP WS-HT WS-ZERO
     MOVE 0 TO WS-BAD
     PERFORM COMPARE
     MOVE "35-6§5.3: no base cell behind the first piece: nothing is written" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

*> F32-CHANCES: the chances of the model as single precision floats
 F32-CHANCES.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-C1 WS-F
     MOVE WS-F TO WS-C1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-C2 WS-F
     MOVE WS-F TO WS-C2
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-C3 WS-F
     MOVE WS-F TO WS-C3
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-C4 WS-F
     MOVE WS-F TO WS-C4
     .
*> RUN-BOTH: both random sources seeded with WS-SEED; the feature runs at (WS-OX, WS-OY, WS-OZ), the model replays it; WS-BAD += the cells that differ, plus one when the random states
*> or the results differ; WS-TOTAL-POINTED and WS-TOTAL-BASE count the blocks written
 RUN-BOTH.
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
     PERFORM MODEL-SPEL
     PERFORM COMPARE
     IF XR-LO NOT = X2-LO OR XR-HI NOT = X2-HI
         ADD 1 TO WS-BAD
     END-IF
     IF WS-RESULT NOT = WS-FULL
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-B-POINTED TO WS-WANT
     PERFORM COUNT-BLOCK
     ADD WS-N TO WS-TOTAL-POINTED
     MOVE WS-B-BASE TO WS-WANT
     PERFORM COUNT-BLOCK
     ADD WS-N TO WS-TOTAL-BASE
     .
*> MODEL-SPEL: section 5.2 on the model cells with the second random source
 MODEL-SPEL.
     MOVE 0 TO WS-FULL
     MOVE WS-OX TO WS-MX
     COMPUTE WS-MY = WS-OY + 1
     MOVE WS-OZ TO WS-MZ
     PERFORM MODEL-ISBASE
     MOVE WS-D TO WS-ABOVE
     COMPUTE WS-MY = WS-OY - 1
     PERFORM MODEL-ISBASE
     MOVE WS-D TO WS-BELOW
     IF WS-ABOVE = 0 AND WS-BELOW = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-FULL
     IF WS-ABOVE = 1 AND WS-BELOW = 1
         CALL "F351-NEXT-BOOLEAN" USING XR2-STATE WS-DRAW
         IF WS-DRAW = 1
             MOVE 0 TO WS-TIP
         ELSE
             MOVE 1 TO WS-TIP
         END-IF
     ELSE
         IF WS-ABOVE = 1
             MOVE 0 TO WS-TIP
         ELSE
             MOVE 1 TO WS-TIP
         END-IF
     END-IF
*>   the base cell is behind the tip: above the origin for a stalactite (tip down), below it for a stalagmite
     IF WS-TIP = 0
         COMPUTE WS-PY = WS-OY + 1
     ELSE
         COMPUTE WS-PY = WS-OY - 1
     END-IF
     MOVE WS-OX TO WS-PX
     MOVE WS-OZ TO WS-PZ
     MOVE WS-PX TO WS-MX
     MOVE WS-PY TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM MODEL-PLACE
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 4
         COMPUTE WS-KD = WS-HD(WS-H) + 1
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
         IF NOT WS-F > WS-C2
             COMPUTE WS-MX = WS-PX + WS-SX(WS-KD)
             COMPUTE WS-MY = WS-PY + WS-SY(WS-KD)
             COMPUTE WS-MZ = WS-PZ + WS-SZ(WS-KD)
             PERFORM MODEL-PLACE
             MOVE WS-MX TO WS-QX
             MOVE WS-MY TO WS-HT
             MOVE WS-MZ TO WS-QZ
             CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
             IF NOT WS-F > WS-C3
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SIX WS-DRAW
                 COMPUTE WS-KD = WS-DRAW + 1
                 COMPUTE WS-QX = WS-QX + WS-SX(WS-KD)
                 COMPUTE WS-HT = WS-HT + WS-SY(WS-KD)
                 COMPUTE WS-QZ = WS-QZ + WS-SZ(WS-KD)
                 MOVE WS-QX TO WS-MX
                 MOVE WS-HT TO WS-MY
                 MOVE WS-QZ TO WS-MZ
                 PERFORM MODEL-PLACE
                 CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
                 IF NOT WS-F > WS-C4
                     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-SIX WS-DRAW
                     COMPUTE WS-KD = WS-DRAW + 1
                     COMPUTE WS-MX = WS-QX + WS-SX(WS-KD)
                     COMPUTE WS-MY = WS-HT + WS-SY(WS-KD)
                     COMPUTE WS-MZ = WS-QZ + WS-SZ(WS-KD)
                     PERFORM MODEL-PLACE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   the height
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     MOVE 1 TO WS-HT
     IF WS-F < WS-C1
         COMPUTE WS-KD = WS-TIP + 1
         COMPUTE WS-MX = WS-OX + WS-SX(WS-KD)
         COMPUTE WS-MY = WS-OY + WS-SY(WS-KD)
         COMPUTE WS-MZ = WS-OZ + WS-SZ(WS-KD)
         PERFORM MGET
         PERFORM MBLOCK
         IF WS-MV = WS-S-AIR OR WS-MB = WS-B-WATER
             MOVE 2 TO WS-HT
         END-IF
     END-IF
     IF WS-HT = 2
         ADD 1 TO WS-TALL
     END-IF
     MOVE 0 TO WS-MERGE
     MOVE WS-OX TO WS-GX
     MOVE WS-OY TO WS-GY
     MOVE WS-OZ TO WS-GZ
     PERFORM MODEL-GROW
     .
 COPY SPELMODEL.
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-5.
 COPY CORETEST.
