*> The break, place, use and hotbar controls (US4; client-surface §3; standin-content §1.1 break
*> times, §1.3 use rules, §2 tools; docs/protocol/09-cobolcraft-profile.md §3.2 Player Action
*> 0x29, Use Item On 0x42, Set Carried Item 0x36). Every Player Action and Use Item On carries the
*> next block-change sequence number (CT-SEQUENCE, from 1).
*>   CONTROLS-INPUT (world screen, in play), on the target of RAYCAST:
*>   - the right button pressed sends Use Item On with the target, its face and the hit point
*>     for any block aimed at, whatever the hand holds (an empty hand included: crafting table,
*>     furnace, chests, anvils and the stand-in glowtube and goto_pad all answer on the server);
*>   - the left button pressed sends start destroy. In creative the break is instant: nothing more.
*>     In survival the break lasts the block's hand break time (a quarter of it with the tool of
*>     the block's class; never for baseplate): stop destroy follows once it has passed while the
*>     button is held on the same block, abort destroy when the button is released, the target
*>     changes or the held slot changes first. While the button stays held after a finished break, the next block aimed at
*>     (the one behind, once the server has broken this one) is started without a new press, 5 ticks (250 ms) after the stop.
*>   - the left button pressed while a player or mob is the target (RAYCAST's entity target, which
*>     leaves no target block) sends Attack with its entity id (US7-5; standin-content §10.4, in
*>     either game mode); the server decides the hit and the damage.
*>   - the right button pressed while a player or mob is the target sends Interact (05c 0x1A, main hand, the sneak state) with its entity id, which is how a villager or a
*>     wandering trader opens its trade window and animals are fed (the server decides).
*>   - eating (US8-3; standin-content §11.5, §11.6; 09 §3.3 Use Item 0x43, Player Action 6): the
*>     right button pressed on the world screen with a food item held, when it uses no block,
*>     sends Use Item (the next sequence number, the facing) and the Player is eating; releasing
*>     the button before the eating time (1.5 s) has passed sends release use item (nothing is
*>     eaten); a later release, or Entity Event 9 for the Player first, ends it with nothing sent.
*>     The server decides whether eating starts (food below 24, survival).
*>   - the other items the server uses (lane bugusein; 17 sections 3.14, 3.16, 25 part 7 sections 7 and 9; CONTROLS-USE-KIND): the right button pressed on the world screen with
*>     a boat, a firework rocket, armor or elytra held sends Use Item (the next sequence number, the facing); with a spyglass, goat horn, brush, potion or ominous bottle held it sends
*>     Use Item and the Player is using the item (PL-USING) until the button is released, the item is no longer held or the screen is left: then release use item (Player Action 6) is
*>     sent. The block that was aimed at has had its Use Item On first; when it took the click the server ignores that tick's Use Item. A bow, crossbow, trident and shield (also in the
*>     off hand) are driven by USE-ITEM-INPUT (use-item.cob: ammo, the pose state), not here.
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
 01 WS-IS-AIR-USE           BINARY-LONG.
 01 WS-HOLD-USE             BINARY-LONG.
 01 WS-USE-KIND             BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-IB2                 BINARY-LONG.
 01 WS-IT2                 PIC X.
 01 WS-IF2                 BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-ITEM
     END-IF
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-IBLOCK WS-ITOOL WS-IFOOD
     MOVE 0 TO WS-IS-AIR-USE WS-HOLD-USE
     MOVE SPACES TO WS-PATH
     MOVE 0 TO WS-USE-KIND
     IF WS-ITEM > 0
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-IB2 WS-IT2 WS-IF2 WS-KNOWN
         CALL "CONTROLS-USE-KIND" USING WS-PATH WS-USE-KIND
     END-IF
     IF WS-USE-KIND = 1
         MOVE 1 TO WS-IS-AIR-USE
     END-IF
     IF WS-USE-KIND = 2
         MOVE 1 TO WS-HOLD-USE
     END-IF
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
*>   Use: Use Item On is sent for any block aimed at, whatever the hand holds (the server decides: it opens a menu, toggles a switch,
*>   places the held block or does nothing; the sneaking rule is the server's, 29 section 9). A food item, a bucket or a thrown item held on the
*>   world screen then also sends Use Item (eaten, the fluid ray, the throw), which the server answers when the block did not take the click.
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND TG-HIT = 1
         CALL "CONTROLS-SEND-USE" USING CLIENT-STATE
     END-IF
     EVALUATE TRUE
         WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD
                 AND WS-IFOOD > 0 AND PL-EATING = 0
             CALL "CONTROLS-SEND-EAT" USING CLIENT-STATE
*>       A bucket (the server casts the fluid ray, 29a section 7.2) or a thrown item (an ender eye, pearl, egg, snowball, potion, fishing rod): Use Item.
         WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND WS-IS-AIR-USE = 1
             CALL "CONTROLS-SEND-BUCKET" USING CLIENT-STATE
*>       A spyglass, goat horn, brush, potion or ominous bottle: Use Item starts the use, the release ends it.
         WHEN IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND WS-HOLD-USE = 1 AND PL-USING = 0
             CALL "CONTROLS-SEND-BUCKET" USING CLIENT-STATE
             MOVE 1 TO PL-USING
     END-EVALUATE
*>   The use ends with the button, the held item or the screen: release use item.
     IF PL-USING = 1 AND (IN-BUTTON-DOWN(CC-BUTTON-RIGHT + 1) = 0 OR WS-HOLD-USE = 0 OR SM-SCREEN NOT = SCR-WORLD)
         MOVE 0 TO PL-USING
         CALL "CONTROLS-SEND-ITEM-ACTION" USING CLIENT-STATE WS-ACTION6
     END-IF
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
*>   Interact: the right button on the world screen with a player or mob aimed at (a villager or trader opens its trades, an animal is fed or milked ...); the server decides.
     IF IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND SM-SCREEN = SCR-WORLD AND TG-ENTITY-HIT = 1
         CALL "CONTROLS-SEND-INTERACT" USING CLIENT-STATE
     END-IF
*>   A survival break in progress: aborted, or finished once its time has passed.
*>   Airborne (13 section 2.1 step 7): the server adds a fifth of the progress in a tick the player is not on the ground, so
*>   the time of the frame counts a fifth: the start of the break moves forward by the other four fifths.
     IF CT-BREAKING = 1
         IF PL-ON-GROUND = 0 AND CL-NOW-MS > CT-BREAK-LAST
             COMPUTE CT-BREAK-START = CT-BREAK-START + (CL-NOW-MS - CT-BREAK-LAST) * 4 / 5
         END-IF
         MOVE CL-NOW-MS TO CT-BREAK-LAST
     END-IF
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
             MOVE CL-NOW-MS TO CT-BREAK-START CT-BREAK-LAST
             CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM CT-BREAK-MS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTROLS-USE-KIND.
*> USING item path (PIC X(40)), kind out: how the right button uses the held item in the air (lane bugusein; the server decides what happens): 0 nothing is sent, 1 Use Item is sent
*> (buckets, the thrown items of THROWN-ITEM-USE, boats and rafts, firework rockets, armor and elytra: 25 section 6.3, 17 section 3.16), 2 Use Item is sent and the release is sent too
*> (spyglass, goat horn, brush, potion and ominous bottle: 17 sections 3.5, 3.14, 25 part 7). The bow, crossbow, trident and shield are 0 here: USE-ITEM-INPUT drives them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(40).
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-KIND.
     MOVE 0 TO L-KIND
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-PATH TRAILING))
     EVALUATE TRUE
         WHEN L-PATH = "bucket" OR "water_bucket" OR "lava_bucket"
             MOVE 1 TO L-KIND
         WHEN L-PATH = "ender_eye" OR "ender_pearl" OR "egg" OR "snowball" OR "splash_potion" OR "lingering_potion" OR "fishing_rod"
             MOVE 1 TO L-KIND
         WHEN L-PATH = "firework_rocket" OR "elytra"
             MOVE 1 TO L-KIND
         WHEN L-PATH = "spyglass" OR "goat_horn" OR "brush" OR "potion" OR "ominous_bottle"
             MOVE 2 TO L-KIND
     END-EVALUATE
     IF L-KIND = 0 AND WS-LEN >= 5
         COMPUTE WS-START = WS-LEN - 4
         IF L-PATH(WS-START:5) = "_boat" OR "_raft"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     IF L-KIND = 0 AND WS-LEN >= 6
         COMPUTE WS-START = WS-LEN - 5
         IF L-PATH(WS-START:6) = "_boots"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     IF L-KIND = 0 AND WS-LEN >= 7
         COMPUTE WS-START = WS-LEN - 6
         IF L-PATH(WS-START:7) = "_helmet"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     IF L-KIND = 0 AND WS-LEN >= 9
         COMPUTE WS-START = WS-LEN - 8
         IF L-PATH(WS-START:9) = "_leggings"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     IF L-KIND = 0 AND WS-LEN >= 11
         COMPUTE WS-START = WS-LEN - 10
         IF L-PATH(WS-START:11) = "_chestplate"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-USE-KIND.

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
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-SPEED               BINARY-LONG.
 01 WS-RULE-CORRECT        BINARY-LONG.
 01 WS-CORRECT             BINARY-LONG.
 01 WS-HASTE               BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG.
 01 WS-EFFICIENCY          BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-RATE                FLOAT-SHORT.
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
         IF WS-HARDNESS < 0
             MOVE -1 TO L-MS
             GOBACK
         END-IF
         IF WS-HARDNESS = 0
             MOVE 0 TO L-MS
             GOBACK
         END-IF
