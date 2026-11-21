*> Implementation test of replace_single_block and the RuleTest family (docs/protocol/35-worldgen-features-4 section 7.5; core/src/feat-replace.cob, T9807): the data feature compiles its target list
*> (type 37, one pair of rule test and state per entry; an unknown predicate_type, an unknown block, a missing state or a missing targets list make the feature unsupported), and on a window of the
*> real block table each rule test of 7.5.3 (block_match, blockstate_match, tag_match, height_match, random_block_match, random_blockstate_match, all_of, any_of, not, always_true) decides what is
*> written at the origin: the first accepted entry writes its state (an object state with properties too) and ends the walk, a failed test keeps the draws it made, a block that does not match draws
*> nothing, the empty all_of is true and the empty any_of is false. A model of this test with its own random stream seeded alike gives the expected block and the expected random state for 24 seeds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-REPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/rsb".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-FTKEY               PIC X(80).
 01 WS-BKEY                PIC X(112).
 01 WS-BPAIRS              PIC X(160).
 01 WS-FT                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-SC                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BADR                BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG VALUE 24.
 01 WS-OZ                  BINARY-LONG VALUE 40.
 01 WS-START               BINARY-LONG.
 01 WS-EXPS                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
 01 WS-S-COBBLE            BINARY-LONG.
 01 WS-S-MOSSY             BINARY-LONG.
 01 WS-S-COARSE            BINARY-LONG.
 01 WS-S-GRANITE           BINARY-LONG.
 01 WS-S-DIORITE           BINARY-LONG.
 01 WS-S-LOG-X             BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-NINE                FLOAT-LONG VALUE 0.9.
 01 WS-SCN                PIC 99.
 01 WS-WRITTEN             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     PERFORM LOOK-UP

*>   the compiled feature
     MOVE "minecraft:rsb_doc" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§7.5.1: the data feature of three targets compiles as type 37 with three pairs" TO WS-CASE
     COMPUTE WS-OBS = FT-TYPE(WS-FT) * 10 + FT-B(WS-FT)
     MOVE 373 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:rsb_empty" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§7.5.1: an empty target list is a supported feature of no pairs" TO WS-CASE
     COMPUTE WS-OBS = FT-TYPE(WS-FT) * 10 + FT-B(WS-FT)
     MOVE 370 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:rsb_bad_pred" TO WS-FTKEY
     PERFORM EXPECT-UNSUPPORTED
     MOVE "35-4§7.5.3: an unknown predicate_type makes the feature unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:rsb_bad_state" TO WS-FTKEY
     PERFORM EXPECT-UNSUPPORTED
     MOVE "35-4§7.5.2: a state that names an unknown block makes the feature unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:rsb_no_state" TO WS-FTKEY
     PERFORM EXPECT-UNSUPPORTED
     MOVE "35-4§7.5.2: an entry without its state makes the feature unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:rsb_no_targets" TO WS-FTKEY
     PERFORM EXPECT-UNSUPPORTED
     MOVE "35-4§7.5.1: a feature without targets is unsupported (the member is required)" TO WS-CASE
     PERFORM ASSERT-N

*>   what the rule tests write, 24 seeds each
     PERFORM VARYING WS-SC FROM 1 BY 1 UNTIL WS-SC > 23
         PERFORM SET-SCENARIO
         PERFORM RUN-SEEDS
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         PERFORM CHECK-WRITES
     END-PERFORM
     STOP RUN.

*> LOOK-UP: the block indexes and states the scenarios use, and the tag of the doc example
 LOOK-UP.
     MOVE "cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-COBBLE
     MOVE "mossy_cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-MOSSY
     MOVE "coarse_dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-COARSE
     COMPUTE WS-TAG-ID(2) = WS-WANT - 1
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-TAG-ID(1) = WS-WANT - 1
     MOVE 2 TO WS-TAG-N
     MOVE "minecraft:rsb_dirt" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "granite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRANITE
     MOVE "diorite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIORITE
     MOVE "oak_log" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-LOG-X
     .

*> EXPECT-UNSUPPORTED: compiles WS-FTKEY; WS-OBS = FT-TYPE (-1 for unsupported), WS-EXP = -1
 EXPECT-UNSUPPORTED.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .

