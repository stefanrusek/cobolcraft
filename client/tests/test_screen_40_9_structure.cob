*> Test US12-client (spec 002; docs/protocol/40-menus-9-block-editor-screens.md section 5, 40-menus-x1-continuation.md section 5): the structure block editor through the real screen stack at GUI 320 x 240
*> (cx 160). Opened by using a structure_block with creative and level 2; the boxes and buttons shown depend on the mode (SAVE: name, position, size, SAVE, DETECT, include entities, show air; LOAD:
*> name, position, integrity, seed, LOAD, include entities, strict, mirror, four rotations, show bounding box); the mode cycle SAVE, LOAD, CORNER changes the entity at once; the name box filters
*> typed characters; SAVE sends Set Structure Block 0x3C with update type SAVE_AREA from the boxes; Cancel restores the initial flags and mode and sends nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-9-STRUCTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-HEX                 PIC X(1024).
 01 WS-X                   BINARY-LONG VALUE 1.
 01 WS-Y                   BINARY-LONG VALUE 2.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-KEYB                PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
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
     MOVE 2 TO PL-PERM
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     MOVE "structure_block" TO WS-KEYB
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-9§5 using a structure block with creative and level 2 opens the form screen" TO TL-CASE
     MOVE SCR-FORM TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE "T" TO TL-MODE
     PERFORM BOXES
     MOVE "acceptance US12 40-x1§5 SAVE mode: name (8, 40, 300), position and size boxes (8, 88, 168 at y 80 and 120), mode, SAVE, DETECT, include entities, show air, Done and Cancel" TO TL-CASE
     MOVE "F8:40:300x20 F8:80:80x20 F88:80:80x20 F168:80:80x20 F8:120:80x20 F88:120:80x20 F168:120:80x20 B6:185:50x20 B264:185:50x20 B264:120:50x20 B264:160:50x20 B264:80:50x20 B6:210:150x20 B164:210:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The name box filter: a:b/c is typed whole (a, colon, b, slash, c), upper case and a second colon are refused.
     MOVE 50 TO WS-D1
     MOVE 50 TO WS-D2
     PERFORM CLICK-GUI
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4)
     MOVE 104 TO WS-A(1)
     MOVE 111 TO WS-A(2)
     MOVE 117 TO WS-A(3)
     MOVE 115 TO WS-A(4)
     MOVE 4 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3)
     MOVE 65 TO WS-A(1)
     MOVE 101 TO WS-A(2)
     MOVE 32 TO WS-A(3)
     MOVE 3 TO WS-N
     PERFORM FRAME
     MOVE SPACES TO TL-OBSERVED
     MOVE EF-TEXT(1)(1:EF-LEN(1)) TO TL-OBSERVED
     MOVE "acceptance US12 40-x1§5 the name box refuses upper case and a space: typing hous, A, e and a space leaves house" TO TL-CASE
     MOVE "house" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Position Y 1, size X 5, then SAVE.
     MOVE 100 TO WS-D1
     MOVE 90 TO WS-D2
     PERFORM CLICK-GUI
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 49 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE 20 TO WS-D1
     MOVE 130 TO WS-D2
     PERFORM CLICK-GUI
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 53 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 270 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "acceptance US12 40-x1§5 SAVE sends Set Structure Block 0x3C: update SAVE_AREA (1), mode SAVE (0), name house, offset 0 1 0, size 5 0 0, mirror 0, rotation 0, empty data, integrity 1.0, seed 0, flags 4" TO TL-CASE
     MOVE "3c0000004000003002010005686f7573650001000500000000003f8000000004" TO TL-EXPECTED
     MOVE WS-HEX(1:64) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Reopen: the mode cycle to LOAD shows the LOAD layout; toggles, mirror, rotation change the entity at once; Cancel restores them and sends nothing.
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE 20 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM BOXES
     MOVE "acceptance US12 40-x1§5 LOAD mode: name, position, integrity and seed boxes, the mode button, LOAD, include entities, strict, mirror, four rotations (the 0 button inactive), show bounding box, Done, Cancel" TO TL-CASE
     MOVE "F8:40:300x20 F8:80:80x20 F88:80:80x20 F168:80:80x20 F8:120:80x20 F88:120:80x20 B6:185:50x20 B264:185:50x20 B264:160:50x20 B264:120:50x20 B140:185:40x20 B58:185:40x20 B99:185:40x20 B181:185:40x20 B222:185:40x20 B264:80:50x20 B6:210:150x20 B164:210:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 280 TO WS-D1
     MOVE 170 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 280 TO WS-D1
     MOVE 130 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 280 TO WS-D1
     MOVE 90 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 160 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     MOVE 200 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-x1§5 toggles, mirror and rotation change the entity at once: flags 4 with include, strict and show bounding box toggled is 9, mirror 1, rotation 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1 * 10000 + 2 * 100 + 9
     COMPUTE TL-OBSERVED-N = EB-ST-MIRROR * 10000 + EB-ST-ROTATION * 100 + EB-ST-FLAGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 20 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM CLICK-GUI
     MOVE "acceptance US12 40-x1§5 the mode cycle LOAD, CORNER, SAVE: two clicks from LOAD give SAVE" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EB-ST-MODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 0 TO EB-ST-MODE
     MOVE 3 TO EB-ST-MODE
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE 1 TO WS-I
     MOVE "xyz" TO EF-TEXT(1)
     MOVE 3 TO EF-LEN(1)
     MOVE "abc" TO EF-TEXT(5)
     MOVE 3 TO EF-LEN(5)
     MOVE "1.5" TO EF-TEXT(8)
     MOVE 3 TO EF-LEN(8)
     MOVE "-7" TO EF-TEXT(2)
     MOVE 2 TO EF-LEN(2)
     MOVE 2 TO WS-N
     MOVE 3 TO EB-ST-MODE
     MOVE "data" TO EF-TEXT(10)
     MOVE 4 TO EF-LEN(10)
     MOVE 9 TO WS-N
     MOVE 4 TO EB-ST-FLAGS
     MOVE 1 TO EB-ST-INIT-MODE
     MOVE 1 TO EB-ST-INIT-MIRROR
     MOVE 3 TO EB-ST-INIT-ROT
     MOVE 12 TO EB-ST-INIT-FLAGS
     PERFORM FRAME
     MOVE 200 TO WS-D1
     MOVE 220 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-x1§5 Cancel restores the initial mode, mirror, rotation and flags and closes with no packet" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + 1 * 10000 + 3 * 100 + 12
     COMPUTE TL-OBSERVED-N = EB-ST-MODE * 1000000 + EB-ST-MIRROR * 10000 + EB-ST-ROTATION * 100 + EB-ST-FLAGS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-x1§5 Cancel closes the screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     CALL "CONTENT-CLOSE"
     STOP RUN.

 FRAME.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     .

 FLUSH.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
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

*> TL-OBSERVED: the field overlays (F) and the buttons (B) as "Fx:y:wxh " in widget order.
 BOXES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF (SM-W-KIND(WS-I) = WK-OVERLAY AND SM-W-ARG(WS-I) = SW-FIELD) OR SM-W-KIND(WS-I) = WK-BUTTON
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             IF SM-W-KIND(WS-I) = WK-BUTTON
                 STRING "B" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             ELSE
                 STRING "F" FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-9-STRUCTURE.

 COPY CLTEST.
