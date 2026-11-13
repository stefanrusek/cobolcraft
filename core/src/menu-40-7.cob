*> Menus, part 7: the creative inventory screen (docs/protocol/40-menus-7-creative-inventory.md sections 1 to 10; US12 phase 44).
*> Programs of plain numbers and texts (MN7- prefix): each takes the facts the caller read (flags, counts, positions, tab numbers) and returns the decision or
*> the pixel arithmetic of the section. The live window of a player (menus.cob) is not changed by this file. Flags are 0 or 1. Tabs are numbered 1 to 14 in the
*> registry order of 2.2; tab types 1 CATEGORY, 2 INVENTORY, 3 HOTBAR, 4 SEARCH; rows 0 top, 1 bottom. Container inputs are the numbers of 40-1 3.4 (0 PICKUP,
*> 1 QUICK_MOVE, 2 SWAP, 3 CLONE, 4 THROW, 5 QUICK_CRAFT, 6 PICKUP_ALL). The per-item member lists of the tabs are not in the document (its 4.6): only the
*> generator structure is here. Scaled results are x 1e6.
*>
*>   MN7-IDENT, -AVAILABLE, -PERMS, -TICK (1); MN7-TAB, -TABNAME, -TABTITLE, -TABBG, -DISPLAY, -TABOK, -TABCHECK, -TABCOUNTS (2)
*>   MN7-TABX, -TABGEO, -SPRITE, -HIT, -HOVER, -CURSOR, -TABPICK, -OUTSIDE (3)
*>   MN7-NEEDS, -REBUILD, -PASS, -ACCEPT, -GENTABLE, -GENLIST, -OPITEM, -TESTMODE, -OPCOUNT, -COLOR, -PAINTCMP, -SPAWNITEM, -SEARCHORDER, -UNION, -REFRESHTABS (4)
*>   MN7-PSLOT, -CPICKUP, -ROWCOUNT, -ROWAT, -SCROLLOF, -SUBTRACT, -SCROLLTO, -DRAGGABLE, -PQUICK (5)
*>   MN7-SEARCHBOX, -DRAWSTEP, -THUMB, -LABEL, -WRAP, -DELETESLOT, -SELECT, -HBLIST, -HBENTRY, -REFRESHCUR, -SCROLLBOX, -DRAG, -PRESS, -WHEEL, -CANSC, -CURSORBAR,
*>   -DELTIP (6); MN7-PRE, -SURV, -CASE, -SWAPCLONE, -THROWCOUNT, -DRAGEND, -HOTTHROW, -OUTCLICK, -KEY, -CHAR (7)
*>   MN7-SREFRESH, -CONTAINS, -SPLIT, -VISTAG, -S-LOWER, -S-LINE, -S-DROP, -S-NAME, -S-TAG, -S-RESULTS, -TIPPLAN, -TIPORDER (8)
*>   MN7-ADD, -DROP, -SERVER, -LISTENER, -THROTTLE, -BURST (9); MN7-HB-IDENT, -HB-FILE, -HB-LOAD, -HB-KEY, -HB-LOADSLOT, -HB-MSG, -HB-ISEMPTY (10)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-IDENT.
*> USING image width out, image height out, texture sheet size out, menu type out (-1: none), container id out, default tab out (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-SHEET                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-SHEET L-TYPE L-ID L-DEFAULT.
    MOVE 195 TO L-W
    MOVE 136 TO L-H
    MOVE 256 TO L-SHEET
    MOVE -1 TO L-TYPE
    MOVE 0 TO L-ID
    MOVE 1 TO L-DEFAULT
    GOBACK.
 END PROGRAM MN7-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-AVAILABLE.
*> USING infinite materials, screen out (1 the creative screen, 2 the survival InventoryScreen) (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INFINITE             BINARY-LONG.
 01 L-SCREEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-INFINITE L-SCREEN.
    MOVE 2 TO L-SCREEN
    IF L-INFINITE = 1
        MOVE 1 TO L-SCREEN
    END-IF
    GOBACK.
 END PROGRAM MN7-AVAILABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PERMS.
*> USING instabuild ability, game master permission, operatorItemsTab option, canUseGameMasterBlocks out, hasPermissions out (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSTABUILD           BINARY-LONG.
 01 L-GM                   BINARY-LONG.
 01 L-OPTION               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INSTABUILD L-GM L-OPTION L-CAN L-HAS.
    MOVE 0 TO L-CAN L-HAS
    IF L-INSTABUILD = 1 AND L-GM = 1
        MOVE 1 TO L-CAN
        MOVE L-OPTION TO L-HAS
    END-IF
    GOBACK.
 END PROGRAM MN7-PERMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TICK.
*> USING a local player exists, infinite materials, refresh the tabs out, replace the screen out (1 containerTick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-REFRESH              BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-INFINITE L-REFRESH L-REPLACE.
    MOVE L-PLAYER TO L-REFRESH
    MOVE 0 TO L-REPLACE
    IF L-PLAYER = 1 AND L-INFINITE = 0
        MOVE 1 TO L-REPLACE
    END-IF
    GOBACK.
 END PROGRAM MN7-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TAB.
*> USING tab 1 to 14, row, column, type, right aligned, background (1 tab_items, 2 tab_inventory, 3 tab_item_search), scrollbar, title shown (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DATA                 PIC X(98) VALUE "00101110110111021011103101110410111053111106413111010111111011112101111310111141011115111111621200".
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 01 L-BG                   BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-ROW L-COL L-TYPE L-RIGHT L-BG L-SCROLL L-SHOW.
    COMPUTE W-POS = (L-N - 1) * 7 + 1
    MOVE W-DATA(W-POS:1) TO L-ROW
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-COL
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-TYPE
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-RIGHT
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-BG
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-SCROLL
    ADD 1 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-SHOW
    GOBACK.
 END PROGRAM MN7-TAB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABNAME.
*> USING tab 1 to 14, resource key out, title key out (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-KEYS.
    05 FILLER              PIC X(30) VALUE "building_blocks".
    05 FILLER              PIC X(30) VALUE "colored_blocks".
    05 FILLER              PIC X(30) VALUE "natural_blocks".
    05 FILLER              PIC X(30) VALUE "functional_blocks".
    05 FILLER              PIC X(30) VALUE "redstone_blocks".
    05 FILLER              PIC X(30) VALUE "hotbar".
    05 FILLER              PIC X(30) VALUE "search".
    05 FILLER              PIC X(30) VALUE "tools_and_utilities".
    05 FILLER              PIC X(30) VALUE "combat".
    05 FILLER              PIC X(30) VALUE "food_and_drinks".
    05 FILLER              PIC X(30) VALUE "ingredients".
    05 FILLER              PIC X(30) VALUE "spawn_eggs".
    05 FILLER              PIC X(30) VALUE "op_blocks".
    05 FILLER              PIC X(30) VALUE "inventory".
 01 W-KEYT REDEFINES W-KEYS.
    05 W-KEY               PIC X(30) OCCURS 14 TIMES.
 01 W-TITLES.
    05 FILLER              PIC X(30) VALUE "itemGroup.buildingBlocks".
    05 FILLER              PIC X(30) VALUE "itemGroup.coloredBlocks".
    05 FILLER              PIC X(30) VALUE "itemGroup.natural".
    05 FILLER              PIC X(30) VALUE "itemGroup.functional".
    05 FILLER              PIC X(30) VALUE "itemGroup.redstone".
    05 FILLER              PIC X(30) VALUE "itemGroup.hotbar".
    05 FILLER              PIC X(30) VALUE "itemGroup.search".
    05 FILLER              PIC X(30) VALUE "itemGroup.tools".
    05 FILLER              PIC X(30) VALUE "itemGroup.combat".
    05 FILLER              PIC X(30) VALUE "itemGroup.foodAndDrink".
    05 FILLER              PIC X(30) VALUE "itemGroup.ingredients".
    05 FILLER              PIC X(30) VALUE "itemGroup.spawnEggs".
    05 FILLER              PIC X(30) VALUE "itemGroup.op".
    05 FILLER              PIC X(30) VALUE "itemGroup.inventory".
 01 W-TITLET REDEFINES W-TITLES.
    05 W-TITLE             PIC X(30) OCCURS 14 TIMES.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-KEY                  PIC X(96).
 01 L-TITLE                PIC X(96).
 PROCEDURE DIVISION USING L-N L-KEY L-TITLE.
    MOVE SPACES TO L-KEY L-TITLE
    MOVE W-KEY(L-N) TO L-KEY
    MOVE W-TITLE(L-N) TO L-TITLE
    GOBACK.
 END PROGRAM MN7-TABNAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABTITLE.
*> USING tab 1 to 14, en_us title out, icon item out (2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NAMES.
    05 FILLER              PIC X(30) VALUE "Building Blocks".
    05 FILLER              PIC X(30) VALUE "Colored Blocks".
    05 FILLER              PIC X(30) VALUE "Natural Blocks".
    05 FILLER              PIC X(30) VALUE "Functional Blocks".
    05 FILLER              PIC X(30) VALUE "Redstone Blocks".
    05 FILLER              PIC X(30) VALUE "Saved Hotbars".
    05 FILLER              PIC X(30) VALUE "Search Items".
    05 FILLER              PIC X(30) VALUE "Tools & Utilities".
    05 FILLER              PIC X(30) VALUE "Combat".
    05 FILLER              PIC X(30) VALUE "Food & Drinks".
    05 FILLER              PIC X(30) VALUE "Ingredients".
    05 FILLER              PIC X(30) VALUE "Spawn Eggs".
    05 FILLER              PIC X(30) VALUE "Operator Utilities".
    05 FILLER              PIC X(30) VALUE "Survival Inventory".
 01 W-NAMET REDEFINES W-NAMES.
    05 W-NAME              PIC X(30) OCCURS 14 TIMES.
 01 W-ICONS.
    05 FILLER              PIC X(30) VALUE "bricks".
    05 FILLER              PIC X(30) VALUE "cyan_wool".
    05 FILLER              PIC X(30) VALUE "grass_block".
    05 FILLER              PIC X(30) VALUE "oak_sign".
    05 FILLER              PIC X(30) VALUE "redstone".
    05 FILLER              PIC X(30) VALUE "bookshelf".
    05 FILLER              PIC X(30) VALUE "compass".
    05 FILLER              PIC X(30) VALUE "diamond_pickaxe".
    05 FILLER              PIC X(30) VALUE "netherite_sword".
    05 FILLER              PIC X(30) VALUE "golden_apple".
    05 FILLER              PIC X(30) VALUE "iron_ingot".
    05 FILLER              PIC X(30) VALUE "creeper_spawn_egg".
    05 FILLER              PIC X(30) VALUE "command_block".
    05 FILLER              PIC X(30) VALUE "chest".
 01 W-ICONT REDEFINES W-ICONS.
    05 W-ICON              PIC X(30) OCCURS 14 TIMES.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-ICON                 PIC X(96).
 PROCEDURE DIVISION USING L-N L-NAME L-ICON.
    MOVE SPACES TO L-NAME L-ICON
    MOVE W-NAME(L-N) TO L-NAME
    MOVE W-ICON(L-N) TO L-ICON
    GOBACK.
 END PROGRAM MN7-TABTITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABBG.
*> USING background (1 tab_items, 2 tab_inventory, 3 tab_item_search), texture location out, sheet size out (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BG                   BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-SIZE                 PIC X(96).
 PROCEDURE DIVISION USING L-BG L-NAME L-SIZE.
    MOVE SPACES TO L-NAME L-SIZE
    MOVE "256x256" TO L-SIZE
    EVALUATE L-BG
        WHEN 1
            MOVE "minecraft:textures/gui/container/creative_inventory/tab_items.png" TO L-NAME
        WHEN 2
            MOVE "minecraft:textures/gui/container/creative_inventory/tab_inventory.png" TO L-NAME
        WHEN OTHER
            MOVE "minecraft:textures/gui/container/creative_inventory/tab_item_search.png" TO L-NAME
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-TABBG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DISPLAY.
*> USING tab type, the tab has items, shouldDisplay out: true unless a CATEGORY tab is empty (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-SHOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-HAS L-SHOW.
    MOVE 1 TO L-SHOW
    IF L-TYPE = 1 AND L-HAS = 0
        MOVE 0 TO L-SHOW
    END-IF
    GOBACK.
 END PROGRAM MN7-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABOK.
*> USING tab type, has a display items generator, allowed out: HOTBAR and INVENTORY tabs refuse one (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-GEN                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-GEN L-OK.
    MOVE 1 TO L-OK
    IF (L-TYPE = 2 OR L-TYPE = 3) AND L-GEN = 1
        MOVE 0 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN7-TABOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABCHECK.
*> USING clashes out: pairs of registered tabs with the same row and column (2.2 self-check).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-RIGHT                BINARY-LONG.
 01 W-BG                   BINARY-LONG.
 01 W-SCROLL               BINARY-LONG.
 01 W-SHOW                 BINARY-LONG.
 01 W-TABS.
    05 W-T                 OCCURS 14 TIMES.
       10 W-ROW            BINARY-LONG.
       10 W-COL            BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASHES              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASHES.
    MOVE 0 TO L-CLASHES
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 14
        CALL "MN7-TAB" USING W-I W-ROW(W-I) W-COL(W-I) W-TYPE W-RIGHT W-BG W-SCROLL W-SHOW
    END-PERFORM
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 13
        PERFORM VARYING W-J FROM W-I BY 1 UNTIL W-J > 13
            IF W-ROW(W-I) = W-ROW(W-J + 1) AND W-COL(W-I) = W-COL(W-J + 1)
                ADD 1 TO L-CLASHES
            END-IF
        END-PERFORM
    END-PERFORM
    GOBACK.
 END PROGRAM MN7-TABCHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABCOUNTS.
*> USING the operator list is not empty, tabs() size out, top row count out, bottom row count out (2.2, 11.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-RIGHT                BINARY-LONG.
 01 W-BG                   BINARY-LONG.
 01 W-SCROLL               BINARY-LONG.
 01 W-SHOW                 BINARY-LONG.
 01 W-HAS                  BINARY-LONG.
 01 W-DISPLAY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-BOTTOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-TOTAL L-TOP L-BOTTOM.
    MOVE 0 TO L-TOTAL L-TOP L-BOTTOM
    PERFORM VARYING W-N FROM 1 BY 1 UNTIL W-N > 14
        CALL "MN7-TAB" USING W-N W-ROW W-COL W-TYPE W-RIGHT W-BG W-SCROLL W-SHOW
        MOVE 1 TO W-HAS
        IF W-N = 13
            MOVE L-OP TO W-HAS
        END-IF
        CALL "MN7-DISPLAY" USING W-TYPE W-HAS W-DISPLAY
        IF W-DISPLAY = 1
            ADD 1 TO L-TOTAL
            IF W-ROW = 0
                ADD 1 TO L-TOP
            ELSE
                ADD 1 TO L-BOTTOM
            END-IF
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN7-TABCOUNTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABX.
*> USING right aligned, column, image width, tabX out (3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RIGHT                BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-RIGHT L-COL L-WIDTH L-X.
    COMPUTE L-X = 27 * L-COL
    IF L-RIGHT = 1
        COMPUTE L-X = L-WIDTH - 27 * (7 - L-COL) + 1
    END-IF
    GOBACK.
 END PROGRAM MN7-TABX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABGEO.
*> USING tab, leftPos, topPos, tabX out, hit test y out, drawn x out, drawn y out, icon x out, icon y out, sprite index out (3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-RIGHT                BINARY-LONG.
 01 W-BG                   BINARY-LONG.
 01 W-SCROLL               BINARY-LONG.
 01 W-SHOW                 BINARY-LONG.
 01 W-WIDTH                BINARY-LONG VALUE 195.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-HITY                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-LEFT L-TOP L-X L-HITY L-DX L-DY L-IX L-IY L-SPRITE.
    CALL "MN7-TAB" USING L-N W-ROW W-COL W-TYPE W-RIGHT W-BG W-SCROLL W-SHOW
    CALL "MN7-TABX" USING W-RIGHT W-COL W-WIDTH L-X
    COMPUTE L-DX = L-LEFT + L-X
    COMPUTE L-IX = L-DX + 5
    IF W-ROW = 1
        MOVE 136 TO L-HITY
        COMPUTE L-DY = L-TOP + 132
        COMPUTE L-IY = L-DY + 7
    ELSE
        MOVE -32 TO L-HITY
        COMPUTE L-DY = L-TOP - 28
        COMPUTE L-IY = L-DY + 9
    END-IF
    COMPUTE L-SPRITE = FUNCTION MIN(W-COL, 7) + 1
    GOBACK.
 END PROGRAM MN7-TABGEO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SPRITE.
*> USING row, selected, column, sprite name out, size out (3.1: tab_top or tab_bottom, selected or unselected, column + 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-INDEX                BINARY-LONG.
 01 W-DIGIT                PIC 9.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-SIZE                 PIC X(96).
 PROCEDURE DIVISION USING L-ROW L-SELECTED L-COL L-NAME L-SIZE.
    MOVE SPACES TO L-NAME L-SIZE
    MOVE "26x32" TO L-SIZE
    COMPUTE W-INDEX = FUNCTION MIN(L-COL, 7) + 1
    MOVE W-INDEX TO W-DIGIT
    IF L-ROW = 1
        MOVE "container/creative_inventory/tab_bottom_" TO L-NAME
    ELSE
        MOVE "container/creative_inventory/tab_top_" TO L-NAME
    END-IF
    IF L-SELECTED = 1
        STRING FUNCTION TRIM(L-NAME) "selected_" W-DIGIT DELIMITED BY SIZE INTO L-NAME
    ELSE
        STRING FUNCTION TRIM(L-NAME) "unselected_" W-DIGIT DELIMITED BY SIZE INTO L-NAME
    END-IF
    GOBACK.
 END PROGRAM MN7-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HIT.
*> USING x, y relative to the image, tabX, tab y, hit out (3.2 checkTabClicked, inclusive).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-TX L-TY L-HIT.
    MOVE 0 TO L-HIT
    IF L-X >= L-TX AND L-X <= L-TX + 26 AND L-Y >= L-TY AND L-Y <= L-TY + 32
        MOVE 1 TO L-HIT
    END-IF
    GOBACK.
 END PROGRAM MN7-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HOVER.
*> USING x, y relative to the image, tabX, tab y, hover out (3.2: the box (tabX + 3, tabY + 3) of 21 x 27 widened by one pixel on each side).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-HOVER                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-TX L-TY L-HOVER.
    MOVE 0 TO L-HOVER
    IF L-X >= L-TX + 2 AND L-X < L-TX + 25 AND L-Y >= L-TY + 2 AND L-Y < L-TY + 33
        MOVE 1 TO L-HOVER
    END-IF
    GOBACK.
 END PROGRAM MN7-HOVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CURSOR.
*> USING selected, pointer x, y, drawn x, drawn y (absolute), hand cursor out (3.2: unselected tabs, strict edges).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SELECTED             BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SELECTED L-PX L-PY L-DX L-DY L-HAND.
    MOVE 0 TO L-HAND
    IF L-SELECTED = 0 AND L-PX > L-DX AND L-PX < L-DX + 26 AND L-PY > L-DY AND L-PY < L-DY + 32
        MOVE 1 TO L-HAND
    END-IF
    GOBACK.
 END PROGRAM MN7-CURSOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TABPICK.
*> USING x, y relative to the image, the operator tab is available, tab out (0 none): the first displayed tab in registry order that the point hits (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-RIGHT                BINARY-LONG.
 01 W-BG                   BINARY-LONG.
 01 W-SCROLL               BINARY-LONG.
 01 W-SHOW                 BINARY-LONG.
 01 W-WIDTH                BINARY-LONG VALUE 195.
 01 W-TX                   BINARY-LONG.
 01 W-TY                   BINARY-LONG.
 01 W-HIT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 01 L-TAB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-OP L-TAB.
    MOVE 0 TO L-TAB
    PERFORM VARYING W-N FROM 1 BY 1 UNTIL W-N > 14 OR L-TAB > 0
        IF W-N NOT = 13 OR L-OP = 1
            CALL "MN7-TAB" USING W-N W-ROW W-COL W-TYPE W-RIGHT W-BG W-SCROLL W-SHOW
            CALL "MN7-TABX" USING W-RIGHT W-COL W-WIDTH W-TX
            MOVE -32 TO W-TY
            IF W-ROW = 1
                MOVE 136 TO W-TY
            END-IF
            CALL "MN7-HIT" USING L-X L-Y W-TX W-TY W-HIT
            IF W-HIT = 1
                MOVE W-N TO L-TAB
            END-IF
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN7-TABPICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-OUTSIDE.
*> USING pointer x, y (absolute), leftPos, topPos, selected tab, hasClickedOutside out (3.3: outside the image and not on the selected tab's box).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 01 W-TYPE                 BINARY-LONG.
 01 W-RIGHT                BINARY-LONG.
 01 W-BG                   BINARY-LONG.
 01 W-SCROLL               BINARY-LONG.
 01 W-SHOW                 BINARY-LONG.
 01 W-WIDTH                BINARY-LONG VALUE 195.
 01 W-TX                   BINARY-LONG.
 01 W-TY                   BINARY-LONG.
 01 W-RX                   BINARY-LONG.
 01 W-RY                   BINARY-LONG.
 01 W-HIT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PX L-PY L-LEFT L-TOP L-SELECTED L-OUT.
    MOVE 0 TO L-OUT
    CALL "MN7-TAB" USING L-SELECTED W-ROW W-COL W-TYPE W-RIGHT W-BG W-SCROLL W-SHOW
    CALL "MN7-TABX" USING W-RIGHT W-COL W-WIDTH W-TX
    MOVE -32 TO W-TY
    IF W-ROW = 1
        MOVE 136 TO W-TY
    END-IF
    COMPUTE W-RX = L-PX - L-LEFT
    COMPUTE W-RY = L-PY - L-TOP
    CALL "MN7-HIT" USING W-RX W-RY W-TX W-TY W-HIT
    IF (L-PX < L-LEFT OR L-PY < L-TOP OR L-PX >= L-LEFT + 195 OR L-PY >= L-TOP + 136) AND W-HIT = 0
        MOVE 1 TO L-OUT
    END-IF
    GOBACK.
 END PROGRAM MN7-OUTSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-NEEDS.
*> USING feature set equal, permission flag equal, provider is the same object, needs update out (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FEATURES             BINARY-LONG.
 01 L-PERMS                BINARY-LONG.
 01 L-HOLDERS              BINARY-LONG.
 01 L-NEEDS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FEATURES L-PERMS L-HOLDERS L-NEEDS.
    MOVE 1 TO L-NEEDS
    IF L-FEATURES = 1 AND L-PERMS = 1 AND L-HOLDERS = 1
        MOVE 0 TO L-NEEDS
    END-IF
    GOBACK.
 END PROGRAM MN7-NEEDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-REBUILD.
*> USING parameters cached, needs update, rebuilt out (4.1 tryRebuildTabContents).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CACHED               BINARY-LONG.
 01 L-NEEDS                BINARY-LONG.
 01 L-REBUILT              BINARY-LONG.
 PROCEDURE DIVISION USING L-CACHED L-NEEDS L-REBUILT.
    MOVE 1 TO L-REBUILT
    IF L-CACHED = 1 AND L-NEEDS = 0
        MOVE 0 TO L-REBUILT
    END-IF
    GOBACK.
 END PROGRAM MN7-REBUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PASS.
*> USING tab type, build pass out (1 CATEGORY tabs first, 2 the other types) (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-PASS.
    MOVE 2 TO L-PASS
    IF L-TYPE = 1
        MOVE 1 TO L-PASS
    END-IF
    GOBACK.
 END PROGRAM MN7-PASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-ACCEPT.
*> USING stack count, the parent list has an equal stack, visibility (0 parent and search, 1 parent only, 2 search only), item enabled, error out (1 count,
*> 2 duplicate), added to the parent list out, added to the search list out (4.2 output rules in order).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-VIS                  BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 01 L-PARENT               BINARY-LONG.
 01 L-SEARCH               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-HAS L-VIS L-ENABLED L-ERROR L-PARENT L-SEARCH.
    MOVE 0 TO L-ERROR L-PARENT L-SEARCH
    EVALUATE TRUE
        WHEN L-COUNT NOT = 1
            MOVE 1 TO L-ERROR
        WHEN L-HAS = 1 AND L-VIS NOT = 2
            MOVE 2 TO L-ERROR
        WHEN L-ENABLED = 1
            IF L-VIS = 0 OR L-VIS = 1
                MOVE 1 TO L-PARENT
            END-IF
            IF L-VIS = 0 OR L-VIS = 2
                MOVE 1 TO L-SEARCH
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-GENTABLE.
*> USING generator (1 potions, 2 tipped arrows, 3 suspicious stews, 4 ominous bottles, 5 fireworks, 6 goat horns, 7 enchanted books max level, 8 enchanted books
*> all levels, 9 coloured families, 10 copper families, 11 placeable paintings, 12 non-placeable paintings), tab out, second tab out (0 none), visibility out (4.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DATA                 PIC X(60) VALUE "100000900010000100000809008000110011100202040010400400013000".
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-TAB                  BINARY-LONG.
 01 L-TAB2                 BINARY-LONG.
 01 L-VIS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-TAB L-TAB2 L-VIS.
    COMPUTE W-POS = (L-I - 1) * 5 + 1
    MOVE W-DATA(W-POS:2) TO L-TAB
    ADD 2 TO W-POS
    MOVE W-DATA(W-POS:2) TO L-TAB2
    ADD 2 TO W-POS
    MOVE W-DATA(W-POS:1) TO L-VIS
    GOBACK.
 END PROGRAM MN7-GENTABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-GENLIST.
*> USING kind (1 ominous bottles, 2 firework durations, 3 light levels), position from 1, count out, value out (4.4: amplifiers 0 to 4, durations 1 to 3, levels 15 down to 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-I L-COUNT L-VALUE.
    EVALUATE L-KIND
        WHEN 1
            MOVE 5 TO L-COUNT
            COMPUTE L-VALUE = L-I - 1
        WHEN 2
            MOVE 3 TO L-COUNT
            MOVE L-I TO L-VALUE
        WHEN OTHER
            MOVE 16 TO L-COUNT
            COMPUTE L-VALUE = 16 - L-I
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-GENLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-OPITEM.
*> USING position 1 to 10, plain operator item out, a dash out (4.4 the op_blocks plain items in order).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ITEMS.
    05 FILLER              PIC X(30) VALUE "command_block".
    05 FILLER              PIC X(30) VALUE "chain_command_block".
    05 FILLER              PIC X(30) VALUE "repeating_command_block".
    05 FILLER              PIC X(30) VALUE "command_block_minecart".
    05 FILLER              PIC X(30) VALUE "jigsaw".
    05 FILLER              PIC X(30) VALUE "structure_block".
    05 FILLER              PIC X(30) VALUE "structure_void".
    05 FILLER              PIC X(30) VALUE "barrier".
    05 FILLER              PIC X(30) VALUE "debug_stick".
    05 FILLER              PIC X(30) VALUE "test_instance_block".
 01 W-ITEMT REDEFINES W-ITEMS.
    05 W-ITEM              PIC X(30) OCCURS 10 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-DASH                 PIC X(96).
 PROCEDURE DIVISION USING L-I L-NAME L-DASH.
    MOVE SPACES TO L-NAME L-DASH
    MOVE W-ITEM(L-I) TO L-NAME
    MOVE "-" TO L-DASH
    GOBACK.
 END PROGRAM MN7-OPITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TESTMODE.
*> USING position 1 to 4, test block mode out, a dash out (4.4 TestBlockMode in declaration order).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-MODES.
    05 FILLER              PIC X(30) VALUE "start".
    05 FILLER              PIC X(30) VALUE "log".
    05 FILLER              PIC X(30) VALUE "fail".
    05 FILLER              PIC X(30) VALUE "accept".
 01 W-MODET REDEFINES W-MODES.
    05 W-MODE              PIC X(30) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-DASH                 PIC X(96).
 PROCEDURE DIVISION USING L-I L-NAME L-DASH.
    MOVE SPACES TO L-NAME L-DASH
    MOVE W-MODE(L-I) TO L-NAME
    MOVE "-" TO L-DASH
    GOBACK.
 END PROGRAM MN7-TESTMODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-OPCOUNT.
*> USING has permission, non-placeable painting count, plain items out, test blocks out, light blocks out, paintings out, total out (4.4 op_blocks generator).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PERM                 BINARY-LONG.
 01 L-PAINTINGS            BINARY-LONG.
 01 L-PLAIN                BINARY-LONG.
 01 L-TESTS                BINARY-LONG.
 01 L-LIGHTS               BINARY-LONG.
 01 L-OUTPAINT             BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-PERM L-PAINTINGS L-PLAIN L-TESTS L-LIGHTS L-OUTPAINT L-TOTAL.
    MOVE 0 TO L-PLAIN L-TESTS L-LIGHTS L-OUTPAINT L-TOTAL
    IF L-PERM = 1
        MOVE 10 TO L-PLAIN
        MOVE 4 TO L-TESTS
        MOVE 16 TO L-LIGHTS
        MOVE L-PAINTINGS TO L-OUTPAINT
        COMPUTE L-TOTAL = L-PLAIN + L-TESTS + L-LIGHTS + L-OUTPAINT
    END-IF
    GOBACK.
 END PROGRAM MN7-OPCOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-COLOR.
*> USING position 1 to 16, dye colour out, a dash out (4.4 the fixed colour order of the coloured families).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-COLORS.
    05 FILLER              PIC X(30) VALUE "white".
    05 FILLER              PIC X(30) VALUE "light_gray".
    05 FILLER              PIC X(30) VALUE "gray".
    05 FILLER              PIC X(30) VALUE "black".
    05 FILLER              PIC X(30) VALUE "brown".
    05 FILLER              PIC X(30) VALUE "red".
    05 FILLER              PIC X(30) VALUE "orange".
    05 FILLER              PIC X(30) VALUE "yellow".
    05 FILLER              PIC X(30) VALUE "lime".
    05 FILLER              PIC X(30) VALUE "green".
    05 FILLER              PIC X(30) VALUE "cyan".
    05 FILLER              PIC X(30) VALUE "light_blue".
    05 FILLER              PIC X(30) VALUE "blue".
    05 FILLER              PIC X(30) VALUE "purple".
    05 FILLER              PIC X(30) VALUE "magenta".
    05 FILLER              PIC X(30) VALUE "pink".
 01 W-COLORT REDEFINES W-COLORS.
    05 W-COLOR              PIC X(30) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-DASH                 PIC X(96).
 PROCEDURE DIVISION USING L-I L-NAME L-DASH.
    MOVE SPACES TO L-NAME L-DASH
    MOVE W-COLOR(L-I) TO L-NAME
    MOVE "-" TO L-DASH
    GOBACK.
 END PROGRAM MN7-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PAINTCMP.
*> USING area, width, area, width of two painting variants, comparison out (-1, 0, 1): area ascending then width ascending (4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A1                   BINARY-LONG.
 01 L-W1                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 01 L-W2                   BINARY-LONG.
 01 L-CMP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-A1 L-W1 L-A2 L-W2 L-CMP.
    EVALUATE TRUE
        WHEN L-A1 < L-A2
            MOVE -1 TO L-CMP
        WHEN L-A1 > L-A2
            MOVE 1 TO L-CMP
        WHEN L-W1 < L-W2
            MOVE -1 TO L-CMP
        WHEN L-W1 > L-W2
            MOVE 1 TO L-CMP
        WHEN OTHER
            MOVE 0 TO L-CMP
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-PAINTCMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SPAWNITEM.
*> USING position 1 to 40, item out, a dash out (4.4 the start of the spawn_eggs list as far as the document names it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-EGGS.
    05 FILLER              PIC X(30) VALUE "spawner".
    05 FILLER              PIC X(30) VALUE "trial_spawner".
    05 FILLER              PIC X(30) VALUE "creaking_heart".
    05 FILLER              PIC X(30) VALUE "chicken_spawn_egg".
    05 FILLER              PIC X(30) VALUE "cow_spawn_egg".
    05 FILLER              PIC X(30) VALUE "pig_spawn_egg".
    05 FILLER              PIC X(30) VALUE "sheep_spawn_egg".
    05 FILLER              PIC X(30) VALUE "camel_spawn_egg".
    05 FILLER              PIC X(30) VALUE "donkey_spawn_egg".
    05 FILLER              PIC X(30) VALUE "horse_spawn_egg".
    05 FILLER              PIC X(30) VALUE "mule_spawn_egg".
    05 FILLER              PIC X(30) VALUE "cat_spawn_egg".
    05 FILLER              PIC X(30) VALUE "parrot_spawn_egg".
    05 FILLER              PIC X(30) VALUE "wolf_spawn_egg".
    05 FILLER              PIC X(30) VALUE "armadillo_spawn_egg".
    05 FILLER              PIC X(30) VALUE "bat_spawn_egg".
    05 FILLER              PIC X(30) VALUE "bee_spawn_egg".
    05 FILLER              PIC X(30) VALUE "fox_spawn_egg".
    05 FILLER              PIC X(30) VALUE "goat_spawn_egg".
    05 FILLER              PIC X(30) VALUE "llama_spawn_egg".
    05 FILLER              PIC X(30) VALUE "ocelot_spawn_egg".
    05 FILLER              PIC X(30) VALUE "panda_spawn_egg".
    05 FILLER              PIC X(30) VALUE "polar_bear_spawn_egg".
    05 FILLER              PIC X(30) VALUE "rabbit_spawn_egg".
    05 FILLER              PIC X(30) VALUE "axolotl_spawn_egg".
    05 FILLER              PIC X(30) VALUE "cod_spawn_egg".
    05 FILLER              PIC X(30) VALUE "dolphin_spawn_egg".
    05 FILLER              PIC X(30) VALUE "frog_spawn_egg".
    05 FILLER              PIC X(30) VALUE "glow_squid_spawn_egg".
    05 FILLER              PIC X(30) VALUE "nautilus_spawn_egg".
    05 FILLER              PIC X(30) VALUE "pufferfish_spawn_egg".
    05 FILLER              PIC X(30) VALUE "salmon_spawn_egg".
    05 FILLER              PIC X(30) VALUE "squid_spawn_egg".
    05 FILLER              PIC X(30) VALUE "tadpole_spawn_egg".
    05 FILLER              PIC X(30) VALUE "tropical_fish_spawn_egg".
    05 FILLER              PIC X(30) VALUE "turtle_spawn_egg".
    05 FILLER              PIC X(30) VALUE "allay_spawn_egg".
    05 FILLER              PIC X(30) VALUE "mooshroom_spawn_egg".
    05 FILLER              PIC X(30) VALUE "sniffer_spawn_egg".
    05 FILLER              PIC X(30) VALUE "sulfur_cube_spawn_egg".
 01 W-EGGT REDEFINES W-EGGS.
    05 W-EGG              PIC X(30) OCCURS 40 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-DASH                 PIC X(96).
 PROCEDURE DIVISION USING L-I L-NAME L-DASH.
    MOVE SPACES TO L-NAME L-DASH
    MOVE W-EGG(L-I) TO L-NAME
    MOVE "-" TO L-DASH
    GOBACK.
 END PROGRAM MN7-SPAWNITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SEARCHORDER.
*> USING position 1 to 11, tab out (4.5: building, colored, natural, functional, redstone, tools, combat, food, ingredients, spawn eggs, op).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DATA                 PIC X(22) VALUE "0102030405080910111213".
 01 W-POS                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-TAB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-TAB.
    COMPUTE W-POS = (L-I - 1) * 2 + 1
    MOVE W-DATA(W-POS:2) TO L-TAB
    GOBACK.
 END PROGRAM MN7-SEARCHORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-UNION.
*> USING stack ids of two lists of four (0 is no stack), count out, the merged ids out (8): the first occurrence of an equal stack keeps its position (4.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-COUNT                BINARY-LONG.
 01 W-FOUND                BINARY-LONG.
 01 W-IN.
    05 W-ID                BINARY-LONG OCCURS 8 TIMES.
 01 W-OUT.
    05 W-O                 BINARY-LONG OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-A1                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 01 L-A3                   BINARY-LONG.
 01 L-A4                   BINARY-LONG.
 01 L-B1                   BINARY-LONG.
 01 L-B2                   BINARY-LONG.
 01 L-B3                   BINARY-LONG.
 01 L-B4                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-O3                   BINARY-LONG.
 01 L-O4                   BINARY-LONG.
 01 L-O5                   BINARY-LONG.
 01 L-O6                   BINARY-LONG.
 01 L-O7                   BINARY-LONG.
 01 L-O8                   BINARY-LONG.
 PROCEDURE DIVISION USING L-A1 L-A2 L-A3 L-A4 L-B1 L-B2 L-B3 L-B4 L-COUNT L-O1 L-O2 L-O3 L-O4 L-O5 L-O6 L-O7 L-O8.
    MOVE L-A1 TO W-ID(1)
    MOVE L-A2 TO W-ID(2)
    MOVE L-A3 TO W-ID(3)
    MOVE L-A4 TO W-ID(4)
    MOVE L-B1 TO W-ID(5)
    MOVE L-B2 TO W-ID(6)
    MOVE L-B3 TO W-ID(7)
    MOVE L-B4 TO W-ID(8)
    INITIALIZE W-OUT
    MOVE 0 TO W-COUNT
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 8
        MOVE 0 TO W-FOUND
        IF W-ID(W-I) = 0
            MOVE 1 TO W-FOUND
        END-IF
        PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > W-COUNT
            IF W-O(W-J) = W-ID(W-I)
                MOVE 1 TO W-FOUND
            END-IF
        END-PERFORM
        IF W-FOUND = 0
            ADD 1 TO W-COUNT
            MOVE W-ID(W-I) TO W-O(W-COUNT)
        END-IF
    END-PERFORM
    MOVE W-COUNT TO L-COUNT
    MOVE W-O(1) TO L-O1
    MOVE W-O(2) TO L-O2
    MOVE W-O(3) TO L-O3
    MOVE W-O(4) TO L-O4
    MOVE W-O(5) TO L-O5
    MOVE W-O(6) TO L-O6
    MOVE W-O(7) TO L-O7
    MOVE W-O(8) TO L-O8
    GOBACK.
 END PROGRAM MN7-UNION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-REFRESHTABS.
*> USING tabs were rebuilt, this tab is the selected one, tab type, its list is empty, action out (0 nothing, 1 select the default tab, 2 refresh the contents) (4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REBUILT              BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-REBUILT L-SELECTED L-TYPE L-EMPTY L-ACTION.
    MOVE 0 TO L-ACTION
    EVALUATE TRUE
        WHEN L-REBUILT = 0 OR L-SELECTED = 0
            MOVE 0 TO L-ACTION
        WHEN L-TYPE = 1 AND L-EMPTY = 1
            MOVE 1 TO L-ACTION
        WHEN OTHER
            MOVE 2 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-REFRESHTABS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PSLOT.
*> USING menu slot 0 to 53, x out, y out, class out (1 grid slot, 2 player inventory slot), container slot out (5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-X L-Y L-CLASS L-CONTAINER.
    IF L-SLOT < 45
        DIVIDE L-SLOT BY 9 GIVING W-ROW REMAINDER W-COL
        COMPUTE L-X = 9 + 18 * W-COL
        COMPUTE L-Y = 18 + 18 * W-ROW
        MOVE 1 TO L-CLASS
        MOVE L-SLOT TO L-CONTAINER
    ELSE
        COMPUTE W-COL = L-SLOT - 45
        COMPUTE L-X = 9 + 18 * W-COL
        MOVE 112 TO L-Y
        MOVE 2 TO L-CLASS
        MOVE W-COL TO L-CONTAINER
    END-IF
    GOBACK.
 END PROGRAM MN7-PSLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CPICKUP.
*> USING base mayPickup, the slot is not empty, the item is enabled, the stack has creative_slot_lock, may pickup out (5.1 CustomCreativeSlot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-NONEMPTY L-ENABLED L-LOCKED L-OK.
    MOVE 0 TO L-OK
    EVALUATE TRUE
        WHEN L-BASE = 1 AND L-NONEMPTY = 1
            IF L-ENABLED = 1 AND L-LOCKED = 0
                MOVE 1 TO L-OK
            END-IF
        WHEN L-NONEMPTY = 0
            MOVE 1 TO L-OK
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-CPICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-ROWCOUNT.
*> USING list size, calculateRowCount out (ceil(size / 9) - 5), canScroll out (size > 45) (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ROWS                 BINARY-LONG.
 01 W-SUM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-ROWS                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-ROWS L-CAN.
    COMPUTE W-SUM = L-SIZE + 8
    DIVIDE W-SUM BY 9 GIVING W-ROWS
    COMPUTE L-ROWS = W-ROWS - 5
    MOVE 0 TO L-CAN
    IF L-SIZE > 45
        MOVE 1 TO L-CAN
    END-IF
    GOBACK.
 END PROGRAM MN7-ROWCOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-ROWAT.
*> USING rowCount, scroll (float), first row out: max(0, (int)(scroll x rowCount + 0.5)) with the product in single precision (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-S                    FLOAT-SHORT.
 01 W-RC                   FLOAT-SHORT.
 01 W-P                    FLOAT-SHORT.
 01 W-D                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROWCOUNT             BINARY-LONG.
 01 L-SCROLL               FLOAT-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROWCOUNT L-SCROLL L-FIRST.
    MOVE L-SCROLL TO W-S
    MOVE L-ROWCOUNT TO W-RC
    COMPUTE W-P = W-S * W-RC
    COMPUTE W-D = W-P + 0.5
    COMPUTE L-FIRST = FUNCTION INTEGER-PART(W-D)
    IF L-FIRST < 0
        MOVE 0 TO L-FIRST
    END-IF
    GOBACK.
 END PROGRAM MN7-ROWAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SCROLLOF.
*> USING row index, rowCount, scroll out x 1e6: clamp(row / rowCount, 0, 1) (5.2 getScrollForRowIndex).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ROW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ROWCOUNT             BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ROWCOUNT L-SCROLL.
    MOVE L-ROW TO W-ROW
    IF W-ROW < 0
        MOVE 0 TO W-ROW
    END-IF
    IF W-ROW > L-ROWCOUNT
        MOVE L-ROWCOUNT TO W-ROW
    END-IF
    COMPUTE L-SCROLL ROUNDED = W-ROW * 1000000 / L-ROWCOUNT
    GOBACK.
 END PROGRAM MN7-SCROLLOF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SUBTRACT.
*> USING scroll (float), wheel (double), rowCount, scroll out x 1e6: clamp(scroll - wheel / rowCount, 0, 1) (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SCROLL               FLOAT-LONG.
 01 L-WHEEL                FLOAT-LONG.
 01 L-ROWCOUNT             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SCROLL L-WHEEL L-ROWCOUNT L-OUT.
    COMPUTE W-V = L-SCROLL - L-WHEEL / L-ROWCOUNT
    IF W-V < 0
        MOVE 0 TO W-V
    END-IF
    IF W-V > 1
        MOVE 1 TO W-V
    END-IF
    COMPUTE L-OUT ROUNDED = W-V * 1000000
    GOBACK.
 END PROGRAM MN7-SUBTRACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SCROLLTO.
*> USING first row, row, column, list size, item index out (-1: the empty stack): index = col + (row + first) x 9 (5.2 scrollTo).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-ROW L-COL L-SIZE L-INDEX.
    COMPUTE L-INDEX = L-COL + (L-ROW + L-FIRST) * 9
    IF L-INDEX < 0 OR L-INDEX >= L-SIZE
        MOVE -1 TO L-INDEX
    END-IF
    GOBACK.
 END PROGRAM MN7-SCROLLTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DRAGGABLE.
*> USING the slot is in the shared grid container, canDragTo out, canTakeItemForPickAll out (5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GRID                 BINARY-LONG.
 01 L-DRAG                 BINARY-LONG.
 01 L-PICKALL              BINARY-LONG.
 PROCEDURE DIVISION USING L-GRID L-DRAG L-PICKALL.
    COMPUTE L-DRAG = 1 - L-GRID
    MOVE L-DRAG TO L-PICKALL
    GOBACK.
 END PROGRAM MN7-DRAGGABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PQUICK.
*> USING slot index, slot count, the slot has an item, deleted out, moved count out (always 0) (5.3 quickMoveStack).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DELETED              BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TOTAL L-HAS L-DELETED L-MOVED.
    MOVE 0 TO L-DELETED L-MOVED
    IF L-INDEX >= L-TOTAL - 9 AND L-HAS = 1
        MOVE 1 TO L-DELETED
    END-IF
    GOBACK.
 END PROGRAM MN7-PQUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SEARCHBOX.
*> USING leftPos, topPos, x out, y out, width out, height out, max length out, text colour out (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-X L-Y L-W L-H L-MAX L-COLOUR.
    COMPUTE L-X = L-LEFT + 82
    COMPUTE L-Y = L-TOP + 6
    MOVE 80 TO L-W
    MOVE 9 TO L-H
    MOVE 50 TO L-MAX
    MOVE -1 TO L-COLOUR
    GOBACK.
 END PROGRAM MN7-SEARCHBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DRAWSTEP.
*> USING step 1 to 8, the extractBackground step out, a dash out (6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-STEPS.
    05 FILLER              PIC X(30) VALUE "dimmed world".
    05 FILLER              PIC X(30) VALUE "other tabs".
    05 FILLER              PIC X(30) VALUE "selected tab background".
    05 FILLER              PIC X(30) VALUE "scrollbar cursor".
    05 FILLER              PIC X(30) VALUE "search box".
    05 FILLER              PIC X(30) VALUE "scroller".
    05 FILLER              PIC X(30) VALUE "selected tab button".
    05 FILLER              PIC X(30) VALUE "player preview".
 01 W-STEPT REDEFINES W-STEPS.
    05 W-STEP              PIC X(30) OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-NAME                 PIC X(96).
 01 L-DASH                 PIC X(96).
 PROCEDURE DIVISION USING L-I L-NAME L-DASH.
    MOVE SPACES TO L-NAME L-DASH
    MOVE W-STEP(L-I) TO L-NAME
    MOVE "-" TO L-DASH
    GOBACK.
 END PROGRAM MN7-DRAWSTEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-THUMB.
*> USING leftPos, topPos, scroll (float), x out, y out: (leftPos + 175, topPos + 18 + (int)(95 x scroll)) with a single precision product (6.2, 6.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-S                    FLOAT-SHORT.
 01 W-95                   FLOAT-SHORT VALUE 95.
 01 W-P                    FLOAT-SHORT.
 01 W-OFF                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SCROLL               FLOAT-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-TOP L-SCROLL L-X L-Y.
    MOVE L-SCROLL TO W-S
    COMPUTE W-P = W-95 * W-S
    COMPUTE W-OFF = FUNCTION INTEGER-PART(W-P)
    COMPUTE L-X = L-LEFT + 175
    COMPUTE L-Y = L-TOP + 18 + W-OFF
    GOBACK.
 END PROGRAM MN7-THUMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-LABEL.
*> USING the tab shows its title, drawn out, x out, y out, colour out, shadow out (6.3: (8, 6) in #404040 without shadow).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHOW                 BINARY-LONG.
 01 L-DRAWN                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-SHADOW               BINARY-LONG.
 PROCEDURE DIVISION USING L-SHOW L-DRAWN L-X L-Y L-COLOUR L-SHADOW.
    MOVE L-SHOW TO L-DRAWN
    MOVE 8 TO L-X
    MOVE 6 TO L-Y
    MOVE -12566464 TO L-COLOUR
    MOVE 0 TO L-SHADOW
    GOBACK.
 END PROGRAM MN7-LABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-WRAP.
*> USING inventory menu slot 0 to 45, wrapper x out, wrapper y out (6.4 survival tab positions).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-K                    BINARY-LONG.
 01 W-HALF                 BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-ROW                  BINARY-LONG.
 01 W-COL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-X L-Y.
    EVALUATE TRUE
        WHEN L-SLOT <= 4
            MOVE -2000 TO L-X L-Y
        WHEN L-SLOT <= 8
            COMPUTE W-K = L-SLOT - 5
            DIVIDE W-K BY 2 GIVING W-HALF REMAINDER W-COL
            COMPUTE L-X = 54 + W-HALF * 54
            COMPUTE L-Y = 6 + W-COL * 27
        WHEN L-SLOT <= 35
            COMPUTE W-J = L-SLOT - 9
            DIVIDE W-J BY 9 GIVING W-ROW REMAINDER W-COL
            COMPUTE L-X = 9 + 18 * W-COL
            COMPUTE L-Y = 54 + 18 * W-ROW
        WHEN L-SLOT <= 44
            COMPUTE W-COL = FUNCTION MOD(L-SLOT - 9, 9)
            COMPUTE L-X = 9 + 18 * W-COL
            MOVE 112 TO L-Y
        WHEN OTHER
            MOVE 35 TO L-X
            MOVE 20 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DELETESLOT.
*> USING x out, y out, container slot out, slot count of the survival tab out (6.4: the delete slot after the 46 wrappers).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-CONTAINER L-COUNT.
    MOVE 173 TO L-X
    MOVE 112 TO L-Y
    MOVE 0 TO L-CONTAINER
    COMPUTE L-COUNT = 46 + 1
    GOBACK.
 END PROGRAM MN7-DELETESLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SELECT.
*> USING new tab type, old tab type, new tab, old tab, items out (0 none, 1 the saved hotbars, 2 a copy of the tab list), slot list out (0 unchanged, 1 replaced by the
*> 47 survival slots, 2 the saved list restored), search box visible out, text cleared out (6.5 selectTab).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEWTYPE              BINARY-LONG.
 01 L-OLDTYPE              BINARY-LONG.
 01 L-NEWTAB               BINARY-LONG.
 01 L-OLDTAB               BINARY-LONG.
 01 L-ITEMS                BINARY-LONG.
 01 L-SLOTS                BINARY-LONG.
 01 L-BOX                  BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 PROCEDURE DIVISION USING L-NEWTYPE L-OLDTYPE L-NEWTAB L-OLDTAB L-ITEMS L-SLOTS L-BOX L-CLEAR.
    MOVE 0 TO L-ITEMS L-SLOTS L-BOX
    MOVE 1 TO L-CLEAR
    EVALUATE TRUE
        WHEN L-NEWTYPE = 3
            MOVE 1 TO L-ITEMS
        WHEN L-NEWTYPE = 1
            MOVE 2 TO L-ITEMS
    END-EVALUATE
    EVALUATE TRUE
        WHEN L-NEWTYPE = 2
            MOVE 1 TO L-SLOTS
        WHEN L-OLDTYPE = 2
            MOVE 2 TO L-SLOTS
    END-EVALUATE
    IF L-NEWTYPE = 4
        MOVE 1 TO L-BOX
        IF L-NEWTAB = L-OLDTAB
            MOVE 0 TO L-CLEAR
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HBLIST.
*> USING list index 0 to 80, saved hotbar out, entry in the hotbar out (6.5 step 2: 9 entries for each of the 9 hotbars).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-HOTBAR               BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-HOTBAR L-ENTRY.
    DIVIDE L-INDEX BY 9 GIVING L-HOTBAR REMAINDER L-ENTRY
    GOBACK.
 END PROGRAM MN7-HBLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HBENTRY.
*> USING saved hotbar, entry, the hotbar is empty, entry kind out (0 empty stack, 1 paper with creative_slot_lock named inventory.hotbarInfo, 2 loaded stack) (6.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOTBAR               BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HOTBAR L-ENTRY L-EMPTY L-KIND.
    MOVE 2 TO L-KIND
    IF L-EMPTY = 1
        MOVE 0 TO L-KIND
        IF L-ENTRY = L-HOTBAR
            MOVE 1 TO L-KIND
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-HBENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-REFRESHCUR.
*> USING selected tab type, source out (1 refreshSearchResults, 2 add the whole list) (6.5 refreshCurrentTabContents).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-SOURCE.
    MOVE 2 TO L-SOURCE
    IF L-TYPE = 4
        MOVE 1 TO L-SOURCE
    END-IF
    GOBACK.
 END PROGRAM MN7-REFRESHCUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SCROLLBOX.
*> USING pointer x, y (absolute), leftPos, topPos, the tab can scroll, inside out (6.6: x 175 to 188, y 18 to 129 relative).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-PX L-PY L-LEFT L-TOP L-CAN L-INSIDE.
    MOVE 0 TO L-INSIDE
    IF L-PX >= L-LEFT + 175 AND L-PX < L-LEFT + 189 AND L-PY >= L-TOP + 18 AND L-PY < L-TOP + 130 AND L-CAN = 1
        MOVE 1 TO L-INSIDE
    END-IF
    GOBACK.
 END PROGRAM MN7-SCROLLBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DRAG.
*> USING pointer y, topPos, scroll out x 1e6: clamp((y - (topPos + 18) - 7.5) / 97, 0, 1) (6.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-V                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PY                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 PROCEDURE DIVISION USING L-PY L-TOP L-SCROLL.
    COMPUTE W-V = (L-PY - (L-TOP + 18) - 7.5) / 97
    IF W-V < 0
        MOVE 0 TO W-V
    END-IF
    IF W-V > 1
        MOVE 1 TO W-V
    END-IF
    COMPUTE L-SCROLL ROUNDED = W-V * 1000000
    GOBACK.
 END PROGRAM MN7-DRAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PRESS.
*> USING inside the scrollbar box, the screen can scroll, scrolling before, scrolling out, consumed out (6.6 press).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSIDE               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-BEFORE               BINARY-LONG.
 01 L-SCROLLING            BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-INSIDE L-CAN L-BEFORE L-SCROLLING L-CONSUMED.
    MOVE L-BEFORE TO L-SCROLLING
    MOVE L-INSIDE TO L-CONSUMED
    IF L-INSIDE = 1
        MOVE L-CAN TO L-SCROLLING
    END-IF
    GOBACK.
 END PROGRAM MN7-PRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-WHEEL.
*> USING the generic handler consumed it, the screen can scroll, the wheel scrolls out, consumed out (6.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GENERIC              BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-SCROLLS              BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-GENERIC L-CAN L-SCROLLS L-CONSUMED.
    MOVE 0 TO L-SCROLLS
    MOVE L-GENERIC TO L-CONSUMED
    IF L-GENERIC = 0 AND L-CAN = 1
        MOVE 1 TO L-SCROLLS
        MOVE 1 TO L-CONSUMED
    END-IF
    GOBACK.
 END PROGRAM MN7-WHEEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CANSC.
*> USING the tab's can-scroll flag, the menu's canScroll, the screen's canScroll out (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAB                  BINARY-LONG.
 01 L-MENU                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAB L-MENU L-CAN.
    MOVE 0 TO L-CAN
    IF L-TAB = 1 AND L-MENU = 1
        MOVE 1 TO L-CAN
    END-IF
    GOBACK.
 END PROGRAM MN7-CANSC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CURSORBAR.
*> USING pointer inside the scrollbar box, dragging, can scroll, cursor out (0 none, 1 resize north-south, 2 pointing hand, 3 not allowed) (6.2 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSIDE               BINARY-LONG.
 01 L-DRAGGING             BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-CURSOR               BINARY-LONG.
 PROCEDURE DIVISION USING L-INSIDE L-DRAGGING L-CAN L-CURSOR.
    MOVE 0 TO L-CURSOR
    EVALUATE TRUE
        WHEN L-INSIDE = 0
            MOVE 0 TO L-CURSOR
        WHEN L-DRAGGING = 1 AND L-CAN = 1
            MOVE 1 TO L-CURSOR
        WHEN L-CAN = 1
            MOVE 2 TO L-CURSOR
        WHEN OTHER
            MOVE 3 TO L-CURSOR
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-CURSORBAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DELTIP.
*> USING selected tab type, pointer over the delete slot, the inventory.binSlot tooltip shown out (6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OVER                 BINARY-LONG.
 01 L-TIP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OVER L-TIP.
    MOVE 0 TO L-TIP
    IF L-TYPE = 2 AND L-OVER = 1
        MOVE 1 TO L-TIP
    END-IF
    GOBACK.
 END PROGRAM MN7-DELTIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-PRE.
*> USING slot id, input, a slot exists, tab type, canDropItems, slot mayPickup, the slot is the delete slot, outcome out (0 stop, 1 the outside handler, 2 delete
*> all, 3 go on), input out (an outside PICKUP becomes THROW), quick out (7.1 pre-processing in order).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOTID               BINARY-LONG.
 01 L-INPUT                BINARY-LONG.
 01 L-EXISTS               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-MAYPICKUP            BINARY-LONG.
 01 L-DELETE               BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 01 L-NEWINPUT             BINARY-LONG.
 01 L-QUICK                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOTID L-INPUT L-EXISTS L-TYPE L-DROP L-MAYPICKUP L-DELETE L-OUTCOME L-NEWINPUT L-QUICK.
    MOVE 0 TO L-QUICK
    IF L-INPUT = 1
        MOVE 1 TO L-QUICK
    END-IF
    MOVE L-INPUT TO L-NEWINPUT
    IF L-SLOTID = -999 AND L-INPUT = 0
        MOVE 4 TO L-NEWINPUT
    END-IF
    EVALUATE TRUE
        WHEN L-NEWINPUT = 4 AND L-DROP = 0
            MOVE 0 TO L-OUTCOME
        WHEN L-EXISTS = 0 AND L-TYPE NOT = 2 AND L-NEWINPUT NOT = 5
            MOVE 1 TO L-OUTCOME
        WHEN L-EXISTS = 1 AND L-MAYPICKUP = 0
            MOVE 0 TO L-OUTCOME
        WHEN L-EXISTS = 1 AND L-DELETE = 1 AND L-QUICK = 1
            MOVE 2 TO L-OUTCOME
        WHEN OTHER
            MOVE 3 TO L-OUTCOME
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-PRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SURV.
*> USING the slot is the delete slot, input, a wrapper slot, it has an item, button, slot id, carried non-empty, max stack size, action out (1 empty the carried
*> stack, 2 THROW from the slot, 3 drop the carried stack, 4 forward to the inventory menu), count out (7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DELETE               BINARY-LONG.
 01 L-INPUT                BINARY-LONG.
 01 L-WRAPPER              BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-SLOTID               BINARY-LONG.
 01 L-CARRIED              BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DELETE L-INPUT L-WRAPPER L-HAS L-BUTTON L-SLOTID L-CARRIED L-MAX L-ACTION L-COUNT.
    MOVE 0 TO L-COUNT
    EVALUATE TRUE
        WHEN L-DELETE = 1 AND L-INPUT NOT = 1
            MOVE 1 TO L-ACTION
        WHEN L-INPUT = 4 AND L-WRAPPER = 1 AND L-HAS = 1
            MOVE 2 TO L-ACTION
            MOVE 1 TO L-COUNT
            IF L-BUTTON NOT = 0
                MOVE L-MAX TO L-COUNT
            END-IF
        WHEN L-INPUT = 4 AND L-SLOTID = -999 AND L-CARRIED = 1
            MOVE 3 TO L-ACTION
        WHEN OTHER
            MOVE 4 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-SURV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CASE.
*> USING carried empty, carried count, carried max stack, grid stack empty, grid count, grid max stack, same item and components, button, shift (quick), result
*> item out (0 empty, 1 the carried item, 2 the grid item), count out (7.3 case table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CE                   BINARY-LONG.
 01 L-CC                   BINARY-LONG.
 01 L-CM                   BINARY-LONG.
 01 L-SE                   BINARY-LONG.
 01 L-SC                   BINARY-LONG.
 01 L-SM                   BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-QUICK                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CE L-CC L-CM L-SE L-SC L-SM L-SAME L-BUTTON L-QUICK L-ITEM L-COUNT.
    MOVE 0 TO L-ITEM L-COUNT
    EVALUATE TRUE
        WHEN L-CE = 0 AND L-SE = 0 AND L-SAME = 1
            MOVE 1 TO L-ITEM
            MOVE L-CC TO L-COUNT
            EVALUATE TRUE
                WHEN L-BUTTON = 0 AND L-QUICK = 1
                    MOVE L-CM TO L-COUNT
                WHEN L-BUTTON = 0
                    IF L-CC < L-CM
                        COMPUTE L-COUNT = L-CC + 1
                    END-IF
                WHEN OTHER
                    COMPUTE L-COUNT = L-CC - 1
                    IF L-COUNT <= 0
                        MOVE 0 TO L-ITEM L-COUNT
                    END-IF
            END-EVALUATE
        WHEN L-CE = 0 AND L-BUTTON NOT = 0 AND (L-SE = 1 OR L-SAME = 0)
            COMPUTE L-COUNT = L-CC - 1
            IF L-COUNT > 0
                MOVE 1 TO L-ITEM
            ELSE
                MOVE 0 TO L-COUNT
            END-IF
        WHEN L-CE = 1 AND L-SE = 0
            MOVE 2 TO L-ITEM
            MOVE L-SC TO L-COUNT
            IF L-QUICK = 1
                MOVE L-SM TO L-COUNT
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-CASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SWAPCLONE.
*> USING input (2 SWAP, 3 CLONE), grid stack empty, carried empty, grid max stack size, inventory slot count out (0 none), carried count out (0 none) (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-SE                   BINARY-LONG.
 01 L-CE                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CARRIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-SE L-CE L-MAX L-SLOT L-CARRIED.
    MOVE 0 TO L-SLOT L-CARRIED
    EVALUATE TRUE
        WHEN L-INPUT = 2 AND L-SE = 0
            MOVE L-MAX TO L-SLOT
        WHEN L-INPUT = 3 AND L-CE = 1 AND L-SE = 0
            MOVE L-MAX TO L-CARRIED
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-SWAPCLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-THROWCOUNT.
*> USING grid stack empty, button, grid max stack size, dropped count out (7.3 THROW from a grid slot).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-BUTTON L-MAX L-COUNT.
    MOVE 0 TO L-COUNT
    IF L-EMPTY = 0
        MOVE 1 TO L-COUNT
        IF L-BUTTON NOT = 0
            MOVE L-MAX TO L-COUNT
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-THROWCOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DRAGEND.
*> USING button of a drag step, send the nine hotbar slots out: the header (bits 0 and 1) is 2 (7.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUTTON               BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BUTTON L-SEND.
    MOVE 0 TO L-SEND
    IF FUNCTION MOD(L-BUTTON, 4) = 2
        MOVE 1 TO L-SEND
    END-IF
    GOBACK.
 END PROGRAM MN7-DRAGEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HOTTHROW.
*> USING input, the stack read before the click is non-empty, carried non-empty, button, the stack count, dropped count out (7.4 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 01 L-CARRIED              BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-STACK L-CARRIED L-BUTTON L-COUNT L-DROPPED.
    MOVE 0 TO L-DROPPED
    IF L-INPUT = 4 AND L-STACK = 1 AND L-CARRIED = 1
        MOVE L-COUNT TO L-DROPPED
        IF L-BUTTON = 0
            MOVE 1 TO L-DROPPED
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-HOTTHROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-OUTCLICK.
*> USING carried non-empty, hasClickedOutside, canDropItems, button, carried count, dropped count out, carried stack emptied out (7.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CARRIED              BINARY-LONG.
 01 L-OUTSIDE              BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DROPPED              BINARY-LONG.
 01 L-EMPTIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CARRIED L-OUTSIDE L-DROP L-BUTTON L-COUNT L-DROPPED L-EMPTIED.
    MOVE 0 TO L-DROPPED L-EMPTIED
    IF L-CARRIED = 1 AND L-OUTSIDE = 1 AND L-DROP = 1
        EVALUATE L-BUTTON
            WHEN 0
                MOVE L-COUNT TO L-DROPPED
                MOVE 1 TO L-EMPTIED
            WHEN 1
                MOVE 1 TO L-DROPPED
        END-EVALUATE
    END-IF
    GOBACK.
 END PROGRAM MN7-OUTCLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-KEY.
*> USING tab type, chat key, hovered slot is not a grid slot, hovered slot has an item, digit key, hotbar key handled, search box consumed the key, text
*> changed, box captures input, key is Escape, action out (1 select the search tab, 2 hotbar key, 3 the box, 4 swallowed, 0 generic), ignoreTextInput out,
*> refresh search out (7.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-CHAT                 BINARY-LONG.
 01 L-NOTGRID              BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DIGIT                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-BOX                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-CAPTURES             BINARY-LONG.
 01 L-ESCAPE               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-REFRESH              BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-CHAT L-NOTGRID L-HAS L-DIGIT L-HANDLED L-BOX L-CHANGED L-CAPTURES L-ESCAPE L-ACTION L-IGNORE L-REFRESH.
    MOVE 0 TO L-ACTION L-IGNORE L-REFRESH
    EVALUATE TRUE
        WHEN L-TYPE NOT = 4 AND L-CHAT = 1
            MOVE 1 TO L-ACTION L-IGNORE
        WHEN L-TYPE NOT = 4
            MOVE 0 TO L-ACTION
        WHEN (L-NOTGRID = 1 OR L-HAS = 1) AND L-DIGIT = 1 AND L-HANDLED = 1
            MOVE 2 TO L-ACTION
            MOVE 1 TO L-IGNORE
        WHEN L-BOX = 1
            MOVE 3 TO L-ACTION
            MOVE L-CHANGED TO L-REFRESH
        WHEN L-CAPTURES = 1 AND L-ESCAPE = 0
            MOVE 4 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CHAR.
*> USING ignoreTextInput, the search tab is selected, the text changed, typed into the box out, refresh search out (7.6 charTyped).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IGNORE               BINARY-LONG.
 01 L-SEARCH               BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-TYPED                BINARY-LONG.
 01 L-REFRESH              BINARY-LONG.
 PROCEDURE DIVISION USING L-IGNORE L-SEARCH L-CHANGED L-TYPED L-REFRESH.
    MOVE 0 TO L-TYPED L-REFRESH
    IF L-IGNORE = 0 AND L-SEARCH = 1
        MOVE 1 TO L-TYPED
        MOVE L-CHANGED TO L-REFRESH
    END-IF
    GOBACK.
 END PROGRAM MN7-CHAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SREFRESH.
*> USING the query is empty, a connection exists, the query starts with #, mode out (0 empty list, 1 the whole search list, 2 name tree, 3 tag tree) (8.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-CONN                 BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-CONN L-HASH L-MODE.
    EVALUATE TRUE
        WHEN L-EMPTY = 1
            MOVE 1 TO L-MODE
        WHEN L-CONN = 0
            MOVE 0 TO L-MODE
        WHEN L-HASH = 1
            MOVE 3 TO L-MODE
        WHEN OTHER
            MOVE 2 TO L-MODE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-SREFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-CONTAINS.
*> USING haystack, needle, found out: the needle is a substring of the haystack; an empty needle is contained, an empty haystack contains nothing else (8.1, 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-HL                   BINARY-LONG.
 01 W-NL                   BINARY-LONG.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-HAY                  PIC X(96).
 01 L-NEEDLE               PIC X(96).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAY L-NEEDLE L-FOUND.
    MOVE 0 TO L-FOUND W-N
    EVALUATE TRUE
        WHEN L-NEEDLE = SPACES
            MOVE 1 TO L-FOUND
        WHEN L-HAY = SPACES
            MOVE 0 TO L-FOUND
        WHEN OTHER
            COMPUTE W-NL = FUNCTION LENGTH(FUNCTION TRIM(L-NEEDLE TRAILING))
            COMPUTE W-HL = FUNCTION LENGTH(FUNCTION TRIM(L-HAY TRAILING))
            IF W-NL <= W-HL
                INSPECT L-HAY(1:W-HL) TALLYING W-N FOR ALL L-NEEDLE(1:W-NL)
                IF W-N > 0
                    MOVE 1 TO L-FOUND
                END-IF
            END-IF
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-CONTAINS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SPLIT.
*> USING text, has a colon out, the part before the first colon out, the part after it out, both trimmed (8.1 updateVisibleTags, 8.2 queries).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-P                    BINARY-LONG.
 01 W-START                BINARY-LONG.
 01 W-LEN                  BINARY-LONG.
 01 W-A                    PIC X(96).
 01 W-B                    PIC X(96).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(96).
 01 L-HAS                  BINARY-LONG.
 01 L-A                    PIC X(96).
 01 L-B                    PIC X(96).
 PROCEDURE DIVISION USING L-TEXT L-HAS L-A L-B.
    MOVE SPACES TO L-A L-B W-A W-B
    MOVE 0 TO L-HAS W-P
    INSPECT L-TEXT TALLYING W-P FOR CHARACTERS BEFORE INITIAL ":"
    IF W-P < 96
        MOVE 1 TO L-HAS
        IF W-P > 0
            MOVE L-TEXT(1:W-P) TO W-A
        END-IF
        COMPUTE W-START = W-P + 2
        COMPUTE W-LEN = 96 - W-P - 1
        IF W-LEN > 0
            MOVE L-TEXT(W-START:W-LEN) TO W-B
        END-IF
        IF W-A NOT = SPACES
            MOVE FUNCTION TRIM(W-A) TO L-A
        END-IF
        IF W-B NOT = SPACES
            MOVE FUNCTION TRIM(W-B) TO L-B
        END-IF
    ELSE
        MOVE L-TEXT TO L-A
    END-IF
    GOBACK.
 END PROGRAM MN7-SPLIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-VISTAG.
*> USING query text, tag identifier ns:path, selected out (8.1 updateVisibleTags: case-sensitive substring tests).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-HAS                  BINARY-LONG.
 01 W-NS                   PIC X(96).
 01 W-PATH                 PIC X(96).
 01 W-HQ                   BINARY-LONG.
 01 W-A                    PIC X(96).
 01 W-B                    PIC X(96).
 01 W-F1                   BINARY-LONG.
 01 W-F2                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-QUERY                PIC X(96).
 01 L-TAG                  PIC X(96).
 01 L-SELECTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-QUERY L-TAG L-SELECTED.
    MOVE 0 TO L-SELECTED
    CALL "MN7-SPLIT" USING L-TAG W-HAS W-NS W-PATH
    CALL "MN7-SPLIT" USING L-QUERY W-HQ W-A W-B
    IF W-HQ = 1
        CALL "MN7-CONTAINS" USING W-NS W-A W-F1
        CALL "MN7-CONTAINS" USING W-PATH W-B W-F2
        IF W-F1 = 1 AND W-F2 = 1
            MOVE 1 TO L-SELECTED
        END-IF
    ELSE
        CALL "MN7-CONTAINS" USING W-PATH L-QUERY W-F2
        MOVE W-F2 TO L-SELECTED
    END-IF
    GOBACK.
 END PROGRAM MN7-VISTAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-LOWER.
*> USING text, lower-cased text out: ASCII letters only, so the root locale rules apply (8.2, 12 check 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(96).
 01 L-LOWER                PIC X(96).
 PROCEDURE DIVISION USING L-TEXT L-LOWER.
    MOVE L-TEXT TO L-LOWER
    INSPECT L-LOWER CONVERTING "ABCDEFGHIJKLMNOPQRSTUVWXYZ" TO "abcdefghijklmnopqrstuvwxyz"
    GOBACK.
 END PROGRAM MN7-S-LOWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-LINE.
*> USING a tooltip line, indexed text out: formatting codes (the section sign and the character after it) stripped, trimmed, lower-cased; spaces when empty (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SIGN                 PIC XX.
 01 W-I                    BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-OUT                  PIC X(96).
 01 W-TRIM                 PIC X(96).
 LINKAGE SECTION.
 01 L-LINE                 PIC X(96).
 01 L-TEXT                 PIC X(96).
 PROCEDURE DIVISION USING L-LINE L-TEXT.
    MOVE FUNCTION CHAR(195) TO W-SIGN(1:1)
    MOVE FUNCTION CHAR(168) TO W-SIGN(2:1)
    MOVE SPACES TO W-OUT L-TEXT
    MOVE 1 TO W-I
    MOVE 0 TO W-J
    PERFORM UNTIL W-I > 96
        IF W-I < 96 AND L-LINE(W-I:2) = W-SIGN
            ADD 3 TO W-I
        ELSE
            ADD 1 TO W-J
            MOVE L-LINE(W-I:1) TO W-OUT(W-J:1)
            ADD 1 TO W-I
        END-IF
    END-PERFORM
    IF W-OUT NOT = SPACES
        MOVE FUNCTION TRIM(W-OUT) TO W-TRIM
        CALL "MN7-S-LOWER" USING W-TRIM L-TEXT
    END-IF
    GOBACK.
 END PROGRAM MN7-S-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-DROP.
*> USING a tooltip line, dropped out: the indexed text is empty (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TEXT                 PIC X(96).
 LINKAGE SECTION.
 01 L-LINE                 PIC X(96).
 01 L-DROPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-LINE L-DROPPED.
    CALL "MN7-S-LINE" USING L-LINE W-TEXT
    MOVE 0 TO L-DROPPED
    IF W-TEXT = SPACES
        MOVE 1 TO L-DROPPED
    END-IF
    GOBACK.
 END PROGRAM MN7-S-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-NAME.
*> USING query, item key ns:path, indexed tooltip text (lower-cased), matches out (8.2 name search tree for one stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-Q                    PIC X(96).
 01 W-HAS                  BINARY-LONG.
 01 W-NS                   PIC X(96).
 01 W-PATH                 PIC X(96).
 01 W-HQ                   BINARY-LONG.
 01 W-A                    PIC X(96).
 01 W-B                    PIC X(96).
 01 W-F1                   BINARY-LONG.
 01 W-F2                   BINARY-LONG.
 01 W-F3                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-QUERY                PIC X(96).
 01 L-KEY                  PIC X(96).
 01 L-TEXT                 PIC X(96).
 01 L-MATCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-QUERY L-KEY L-TEXT L-MATCH.
    MOVE 0 TO L-MATCH
    CALL "MN7-S-LOWER" USING L-QUERY W-Q
    CALL "MN7-SPLIT" USING L-KEY W-HAS W-NS W-PATH
    CALL "MN7-SPLIT" USING W-Q W-HQ W-A W-B
    IF W-HQ = 1
        CALL "MN7-CONTAINS" USING W-NS W-A W-F1
        CALL "MN7-CONTAINS" USING W-PATH W-B W-F2
        CALL "MN7-CONTAINS" USING L-TEXT W-B W-F3
        IF W-F1 = 1 AND (W-F2 = 1 OR W-F3 = 1)
            MOVE 1 TO L-MATCH
        END-IF
    ELSE
        CALL "MN7-CONTAINS" USING L-TEXT W-Q W-F2
        CALL "MN7-CONTAINS" USING W-PATH W-Q W-F3
        IF W-F2 = 1 OR W-F3 = 1
            MOVE 1 TO L-MATCH
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-S-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-TAG.
*> USING query, tags of the item as ns:path separated by commas (up to 6), matches out (8.2 tag search tree for one stack: an intersection of the namespace and the
*> path results).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-TAGS.
    05 W-TAG               PIC X(96) OCCURS 6 TIMES.
 01 W-I                    BINARY-LONG.
 01 W-HAS                  BINARY-LONG.
 01 W-NS                   PIC X(96).
 01 W-PATH                 PIC X(96).
 01 W-HQ                   BINARY-LONG.
 01 W-A                    PIC X(96).
 01 W-B                    PIC X(96).
 01 W-F                    BINARY-LONG.
 01 W-NSANY                BINARY-LONG.
 01 W-PATHANY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-QUERY                PIC X(96).
 01 L-TAGS                 PIC X(96).
 01 L-MATCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-QUERY L-TAGS L-MATCH.
    MOVE SPACES TO W-TAGS
    MOVE 0 TO L-MATCH W-NSANY W-PATHANY
    UNSTRING L-TAGS DELIMITED BY "," INTO W-TAG(1) W-TAG(2) W-TAG(3) W-TAG(4) W-TAG(5) W-TAG(6)
    CALL "MN7-SPLIT" USING L-QUERY W-HQ W-A W-B
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 6
        IF W-TAG(W-I) NOT = SPACES
            CALL "MN7-SPLIT" USING W-TAG(W-I) W-HAS W-NS W-PATH
            IF W-HQ = 1
                CALL "MN7-CONTAINS" USING W-NS W-A W-F
                IF W-F = 1
                    MOVE 1 TO W-NSANY
                END-IF
                CALL "MN7-CONTAINS" USING W-PATH W-B W-F
            ELSE
                CALL "MN7-CONTAINS" USING W-PATH L-QUERY W-F
            END-IF
            IF W-F = 1
                MOVE 1 TO W-PATHANY
            END-IF
        END-IF
    END-PERFORM
    IF W-PATHANY = 1 AND (W-HQ = 0 OR W-NSANY = 1)
        MOVE 1 TO L-MATCH
    END-IF
    GOBACK.
 END PROGRAM MN7-S-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-S-RESULTS.
*> USING eight pairs (stack id, this entry matched), count out, the stack ids out (8): entries in insertion order, each stack once at its first match (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-COUNT                BINARY-LONG.
 01 W-FOUND                BINARY-LONG.
 01 W-IN.
    05 W-PAIR              OCCURS 8 TIMES.
       10 W-ID             BINARY-LONG.
       10 W-FLAG           BINARY-LONG.
 01 W-OUT.
    05 W-O                 BINARY-LONG OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-I1                   BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-I2                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-I3                   BINARY-LONG.
 01 L-F3                   BINARY-LONG.
 01 L-I4                   BINARY-LONG.
 01 L-F4                   BINARY-LONG.
 01 L-I5                   BINARY-LONG.
 01 L-F5                   BINARY-LONG.
 01 L-I6                   BINARY-LONG.
 01 L-F6                   BINARY-LONG.
 01 L-I7                   BINARY-LONG.
 01 L-F7                   BINARY-LONG.
 01 L-I8                   BINARY-LONG.
 01 L-F8                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-O3                   BINARY-LONG.
 01 L-O4                   BINARY-LONG.
 01 L-O5                   BINARY-LONG.
 01 L-O6                   BINARY-LONG.
 01 L-O7                   BINARY-LONG.
 01 L-O8                   BINARY-LONG.
 PROCEDURE DIVISION USING L-I1 L-F1 L-I2 L-F2 L-I3 L-F3 L-I4 L-F4 L-I5 L-F5 L-I6 L-F6 L-I7 L-F7 L-I8 L-F8
                          L-COUNT L-O1 L-O2 L-O3 L-O4 L-O5 L-O6 L-O7 L-O8.
    MOVE L-I1 TO W-ID(1)
    MOVE L-F1 TO W-FLAG(1)
    MOVE L-I2 TO W-ID(2)
    MOVE L-F2 TO W-FLAG(2)
    MOVE L-I3 TO W-ID(3)
    MOVE L-F3 TO W-FLAG(3)
    MOVE L-I4 TO W-ID(4)
    MOVE L-F4 TO W-FLAG(4)
    MOVE L-I5 TO W-ID(5)
    MOVE L-F5 TO W-FLAG(5)
    MOVE L-I6 TO W-ID(6)
    MOVE L-F6 TO W-FLAG(6)
    MOVE L-I7 TO W-ID(7)
    MOVE L-F7 TO W-FLAG(7)
    MOVE L-I8 TO W-ID(8)
    MOVE L-F8 TO W-FLAG(8)
    INITIALIZE W-OUT
    MOVE 0 TO W-COUNT
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 8
        MOVE 0 TO W-FOUND
        IF W-FLAG(W-I) = 0
            MOVE 1 TO W-FOUND
        END-IF
        PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > W-COUNT
            IF W-O(W-J) = W-ID(W-I)
                MOVE 1 TO W-FOUND
            END-IF
        END-PERFORM
        IF W-FOUND = 0
            ADD 1 TO W-COUNT
            MOVE W-ID(W-I) TO W-O(W-COUNT)
        END-IF
    END-PERFORM
    MOVE W-COUNT TO L-COUNT
    MOVE W-O(1) TO L-O1
    MOVE W-O(2) TO L-O2
    MOVE W-O(3) TO L-O3
    MOVE W-O(4) TO L-O4
    MOVE W-O(5) TO L-O5
    MOVE W-O(6) TO L-O6
    MOVE W-O(7) TO L-O7
    MOVE W-O(8) TO L-O8
    GOBACK.
 END PROGRAM MN7-S-RESULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TIPPLAN.
*> USING the advanced tooltips option, the slot is a grid slot, selected tab type, the line list is empty, advanced flags out, creative variant out, lines
*> returned unchanged out, tag lines inserted out, tab titles inserted out (8.3 getTooltipFromContainerItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADVANCED             BINARY-LONG.
 01 L-GRID                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 01 L-TAGS                 BINARY-LONG.
 01 L-TABS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ADVANCED L-GRID L-TYPE L-EMPTY L-FLAGS L-CREATIVE L-KEEP L-TAGS L-TABS.
    MOVE 0 TO L-FLAGS L-CREATIVE L-KEEP L-TAGS L-TABS
    IF L-EMPTY = 0
        MOVE L-ADVANCED TO L-FLAGS
        MOVE L-GRID TO L-CREATIVE
        IF L-TYPE = 1 AND L-GRID = 1
            MOVE 1 TO L-KEEP
        ELSE
            MOVE 1 TO L-TABS
            IF L-TYPE = 4 AND L-GRID = 1
                MOVE 1 TO L-TAGS
            END-IF
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-TIPPLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-TIPORDER.
*> USING visible tag lines, tab titles, index of the first tab title out, index of the first tag line out (8.3: tag lines go in first, then the titles).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAGS                 BINARY-LONG.
 01 L-TABS                 BINARY-LONG.
 01 L-TABINDEX             BINARY-LONG.
 01 L-TAGINDEX             BINARY-LONG.
 PROCEDURE DIVISION USING L-TAGS L-TABS L-TABINDEX L-TAGINDEX.
    MOVE 1 TO L-TABINDEX
    COMPUTE L-TAGINDEX = 1 + L-TABS
    GOBACK.
 END PROGRAM MN7-TIPORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-ADD.
*> USING infinite materials, the item's required features are enabled, send out (9.1 handleCreativeModeItemAdd).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INFINITE             BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INFINITE L-ENABLED L-SEND.
    MOVE 0 TO L-SEND
    IF L-INFINITE = 1 AND L-ENABLED = 1
        MOVE 1 TO L-SEND
    END-IF
    GOBACK.
 END PROGRAM MN7-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-DROP.
*> USING infinite materials, the screen is another container screen, the stack is not empty, the item is enabled, send out, throttler increment out (9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INFINITE             BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 01 L-INCREMENT            BINARY-LONG.
 PROCEDURE DIVISION USING L-INFINITE L-OTHER L-NONEMPTY L-ENABLED L-SEND L-INCREMENT.
    MOVE 0 TO L-SEND L-INCREMENT
    IF L-INFINITE = 1 AND L-OTHER = 0 AND L-NONEMPTY = 1 AND L-ENABLED = 1
        MOVE 1 TO L-SEND L-INCREMENT
    END-IF
    GOBACK.
 END PROGRAM MN7-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-SERVER.
*> USING infinite materials, item enabled, slot, the stack count is valid, the drop throttler is under its threshold, action out (0 ignore, 1 set the slot, 2 drop,
*> 3 dropping too fast), throttler incremented out (9.1 server rule).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INFINITE             BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-UNDER                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-INCREMENT            BINARY-LONG.
 PROCEDURE DIVISION USING L-INFINITE L-ENABLED L-SLOT L-VALID L-UNDER L-ACTION L-INCREMENT.
    MOVE 0 TO L-ACTION L-INCREMENT
    EVALUATE TRUE
        WHEN L-INFINITE = 0 OR L-ENABLED = 0
            MOVE 0 TO L-ACTION
        WHEN L-SLOT >= 1 AND L-SLOT <= 45 AND L-VALID = 1
            MOVE 1 TO L-ACTION
        WHEN L-SLOT < 0 AND L-VALID = 1 AND L-UNDER = 1
            MOVE 2 TO L-ACTION
            MOVE 1 TO L-INCREMENT
        WHEN L-SLOT < 0 AND L-VALID = 1
            MOVE 3 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-SERVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-LISTENER.
*> USING change (1 slotChanged, 2 dataChanged), handleCreativeModeItemAdd called out (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ADD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ADD.
    MOVE 0 TO L-ADD
    IF L-KIND = 1
        MOVE 1 TO L-ADD
    END-IF
    GOBACK.
 END PROGRAM MN7-LISTENER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-THROTTLE.
*> USING counter, incremented out (step 20), after a tick out (1 less while positive), under the server threshold 1480 out, under the client threshold 1280 out (9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-INC                  BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-CLIENT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-INC L-TICK L-SERVER L-CLIENT.
    COMPUTE L-INC = L-COUNTER + 20
    MOVE L-COUNTER TO L-TICK
    IF L-COUNTER > 0
        COMPUTE L-TICK = L-COUNTER - 1
    END-IF
    MOVE 0 TO L-SERVER L-CLIENT
    IF L-COUNTER < 1480
        MOVE 1 TO L-SERVER
    END-IF
    IF L-COUNTER < 1280
        MOVE 1 TO L-CLIENT
    END-IF
    GOBACK.
 END PROGRAM MN7-THROTTLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-BURST.
*> USING threshold, step, drops allowed in a burst out (-1: no limit for a threshold that is not positive) (9.3, 11.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SUM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-THRESHOLD            BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-THRESHOLD L-STEP L-DROPS.
    MOVE -1 TO L-DROPS
    IF L-THRESHOLD > 0
        COMPUTE W-SUM = L-THRESHOLD + L-STEP - 1
        DIVIDE W-SUM BY L-STEP GIVING L-DROPS
    END-IF
    GOBACK.
 END PROGRAM MN7-BURST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-IDENT.
*> USING saved hotbars out (9), default stored data version out (1343) (10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-VERSION              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-VERSION.
    MOVE 9 TO L-COUNT
    MOVE 1343 TO L-VERSION
    GOBACK.
 END PROGRAM MN7-HB-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-FILE.
*> USING hotbar 0 to 8, file name out, entry name out (10: hotbar.nbt with entries 0 to 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-DIGIT                PIC 9.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-FILE                 PIC X(96).
 01 L-ENTRY                PIC X(96).
 PROCEDURE DIVISION USING L-I L-FILE L-ENTRY.
    MOVE SPACES TO L-FILE L-ENTRY
    MOVE "hotbar.nbt" TO L-FILE
    MOVE L-I TO W-DIGIT
    MOVE W-DIGIT TO L-ENTRY(1:1)
    GOBACK.
 END PROGRAM MN7-HB-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-LOAD.
*> USING the file exists, the data version is present, the stored version, the entry parses, hotbar is empty out, version used out, warning logged out (10 loading).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXISTS               BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-VERSION              BINARY-LONG.
 01 L-PARSES               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 01 L-WARNING              BINARY-LONG.
 PROCEDURE DIVISION USING L-EXISTS L-PRESENT L-VERSION L-PARSES L-EMPTY L-USED L-WARNING.
    MOVE 1343 TO L-USED
    MOVE 0 TO L-WARNING
    MOVE 1 TO L-EMPTY
    IF L-EXISTS = 1
        IF L-PRESENT = 1
            MOVE L-VERSION TO L-USED
        END-IF
        IF L-PARSES = 1
            MOVE 0 TO L-EMPTY
        ELSE
            MOVE 1 TO L-WARNING
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN7-HB-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-KEY.
*> USING hotbar key, spectator, infinite materials, a screen is open, load activator down, save activator down, action out (0 select the hotbar slot, 1 load,
*> 2 save, 3 the spectator hotbar) (10 key use).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOTBAR               BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-SCREEN               BINARY-LONG.
 01 L-LOAD                 BINARY-LONG.
 01 L-SAVE                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOTBAR L-SPECTATOR L-INFINITE L-SCREEN L-LOAD L-SAVE L-ACTION.
    MOVE 0 TO L-ACTION
    EVALUATE TRUE
        WHEN L-SPECTATOR = 1
            MOVE 3 TO L-ACTION
        WHEN L-INFINITE = 1 AND L-SCREEN = 0 AND L-LOAD = 1
            MOVE 1 TO L-ACTION
        WHEN L-INFINITE = 1 AND L-SCREEN = 0 AND L-SAVE = 1
            MOVE 2 TO L-ACTION
    END-EVALUATE
    GOBACK.
 END PROGRAM MN7-HB-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-LOADSLOT.
*> USING hotbar position j 0 to 8, the creative slot packet's slot out (36 + j) (10 load).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-J                    BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-J L-SLOT.
    COMPUTE L-SLOT = 36 + L-J
    GOBACK.
 END PROGRAM MN7-HB-LOADSLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-MSG.
*> USING message (1 saved, 2 info), translation key out, English text out (10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  PIC X(96).
 01 L-TEXT                 PIC X(96).
 PROCEDURE DIVISION USING L-KIND L-KEY L-TEXT.
    MOVE SPACES TO L-KEY L-TEXT
    IF L-KIND = 1
        MOVE "inventory.hotbarSaved" TO L-KEY
        MOVE "Item hotbar saved (restore with %1$s + %2$s)" TO L-TEXT
    ELSE
        MOVE "inventory.hotbarInfo" TO L-KEY
        MOVE "Save hotbar with %1$s + %2$s" TO L-TEXT
    END-IF
    GOBACK.
 END PROGRAM MN7-HB-MSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN7-HB-ISEMPTY.
*> USING the number of stored entries that are not the empty stack encoding, Hotbar.isEmpty out (10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FILLED               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-FILLED L-EMPTY.
    MOVE 0 TO L-EMPTY
    IF L-FILLED = 0
        MOVE 1 TO L-EMPTY
    END-IF
    GOBACK.
 END PROGRAM MN7-HB-ISEMPTY.
