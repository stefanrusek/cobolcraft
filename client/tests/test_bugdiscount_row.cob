*> Test lane 002-lane-bugdiscount (T59500; docs/protocol/40-menus-5-merchant-beacon-lectern.md 2.10 "First-cost decorations"): a merchant row whose price differs from the base shows the
*> base count crossed out and the modified count once. Operator report (try17): "discounts render wrong": the row showed the modified count twice ("1919") and no strike-through.
*> Causes: the strike was an overlay widget created while the label's text was still in the widget text buffer, so UI-RENDER drew the count a second time at the overlay; and the
*> overlay was the 31 % red hurt swatch on the UI layer, hidden behind the item icon. The strike is now state 4 of the first cost's slot widget (UI-SLOT: opaque red 9 x 2 at (7, 12)
*> on the layer over the icons and the count). Offers are set into the replica directly (the wire form is covered by test_screen_40_5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUGDISCOUNT-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-RED-OK              BINARY-LONG.
 01 WS-U                   FLOAT-SHORT.
 01 WS-DIFF                FLOAT-SHORT.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE 19 TO WS-TYPE
     PERFORM OPEN-TYPE
*>   Three offers: 20 x item 5 with special price diff -1 (the report: 20 shown struck, 19 shown), 5 x item 7 with diff -3 (2), 4 x item 9 at its base price.
     MOVE 3 TO MC-COUNT
     MOVE 2 TO MC-LEVEL
     MOVE 1 TO MC-PROGRESS
     MOVE 0 TO MC-SELECTED MC-SCROLL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 7 TO MO-R-ITEM(WS-I)
         MOVE 1 TO MO-R-COUNT(WS-I)
         MOVE 0 TO MO-B-ITEM(WS-I) MO-B-COUNT(WS-I) MO-OUT(WS-I) MO-USES(WS-I) MO-DEMAND(WS-I) MO-SPECIAL(WS-I)
         MOVE 10 TO MO-MAX(WS-I)
         MOVE 5 TO MO-XP(WS-I)
         MOVE 0.05 TO MO-MULT(WS-I)
     END-PERFORM
     MOVE 5 TO MO-A-ITEM(1)
     MOVE 20 TO MO-A-COUNT(1)
     MOVE -1 TO MO-SPECIAL(1)
     MOVE 7 TO MO-A-ITEM(2)
     MOVE 5 TO MO-A-COUNT(2)
     MOVE -3 TO MO-SPECIAL(2)
     MOVE 9 TO MO-A-ITEM(3)
     MOVE 4 TO MO-A-COUNT(3)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE

*>   The modified count is one label ("19"); no overlay carries text (an overlay with the label's text drew it twice).
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-LENGTH(WS-I) > 0
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "bugdiscount 40-5§2.10 no overlay widget carries text (the discounted count was drawn twice)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-LENGTH(WS-I) = 2 AND SM-W-TEXT(WS-I)(1:2) = "19"
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     MOVE "bugdiscount 40-5§2.10 the modified count 19 is on exactly one widget" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The strike-through: a 9 x 2 quad on the layer over the icons at (x + 7, y + 12) of the first cost of rows 0 and 1 (x = left + 10, y = top + 19 + 20 r), none for row 2 (unchanged).
     COMPUTE WS-LEFT = (IN-WIN-W / CL-GUI-SCALE - 276) / 2
     COMPUTE WS-TOP = (IN-WIN-H / CL-GUI-SCALE - 166) / 2
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-RED-OK
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K * 6 + 3 > RL-UT-COUNT
         COMPUTE WS-I = WS-K * 6 + 1
         COMPUTE WS-X0 = RL-UT-X(WS-I)
         COMPUTE WS-Y0 = RL-UT-Y(WS-I)
         COMPUTE WS-X1 = RL-UT-X(WS-I + 2)
         COMPUTE WS-Y1 = RL-UT-Y(WS-I + 2)
         IF WS-X1 - WS-X0 = 9 * CL-GUI-SCALE AND WS-Y1 - WS-Y0 = 2 * CL-GUI-SCALE
             COMPUTE WS-X0 = WS-X0 / CL-GUI-SCALE - WS-LEFT
             COMPUTE WS-Y0 = WS-Y0 / CL-GUI-SCALE - WS-TOP
             MOVE WS-X0 TO WS-E1
             MOVE WS-Y0 TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
*>           Opaque red: the swatch SW-BAR-0 (FF0000FF), not the 31 % red of the hurt swatch.
             COMPUTE WS-U = (SW-BAR-0 * 8 + 4) / UA-W
             COMPUTE WS-DIFF = FUNCTION ABS(RL-UT-U(WS-I) - WS-U)
             IF WS-DIFF < 0.00001 AND RL-UT-A(WS-I) > 0.99
                 ADD 1 TO WS-RED-OK
             END-IF
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "bugdiscount 40-5§2.10 the strike-through 9 x 2 is drawn over the first cost at (x + 7, y + 12) of the two changed rows only" TO TL-CASE
     MOVE "17:31 17:51 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "bugdiscount 40-5§2.10 both strike-throughs are the opaque red swatch" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-RED-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

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

 END PROGRAM TEST-BUGDISCOUNT-ROW.

 COPY CLTEST.
