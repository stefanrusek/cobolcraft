*> The death screen (US7-4; standin-content §10.6, §10.7; 08 §10.8.2 cobolcraft.screen.death.title
*> and .respawn; docs/protocol/09-cobolcraft-profile.md §3.3 Client Command 0x0C). Player Combat
*> Kill for the local player opens it (protocol-client.cob): the title, under it the cause (the
*> packet's message, SM-DEATH-CAUSE) and the respawn control, which sends Client Command action 0
*> PERFORM_RESPAWN. The screen stays (Escape does nothing) until the server's Respawn enters the
*> world again.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DEATH-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 30
     MOVE 40 TO WS-Y
     MOVE "cobolcraft.screen.death.title" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
*>   The cause (as much as a widget holds), centred under the title.
     MOVE SM-DEATH-CAUSE(1:256) TO WS-TEXT
     MOVE FUNCTION MIN(SM-DEATH-CAUSE-LENGTH, 256) TO WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
     COMPUTE WS-X = (L-GW - WS-WIDTH) / 2
     MOVE 60 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-WIDTH WS-Z3
         SM-DEATH-CAUSE SM-DEATH-CAUSE-LENGTH WS-STATE
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-RESPAWN TO WS-ACTION
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 90 TO WS-Y
     MOVE "cobolcraft.screen.death.respawn" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM DEATH-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DEATH-RESPAWN.
*> USING CLIENT-STATE: Client Command action 0 PERFORM_RESPAWN on the game connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CLIENT-COMMAND" USING PB-BUFFER WS-ACTION
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM DEATH-RESPAWN.
