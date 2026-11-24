*> Test of crafting matching (core/src/crafting-match.cob; docs/protocol/13 §3.2, §3.3, §3.6 and the §9 "Crafting
*> matches" examples): shaped (trimmed, any window of the grid, mirrored when not symmetric), shapeless (any order,
*> several accepted items by tag) and the result for a 2 x 2 and a 3 x 3 grid with the recipes of the content set
*> (the cobolcraft built-ins: shapeless recipes from 2 to 7 items and the shaped bench recipe ["##","##"]); the use of
*> one item per slot when the result is taken.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CRAFTING-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-COUNTS.
    05 WS-N                BINARY-LONG OCCURS 9 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEDGER              BINARY-LONG.
 01 WS-GREY                BINARY-LONG.
 01 WS-GRIT                BINARY-LONG.
 01 WS-LOAM                BINARY-LONG.
 01 WS-CARD                BINARY-LONG.
 01 WS-LUCITE              BINARY-LONG.
 01 WS-DUMP                BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-TURF                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-TEXT                PIC X(200).
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "cobolcraft:test_soils".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 2 TIMES.
 01 WS-STATUS              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "cobolcraft:ledger_tile" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-LEDGER
     MOVE "cobolcraft:greystone" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-GREY
     MOVE "cobolcraft:grit" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-GRIT
     MOVE "cobolcraft:loam" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-LOAM
     MOVE "cobolcraft:cardstack" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-CARD
     MOVE "cobolcraft:lucite" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-LUCITE
     MOVE "cobolcraft:dump_shard" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-DUMP
     MOVE "cobolcraft:glowtube" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-GLOW
     MOVE "cobolcraft:turf" TO WS-KEY
     PERFORM ITEM-BY-KEY
     MOVE WS-FOUND TO WS-TURF

     MOVE "test crafting match 13§9 a 2x2 square of the bench ingredient in the 2x2 inventory grid "
         & "matches the shaped bench recipe (row 10)" TO TL-CASE
     PERFORM CLEAR-GRID-2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-LEDGER TO WS-G(WS-I)
     END-PERFORM
     PERFORM MATCH-GRID
     MOVE "10 1 cobolcraft:crafting_bench" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match 13§9 the 2x2 square matches in every corner window of the 3x3 grid" 
         TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID-3
     PERFORM SQUARE-AT-0
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-3
     PERFORM SQUARE-AT-1
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-3
     PERFORM SQUARE-AT-3
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-3
     PERFORM SQUARE-AT-4
     PERFORM ADD-ROW
     MOVE "10 10 10 10" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test crafting match 13§9 four ledger tiles at (0,0), (1,0), (0,1), (2,2) of the 3x3 grid "
         & "(trimmed size 3x3) match no recipe" TO TL-CASE
     PERFORM CLEAR-GRID-3
     MOVE WS-LEDGER TO WS-G(1) WS-G(2) WS-G(4) WS-G(9)
     PERFORM MATCH-GRID
     MOVE "0 0 -" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match 13§3.2 a bigger or smaller count of the ingredient does not match "
         & "(three tiles; five tiles) and an empty grid matches nothing" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID-3
     MOVE WS-LEDGER TO WS-G(1) WS-G(2) WS-G(4)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE WS-LEDGER TO WS-G(5) WS-G(7)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-3
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE "0 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test crafting match 13§3.3 shapeless: four grit in any slots of the 2x2 grid give 2 lucite "
         & "(row 2), in the 3x3 grid too" TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-GRIT TO WS-G(1) WS-G(2) WS-G(3) WS-G(4)
     PERFORM MATCH-GRID
     MOVE "2 2 cobolcraft:lucite" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test crafting match 13§3.3 four grit scattered over the 3x3 grid give 2 lucite" TO TL-CASE
     PERFORM CLEAR-GRID-3
     MOVE WS-GRIT TO WS-G(1) WS-G(3) WS-G(7) WS-G(9)
     PERFORM MATCH-GRID
     MOVE "2 2 cobolcraft:lucite" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match 13§3.3 shapeless in any order: cardstack first then three greystone "
         & "give the pry_bar (row 3)" TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-CARD TO WS-G(1)
     MOVE WS-GREY TO WS-G(2) WS-G(3) WS-G(4)
     PERFORM MATCH-GRID
     MOVE "3 1 cobolcraft:pry_bar" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match 13§3.3 an extra slot is no match: greystone x2 + cardstack + loam "
         & "(the trowel needs exactly three slots)" TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(2)
     MOVE WS-CARD TO WS-G(3)
     MOVE WS-LOAM TO WS-G(4)
     PERFORM MATCH-GRID
     MOVE "0 0 -" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match 13§3.3 the trowel (row 4): greystone x2 + cardstack in the 2x2 grid"
         TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(4)
     MOVE WS-CARD TO WS-G(2)
     PERFORM MATCH-GRID
     MOVE "4 1 cobolcraft:trowel" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test crafting match US10-3 a recipe of seven items (goto_pad) matches only in the 3x3 grid "
         & "(the 2x2 grid has four slots)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID-3
     MOVE WS-LEDGER TO WS-G(1) WS-G(2) WS-G(3) WS-G(4)
     MOVE WS-DUMP TO WS-G(5) WS-G(6)
     MOVE WS-GLOW TO WS-G(7)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE 2 TO WS-W
     MOVE 2 TO WS-H
     MOVE WS-LEDGER TO WS-G(1)
     MOVE WS-LEDGER TO WS-G(2)
     MOVE WS-DUMP TO WS-G(3)
     MOVE WS-GLOW TO WS-G(4)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE "8 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM SYNTHETIC-CASES

     MOVE "test crafting match 13§3.6 taking the result uses one item of each non-empty slot: counts "
         & "3 2 1 become 2 1 0 and the emptied slot has no item" TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(2)
     MOVE WS-CARD TO WS-G(4)
     MOVE 3 TO WS-N(1)
     MOVE 2 TO WS-N(2)
     MOVE 1 TO WS-N(4)
     CALL "CRAFT-TAKE" USING WS-W WS-H WS-GRID WS-COUNTS
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-N(WS-I) TO WS-EDIT
         MOVE WS-G(WS-I) TO WS-EDIT2
         MOVE SPACES TO TL-OBSERVED
         IF WS-G(WS-I) = 0
             STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) "/empty" DELIMITED BY SIZE
                 INTO TL-OBSERVED
         ELSE
             STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) "/item" DELIMITED BY SIZE
                 INTO TL-OBSERVED
         END-IF
         MOVE TL-OBSERVED TO WS-TEXT
     END-PERFORM
     MOVE "2/item 1/item 0/empty 0/empty" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Rows the content set does not hold: a pattern that is not left-right symmetric (13 §9 "Mirroring") and an
