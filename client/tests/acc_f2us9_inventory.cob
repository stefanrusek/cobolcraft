*> Acceptance test US9-1, US9-3 (spec 002 FR-024, FR-025, FR-028; SC-005; 12 §5.6a; 13 §3.5; contract/fixtures/wire/play-s2c-12-container-
*> set-content-46-slots.hex): the Container Set Content of the 46-slot inventory menu fills the replica (hotbar slot 0 64 x stone, the
*> damaged stone with its damage in hotbar 4, the cobblestone in the off hand, 5 oak planks on the cursor, state id 3); the inventory screen
*> lays the menu out at the places of 12 §5.6a on the 176 x 166 sheet (leftPos 72, topPos 37 at 320 x 240): the title, 46 bare slots 18 x 18
*> around the 16 x 16 icon cells, none missing; a click on the slot of the off hand, armour, grid, result, main inventory and hotbar sends
*> Container Click with the menu's slot number (45, 5, 1, 0, 9, 36).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US9-INVENTORY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 15.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-E                   PIC Z(8)9.
 01 WS-CONTAINER           BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 9.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ARGS.
    05 FILLER PIC 999 VALUE 37.
    05 FILLER PIC 999 VALUE 101.
    05 FILLER PIC 999 VALUE 106.
    05 FILLER PIC 999 VALUE 105.
    05 FILLER PIC 999 VALUE 9.
    05 FILLER PIC 999 VALUE 0.
 01 WS-ARG-TABLE REDEFINES WS-ARGS.
    05 WS-CLICK-ARG        PIC 999 OCCURS 6 TIMES.
 01 WS-PLACES.
    05 FILLER PIC 9(9) VALUE 149099.
    05 FILLER PIC 9(9) VALUE 080045.
    05 FILLER PIC 9(9) VALUE 170055.
    05 FILLER PIC 9(9) VALUE 226065.
    05 FILLER PIC 9(9) VALUE 080121.
    05 FILLER PIC 9(9) VALUE 080179.
 01 WS-PLACE-TABLE REDEFINES WS-PLACES.
    05 WS-PLACE            PIC 9(9) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-46-slots.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US9-1 the 46 slots set hotbar slot 0 to 64 x stone (item 1)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 1000 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 1000 + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 menu slot 40 is hotbar slot 4: 1 x stone with damage 5" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 10000 + 1 * 10 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-DAMAGE(5) * 10000 + PL-SLOT-COUNT(5) * 10 + PL-SLOT-ITEM(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 menu slot 45 is the off hand: 1 x cobblestone (item 62)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 62
     COMPUTE TL-OBSERVED-N = PL-OFFHAND-COUNT * 1000 + PL-OFFHAND-ITEM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 the cursor holds 5 x oak planks (item 63), state id 3" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 10000 + 63 * 10 + 3
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 10000 + PL-CARRIED-ITEM * 10 + PL-INV-STATE-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 the empty slots stay empty (no crafting result)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE IX-COUNT(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The slots outside the player's 36: Container Set Slot of the menu slots 0 (the result), 3 (the grid), 5 and 8 (helmet, boots);
*>   Set Player Inventory index 38 is the chestplate (menu 6).
     MOVE 0 TO WS-SLOT
     MOVE 2 TO WS-COUNT
     MOVE 5 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE 3 TO WS-SLOT
     MOVE 3 TO WS-COUNT
     MOVE 6 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE 5 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     MOVE 7 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE 8 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     MOVE 8 TO WS-ITEM
     CALL "TEST-FEED-SET-SLOT" USING CLIENT-STATE WS-CONN WS-CONTAINER WS-STATE WS-SLOT WS-COUNT WS-ITEM
     MOVE "acceptance US9-1 menu slot 0 is the result (IX 5), slot 3 the third grid slot (IX 8)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (2 * 100 + 5) * 100000 + 3 * 100 + 6
     COMPUTE TL-OBSERVED-N = (IX-COUNT(5) * 100 + IX-ITEM(5)) * 100000 + IX-COUNT(8) * 100 + IX-ITEM(8)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 menu slot 5 is the helmet (IX 1), slot 8 the boots (IX 4); the state id is 9" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (1 * 100 + 7) * 100000 + (1 * 100 + 8) * 10 + 9
     COMPUTE TL-OBSERVED-N = (IX-COUNT(1) * 100 + IX-ITEM(1)) * 100000 + (IX-COUNT(4) * 100 + IX-ITEM(4)) * 10 + PL-INV-STATE-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The screen.
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE SCR-INVENTORY TO WS-ARG
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ARG
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) NOT = 36
             ADD 1 TO WS-N
             IF SM-W-W(WS-I) NOT = 18 OR SM-W-H(WS-I) NOT = 18 OR SM-W-STATE(WS-I) NOT = 3
                 ADD 1 TO WS-K
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US9-1 the inventory screen has 46 slot widgets of 46 menu slots (the hotbar 9, main 27, 4 armour, result, 4 grid, off hand)"
         TO TL-CASE
     MOVE 46 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US9-1 every slot widget is bare and 18 x 18" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SHEET
             COMPUTE WS-N = SM-W-ARG(WS-I) * 1000000 + SM-W-X(WS-I) * 1000 + SM-W-Y(WS-I)
             IF SM-W-W(WS-I) NOT = 176 OR SM-W-H(WS-I) NOT = 166
                 MOVE -1 TO WS-N
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US9-1 the inventory sheet is at (72, 37), 176 x 166" TO TL-CASE
     COMPUTE TL-EXPECTED-N = GSP-SHEET-INVENTORY * 1000000 + 72 * 1000 + 37
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             MOVE SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) TO WS-TEXT
             COMPUTE WS-N = SM-W-X(WS-I) * 1000 + SM-W-Y(WS-I)
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US9-1 the title is Crafting at (169, 43)" TO TL-CASE
     MOVE "Crafting 169043" TO TL-EXPECTED
     MOVE WS-N TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   Click places: the icon cell of the off hand, a helmet, the first grid slot, the result, main slot 9 and hotbar 0 at left + x, top + y
*>   (the widget is 1 pixel more on each side).
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-CLICK-ARG(WS-K)
                 COMPUTE WS-N = (SM-W-X(WS-I) + 1) * 1000 + SM-W-Y(WS-I) + 1
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         MOVE WS-CLICK-ARG(WS-K) TO WS-E
         STRING "acceptance US9-1 the slot widget of argument " FUNCTION TRIM(WS-E) " is at its place of 12 5.6a"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-PLACE(WS-K) TO TL-EXPECTED-N
         MOVE WS-N TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Container Click carries the menu's slot number: 45, 5, 1, 0, 9, 36 with container 0 and state id 3.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE WS-CLICK-ARG(WS-K) TO WS-ARG
         CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         STRING FUNCTION TRIM(TL-OBSERVED) " " WS-TEXT(1:10) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US9-3 clicks send Container Click of container 0, state 9 (the last Set Slot) and the menu slots 45, 5, 1, 0, 9 and 36"
         TO TL-CASE
     MOVE "120009002d 1200090005 1200090001 1200090000 1200090009 1200090024" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US9-INVENTORY.

 COPY CLTEST.
