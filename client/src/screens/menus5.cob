*> The merchant, beacon and lectern screens (docs/protocol/40-menus-5-merchant-beacon-lectern.md). The sprites of these screens (villager.png, beacon.png, the buttons and arrows) are not in the
*> built-in pack, so each is a swatch overlay of the sprite's drawn size; icons are the mob-effect sprites where the pack has them. MENU-DECOR (workstation.cob) calls MERCHANT-DECOR,
*> BEACON-DECOR and LECTERN-DECOR; MENU-ACTION handles the actions of their buttons; MENU-EXTRA-INPUT the merchant's wheel and scroller drag.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MERCHANT-OFFERS-READ.
*> USING CLIENT-STATE, PB-BUFFER: Merchant Offers (05a 0x35): container id, the offers (each: cost A = item, count, a predicate of typed components skipped; the result stack; optional
*> cost B; out-of-stock flag; uses, max uses, xp, special price diff (Int), price multiplier (Float), demand (Int)), level, xp, show progress, can restock. Stored for the open merchant
*> menu (the first 32 offers); a packet for another container or menu is read and dropped, and a component type the client cannot size ends the packet unread (no offers).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STORE               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SCRATCH             BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-BOOL                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     GO TO MAIN-FLOW.

*> An ItemCost: item, count, then the components of its predicate (type and value, sized as an item stack's components are).
 COST-READ.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ITEM
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-SCRATCH OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-TYPE
         EVALUATE WS-TYPE
             WHEN 1 WHEN 2 WHEN 3 WHEN 12 WHEN 19 WHEN 31 WHEN 75
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-J
             WHEN 4 WHEN 22 WHEN 34
                 CONTINUE
             WHEN 21
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-J
             WHEN 7 WHEN 54
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
     END-PERFORM
     .

 MAIN-FLOW.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-N
     MOVE 0 TO WS-STORE
     IF PB-ERROR = 0 AND WS-CONTAINER = BM-ID AND BM-TYPE = 19 AND WS-N >= 0
         MOVE 1 TO WS-STORE
         MOVE 0 TO MC-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR PB-ERROR = 1
*>       Cost A, then the result, then the optional cost B.
         PERFORM COST-READ
         MOVE WS-ITEM TO WS-K
         MOVE WS-COUNT TO WS-J
         CALL "PB-GET-ITEM-STACK" USING PB-BUFFER WS-ITEMSTACK-X
         IF WS-STORE = 1 AND WS-I <= 32
             MOVE WS-K TO MO-A-ITEM(WS-I)
             MOVE WS-J TO MO-A-COUNT(WS-I)
             MOVE WS-ISX-ITEM TO MO-R-ITEM(WS-I)
             MOVE WS-ISX-COUNT TO MO-R-COUNT(WS-I)
             MOVE 0 TO MO-B-ITEM(WS-I) MO-B-COUNT(WS-I)
         END-IF
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
         IF WS-FLAG = 1
             PERFORM COST-READ
             IF WS-STORE = 1 AND WS-I <= 32
                 MOVE WS-ITEM TO MO-B-ITEM(WS-I)
                 MOVE WS-COUNT TO MO-B-COUNT(WS-I)
             END-IF
         END-IF
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOL
         CALL "PB-GET-INT" USING PB-BUFFER WS-K
         CALL "PB-GET-INT" USING PB-BUFFER WS-J
         IF WS-STORE = 1 AND WS-I <= 32
             MOVE WS-BOOL TO MO-OUT(WS-I)
             MOVE WS-K TO MO-USES(WS-I)
             MOVE WS-J TO MO-MAX(WS-I)
             IF WS-BOOL = 1
                 MOVE WS-J TO MO-USES(WS-I)
             END-IF
             CALL "PB-GET-INT" USING PB-BUFFER MO-XP(WS-I)
             CALL "PB-GET-INT" USING PB-BUFFER MO-SPECIAL(WS-I)
             CALL "PB-GET-FLOAT" USING PB-BUFFER MO-MULT(WS-I)
             CALL "PB-GET-INT" USING PB-BUFFER MO-DEMAND(WS-I)
             ADD 1 TO MC-COUNT
         ELSE
             CALL "PB-GET-INT" USING PB-BUFFER WS-SCRATCH
             CALL "PB-GET-INT" USING PB-BUFFER WS-SCRATCH
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             CALL "PB-GET-INT" USING PB-BUFFER WS-SCRATCH
         END-IF
     END-PERFORM
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-K
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-J
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOL
     IF PB-ERROR = 1 AND WS-STORE = 1
         MOVE 0 TO MC-COUNT
     END-IF
     IF PB-ERROR = 0 AND WS-STORE = 1
         MOVE WS-K TO MC-LEVEL
         MOVE WS-J TO MC-XP
         MOVE WS-FLAG TO MC-PROGRESS
         MOVE WS-BOOL TO MC-RESTOCK
     END-IF
     GOBACK.
 END PROGRAM MERCHANT-OFFERS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MERCHANT-PRICE.
*> USING CLIENT-STATE, offer index (1-based), modified first cost count out (2.4): adj = max(0, floor(c x d x m)) with the product taken as a float, count = clamp(c + adj + special
*> price diff, 1, the cost item's maximum stack size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ADJ                 BINARY-LONG.
 01 WS-PRODUCT             FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INDEX L-COUNT.
     CALL "ITEM-MAX-STACK" USING MO-A-ITEM(L-INDEX) WS-MAX
     COMPUTE WS-PRODUCT = MO-A-COUNT(L-INDEX) * MO-DEMAND(L-INDEX)
     COMPUTE WS-ADJ = FUNCTION MAX(0, FUNCTION INTEGER(WS-PRODUCT * MO-MULT(L-INDEX)))
     COMPUTE L-COUNT = FUNCTION MAX(1, FUNCTION MIN(MO-A-COUNT(L-INDEX) + WS-ADJ + MO-SPECIAL(L-INDEX), WS-MAX))
     GOBACK.
 END PROGRAM MERCHANT-PRICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MERCHANT-DECOR.
*> USING CLIENT-STATE, left, top: the merchant's trades (2.10): the "Trades" label, then with offers the seven row buttons (88 x 20 at (5, 18 + 20 k), visible while k is below the offer
*> count; the selected offer's button is drawn selected), the visible rows (first cost at (10, 19 + 20 r) as a bare item with its modified count, second cost at 40, the arrow 10 x 9 at
*> (60, +3), red when out of stock, the result at 73), the scroller (6 x 27 thumb at (94, 18 + t), the disabled one when the offers fit), the XP bar when progress is shown (102 x 5 at
*> (136, 16), the current part and the preview of the trade shown in the result slot) and the out-of-stock cross (28 x 21 at (182, 35)) of the selected offer with its tooltip.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-PRICE               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-FUTURE              BINARY-LONG.
 01 WS-SCALE               FLOAT-SHORT.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EDIT                PIC Z(8)9.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT256              PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-LABEL-W             BINARY-LONG VALUE 160.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-XP-TABLE.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 70.
    05 FILLER              BINARY-LONG VALUE 150.
    05 FILLER              BINARY-LONG VALUE 250.
 01 WS-XP-T REDEFINES WS-XP-TABLE.
    05 WS-XPT              BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     GO TO MAIN-FLOW.

 BUTTONS-AND-ROWS.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 6 OR WS-K >= MC-COUNT
         COMPUTE WS-X = L-LEFT + 5
         COMPUTE WS-Y = L-TOP + 18 + 20 * WS-K
         MOVE 88 TO WS-W
         MOVE 20 TO WS-H
         MOVE SW-BUTTON TO WS-SWATCH
         IF MC-SELECTED = WS-K + MC-SCROLL
             MOVE SW-SELECTED TO WS-SWATCH
         END-IF
         MOVE WK-OVERLAY TO WS-KIND
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
         MOVE WK-IMAGE TO WS-KIND
         MOVE ACT-TRADE-SELECT TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-K WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
         MOVE ACT-NONE TO WS-ACTION
     END-PERFORM
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 6 OR WS-R + MC-SCROLL >= MC-COUNT
         COMPUTE WS-I = WS-R + MC-SCROLL + 1
         COMPUTE WS-Y = L-TOP + 19 + 20 * WS-R
         CALL "MERCHANT-PRICE" USING CLIENT-STATE WS-I WS-PRICE
         COMPUTE WS-N = 3 * WS-R + 1
         MOVE MO-A-ITEM(WS-I) TO MC-DISP-ITEM(WS-N)
         MOVE WS-PRICE TO MC-DISP-COUNT(WS-N)
         MOVE MO-B-ITEM(WS-I) TO MC-DISP-ITEM(WS-N + 1)
         MOVE MO-B-COUNT(WS-I) TO MC-DISP-COUNT(WS-N + 1)
         MOVE MO-R-ITEM(WS-I) TO MC-DISP-ITEM(WS-N + 2)
         MOVE MO-R-COUNT(WS-I) TO MC-DISP-COUNT(WS-N + 2)
         COMPUTE WS-X = L-LEFT + 10
         IF WS-PRICE NOT = MO-A-COUNT(WS-I)
             PERFORM DISCOUNT-WIDGET
         ELSE
             PERFORM ITEM-WIDGET
         END-IF
         IF MO-B-COUNT(WS-I) > 0
             COMPUTE WS-X = L-LEFT + 40
             ADD 1 TO WS-N
             PERFORM ITEM-WIDGET
             SUBTRACT 1 FROM WS-N
         END-IF
         COMPUTE WS-X = L-LEFT + 60
         COMPUTE WS-Y = L-TOP + 22 + 20 * WS-R
         MOVE 10 TO WS-W
         MOVE 9 TO WS-H
         MOVE SW-WHITE TO WS-SWATCH
         IF MO-OUT(WS-I) = 1 OR MO-USES(WS-I) >= MO-MAX(WS-I)
             MOVE SW-HURT TO WS-SWATCH
         END-IF
         MOVE WK-OVERLAY TO WS-KIND
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
         COMPUTE WS-X = L-LEFT + 73
         COMPUTE WS-Y = L-TOP + 19 + 20 * WS-R
         ADD 2 TO WS-N
         PERFORM ITEM-WIDGET
     END-PERFORM
     PERFORM ROW-TOOLTIP
     .

*> 2.10 first-cost decorations of a changed price: the item with the base count (text "1" too) at x, the modified count right-aligned to x + 31 at y + 9 and the
*> strike-through 9 x 2 at (x + 7, y + 12).
 DISCOUNT-WIDGET.
     MOVE MC-DISP-COUNT(WS-N) TO WS-PRICE
     MOVE MO-A-COUNT(WS-I) TO MC-DISP-COUNT(WS-N)
     MOVE SPACES TO WS-TEXT
     MOVE MO-A-COUNT(WS-I) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     COMPUTE WS-ARG = 800 + WS-N
     MOVE WK-SLOT TO WS-KIND
     MOVE 16 TO WS-W WS-H
     MOVE 3 TO WS-STATE
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     MOVE WS-PRICE TO MC-DISP-COUNT(WS-N)
     MOVE WS-PRICE TO WS-EDIT
     MOVE SPACES TO WS-OUT256
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-OUT256
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT256 WS-LENGTH WS-WIDTH
     MOVE WS-OUT256 TO WS-TEXT
     COMPUTE WS-X = WS-X + 31 - WS-WIDTH
     COMPUTE WS-Y = WS-Y + 9
     MOVE WK-LABEL TO WS-KIND
     MOVE WS-LABEL-W TO WS-W
     MOVE WS-LABEL-H TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     COMPUTE WS-X = L-LEFT + 17
     COMPUTE WS-Y = L-TOP + 19 + 20 * WS-R + 12
     MOVE 9 TO WS-W
     MOVE 2 TO WS-H
     MOVE SW-HURT TO WS-SWATCH
     MOVE WK-OVERLAY TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     COMPUTE WS-Y = L-TOP + 19 + 20 * WS-R
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH WS-STATE WS-ARG
     .

*> 2.10 row tooltips: the pointer over a row button (88 x 20): x < 20 the first cost, 30 < x < 50 the second cost (when there is one), x > 65 the result: that item's name.
 ROW-TOOLTIP.
     COMPUTE WS-MX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-MY = IN-CURSOR-Y / CL-GUI-SCALE
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 6 OR WS-R + MC-SCROLL >= MC-COUNT
         COMPUTE WS-I = WS-R + MC-SCROLL + 1
         COMPUTE WS-X = WS-MX - L-LEFT - 5
         COMPUTE WS-Y = WS-MY - L-TOP - 18 - 20 * WS-R
         MOVE 0 TO WS-N
         IF WS-X >= 0 AND WS-X < 88 AND WS-Y >= 0 AND WS-Y < 20
             EVALUATE TRUE
                 WHEN WS-X < 20
                     MOVE MO-A-ITEM(WS-I) TO WS-N
                     ADD 1 TO WS-N
                 WHEN WS-X > 30 AND WS-X < 50 AND MO-B-COUNT(WS-I) > 0
                     MOVE MO-B-ITEM(WS-I) TO WS-N
                     ADD 1 TO WS-N
                 WHEN WS-X > 65
                     MOVE MO-R-ITEM(WS-I) TO WS-N
                     ADD 1 TO WS-N
             END-EVALUATE
         END-IF
         IF WS-N > 0
             SUBTRACT 1 FROM WS-N
             CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-N WS-OUT WS-OUT-LENGTH
             MOVE WS-OUT(1:256) TO WS-OUT256
             MOVE FUNCTION MIN(WS-OUT-LENGTH, 120) TO WS-OUT-LENGTH
             MOVE WS-MX TO TT-X
             MOVE WS-MY TO TT-Y
             MOVE 1 TO TT-TITLE-GAP
             MOVE 16777215 TO WS-ARG
             CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-OUT256 WS-OUT-LENGTH WS-ARG
             MOVE 0 TO WS-ARG
         END-IF
     END-PERFORM
     .

*> A bare 16 x 16 item at (x, y) showing the display stack WS-N (argument 800 + WS-N), its count when above 1.
 ITEM-WIDGET.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH
     IF MC-DISP-COUNT(WS-N) > 1
         MOVE MC-DISP-COUNT(WS-N) TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     END-IF
     COMPUTE WS-ARG = 800 + WS-N
     MOVE WK-SLOT TO WS-KIND
     MOVE 16 TO WS-W WS-H
     MOVE 3 TO WS-STATE
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH WS-STATE WS-ARG
     .

*> 2.10 the scroller: n = count - 6; step = 1 + h / n + 139 / n with h = 139 - (27 + (n - 1) x 139 / n); t = min(113, scroll x step), 113 at the last offset.
 SCROLLER.
     COMPUTE WS-N = MC-COUNT - 6
     MOVE 6 TO WS-W
     MOVE 27 TO WS-H
     COMPUTE WS-X = L-LEFT + 94
     MOVE WK-OVERLAY TO WS-KIND
     IF WS-N > 1
         COMPUTE WS-T = 139 - (27 + (WS-N - 1) * 139 / WS-N)
         COMPUTE WS-STEP = 1 + WS-T / WS-N + 139 / WS-N
         COMPUTE WS-T = FUNCTION MIN(113, MC-SCROLL * WS-STEP)
         IF MC-SCROLL = WS-N - 1
             MOVE 113 TO WS-T
         END-IF
         MOVE SW-BUTTON TO WS-SWATCH
     ELSE
         MOVE 0 TO WS-T
         MOVE SW-BLACK TO WS-SWATCH
     END-IF
     COMPUTE WS-Y = L-TOP + 18 + WS-T
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     .

*> 2.10 the XP bar (nothing at level 5 and over or without the progress flag).
 XP-BAR.
     IF MC-PROGRESS = 1 AND MC-LEVEL >= 1 AND MC-LEVEL < 5
         COMPUTE WS-X = L-LEFT + 136
         COMPUTE WS-Y = L-TOP + 16
         MOVE 102 TO WS-W
         MOVE 5 TO WS-H
         MOVE SW-BLACK TO WS-SWATCH
         MOVE WK-OVERLAY TO WS-KIND
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
         MOVE WS-XPT(MC-LEVEL) TO WS-MIN
         MOVE WS-XPT(MC-LEVEL + 1) TO WS-MAX
         IF MC-XP >= WS-MIN
             COMPUTE WS-SCALE = 102.0 / (WS-MAX - WS-MIN)
             COMPUTE WS-CUR = FUNCTION MIN(FUNCTION INTEGER(WS-SCALE * (MC-XP - WS-MIN)), 102)
             IF WS-CUR > 0
                 MOVE WS-CUR TO WS-W
                 COMPUTE WS-SWATCH = SW-BAR-0 + 23
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
             END-IF
             MOVE 0 TO WS-FUTURE
             IF BX-COUNT(3) > 0 AND MC-SELECTED >= 0 AND MC-SELECTED < MC-COUNT
                 MOVE MO-XP(MC-SELECTED + 1) TO WS-FUTURE
             END-IF
             IF WS-FUTURE > 0
                 COMPUTE WS-W = FUNCTION MIN(FUNCTION INTEGER(WS-FUTURE * WS-SCALE), 102 - WS-CUR)
                 IF WS-W > 0
                     COMPUTE WS-X = L-LEFT + 136 + WS-CUR
                     MOVE SW-WHITE TO WS-SWATCH
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
                 END-IF
             END-IF
         END-IF
     END-IF
     .

*> 2.10 the cross of the selected out-of-stock offer at (182, 35), 28 x 21; the tooltip (merchant.deprecated) over x 186 to 208, y 35 to 56 when the villager can restock.
 CROSS.
     IF MC-SELECTED >= 0 AND MC-SELECTED < MC-COUNT
         COMPUTE WS-I = MC-SELECTED + 1
         IF MO-OUT(WS-I) = 1 OR MO-USES(WS-I) >= MO-MAX(WS-I)
             COMPUTE WS-X = L-LEFT + 182
             COMPUTE WS-Y = L-TOP + 35
             MOVE 28 TO WS-W
             MOVE 21 TO WS-H
             MOVE SW-HURT TO WS-SWATCH
             MOVE WK-OVERLAY TO WS-KIND
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
             COMPUTE WS-MX = IN-CURSOR-X / CL-GUI-SCALE
             COMPUTE WS-MY = IN-CURSOR-Y / CL-GUI-SCALE
             IF MC-RESTOCK = 1 AND WS-MX >= L-LEFT + 186 AND WS-MX < L-LEFT + 208
                     AND WS-MY >= L-TOP + 35 AND WS-MY < L-TOP + 56
                 MOVE "merchant.deprecated" TO WS-KEY
                 MOVE 19 TO WS-KEY-LENGTH
                 CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
                 MOVE WS-OUT(1:256) TO WS-OUT256
                 MOVE WS-MX TO TT-X
                 MOVE WS-MY TO TT-Y
                 MOVE 0 TO TT-TITLE-GAP
                 MOVE 16777215 TO WS-ARG
                 CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-OUT256 WS-OUT-LENGTH WS-ARG
             END-IF
         END-IF
     END-IF
     .

 MAIN-FLOW.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH WS-STATE WS-ACTION WS-ARG
*>   The "Trades" label at 53 - width / 2.
     MOVE "merchant.trades" TO WS-KEY
     MOVE 15 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     MOVE WS-OUT(1:256) TO WS-OUT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT256 WS-OUT-LENGTH WS-WIDTH
     COMPUTE WS-X = L-LEFT + 53 - WS-WIDTH / 2
     COMPUTE WS-Y = L-TOP + 6
     MOVE WK-LABEL TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-OUT WS-OUT-LENGTH WS-STATE
     IF MC-COUNT > 0
         PERFORM BUTTONS-AND-ROWS
         PERFORM SCROLLER
         PERFORM XP-BAR
         PERFORM CROSS
     END-IF
     GOBACK.
 END PROGRAM MERCHANT-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MERCHANT-TITLE.
*> USING CLIENT-STATE, title text (PIC X(256)) in and out, length in and out: with the progress bar shown and a level 1 to 5 the title is "<title> - <level name>"
*> (merchant.title with merchant.level.<n>), else unchanged (2.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLARGS.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LEVEL               PIC 9.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     IF BM-TYPE = 19 AND MC-PROGRESS = 1 AND MC-LEVEL >= 1 AND MC-LEVEL <= 5
         MOVE 2 TO LA-COUNT
         MOVE L-LENGTH TO LA-LENGTH(1)
         MOVE L-TEXT TO LA-TEXT(1)
         MOVE MC-LEVEL TO WS-LEVEL
         MOVE SPACES TO WS-KEY
         STRING "merchant.level." WS-LEVEL DELIMITED BY SIZE INTO WS-KEY
         MOVE 16 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT-LENGTH TO LA-LENGTH(2)
         MOVE WS-OUT(1:256) TO LA-TEXT(2)
         MOVE "merchant.title" TO WS-KEY
         MOVE 14 TO WS-KEY-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT(1:256) TO L-TEXT
         MOVE FUNCTION MIN(WS-OUT-LENGTH, 256) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM MERCHANT-TITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEACON-DECOR.
*> USING CLIENT-STATE, left, top: the beacon's widgets (3.7): the two heading labels (#E0E0E0) centred on x 62 and 169 at y 10, the 22 x 22 power buttons (primary rows speed and haste at
*> (53, 22) and (77, 22), resistance and jump boost at (53, 47) and (77, 47), strength at (65, 72); secondary regeneration at (144, 47); the upgrade button at (168, 47) once a primary is
*> chosen) each with its 18 x 18 mob-effect icon at (+2, +2), the confirm (164, 107) and cancel (190, 107) buttons; a button is active when its tier is below the pyramid level (data
*> slot 0) and selected when it is the chosen power; confirm needs a payment in the slot and a primary. The tooltip is the effect's name (" II" on the upgrade button, "Done", "Cancel").
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PAY-KEYS             PIC X(80).
 01 WS-PAY-TABLE REDEFINES WS-PAY-KEYS.
    05 WS-PAY-KEY          PIC X(16) OCCURS 5 TIMES.
 01 WS-PAY-DXS.
    05 WS-PAY-DX           BINARY-LONG OCCURS 5 TIMES.
 01 WS-TABLE.
*>   One row per power button: effect id, tier, x, y, secondary flag.
    05 WS-ROW OCCURS 6 TIMES.
       10 WS-R-EFFECT      BINARY-LONG.
       10 WS-R-TIER        BINARY-LONG.
       10 WS-R-X           BINARY-LONG.
       10 WS-R-Y           BINARY-LONG.
       10 WS-R-SECONDARY   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-SELECTED            BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT256              PIC X(256).
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-LABEL-W             BINARY-LONG VALUE 160.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-UPGRADE             BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 18.
 01 WS-SIZE2               BINARY-LONG VALUE 18.
 01 WS-NOACT               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP.
     GO TO MAIN-FLOW.

*> A heading centred on x (the screen's own, plus left) at y 10, in WS-COLOUR.
 HEADING-ADD.
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     MOVE WS-OUT(1:256) TO WS-OUT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT256 WS-OUT-LENGTH WS-WIDTH
     COMPUTE WS-W = L-LEFT + WS-X - WS-WIDTH / 2
     COMPUTE WS-Y = L-TOP + 10
     MOVE WK-LABEL TO WS-KIND
     MOVE 0 TO WS-ARG WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-W WS-Y WS-LABEL-W WS-LABEL-H WS-OUT WS-OUT-LENGTH WS-STATE
     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-COLOUR
     .

*> A power button at (WS-X, WS-Y): the box, the clickable area when active and not selected, and the effect icon (WS-EFFECT) 18 x 18 at (+2, +2).
 BUTTON.
     PERFORM BUTTON-BOX
     COMPUTE WS-ICON = GSP-MOB-EFFECT-0 + WS-EFFECT
     ADD 2 TO WS-X WS-Y
     MOVE WK-SPRITE TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NOACT WS-ICON WS-X WS-Y WS-SIZE WS-SIZE2 WS-TEXT WS-LENGTH WS-STATE
     SUBTRACT 2 FROM WS-X WS-Y
     .

*> The 22 x 22 box: disabled swatch black, selected the selected swatch, else the button swatch; a WK-IMAGE click area while active and not selected.
 BUTTON-BOX.
     MOVE 22 TO WS-W WS-H
     MOVE SW-BUTTON TO WS-SWATCH
     IF WS-ACTIVE = 0
         MOVE SW-BLACK TO WS-SWATCH
     END-IF
     IF WS-SELECTED = 1
         MOVE SW-SELECTED TO WS-SWATCH
     END-IF
     MOVE WK-OVERLAY TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NOACT WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     IF WS-ACTIVE = 1 AND WS-SELECTED = 0
         MOVE WK-IMAGE TO WS-KIND
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-IF
     .

*> The tooltip of a power button when the pointer is over its box: the effect's name, " II" after it on the upgrade button.
 TOOLTIP.
     IF WS-MX >= WS-X AND WS-MX < WS-X + 22 AND WS-MY >= WS-Y AND WS-MY < WS-Y + 22
         CALL "EFFECT-NAME-TEXT" USING CLIENT-STATE WS-EFFECT WS-AMP WS-NAME WS-NAME-LENGTH
         IF WS-UPGRADE = 1
             MOVE " II" TO WS-NAME(WS-NAME-LENGTH + 1:3)
             ADD 3 TO WS-NAME-LENGTH
         END-IF
         MOVE WS-NAME TO WS-OUT256
         PERFORM TOOLTIP-SET
     END-IF
     .

 TOOLTIP-KEY.
     IF WS-MX >= WS-X AND WS-MX < WS-X + 22 AND WS-MY >= WS-Y AND WS-MY < WS-Y + 22
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT(1:256) TO WS-OUT256
         MOVE WS-OUT-LENGTH TO WS-NAME-LENGTH
         PERFORM TOOLTIP-SET
     END-IF
     .

 TOOLTIP-SET.
     MOVE WS-MX TO TT-X
     MOVE WS-MY TO TT-Y
     MOVE 0 TO TT-TITLE-GAP
     MOVE 16777215 TO WS-COLOUR
     CALL "TOOLTIP-ADD" USING CLIENT-STATE WS-OUT256 WS-NAME-LENGTH WS-COLOUR
     MOVE 14737632 TO WS-COLOUR
     .

 MAIN-FLOW.
     MOVE 0 TO WS-STATE WS-ACTION WS-ARG
     MOVE SPACES TO WS-TEXT
     MOVE BM-DATA(1) TO WS-LEVELS
     MOVE SPACES TO WS-TABLE
     MOVE 0 TO WS-R-EFFECT(1) WS-R-TIER(1) WS-R-SECONDARY(1)
     MOVE 53 TO WS-R-X(1)
     MOVE 22 TO WS-R-Y(1)
     MOVE 2 TO WS-R-EFFECT(2)
     MOVE 0 TO WS-R-TIER(2) WS-R-SECONDARY(2)
     MOVE 77 TO WS-R-X(2)
     MOVE 22 TO WS-R-Y(2)
     MOVE 10 TO WS-R-EFFECT(3)
     MOVE 1 TO WS-R-TIER(3)
     MOVE 0 TO WS-R-SECONDARY(3)
     MOVE 53 TO WS-R-X(3)
     MOVE 47 TO WS-R-Y(3)
     MOVE 7 TO WS-R-EFFECT(4)
     MOVE 1 TO WS-R-TIER(4)
     MOVE 0 TO WS-R-SECONDARY(4)
     MOVE 77 TO WS-R-X(4)
     MOVE 47 TO WS-R-Y(4)
     MOVE 4 TO WS-R-EFFECT(5)
     MOVE 2 TO WS-R-TIER(5)
     MOVE 0 TO WS-R-SECONDARY(5)
     MOVE 65 TO WS-R-X(5)
     MOVE 72 TO WS-R-Y(5)
     MOVE 9 TO WS-R-EFFECT(6)
     MOVE 3 TO WS-R-TIER(6)
     MOVE 1 TO WS-R-SECONDARY(6)
     MOVE 144 TO WS-R-X(6)
     MOVE 47 TO WS-R-Y(6)
     COMPUTE WS-MX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-MY = IN-CURSOR-Y / CL-GUI-SCALE
*>   The two headings.
     MOVE 14737632 TO WS-COLOUR
     MOVE "block.minecraft.beacon.primary" TO WS-KEY
     MOVE 30 TO WS-KEY-LENGTH
     MOVE 62 TO WS-X
     PERFORM HEADING-ADD
     MOVE "block.minecraft.beacon.secondary" TO WS-KEY
     MOVE 32 TO WS-KEY-LENGTH
     MOVE 169 TO WS-X
     PERFORM HEADING-ADD
*>   The power buttons.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-R-EFFECT(WS-I) TO WS-EFFECT
         COMPUTE WS-ACTIVE = FUNCTION MIN(1, FUNCTION MAX(0, WS-LEVELS - WS-R-TIER(WS-I)))
         MOVE 0 TO WS-SELECTED
         IF WS-R-SECONDARY(WS-I) = 0 AND BC-PRIMARY = WS-EFFECT + 1
             MOVE 1 TO WS-SELECTED
         END-IF
         IF WS-R-SECONDARY(WS-I) = 1 AND BC-SECONDARY = WS-EFFECT + 1
             MOVE 1 TO WS-SELECTED
         END-IF
         COMPUTE WS-X = L-LEFT + WS-R-X(WS-I)
         COMPUTE WS-Y = L-TOP + WS-R-Y(WS-I)
         MOVE ACT-BEACON-PRIMARY TO WS-ACTION
         IF WS-R-SECONDARY(WS-I) = 1
             MOVE ACT-BEACON-SECONDARY TO WS-ACTION
         END-IF
         COMPUTE WS-ARG = WS-EFFECT + 1
         PERFORM BUTTON
         MOVE 0 TO WS-UPGRADE
         PERFORM TOOLTIP
     END-PERFORM
*>   The upgrade button, once a primary power is chosen: the secondary of the same effect, active from level 4.
     IF BC-PRIMARY > 0
         COMPUTE WS-EFFECT = BC-PRIMARY - 1
         COMPUTE WS-ACTIVE = FUNCTION MIN(1, FUNCTION MAX(0, WS-LEVELS - 3))
         MOVE 0 TO WS-SELECTED
         IF BC-SECONDARY = BC-PRIMARY
             MOVE 1 TO WS-SELECTED
         END-IF
         COMPUTE WS-X = L-LEFT + 168
         COMPUTE WS-Y = L-TOP + 47
         MOVE ACT-BEACON-SECONDARY TO WS-ACTION
         MOVE 0 TO WS-ARG
         PERFORM BUTTON
         MOVE 1 TO WS-UPGRADE
         PERFORM TOOLTIP
     END-IF
*>   Confirm (active with a payment and a primary) and cancel.
     MOVE 0 TO WS-ACTIVE
     IF BX-COUNT(1) > 0 AND BC-PRIMARY > 0
         MOVE 1 TO WS-ACTIVE
     END-IF
     MOVE 0 TO WS-SELECTED
     COMPUTE WS-X = L-LEFT + 164
     COMPUTE WS-Y = L-TOP + 107
     MOVE ACT-BEACON-CONFIRM TO WS-ACTION
     MOVE 0 TO WS-ARG
     PERFORM BUTTON-BOX
     MOVE "gui.done" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     PERFORM TOOLTIP-KEY
     MOVE 1 TO WS-ACTIVE
     COMPUTE WS-X = L-LEFT + 190
     MOVE ACT-CLOSE-MENU TO WS-ACTION
     PERFORM BUTTON-BOX
     MOVE "gui.cancel" TO WS-KEY
     MOVE 10 TO WS-KEY-LENGTH
     PERFORM TOOLTIP-KEY
*>   The icons of confirm and cancel (18 x 18 at (+2, +2); the sprites are not in the built-in pack: a swatch each).
     MOVE 18 TO WS-W WS-H
     COMPUTE WS-Y = L-TOP + 109
     MOVE ACT-NONE TO WS-ACTION
     MOVE WK-OVERLAY TO WS-KIND
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH WS-STATE
     COMPUTE WS-X = L-LEFT + 166
     MOVE SW-SELECTED TO WS-SWATCH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     COMPUTE WS-X = L-LEFT + 192
     MOVE SW-HURT TO WS-SWATCH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
*>   The payment strip: netherite ingot, emerald, diamond, gold ingot and iron ingot at y + 109 and x + 20, 41, 63, 86, 108, as bare items (display stacks 1 to 5).
     MOVE "netherite_ingot  emerald          diamond          gold_ingot       iron_ingot       " TO WS-PAY-KEYS
     MOVE 20 TO WS-PAY-DX(1)
     MOVE 41 TO WS-PAY-DX(2)
     MOVE 63 TO WS-PAY-DX(3)
     MOVE 86 TO WS-PAY-DX(4)
     MOVE 108 TO WS-PAY-DX(5)
     MOVE WK-SLOT TO WS-KIND
     MOVE 16 TO WS-W WS-H
     MOVE 3 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-PAY-KEY(WS-I) MC-DISP-ITEM(WS-I)
         MOVE 1 TO MC-DISP-COUNT(WS-I)
         COMPUTE WS-ARG = 800 + WS-I
         COMPUTE WS-X = L-LEFT + WS-PAY-DX(WS-I)
         COMPUTE WS-Y = L-TOP + 109
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM BEACON-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-BY-KEY.
*> USING CLIENT-STATE, item key (PIC X(16), without namespace), item id out (0 when no item has that key): over the items of the open content set, else of the stand-in table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(16).
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-ITEM.
     MOVE 0 TO L-ITEM
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     PERFORM VARYING WS-I FROM WS-COUNT BY -1 UNTIL WS-I < 1
         COMPUTE WS-ID = WS-I - 1
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ID WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-PATH = L-KEY
             COMPUTE L-ITEM = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEM-BY-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LECTERN-DECOR.
*> USING CLIENT-STATE, GUI width: the lectern's book view (4.7): the page indicator "Page <page + 1> of <count>" right-aligned to x backgroundLeft + 148 at y 18 (the page count is not
*> known to the client, which does not decode the book's components: the count is the page number), the back button (23 x 13 at backgroundLeft + 43, 159; visible from page 1) and forward button
*> (+ 116, 159) sending button ids 1 and 2, and at y 196 Done (closes) with Take Book (button 3) at width 98 for a player who can build (survival or creative), else Done alone at width 200.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-LEFT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT256              PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-PAGE                PIC Z(8)9.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-LABEL-W             BINARY-LONG VALUE 120.
 01 WS-BUTTON-H            BINARY-LONG VALUE 20.
 01 WS-SWATCH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW.
     GO TO MAIN-FLOW.

 PAGE-BUTTON.
     MOVE WK-OVERLAY TO WS-KIND
     MOVE ACT-NONE TO WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     MOVE WK-IMAGE TO WS-KIND
     MOVE ACT-MENU-BUTTON TO WS-ACTION
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     .

 TEXT-BUTTON.
     MOVE WK-BUTTON TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-BUTTON-H WS-OUT WS-OUT-LENGTH WS-STATE
     .

 MAIN-FLOW.
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH WS-STATE WS-ACTION WS-ARG
     COMPUTE WS-LEFT = (L-GW - 192) / 2
*>   The indicator.
     MOVE 2 TO LA-COUNT
     COMPUTE WS-PAGE = BM-DATA(1) + 1
     MOVE FUNCTION TRIM(WS-PAGE) TO LA-TEXT(1)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAGE)) TO LA-LENGTH(1)
     MOVE LA-TEXT(1) TO LA-TEXT(2)
     MOVE LA-LENGTH(1) TO LA-LENGTH(2)
     MOVE "book.pageIndicator" TO WS-KEY
     MOVE 18 TO WS-KEY-LENGTH
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-OUT WS-OUT-LENGTH
     MOVE WS-OUT(1:256) TO WS-OUT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-OUT256 WS-OUT-LENGTH WS-WIDTH
     COMPUTE WS-X = WS-LEFT + 148 - WS-WIDTH
     MOVE 18 TO WS-Y
     MOVE WK-LABEL TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-OUT WS-OUT-LENGTH WS-STATE