*>       The tool component's rules of the held item give the speed and the correct tool for drops (17 section 1.3); a block that
*>       needs no tool is always correct. The rate is BREAK-RATE's (core), the time the ticks that reach 1.0 (13 section 2.1).
         MOVE SPACES TO WS-BLOCK-KEY
         MOVE CT-BR-KEY TO WS-BLOCK-KEY
         CALL "TOOL-RULE-EVAL" USING L-ITEM WS-BLOCK-KEY WS-CODE WS-SPEED WS-RULE-CORRECT
         MOVE 1 TO WS-CORRECT
         IF CT-BR-TOOL-REQUIRED = "yes"
             MOVE WS-RULE-CORRECT TO WS-CORRECT
         END-IF
         MOVE 0 TO WS-HASTE WS-FATIGUE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
             IF EF-ID(WS-I) = 2 AND EF-AMP(WS-I) + 1 > WS-HASTE
                 COMPUTE WS-HASTE = EF-AMP(WS-I) + 1
             END-IF
             IF EF-ID(WS-I) = 3 AND EF-AMP(WS-I) + 1 > WS-FATIGUE
                 COMPUTE WS-FATIGUE = EF-AMP(WS-I) + 1
             END-IF
         END-PERFORM
         COMPUTE WS-MILLI = WS-HARDNESS * 1000
         MOVE 0 TO WS-EFFICIENCY
         MOVE PL-EYES-WATER TO WS-WATER
         MOVE 1 TO WS-GROUND
         CALL "BREAK-RATE" USING WS-MILLI WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE WS-FATIGUE
             WS-WATER WS-GROUND WS-RATE
         COMPUTE WS-TICKS = FUNCTION INTEGER(1 / WS-RATE)
         IF WS-TICKS > 1
             SUBTRACT 1 FROM WS-TICKS
         END-IF
         PERFORM UNTIL WS-TICKS * WS-RATE >= 1.0
             ADD 1 TO WS-TICKS
         END-PERFORM
         COMPUTE L-MS = WS-TICKS * 50
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
 PROGRAM-ID. CONTROLS-SEND-BUCKET.
