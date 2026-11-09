*> Test of the loader of docs/protocol/38-end.md (T0275; the End). LOAD-38 USING root (PIC X(1100): the folder that holds
*> data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load stays): the files of
*> the End are the dimension type the_end, noise settings end, surface rule end, density functions end/*, the biomes
*> (carvers none, 11 feature steps) through the loaders of phase 22 (WG store), and through the shape engine (shapes.cob) the
*> worldgen/feature types of section 8 (end_spike, end_platform, end_island, end_gateway, chorus_plant, end_podium), the placed
*> features with their placement modifiers, the structure end_city (section 10, settings of 36 section 3.1) and the structure set
*> end_cities (36 section 3.2 and 3.3). Fixture tree content/tests/fixtures/load-38; each reject case copies a file of
*> content/tests/fixtures/load-38-bad into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-38.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTWORLDGEN.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(64).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-T                   PIC X(50).
 01 WS-PATH                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC 99.
 01 WS-CASES.
    05 FILLER PIC X(50) VALUE "a dimension type of height 100".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "noise settings without a noise block".
    05 FILLER PIC X(48) VALUE "worldgen/noise_settings/bad.json".
    05 FILLER PIC X(50) VALUE "a surface rule of an unknown type".
    05 FILLER PIC X(48) VALUE "worldgen/material_rule/bad.json".
    05 FILLER PIC X(50) VALUE "a density function of an unknown type".
    05 FILLER PIC X(48) VALUE "worldgen/density_function/end/bad.json".
    05 FILLER PIC X(50) VALUE "a biome that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/biome/bad.json".
    05 FILLER PIC X(50) VALUE "an end gateway without exact".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end gateway whose exact is a string".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end gateway whose exit is an object".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end podium whose active is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end spike without spikes".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end spike whose crystal flag is a number".
    05 FILLER PIC X(48) VALUE "worldgen/feature/bad.json".
    05 FILLER PIC X(50) VALUE "a feature file with a bad identifier".
    05 FILLER PIC X(48) VALUE "worldgen/feature/Bad.json".
    05 FILLER PIC X(50) VALUE "a placed feature without placement".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "a placed feature without feature".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "a placed feature whose feature is a bad id".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "a modifier without a type".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "rarity_filter chance 0".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "rarity_filter chance 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "rarity_filter without chance".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "count without count".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "count that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "a uniform count without max".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "heightmap that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "height_range without height".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "offset without y".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "fixed_placement positions that is an object".
    05 FILLER PIC X(48) VALUE "worldgen/placed_feature/bad.json".
    05 FILLER PIC X(50) VALUE "an end city without step".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "an end city without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "an end city whose spawn_overrides is an array".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "an end city whose step is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "an end city whose terrain_adaptation is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "an end city whose biomes is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure/bad.json".
    05 FILLER PIC X(50) VALUE "a structure set without structures".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "a structure set without placement".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "a selection of weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "a selection without structure".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "a placement without type".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread spacing 5000".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread without separation".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread without salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread negative salt".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread spread_type quadratic".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
    05 FILLER PIC X(50) VALUE "random_spread frequency 2".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set/bad.json".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 43 TIMES.
       10 WS-CASE-LABEL    PIC X(50).
       10 WS-CASE-PATH     PIC X(48).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-38" TO WS-DIR
     CALL "LOAD-38" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 38 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 38 seven worldgen functions (type, settings, rule, 2 densities, 2 biomes)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 38 fifteen shape elements (8 features, 5 placed, 1 structure, 1 set)" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/feature" TO WS-REGISTRY
     MOVE "minecraft:end_gateway_return" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     IF WS-ROW = 0
         MOVE 1 TO WS-ROW
     END-IF
     MOVE "acceptance US12 load 38 end_gateway_return is of type end_gateway" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "end_gateway" TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "worldgen/structure" TO WS-REGISTRY
     MOVE "minecraft:end_city" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     IF WS-ROW = 0
         MOVE 1 TO WS-ROW
     END-IF
     MOVE "acceptance US12 load 38 end_city is of type end_city" TO TL-CASE
     MOVE "end_city" TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "worldgen/placed_feature" TO WS-REGISTRY
     MOVE "minecraft:chorus_plant" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "acceptance US12 load 38 the placed feature chorus_plant is there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 43
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-38/t" TO WS-DIR
     MOVE WS-I TO WS-N-TEXT
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-38 2>/dev/null; rm -rf build/content-test/load-38; "
         "mkdir -p build/content-test/load-38 && cp -R content/tests/fixtures/load-38 build/content-test/load-38/t && "
         "cp content/tests/fixtures/load-38-bad/" WS-N-TEXT ".json build/content-test/load-38/t/data/minecraft/"
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-38" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 38 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 38 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = WG-COUNT(WGK-FUNCTION) + SH-ELEMENT-COUNT
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