*>   The page buttons.
     MOVE 23 TO WS-W
     MOVE 13 TO WS-H
     MOVE 159 TO WS-Y
     MOVE SW-BUTTON TO WS-SWATCH
     IF BM-DATA(1) > 0
         COMPUTE WS-X = WS-LEFT + 43
         MOVE 1 TO WS-ARG
         PERFORM PAGE-BUTTON
     END-IF
     COMPUTE WS-X = WS-LEFT + 116
     MOVE 2 TO WS-ARG
     PERFORM PAGE-BUTTON
*>   Done and Take Book.
     MOVE 196 TO WS-Y
     MOVE 20 TO WS-H
     MOVE "gui.done" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     IF PL-MODE = 0 OR PL-MODE = 1
         MOVE 98 TO WS-W
         COMPUTE WS-X = L-GW / 2 - 98 - 2
         MOVE 0 TO WS-ARG
         MOVE ACT-CLOSE-MENU TO WS-ACTION
         PERFORM TEXT-BUTTON
         COMPUTE WS-X = L-GW / 2 + 2
         MOVE 3 TO WS-ARG
         MOVE ACT-MENU-BUTTON TO WS-ACTION
         MOVE "lectern.take_book" TO WS-KEY
         MOVE 17 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         PERFORM TEXT-BUTTON
     ELSE
         MOVE 200 TO WS-W
         COMPUTE WS-X = (L-GW - 200) / 2
         MOVE 0 TO WS-ARG
         MOVE ACT-CLOSE-MENU TO WS-ACTION
         PERFORM TEXT-BUTTON
     END-IF
     GOBACK.
 END PROGRAM LECTERN-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-SET-BEACON.
