*> Test of the crafting recipe families beyond shaped and shapeless (docs/protocol/27 section 2; core/src/recipes-27.cob):
*> transmute (2.4: the non-empty count within [min + 1, max + 1], one input, counted materials, the result size and
*> the refusal of a result equal to the input), repair item (2.13: the formula), imbue (2.9: 3 x 3 with the source in
*> the centre), decorated pot (2.10: four named cells) and the firework rocket (2.12: one shell, 1 to 3 fuel).
*> Items: greystone 2, loam 3, grit 5 of the cobolcraft content set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-27-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DMG                 BINARY-LONG.
 01 WS-MAX-A               BINARY-LONG.
 01 WS-DMG-A               BINARY-LONG.
 01 WS-MAX-B               BINARY-LONG.
 01 WS-DMG-B               BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-ROW-D               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SRC                 PIC X(800).
 01 WS-MAT                 PIC X(800).
 01 WS-STAR                PIC X(800).
 01 WS-FLIGHT              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM ADD-TRANSMUTE-ROWS

     MOVE "acceptance US9 27§2 Crafting recipes transmute: input plus one material matches; the input alone, "
         & "two materials over the maximum, another item and no input do not" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-ROW-A TO WS-ROW
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE 3 TO WS-G(3)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 5 TO WS-G(2)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 3 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     PERFORM ADD-TM
     MOVE "1/1 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes transmute with material_count 1 to 3 and the add flag: the result "
         & "count is the template count plus the materials" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-ROW-B TO WS-ROW
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(5)
     MOVE 3 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE 3 TO WS-G(9)
     PERFORM ADD-TM
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE 3 TO WS-G(3)
     MOVE 3 TO WS-G(4)
     MOVE 3 TO WS-G(5)
     PERFORM ADD-TM
     MOVE "1/2 1/4 0/0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes transmute: a result of size 1 equal to the input item, or with "
         & "no id, does not match (a shulker box dyed its own colour)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE WS-ROW-C TO WS-ROW
     PERFORM ADD-TM
     MOVE WS-ROW-D TO WS-ROW
     PERFORM ADD-TM
     MOVE "0/0 0/0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes repair item: remaining = remA + remB + max * 5 / 100, "
         & "damage = max(M - remaining, 0)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 100 TO WS-MAX-A WS-MAX-B
     MOVE 30 TO WS-DMG-A
     MOVE 50 TO WS-DMG-B
     PERFORM ADD-REPAIR
     MOVE 90 TO WS-DMG-A WS-DMG-B
     PERFORM ADD-REPAIR
     MOVE 200 TO WS-MAX-A
     MOVE 150 TO WS-DMG-A
     MOVE 80 TO WS-DMG-B
     PERFORM ADD-REPAIR
     MOVE 33 TO WS-MAX-A WS-MAX-B
     MOVE 30 TO WS-DMG-A WS-DMG-B
     PERFORM ADD-REPAIR
     MOVE "100/0 100/75 200/120 33/26" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes imbue: the source in the centre of a full 3 x 3 grid, the "
         & "material in the eight other cells" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-SRC
     MOVE "cobolcraft:loam" TO WS-MAT
     MOVE SPACES TO WS-TEXT
     PERFORM FILL-IMBUE
     PERFORM ADD-IMBUE
     MOVE 3 TO WS-G(5)
     PERFORM ADD-IMBUE
     MOVE 2 TO WS-G(5)
     MOVE 2 TO WS-G(1)
     PERFORM ADD-IMBUE
     PERFORM FILL-IMBUE
     MOVE 0 TO WS-G(9)
     PERFORM ADD-IMBUE
     PERFORM FILL-IMBUE
     MOVE 2 TO WS-G(2)
     PERFORM ADD-IMBUE
     MOVE "1 0 0 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes decorated pot: exactly four stacks in back, left, right, front"
         TO TL-CASE
     MOVE "cobolcraft:loam cobolcraft:grit" TO WS-MAT
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID
     MOVE 3 TO WS-G(2) WS-G(4)
     MOVE 5 TO WS-G(6) WS-G(8)
     PERFORM ADD-POT
     MOVE 3 TO WS-G(1)
     PERFORM ADD-POT
     MOVE 0 TO WS-G(1)
     MOVE 0 TO WS-G(8)
     MOVE 5 TO WS-G(9)
     PERFORM ADD-POT
     MOVE 0 TO WS-G(9)
     MOVE 2 TO WS-G(8)
     PERFORM ADD-POT
     MOVE "1 0 0 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US9 27§2 Crafting recipes firework rocket: one shell, one to three fuel, any stars; the "
         & "flight duration is the fuel count" TO TL-CASE
     MOVE "cobolcraft:greystone" TO WS-SRC
     MOVE "cobolcraft:loam" TO WS-MAT
     MOVE "cobolcraft:grit" TO WS-STAR
     MOVE SPACES TO WS-TEXT
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     PERFORM ADD-ROCKET
     MOVE 3 TO WS-G(3) WS-G(4)
     MOVE 5 TO WS-G(5)
     PERFORM ADD-ROCKET
     MOVE 3 TO WS-G(6)
     PERFORM ADD-ROCKET
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1) WS-G(2)
     MOVE 3 TO WS-G(3)
     PERFORM ADD-ROCKET
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     PERFORM ADD-ROCKET
     PERFORM CLEAR-GRID
     MOVE 2 TO WS-G(1)
     MOVE 3 TO WS-G(2)
     MOVE 9 TO WS-G(3)
     PERFORM ADD-ROCKET
     MOVE "1/1 1/3 0/0 0/0 0/0 0/0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLEAR-GRID.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-G(WS-I)
     END-PERFORM.

 FILL-IMBUE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 3 TO WS-G(WS-I)
     END-PERFORM
     MOVE 2 TO WS-G(5).

 ADD-TM.
     CALL "RECIPE-TRANSMUTE-MATCH" USING WS-ROW WS-GRID WS-MATCHED WS-COUNT
     MOVE WS-MATCHED TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.

 ADD-REPAIR.
     CALL "RECIPE-REPAIR" USING WS-MAX-A WS-DMG-A WS-MAX-B WS-DMG-B WS-MAX WS-DMG
     MOVE WS-MAX TO WS-EDIT
     MOVE WS-DMG TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.

 ADD-IMBUE.
     CALL "RECIPE-CENTRE-MATCH" USING WS-GRID WS-SRC WS-MAT WS-MATCHED
     MOVE WS-MATCHED TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 ADD-POT.
     CALL "RECIPE-POT-MATCH" USING WS-GRID WS-MAT WS-MATCHED
     MOVE WS-MATCHED TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 ADD-ROCKET.
     CALL "RECIPE-ROCKET-MATCH" USING WS-GRID WS-SRC WS-MAT WS-STAR WS-MATCHED WS-FLIGHT
     MOVE WS-MATCHED TO WS-EDIT
     MOVE WS-FLIGHT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO WS-TEXT.