*> ingredient given as a tag.
 SYNTHETIC-CASES.
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_mirror" TO RR-KEY(RC-COUNT)
     MOVE 0 TO RR-SERIALIZER(RC-COUNT)
     MOVE 2 TO RR-WIDTH(RC-COUNT) RR-HEIGHT(RC-COUNT)
     MOVE 3 TO RR-ING-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1) RR-ING(RC-COUNT, 2) RR-ING(RC-COUNT, 3)
     MOVE "cobolcraft:sod_cake" TO RR-RESULT-ID(RC-COUNT)
     MOVE 1 TO RR-RESULT-COUNT(RC-COUNT)
     MOVE "test crafting match 13§9 mirroring: pattern [XX, X.] also matches the grid [XX, .X] "
         & "but not [X., XX] (no vertical flip)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(2) WS-G(3)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(2) WS-G(4)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(3) WS-G(4)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE "11 11 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_hole" TO RR-KEY(RC-COUNT)
     MOVE 0 TO RR-SERIALIZER(RC-COUNT)
     MOVE 2 TO RR-WIDTH(RC-COUNT) RR-HEIGHT(RC-COUNT)
     MOVE 3 TO RR-ING-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 2) RR-ING(RC-COUNT, 3) RR-ING(RC-COUNT, 4)
     MOVE "cobolcraft:slag" TO RR-RESULT-ID(RC-COUNT)
     MOVE 1 TO RR-RESULT-COUNT(RC-COUNT)
     MOVE "test crafting match 13§3.2 an empty pattern cell needs an empty slot: [., X / X, X] "
         & "takes [X, . / X, X] only mirrored (row 12)" TO TL-CASE
     PERFORM CLEAR-GRID-2
     MOVE WS-GREY TO WS-G(1) WS-G(3) WS-G(4)
     PERFORM MATCH-GRID
     MOVE "12 1 cobolcraft:slag" TO TL-EXPECTED
     PERFORM CHECK

     MOVE WS-LOAM TO WS-MEMBER(1)
     MOVE WS-TURF TO WS-MEMBER(2)
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-TWO WS-MEMBERS WS-STATUS
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_tag" TO RR-KEY(RC-COUNT)
     MOVE 1 TO RR-SERIALIZER(RC-COUNT)
     MOVE 2 TO RR-ING-COUNT(RC-COUNT)
     MOVE "#cobolcraft:test_soils" TO RR-ING(RC-COUNT, 1)
     MOVE "cobolcraft:cardstack" TO RR-ING(RC-COUNT, 2)
     MOVE "cobolcraft:seared_flank" TO RR-RESULT-ID(RC-COUNT)
     MOVE 3 TO RR-RESULT-COUNT(RC-COUNT)
     MOVE "test crafting match 27§1.3 an ingredient given as a tag accepts every member (loam or "
         & "turf) and no other item (grit)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID-2
     MOVE WS-LOAM TO WS-G(1)
     MOVE WS-CARD TO WS-G(4)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE WS-TURF TO WS-G(1)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE WS-GRIT TO WS-G(1)
     PERFORM MATCH-GRID
     PERFORM ADD-ROW
     MOVE "13 13 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ITEM-BY-KEY.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT OR WS-FOUND > 0
         IF IT-KEY(WS-I) = WS-KEY
             COMPUTE WS-FOUND = WS-I - 1
         END-IF
     END-PERFORM.

 CLEAR-GRID-2.
     MOVE 2 TO WS-W
     MOVE 2 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-G(WS-I) WS-N(WS-I)
     END-PERFORM.

 CLEAR-GRID-3.
     MOVE 3 TO WS-W
     MOVE 3 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-G(WS-I) WS-N(WS-I)
     END-PERFORM.

