*> Test of the other recipe families (docs/protocol/27 section 3; core/src/recipes-27.cob): the recipe book category of
*> the cooking family by cooking category (3.1), the stonecutter selection rules (3.2) and the refusal to apply the
*> same smithing trim again (3.3). The input rule of the single-input families is the ingredient test of section 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SER                 BINARY-LONG.
 01 WS-CAT-NAME            PIC X(24).
 01 WS-CATEGORY            BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OPTIONS             BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-M1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-M2                  BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     MOVE "acceptance US9 27§3 The other recipe families the category of a smelting recipe: food 4, blocks 5, "
         & "misc 6" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 14 TO WS-SER
     MOVE "food" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "blocks" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "misc" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "4 5 6" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§3 The other recipe families blasting: blocks 7, food and misc both 8; smoking "
         & "always 9; campfire cooking always 12; stonecutting 10; smithing 11" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 15 TO WS-SER
     MOVE "blocks" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "food" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "misc" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE 16 TO WS-SER
     PERFORM ADD-CAT
     MOVE 17 TO WS-SER
     PERFORM ADD-CAT
     MOVE 18 TO WS-SER
     PERFORM ADD-CAT
     MOVE 19 TO WS-SER
     PERFORM ADD-CAT
     MOVE 21 TO WS-SER
     PERFORM ADD-CAT
     MOVE "7 8 8 9 12 10 11 11" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§3 The other recipe families the crafting categories building 0, redstone 1, "
         & "equipment 2, misc 3 (the cobolcraft built-ins use building, equipment and misc); a brewing recipe 3" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-SER
     MOVE "building" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "redstone" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "equipment" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE "misc" TO WS-CAT-NAME
     PERFORM ADD-CAT
     MOVE 20 TO WS-SER
     PERFORM ADD-CAT
     MOVE "0 1 2 3 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§3 The other recipe families stonecutter button i is valid when 0 <= i < options "
         & "and differs from the current index" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 3 TO WS-OPTIONS
     MOVE -1 TO WS-CURRENT
     MOVE 0 TO WS-INDEX
     PERFORM ADD-VALID
     MOVE 2 TO WS-INDEX
     PERFORM ADD-VALID
     MOVE 3 TO WS-INDEX
     PERFORM ADD-VALID
     MOVE -1 TO WS-INDEX
     PERFORM ADD-VALID
     MOVE 1 TO WS-CURRENT WS-INDEX
     PERFORM ADD-VALID
     MOVE "1 1 0 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§3 The other recipe families smithing trim: re-applying the same pattern and "
         & "material is refused, another pair or an untrimmed base is accepted" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 4 TO WS-P1
     MOVE 7 TO WS-M1
     MOVE 4 TO WS-P2
     MOVE 7 TO WS-M2
     PERFORM ADD-TRIM
     MOVE 5 TO WS-P2
     PERFORM ADD-TRIM
     MOVE 4 TO WS-P2
     MOVE 8 TO WS-M2
     PERFORM ADD-TRIM
     MOVE 0 TO WS-P1 WS-M1
     MOVE 4 TO WS-P2
     MOVE 7 TO WS-M2
     PERFORM ADD-TRIM
     MOVE "1 0 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-CAT.
     CALL "RECIPE-BOOK-CATEGORY" USING WS-SER WS-CAT-NAME WS-CATEGORY
     MOVE WS-CATEGORY TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 ADD-VALID.
     CALL "RECIPE-STONECUT-VALID" USING WS-INDEX WS-OPTIONS WS-CURRENT WS-VALID
     MOVE WS-VALID TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 ADD-TRIM.
     CALL "RECIPE-TRIM-REFUSED" USING WS-P1 WS-M1 WS-P2 WS-M2 WS-VALID
     MOVE WS-VALID TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM TEST-RECIPES-27-3.

 COPY CORETEST.
