*> Test of the loader of docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md (T0245/T0246): LOAD-36-10 USING root (PIC X(1100)), status out. The fixture tree content/tests/fixtures/load-36-10 holds the
*> documented data pack files of the part (10 elements: worldgen/processor_list, worldgen/structure, worldgen/structure_set, worldgen/template_pool); each reject case copies one bad file of content/tests/fixtures/load-36-10/bad into
*> a fresh copy of the tree and the whole load is CT-BAD-DATA with nothing left loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-10.
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
 01 WS-KEY                 PIC X(64).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-LABEL               PIC X(70).
 01 WS-NAME                PIC X(40).
 01 WS-FILE                PIC X(40).
 01 WS-DEST                PIC X(40).
 01 WS-COMMAND             PIC X(600).
 01 WS-FINDS.
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:ancient_city".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:trial_chambers".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:trail_ruins".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:ancient_cities".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:trial_chambers".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:trail_ruins".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:ancient_city/city_center".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:ancient_city/sculk".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:ancient_city/walls".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(64) VALUE "minecraft:trail_ruins_roads_archaeology".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-FIND-TABLE REDEFINES WS-FINDS.
    05 WS-FIND OCCURS 10 TIMES.
       10 WS-F-REGISTRY   PIC X(48).
       10 WS-F-KEY        PIC X(64).
       10 WS-F-TYPE       PIC X(48).
 01 WS-BADS.
    05 FILLER PIC X(40) VALUE "an ancient city without start_pool".
    05 FILLER PIC X(40) VALUE "anc-no-jigsaw-pool.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a start_jigsaw_name that is a bad id".
    05 FILLER PIC X(40) VALUE "anc-jigsaw-name-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a size of 21".
    05 FILLER PIC X(40) VALUE "anc-size-21.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a fractional size".
    05 FILLER PIC X(40) VALUE "anc-size-frac.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "spawn_overrides that is a string".
    05 FILLER PIC X(40) VALUE "anc-so-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an ancient city without start_height".
    05 FILLER PIC X(40) VALUE "anc-no-height.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an ancient city without step".
    05 FILLER PIC X(40) VALUE "anc-no-step.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "liquid_settings not listed".
    05 FILLER PIC X(40) VALUE "trial-liquid.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an alias binding without type".
    05 FILLER PIC X(40) VALUE "trial-alias-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a direct binding without alias".
    05 FILLER PIC X(40) VALUE "trial-alias-direct-no-alias.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a direct target that is a bad id".
    05 FILLER PIC X(40) VALUE "trial-alias-direct-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a random target of weight 0".
    05 FILLER PIC X(40) VALUE "trial-alias-random-weight.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a random binding without targets".
    05 FILLER PIC X(40) VALUE "trial-alias-random-no-targets.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a random target data that is a bad id".
    05 FILLER PIC X(40) VALUE "trial-alias-random-data-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a random_group binding without groups".
    05 FILLER PIC X(40) VALUE "trial-alias-group-no-groups.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "random_group groups that is an object".
    05 FILLER PIC X(40) VALUE "trial-alias-group-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a heightmap that is a number".
    05 FILLER PIC X(40) VALUE "trail-heightmap-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "trail ruins without biomes".
    05 FILLER PIC X(40) VALUE "trail-no-biomes.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a negative salt".
    05 FILLER PIC X(40) VALUE "set-salt-neg.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a spacing that is a string".
    05 FILLER PIC X(40) VALUE "set-spacing-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a set entry of weight 0".
    05 FILLER PIC X(40) VALUE "set-weight-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a list element member without element_ty".
    05 FILLER PIC X(40) VALUE "pool-list-no-elements-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a list element whose elements is an obje".
    05 FILLER PIC X(40) VALUE "pool-list-elements-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a feature element feature that is a bad ".
    05 FILLER PIC X(40) VALUE "pool-feature-bad-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool entry of weight 151".
    05 FILLER PIC X(40) VALUE "pool-weight-151.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool without fallback".
    05 FILLER PIC X(40) VALUE "pool-fallback-missing.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "override_liquid_settings not listed".
    05 FILLER PIC X(40) VALUE "pool-override-liquid.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a capped delegate without processor_type".
    05 FILLER PIC X(40) VALUE "proc-capped-delegate-bad.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a capped delegate that is a number".
    05 FILLER PIC X(40) VALUE "proc-capped-delegate-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "block_rot integrity above 1".
    05 FILLER PIC X(40) VALUE "proc-rot-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "protected_blocks value that is a number".
    05 FILLER PIC X(40) VALUE "proc-protected-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a processor without processor_type".
    05 FILLER PIC X(40) VALUE "proc-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a processor loot_table that is a bad id".
    05 FILLER PIC X(40) VALUE "proc-loot-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule without location_predicate".
    05 FILLER PIC X(40) VALUE "proc-rule-no-location.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule test tag that is a bad id".
    05 FILLER PIC X(40) VALUE "proc-rule-test-tag-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(40) VALUE "not-json.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD OCCURS 36 TIMES.
       10 WS-B-LABEL      PIC X(40).
       10 WS-B-FILE       PIC X(40).
       10 WS-B-REGISTRY   PIC X(40).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-10" TO WS-DIR
     CALL "LOAD-36-10" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-10 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-10 every documented file is an element" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-F-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-F-KEY(WS-I) TO WS-KEY
         MOVE WS-F-TYPE(WS-I) TO WS-WANT-TYPE
         PERFORM CHECK-FIND
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-B-LABEL(WS-I) TO WS-LABEL
         MOVE WS-B-FILE(WS-I) TO WS-FILE
         MOVE WS-B-REGISTRY(WS-I) TO WS-DEST
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 CHECK-FIND.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-10 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO WS-ROW
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-10 " FUNCTION TRIM(WS-KEY) " has the shape " FUNCTION TRIM(WS-WANT-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-36-10 2>/dev/null; rm -rf build/content-test/load-36-10; "
         "mkdir -p build/content-test/load-36-10/t && cp -R content/tests/fixtures/load-36-10/data build/content-test/load-36-10/t/data && "
         "cp content/tests/fixtures/load-36-10/bad/" FUNCTION TRIM(WS-FILE) " build/content-test/load-36-10/t/data/minecraft/"
         FUNCTION TRIM(WS-DEST) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-36-10/t" TO WS-DIR
     CALL "LOAD-36-10" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-10 reject " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-10 reject " FUNCTION TRIM(WS-LABEL) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
