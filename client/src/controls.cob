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
*>     button is held on the same block, abort destroy when the button is released, the target
*>     changes or the held slot changes first. While the button stays held after a finished break, the next block aimed at
*>     (the one behind, once the server has broken this one) is started without a new press, 5 ticks (250 ms) after the stop.
*>   - the left button pressed while a player or mob is the target (RAYCAST's entity target, which
*>     leaves no target block) sends Attack with its entity id (US7-5; standin-content §10.4, in
*>     either game mode); the server decides the hit and the damage.
*>   - eating (US8-3; standin-content §11.5, §11.6; 09 §3.3 Use Item 0x43, Player Action 6): the
*>     right button pressed on the world screen with a food item held, when it uses no block,
*>     sends Use Item (the next sequence number, the facing) and the Player is eating; releasing
*>     the button before the eating time (1.5 s) has passed sends release use item (nothing is
*>     eaten); a later release, or Entity Event 9 for the Player first, ends it with nothing sent.
*>     The server decides whether eating starts (food below 24, survival).
*>   CONTROLS-SPRINT (every frame in play, before the client tick; US8-2; client-surface §3;
*>   09 §3.3 Player Command 0x2A): the Player sprints while, on the world screen, Left Control is
*>   held and the Player moves forward (W without S); start sprinting is sent when that begins and
*>   stop sprinting when it ends (Left Control or W released, S pressed, the world screen left).
*>   physics.cob moves a sprinting Player at the sprint speed.
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
 01 WS-ACTION6             BINARY-LONG VALUE 6.
 01 WS-IBLOCK              BINARY-LONG.
 01 WS-ITOOL               PIC X.
 01 WS-IFOOD               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
     END-IF
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-IBLOCK WS-ITOOL WS-IFOOD
     MOVE 0 TO WS-STATE
     IF TG-HIT = 1
         CALL "WORLD-CELL" USING CLIENT-STATE TG-X TG-Y TG-Z WS-STATE WS-SKY WS-BLOCK
     END-IF
*>   A command block used on the world screen opens its editor with the permission (40-9 section 2.1).
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND TG-ENTITY-HIT = 1
         CALL "MINECART-USE-CHECK" USING CLIENT-STATE TG-ENTITY
     END-IF
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND TG-HIT = 1
         CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE TG-X TG-Y TG-Z WS-STATE
     END-IF
*>   A writable book held on the world screen opens the book editor on the client's own (40-8 section 1.1).
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND WS-ITEM > 0
         CALL "BOOK-USE-CHECK" USING CLIENT-STATE WS-ITEM
     END-IF
*>   Use: a block item placed against the face, a glowtube toggled, a goto_pad used; otherwise
*>   a food item held on the world screen is eaten.
     EVALUATE TRUE
         WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND TG-HIT = 1
                 AND (WS-IBLOCK = 1 OR WS-STATE = 13 OR WS-STATE = 14
                 OR WS-STATE = 16)
             CALL "CONTROLS-SEND-USE" USING CLIENT-STATE
         WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD
                 AND WS-IFOOD > 0 AND PL-EATING = 0
             CALL "CONTROLS-SEND-EAT" USING CLIENT-STATE
     END-EVALUATE
*>   Eating ends when the button is released; early, the server is told.
     IF PL-EATING = 1 AND IN-BUTTON-DOWN(CC-BUTTON-RIGHT + 1) = 0
         MOVE 0 TO PL-EATING
         IF CL-NOW-MS - PL-EAT-START < CL-EAT-MS
             CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION6
         END-IF
     END-IF
*>   Attack: the entity aimed at.
     IF IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1 AND TG-ENTITY-HIT = 1
         CALL "CONTROLS-SEND-ATTACK" USING CLIENT-STATE
     END-IF
