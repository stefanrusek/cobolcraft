*> Test of the loader of docs/protocol/36-structures-1-model-placement-starts.md (structures: model, placement, starts (sections 2 and 3)). LOAD-36-1 USING root (PIC X(1100)), status out (CT-OK, or CT-BAD-DATA
*> with every error on standard error and nothing kept): the files of content/tests/fixtures/load-36-1 load through JSON-STRICT and
*> the shape engine (shapes.cob), each accept case is an element of its registry with the type row named, and each reject case is
*> one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-1.
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
    05 FILLER PIC X(64) VALUE "minecraft:buried_treasure".
    05 FILLER PIC X(48) VALUE "buried_treasure".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:swamp_hut".
    05 FILLER PIC X(48) VALUE "swamp_hut".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:fortress".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:stronghold".
    05 FILLER PIC X(48) VALUE "stronghold".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:desert_pyramids".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:buried_treasures".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:strongholds".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:origin".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:excluding".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:inline".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPTS.
    05 WS-ACCEPT OCCURS 11 TIMES.
       10 WS-A-REGISTRY    PIC X(48).
       10 WS-A-KEY         PIC X(64).
       10 WS-A-TYPE        PIC X(48).
 01 WS-REJECTS.
    05 FILLER PIC X(70) VALUE "a structure without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure without a step".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#a:b","spawn_overrides":{}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure without spawn_overrides".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#a:b","step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure without a type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"biomes":"#a:b","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure of an unknown type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:nope","biomes":"#a:b","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure whose step is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#a:b","spawn_overrides":{},"step":1}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure whose biomes is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":3,"spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure whose spawn_overrides is an array".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#a:b","spawn_overrides":[],"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure whose terrain_adaptation is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:igloo","biomes":"#a:b","spawn_overrides":{},"step":"surface_structures","terrain_adaptation":2}'.
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
    05 FILLER PIC X(70) VALUE "a structure set without a placement".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure set without structures".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure set whose structures is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":1,"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a selection entry without a structure".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a selection entry with weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":0}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a selection entry without a weight".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b"}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a selection entry with a bad structure id".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"A b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread without spacing".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread without separation".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread without salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE '}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with spacing 4097".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":4097,"separation"'.
    05 FILLER PIC X(120) VALUE ':8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with separation -1".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":-'.
    05 FILLER PIC X(120) VALUE '1,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with a negative salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":-1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with an unknown spread_type".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"spread_type":"bogus"}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with frequency 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"frequency":1.5}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread whose salt is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":"1"}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread whose locate_offset is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"locate_offset":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an exclusion zone with chunk_count 17".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"exclusion_zone":{"other_set":"a:b","chunk_count":17}}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an exclusion zone with chunk_count 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"exclusion_zone":{"other_set":"a:b","chunk_count":0}}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an exclusion zone without other_set".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1,"exclusion_zone":{"chunk_count":2}}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings without count".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3'.
    05 FILLER PIC X(120) VALUE ',"preferred_biomes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with count 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3'.
    05 FILLER PIC X(120) VALUE ',"count":0,"preferred_biomes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with count 4096".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3'.
    05 FILLER PIC X(120) VALUE ',"count":4096,"preferred_biomes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with distance 1024".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":1024,"spread"'.
    05 FILLER PIC X(120) VALUE ':3,"count":128,"preferred_biomes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with spread -1".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":-'.
    05 FILLER PIC X(120) VALUE '1,"count":128,"preferred_biomes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings without preferred_biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3'.
    05 FILLER PIC X(120) VALUE ',"count":128,"salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a structure set whose placement has no type".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":1}],"placement":{"spacing":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
 01 WS-REJECT-TABLE REDEFINES WS-REJECTS.
    05 WS-REJECT OCCURS 37 TIMES.
       10 WS-R-LABEL       PIC X(70).
       10 WS-R-REGISTRY    PIC X(48).
       10 WS-R-BODY        PIC X(700).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-1" TO WS-DIR
     CALL "LOAD-36-1" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-1 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-1 11 elements are kept" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-A-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-1 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 1 TO WS-ROW
         END-IF
         PERFORM ASSERT-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-1 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " has type row " FUNCTION TRIM(WS-A-TYPE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         MOVE WS-R-LABEL(WS-I) TO WS-T
         MOVE WS-R-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-R-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-36-1/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-36-1 2>/dev/null; rm -rf build/content-test/load-36-1; mkdir -p build/content-test/load-36-1 && cp -R content/tests/fixtures/load-36-1 build/content-test/load-36-1/t"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-36-1/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) " && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/load-36-1/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-36-1" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-1 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-1 " FUNCTION TRIM(WS-T) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
