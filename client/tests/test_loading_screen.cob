*> Implementation test of the level-loading screen (docs/protocol/50 sections 2 and 4; client/src/screens/loading.cob, connecting.cob): the layout of the
*> worked example of 50 section 2.7 (GUI 480 x 270: grid x 205 to 275 and y 100 to 170, text top y 74, bar x 140 to 340, y 86 to 88, green part to x 240 at
*> half progress), the text alone at cy - 50 without a grid, the smoothing of the bar by 0.2 of the gap per 50 ms tick, the grid cell colours, and the screen
*> of a hosted world while its spawn is searched and its spawn area made: the loading text, the grid around the spawn, the bar following the chunks ready,
*> the world once the client joins.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOADING-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-loading".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-FOLDER              PIC X(80) VALUE "Load".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-NAME                PIC X(64) VALUE "Load".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-GRID                BINARY-LONG VALUE 1.
 01 WS-NOGRID              BINARY-LONG VALUE 0.
 01 WS-PROGRESS            BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OBSERVED            PIC X(256).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-TARGET              BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-LABEL               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PERMILLE            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-LAST-FILL           BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SEEN-PARTIAL        BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH

*>   the worked example of 50 section 2.7, with the bar at half
     MOVE 480 TO WS-GW
     MOVE 270 TO WS-GH
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 500000 TO SM-LOAD-SMOOTH
     CALL "LOADING-LAYOUT" USING CLIENT-STATE WS-GW WS-GH WS-GRID WS-PROGRESS
     MOVE "loading screen the layout of 50 section 2.7 at GUI 480 x 270" TO TL-CASE
     MOVE "grid 205 100 70 70 | text 74 | bar 140 86 200 2 black | fill 140 86 100 2 green" TO TL-EXPECTED
     PERFORM DESCRIBE-WIDGETS
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the text alone, and no bar without progress
     MOVE 0 TO SM-WIDGET-COUNT
     MOVE 0 TO WS-PROGRESS
     CALL "LOADING-LAYOUT" USING CLIENT-STATE WS-GW WS-GH WS-NOGRID WS-PROGRESS
     MOVE "loading screen without a grid the text is at cy - 50 and without progress there is no bar" TO TL-CASE
     MOVE "text 85" TO TL-EXPECTED
     PERFORM DESCRIBE-WIDGETS
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the text is centred on cx
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "LOADING-LAYOUT" USING CLIENT-STATE WS-GW WS-GH WS-NOGRID WS-PROGRESS
     MOVE SM-W-TEXT(1) TO WS-TEXT
     MOVE SM-W-LENGTH(1) TO WS-LEN
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LEN WS-WIDTH
     MOVE "loading screen the text Loading terrain... is centred on the middle of the screen" TO TL-CASE
     COMPUTE WS-HALF = WS-WIDTH / 2
     COMPUTE WS-E1 = 240 - WS-HALF
     MOVE SPACES TO TL-EXPECTED
     STRING "Loading terrain... at " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SM-W-X(1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(SM-W-TEXT(1)) " at " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the smoothing: 0.2 of the gap each 50 ms, so 36 % of the gap after two ticks
     MOVE 0 TO SM-LOAD-SMOOTH
     MOVE 1000 TO CL-NOW-MS
     MOVE 1000 TO SM-LOAD-TICK-MS
     MOVE 1000 TO WS-TARGET
     MOVE 1100 TO CL-NOW-MS
     CALL "LOADING-SMOOTH" USING CLIENT-STATE WS-TARGET
     MOVE "loading screen two 50 ms ticks bring the bar 36 percent of the way to its target" TO TL-CASE
     MOVE "360000" TO TL-EXPECTED
     MOVE SM-LOAD-SMOOTH TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1120 TO CL-NOW-MS
     CALL "LOADING-SMOOTH" USING CLIENT-STATE WS-TARGET
     MOVE "loading screen a frame less than a tick later changes nothing" TO TL-CASE
     MOVE SM-LOAD-SMOOTH TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the cell colours: runs of equal status are one quad each
     MOVE 1 TO CL-GUI-SCALE
     MOVE 0 TO SM-WIDGET-COUNT
     CALL "LOADING-LAYOUT" USING CLIENT-STATE WS-GW WS-GH WS-GRID WS-PROGRESS
     MOVE 0 TO RL-UI-COUNT
     MOVE ALL LOW-VALUES TO SM-LOAD-CELLS
     MOVE FUNCTION CHAR(11) TO SM-LOAD-CELLS(1:1)
     MOVE FUNCTION CHAR(11) TO SM-LOAD-CELLS(2:1)
     MOVE FUNCTION CHAR(2) TO SM-LOAD-CELLS(3:1)
     MOVE 1 TO WS-W
     CALL "UI-LOADGRID" USING CLIENT-STATE WS-W
     MOVE "loading screen the grid is drawn as one quad per run of equal cells of a row, black cells included" TO TL-CASE
     MOVE "quads 37" TO TL-EXPECTED
     COMPUTE WS-E1 = RL-UI-COUNT / 6
     MOVE SPACES TO TL-OBSERVED
     STRING "quads " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a hosted world: the spawn is searched and the spawn area made while the loading screen shows
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "GEN-SPAWN-BEGIN"
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "loading screen a hosted world with its spawn being searched shows Loading terrain... and the grid, no green yet" TO TL-CASE
     PERFORM DESCRIBE-WIDGETS
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-OBSERVED-N
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-LEN
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-W) = WK-LABEL
             MOVE SM-W-TEXT(WS-W) TO WS-TEXT
             MOVE SM-W-LENGTH(WS-W) TO WS-LEN
         END-IF
     END-PERFORM
     IF SM-SCREEN = SCR-CONNECTING AND WS-LEN = 18 AND WS-TEXT(1:WS-LEN) = "Loading terrain..."
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-W) = WK-OVERLAY AND SM-W-COLOUR(WS-W) = LOAD-GREEN
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "loading screen at progress 0 no green part is drawn" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   tick by tick until the client has joined: the green part never shrinks and is seen part way
     MOVE 0 TO WS-LAST-FILL WS-BAD WS-SEEN-PARTIAL WS-JOINED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR WS-JOINED = 1
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
         IF SM-SCREEN = SCR-CONNECTING
             MOVE 0 TO WS-TARGET
             PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
                 IF SM-W-KIND(WS-W) = WK-OVERLAY AND SM-W-COLOUR(WS-W) = LOAD-GREEN
                     MOVE SM-W-W(WS-W) TO WS-TARGET
                 END-IF
             END-PERFORM
             IF WS-TARGET < WS-LAST-FILL
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-TARGET > 0 AND WS-TARGET < 200
                 ADD 1 TO WS-SEEN-PARTIAL
             END-IF
             MOVE WS-TARGET TO WS-LAST-FILL
         ELSE
             MOVE 1 TO WS-JOINED
         END-IF
     END-PERFORM
     MOVE "loading screen while the spawn area is made the green part never shrinks" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "loading screen while the spawn area is made the green part is seen part way" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN-PARTIAL > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "loading screen when the spawn area is ready the client joins and the world screen replaces the loading screen" TO TL-CASE
     MOVE WS-JOINED TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-OBSERVED: each widget of the screen as "grid x y w h" (WK-LOADGRID), "text y" (a label), "bar x y w h black" or "fill x y w h green" (overlays).
 DESCRIBE-WIDGETS.
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-LEN
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         MOVE SM-W-X(WS-W) TO WS-E1
         MOVE SM-W-Y(WS-W) TO WS-E2
         MOVE SM-W-W(WS-W) TO WS-E3
         MOVE SM-W-H(WS-W) TO WS-E4
         IF WS-W > 1
             STRING " | " DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-LEN
         END-IF
         EVALUATE TRUE
             WHEN SM-W-KIND(WS-W) = WK-LOADGRID
                 STRING "grid " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
                     FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-LEN
             WHEN SM-W-KIND(WS-W) = WK-LABEL
                 STRING "text " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-LEN
             WHEN SM-W-KIND(WS-W) = WK-OVERLAY AND SM-W-COLOUR(WS-W) = LOAD-GREEN
                 STRING "fill " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
                     FUNCTION TRIM(WS-E4) " green" DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-LEN
             WHEN OTHER
                 STRING "bar " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
                     FUNCTION TRIM(WS-E4) " black" DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-LEN
         END-EVALUATE
     END-PERFORM.
 END PROGRAM TEST-LOADING-SCREEN.
 COPY CLTEST.