*>   A survival break in progress: aborted, or finished once its time has passed.
     MOVE 0 TO WS-SAME
     IF TG-HIT = 1 AND TG-X = CT-BREAK-X AND TG-Y = CT-BREAK-Y AND TG-Z = CT-BREAK-Z
         MOVE 1 TO WS-SAME
     END-IF
     EVALUATE TRUE
         WHEN CT-BREAKING = 1 AND (IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 0 OR WS-SAME = 0
                 OR PL-HELD NOT = CT-BREAK-HELD)
             MOVE 2 TO WS-ACTION
             CALL "CONTROLS-SEND-ACTION" USING CLIENT-STATE WS-ACTION
             MOVE 0 TO CT-BREAKING
         WHEN CT-BREAKING = 1 AND CT-BREAK-MS >= 0
                 AND CL-NOW-MS - CT-BREAK-START >= CT-BREAK-MS
             MOVE 3 TO WS-ACTION
             CALL "CONTROLS-SEND-ACTION" USING CLIENT-STATE WS-ACTION
             MOVE 0 TO CT-BREAKING
             MOVE 1 TO CT-DONE
             MOVE CL-NOW-MS TO CT-DONE-MS
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
*>   The continuous-break cooldown (13 section 2.2): no new break for 5 ticks (250 ms) after a finished one.
     IF WS-START = 1 AND CT-DONE = 1 AND IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 0
             AND CL-NOW-MS - CT-DONE-MS < CL-BREAK-COOLDOWN-MS
         MOVE 0 TO WS-START
     END-IF
     IF WS-START = 1
         MOVE TG-X TO CT-BREAK-X
         MOVE TG-Y TO CT-BREAK-Y
         MOVE TG-Z TO CT-BREAK-Z
         MOVE TG-FACE TO CT-BREAK-FACE
         MOVE PL-HELD TO CT-BREAK-HELD
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
 COPY CONTENT.
 01 WS-CODE                BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-HARDNESS            FLOAT-LONG.
 01 WS-IBLOCK              BINARY-LONG.
 01 WS-ITOOL               PIC X.
 01 WS-IFOOD               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-ITEM L-MS.
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE L-ITEM WS-IBLOCK WS-ITOOL WS-IFOOD
*>   The standard content set: hardness x 1.5 s by hand, x 5 s when the block needs the correct tool for
*>   its drops, never for an unbreakable block (hardness below 0). The held item's tool speed is not
*>   applied (it needs the item rules of 17).
     IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND CT-STATE-COUNT > 0
         CALL "CONTENT-BLOCK-OF-STATE" USING L-STATE WS-CODE WS-INDEX WS-ROW WS-STATUS
         MOVE WS-ROW TO CT-BLOCK-ROW
         COMPUTE WS-HARDNESS = FUNCTION NUMVAL(CT-BR-HARDNESS)
         EVALUATE TRUE
             WHEN WS-HARDNESS < 0
                 MOVE -1 TO L-MS
             WHEN CT-BR-TOOL-REQUIRED = "yes"
                 COMPUTE L-MS = WS-HARDNESS * 5000
             WHEN OTHER
                 COMPUTE L-MS = WS-HARDNESS * 1500
         END-EVALUATE
         GOBACK
     END-IF
*>   The block id is the hex digit of the state's row (0 to 9, A, B).
     COMPUTE WS-CODE = FUNCTION ORD(CL-BS-BLOCK(L-STATE + 1)) - 1
     COMPUTE WS-B = WS-CODE - 48
     IF WS-CODE >= 65
         COMPUTE WS-B = WS-CODE - 55
     END-IF
     MOVE CL-BK-BREAK-MS(WS-B + 1) TO L-MS
     IF CL-BK-CLASS(WS-B + 1) NOT = SPACE AND CL-BK-CLASS(WS-B + 1) = WS-ITOOL
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
 PROGRAM-ID. CONTROLS-SEND-EAT.
*> USING CLIENT-STATE: Use Item with the next sequence number and the facing; the Player is eating
*> from now.
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
     CALL "CLP-USE-ITEM" USING PB-BUFFER CT-SEQUENCE PL-YAW PL-PITCH
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     MOVE 1 TO PL-EATING
     MOVE CL-NOW-MS TO PL-EAT-START
     GOBACK.
 END PROGRAM CONTROLS-SEND-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SEND-ITEM-ACTION.
