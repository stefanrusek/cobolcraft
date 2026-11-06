*> The break, place, use and hotbar controls (US4; client-surface §3; standin-content §1.1 break
*> times, §1.3 use rules, §2 tools; docs/protocol/09-cobolcraft-profile.md §3.2 Player Action
*> 0x29, Use Item On 0x42, Set Carried Item 0x36). Every Player Action and Use Item On carries the
*> next block-change sequence number (CT-SEQUENCE, from 1).
*>   CONTROLS-INPUT (world screen, in play), on the target of RAYCAST:
*>   - the right button pressed sends Use Item On with the target, its face and the hit point when
*>     the held stack is a block item, or the target is a glowtube (toggle) or a goto_pad (travel);
*>     otherwise nothing (the server would place nothing);
*>   - the left button pressed sends start destroy. In creative the break is instant: nothing more.
*>     In survival the break lasts the block's hand break time (a quarter of it with the tool of
*>     the block's class; never for baseplate): stop destroy follows once it has passed while the
*>     button is held on the same block, abort destroy when the button is released or the target
*>     changes first. While the button stays held after a finished break, the next block aimed at
*>     (the one behind, once the server has broken this one) is started without a new press.
*>   CONTROLS-HOTBAR (world and inventory screens): keys 1 to 9 hold hotbar slot 0 to 8, the wheel
*>   moves the held slot (up: the previous slot, down: the next, wrapping); a change is sent.
*>   CONTROLS-THROW (world screen; US5-3; standin-content §9.1; 09 §3.3 Player Action actions 5
*>   and 4): Q pressed sends drop item (one item of the held slot), with Control held (the modifier
*>   bits of the frame's last key event) drop all items (the whole stack); nothing while the held
*>   slot is empty. The server throws and sends the inventory change.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-ITEM                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
     END-IF
     MOVE 0 TO WS-STATE
     IF TG-HIT = 1
         CALL "WORLD-CELL" USING CLIENT-STATE TG-X TG-Y TG-Z WS-STATE WS-SKY WS-BLOCK
     END-IF
*>   Use: a block item placed against the face, a glowtube toggled, a goto_pad used.
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND TG-HIT = 1
             AND (CL-IT-STATE(WS-ITEM + 1) > 0 OR WS-STATE = 13 OR WS-STATE = 14
             OR WS-STATE = 16)
         CALL "CONTROLS-SEND-USE" USING CLIENT-STATE
     END-IF
*>   A survival break in progress: aborted, or finished once its time has passed.
     MOVE 0 TO WS-SAME
     IF TG-HIT = 1 AND TG-X = CT-BREAK-X AND TG-Y = CT-BREAK-Y AND TG-Z = CT-BREAK-Z
         MOVE 1 TO WS-SAME
     END-IF
     EVALUATE TRUE
         WHEN CT-BREAKING = 1 AND (IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 0 OR WS-SAME = 0)
             MOVE 2 TO WS-ACTION
             CALL "CONTROLS-SEND-ACTION" USING CLIENT-STATE WS-ACTION
             MOVE 0 TO CT-BREAKING
         WHEN CT-BREAKING = 1 AND CT-BREAK-MS >= 0
                 AND CL-NOW-MS - CT-BREAK-START >= CT-BREAK-MS
             MOVE 3 TO WS-ACTION
             CALL "CONTROLS-SEND-ACTION" USING CLIENT-STATE WS-ACTION
             MOVE 0 TO CT-BREAKING
             MOVE 1 TO CT-DONE
             MOVE CT-BREAK-X TO CT-DONE-X
             MOVE CT-BREAK-Y TO CT-DONE-Y
             MOVE CT-BREAK-Z TO CT-DONE-Z
     END-EVALUATE
     IF IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 0
         MOVE 0 TO CT-DONE
     END-IF
*>   A new break: on a press, or (survival) held onto a block other than the one just finished.
     MOVE 0 TO WS-DONE
     IF CT-DONE = 1 AND TG-X = CT-DONE-X AND TG-Y = CT-DONE-Y AND TG-Z = CT-DONE-Z
         MOVE 1 TO WS-DONE
     END-IF
     MOVE 0 TO WS-START
     IF CT-BREAKING = 0 AND TG-HIT = 1 AND IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 1
             AND (IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1 OR (PL-MODE NOT = 1 AND WS-DONE = 0))
         MOVE 1 TO WS-START
     END-IF
     IF WS-START = 1
         MOVE TG-X TO CT-BREAK-X
         MOVE TG-Y TO CT-BREAK-Y
         MOVE TG-Z TO CT-BREAK-Z
         MOVE TG-FACE TO CT-BREAK-FACE
         MOVE 0 TO WS-ACTION
         CALL "CONTROLS-SEND-ACTION" USING CLIENT-STATE WS-ACTION
         IF PL-MODE NOT = 1
             MOVE 1 TO CT-BREAKING
             MOVE CL-NOW-MS TO CT-BREAK-START
             CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM CT-BREAK-MS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-BREAK-TIME.
*> USING CLIENT-STATE, block state id, held item id, milliseconds out: the survival break time of
*> the state's block (standin-content §1.1), divided by 4 when the item is the tool of the block's
*> class (§2); -1 for an unbreakable block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CODE                BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-ITEM L-MS.
*>   The block id is the hex digit of the state's row (0 to 9, A, B).
     COMPUTE WS-CODE = FUNCTION ORD(CL-BS-BLOCK(L-STATE + 1)) - 1
     COMPUTE WS-B = WS-CODE - 48
     IF WS-CODE >= 65
         COMPUTE WS-B = WS-CODE - 55
     END-IF
     MOVE CL-BK-BREAK-MS(WS-B + 1) TO L-MS
     IF CL-BK-CLASS(WS-B + 1) NOT = SPACE AND CL-BK-CLASS(WS-B + 1) = CL-IT-TOOL(L-ITEM + 1)
         COMPUTE L-MS = L-MS / 4
     END-IF
     IF L-MS = 99999
         MOVE -1 TO L-MS
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-BREAK-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SEND-ACTION.
*> USING CLIENT-STATE, action (0 start, 2 abort, 3 stop destroy): Player Action on the break's
*> block and face with the next sequence number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     ADD 1 TO CT-SEQUENCE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLAYER-ACTION" USING PB-BUFFER L-ACTION CT-BREAK-X CT-BREAK-Y CT-BREAK-Z
         CT-BREAK-FACE CT-SEQUENCE
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CONTROLS-SEND-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SEND-USE.
*> USING CLIENT-STATE: Use Item On the target, its face and the hit point, with the next sequence
*> number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     ADD 1 TO CT-SEQUENCE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-USE-ITEM-ON" USING PB-BUFFER TG-X TG-Y TG-Z TG-FACE TG-CX TG-CY TG-CZ CT-SEQUENCE
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CONTROLS-SEND-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-HOTBAR.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-K                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE PL-HELD TO WS-HELD
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 8
         IF IN-KEY-PRESSED(CC-KEY-1 + WS-K + 1) = 1
             MOVE WS-K TO WS-HELD
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN IN-SCROLL-Y > 0
             COMPUTE WS-HELD = FUNCTION MOD(WS-HELD + 8, 9)
         WHEN IN-SCROLL-Y < 0
             COMPUTE WS-HELD = FUNCTION MOD(WS-HELD + 1, 9)
     END-EVALUATE
     IF WS-HELD NOT = PL-HELD
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         MOVE WS-HELD TO PL-HELD
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-SET-CARRIED" USING PB-BUFFER PL-HELD
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-HOTBAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-THROW.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-ACTION              BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF IN-KEY-PRESSED(CC-KEY-Q + 1) = 1 AND PL-SLOT-COUNT(PL-HELD + 1) > 0
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         COMPUTE WS-MODS = IN-MODS / CC-MOD-CONTROL
         MOVE 5 TO WS-ACTION
         IF FUNCTION MOD(WS-MODS, 2) = 1
             MOVE 4 TO WS-ACTION
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-DROP" USING PB-BUFFER WS-ACTION
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-THROW.
