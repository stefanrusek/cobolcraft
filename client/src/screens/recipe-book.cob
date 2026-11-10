*> The recipe book panel of the inventory screen and the crafting bench (13 sections 3.8, 3.9; builtin-ui-art 4.13.4): its place beside the
*> screen (RECIPE-BOOK-GEOMETRY), the craftable marks and collections (RECIPE-BOOK-REFRESH), the panel's widgets (RECIPE-BOOK-BUILD), the
*> clicks (RECIPE-BOOK-ACTION), the search box (RECIPE-BOOK-INPUT) and the toast of a new recipe (RECIPE-TOAST-BUILD). The entries come from
*> Recipe Book Add (protocol-play.cob). Tabs: 1 Search (all four crafting categories), 2 Equipment (category 2), 3 Building Blocks (0), 4 Misc
*> (3), 5 Redstone (1); a tab shows only while it has a recipe that fits the screen's grid.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-GEOMETRY.
*> USING CLIENT-STATE, GUI width, GUI height, left (the screen's), top, panel x out: with the book open and the GUI at least 379 wide the
*> screen moves right to 177 + (width - 176 - 200) div 2 and the panel stands 86 left of the centred position; otherwise the screen is
*> centred and the panel (147 wide) overlays it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH L-LEFT L-TOP L-PX.
     COMPUTE L-TOP = (L-GH - 166) / 2
     COMPUTE L-LEFT = (L-GW - 176) / 2
     COMPUTE L-PX = (L-GW - 147) / 2
     IF RK-OPEN(1) = 1 AND L-GW >= 379
         COMPUTE L-LEFT = 177 + (L-GW - 176 - 200) / 2
         COMPUTE L-PX = L-PX - 86
     END-IF
     GOBACK.
 END PROGRAM RECIPE-BOOK-GEOMETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-TAB-OF.
*> USING category, tab out: the tab of a crafting category (0 building 3, 1 redstone 5, 2 equipment 2, 3 misc 4); 0 for another book.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-CATEGORY             BINARY-LONG.
 01 L-TAB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CATEGORY L-TAB.
     EVALUATE L-CATEGORY
         WHEN 0
             MOVE 3 TO L-TAB
         WHEN 1
             MOVE 5 TO L-TAB
         WHEN 2
             MOVE 2 TO L-TAB
         WHEN 3
             MOVE 4 TO L-TAB
         WHEN OTHER
             MOVE 0 TO L-TAB
     END-EVALUATE
     GOBACK.
 END PROGRAM RK-TAB-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-FITS.
*> USING CLIENT-STATE, row, grid (2 or 3), fits out (0 or 1): a crafting entry is listed in a grid when a shaped recipe is no wider or
*> higher than it, or a shapeless one has no more ingredients than it has slots (13 section 3.9, canDisplay).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-GRID                 BINARY-LONG.
 01 L-FITS                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-GRID L-FITS.
     MOVE 0 TO L-FITS
     IF RK-CATEGORY(L-ROW) <= 3
         IF RK-TYPE(L-ROW) = 0 AND RK-SLOTS(L-ROW) <= L-GRID * L-GRID
             MOVE 1 TO L-FITS
         END-IF
         IF RK-TYPE(L-ROW) = 1 AND RK-WIDTH(L-ROW) <= L-GRID AND RK-HEIGHT(L-ROW) <= L-GRID
             MOVE 1 TO L-FITS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RK-FITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-ITEM-NAME.
*> USING CLIENT-STATE, item, text out (PIC X(512)), length out: the item's name from the language (08 section 10.8.1: an item that places a
*> block by its block key, any other by its item key); an item outside the table is named as item 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-TEXT L-LENGTH.
     MOVE L-ITEM TO WS-ITEM
     IF WS-ITEM < 0 OR WS-ITEM >= CL-ITEM-COUNT
         MOVE 0 TO WS-ITEM
     END-IF
     MOVE SPACES TO WS-KEY
     IF CL-IT-STATE(WS-ITEM + 1) > 0
         STRING "block.cobolcraft." FUNCTION TRIM(CL-IT-KEY(WS-ITEM + 1)) DELIMITED BY SIZE INTO WS-KEY
     ELSE
         STRING "item.cobolcraft." FUNCTION TRIM(CL-IT-KEY(WS-ITEM + 1)) DELIMITED BY SIZE INTO WS-KEY
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM RK-ITEM-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-VISIBLE.
*> USING CLIENT-STATE, row, visible out: the entry heads a collection that the panel lists now: it fits the grid in some member, belongs
*> to the selected tab, matches the search text (when there is one) and, with the filter on, has a craftable member.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-VISIBLE.
     MOVE 0 TO L-VISIBLE
     CALL "RK-TAB-OF" USING RK-CATEGORY(L-ROW) WS-TAB
     IF RK-HEAD(L-ROW) = L-ROW AND RK-NDISP(L-ROW) > 0 AND (RK-TAB = 1 OR WS-TAB = RK-TAB)
             AND (RK-SEARCH-LENGTH = 0 OR RK-NMATCH(L-ROW) > 0)
             AND (RK-FILTERING(1) = 0 OR RK-NCAN(L-ROW) > 0)
         MOVE 1 TO L-VISIBLE
     END-IF
     GOBACK.
 END PROGRAM RK-VISIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-REFRESH.
