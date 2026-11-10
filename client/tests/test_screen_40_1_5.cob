*> Test US12-client (spec 002 T3188, T3189; docs/protocol/40-menus-1-model-and-containers.md section 5.2 to 5.5): the generic container screen's pointer model. The chest menu (type 2,
*> 27 own slots; widget argument 401 + k is own slot k) at GUI 320 x 240, the stacks set directly: a left click on a slot is PICKUP (type 0, button 0) and a right click PICKUP button 1
*> (the carried stack empty); shift and left is QUICK_MOVE (1); the middle button in creative is CLONE (3); with a carried stack a press starts a drag: every slot the pointer holds
*> over is added and the release sends QUICK_CRAFT (5) packets: slot -999 button mask(0, type), each slot button mask(1, type), slot -999 button mask(2, type) (type 0 left: 0, 1, 2;
*> type 1 right: 4, 5, 6); a drag over one slot is the same three packets; a press and release with no slot added is a PICKUP; a release outside the image sends PICKUP slot -999
*> (button 0 or 1); a second left click on the same slot within 250 ms sends PICKUP_ALL (6); a hotbar key over a slot with an empty cursor sends SWAP (2) with button i, the off-hand
*> key button 40; the drop key sends THROW (4) with button 0 (Ctrl: 1); the hovered slot draws the highlight back sprite before the slots and the front sprite after (5.4).
*> Each packet is shown by its first 8 bytes: id 12, container id 09, state id 01, slot (Short), button, type, number of changed slots.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-ARG                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-PY                  FLOAT-SHORT.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-TEXT                PIC X(1024).
 01 WS-TOKEN               PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-OPTR                BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-KEYCODE             BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FIRST-SLOT          BINARY-LONG.
 01 WS-LAST-SLOT           BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 4 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE "T" TO TL-MODE
     PERFORM OPEN-TYPE
     PERFORM FRESH
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM DRAIN

     MOVE "acceptance US12 40-1§5.5 a left click on a slot with an empty cursor is PICKUP button 0 (type 0) with the changed slot" TO TL-CASE
     MOVE 401 TO WS-ARG
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK
     MOVE "1209010000000001" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a click with a carried stack on another slot is a plain PICKUP there when no slot was dragged over (press and release in one frame)" TO TL-CASE
     MOVE 403 TO WS-ARG
     PERFORM CLICK
     MOVE "1209010002000001" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a right click on a slot with an empty cursor is PICKUP button 1" TO TL-CASE
     PERFORM FRESH
     MOVE 402 TO WS-ARG
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK
     MOVE "1209010001010000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 shift and a left click is QUICK_MOVE (type 1), button 0, nothing predicted" TO TL-CASE
     PERFORM FRESH
     PERFORM SHIFT-DOWN
     MOVE 402 TO WS-ARG
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK
     MOVE "1209010001000100" TO TL-EXPECTED
     PERFORM CHECK
     PERFORM SHIFT-UP
     MOVE "acceptance US12 40-1§5.5 the middle button over a slot in creative is CLONE (type 3), button 0" TO TL-CASE
     PERFORM FRESH
     MOVE 1 TO PL-MODE
     MOVE 402 TO WS-ARG
     MOVE 2 TO WS-BUTTON
     PERFORM CLICK
     MOVE "1209010001000300" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 in creative a left click in a container is still a Container Click PICKUP (not Set Creative Mode Slot)" TO TL-CASE
     PERFORM FRESH
     MOVE 1 TO PL-MODE
     MOVE 402 TO WS-ARG
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK
     MOVE "1209010001000001" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-MODE
     MOVE "acceptance US12 40-1§5.5 a left drag over slots 3, 4 and 5 sends QUICK_CRAFT: -999 button 0, 3 b1, 4 b1, 5 b1, -999 button 2" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 404 TO WS-ARG
     PERFORM PRESS
     PERFORM HOVER-AT
     MOVE 405 TO WS-ARG
     PERFORM HOVER-AT
     MOVE 406 TO WS-ARG
     PERFORM HOVER-AT
     PERFORM LET-GO
     MOVE "120901fc19000500 1209010003010500 1209010004010500 1209010005010500 120901fc19020500" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a right drag (greedy, type 1) uses the buttons 4, 5 and 6" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE 407 TO WS-ARG
     PERFORM PRESS
     PERFORM HOVER-AT
     MOVE 408 TO WS-ARG
     PERFORM HOVER-AT
     PERFORM LET-GO
     MOVE "120901fc19040500 1209010006050500 1209010007050500 120901fc19060500" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a drag that stays over one slot sends the same three packets with a one-slot set" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 409 TO WS-ARG
     PERFORM PRESS
     PERFORM HOVER-AT
     PERFORM LET-GO
     MOVE "120901fc19000500 1209010008010500 120901fc19020500" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a slot holding another item is not added to the drag: dragging over slot 1 (20 x item 3) and slot 5 adds only slot 5" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 402 TO WS-ARG
     PERFORM PRESS
     PERFORM HOVER-AT
     MOVE 406 TO WS-ARG
     PERFORM HOVER-AT
     PERFORM LET-GO
     MOVE "120901fc19000500 1209010005010500 120901fc19020500" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a left release outside the image with a carried stack is PICKUP slot -999 button 0; a right one button 1" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK-OUTSIDE
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK-OUTSIDE
     MOVE "120901fc19000000 120901fc19010000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a right release outside the image with one carried item drops it: the cursor is empty after" TO TL-CASE
     PERFORM FRESH
     MOVE 1 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK-OUTSIDE
     MOVE "120901fc19010000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a second left click on the same slot within 250 ms sends PICKUP_ALL (type 6) after the PICKUP" TO TL-CASE
     PERFORM FRESH
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 401 TO WS-ARG
     PERFORM CLICK
     PERFORM CLICK
     MOVE "1209010000000001 1209010000000600" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 two left clicks on the same slot 400 ms apart are two PICKUPs (no PICKUP_ALL)" TO TL-CASE
     PERFORM FRESH
     MOVE 401 TO WS-ARG
     PERFORM CLICK
     MOVE 400 TO WS-MS
     PERFORM CLICK
     MOVE 20 TO WS-MS
     MOVE "1209010000000001 1209010000000001" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 shift and a click that carries a stack, released over a slot with no drag, is QUICK_MOVE" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     PERFORM SHIFT-DOWN
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 403 TO WS-ARG
     PERFORM CLICK
     PERFORM SHIFT-UP
     MOVE "1209010002000100" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a click outside the image with an empty cursor is THROW at -999 (button 0)" TO TL-CASE
     PERFORM FRESH
     PERFORM CLICK-OUTSIDE
     MOVE "120901fc19000400" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a right click that carries a stack on a slot is PICKUP button 1, nothing predicted" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE 403 TO WS-ARG
     PERFORM CLICK
     MOVE "1209010002010000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 another button released during a drag ends the drag and the later release of the drag's button is swallowed: nothing is sent" TO TL-CASE
     PERFORM FRESH
     MOVE 10 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 404 TO WS-ARG
     PERFORM PRESS
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE 405 TO WS-ARG
     PERFORM CLICK
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM LET-GO
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 a release with no press and an empty cursor sends nothing" TO TL-CASE
     PERFORM FRESH
     PERFORM LET-GO
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 hotbar key 3 over a slot with an empty cursor is SWAP (type 2) with button 2; the off-hand key button 40" TO TL-CASE
     PERFORM FRESH
     MOVE 403 TO WS-ARG
     PERFORM HOVER
     MOVE 0 TO WS-M
     MOVE CC-KEY-3 TO WS-KEYCODE
     PERFORM KEYTAP
     MOVE KB-CODE(KB-SWAP-OFFHAND) TO WS-KEYCODE
     PERFORM KEYTAP
     MOVE "1209010002020200 1209010002280200" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US12 40-1§5.5 the drop key over a slot is THROW (type 4) button 0, with Ctrl button 1, the slot's stack predicted" TO TL-CASE
     PERFORM FRESH
     MOVE 402 TO WS-ARG
     PERFORM HOVER
     MOVE 0 TO WS-M
     MOVE KB-CODE(KB-DROP) TO WS-KEYCODE
     PERFORM KEYTAP
     MOVE CC-MOD-CONTROL TO WS-M
     PERFORM KEYTAP
     MOVE "1209010001000401 1209010001010401" TO TL-EXPECTED
     PERFORM CHECK
