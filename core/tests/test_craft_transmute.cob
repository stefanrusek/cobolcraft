*> Test of the transmute recipes in the crafting match (core/src/crafting-match.cob CRAFT-MATCH over RECIPE-TRANSMUTE-MATCH of
*> recipes-27.cob; docs/protocol/27 section 2.4; T3658): a transmute recipe (serializer 4) is offered for a grid with one
*> input and the material count its range allows, the result is the recipe's item (or the input's own item when the recipe names
*> none) with its count, plus the material count when the recipe adds it; a grid with another item, too few materials or the
*> input twice matches nothing. Items: greystone 2 (input), loam 3 (material), turf 4 (result).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CRAFT-TRANSMUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 2.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TRANSMUTE           BINARY-LONG.
 01 WS-ADDING              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-TRANSMUTE
     INITIALIZE RC-ROW(WS-TRANSMUTE)
     MOVE "cobolcraft:test_transmute" TO RR-KEY(WS-TRANSMUTE)
     MOVE 4 TO RR-SERIALIZER(WS-TRANSMUTE)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-TRANSMUTE, 1)
     MOVE "cobolcraft:loam" TO RR-ING(WS-TRANSMUTE, 2)
     MOVE 1 TO RR-MATERIAL-MIN(WS-TRANSMUTE) RR-MATERIAL-MAX(WS-TRANSMUTE) RR-RESULT-COUNT(WS-TRANSMUTE)
     MOVE "cobolcraft:turf" TO RR-RESULT-ID(WS-TRANSMUTE)
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ADDING
     INITIALIZE RC-ROW(WS-ADDING)
     MOVE "cobolcraft:test_transmute_add" TO RR-KEY(WS-ADDING)
     MOVE 4 TO RR-SERIALIZER(WS-ADDING)
     MOVE "cobolcraft:turf" TO RR-ING(WS-ADDING, 1)
     MOVE "cobolcraft:grit" TO RR-ING(WS-ADDING, 2)
     MOVE 1 TO RR-MATERIAL-MIN(WS-ADDING) RR-ADD-COUNT(WS-ADDING) RR-RESULT-COUNT(WS-ADDING)
     MOVE 2 TO RR-MATERIAL-MAX(WS-ADDING)

     MOVE "test craft transmute one greystone and one loam in a 2 x 2 grid offer the transmute recipe: 1 x turf" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(4)
     PERFORM MATCH
     MOVE WS-ROW TO WS-EDIT3
     MOVE WS-TRANSMUTE TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "row " FUNCTION TRIM(WS-EDIT) " item 4 count 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM SHOW
     PERFORM CHECK

     MOVE "test craft transmute a recipe that adds the material count: turf with two grit gives 1 + 2 results of the "
         & "input's item when the recipe's result is the input's own" TO TL-CASE
     MOVE SPACES TO RR-RESULT-ID(WS-ADDING)
     PERFORM CLEAR-GRID
     MOVE 4 TO WS-G(1)
     MOVE 5 TO WS-G(2) WS-G(3)
     PERFORM MATCH
     MOVE WS-ADDING TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "row " FUNCTION TRIM(WS-EDIT) " item 4 count 3" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM SHOW
     PERFORM CHECK

     MOVE "test craft transmute another item, no material, or the input twice matches no transmute recipe" TO TL-CASE
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE 7 TO WS-G(3)
     PERFORM MATCH
     MOVE WS-ROW TO WS-EDIT
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     PERFORM MATCH
     MOVE WS-ROW TO WS-EDIT2
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1) WS-G(2)
     PERFORM MATCH
     MOVE WS-ROW TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "foreign " FUNCTION TRIM(WS-EDIT) " alone " FUNCTION TRIM(WS-EDIT2) " twice "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "foreign 0 alone 0 twice 0" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

 CLEAR-GRID.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 9
         MOVE 0 TO WS-G(WS-ROW)
     END-PERFORM.

 MATCH.
     CALL "CRAFT-MATCH" USING WS-W WS-H WS-GRID WS-ROW WS-ITEM WS-COUNT.

 SHOW.
     MOVE WS-ROW TO WS-EDIT
     MOVE WS-ITEM TO WS-EDIT2
     MOVE WS-COUNT TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "row " FUNCTION TRIM(WS-EDIT) " item " FUNCTION TRIM(WS-EDIT2) " count " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CRAFT-TRANSMUTE.
 COPY CORETEST.
