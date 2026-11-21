*> Test US12-client (spec 002 T3200 to T3215, in one file; docs/protocol/40-menus-2-furnaces-brewing-crafter.md sections 1 to 8): the furnace family, brewing stand and crafter
*> screens at GUI 320 x 240 (left 72, top 37 for the 176 x 166 image). Frame (1.1): the title centred, the label "Inventory" at (8, 72). Slots (2.2, 4.2, 6.2): furnace (56, 17),
*> (56, 53), (116, 35); brewing (56, 51), (79, 58), (102, 51), (79, 17), (17, 17); crafter 3 x 3 from (26, 17) and the result at (134, 35). Progress (3.2, 5): the flame is the bottom
*> h = ceil(litProgress x 13) + 1 rows of 14 x 14 at (56, 36 + 14 - h) while data 0 > 0 (litProgress = data0 / data1, data1 0 is 200); the arrow is w = ceil(burnProgress x 24)
*> columns of 24 x 16 at (79, 34); brewing: fuel bar w = ceilDiv(18 f, T) of 18 x 4 at (60, 44), arrow a = trunc(28 (1 - b / B)) rows of 9 x 28 at (97, 16), bubbles the bottom L rows
*> (29 24 20 16 11 6 0 by (b / 2) mod 7) of 12 x 29 at (63, 14 + 29 - L). These sprites are not in the built-in pack: each is drawn as a panel fallback, a WK-OVERLAY rectangle of
*> that size ("x:y:wxh" below). Crafter (7): a disabled slot (data i = 1) is an 18 x 18 overlay at the slot widget; the power indicator is a 16 x 16 overlay at (GW / 2 + 9,
*> GH / 2 - 48), another swatch when powered; clicking an empty crafting slot with an empty cursor toggles it: Container Slot State Changed (0x14: slot VarInt, container VarInt,
*> state Boolean) and the local data, then the ordinary click; a disabled slot clicked with a carried stack is enabled first; the swap key over a disabled slot with an inventory
*> stack in that hotbar position enables it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-2.
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
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-PY                  FLOAT-SHORT.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-D4                  BINARY-LONG.
 01 WS-PROP                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TOKEN               PIC X(1024).
 01 WS-OPTR                BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
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
*>   2.2 and 1.1: slots and labels of the furnace.
     MOVE 14 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 401 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE 402 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE 403 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE "acceptance US12 40-2§2 furnace slots: input (56, 17), fuel (56, 53), result (116, 35) at left 72, top 37: widgets at (127, 53), (127, 89), (187, 71)" TO TL-CASE
     MOVE "127:53 127:89 187:71 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "Loot" TO WS-TEXT
     MOVE 4 TO WS-I
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-I WS-N
     COMPUTE WS-K = 72 + (176 - WS-N) / 2
     MOVE WS-K TO WS-E1
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) ":43 80:109 " DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-2§1 the title is centred at y 6 and the inventory label stays at (8, 72) (frame 1.1)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3.2 flame and arrow: E3 and V8, V9.
     MOVE 1200 TO WS-D1
     MOVE 1600 TO WS-D2
     MOVE 57 TO WS-D3
     MOVE 200 TO WS-D4
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§3 E3: data 1200 1600 57 200 draw the flame 14 x 11 at (128, 76) and the arrow 7 x 16 at (151, 71)" TO TL-CASE
     MOVE "128:76:14x11 151:71:7x16 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 1 TO WS-D1
     MOVE 200 TO WS-D2
     MOVE 1 TO WS-D3
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§3 V8, V9: data (1, 1600) a flame of 2 rows, arrow (1, 200) 1 column" TO TL-CASE
     MOVE 1600 TO WS-D2
     PERFORM SET-DATA
     MOVE "128:85:14x2 151:71:1x16 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 1600 TO WS-D1
     MOVE 200 TO WS-D3
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§3 V8, V9: data (1600, 1600) a flame of 14 rows, arrow (200, 200) 24 columns" TO TL-CASE
     MOVE "128:73:14x14 151:71:24x16 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 100 TO WS-D1
     MOVE 0 TO WS-D2 WS-D3
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§3 total burn time 0 uses 200: data0 100 is a flame of 8 rows; a cooking progress of 0 draws no arrow" TO TL-CASE
     MOVE "128:79:14x8 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 0 TO WS-D1
     MOVE 5 TO WS-D3
     MOVE 0 TO WS-D4
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§3 not lit and no total cooking time: nothing is drawn" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
*>   8: the data arrives with Container Set Data and the picture follows.
     MOVE 0 TO WS-PROP
     MOVE 1200 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE 1 TO WS-PROP
     MOVE 1600 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE "acceptance US12 40-2§8 Container Set Data properties 0 and 1 (1200, 1600) light the flame: 14 x 11 at (128, 76)" TO TL-CASE
     MOVE "128:76:14x11 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
