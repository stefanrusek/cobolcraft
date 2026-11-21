*> Test of the crafting bench content (T0217; docs/design/cobolcraft-standard-core.md sections 4.1, 5.1, 5.2 and 5.7,
*> decision CORE-25, FR-027, FR-005): cobolcraft:crafting_bench is block 12 (state 18, class CraftingTableBlock) and
*> item 18 (a BlockItem placing block 12) of the cobolcraft set, has recipe 9 (crafting_shaped, ["##","##"] with
*> # = ledger_tile, 4 ledger_tile into 1 bench, category building, display id 9) and joins the block tags
*> mineable/pickaxe, causes_suffocation and the four blocks_motion tags; it is in no item tag. The standard set has
*> neither the block nor the item.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-BENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(35).
    05 WS-R-CLASS          PIC X(32).
    05 WS-R-PROPS          PIC X(288).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 WS-R-DEFAULT        PIC X(5).
    05 WS-R-HARDNESS       PIC X(21).
    05 WS-R-BLAST          PIC X(9).
    05 WS-R-TOOL           PIC X(3).
    05 WS-R-LIGHT          PIC X(41).
    05 WS-R-MAP            PIC X(50).
    05 WS-R-SOUND          PIC X(150).
    05 WS-R-PUSH           PIC X(10).
    05 WS-R-INSTRUMENT     PIC X(15).
    05 WS-R-FLAGS          PIC X(147).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ITEM-VIEW REDEFINES WS-ITEM-ROW.
    05 WS-I-ID             PIC X(4).
    05 WS-I-KEY            PIC X(38).
    05 WS-I-CLASS          PIC X(24).
    05 WS-I-BLOCK          PIC X(4).
    05 WS-I-STACK          PIC X(2).
    05 FILLER              PIC X(198).
 01 WS-TAG-REGISTRY        PIC X(48).
 01 WS-TAG                 PIC X(112).
 01 WS-RESULT              BINARY-LONG.
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-NUM                 PIC 9.
 01 WS-TAG-NAMES.
    05 FILLER PIC X(112) VALUE "minecraft:mineable/pickaxe".
    05 FILLER PIC X(112) VALUE "minecraft:causes_suffocation".
    05 FILLER PIC X(112) VALUE "minecraft:blocks_motion".
    05 FILLER PIC X(112) VALUE "minecraft:blocks_motion_no_leaves".
    05 FILLER PIC X(112) VALUE "minecraft:blocks_motion_in_heightmap".
    05 FILLER PIC X(112) VALUE "minecraft:blocks_motion_in_heightmap_no_leaves".
 01 WS-TAG-TABLE REDEFINES WS-TAG-NAMES.
    05 WS-TAG-NAME         PIC X(112) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE "N" TO TL-MODE

*>   The block (core 5.1 row 12).
     MOVE "cobolcraft:crafting_bench" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "bench: the block is found in the cobolcraft set" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: the block id is 12" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "bench: the block class" TO TL-CASE
     MOVE "CraftingTableBlock" TO TL-EXPECTED
     MOVE WS-R-CLASS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: one state, first and default 18" TO TL-CASE
     MOVE "1   18   18   " TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-R-COUNT WS-R-FIRST WS-R-DEFAULT DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: hardness 0.8" TO TL-CASE
     MOVE "0.8" TO TL-EXPECTED
     MOVE WS-R-HARDNESS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: blast resistance 0.8" TO TL-CASE
     MOVE WS-R-BLAST TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: cosmetic columns WOOD WOOD PUSH_PULL BASS" TO TL-CASE
     MOVE "WOOD|WOOD|PUSH_PULL|BASS" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-R-MAP) "|" FUNCTION TRIM(WS-R-SOUND) "|" FUNCTION TRIM(WS-R-PUSH) "|"
         FUNCTION TRIM(WS-R-INSTRUMENT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-ID
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-ID WS-S WS-COUNT WS-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "bench: state 18 belongs to block 12" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-ID
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-ID WS-S WS-COUNT WS-ROW WS-STATUS
     MOVE "bench: state 19 is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The item (core 5.2 row 18).
     MOVE "cobolcraft:crafting_bench" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "bench: the item is found with id 18" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "bench: the item is a BlockItem" TO TL-CASE
     MOVE "BlockItem" TO TL-EXPECTED
     MOVE WS-I-CLASS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: the item places block 12, stack 64" TO TL-CASE
     MOVE "12  64" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-I-BLOCK WS-I-STACK DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The block tags (core 4.1): the bench joins six lists, with block id 12.
     MOVE "block" TO WS-TAG-REGISTRY
     MOVE 16 TO WS-CAPACITY
     CALL "BUILTIN-BLOCK-TAGS"
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 6
         MOVE 12 TO WS-ID
         CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG-NAME(WS-S) WS-ID WS-RESULT
         MOVE SPACES TO TL-CASE
         STRING "bench: block 12 is in " FUNCTION TRIM(WS-TAG-NAME(WS-S)) DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-RESULT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "minecraft:mineable/shovel" TO WS-TAG
     MOVE 12 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "bench: block 12 is not in mineable/shovel" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:replaceable" TO WS-TAG
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "bench: block 12 is not in replaceable" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     CALL "CONTENT-TAG-MEMBERS" USING WS-TAG-REGISTRY WS-TAG WS-COUNT WS-MEMBERS WS-CAPACITY WS-STATUS
     MOVE "bench: mineable/pickaxe holds 5 members, the last 12" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 100 + WS-MEMBER(5)
     MOVE 512 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No item tag names the bench.
     MOVE "item" TO WS-TAG-REGISTRY
     MOVE "minecraft:enchantable/mining" TO WS-TAG
     CALL "BUILTIN-ITEM-TAGS"
     MOVE 18 TO WS-ID
     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TAG WS-ID WS-RESULT
     MOVE "bench: item 18 is in no item tag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TAGS-FREE"

*>   The recipe (core 5.7 row 9): shaped, 2 x 2, four ledger_tile.
     CALL "BUILTIN-RECIPES-LOAD"
     MOVE "cobolcraft:crafting_bench" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-S
     MOVE "bench: the recipe has display id 9 (row 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: ten recipes in all" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe is crafting_shaped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RR-SERIALIZER(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe is 2 wide and 2 high with four slots" TO TL-CASE
     MOVE 224 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RR-WIDTH(WS-S) * 100 + RR-HEIGHT(WS-S) * 10 + RR-ING-COUNT(WS-S)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe result count 1, not special, no notification" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RR-RESULT-COUNT(WS-S) + RR-SPECIAL(WS-S) * 10 + RR-NOTIFY(WS-S) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe has no unlock entries" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RR-UNLOCK-N(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "bench: recipe result" TO TL-CASE
     MOVE "cobolcraft:crafting_bench" TO TL-EXPECTED
     MOVE RR-RESULT-ID(WS-S) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe category" TO TL-CASE
     MOVE "building" TO TL-EXPECTED
     MOVE RR-CATEGORY(WS-S) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bench: recipe has no group" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE RR-GROUP(WS-S) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > 4
         MOVE SPACES TO TL-CASE
         MOVE WS-ID TO WS-NUM
         STRING "bench: recipe cell " WS-NUM " is ledger_tile" DELIMITED BY SIZE INTO TL-CASE
         MOVE "cobolcraft:ledger_tile" TO TL-EXPECTED
         MOVE RR-ING(WS-S, WS-ID) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "RECIPES-FREE"

*>   The standard set has neither the block nor the item (FR-005).
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "N" TO TL-MODE
     MOVE "cobolcraft:crafting_bench" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "bench: the standard set has no such block" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE "bench: the standard set has no such item" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BUILTIN-BENCH.
