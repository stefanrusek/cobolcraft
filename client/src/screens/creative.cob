*> The creative inventory's engines (docs/protocol/40-menus-7-creative-inventory.md; no screen widgets yet): the 14 tabs of 2.2 (CREATIVE-TAB), their boxes and hit tests (3.1, 3.2),
*> the displayed tabs (2.1), the content lists (CREATIVE-SELECT; the per-tab member lists of 4.6 are not in the documents, so the stand-in content is sorted by a stand-in rule: an
*> item that places a block is a building block, a tool class a tool, a food a food, the rest an ingredient), the scroll maths (5.2, 6.6), the grid click table (7.3), swap,
*> outside drop and delete-all (7.3, 7.5, 7.2), the Set Creative Mode Slot sends with the drop throttler (9.1, 9.3), the name search (8.1, 8.2; no item tags in the stand-in
*> content) and the saved hotbars in memory (10; the file hotbar.nbt is not written).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-TAB.
*> USING tab (1 to 14), key (PIC X(24) out), row (0 top, 1 bottom), column, type (1 category, 2 inventory, 3 hotbar, 4 search), right-aligned, scrollbar, title shown, title key
*> (PIC X(32) out): the tab registry of 2.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(52) VALUE "building_blocks     001011itemGroup.buildingBlocks  ".
    05 FILLER PIC X(52) VALUE "colored_blocks      011011itemGroup.coloredBlocks   ".
    05 FILLER PIC X(52) VALUE "natural_blocks      021011itemGroup.natural         ".
    05 FILLER PIC X(52) VALUE "functional_blocks   031011itemGroup.functional      ".
    05 FILLER PIC X(52) VALUE "redstone_blocks     041011itemGroup.redstone        ".
    05 FILLER PIC X(52) VALUE "hotbar              053111itemGroup.hotbar          ".
    05 FILLER PIC X(52) VALUE "search              064111itemGroup.search          ".
    05 FILLER PIC X(52) VALUE "tools_and_utilities 101011itemGroup.tools           ".
    05 FILLER PIC X(52) VALUE "combat              111011itemGroup.combat          ".
    05 FILLER PIC X(52) VALUE "food_and_drinks     121011itemGroup.foodAndDrink    ".
    05 FILLER PIC X(52) VALUE "ingredients         131011itemGroup.ingredients     ".
    05 FILLER PIC X(52) VALUE "spawn_eggs          141011itemGroup.spawnEggs       ".
    05 FILLER PIC X(52) VALUE "op_blocks           151111itemGroup.op              ".
    05 FILLER PIC X(52) VALUE "inventory           162100itemGroup.inventory       ".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 14 TIMES.
       10 WS-R-KEY         PIC X(20).
       10 WS-R-ROW         PIC 9.
       10 WS-R-COL         PIC 9.
       10 WS-R-TYPE        PIC 9.
       10 WS-R-RIGHT       PIC 9.
       10 WS-R-SCROLL      PIC 9.
       10 WS-R-TITLE-SHOWN PIC 9.
       10 WS-R-TITLE       PIC X(26).
 LINKAGE SECTION.
 01 L-TAB                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-ROW                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 01 L-SHOWTITLE            BINARY-LONG.
 01 L-TITLE                PIC X(32).
 PROCEDURE DIVISION USING L-TAB L-KEY L-ROW L-COL L-TYPE L-RIGHT L-SCROLL L-SHOWTITLE L-TITLE.
     MOVE WS-R-KEY(L-TAB) TO L-KEY
     MOVE WS-R-ROW(L-TAB) TO L-ROW
     MOVE WS-R-COL(L-TAB) TO L-COL
     MOVE WS-R-TYPE(L-TAB) TO L-TYPE
     MOVE WS-R-RIGHT(L-TAB) TO L-RIGHT
     MOVE WS-R-SCROLL(L-TAB) TO L-SCROLL
     MOVE WS-R-TITLE-SHOWN(L-TAB) TO L-SHOWTITLE
     MOVE WS-R-TITLE(L-TAB) TO L-TITLE
     GOBACK.
 END PROGRAM CREATIVE-TAB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-TAB-BOX.