*> USING CLIENT-STATE: Use Item with the next sequence number and the facing (the same packet as eating, without eating).
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
     GOBACK.
 END PROGRAM CONTROLS-SEND-BUCKET.

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
 PROGRAM-ID. CONTROLS-SEND-INTERACT.
*> USING CLIENT-STATE: Interact with the main hand on the entity target, with the sneak state of the client.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-SNEAK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE PL-SNEAK-FLAG TO WS-SNEAK
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-INTERACT" USING PB-BUFFER TG-ENTITY WS-SNEAK
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CONTROLS-SEND-INTERACT.

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
*> USING CLIENT-STATE: the sprint rules of docs/protocol/13 section 1.5, once a frame before the client tick.
*>   Start: forward is held (and not back), sprinting is possible (survival food above 6, no Blindness, no item in use, not moving slowly: shift
*>   up and not crouching, unless the eyes are in water) and either the sprint key is held or forward was pressed a second time within 350 ms of
*>   its press (the double tap; sprintWindow 7 ticks).
*>   Stop: any of those fails, a horizontal collision of the last tick, or (a sprint started by the key) the key is released.
*>   Player Command 0x2A start or stop is sent when the state changes.
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
 01 WS-K4                  BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-FWD                 BINARY-LONG.
 01 WS-KEY-DOWN            BINARY-LONG.
 01 WS-TAP                 BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-WINDOW              BINARY-DOUBLE VALUE 350.
 01 WS-BLINDNESS           BINARY-LONG VALUE 14.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE KB-CODE(KB-SPRINT) TO WS-K1
     MOVE KB-CODE(KB-FORWARD) TO WS-K2
     MOVE KB-CODE(KB-BACK) TO WS-K3
     MOVE KB-CODE(KB-SNEAK) TO WS-K4
     MOVE 0 TO WS-FWD WS-KEY-DOWN WS-TAP
     IF SM-SCREEN = SCR-WORLD AND IN-KEY-DOWN(WS-K2 + 1) = 1 AND IN-KEY-DOWN(WS-K3 + 1) = 0
         MOVE 1 TO WS-FWD
     END-IF
     IF SM-SCREEN = SCR-WORLD AND IN-KEY-DOWN(WS-K1 + 1) = 1
         MOVE 1 TO WS-KEY-DOWN
     END-IF
