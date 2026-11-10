*> Test US12-client (spec 002 T3216 to T3229, in one file; docs/protocol/40-menus-3-anvil-grindstone-smithing.md sections 1 to 6 and 9): the anvil (8), grindstone (15) and smithing
*> table (21) screens at GUI 320 x 240 (left 72, top 37). Slots: anvil (27, 47), (76, 47), (134, 47); grindstone (49, 19), (49, 40), (129, 34); smithing (8, 48), (26, 48), (44, 48),
*> (98, 48). Titles: anvil x 60, smithing (44, 15). The error icon (28 x 21; a panel fallback rectangle: the sprite is not in the built-in pack) is drawn at (99, 45) on the anvil and
*> (92, 31) on the grindstone when slot 0 or 1 has an item and the result slot has none, at (65, 46) on the smithing table when the error data slot is 1. The anvil's cost label
*> (3.8): nothing for cost <= 0; "Too Expensive!" for cost >= 40 without infinite materials (creative); nothing when the result slot is empty; else "Enchantment Cost: <cost>"; the
*> text at (166 - width, 69) over a box from (x - 2, 67) to (168, 79). Shift-click is QUICK_MOVE (the combiner's quick-move rules are the server's, 2.5, 3.6, 4.5, 5.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-3.
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
 01 WS-CLR                BINARY-LONG.
 01 WS-CLRE               PIC -(9)9.
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
     MOVE 8 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 403
         PERFORM SLOT-LIST
     END-PERFORM
     MOVE "acceptance US12 40-3§3 anvil slots: (27, 47), (76, 47), (134, 47): widgets (98, 83), (147, 83), (205, 83)" TO TL-CASE
     MOVE "98:83 147:83 205:83 " TO TL-EXPECTED
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
     MOVE "acceptance US12 40-3§3 anvil labels: the title at x 60 (132, 43) and the inventory label at (80, 109)" TO TL-CASE
     MOVE "132:43 80:109 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   3.8 the error icon.
     PERFORM CLEAR-STACKS
     MOVE 1 TO BX-COUNT(1)
     MOVE 2 TO BX-ITEM(1)
     MOVE "acceptance US12 40-3§3 anvil: an input item and an empty result draw the error icon 28 x 21 at (171, 82)" TO TL-CASE
     MOVE "171:82:28x21 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 1 TO BX-COUNT(3)
     MOVE 3 TO BX-ITEM(3)
     MOVE "acceptance US12 40-3§3 anvil: with a result there is no error icon" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     PERFORM CLEAR-STACKS
     MOVE "acceptance US12 40-3§3 anvil: no input item, no error icon" TO TL-CASE
     PERFORM CHECK-OVERLAYS
     MOVE 1 TO BX-COUNT(2)
     MOVE 2 TO BX-ITEM(2)
     MOVE "acceptance US12 40-3§3 anvil: an item in the right slot only also draws it" TO TL-CASE
     MOVE "171:82:28x21 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
*>   Cost label.
     PERFORM CLEAR-STACKS
     MOVE 5 TO BM-DATA(1)
     MOVE "acceptance US12 40-3§3 cost 5 with no result: no cost label" TO TL-CASE
     PERFORM CHECK-COST
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BX-COUNT(3)
     MOVE 3 TO BX-ITEM(3)
     MOVE "Enchantment Cost: 5" TO WS-TEXT
     MOVE 19 TO WS-I
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-I WS-N
     COMPUTE WS-K = 236 - WS-N
     MOVE WS-K TO WS-E1
     COMPUTE WS-K = 238 + 0 - (236 - WS-N) - 2 + 0
     MOVE SPACES TO TL-EXPECTED
     COMPUTE WS-D1 = 72 + 166 - WS-N
     COMPUTE WS-D2 = WS-N + 4
     MOVE WS-D1 TO WS-E1
     MOVE WS-D2 TO WS-E2
     COMPUTE WS-D1 = WS-D1 - 2
     MOVE WS-D1 TO WS-E3
     STRING "label " FUNCTION TRIM(WS-E1) ":106 box " FUNCTION TRIM(WS-E3) ":104:" FUNCTION TRIM(WS-E2) "x12 text Enchantment Cost: 5"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-3§3 cost 5 with a result: Enchantment Cost: 5 at (166 - width, 69) over a box from (x - 2, 67) to (168, 79)" TO TL-CASE
     PERFORM CHECK-COST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO PL-XP-LEVEL
     PERFORM CHECK-COST
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CLR TO WS-CLRE
     MOVE FUNCTION TRIM(WS-CLRE) TO TL-OBSERVED
     MOVE "acceptance US12 40-3§3 cost 5 with level 4 (result not takeable): the label is red #FF6060" TO TL-CASE
     MOVE "16736352" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-XP-LEVEL
     PERFORM CHECK-COST
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CLR TO WS-CLRE
     MOVE FUNCTION TRIM(WS-CLRE) TO TL-OBSERVED
     MOVE "acceptance US12 40-3§3 cost 5 with level 5: the label is green #80FF20" TO TL-CASE
     MOVE "8453920" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BM-DATA(1)
     MOVE "acceptance US12 40-3§3 cost 0: no label" TO TL-CASE
     PERFORM CHECK-COST
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO BM-DATA(1)
     MOVE "Too Expensive!" TO WS-TEXT
     MOVE 14 TO WS-I
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-I WS-N
     COMPUTE WS-D1 = 72 + 166 - WS-N
     MOVE WS-D1 TO WS-E1
     COMPUTE WS-D2 = WS-N + 4
     MOVE WS-D2 TO WS-E2
     COMPUTE WS-D1 = WS-D1 - 2
     MOVE WS-D1 TO WS-E3
     MOVE SPACES TO TL-EXPECTED
     STRING "label " FUNCTION TRIM(WS-E1) ":106 box " FUNCTION TRIM(WS-E3) ":104:" FUNCTION TRIM(WS-E2) "x12 text Too Expensive!"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-3§3 cost 40 in survival: Too Expensive!" TO TL-CASE
     PERFORM CHECK-COST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CLR TO WS-CLRE
     MOVE FUNCTION TRIM(WS-CLRE) TO TL-OBSERVED
     MOVE "acceptance US12 40-3§3 Too Expensive! is red #FF6060" TO TL-CASE
     MOVE "16736352" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     MOVE "Enchantment Cost: 40" TO WS-TEXT
     MOVE 20 TO WS-I
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-I WS-N
     COMPUTE WS-D1 = 72 + 166 - WS-N
     MOVE WS-D1 TO WS-E1
     COMPUTE WS-D2 = WS-N + 4
     MOVE WS-D2 TO WS-E2
     COMPUTE WS-D1 = WS-D1 - 2
     MOVE WS-D1 TO WS-E3
     MOVE SPACES TO TL-EXPECTED
     STRING "label " FUNCTION TRIM(WS-E1) ":106 box " FUNCTION TRIM(WS-E3) ":104:" FUNCTION TRIM(WS-E2) "x12 text Enchantment Cost: 40"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-3§3 cost 40 in creative (infinite materials): the cost is shown" TO TL-CASE
     PERFORM CHECK-COST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
*>   Grindstone.
     MOVE 15 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 403
         PERFORM SLOT-LIST
     END-PERFORM
     MOVE "acceptance US12 40-3§4 grindstone slots: (49, 19), (49, 40), (129, 34): widgets (120, 55), (120, 76), (200, 70)" TO TL-CASE
     MOVE "120:55 120:76 200:70 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-STACKS
     MOVE 1 TO BX-COUNT(2)
     MOVE 2 TO BX-ITEM(2)
     MOVE "acceptance US12 40-3§4 grindstone: an input and no result draw the error icon 28 x 21 at (164, 68)" TO TL-CASE
     MOVE "164:68:28x21 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE 1 TO BX-COUNT(3)
     MOVE 3 TO BX-ITEM(3)
     MOVE "acceptance US12 40-3§4 grindstone: with a result no error icon" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
*>   Smithing.
     MOVE 21 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 404
         PERFORM SLOT-LIST
     END-PERFORM
     MOVE "acceptance US12 40-3§5 smithing slots: (8, 48), (26, 48), (44, 48), result (98, 48): widgets (79, 84), (97, 84), (115, 84), (169, 84)" TO TL-CASE
     MOVE "79:84 97:84 115:84 169:84 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-EXPECTED
     MOVE "acceptance US12 40-3§5 smithing: no error flag, no error icon" TO TL-CASE
     PERFORM CHECK-OVERLAYS
     MOVE 0 TO WS-PROP
     MOVE 1 TO WS-VALUE
     PERFORM SEND-DATA
     MOVE "acceptance US12 40-3§5 smithing: Container Set Data property 0 = 1 (the error flag) draws the icon 28 x 21 at (137, 83)" TO TL-CASE
     MOVE "137:83:28x21 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-3§5 smithing labels: title at (44, 15) = (116, 52), inventory label (80, 109)" TO TL-CASE
     MOVE "116:52 80:109 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.5 shift-click on the result slot is QUICK_MOVE slot 3 (the move is the server's).
     MOVE 1 TO BX-COUNT(4)
     MOVE 3 TO BX-ITEM(4)
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-LEFT-SHIFT TO WS-A(1)
     MOVE CC-MOD-SHIFT TO WS-B(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE 404 TO WS-ARG
     PERFORM CLICK-LEFT
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:16) TO TL-OBSERVED
     MOVE "acceptance US12 40-3§2 shift and a click on the smithing result is QUICK_MOVE (type 1) of menu slot 3, nothing predicted" TO TL-CASE
     MOVE "1209010003000100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> TL-OBSERVED as "label x:y box x:y:wxh text <text>" for the cost label of the anvil screen (empty when none).
 CHECK-COST.
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-Y(WS-I) = 106
             MOVE SM-W-X(WS-I) TO WS-E1
             STRING "label " FUNCTION TRIM(WS-E1) ":106 " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             MOVE SM-W-TEXT(WS-I) TO WS-TOKEN
             MOVE SM-W-LENGTH(WS-I) TO WS-K
             MOVE SM-W-COLOUR(WS-I) TO WS-CLR
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-Y(WS-I) = 104
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-W(WS-I) TO WS-E2
             MOVE SM-W-H(WS-I) TO WS-E3
             STRING "box " FUNCTION TRIM(WS-E1) ":104:" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3) " text " WS-TOKEN(1:WS-K)
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

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

 END PROGRAM TEST-SCREEN-40-3.

 COPY CLTEST.
