*> Implementation test of the recipe book and the crafting screen texts (client/src/
*> protocol-client.cob RECIPE-BOOK-READ, client/src/screens/crafting.cob CRAFT-STACK-TEXT; 05b
*> 0x4B Recipe Book Add; 08 §10.8.1 names): an Add without Replace updates the recipe it names and
*> appends a new one; the book keeps at most CL-MAX-RECIPES recipes; a malformed Add changes
*> nothing; an item_stack count is kept and an item display counts 1; an item id outside the
*> registry is named as item 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CRAFTING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-P                   BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.crafting.result".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 33.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE

*>   A book of two recipes: 0 (4 greystone -> 2 ledger_tile, craftable) and 1.
     MOVE 1 TO WS-REPLACE
     MOVE 2 TO WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-I
     MOVE 1 TO WS-FLAGS
     PERFORM PUT-RECIPE
     MOVE 1 TO WS-I
     MOVE 0 TO WS-FLAGS
     PERFORM PUT-RECIPE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-REPLACE
     CALL "RECIPE-BOOK-READ" USING CLIENT-STATE PB-BUFFER

*>   Without Replace: recipe 0 is no longer craftable, recipe 5 is new (an item display).
     MOVE 0 TO WS-REPLACE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO WS-I WS-FLAGS
     PERFORM PUT-RECIPE
     INITIALIZE PB-RECIPE-DISPLAY
     MOVE PB-SLOT-ITEM TO PB-RD-IN-TYPE(1)
     MOVE 5 TO WS-I
     MOVE 1 TO WS-FLAGS
     PERFORM PUT-RECIPE-ITEM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-REPLACE
     CALL "RECIPE-BOOK-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test crafting Recipe Book Add without Replace replaces recipe 0 (now not craftable) "
         & "and appends recipe 5, whose item ingredient display counts 1" TO TL-CASE
     PERFORM BOOK-TEXT
     MOVE "3 0:4x2>2x9:0 1:4x2>2x9:0 5:1x2>2x9:1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A malformed Add (the Replace flag missing) changes nothing.
     MOVE 1 TO WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 7 TO WS-I
     PERFORM PUT-RECIPE
     CALL "RECIPE-BOOK-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test crafting a Recipe Book Add cut short changes nothing" TO TL-CASE
     PERFORM BOOK-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Twenty recipes with Replace: the book keeps the first sixteen.
     MOVE 1 TO WS-REPLACE
     MOVE 20 TO WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 19
         PERFORM PUT-RECIPE
     END-PERFORM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-REPLACE
     CALL "RECIPE-BOOK-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "test crafting a Recipe Book Add of twenty recipes keeps sixteen (display ids 0 to 15)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 16 * 100 + 15
     COMPUTE TL-OBSERVED-N = RB-COUNT * 100 + RB-ID(RB-COUNT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 99 TO WS-ITEM
     CALL "CRAFT-STACK-TEXT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-AMOUNT WS-ITEM WS-TEXT
         WS-LENGTH
     MOVE "test crafting an item id outside the registry is named as item 0 (its key, which the "
         & "language lacks)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT(1:WS-LENGTH) TO TL-OBSERVED
     MOVE "Makes 3 x item.cobolcraft.nothing" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-ITEM
     CALL "CRAFT-STACK-TEXT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-AMOUNT WS-ITEM WS-TEXT
         WS-LENGTH
     MOVE "test crafting an item that places a block is named by its block key (08 §10.8.1)"
         TO TL-CASE
     MOVE WS-TEXT(1:WS-LENGTH) TO TL-OBSERVED
     MOVE "Makes 3 x GOTO Pad" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   One entry: display id WS-I, 4 greystone (item_stack) -> 2 ledger_tile, requirements present
*>   when WS-FLAGS is 1, then the entry flags byte.
 PUT-RECIPE.
     INITIALIZE PB-RECIPE-DISPLAY
     MOVE PB-SLOT-ITEM-STACK TO PB-RD-IN-TYPE(1)
     MOVE 4 TO PB-RD-IN-COUNT(1)
     PERFORM PUT-RECIPE-ITEM.

 PUT-RECIPE-ITEM.
     MOVE WS-I TO PB-RD-DISPLAY-ID
     MOVE PB-RECIPE-SHAPELESS TO PB-RD-TYPE
     MOVE 1 TO PB-RD-INGREDIENT-COUNT
     MOVE 2 TO PB-RD-IN-ITEM(1)
     MOVE PB-SLOT-ITEM-STACK TO PB-RD-RES-TYPE
     MOVE 9 TO PB-RD-RES-ITEM
     MOVE 2 TO PB-RD-RES-COUNT
     MOVE PB-SLOT-EMPTY TO PB-RD-ST-TYPE
     MOVE WS-FLAGS TO PB-RD-REQ-PRESENT
     MOVE 0 TO PB-RD-REQ-COUNT
     IF WS-FLAGS = 1
         MOVE 1 TO PB-RD-REQ-COUNT
         MOVE 2 TO PB-RD-REQ-ITEM(1)
     END-IF
     CALL "PB-PUT-RECIPE-DISPLAY" USING PB-BUFFER PB-RECIPE-DISPLAY
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-FLAGS.

 BOOK-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-P
     MOVE RB-COUNT TO WS-E
     STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-P
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RB-COUNT
         MOVE RB-ID(WS-I) TO WS-E
         MOVE RB-IN-AMOUNT(WS-I, 1) TO WS-E2
         STRING " " FUNCTION TRIM(WS-E) ":" FUNCTION TRIM(WS-E2) "x" DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-P
         MOVE RB-IN-ITEM(WS-I, 1) TO WS-E
         MOVE RB-RES-AMOUNT(WS-I) TO WS-E2
         STRING FUNCTION TRIM(WS-E) ">" FUNCTION TRIM(WS-E2) "x" DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-P
         MOVE RB-RES-ITEM(WS-I) TO WS-E
         STRING FUNCTION TRIM(WS-E) ":" RB-CRAFTABLE(WS-I) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-P
     END-PERFORM.
 END PROGRAM TEST-CRAFTING.
 COPY CLTEST.
