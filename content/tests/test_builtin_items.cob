*> Test of the built-in item layer (T0204; docs/design/standin-content.md section 2, cobolcraft-standard-core.md sections
*> 5.2 to 5.4): the cobolcraft set answers the item lookups with the eighteen items (ids 0 to 17) as the same
*> record shapes the standard set returns: key, class, the block a block item places, stack size, and the
*> default components (tool, attributes, food, consumable) as "name value" entries of the summary. The bench
*> item (id 18) is covered by test_builtin_bench.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-R-ID             PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 WS-R-CLASS          PIC X(24).
    05 WS-R-BLOCK          PIC X(4).
    05 WS-R-STACK          PIC X(2).
    05 WS-R-DAMAGE         PIC X(4).
    05 WS-R-FLAGS          PIC X(34).
    05 WS-R-COMPONENTS     PIC X(160).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-I                   BINARY-LONG.
 01 WS-NUM                 PIC 99.
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-TAG                 PIC X(112).
 01 WS-RESULT              BINARY-LONG.
*> Key, block it places (empty: none) and stack size of each item (standin 2, core 5.2).
 01 WS-ITEMS.
    05 FILLER PIC X(29) VALUE "cobolcraft:nothing     |  |  ".
    05 FILLER PIC X(29) VALUE "cobolcraft:baseplate   |1 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:greystone   |2 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:loam        |3 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:turf        |4 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:grit        |5 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:cardstack   |6 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:lucite      |7 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:glowtube    |8 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:ledger_tile |9 |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:pry_bar     |  |1 ".
    05 FILLER PIC X(29) VALUE "cobolcraft:trowel      |  |1 ".
    05 FILLER PIC X(29) VALUE "cobolcraft:grazer_flank|  |32".
    05 FILLER PIC X(29) VALUE "cobolcraft:seared_flank|  |32".
    05 FILLER PIC X(29) VALUE "cobolcraft:sod_cake    |  |16".
    05 FILLER PIC X(29) VALUE "cobolcraft:dump_shard  |  |64".
    05 FILLER PIC X(29) VALUE "cobolcraft:goto_pad    |10|16".
    05 FILLER PIC X(29) VALUE "cobolcraft:slag        |11|64".
 01 WS-ITEM-TABLE REDEFINES WS-ITEMS.
    05 WS-ITEM OCCURS 18 TIMES.
       10 WS-I-KEY         PIC X(23).
       10 FILLER           PIC X.
       10 WS-I-BLOCK       PIC X(2).
       10 FILLER           PIC X.
       10 WS-I-STACK       PIC X(2).
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE SPACES TO WS-KEY
         MOVE WS-I-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         COMPUTE WS-NUM = WS-I - 1
         MOVE SPACES TO TL-CASE
         STRING "builtin items: " FUNCTION TRIM(WS-I-KEY(WS-I)) " is item " WS-NUM DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         COMPUTE TL-EXPECTED-N = WS-I - 1
         MOVE WS-ID TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin items: item " WS-NUM " places the block of standin 2" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-I-BLOCK(WS-I) TO TL-EXPECTED
         MOVE WS-R-BLOCK TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin items: item " WS-NUM " stack size" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-I-STACK(WS-I) TO TL-EXPECTED
         MOVE WS-R-STACK TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
         MOVE SPACES TO TL-CASE
         STRING "builtin items: item " WS-NUM " by id has its key" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-I-KEY(WS-I) TO TL-EXPECTED
         MOVE WS-R-KEY TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Classes of the rows that have one.
     MOVE 0 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "builtin items: nothing is an AirItem" TO TL-CASE
     MOVE "AirItem" TO TL-EXPECTED
     MOVE WS-R-CLASS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "builtin items: lucite is a BlockItem" TO TL-CASE
     MOVE "BlockItem" TO TL-EXPECTED
     MOVE WS-R-CLASS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Components: the tools (core 5.3), the foods (5.4) and the stack sizes.
     MOVE 10 TO WS-ID
     MOVE "tool" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: pry_bar tool rule" TO TL-CASE
     MOVE "#minecraft:mineable/pickaxe 4.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "attack_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: pry_bar attack damage modifier 3.0 (damage 4)" TO TL-CASE
     MOVE "3.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "attack_speed" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: pry_bar attack speed modifier" TO TL-CASE
     MOVE "-2.8" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-ID
     MOVE "tool" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: trowel tool rule" TO TL-CASE
     MOVE "#minecraft:mineable/shovel 4.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "attack_speed" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: trowel attack speed modifier" TO TL-CASE
     MOVE "-3.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: the tools have no durability (CORE-19)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-ID
     MOVE "food" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: grazer_flank nutrition 3" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "3" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "consumable" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: grazer_flank consume seconds and animation" TO TL-CASE
     MOVE "1.6 eat" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-ID
     MOVE "food" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: seared_flank nutrition 8" TO TL-CASE
     MOVE "8" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-ID
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: sod_cake nutrition 2" TO TL-CASE
     MOVE "2" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-ID
     MOVE "max_stack_size" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: sod_cake max_stack_size 16" TO TL-CASE
     MOVE "16" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ID
     MOVE "food" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "builtin items: a block item carries no food" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sets share no rows (WT-25) and unknown ids are row 0.
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "builtin items: stone is not in the cobolcraft set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin items: unknown key gives row 0 (nothing)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft:nothing" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "builtin items: item 19 is not found" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "builtin items: item -1 is not found" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The built-in item tag (core 4.2): enchantable/mining holds the two tools.
     CALL "BUILTIN-ITEM-TAGS"
     MOVE "item" TO WS-TAG-REGISTRY
     MOVE "minecraft:enchantable/mining" TO WS-TAG
     MOVE 10 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "builtin items: pry_bar (10) is in enchantable/mining" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "builtin items: trowel (11) is in enchantable/mining" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "builtin items: a food is not in enchantable/mining" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TAGS-FREE"
     STOP RUN.
