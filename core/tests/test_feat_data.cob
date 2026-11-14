*> Test of the feature data compiler (core/src/feat-data.cob; docs/protocol/35-worldgen-features-1 sections 1, 7, 9 and 35-2 sections 3 and 4): placed features, features,
*> modifiers, predicates and providers read from the JSON files of core/tests/fixtures/feat and compiled into the tables of FEATDATA.cpy; references are stubs compiled on demand;
*> an unknown predicate, feature type, modifier, block or state property marks the placed feature unsupported.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY FEATDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-PF2                 BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 COPY JSONDOC.
 01 WS-TEXT                PIC X(4096).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(60).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 7 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 1 TO CB-SOLID(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE "minecraft:dandelion" TO CB-KEY(4)
     MOVE "minecraft:poppy" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     MOVE 1 TO CB-SOLID(8)
     MOVE "minecraft:lava" TO CB-KEY(9)
     MOVE "minecraft:tall_grass" TO CB-KEY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "minecraft:patch_flowers" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     MOVE "acceptance feature data: a new placed feature is a stub row" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-PF * 10 + PF-STATUS(WS-PF)
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-GET-PF" USING WS-KEY WS-PF2
     MOVE "acceptance feature data: the same id gives the same row" TO TL-CASE
     MOVE WS-PF2 TO TL-OBSERVED-N
     MOVE WS-PF TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: patch_flowers compiles with four modifiers" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PF-STATUS(WS-PF) * 10 + PF-MD-COUNT(WS-PF)
     MOVE 14 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE "acceptance feature data: the modifier kinds are count (6), in_square (14), heightmap (12), biome (5)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-KIND(WS-M) * 1000000 + MD-KIND(WS-M + 1) * 10000 + MD-KIND(WS-M + 2) * 100 + MD-KIND(WS-M + 3)
     MOVE 6141205 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature data: count 4 is the constant provider (1, 4); heightmap MOTION_BLOCKING is ordinal 4" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-P(WS-M, 1) * 1000 + MD-P(WS-M, 2) * 10 + MD-A(WS-M + 2)
     MOVE 1044 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-FT(WS-PF) TO WS-FT
     MOVE "acceptance feature data: the feature id is a stub until it is first needed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FT-TYPE(WS-FT)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "acceptance feature data: flower is a simple_block (42) with a weighted provider of two states" TO TL-CASE
     MOVE FT-A(WS-FT) TO WS-P
     COMPUTE TL-OBSERVED-N = FT-TYPE(WS-FT) * 1000 + PV-TYPE(WS-P) * 100 + PV-N(WS-P)
     MOVE 42202 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature data: the weighted pairs are (dandelion state 3, weight 3) and (poppy state 4, weight 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FD-POOL(PV-POOL(WS-P)) * 1000 + FD-POOL(PV-POOL(WS-P) + 1) * 100 + FD-POOL(PV-POOL(WS-P) + 2) * 10 + FD-POOL(PV-POOL(WS-P) + 3)
     MOVE 3341 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:rare_patch" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE "acceptance feature data: rare_patch compiles with count, in_square, heightmap, offset, filter, biome" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PF-STATUS(WS-PF) * 100 + PF-MD-COUNT(WS-PF)
     MOVE 106 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature data: count is the uniform provider 2 to 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-P(WS-M, 1) * 100 + MD-P(WS-M, 2) * 10 + MD-P(WS-M, 3)
     MOVE 223 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-I = WS-M + 3
     MOVE "acceptance feature data: offset z is the trapezoid -2 to 2 plateau 0 (type 5, min -2, max 2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-P(WS-I, 9) * 10000 + (MD-P(WS-I, 10) + 10) * 100 + MD-P(WS-I, 11) + 10
     MOVE 50812 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-I = WS-M + 4
     MOVE MD-PR(WS-I) TO WS-P
     MOVE "acceptance feature data: the filter predicate is all_of (10) of matching_blocks (0) and not (11)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PR-TYPE(WS-P) * 10000 + PR-TYPE(PR-CHILD(WS-P)) * 100 + PR-TYPE(PR-NEXT(PR-CHILD(WS-P)))
     MOVE 100011 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature data: matching_blocks air is one block index (air is block 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PR-N(PR-CHILD(WS-P)) * 10 + FD-POOL(PR-POOL(PR-CHILD(WS-P)))
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PR-CHILD(PR-NEXT(PR-CHILD(WS-P))) TO WS-P
     MOVE "acceptance feature data: the inner matching_blocks has offset (0, -1, 0) and two blocks (air, water)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PR-N(WS-P) * 100 + PR-OY(WS-P) + 10
     MOVE 209 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-FT(WS-PF) TO WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "acceptance feature data: an inline random_selector (36) has one entry and an inline no_op default placed feature" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FT-TYPE(WS-FT) * 100 + FT-B(WS-FT)
     MOVE 3601 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE FT-C(WS-FT) TO WS-PF2
     MOVE "acceptance feature data: the default is compiled in place (status 1, no modifiers, feature no_op 30)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PF-STATUS(WS-PF2) * 10000 + PF-MD-COUNT(WS-PF2) * 1000 + FT-TYPE(PF-FT(WS-PF2))
     MOVE 10030 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature data: the entry's chance 0.5 and its reference to single_poppy (a stub)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CH-F(FT-A(WS-FT)) * 10 + PF-STATUS(CH-PF(FT-A(WS-FT)))
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:bad_predicate" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: a would_survive predicate is not supported: the placed feature is status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bad_modifier" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: a noise count modifier is not supported: status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bad_feature" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: an inline feature of an unsupported type (tree) makes the placed feature status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:props" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: a block state with properties is not supported: status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:double" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: a double plant (tall_grass) is not supported: status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:no_such_feature" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: an id with no file is status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature data: a compiled or failed row is not compiled again (still 2)" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:hr_trap" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE "acceptance feature data: a trapezoid height provider with anchors above_bottom 0 and 20, plateau 6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-P(WS-M, 1) * 100000 + MD-P(WS-M, 2) * 10000 + MD-P(WS-M, 3) * 1000 + MD-P(WS-M, 4) * 100 + MD-P(WS-M, 5) * 10 + MD-P(WS-M, 6) / 10
     MOVE 562022 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:hr_const" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE PF-MD-FIRST(WS-PF) TO WS-M
     MOVE "acceptance feature data: a bare anchor object is a constant height provider (below_top 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = MD-P(WS-M, 1) * 100 + MD-P(WS-M, 3) * 10 + MD-P(WS-M, 4)
     MOVE 130 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   malformed placed features: every one is unsupported (status 2), and the compile of the next one is not disturbed
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         EVALUATE WS-I
             WHEN 1
                 MOVE "bad_modifiers" TO WS-NAME
             WHEN 2
                 MOVE "bad_preds" TO WS-NAME
             WHEN 3
                 MOVE "bad_features" TO WS-NAME
             WHEN 4
                 MOVE "bad_features2" TO WS-NAME
             WHEN 5
                 MOVE "bad_features3" TO WS-NAME
             WHEN 6
                 MOVE "bad_features4" TO WS-NAME
             WHEN 7
                 MOVE "bad_features5" TO WS-NAME
             WHEN 8
                 MOVE "bad_features6" TO WS-NAME
             WHEN 9
                 MOVE "bad_features7" TO WS-NAME
             WHEN 10
                 MOVE "bad_features8" TO WS-NAME
             WHEN 11
                 MOVE "bad_features9" TO WS-NAME
             WHEN 12
                 MOVE "bad_features10" TO WS-NAME
             WHEN 13
                 MOVE "bad_features11" TO WS-NAME
             WHEN 14
                 MOVE "bad_features12" TO WS-NAME
             WHEN 15
                 MOVE "big_sel" TO WS-NAME
             WHEN 16
                 MOVE "noplacement" TO WS-NAME
             WHEN 17
                 MOVE "nofeature" TO WS-NAME
             WHEN 18
                 MOVE "nofile_feature" TO WS-NAME
             WHEN 19
                 MOVE "ok_variants" TO WS-NAME
             WHEN 20
                 MOVE "state_id" TO WS-NAME
             WHEN 21
                 MOVE "tag_air" TO WS-NAME
             WHEN OTHER
                 MOVE "count_cap" TO WS-NAME
         END-EVALUATE
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         CALL "FD-GET-PF" USING WS-KEY WS-PF
         CALL "FD-ENSURE-PF" USING WS-PF
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance feature data: malformed or well formed variant " FUNCTION TRIM(WS-NAME) " gets its status" DELIMITED BY SIZE INTO TL-CASE
         MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
         MOVE 2 TO TL-EXPECTED-N
         IF WS-I = 19 OR WS-I = 20 OR WS-I = 21 OR WS-I = 22
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         IF WS-I = 18
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE "minecraft:nofile_feature" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     MOVE PF-FT(WS-PF) TO WS-P
     CALL "FD-ENSURE-FT" USING WS-P
     MOVE "acceptance feature data: a feature id with no file is unsupported when it is first needed (type -1)" TO TL-CASE
     MOVE FT-TYPE(WS-P) TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-ENSURE-FT" USING WS-P
     MOVE "acceptance feature data: a feature that failed is not read again" TO TL-CASE
     MOVE FT-TYPE(WS-P) TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a full table refuses the next row: the compile stays safe (each call is made with its table at the limit)
     CALL "FD-RESET"
     MOVE FD-MAX-POOL TO FD-POOL-COUNT
     CALL "FD-POOL-ADD" USING WS-ONE WS-P
     MOVE "acceptance feature data: a full pool refuses a value and flags the compile" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-P * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type": "minecraft:solid"}' TO WS-TEXT
     MOVE 26 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     MOVE FD-MAX-PR TO FD-PR-COUNT
     CALL "FD-PRED-NODE" USING JSON-DOC WS-ONE WS-P
     MOVE "acceptance feature data: a full predicate table refuses a predicate" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-P * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE FD-MAX-PV TO FD-PV-COUNT
     CALL "FD-PROV-NODE" USING JSON-DOC WS-ONE WS-P
     MOVE "acceptance feature data: a full provider table refuses a provider" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-P * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE FD-MAX-MD TO FD-MD-COUNT
     CALL "FD-MD-NODE" USING JSON-DOC WS-ONE
     MOVE "acceptance feature data: a full modifier table refuses a modifier" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FD-MD-COUNT * 10 + FD-BAD - FD-MAX-MD * 10
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE FD-MAX-FT TO FD-FT-COUNT
     MOVE 0 TO WS-P
     CALL "FD-FEAT-NODE" USING JSON-DOC WS-ONE WS-P
     MOVE "acceptance feature data: a full feature table refuses a feature" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-P * 10 + FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     MOVE '{"type": "minecraft:sequence", "features": ["minecraft:pf_poppy"]}' TO WS-TEXT
     MOVE 62 TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     MOVE FD-MAX-CH TO FD-CH-COUNT
     MOVE 0 TO WS-P
     CALL "FD-FEAT-NODE" USING JSON-DOC WS-ONE WS-P
     MOVE "acceptance feature data: a full child table refuses the children of a selector" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FD-BAD
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-RESET"
     GOBACK.
