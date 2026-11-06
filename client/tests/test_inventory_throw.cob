*> Implementation test of the inventory-screen throws on the client (tasks T1087; standin-content
*> §9.1 "Inventory-screen throw" and "Inventory screen closed while carrying"; client-surface §3
*> controls; 05c Container Click 0x12, Container Close 0x13; client/src/screens/inventory.cob):
*> Q over a slot sends Container Click THROW (4) button 0, Ctrl+Q button 1; a left click or the
*> release of a left drag outside the window with a carried stack sends PICKUP (0) slot -999
*> button 0, a right click outside button 1; leaving the screen sends Container Close and puts the
*> carried stack back into the inventory. The client predicts each as the server does
*> (core/src/inventory.cob). Starting items: slots 0 to 7 hold 64 of items 2 to 9, state id 1.
*> Slot -999 is the Short fc19.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 15.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODS                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-PY                  FLOAT-SHORT.
 01 WS-N                   BINARY-LONG.
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
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO IN-CAPTURED
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE "test inventory throw Q over slot 0 sends THROW button 0 and leaves 63" TO TL-CASE
     MOVE 0 TO WS-SLOT WS-MODS
     PERFORM PRESS-Q
     MOVE "12000100000004010000" & "01023f000000 slot 63x2 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw Ctrl+Q over slot 1 sends THROW button 1 and empties it"
         TO TL-CASE
     MOVE 1 TO WS-SLOT
     MOVE CC-MOD-CONTROL TO WS-MODS
     PERFORM PRESS-Q
     MOVE "1200010001010401000100" & "00 slot 0x0 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw Q over an empty slot sends nothing" TO TL-CASE
     MOVE 0 TO WS-MODS
     PERFORM PRESS-Q
     MOVE "slot 0x0 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw Q outside the window sends nothing" TO TL-CASE
     MOVE -1 TO WS-SLOT
     PERFORM PRESS-Q
     MOVE "slot 0x0 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw a left drag from slot 2 released outside the window throws the "
         & "carried stack: PICKUP -999 button 0" TO TL-CASE
     MOVE 2 TO WS-SLOT
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-LEFT TO WS-A(1)
     MOVE WS-PX TO WS-X(1)
     MOVE WS-PY TO WS-Y(1)
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE 2 TO WS-X(1) WS-Y(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE CC-BUTTON-LEFT TO WS-A(2)
     MOVE 2 TO WS-X(2) WS-Y(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     PERFORM OBSERVE
     MOVE "1200010002000001000200" & "0104400000 120001fc1900000000 slot 0x0 cursor 0x0"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw a left click outside the window with a carried stack sends "
         & "PICKUP -999 button 0; without one nothing" TO TL-CASE
     MOVE 3 TO WS-SLOT
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-SLOT WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     PERFORM CLICK-OUTSIDE
     PERFORM CLICK-OUTSIDE
     PERFORM OBSERVE
     MOVE "120001fc1900000000 slot 0x0 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw a right click outside the window sends PICKUP -999 button 1 and "
         & "keeps the rest on the cursor" TO TL-CASE
     MOVE 4 TO WS-SLOT
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-SLOT WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     PERFORM CLICK-OUTSIDE
     PERFORM OBSERVE
     MOVE "120001fc19010000" & "01063f0000 slot 0x0 cursor 63x6" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw closing the screen while carrying sends Container Close and "
         & "puts the stack back into the inventory" TO TL-CASE
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 1 TO WS-SLOT
     PERFORM OBSERVE
     MOVE "1300 slot 63x6 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw closing the screen in creative while carrying sends Set Creative "
         & "Mode Slot of each slot the stack went to, then Container Close" TO TL-CASE
     MOVE 1 TO PL-MODE
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO IN-CAPTURED
     MOVE 5 TO WS-SLOT
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-SLOT WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 2 TO WS-SLOT
     PERFORM OBSERVE
     MOVE "39000240070000 1300 slot 64x7 cursor 0x0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test inventory throw closing the screen tops up a stack of the carried item first, "
         & "then fills an empty slot" TO TL-CASE
     MOVE 0 TO PL-MODE
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO IN-CAPTURED
     MOVE 0 TO WS-SLOT
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-SLOT WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 2 TO PL-SLOT-ITEM(10)
     MOVE 60 TO PL-SLOT-COUNT(10)
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     PERFORM OBSERVE
     MOVE PL-SLOT-COUNT(10) TO WS-E1
     STRING FUNCTION TRIM(WS-TEXT) " slot 9 " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "1300 slot 59x2 cursor 0x0 slot 9 64" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Window position of the centre of slot widget WS-SLOT (WS-PX, WS-PY); (2, 2), outside the
*> window, for slot -1.
 SLOT-POS.
     MOVE 2 TO WS-PX WS-PY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-SLOT AND WS-SLOT >= 0
             COMPUTE WS-PX = (SM-W-X(WS-I) + SM-W-W(WS-I) / 2) * CL-GUI-SCALE
             COMPUTE WS-PY = (SM-W-Y(WS-I) + SM-W-H(WS-I) / 2) * CL-GUI-SCALE
         END-IF
     END-PERFORM.

*> The cursor moved over slot WS-SLOT, then Q down (modifiers WS-MODS) and up, in one frame.
 PRESS-Q.
     PERFORM SLOT-POS
     INITIALIZE WS-EVENTS
     MOVE CC-EV-CURSOR TO WS-KIND(1)
     MOVE WS-PX TO WS-X(1)
     MOVE WS-PY TO WS-Y(1)
     MOVE CC-EV-KEY-DOWN TO WS-KIND(2)
     MOVE CC-EV-KEY-UP TO WS-KIND(3)
     MOVE CC-KEY-Q TO WS-A(2) WS-A(3)
     MOVE WS-MODS TO WS-B(2) WS-B(3)
     MOVE 3 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N
     PERFORM OBSERVE.

*> Button WS-BUTTON down and up at (2, 2), outside the window, in one frame.
 CLICK-OUTSIDE.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE WS-BUTTON TO WS-A(1) WS-A(2)
     MOVE 2 TO WS-X(1) WS-Y(1) WS-X(2) WS-Y(2)
     MOVE 2 TO WS-N
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-N.

*> What the server received, then the slot WS-SLOT (when 0 to 35) and the cursor as
*> "<count>x<item>".
 OBSERVE.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-E1 WS-E2
     IF WS-SLOT >= 0
         MOVE PL-SLOT-COUNT(WS-SLOT + 1) TO WS-E1
         MOVE PL-SLOT-ITEM(WS-SLOT + 1) TO WS-E2
     END-IF
     STRING FUNCTION TRIM(WS-TEXT) " slot " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-CARRIED-COUNT TO WS-E1
     MOVE PL-CARRIED-ITEM TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " cursor " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY-THROW.
 COPY CLTEST.
