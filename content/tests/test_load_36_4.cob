*> Test of the loader of docs/protocol/36-structures-4-scattered-and-small.md (desert pyramid, jungle temple, swamp hut, igloo, buried treasure, ruined portal, nether fossil (sections 1, 8.1, 9.1)). LOAD-36-4 USING root (PIC X(1100)), status out (CT-OK, or CT-BAD-DATA
*> with every error on standard error and nothing kept): the files of content/tests/fixtures/load-36-4 load through JSON-STRICT and
*> the shape engine (shapes.cob), each accept case is an element of its registry with the type row named, and each reject case is
*> one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-T                   PIC X(70).
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1100).
 01 WS-I                   BINARY-LONG.
 01 WS-ACCEPTS.
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:desert_pyramid".
    05 FILLER PIC X(48) VALUE "desert_pyramid".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:jungle_pyramid".
    05 FILLER PIC X(48) VALUE "jungle_temple".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:swamp_hut".
    05 FILLER PIC X(48) VALUE "swamp_hut".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:igloo".
    05 FILLER PIC X(48) VALUE "igloo".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:buried_treasure".
    05 FILLER PIC X(48) VALUE "buried_treasure".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:ruined_portal_nether".
    05 FILLER PIC X(48) VALUE "ruined_portal".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:nether_fossil".
    05 FILLER PIC X(48) VALUE "nether_fossil".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:desert_pyramids".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:buried_treasures".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:ruined_portals".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:nether_fossils".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPTS.
    05 WS-ACCEPT OCCURS 12 TIMES.
       10 WS-A-REGISTRY    PIC X(48).
       10 WS-A-KEY         PIC X(64).
       10 WS-A-TYPE        PIC X(48).
 01 WS-REJECTS.
    05 FILLER PIC X(70) VALUE "a ruined portal without setups".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a ruined portal whose setups is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":1}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup without placement".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"mossiness":0.1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose placement is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup with air_pocket_probability 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","air_pocket_probability":1.5}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup with a negative mossiness".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","mossiness":-0.1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup with mossiness 1.1".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","mossiness":1.1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose overgrown is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","overgrown":"yes"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose vines is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","vines":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose can_be_cold is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","can_be_cold":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose replace_with_blackstone is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","replace_with_blackstone":"x"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a setup whose weight is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal","spawn_overrides":{},"step":"surface'.
    05 FILLER PIC X(120) VALUE '_structures","setups":[{"placement":"underground","weight":"1"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a nether fossil without height".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:nether_fossil","biomes":"#minecraft:has_structure/nether_fossil","spawn_overrides":{},"step":"undergr'.
    05 FILLER PIC X(120) VALUE 'ound_decoration"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a desert pyramid without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:desert_pyramid","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a swamp hut without spawn_overrides".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:swamp_hut","biomes":"#minecraft:has_structure/swamp_hut","step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an igloo whose step is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#minecraft:has_structure/igloo","spawn_overrides":{},"step":2}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a buried treasure without a type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"biomes":"#minecraft:has_structure/buried_treasure","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure file that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '[]'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set with weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":0}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set with spacing 4097".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":4097,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set without salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set with frequency 2".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1,"frequency":2}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set whose frequency_reduction_method is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1,"frequency_reduction'.
    05 FILLER PIC X(120) VALUE '_method":2}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set whose locate_offset is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1,"locate_offset":"9"}'.
    05 FILLER PIC X(120) VALUE '}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set without placement".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set without structures".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
 01 WS-REJECT-TABLE REDEFINES WS-REJECTS.
    05 WS-REJECT OCCURS 26 TIMES.
       10 WS-R-LABEL       PIC X(70).
       10 WS-R-REGISTRY    PIC X(48).
       10 WS-R-BODY        PIC X(700).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-4" TO WS-DIR
     CALL "LOAD-36-4" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-4 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-4 12 elements are kept" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-A-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-4 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 1 TO WS-ROW
         END-IF
         PERFORM ASSERT-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-4 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " has type row " FUNCTION TRIM(WS-A-TYPE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 26
         MOVE WS-R-LABEL(WS-I) TO WS-T
         MOVE WS-R-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-R-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-36-4/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-36-4 2>/dev/null; rm -rf build/content-test/load-36-4; mkdir -p build/content-test/load-36-4 && cp -R content/tests/fixtures/load-36-4 build/content-test/load-36-4/t"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-36-4/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) " && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/load-36-4/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-36-4" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-4 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-4 " FUNCTION TRIM(WS-T) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
