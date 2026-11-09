*> Test of the loader of docs/protocol/36-structures-5-mineshaft-stronghold.md (mineshaft and stronghold (section 1 data table)). LOAD-36-5 USING root (PIC X(1100)), status out (CT-OK, or CT-BAD-DATA
*> with every error on standard error and nothing kept): the files of content/tests/fixtures/load-36-5 load through JSON-STRICT and
*> the shape engine (shapes.cob), each accept case is an element of its registry with the type row named, and each reject case is
*> one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-5.
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
    05 FILLER PIC X(64) VALUE "minecraft:mineshaft".
    05 FILLER PIC X(48) VALUE "mineshaft".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:mineshaft_mesa".
    05 FILLER PIC X(48) VALUE "mineshaft".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:stronghold".
    05 FILLER PIC X(48) VALUE "stronghold".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:mineshafts".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:strongholds".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPTS.
    05 WS-ACCEPT OCCURS 5 TIMES.
       10 WS-A-REGISTRY    PIC X(48).
       10 WS-A-KEY         PIC X(64).
       10 WS-A-TYPE        PIC X(48).
 01 WS-REJECTS.
    05 FILLER PIC X(70) VALUE "a mineshaft without mineshaft_type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","biomes":"#a:b","spawn_overrides":{},"step":"underground_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a mineshaft of an unknown mineshaft_type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","mineshaft_type":"deep","biomes":"#a:b","spawn_overrides":{},"step":"underground_structure'.
    05 FILLER PIC X(120) VALUE 's"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a mineshaft whose mineshaft_type is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","mineshaft_type":1,"biomes":"#a:b","spawn_overrides":{},"step":"underground_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a mineshaft without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","mineshaft_type":"normal","spawn_overrides":{},"step":"underground_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a mineshaft without a step".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","mineshaft_type":"normal","biomes":"#a:b","spawn_overrides":{}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a mineshaft without spawn_overrides".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:mineshaft","mineshaft_type":"normal","biomes":"#a:b","step":"underground_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a stronghold whose terrain_adaptation is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:stronghold","biomes":"#a:b","spawn_overrides":{},"step":"surface_structures","terrain_adaptation":1}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a stronghold without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:stronghold","spawn_overrides":{},"step":"surface_structures"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a stronghold whose biomes is an object".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:stronghold","biomes":{"a":1},"spawn_overrides":{},"step":"surface_structures"}'.
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
    05 FILLER PIC X(70) VALUE "a set with a mineshaft of weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"a:b","weight":0}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a set with a bad structure id".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[{"structure":"A:b","weight":1}],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8'.
    05 FILLER PIC X(120) VALUE ',"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with separation 4097".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":4097,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with a negative spacing".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":-1,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with frequency -0.1".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1,"frequency":-0.1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "random_spread with an unknown spread_type".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1,"spread_type":"round'.
    05 FILLER PIC X(120) VALUE '"}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings without preferred_biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3,"count":128,"salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings without distance".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","spread":3,"count":128,"preferred_biomes":"#a:b","salt'.
    05 FILLER PIC X(120) VALUE '":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with count 4096".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3,"count":4096,"preferred_biome'.
    05 FILLER PIC X(120) VALUE 's":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with count 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3,"count":0,"preferred_biomes":'.
    05 FILLER PIC X(120) VALUE '"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with spread 1024".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":1024,"count":128,"preferred_bio'.
    05 FILLER PIC X(120) VALUE 'mes":"#a:b","salt":0}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "concentric_rings with a negative salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":[],"placement":{"type":"minecraft:concentric_rings","distance":32,"spread":3,"count":128,"preferred_biomes'.
    05 FILLER PIC X(120) VALUE '":"#a:b","salt":-1}}'.
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
    05 FILLER PIC X(70) VALUE "a set whose structures is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(120) VALUE '{"structures":{},"placement":{"type":"minecraft:random_spread","spacing":32,"separation":8,"salt":1}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
 01 WS-REJECT-TABLE REDEFINES WS-REJECTS.
    05 WS-REJECT OCCURS 24 TIMES.
       10 WS-R-LABEL       PIC X(70).
       10 WS-R-REGISTRY    PIC X(48).
       10 WS-R-BODY        PIC X(700).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-5" TO WS-DIR
     CALL "LOAD-36-5" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-5 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-5 5 elements are kept" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-A-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-5 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 1 TO WS-ROW
         END-IF
         PERFORM ASSERT-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-5 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " has type row " FUNCTION TRIM(WS-A-TYPE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-R-LABEL(WS-I) TO WS-T
         MOVE WS-R-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-R-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-36-5/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-36-5 2>/dev/null; rm -rf build/content-test/load-36-5; mkdir -p build/content-test/load-36-5 && cp -R content/tests/fixtures/load-36-5 build/content-test/load-36-5/t"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-36-5/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) " && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/load-36-5/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-36-5" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-5 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-5 " FUNCTION TRIM(WS-T) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
