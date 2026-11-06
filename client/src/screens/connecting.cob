*> The connecting screen (US2-3 client half; 08 §10.8.6 connecting texts): "Connecting to <address>"
*> until the login is done, then "Joining the world" until the play Login shows the world.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONNECTING-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ZERO4               BINARY-LONG VALUE 0.
 01 WS-ZERO5               BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 01 WS-Z4                   BINARY-LONG VALUE 0.
 01 WS-Z5                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE "cobolcraft.screen.connecting.title" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE SM-CONNECT-ADDR TO LA-TEXT(1)
     MOVE SM-CONNECT-ADDR-LENGTH TO LA-LENGTH(1)
     IF CN-PHASE(CONN-GAME) >= PH-CONFIG
         MOVE "cobolcraft.screen.connecting.joining" TO WS-KEY
         MOVE 36 TO WS-KEY-LENGTH
     END-IF
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
     COMPUTE WS-X = (L-GW - WS-WIDTH) / 2
     COMPUTE WS-Y = L-GH / 2 - 4
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4
         WS-TEXT WS-LENGTH WS-Z5
     GOBACK.
 END PROGRAM CONNECTING-BUILD.
