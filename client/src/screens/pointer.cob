*> The container screen's pointer and keys (docs/protocol/40-menus-1-model-and-containers.md section 5.5; 3.4 click types): MENU-POINTER runs each frame on a
*> container screen (SCR-CONTAINER). The hovered slot is the slot widget under the pointer (an 18 x 18 cell around the item cell); the target of a click is its menu
*> slot, -999 outside the image and -1 in the image on no slot. A press with an empty cursor sends PICKUP (0) with the left button (predicted: INVENTORY-CLICK) or the
*> right (button 1, nothing predicted), QUICK_MOVE (1) with shift held, THROW (4) at -999, and in creative the middle button sends CLONE (3); the release of that click is
*> swallowed. A press with a carried stack starts a drag (type 0 with the left button, 1 with the right): each frame the held pointer adds the slot under it when the
*> carried count exceeds the slots already in the set and the slot is empty or holds the carried item; the release sends QUICK_CRAFT (5): slot -999 with button
*> 4 x type, each slot with 1 + 4 x type, slot -999 with 2 + 4 x type (a one-slot set too). A release with an empty set is a PICKUP (or QUICK_MOVE with shift) at the target
*> and outside the image drops the carried stack (left) or one item (right) as PICKUP at -999, nothing predicted. A second left press on the same slot within 250 ms makes
*> the release send PICKUP_ALL (6). With an empty cursor over a slot a hotbar key sends SWAP (2) with its number 0 to 8, the off-hand key button 40, and the drop key THROW
*> (4) with button 0 (Ctrl: 1) predicted as the slot emptied by one (the whole stack with Ctrl).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RESET.
*> USING CLIENT-STATE: no drag, no swallowed release, no previous click.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO CX-DRAG-ON CX-DRAG-BUTTON CX-DRAG-N CX-SKIP-RELEASE CX-PREV-MS CX-DOUBLE
     MOVE -2 TO CX-PREV-SLOT
     GOBACK.
 END PROGRAM CX-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-POINTER.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
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
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG.
 01 WS-CTRL                BINARY-LONG.
 01 WS-KEYC                BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-S-SLOT              BINARY-LONG.
 01 WS-S-BUTTON            BINARY-LONG.
 01 WS-S-TYPE              BINARY-LONG.
 01 WS-S-CHANGED           BINARY-LONG.
 01 WS-S-COUNT             BINARY-LONG.
 01 WS-S-ITEM              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-DUP                 BINARY-LONG.
 01 WS-ADD-WIRE            BINARY-LONG.
 01 WS-QUICK               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TOGGLE-MODE         BINARY-LONG VALUE 0.
 01 WS-TOGGLE-SWAP         BINARY-LONG VALUE 1.
 01 WS-S-BUTTON-40         BINARY-LONG VALUE 40.
 01 WS-NO-BUTTON           BINARY-LONG VALUE -1.
 01 WS-PICKUP              BINARY-LONG VALUE 0.
 01 WS-QUICK-MOVE          BINARY-LONG VALUE 1.
 01 WS-SWAP                BINARY-LONG VALUE 2.
 01 WS-CLONE               BINARY-LONG VALUE 3.
 01 WS-THROW               BINARY-LONG VALUE 4.
 01 WS-QUICK-CRAFT         BINARY-LONG VALUE 5.
 01 WS-PICKUP-ALL          BINARY-LONG VALUE 6.
 01 WS-OUTSIDE             BINARY-LONG VALUE -999.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     GO TO MAIN-FLOW.
*> The slot under the pointer (WS-ARG its widget argument, WS-WIRE its menu slot, -1 none) and the click target.
 FIND-TARGET.
     CALL "MENU-SLOT-AT" USING CLIENT-STATE WS-GX WS-GY WS-ARG
     MOVE -1 TO WS-WIRE
     IF WS-ARG >= 0
         CALL "MENU-SLOT-WIRE" USING CLIENT-STATE WS-ARG WS-WIRE
     END-IF
     MOVE WS-WIRE TO WS-TARGET
     IF WS-WIRE < 0
         MOVE -1 TO WS-TARGET
         IF WS-GX < WS-LEFT OR WS-GY < WS-TOP OR WS-GX >= WS-LEFT + WS-W OR WS-GY >= WS-TOP + WS-H
             MOVE WS-OUTSIDE TO WS-TARGET
         END-IF
     END-IF
     .