*> SET-SCENARIO: WS-FTKEY, the block at the origin (WS-BKEY, WS-BPAIRS) and the origin's y
 SET-SCENARIO.
     MOVE SPACES TO WS-BPAIRS
     MOVE 64 TO WS-OY
     MOVE SPACES TO WS-CASE
     EVALUATE WS-SC
         WHEN 1
             MOVE "minecraft:rsb_doc" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.4: stone with targets E1 (random_block_match 0.5), E2, E3: the draw decides cobblestone or mossy cobblestone, one draw" TO WS-CASE
         WHEN 2
             MOVE "minecraft:rsb_doc" TO WS-FTKEY
             MOVE "dirt" TO WS-BKEY
             MOVE "35-4§7.5.4: dirt is rejected by E1 and E2 without a draw and accepted by the tag test E3: coarse dirt" TO WS-CASE
         WHEN 3
             MOVE "minecraft:rsb_doc" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.4: sand is accepted by no entry: nothing written, no draw" TO WS-CASE
         WHEN 4
             MOVE "minecraft:rsb_edge0" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.3: random_block_match with probability 0 draws once and never passes: the next entry writes mossy cobblestone" TO WS-CASE
         WHEN 5
             MOVE "minecraft:rsb_edge1" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.3: random_block_match with probability 1.0 draws once and always passes: cobblestone" TO WS-CASE
         WHEN 6
             MOVE "minecraft:rsb_not" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.3: not of random_block_match 0.25 on stone: the child's draw happens, granite when the child failed" TO WS-CASE
         WHEN 7
             MOVE "minecraft:rsb_not" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.3: not of random_block_match on sand: the child is false without a draw, so the test is true: granite, no draw" TO WS-CASE
         WHEN 8
             MOVE "minecraft:rsb_allof" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.3: all_of of two random_block_match 0.9: the second child is evaluated only when the first passed" TO WS-CASE
         WHEN 9
             MOVE "minecraft:rsb_empty" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.1: an empty target list writes nothing and draws nothing" TO WS-CASE
         WHEN 10
             MOVE "minecraft:rsb_emptylists" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.3: the empty all_of is true (granite, the entry after it is not evaluated)" TO WS-CASE
         WHEN 11
             MOVE "minecraft:rsb_anyempty" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.3: the empty any_of is false: nothing written" TO WS-CASE
         WHEN 12
             MOVE "minecraft:rsb_height" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE 8 TO WS-OY
             MOVE "35-4§7.5.3: height_match [0, 8] is true at y = 8 (granite)" TO WS-CASE
         WHEN 13
             MOVE "minecraft:rsb_height" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE 9 TO WS-OY
             MOVE "35-4§7.5.3: height_match [0, 8] is false at y = 9" TO WS-CASE
         WHEN 14
             MOVE "minecraft:rsb_height" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE 0 TO WS-OY
             MOVE "35-4§7.5.3: height_match [0, 8] is true at y = 0 (granite)" TO WS-CASE
         WHEN 15
             MOVE "minecraft:rsb_height" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE -1 TO WS-OY
             MOVE "35-4§7.5.3: height_match [0, 8] is false at y = -1" TO WS-CASE
         WHEN 16
             MOVE "minecraft:rsb_props" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.2: always_true with an object state {id, properties}: the written state is oak_log axis=x" TO WS-CASE
         WHEN 17
             MOVE "minecraft:rsb_state" TO WS-FTKEY
             MOVE "oak_log" TO WS-BKEY
             MOVE "axis=y" TO WS-BPAIRS
             MOVE "35-4§7.5.3: blockstate_match oak_log axis=y accepts that state: granite" TO WS-CASE
         WHEN 18
             MOVE "minecraft:rsb_state" TO WS-FTKEY
             MOVE "oak_log" TO WS-BKEY
             MOVE "axis=x" TO WS-BPAIRS
             MOVE "35-4§7.5.3: blockstate_match oak_log axis=y rejects axis=x (another state of the same block): nothing written" TO WS-CASE
         WHEN 19
             MOVE "minecraft:rsb_rstate" TO WS-FTKEY
             MOVE "oak_log" TO WS-BKEY
             MOVE "axis=y" TO WS-BPAIRS
             MOVE "35-4§7.5.3: random_blockstate_match with probability 1.0 on the state: one draw, granite" TO WS-CASE
         WHEN 20
             MOVE "minecraft:rsb_rstate" TO WS-FTKEY
             MOVE "oak_log" TO WS-BKEY
             MOVE "axis=x" TO WS-BPAIRS
             MOVE "35-4§7.5.3: random_blockstate_match on another state of the block: no draw, nothing written" TO WS-CASE
         WHEN 21
             MOVE "minecraft:rsb_anyof" TO WS-FTKEY
             MOVE "sand" TO WS-BKEY
             MOVE "35-4§7.5.3: any_of [block_match sand, random_block_match stone 0.5] on sand: true by the first child, no draw: granite" TO WS-CASE
         WHEN 22
             MOVE "minecraft:rsb_anyof" TO WS-FTKEY
             MOVE "stone" TO WS-BKEY
             MOVE "35-4§7.5.3: the same any_of on stone: the second child draws once, granite below 0.5" TO WS-CASE
         WHEN OTHER
             MOVE "minecraft:rsb_anyof" TO WS-FTKEY
             MOVE "dirt" TO WS-BKEY
             MOVE "35-4§7.5.3: the same any_of on dirt: both children false, no draw, nothing written" TO WS-CASE
     END-EVALUATE
     .