*> Four synthetic transmute rows: A the default (1 to 1 material, result sod_cake x1), B (1 to 3 materials, add flag),
*> C (result greystone x1, the input's own item), D (no result id).
 ADD-TRANSMUTE-ROWS.
     PERFORM ADD-ONE-ROW
     MOVE RC-COUNT TO WS-ROW-A
     PERFORM ADD-ONE-ROW
     MOVE RC-COUNT TO WS-ROW-B
     MOVE 3 TO RR-MATERIAL-MAX(RC-COUNT)
     MOVE 1 TO RR-ADD-COUNT(RC-COUNT)
     PERFORM ADD-ONE-ROW
     MOVE RC-COUNT TO WS-ROW-C
     MOVE "cobolcraft:greystone" TO RR-RESULT-ID(RC-COUNT)
     PERFORM ADD-ONE-ROW
     MOVE RC-COUNT TO WS-ROW-D
     MOVE SPACES TO RR-RESULT-ID(RC-COUNT).

 ADD-ONE-ROW.
     ADD 1 TO RC-COUNT
     INITIALIZE RC-ROW(RC-COUNT)
     MOVE "cobolcraft:test_transmute" TO RR-KEY(RC-COUNT)
     MOVE 4 TO RR-SERIALIZER(RC-COUNT)
     MOVE 2 TO RR-ING-COUNT(RC-COUNT)
     MOVE "cobolcraft:greystone" TO RR-ING(RC-COUNT, 1)
     MOVE "cobolcraft:loam" TO RR-ING(RC-COUNT, 2)
     MOVE 1 TO RR-MATERIAL-MIN(RC-COUNT) RR-MATERIAL-MAX(RC-COUNT)
     MOVE "cobolcraft:sod_cake" TO RR-RESULT-ID(RC-COUNT)
     MOVE 1 TO RR-RESULT-COUNT(RC-COUNT).
 END PROGRAM TEST-RECIPES-27-2.

 COPY CORETEST.
