*> The generic container screen (docs/protocol/40-menus-1-model-and-containers.md sections 2.1, 5, 7 to 10; 05a Open Screen 0x3C, Container Set Slot 0x14): the menus of the chest
*> family (generic_9x1 to 9x6, ids 0 to 5), the dispenser and dropper (generic_3x3, 6), the hopper (16) and the shulker box (20). CONTAINER-LAYOUT is the table of
*> 7.2, 8.2, 9.2 and 10.2 (own slot count, imageHeight, the player inventory's top Y0, a centred title); CONTAINER-SLOT-POS the position of an own slot; the screen
*> is leftPos = (W - 176) div 2, topPos = (H - imageHeight) div 2, a panel (the sheet textures of these menus are not in the built-in pack) with the title at (8, 6)
*> (centred for the dispenser) and "Inventory" at (8, imageHeight - 94), the own slots (widget argument 401 + n, menu slot n), the player's main inventory
*> (argument 9 to 35, menu slot own + argument - 9) and hotbar (argument 0 to 8, menu slot own + 27 + argument), 18 x 18 widgets 1 pixel out of the item cell.
*> The labels' colour #404040 is not drawn (labels have one colour).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-LAYOUT.
*> USING menu type, own slots (out), image height (out), Y0 (out), centred title (out 1/0), known (out 1/0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-CENTRED              BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OWN L-HEIGHT L-Y0 L-CENTRED L-KNOWN.
     MOVE 1 TO L-KNOWN
     MOVE 0 TO L-CENTRED
     EVALUATE TRUE
         WHEN L-TYPE >= 0 AND L-TYPE <= 5
             COMPUTE L-OWN = 9 * (L-TYPE + 1)
             COMPUTE L-HEIGHT = 114 + 18 * (L-TYPE + 1)
             COMPUTE L-Y0 = 31 + 18 * (L-TYPE + 1)
         WHEN L-TYPE = 6
             MOVE 9 TO L-OWN
             MOVE 166 TO L-HEIGHT
             MOVE 84 TO L-Y0
             MOVE 1 TO L-CENTRED
         WHEN L-TYPE = 16
             MOVE 5 TO L-OWN
             MOVE 133 TO L-HEIGHT
             MOVE 51 TO L-Y0
         WHEN L-TYPE = 20
             MOVE 27 TO L-OWN
             MOVE 167 TO L-HEIGHT
             MOVE 84 TO L-Y0
         WHEN OTHER
             MOVE 0 TO L-OWN L-HEIGHT L-Y0 L-KNOWN
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-SLOT-POS.
*> USING menu type, own slot n (0 based), x (out), y (out): the item cell of an own slot in the screen image.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
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
         WHEN OTHER
             COMPUTE WS-R = L-N / 9
             COMPUTE L-X = 8 + 18 * (L-N - WS-R * 9)
             COMPUTE L-Y = 18 + 18 * WS-R
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-SLOT-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-WIRE.
*> USING CLIENT-STATE, widget argument, menu slot out (-1: no menu slot): own slot 401 + n is n, the main inventory 9 to 35 is own + argument - 9, the
*> hotbar 0 to 8 is own + 27 + argument.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWN                 BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-CENTRED             BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ARG                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ARG L-SLOT.
     CALL "CONTAINER-LAYOUT" USING BM-TYPE WS-OWN WS-HEIGHT WS-Y0 WS-CENTRED WS-KNOWN
     MOVE -1 TO L-SLOT
     EVALUATE TRUE
         WHEN L-ARG >= 401 AND L-ARG - 401 < WS-OWN
             COMPUTE L-SLOT = L-ARG - 401
         WHEN L-ARG >= 9 AND L-ARG <= 35
             COMPUTE L-SLOT = WS-OWN + L-ARG - 9
         WHEN L-ARG >= 0 AND L-ARG <= 8
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
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-CENTRED             BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-ARG.
     CALL "CONTAINER-LAYOUT" USING BM-TYPE WS-OWN WS-HEIGHT WS-Y0 WS-CENTRED WS-KNOWN
     COMPUTE WS-REST = L-SLOT - WS-OWN
     EVALUATE TRUE
         WHEN L-SLOT >= 0 AND L-SLOT < WS-OWN
             COMPUTE L-ARG = 401 + L-SLOT
         WHEN WS-REST >= 0 AND WS-REST <= 26
             COMPUTE L-ARG = 9 + WS-REST
         WHEN WS-REST >= 27 AND WS-REST <= 35
             COMPUTE L-ARG = WS-REST - 27
         WHEN OTHER
             MOVE -1 TO L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTAINER-ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTAINER-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-OWN                 BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-CENTRED             BINARY-LONG.
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
 01 WS-SLOT-ACTION         BINARY-LONG VALUE ACT-SLOT.
 01 WS-PANEL               BINARY-LONG VALUE SW-PANEL.
 01 WS-W                   BINARY-LONG VALUE 176.
 01 WS-H                   BINARY-LONG.
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
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     CALL "CONTAINER-LAYOUT" USING BM-TYPE WS-OWN WS-HEIGHT WS-Y0 WS-CENTRED WS-KNOWN
     COMPUTE WS-LEFT = (L-GW - 176) / 2
     COMPUTE WS-TOP = (L-GH - WS-HEIGHT) / 2
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LENGTH
     MOVE WK-OVERLAY TO WS-KIND
     MOVE WS-HEIGHT TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-PANEL WS-LEFT WS-TOP WS-W WS-H
         WS-TEXT WS-LENGTH WS-STATE
*>   The title at (8, 6), centred in the image for the dispenser; the inventory label at (8, imageHeight - 94).
     MOVE SM-CX-TITLE TO WS-TEXT
     MOVE SM-CX-TITLE-LENGTH TO WS-LENGTH
     COMPUTE WS-X = WS-LEFT + 8
     IF WS-CENTRED = 1
         MOVE SM-CX-TITLE TO WS-TEXT256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-LENGTH WS-WIDTH
         COMPUTE WS-X = WS-LEFT + (176 - WS-WIDTH) / 2
     END-IF
     COMPUTE WS-Y = WS-TOP + 6
     MOVE WK-LABEL TO WS-KIND
     MOVE 0 TO WS-ARG
     MOVE 160 TO WS-C
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-C WS-LABEL-H
         WS-TEXT WS-LENGTH WS-STATE
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-LANG-TEXT WS-LANG-LENGTH
     IF WS-LANG-TEXT(1:WS-LANG-LENGTH) = WS-KEY(1:WS-KEY-LENGTH)
         MOVE "Inventory" TO WS-LANG-TEXT
         MOVE 9 TO WS-LANG-LENGTH
     END-IF
     COMPUTE WS-X = WS-LEFT + 8
     COMPUTE WS-Y = WS-TOP + WS-HEIGHT - 94
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-C WS-LABEL-H
         WS-LANG-TEXT WS-LANG-LENGTH WS-STATE
*>   The own slots, then the player's main inventory and hotbar.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-OWN
         CALL "CONTAINER-SLOT-POS" USING BM-TYPE WS-I WS-X WS-Y
         COMPUTE WS-ARG = 401 + WS-I
         COMPUTE WS-X = WS-LEFT + WS-X - 1
         COMPUTE WS-Y = WS-TOP + WS-Y - 1
         CALL "CONTAINER-SLOT-ADD" USING CLIENT-STATE WS-ARG WS-X WS-Y
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 35
         IF WS-I < 9
             MOVE WS-I TO WS-C
             COMPUTE WS-Y = WS-Y0 + 58
         ELSE
             COMPUTE WS-R = (WS-I - 9) / 9
             COMPUTE WS-C = WS-I - 9 - WS-R * 9
             COMPUTE WS-Y = WS-Y0 + WS-R * 18
         END-IF
         COMPUTE WS-X = WS-LEFT + 8 + WS-C * 18 - 1
         COMPUTE WS-Y = WS-TOP + WS-Y - 1
         CALL "CONTAINER-SLOT-ADD" USING CLIENT-STATE WS-I WS-X WS-Y
     END-PERFORM
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
