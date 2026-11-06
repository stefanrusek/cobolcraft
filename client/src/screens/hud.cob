*> The world screen's HUD (data-model §13; 08 §10.8.6 crosshair and hotbar): the crosshair "+" in
*> the middle and the hotbar along the bottom edge: hotbar slots 0 to 8 as item slot widgets (20
*> GUI pixels each, side by side, centred), the held one selected; each shows its stack's icon and
*> count (ui-render.cob). SLOT-WIDGET-ADD adds one item slot widget (the inventory screen's too).

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
     GOBACK.
 END PROGRAM HUD-BUILD.

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
