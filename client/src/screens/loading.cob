*> The level-loading screen (docs/protocol/50 section 2): the text "Loading terrain..." (cobolcraft.screen.connecting.loading) above a bar, and for a hosted world a
*> grid of chunk status cells under the bar. CONNECTING-BUILD shows it while a hosted world's spawn is searched and its spawn area made (core GEN-LOAD-PROGRESS,
*> GEN-LOAD-GRID); the background is the screen's own (a design choice: the panorama and the blur of 50 section 2.4 are not drawn).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOADING-SMOOTH.
*> USING CLIENT-STATE, target progress in thousandths (BINARY-LONG): moves the bar's smoothed progress (SM-LOAD-SMOOTH, millionths) towards the target by a fifth of
*> the gap for each whole 50 ms since SM-LOAD-TICK-MS (50 section 2.2: 0.2 per client tick); the first call only starts the clock.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TARGET.
     COMPUTE WS-TARGET = L-TARGET * 1000
     IF SM-LOAD-TICK-MS = 0
         MOVE CL-NOW-MS TO SM-LOAD-TICK-MS
     END-IF
     PERFORM UNTIL CL-NOW-MS - SM-LOAD-TICK-MS < CL-TICK-MS
         COMPUTE SM-LOAD-SMOOTH = SM-LOAD-SMOOTH + (WS-TARGET - SM-LOAD-SMOOTH) / 5
         ADD CL-TICK-MS TO SM-LOAD-TICK-MS
     END-PERFORM
     GOBACK.
 END PROGRAM LOADING-SMOOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOADING-LAYOUT.
*> USING CLIENT-STATE, GUI width, GUI height, grid flag, progress flag (BINARY-LONG each): the widgets of the screen in drawing order (50 section 2.3): the grid when
*> the grid flag is 1 (35 x 35 cells of 2 GUI pixels centred on the middle of the screen), the text, and when the progress flag is 1 the bar: 200 x 2 black with
*> a green fill of round(smoothed * 200) pixels (none when 0). Text top y is cy - 61 with the grid (cy - 2R - 27, R = 17) and cy - 50 without.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ZERO4               BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-FILL                BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.connecting.loading".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 36.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-EMPTY               PIC X(512) VALUE SPACES.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 01 L-GRID                 BINARY-LONG.
 01 L-PROGRESS             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH L-GRID L-PROGRESS.
     COMPUTE WS-CX = L-GW / 2
     COMPUTE WS-CY = L-GH / 2
     COMPUTE WS-TOP = WS-CY - 50
     IF L-GRID = 1
         COMPUTE WS-TOP = WS-CY - 61
         COMPUTE WS-X = WS-CX - 35
         COMPUTE WS-Y = WS-CY - 35
         MOVE WK-LOADGRID TO WS-KIND
         MOVE 70 TO WS-W WS-H
         MOVE 0 TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ZERO WS-ZERO2 WS-X WS-Y WS-W WS-H
             WS-EMPTY WS-LENGTH WS-NONE
     END-IF
     MOVE WK-LABEL TO WS-KIND
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
     COMPUTE WS-HALF = WS-WIDTH / 2
     COMPUTE WS-X = WS-CX - WS-HALF
     MOVE 0 TO WS-W WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ZERO WS-ZERO3 WS-X WS-TOP WS-W WS-H
         WS-TEXT WS-LENGTH WS-NONE
     IF L-PROGRESS = 1
         MOVE WK-OVERLAY TO WS-KIND
         COMPUTE WS-X = WS-CX - 100
         COMPUTE WS-Y = WS-TOP + 12
         MOVE 200 TO WS-W
         MOVE 2 TO WS-H
         MOVE SW-BLACK TO WS-ARG
         MOVE 0 TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ZERO WS-ARG WS-X WS-Y WS-W WS-H
             WS-EMPTY WS-LENGTH WS-NONE
         COMPUTE WS-FILL = (SM-LOAD-SMOOTH * 200 + 500000) / 1000000
         IF WS-FILL > 0
             MOVE WS-FILL TO WS-W
             MOVE SW-WHITE TO WS-ARG
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ZERO4 WS-ARG WS-X WS-Y WS-W WS-H
                 WS-EMPTY WS-LENGTH WS-NONE
             MOVE LOAD-GREEN TO SM-W-COLOUR(SM-WIDGET-COUNT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOADING-LAYOUT.
