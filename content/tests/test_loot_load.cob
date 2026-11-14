*> Test of the loot loaders (T0288; docs/protocol/26-loot-and-predicates.md sections 1, 2, 6 to 9 and 13). LOOT-LOAD USING root
*> (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of
*> the load staying): the files of data/<namespace>/loot_table, predicate, item_modifier, slot_source, context_int_provider and
*> context_float_provider are checked through the shape engine (shapes.cob) against the member lists of section 2 (table, pool,
*> entry), 6 (9 entry types, 6 slot sources), 7 (42 function types), 8 (20 condition types and the level based values), 9
*> (23 int and 28 float provider types, score and nbt providers) and 3.2 (the 31 parameter sets a table type may name). The
*> fixture tree content/tests/fixtures/load-26 holds 4 loot tables, 2 predicates, 2 int providers and 1 float provider; each
*> reject case copies a file of content/tests/fixtures/load-26-bad into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-T                   PIC X(60).
 01 WS-PATH                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC 99.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a loot table of an unknown parameter set".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a loot table whose pools is an object".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a pool without rolls".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a pool without entries".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an entry of an unknown type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an entry without a type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an item entry without a name".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an entry whose weight is a string".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an alternatives entry whose children is an object".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a function of an unknown type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a set_count function without count".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a set_item function of a bad identifier".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a limit_count function whose limit is a number".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a condition of an unknown type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an inverted condition without a term".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a random_chance whose chance is an array".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an any_of whose terms is a number".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an int provider add with a boolean input".
    05 FILLER PIC X(48) VALUE "context_int_provider/bad.json".
    05 FILLER PIC X(60) VALUE "an int provider add whose inputs is an object".
    05 FILLER PIC X(48) VALUE "context_int_provider/bad.json".
    05 FILLER PIC X(60) VALUE "an int provider of an unknown type".
    05 FILLER PIC X(48) VALUE "context_int_provider/bad.json".
    05 FILLER PIC X(60) VALUE "a float provider of an unknown type".
    05 FILLER PIC X(48) VALUE "context_float_provider/bad.json".
    05 FILLER PIC X(60) VALUE "a slots entry of an unknown slot source".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a modifier that is a number".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a level based value of an unknown type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a predicate file that is a number".
    05 FILLER PIC X(48) VALUE "predicate/bad.json".
    05 FILLER PIC X(60) VALUE "a set_attributes modifier without an attribute".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a copy_custom_data op of swap".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "an nbt provider of an unknown type".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a score name provider of an unknown type".
    05 FILLER PIC X(48) VALUE "context_int_provider/bad.json".
    05 FILLER PIC X(60) VALUE "a table_bonus whose chances is a number".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a weighted_list entry of weight -1".
    05 FILLER PIC X(48) VALUE "context_int_provider/bad.json".
    05 FILLER PIC X(60) VALUE "a loot_table entry whose value is a number".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a sequence function without functions".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a loot table file that is not JSON".
    05 FILLER PIC X(48) VALUE "loot_table/bad.json".
    05 FILLER PIC X(60) VALUE "a loot table file with a bad identifier".
    05 FILLER PIC X(48) VALUE "loot_table/Bad.json".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 35 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(48).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-26" TO WS-DIR
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US15 loot the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US15 loot nine elements (4 tables, 2 predicates, 3 providers)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "loot_table" TO WS-REGISTRY
     MOVE "minecraft:blocks/diamond_ore" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot blocks/diamond_ore (alternatives, apply_bonus, explosion_decay) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:entities/zombie" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot entities/zombie (uniform rolls, looting bonus) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:chests/entries" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot chests/entries (all entry types, slot sources) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:chests/functions" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot chests/functions (all 42 function types) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "predicate" TO WS-REGISTRY
     MOVE "minecraft:tool/can_silk_touch" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot predicate tool/can_silk_touch is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:block/conditions" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot predicate with the 18 other condition types is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "context_int_provider" TO WS-REGISTRY
     MOVE "minecraft:cooking/time_default" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot int provider cooking/time_default is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:cooking/time_other" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot int provider cooking/time_other is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "context_float_provider" TO WS-REGISTRY
     MOVE "minecraft:cooking/speed_default" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot float provider cooking/speed_default is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "loot_table" TO WS-REGISTRY
     MOVE "minecraft:blocks/absent" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US15 loot an absent table is not there" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-26/t" TO WS-DIR
     MOVE WS-I TO WS-N-TEXT
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-26 2>/dev/null; rm -rf build/content-test/load-26; "
         "mkdir -p build/content-test/load-26 && cp -R content/tests/fixtures/load-26 build/content-test/load-26/t && "
         "cp content/tests/fixtures/load-26-bad/" WS-N-TEXT ".json build/content-test/load-26/t/data/minecraft/"
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 loot " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 loot after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 FIND-ELEMENT.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW.

 ASSERT-FOUND.
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
