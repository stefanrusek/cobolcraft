*> Test US12-client (spec 002, step 3 of the UI7 follow-up; docs/protocol/40-menus-8-book-and-sign-editors.md sections 1.1, 3, 4, 7): the writable book editor through the real screen stack.
*> Using a writable_book (right button in the world, a standard content set open so the item exists) opens the book screen by the client's own prediction (GUI 320 x 240, L = 64): typed text
*> goes to the page, Page Down turns to a new page, Done sends Edit Book (05c 0x18: slot, pages, no title) and closes; the Sign button opens the title screen: Enter with a title sends the
*> pages with the trimmed title; Escape closes without any packet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-8-BOOK.
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
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-KEY16               PIC X(16).
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
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
     MOVE 0 TO PL-MODE
*>   A standard content set (an empty Update Tags opens it) holds the item writable_book.
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     MOVE "writable_book  " TO WS-KEY16
     CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY16 WS-ITEM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-8§1.1 the standard set has the item writable_book (a non-zero id)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ITEM > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-ITEM TO PL-SLOT-ITEM(1)
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE 0 TO PL-HELD
*>   Right button: the book screen opens.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE CC-BUTTON-RIGHT TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE "acceptance US12 40-8§1.1 using a writable book in the world opens the book editor on the client's own (no server message)" TO TL-CASE
     MOVE SCR-BOOK TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Type Hi, Page Down (a new page), type x.
     MOVE 2 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 72 TO WS-A(1)
     MOVE 105 TO WS-A(2)
     PERFORM FRAME
     MOVE 1 TO WS-N
     MOVE "T" TO TL-MODE
     PERFORM TEXT-LINES
     MOVE "acceptance US12 40-8§3.2 the typed page text is drawn at the text origin (99, 32)" TO TL-CASE
     MOVE "99:32=Hi;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE 267 TO WS-A(1)
     PERFORM FRAME
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 120 TO WS-A(1)
     PERFORM FRAME
     PERFORM TEXT-LINES
     MOVE "acceptance US12 40-8§3.3 Page Down turned to a new page: it shows x" TO TL-CASE
     MOVE "99:32=x;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Done: click the Done button at (162, 196): Edit Book with 2 pages, no title; the world screen.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 170 TO WS-D1
     MOVE 205 TO WS-D2
     PERFORM CLICK-GUI
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "acceptance US12 40-8§3.3 Done sends Edit Book 18: slot 0, 2 pages Hi and x, no title" TO TL-CASE
     MOVE "180002024869017800" TO TL-EXPECTED
     MOVE WS-HEX(1:18) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-8§3.3 Done closes the editor: the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Sign: open again, type A, click Sign (60, 196), type a title, Enter.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE CC-BUTTON-RIGHT TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 65 TO WS-A(1)
     PERFORM FRAME
     MOVE 70 TO WS-D1
     MOVE 205 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 3 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3)
     MOVE 32 TO WS-A(1)
     MOVE 72 TO WS-A(2)
     MOVE 105 TO WS-A(3)
     PERFORM FRAME
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-8§4 the Sign button opens the title screen (mode 1) and the typed title is kept: 1 and ' Hi'" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE BE-MODE TO WS-E1
     STRING FUNCTION TRIM(WS-E1) ":" BE-TITLE(1:BE-TITLE-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1: Hi" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 1 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE 257 TO WS-A(1)
     PERFORM FRAME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "acceptance US12 40-8§4 Enter with the title sends Edit Book with the pages as they are and the trimmed title Hi: 18 00 01 01 41 01 02 48 69" TO TL-CASE
     MOVE "180001014101024869" TO TL-EXPECTED
     MOVE WS-HEX(1:18) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Escape closes with no packet.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE CC-BUTTON-RIGHT TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 90 TO WS-A(1)
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-ESCAPE TO WS-A(1)
     PERFORM FRAME
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "acceptance US12 40-8§3.3 Escape discards: no packet is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-HEX(1:6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-8§3.3 and the screen is the world (not the pause menu)" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The editing keys and the page and title buttons: abc, Left, Backspace (ac), Delete (a), Enter (a LF), Up, Right, Down, Home, End, then z gives a LF z; Page Down and Page Up keep it.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
     MOVE CC-BUTTON-RIGHT TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE 3 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3)
     MOVE 97 TO WS-A(1)
     MOVE 98 TO WS-A(2)
     MOVE 99 TO WS-A(3)
     PERFORM FRAME
     MOVE 263 TO WS-D1
     PERFORM PRESS
     MOVE 259 TO WS-D1
     PERFORM PRESS
     MOVE 261 TO WS-D1
     PERFORM PRESS
     MOVE 257 TO WS-D1
     PERFORM PRESS
     MOVE 265 TO WS-D1
     PERFORM PRESS
     MOVE 262 TO WS-D1
     PERFORM PRESS
     MOVE 264 TO WS-D1
     PERFORM PRESS
     MOVE 268 TO WS-D1
     PERFORM PRESS
     MOVE 269 TO WS-D1
     PERFORM PRESS
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 122 TO WS-A(1)
     PERFORM FRAME
     MOVE 267 TO WS-D1
     PERFORM PRESS
     MOVE 266 TO WS-D1
     PERFORM PRESS
     MOVE "T" TO TL-MODE
     PERFORM TEXT-LINES
     MOVE "acceptance US12 40-8§2.5 the editing keys (Left, Backspace, Delete, Enter, Up, Right, Down, Home, End) and the page keys give the page a, line feed, z: lines a at y 32 and z at y 41" TO TL-CASE
     MOVE "99:32=a;99:41=z;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-D1
     MOVE 205 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 81 TO WS-A(1)
     PERFORM FRAME
     MOVE 2 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 98 TO WS-A(1)
     MOVE 99 TO WS-A(2)
     PERFORM FRAME
     MOVE 259 TO WS-D1
     PERFORM PRESS
     MOVE 170 TO WS-D1
     MOVE 205 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-8§4 Backspace in the title and Cancel: back to the pages (mode 0) with the title Qb kept" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE BE-MODE TO WS-E1
     STRING FUNCTION TRIM(WS-E1) ":" BE-TITLE(1:BE-TITLE-LEN) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0:Qb" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> A click on the GUI point (WS-D1, WS-D2) (GUI scale 2).
 PRESS.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE WS-D1 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     .

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

*> TL-OBSERVED: each label drawn at the text origin of the page (x 99, y 32 to 158) as "x:y=text;".
 TEXT-LINES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) > 0 AND SM-W-X(WS-I) = 99 AND SM-W-Y(WS-I) >= 32
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "=" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) ";" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-8-BOOK.

 COPY CLTEST.
