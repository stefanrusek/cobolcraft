*> Test US12-client (spec 002; docs/protocol/40-menus-7-creative-inventory.md 5.3, 6.4, 7.1 and 40-1 3.4): the hotbar slot clicks beyond the plain left click (a shift click on a stack deletes it and sends the
*> empty slot; a right click takes the larger half or places one), the survival inventory tab (the 27 main slots at (9 + 18 col, 54 + 18 row), the delete slot at (173, 112): a click empties the cursor, a
*> shift click empties the inventory).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-7-SLOTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-HEX                 PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 4 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-EX            FLOAT-SHORT.
       10 WS-EY            FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE 1 TO PL-MODE
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE "N" TO TL-MODE
*>   The inventory key opens the creative screen.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-E TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§1 in creative mode the inventory key opens the creative screen" TO TL-CASE
     MOVE SCR-CREATIVE TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Hotbar slot 0 holds item 5 x 7: a right click with an empty cursor takes 4.
     MOVE 5 TO PL-SLOT-ITEM(1)
     MOVE 7 TO PL-SLOT-COUNT(1)
     MOVE 75 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click on a hotbar slot with 7 items and an empty cursor takes the larger half: carried 4, slot 3" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 100 + 3
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 100 + PL-SLOT-COUNT(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Right click on the empty slot 1 with the carried 4: one is placed.
     MOVE 0 TO PL-SLOT-COUNT(2)
     MOVE 93 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click on an empty hotbar slot with a carried stack places one item: carried 3, slot 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 1
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 100 + PL-SLOT-COUNT(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
*>   Shift click on hotbar slot 0 (3 left) deletes it and sends the empty slot 36.
     MOVE CC-MOD-SHIFT TO IN-MODS
     MOVE 75 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 0 TO IN-MODS
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§5.3 a shift click on a hotbar slot with a stack deletes it and sends Set Creative Mode Slot 36 with the empty stack (39 0024 00)" TO TL-CASE
     MOVE "39002400" TO TL-EXPECTED
     MOVE WS-HEX(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§5.3 the slot is empty afterwards" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Right clicks on hotbar slots, the remaining branches: one item taken from a stack of one empties the slot; the last carried item placed; onto the same item; onto another item (swap); nothing to do.
     MOVE 5 TO PL-SLOT-ITEM(1)
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE 75 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click on a slot with one item and an empty cursor takes it: carried 1, slot empty" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 0
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 100 + PL-SLOT-COUNT(1) + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 the right click with the last carried item on the empty slot places it: carried 0, slot 1 item 5" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100 + 1 + 5
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 100 + PL-SLOT-COUNT(1) + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-CARRIED-ITEM
     MOVE 1 TO PL-CARRIED-COUNT
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click with the same item adds one: slot 2, carried 0 and the item cleared" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 100 + 0
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-CARRIED-COUNT + PL-CARRIED-ITEM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-CARRIED-ITEM
     MOVE 3 TO PL-CARRIED-COUNT
     MOVE 1 TO PL-SLOT-COUNT(1)
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click with a carried stack of 3 on the same item adds one: slot 2, carried 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 100 + 2
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO PL-SLOT-COUNT(1)
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 onto a full stack nothing is added: slot 64, carried 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 100 + 2
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO PL-CARRIED-ITEM
     MOVE 4 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-SLOT-COUNT(1)
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click with another item swaps the stacks: slot item 6 x 4, carried item 5 x 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 6 * 100000 + 4 * 1000 + 5 * 100 + 2
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(1) * 100000 + PL-SLOT-COUNT(1) * 1000 + PL-CARRIED-ITEM * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 0 TO PL-SLOT-COUNT(1)
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a right click on an empty slot with an empty cursor does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT + PL-SLOT-COUNT(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The survival tab (tab 14 at (231, 200)): main slots and the delete slot.
     MOVE 245 TO WS-D1
     MOVE 200 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 the survival inventory tab is selected by a click on it: tab 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE CR-TAB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM MAIN-LIST
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§6.4 the survival tab holds the main slots 9 at (70, 105), 35 at (214, 141) and the delete slot at (234, 163)" TO TL-CASE
     MOVE "9@70:105 35@214:141 D@234:163 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 3 TO PL-SLOT-ITEM(10)
     MOVE 2 TO PL-SLOT-COUNT(10)
     MOVE 75 TO WS-D1
     MOVE 110 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 a click on the main slot 9 takes its stack: carried 3 x 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 2
     COMPUTE TL-OBSERVED-N = PL-CARRIED-ITEM * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 240 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§5.3 a click on the delete slot empties the cursor" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-CARRIED-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO PL-SLOT-COUNT(11)
     MOVE 3 TO PL-SLOT-ITEM(11)
     MOVE CC-MOD-SHIFT TO IN-MODS
     MOVE 240 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 0 TO IN-MODS
     MOVE "acceptance US12 40-7§7.1 rule 8: a shift click on the delete slot empties the whole inventory" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(11) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-SLOT-ITEM(10)
     MOVE 4 TO PL-SLOT-COUNT(10)
     MOVE 75 TO WS-D1
     MOVE 110 TO WS-D2
     PERFORM RIGHT-CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 a right click on the main slot 9 takes half of its stack: carried 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 100 + 2
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT * 100 + PL-SLOT-COUNT(10)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Armour and off-hand wrappers of the survival tab: the helmet slot at (54, 6), a swap; the off-hand slot at (35, 20), a take and a place.
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 4 TO IX-ITEM(1)
     MOVE 1 TO IX-COUNT(1)
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 2 TO PL-CARRIED-COUNT
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE 120 TO WS-D1
     MOVE 62 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 a click on the survival tab's helmet wrapper (62 + 54, 52 + 6) swaps: the slot holds item 3 x 2, the cursor item 4 x 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 10000 + 2 * 1000 + 4 * 10 + 1
     COMPUTE TL-OBSERVED-N = IX-ITEM(1) * 10000 + IX-COUNT(1) * 1000 + PL-CARRIED-ITEM * 10 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-OFFHAND-COUNT
     MOVE 100 TO WS-D1
     MOVE 78 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 the cursor stack goes into the empty off-hand wrapper (35, 20)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 10 + 1
     COMPUTE TL-OBSERVED-N = PL-OFFHAND-ITEM * 10 + PL-OFFHAND-COUNT + PL-CARRIED-COUNT * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 and a second click takes it back: cursor 4 x 1, off-hand empty" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 10 + 1
     COMPUTE TL-OBSERVED-N = PL-CARRIED-ITEM * 10 + PL-CARRIED-COUNT + PL-OFFHAND-COUNT * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 120 TO WS-D1
     MOVE 62 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM CLICK-GUI
     MOVE 0 TO PL-CARRIED-COUNT
     MOVE 0 TO IX-COUNT(2)
     MOVE 120 TO WS-D1
     MOVE 90 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§6.4 a click on the empty chestplate wrapper with an empty cursor does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-CARRIED-COUNT + IX-COUNT(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> A click on the GUI point (WS-D1, WS-D2) (GUI scale 2).
 CLICK-GUI.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-EX(1) = WS-D1 * 2
     COMPUTE WS-EY(1) = WS-D2 * 2
     MOVE WS-EX(1) TO WS-EX(2) WS-EX(3)
     MOVE WS-EY(1) TO WS-EY(2) WS-EY(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> The tab boxes (26 x 32 overlays) as "Sx:y " (selected swatch) or "Nx:y ".
 TAB-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 26 AND SM-W-H(WS-I) = 32
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             IF SM-W-ARG(WS-I) = SW-SELECTED
                 STRING "S" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             ELSE
                 STRING "N" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     .

*> Slot widgets: the hotbar arguments 0 and 8 and the grid arguments 901 and 945 as "argument@x:y ", in argument order.
*> TL-OBSERVED: main slot widgets 9 and 35 and the delete slot (argument 99) as arg@x:y.
 MAIN-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF (SM-W-KIND(WS-I) = WK-SLOT AND (SM-W-ARG(WS-I) = 9 OR SM-W-ARG(WS-I) = 35)) OR (SM-W-ACTION(WS-I) = ACT-CREATIVE-HOTBAR AND SM-W-ARG(WS-I) = 99)
             MOVE SM-W-ARG(WS-I) TO WS-E3
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             IF SM-W-ARG(WS-I) = 99
                 STRING "D@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             ELSE
                 STRING FUNCTION TRIM(WS-E3) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     .

*> A right click on the GUI point (WS-D1, WS-D2).
 RIGHT-CLICK-GUI.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-EX(1) = WS-D1 * 2
     COMPUTE WS-EY(1) = WS-D2 * 2
     MOVE WS-EX(1) TO WS-EX(2) WS-EX(3)
     MOVE WS-EY(1) TO WS-EY(2) WS-EY(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-BUTTON-RIGHT TO WS-A(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE CC-BUTTON-RIGHT TO WS-A(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

 END PROGRAM TEST-SCREEN-40-7-SLOTS.

 COPY CLTEST.
