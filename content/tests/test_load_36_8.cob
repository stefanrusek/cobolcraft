*> Test of the loader of docs/protocol/36-structures-8-nether-and-end.md (T0259/T0260): LOAD-36-8 USING root (PIC X(1100)), status out. The fixture tree content/tests/fixtures/load-36-8 holds the
*> documented data pack files of the part (7 elements: worldgen/structure, worldgen/structure_set, worldgen/template_pool); each reject case copies one bad file of content/tests/fixtures/load-36-8/bad into
*> a fresh copy of the tree and the whole load is CT-BAD-DATA with nothing left loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-LABEL               PIC X(70).
 01 WS-NAME                PIC X(40).
 01 WS-FILE                PIC X(40).
 01 WS-DEST                PIC X(40).
 01 WS-COMMAND             PIC X(600).
 01 WS-FINDS.
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:fortress".
    05 FILLER PIC X(48) VALUE "fortress".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:end_city".
    05 FILLER PIC X(48) VALUE "end_city".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:bastion_remnant".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:nether_complexes".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:end_cities".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(112) VALUE "minecraft:bastion/starts".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(112) VALUE "minecraft:empty".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-FIND-TABLE REDEFINES WS-FINDS.
    05 WS-FIND OCCURS 7 TIMES.
       10 WS-F-REGISTRY   PIC X(48).
       10 WS-F-KEY        PIC X(112).
       10 WS-F-TYPE       PIC X(48).
 01 WS-BADS.
    05 FILLER PIC X(40) VALUE "a fortress without biomes".
    05 FILLER PIC X(40) VALUE "fort-no-biomes.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "fortress spawn_overrides that is a numbe".
    05 FILLER PIC X(40) VALUE "fort-so-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an end city without step".
    05 FILLER PIC X(40) VALUE "end-no-step.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a jigsaw without start_pool".
    05 FILLER PIC X(40) VALUE "jig-no-pool.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a start_pool that is a number".
    05 FILLER PIC X(40) VALUE "jig-pool-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a start_pool that is a bad id".
    05 FILLER PIC X(40) VALUE "jig-pool-bad-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "size above 20".
    05 FILLER PIC X(40) VALUE "jig-size-21.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a negative size".
    05 FILLER PIC X(40) VALUE "jig-size-neg.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a size that is a string".
    05 FILLER PIC X(40) VALUE "jig-size-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a jigsaw without use_expansion_hack".
    05 FILLER PIC X(40) VALUE "jig-no-hack.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a jigsaw without start_height".
    05 FILLER PIC X(40) VALUE "jig-no-height.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a start_height that is an array".
    05 FILLER PIC X(40) VALUE "jig-height-array.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a jigsaw without max_distance_from_cente".
    05 FILLER PIC X(40) VALUE "jig-no-mdc.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a heightmap that is a number".
    05 FILLER PIC X(40) VALUE "jig-heightmap-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a liquid_settings value not listed".
    05 FILLER PIC X(40) VALUE "jig-liquid.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a start_jigsaw_name that is a bad id".
    05 FILLER PIC X(40) VALUE "jig-start-jigsaw-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "pool_aliases that is an object".
    05 FILLER PIC X(40) VALUE "jig-aliases-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an alias binding without type".
    05 FILLER PIC X(40) VALUE "jig-alias-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a direct alias without target".
    05 FILLER PIC X(40) VALUE "jig-alias-direct-no-target.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a random alias target of weight 0".
    05 FILLER PIC X(40) VALUE "jig-alias-random-weight.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "random_group groups that is an object".
    05 FILLER PIC X(40) VALUE "jig-alias-group-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a pool without fallback".
    05 FILLER PIC X(40) VALUE "pool-no-fallback.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool without elements".
    05 FILLER PIC X(40) VALUE "pool-no-elements.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool entry of weight 151".
    05 FILLER PIC X(40) VALUE "pool-weight-151.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool entry of weight 0".
    05 FILLER PIC X(40) VALUE "pool-weight-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool entry without element".
    05 FILLER PIC X(40) VALUE "pool-no-element.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool element without element_type".
    05 FILLER PIC X(40) VALUE "pool-no-element-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a projection not listed".
    05 FILLER PIC X(40) VALUE "pool-projection.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a location that is a bad id".
    05 FILLER PIC X(40) VALUE "pool-location-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "processors that is a number".
    05 FILLER PIC X(40) VALUE "pool-processors-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a list element whose members are bad".
    05 FILLER PIC X(40) VALUE "pool-list-elements.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a fallback that is a number".
    05 FILLER PIC X(40) VALUE "pool-fallback-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(40) VALUE "not-json.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD OCCURS 33 TIMES.
       10 WS-B-LABEL      PIC X(40).
       10 WS-B-FILE       PIC X(40).
       10 WS-B-REGISTRY   PIC X(40).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-8" TO WS-DIR
     CALL "LOAD-36-8" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-8 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-8 every documented file is an element" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE WS-F-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-F-KEY(WS-I) TO WS-KEY
         MOVE WS-F-TYPE(WS-I) TO WS-WANT-TYPE
         PERFORM CHECK-FIND
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         MOVE WS-B-LABEL(WS-I) TO WS-LABEL
         MOVE WS-B-FILE(WS-I) TO WS-FILE
         MOVE WS-B-REGISTRY(WS-I) TO WS-DEST
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 CHECK-FIND.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-8 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO WS-ROW
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-8 " FUNCTION TRIM(WS-KEY) " has the shape " FUNCTION TRIM(WS-WANT-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-36-8 2>/dev/null; rm -rf build/content-test/load-36-8; "
         "mkdir -p build/content-test/load-36-8/t && cp -R content/tests/fixtures/load-36-8/data build/content-test/load-36-8/t/data && "
         "cp content/tests/fixtures/load-36-8/bad/" FUNCTION TRIM(WS-FILE) " build/content-test/load-36-8/t/data/minecraft/"
         FUNCTION TRIM(WS-DEST) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-36-8/t" TO WS-DIR
     CALL "LOAD-36-8" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-8 reject " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-8 reject " FUNCTION TRIM(WS-LABEL) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