*> Container Click of WS-S-SLOT, WS-S-BUTTON, WS-S-TYPE, listing the slot with WS-S-COUNT and WS-S-ITEM when WS-S-CHANGED is 1, with the cursor as it is.
 CLICK-OUT.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MENU-CLICK-AS" USING PB-BUFFER WS-CONTAINER WS-STATE-ID WS-S-SLOT WS-S-BUTTON WS-S-TYPE
         WS-S-CHANGED WS-S-COUNT WS-S-ITEM PL-CARRIED-COUNT PL-CARRIED-ITEM
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     .

*> A click with nothing listed: slot WS-S-SLOT, button WS-S-BUTTON, type WS-S-TYPE.
 CLICK-PLAIN.
     MOVE 0 TO WS-S-CHANGED WS-S-COUNT WS-S-ITEM
     PERFORM CLICK-OUT
     .

 KEYS.
     IF WS-WIRE >= 0
         MOVE KB-CODE(KB-SWAP-OFFHAND) TO WS-KEYC
         IF IN-KEY-PRESSED(WS-KEYC + 1) = 1 AND PL-CARRIED-COUNT = 0
             CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-SWAP WS-S-BUTTON-40
             MOVE WS-WIRE TO WS-S-SLOT
             MOVE 40 TO WS-S-BUTTON
             MOVE WS-SWAP TO WS-S-TYPE
             PERFORM CLICK-PLAIN
         END-IF
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
             MOVE KB-CODE(KB-HOTBAR-1 + WS-I) TO WS-KEYC
             IF IN-KEY-PRESSED(WS-KEYC + 1) = 1 AND PL-CARRIED-COUNT = 0
                 CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-SWAP WS-I
                 MOVE WS-WIRE TO WS-S-SLOT
                 MOVE WS-I TO WS-S-BUTTON
                 MOVE WS-SWAP TO WS-S-TYPE
                 PERFORM CLICK-PLAIN
             END-IF
         END-PERFORM
         MOVE KB-CODE(KB-DROP) TO WS-KEYC
         IF IN-KEY-PRESSED(WS-KEYC + 1) = 1
             CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
             IF WS-COUNT > 0
                 MOVE 1 TO WS-S-COUNT
                 MOVE 0 TO WS-S-BUTTON
                 IF WS-CTRL = 1
                     MOVE WS-COUNT TO WS-S-COUNT
                     MOVE 1 TO WS-S-BUTTON
                 END-IF
                 COMPUTE WS-NEW = WS-COUNT - WS-S-COUNT
                 CALL "MENU-STACK-PUT" USING CLIENT-STATE WS-ARG WS-NEW WS-ITEM WS-DAMAGE
                 CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-S-COUNT WS-S-ITEM WS-DAMAGE
                 MOVE WS-WIRE TO WS-S-SLOT
                 MOVE WS-THROW TO WS-S-TYPE
                 MOVE 1 TO WS-S-CHANGED
                 PERFORM CLICK-OUT
             END-IF
         END-IF
     END-IF
     .

