*> Test of the drop collector of an explosion (core/src/block-drops.cob DROP-COLLECT-ADD, DROP-COLLECT-FLUSH; docs/protocol/26-loot-and-predicates.md section 11.2,
*> ServerExplosion.interactWithBlocks): each new stack is tried against the entries in order and merges while the item matches and the entry's count stays at most 16 (and
*> the item's stack size); what is left starts an entry at the block that produced it; the flush spawns every entry; the immediate mode (a single block break) spawns at once.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DROP-COLLECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY DROPCOLL.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-DIRT                BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ENTS                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE 1 TO WS-DIM
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIRT WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COBBLE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:diamond_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PICK WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE

*>   A first stack starts an entry at its block.
     MOVE 0 TO DC-COUNT DC-IMMEDIATE
     MOVE 1 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 5 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     MOVE "test drop collect: a first stack starts one entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: holding its count" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: at its block (x)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DC-X(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same item merges into it (5 + 9 = 14).
     MOVE 4 TO WS-X
     MOVE 9 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     MOVE "test drop collect: the same item merges into the entry (still one entry)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: 5 and 9 make 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   6 more fill the entry to 16 and 4 start a new entry at the new block.
     MOVE 7 TO WS-X
     MOVE 6 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     MOVE "test drop collect: an entry holds 16 at the most" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: the rest starts a second entry" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: of 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: at the block that produced the rest" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE DC-X(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Another item has an entry of its own.
     MOVE 3 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-COBBLE WS-AMOUNT
     MOVE "test drop collect: another item starts a third entry" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Dirt again: the full entry 1 is skipped and entry 2 takes it (4 + 3).
     MOVE 3 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     MOVE "test drop collect: a full entry is skipped, the next one of the item takes the stack (4 + 3)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: and no entry was added" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A stack of 20: entry 2 takes 9 (to 16), the 11 left start entry 4.
     MOVE 20 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     MOVE "test drop collect: a stack of 20 fills the open entry to 16" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: and the 11 left are a fourth entry" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE DC-AMOUNT(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An item that stacks to 1 never merges (the limit is the smaller of 16 and the stack size).
     MOVE 1 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-PICK WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-PICK WS-AMOUNT
     MOVE "test drop collect: two tools that stack to 1 are two entries" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The flush spawns every entry and empties the collector.
     PERFORM CLEAR-ITEMS
     CALL "DROP-COLLECT-FLUSH" USING WS-DIM DROP-COLLECTOR
     PERFORM COUNT-ITEMS
     MOVE "test drop collect: the flush spawns one item entity per entry" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-ENTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: holding every drop (16 + 16 + 11 + 3 + 1 + 1 = 48)" TO TL-CASE
     MOVE 48 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: and empties the collector" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The immediate mode (a single block break) spawns each stack as it comes and keeps nothing.
     PERFORM CLEAR-ITEMS
     MOVE 1 TO DC-IMMEDIATE
     MOVE 3 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     PERFORM COUNT-ITEMS
     MOVE "test drop collect: in immediate mode the stack is on the ground at once" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: and the collector keeps nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A full table spawns the stack at once instead of losing it.
     PERFORM CLEAR-ITEMS
     MOVE 0 TO DC-IMMEDIATE
     MOVE DC-MAX TO DC-COUNT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > DC-MAX
         MOVE 0 TO DC-ITEM(WS-E) DC-AMOUNT(WS-E)
     END-PERFORM
     MOVE 2 TO WS-AMOUNT
     CALL "DROP-COLLECT-ADD" USING WS-DIM DROP-COLLECTOR WS-X WS-Y WS-Z WS-DIRT WS-AMOUNT
     PERFORM COUNT-ITEMS
     MOVE "test drop collect: a full table spawns the stack at once" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test drop collect: and keeps the table as it was" TO TL-CASE
     MOVE DC-MAX TO TL-EXPECTED-N
     MOVE DC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-ITEMS
     GOBACK.

*> Every loose item entity removed.
 CLEAR-ITEMS.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-PERFORM.

*> WS-ENTS = the loose item entities, WS-TOTAL = the items on them.
 COUNT-ITEMS.
     MOVE 0 TO WS-ENTS WS-TOTAL
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM
             ADD 1 TO WS-ENTS
             ADD EN-ITEM-COUNT(WS-E) TO WS-TOTAL
         END-IF
     END-PERFORM.
 END PROGRAM TEST-DROP-COLLECT.
 COPY CORETEST.
