*> Acceptance test US9-3 / CC-0006 (spec 002 FR-024, FR-025, FR-028; SC-005; 40-menus-7 §3.3 the creative drop; 09 §3.2 row 0x39): in creative the
*> inventory screen's cursor stack is the client's, so a left click or the release of a drag outside the sheet sends the creative drop, Set
*> Creative Mode Slot with slot -1 and the whole stack (ffff), and empties the cursor; a right click outside drops one item and keeps the rest;
*> a release inside the sheet sends nothing; the survival throw stays Container Click PICKUP at -999 (test_inventory_throw).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US9-CREATIVE-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-AT-X                FLOAT-SHORT.
 01 WS-AT-Y                FLOAT-SHORT.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 1 TO PL-MODE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO IN-CAPTURED
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 2 TO WS-AT-X WS-AT-Y
     PERFORM CLICK-AT
     MOVE "acceptance US9-3 creative: a left click outside the sheet sends Set Creative Mode Slot -1 with the whole stack, the cursor empty"
         TO TL-CASE
     PERFORM OBSERVE
     MOVE "39ffff05030000 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK-AT
     MOVE "acceptance US9-3 creative: a right click outside drops one item and keeps 4 on the cursor" TO TL-CASE
     PERFORM OBSERVE
     MOVE "39ffff01030000 cursor 4x3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE 480 TO WS-AT-X
     MOVE 80 TO WS-AT-Y
     PERFORM CLICK-AT
     MOVE "acceptance US9-3 creative: a release inside the sheet sends no drop and keeps the cursor" TO TL-CASE
     PERFORM OBSERVE
     MOVE "cursor 5x3" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-CARRIED-COUNT PL-CARRIED-ITEM
     STOP RUN.

*> Button WS-BUTTON down and up at (WS-AT-X, WS-AT-Y) window pixels in one frame.
 CLICK-AT.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-BUTTON TO WS-A(1) WS-A(2)
     MOVE WS-AT-X TO WS-X(1) WS-X(2)
     MOVE WS-AT-Y TO WS-Y(1) WS-Y(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N.

 OBSERVE.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     STRING FUNCTION TRIM(WS-TEXT) " cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US9-CREATIVE-THROW.
 COPY CLTEST.
