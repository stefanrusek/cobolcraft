*> Test US12-client (spec 002, step 3 of the UI7 follow-up; docs/protocol/40-menus-8-book-and-sign-editors.md sections 1.2, 6.2, 6.3, 7): the sign editor through the real screen stack.
*> Open Sign Editor (05a 0x3D: position, side) opens the sign screen (GUI 320 x 240): the title Edit Sign Message at y 40, the four lines centred on x 160 at y 70, 80, 90, 100, the
*> Done button (60, 204, 200 x 20); typed characters go to the current line, Down and Enter select the next line (cursor at its end), Escape closes the screen and sends Sign Update
*> (05c 0x3E) with the four lines; Done does the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-8-SIGN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-TITLE               PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
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
     MOVE 1 TO PL-MODE
     MOVE "N" TO TL-MODE
*>   The packet opens the screen.
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 1 TO WS-FRONT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FRONT
     MOVE 61 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "acceptance US12 40-8§1.2 Open Sign Editor (05a 0x3D) opens the sign editor screen" TO TL-CASE
     MOVE SCR-SIGN TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Typing hi on line 0, Down, x on line 1.
     MOVE 2 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 104 TO WS-A(1)
     MOVE 105 TO WS-A(2)
     PERFORM FRAME
     MOVE 1 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE 264 TO WS-A(1)
     PERFORM FRAME
     MOVE 1 TO WS-N
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 120 TO WS-A(1)
     PERFORM FRAME
     MOVE "T" TO TL-MODE
     PERFORM LABELS
     MOVE "acceptance US12 40-8§6.3 the screen shows the title at y 40 and the lines hi and x centred on x 160 (y 70 and 80)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE "Edit Sign Message" TO WS-TITLE
     MOVE 17 TO WS-N
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TITLE WS-N WS-I
     COMPUTE WS-X = 160 - WS-I / 2
     MOVE WS-X TO WS-E1
     MOVE "hi" TO WS-TITLE
     MOVE 2 TO WS-N
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TITLE WS-N WS-I
     COMPUTE WS-X = 160 - WS-I / 2
     MOVE WS-X TO WS-E2
     STRING FUNCTION TRIM(WS-E1) ":40=Edit Sign Message;" FUNCTION TRIM(WS-E2) ":70=hi;" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "x" TO WS-TITLE
     MOVE 1 TO WS-N
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TITLE WS-N WS-I
     COMPUTE WS-X = 160 - WS-I / 2
     MOVE WS-X TO WS-E1
     STRING FUNCTION TRIM(TL-EXPECTED) FUNCTION TRIM(WS-E1) ":80=x;" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Escape closes and sends Sign Update.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 1 TO WS-N
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-ESCAPE TO WS-A(1)
     PERFORM FRAME
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-8§6.2 Escape closes the sign editor: the world screen (not the pause menu)" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-8§7 closing sends Sign Update: 3e, the position (1, 2, 3), hi, x, two empty lines, the front side" TO TL-CASE
     MOVE "3e00000040000030020268690178" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HEX(1:28) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-8§7 the packet ends with the empty lines and side 1" TO TL-CASE
     MOVE "000001" TO TL-EXPECTED
     MOVE WS-HEX(29:6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> One frame with the first WS-N events, then the screen is built.
 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

*> TL-OBSERVED: each label as "x:y=text;".
 LABELS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) > 0
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "=" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) ";" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-8-SIGN.

 COPY CLTEST.
