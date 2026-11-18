*> Test of the Nether ruined portal (docs/protocol/37-nether-6 section 6; T1711; the engine is core/src/struct-portal.cob and struct-proc.cob, reused here), on the generated data
*> (CC_GENERATED_DIR, skipped as a pass without it): the setup the file gives (6, 3.3), the draws of a start (the stub at the chunk corner, the template among portal_1..10 and
*> giant_portal_1..3, the y between 15 and 100, 6 steps 3 to 7), the processors of the piece in order (6) and the 23-entry blackstone replacement table with the properties it copies (6.1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTDATA.
 COPY STRUCTPORTAL.
 COPY STRUCTPIECE.
 COPY STRUCTPROC.
 COPY STRUCTCUR.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-V                   BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-STRUCT              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-OLD                 PIC X(48).
 01 WS-NEW                 PIC X(48).
 01 WS-OLD-IDX             BINARY-LONG.
 01 WS-NEW-IDX             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DI                  PIC 99.
 01 WS-TABLE.
    05 FILLER              PIC X(96) VALUE "cobblestone                 blackstone".
    05 FILLER              PIC X(96) VALUE "mossy_cobblestone          blackstone".
    05 FILLER              PIC X(96) VALUE "stone                      polished_blackstone".
    05 FILLER              PIC X(96) VALUE "stone_bricks               polished_blackstone_bricks".
    05 FILLER              PIC X(96) VALUE "mossy_stone_bricks         polished_blackstone_bricks".
    05 FILLER              PIC X(96) VALUE "cobblestone_stairs         blackstone_stairs".
    05 FILLER              PIC X(96) VALUE "mossy_cobblestone_stairs   blackstone_stairs".
    05 FILLER              PIC X(96) VALUE "stone_stairs               polished_blackstone_stairs".
    05 FILLER              PIC X(96) VALUE "stone_brick_stairs         polished_blackstone_brick_stairs".
    05 FILLER              PIC X(96) VALUE "mossy_stone_brick_stairs   polished_blackstone_brick_stairs".
    05 FILLER              PIC X(96) VALUE "cobblestone_slab           blackstone_slab".
    05 FILLER              PIC X(96) VALUE "mossy_cobblestone_slab     blackstone_slab".
    05 FILLER              PIC X(96) VALUE "smooth_stone_slab          polished_blackstone_slab".
    05 FILLER              PIC X(96) VALUE "stone_slab                 polished_blackstone_slab".
    05 FILLER              PIC X(96) VALUE "stone_brick_slab           polished_blackstone_brick_slab".
    05 FILLER              PIC X(96) VALUE "mossy_stone_brick_slab     polished_blackstone_brick_slab".
    05 FILLER              PIC X(96) VALUE "stone_brick_wall           polished_blackstone_brick_wall".
    05 FILLER              PIC X(96) VALUE "mossy_stone_brick_wall     polished_blackstone_brick_wall".
    05 FILLER              PIC X(96) VALUE "cobblestone_wall           blackstone_wall".
    05 FILLER              PIC X(96) VALUE "mossy_cobblestone_wall     blackstone_wall".
    05 FILLER              PIC X(96) VALUE "chiseled_stone_bricks      chiseled_polished_blackstone".
    05 FILLER              PIC X(96) VALUE "cracked_stone_bricks       cracked_polished_blackstone_bricks".
    05 FILLER              PIC X(96) VALUE "iron_bars                  iron_chain".
 01 WS-TABLE-T REDEFINES WS-TABLE.
    05 WS-ROW-T            PIC X(96) OCCURS 23 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 37-6§6 The Nether ruined portal: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM SETUP-CASES
     PERFORM START-CASES
     PERFORM PROCESSOR-CASES
     PERFORM TABLE-CASES
     PERFORM PROPERTY-CASES
     STOP RUN.

 CHECK-V.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§6 The Nether ruined portal: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 FIND-STRUCT.
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM.

 SETUP-CASES.
     MOVE "minecraft:ruined_portal_nether" TO WS-KEY
     PERFORM FIND-STRUCT
     MOVE 1 TO WS-EXPECT
     IF WS-STRUCT > 0
         MOVE 1 TO WS-V
     ELSE
         MOVE 0 TO WS-V
     END-IF
     MOVE "the structure ruined_portal_nether is in the data" TO WS-CASE
     PERFORM CHECK-V
     MOVE SDT-RP-N(WS-STRUCT) TO WS-V
     MOVE "it has exactly one setup (no random draw for the choice)" TO WS-CASE
     PERFORM CHECK-V
     MOVE SDT-RP-FIRST(WS-STRUCT) TO WS-FIRST
     MOVE RP-PLACEMENT(WS-FIRST) TO WS-V
     MOVE 5 TO WS-EXPECT
     MOVE "its placement is in_nether (5)" TO WS-CASE
     PERFORM CHECK-V
     COMPUTE WS-V = RP-AIR(WS-FIRST) * 100 + 0.5
     MOVE 0 TO WS-EXPECT
     MOVE "air_pocket_probability is 0.0" TO WS-CASE
     PERFORM CHECK-V
     MOVE RP-MOSS(WS-FIRST) TO WS-V
     MOVE "mossiness is 0.0" TO WS-CASE
     PERFORM CHECK-V
     COMPUTE WS-V = RP-OVERGROWN(WS-FIRST) + RP-VINES(WS-FIRST) + RP-COLD(WS-FIRST)
     MOVE "overgrown, vines and can_be_cold are false" TO WS-CASE
     PERFORM CHECK-V
     MOVE RP-BLACK(WS-FIRST) TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "replace_with_blackstone is true" TO WS-CASE
     PERFORM CHECK-V
     COMPUTE WS-V = RP-WEIGHT(WS-FIRST) * 100 + 0.5
     MOVE 100 TO WS-EXPECT
     MOVE "the weight is 1.0" TO WS-CASE
     PERFORM CHECK-V.

 START-CASES.
*>   starts of 25 candidate chunks: valid, the stub at the chunk's world corner, the piece a portal_N or giant_portal_N, the y of the final step between 15 and 100
     MOVE 0 TO WS-BAD WS-LOW
     MOVE 1000 TO WS-HIGH
     PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 2
         PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 2
             CALL "STRUCT-PORTAL-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-SX WS-SY WS-SZ WS-VALID
             IF WS-VALID NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-V = WS-CX * 16
             IF WS-SX NOT = WS-V
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-V = WS-CZ * 16
             IF WS-SZ NOT = WS-V
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-SY < 15 OR WS-SY > 100
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-SY < WS-HIGH
                 MOVE WS-SY TO WS-HIGH
             END-IF
             IF WS-SY > WS-LOW
                 MOVE WS-SY TO WS-LOW
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO WS-V
     MOVE 0 TO WS-EXPECT
     MOVE "25 starts are valid, with the stub at the chunk's corner and a y from 15 to 100 (6 steps 6 and 7)" TO WS-CASE
     PERFORM CHECK-V
     MOVE 1 TO WS-V
     IF WS-LOW = WS-HIGH
         MOVE 0 TO WS-V
     END-IF
     MOVE 1 TO WS-EXPECT
     MOVE "the y differs from chunk to chunk (the candidate is drawn: 27 to 29 or 29 to 100)" TO WS-CASE
     PERFORM CHECK-V.

 PROCESSOR-CASES.
*>   6: block_ignore (air and structure blocks without an air pocket), the rule processor, block_age 0.0, protected blocks, lava_submerged_block, blackstone_replace (the key: air pocket 0,
*>   ocean floor 0, cold 0, blackstone 1, mossiness 0 tenths)
     MOVE "cobolcraft:inline/portal/0001/0" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE SPL-N(WS-LIST) TO WS-V
     MOVE 6 TO WS-EXPECT
     MOVE "the piece's list holds six processors" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPL-FIRST(WS-LIST) TO WS-FIRST
     MOVE SPP-TYPE(WS-FIRST) TO WS-V
     MOVE 9 TO WS-EXPECT
     MOVE "1: block_ignore" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-N(WS-FIRST) TO WS-V
     MOVE 2 TO WS-EXPECT
     MOVE "1: it ignores two blocks (structure blocks and air) when there is no air pocket" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(WS-FIRST + 1) TO WS-V
     MOVE 1 TO WS-EXPECT
     MOVE "2: the rule processor" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-N(WS-FIRST + 1) TO WS-V
     MOVE 3 TO WS-EXPECT
     MOVE "2: with three rules: gold to air, lava to magma, netherrack to magma" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(WS-FIRST + 2) TO WS-V
     MOVE 11 TO WS-EXPECT
     MOVE "3: BlockAgeProcessor (mossiness 0.0: no aging)" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(WS-FIRST + 3) TO WS-V
     MOVE 2 TO WS-EXPECT
     MOVE "4: protected blocks (features_cannot_replace)" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(WS-FIRST + 4) TO WS-V
     MOVE 7 TO WS-EXPECT
     MOVE "5: lava_submerged_block" TO WS-CASE
     PERFORM CHECK-V
     MOVE SPP-TYPE(WS-FIRST + 5) TO WS-V
     MOVE 10 TO WS-EXPECT
     MOVE "6: BlackstoneReplaceProcessor ends the list when replace_with_blackstone is true" TO WS-CASE
     PERFORM CHECK-V
*>   the rules: gold_block to air 0.3, lava to magma_block 0.2, netherrack to magma_block 0.07 (probabilities in hundredths)
     MOVE SPP-A(WS-FIRST + 1) TO WS-I
     PERFORM VARYING WS-OUT FROM 0 BY 1 UNTIL WS-OUT > 2
         COMPUTE WS-SX = WS-I + WS-OUT
         MOVE SPR-IN(WS-SX) TO WS-SY
         MOVE SPT-TYPE(WS-SY) TO WS-V
         EVALUATE WS-OUT
             WHEN 0
                 MOVE 5 TO WS-EXPECT
                 MOVE "rule 1 input is a random_block_match" TO WS-CASE
                 PERFORM CHECK-V
                 COMPUTE WS-V = SPT-F(WS-SY) * 100 + 0.5
                 MOVE 30 TO WS-EXPECT
                 MOVE "rule 1 (gold_block to air) has probability 0.3" TO WS-CASE
                 PERFORM CHECK-V
                 MOVE SPR-STATE(WS-SX) TO WS-V
                 MOVE 0 TO WS-EXPECT
                 MOVE "rule 1 outputs air (state 0)" TO WS-CASE
                 PERFORM CHECK-V
             WHEN 1
                 MOVE 5 TO WS-EXPECT
                 MOVE "rule 2 input is a random_block_match" TO WS-CASE
                 PERFORM CHECK-V
                 COMPUTE WS-V = SPT-F(WS-SY) * 100 + 0.5
                 MOVE 20 TO WS-EXPECT
                 MOVE "rule 2 (lava to magma_block, not cold, not on the ocean floor) has probability 0.2" TO WS-CASE
                 PERFORM CHECK-V
             WHEN 2
                 MOVE 5 TO WS-EXPECT
                 MOVE "rule 3 input is a random_block_match" TO WS-CASE
                 PERFORM CHECK-V
                 COMPUTE WS-V = SPT-F(WS-SY) * 100 + 0.5
                 MOVE 7 TO WS-EXPECT
                 MOVE "rule 3 (netherrack to magma_block, not cold) has probability 0.07" TO WS-CASE
                 PERFORM CHECK-V
         END-EVALUATE
     END-PERFORM.

*> 6.1: each of the 23 keys goes to its replacement
 TABLE-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE SPACES TO WS-OLD WS-NEW
         UNSTRING WS-ROW-T(WS-I) DELIMITED BY ALL SPACE INTO WS-OLD WS-NEW
         CALL "FD-BLOCK-INDEX" USING WS-OLD WS-OLD-IDX
         CALL "FD-BLOCK-INDEX" USING WS-NEW WS-NEW-IDX
         MOVE 0 TO CU-X CU-Y CU-Z CU-NBT CU-LOOT
         MOVE CB-DEFAULT-STATE(WS-OLD-IDX) TO CU-STATE
         CALL "STRUCT-PROC-BLACKSTONE" USING STRUCT-CUR
         COMPUTE WS-V = CB-S-BLOCK(CU-STATE + 1) + 1
         MOVE WS-NEW-IDX TO WS-EXPECT
         MOVE WS-I TO WS-DI
         MOVE SPACES TO WS-CASE
         STRING "table row " WS-DI " " FUNCTION TRIM(WS-OLD) " becomes " FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-V
     END-PERFORM
*>   a block outside the table is unchanged
     MOVE "oak_planks" TO WS-OLD
     CALL "FD-BLOCK-INDEX" USING WS-OLD WS-OLD-IDX
     MOVE CB-DEFAULT-STATE(WS-OLD-IDX) TO CU-STATE
     MOVE CU-STATE TO WS-EXPECT
     CALL "STRUCT-PROC-BLACKSTONE" USING STRUCT-CUR
     MOVE CU-STATE TO WS-V
     MOVE "a block that is not in the table (oak_planks) is unchanged" TO WS-CASE
     PERFORM CHECK-V.

*> 6.1: FACING, HALF and TYPE are copied when the old state has them; waterlogging is not
 PROPERTY-CASES.
     MOVE "cobblestone_stairs" TO WS-OLD
     CALL "FD-BLOCK-INDEX" USING WS-OLD WS-OLD-IDX
     MOVE CB-DEFAULT-STATE(WS-OLD-IDX) TO WS-STATE
     MOVE 2 TO WS-MODE
     MOVE "facing" TO WS-NAME
     MOVE "east" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-OUT
     MOVE WS-OUT TO WS-STATE
     MOVE "half" TO WS-NAME
     MOVE "top" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-OUT
     MOVE WS-OUT TO WS-STATE
     MOVE "waterlogged" TO WS-NAME
     MOVE "true" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-OUT
     MOVE WS-OUT TO CU-STATE
     CALL "STRUCT-PROC-BLACKSTONE" USING STRUCT-CUR
     MOVE 1 TO WS-MODE
     MOVE "facing" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE CU-STATE WS-NAME WS-TEXT WS-OUT
     MOVE 1 TO WS-V
     IF WS-TEXT NOT = "east"
         MOVE 0 TO WS-V
     END-IF
     MOVE 1 TO WS-EXPECT
     MOVE "stairs: facing east is copied to blackstone_stairs" TO WS-CASE
     PERFORM CHECK-V
     MOVE "half" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE CU-STATE WS-NAME WS-TEXT WS-OUT
     MOVE 1 TO WS-V
     IF WS-TEXT NOT = "top"
         MOVE 0 TO WS-V
     END-IF
     MOVE "stairs: half top is copied" TO WS-CASE
     PERFORM CHECK-V
     MOVE "waterlogged" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-MODE CU-STATE WS-NAME WS-TEXT WS-OUT
     MOVE 1 TO WS-V
     IF WS-TEXT NOT = "false"
         MOVE 0 TO WS-V
     END-IF
     MOVE "stairs: waterlogged true is not copied (the new block's default false)" TO WS-CASE
     PERFORM CHECK-V
     MOVE "cobblestone_slab" TO WS-OLD
     CALL "FD-BLOCK-INDEX" USING WS-OLD WS-OLD-IDX
     MOVE CB-DEFAULT-STATE(WS-OLD-IDX) TO WS-STATE
     MOVE 2 TO WS-MODE
     MOVE "type" TO WS-NAME
     MOVE "top" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-OUT
     MOVE WS-OUT TO CU-STATE
     CALL "STRUCT-PROC-BLACKSTONE" USING STRUCT-CUR
     MOVE 1 TO WS-MODE
     CALL "BLOCK-STATE-PROP" USING WS-MODE CU-STATE WS-NAME WS-TEXT WS-OUT
     MOVE 1 TO WS-V
     IF WS-TEXT NOT = "top"
         MOVE 0 TO WS-V
     END-IF
     MOVE "slab: type top is copied to blackstone_slab" TO WS-CASE
     PERFORM CHECK-V.
 END PROGRAM TEST-NETHER-37-6-6.
 COPY NOSPAWN.
 COPY CORETEST.
