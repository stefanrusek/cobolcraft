*> Test US12-client (spec 002 T3230 to T3241, in one file; docs/protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md sections 1 to 6): the enchanting table (13), loom (18),
*> stonecutter (24) and cartography table (23) screens at GUI 320 x 240 (left 72, top 37). Slots: enchanting (15, 47), (35, 47); loom (13, 26), (33, 26), (23, 45), result (143, 57);
*> stonecutter (20, 33), result (143, 33); cartography (15, 15), (15, 52), result (145, 39). Title y: enchanting 6, loom 4, stonecutter 5, cartography 4 (1 rule 3). Enchanting
*> (2.9): three option rows of 108 x 19 at (60, 14 + 19 i) drawn as panel fallbacks (the row sprites are not in the built-in pack), the cost (data i, 0 to 2) right-aligned to x 166 at
*> y 23 + 19 i when it is above 0; a row is enabled when (lapis in slot 1 >= i + 1 and the player's level >= cost) or infinite materials (creative) and only then is it clickable: the
*> click sends Container Button Click (05c 0x11: container id, button id i). The level comes from Set Experience (05b 0x69). The galactic clue names, the loom pattern grid, the
*> stonecutter recipe list, the cartography map previews and the banner and enchantment tooltips need data the client does not hold and are not drawn (partial).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-4.
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
 01 WS-CLRE               PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 01 WS-TOKEN               PIC X(1024).
 01 WS-OPTR                BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-FLOATV              FLOAT-SHORT.
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
*>   Slots and title rows of the four menus.
     MOVE 13 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 402
         PERFORM SLOT-LIST
     END-PERFORM
     PERFORM TITLE-Y
     MOVE "acceptance US12 40-4§2 enchanting slots (15, 47), (35, 47): widgets (86, 83), (106, 83); title y 6 (43)" TO TL-CASE
     MOVE "86:83 106:83  43" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 404
         PERFORM SLOT-LIST
     END-PERFORM
     PERFORM TITLE-Y
     MOVE "acceptance US12 40-4§3 loom slots (13, 26), (33, 26), (23, 45), result (143, 57): widgets (84, 62), (104, 62), (94, 81), (214, 93); title y 4 (41)" TO TL-CASE
     MOVE "84:62 104:62 94:81 214:93  41" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 402
         PERFORM SLOT-LIST
     END-PERFORM
     PERFORM TITLE-Y
     MOVE "acceptance US12 40-4§4 stonecutter slots (20, 33), result (143, 33): widgets (91, 69), (214, 69); title y 5 (42)" TO TL-CASE
     MOVE "91:69 214:69  42" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ARG FROM 401 BY 1 UNTIL WS-ARG > 403
         PERFORM SLOT-LIST
     END-PERFORM
     PERFORM TITLE-Y
     MOVE "acceptance US12 40-4§5 cartography slots (15, 15), (15, 52), result (145, 39): widgets (86, 51), (86, 88), (216, 75); title y 4 (41)" TO TL-CASE
     MOVE "86:51 86:88 216:75  41" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.9 the enchanting rows.
     MOVE 13 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 10 TO BM-DATA(1)
     MOVE 20 TO BM-DATA(2)
     MOVE 30 TO BM-DATA(3)
     MOVE 2 TO BX-COUNT(2)
     MOVE 5 TO BX-ITEM(2)
     MOVE 15 TO PL-XP-LEVEL
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "acceptance US12 40-4§2 three rows of 108 x 19 at (132, 51), (132, 70), (132, 89)" TO TL-CASE
     MOVE "132:51:108x19 132:70:108x19 132:89:108x19 " TO TL-EXPECTED
     PERFORM CHECK-OVERLAYS
     PERFORM ROW-TEXTS
     MOVE "acceptance US12 40-4§2 the costs are right-aligned to x 166 (+ left 72) at y 23 + 19 i (+ top 37): 10 at row 0, 20 at row 1, 30 at row 2" TO TL-CASE
     PERFORM EXPECT-COSTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND (SM-W-Y(WS-I) = 60 OR SM-W-Y(WS-I) = 79 OR SM-W-Y(WS-I) = 98)
             MOVE SM-W-COLOUR(WS-I) TO WS-CLRE
             STRING FUNCTION TRIM(WS-CLRE) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-4§2 cost numbers: #80FF20 on the enabled row 0, #407F10 on the disabled rows 1 and 2" TO TL-CASE
     MOVE "8453920 4226832 4226832 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM ROW-BUTTONS
     MOVE "acceptance US12 40-4§2 with 2 lapis and level 15 only row 0 (cost 10) is enabled: one clickable row at (132, 51), button 0" TO TL-CASE
     MOVE "132:51:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO PL-XP-LEVEL
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM ROW-BUTTONS
     MOVE "acceptance US12 40-4§2 at level 25 row 1 (cost 20, 2 lapis) is enabled too, row 2 (3 lapis needed) is not" TO TL-CASE
     MOVE "132:51:0 132:70:1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM ROW-BUTTONS
     MOVE "acceptance US12 40-4§2 with infinite materials (creative) all three rows are enabled" TO TL-CASE
     MOVE "132:51:0 132:70:1 132:89:2 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
     MOVE 0 TO BM-DATA(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM ROW-BUTTONS
     MOVE "acceptance US12 40-4§2 a row with cost 0 is disabled and has no cost text" TO TL-CASE
     MOVE "132:70:1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.9 click: Container Button Click of row 1.
     MOVE 10 TO BM-DATA(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     MOVE 70 TO WS-D1
     PERFORM CLICK-AT-ROW
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:6) TO TL-OBSERVED
     MOVE "acceptance US12 40-4§2 a click on row 1 sends Container Button Click: 11, container 09, button 01" TO TL-CASE
     MOVE "110901" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 89 TO WS-D1
     MOVE 15 TO PL-XP-LEVEL
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM CLICK-AT-ROW
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:6) TO TL-OBSERVED
     MOVE "acceptance US12 40-4§2 a click on a disabled row sends nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   6: Set Experience sets the level.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0.5 TO WS-FLOATV
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLOATV
     MOVE 33 TO WS-D2
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D2
     MOVE 900 TO WS-D3
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D3
     MOVE 105 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-4§6 Set Experience (05b 0x69) sets the player's level (33)" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE PL-XP-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     STOP RUN.

*> The title label's y (and its x blank) as " <y>" appended after the slot list.
 TITLE-Y.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-Y(WS-I) < 50
             MOVE SM-W-Y(WS-I) TO WS-E1
             STRING " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> The cost labels (those with a y of 60, 79, 98): "<text>@<x>:<y> ".
 ROW-TEXTS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND (SM-W-Y(WS-I) = 60 OR SM-W-Y(WS-I) = 79 OR SM-W-Y(WS-I) = 98)
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> The expected cost texts: width-dependent x = 72 + 166 - width.
 EXPECT-COSTS.
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-D4 = (WS-K + 1) * 10
         MOVE WS-D4 TO WS-E3
         MOVE FUNCTION TRIM(WS-E3) TO WS-TEXT
         MOVE 2 TO WS-I
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-I WS-N
         COMPUTE WS-D1 = 72 + 166 - WS-N
         COMPUTE WS-D2 = 60 + 19 * WS-K
         MOVE WS-D1 TO WS-E1
         MOVE WS-D2 TO WS-E2
         STRING FUNCTION TRIM(WS-E3) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE
             INTO TL-EXPECTED WITH POINTER WS-PTR
     END-PERFORM
     .

*> The clickable rows: "x:y:button ".
 ROW-BUTTONS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-MENU-BUTTON
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-ARG(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> A left click in the middle of the row whose screen y is WS-D1 (x 132 + 54).
 CLICK-AT-ROW.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = (132 + 54) * 2
     COMPUTE WS-Y(1) = (WS-D1 + 9) * 2
     MOVE WS-X(1) TO WS-X(2) WS-X(3)
     MOVE WS-Y(1) TO WS-Y(2) WS-Y(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE 3 TO WS-N
     PERFORM FRAME
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


 END PROGRAM TEST-SCREEN-40-4.

 COPY CLTEST.
