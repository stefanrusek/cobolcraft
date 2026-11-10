*> Test US12-client (spec 002, step 3 of the UI7 follow-up; docs/protocol/40-menus-7-creative-inventory.md sections 1, 3, 5, 6, 7, 9): the creative inventory through the real screen stack at GUI
*> 320 x 240 (left 62, top 52). In creative mode the inventory key opens it instead of the survival-style inventory screen; it draws the displayed tabs (26 x 32 boxes: the selected one marked),
*> the 45 grid slots (arguments 901 to 945, item cells at (left + 9 + 18 col, top + 18 + 18 row)) and the 9 hotbar slots (arguments 0 to 8 at y top + 112); a tab click selects the tab and fills
*> the grid; a grid click picks the stack up, a hotbar click puts it down and sends Set Creative Mode Slot (36 + slot); a click outside the image drops the carried stack (slot -1); typing in
*> the search tab filters; the inventory key closes it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-7-SCREEN.
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
*>   The widgets: tabs (selected marked), the first and last grid slot, the first and last hotbar slot.
     MOVE "T" TO TL-MODE
     PERFORM TAB-LIST
     MOVE "acceptance US12 40-7§3.1 the displayed tabs (building blocks, saved hotbars, search, tools, food, ingredients, survival inventory) are 26 x 32 boxes: the building blocks tab (62, 24) is selected" TO TL-CASE
     MOVE "S62:24 N204:24 N231:24 N62:184 N116:184 N143:184 N231:184 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM SLOT-LIST
     MOVE "acceptance US12 40-7§6.2 the grid slot 901 is at (70, 69), 945 at (214, 141), the hotbar slots 0 and 8 at (70, 163) and (214, 163): widgets are 18 x 18 cells 1 pixel out of the item cells" TO TL-CASE
     MOVE "0@70:163 8@214:163 901@70:69 945@214:141 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Select the tools tab (a click in its box at (75, 200)).
     MOVE 75 TO WS-D1
     MOVE 200 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§3.3 a click on the tools tab selects it: tab 8, 2 stacks, the first is item 10 (pry_bar)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 8 * 10000 + 2 * 100 + 10
     COMPUTE TL-OBSERVED-N = CR-TAB * 10000 + CR-COUNT * 100 + CR-STACK-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Pick up the first stack (grid slot 901 item cell (71, 70)): carried item 10 x 1.
     MOVE 75 TO WS-D1
     MOVE 75 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§7.3 a left click on a grid slot picks its stack up: carried 10 x 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 * 100 + 1
     COMPUTE TL-OBSERVED-N = PL-CARRIED-ITEM * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Put it down on hotbar slot 0 (item cell (71, 164)): Set Creative Mode Slot 36.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 75 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM CLICK-GUI
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§7.4 a click on the empty hotbar slot 0 puts the stack down and sends Set Creative Mode Slot 36 (0024) with 10 x 1: 39 0024 01 0a 00 00" TO TL-CASE
     MOVE "39002401" TO TL-EXPECTED
     MOVE WS-HEX(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§7.4 and the hotbar holds it, the cursor is empty" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 * 100 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(1) * 100 + PL-SLOT-COUNT(1) + PL-CARRIED-COUNT * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A click outside the image with a carried stack drops it (Set Creative Mode Slot -1).
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 5 TO PL-CARRIED-COUNT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 1 TO WS-D1
     MOVE 1 TO WS-D2
     PERFORM CLICK-GUI
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§7.5 a left click outside the image drops the whole carried stack: 39 ffff 05 03 00 00" TO TL-CASE
     MOVE "39ffff05030000" TO TL-EXPECTED
     MOVE WS-HEX(1:14) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The search tab: typing flank filters to the two flanks.
     MOVE 236 TO WS-D1
     MOVE 34 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 5 TO WS-N
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4)
     MOVE 102 TO WS-A(1)
     MOVE 108 TO WS-A(2)
     MOVE 97 TO WS-A(3)
     MOVE 110 TO WS-A(4)
     MOVE 4 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 107 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-7§8.1 typing flank in the search tab leaves the 2 flanks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 7 * 100 + 2
     COMPUTE TL-OBSERVED-N = CR-TAB * 100 + CR-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Backspace in the search box removes a character: flan leaves the search list.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-BACKSPACE TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§8.1 Backspace in the search box refilters: flan finds the 2 flanks, the query is 4 characters" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 402
     COMPUTE TL-OBSERVED-N = CR-QUERY-LEN * 100 + CR-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hotbar clicks: take the stack back (the carried stack was dropped by the outside click: carry nothing), merge, top up, swap.
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 75 TO WS-D1
     MOVE 168 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§7.4 a click on a hotbar slot with an item and an empty cursor takes the stack: carried 10 x 1, the slot empty" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 * 100 + 1
     COMPUTE TL-OBSERVED-N = PL-CARRIED-ITEM * 100 + PL-CARRIED-COUNT + PL-SLOT-COUNT(1) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-SLOT-ITEM(1)
     MOVE 60 TO PL-SLOT-COUNT(1)
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE 10 TO PL-CARRIED-COUNT
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§7.4 the same item tops the slot up to 64 and keeps the rest on the cursor: slot 64, cursor 6" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 100 + 6
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO PL-SLOT-COUNT(1)
     MOVE 2 TO PL-CARRIED-COUNT
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§7.4 a stack that fits is put in whole: slot 62, the cursor empty" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 62 * 100 + 0
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO PL-CARRIED-ITEM
     MOVE 5 TO PL-CARRIED-COUNT
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-7§7.4 another item swaps: the slot holds 4 x 5, the cursor 3 x 62" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 100000 + 5 * 1000 + 3 * 100 + 62
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(1) * 100000 + PL-SLOT-COUNT(1) * 1000 + PL-CARRIED-ITEM * 100 + PL-CARRIED-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
*>   Escape closes (the inventory key would type into the search box).
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-ESCAPE TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§1 Escape closes the creative screen: the world" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A tab that is not displayed gives the default tab when the screen opens: the remembered tab 3 (natural blocks, empty).
     MOVE 3 TO CR-TAB
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§1 a remembered tab that is not displayed (natural blocks, empty) gives the default tab 1 when the screen opens" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-CREATIVE * 100 + 1
     COMPUTE TL-OBSERVED-N = SM-SCREEN * 100 + CR-TAB
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A standard content set (an empty Update Tags opens it): the building blocks list is over 45, so the scroller shows, the wheel and a drag on it scroll.
     MOVE X"00" TO WS-BODY(1:1)
     MOVE 14 TO WS-PACKET-ID
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     MOVE 1 TO WS-I
     CALL "CREATIVE-SELECT" USING CLIENT-STATE WS-I
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 12 AND SM-W-H(WS-I) = 15
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-7§6.2 with more than 45 stacks the scroller (12 x 15) is drawn at (left + 175, top + 18) = (237, 70)" TO TL-CASE
     MOVE "237:70" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-N
     INITIALIZE WS-EVENTS
     MOVE CC-EV-SCROLL TO WS-KIND(1)
     MOVE -1.0 TO WS-EY(1)
     PERFORM FRAME
     MOVE "acceptance US12 40-7§5.2 a wheel step down scrolls: the scroll is above 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CR-SCROLL > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 480 TO WS-EX(1)
     MOVE 160 TO WS-EY(1)
     MOVE WS-EX(1) TO WS-EX(2)
     MOVE WS-EY(1) TO WS-EY(2)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 480 TO WS-EX(1)
     MOVE 300 TO WS-EY(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     COMPUTE WS-MILLI ROUNDED = CR-SCROLL * 1000
     MOVE "acceptance US12 40-7§6.6 a press on the scroller and a drag to y 150: scroll (150 - 70 - 7.5) / 97 = 0.747" TO TL-CASE
     MOVE 747 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
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
 SLOT-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 945
         IF WS-N = 0 OR WS-N = 8 OR WS-N = 901 OR WS-N = 945
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
                 IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-N
                     MOVE SM-W-ARG(WS-I) TO WS-E3
                     MOVE SM-W-X(WS-I) TO WS-E1
                     MOVE SM-W-Y(WS-I) TO WS-E2
                     STRING FUNCTION TRIM(WS-E3) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-7-SCREEN.

 COPY CLTEST.
