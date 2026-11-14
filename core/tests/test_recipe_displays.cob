*> Test of the recipe book displays (docs/protocol/27 sections 3.1, 3.2 and 4.2, 05b RecipeDisplayEntry; core/src/
*> recipe-unlock.cob RECIPE-ENTRY-BUILD): the display of a shaped recipe with an empty cell, a shapeless recipe with a tag or
*> alternatives, a transmute recipe (one display per material count, the result count with the add flag), a cooking recipe
*> (furnace display with the cooking time) and a stonecutting recipe; a family without a display is not built. The
*> requirements are present when every ingredient is a HolderSet of the book: one item, a list of two to eight items or one tag
*> (T3663; a tag mixed with items, a list of nine or an unknown item has none). Items: greystone 2, loam 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-DISPLAYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY PROTO.
 01 WS-ROW                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUILT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-PTR                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-PTR2                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "test recipe displays 27§4.2 a shaped 2 x 2 recipe with an empty cell: four ingredient slots (item, empty, "
         & "item, empty), requirements for the two items, category equipment" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 0 TO RR-SERIALIZER(WS-ROW)
     MOVE 2 TO RR-WIDTH(WS-ROW) RR-HEIGHT(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 3)
     MOVE "equipment" TO RR-CATEGORY(WS-ROW)
     PERFORM SHOW
     MOVE "1 type 1 2x2 ing 4 [4 0 4 0] req 1/2 [2 3] res 5x1 cat 2 group 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 27§4.2 a shapeless recipe with a tag and with alternatives: tag node and composite "
         & "node, requirements a tag and a list of two, a group number and the notify flag" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 1 TO RR-SERIALIZER(WS-ROW) RR-ING-COUNT(WS-ROW)
     MOVE 2 TO RR-ING-COUNT(WS-ROW)
     MOVE "#cobolcraft:soils" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:greystone cobolcraft:loam" TO RR-ING(WS-ROW, 2)
     MOVE "plates" TO RR-GROUP(WS-ROW)
     MOVE 3 TO WS-FLAGS
     PERFORM SHOW
     MOVE "1 type 0 0x0 ing 2 [6 10] req 1/2 [#cobolcraft:soils L(2,3)] res 5x1 cat 3 group 1 flags 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays T3663 a tag mixed with an item, a list of nine items and an unknown item are not requirements"
         TO TL-CASE
     PERFORM NEW-ROW
     MOVE 1 TO RR-SERIALIZER(WS-ROW)
     MOVE 3 TO RR-ING-COUNT(WS-ROW)
     MOVE "cobolcraft:greystone #cobolcraft:soils" TO RR-ING(WS-ROW, 1)
     MOVE 1 TO WS-PTR2
     MOVE SPACES TO RR-ING(WS-ROW, 2)
     PERFORM 9 TIMES
         STRING "cobolcraft:loam " DELIMITED BY SIZE INTO RR-ING(WS-ROW, 2) POINTER WS-PTR2
     END-PERFORM
     MOVE "cobolcraft:no_such_item" TO RR-ING(WS-ROW, 3)
     MOVE 0 TO WS-FLAGS
     PERFORM SHOW
     MOVE "1 type 0 0x0 ing 3 [10 10 4] req 0/0 [] res 5x1 cat 3 group 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 27§2.4 a transmute recipe of 1 to 3 materials with the add flag: display index 2 "
         & "has the input and 3 materials and the result count 1 + 3; a blank result id shows the input item" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 4 TO RR-SERIALIZER(WS-ROW) RR-ING-COUNT(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 2)
     MOVE 1 TO RR-MATERIAL-MIN(WS-ROW) RR-ADD-COUNT(WS-ROW)
     MOVE 3 TO RR-MATERIAL-MAX(WS-ROW)
     MOVE SPACES TO RR-RESULT-ID(WS-ROW)
     MOVE 2 TO WS-INDEX
     PERFORM SHOW
     MOVE "1 type 0 0x0 ing 4 [4 4 4 4] req 1/4 [2 3 3 3] res 5x4 cat 3 group 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 27§3.1 a smelting recipe: furnace display, the any-fuel slot, the cooking time and "
         & "no requirements" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 14 TO RR-SERIALIZER(WS-ROW)
     MOVE 1 TO RR-ING-COUNT(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     MOVE 200 TO RR-COOK-TIME(WS-ROW)
     MOVE 0.5 TO RR-EXPERIENCE(WS-ROW)
     MOVE "food" TO RR-CATEGORY(WS-ROW)
     PERFORM SHOW
     MOVE "1 type 2 0x0 ing 0 [4 1] req 0/0 [] res 5x1 cat 4 group 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 27§3.2 a stonecutting recipe: stonecutter display with one input, category 10"
         TO TL-CASE
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE 1 TO RR-ING-COUNT(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     PERFORM SHOW
     MOVE "1 type 3 0x0 ing 0 [4] req 0/0 [] res 5x1 cat 10 group 0 flags 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 27§3.4 a brewing recipe has no book display: nothing is built" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 20 TO RR-SERIALIZER(WS-ROW)
     PERFORM SHOW
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe displays 4.2 an ingredient list that needs more slot nodes than the table has falls back to "
         & "the first node instead of overflowing" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 1 TO RR-SERIALIZER(WS-ROW)
     MOVE 9 TO RR-ING-COUNT(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE "cobolcraft:greystone cobolcraft:loam cobolcraft:grit cobolcraft:turf" TO RR-ING(WS-ROW, WS-I)
     END-PERFORM
     MOVE 0 TO WS-INDEX WS-FLAGS
     CALL "RECIPE-ENTRY-BUILD" USING WS-ROW WS-INDEX WS-FLAGS PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE WS-BUILT
     MOVE PB-SDT-COUNT TO WS-E
     MOVE WS-BUILT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "built " FUNCTION TRIM(WS-B) " nodes " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "built 1 nodes 31" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 NEW-ROW.
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE "cobolcraft:test_display" TO RR-KEY(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     MOVE 0 TO WS-INDEX WS-FLAGS.

*> "<built> type <t> <w>x<h> ing <n> [node types] req <present>/<count> [items] res <node type>x<count> cat <c> group <g>
*> flags <f>" of the display WS-INDEX of the row WS-ROW ("0" when nothing is built).
 SHOW.
     CALL "RECIPE-ENTRY-BUILD" USING WS-ROW WS-INDEX WS-FLAGS PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE WS-BUILT
     MOVE SPACES TO TL-OBSERVED
     IF WS-BUILT = 0
         MOVE "0" TO TL-OBSERVED
     ELSE
         MOVE 1 TO WS-PTR
         MOVE PB-RE-TYPE TO WS-E
         STRING "1 type " FUNCTION TRIM(WS-E) " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-WIDTH TO WS-E
         STRING FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-HEIGHT TO WS-E
         STRING FUNCTION TRIM(WS-E) " ing " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-INGREDIENT-COUNT TO WS-E
         STRING FUNCTION TRIM(WS-E) " [" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         EVALUATE PB-RE-TYPE
             WHEN PB-RT-FURNACE
                 MOVE 2 TO WS-LIST
             WHEN PB-RT-STONECUTTER
                 MOVE 1 TO WS-LIST
             WHEN OTHER
                 MOVE PB-RE-INGREDIENT-COUNT TO WS-LIST
         END-EVALUATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIST
             MOVE PB-SDN-TYPE(PB-RE-INGREDIENT(WS-I)) TO WS-E
             IF WS-I > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-PERFORM
         MOVE PB-RE-REQ-PRESENT TO WS-E
         STRING "] req " FUNCTION TRIM(WS-E) "/" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-REQ-COUNT TO WS-E
         STRING FUNCTION TRIM(WS-E) " [" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RE-REQ-COUNT
             IF WS-I > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-IF
             EVALUATE TRUE
                 WHEN PB-RE-REQ-TAG-LENGTH(WS-I) > 0
                     STRING "#" PB-RE-REQ-TAG(WS-I)(1:PB-RE-REQ-TAG-LENGTH(WS-I)) DELIMITED BY SIZE
                         INTO TL-OBSERVED POINTER WS-PTR
                 WHEN PB-RE-REQ-N(WS-I) > 0
                     STRING "L(" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
                     PERFORM VARYING WS-LIST FROM 1 BY 1 UNTIL WS-LIST > PB-RE-REQ-N(WS-I)
                         MOVE PB-RE-REQ-LIST(WS-I, WS-LIST) TO WS-E
                         IF WS-LIST > 1
                             STRING "," DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
                         END-IF
                         STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
                     END-PERFORM
                     STRING ")" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
                 WHEN OTHER
                     MOVE PB-RE-REQ-ITEM(WS-I) TO WS-E
                     STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-EVALUATE
         END-PERFORM
         MOVE PB-SDN-TYPE(PB-RE-RESULT) TO WS-E
         STRING "] res " FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-SDN-COUNT(PB-RE-RESULT) TO WS-E
         STRING FUNCTION TRIM(WS-E) " cat " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-CATEGORY TO WS-E
         STRING FUNCTION TRIM(WS-E) " group " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-GROUP TO WS-E
         STRING FUNCTION TRIM(WS-E) " flags " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-RE-FLAGS TO WS-E
         STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-IF.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPE-DISPLAYS.

 COPY CORETEST.