*>   5.4 the hover highlight: sprite rows 125 (back) and 126 (front), 24 x 24, at the slot widget's corner - 3, the back before the first slot widget and the front after the last.
     PERFORM FRESH
     MOVE 405 TO WS-ARG
     PERFORM HOVER
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-FIRST-SLOT WS-LAST-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT
             IF WS-FIRST-SLOT = 0
                 MOVE WS-I TO WS-FIRST-SLOT
             END-IF
             MOVE WS-I TO WS-LAST-SLOT
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND (SM-W-ARG(WS-I) = GSP-HIGHLIGHT-BACK OR SM-W-ARG(WS-I) = GSP-HIGHLIGHT-FRONT)
             MOVE SM-W-ARG(WS-I) TO WS-E1
             MOVE SM-W-W(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE SM-W-H(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             IF SM-W-ARG(WS-I) = GSP-HIGHLIGHT-BACK AND WS-I < WS-FIRST-SLOT
                 STRING "before " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
             IF SM-W-ARG(WS-I) = GSP-HIGHLIGHT-FRONT AND WS-I > WS-LAST-SLOT
                 STRING "after " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-1§5.4 the hovered slot draws the back highlight (125, 24 x 24) before the slots and the front one (126) after them" TO TL-CASE
     MOVE "125:24x24 before 126:24x24 after" TO TL-EXPECTED
     PERFORM CHECK-NOW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND SM-W-ARG(WS-I) = GSP-HIGHLIGHT-BACK
             COMPUTE WS-N = SM-W-X(WS-I) * 1000 + SM-W-Y(WS-I)
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§5.4 the highlight sits at (slot x - 4, slot y - 4) of the item cell: own slot 4 (col 4, row 0) at screen (72 + 8 + 72 - 4, 36 + 18 - 4) = (148, 50)" TO TL-CASE
     MOVE 148050 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-ARG
     PERFORM HOVER-NOWHERE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND (SM-W-ARG(WS-I) = GSP-HIGHLIGHT-BACK OR SM-W-ARG(WS-I) = GSP-HIGHLIGHT-FRONT)
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-1§5.4 with the pointer over no slot no highlight is drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Open Screen of container 9, menu type WS-TYPE, then the screen built at 640 x 480 (GUI scale 2).
 OPEN-TYPE.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 4 TO PB-TX-LENGTH
     MOVE "Loot" TO PB-TX-VALUE
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     MOVE 60 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

*> The starting stacks: own slot 0 holds 10 x item 2, own slot 1 holds 20 x item 3, the rest is empty; nothing carried; state id 1; the pointer state cleared.
 FRESH.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
     END-PERFORM
     MOVE 10 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE 20 TO BX-COUNT(2)
     MOVE 3 TO BX-ITEM(2)
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 1 TO BM-STATE-ID
     CALL "CX-RESET" USING CLIENT-STATE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO IN-MODS
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM DRAIN
     .

 DRAIN.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .

*> The window position of the centre of the slot widget WS-ARG (outside the image for 0).
 SLOT-POS.
     MOVE 2 TO WS-PX WS-PY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-ARG AND WS-ARG > 0
             COMPUTE WS-PX = (SM-W-X(WS-I) + SM-W-W(WS-I) / 2) * CL-GUI-SCALE
             COMPUTE WS-PY = (SM-W-Y(WS-I) + SM-W-H(WS-I) / 2) * CL-GUI-SCALE
         END-IF
     END-PERFORM
     .

 FRAME.
     MOVE WS-MS TO WS-SLOT
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-SLOT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> Button WS-BUTTON down and up over the slot WS-ARG in one frame.
 CLICK.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1) WS-X(2) WS-X(3)
     MOVE WS-PY TO WS-Y(1) WS-Y(2) WS-Y(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE WS-BUTTON TO WS-A(2) WS-A(3)
     MOVE 3 TO WS-N
     PERFORM FRAME
     .

 CLICK-OUTSIDE.
     MOVE 0 TO WS-ARG
     PERFORM CLICK
     .

 PRESS.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1) WS-X(2)
     MOVE WS-PY TO WS-Y(1) WS-Y(2)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE WS-BUTTON TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     .

 HOVER-AT.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1)
     MOVE WS-PY TO WS-Y(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

 LET-GO.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-UP TO WS-KIND(1)
     MOVE WS-BUTTON TO WS-A(1)
     MOVE WS-PX TO WS-X(1)
     MOVE WS-PY TO WS-Y(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

 HOVER.
     PERFORM HOVER-AT
     .

 HOVER-NOWHERE.
     MOVE 0 TO WS-ARG
     PERFORM HOVER-AT
     .

*> Key WS-KEYCODE down and up in one frame with the modifiers WS-M; SHIFT-DOWN and SHIFT-UP hold the shift key between frames.
 KEYTAP.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE WS-KEYCODE TO WS-A(1) WS-A(2)
     MOVE WS-M TO WS-B(1) WS-B(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     .

 SHIFT-DOWN.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-LEFT-SHIFT TO WS-A(1)
     MOVE CC-MOD-SHIFT TO WS-B(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

 SHIFT-UP.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-UP TO WS-KIND(1)
     MOVE CC-KEY-LEFT-SHIFT TO WS-A(1)
     MOVE 0 TO WS-B(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

*> The packets 12 and 13 the server received, each by its first 8 bytes, against TL-EXPECTED.
 CHECK.
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-OPTR
     PERFORM UNTIL WS-PTR > 1024 OR WS-TEXT(WS-PTR:1) = SPACE
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-TEXT DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-PTR
         IF WS-TOKEN(1:2) = "12" OR WS-TOKEN(1:2) = "13"
             IF WS-OPTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-OPTR
             END-IF
             STRING WS-TOKEN(1:16) DELIMITED BY SPACE INTO TL-OBSERVED WITH POINTER WS-OPTR
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 CHECK-NOW.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 END PROGRAM TEST-SCREEN-40-1-5.

 COPY CLTEST.
