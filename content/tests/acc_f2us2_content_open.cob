*> Acceptance test (US2-content; FR-003, FR-004, FR-005, FR-037, SC-011; content-api section 2, world-types WT-14 and WT-25):
*> CONTENT-OPEN USING type (BINARY-LONG, CT-TYPE-*), generated directory (PIC X(1100)), status out; CONTENT-CLOSE
*> (no parameters). Given trees of the generated directory, When a set is opened, Then a standard set is
*> refused unless the packs check is ok (status CT-PACKS-NOT-OK, nothing open, CT-PACKS-STATUS the check's
*> answer), an ok standard set loads the registries and tags of vanilla-data and answers the lookups with
*> the generated rows, the cobolcraft set opens with an empty directory and never reads the generated data
*> pack (a tree with a broken data file does not matter), and the two sets share no rows (WT-25). The trees:
*> content/tests/fixtures/std (the contract's valid tree plus the 13 variant registries and elements of
*> several namespaces), the contract's incomplete, stale, damaged and damaged-manifest trees, and
*> scratch copies of the std tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-CONTENT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-REGISTRY            PIC X(64).
 01 WS-TAG                 PIC X(64).
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-IDS.
    05 WS-IDS-ENTRY        BINARY-LONG OCCURS 64 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/open 2>/dev/null; rm -rf build/content-test/open; mkdir -p build/content-test/open && cp -R content/tests/fixtures/std build/content-test/open/ok && cp -R content/tests/fixtures/std build/content-test/open/broken && printf '{""a"": 1,}' > build/content-test/open/broken/vanilla-data/data/minecraft/worldgen/biome/bad.json"

