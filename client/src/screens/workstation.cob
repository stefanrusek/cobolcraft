*> The workstation screens' own drawing and clicks (docs/protocol/40-menus-2-furnaces-brewing-crafter.md sections 3, 5, 7; 40-menus-3 and 40-menus-4 as noted): MENU-DECOR adds
*> the progress pictures a menu type has to the container screen, from the menu's data slots (BM-DATA). The sprites (flame, arrows, bubbles, bars, error icons, the crafter's
*> disabled slot and indicator) are not in the built-in pack (builtin-ui-art.md does not list the container sprites of the workstations), so each is a panel fallback: a WK-OVERLAY
*> rectangle of the sprite's drawn size at its place. CRAFTER-TOGGLE is the crafter's slot toggle (7.2) and CLP-SLOT-STATE builds Container Slot State Changed (05c 0x14).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DECOR.
*> USING CLIENT-STATE, left, top, GUI width, GUI height: the overlays of the open menu type, in drawing order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-OVERLAY.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-CAN-ERROR           BINARY-LONG.
 01 WS-LABEL               BINARY-LONG VALUE WK-LABEL.
 01 WS-PRESS               BINARY-LONG.
 01 WS-IMAGE               BINARY-LONG.
 01 WS-LINE                PIC X(256).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-LINE-WIDTH          BINARY-LONG.
 01 WS-COST                PIC Z(8)9.
 01 WS-RGB                 BINARY-LONG.
 COPY CLARGS.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-LABEL-W             BINARY-LONG VALUE 160.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 01 WS-ICON-W              BINARY-LONG VALUE 28.
 01 WS-ICON-H              BINARY-LONG VALUE 21.
 01 WS-BOX-H               BINARY-LONG VALUE 12.
 01 WS-SLOT-X              BINARY-LONG.
 01 WS-SLOT-Y              BINARY-LONG.
 01 WS-BUBBLES             PIC X(14) VALUE "29242016110600".
 01 WS-BUBBLE-TABLE REDEFINES WS-BUBBLES.
    05 WS-BUBBLE           PIC 99 OCCURS 7 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LEFT                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LEFT L-TOP L-GW L-GH.
     MOVE SPACES TO WS-TEXT
     EVALUATE TRUE
         WHEN BM-TYPE = 10 OR BM-TYPE = 14 OR BM-TYPE = 22
*>           3.2: the flame, the bottom h = ceil(lit x 13) + 1 rows of the 14 x 14 sprite while data 0 > 0; the arrow, ceil(progress x 24) columns of 24 x 16.
             IF BM-DATA(1) > 0
                 MOVE BM-DATA(2) TO WS-D
                 IF WS-D <= 0
                     MOVE 200 TO WS-D
                 END-IF
                 COMPUTE WS-P = FUNCTION MIN(BM-DATA(1), WS-D)
                 COMPUTE WS-H = (13 * WS-P + WS-D - 1) / WS-D + 1
                 COMPUTE WS-X = L-LEFT + 56
                 COMPUTE WS-Y = L-TOP + 36 + 14 - WS-H
                 MOVE 14 TO WS-W
                 MOVE SW-BAR-0 TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
             IF BM-DATA(3) > 0 AND BM-DATA(4) > 0
                 COMPUTE WS-P = FUNCTION MIN(BM-DATA(3), BM-DATA(4))
                 COMPUTE WS-W = (24 * WS-P + BM-DATA(4) - 1) / BM-DATA(4)
                 COMPUTE WS-X = L-LEFT + 79
                 COMPUTE WS-Y = L-TOP + 34
                 MOVE 16 TO WS-H
                 MOVE SW-WHITE TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
         WHEN BM-TYPE = 11
