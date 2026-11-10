*> Test US12-client (spec 002 T3190, T3191; docs/protocol/40-menus-1-model-and-containers.md section 6 and the M1 to M7 tables of parts 2 to 5): the table schema
*> every menu follows. CONTAINER-FRAME gives, for a menu type id, the own slots (head and tail), the player inventory's origin (x, y; y -1 when the menu has no
*> player inventory), the image size, the title position (x -1 centred, y -1 no title), the inventory label position (y -1 none) and the data slot count; the
*> menu slot count is own + 36 (3.3), 41 for the brewing stand, 46 for the crafter, 1 for the lectern (no player inventory).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-E                   PIC -(7)9 OCCURS 12 TIMES.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   M1 to M7 of each menu: "own+tail iy W H data title-x title-y label-x label-y" (inventory x 8 unless said).
     MOVE 14 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 furnace (14): 3 own slots, inventory at (8, 84), 176 x 166, 4 data slots, centred title at y 6, label (8, 72)" TO TL-CASE
     MOVE "3+0 8,84 176x166 d4 t-1,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 blast furnace (10) is the furnace frame" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 smoker (22) is the furnace frame" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 brewing stand (11): 5 own slots (41 in all), 4 data slots, centred title" TO TL-CASE
     MOVE "5+0 8,84 176x166 d4 t-1,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 crafter (7): 9 crafting slots and 1 result slot after the player inventory (46 in all), 10 data slots" TO TL-CASE
     MOVE "9+1 8,84 176x166 d10 t-1,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 anvil (8): 3 own slots, 1 data slot, title x 60" TO TL-CASE
     MOVE "3+0 8,84 176x166 d1 t60,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 grindstone (15): 3 own slots, no data slots, default labels" TO TL-CASE
     MOVE "3+0 8,84 176x166 d0 t8,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 21 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 smithing table (21): 4 own slots (40 in all), title (44, 15)" TO TL-CASE
     MOVE "4+0 8,84 176x166 d1 t44,15 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 enchanting table (13): 2 own slots (38 in all), 10 data slots" TO TL-CASE
     MOVE "2+0 8,84 176x166 d10 t8,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 loom (18): 4 own slots (40 in all), 1 data slot, title y 4" TO TL-CASE
     MOVE "4+0 8,84 176x166 d1 t8,4 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 stonecutter (24): 2 own slots (38 in all), 1 data slot, title y 5" TO TL-CASE
     MOVE "2+0 8,84 176x166 d1 t8,5 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 cartography table (23): 3 own slots (39 in all), no data slots, title y 4" TO TL-CASE
     MOVE "3+0 8,84 176x166 d0 t8,4 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 merchant (19): 3 own slots, inventory at (108, 84), 276 x 166, inventory label at x 107" TO TL-CASE
     MOVE "3+0 108,84 276x166 d0 t8,6 l107,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 beacon (9): 1 own slot (37 in all), inventory at (36, 137), 230 x 219, 3 data slots, no title, no inventory label" TO TL-CASE
     MOVE "1+0 36,137 230x219 d3 t-1,-1 l8,-1 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 lectern (17): 1 slot and no player inventory, 1 data slot" TO TL-CASE
     MOVE "1+0 8,-1 176x166 d1 t-1,-1 l8,-1 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 the crafting bench (12) is not a table frame (13 section 3.5)" TO TL-CASE
     MOVE "0+0 0,0 0x0 d0 t0,0 l0,0 k0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 a type id past the 25 registered ones has no frame" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 chest 6 rows (5): 54 own slots, inventory at (8, 139), 176 x 222, labels (8, 6) and (8, 128)" TO TL-CASE
     MOVE "54+0 8,139 176x222 d0 t8,6 l8,128 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-TYPE
     PERFORM CHECK-FRAME
     MOVE "acceptance US12 40-1§6 dispenser (6): 9 own slots, centred title" TO TL-CASE
     MOVE "9+0 8,84 176x166 d0 t-1,6 l8,72 k1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-FRAME.
     CALL "CONTAINER-FRAME" USING WS-TYPE WS-OWN WS-TAIL WS-IX WS-IY WS-W WS-H WS-TX WS-TY WS-LX WS-LY
         WS-DATA WS-KNOWN
     MOVE WS-OWN TO WS-E(1)
     MOVE WS-TAIL TO WS-E(2)
     MOVE WS-IX TO WS-E(3)
     MOVE WS-IY TO WS-E(4)
     MOVE WS-W TO WS-E(5)
     MOVE WS-H TO WS-E(6)
     MOVE WS-DATA TO WS-E(7)
     MOVE WS-TX TO WS-E(8)
     MOVE WS-TY TO WS-E(9)
     MOVE WS-LX TO WS-E(10)
     MOVE WS-LY TO WS-E(11)
     MOVE WS-KNOWN TO WS-E(12)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E(1)) "+" FUNCTION TRIM(WS-E(2)) " " FUNCTION TRIM(WS-E(3)) "," FUNCTION TRIM(WS-E(4))
         " " FUNCTION TRIM(WS-E(5)) "x" FUNCTION TRIM(WS-E(6)) " d" FUNCTION TRIM(WS-E(7)) " t"
         FUNCTION TRIM(WS-E(8)) "," FUNCTION TRIM(WS-E(9)) " l" FUNCTION TRIM(WS-E(10)) ","
         FUNCTION TRIM(WS-E(11)) " k" FUNCTION TRIM(WS-E(12)) DELIMITED BY SIZE INTO TL-OBSERVED
     .

 END PROGRAM TEST-SCREEN-40-1-6.