*> While a drag is held: the slot under the pointer joins the set (see the header).
 DRAG-ADD.
     IF CX-DRAG-ON = 1 AND PL-CARRIED-COUNT > 0 AND WS-WIRE >= 0 AND CX-DRAG-N < 64
             AND (IN-BUTTON-DOWN(CX-DRAG-BUTTON + 1) = 1 OR IN-BUTTON-RELEASED(CX-DRAG-BUTTON + 1) = 1)
             AND CX-DRAG-N < PL-CARRIED-COUNT
         CALL "MENU-STACK-GET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ITEM WS-DAMAGE
         MOVE 0 TO WS-DUP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CX-DRAG-N
             IF CX-DRAG-SLOT(WS-I) = WS-WIRE
                 MOVE 1 TO WS-DUP
             END-IF
         END-PERFORM
         IF WS-DUP = 0 AND (WS-COUNT = 0 OR WS-ITEM = PL-CARRIED-ITEM)
             ADD 1 TO CX-DRAG-N
             MOVE WS-WIRE TO CX-DRAG-SLOT(CX-DRAG-N)
         END-IF
     END-IF
     .

 PRESS.
     MOVE 0 TO CX-SKIP-RELEASE CX-DOUBLE
     IF WS-B = 0 AND WS-TARGET >= 0 AND WS-TARGET = CX-PREV-SLOT AND CL-NOW-MS - CX-PREV-MS < 250
         MOVE 1 TO CX-DOUBLE
     END-IF
     MOVE FUNCTION MIN(WS-B, 1) TO WS-C
     EVALUATE TRUE
         WHEN WS-B = 2
             IF PL-MODE = 1 AND PL-CARRIED-COUNT = 0 AND WS-WIRE >= 0
                 MOVE WS-WIRE TO WS-S-SLOT
                 MOVE 0 TO WS-S-BUTTON
                 MOVE WS-CLONE TO WS-S-TYPE
                 PERFORM CLICK-PLAIN
                 MOVE 1 TO CX-SKIP-RELEASE
             END-IF
         WHEN WS-TARGET = -1 OR CX-DRAG-ON = 1
             CONTINUE
         WHEN PL-CARRIED-COUNT > 0
             MOVE 1 TO CX-DRAG-ON
             MOVE WS-B TO CX-DRAG-BUTTON
             MOVE 0 TO CX-DRAG-N
         WHEN OTHER
             PERFORM EMPTY-CURSOR-CLICK
             MOVE 1 TO CX-SKIP-RELEASE
     END-EVALUATE
     MOVE WS-TARGET TO CX-PREV-SLOT
     MOVE CL-NOW-MS TO CX-PREV-MS
     .

*> The click of an empty cursor on the target: QUICK_MOVE with shift, THROW outside, PICKUP otherwise.
 EMPTY-CURSOR-CLICK.
     MOVE WS-TARGET TO WS-S-SLOT
     MOVE WS-C TO WS-S-BUTTON
     EVALUATE TRUE
         WHEN WS-SHIFT = 1 AND WS-TARGET NOT = WS-OUTSIDE
             MOVE WS-QUICK-MOVE TO WS-S-TYPE
             PERFORM CLICK-PLAIN
         WHEN WS-TARGET = WS-OUTSIDE
             MOVE WS-THROW TO WS-S-TYPE
             PERFORM CLICK-PLAIN
         WHEN WS-B = 0
             CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-MODE WS-NO-BUTTON
             CALL "INVENTORY-CLICK" USING CLIENT-STATE WS-ARG
         WHEN OTHER
             CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-MODE WS-NO-BUTTON
             MOVE WS-PICKUP TO WS-S-TYPE
             PERFORM CLICK-PLAIN
     END-EVALUATE
     .

 LET-GO.
     EVALUATE TRUE
         WHEN CX-DOUBLE = 1 AND WS-B = 0 AND WS-WIRE >= 0
             MOVE WS-WIRE TO WS-S-SLOT
             MOVE 0 TO WS-S-BUTTON
             MOVE WS-PICKUP-ALL TO WS-S-TYPE
             PERFORM CLICK-PLAIN
             MOVE 0 TO CX-DOUBLE CX-DRAG-ON
         WHEN CX-DRAG-ON = 1 AND WS-B NOT = CX-DRAG-BUTTON
             MOVE 0 TO CX-DRAG-ON
             MOVE 1 TO CX-SKIP-RELEASE
         WHEN CX-SKIP-RELEASE = 1
             MOVE 0 TO CX-SKIP-RELEASE
         WHEN CX-DRAG-ON = 1 AND CX-DRAG-N > 0
             PERFORM CLICK-DRAG
             MOVE 0 TO CX-DRAG-ON
         WHEN PL-CARRIED-COUNT > 0 AND WS-TARGET NOT = -1
             MOVE 0 TO CX-DRAG-ON
             MOVE FUNCTION MIN(WS-B, 1) TO WS-C
             PERFORM CARRIED-CLICK
         WHEN OTHER
             MOVE 0 TO CX-DRAG-ON
     END-EVALUATE
     .

