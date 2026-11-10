*> The generic container screen (docs/protocol/40-menus-1-model-and-containers.md sections 2.1, 5, 7 to 10; 05a Open Screen 0x3C, Container Set Slot 0x14): the menus of the chest
*> family (generic_9x1 to 9x6, ids 0 to 5), the dispenser and dropper (generic_3x3, 6), the hopper (16) and the shulker box (20). CONTAINER-LAYOUT is the table of
*> 7.2, 8.2, 9.2 and 10.2 (own slot count, imageHeight, the player inventory's top Y0, a centred title); CONTAINER-SLOT-POS the position of an own slot; the screen
*> is leftPos = (W - 176) div 2, topPos = (H - imageHeight) div 2, a panel (the sheet textures of these menus are not in the built-in pack) with the title at (8, 6)
*> (centred for the dispenser) and "Inventory" at (8, imageHeight - 94), the own slots (widget argument 401 + n, menu slot n), the player's main inventory
*> (argument 9 to 35, menu slot own + argument - 9) and hotbar (argument 0 to 8, menu slot own + 27 + argument), 18 x 18 widgets 1 pixel out of the item cell.
*> The labels' colour #404040 is not drawn (labels have one colour).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-FRAME.
*> USING menu type, own slots before the player inventory (out), own slots after it (out: the crafter's result), the player inventory's x and y
*> (out; y -1 for a menu with no player inventory), image width and height (out), title x (out; -1 centred) and y (out; -1 no title), inventory label x
*> and y (out; y -1 none), data slot count (out), known (out 1/0): the M1 to M7 tables of 40-1 sections 7 to 10 and parts 2 to 5 for the 24 menu types that
*> open a container screen (the crafting bench, 12, has its own screen); an unknown type gives zeros.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-TAIL                 BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IY                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-LX                   BINARY-LONG.
 01 L-LY                   BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OWN L-TAIL L-IX L-IY L-W L-H L-TX L-TY L-LX L-LY L-DATA L-KNOWN.
     MOVE 1 TO L-KNOWN
     MOVE 0 TO L-TAIL L-DATA
     MOVE 8 TO L-IX L-TX L-LX
     MOVE 84 TO L-IY
     MOVE 176 TO L-W
     MOVE 166 TO L-H
     MOVE 6 TO L-TY
     EVALUATE TRUE
         WHEN L-TYPE >= 0 AND L-TYPE <= 5
             COMPUTE L-OWN = 9 * (L-TYPE + 1)
             COMPUTE L-H = 114 + 18 * (L-TYPE + 1)
             COMPUTE L-IY = 31 + 18 * (L-TYPE + 1)
         WHEN L-TYPE = 6
             MOVE 9 TO L-OWN
             MOVE -1 TO L-TX
         WHEN L-TYPE = 7
             MOVE 9 TO L-OWN
             MOVE 1 TO L-TAIL
             MOVE 10 TO L-DATA
             MOVE -1 TO L-TX
         WHEN L-TYPE = 8
             MOVE 3 TO L-OWN
             MOVE 1 TO L-DATA
             MOVE 60 TO L-TX
         WHEN L-TYPE = 9
             MOVE 1 TO L-OWN
             MOVE 36 TO L-IX
             MOVE 137 TO L-IY
             MOVE 230 TO L-W
             MOVE 219 TO L-H
             MOVE 3 TO L-DATA
             MOVE -1 TO L-TX L-TY L-LY
         WHEN L-TYPE = 10 OR L-TYPE = 14 OR L-TYPE = 22
             MOVE 3 TO L-OWN
             MOVE 4 TO L-DATA
             MOVE -1 TO L-TX
         WHEN L-TYPE = 11
             MOVE 5 TO L-OWN
             MOVE 4 TO L-DATA
             MOVE -1 TO L-TX
         WHEN L-TYPE = 13
             MOVE 2 TO L-OWN
             MOVE 10 TO L-DATA
         WHEN L-TYPE = 15
             MOVE 3 TO L-OWN
         WHEN L-TYPE = 16
             MOVE 5 TO L-OWN
             MOVE 51 TO L-IY
             MOVE 133 TO L-H
         WHEN L-TYPE = 17
             MOVE 1 TO L-OWN
             MOVE 1 TO L-DATA
             MOVE -1 TO L-IY L-TX L-TY L-LY
         WHEN L-TYPE = 18
             MOVE 4 TO L-OWN
             MOVE 1 TO L-DATA
             MOVE 4 TO L-TY
         WHEN L-TYPE = 19
             MOVE 3 TO L-OWN
             MOVE 108 TO L-IX
             MOVE 276 TO L-W
             MOVE 107 TO L-LX
         WHEN L-TYPE = 20
             MOVE 27 TO L-OWN
             MOVE 167 TO L-H
         WHEN L-TYPE = 21
             MOVE 4 TO L-OWN
             MOVE 1 TO L-DATA
             MOVE 44 TO L-TX
             MOVE 15 TO L-TY
         WHEN L-TYPE = 23
             MOVE 3 TO L-OWN
             MOVE 4 TO L-TY
         WHEN L-TYPE = 24
             MOVE 2 TO L-OWN
             MOVE 1 TO L-DATA
             MOVE 5 TO L-TY
         WHEN OTHER
             MOVE 0 TO L-KNOWN L-OWN L-IX L-IY L-W L-H L-TX L-TY L-LX L-LY
     END-EVALUATE
     IF L-KNOWN = 1 AND NOT (L-TYPE = 9 OR L-TYPE = 17)
         COMPUTE L-LY = L-H - 94
     END-IF
     IF L-TYPE = 17
         MOVE 8 TO L-LX
     END-IF
     GOBACK.
 END PROGRAM CONTAINER-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-LAYOUT.
*> USING menu type, own slots (out), image height (out), Y0 (out), centred title (out 1/0), known (out 1/0): CONTAINER-FRAME's own slots before the
*> player inventory, image height, inventory y, centred title and known.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAIL                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-CENTRED              BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OWN L-HEIGHT L-Y0 L-CENTRED L-KNOWN.
     IF L-TYPE = 12
         MOVE 0 TO L-OWN L-HEIGHT L-Y0 L-CENTRED L-KNOWN
         GOBACK
     END-IF
     CALL "CONTAINER-FRAME" USING L-TYPE L-OWN WS-TAIL WS-IX L-Y0 WS-W L-HEIGHT WS-TX WS-TY WS-LX WS-LY
         WS-DATA L-KNOWN
     MOVE 0 TO L-CENTRED
     IF WS-TX = -1 AND WS-TY >= 0
         MOVE 1 TO L-CENTRED
     END-IF
     GOBACK.
 END PROGRAM CONTAINER-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-SLOT-POS.
*> USING menu type, own slot n (0 based; n after the own slots before the player inventory is a tail slot), x (out), y (out): the item cell of an own slot in
*> the screen image (the tables M2 of 40-1 sections 7 to 10 and parts 2 to 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-POSITIONS.
*>   Furnace family, brewing stand, anvil, beacon, enchanting, grindstone, lectern, loom, merchant, smithing, cartography, stonecutter: type (2 digits) and
*>   x, y (3 digits each) of each own slot in order; the types of one row are the rows of 3 or 5 slots.
    05 FILLER PIC X(8) VALUE "14056017".
    05 FILLER PIC X(8) VALUE "14056053".
    05 FILLER PIC X(8) VALUE "14116035".
    05 FILLER PIC X(8) VALUE "10056017".
    05 FILLER PIC X(8) VALUE "10056053".
    05 FILLER PIC X(8) VALUE "10116035".
    05 FILLER PIC X(8) VALUE "22056017".
    05 FILLER PIC X(8) VALUE "22056053".
    05 FILLER PIC X(8) VALUE "22116035".
    05 FILLER PIC X(8) VALUE "11056051".
    05 FILLER PIC X(8) VALUE "11079058".
    05 FILLER PIC X(8) VALUE "11102051".
    05 FILLER PIC X(8) VALUE "11079017".
    05 FILLER PIC X(8) VALUE "11017017".
    05 FILLER PIC X(8) VALUE "08027047".
    05 FILLER PIC X(8) VALUE "08076047".
    05 FILLER PIC X(8) VALUE "08134047".
    05 FILLER PIC X(8) VALUE "09136110".
    05 FILLER PIC X(8) VALUE "13015047".
    05 FILLER PIC X(8) VALUE "13035047".
    05 FILLER PIC X(8) VALUE "15049019".
    05 FILLER PIC X(8) VALUE "15049040".
    05 FILLER PIC X(8) VALUE "15129034".
    05 FILLER PIC X(8) VALUE "17000000".
    05 FILLER PIC X(8) VALUE "18013026".
    05 FILLER PIC X(8) VALUE "18033026".
    05 FILLER PIC X(8) VALUE "18023045".
    05 FILLER PIC X(8) VALUE "18143057".
    05 FILLER PIC X(8) VALUE "19136037".
    05 FILLER PIC X(8) VALUE "19162037".
    05 FILLER PIC X(8) VALUE "19220037".
    05 FILLER PIC X(8) VALUE "21008048".
    05 FILLER PIC X(8) VALUE "21026048".
    05 FILLER PIC X(8) VALUE "21044048".
    05 FILLER PIC X(8) VALUE "21098048".
    05 FILLER PIC X(8) VALUE "23015015".
    05 FILLER PIC X(8) VALUE "23015052".
    05 FILLER PIC X(8) VALUE "23145039".
    05 FILLER PIC X(8) VALUE "24020033".
    05 FILLER PIC X(8) VALUE "24143033".
 01 WS-POS-TABLE REDEFINES WS-POSITIONS.
    05 WS-ROW OCCURS 40 TIMES.
       10 WS-ROW-TYPE      PIC 99.
       10 WS-ROW-X         PIC 999.
       10 WS-ROW-Y         PIC 999.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-N L-X L-Y.
     EVALUATE TRUE
         WHEN L-TYPE = 6
             COMPUTE WS-R = L-N / 3
             COMPUTE L-X = 62 + 18 * (L-N - WS-R * 3)
             COMPUTE L-Y = 17 + 18 * WS-R
         WHEN L-TYPE = 16
             COMPUTE L-X = 44 + 18 * L-N
             MOVE 20 TO L-Y
         WHEN L-TYPE = 7 AND L-N < 9
             COMPUTE WS-R = L-N / 3
             COMPUTE L-X = 26 + 18 * (L-N - WS-R * 3)
             COMPUTE L-Y = 17 + 18 * WS-R
         WHEN L-TYPE = 7
             MOVE 134 TO L-X
             MOVE 35 TO L-Y
         WHEN L-TYPE >= 0 AND (L-TYPE <= 5 OR L-TYPE = 20)
             COMPUTE WS-R = L-N / 9
             COMPUTE L-X = 8 + 18 * (L-N - WS-R * 9)
             COMPUTE L-Y = 18 + 18 * WS-R
         WHEN OTHER
             MOVE 0 TO L-X L-Y WS-K
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
                 IF WS-ROW-TYPE(WS-I) = L-TYPE
                     IF WS-K = L-N
                         MOVE WS-ROW-X(WS-I) TO L-X
                         MOVE WS-ROW-Y(WS-I) TO L-Y
                     END-IF
                     ADD 1 TO WS-K
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-SLOT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-WIRE.
*> USING CLIENT-STATE, widget argument, menu slot out (-1: no menu slot): own slot 401 + n is n (a tail slot, after the player inventory, is own + 36 + n
*> - own), the main inventory 9 to 35 is own + argument - 9, the hotbar 0 to 8 is own + 27 + argument; a menu with no player inventory has none of these.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-SLOT.
     CALL "CONTAINER-FRAME" USING BM-TYPE WS-OWN WS-TAIL WS-IX WS-IY WS-W WS-H WS-TX WS-TY WS-LX WS-LY
         WS-DATA WS-KNOWN
     MOVE -1 TO L-SLOT
     EVALUATE TRUE
         WHEN L-ARG >= 401 AND L-ARG - 401 < WS-OWN
             COMPUTE L-SLOT = L-ARG - 401
         WHEN L-ARG >= 401 + WS-OWN AND L-ARG - 401 < WS-OWN + WS-TAIL AND WS-IY >= 0
             COMPUTE L-SLOT = L-ARG - 401 + 36
         WHEN L-ARG >= 9 AND L-ARG <= 35 AND WS-IY >= 0
             COMPUTE L-SLOT = WS-OWN + L-ARG - 9
         WHEN L-ARG >= 0 AND L-ARG <= 8 AND WS-IY >= 0
             COMPUTE L-SLOT = WS-OWN + 27 + L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-ARG.
*> USING CLIENT-STATE, menu slot, widget argument out (-1: none): the inverse of CONTAINER-WIRE for the open container's type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-ARG.
     CALL "CONTAINER-FRAME" USING BM-TYPE WS-OWN WS-TAIL WS-IX WS-IY WS-W WS-H WS-TX WS-TY WS-LX WS-LY
         WS-DATA WS-KNOWN
     COMPUTE WS-REST = L-SLOT - WS-OWN
     EVALUATE TRUE
         WHEN L-SLOT >= 0 AND L-SLOT < WS-OWN
             COMPUTE L-ARG = 401 + L-SLOT
         WHEN WS-IY < 0
             MOVE -1 TO L-ARG
         WHEN WS-REST >= 0 AND WS-REST <= 26
             COMPUTE L-ARG = 9 + WS-REST
         WHEN WS-REST >= 27 AND WS-REST <= 35
             COMPUTE L-ARG = WS-REST - 27
         WHEN WS-REST >= 36 AND WS-REST < 36 + WS-TAIL
             COMPUTE L-ARG = 401 + WS-OWN + WS-REST - 36
         WHEN OTHER
             MOVE -1 TO L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the panel of the image (CONTAINER-FRAME), the title and the inventory label, the hover highlight's back sprite
*> (24 x 24 at the hovered slot's item cell - 4, 40-1 section 5.4), the own slots, the player's main inventory and hotbar, the highlight's front sprite and the
*> carried stack at the pointer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-PANEL               BINARY-LONG VALUE SW-PANEL.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "container.inventory".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 19.
 01 WS-LANG-TEXT           PIC X(512).
 01 WS-LANG-LENGTH         BINARY-LONG.
 01 WS-CURSOR              BINARY-LONG VALUE 36.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-HOVER               BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-24                  BINARY-LONG VALUE 24.
 01 WS-24H                 BINARY-LONG VALUE 24.
 01 WS-LABEL-W             BINARY-LONG VALUE 160.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     GO TO MAIN-FLOW.
*> The item cell (WS-X, WS-Y in the image) of slot WS-I: own slots first, then the 27 main and 9 hotbar slots of the player, with the player's argument
*> in WS-ARG when it is one; a menu with no player inventory puts them at (-100, -100).
 SLOT-CELL.
     EVALUATE TRUE
         WHEN WS-I < WS-OWN + WS-TAIL
             CALL "CONTAINER-SLOT-POS" USING BM-TYPE WS-I WS-X WS-Y
         WHEN WS-IY < 0
             MOVE -100 TO WS-X WS-Y
         WHEN WS-I - WS-OWN - WS-TAIL < 9
             COMPUTE WS-C = WS-I - WS-OWN - WS-TAIL
             COMPUTE WS-X = WS-IX + 18 * WS-C
             COMPUTE WS-Y = WS-IY + 58
         WHEN OTHER
             COMPUTE WS-R = (WS-I - WS-OWN - WS-TAIL - 9) / 9
             COMPUTE WS-C = WS-I - WS-OWN - WS-TAIL - 9 - WS-R * 9
             COMPUTE WS-X = WS-IX + 18 * WS-C
             COMPUTE WS-Y = WS-IY + 18 * WS-R
     END-EVALUATE
     .

 MAIN-FLOW.
     CALL "CONTAINER-FRAME" USING BM-TYPE WS-OWN WS-TAIL WS-IX WS-IY WS-W WS-H WS-TX WS-TY WS-LX WS-LY
         WS-DATA WS-KNOWN
     COMPUTE WS-LEFT = (L-GW - WS-W) / 2
     COMPUTE WS-TOP = (L-GH - WS-H) / 2
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH
     MOVE WK-OVERLAY TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-PANEL WS-LEFT WS-TOP WS-W WS-H
         WS-TEXT WS-LENGTH WS-STATE
*>   The title at (tx, ty), centred in the image when tx is -1 (none when ty is -1); the inventory label (none when ly is -1).
     IF WS-TY >= 0
         MOVE SM-CX-TITLE TO WS-TEXT
         MOVE SM-CX-TITLE-LENGTH TO WS-LENGTH
         COMPUTE WS-X = WS-LEFT + WS-TX
         IF WS-TX = -1
             MOVE SM-CX-TITLE TO WS-TEXT256
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-WIDTH
             COMPUTE WS-X = WS-LEFT + (WS-W - WS-WIDTH) / 2
         END-IF
*>       The merchant's title is "<title> - <level>" at 49 + (276 - width) / 2 (40-5 section 2.10).
         IF BM-TYPE = 19
             MOVE SM-CX-TITLE TO WS-TEXT256
             CALL "MERCHANT-TITLE" USING CLIENT-STATE WS-TEXT256 WS-LENGTH
             MOVE WS-TEXT256 TO WS-TEXT
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-WIDTH
             COMPUTE WS-X = WS-LEFT + 49 + (WS-W - WS-WIDTH) / 2
         END-IF
         COMPUTE WS-Y = WS-TOP + WS-TY
         MOVE WK-LABEL TO WS-KIND
         MOVE 0 TO WS-ARG
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H
             WS-TEXT WS-LENGTH WS-STATE
     END-IF
     IF WS-LY >= 0
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-LANG-TEXT WS-LANG-LENGTH
         COMPUTE WS-X = WS-LEFT + WS-LX
         COMPUTE WS-Y = WS-TOP + WS-LY
         MOVE WK-LABEL TO WS-KIND
         MOVE 0 TO WS-ARG
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H
             WS-LANG-TEXT WS-LANG-LENGTH WS-STATE
     END-IF
     CALL "MENU-DECOR" USING CLIENT-STATE WS-LEFT WS-TOP L-GW L-GH
*>   The hovered slot: the first slot in order whose 18 x 18 cell holds the pointer.
     COMPUTE WS-PX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-PY = IN-CURSOR-Y / CL-GUI-SCALE
     MOVE -1 TO WS-HOVER
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-OWN + WS-TAIL + 36 OR WS-HOVER >= 0
         PERFORM SLOT-CELL
         IF WS-PX >= WS-LEFT + WS-X - 1 AND WS-PX < WS-LEFT + WS-X + 17
                 AND WS-PY >= WS-TOP + WS-Y - 1 AND WS-PY < WS-TOP + WS-Y + 17
             MOVE WS-I TO WS-HOVER
             COMPUTE WS-HX = WS-LEFT + WS-X - 4
             COMPUTE WS-HY = WS-TOP + WS-Y - 4
         END-IF
     END-PERFORM
     MOVE WK-SPRITE TO WS-KIND
     IF WS-HOVER >= 0
         MOVE GSP-HIGHLIGHT-BACK TO WS-SPRITE
         MOVE SPACES TO WS-TEXT
         MOVE 0 TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SPRITE WS-HX WS-HY WS-24 WS-24H
             WS-TEXT WS-LENGTH WS-STATE
     END-IF
*>   The own slots (widget argument 401 + n), then the player's slots (argument 0 to 35).
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-OWN + WS-TAIL + 36
         PERFORM SLOT-CELL
         COMPUTE WS-X = WS-LEFT + WS-X - 1
         COMPUTE WS-Y = WS-TOP + WS-Y - 1
         IF WS-I < WS-OWN + WS-TAIL
             COMPUTE WS-ARG = 401 + WS-I
             CALL "CONTAINER-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-X WS-Y
         END-IF
         IF WS-I >= WS-OWN + WS-TAIL AND WS-IY >= 0
             COMPUTE WS-ARG = WS-I - WS-OWN - WS-TAIL
             CALL "CONTAINER-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-X WS-Y
         END-IF
     END-PERFORM
     IF WS-HOVER >= 0
         MOVE WK-SPRITE TO WS-KIND
         MOVE GSP-HIGHLIGHT-FRONT TO WS-SPRITE
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SPRITE WS-HX WS-HY WS-24 WS-24H
             WS-TEXT WS-LENGTH WS-STATE
     END-IF
     IF PL-CARRIED-COUNT > 0
         COMPUTE WS-X = IN-CURSOR-X / CL-GUI-SCALE - 8
         COMPUTE WS-Y = IN-CURSOR-Y / CL-GUI-SCALE - 8
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-CURSOR WS-X WS-Y WS-NONE
     END-IF
     GOBACK.
 END PROGRAM CONTAINER-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-SLOT-ADD.
*> USING CLIENT-STATE, widget argument, x, y (the widget's corner): an item slot widget of 18 x 18 GUI pixels.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ACTION              BINARY-LONG VALUE ACT-SLOT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-X L-Y.
     CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE L-ARG L-X L-Y WS-ACTION
     MOVE 18 TO SM-W-W(SM-WIDGET-COUNT) SM-W-H(SM-WIDGET-COUNT)
     GOBACK.
 END PROGRAM CONTAINER-SLOT-ADD.
