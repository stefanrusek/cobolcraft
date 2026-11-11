*> Test US12-client (spec 002; docs/protocol/40-menus-9-block-editor-screens.md sections 6 and 7, 40-menus-x1-continuation.md sections 6 and 7): the jigsaw block and test block editors through the real
*> screen stack at GUI 320 x 240 (cx 160). Using the block with creative and level 2 opens the screen (no block entity copy is kept, so the boxes start with the entity defaults). Test block: the mode
*> cycle START, LOG, FAIL, ACCEPT shows the message box (8, 80, 240 x 20) from LOG on; Done sends Set Test Block 0x3D (position, mode, the box text) and closes; Cancel closes with no packet.
*> Jigsaw: the six boxes, focus by click, typing, Done and Generate active only while the pool, name and target are valid identifiers; Done sends 0x3B, Generate 0x3B then 0x1B with the levels
*> of the slider (a click at x 56 gives 0.5 and 10 levels) and the keep jigsaws flag.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-9-FORMS.
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
     MOVE "N" TO TL-MODE
*>   ---- the test block ----
     MOVE "test_block" TO WS-KEYB
     PERFORM STATE-OF
     MOVE 1 TO PL-PERM
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 40-9§7 using a test block with level 1 opens nothing" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PL-PERM
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 40-9§7 with creative and level 2 a test block opens the form screen" TO TL-CASE
     MOVE SCR-FORM TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE "T" TO TL-MODE
     PERFORM BOXES
     MOVE "acceptance US12 40-x1§7 in START mode there is no message box: only the mode button (6, 185, 50 x 20), Done (6, 210) and Cancel (164, 210)" TO TL-CASE
     MOVE "B6:185:50x20 B6:210:150x20 B164:210:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM BOXES
     MOVE "acceptance US12 40-x1§7 clicking the mode button (LOG) shows the message box at (8, 80, 240 x 20)" TO TL-CASE
     MOVE "F8:80:240x20 B6:185:50x20 B6:210:150x20 B164:210:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-D1
     MOVE 90 TO WS-D2
     PERFORM CLICK-GUI
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 104 TO WS-A(1)
     MOVE 105 TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 26 TO WS-D1
     MOVE 220 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§7 Done sends Set Test Block 0x3D: position (1, 2, 3), mode 1 (LOG), message hi" TO TL-CASE
     MOVE "3d000000400000300201026869" TO TL-EXPECTED
     MOVE WS-HEX(1:26) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-9§7 and the screen closes: the world" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Cancel sends nothing.
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 170 TO WS-D1
     MOVE 220 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-9§7 Cancel closes the test block screen with no packet" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-HEX(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- the jigsaw ----
     MOVE "jigsaw" TO WS-KEYB
     PERFORM STATE-OF
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N
     PERFORM FRAME
     PERFORM BOXES
     MOVE "acceptance US12 40-x1§6 the jigsaw boxes (pool, name, target, final state 300 x 20 at x 7; priorities 98 x 20 at x 7 and 110) and the buttons (slider, keep, Generate, Done, Cancel)" TO TL-CASE
     MOVE "F7:20:300x20 F7:55:300x20 F7:90:300x20 F7:125:300x20 F7:160:98x20 F110:160:98x20 B6:185:100x20 B110:185:100x20 B214:185:100x20 B6:210:150x20 B164:210:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Pool box: click it, Backspace over minecraft:empty (15), type a space: invalid, Done does nothing.
     MOVE 30 TO WS-D1
     MOVE 30 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         INITIALIZE WS-EVENTS
         MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
         MOVE CC-KEY-BACKSPACE TO WS-A(1)
         MOVE 1 TO WS-N
         PERFORM FRAME
     END-PERFORM
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 32 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 20 TO WS-D1
     MOVE 220 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§6 with the pool box ' ' (not an identifier) Done and Generate are inactive: Done sends nothing and the screen stays the form" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) ":" WS-HEX(1:4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "25:" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Backspace the space, type p: pool "p" is valid (minecraft:p). Set the slider (click x 56: 10 levels) and press Generate.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-BACKSPACE TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1)
     MOVE 112 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE 96 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-x1§6 the slider: a click at x 96 gives (96 - 6 - 4) / 92 = 0.935 and floor(18.7) = 18 levels" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE EB-LEVELS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 56 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 260 TO WS-D1
     MOVE 195 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "acceptance US12 40-x1§6 Generate sends Set Jigsaw Block (pool minecraft:p, final state minecraft:air, rollable, priorities 0) then Jigsaw Generate with 10 levels, keep true" TO TL-CASE
     MOVE "3b00000040000030020f6d696e6563726166743a656d7074790f6d696e6563726166743a656d7074790b6d696e6563726166743a700d6d696e6563726166743a61697208726f6c6c61626c650000 1b00000040000030020a01" TO TL-EXPECTED
     MOVE WS-HEX(1:179) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

*> The block key WS-KEYB's default state in WS-STATE.
 STATE-OF.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     .

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

*> TL-OBSERVED: the field overlays (F, swatch field) and the buttons (B) as "Fx:y:wxh " in widget order.
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

 END PROGRAM TEST-SCREEN-40-9-FORMS.

 COPY CLTEST.