*>   Given no set is open, the lookups answer CT-NOT-OPEN.
     MOVE 0 TO CT-OPEN
     MOVE SPACES TO WS-KEY
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-no set: Given nothing opened When asked Then CT-NOT-OPEN" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   A standard set over the valid tree.
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/open/ok" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-standard: Given valid packs When opened Then CT-OK" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-standard: the set is open and standard" TO TL-CASE
     MOVE CT-TYPE-STANDARD TO TL-EXPECTED-N
     MOVE CT-SET-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: CT-OPEN is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: the packs status is ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE CT-PACKS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: the generated directory is kept" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "build/content-test/open/ok" TO TL-EXPECTED
     MOVE CT-GENERATED-DIR TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US2-standard: 1286 blocks" TO TL-CASE
     MOVE 1286 TO TL-EXPECTED-N
     MOVE CT-BLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: 35723 block states" TO TL-CASE
     MOVE 35723 TO TL-EXPECTED-N
     MOVE CT-STATE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: 1658 items" TO TL-CASE
     MOVE 1658 TO TL-EXPECTED-N
     MOVE CT-ITEM-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: 161 entity types" TO TL-CASE
     MOVE 161 TO TL-EXPECTED-N
     MOVE CT-ENTITY-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: 51 world registries" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     MOVE CT-REGISTRY-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-standard: the two planks tags of vanilla-data" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CT-TAG-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "acceptance US2-standard: the dimension types of the data pack are loaded" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-standard: stone is block 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-WT-25: a cobolcraft block is not in the standard set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "acceptance US2-WT-25: a cobolcraft item is not in the standard set" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "cobolcraft:abend" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     MOVE "acceptance US2-WT-25: a cobolcraft entity is not in the standard set" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:planks" TO WS-TAG
     MOVE "oak_planks" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "acceptance US2-standard: oak_planks is in the block tag planks (23 section 6)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "item" TO WS-TAG-REGISTRY
     MOVE "oak_planks" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "acceptance US2-standard: oak_planks is in the item tag planks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "acceptance US2-standard: stone is not in the item tag planks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "point_of_interest_type" TO WS-TAG-REGISTRY
     MOVE "minecraft:acquirable_job_site" TO WS-TAG
     MOVE 0 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "acceptance US2-standard: feature packs are not loaded (22 section 8.3)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   The cobolcraft type: an empty directory, built-in rows only, its own tags, the data pack never read.
     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-cobolcraft: Given an empty directory When opened Then CT-OK" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-cobolcraft: opening replaced the standard set" TO TL-CASE
     MOVE CT-TYPE-COBOLCRAFT TO TL-EXPECTED-N
     MOVE CT-SET-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: 12 blocks" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE CT-BLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: 18 states" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE CT-STATE-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: 18 items" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE CT-ITEM-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: 4 entity types" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE CT-ENTITY-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: no data-pack registry is loaded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-REGISTRY-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: 10 built-in tags (9 block, 1 item)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE CT-TAG-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "dimension_type" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "acceptance US2-cobolcraft: dimension_type is not loaded from files" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-WT-25: greystone is block 2 in the cobolcraft set" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-WT-25: stone is not in the cobolcraft set" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     MOVE 64 TO WS-CAPACITY
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE "acceptance US2-cobolcraft: mineable/pickaxe has 4 members (the bench joins later)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: ... greystone, cardstack, ledger_tile, slag (2, 6, 9, 11)" TO TL-CASE
     MOVE 2002 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-IDS-ENTRY(1) * 1000 + WS-IDS-ENTRY(2) - 4
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-cobolcraft: the standard planks tag does not exist here" TO TL-CASE
     MOVE "minecraft:planks" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   The cobolcraft type never reads the generated data pack: a tree with a broken data file opens.
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/open/broken" TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-FR-005: Given a broken data pack When the cobolcraft type opens Then CT-OK" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-FR-004: ... the standard type refuses it with CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-FR-004: ... and no set stays open" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   The standard type is refused unless the packs check is ok (FR-003, FR-004).
     PERFORM REFUSE-ABSENT
     MOVE "contract/fixtures/content/incomplete" TO WS-DIR
     MOVE CT-PACKS-INCOMPLETE TO TL-EXPECTED-N
     MOVE "acceptance US2-FR-004: incomplete packs refuse a standard world" TO TL-CASE
     PERFORM REFUSE-CASE
     MOVE "contract/fixtures/content/stale" TO WS-DIR
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     MOVE "acceptance US2-FR-004: stale packs refuse a standard world" TO TL-CASE
     PERFORM REFUSE-CASE
     MOVE "contract/fixtures/content/damaged" TO WS-DIR
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     MOVE "acceptance US2-FR-004: damaged packs refuse a standard world" TO TL-CASE
     PERFORM REFUSE-CASE
     MOVE "contract/fixtures/content/damaged-manifest" TO WS-DIR
     MOVE CT-PACKS-DAMAGED TO TL-EXPECTED-N
     MOVE "acceptance US2-FR-004: a damaged manifest refuses a standard world" TO TL-CASE
     PERFORM REFUSE-CASE
     MOVE "contract/fixtures/content/valid" TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-the contract valid tree has no variant registries: CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   The hidden debug world opens as the standard set (data-model section 1) and needs valid packs too.
     MOVE "build/content-test/open/ok" TO WS-DIR
     MOVE CT-TYPE-DEBUG TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-debug: Given valid packs When the debug type opens Then CT-OK" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-debug: the set type stays the debug type" TO TL-CASE
     MOVE CT-TYPE-DEBUG TO TL-EXPECTED-N
     MOVE CT-SET-TYPE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-debug: it answers with the standard rows" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "contract/fixtures/content/stale" TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-debug: stale packs refuse the debug type" TO TL-CASE
     MOVE CT-PACKS-NOT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   Close frees the set; a wrong type is a defined outcome.
     MOVE "build/content-test/open/ok" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "CONTENT-CLOSE"
     MOVE "acceptance US2-close: CT-OPEN is 0 after a close" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-close: counts are zero" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CT-BLOCK-COUNT + CT-REGISTRY-COUNT + CT-TAG-COUNT
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "acceptance US2-close: lookups answer CT-NOT-OPEN" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"
     MOVE "acceptance US2-close: a second close is harmless" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 9 TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-type: an unknown type is CT-WRONG-TYPE" TO TL-CASE
     MOVE CT-WRONG-TYPE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE -1 TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-type: a negative type is CT-WRONG-TYPE" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   Open, open again (the first set is closed first), close.
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-reopen: opening over an open set works" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-reopen: ... and holds one set of tags" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CT-TAG-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "CONTENT-CLOSE"
     STOP RUN.

 REFUSE-ABSENT.
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/open/no-such-tree" TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "acceptance US2-FR-004: Given absent packs When a standard set opens Then CT-PACKS-NOT-OK" TO TL-CASE
     MOVE CT-PACKS-NOT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "acceptance US2-FR-004: ... the check's answer is absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     MOVE CT-PACKS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "acceptance US2-FR-004: ... and nothing is open" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CT-OPEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 REFUSE-CASE.
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE CT-PACKS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US2-FR-004: ... refused with CT-PACKS-NOT-OK" TO TL-CASE
     MOVE CT-PACKS-NOT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
