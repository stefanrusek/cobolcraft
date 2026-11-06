*> The inventory screen (US4-6; client-surface §3 E; data-model §4 Inventory; 08 §10.8.6
*> inventory title; 09 §3.2 Container Click 0x12, Set Creative Mode Slot 0x39): its title, the main
*> inventory (slots 9 to 35) in three rows of nine and the hotbar (slots 0 to 8) below them, each an
*> item slot widget that moves items when clicked, and the stack on the cursor drawn at the
*> pointer. INVENTORY-CLICK carries out a left click on a slot: the click is predicted on the
*> replica (INV-PICKUP), then sent, in survival as Container Click with the changed slot and the
*> cursor, in creative as Set Creative Mode Slot of the changed slot (the cursor is the client's).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.inventory.title".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 33.
 01 WS-ACTION              BINARY-LONG VALUE ACT-SLOT.
 01 WS-NONE                BINARY-LONG VALUE ACT-NONE.
 01 WS-CURSOR              BINARY-LONG VALUE 36.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-X0 = L-GW / 2 - 90
     COMPUTE WS-Y0 = L-GH / 2 - 43
     COMPUTE WS-Y = WS-Y0 - 14
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X0 WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 35
         IF WS-S < 9
             MOVE WS-S TO WS-C
             COMPUTE WS-Y = WS-Y0 + 3 * CL-SLOT-SIZE + 6
         ELSE
             COMPUTE WS-R = (WS-S - 9) / 9
             COMPUTE WS-C = WS-S - 9 - WS-R * 9
             COMPUTE WS-Y = WS-Y0 + WS-R * CL-SLOT-SIZE
         END-IF
         COMPUTE WS-X = WS-X0 + WS-C * CL-SLOT-SIZE
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-S WS-X WS-Y WS-ACTION
     END-PERFORM
     IF PL-CARRIED-COUNT > 0
         COMPUTE WS-X = IN-CURSOR-X / CL-GUI-SCALE - CL-SLOT-SIZE / 2
         COMPUTE WS-Y = IN-CURSOR-Y / CL-GUI-SCALE - CL-SLOT-SIZE / 2
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-CURSOR WS-X WS-Y WS-NONE
     END-IF
     GOBACK.
 END PROGRAM INVENTORY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-CLICK.
*> USING CLIENT-STATE, slot (0 to 35).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-SLOT TO WS-SLOT
     CALL "INV-PICKUP" USING CLIENT-STATE WS-SLOT
     CALL "PB-RESET" USING PB-BUFFER
     IF PL-MODE = 1
         CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER WS-SLOT PL-SLOT-COUNT(WS-SLOT + 1)
             PL-SLOT-ITEM(WS-SLOT + 1)
     ELSE
         CALL "CLP-CONTAINER-CLICK" USING PB-BUFFER PL-INV-STATE-ID WS-SLOT
             PL-SLOT-COUNT(WS-SLOT + 1) PL-SLOT-ITEM(WS-SLOT + 1) PL-CARRIED-COUNT
             PL-CARRIED-ITEM
     END-IF
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM INVENTORY-CLICK.