*>           5: the fuel bar ceilDiv(18 f, T) of 18 x 4, then (while a brew runs) the arrow trunc(28 (1 - b / B)) rows of 9 x 28 and the bubbles.
             IF BM-DATA(4) > 0 AND BM-DATA(2) > 0
                 COMPUTE WS-W = FUNCTION MIN((18 * BM-DATA(2) + BM-DATA(4) - 1) / BM-DATA(4), 18)
                 COMPUTE WS-X = L-LEFT + 60
                 COMPUTE WS-Y = L-TOP + 44
                 MOVE 4 TO WS-H
                 MOVE SW-WHITE TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
             IF BM-DATA(1) > 0 AND BM-DATA(3) > 0
                 COMPUTE WS-H = 28 * (BM-DATA(3) - BM-DATA(1)) / BM-DATA(3)
                 IF WS-H > 0
                     COMPUTE WS-X = L-LEFT + 97
                     COMPUTE WS-Y = L-TOP + 16
                     MOVE 9 TO WS-W
                     MOVE SW-WHITE TO WS-SWATCH
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                         WS-TEXT WS-LENGTH WS-STATE
                 END-IF
                 COMPUTE WS-D = BM-DATA(1) / 2
                 COMPUTE WS-IDX = FUNCTION MOD(WS-D, 7) + 1
                 MOVE WS-BUBBLE(WS-IDX) TO WS-H
                 IF WS-H > 0
                     COMPUTE WS-X = L-LEFT + 63
                     COMPUTE WS-Y = L-TOP + 14 + 29 - WS-H
                     MOVE 12 TO WS-W
                     COMPUTE WS-SWATCH = SW-BAR-0 + 23
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                         WS-TEXT WS-LENGTH WS-STATE
                 END-IF
             END-IF
         WHEN BM-TYPE = 8 OR BM-TYPE = 15
*>           3.8 the anvil's name field: the background 110 x 16 at (59, 20) (black when slot 0 has an item, else the panel colour of the disabled sprite) and, when editable,
*>           the text at (62, 24).
             IF BM-TYPE = 8
                 COMPUTE WS-X = L-LEFT + 59
                 COMPUTE WS-Y = L-TOP + 20
                 MOVE 110 TO WS-W
                 MOVE 16 TO WS-H
                 MOVE SW-PANEL TO WS-SWATCH
                 IF BX-COUNT(1) > 0
                     MOVE SW-BLACK TO WS-SWATCH
                 END-IF
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
                 IF BX-COUNT(1) > 0 AND AN-NAME-LENGTH > 0 AND AN-ID = BM-ID
                     MOVE AN-NAME TO WS-TEXT
                     COMPUTE WS-X = L-LEFT + 62
                     COMPUTE WS-Y = L-TOP + 24
                     MOVE 0 TO WS-SWATCH
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-ACTION WS-SWATCH WS-X WS-Y WS-LABEL-W WS-LABEL-H
                         WS-TEXT AN-NAME-LENGTH WS-STATE
                 END-IF
             END-IF
*>           The error icon (28 x 21): an input item and no result; the anvil (99, 45), the grindstone (92, 31).
             MOVE 0 TO WS-CAN-ERROR
             IF (BX-COUNT(1) > 0 OR BX-COUNT(2) > 0) AND BX-COUNT(3) = 0
                 MOVE 1 TO WS-CAN-ERROR
             END-IF
             IF WS-CAN-ERROR = 1
                 COMPUTE WS-X = L-LEFT + 99
                 COMPUTE WS-Y = L-TOP + 45
                 IF BM-TYPE = 15
                     COMPUTE WS-X = L-LEFT + 92
                     COMPUTE WS-Y = L-TOP + 31
                 END-IF
                 MOVE SW-HURT TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-ICON-W WS-ICON-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
*>           3.8 the anvil's cost: nothing for cost <= 0, "Too Expensive!" from 40 without infinite materials, nothing without a result, else the cost.
             MOVE SPACES TO WS-LINE
             MOVE 0 TO WS-LINE-LENGTH
             EVALUATE TRUE
                 WHEN BM-TYPE NOT = 8 OR BM-DATA(1) <= 0
                     CONTINUE
                 WHEN BM-DATA(1) >= 40 AND PL-MODE NOT = 1
                     MOVE "container.repair.expensive" TO WS-KEY
                     MOVE 26 TO WS-KEY-LENGTH
                     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
                     MOVE WS-OUT(1:WS-OUT-LENGTH) TO WS-LINE
                     MOVE WS-OUT-LENGTH TO WS-LINE-LENGTH
                 WHEN BX-COUNT(3) > 0
                     MOVE BM-DATA(1) TO WS-COST
                     MOVE 1 TO LA-COUNT
                     MOVE FUNCTION TRIM(WS-COST) TO LA-TEXT(1)
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-COST)) TO LA-LENGTH(1)
                     MOVE "container.repair.cost" TO WS-KEY
                     MOVE 21 TO WS-KEY-LENGTH
                     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-OUT WS-OUT-LENGTH
                     MOVE WS-OUT(1:WS-OUT-LENGTH) TO WS-LINE
                     MOVE WS-OUT-LENGTH TO WS-LINE-LENGTH
             END-EVALUATE
             IF WS-LINE-LENGTH > 0
                 CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-LINE WS-LINE-LENGTH WS-LINE-WIDTH
                 COMPUTE WS-X = L-LEFT + 166 - WS-LINE-WIDTH - 2
                 COMPUTE WS-Y = L-TOP + 67
                 COMPUTE WS-W = WS-LINE-WIDTH + 4
                 MOVE SW-BLACK TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-BOX-H
                     WS-TEXT WS-LENGTH WS-STATE
                 MOVE WS-LINE TO WS-TEXT
                 COMPUTE WS-X = L-LEFT + 166 - WS-LINE-WIDTH
                 COMPUTE WS-Y = L-TOP + 69
                 MOVE 0 TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-ACTION WS-SWATCH WS-X WS-Y WS-LABEL-W WS-LABEL-H
                     WS-TEXT WS-LINE-LENGTH WS-STATE
