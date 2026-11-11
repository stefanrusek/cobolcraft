*> Test US12-client (spec 002, step 2b of the UI7 follow-up): item facts come from the content registry when a set is open (CL-ITEM-INFO: namespace, path, maximum stack size, places a
*> block, tool class, food), from the stand-in table of CLCONST otherwise; RK-ITEM-NAME, ITEM-BY-KEY and the creative lists use it. The built-in set of the cobolcraft world type holds
*> item 18 (crafting_bench), which the 18-item stand-in table does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LEN            BINARY-LONG.
 01 WS-KEYTEXT             PIC X(80).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-WANT                PIC X(512).
 01 WS-WANT-LEN            BINARY-LONG.
 01 WS-KEY16               PIC X(16).
 01 WS-TAB                 BINARY-LONG.

 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
*>   Without an open set: the stand-in table (grit is item 5), item 18 is unknown.
     MOVE 5 TO WS-ITEM
     PERFORM INFO-TEXT
     MOVE "acceptance US12 40-1 item facts without a content set: grit from the stand-in table: cobolcraft grit 64 block 1 no tool food 0" TO TL-CASE
     MOVE "cobolcraft grit 64 1 _ 0 known 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-ITEM
     CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1 item 18 is unknown to the stand-in table (and no set is open)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KNOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "grit            " TO WS-KEY16
     CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY16 WS-ITEM
     MOVE "crafting_bench  " TO WS-KEY16
     CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY16 WS-ITEM
     MOVE "acceptance US12 40-1 crafting_bench is not found without a content set (item 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ITEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With the built-in set open.
     MOVE SPACES TO WS-DIR
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "T" TO TL-MODE
     MOVE 18 TO WS-ITEM
     PERFORM INFO-TEXT
     MOVE "acceptance US12 40-1 item facts from the open set: item 18 is cobolcraft crafting_bench, stack 64, places a block" TO TL-CASE
     MOVE "cobolcraft crafting_bench 64 1 _ 0 known 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-ITEM
     PERFORM INFO-TEXT
     MOVE "acceptance US12 40-1 the pry bar of the open set is a tool (a pickaxe rule: hard class H): max 1, no block" TO TL-CASE
     MOVE "cobolcraft pry_bar 1 0 H 0 known 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-ITEM
     PERFORM INFO-TEXT
     MOVE "acceptance US12 40-1 the seared flank of the open set is a food: max 32, nutrition 8" TO TL-CASE
     MOVE "cobolcraft seared_flank 32 0 _ 8 known 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-NAME WS-NAME-LEN
     MOVE "block.cobolcraft.crafting_bench" TO WS-KEYTEXT
     MOVE 31 TO WS-KEYLEN
     CALL "LANG-GET" USING CLIENT-STATE WS-KEYTEXT WS-KEYLEN WS-WANT WS-WANT-LEN
     MOVE "acceptance US12 40-1 the name of item 18 is the language entry of its block key, not the name of item 0" TO TL-CASE
     MOVE WS-WANT(1:WS-WANT-LEN) TO TL-EXPECTED
     MOVE WS-NAME(1:WS-NAME-LEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "crafting_bench  " TO WS-KEY16
     CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY16 WS-ITEM
     MOVE "acceptance US12 40-1 ITEM-BY-KEY finds crafting_bench in the open set: item 18" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-ITEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The creative lists follow the set: building blocks gain item 18 (12), the search list has 18.
     MOVE 1 TO WS-TAB
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-TAB
     MOVE "acceptance US12 40-7 building blocks from the open set: 12 stacks (the 11 of the stand-in and the crafting bench)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-TAB
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-TAB
     MOVE "acceptance US12 40-7 the search tab of the open set lists 18 stacks" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE CR-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

*> TL-OBSERVED: "ns path max block tool food known k" of item WS-ITEM (an empty tool class as _).
 INFO-TEXT.
     CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-MAX TO WS-E1
     MOVE WS-BLOCK TO WS-E2
     MOVE WS-FOOD TO WS-E3
     MOVE WS-KNOWN TO WS-E4
     IF WS-TOOL = SPACE
         MOVE "_" TO WS-TOOL
     END-IF
     STRING FUNCTION TRIM(WS-NS) " " FUNCTION TRIM(WS-PATH) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " WS-TOOL " " FUNCTION TRIM(WS-E3)
         " known " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     .

 END PROGRAM TEST-ITEM-INFO.
