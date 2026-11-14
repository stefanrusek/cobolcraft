*> Test US12-client (spec 002; docs/protocol/40-menus-7-creative-inventory.md 3.3): a tab is selected on mouse release, not on press: pressing on a tab only consumes the event; the release over a tab (the
*> first displayed tab hit, which may be another tab than the pressed one) selects it; a release elsewhere selects nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-7-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-HEX                 PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 4 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-EX            FLOAT-SHORT.
       10 WS-EY            FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE 1 TO PL-MODE
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     MOVE "N" TO TL-MODE
*>   The inventory key opens the creative screen.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-E TO WS-A(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE CC-KEY-E TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§1 in creative mode the inventory key opens the creative screen" TO TL-CASE
     MOVE SCR-CREATIVE TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Press on the tools tab (75, 200): nothing yet.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 150 TO WS-EX(1)
     MOVE 400 TO WS-EY(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE WS-EX(1) TO WS-EX(2)
     MOVE WS-EY(1) TO WS-EY(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§3.3 pressing the left button on the tools tab selects nothing yet: the building blocks tab (1) stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CR-TAB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Move to the grid and release: not over a tab, nothing.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 300 TO WS-EX(1)
     MOVE 200 TO WS-EY(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-EX(1) TO WS-EX(2)
     MOVE WS-EY(1) TO WS-EY(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§3.3 a release away from every tab selects nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CR-TAB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Press on the tools tab, release over the ingredients tab (150, 200): the ingredients tab (11) is selected.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 150 TO WS-EX(1)
     MOVE 400 TO WS-EY(1)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE WS-EX(1) TO WS-EX(2)
     MOVE WS-EY(1) TO WS-EY(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 300 TO WS-EX(1)
     MOVE 400 TO WS-EY(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-EX(1) TO WS-EX(2)
     MOVE WS-EY(1) TO WS-EY(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-7§3.3 pressing on the tools tab and releasing over the ingredients tab selects the ingredients tab (11)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE CR-TAB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> A click on the GUI point (WS-D1, WS-D2) (GUI scale 2).
 CLICK-GUI.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     COMPUTE WS-EX(1) = WS-D1 * 2
     COMPUTE WS-EY(1) = WS-D2 * 2
     MOVE WS-EX(1) TO WS-EX(2) WS-EX(3)
     MOVE WS-EY(1) TO WS-EY(2) WS-EY(3)
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(2)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> The tab boxes (26 x 32 overlays) as "Sx:y " (selected swatch) or "Nx:y ".
 TAB-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-W(WS-I) = 26 AND SM-W-H(WS-I) = 32
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             IF SM-W-ARG(WS-I) = SW-SELECTED
                 STRING "S" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             ELSE
                 STRING "N" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     .

*> Slot widgets: the hotbar arguments 0 and 8 and the grid arguments 901 and 945 as "argument@x:y ", in argument order.
 SLOT-LIST.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 945
         IF WS-N = 0 OR WS-N = 8 OR WS-N = 901 OR WS-N = 945
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
                 IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-N
                     MOVE SM-W-ARG(WS-I) TO WS-E3
                     MOVE SM-W-X(WS-I) TO WS-E1
                     MOVE SM-W-Y(WS-I) TO WS-E2
                     STRING FUNCTION TRIM(WS-E3) "@" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-7-RELEASE.

 COPY CLTEST.
