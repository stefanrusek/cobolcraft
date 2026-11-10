*> The inventory screen (US4-6; client-surface §3 E; data-model §4 Inventory; 08 §10.8.6
*> inventory title; 09 §3.2 Container Click 0x12, Set Creative Mode Slot 0x39): its title, the main
*> inventory (slots 9 to 35) in three rows of nine and the hotbar (slots 0 to 8) below them, each an
*> item slot widget that moves items when clicked, and the stack on the cursor drawn at the
*> pointer. INVENTORY-CLICK carries out a left click on a slot: the click is predicted on the
*> replica (INV-PICKUP), then sent, in survival as Container Click with the changed slot and the
*> cursor, in creative as Set Creative Mode Slot of the changed slot (the cursor is the client's).
*> INVENTORY-INPUT (each frame on this screen, in play) does the throws of standin §9.1
*> (client-surface §3): Q over a slot sends Container Click THROW (4) button 0, Ctrl+Q button 1,
*> with the slot's predicted stack; a left (or right) button released outside the window while a
*> stack is carried, which ends a click there or a drag out of it, sends PICKUP (0) at slot -999
*> button 0 (1), the whole carried stack (one item) predicted gone. The window is the screen's
*> title row, three main rows and the hotbar row: x0 to x0 + 9 slots, y0 - 14 to y0 + 4 slots + 6.
*> INVENTORY-CLOSE (when the screen is left, in play) puts the carried stack back into the slots
*> as the server's INV-ADD does (stacks of its item first, then empty slots; the rest is thrown
*> by the server), in creative sends Set Creative Mode Slot of each slot it went to, and sends
*> Container Close.

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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-THROW               BINARY-LONG VALUE 4.
 01 WS-KEYC                BINARY-LONG.
 01 WS-PICKUP              BINARY-LONG VALUE 0.
 01 WS-CHANGED             BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-NONE3               BINARY-LONG VALUE 0.
 01 WS-OUTSIDE             BINARY-LONG VALUE -999.
 01 WS-INSIDE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-X = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-Y = IN-CURSOR-Y / CL-GUI-SCALE
*>   Q over a slot (the slot widget under the cursor) holding a stack.
     MOVE KB-CODE(KB-DROP) TO WS-KEYC
     IF IN-KEY-PRESSED(WS-KEYC + 1) = 1
         MOVE -1 TO WS-SLOT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) <= 35
                     AND WS-X >= SM-W-X(WS-I) AND WS-X < SM-W-X(WS-I) + SM-W-W(WS-I)
                     AND WS-Y >= SM-W-Y(WS-I) AND WS-Y < SM-W-Y(WS-I) + SM-W-H(WS-I)
                 MOVE SM-W-ARG(WS-I) TO WS-SLOT
             END-IF
         END-PERFORM
         IF WS-SLOT >= 0 AND PL-SLOT-COUNT(WS-SLOT + 1) > 0
             COMPUTE WS-MODS = IN-MODS / CC-MOD-CONTROL
             MOVE 1 TO WS-COUNT
             MOVE 0 TO WS-BUTTON
             IF FUNCTION MOD(WS-MODS, 2) = 1
                 MOVE PL-SLOT-COUNT(WS-SLOT + 1) TO WS-COUNT
                 MOVE 1 TO WS-BUTTON
             END-IF
             SUBTRACT WS-COUNT FROM PL-SLOT-COUNT(WS-SLOT + 1)
             IF PL-SLOT-COUNT(WS-SLOT + 1) = 0
                 MOVE 0 TO PL-SLOT-ITEM(WS-SLOT + 1)
             END-IF
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CLP-CONTAINER-CLICK-AS" USING PB-BUFFER PL-INV-STATE-ID WS-SLOT WS-BUTTON
                 WS-THROW WS-CHANGED PL-SLOT-COUNT(WS-SLOT + 1) PL-SLOT-ITEM(WS-SLOT + 1)
                 PL-CARRIED-COUNT PL-CARRIED-ITEM
             CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
         END-IF
     END-IF
*>   A button released outside the window while carrying.
     IF PL-CARRIED-COUNT > 0
             AND (IN-BUTTON-RELEASED(CC-BUTTON-LEFT + 1) = 1
             OR IN-BUTTON-RELEASED(CC-BUTTON-RIGHT + 1) = 1)
         COMPUTE WS-X0 = IN-WIN-W / CL-GUI-SCALE / 2 - 90
         COMPUTE WS-Y0 = IN-WIN-H / CL-GUI-SCALE / 2 - 43
         MOVE 0 TO WS-INSIDE
         IF WS-X >= WS-X0 AND WS-X < WS-X0 + 9 * CL-SLOT-SIZE
                 AND WS-Y >= WS-Y0 - 14 AND WS-Y < WS-Y0 + 4 * CL-SLOT-SIZE + 6
             MOVE 1 TO WS-INSIDE
         END-IF
         IF WS-INSIDE = 0
             MOVE 0 TO WS-BUTTON
             MOVE PL-CARRIED-COUNT TO WS-COUNT
             IF IN-BUTTON-RELEASED(CC-BUTTON-LEFT + 1) = 0
                 MOVE 1 TO WS-BUTTON WS-COUNT
             END-IF
             SUBTRACT WS-COUNT FROM PL-CARRIED-COUNT
             IF PL-CARRIED-COUNT = 0
                 MOVE 0 TO PL-CARRIED-ITEM
             END-IF
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CLP-CONTAINER-CLICK-AS" USING PB-BUFFER PL-INV-STATE-ID WS-OUTSIDE WS-BUTTON
                 WS-PICKUP WS-NONE WS-NONE2 WS-NONE3 PL-CARRIED-COUNT PL-CARRIED-ITEM
             CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM INVENTORY-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. INVENTORY-CLOSE.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-PASS                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CL-IT-MAX(PL-CARRIED-ITEM + 1) TO WS-MAX
*>   Pass 1: stacks of the carried item below the maximum; pass 2: empty slots.
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR PL-CARRIED-COUNT = 0
             MOVE 0 TO WS-N
             IF WS-PASS = 1 AND PL-SLOT-COUNT(WS-S) > 0
                     AND PL-SLOT-ITEM(WS-S) = PL-CARRIED-ITEM
                 COMPUTE WS-N = FUNCTION MIN(PL-CARRIED-COUNT, WS-MAX - PL-SLOT-COUNT(WS-S))
             END-IF
             IF WS-PASS = 2 AND PL-SLOT-COUNT(WS-S) = 0
                 COMPUTE WS-N = FUNCTION MIN(PL-CARRIED-COUNT, WS-MAX)
             END-IF
             IF WS-N > 0
                 MOVE PL-CARRIED-ITEM TO PL-SLOT-ITEM(WS-S)
                 ADD WS-N TO PL-SLOT-COUNT(WS-S)
                 SUBTRACT WS-N FROM PL-CARRIED-COUNT
                 COMPUTE WS-SLOT = WS-S - 1
                 IF PL-MODE = 1
                     CALL "PB-RESET" USING PB-BUFFER
                     CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER WS-SLOT PL-SLOT-COUNT(WS-S)
                         PL-SLOT-ITEM(WS-S)
                     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CONTAINER-CLOSE" USING PB-BUFFER
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM INVENTORY-CLOSE.
