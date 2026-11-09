*> Test of the loader LOAD-35-7 (docs/protocol/35-worldgen-features-7-nether-end-misc.md). LOAD-35-7 USING root (PIC X(1100): the folder that holds data/),
*> status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load kept). Accept cases: the
*> fixture tree content/tests/fixtures/load-35-7 (16 files). Reject cases: one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-35-7.
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
    05 FILLER PIC X(64) VALUE "minecraft:delta".
    05 FILLER PIC X(48) VALUE "delta_feature".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:basalt_columns_small".
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_spike".
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_spike_listed".
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:chorus_plant".
    05 FILLER PIC X(48) VALUE "chorus_plant".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_island".
    05 FILLER PIC X(48) VALUE "end_island".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_platform".
    05 FILLER PIC X(48) VALUE "end_platform".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_podium_active".
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_podium_inactive".
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_gateway_return".
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:end_gateway_delayed".
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:void_start_platform".
    05 FILLER PIC X(48) VALUE "void_start_platform".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:replace".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:bonus_chest".
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:template_a".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(64) VALUE "minecraft:basalt_pillar".
    05 FILLER PIC X(48) VALUE SPACES.
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPT.
    05 WS-A OCCURS 16 TIMES.
       10 WS-A-REG     PIC X(48).
       10 WS-A-KEY     PIC X(64).
       10 WS-A-TYPE    PIC X(48).
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a feature without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""rim"":{""Name"":""a:b""}}".
    05 FILLER PIC X(60) VALUE "a delta_feature without rim".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""contents"":{""Name"":""minecraft:lava""},""size"":{""" &
        "type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""rim_size"":3}".
    05 FILLER PIC X(60) VALUE "a delta_feature without contents".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""rim"":{""Name"":""minecraft:magma_block""},""size"":" &
        "{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""rim_size"":3}".
    05 FILLER PIC X(60) VALUE "a delta_feature rim state without Name".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""contents"":{""Name"":""minecraft:lava""},""rim"":{}," &
        """size"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""rim_siz" &
        "e"":3}".
    05 FILLER PIC X(60) VALUE "a delta_feature contents that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""contents"":""minecraft:lava"",""rim"":{""Name"":""min" &
        "ecraft:magma_block""},""size"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_i" &
        "nclusive"":8},""rim_size"":3}".
    05 FILLER PIC X(60) VALUE "a delta_feature size that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""contents"":{""Name"":""minecraft:lava""},""rim"":{""N" &
        "ame"":""minecraft:magma_block""},""size"":""3"",""rim_size"":3}".
    05 FILLER PIC X(60) VALUE "a delta_feature without rim_size".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:delta_feature"",""contents"":{""Name"":""minecraft:lava""},""rim"":{""N" &
        "ame"":""minecraft:magma_block""},""size"":{""type"":""minecraft:uniform"",""min_inclusive""" &
        ":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster without continue_through".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""can_replace"":{""type"":""minecraft:matching_blocks"",""blocks" &
        """:""minecraft:air""},""cannot_place_on"":""#minecraft:lava"",""cluster_reach"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_count"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""height" &
        """:{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster without block".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""continue_through"":{""type"":""minecraft" &
        ":matching_blocks"",""blocks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:mat" &
        "ching_blocks"",""blocks"":""minecraft:air""},""cannot_place_on"":""#minecraft:lava"",""clu" &
        "ster_reach"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""co" &
        "lumn_count"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""co" &
        "lumn_reach"":2,""height"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclus" &
        "ive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster predicate without a type".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{},""cannot_place_on"":""#minecraft:lava"",""cl" &
        "uster_reach"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""c" &
        "olumn_count"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""c" &
        "olumn_reach"":2,""height"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclu" &
        "sive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster cannot_place_on that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:matching_blocks"",""block" &
        "s"":""minecraft:air""},""cannot_place_on"":1,""cluster_reach"":{""type"":""minecraft:unifo" &
        "rm"",""min_inclusive"":2,""max_inclusive"":8},""column_count"":{""type"":""minecraft:unifo" &
        "rm"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""height"":{""type"":""mine" &
        "craft:uniform"",""min_inclusive"":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster cannot_place_on tag that is invalid".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:matching_blocks"",""block" &
        "s"":""minecraft:air""},""cannot_place_on"":""#Bad Id"",""cluster_reach"":{""type"":""minecra" &
        "ft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_count"":{""type"":""minecra" &
        "ft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""height"":{""typ" &
        "e"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster height that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:matching_blocks"",""block" &
        "s"":""minecraft:air""},""cannot_place_on"":""#minecraft:lava"",""cluster_reach"":{""type"":" &
        """minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_count"":{""type"":" &
        """minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""heigh" &
        "t"":""1""}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster without column_count".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:matching_blocks"",""block" &
        "s"":""minecraft:air""},""cannot_place_on"":""#minecraft:lava"",""cluster_reach"":{""type"":" &
        """minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""heigh" &
        "t"":{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "a stepped_column_cluster without cluster_reach".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:stepped_column_cluster"",""block"":{""id"":""minecraft:basalt"",""pro" &
        "perties"":{""axis"":""y""}},""continue_through"":{""type"":""minecraft:matching_blocks"",""b" &
        "locks"":""minecraft:air""},""can_replace"":{""type"":""minecraft:matching_blocks"",""block" &
        "s"":""minecraft:air""},""cannot_place_on"":""#minecraft:lava"",""column_count"":{""type"":""" &
        "minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8},""column_reach"":2,""height" &
        """:{""type"":""minecraft:uniform"",""min_inclusive"":2,""max_inclusive"":8}}".
    05 FILLER PIC X(60) VALUE "an end_spike without spikes".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike""}".
    05 FILLER PIC X(60) VALUE "an end_spike spikes that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":{}}".
    05 FILLER PIC X(60) VALUE "an end_spike spike centerX that is fractional".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[{""centerX"":1.5}]}".
    05 FILLER PIC X(60) VALUE "an end_spike spike radius that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[{""radius"":""2""}]}".
    05 FILLER PIC X(60) VALUE "an end_spike spike guarded that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[{""guarded"":1}]}".
    05 FILLER PIC X(60) VALUE "an end_spike spike that is no object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[3]}".
    05 FILLER PIC X(60) VALUE "an end_spike crystal_invulnerable that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[],""crystal_invulnerable"":1}".
    05 FILLER PIC X(60) VALUE "an end_spike crystal_beam_target that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_spike"",""spikes"":[],""crystal_beam_target"":{}}".
    05 FILLER PIC X(60) VALUE "an end_podium active that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_podium"",""active"":""yes""}".
    05 FILLER PIC X(60) VALUE "an end_gateway without exact".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_gateway"",""exit"":[100,50,0]}".
    05 FILLER PIC X(60) VALUE "an end_gateway exact that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_gateway"",""exact"":1}".
    05 FILLER PIC X(60) VALUE "an end_gateway exit that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_gateway"",""exact"":true,""exit"":{}}".
    05 FILLER PIC X(60) VALUE "a replace_single_block without targets".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:replace_single_block""}".
    05 FILLER PIC X(60) VALUE "a replace_single_block targets that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:replace_single_block"",""targets"":{}}".
    05 FILLER PIC X(60) VALUE "a replace_single_block target that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:replace_single_block"",""targets"":[{""target"":[],""state"":{""Name""" &
        ":""a:b""}}]}".
    05 FILLER PIC X(60) VALUE "a replace_single_block replacement without state".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:replace_single_block"",""targets"":[{""target"":{}}]}".
    05 FILLER PIC X(60) VALUE "a replace_single_block replacement state without Name".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:replace_single_block"",""targets"":[{""target"":{},""state"":{}}]}".
    05 FILLER PIC X(60) VALUE "a template without templates".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template""}".
    05 FILLER PIC X(60) VALUE "a template entry id that is invalid".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""Bad Id""},""weight"":1}]}".
    05 FILLER PIC X(60) VALUE "a template entry weight below 0".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:template"",""templates"":[{""data"":{""id"":""a:b""},""weight"":-1}]}".
    05 FILLER PIC X(60) VALUE "a file that is no JSON".
    05 FILLER PIC X(48) VALUE "worldgen/feature".
    05 FILLER PIC X(1500) VALUE "{""type"":""minecraft:end_island"",}".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 36 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-REG      PIC X(48).
       10 WS-CASE-BODY     PIC X(1500).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-35-7" TO WS-DIR
     CALL "LOAD-35-7" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 35-7 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 35-7 element count" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-A-REG(WS-I) TO WS-REG
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 35-7 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
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
         STRING "acceptance US12 load 35-7 " FUNCTION TRIM(WS-KEY) " has the type it names" DELIMITED BY SIZE INTO TL-CASE
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
     MOVE "build/content-test/load-35-7/t" TO WS-DIR
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-35-7 2>/dev/null; rm -rf build/content-test/load-35-7; mkdir -p build/content-test/load-35-7 && cp -R content/tests/fixtures/load-35-7 build/content-test/load-35-7/t && mkdir -p build/content-test/load-35-7/t/data/minecraft/" FUNCTION TRIM(WS-REG) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/load-35-7/t/data/minecraft/" FUNCTION TRIM(WS-REG) "/bad.json" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-35-7" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-7 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 35-7 " FUNCTION TRIM(WS-T) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
