*> Test of the recipe model (docs/protocol/27-recipes-and-unlocks.md section 1; core/src/recipes-27.cob): the 22
*> serializers and the 8 recipe types with the type of each serializer, the serializer ids by name, the ingredient
*> rule (an item key, a tag or several; count never inspected) and the rule that an empty input never matches.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-TYPE-NAME           PIC X(16).
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 01 WS-ING                 PIC X(800).
 01 WS-ITEM                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RITEM               BINARY-LONG.
 01 WS-RCOUNT              BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-THREE-H             BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance US9 27§1 Recipe model the 22 serializer ids map to the 8 recipe types in table order"
         TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 22
         CALL "RECIPE-SERIALIZER-TYPE" USING WS-I WS-TYPE
         MOVE WS-TYPE TO WS-EDIT
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     END-PERFORM
     MOVE "0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 6 -1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§1 Recipe model the recipe type names in registration order" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         CALL "RECIPE-TYPE-NAME" USING WS-I WS-TYPE-NAME
         IF WS-TYPE-NAME = SPACES
             MOVE "?" TO WS-TYPE-NAME
         END-IF
         STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-TYPE-NAME) DELIMITED BY SIZE INTO WS-TEXT
     END-PERFORM
     MOVE "crafting smelting blasting smoking campfire_cooking stonecutting smithing brewing ?"
         TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§1 Recipe model serializer ids by name: shaped 0, transmute 4, repairitem 13, "
         & "smelting 14, smithing_trim 21, unknown -1" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "crafting_shaped" TO WS-NAME
     PERFORM ADD-ID
     MOVE "crafting_transmute" TO WS-NAME
     PERFORM ADD-ID
     MOVE "crafting_special_repairitem" TO WS-NAME
     PERFORM ADD-ID
     MOVE "smelting" TO WS-NAME
     PERFORM ADD-ID
     MOVE "smithing_trim" TO WS-NAME
     PERFORM ADD-ID
     MOVE "crafting_nonsense" TO WS-NAME
     PERFORM ADD-ID
     MOVE "0 4 13 14 21 -1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§1 Recipe model an ingredient accepts by item identity only: a key, one of "
         & "several keys, not another item" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "cobolcraft:greystone cobolcraft:loam" TO WS-ING
     MOVE 2 TO WS-ITEM
     PERFORM ADD-TEST
     MOVE 3 TO WS-ITEM
     PERFORM ADD-TEST
     MOVE 4 TO WS-ITEM
     PERFORM ADD-TEST
     MOVE 0 TO WS-ITEM
     PERFORM ADD-TEST
     MOVE "1 1 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§1 Recipe model an empty input never matches" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-G(WS-I)
     END-PERFORM
     CALL "CRAFT-MATCH" USING WS-THREE WS-THREE-H WS-GRID WS-ROW WS-RITEM WS-RCOUNT
     MOVE WS-ROW TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-ID.
     CALL "RECIPE-SERIALIZER-ID" USING WS-NAME WS-ID
     MOVE WS-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 ADD-TEST.
     CALL "CRAFT-ING-TEST" USING WS-ITEM WS-ING WS-RESULT
     MOVE WS-RESULT TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM TEST-RECIPES-27-1.

 COPY CORETEST.