*> The release of a click that carries a stack, on the target.
 CARRIED-CLICK.
     MOVE WS-TARGET TO WS-S-SLOT
     MOVE WS-C TO WS-S-BUTTON
     EVALUATE TRUE
         WHEN WS-SHIFT = 1 AND WS-TARGET NOT = WS-OUTSIDE
             MOVE WS-QUICK-MOVE TO WS-S-TYPE
             PERFORM CLICK-PLAIN
         WHEN WS-TARGET = WS-OUTSIDE
             MOVE WS-PICKUP TO WS-S-TYPE
             IF WS-B = 0
                 MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
             ELSE
                 SUBTRACT 1 FROM PL-CARRIED-COUNT
                 IF PL-CARRIED-COUNT = 0
                     MOVE 0 TO PL-CARRIED-ITEM
                 END-IF
             END-IF
             PERFORM CLICK-PLAIN
         WHEN WS-B = 0
             CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-MODE WS-NO-BUTTON
             CALL "INVENTORY-CLICK" USING CLIENT-STATE WS-ARG
         WHEN OTHER
             CALL "CRAFTER-TOGGLE" USING CLIENT-STATE WS-WIRE WS-TOGGLE-MODE WS-NO-BUTTON
             MOVE WS-PICKUP TO WS-S-TYPE
             PERFORM CLICK-PLAIN
     END-EVALUATE
     .

*> Three kinds of QUICK_CRAFT packets: start, each slot of the set, end (the masks of 3.4: header + 4 x type).
 CLICK-DRAG.
     COMPUTE WS-HELD = 4 * CX-DRAG-BUTTON
     MOVE WS-OUTSIDE TO WS-S-SLOT
     MOVE WS-HELD TO WS-S-BUTTON
     MOVE WS-QUICK-CRAFT TO WS-S-TYPE
     PERFORM CLICK-PLAIN
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CX-DRAG-N
         MOVE CX-DRAG-SLOT(WS-J) TO WS-S-SLOT
         COMPUTE WS-S-BUTTON = WS-HELD + 1
         PERFORM CLICK-PLAIN
     END-PERFORM
     MOVE WS-OUTSIDE TO WS-S-SLOT
     COMPUTE WS-S-BUTTON = WS-HELD + 2
     PERFORM CLICK-PLAIN
     .

 MAIN-FLOW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "MENU-CONTAINER" USING CLIENT-STATE WS-CONTAINER WS-STATE-ID
     CALL "CONTAINER-FRAME" USING BM-TYPE WS-OWN WS-TAIL WS-IX WS-IY WS-W WS-H WS-TX WS-TY WS-LX WS-LY
         WS-DATA WS-KNOWN
     COMPUTE WS-GW = FUNCTION MAX(IN-WIN-W / CL-GUI-SCALE, CL-MIN-GUI-W)
     COMPUTE WS-GH = FUNCTION MAX(IN-WIN-H / CL-GUI-SCALE, CL-MIN-GUI-H)
     COMPUTE WS-LEFT = (WS-GW - WS-W) / 2
     COMPUTE WS-TOP = (WS-GH - WS-H) / 2
     COMPUTE WS-GX = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE WS-GY = IN-CURSOR-Y / CL-GUI-SCALE
     COMPUTE WS-SHIFT = FUNCTION MOD(IN-MODS, 2)
     COMPUTE WS-CTRL = FUNCTION MOD(IN-MODS / CC-MOD-CONTROL, 2)
     PERFORM FIND-TARGET
     PERFORM KEYS
     PERFORM DRAG-ADD
     PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 2
         IF IN-BUTTON-PRESSED(WS-B + 1) = 1
             PERFORM PRESS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 1
         IF IN-BUTTON-RELEASED(WS-B + 1) = 1
             PERFORM LET-GO
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-POINTER.
