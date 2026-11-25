*> Implementation test of the recipe book's craftability (operator report try18 "recipe book often lacks things that it should have"; 13 section 3.9
*> Craftability, 05b Recipe Book Add requirements as HolderSets; client/src/screens/recipe-book.cob RK-CRAFTABLE, client/src/protocol-play.cob
*> RK-TAG-INDEX and RECIPE-BOOK-READ): Recipe Book Add keeps the tag, the list and the item of each requirement; a requirement is met by a unit of any
*> kind it accepts and each requirement takes its own unit, found by augmenting paths so that a requirement with a choice gives way to one without.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-BOOK-CRAFTABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==XB-==.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-STOCK-N             BINARY-LONG.
 01 WS-STOCK.
    05 WS-ST OCCURS 64 TIMES.
       10 WS-ST-ITEM       BINARY-LONG.
       10 WS-ST-COUNT      BINARY-LONG.
 01 WS-TAG-TABLE.
    05 WS-TAG-ROW OCCURS 256 TIMES.
       10 WS-TAG-HAS       PIC 9 OCCURS 64 TIMES.
 01 WS-NAME                PIC X(64).
 01 WS-INDEX               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-E1                  PIC -(4)9.
 01 WS-E2                  PIC -(4)9.
 01 WS-E3                  PIC -(4)9.
 01 WS-E4                  PIC -(4)9.
 01 WS-E5                  PIC -(4)9.
 01 WS-E6                  PIC -(4)9.
 01 WS-E7                  PIC -(4)9.
 01 WS-E8                  PIC -(4)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     INITIALIZE CLIENT-STATE
     INITIALIZE WS-TAG-TABLE
     MOVE 2 TO WS-STOCK-N
     MOVE 5 TO WS-ST-ITEM(1)
     MOVE 1 TO WS-ST-COUNT(1)
     MOVE 6 TO WS-ST-ITEM(2)
     MOVE 1 TO WS-ST-COUNT(2)

*>   Two requirements for the one item need two units of it.
     MOVE 2 TO RK-REQ-COUNT(1)
     MOVE 5 TO RK-REQ-ITEM(1, 1) RK-REQ-ITEM(1, 2)
     PERFORM CHECK-ROW
     MOVE "craftable given two requirements for item 5 and one unit of it when checked then not craftable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ST-COUNT(1)
     PERFORM CHECK-ROW
     MOVE "craftable given two requirements for item 5 and two units of it when checked then craftable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A list is met by any of its items.
     MOVE 1 TO RK-REQ-COUNT(1)
     MOVE 2 TO RK-REQ-N(1, 1)
     MOVE 9 TO RK-REQ-LIST(1, 1, 1)
     MOVE 6 TO RK-REQ-LIST(1, 1, 2)
     PERFORM CHECK-ROW
     MOVE "craftable given a requirement of the list 9, 6 and a unit of item 6 when checked then craftable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO RK-REQ-LIST(1, 1, 2)
     PERFORM CHECK-ROW
     MOVE "craftable given a requirement of the list 9, 8 and no unit of either when checked then not craftable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A tag is met by any kind that is a member of it.
     MOVE 0 TO RK-REQ-N(1, 1)
     MOVE 1 TO RK-REQ-TAG-IX(1, 1)
     PERFORM CHECK-ROW
     MOVE "craftable given a tag requirement that no stocked kind belongs to when checked then not craftable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-TAG-HAS(1, 2)
     PERFORM CHECK-ROW
     MOVE "craftable given a tag requirement that the second stocked kind belongs to when checked then craftable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A tag the table had no room for is never met.
     MOVE -1 TO RK-REQ-TAG-IX(1, 1)
     PERFORM CHECK-ROW
     MOVE "craftable given a tag requirement the table had no room for when checked then not craftable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Augmenting path: the first requirement (5 or 6) must take 6 so that the second (5) has its unit.
     MOVE 2 TO RK-REQ-COUNT(1)
     MOVE 0 TO RK-REQ-TAG-IX(1, 1)
     MOVE 2 TO RK-REQ-N(1, 1)
     MOVE 5 TO RK-REQ-LIST(1, 1, 1)
     MOVE 6 TO RK-REQ-LIST(1, 1, 2)
     MOVE 0 TO RK-REQ-N(1, 2)
     MOVE 5 TO RK-REQ-ITEM(1, 2)
     MOVE 1 TO WS-ST-COUNT(1)
     PERFORM CHECK-ROW
     MOVE "craftable given the requirements (5 or 6) and (5) and one unit each of 5 and 6 when checked then craftable (the first gives way)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STOCK-N
     PERFORM CHECK-ROW
     MOVE "craftable given the requirements (5 or 6) and (5) and one unit of 5 only when checked then not craftable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chain of three: (5 or 6), (6 or 7), (5) with one unit each of 5, 6, 7.
     MOVE 3 TO WS-STOCK-N
     MOVE 7 TO WS-ST-ITEM(3)
     MOVE 1 TO WS-ST-COUNT(3)
     MOVE 3 TO RK-REQ-COUNT(1)
     MOVE 2 TO RK-REQ-N(1, 2)
     MOVE 6 TO RK-REQ-LIST(1, 2, 1)
     MOVE 7 TO RK-REQ-LIST(1, 2, 2)
     MOVE 0 TO RK-REQ-N(1, 3)
     MOVE 5 TO RK-REQ-ITEM(1, 3)
     PERFORM CHECK-ROW
     MOVE "craftable given (5 or 6), (6 or 7), (5) and one unit each of 5, 6, 7 when checked then craftable (two requirements give way)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No requirements at all: nothing is missing.
     MOVE 0 TO RK-REQ-COUNT(1)
     PERFORM CHECK-ROW
     MOVE "craftable given no requirement when checked then craftable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The tag table: a new name is added, a known one found, a full table answers -1.
     MOVE SPACES TO WS-NAME
     MOVE "minecraft:planks" TO WS-NAME
     CALL "RK-TAG-INDEX" USING CLIENT-STATE WS-NAME WS-INDEX
     MOVE WS-INDEX TO WS-E1
     MOVE "minecraft:logs" TO WS-NAME
     CALL "RK-TAG-INDEX" USING CLIENT-STATE WS-NAME WS-INDEX
     MOVE WS-INDEX TO WS-E2
     MOVE "minecraft:planks" TO WS-NAME
     CALL "RK-TAG-INDEX" USING CLIENT-STATE WS-NAME WS-INDEX
     MOVE WS-INDEX TO WS-E3
     MOVE RK-TAG-COUNT TO WS-E4
     MOVE "T" TO TL-MODE
     MOVE "tag index given two tags and the first again when looked up then rows 1, 2 and 1 and two tags" TO TL-CASE
     MOVE "1 2 1 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 256 TO RK-TAG-COUNT
     MOVE "minecraft:never_seen" TO WS-NAME
     CALL "RK-TAG-INDEX" USING CLIENT-STATE WS-NAME WS-INDEX
     MOVE "tag index given a full table when a new tag is looked up then -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO RK-TAG-COUNT

