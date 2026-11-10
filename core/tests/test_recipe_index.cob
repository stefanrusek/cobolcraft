*> Test of the unlock check's skip (core/src/recipe-packets.cob RECIPE-NEW-ITEM, recipe-unlock.cob CRAFT-REFRESH-ALL; docs/protocol/27
*> section 5.9; T3659): an "inventory_changed" criterion asks whether a slot holds one of its items, so only an item that no slot
*> held at the last check can make a recipe newly known. A change of counts or an item moving between slots runs no scan of
*> the recipe store; a new item runs the check, and a recipe that wants it unlocks. With a synthetic store of 1,700 recipes with
*> one unlock criterion each (the size of the standard set) 400 inventory changes of counts take a measured time (named in
*> the case title, in hundredths of a second) and one full check over the store another; without the skip each of the 400
*> changes would cost a full check.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY RECBOOK.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CARDSTACK-ROW       BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(20).
 01 WS-NUMBER              PIC 9(4).
 01 WS-STAMP               PIC X(21).
 01 WS-START               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-REFRESH             BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM ADD-RECIPES
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     CALL "CRAFT-REFRESH-ALL"

     MOVE "test recipe index a change of counts and an item that moves between slots is no new item" TO TL-CASE
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-A
     SUBTRACT 1 FROM PL-SLOT-COUNT(WS-ROW, 1)
     CALL "RECIPE-NEW-ITEM" USING WS-ROW WS-NEW
     MOVE WS-NEW TO WS-A
     CALL "CRAFT-REFRESH-ALL"
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO PL-SLOT-ITEM(WS-ROW, 20)
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO PL-SLOT-COUNT(WS-ROW, 20)
     MOVE 0 TO PL-SLOT-ITEM(WS-ROW, 1) PL-SLOT-COUNT(WS-ROW, 1)
     CALL "RECIPE-NEW-ITEM" USING WS-ROW WS-NEW
     MOVE WS-NEW TO WS-B
     CALL "CRAFT-REFRESH-ALL"
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING "counts " FUNCTION TRIM(WS-EDIT) " moved " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "counts 0 moved 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipe index an item the inventory did not hold is a new item, and the recipe that wants it becomes known" TO TL-CASE
     MOVE 12 TO PL-SLOT-ITEM(WS-ROW, 3)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 3)
     CALL "RECIPE-NEW-ITEM" USING WS-ROW WS-NEW
     MOVE WS-NEW TO WS-A
     CALL "CRAFT-REFRESH-ALL"
     MOVE RB-KNOWN(WS-ROW, WS-CARDSTACK-ROW) TO WS-B
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING "new " FUNCTION TRIM(WS-EDIT) " known " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "new 1 known 1" TO TL-EXPECTED
     PERFORM CHECK

     PERFORM STAMP
     MOVE WS-START TO WS-STOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         ADD 1 TO PL-SLOT-COUNT(WS-ROW, 5)
         MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 5)
         CALL "CRAFT-REFRESH-ALL"
     END-PERFORM
     MOVE WS-START TO WS-REFRESH
     PERFORM STAMP
     COMPUTE WS-REFRESH = WS-START - WS-STOP
     MOVE WS-START TO WS-STOP
     CALL "RECIPE-UNLOCK-CHECK" USING WS-ROW
     PERFORM STAMP
     COMPUTE WS-FULL = WS-START - WS-STOP
     MOVE WS-REFRESH TO WS-EDIT
     MOVE WS-FULL TO WS-EDIT2
     MOVE SPACES TO TL-CASE
     STRING "test recipe index 400 count changes with 1700 unlock criteria take " FUNCTION TRIM(WS-EDIT)
         " hundredths of a second, one full check over them " FUNCTION TRIM(WS-EDIT2) " (the count changes run no scan)"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     IF WS-REFRESH < 100
         MOVE "fast" TO TL-OBSERVED
     ELSE
         MOVE "slow" TO TL-OBSERVED
     END-IF
     MOVE "fast" TO TL-EXPECTED
     PERFORM CHECK
     GOBACK.

*> 1,700 recipes with one inventory_changed criterion each naming an item the test never holds (cobolcraft:never_N), and a recipe
*> that wants the grazer_flank (item 12, not in the starting kit) at row WS-CARDSTACK-ROW.
 ADD-RECIPES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1700
         ADD 1 TO RC-COUNT
         INITIALIZE RC-ROW(RC-COUNT)
         MOVE "cobolcraft:test_index" TO RR-KEY(RC-COUNT)
         MOVE 1 TO RR-SERIALIZER(RC-COUNT) RR-ING-COUNT(RC-COUNT) RR-RESULT-COUNT(RC-COUNT)
         MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1)
         MOVE "cobolcraft:loam" TO RR-RESULT-ID(RC-COUNT)
         ADD 1 TO RC-UNLOCK-COUNT
         MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(RC-COUNT)
         MOVE 1 TO RR-UNLOCK-N(RC-COUNT)
         MOVE "inventory_changed" TO RU-TRIGGER(RC-UNLOCK-COUNT)
         MOVE WS-I TO WS-NUMBER
         MOVE SPACES TO RU-ITEMS(RC-UNLOCK-COUNT)
         STRING "cobolcraft:never_" WS-NUMBER DELIMITED BY SIZE INTO RU-ITEMS(RC-UNLOCK-COUNT)
         IF WS-I = 1700
             MOVE "cobolcraft:grazer_flank" TO RU-ITEMS(RC-UNLOCK-COUNT)
             MOVE RC-COUNT TO WS-CARDSTACK-ROW
         END-IF
     END-PERFORM.

*> WS-START: hundredths of a second since midnight.
 STAMP.
     MOVE FUNCTION CURRENT-DATE TO WS-STAMP
     COMPUTE WS-START = FUNCTION NUMVAL(WS-STAMP(9:2)) * 360000 + FUNCTION NUMVAL(WS-STAMP(11:2)) * 6000
         + FUNCTION NUMVAL(WS-STAMP(13:2)) * 100 + FUNCTION NUMVAL(WS-STAMP(15:2)).

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPE-INDEX.
 COPY CORETEST.