*> USING CLIENT-STATE, action (4 drop all items, 5 drop item, 6 release use item): the Player
*> Action on the held item.
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
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ITEM-ACTION" USING PB-BUFFER L-ACTION
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CONTROLS-SEND-ITEM-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SEND-ATTACK.
*> USING CLIENT-STATE: Attack on the entity target.
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
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ATTACK" USING PB-BUFFER TG-ENTITY
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CONTROLS-SEND-ATTACK.

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
 01 WS-KEY                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-SAVE-KEY            BINARY-LONG.
 01 WS-LOAD-KEY            BINARY-LONG.
 01 WS-SAVE                BINARY-LONG.
 01 WS-LOAD                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE PL-HELD TO WS-HELD
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 8
         COMPUTE WS-KEY = KB-HOTBAR-1 + WS-K
         MOVE KB-CODE(WS-KEY) TO WS-KEY
         IF IN-KEY-PRESSED(WS-KEY + 1) = 1
             MOVE KB-CODE(KB-SAVE-TOOLBAR) TO WS-SAVE-KEY
             MOVE KB-CODE(KB-LOAD-TOOLBAR) TO WS-LOAD-KEY
             MOVE 0 TO WS-SAVE WS-LOAD
             IF WS-SAVE-KEY > 0 AND IN-KEY-DOWN(WS-SAVE-KEY + 1) = 1
                 MOVE 1 TO WS-SAVE
             END-IF
             IF WS-LOAD-KEY > 0 AND IN-KEY-DOWN(WS-LOAD-KEY + 1) = 1
                 MOVE 1 TO WS-LOAD
             END-IF
*>           40-7 10: with infinite materials and no screen open, an activator key down makes the key a saved hotbar action (load wins).
             IF PL-MODE = 1 AND SM-SCREEN = SCR-WORLD AND (WS-SAVE = 1 OR WS-LOAD = 1)
                 IF WS-LOAD = 1
                     CALL "CREATIVE-HOTBAR-LOAD" USING CLIENT-STATE WS-K
                 ELSE
                     CALL "CREATIVE-HOTBAR-SAVE" USING CLIENT-STATE WS-K
                 END-IF
             ELSE
                 MOVE WS-K TO WS-HELD
             END-IF
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
 01 WS-ACTION              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE KB-CODE(KB-DROP) TO WS-KEY
     IF IN-KEY-PRESSED(WS-KEY + 1) = 1 AND PL-SLOT-COUNT(PL-HELD + 1) > 0
         COMPUTE WS-MODS = IN-MODS / CC-MOD-CONTROL
         MOVE 5 TO WS-ACTION
         IF FUNCTION MOD(WS-MODS, 2) = 1
             MOVE 4 TO WS-ACTION
         END-IF
         CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-THROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SPRINT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-WANT                BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-K3                  BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-WANT
     MOVE KB-CODE(KB-SPRINT) TO WS-K1
     MOVE KB-CODE(KB-FORWARD) TO WS-K2
     MOVE KB-CODE(KB-BACK) TO WS-K3
     IF SM-SCREEN = SCR-WORLD AND IN-KEY-DOWN(WS-K1 + 1) = 1
             AND IN-KEY-DOWN(WS-K2 + 1) = 1 AND IN-KEY-DOWN(WS-K3 + 1) = 0
             AND (PL-MODE = 1 OR PL-FOOD > CL-SPRINT-FOOD)
         MOVE 1 TO WS-WANT
     END-IF
     IF WS-WANT NOT = PL-SPRINTING
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         MOVE WS-WANT TO PL-SPRINTING
         COMPUTE WS-ACTION = 2 - WS-WANT
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-PLAYER-COMMAND" USING PB-BUFFER PL-ENTITY-ID WS-ACTION
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-SPRINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-CTRL-DOWN.
*> USING CLIENT-STATE, down out (1 = a Ctrl key is held): the left Ctrl key is down, or the modifier
*> bits of the last key event (IN-MODS) name Control. Screens read it for the Ctrl-click of the hidden
*> debug world type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DOWN                 PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-DOWN.
     MOVE 0 TO L-DOWN
     IF IN-KEY-DOWN(CC-KEY-LEFT-CONTROL + 1) = 1
             OR FUNCTION MOD(IN-MODS / CC-MOD-CONTROL, 2) = 1
         MOVE 1 TO L-DOWN
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-CTRL-DOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-SWAP.
*> USING CLIENT-STATE (world screen, in play; US19; 13 §4): the swap key (F) pressed sends Player Action SWAP_ITEM_WITH_OFFHAND (7: position
*> 0 0 0, face down, sequence 0), not for a spectator, with no local prediction: the server answers with the new contents of both hands.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE KB-CODE(KB-SWAP-OFFHAND) TO WS-KEY
     IF IN-KEY-PRESSED(WS-KEY + 1) = 1 AND PL-MODE NOT = 3
         CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-SWAP.
