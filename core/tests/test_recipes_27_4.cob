*> Test of the recipe book and unlocking rules (docs/protocol/27 section 4; core/src/recipes-27.cob): the server recipe
*> book operations of 4.4 (add, remove, seen, settings, copy at respawn, a special recipe never known), the display ids
*> of 4.2 (contiguous, several for a transmute recipe), the group numbers (first seen, shared by all types) and the
*> limited_crafting rule of 4.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY RECBOOK.
 01 WS-P1                  BINARY-LONG VALUE 1.
 01 WS-P2                  BINARY-LONG VALUE 2.
 01 WS-R                   BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-SP                  BINARY-LONG.
 01 WS-KN                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE RC-COUNT TO WS-BASE
     PERFORM ADD-ROWS
     CALL "RECBOOK-RESET" USING WS-P1
     CALL "RECBOOK-RESET" USING WS-P2

     MOVE "acceptance US9 27§4 Recipe book and unlocking addRecipes: a new recipe is added and highlighted, a known "
         & "one is not added again, a special recipe never is" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-R
     PERFORM ADD-RECIPE
     PERFORM ADD-RECIPE
     MOVE WS-SPECIAL TO WS-R
     PERFORM ADD-RECIPE
     MOVE 1 TO WS-R
     PERFORM SHOW-STATE
     MOVE WS-SPECIAL TO WS-R
     PERFORM SHOW-STATE
     MOVE "added 1 added 0 added 0 known 1 high 1 known 0 high 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§4 Recipe book and unlocking seen removes the highlight only; removeRecipes removes a "
         & "known recipe once and does nothing for an unknown one" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-R
     CALL "RECBOOK-SEEN" USING WS-P1 WS-R
     PERFORM SHOW-STATE
     CALL "RECBOOK-REMOVE" USING WS-P1 WS-R WS-RES
     MOVE WS-RES TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " removed " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     CALL "RECBOOK-REMOVE" USING WS-P1 WS-R WS-RES
     MOVE WS-RES TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " removed " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     PERFORM SHOW-STATE
     MOVE "known 1 high 0 removed 1 removed 0 known 0 high 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§4 Recipe book and unlocking settings are stored per book type, and the book of the "
         & "old player is copied over at respawn (known, highlight, settings)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 2 TO WS-R
     CALL "RECBOOK-ADD" USING WS-P1 WS-R WS-RES
     MOVE 2 TO WS-TYPE
     MOVE 1 TO WS-OPEN
     MOVE 0 TO WS-FILTER
     CALL "RECBOOK-SETTING" USING WS-P1 WS-TYPE WS-OPEN WS-FILTER
     CALL "RECBOOK-COPY" USING WS-P1 WS-P2
     CALL "RECBOOK-CONTAINS" USING WS-P2 WS-R WS-RES
     MOVE WS-RES TO WS-EDIT
     MOVE RB-OPEN(2, 3) TO WS-EDIT2
     STRING "copy known " FUNCTION TRIM(WS-EDIT) " open " FUNCTION TRIM(WS-EDIT2) " other "
         RB-OPEN(2, 1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "copy known 1 open 1 other 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§4 Recipe book and unlocking display ids are contiguous: one per recipe, one per "
         & "material count of a transmute recipe" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-R
     PERFORM SHOW-FIRST
     MOVE WS-T TO WS-R
     PERFORM SHOW-FIRST
     MOVE WS-S TO WS-R
     PERFORM SHOW-FIRST
     COMPUTE WS-ID = WS-BASE + 2
     PERFORM SHOW-ROW
     COMPUTE WS-ID = WS-BASE + 3
     PERFORM SHOW-ROW
     MOVE 99999 TO WS-ID
     PERFORM SHOW-ROW
     MOVE WS-BASE TO WS-EDIT
     COMPUTE WS-ID = WS-BASE + 3
     MOVE WS-ID TO WS-EDIT2
     MOVE WS-T TO WS-N
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-S TO WS-IDX
     STRING "first 0 first " FUNCTION TRIM(WS-EDIT) " first " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE WS-N TO WS-EDIT
     MOVE WS-IDX TO WS-EDIT2
     STRING FUNCTION TRIM(TL-EXPECTED) " row " FUNCTION TRIM(WS-EDIT) "/2 row " FUNCTION TRIM(WS-EDIT2)
         "/0 row 0/0" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§4 Recipe book and unlocking group numbers: empty group none, others by first "
         & "appearance across all types, on the wire index + 1" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     COMPUTE WS-R = WS-S + 1
     PERFORM SHOW-GROUP
     ADD 1 TO WS-R
     PERFORM SHOW-GROUP
     ADD 1 TO WS-R
     PERFORM SHOW-GROUP
     MOVE 1 TO WS-R
     PERFORM SHOW-GROUP
     MOVE "g 1 g 2 g 1 g 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§4 Recipe book and unlocking limited_crafting: usable when special, or the rule is "
         & "off, or the recipe is known" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-RULE FROM 0 BY 1 UNTIL WS-RULE > 1
         PERFORM VARYING WS-SP FROM 0 BY 1 UNTIL WS-SP > 1
             PERFORM VARYING WS-KN FROM 0 BY 1 UNTIL WS-KN > 1
                 CALL "RECIPE-LIMITED-USABLE" USING WS-RULE WS-SP WS-KN WS-RES
                 MOVE WS-RES TO WS-EDIT
                 STRING FUNCTION TRIM(WS-TEXT) FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "11110111" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Rows past the content: a transmute recipe T (material_count 1 to 3), a plain row S, then three rows with groups
*> alpha, beta, alpha, and a special row.
 ADD-ROWS.
     PERFORM ADD-ONE
     MOVE RC-COUNT TO WS-T
     MOVE 4 TO RR-SERIALIZER(RC-COUNT)
     MOVE 3 TO RR-MATERIAL-MAX(RC-COUNT)
     PERFORM ADD-ONE
     MOVE RC-COUNT TO WS-S
     PERFORM ADD-ONE
     MOVE "alpha" TO RR-GROUP(RC-COUNT)
     PERFORM ADD-ONE
     MOVE "beta" TO RR-GROUP(RC-COUNT)
     PERFORM ADD-ONE
     MOVE "alpha" TO RR-GROUP(RC-COUNT)
     PERFORM ADD-ONE
     MOVE RC-COUNT TO WS-SPECIAL
     MOVE 1 TO RR-SPECIAL(RC-COUNT).

 ADD-ONE.
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_row" TO RR-KEY(RC-COUNT)
     MOVE 1 TO RR-SERIALIZER(RC-COUNT)
     MOVE 1 TO RR-MATERIAL-MIN(RC-COUNT) RR-MATERIAL-MAX(RC-COUNT).

 ADD-RECIPE.
     CALL "RECBOOK-ADD" USING WS-P1 WS-R WS-RES
     MOVE WS-RES TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " added " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 SHOW-STATE.
     STRING FUNCTION TRIM(WS-TEXT) " known " RB-KNOWN(1, WS-R) " high " RB-HIGHLIGHT(1, WS-R)
         DELIMITED BY SIZE INTO WS-TEXT.

 SHOW-FIRST.
     CALL "RECIPE-DISPLAY-FIRST" USING WS-R WS-ID
     MOVE WS-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " first " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 SHOW-GROUP.
     CALL "RECIPE-GROUP-NUMBER" USING WS-R WS-ID
     MOVE WS-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " g " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 SHOW-ROW.
     CALL "RECIPE-DISPLAY-ROW" USING WS-ID WS-R WS-IDX
     MOVE WS-R TO WS-EDIT
     MOVE WS-IDX TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " row " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.
 END PROGRAM TEST-RECIPES-27-4.

 COPY CORETEST.