*>   4.2 brewing stand slots.
     MOVE 11 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 405
         PERFORM SLOT-LIST
     END-PERFORM
     MOVE "acceptance US12 40-2§4 brewing slots: bottles (56, 51), (79, 58), (102, 51), ingredient (79, 17), fuel (17, 17): widgets (127, 87), (150, 94), (173, 87), (150, 53), (88, 53)" TO TL-CASE
     MOVE "127:87 150:94 173:87 150:53 88:53 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5 brewing screen: E6.
     MOVE 400 TO WS-D1
     MOVE 10 TO WS-D2
     MOVE 400 TO WS-D3
     MOVE 20 TO WS-D4
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§5 E6: data (400, 10, 400, 20): fuel bar 9 x 4 at (132, 81), no arrow, bubbles 12 x 11 at (135, 69)" TO TL-CASE
     MOVE "132:81:9x4 135:69:12x11 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 200 TO WS-D1
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§5 E6: at 200 ticks the arrow is 9 x 14 at (169, 53) and the bubbles 12 x 20 at (135, 60)" TO TL-CASE
     MOVE "132:81:9x4 169:53:9x14 135:60:12x20 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 0 TO WS-D1
     MOVE 0 TO WS-D2
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§5 an idle stand with no fuel draws nothing; a fuel total of 0 draws no bar" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 1 TO WS-D1
     MOVE 399 TO WS-D3
     MOVE 6 TO WS-D2
     MOVE 20 TO WS-D4
     PERFORM SET-DATA
     MOVE "acceptance US12 40-2§5 bubble index (1 / 2) mod 7 = 0 is 29 rows; the bar of 6 of 20 fuel uses is ceil(108 / 20) = 6 columns, the arrow trunc(28 x 398 / 399) = 27 rows" TO TL-CASE
     MOVE "132:81:6x4 169:53:9x27 135:51:12x29 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