*>               Green #80FF20, red #FF6060 for "Too Expensive!" and when the player's level is under the cost (no infinite materials).
                 MOVE 8453920 TO WS-RGB
                 IF BM-DATA(1) >= 40 OR (PL-XP-LEVEL < BM-DATA(1) AND PL-MODE NOT = 1)
                     MOVE 16736352 TO WS-RGB
                 END-IF
                 CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
             END-IF
         WHEN BM-TYPE = 13
*>           2.9: the three option rows (108 x 19 at (60, 14 + 19 i)), the cost right-aligned to x 166 at y 23 + 19 i, and for an enabled row the click area (button i).
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
                 COMPUTE WS-X = L-LEFT + 60
                 COMPUTE WS-Y = L-TOP + 14 + 19 * WS-I
                 MOVE 108 TO WS-W
                 MOVE 19 TO WS-H
                 MOVE SW-PANEL TO WS-SWATCH
                 MOVE 0 TO WS-CAN-ERROR
                 IF BM-DATA(WS-I + 1) > 0 AND ((BX-COUNT(2) >= WS-I + 1 AND PL-XP-LEVEL >= BM-DATA(WS-I + 1)) OR PL-MODE = 1)
                     MOVE 1 TO WS-CAN-ERROR
                     MOVE SW-BUTTON TO WS-SWATCH
                 END-IF
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                     WS-TEXT WS-LENGTH WS-STATE
                 IF BM-DATA(WS-I + 1) > 0
                     MOVE BM-DATA(WS-I + 1) TO WS-COST
                     MOVE SPACES TO WS-LINE
                     MOVE FUNCTION TRIM(WS-COST) TO WS-LINE
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-COST)) TO WS-LINE-LENGTH
                     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-LINE WS-LINE-LENGTH WS-LINE-WIDTH
                     MOVE WS-LINE TO WS-TEXT
                     COMPUTE WS-X = L-LEFT + 166 - WS-LINE-WIDTH
                     COMPUTE WS-Y = L-TOP + 23 + 19 * WS-I
                     MOVE 0 TO WS-SWATCH
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-ACTION WS-SWATCH WS-X WS-Y WS-LABEL-W WS-LABEL-H
                         WS-TEXT WS-LINE-LENGTH WS-STATE
*>                   The cost number: #80FF20 on an enabled row, #407F10 on a disabled one (40-4 2.9).
                     MOVE 4226832 TO WS-RGB
                     IF WS-CAN-ERROR = 1
                         MOVE 8453920 TO WS-RGB
                     END-IF
                     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
                     MOVE SPACES TO WS-TEXT
                 END-IF
                 IF WS-CAN-ERROR = 1
                     COMPUTE WS-X = L-LEFT + 60
                     COMPUTE WS-Y = L-TOP + 14 + 19 * WS-I
                     MOVE ACT-MENU-BUTTON TO WS-PRESS
                     MOVE WK-IMAGE TO WS-IMAGE
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-IMAGE WS-PRESS WS-I WS-X WS-Y WS-W WS-H
                         WS-TEXT WS-LENGTH WS-STATE
                 END-IF
             END-PERFORM
         WHEN BM-TYPE = 21
*>           5.5 the smithing error icon at (65, 46) while the error flag (data 0) is 1.
             IF BM-DATA(1) = 1
                 COMPUTE WS-X = L-LEFT + 65
                 COMPUTE WS-Y = L-TOP + 46
                 MOVE SW-HURT TO WS-SWATCH
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-ICON-W WS-ICON-H
                     WS-TEXT WS-LENGTH WS-STATE
             END-IF
         WHEN BM-TYPE = 19
             CALL "MERCHANT-DECOR" USING CLIENT-STATE L-LEFT L-TOP
         WHEN BM-TYPE = 9
             CALL "BEACON-DECOR" USING CLIENT-STATE L-LEFT L-TOP
         WHEN BM-TYPE = 17
             CALL "LECTERN-DECOR" USING CLIENT-STATE L-GW
         WHEN BM-TYPE = 7