*> USING tab, left, top, drawn x (out), drawn y (out), icon x (out), icon y (out): 3.1: tabX = 27 x column, or 195 - 27 x (7 - column) + 1 when right-aligned; drawn at y top - 28
*> (top row) or top + 132 (bottom row); the 16 x 16 icon cell at (+5, +9) on a top tab and (+5, +7) on a bottom tab.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLL              BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 01 WS-TABX                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAB                  BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TAB L-LEFT L-TOP L-X L-Y L-IX L-IY.
     CALL "CREATIVE-TAB" USING L-TAB WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLL WS-SHOWTITLE WS-TITLE
     IF WS-RIGHT = 1
         COMPUTE WS-TABX = 195 - 27 * (7 - WS-COL) + 1
     ELSE
         COMPUTE WS-TABX = 27 * WS-COL
     END-IF
     COMPUTE L-X = L-LEFT + WS-TABX
     COMPUTE L-IX = L-X + 5
     IF WS-ROW = 0
         COMPUTE L-Y = L-TOP - 28
         COMPUTE L-IY = L-Y + 9
     ELSE
         COMPUTE L-Y = L-TOP + 132
         COMPUTE L-IY = L-Y + 7
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-TAB-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-TAB-HIT.
*> USING tab, x, y (relative to the screen's left and top), hit out (1/0): 3.2 the box tabX to tabX + 26 by tabY to tabY + 32, inclusive, tabY -32 (top row) or 136 (bottom).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLL              BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 01 WS-TABX                BINARY-LONG.
 01 WS-TABY                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAB                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAB L-X L-Y L-HIT.
     CALL "CREATIVE-TAB" USING L-TAB WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLL WS-SHOWTITLE WS-TITLE
     IF WS-RIGHT = 1
         COMPUTE WS-TABX = 195 - 27 * (7 - WS-COL) + 1
     ELSE
         COMPUTE WS-TABX = 27 * WS-COL
     END-IF
     IF WS-ROW = 0
         MOVE -32 TO WS-TABY
     ELSE
         MOVE 136 TO WS-TABY
     END-IF
     MOVE 0 TO L-HIT
     IF L-X >= WS-TABX AND L-X <= WS-TABX + 26 AND L-Y >= WS-TABY AND L-Y <= WS-TABY + 32
         MOVE 1 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-TAB-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-MEMBER.
*> USING tab, item, member out (1/0): the stand-in rule of the category tabs over the item facts of CL-ITEM-INFO (the open content set, else the stand-in table): building blocks the items
*> that place a block, tools the tool classes, food and drinks the foods, ingredients the rest; item 0 is no stack; the other category tabs hold nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-STATE.
    05 FILLER              PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TAB                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TAB L-ITEM L-MEMBER.
     MOVE 0 TO L-MEMBER
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     IF L-ITEM > 0 AND L-ITEM < WS-COUNT
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         EVALUATE L-TAB
             WHEN 1
                 IF WS-BLOCK = 1
                     MOVE 1 TO L-MEMBER
                 END-IF
             WHEN 8
                 IF WS-TOOL NOT = SPACE
                     MOVE 1 TO L-MEMBER
                 END-IF
             WHEN 10
                 IF WS-FOOD > 0
                     MOVE 1 TO L-MEMBER
                 END-IF
             WHEN 11
                 IF WS-BLOCK = 0 AND WS-TOOL = SPACE AND WS-FOOD = 0
                     MOVE 1 TO L-MEMBER
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-TAB-SHOWN.
*> USING CLIENT-STATE, tab, shown out (1/0): 2.1 shouldDisplay: the three special tabs (hotbar, search, inventory) always; a category tab only with at least one stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TAB                  BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TAB L-SHOWN.
     CALL "CL-ITEM-COUNT-NOW" USING WS-ITEMS
     MOVE 0 TO L-SHOWN
     IF L-TAB = 6 OR L-TAB = 7 OR L-TAB = 14
         MOVE 1 TO L-SHOWN
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-ITEMS
         CALL "CREATIVE-MEMBER" USING CLIENT-STATE L-TAB WS-I WS-MEMBER
         IF WS-MEMBER = 1
             MOVE 1 TO L-SHOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREATIVE-TAB-SHOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SEARCH.
*> USING CLIENT-STATE, query (PIC X(64)), length: 8.1: the picker's stacks become the search tab's union list (the members of the tabs 1 to 13 other than the hotbar and the search
*> tab, in tab order) for an empty query; else those whose lower-cased name or key contains the lower-cased query. A query starting with # is a tag search (no tags: nothing). A
*> colon splits the query: the namespace part must be contained in "minecraft" and the path part in the name or key (8.2). The scroll returns to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-TAB                 BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-Q                   PIC X(64).
 01 WS-QLEN                BINARY-LONG.
 01 WS-NS                  PIC X(64).
 01 WS-NSLEN               BINARY-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-PLEN                BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-NAME                PIC X(512).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(512).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-INS                 PIC X(16).
 01 WS-INP                 PIC X(40).
 01 WS-IMAX                BINARY-LONG.
 01 WS-IBLK                BINARY-LONG.
 01 WS-ITOOL               PIC X.
 01 WS-IFOOD               BINARY-LONG.
 01 WS-IKNOWN              BINARY-LONG.
 01 WS-NAMESPACE           PIC X(9) VALUE "minecraft".
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-QUERY                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-QUERY L-LENGTH.
     GO TO MAIN-FLOW.

*> WS-KEEP for the item WS-I: the namespace part is contained in "minecraft" and the path part in the lower-cased name or key.
 FILTER.
     MOVE 1 TO WS-KEEP
     IF WS-NSLEN > 0
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9 - WS-NSLEN + 1
             IF WS-NAMESPACE(WS-J:WS-NSLEN) = WS-NS(1:WS-NSLEN)
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             MOVE 0 TO WS-KEEP
         END-IF
     END-IF
     IF WS-KEEP = 1 AND WS-PLEN > 0
         CALL "RK-ITEM-NAME" USING CLIENT-STATE WS-I WS-NAME WS-NAME-LENGTH
         MOVE FUNCTION LOWER-CASE(WS-NAME(1:WS-NAME-LENGTH)) TO WS-NAME
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-I WS-INS WS-INP WS-IMAX WS-IBLK WS-ITOOL WS-IFOOD WS-IKNOWN
         MOVE FUNCTION LOWER-CASE(WS-INP) TO WS-KEY
         MOVE 40 TO WS-KEY-LENGTH
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NAME-LENGTH - WS-PLEN + 1
             IF WS-NAME(WS-J:WS-PLEN) = WS-PATH(1:WS-PLEN)
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-KEY-LENGTH - WS-PLEN + 1
             IF WS-KEY(WS-J:WS-PLEN) = WS-PATH(1:WS-PLEN)
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             MOVE 0 TO WS-KEEP
         END-IF
     END-IF
     .
 MAIN-FLOW.
     CALL "CL-ITEM-COUNT-NOW" USING WS-ITEMS
     MOVE 0 TO CR-COUNT
     MOVE 0 TO CR-SCROLL
     MOVE SPACES TO WS-Q WS-NS WS-PATH
     MOVE 0 TO WS-QLEN WS-NSLEN WS-PLEN WS-COLON
     IF L-LENGTH > 0
         MOVE FUNCTION LOWER-CASE(L-QUERY(1:L-LENGTH)) TO WS-Q
         MOVE L-LENGTH TO WS-QLEN
     END-IF
     IF WS-QLEN > 0 AND WS-Q(1:1) = "#"
         GOBACK
     END-IF
     IF WS-QLEN > 0
         PERFORM VARYING WS-J FROM WS-QLEN BY -1 UNTIL WS-J < 1
             IF WS-Q(WS-J:1) = ":"
                 MOVE WS-J TO WS-COLON
             END-IF
         END-PERFORM
     END-IF
     IF WS-COLON > 0
         COMPUTE WS-NSLEN = WS-COLON - 1
         IF WS-NSLEN > 0
             MOVE WS-Q(1:WS-NSLEN) TO WS-NS
         END-IF
         COMPUTE WS-PLEN = WS-QLEN - WS-COLON
         IF WS-PLEN > 0
             MOVE WS-Q(WS-COLON + 1:WS-PLEN) TO WS-PATH
         END-IF
     ELSE
         MOVE WS-Q TO WS-PATH
         MOVE WS-QLEN TO WS-PLEN
     END-IF
     PERFORM VARYING WS-TAB FROM 1 BY 1 UNTIL WS-TAB > 13
         IF WS-TAB NOT = 6 AND WS-TAB NOT = 7
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-ITEMS
                 CALL "CREATIVE-MEMBER" USING CLIENT-STATE WS-TAB WS-I WS-MEMBER
                 IF WS-MEMBER = 1
                     PERFORM FILTER
                     IF WS-KEEP = 1 AND CR-COUNT < 2048
                         ADD 1 TO CR-COUNT
                         MOVE WS-I TO CR-STACK-ITEM(CR-COUNT)
                         MOVE 1 TO CR-STACK-COUNT(CR-COUNT)
                         MOVE 0 TO CR-STACK-LOCK(CR-COUNT)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.

 END PROGRAM CREATIVE-SEARCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SELECT.
*> USING CLIENT-STATE, tab: 6.5 selectTab: the picker's stacks: the hotbar tab 81 entries (9 per saved hotbar; an empty hotbar h has the locked paper at entry h), a category
*> tab its list, the search tab the union (CREATIVE-SEARCH with no query), the inventory tab none; the scroll returns to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SCROLLB             BINARY-LONG.
 01 WS-SHOWTITLE           BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 01 WS-QUERY               PIC X(64).
 01 WS-QLEN                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TAB                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TAB.
     CALL "CL-ITEM-COUNT-NOW" USING WS-ITEMS
     MOVE L-TAB TO CR-TAB
     MOVE 0 TO CR-COUNT
     MOVE 0 TO CR-SCROLL
     CALL "CREATIVE-TAB" USING L-TAB WS-KEY WS-ROW WS-COL WS-TYPE WS-RIGHT WS-SCROLLB WS-SHOWTITLE WS-TITLE
     EVALUATE WS-TYPE
         WHEN 3
             PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 8
                 MOVE 1 TO WS-EMPTY
                 PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 8
                     IF CR-HB-COUNT(WS-H * 9 + WS-J + 1) > 0
                         MOVE 0 TO WS-EMPTY
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 8
                     ADD 1 TO CR-COUNT
                     MOVE 0 TO CR-STACK-ITEM(CR-COUNT) CR-STACK-COUNT(CR-COUNT) CR-STACK-LOCK(CR-COUNT)
                     IF WS-EMPTY = 1 AND WS-J = WS-H
                         MOVE 1 TO CR-STACK-COUNT(CR-COUNT) CR-STACK-LOCK(CR-COUNT)
                     END-IF
                     IF WS-EMPTY = 0
                         MOVE CR-HB-ITEM(WS-H * 9 + WS-J + 1) TO CR-STACK-ITEM(CR-COUNT)
                         MOVE CR-HB-COUNT(WS-H * 9 + WS-J + 1) TO CR-STACK-COUNT(CR-COUNT)
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN 4
             MOVE SPACES TO WS-QUERY
             CALL "CREATIVE-SEARCH" USING CLIENT-STATE WS-QUERY WS-QLEN
         WHEN 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-ITEMS
                 CALL "CREATIVE-MEMBER" USING CLIENT-STATE L-TAB WS-I WS-MEMBER
                 IF WS-MEMBER = 1 AND CR-COUNT < 2048
                     ADD 1 TO CR-COUNT
                     MOVE WS-I TO CR-STACK-ITEM(CR-COUNT)
                     MOVE 1 TO CR-STACK-COUNT(CR-COUNT)
                     MOVE 0 TO CR-STACK-LOCK(CR-COUNT)
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM CREATIVE-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-ROWS.
*> USING count, rows out: 5.2 calculateRowCount: ceil(count / 9) - 5 (0 or less for a list that fits).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-ROWS.
     COMPUTE L-ROWS = (L-COUNT + 8) / 9 - 5
     GOBACK.
 END PROGRAM CREATIVE-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-FIRST-ROW.
*> USING scroll (FLOAT-SHORT), rows, first row out: 5.2: max(0, (int)(scroll x rows + 0.5)); the product in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRODUCT             FLOAT-SHORT.
 01 WS-SUM                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SCROLL               FLOAT-SHORT.
 01 L-ROWS                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-SCROLL L-ROWS L-FIRST.
     COMPUTE WS-PRODUCT = L-SCROLL * L-ROWS
     COMPUTE WS-SUM = WS-PRODUCT + 0.5
     COMPUTE L-FIRST = FUNCTION MAX(0, FUNCTION INTEGER-PART(WS-SUM))
     GOBACK.
 END PROGRAM CREATIVE-FIRST-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-WHEEL.
*> USING scroll (FLOAT-SHORT, in and out), wheel (FLOAT-SHORT), rows: 5.2 subtractInputFromScroll: clamp(scroll - wheel / rows, 0, 1); unchanged when there are no rows.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCROLL               FLOAT-SHORT.
 01 L-WHEEL                FLOAT-SHORT.
 01 L-ROWS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SCROLL L-WHEEL L-ROWS.
     IF L-ROWS > 0
         COMPUTE L-SCROLL = FUNCTION MAX(0, FUNCTION MIN(1, L-SCROLL - L-WHEEL / L-ROWS))
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-WHEEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-DRAG.
*> USING pointer y, top, scroll (FLOAT-SHORT out): 6.6 the drag: clamp((y - (top + 18) - 7.5) / 97, 0, 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SCROLL               FLOAT-SHORT.
 PROCEDURE DIVISION USING L-Y L-TOP L-SCROLL.
     COMPUTE L-SCROLL = FUNCTION MAX(0, FUNCTION MIN(1, (L-Y - (L-TOP + 18) - 7.5) / 97))
     GOBACK.
 END PROGRAM CREATIVE-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SCROLLER-Y.
*> USING scroll (FLOAT-SHORT), y below the top (out): 6.2: 18 + (int)(95 x scroll).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCROLL               FLOAT-SHORT.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SCROLL L-Y.
     COMPUTE L-Y = 18 + FUNCTION INTEGER-PART(95 * L-SCROLL)
     GOBACK.
 END PROGRAM CREATIVE-SCROLLER-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-GRID-CLICK.
*> USING CLIENT-STATE, grid stack item, count, button (0 left), quick (shift), clone (middle): the table of 7.3 on the carried stack: the same item raises the count by one (shift:
*> to the maximum stack size) on the left button and lowers it on another; an empty grid slot or a different item deletes the carried stack on the left button and lowers it by one
*> otherwise; an empty carried stack takes a copy of the grid stack (shift: at the maximum size); clone takes the maximum size when the carried stack is empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-QUICK                BINARY-LONG.
 01 L-CLONE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-COUNT L-BUTTON L-QUICK L-CLONE.
     MOVE 1 TO WS-MAX
     IF L-COUNT > 0
         CALL "CREATIVE-MAX-STACK" USING CLIENT-STATE L-ITEM WS-MAX
     END-IF
     EVALUATE TRUE
         WHEN L-CLONE = 1
             IF PL-CARRIED-COUNT = 0 AND L-COUNT > 0
                 MOVE L-ITEM TO PL-CARRIED-ITEM
                 MOVE WS-MAX TO PL-CARRIED-COUNT
             END-IF
         WHEN PL-CARRIED-COUNT > 0 AND L-COUNT > 0 AND PL-CARRIED-ITEM = L-ITEM
             IF L-BUTTON = 0
                 IF L-QUICK = 1
                     MOVE WS-MAX TO PL-CARRIED-COUNT
                 ELSE
                     IF PL-CARRIED-COUNT < WS-MAX
                         ADD 1 TO PL-CARRIED-COUNT
                     END-IF
                 END-IF
             ELSE
                 SUBTRACT 1 FROM PL-CARRIED-COUNT
             END-IF
         WHEN L-COUNT = 0 OR PL-CARRIED-COUNT > 0
             IF L-BUTTON = 0
                 MOVE 0 TO PL-CARRIED-COUNT
             ELSE
                 IF PL-CARRIED-COUNT > 0
                     SUBTRACT 1 FROM PL-CARRIED-COUNT
                 END-IF
             END-IF
         WHEN OTHER
             MOVE L-ITEM TO PL-CARRIED-ITEM
             IF L-QUICK = 1
                 MOVE WS-MAX TO PL-CARRIED-COUNT
             ELSE
                 MOVE L-COUNT TO PL-CARRIED-COUNT
             END-IF
     END-EVALUATE
     IF PL-CARRIED-COUNT = 0
         MOVE 0 TO PL-CARRIED-ITEM
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-GRID-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SEND.
*> USING CLIENT-STATE, slot, count, item: Set Creative Mode Slot (05c 0x39), only for a player with infinite materials (creative, PL-MODE 1; 9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-COUNT L-ITEM.
     IF PL-MODE = 1
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER L-SLOT L-COUNT L-ITEM
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-DROP-OK.
*> USING CLIENT-STATE, ok out (1/0): 9.3 the client's throttler, step 20, threshold 1280: a drop is allowed while the counter is below the threshold and then raises it by 20.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-OK.
     MOVE 0 TO L-OK
     IF CR-THROTTLE < 1280
         MOVE 1 TO L-OK
         ADD 20 TO CR-THROTTLE
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-DROP-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-TICK.
*> USING CLIENT-STATE: one client tick of the drop throttler: 1 off the counter while it is above 0.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CR-THROTTLE > 0
         SUBTRACT 1 FROM CR-THROTTLE
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-OUTSIDE.
*> USING CLIENT-STATE, button: 7.5 a click outside the image with a carried stack: the left button drops all of it, the right button one item (Set Creative Mode Slot -1 and the
*> stack, 9.1); nothing when the stack is empty, the throttler is over its threshold or another button was used.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE -1.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BUTTON.
     IF PL-CARRIED-COUNT > 0 AND (L-BUTTON = 0 OR L-BUTTON = 1)
         CALL "CREATIVE-DROP-OK" USING CLIENT-STATE WS-OK
         IF WS-OK = 1
             MOVE 1 TO WS-COUNT
             IF L-BUTTON = 0
                 MOVE PL-CARRIED-COUNT TO WS-COUNT
             END-IF
             CALL "CREATIVE-SEND" USING CLIENT-STATE WS-SLOT WS-COUNT PL-CARRIED-ITEM
             SUBTRACT WS-COUNT FROM PL-CARRIED-COUNT
             IF PL-CARRIED-COUNT = 0
                 MOVE 0 TO PL-CARRIED-ITEM
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-OUTSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-SWAP.
*> USING CLIENT-STATE, grid item, count, hotbar slot (0 to 8): 7.3 SWAP: the player's slot becomes a copy of the grid stack at its maximum size, sent as Set Creative Mode Slot
*> 36 + slot; an empty grid slot changes nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-WIRE                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-COUNT L-SLOT.
     IF L-COUNT > 0
         CALL "CREATIVE-MAX-STACK" USING CLIENT-STATE L-ITEM WS-MAX
         MOVE L-ITEM TO PL-SLOT-ITEM(L-SLOT + 1)
         MOVE WS-MAX TO PL-SLOT-COUNT(L-SLOT + 1)
         MOVE 0 TO PL-SLOT-DAMAGE(L-SLOT + 1)
         COMPUTE WS-WIRE = 36 + L-SLOT
         CALL "CREATIVE-SEND" USING CLIENT-STATE WS-WIRE WS-MAX L-ITEM
     END-IF
     GOBACK.
 END PROGRAM CREATIVE-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-DELETE-ALL.
*> USING CLIENT-STATE: 7.1 rule 8: every slot 0 to 45 of the inventory menu is emptied and an empty Set Creative Mode Slot sent for each (the player's 36 slots are emptied here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-I) PL-SLOT-ITEM(WS-I) PL-SLOT-DAMAGE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 45
         CALL "CREATIVE-SEND" USING CLIENT-STATE WS-I WS-COUNT WS-ITEM
     END-PERFORM
     GOBACK.
 END PROGRAM CREATIVE-DELETE-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-HOTBAR-SAVE.
*> USING CLIENT-STATE, hotbar (0 to 8): 10 Hotbar.storeFrom: the player's nine hotbar stacks are kept as saved hotbar number (in memory; hotbar.nbt is not written).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HOTBAR               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HOTBAR.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 8
         MOVE PL-SLOT-ITEM(WS-J + 1) TO CR-HB-ITEM(L-HOTBAR * 9 + WS-J + 1)
         MOVE PL-SLOT-COUNT(WS-J + 1) TO CR-HB-COUNT(L-HOTBAR * 9 + WS-J + 1)
     END-PERFORM
     GOBACK.
 END PROGRAM CREATIVE-HOTBAR-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-HOTBAR-LOAD.
*> USING CLIENT-STATE, hotbar (0 to 8): 10 handleHotbarLoadOrSave load: the player's slots 0 to 8 take the saved stacks, each sent as Set Creative Mode Slot 36 + j.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HOTBAR               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HOTBAR.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 8
         MOVE CR-HB-ITEM(L-HOTBAR * 9 + WS-J + 1) TO PL-SLOT-ITEM(WS-J + 1)
         MOVE CR-HB-COUNT(L-HOTBAR * 9 + WS-J + 1) TO PL-SLOT-COUNT(WS-J + 1)
         COMPUTE WS-WIRE = 36 + WS-J
         CALL "CREATIVE-SEND" USING CLIENT-STATE WS-WIRE CR-HB-COUNT(L-HOTBAR * 9 + WS-J + 1) CR-HB-ITEM(L-HOTBAR * 9 + WS-J + 1)
     END-PERFORM
     GOBACK.
 END PROGRAM CREATIVE-HOTBAR-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATIVE-MAX-STACK.
*> USING CLIENT-STATE, item, maximum stack size out (at least 1): from the item facts (CL-ITEM-INFO).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-MAX.
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     MOVE FUNCTION MAX(WS-MAX, 1) TO L-MAX
     GOBACK.
 END PROGRAM CREATIVE-MAX-STACK.
