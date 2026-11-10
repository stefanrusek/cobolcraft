*> The world screen's HUD (data-model §13; 08 §10.8.6 crosshair and hotbar): the crosshair "+" in
*> the middle and the hotbar along the bottom edge: hotbar slots 0 to 8 as item slot widgets (20
*> GUI pixels each, side by side, centred), the held one selected; each shows its stack's icon and
*> count (ui-render.cob). SLOT-WIDGET-ADD adds one item slot widget (the inventory screen's too).
*> The chat area (US6-2; client-surface §4): CHAT-MESSAGE-ADD keeps a received message (rendered
*> text, arrival clock) in the history of the last 100, oldest first; CHAT-AREA-ADD adds the shown
*> messages as labels at the left edge, one per 9 GUI pixels, in the order received, the newest at
*> the bottom: with chat closed (the HUD, above the hotbar) at most the 10 most recent that arrived
*> less than 10 seconds ago; with chat open (chat.cob, above the input line and the CS-SHOWN
*> command suggestions) the 10 ending CH-SCROLL messages before the newest, regardless of age.
*> Health (US7-1, US7-6; standin-content §10.1; 08 §10.8.6 cobolcraft.hud.health): in survival a
*> label "Health <current>/<maximum>" (the last Set Health as a whole number, maximum 30) above the
*> hotbar's left end; none in creative. The hurt indication (US7-2): while the clock is before
*> PL-HURT-UNTIL, the first widget is an overlay over the whole screen on the hurt swatch (a red
*> tint, drawn under the rest of the HUD).
*> Food (US8-1, US8-6; standin-content §11.1; 08 §10.8.6 cobolcraft.hud.food): in survival a label
*> "Food <current>/<maximum>" (the last Set Health's food, maximum 24) beside the health label, to
*> its right above the hotbar's right half; none in creative.
*> Both follow the current game mode (PL-MODE: Login, Respawn, Game Event 3, US14-2): they go when
*> it becomes creative and come back in survival with the latest Set Health's values.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-CLOSED              BINARY-LONG VALUE 0.
 01 WS-OVERLAY             BINARY-LONG VALUE WK-OVERLAY.
 01 WS-HURT                BINARY-LONG VALUE SW-HURT.
 01 WS-TEXT                PIC X(512).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     IF CL-NOW-MS < PL-HURT-UNTIL
         MOVE SPACES TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-OVERLAY WS-ACTION WS-HURT WS-Z1 WS-Z2 L-GW L-GH
             WS-TEXT WS-Z3 WS-STATE
     END-IF
     MOVE SPACES TO WS-TEXT
     MOVE WK-SPRITE TO WS-KIND
*>   The crosshair is not drawn in the third-person modes (12 section 5.3, 7.1).
     IF CL-CAMERA = 0
         MOVE GSP-CROSSHAIR TO WS-ARG
         COMPUTE WS-X = (L-GW - 15) / 2
         COMPUTE WS-Y = (L-GH - 15) / 2
         MOVE 15 TO WS-W WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-TEXT WS-Z3 WS-STATE
     END-IF
*>   The hotbar sprite, then the selection frame over the held slot (12 section 5.2).
     MOVE GSP-HOTBAR TO WS-ARG
     COMPUTE WS-X = L-GW / 2 - 91
     COMPUTE WS-Y = L-GH - 22
     MOVE 182 TO WS-W
     MOVE 22 TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
         WS-TEXT WS-Z3 WS-STATE
     MOVE GSP-HOTBAR-SELECTION TO WS-ARG
     COMPUTE WS-X = L-GW / 2 - 92 + 20 * PL-HELD
     COMPUTE WS-Y = L-GH - 23
     MOVE 24 TO WS-W
     MOVE 23 TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
         WS-TEXT WS-Z3 WS-STATE
*>   The slots are bare (state 3): the sprite carries the wells; the icon cell is 2 pixels in.
     COMPUTE WS-Y = L-GH - 21
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 8
         COMPUTE WS-X = L-GW / 2 - 90 + WS-C * CL-SLOT-SIZE
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-C WS-X WS-Y WS-ACTION
         MOVE 3 TO SM-W-STATE(SM-WIDGET-COUNT)
     END-PERFORM
*>   The off-hand backing and slot beside the hotbar (12 section 5.2; 13 section 4; widget slot 37 is the off hand), while
*>   the off hand holds a stack.
     IF PL-OFFHAND-COUNT > 0
         MOVE GSP-OFFHAND-LEFT TO WS-ARG
         COMPUTE WS-X = L-GW / 2 - 91 - 29
         COMPUTE WS-Y = L-GH - 23
         MOVE 29 TO WS-W
         MOVE 24 TO WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-TEXT WS-Z3 WS-STATE
         COMPUTE WS-X = L-GW / 2 - 91 - 28
         COMPUTE WS-Y = L-GH - 21
         MOVE 37 TO WS-C
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-C WS-X WS-Y WS-ACTION
         MOVE 3 TO SM-W-STATE(SM-WIDGET-COUNT)
     END-IF
*>   Survival: the heart meter from the left end of the hotbar and the food meter from the right end, both at
*>   y = H - 39 (12 section 5.4); the value in half icons (health rounded up).
     IF PL-MODE = 0
         MOVE WK-METER TO WS-KIND
         MOVE 1 TO WS-ARG
         COMPUTE WS-X = L-GW / 2 - 91
         COMPUTE WS-Y = L-GH - 39
         COMPUTE WS-C = FUNCTION INTEGER(PL-HEALTH + 0.999)
         IF WS-C < 0
             MOVE 0 TO WS-C
         END-IF
         MOVE CL-MAX-HEALTH TO WS-ACTION
         MOVE 82 TO WS-W
         MOVE 9 TO WS-H
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-TEXT WS-Z3 WS-C
         MOVE 2 TO WS-ARG
         COMPUTE WS-X = L-GW / 2 + 91 - 9
         MOVE CL-MAX-FOOD TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-TEXT WS-Z3 PL-FOOD
     END-IF
     CALL "CHAT-AREA-ADD" USING CLIENT-STATE L-GW L-GH WS-CLOSED
     CALL "DEBUG-OVERLAY-ADD" USING CLIENT-STATE L-GW L-GH
     GOBACK.
 END PROGRAM HUD-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-MESSAGE-ADD.
*> USING CLIENT-STATE, text (PIC X(512)), length: the message arrives now (its first 256 bytes are
*> kept); the oldest is dropped once 100 are kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     IF CH-COUNT = CL-MAX-CHAT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= CL-MAX-CHAT
             MOVE CH-MESSAGE(WS-I + 1) TO CH-MESSAGE(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM CH-COUNT
     END-IF
     ADD 1 TO CH-COUNT
     MOVE CL-NOW-MS TO CH-TIME(CH-COUNT)
     MOVE L-TEXT(1:256) TO CH-TEXT(CH-COUNT)
     MOVE FUNCTION MIN(L-LENGTH, 256) TO CH-LENGTH(CH-COUNT)
     GOBACK.
 END PROGRAM CHAT-MESSAGE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-AREA-ADD.
*> USING CLIENT-STATE, GUI width, GUI height, open (1 = chat is open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 2.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG VALUE 9.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH L-OPEN.
     COMPUTE WS-W = L-GW - 4
     COMPUTE WS-BASE = L-GH - 59
     MOVE CH-COUNT TO WS-LAST
     IF L-OPEN = 1
         COMPUTE WS-BASE = L-GH - 26 - CS-SHOWN * 9
         COMPUTE WS-LAST = CH-COUNT - CH-SCROLL
     END-IF
     COMPUTE WS-FIRST = FUNCTION MAX(1, WS-LAST - CL-CHAT-SHOWN + 1)
*>   Closed: messages 10 seconds old or older are hidden (they arrived in clock order).
     PERFORM UNTIL L-OPEN = 1 OR WS-FIRST > WS-LAST
             OR CL-NOW-MS - CH-TIME(WS-FIRST) < CL-CHAT-MS
         ADD 1 TO WS-FIRST
     END-PERFORM
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-LAST
         COMPUTE WS-Y = WS-BASE - (WS-LAST - WS-I) * 9
         MOVE CH-TEXT(WS-I) TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H
             WS-TEXT CH-LENGTH(WS-I) WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM CHAT-AREA-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLOT-WIDGET-ADD.
*> USING CLIENT-STATE, slot (0 to 35, 36 the stack on the cursor), x, y (GUI pixels), action: an
*> item slot widget showing the stack's count (empty for an empty slot), selected when it is the
*> held hotbar slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-SLOT.
 01 WS-SIZE                BINARY-LONG VALUE CL-SLOT-SIZE.
 01 WS-SIZE2               BINARY-LONG VALUE CL-SLOT-SIZE.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-X L-Y L-ACTION.
     CALL "MENU-STACK-GET" USING CLIENT-STATE L-SLOT WS-COUNT WS-ITEM WS-DAMAGE
     MOVE 0 TO WS-STATE WS-LENGTH
     IF L-SLOT = PL-HELD
         MOVE 1 TO WS-STATE
     END-IF
     MOVE SPACES TO WS-TEXT
*>   A single item shows no count (FR-014).
     IF WS-COUNT > 1
         MOVE WS-COUNT TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND L-ACTION L-SLOT L-X L-Y WS-SIZE WS-SIZE2 WS-TEXT
         WS-LENGTH WS-STATE
     GOBACK.
 END PROGRAM SLOT-WIDGET-ADD.
