*> Contract test of the content library, provider side (T0189; specs/002-client-polish/contracts/content-api.md section 4): the lookups of
*> an opened set return the worked examples of the documents, for the standard set (24 part 1 section 16, 25 part
*> 1 section 13, 46 section 15, 23 section 3.4 and 6.7) and for the cobolcraft set (docs/design/standin-content.md section 1.2,
*> 2, 3 and cobolcraft-standard-core.md section 4), and an unknown key or id is the defined outcome (row 0, "not found")
*> in both (content-api section 3). The standard set is opened through CONTENT-OPEN over content/tests/fixtures/std
*> (a copy in build/content-test/contract); no program here tests the world type to choose a lookup.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-CONTENT-PROVIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-REGISTRY            PIC X(64).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK-VIEW REDEFINES WS-BLOCK-ROW.
    05 WS-B-ID             PIC X(4).
    05 WS-B-KEY            PIC X(35).
    05 FILLER              PIC X(780).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ITEM-VIEW REDEFINES WS-ITEM-ROW.
    05 WS-I-ID             PIC X(4).
    05 WS-I-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ENTITY-VIEW REDEFINES WS-ENTITY-ROW.
    05 WS-E-ID             PIC X(3).
    05 WS-E-KEY            PIC X(22).
    05 FILLER              PIC X(41).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-ENTRY-KEY           PIC X(64).
 01 WS-ENTRY-LENGTH        BINARY-LONG.
 01 WS-PAYLOAD             PIC X(1000).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-PAYLOAD-LENGTH      BINARY-LONG.
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-TAG                 PIC X(64).
 01 WS-PACK                PIC X(32).
 01 WS-JSON                PIC X(400).
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-IDS.
    05 WS-MEMBER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-MEMBER-CAPACITY     BINARY-LONG VALUE 16.
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/contract 2>/dev/null; rm -rf build/content-test/contract; mkdir -p build/content-test/contract && cp -R content/tests/fixtures/std build/content-test/contract/std"
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/contract/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "contract provider: the standard set opens" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   24 part 1 section 16, examples 1 to 4: the state id rule.
     MOVE "oak_log" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: 24 ex 1 oak_log is block 51" TO TL-CASE
     MOVE 51 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "contract provider: 24 ex 1 oak_log default state is 140" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE
     MOVE 139 TO WS-STATE
     PERFORM PROPS-TEXT
     MOVE "contract provider: 24 ex 1 state 139 is axis=x" TO TL-CASE
     MOVE "axis=x" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 294 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: 24 ex 2 state 294 is oak_leaves index 27" TO TL-CASE
     MOVE 2794 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-INDEX * 100 + WS-ID
     PERFORM ASSERT-NUMBER
     MOVE 295 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: 24 ex 2 spruce_leaves starts at 295" TO TL-CASE
     MOVE "spruce_leaves" TO TL-EXPECTED
     MOVE WS-B-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 51 TO WS-STATE
     PERFORM PROPS-TEXT
     MOVE "contract provider: 24 ex 3 propagule default state 51" TO TL-CASE
     MOVE "age=0,hanging=false,stage=0,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 86 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: 24 ex 3 poplar_sapling starts at 86" TO TL-CASE
     MOVE "poplar_sapling" TO TL-EXPECTED
     MOVE WS-B-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "lava" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: 24 ex 4 lava is block 38" TO TL-CASE
     MOVE 38 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "sand" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "contract provider: 24 ex 4 sand is state 121" TO TL-CASE
     MOVE 121 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE

*>   25 part 1 section 13: item ids and default components.
     MOVE "gold_block" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "contract provider: 25 ex 2 gold_block is item 128" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "waxed_oxidized_chiseled_copper" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "contract provider: 25 ex 3 the copper family ends at 138" TO TL-CASE
     MOVE 138 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE 163 TO WS-ID
     MOVE "fuel" TO WS-NAME
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE "contract provider: 25 ex 5 oak_log fuel wood_blocks" TO TL-CASE
     MOVE "wood_blocks" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   46 section 15: entity ids and static ids.
     MOVE "pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     MOVE "contract provider: 46 ex 12 pig is entity 101" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "player" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     MOVE "contract provider: 46 ex 12 player is entity 159" TO TL-CASE
     MOVE 159 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE "haste" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "contract provider: 46 ex 1 haste is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "villager_profession" TO WS-REGISTRY
     MOVE "librarian" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "contract provider: 46 ex 7 librarian is 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "data_component_type" TO WS-REGISTRY
     MOVE "custom_name" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "contract provider: 46 ex 11 custom_name is 6" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "point_of_interest_type" TO WS-REGISTRY
     MOVE "test_instance" TO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "contract provider: 46 ex 10 test_instance is 19" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     PERFORM ASSERT-ID