*>   6.2 crafter slots.
     MOVE 7 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 401 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE 409 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE 410 TO WS-ARG
     PERFORM SLOT-LIST
     MOVE "acceptance US12 40-2§6 crafter slots: crafting slot 0 (26, 17), 8 (62, 53), result (134, 35): widgets (97, 53), (133, 89), (205, 71)" TO TL-CASE
     MOVE "97:53 133:89 205:71 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   7.3 drawing: slot 4 disabled, power 0 then 1.
     MOVE 0 TO WS-D1 WS-D2 WS-D3 WS-D4
     PERFORM SET-DATA
     MOVE 1 TO BM-DATA(5)
     MOVE "acceptance US12 40-2§7 a disabled crafting slot (data 4 = 1) is an 18 x 18 overlay at its widget (115, 71); the power indicator 16 x 16 at (169, 72)" TO TL-CASE
     MOVE "115:71:18x18 169:72:16x16 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 16
             MOVE SM-W-ARG(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-D1
     MOVE 1 TO BM-DATA(10)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 16
             MOVE SM-W-ARG(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-2§7 the powered indicator uses another swatch than the unpowered one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N NOT = WS-D1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
*>   7.2 the toggle: click the empty enabled slot 0 with an empty cursor: disable (state 0); the click of slot 4 (disabled) enables.
     MOVE 0 TO BM-DATA(5) BM-DATA(10)
     MOVE 1 TO BM-STATE-ID
     PERFORM CLEAR-STACKS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     MOVE 405 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE "acceptance US12 40-2§7 E7: a click on the empty enabled centre slot with an empty cursor sends Container Slot State Changed (slot 4, container 9, false) and disables it" TO TL-CASE
     PERFORM TOKENS-14
     MOVE "1404 0900" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-2§7 the local data slot 4 is 1 (disabled) after the click" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BM-DATA(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 405 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE "acceptance US12 40-2§7 a click on the disabled slot enables it: the packet carries true (01)" TO TL-CASE
     PERFORM TOKENS-14
     MOVE "1404 0901" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-2§7 a click on an enabled slot with a carried stack is only the ordinary click (no 0x14); on a disabled one the slot is enabled first" TO TL-CASE
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 2 TO PL-CARRIED-ITEM
     MOVE 1 TO BM-DATA(3)
     MOVE 1 TO BM-DATA(2)
     MOVE 404 TO WS-ARG
     PERFORM CLICK-LEFT
     MOVE 403 TO WS-ARG
     PERFORM CLICK-LEFT
     PERFORM TOKENS-14
     MOVE "1402 0901" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-2§7 a click on a crafting slot that holds an item is no toggle" TO TL-CASE
     PERFORM CLEAR-STACKS
     MOVE 3 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 401 TO WS-ARG
     PERFORM CLICK-LEFT
     PERFORM TOKENS-14
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-2§7 the swap key over a disabled slot with a stack in that hotbar position enables it (slot 2, state true)" TO TL-CASE
     PERFORM CLEAR-STACKS
     MOVE 1 TO BM-DATA(3)
     MOVE 7 TO PL-SLOT-COUNT(1)
     MOVE 2 TO PL-SLOT-ITEM(1)
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 403 TO WS-ARG
     PERFORM HOVER-ON
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-1 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     PERFORM TOKENS-14
     MOVE "1402 0901" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-2§7 the off-hand swap key (button 40) over a disabled slot with an off-hand stack enables it too" TO TL-CASE
     PERFORM CLEAR-STACKS
     MOVE 1 TO BM-DATA(3)
     MOVE 0 TO PL-SLOT-COUNT(1)
     MOVE 3 TO PL-OFFHAND-COUNT
     MOVE 2 TO PL-OFFHAND-ITEM
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 403 TO WS-ARG
     PERFORM HOVER-ON
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE KB-CODE(KB-SWAP-OFFHAND) TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     PERFORM TOKENS-14
     MOVE "1402 0901" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> "x:y" of the slot widget WS-ARG appended to TL-OBSERVED (WS-PTR).
 SLOT-LIST.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-ARG
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 SET-DATA.
     MOVE WS-D1 TO BM-DATA(1)
     MOVE WS-D2 TO BM-DATA(2)
     MOVE WS-D3 TO BM-DATA(3)
     MOVE WS-D4 TO BM-DATA(4)
     .

*> Build the screen and compare the overlays after the panel ("x:y:wxh ") with TL-EXPECTED.
 CHECK-OVERLAYS.
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 SEND-DATA.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 9 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-PROP
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-VALUE
     MOVE 19 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

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
     MOVE 1 TO BM-STATE-ID
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

 CLEAR-STACKS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO BX-COUNT(WS-I) BX-ITEM(WS-I) BX-DAMAGE(WS-I)
     END-PERFORM
     MOVE 0 TO PL-SLOT-COUNT(1)
     .

 DRAIN.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .

 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

 SLOT-POS.
     MOVE 2 TO WS-PX WS-PY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-ARG
             COMPUTE WS-PX = (SM-W-X(WS-I) + SM-W-W(WS-I) / 2) * CL-GUI-SCALE
             COMPUTE WS-PY = (SM-W-Y(WS-I) + SM-W-H(WS-I) / 2) * CL-GUI-SCALE
         END-IF
     END-PERFORM
     .

 HOVER-ON.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1)
     MOVE WS-PY TO WS-Y(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

 CLICK-LEFT.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1) WS-X(2) WS-X(3)
     MOVE WS-PY TO WS-Y(1) WS-Y(2) WS-Y(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE 3 TO WS-N
     PERFORM FRAME
     .

*> The packets 14 the server received (each by its first 4 bytes), spaced: TL-OBSERVED as "1404 0900" per packet pair.
 TOKENS-14.
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 1 TO WS-OPTR
     PERFORM UNTIL WS-PTR > 1024 OR WS-TEXT(WS-PTR:1) = SPACE
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-TEXT DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-PTR
         IF WS-TOKEN(1:2) = "14"
             IF WS-OPTR > 1
                 STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-OPTR
             END-IF
             STRING WS-TOKEN(1:4) " " WS-TOKEN(5:2) WS-TOKEN(7:2) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-OPTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-2.

 COPY CLTEST.