*>           7.3: a disabled crafting slot (data i = 1) is the 18 x 18 disabled-slot sprite at the slot widget; the indicator 16 x 16 at (GW / 2 + 9, GH / 2 - 48).
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
                 IF BM-DATA(WS-I + 1) = 1
                     CALL "CONTAINER-SLOT-POS" USING BM-TYPE WS-I WS-SLOT-X WS-SLOT-Y
                     COMPUTE WS-X = L-LEFT + WS-SLOT-X - 1
                     COMPUTE WS-Y = L-TOP + WS-SLOT-Y - 1
                     MOVE 18 TO WS-W WS-H
                     MOVE SW-BLACK TO WS-SWATCH
                     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                         WS-TEXT WS-LENGTH WS-STATE
                 END-IF
             END-PERFORM
             COMPUTE WS-X = L-GW / 2 + 9
             COMPUTE WS-Y = L-GH / 2 - 48
             MOVE 16 TO WS-W WS-H
             MOVE SW-BAR-0 TO WS-SWATCH
             IF BM-DATA(10) = 1
                 COMPUTE WS-SWATCH = SW-BAR-0 + 23
             END-IF
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H
                 WS-TEXT WS-LENGTH WS-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM MENU-DECOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-SLOT-STATE.
*> USING PB-BUFFER, slot id, container id, new state (1 enabled, 0 disabled): Container Slot State Changed (05c 0x14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLOT                 BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SLOT L-CONTAINER L-STATE.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-STATE
     GOBACK.
 END PROGRAM CLP-SLOT-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFTER-TOGGLE.
*> USING CLIENT-STATE, menu slot, mode (0 an ordinary PICKUP click, 1 a SWAP), button (the SWAP's): on an empty crafting slot (0 to 8) of the crafter (type 7) an
*> ordinary click enables a disabled slot and disables an enabled one while the cursor is empty; a SWAP enables a disabled slot when the inventory stack at the button
*> (0 to 8 hotbar, 40 off hand) is not empty; the data slot changes at once and Container Slot State Changed is sent (7.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-MODE L-BUTTON.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE -1 TO WS-NEW
     IF BM-TYPE = 7 AND L-SLOT >= 0 AND L-SLOT < 9 AND BX-COUNT(L-SLOT + 1) = 0
         MOVE 0 TO WS-HAS
         EVALUATE TRUE
             WHEN L-BUTTON >= 0 AND L-BUTTON <= 8
                 IF PL-SLOT-COUNT(L-BUTTON + 1) > 0
                     MOVE 1 TO WS-HAS
                 END-IF
             WHEN L-BUTTON = 40
                 IF PL-OFFHAND-COUNT > 0
                     MOVE 1 TO WS-HAS
                 END-IF
         END-EVALUATE
         EVALUATE TRUE
             WHEN L-MODE = 0 AND BM-DATA(L-SLOT + 1) = 1
                 MOVE 1 TO WS-NEW
             WHEN L-MODE = 0 AND PL-CARRIED-COUNT = 0
                 MOVE 0 TO WS-NEW
             WHEN L-MODE = 1 AND BM-DATA(L-SLOT + 1) = 1 AND WS-HAS = 1
                 MOVE 1 TO WS-NEW
         END-EVALUATE
     END-IF
     IF WS-NEW >= 0
         COMPUTE BM-DATA(L-SLOT + 1) = 1 - WS-NEW
         CALL "MENU-CONTAINER" USING CLIENT-STATE WS-CONTAINER WS-STATE-ID
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-SLOT-STATE" USING PB-BUFFER L-SLOT WS-CONTAINER WS-NEW
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CRAFTER-TOGGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-BUTTON-CLICK.
*> USING PB-BUFFER, container id, button id: Container Button Click (05c 0x11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 17.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CONTAINER            BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-CONTAINER L-BUTTON.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-BUTTON
     GOBACK.
 END PROGRAM CLP-BUTTON-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BUTTON-CLICK.
*> USING CLIENT-STATE, button id: sends Container Button Click of the open container.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BUTTON.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "MENU-CONTAINER" USING CLIENT-STATE WS-CONTAINER WS-STATE-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-BUTTON-CLICK" USING PB-BUFFER WS-CONTAINER L-BUTTON
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM MENU-BUTTON-CLICK.