*>   Recipe Book Add keeps the tag, the list and the item of the requirements (05b).
     CALL "PB-INIT" USING XB-BUFFER WS-CAPACITY
     MOVE 1 TO WS-COUNT
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-COUNT
     INITIALIZE XB-RECIPE-ENTRY XB-SLOT-DISPLAY-TABLE
     MOVE 77 TO XB-RE-DISPLAY-ID
     MOVE XB-RT-SHAPELESS TO XB-RE-TYPE
     MOVE 3 TO XB-RE-INGREDIENT-COUNT
     MOVE 5 TO XB-SDT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE XB-SDX-ITEM TO XB-SDN-TYPE(WS-I)
         MOVE 4 TO XB-SDN-ITEM(WS-I)
         MOVE WS-I TO XB-RE-INGREDIENT(WS-I)
     END-PERFORM
     MOVE 4 TO XB-RE-RESULT
     MOVE 5 TO XB-RE-STATION
     MOVE XB-SDX-ITEM-STACK TO XB-SDN-TYPE(4)
     MOVE 4 TO XB-SDN-ITEM(4)
     MOVE 1 TO XB-SDN-COUNT(4)
     MOVE XB-SDX-EMPTY TO XB-SDN-TYPE(5)
     MOVE 1 TO XB-RE-REQ-PRESENT
     MOVE 3 TO XB-RE-REQ-COUNT
     MOVE "minecraft:planks" TO XB-RE-REQ-TAG(1)
     MOVE 16 TO XB-RE-REQ-TAG-LENGTH(1)
     MOVE 2 TO XB-RE-REQ-N(2)
     MOVE 7 TO XB-RE-REQ-LIST(2, 1)
     MOVE 9 TO XB-RE-REQ-LIST(2, 2)
     MOVE 4 TO XB-RE-REQ-ITEM(3)
     CALL "PB-PUT-RECIPE-ENTRY" USING XB-BUFFER XB-RECIPE-ENTRY XB-SLOT-DISPLAY-TABLE
     MOVE 0 TO WS-REPLACE
     CALL "PB-PUT-BOOL" USING XB-BUFFER WS-REPLACE
     MOVE 0 TO XB-POS
     MOVE 0 TO RK-COUNT
     CALL "RECIPE-BOOK-READ" USING CLIENT-STATE XB-BUFFER
     MOVE "T" TO TL-MODE
     MOVE RK-COUNT TO WS-E1
     MOVE RK-REQ-TAG-IX(1, 1) TO WS-E2
     MOVE RK-REQ-N(1, 2) TO WS-E3
     MOVE RK-REQ-LIST(1, 2, 1) TO WS-E4
     MOVE RK-REQ-LIST(1, 2, 2) TO WS-E5
     MOVE RK-REQ-ITEM(1, 3) TO WS-E6
     MOVE RK-REQ-N(1, 3) TO WS-E7
     MOVE RK-REQ-TAG-IX(1, 3) TO WS-E8
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) " " FUNCTION TRIM(WS-E7) " " FUNCTION TRIM(WS-E8) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "recipe book add given a requirement tag, a list of two and an item when read then the book holds all three (entries, tag row, list)"
         TO TL-CASE
     MOVE "1 1 2 7 9 4 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-ROW.
     CALL "RK-CRAFTABLE" USING CLIENT-STATE WS-ROW WS-STOCK-N WS-STOCK WS-TAG-TABLE WS-OK.
 END PROGRAM TEST-RECIPE-BOOK-CRAFTABLE.
