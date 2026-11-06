*> The pause menu (US2-5; client-surface.md §3 Escape; 08 §10.8.6 pause texts): its title, Back to
*> the World and Disconnect; in a world this client hosts, Save and Leave the World in place of
*> Disconnect (US16-5, sp-host.cob SP-QUIT). Open to others joins it with US17.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAUSE-BUILD.
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 30
     MOVE 40 TO WS-Y
     MOVE "cobolcraft.screen.pause.title" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE WK-BUTTON TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 80 TO WS-Y
     MOVE ACT-RESUME TO WS-ACTION
     MOVE "cobolcraft.screen.pause.resume" TO WS-KEY
     MOVE 30 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     MOVE 106 TO WS-Y
     MOVE ACT-DISCONNECT TO WS-ACTION
     MOVE "cobolcraft.screen.pause.disconnect" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     IF SP-ACTIVE = 1
         MOVE ACT-QUIT-WORLD TO WS-ACTION
         MOVE "cobolcraft.screen.pause.quit_world" TO WS-KEY
     END-IF
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM PAUSE-BUILD.
