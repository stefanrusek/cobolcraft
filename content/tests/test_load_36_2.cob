*> Test of the loader of docs/protocol/36-structures-2-templates-and-processors.md (structure processors (sections 7 to 9; the structure NBT files are not JSON)). LOAD-36-2 USING root (PIC X(1100)), status out (CT-OK, or CT-BAD-DATA
*> with every error on standard error and nothing kept): the files of content/tests/fixtures/load-36-2 load through JSON-STRICT and
*> the shape engine (shapes.cob), each accept case is an element of its registry with the type row named, and each reject case is
*> one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-T                   PIC X(70).
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1100).
 01 WS-I                   BINARY-LONG.
 01 WS-ACCEPTS.
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:empty".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:mossify".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:rot".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:capped".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:tests".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(112) VALUE "minecraft:others".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPTS.
    05 WS-ACCEPT OCCURS 6 TIMES.
       10 WS-A-REGISTRY    PIC X(48).
       10 WS-A-KEY         PIC X(112).
       10 WS-A-TYPE        PIC X(48).
 01 WS-REJECTS.
    05 FILLER PIC X(70) VALUE "a list without processors".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a list whose processors is no array".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":{}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a processor without processor_type".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"integrity":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a processor whose processor_type is a number".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a processor that is a string".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":["minecraft:nop"]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule processor whose rules is no array".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule without input_predicate".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"location_predicate":{"predicate_type":"minecraft:always_tru'.
    05 FILLER PIC X(120) VALUE 'e"},"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule without location_predicate".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:always_true"}'.
    05 FILLER PIC X(120) VALUE ',"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule without output_state".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:always_true"}'.
    05 FILLER PIC X(120) VALUE ',"location_predicate":{"predicate_type":"minecraft:always_true"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an output_state without Name".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:always_true"}'.
    05 FILLER PIC X(120) VALUE ',"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"properties":{}}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an output_state whose Name is no id".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:always_true"}'.
    05 FILLER PIC X(120) VALUE ',"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"id"  :"No Id"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an output_state that is a number".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:always_true"}'.
    05 FILLER PIC X(120) VALUE ',"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":  7}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule test without predicate_type".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"block":"a:b"},"location_predicate":{"pre'.
    05 FILLER PIC X(120) VALUE 'dicate_type":"minecraft:always_true"},"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule test with probability 1.5".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:random_block_'.
    05 FILLER PIC X(120) VALUE 'match","block":"a:b","probability":1.5},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{'.
    05 FILLER PIC X(120) VALUE '"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule test with a bad block id".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:block_match",'.
    05 FILLER PIC X(120) VALUE '"block":"No Id"},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a rule test with a fractional min_inclusive".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:height_match"'.
    05 FILLER PIC X(120) VALUE ',"min_inclusive":0.5,"max_inclusive":3},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{'.
    05 FILLER PIC X(120) VALUE '"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an all_of whose rules has a bad rule".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:all_of","rule'.
    05 FILLER PIC X(120) VALUE 's":[{"block":"a:b"}]},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a not whose rule is a number".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:not","rule":3'.
    05 FILLER PIC X(120) VALUE '},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"id"  :"a:b"}}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a block_state_match whose block_state has no Name".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:rule","rules":[{"input_predicate":{"predicate_type":"minecraft:blockstate_ma'.
    05 FILLER PIC X(120) VALUE 'tch","block_state":{}},"location_predicate":{"predicate_type":"minecraft:always_true"},"output_state":{"id"  :"a:b"}}]}]'.
    05 FILLER PIC X(120) VALUE '}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "block_rot with integrity 2".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:block_rot","integrity":2}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "block_rot with a negative integrity".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:block_rot","integrity":-0.5}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "block_rot whose integrity is a string".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:block_rot","integrity":"1"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "protected_blocks whose value is a number".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:protected_blocks","value":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "protected_blocks with a bad tag".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:protected_blocks","value":"#No Tag"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "capped with a delegate without processor_type".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:capped","limit":1,"delegate":{}}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "capped whose limit is a string".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:capped","limit":"x","delegate":{"processor_type":"minecraft:nop"}}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "gravity with a fractional offset".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:gravity","offset":0.5}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "gravity whose heightmap is a number".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:gravity","heightmap":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "block_ignore whose blocks has an entry without Name".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:block_ignore","blocks":[{}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "block_age whose mossiness is a string".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '{"processors":[{"processor_type":"minecraft:block_age","mossiness":"x"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a processor list file that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/processor_list".
    05 FILLER PIC X(120) VALUE '[]'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
 01 WS-REJECT-TABLE REDEFINES WS-REJECTS.
    05 WS-REJECT OCCURS 31 TIMES.
       10 WS-R-LABEL       PIC X(70).
       10 WS-R-REGISTRY    PIC X(48).
       10 WS-R-BODY        PIC X(700).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-2" TO WS-DIR
     CALL "LOAD-36-2" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-2 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-2 6 elements are kept" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-A-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-2 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 1 TO WS-ROW
         END-IF
         PERFORM ASSERT-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-2 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " has type row " FUNCTION TRIM(WS-A-TYPE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         MOVE WS-R-LABEL(WS-I) TO WS-T
         MOVE WS-R-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-R-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-36-2/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-36-2 2>/dev/null; rm -rf build/content-test/load-36-2; mkdir -p build/content-test/load-36-2 && cp -R content/tests/fixtures/load-36-2 build/content-test/load-36-2/t"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-36-2/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) " && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/load-36-2/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-36-2" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-2 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-2 " FUNCTION TRIM(WS-T) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