*> RUN-SEEDS: 24 seeds of the feature at the origin; WS-BAD counts the seeds whose block or random state differs from the model; WS-WRITTEN the seeds that wrote something
 RUN-SEEDS.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE 0 TO WS-BAD WS-WRITTEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-I TO WS-SEED
         SET ADDRESS OF WS-A TO WS-PTR
         MOVE LOW-VALUES TO WS-A
         CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
         MOVE WS-BKEY TO WS-KEY
         MOVE WS-BPAIRS TO WS-PAIRS
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         PERFORM PUT-PAIRS
         MOVE WS-STATE TO WS-START
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-OK
         PERFORM MODEL
         CALL "FL-GET-STATE" USING WS-OX WS-OY WS-OZ WS-STATE
         MOVE 1000000 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-P1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-P2
         IF WS-STATE NOT = WS-EXPS OR WS-P1 NOT = WS-P2 OR WS-OK NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         IF WS-STATE NOT = WS-START
             ADD 1 TO WS-WRITTEN
         END-IF
     END-PERFORM
     .

*> CHECK-WRITES: the scenarios whose outcome is fixed by the rules write in no seed, in every seed (24), or only in the seeds whose draws pass (some: neither none nor all)
 CHECK-WRITES.
     MOVE SPACES TO WS-CASE
     MOVE WS-SC TO WS-SCN
     STRING "35-4§7.5 scenario " WS-SCN " wrote in the expected number of seeds (none, all, or some)" DELIMITED BY SIZE INTO WS-CASE
     EVALUATE WS-SC
         WHEN 3
         WHEN 9
         WHEN 11
         WHEN 13
         WHEN 15
         WHEN 18
         WHEN 20
         WHEN 23
             MOVE 0 TO WS-EXP
             MOVE WS-WRITTEN TO WS-OBS
         WHEN 6
         WHEN 8
         WHEN 22
             MOVE 1 TO WS-EXP
             MOVE 0 TO WS-OBS
             IF WS-WRITTEN > 0 AND WS-WRITTEN < 24
                 MOVE 1 TO WS-OBS
             END-IF
         WHEN OTHER
             MOVE 24 TO WS-EXP
             MOVE WS-WRITTEN TO WS-OBS
     END-EVALUATE
     PERFORM ASSERT-N
     .

*> MODEL: the expected state at the origin in WS-EXPS, drawing from the model's own stream (XR2-STATE) as the rules of 7.5.3 say
 MODEL.
     MOVE WS-START TO WS-EXPS
     EVALUATE WS-SC
         WHEN 1
             PERFORM MFLOAT
             IF WS-F < WS-HALF
                 MOVE WS-S-COBBLE TO WS-EXPS
             ELSE
                 MOVE WS-S-MOSSY TO WS-EXPS
             END-IF
         WHEN 2
             MOVE WS-S-COARSE TO WS-EXPS
         WHEN 4
             PERFORM MFLOAT
             MOVE WS-S-MOSSY TO WS-EXPS
         WHEN 5
             PERFORM MFLOAT
             MOVE WS-S-COBBLE TO WS-EXPS
         WHEN 6
             PERFORM MFLOAT
             IF WS-F >= WS-QUARTER
                 MOVE WS-S-GRANITE TO WS-EXPS
             END-IF
         WHEN 7
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 8
             PERFORM MFLOAT
             IF WS-F < WS-NINE
                 PERFORM MFLOAT
                 IF WS-F < WS-NINE
                     MOVE WS-S-GRANITE TO WS-EXPS
                 END-IF
             END-IF
         WHEN 10
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 12
         WHEN 14
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 16
             MOVE WS-S-LOG-X TO WS-EXPS
         WHEN 17
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 19
             PERFORM MFLOAT
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 21
             MOVE WS-S-GRANITE TO WS-EXPS
         WHEN 22
             PERFORM MFLOAT
             IF WS-F < WS-HALF
                 MOVE WS-S-GRANITE TO WS-EXPS
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     .
 MFLOAT.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-REPLACE.
 COPY NOSPAWN.
 COPY CORETEST.
