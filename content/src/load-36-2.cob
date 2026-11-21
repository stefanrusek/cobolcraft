*> Loader of docs/protocol/36-structures-2-templates-and-processors.md (structure processors (sections 7 to 9; the structure NBT files are not JSON)).
*> Shapes: worldgen/processor_list elements (7.2: the object form {"processors": [...]}), the processors of 8 and 9 (member processor_type),
*> the rule processor's rules (8.2) with their rule tests (8.3, member predicate_type) and block states (Name, Properties). The structure
*> NBT file of section 1.2 is not a data pack JSON file and is not loaded here. The documents' dispatch members processor_type and
*> predicate_type are not the engine's "type" member, so each of the groups processor and rule_test is one untyped row of all the members of
*> its types (only processor_type and predicate_type are required, the others are checked where present). position_predicate and
*> block_entity_modifier are lenient in 8.2 (an invalid value falls back to the default) and are not checked. Not loaded: the bare array form of a
*> processor list file (7.2), which the engine does not read (a file must be an object).
*> USING root (PIC X(1100): the folder that holds data/), status out (BINARY-LONG: CT-OK, or CT-BAD-DATA with every error on
*> standard error as "ERROR registry: <registry> <key>: <detail>" and nothing of the load kept). Engine: shapes.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-36-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "processor_list".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L processors=processor".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "processor_type".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_rot".
    05 FILLER PIC X(600) VALUE "N integrity=0..1;h rottable_blocks=block".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "capped".
    05 FILLER PIC X(600) VALUE "T delegate=processor;V limit=int_provider".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "protected_blocks".
    05 FILLER PIC X(600) VALUE "H value=block".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "rule".
    05 FILLER PIC X(600) VALUE "L rules=processor_rule".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "gravity".
    05 FILLER PIC X(600) VALUE "s heightmap;i offset".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_ignore".
    05 FILLER PIC X(600) VALUE "l blocks=block_state".
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "block_age".
    05 FILLER PIC X(600) VALUE "n mossiness".
    05 FILLER PIC X(24) VALUE "processor_rule".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "T input_predicate=rule_test;T location_predicate=rule_test;Q output_state;x po" &
        "sition_predicate;x block_entity_modifier".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "predicate_type".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "always_true".
    05 FILLER PIC X(600) VALUE SPACES.
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "all_of".
    05 FILLER PIC X(600) VALUE "L rules=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "any_of".
    05 FILLER PIC X(600) VALUE "L rules=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "block_match".
    05 FILLER PIC X(600) VALUE "D block".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "blockstate_match".
    05 FILLER PIC X(600) VALUE "Q block_state".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "height_match".
    05 FILLER PIC X(600) VALUE "I min_inclusive;I max_inclusive".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "not".
    05 FILLER PIC X(600) VALUE "T rule=rule_test".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "random_block_match".
    05 FILLER PIC X(600) VALUE "D block;N probability=0..1".
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "tag_match".
    05 FILLER PIC X(600) VALUE "D tag".
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;o properties".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "@".
    05 FILLER PIC X(600) VALUE "predicate_type".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "axis_aligned_linear_pos".
    05 FILLER PIC X(600) VALUE "n min_chance=0..1;N max_chance=0..1;i min_dist;I max_dist;e axis=x|y|z".
    05 FILLER PIC X(24) VALUE "pos_rule_test".
    05 FILLER PIC X(48) VALUE "linear_pos".
    05 FILLER PIC X(600) VALUE "n min_chance=0..1;n max_chance=0..1;i min_dist;i max_dist".
 01 WS-COUNT              BINARY-LONG VALUE 24.
 01 WS-REGISTRY-1         PIC X(48) VALUE "worldgen/processor_list".
 01 WS-GROUP-1            PIC X(24) VALUE "processor_list".
 01 WS-STRICT-1           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-REGISTRY-1 WS-GROUP-1 WS-STRICT-1
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOAD-36-2.
