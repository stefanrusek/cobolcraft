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
 01 WS-STATE               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PERMILLE            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GRID-FLAG           BINARY-LONG VALUE 1.
 01 WS-PROGRESS-FLAG       BINARY-LONG VALUE 1.
 01 WS-NO-GRID             BINARY-LONG VALUE 0.
 01 WS-NO-PROGRESS         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
*>   A hosted world whose spawn is searched and spawn area made shows the level-loading screen (docs/protocol/50) from the start, and keeps it until
*>   the world replaces it at the play Login.
     IF PL-WAIT > 0
*>       the wait for the level after Login: the text alone, and for a hosted world the grid and the full bar (50 sections 5.4, 7)
         IF SP-ACTIVE = 1 AND SM-LOAD-SHOWN = 1
             MOVE 1000000 TO SM-LOAD-SMOOTH
             CALL "LOADING-LAYOUT" USING CLIENT-STATE L-GW L-GH WS-GRID-FLAG WS-PROGRESS-FLAG
         ELSE
             CALL "LOADING-LAYOUT" USING CLIENT-STATE L-GW L-GH WS-NO-GRID WS-NO-PROGRESS
         END-IF
         GOBACK
     END-IF
     IF SP-ACTIVE = 1
         CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
         IF WS-STATE > 0
             MOVE 1 TO SM-LOAD-SHOWN
         END-IF
         IF SM-LOAD-SHOWN = 1
             IF CL-NOW-MS - SM-LOAD-GRID-MS >= 100 OR SM-LOAD-GRID-MS = 0
                 CALL "GEN-LOAD-GRID" USING SM-LOAD-CELLS
                 MOVE CL-NOW-MS TO SM-LOAD-GRID-MS
             END-IF
             CALL "LOADING-SMOOTH" USING CLIENT-STATE WS-PERMILLE
             CALL "LOADING-LAYOUT" USING CLIENT-STATE L-GW L-GH WS-GRID-FLAG WS-PROGRESS-FLAG
             GOBACK
         END-IF
     END-IF
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
