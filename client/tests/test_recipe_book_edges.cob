*> Edge cases of the recipe book (spec 002 edge cases; 13 sections 3.8, 3.9): a book with no known recipes lists none (only the Search tab); a bench-only
*> recipe (3 x 3) is not listed in the 2 x 2 inventory grid (its tab stays hidden) and is listed in the bench with the bench's container id; a Place Ghost
*> Recipe (the server could not fill the grid) shows ghost items in the empty grid slots, changes no slot, and goes when a grid slot is clicked; a recipe
*> that is not craftable is not placed twice in a row; a GUI at least 379 wide moves the screen right and the panel stands beside it; a stack carried and
*> released over the panel is not thrown.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPE-BOOK-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==XB-==.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   PIC Z(8)9.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-PACKET              BINARY-LONG VALUE 75.
 01 WS-GHOST               BINARY-LONG VALUE 64.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-ROWS.
    05 FILLER PIC X(18) VALUE "001100002240102110".
    05 FILLER PIC X(18) VALUE "004101003390107110".
    05 FILLER PIC X(18) VALUE "007003000010304110".
    05 FILLER PIC X(18) VALUE "008003000010362110".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 4 TIMES.
       10 WS-R-ID          PIC 999.
       10 WS-R-TYPE        PIC 9.
       10 WS-R-CAT         PIC 99.
       10 WS-R-GROUP       PIC 99.
       10 WS-R-W           PIC 9.
       10 WS-R-H           PIC 9.
       10 WS-R-SLOTS       PIC 9.
       10 WS-R-ING         PIC 99.
       10 WS-R-RES         PIC 99.
       10 WS-R-RC          PIC 9.
       10 WS-R-REQ         PIC 9.
       10 WS-R-FLAGS       PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-I) PL-SLOT-ITEM(WS-I)
     END-PERFORM
     MOVE 1 TO RK-OPEN(1)
     MOVE "contract/fixtures/wire/play-s2c-4b-recipe-book-add-standard-replace-empty.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM COUNT-WIDGETS
     MOVE "acceptance edge recipe book with no known recipes: the panel, only the Search tab, no cell, no arrow" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1000000 + 1000 + 0
     COMPUTE TL-OBSERVED-N = WS-N * 1000000 + WS-K * 1000 + RK-CELL-COUNT * 100 + WS-G
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A 2 x 2 recipe with 4 x item 1 not in the inventory (not craftable), and a 3 x 3 one.
     MOVE 2 TO WS-COUNT
     MOVE 0 TO WS-REPLACE
     PERFORM FEED-ROWS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM COUNT-WIDGETS
     MOVE "acceptance edge the 3 x 3 recipe is not listed in the inventory: 1 cell, the Search and Building tabs (2)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + 2 * 1000 + 1 * 100
     COMPUTE TL-OBSERVED-N = WS-N * 1000000 + WS-K * 1000 + RK-CELL-COUNT * 100 + WS-G
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An uncraftable recipe is placed once, not twice in a row.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 201 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "acceptance edge an uncraftable recipe clicked twice sends one Place Recipe (the server answers with a ghost)" TO TL-CASE
     MOVE "27000100" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The ghost: container 0, shaped 2x2 of item 1 (the fill failed with a full inventory).
     MOVE 0 TO WS-CONTAINER
     PERFORM FEED-GHOST
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) > 300 AND SM-W-ARG(WS-I) < 310
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance edge Place Ghost Recipe shows 4 ghost items in the empty 2 x 2 grid and changes no slot" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 4 * 1000 + 0
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + IX-COUNT(6) + IX-COUNT(7) + IX-COUNT(8) + IX-COUNT(9)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-SLOT TO WS-ACTION
     MOVE 108 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "acceptance edge clicking a grid slot (the lower left one) clears the ghost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RK-GHOST-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A ghost of another display type (a furnace, type 2) clears it too, and a ghost of a container not open shows nothing.
     MOVE 7 TO WS-CONTAINER
     PERFORM FEED-GHOST
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) > 300 AND SM-W-ARG(WS-I) < 310
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance edge a ghost of container 7 (not open) draws no ghost item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CONTAINER
     MOVE 2 TO WS-G
     PERFORM FEED-GHOST-FURNACE
     MOVE "acceptance edge a ghost of a furnace display clears the ghost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RK-GHOST-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The bench: Open Screen of the crafting menu, container 2: the 3 x 3 recipe is listed and placed with container 2.
     MOVE "contract/fixtures/wire/play-s2c-3c-open-screen-crafting.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM COUNT-WIDGETS
     MOVE "acceptance edge the bench lists both recipes (2 cells) with the Search, Building and Redstone tabs (3)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + 3 * 1000 + 2 * 100
     COMPUTE TL-OBSERVED-N = WS-N * 1000000 + WS-K * 1000 + RK-CELL-COUNT * 100 + WS-G
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 202 TO WS-ARG
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance edge a recipe placed in the bench carries container 2 and the display id 4 (after the close of container 0)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1300 27020400" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A 1 x 1 ghost in the bench grid is centred (grid slot 5).
     MOVE 2 TO WS-CONTAINER
     MOVE 1 TO WS-G
     PERFORM FEED-GHOST
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) > 300 AND SM-W-ARG(WS-I) < 310
             MOVE SM-W-ARG(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance edge a 1 x 1 ghost in the bench grid is centred: grid slot 5 (argument 305)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 305 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY

*>   A wide GUI (1280 x 480 is 640 x 240 GUI pixels): the screen moves to 309 and the panel stands at 160.
     MOVE 1280 TO IN-WIN-W
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-N WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SHEET AND SM-W-ARG(WS-I) = GSP-SHEET-INVENTORY
             MOVE SM-W-X(WS-I) TO WS-N
         END-IF
         IF SM-W-KIND(WS-I) = WK-SHEET AND SM-W-ARG(WS-I) = GSP-SHEET-BOOK
             MOVE SM-W-X(WS-I) TO WS-K
         END-IF
     END-PERFORM
     MOVE "acceptance edge a GUI 640 wide moves the inventory sheet to x 309 and the panel to x 160" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 309 * 1000 + 160
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + WS-K
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A stack carried and released over a cell (outside the screen's sheet, inside the panel) is not thrown.
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 1 TO PL-CARRIED-ITEM
     MOVE ACT-RB-CELL TO WS-ACTION
     MOVE 201 TO WS-ARG
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance edge a stack released over the recipe book panel is kept: only Place Recipe is sent, no throw" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "27000100" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A truncated Recipe Book Add (one entry announced, none sent) changes nothing.
     MOVE RK-COUNT TO WS-N
     CALL "PB-RESET" USING XB-BUFFER
     MOVE 1 TO WS-K
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-K
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-PACKET
     MOVE "acceptance edge a truncated Recipe Book Add changes nothing in the book" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-N TO TL-EXPECTED-N
     MOVE RK-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A ghost of ten ingredients is malformed: no ghost.
     MOVE 0 TO WS-CONTAINER
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     MOVE 10 TO WS-K
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-K
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-GHOST
     MOVE "acceptance edge a Place Ghost Recipe announcing 10 ingredients is malformed: no ghost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RK-GHOST-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A shapeless ghost of two items fills the first two grid slots; the ghost stacks of the menu.
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     MOVE 2 TO WS-K
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-K
     INITIALIZE XB-SLOT-DISPLAY-TABLE
     MOVE 4 TO XB-SDT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE XB-SDX-ITEM TO XB-SDN-TYPE(WS-I)
         MOVE 1 TO XB-SDN-ITEM(WS-I)
         CALL "PB-PUT-SLOT-DISPLAY-NODE" USING XB-BUFFER XB-SLOT-DISPLAY-TABLE WS-I WS-ZERO
     END-PERFORM
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-GHOST
     MOVE 301 TO WS-ARG
     CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT2 WS-ITEM WS-DAMAGE
     MOVE WS-COUNT2 TO WS-N
     MOVE 303 TO WS-ARG
     CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT2 WS-ITEM WS-DAMAGE
     MOVE "acceptance edge a shapeless ghost of 2 items: ghost stack 301 is 1 item, 303 is none (grid 2 x 2)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 100 + 10 + 0
     COMPUTE TL-OBSERVED-N = RK-GHOST-W * 100 + WS-N * 10 + WS-COUNT2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A recipe of the Misc category (a tab of its own); a result item outside the item table is named as item 0 in the search; the stock
*>   adds the same item of two slots; a selected tab that has no recipe goes back to Search.
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE 1 TO PL-SLOT-COUNT(12)
     MOVE 3 TO PL-SLOT-ITEM(12)
     MOVE 1 TO PL-SLOT-COUNT(13)
     MOVE 3 TO PL-SLOT-ITEM(13)
     MOVE 4 TO WS-COUNT
     MOVE 0 TO WS-REPLACE
     PERFORM FEED-ROWS
     MOVE 5 TO RK-TAB
     MOVE "t" TO RK-SEARCH
     MOVE 1 TO RK-SEARCH-LENGTH RK-SDIRTY
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RK-COUNT
         IF RK-ID(WS-I) = 7 AND RK-CAN(WS-I) = 1
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance edge Misc has its tab, the empty Redstone tab falls back to Search, two stacks of item 3 craft recipe 7" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + 1 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-N * 1000 + RK-TAB * 10 + RK-TABHAS(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-N the sheets of the book, WS-K the tab images, WS-G the page arrows.
 COUNT-WIDGETS.
     MOVE 0 TO WS-N WS-K WS-G
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SHEET AND SM-W-ARG(WS-I) = GSP-SHEET-BOOK
             ADD 1 TO WS-N
         END-IF
         IF SM-W-KIND(WS-I) = WK-IMAGE AND SM-W-ACTION(WS-I) = ACT-RB-TAB
             ADD 1 TO WS-K
         END-IF
         IF SM-W-KIND(WS-I) = WK-IMAGE AND SM-W-ACTION(WS-I) = ACT-RB-PAGE
             ADD 1 TO WS-G
         END-IF
     END-PERFORM
     EXIT.

 FEED-ROWS.
     IF WS-READY = 0
         CALL "PB-INIT" USING XB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-COUNT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         MOVE FUNCTION MIN(WS-K, 4) TO WS-I
         PERFORM PUT-ENTRY
     END-PERFORM
     CALL "PB-PUT-BOOL" USING XB-BUFFER WS-REPLACE
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-PACKET
     EXIT.

 FEED-MANY.
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-COUNT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         MOVE 1 TO WS-I
         PERFORM PUT-ENTRY
     END-PERFORM
     CALL "PB-PUT-BOOL" USING XB-BUFFER WS-REPLACE
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-PACKET
     EXIT.

*> One entry of the row WS-I: the display id is the row's id, or 100 + WS-K in FEED-MANY (WS-COUNT 45, the group dropped).
 PUT-ENTRY.
     INITIALIZE XB-RECIPE-ENTRY XB-SLOT-DISPLAY-TABLE
     MOVE WS-R-ID(WS-I) TO XB-RE-DISPLAY-ID
     MOVE WS-R-TYPE(WS-I) TO XB-RE-TYPE
     MOVE WS-R-CAT(WS-I) TO XB-RE-CATEGORY
     MOVE WS-R-GROUP(WS-I) TO XB-RE-GROUP
     MOVE WS-R-W(WS-I) TO XB-RE-WIDTH
     MOVE WS-R-H(WS-I) TO XB-RE-HEIGHT
     MOVE WS-R-SLOTS(WS-I) TO XB-RE-INGREDIENT-COUNT
     IF WS-COUNT = 45
         COMPUTE XB-RE-DISPLAY-ID = 100 + WS-K
         MOVE 0 TO XB-RE-GROUP
         MOVE 0 TO XB-RE-CATEGORY
         MOVE 0 TO XB-RE-TYPE
         MOVE 1 TO XB-RE-INGREDIENT-COUNT
     END-IF
     COMPUTE XB-SDT-COUNT = XB-RE-INGREDIENT-COUNT + 2
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > XB-RE-INGREDIENT-COUNT
         MOVE XB-SDX-ITEM TO XB-SDN-TYPE(WS-N)
         MOVE WS-R-ING(WS-I) TO XB-SDN-ITEM(WS-N)
         MOVE WS-N TO XB-RE-INGREDIENT(WS-N)
         MOVE WS-R-ING(WS-I) TO XB-RE-REQ-ITEM(WS-N)
     END-PERFORM
     COMPUTE XB-RE-RESULT = XB-RE-INGREDIENT-COUNT + 1
     COMPUTE XB-RE-STATION = XB-RE-INGREDIENT-COUNT + 2
     MOVE XB-SDX-ITEM-STACK TO XB-SDN-TYPE(XB-RE-RESULT)
     MOVE WS-R-RES(WS-I) TO XB-SDN-ITEM(XB-RE-RESULT)
     MOVE WS-R-RC(WS-I) TO XB-SDN-COUNT(XB-RE-RESULT)
     MOVE XB-SDX-EMPTY TO XB-SDN-TYPE(XB-RE-STATION)
     MOVE WS-R-REQ(WS-I) TO XB-RE-REQ-PRESENT
     MOVE XB-RE-INGREDIENT-COUNT TO XB-RE-REQ-COUNT
     MOVE WS-R-FLAGS(WS-I) TO XB-RE-FLAGS
     CALL "PB-PUT-RECIPE-ENTRY" USING XB-BUFFER XB-RECIPE-ENTRY XB-SLOT-DISPLAY-TABLE
     EXIT.

*> Place Ghost Recipe of container WS-CONTAINER: shaped WS-G x WS-G (1 x 1 when WS-G is 1, else 2 x 2) of item 1.
 FEED-GHOST.
     IF WS-READY = 0
         CALL "PB-INIT" USING XB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     MOVE 1 TO WS-N
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-N
     MOVE 2 TO WS-N
     IF WS-G = 1
         MOVE 1 TO WS-N
     END-IF
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-N
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-N
     COMPUTE WS-K = WS-N * WS-N
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-K
     INITIALIZE XB-SLOT-DISPLAY-TABLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-K + 2
         MOVE XB-SDX-ITEM TO XB-SDN-TYPE(WS-I)
         MOVE 1 TO XB-SDN-ITEM(WS-I)
     END-PERFORM
     MOVE WS-K TO XB-SDT-COUNT
     ADD 2 TO XB-SDT-COUNT
     MOVE XB-SDX-EMPTY TO XB-SDN-TYPE(XB-SDT-COUNT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > XB-SDT-COUNT
         CALL "PB-PUT-SLOT-DISPLAY-NODE" USING XB-BUFFER XB-SLOT-DISPLAY-TABLE WS-I WS-ZERO
     END-PERFORM
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-GHOST
     EXIT.

*> A furnace display (type 2: ingredient, fuel, result, station, duration, experience are not needed: the type alone clears the ghost).
 FEED-GHOST-FURNACE.
     CALL "PB-RESET" USING XB-BUFFER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-CONTAINER
     CALL "PB-PUT-VARINT" USING XB-BUFFER WS-G
     MOVE 0 TO XB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN XB-BUFFER WS-GHOST
     EXIT.


 END PROGRAM TEST-RECIPE-BOOK-EDGES.

 COPY CLTEST.