*>   The double tap: the second press of forward within the window.
     IF WS-FWD = 1 AND PL-FWD-PREV = 0
         IF PL-TAP-MS > 0 AND CL-NOW-MS - PL-TAP-MS <= WS-WINDOW
             MOVE 1 TO WS-TAP
             MOVE 0 TO PL-TAP-MS
         ELSE
             MOVE CL-NOW-MS TO PL-TAP-MS
         END-IF
     END-IF
     MOVE WS-FWD TO PL-FWD-PREV
*>   Sprinting is possible.
     MOVE 1 TO WS-CAN
     IF PL-MODE NOT = 1 AND PL-FOOD <= CL-SPRINT-FOOD
         MOVE 0 TO WS-CAN
     END-IF
     IF PL-EATING = 1
         MOVE 0 TO WS-CAN
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-ID(WS-I) = WS-BLINDNESS
             MOVE 0 TO WS-CAN
         END-IF
     END-PERFORM
     IF PL-EYE-WATER = 0 AND (PL-SNEAK-FLAG = 1 OR PL-POSE = 5 OR IN-KEY-DOWN(WS-K4 + 1) = 1)
         MOVE 0 TO WS-CAN
     END-IF
*>   In shallow water (in it, the head out) a player on foot cannot sprint (13 section 1.5); a swimmer keeps its sprint while in water.
     IF PL-IN-WATER = 1 AND PL-EYE-WATER = 0 AND PL-SWIMMING = 0 AND PL-FLYING = 0
         MOVE 0 TO WS-CAN
     END-IF
     MOVE PL-SPRINTING TO WS-WANT
     IF WS-WANT = 1
         IF WS-FWD = 0 OR WS-CAN = 0 OR (PL-COLLIDED = 1 AND PL-SWIMMING = 0)
                 OR (PL-SPRINT-KEY = 1 AND WS-KEY-DOWN = 0) OR (PL-SWIMMING = 1 AND PL-IN-WATER = 0)
             MOVE 0 TO WS-WANT
         END-IF
     ELSE
         IF WS-FWD = 1 AND WS-CAN = 1 AND PL-COLLIDED = 0 AND (WS-KEY-DOWN = 1 OR WS-TAP = 1)
             MOVE 1 TO WS-WANT
             MOVE WS-KEY-DOWN TO PL-SPRINT-KEY
         END-IF
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
 PROGRAM-ID. CONTROLS-SNEAK.
*> USING CLIENT-STATE: Player Input (05c 0x2B) with the shift flag 0x20 when the Sneak key goes down or up on the world screen
*> (53 section 10.1; the server keeps the sneak state and tells the other players).
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
 01 WS-FLAGS               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-WANT
     MOVE KB-CODE(KB-SNEAK) TO WS-K1
     IF SM-SCREEN = SCR-WORLD AND IN-KEY-DOWN(WS-K1 + 1) = 1
         MOVE 1 TO WS-WANT
     END-IF
     IF WS-WANT NOT = PL-SNEAK-SENT
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         MOVE WS-WANT TO PL-SNEAK-SENT
         COMPUTE WS-FLAGS = WS-WANT * 32
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-PLAYER-INPUT" USING PB-BUFFER WS-FLAGS
         CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM CONTROLS-SNEAK.

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