*> USING CLIENT-STATE, grid (2 or 3): what the panel shows for this frame. The craftable marks (a requirement is one item; the stock is the
*> main inventory, the hotbar and the grid slots, each requirement taking its own unit) are recomputed when the inventory or the grid
*> changed or the book did; the search matches (the lower-cased text a substring of the lower-cased result name) when the text or the
*> book did. Then the members of each collection that fit, are craftable or match are counted, the tabs that have recipes marked, and
*> the cells of the selected page filled (RK-CELL: a collection with several recipes cycles its recipe every 30 ticks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-FITS                BINARY-LONG.
 01 WS-TAB                 BINARY-LONG.
 01 WS-VISIBLE             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-STOCK-N             BINARY-LONG.
 01 WS-STOCK.
    05 WS-ST OCCURS 64 TIMES.
       10 WS-ST-ITEM       BINARY-LONG.
       10 WS-ST-COUNT      BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-NEED                BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-HAY                 PIC X(512).
 01 WS-NEEDLE              PIC X(50).
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GRID                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GRID.
*>   The stock: the 36 slots and the grid slots (arguments 0 to 35 and 106 up), their items summed.
     MOVE 0 TO WS-STOCK-N WS-SIG
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 35 + L-GRID * L-GRID
         MOVE WS-K TO WS-ARG
         IF WS-K > 35
             COMPUTE WS-ARG = 70 + WS-K
         END-IF
         CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
         COMPUTE WS-SIG = FUNCTION MOD(WS-SIG * 31 + WS-ITEM * 7 + WS-COUNT + 1, 1000000007)
         IF WS-COUNT > 0
             MOVE 0 TO WS-J
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STOCK-N
                 IF WS-ST-ITEM(WS-I) = WS-ITEM
                     MOVE WS-I TO WS-J
                 END-IF
             END-PERFORM
             IF WS-J = 0 AND WS-STOCK-N < 64
                 ADD 1 TO WS-STOCK-N
                 MOVE WS-STOCK-N TO WS-J
                 MOVE WS-ITEM TO WS-ST-ITEM(WS-J)
                 MOVE 0 TO WS-ST-COUNT(WS-J)
             END-IF
             IF WS-J > 0
                 ADD WS-COUNT TO WS-ST-COUNT(WS-J)
             END-IF
         END-IF
     END-PERFORM
     IF WS-SIG NOT = RK-SIG OR L-GRID NOT = RK-GRID OR RK-DIRTY = 1
         MOVE WS-SIG TO RK-SIG
         MOVE L-GRID TO RK-GRID
         MOVE 0 TO RK-DIRTY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
             MOVE RK-REQ-PRESENT(WS-I) TO WS-OK
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RK-REQ-COUNT(WS-I)
                 MOVE 0 TO WS-NEED WS-HAVE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-J
                     IF RK-REQ-ITEM(WS-I, WS-K) = RK-REQ-ITEM(WS-I, WS-J)
                         ADD 1 TO WS-NEED
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-STOCK-N
                     IF WS-ST-ITEM(WS-K) = RK-REQ-ITEM(WS-I, WS-J)
                         MOVE WS-ST-COUNT(WS-K) TO WS-HAVE
                     END-IF
                 END-PERFORM
                 IF WS-HAVE < WS-NEED
                     MOVE 0 TO WS-OK
                 END-IF
             END-PERFORM
             MOVE WS-OK TO RK-CAN(WS-I)
         END-PERFORM
     END-IF
*>   The search matches.
     IF RK-SDIRTY = 1
         MOVE 0 TO RK-SDIRTY
         MOVE FUNCTION LOWER-CASE(RK-SEARCH) TO WS-NEEDLE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
             MOVE 0 TO RK-MATCH(WS-I)
             IF RK-SEARCH-LENGTH > 0
                 CALL "RK-ITEM-NAME" USING CLIENT-STATE RK-RES-ITEM(WS-I) WS-NAME WS-NAME-LENGTH
                 MOVE FUNCTION LOWER-CASE(WS-NAME) TO WS-HAY
                 MOVE 0 TO WS-HITS
                 INSPECT WS-HAY TALLYING WS-HITS FOR ALL WS-NEEDLE(1:RK-SEARCH-LENGTH)
                 IF WS-HITS > 0
                     MOVE 1 TO RK-MATCH(WS-I)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
*>   The collections' counts and the tabs.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO RK-TABHAS(WS-I)
     END-PERFORM
     MOVE 1 TO RK-TABHAS(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
         MOVE 0 TO RK-NDISP(WS-I) RK-NCAN(WS-I) RK-NMATCH(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
         CALL "RK-FITS" USING CLIENT-STATE WS-I L-GRID WS-FITS
         IF WS-FITS = 1
             MOVE RK-HEAD(WS-I) TO WS-J
             ADD 1 TO RK-NDISP(WS-J)
             ADD RK-CAN(WS-I) TO RK-NCAN(WS-J)
             ADD RK-MATCH(WS-I) TO RK-NMATCH(WS-J)
             CALL "RK-TAB-OF" USING RK-CATEGORY(WS-I) WS-TAB
             MOVE 1 TO RK-TABHAS(WS-TAB)
         END-IF
     END-PERFORM
     IF RK-TAB < 1 OR RK-TAB > 5
         MOVE 1 TO RK-TAB
     END-IF
     IF RK-TABHAS(RK-TAB) = 0
         MOVE 1 TO RK-TAB
     END-IF
*>   The pages: 20 collections a page.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
         CALL "RK-VISIBLE" USING CLIENT-STATE WS-I WS-VISIBLE
         ADD WS-VISIBLE TO WS-TOTAL
     END-PERFORM
     COMPUTE RK-PAGES = FUNCTION MAX(1, (WS-TOTAL + 19) / 20)
     COMPUTE RK-PAGE = FUNCTION MAX(1, FUNCTION MIN(RK-PAGE, RK-PAGES))
     COMPUTE WS-FIRST = (RK-PAGE - 1) * 20
     MOVE 0 TO RK-CELL-COUNT WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT OR RK-CELL-COUNT = 20
         CALL "RK-VISIBLE" USING CLIENT-STATE WS-I WS-VISIBLE
         IF WS-VISIBLE = 1
             ADD 1 TO WS-TOTAL
             IF WS-TOTAL > WS-FIRST
                 ADD 1 TO RK-CELL-COUNT
                 MOVE WS-I TO RK-CELL-ROW(RK-CELL-COUNT)
                 MOVE RK-NDISP(WS-I) TO RK-CELL-MANY(RK-CELL-COUNT)
*>               The recipe shown: the member picked by the clock among those that fit.
                 COMPUTE WS-CELL = CL-NOW-MS / (CL-TICK-MS * 30)
                 COMPUTE WS-PICK = FUNCTION MOD(WS-CELL, RK-NDISP(WS-I))
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RK-COUNT
                     CALL "RK-FITS" USING CLIENT-STATE WS-J L-GRID WS-FITS
                     IF WS-FITS = 1 AND RK-HEAD(WS-J) = WS-I
                         IF WS-PICK = 0
                             MOVE WS-J TO RK-CELL-ROW(RK-CELL-COUNT)
                         END-IF
                         SUBTRACT 1 FROM WS-PICK
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-BOOK-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-IMAGE-ADD.
*> USING CLIENT-STATE, action, argument, x, y, width, height, sprite row: a clickable GUI sprite (WK-IMAGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-IMAGE.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG L-X L-Y L-W L-H L-SPRITE.
     MOVE SPACES TO WS-TEXT
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND L-ACTION L-ARG L-X L-Y L-W L-H WS-TEXT WS-LENGTH WS-STATE
     MOVE L-SPRITE TO SM-W-SPRITE(SM-WIDGET-COUNT)
     GOBACK.
 END PROGRAM RK-IMAGE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RK-LABEL-ADD.
*> USING CLIENT-STATE, lang key (PIC X(80)), key length, x, y, first only (1 = only the first character of the text): a label.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 0.
 01 WS-H                   BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH L-X L-Y L-FIRST.
     CALL "LANG-GET" USING CLIENT-STATE L-KEY L-KEY-LENGTH WS-TEXT WS-LENGTH
     IF L-FIRST = 1
         MOVE 1 TO WS-LENGTH
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NONE WS-ZERO L-X L-Y WS-W WS-H WS-TEXT WS-LENGTH WS-STATE
     GOBACK.
 END PROGRAM RK-LABEL-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-BUILD.
*> USING CLIENT-STATE, GUI height, screen left, screen top, panel x, kind (0 inventory, 12 bench): the book button (20 x 18 at (left +
*> 104, height / 2 - 22) in the inventory, (left + 5, height / 2 - 49) in the bench) and, while the book is open, the panel (147 x 166
*> from the sheet's origin (1, 1) when a pack above the built-in one supplies it, else (0, 0)), the tabs (35 x 27 at panel x - 30, top
*> + 3 + 27 n, the selected one 2 left, its first letter in it), the filter (26 x 16 at (110, 12)), the search box (81 x 14 at (25, 13)),
*> the cells (25 x 25 from (11, 31), 5 to a row: the slot sprite behind the item slot), the page arrows (12 x 17 at (38, 137) and (93,
*> 137)) and the page label (centred on 73, y 141), then the ghost items (arguments 301 up) in the empty grid slots.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-GRID                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-SHEET-KIND          BINARY-LONG VALUE WK-SHEET.
 01 WS-SHEET-ROW           BINARY-LONG VALUE GSP-SHEET-BOOK.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-PATH                PIC X(256) VALUE "assets/minecraft/textures/gui/recipe_book.png".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 46.
 01 WS-PACK                BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-TABS.
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.recipe_book.tab.search".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.recipe_book.tab.equipment".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.recipe_book.tab.building".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.recipe_book.tab.misc".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.recipe_book.tab.redstone".
 01 WS-TAB-TABLE REDEFINES WS-TABS.
    05 WS-TAB-KEY          PIC X(48) OCCURS 5 TIMES.
 01 WS-TAB-LENGTHS.
    05 FILLER PIC 99 VALUE 40.
    05 FILLER PIC 99 VALUE 43.
    05 FILLER PIC 99 VALUE 42.
    05 FILLER PIC 99 VALUE 38.
    05 FILLER PIC 99 VALUE 42.
 01 WS-TAB-LENGTH-TABLE REDEFINES WS-TAB-LENGTHS.
    05 WS-TAB-LEN          PIC 99 OCCURS 5 TIMES.
 01 WS-HINT-KEY            PIC X(80) VALUE "cobolcraft.screen.common.search_hint".
 01 WS-PAGE-KEY            PIC X(80) VALUE "cobolcraft.screen.recipe_book.page".
 COPY CLARGS.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GH                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GH L-LEFT L-TOP L-PX L-TYPE.
     MOVE 2 TO WS-GRID
     COMPUTE WS-X = L-LEFT + 104
     COMPUTE WS-Y = L-GH / 2 - 22
     IF L-TYPE = 12
         MOVE 3 TO WS-GRID
         COMPUTE WS-X = L-LEFT + 5
         COMPUTE WS-Y = L-GH / 2 - 49
     END-IF
     MOVE ACT-RB-BOOK TO WS-ACTION
     MOVE 0 TO WS-ARG
     MOVE GSP-RB-BUTTON TO WS-SPRITE
     MOVE 20 TO WS-W
     MOVE 18 TO WS-H
     CALL "RK-IMAGE-ADD" USING CLIENT-STATE WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-SPRITE
     IF RK-OPEN(1) = 1
         CALL "RECIPE-BOOK-REFRESH" USING CLIENT-STATE WS-GRID
*>       The panel (it is drawn over the screen: the first widget of the book).
         CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-PACK
         COMPUTE WS-ORIGIN = FUNCTION MIN(1, WS-PACK / 2)
         MOVE 147 TO WS-W
         MOVE 166 TO WS-H
         MOVE SPACES TO WS-TEXT
         MOVE 0 TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-SHEET-KIND WS-NONE WS-SHEET-ROW L-PX L-TOP WS-W WS-H
             WS-TEXT WS-LENGTH WS-ORIGIN
*>       The tabs that have recipes.
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             IF RK-TABHAS(WS-I) = 1
                 COMPUTE WS-X = L-PX - 30
                 COMPUTE WS-Y = L-TOP + 3 + 27 * WS-N
                 MOVE GSP-RB-TAB TO WS-SPRITE
                 IF WS-I = RK-TAB
                     SUBTRACT 2 FROM WS-X
                     MOVE GSP-RB-TAB-SEL TO WS-SPRITE
                 END-IF
                 MOVE ACT-RB-TAB TO WS-ACTION
                 MOVE WS-I TO WS-ARG
                 MOVE 35 TO WS-W
                 MOVE 27 TO WS-H
                 CALL "RK-IMAGE-ADD" USING CLIENT-STATE WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-SPRITE
                 ADD 13 TO WS-X
                 ADD 9 TO WS-Y
                 MOVE WS-TAB-KEY(WS-I) TO WS-KEY
                 MOVE WS-TAB-LEN(WS-I) TO WS-KEY-LENGTH
                 CALL "RK-LABEL-ADD" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-X WS-Y WS-ONE
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
*>       The filter and the search box.
         COMPUTE WS-X = L-PX + 110
         COMPUTE WS-Y = L-TOP + 12
         MOVE GSP-RB-FILTER-OFF TO WS-SPRITE
         IF RK-FILTERING(1) = 1
             MOVE GSP-RB-FILTER-ON TO WS-SPRITE
         END-IF
         MOVE ACT-RB-FILTER TO WS-ACTION
         MOVE 0 TO WS-ARG
         MOVE 26 TO WS-W
         MOVE 16 TO WS-H
         CALL "RK-IMAGE-ADD" USING CLIENT-STATE WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-SPRITE
         COMPUTE WS-X = L-PX + 25
         COMPUTE WS-Y = L-TOP + 13
         MOVE WK-FIELD TO WS-KIND
         MOVE SPACES TO WS-TEXT
         MOVE RK-SEARCH-LENGTH TO WS-LENGTH
         MOVE RK-SEARCH TO WS-TEXT
         IF RK-SEARCH-LENGTH = 0 AND RK-SEARCH-FOCUS = 0
             MOVE 36 TO WS-KEY-LENGTH
             CALL "LANG-GET" USING CLIENT-STATE WS-HINT-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         END-IF
         MOVE RK-SEARCH-FOCUS TO WS-STATE
         MOVE ACT-RB-SEARCH TO WS-ACTION
         MOVE 81 TO WS-W
         MOVE 14 TO WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH
             WS-STATE
*>       The cells: the slot sprite (craftable or not), then the item slot 25 x 25 whose argument is 200 + the cell.
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RK-CELL-COUNT
             COMPUTE WS-I = (WS-K - 1) / 5
             COMPUTE WS-X = L-PX + 11 + 25 * (WS-K - 1 - WS-I * 5)
             COMPUTE WS-Y = L-TOP + 31 + 25 * WS-I
             MOVE WK-SPRITE TO WS-KIND
             MOVE GSP-RB-SLOT-NO TO WS-ARG
             IF RK-NCAN(RK-CELL-ROW(WS-K)) > 0
                 MOVE GSP-RB-SLOT TO WS-ARG
             END-IF
             MOVE 25 TO WS-W WS-H
             MOVE SPACES TO WS-TEXT
             MOVE 0 TO WS-LENGTH WS-STATE
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NONE WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
                 WS-LENGTH WS-STATE
             MOVE WK-SLOT TO WS-KIND
             COMPUTE WS-ARG = 200 + WS-K
             MOVE ACT-RB-CELL TO WS-ACTION
             MOVE 3 TO WS-STATE
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
                 WS-LENGTH WS-STATE
         END-PERFORM
*>       The page arrows and the label.
         MOVE ACT-RB-PAGE TO WS-ACTION
         MOVE 12 TO WS-W
         MOVE 17 TO WS-H
         COMPUTE WS-Y = L-TOP + 137
         IF RK-PAGE > 1
             COMPUTE WS-X = L-PX + 38
             MOVE 1 TO WS-ARG
             MOVE GSP-RB-BACKWARD TO WS-SPRITE
             CALL "RK-IMAGE-ADD" USING CLIENT-STATE WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-SPRITE
         END-IF
         IF RK-PAGE < RK-PAGES
             COMPUTE WS-X = L-PX + 93
             MOVE 2 TO WS-ARG
             MOVE GSP-RB-FORWARD TO WS-SPRITE
             CALL "RK-IMAGE-ADD" USING CLIENT-STATE WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-SPRITE
         END-IF
         IF RK-PAGES > 1
             MOVE 2 TO LA-COUNT
             MOVE RK-PAGE TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO LA-TEXT(1)
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO LA-LENGTH(1)
             MOVE RK-PAGES TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO LA-TEXT(2)
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO LA-LENGTH(2)
             MOVE 34 TO WS-KEY-LENGTH
             CALL "LANG-FORMAT" USING CLIENT-STATE WS-PAGE-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             COMPUTE WS-X = L-PX + 73 - WS-WIDTH / 2
             COMPUTE WS-Y = L-TOP + 141
             MOVE WK-LABEL TO WS-KIND
             MOVE 0 TO WS-W WS-H WS-STATE
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NONE WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
                 WS-LENGTH WS-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RECIPE-BOOK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-GHOST-BUILD.
*> USING CLIENT-STATE, screen left, screen top, kind (0 inventory, 12 bench): the ghost items (arguments 301 up, the grid slot's place) in
*> the empty grid slots while the ghost is of the open container (13 section 3.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-SLOT.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-GRID                BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 18.
 01 WS-H                   BINARY-LONG VALUE 18.
 01 WS-STATE               BINARY-LONG VALUE 3.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP L-TYPE.
     CALL "MENU-CONTAINER" USING CLIENT-STATE WS-CONTAINER WS-STATE-ID
     IF RK-GHOST-W > 0 AND RK-GHOST-CONTAINER = WS-CONTAINER
         MOVE RK-GHOST-W TO WS-GRID
         MOVE SPACES TO WS-TEXT
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-GRID * WS-GRID
             COMPUTE WS-ARG = 106 + WS-I
             CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
             IF WS-COUNT = 0 AND RK-GHOST-ITEM(WS-I + 1) >= 0
                 COMPUTE WS-R = WS-I / WS-GRID
                 COMPUTE WS-C = WS-I - WS-R * WS-GRID
                 IF L-TYPE = 12
                     COMPUTE WS-X = L-LEFT + 30 + 18 * WS-C - 1
                     COMPUTE WS-Y = L-TOP + 17 + 18 * WS-R - 1
                 ELSE
                     COMPUTE WS-X = L-LEFT + 98 + 18 * WS-C - 1
                     COMPUTE WS-Y = L-TOP + 18 + 18 * WS-R - 1
                 END-IF
                 COMPUTE WS-ARG = 301 + WS-I
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NONE WS-ARG WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM RECIPE-GHOST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-ACTION.
*> USING CLIENT-STATE, action (ACT-RB-*), argument: the book button opens or closes the panel and sends Change Settings; a tab selects
*> that tab; the filter toggles craftable only and sends Change Settings; the arrows turn the page; the search box takes the typing;
*> a cell places its recipe: Seen Recipe first for a highlighted one (the highlight goes), then Place Recipe with the open container's
*> id and use max = Shift (13 section 3.9), not again for a recipe that is not craftable and was the last one placed. The ghost goes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-BOOK                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SEND                BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-FILTERING           BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO RK-SEARCH-FOCUS
     MOVE 0 TO WS-SEND
     EVALUATE L-ACTION
         WHEN ACT-RB-BOOK
             COMPUTE RK-OPEN(1) = 1 - RK-OPEN(1)
             MOVE 1 TO WS-SEND
         WHEN ACT-RB-TAB
             MOVE L-ARG TO RK-TAB
             MOVE 1 TO RK-PAGE
         WHEN ACT-RB-FILTER
             COMPUTE RK-FILTERING(1) = 1 - RK-FILTERING(1)
             MOVE 1 TO RK-PAGE WS-SEND
         WHEN ACT-RB-PAGE
             COMPUTE RK-PAGE = RK-PAGE + L-ARG * 2 - 3
         WHEN ACT-RB-SEARCH
             MOVE 1 TO RK-SEARCH-FOCUS
         WHEN ACT-RB-CELL
             COMPUTE WS-ROW = L-ARG - 200
             MOVE RK-CELL-ROW(WS-ROW) TO WS-ROW
             MOVE 0 TO RK-GHOST-W
             MOVE 0 TO WS-CONTAINER
             IF SM-SCREEN = SCR-BENCH
                 MOVE BM-ID TO WS-CONTAINER
             END-IF
             IF RK-HIGHLIGHT(WS-ROW) = 1
                 MOVE 0 TO RK-HIGHLIGHT(WS-ROW)
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "CLP-RECIPE-SEEN" USING PB-BUFFER RK-ID(WS-ROW)
                 CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
             END-IF
             IF RK-CAN(WS-ROW) = 1 OR RK-LAST-PLACED NOT = RK-ID(WS-ROW) + 1
                 COMPUTE WS-MAX = FUNCTION MOD(IN-MODS, 2)
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "CLP-PLACE-RECIPE" USING PB-BUFFER WS-CONTAINER RK-ID(WS-ROW) WS-MAX
                 CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
             END-IF
             COMPUTE RK-LAST-PLACED = RK-ID(WS-ROW) + 1
     END-EVALUATE
     IF WS-SEND = 1
         CALL "PB-RESET" USING PB-BUFFER
         MOVE RK-OPEN(1) TO WS-OPEN
         MOVE RK-FILTERING(1) TO WS-FILTERING
         CALL "CLP-RECIPE-SETTINGS" USING PB-BUFFER WS-BOOK WS-OPEN WS-FILTERING
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
         MOVE 1 TO RK-DIRTY RK-SDIRTY
     END-IF
     GOBACK.
 END PROGRAM RECIPE-BOOK-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-INPUT.
*> USING CLIENT-STATE: with the search box focused, the typed ASCII characters go on its text (50 at most) and Backspace takes the last
*> one off; the page goes back to the first and the matches are made again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-CHANGED
     IF RK-SEARCH-FOCUS = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             MOVE IN-TEXT(WS-I) TO WS-CODE
             IF WS-CODE >= 32 AND WS-CODE < 127 AND RK-SEARCH-LENGTH < 50
                 ADD 1 TO RK-SEARCH-LENGTH
                 MOVE FUNCTION CHAR(WS-CODE + 1) TO RK-SEARCH(RK-SEARCH-LENGTH:1)
                 MOVE 1 TO WS-CHANGED
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND RK-SEARCH-LENGTH > 0
             MOVE SPACE TO RK-SEARCH(RK-SEARCH-LENGTH:1)
             SUBTRACT 1 FROM RK-SEARCH-LENGTH
             MOVE 1 TO WS-CHANGED
         END-IF
         IF WS-CHANGED = 1
             MOVE 1 TO RK-PAGE RK-SDIRTY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RECIPE-BOOK-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TOAST-BUILD.
*> USING CLIENT-STATE, GUI width: while the toast of a Recipe Book Add with the notification flag runs (5 seconds), the toast sprite (160 x
*> 32) at the screen's top right and its title at (30, 7) and description at (30, 18) (builtin-ui-art 4.13.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-SPRITE.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE GSP-TOAST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 160.
 01 WS-H                   BINARY-LONG VALUE 32.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TITLE               PIC X(80) VALUE "recipe.toast.title".
 01 WS-DESCRIPTION         PIC X(80) VALUE "recipe.toast.description".
 01 WS-TITLE-LENGTH        BINARY-LONG VALUE 18.
 01 WS-DESCRIPTION-LENGTH  BINARY-LONG VALUE 24.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW.
     IF CL-NOW-MS < RK-TOAST-UNTIL
         COMPUTE WS-X = L-GW - 160
         MOVE SPACES TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-NONE WS-ARG WS-X WS-ZERO WS-W WS-H WS-TEXT
             WS-LENGTH WS-STATE
         ADD 30 TO WS-X
         MOVE 7 TO WS-Y
         CALL "RK-LABEL-ADD" USING CLIENT-STATE WS-TITLE WS-TITLE-LENGTH WS-X WS-Y WS-ZERO2
         MOVE 18 TO WS-Y
         CALL "RK-LABEL-ADD" USING CLIENT-STATE WS-DESCRIPTION WS-DESCRIPTION-LENGTH WS-X WS-Y WS-ZERO2
     END-IF
     GOBACK.
 END PROGRAM RECIPE-TOAST-BUILD.