*> USING PB-BUFFER, primary, secondary (effect id + 1, 0 none): Set Beacon (05c 0x35): two optional mob-effect registry ids (a present flag, then the plain id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 53.
 01 WS-HAS                 BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PRIMARY              BINARY-LONG.
 01 L-SECONDARY            BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-PRIMARY L-SECONDARY.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE FUNCTION MIN(1, L-PRIMARY) TO WS-HAS
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-HAS
     IF WS-HAS = 1
         COMPUTE WS-EFFECT = L-PRIMARY - 1
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-EFFECT
     END-IF
     MOVE FUNCTION MIN(1, L-SECONDARY) TO WS-HAS
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-HAS
     IF WS-HAS = 1
         COMPUTE WS-EFFECT = L-SECONDARY - 1
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-EFFECT
     END-IF
     GOBACK.
 END PROGRAM CLP-SET-BEACON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-SELECT-TRADE.
*> USING PB-BUFFER, offer index: Select Trade (05c 0x34).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 52.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-INDEX.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-INDEX
     GOBACK.
 END PROGRAM CLP-SELECT-TRADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-ACTION.
*> USING CLIENT-STATE, action, argument: a beacon, lectern or merchant button. A primary power already selected does nothing; else primary := its effect and the secondary is cleared unless it
*> is the same effect; the secondary (argument 0 = the upgrade button, the current primary) is set when not already selected; confirm sends Set Beacon (the powers) and closes; close (cancel,
*> done) returns to the world, which sends Container Close; a trade row sets the selected offer to row + scroll and sends Select Trade.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     EVALUATE L-ACTION
         WHEN ACT-BEACON-PRIMARY
             IF BC-PRIMARY NOT = L-ARG
                 MOVE L-ARG TO BC-PRIMARY
                 IF BC-SECONDARY NOT = L-ARG
                     MOVE 0 TO BC-SECONDARY
                 END-IF
             END-IF
         WHEN ACT-BEACON-SECONDARY
             MOVE L-ARG TO WS-EFFECT
             IF WS-EFFECT = 0
                 MOVE BC-PRIMARY TO WS-EFFECT
             END-IF
             MOVE WS-EFFECT TO BC-SECONDARY
         WHEN ACT-BEACON-CONFIRM
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CLP-SET-BEACON" USING PB-BUFFER BC-PRIMARY BC-SECONDARY
             CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
             MOVE SCR-WORLD TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         WHEN ACT-CLOSE-MENU
             MOVE SCR-WORLD TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         WHEN ACT-TRADE-SELECT
             COMPUTE WS-INDEX = L-ARG + MC-SCROLL
             MOVE WS-INDEX TO MC-SELECTED
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CLP-SELECT-TRADE" USING PB-BUFFER WS-INDEX
             CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-EXTRA-INPUT.
*> USING CLIENT-STATE: the merchant's scroller (2.10), with more than 7 offers: the wheel moves the offset by the wheel amount (truncated, down is positive: offset - wheel) within 0 to
*> count - 7; a press on the thumb column (x 94 to 100, y 18 to 158 from the panel) starts a drag, the drag sets offset = int((mouse y - top - 13.5) / (139 - 27) x (count - 7) + 0.5)
*> clamped, a release ends it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-MAXOFF              BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BM-TYPE = 8
         CALL "ANVIL-INPUT" USING CLIENT-STATE
     END-IF
*>   4.7 the lectern's keys: Page Up (GLFW 266) presses the back button (visible from page 1), Page Down (267) the forward button.
     IF BM-TYPE = 17
         IF IN-KEY-PRESSED(CL-KEY-PAGE-UP + 1) = 1 AND BM-DATA(1) > 0
             MOVE ACT-MENU-BUTTON TO WS-ACTION
             MOVE 1 TO WS-ARG
             CALL "SCREEN-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
         END-IF
         IF IN-KEY-PRESSED(CL-KEY-PAGE-DOWN + 1) = 1
             MOVE ACT-MENU-BUTTON TO WS-ACTION
             MOVE 2 TO WS-ARG
             CALL "SCREEN-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
         END-IF
     END-IF
     IF BM-TYPE = 19 AND MC-COUNT > 7
         COMPUTE WS-GW = FUNCTION MAX(IN-WIN-W / CL-GUI-SCALE, CL-MIN-GUI-W)
         COMPUTE WS-GH = FUNCTION MAX(IN-WIN-H / CL-GUI-SCALE, CL-MIN-GUI-H)
         COMPUTE WS-LEFT = (WS-GW - 276) / 2
         COMPUTE WS-TOP = (WS-GH - 166) / 2
         COMPUTE WS-MAXOFF = MC-COUNT - 7
         COMPUTE WS-MX = IN-CURSOR-X / CL-GUI-SCALE
         COMPUTE WS-MY = IN-CURSOR-Y / CL-GUI-SCALE
         IF IN-SCROLL-Y NOT = 0
             COMPUTE WS-STEP = FUNCTION INTEGER-PART(MC-SCROLL - IN-SCROLL-Y)
             COMPUTE MC-SCROLL = FUNCTION MAX(0, FUNCTION MIN(WS-STEP, WS-MAXOFF))
         END-IF
         IF IN-BUTTON-PRESSED(1) = 1 AND WS-MX > WS-LEFT + 94 AND WS-MX < WS-LEFT + 100
                 AND WS-MY > WS-TOP + 18 AND WS-MY <= WS-TOP + 158
             MOVE 1 TO MC-DRAGGING
         END-IF
         IF MC-DRAGGING = 1
             COMPUTE WS-F = (WS-MY - (WS-TOP + 18) - 13.5) / (139 - 27.0) * WS-MAXOFF + 0.5
             COMPUTE WS-STEP = FUNCTION INTEGER-PART(WS-F)
             COMPUTE MC-SCROLL = FUNCTION MAX(0, FUNCTION MIN(WS-STEP, WS-MAXOFF))
         END-IF
         IF IN-BUTTON-RELEASED(1) = 1
             MOVE 0 TO MC-DRAGGING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MENU-EXTRA-INPUT.
