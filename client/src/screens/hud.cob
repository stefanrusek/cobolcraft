*> The world screen's HUD (data-model §13; 08 §10.8.6 crosshair and hotbar): the crosshair "+" in
*> the middle and the hotbar along the bottom edge: hotbar slots 0 to 8 as item slot widgets (20
*> GUI pixels each, side by side, centred), the held one selected; each shows its stack's icon and
*> count (ui-render.cob). SLOT-WIDGET-ADD adds one item slot widget (the inventory screen's too).
*> The chat area (US6-2; client-surface §4): CHAT-MESSAGE-ADD keeps a received message (rendered
*> text, arrival clock) in the history of the last 100, oldest first; CHAT-AREA-ADD adds the shown
*> messages as labels at the left edge, one per 9 GUI pixels, in the order received, the newest at
*> the bottom: with chat closed (the HUD, above the hotbar) at most the 10 most recent that arrived
*> less than 10 seconds ago; with chat open (chat.cob, above the input line) the 10 ending
*> CH-SCROLL messages before the newest, regardless of age.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUD-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.hud.crosshair".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 24.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-CLOSED              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-X = L-GW / 2 - 3
     COMPUTE WS-Y = L-GH / 2 - 4
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-Y = L-GH - CL-SLOT-SIZE - 2
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 8
         COMPUTE WS-X = L-GW / 2 - 90 + WS-C * CL-SLOT-SIZE
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-C WS-X WS-Y WS-ACTION
     END-PERFORM
     CALL "CHAT-AREA-ADD" USING CLIENT-STATE L-GW L-GH WS-CLOSED
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
     COMPUTE WS-BASE = L-GH - CL-SLOT-SIZE - 14
     MOVE CH-COUNT TO WS-LAST
     IF L-OPEN = 1
         COMPUTE WS-BASE = L-GH - 26
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
     MOVE PL-CARRIED-COUNT TO WS-COUNT
     IF L-SLOT < 36
         MOVE PL-SLOT-COUNT(L-SLOT + 1) TO WS-COUNT
     END-IF
     MOVE 0 TO WS-STATE WS-LENGTH
     IF L-SLOT = PL-HELD
         MOVE 1 TO WS-STATE
     END-IF
     MOVE SPACES TO WS-TEXT
     IF WS-COUNT > 0
         MOVE WS-COUNT TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND L-ACTION L-SLOT L-X L-Y WS-SIZE WS-SIZE2 WS-TEXT
         WS-LENGTH WS-STATE
     GOBACK.
 END PROGRAM SLOT-WIDGET-ADD.
