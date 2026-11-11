*> Test US12-client (spec 002; docs/protocol/40-menus-9-block-editor-screens.md 2.1): the use hook on the world screen through the real control path: looking at a command block in reach with creative and level 2,
*> the right button opens the command block screen; without the permission, or at a plain block, the world screen stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMDBLOCK-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEYB                PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 9.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-N                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG VALUE 15.
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
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
*>   The world replica takes the states of the open content set (STATE-LIMIT): give the set a state count so the command block state is no void.
     MOVE 1 TO CT-OPEN
     MOVE 30000 TO CT-STATE-COUNT
     MOVE "command_block" TO WS-KEYB
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     MOVE 1 TO PL-MODE
     MOVE 2 TO PL-PERM
     MOVE 90 TO PL-PITCH
     MOVE "N" TO TL-MODE
*>   A plain block under the feet: nothing opens.
     MOVE 0 TO WS-N
     PERFORM RIGHT-CLICK
     MOVE "acceptance US12 40-9§2.1 using a plain block with creative and level 2 leaves the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The command block under the feet, without permission, then with it.
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO PL-PERM
     PERFORM RIGHT-CLICK
     MOVE "acceptance US12 40-9§2.1 a command block used without the game master permission leaves the world screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PL-PERM
     PERFORM RIGHT-CLICK
     MOVE "acceptance US12 40-9§2.1 a command block under the crosshair used with creative and level 2 opens the command block screen at its position (0, 9, 0)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-CMDBLOCK * 1000 + 9
     COMPUTE TL-OBSERVED-N = SM-SCREEN * 1000 + EB-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

 RIGHT-CLICK.
     CALL "TEST-STEP" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     CALL "TEST-STEP" USING CLIENT-STATE
     INITIALIZE WS-EVENTS
     MOVE CC-EV-BUTTON-UP TO WS-KIND(1)
     MOVE CC-BUTTON-RIGHT TO WS-A(1)
     MOVE 1 TO WS-N
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-N WS-MS
     .

 END PROGRAM TEST-CMDBLOCK-WORLD.

 COPY CLTEST.
