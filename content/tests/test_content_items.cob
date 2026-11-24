*> Test of content/src/items.cob (T0192; content-api section 2; 25 part 1 section 13 worked examples 1 to 4 and 5):
*> CONTENT-ITEM-BY-KEY USING key (PIC X(112)), item id out, row out (PIC X(270), CT-ITEM-ROW), status;
*> CONTENT-ITEM-BY-ID USING item id, row out, status; CONTENT-ITEM-COMPONENT USING item id, component name
*> (PIC X(32)), value out (PIC X(100)), status. Components are the stack size and damage columns by their
*> component names (max_stack_size, max_damage) and the "name value" entries of the row's summary. An
*> unknown key or id is CT-NOT-FOUND with row 0 (air). The set is made by setting CT-SET.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-ITEMS.
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
 PROCEDURE DIVISION.
     MOVE 0 TO CT-OPEN
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: no set open, by key" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 1 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: no set open, by id" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "max_stack_size" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: no set open, component" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

*>   By key: example 1 (stone is id 1, class BlockItem, stack 64) and the copper family (example 3).
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: stone by key is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "items: stone is item 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "items: stone class" TO TL-CASE
     MOVE "BlockItem" TO TL-EXPECTED
     MOVE WS-R-CLASS TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: stone stack size" TO TL-CASE
     MOVE "64" TO TL-EXPECTED
     MOVE WS-R-STACK TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: stone places block 1" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE WS-R-BLOCK TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "gold_block" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: gold_block is item 128 (example 2)" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "minecraft:copper_block" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: copper_block with its namespace is item 120" TO TL-CASE
     MOVE 120 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "waxed_oxidized_copper" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: waxed_oxidized_copper is item 127" TO TL-CASE
     MOVE 127 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "chiseled_copper" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: chiseled_copper is item 131" TO TL-CASE
     MOVE 131 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "waxed_oxidized_chiseled_copper" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: waxed_oxidized_chiseled_copper is item 138" TO TL-CASE
     MOVE 138 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "oak_sapling" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: oak_sapling is item 77 (example 4)" TO TL-CASE
     MOVE 77 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "items: oak_sapling flags" TO TL-CASE
     MOVE "compostable" TO TL-EXPECTED
     MOVE WS-R-FLAGS TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   By id.
     MOVE 163 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: item 163 is oak_log" TO TL-CASE
     MOVE "oak_log" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: oak_log places block 51" TO TL-CASE
     MOVE "51" TO TL-EXPECTED
     MOVE WS-R-BLOCK TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: item 0 is air" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: item 0 is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 1657 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: the last item (1657) is found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 1658 TO WS-ID
     MOVE ALL "?" TO WS-ROW
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: item 1658 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "items: an unknown id gives row 0 (air)" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE -1 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
     MOVE "items: item -1 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   Unknown keys: the defined outcome, and the sets share no rows (WT-25).
     MOVE "no_such_item" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: unknown key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "items: unknown key gives id 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "items: unknown key gives row 0 (air)" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-R-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: a cobolcraft key is not in the standard set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "items: a blank key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   Components.
     MOVE 163 TO WS-ID
     MOVE "fuel" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: oak_log fuel component (example 5)" TO TL-CASE
     MOVE "wood_blocks" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: oak_log fuel status" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 77 TO WS-ID
     MOVE "compostable" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: oak_sapling compostable component" TO TL-CASE
     MOVE "low" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "fuel" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: oak_sapling fuel component, the second entry" TO TL-CASE
     MOVE "dry_plants" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-ID
     MOVE "max_stack_size" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: stone max_stack_size" TO TL-CASE
     MOVE "64" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "fuel" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: stone has no fuel component" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "items: a component that is absent leaves the value blank" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: stone has no max_damage" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "brush" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: brush max_damage" TO TL-CASE
     MOVE "64" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   The damage column holds up to four digits (17 section 2.3: iron_pickaxe 250, diamond_pickaxe 1561), and
*>   every durable item has stack size 1.
     MOVE "iron_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: iron_pickaxe max_damage" TO TL-CASE
     MOVE "250" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "items: iron_pickaxe max_damage status ok" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "items: iron_pickaxe stack size is 1" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE WS-R-STACK TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "diamond_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "max_damage" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: diamond_pickaxe max_damage has four digits" TO TL-CASE
     MOVE "1561" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "shield" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "blocks_attacks" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: shield summary entry past 100 characters is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "honey_bottle" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "max_stack_size" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: honey_bottle max_stack_size (25 part 8: 16)" TO TL-CASE
     MOVE "16" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "use_remainder" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: honey_bottle use_remainder entry is whole" TO TL-CASE
     MOVE "glass_bottle" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "ancient_debris" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "fire_resistant" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: ancient_debris fire_resistant has no value, found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "items: a component without a value reads blank" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "fire" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: a component name is matched whole (fire is not fire_resistant)" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 99999 TO WS-ID
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "items: a component of an unknown item" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     STOP RUN.

 ASSERT-ID.
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