*> 2x2 square of ledger tiles with its top left cell at slot 0, 1, 3 and 4 (0-based) of the 3x3 grid.
 SQUARE-AT-0.
     MOVE WS-LEDGER TO WS-G(1) WS-G(2) WS-G(4) WS-G(5).
 SQUARE-AT-1.
     MOVE WS-LEDGER TO WS-G(2) WS-G(3) WS-G(5) WS-G(6).
 SQUARE-AT-3.
     MOVE WS-LEDGER TO WS-G(4) WS-G(5) WS-G(7) WS-G(8).
 SQUARE-AT-4.
     MOVE WS-LEDGER TO WS-G(5) WS-G(6) WS-G(8) WS-G(9).

 MATCH-GRID.
     CALL "CRAFT-MATCH" USING WS-W WS-H WS-GRID WS-ROW WS-ITEM WS-COUNT.

*> "row count result-key" ("0 0 -" for no recipe).
 CHECK.
     MOVE WS-ROW TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW = 0
         STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " -" DELIMITED BY SIZE
             INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(
             IT-KEY(WS-ITEM + 1)) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Appends the row (and, for a row with a result, nothing else) to WS-TEXT.
 ADD-ROW.
     MOVE WS-ROW TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.
 END PROGRAM TEST-CRAFTING-MATCH.

 COPY CORETEST.
