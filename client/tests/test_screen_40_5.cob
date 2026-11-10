*> Test US12-client (spec 002 T3242 to T3249, in one file; docs/protocol/40-menus-5-merchant-beacon-lectern.md sections 1 to 4): the merchant (19), beacon (9) and lectern (17) screens at
*> GUI 320 x 240. Merchant (left 22, top 37): Merchant Offers (05a 0x35) parsed (components of a cost's predicate skipped), prices (2.4), seven row buttons 88 x 20 at (27, 55 + 20 k) that
*> send Select Trade (05c 0x34), the scroller (wheel, drag), the XP bar, the out-of-stock cross and its tooltip, the title with the level. Beacon (left 45, top 10): 22 x 22 power buttons by
*> pyramid level, selection, Set Beacon (05c 0x35) on confirm, the effect-name tooltip, Container Set Data keeping the powers. Lectern: page buttons (Container Button Click 1 and 2), Done,
*> Take Book (3) for a player who can build. Item tooltips of the rows, the discount strike-through, the beacon payment strip and the book text are not drawn (partial).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-5.
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
 01 WS-LOOP                BINARY-LONG.
 01 WS-OFFER               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
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
*>   Merchant: 8 offers.
     MOVE 19 TO WS-TYPE
     PERFORM OPEN-TYPE
     PERFORM SEND-OFFERS
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§2 Merchant Offers stores the 8 offers, level 2, xp 20, progress and restock flags" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 8 * 10000 + 2 * 1000 + 20 * 10 + MC-PROGRESS * 2 + MC-RESTOCK
     COMPUTE TL-OBSERVED-N = MC-COUNT * 10000 + MC-LEVEL * 1000 + MC-XP * 10 + 3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-5§2 both flags are true" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MC-PROGRESS + MC-RESTOCK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-OFFER
     CALL "MERCHANT-PRICE" USING CLIENT-STATE WS-OFFER WS-N
     MOVE "acceptance US12 40-5§2.4 price of offer 0: 2 + floor(2 x 10 x 0.05) = 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-OFFER
     CALL "MERCHANT-PRICE" USING CLIENT-STATE WS-OFFER WS-N
     MOVE "acceptance US12 40-5§2.4 offer 1: 5 + floor(5 x 10 x 0.05) + special price diff -5 = 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-OFFER
     CALL "MERCHANT-PRICE" USING CLIENT-STATE WS-OFFER WS-N
     MOVE "acceptance US12 40-5§2.4 offer 2: demand 5000 raises the price to the item's maximum stack size (64)" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-5 section 1 (shared facts): 1.1 the type id opened is the merchant 19; 1.2 own slots and image height of merchant (3, 166) and beacon (1, 219); the wire form: the
*>   out-of-stock flag of offer 3 (index 2) forces uses to max uses; the price comes from the base cost (1.3).
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§1 Shared facts: Open Screen type id 19 opens the merchant menu" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE BM-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-D1
     CALL "CONTAINER-LAYOUT" USING WS-D1 WS-D2 WS-D3 WS-D4 WS-N WS-OFFER
     MOVE "acceptance US12 40-5§1 Shared facts: merchant has 3 own slots, image height 166, known" TO TL-CASE
     MOVE 301661 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-D2 * 100000 + WS-D3 * 10 + WS-OFFER
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-D1
     CALL "CONTAINER-LAYOUT" USING WS-D1 WS-D2 WS-D3 WS-D4 WS-N WS-OFFER
     MOVE "acceptance US12 40-5§1 Shared facts: beacon has 1 own slot, image height 219, known" TO TL-CASE
     MOVE 102191 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-D2 * 100000 + WS-D3 * 10 + WS-OFFER
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-5§1 Shared facts: an out-of-stock flag forces uses to max uses" TO TL-CASE
     MOVE MO-MAX(3) TO TL-EXPECTED-N
     MOVE MO-USES(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-5§1 Shared facts: the wire carries the base cost A (offer 1: 2), not the price" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE MO-A-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-TRADE-SELECT
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-ARG(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " " DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-5§2.10 seven row buttons 88 x 20 at (5, 18 + 20 k): (27, 55 + 20 k), arguments 0 to 6" TO TL-CASE
     MOVE "27:55:0 27:75:1 27:95:2 27:115:3 27:135:4 27:155:5 27:175:6 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM LABEL-LIST
     MOVE "acceptance US12 40-5§2.10 labels: the title with the level (centred at 49 + (276 - w) / 2), Inventory at (107, 72), Trades" TO TL-CASE
     MOVE "Loot - Apprentice Inventory Trades " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The rows: the first cost at (10, 19), the result at (73, 19) as slot widgets 800 + 3 r + c + 1.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) >= 801 AND SM-W-ARG(WS-I) <= 806
             MOVE SM-W-ARG(WS-I) TO WS-E1
             MOVE SM-W-X(WS-I) TO WS-E2
             MOVE SM-W-Y(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E1) "@" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "=" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-5§2.10 row 0: first cost (base count 2, shown as the base when the price differs) at (32, 56), second cost 4 at (62, 56), result at (95, 56) with no count; row 1: base 5, no second cost" TO TL-CASE
     MOVE "801@32:56=2 802@62:56=4 803@95:56= 804@32:76=5 806@95:76= " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.10 first-cost decorations: the base count at x, the modified count right-aligned to x + 31 at y + 9, and the strike-through 9 x 2 at (x + 7, y + 12) over the base count.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) >= 800 AND SM-W-Y(WS-I) < 100
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING "count " SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 9 AND SM-W-H(WS-I) = 2 AND SM-W-Y(WS-I) < 100
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING "strike@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "3" TO WS-TEXT
     MOVE 1 TO WS-LOOP
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LOOP WS-N
     COMPUTE WS-D1 = 32 + 31 - WS-N
     MOVE WS-D1 TO WS-E1
     MOVE "2" TO WS-TEXT
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LOOP WS-N
     COMPUTE WS-D1 = 32 + 31 - WS-N
     MOVE WS-D1 TO WS-E2
     MOVE SPACES TO TL-EXPECTED
     STRING "count 3@" FUNCTION TRIM(WS-E1) ":65 strike@39:68 count 2@" FUNCTION TRIM(WS-E2) ":85 strike@39:88 " DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-5§2.10 a price that differs from the base: the modified count (3 and 2) is drawn at x + 31 - width, y + 9 and the discount strike-through 9 x 2 at (x + 7, y + 12)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.10 row tooltips: the pointer over the first cost (button x < 20), the second cost (30 to 50) or the result (> 65) gives that item's tooltip; the gaps and the arrow none.
     MOVE 5 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-TEXT WS-LOOP
     MOVE SPACES TO TL-EXPECTED
     STRING "1:" WS-TEXT(1:WS-LOOP) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE 37 TO WS-D1
     MOVE 60 TO WS-D2
     PERFORM POINT-GUI
     MOVE "acceptance US12 40-5§2.10 the pointer over the first cost of row 0 gives the item tooltip of its item" TO TL-CASE
     PERFORM TIP-LIST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-TEXT WS-LOOP
     MOVE SPACES TO TL-EXPECTED
     STRING "1:" WS-TEXT(1:WS-LOOP) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE 62 TO WS-D1
     PERFORM POINT-GUI
     MOVE "acceptance US12 40-5§2.10 the pointer over the second cost (button x 35) gives its item tooltip" TO TL-CASE
     PERFORM TIP-LIST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-ITEM
     CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-ITEM WS-TEXT WS-LOOP
     MOVE SPACES TO TL-EXPECTED
     STRING "1:" WS-TEXT(1:WS-LOOP) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE 97 TO WS-D1
     PERFORM POINT-GUI
     MOVE "acceptance US12 40-5§2.10 the pointer over the result (button x 70) gives its item tooltip" TO TL-CASE
     PERFORM TIP-LIST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 52 TO WS-D1
     PERFORM POINT-GUI
     MOVE "acceptance US12 40-5§2.10 the pointer over the gap between the costs (button x 25) gives no tooltip" TO TL-CASE
     PERFORM TIP-LIST
     MOVE "0:" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-D1
     MOVE 0 TO WS-D2
     PERFORM POINT-GUI
*>   XP bar (level 2, xp 20): background 102 x 5 at (158, 53), current int(102 / 60 x 10) = 17.
     PERFORM OVERLAY-LIST
     MOVE "acceptance US12 40-5§2.10 the XP bar: background 102 x 5 at (158, 53) and the current part 17 wide (xp 20 of 10 to 70)" TO TL-CASE
     MOVE "158:53:102x5 158:53:17x5 " TO TL-EXPECTED
     MOVE SPACES TO WS-TEXT
     PERFORM OVERLAY-FILTER-XP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-5§2.10 more than 7 offers: the scroller thumb 6 x 27 at (116, 55) (offset 0) and no cross while the selected offer 0 is in stock" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE "116:55:6x27 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-SCROLL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Select trade: click on row 1.
     PERFORM DRAIN
     MOVE 40 TO WS-D1
     MOVE 85 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§2.7 a click on row 1 sends Select Trade (05c 0x34) with index 1: 3401" TO TL-CASE
     MOVE "3401" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§2.7 the selected offer is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MC-SELECTED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Scroll: the wheel moves the offset; the row buttons then send offset + row.
     MOVE -1 TO IN-SCROLL-Y
     CALL "MENU-EXTRA-INPUT" USING CLIENT-STATE
     MOVE "acceptance US12 40-5§2.10 the wheel down (-1) moves the offset to 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MC-SCROLL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO IN-SCROLL-Y
     CALL "MENU-EXTRA-INPUT" USING CLIENT-STATE
     MOVE "acceptance US12 40-5§2.10 the offset never goes below 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MC-SCROLL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -9 TO IN-SCROLL-Y
     CALL "MENU-EXTRA-INPUT" USING CLIENT-STATE
     MOVE "acceptance US12 40-5§2.10 the offset never goes above count - 7 (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MC-SCROLL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO IN-SCROLL-Y
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§2.10 with offset 1 (last): the thumb is at y 55 + 113 = 168" TO TL-CASE
     MOVE "116:168:6x27 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-SCROLL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DRAIN
     MOVE 40 TO WS-D1
     MOVE 65 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§2.7 with offset 1 a click on the first row selects offer 1 + 0 = 1: 3401" TO TL-CASE
     MOVE "3401" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drag the scroller: press on the thumb column, move to the top (offset 0), release.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = (22 + 96) * 2
     COMPUTE WS-Y(1) = (37 + 20) * 2
     MOVE WS-X(1) TO WS-X(2)
     MOVE WS-Y(1) TO WS-Y(2)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§2.10 a press on the thumb column and the drag to the top give offset 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MC-SCROLL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-5§2.10 the drag is on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MC-DRAGGING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = (22 + 96) * 2
     COMPUTE WS-Y(1) = (37 + 150) * 2
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-X(1) TO WS-X(2)
     MOVE WS-Y(1) TO WS-Y(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     MOVE "acceptance US12 40-5§2.10 a drag to the bottom gives the last offset (1) and the release ends it" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = MC-SCROLL * 10 + MC-DRAGGING
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out-of-stock cross of the selected offer 2 and its tooltip.
     MOVE 0 TO MC-SCROLL
     MOVE 2 TO MC-SELECTED
     MOVE 450 TO IN-CURSOR-X
     MOVE 150 TO IN-CURSOR-Y
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§2.10 the selected offer 2 is out of stock: the cross 28 x 21 at (204, 72)" TO TL-CASE
     MOVE "204:72:28x21 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-CROSS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§2.10 the pointer over the cross (x 186 to 208, y 35 to 56) of a restocking villager shows merchant.deprecated" TO TL-CASE
     MOVE "Villagers restock up to two times per day." TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MC-RESTOCK
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§2.10 a villager that cannot restock (the wandering trader) shows no tooltip" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE TT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No progress bar: the title is plain and there is no XP bar; level 5: no bar.
     MOVE 0 TO MC-PROGRESS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM LABEL-LIST
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§2.10 without the progress flag the title is the screen title alone" TO TL-CASE
     MOVE "Loot Inventory Trades " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO MC-PROGRESS
     MOVE 5 TO MC-LEVEL
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE SPACES TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-XP
     MOVE "acceptance US12 40-5§2.10 at level 5 nothing of the XP bar is drawn" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO MC-LEVEL
     MOVE 5 TO MC-XP
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE "158:53:102x5 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-XP
     MOVE "acceptance US12 40-5§2.10 xp below the level's minimum: only the background" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The result slot filled: the preview of the selected offer's xp (5) after the current part.
     MOVE 20 TO MC-XP
     MOVE 0 TO MC-SELECTED
     MOVE 1 TO BX-COUNT(3)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE "158:53:102x5 158:53:17x5 175:53:8x5 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-XP
     MOVE "acceptance US12 40-5§2.10 a result in slot 2 previews the offer's xp 5: floor(5 x 1.7) = 8 wide after the current 17" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BX-COUNT(3)
*>   An offers packet for another container is dropped; a malformed predicate leaves no offers.
     MOVE 77 TO WS-D3
     PERFORM SEND-OFFERS-OTHER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§2 a Merchant Offers packet for another container does not replace the offers" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE MC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-D3
     MOVE 99 TO WS-D4
     PERFORM SEND-OFFERS-OTHER
     MOVE "acceptance US12 40-5§2 an offer whose cost predicate has a component the client cannot size leaves no offers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-D4
     MOVE 40 TO WS-D1
     PERFORM SEND-OFFERS-OTHER
     MOVE "acceptance US12 40-5§2 40 offers: the first 32 are kept" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE MC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-LOOP FROM 1 BY 1 UNTIL WS-LOOP > 3
         EVALUATE WS-LOOP
             WHEN 1 MOVE 4 TO WS-D4
             WHEN 2 MOVE 21 TO WS-D4
             WHEN OTHER MOVE 7 TO WS-D4
         END-EVALUATE
         MOVE 9 TO WS-D3
         MOVE 3 TO WS-D1
         PERFORM SEND-OFFERS-OTHER
         MOVE "acceptance US12 40-5§2 predicate components without payload (4), a Boolean (21) and a Float (7) are sized: 3 offers" TO TL-CASE
         MOVE 3 TO TL-EXPECTED-N
         MOVE MC-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "T" TO TL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM OVERLAY-LIST
     MOVE "acceptance US12 40-5§2.10 with 3 offers (they fit) the scroller is the disabled thumb 6 x 27 at (116, 55)" TO TL-CASE
     MOVE "116:55:6x27 " TO TL-EXPECTED
     PERFORM OVERLAY-FILTER-SCROLL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Beacon.
     MOVE 9 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 2 TO BM-DATA(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM BEACON-BUTTONS
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§3 pyramid level 2: the first two tiers are clickable: speed (98, 32), haste (122, 32), resistance (98, 57), jump boost (122, 57); strength (110, 82) is not" TO TL-CASE
     MOVE "54:98:32:1 54:122:32:3 54:98:57:11 54:122:57:8 57:235:117:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ARG
     MOVE ACT-BEACON-PRIMARY TO WS-ACTION
     CALL "MENU-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     MOVE 11 TO WS-ARG
     CALL "MENU-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     MOVE 1 TO WS-ARG
     CALL "MENU-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     MOVE 1 TO WS-ARG
     CALL "MENU-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM BEACON-BUTTONS
     MOVE "acceptance US12 40-5§3.7 after choosing speed (and resistance, then speed again) speed is selected, not clickable; the upgrade button (213, 57) is inactive below level 4" TO TL-CASE
     MOVE "54:122:32:3 54:98:57:11 54:122:57:8 57:235:117:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§3.7 choosing a primary clears a different secondary and keeps the chosen primary 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BC-PRIMARY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO BM-DATA(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM BEACON-BUTTONS
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§3.7 level 4: strength (110, 82), regeneration (189, 57) and the upgrade button (213, 57) are active" TO TL-CASE
     MOVE "54:122:32:3 54:98:57:11 54:122:57:8 54:110:82:5 55:189:57:10 55:213:57:0 57:235:117:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ARG
     MOVE ACT-BEACON-SECONDARY TO WS-ACTION
     CALL "MENU-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§3.7 the upgrade button sets the secondary to the primary (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BC-SECONDARY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM LABEL-LIST
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-5§3.7 the headings Primary Power and Secondary Power (no title, no inventory label), colour #E0E0E0" TO TL-CASE
     MOVE "Primary Power Secondary Power " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Confirm without a payment is inactive; with a payment it sends Set Beacon (speed, speed) and closes.
     PERFORM BEACON-BUTTONS
     MOVE "acceptance US12 40-5§3.7 confirm needs a payment: with an empty payment slot it is not clickable" TO TL-CASE
     MOVE "54:122:32:3 54:98:57:11 54:122:57:8 54:110:82:5 55:189:57:10 57:235:117:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BX-COUNT(1)
     MOVE 5 TO BX-ITEM(1)
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     MOVE 120 TO WS-D1
     MOVE 127 TO WS-D2
     MOVE 164 TO WS-D1
     MOVE 117 TO WS-D2
     ADD 55 TO WS-D1
     ADD 10 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:8) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§3.4 confirm sends Set Beacon (05c 0x35): present speed (0), present speed (0): 35010001" TO TL-CASE
     MOVE "35010001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§3.7 confirm closes the screen: the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Set Beacon with only a primary: absent secondary is a false flag.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 3 TO WS-D1
     MOVE 0 TO WS-D2
     CALL "CLP-SET-BEACON" USING PB-BUFFER WS-D1 WS-D2
     MOVE "acceptance US12 40-5§3.4 Set Beacon with haste (2) and no secondary: 35 01 02 00 (4 bytes)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Data slots 1 and 2 set the powers (Container Set Data 0x13).
     MOVE 9 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 9 TO WS-D1
     MOVE 1 TO WS-D2
     MOVE 3 TO WS-D3
     PERFORM SET-DATA
     MOVE 2 TO WS-D2
     MOVE 10 TO WS-D3
     PERFORM SET-DATA
     MOVE "acceptance US12 40-5§3.3 Container Set Data slots 1 and 2 give the screen's primary 3 (haste) and secondary 10 (regeneration)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 10
     COMPUTE TL-OBSERVED-N = BC-PRIMARY * 100 + BC-SECONDARY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-D2
     MOVE 2 TO WS-D3
     PERFORM SET-DATA
     MOVE "acceptance US12 40-5§3.3 slot 0 is the pyramid level and leaves the powers alone" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 10
     COMPUTE TL-OBSERVED-N = BC-PRIMARY * 100 + BC-SECONDARY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Tooltips: the speed button (98, 32) and the upgrade button.
     MOVE 4 TO BM-DATA(1)
     MOVE 200 TO IN-CURSOR-X
     MOVE 70 TO IN-CURSOR-Y
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§3.7 the pointer over the speed button shows its effect name" TO TL-CASE
     MOVE "Speed" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 426 TO IN-CURSOR-X
     MOVE 120 TO IN-CURSOR-Y
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§3.7 the upgrade button's tooltip is the primary's name and ' II': Haste II" TO TL-CASE
     MOVE "Haste II" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 430 TO IN-CURSOR-X
     MOVE 238 TO IN-CURSOR-Y
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§3.7 the pointer over confirm shows Done" TO TL-CASE
     MOVE "Done" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 482 TO IN-CURSOR-X
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-L-TEXT(1)(1:TT-L-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§3.7 the pointer over cancel shows Cancel" TO TL-CASE
     MOVE "Cancel" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Lectern.
     MOVE 17 TO WS-TYPE
     PERFORM OPEN-TYPE
     MOVE 1 TO BM-DATA(1)
     MOVE 0 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM LECTERN-LIST
     MOVE "acceptance US12 40-5§4.7 lectern at page 1 of a survival player: back (107, 159) button 1, forward (180, 159) button 2, Done (60, 196), Take Book (162, 196) button 3" TO TL-CASE
     MOVE "53:107:159:1 53:180:159:2 57:60:196:0 53:162:196:3 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM LABEL-LIST
     MOVE "acceptance US12 40-5§4.7 the page indicator 'Page 2 of 2' right-aligned to backgroundLeft + 148 = 212 at y 18" TO TL-CASE
     MOVE "Page 2 of 2 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BM-DATA(1)
     MOVE 3 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM LECTERN-LIST
     MOVE "acceptance US12 40-5§4.7 page 0 hides back; a spectator gets Done alone, 200 wide at (60, 196)" TO TL-CASE
     MOVE "53:180:159:2 57:60:196:0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     MOVE 190 TO WS-D1
     MOVE 165 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:6) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§4.4 the forward button sends Container Button Click id 2: 110902" TO TL-CASE
     MOVE "110902" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM DRAIN
     MOVE 180 TO WS-D1
     MOVE 206 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM DRAIN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(1:6) TO TL-OBSERVED
     MOVE "acceptance US12 40-5§4.4 Take Book sends button id 3: 110903" TO TL-CASE
     MOVE "110903" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 100 TO WS-D1
     MOVE 206 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-5§4.7 Done closes the lectern screen: the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
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

*> Container Set Data: container WS-D1, property WS-D2, value WS-D3.
 SET-DATA.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D1
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-D2
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-D3
     MOVE 19 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

*> The 8 offers of container 9: offer k (0 to 7) costs item 5 + k x 2 (k = 0: 2, k = 1: 5 with special -5, k = 2: out of stock, 5000 demand), result item 7 count 1 (k = 0 has a second cost
*> of item 9 x 4 and a one-component predicate on cost A).
 SEND-OFFERS.
     MOVE 9 TO WS-D3
     MOVE 8 TO WS-D1
     MOVE 3 TO WS-D4
     PERFORM SEND-OFFERS-OTHER
     .

*> Merchant Offers for container WS-D3 with WS-D1 offers; WS-D4 is the predicate component type of offer 0 (3 = a VarInt component, 99 = a component the client cannot size).
 SEND-OFFERS-OTHER.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D3
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D1
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-D1
         COMPUTE WS-I = 5 + WS-K * 2
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         MOVE 2 TO WS-I
         IF WS-K = 1
             MOVE 5 TO WS-I
         END-IF
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         IF WS-K = 0
             MOVE 1 TO WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D4
             EVALUATE WS-D4
                 WHEN 4
                     CONTINUE
                 WHEN 21
                     MOVE 1 TO WS-I
                     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
                 WHEN 7
                     MOVE 0.5 TO WS-FLOATV
                     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLOATV
                 WHEN OTHER
                     MOVE 7 TO WS-I
                     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
             END-EVALUATE
         ELSE
             MOVE 0 TO WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         END-IF
         MOVE 1 TO WS-I
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         MOVE 7 TO WS-I
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         MOVE 0 TO WS-I
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         IF WS-K = 0
             MOVE 1 TO WS-I
             CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
             MOVE 9 TO WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
             MOVE 4 TO WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
             MOVE 0 TO WS-I
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
         ELSE
             MOVE 0 TO WS-I
             CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
         END-IF
         MOVE 0 TO WS-I
         IF WS-K = 2
             MOVE 1 TO WS-I
         END-IF
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
         MOVE 0 TO WS-I
         CALL "PB-PUT-INT" USING PB-BUFFER WS-I
         MOVE 10 TO WS-I
         CALL "PB-PUT-INT" USING PB-BUFFER WS-I
         MOVE 5 TO WS-I
         CALL "PB-PUT-INT" USING PB-BUFFER WS-I
         MOVE 0 TO WS-I
         IF WS-K = 1
             MOVE -5 TO WS-I
         END-IF
         CALL "PB-PUT-INT" USING PB-BUFFER WS-I
         MOVE 0.05 TO WS-FLOATV
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FLOATV
         MOVE 10 TO WS-I
         IF WS-K = 2
             MOVE 5000 TO WS-I
         END-IF
         CALL "PB-PUT-INT" USING PB-BUFFER WS-I
     END-PERFORM
     MOVE 2 TO WS-I
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
     MOVE 20 TO WS-I
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
     MOVE 1 TO WS-I
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-I
     MOVE 53 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

 DRAIN.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .

*> A click on the GUI point (WS-D1, WS-D2) (GUI scale 2).
 CLICK-GUI.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = WS-D1 * 2
     COMPUTE WS-Y(1) = WS-D2 * 2
     MOVE WS-X(1) TO WS-X(2) WS-X(3)
     MOVE WS-Y(1) TO WS-Y(2) WS-Y(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> The pointer to the GUI point (WS-D1, WS-D2) (GUI scale 2), one frame.
 POINT-GUI.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-X(1) = WS-D1 * 2
     COMPUTE WS-Y(1) = WS-D2 * 2
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> TL-OBSERVED: the tooltip line count and ":" and its first line.
 TIP-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE TT-COUNT TO WS-E1
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-E1) ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF TT-COUNT > 0
         STRING TT-L-TEXT(1)(1:TT-L-LEN(1)) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     .

*> The label texts in widget order, space-terminated.
 LABEL-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-ARG(WS-I) < 800
             STRING SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> Every overlay as "x:y:wxh " in TL-OBSERVED.
 OVERLAY-LIST.
     MOVE SPACES TO WS-TOKEN
     MOVE 1 TO WS-OPTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " "
                 DELIMITED BY SIZE INTO WS-TOKEN WITH POINTER WS-OPTR
         END-IF
     END-PERFORM
     MOVE WS-TOKEN TO TL-OBSERVED
     .

*> Of the overlay list keep those 102 x 5, 17x5, 8x5 wide ones (the XP bar).
 OVERLAY-FILTER-XP.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-H(WS-I) = 5 AND SM-W-Y(WS-I) = 53
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x5 " DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 OVERLAY-FILTER-SCROLL.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 6 AND SM-W-H(WS-I) = 27
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":6x27 " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 OVERLAY-FILTER-CROSS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 28 AND SM-W-H(WS-I) = 21
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":28x21 " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> The clickable areas of a beacon: "action:x:y:argument " each.
 BEACON-BUTTONS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-IMAGE AND SM-W-ACTION(WS-I) >= ACT-BEACON-PRIMARY AND SM-W-ACTION(WS-I) <= ACT-CLOSE-MENU
             MOVE SM-W-ACTION(WS-I) TO WS-E4
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-ARG(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E4) ":" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> The lectern's buttons and click areas: "action:x:y:argument ".
 LECTERN-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF (SM-W-KIND(WS-I) = WK-IMAGE OR SM-W-KIND(WS-I) = WK-BUTTON) AND SM-W-ACTION(WS-I) NOT = ACT-NONE
             MOVE SM-W-ACTION(WS-I) TO WS-E4
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-ARG(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E4) ":" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " "
                 DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-5.

 COPY CLTEST.