*>   23 section 3.4: registry ids by element order; the dimension types of the fixture.
     MOVE "worldgen/biome" TO WS-REGISTRY
     MOVE 2 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "contract provider: 23 3.4 biome id 2 is mymod:beach" TO TL-CASE
     MOVE "mymod:beach" TO TL-EXPECTED
     MOVE WS-ENTRY-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "chat_type" TO WS-REGISTRY
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "contract provider: 23 3.4 chat_type id 0 is alpha:apple" TO TL-CASE
     MOVE "alpha:apple" TO TL-EXPECTED
     MOVE WS-ENTRY-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   23 section 6.7 example 1 through the tag programs, ids by the block table.
     CALL "TAGS-BEGIN"
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "base" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", "#minecraft:birch_logs", "minecraft:acacia_log"]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "minecraft:birch_logs" TO WS-TAG
     MOVE '{"values": ["minecraft:birch_log", "minecraft:birch_wood"]}' TO WS-JSON
     PERFORM ADD-TAG
     MOVE "user" TO WS-PACK
     MOVE "minecraft:logs" TO WS-TAG
     MOVE '{"values": ["minecraft:oak_log", {"id": "x:cherry_log", "required": false}, "minecraft:dark_oak_log"]}'
         TO WS-JSON
     PERFORM ADD-TAG
     CALL "TAGS-BUILD" USING WS-TAG-REGISTRY WS-STATUS
     MOVE "minecraft:logs" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-IDS WS-MEMBER-CAPACITY WS-STATUS
     MOVE "contract provider: 23 6.7 ex 1 logs has 5 members" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "contract provider: 23 6.7 ex 1 the order oak, birch_log, birch_wood, acacia, dark_oak (51, 53, 77, 55, 57)"
         TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-MEMBER(1) * 1000000000 / 1000 + WS-MEMBER(2) * 10000 + WS-MEMBER(3) * 100
         + WS-MEMBER(4) - WS-MEMBER(5)
     COMPUTE TL-EXPECTED-N = 51 * 1000000 + 53 * 10000 + 77 * 100 + 55 - 57
     PERFORM ASSERT-NUMBER

*>   Unknown keys and ids (content-api section 3).
     MOVE "no_such_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: an unknown block key is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "contract provider: ... with row 0 (air)" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-B-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE -7 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: an unknown state is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 99999 TO WS-ID
     CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "contract provider: an unknown item id is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "contract provider: ... with row 0 (air)" TO TL-CASE
     MOVE "air" TO TL-EXPECTED
     MOVE WS-I-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "no_such" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     MOVE "contract provider: an unknown entity key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "mob_effect" TO WS-REGISTRY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     MOVE "contract provider: an unknown static key is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"

*>   The cobolcraft set: the stand-in rows (standin 1.2, 2, 3; core 4.4), same questions, same shapes.
     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "contract provider: the cobolcraft set opens" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "cobolcraft:cardstack" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: standin 1.1 cardstack is block 6" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "contract provider: standin 1.2 the default of cardstack is state 9, not the first" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     PERFORM ASSERT-STATE
     MOVE 9 TO WS-STATE
     PERFORM PROPS-TEXT
     MOVE "contract provider: standin 1.2 state 9 is axis=y,punched=false" TO TL-CASE
     MOVE "axis=y,punched=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 13 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: standin 1.2 state 13 is glowtube" TO TL-CASE
     MOVE "cobolcraft:glowtube" TO TL-EXPECTED
     MOVE WS-B-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "contract provider: standin 2 pry_bar is item 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "cobolcraft:abend" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ENTITY-ROW WS-STATUS
     MOVE "contract provider: standin 3 abend is entity 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-ID
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE "minecraft:mineable/shovel" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-IDS WS-MEMBER-CAPACITY WS-STATUS
     MOVE "contract provider: core 4.4 mineable/shovel is 3, 4, 5" TO TL-CASE
     MOVE 3004005 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MEMBER(1) * 1000000 + WS-MEMBER(2) * 1000 + WS-MEMBER(3)
     PERFORM ASSERT-NUMBER
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: an unknown block key is not found in the cobolcraft set too" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "contract provider: ... with row 0 (void)" TO TL-CASE
     MOVE "cobolcraft:void" TO TL-EXPECTED
     MOVE WS-B-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 18 TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
     MOVE "contract provider: an unknown state is not found in the cobolcraft set too" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"
     STOP RUN.

 ADD-TAG.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON TRAILING)) TO WS-JSON-LENGTH
     CALL "TAG-ADD-FILE" USING WS-TAG-REGISTRY WS-TAG WS-PACK WS-JSON WS-JSON-LENGTH WS-STATUS.

 ENTRY-OF.
     MOVE 1000 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-ENTRY-KEY WS-ENTRY-LENGTH WS-PAYLOAD
         WS-CAPACITY WS-PAYLOAD-LENGTH WS-STATUS.

 PROPS-TEXT.
     CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
         IF WS-I > 1
             MOVE "," TO WS-TEXT(WS-POS:1)
             ADD 1 TO WS-POS
         END-IF
         STRING FUNCTION TRIM(CTP-NAME(WS-I)) "=" FUNCTION TRIM(CTP-VALUE(WS-I)) DELIMITED BY SIZE
             INTO WS-TEXT WITH POINTER WS-POS
     END-PERFORM
     MOVE WS-TEXT TO TL-OBSERVED.

 ASSERT-ID.
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATE.
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
