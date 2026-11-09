*> Test of the loader of docs/protocol/36-structures-9-villages-outposts.md (T0261/T0262): LOAD-36-9 USING root (PIC X(1100)), status out. The fixture tree content/tests/fixtures/load-36-9 holds the
*> documented data pack files of the part (14 elements: worldgen/processor_list, worldgen/structure, worldgen/structure_set, worldgen/template_pool); each reject case copies one bad file of content/tests/fixtures/load-36-9/bad into
*> a fresh copy of the tree and the whole load is CT-BAD-DATA with nothing left loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-9.
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
    05 FILLER PIC X(64) VALUE "minecraft:village_plains".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:village_taiga".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:pillager_outpost".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:villages".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(64) VALUE "minecraft:pillager_outposts".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:village/plains/town_centers".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:village/plains/decor".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:pillager_outpost/base_plates".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(64) VALUE "minecraft:mossify_10_percent".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(64) VALUE "minecraft:street_plains".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(64) VALUE "minecraft:outpost_rot".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-FIND-TABLE REDEFINES WS-FINDS.
    05 WS-FIND OCCURS 11 TIMES.
       10 WS-F-REGISTRY   PIC X(48).
       10 WS-F-KEY        PIC X(64).
       10 WS-F-TYPE       PIC X(48).
 01 WS-BADS.
    05 FILLER PIC X(40) VALUE "a village without start_pool".
    05 FILLER PIC X(40) VALUE "vil-no-pool.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a village size that is a string".
    05 FILLER PIC X(40) VALUE "vil-size-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a village without biomes".
    05 FILLER PIC X(40) VALUE "vil-no-biomes.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "use_expansion_hack that is a number".
    05 FILLER PIC X(40) VALUE "vil-hack-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a heightmap that is a number".
    05 FILLER PIC X(40) VALUE "vil-heightmap-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "outpost spawn_overrides that is an array".
    05 FILLER PIC X(40) VALUE "out-so-array.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a frequency that is a string".
    05 FILLER PIC X(40) VALUE "set-freq-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a frequency_reduction_method that is a b".
    05 FILLER PIC X(40) VALUE "set-freq-method-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an exclusion zone of 17 chunks".
    05 FILLER PIC X(40) VALUE "set-zone-chunks-17.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an exclusion zone of 0 chunks".
    05 FILLER PIC X(40) VALUE "set-zone-chunks-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an exclusion zone set that is a bad id".
    05 FILLER PIC X(40) VALUE "set-zone-other-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a set entry of weight 0".
    05 FILLER PIC X(40) VALUE "set-weight-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a pool entry of weight 0".
    05 FILLER PIC X(40) VALUE "pool-weight-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a feature element whose feature is a num".
    05 FILLER PIC X(40) VALUE "pool-feature-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "an inline placed feature without placeme".
    05 FILLER PIC X(40) VALUE "pool-feature-inline-no-placement.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "inline processors with a bad rule".
    05 FILLER PIC X(40) VALUE "pool-processors-bad-rule.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a pool without fallback".
    05 FILLER PIC X(40) VALUE "pool-no-fallback.json".
    05 FILLER PIC X(40) VALUE "worldgen/template_pool".
    05 FILLER PIC X(40) VALUE "a processor without processor_type".
    05 FILLER PIC X(40) VALUE "proc-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a processor_type that is a number".
    05 FILLER PIC X(40) VALUE "proc-type-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "rules that is an object".
    05 FILLER PIC X(40) VALUE "proc-rules-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "integrity above 1".
    05 FILLER PIC X(40) VALUE "proc-rot-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "integrity below 0".
    05 FILLER PIC X(40) VALUE "proc-rot-low.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "integrity that is a string".
    05 FILLER PIC X(40) VALUE "proc-rot-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "processors that is an object".
    05 FILLER PIC X(40) VALUE "proc-not-list.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a list without processors".
    05 FILLER PIC X(40) VALUE "proc-no-processors.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule without output_state".
    05 FILLER PIC X(40) VALUE "rule-no-output.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule without input_predicate".
    05 FILLER PIC X(40) VALUE "rule-no-input.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule test without predicate_type".
    05 FILLER PIC X(40) VALUE "rule-test-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a rule test block that is a bad id".
    05 FILLER PIC X(40) VALUE "rule-test-block-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a probability that is a string".
    05 FILLER PIC X(40) VALUE "rule-test-prob-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "an output_state without Name".
    05 FILLER PIC X(40) VALUE "rule-state-no-name.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "output_state Properties that is an array".
    05 FILLER PIC X(40) VALUE "rule-state-props.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a pos_rule_test axis not listed".
    05 FILLER PIC X(40) VALUE "rule-pos-axis.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a pos_rule_test without predicate_type".
    05 FILLER PIC X(40) VALUE "rule-pos-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a min_dist that is fractional".
    05 FILLER PIC X(40) VALUE "rule-pos-dist-frac.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a block entity modifier without type".
    05 FILLER PIC X(40) VALUE "rule-bem-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "append_loot with a bad loot_table id".
    05 FILLER PIC X(40) VALUE "rule-bem-loot-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "append_loot without loot_table".
    05 FILLER PIC X(40) VALUE "rule-bem-loot-missing.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "append_static data that is an array".
    05 FILLER PIC X(40) VALUE "rule-bem-static-data.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(40) VALUE "not-json.json".
    05 FILLER PIC X(40) VALUE "worldgen/processor_list".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD OCCURS 40 TIMES.
       10 WS-B-LABEL      PIC X(40).
       10 WS-B-FILE       PIC X(40).
       10 WS-B-REGISTRY   PIC X(40).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-9" TO WS-DIR
     CALL "LOAD-36-9" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-9 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-9 every documented file is an element" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-F-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-F-KEY(WS-I) TO WS-KEY
         MOVE WS-F-TYPE(WS-I) TO WS-WANT-TYPE
         PERFORM CHECK-FIND
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE WS-B-LABEL(WS-I) TO WS-LABEL
         MOVE WS-B-FILE(WS-I) TO WS-FILE
         MOVE WS-B-REGISTRY(WS-I) TO WS-DEST
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 CHECK-FIND.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-9 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO WS-ROW
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-9 " FUNCTION TRIM(WS-KEY) " has the shape " FUNCTION TRIM(WS-WANT-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-36-9 2>/dev/null; rm -rf build/content-test/load-36-9; "
         "mkdir -p build/content-test/load-36-9/t && cp -R content/tests/fixtures/load-36-9/data build/content-test/load-36-9/t/data && "
         "cp content/tests/fixtures/load-36-9/bad/" FUNCTION TRIM(WS-FILE) " build/content-test/load-36-9/t/data/minecraft/"
         FUNCTION TRIM(WS-DEST) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-36-9/t" TO WS-DIR
     CALL "LOAD-36-9" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-9 reject " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-9 reject " FUNCTION TRIM(WS-LABEL) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
