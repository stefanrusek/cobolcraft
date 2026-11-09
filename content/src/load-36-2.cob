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
    05 FILLER PIC X(120) VALUE "L processors=processor".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "processor".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "S processor_type;l rules=processor_rule;l blocks=block_state;h rottable_blocks=block;n integrity=0..1;h value=block;t de".
    05 FILLER PIC X(120) VALUE "legate=processor;v limit=int_provider;s heightmap;i offset;n mossiness".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "processor_rule".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "T input_predicate=rule_test;T location_predicate=rule_test;x position_predicate;T output_state=block_state;x block_entit".
    05 FILLER PIC X(120) VALUE "y_modifier".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "rule_test".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "S predicate_type;d block;t block_state=block_state;s tag;n probability=0..1;i min_inclusive;i max_inclusive;l rules=rule".
    05 FILLER PIC X(120) VALUE "_test;t rule=rule_test".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(24) VALUE "block_state".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(120) VALUE "D Name;o Properties".
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
 01 WS-COUNT              BINARY-LONG VALUE 5.
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
