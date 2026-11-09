*> Test of the loader LOAD-35-5 (docs/protocol/35-worldgen-features-5-water-and-surface.md). LOAD-35-5 USING root (PIC X(1100): the folder that holds data/),
*> status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load kept). Accept cases: the
*> fixture tree content/tests/fixtures/load-35-5 (23 files). Reject cases: one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-REG                 PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(2000).
 01 WS-BODY                PIC X(1500).
 01 WS-T                   PIC X(60).
 01 WS-I                   BINARY-LONG.
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-ACCEPT.
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:lake_lava".
    05 FILLER PIC X(48) VALUE "lake".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:spring_water".
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:spring_nether_closed".
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:ice_patch".
    05 FILLER PIC X(48) VALUE "disk".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:forest_rock".
    05 FILLER PIC X(48) VALUE "block_blob".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:blackstone_blobs".
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:freeze_top_layer".
    05 FILLER PIC X(48) VALUE "freeze_top_layer".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:iceberg_packed".
    05 FILLER PIC X(48) VALUE "iceberg".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:blue_ice".
    05 FILLER PIC X(48) VALUE "blue_ice".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:fill".
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:pile_ice".
    05 FILLER PIC X(48) VALUE "block_pile".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:coral_tree_a".
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:coral_claw_a".
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:underwater_magma".
    05 FILLER PIC X(48) VALUE "underwater_magma".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:ice_spike".
    05 FILLER PIC X(48) VALUE "spike".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:bonus_chest".
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:desert_well".
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:seq".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:pick".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:seagrass_short".
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:sea_pickle".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:kelp".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:desert_well_part".
    05 FILLER PIC X(48) VALUE "template".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPT.
    05 WS-A OCCURS 23 TIMES.
       10 WS-A-REG     PIC X(48).
       10 WS-A-KEY     PIC X(64).
       10 WS-A-TYPE    PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a feature without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""radius"":1}".
    05 FILLER PIC X(60) VALUE "a feature that is no object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "[]".
    05 FILLER PIC X(60) VALUE "a lake without a barrier".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:lake"",""fluid"":{""type"":""a:b""},""can_place_feature"":{""type"":""a:b" &
        """},""can_replace_with_air_or_fluid"":{""type"":""a:b""},""can_replace_with_barrier"":{""t" &
        "ype"":""a:b""}}".
    05 FILLER PIC X(60) VALUE "a lake fluid without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:lake"",""fluid"":{},""barrier"":{""type"":""a:b""},""can_place_feature""" &
        ":{""type"":""a:b""},""can_replace_with_air_or_fluid"":{""type"":""a:b""},""can_replace_with" &
        "_barrier"":{""type"":""a:b""}}".
    05 FILLER PIC X(60) VALUE "a spring state without a Name".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spring_feature"",""state"":{},""valid_blocks"":""minecraft:stone""}".
    05 FILLER PIC X(60) VALUE "a spring valid_blocks that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spring_feature"",""state"":{""Name"":""minecraft:lava""},""valid_bloc" &
        "ks"":3}".
    05 FILLER PIC X(60) VALUE "a spring valid_blocks tag that is no identifier".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spring_feature"",""state"":{""Name"":""minecraft:lava""},""valid_bloc" &
        "ks"":""#Bad Id""}".
    05 FILLER PIC X(60) VALUE "a spring requires_block_below that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spring_feature"",""state"":{""Name"":""minecraft:lava""},""valid_bloc" &
        "ks"":""a:b"",""requires_block_below"":1}".
    05 FILLER PIC X(60) VALUE "a spring rock_count that is fractional".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spring_feature"",""state"":{""Name"":""minecraft:lava""},""valid_bloc" &
        "ks"":""a:b"",""rock_count"":4.5}".
    05 FILLER PIC X(60) VALUE "a disk without a radius".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:disk"",""state_provider"":{""type"":""a:b""},""target"":{""type"":""a:b""}" &
        ",""half_height"":1}".
    05 FILLER PIC X(60) VALUE "a disk half_height above 4".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:disk"",""state_provider"":{""type"":""a:b""},""target"":{""type"":""a:b""}" &
        ",""radius"":2,""half_height"":5}".
    05 FILLER PIC X(60) VALUE "a disk half_height below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:disk"",""state_provider"":{""type"":""a:b""},""target"":{""type"":""a:b""}" &
        ",""radius"":2,""half_height"":-1}".
    05 FILLER PIC X(60) VALUE "a disk radius that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:disk"",""state_provider"":{""type"":""a:b""},""target"":{""type"":""a:b""}" &
        ",""radius"":""2"",""half_height"":1}".
    05 FILLER PIC X(60) VALUE "a block_blob without can_place_on".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:block_blob"",""state"":{""Name"":""minecraft:stone""}}".
    05 FILLER PIC X(60) VALUE "a netherrack_replace_blobs target that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:netherrack_replace_blobs"",""target"":""minecraft:netherrack"",""st" &
        "ate"":{""Name"":""minecraft:stone""},""radius"":2}".
    05 FILLER PIC X(60) VALUE "an iceberg without a state".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:iceberg""}".
    05 FILLER PIC X(60) VALUE "a fill_layer height above 4064".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fill_layer"",""height"":4065,""state"":{""Name"":""minecraft:stone""}}".
    05 FILLER PIC X(60) VALUE "a fill_layer height below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:fill_layer"",""height"":-1,""state"":{""Name"":""minecraft:stone""}}".
    05 FILLER PIC X(60) VALUE "a coral_tree feature that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:coral_tree"",""feature"":5}".
    05 FILLER PIC X(60) VALUE "a coral_claw feature object that is bad".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:coral_claw"",""feature"":{""feature"":3,""placement"":[]}}".
    05 FILLER PIC X(60) VALUE "an underwater_magma floor_search_range above 512".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:underwater_magma"",""floor_search_range"":513,""placement_probabi" &
        "lity_per_valid_position"":0.5,""placement_radius_around_floor"":1}".
    05 FILLER PIC X(60) VALUE "an underwater_magma radius above 64".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:underwater_magma"",""floor_search_range"":5,""placement_probabili" &
        "ty_per_valid_position"":0.5,""placement_radius_around_floor"":65}".
    05 FILLER PIC X(60) VALUE "a spike without can_replace".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:spike"",""state"":{""Name"":""minecraft:stone""},""can_place_on"":{""ty" &
        "pe"":""a:b""}}".
    05 FILLER PIC X(60) VALUE "an overlay features that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:overlay"",""features"":1}".
    05 FILLER PIC X(60) VALUE "a sequence entry that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:sequence"",""features"":[1]}".
    05 FILLER PIC X(60) VALUE "a weighted selector entry without a weight".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:weighted_random_selector"",""features"":[{""data"":""a:b""}]}".
    05 FILLER PIC X(60) VALUE "a weighted selector weight below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:weighted_random_selector"",""features"":[{""data"":""a:b"",""weight"":" &
        "-1}]}".
    05 FILLER PIC X(60) VALUE "a simple_block without to_place".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:simple_block""}".
    05 FILLER PIC X(60) VALUE "a block_column direction not listed".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:block_column"",""layers"":[],""direction"":""sideways"",""allowed_pla" &
        "cement"":{""type"":""a:b""},""prioritize_tip"":true}".
    05 FILLER PIC X(60) VALUE "a block_column layer without a provider".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:block_column"",""layers"":[{""height"":1}],""direction"":""up"",""allow" &
        "ed_placement"":{""type"":""a:b""},""prioritize_tip"":true}".
    05 FILLER PIC X(60) VALUE "a block_column layer height that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:block_column"",""layers"":[{""height"":""1"",""provider"":{""type"":""a:b" &
        """}}],""direction"":""up"",""allowed_placement"":{""type"":""a:b""},""prioritize_tip"":true}".
    05 FILLER PIC X(60) VALUE "a block_column prioritize_tip that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:block_column"",""layers"":[],""direction"":""up"",""allowed_placement" &
        """:{""type"":""a:b""},""prioritize_tip"":""yes""}".
    05 FILLER PIC X(60) VALUE "a template id that is no identifier".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""Bad Id""},""weight"":1}]}".
    05 FILLER PIC X(60) VALUE "a template without templates".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template""}".
    05 FILLER PIC X(60) VALUE "a template rotations that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""a:b"",""rotations"":{}},""w" &
        "eight"":1}]}".
    05 FILLER PIC X(60) VALUE "a file that is no JSON".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:blue_ice"",}".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 36 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-REG      PIC X(48).
       10 WS-CASE-BODY     PIC X(1500).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-5" TO WS-DIR
     CALL "LOAD-35-5" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-5 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-5 element count" TO TL-CASE
     MOVE 23 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         MOVE WS-A-REG(WS-I) TO WS-REG
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 35-5 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         PERFORM ASSERT-NUM
         IF WS-ROW = 0
             MOVE 1 TO WS-ROW
         END-IF
         MOVE SPACES TO WS-WANT-TYPE
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO WS-WANT-TYPE
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 35-5 " FUNCTION TRIM(WS-KEY) " has the type it names" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE WS-WANT-TYPE TO TL-OBSERVED
         IF WS-A-TYPE(WS-I) = SPACES AND SH-E-TYPE(WS-ROW) = 0
             MOVE SPACES TO TL-EXPECTED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-REG(WS-I) TO WS-REG
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-35-5/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-35-5 2>/dev/null; rm -rf build/content-test/load-35-5; mkdir -p build/content-test/load-35-5 && cp -R content/tests/fixtures/load-35-5 build/content-test/load-35-5/t && mkdir -p build/content-test/load-35-5/t/data/minecraft/" FUNCTION TRIM(WS-REG) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-5/t/data/minecraft/" FUNCTION TRIM(WS-REG) "/bad.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-5" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-5 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-5 " FUNCTION TRIM(WS-T) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
