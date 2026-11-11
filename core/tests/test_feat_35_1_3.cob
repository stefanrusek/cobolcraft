*> Acceptance test of docs/protocol/35-worldgen-features-1 section 3 (type registries used by features): the sizes of the 12 type registries and the ids (registration order) of their first and last and selected entries.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-HM                  PIC X(32).
 01 WS-TEXT                PIC X(60).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 has 58 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 58 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 has 18 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 3 has 16 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 16 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 4 has 10 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 5 has 8 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 8 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 6 has 4 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 7 has 6 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 8 has 10 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 9 has 12 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 10 has 1 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 11 has 11 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 12 has 2 entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "bamboo" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 name bamboo is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "weighted_random_selector" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 name weighted_random_selector is id 57" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 57 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "ore" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 name ore is id 31" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 31 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "delta_feature" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 name delta_feature is id 9" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "scattered_ore" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 1 name scattered_ore is id 39" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 39 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE "block_predicate_filter" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 name block_predicate_filter is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE "fixed_placement" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 name fixed_placement is id 17" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 17 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE "cuboid" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 name cuboid is id 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE "in_square" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 name in_square is id 14" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 14 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE "biome" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 2 name biome is id 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE "matching_blocks" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 3 name matching_blocks is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE "volume_match" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 3 name volume_match is id 15" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 15 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE "copy_properties" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 4 name copy_properties is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE "weighted" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 4 name weighted is id 9" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE "constant" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 5 name constant is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE "trapezoid" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 5 name trapezoid is id 7" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-A
     MOVE "weighted_list" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 7 name weighted_list is id 5" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-A
     MOVE "poplar_trunk_placer" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 8 name poplar_trunk_placer is id 9" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 9 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     MOVE "jungle_foliage_placer" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 9 name jungle_foliage_placer is id 6" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-A
     MOVE "mangrove_root_placer" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 10 name mangrove_root_placer is id 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-A
     MOVE "attached_to_logs" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: registry 11 name attached_to_logs is id 10" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-A
     MOVE "three_layers_feature_size" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: feature size type three_layers_feature_size is id 1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "cuboid" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§3 Type registries used by features: a name of another registry is unknown (cuboid is not a feature type)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
