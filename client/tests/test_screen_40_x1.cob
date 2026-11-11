*> Test US12-client (spec 002 T3314 to T3321; docs/protocol/40-menus-x1-continuation.md sections 1 to 4, the continuation of 40-9): the command block screen's layout of section 4.4 and worked example
*> 4.5 at GUI 320 x 240 (cx 160), the cycle order of 4.6 (TRUE first: the first click on a FALSE button gives TRUE; the mode list has three entries and wraps), the wire limit of 4.7 (the command
*> is sent whole) and the opening rule of section 2 (creative and level 2). The screens other than the command block are not drawn (their packets are tested in test_screen_40_9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-X1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
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
 01 WS-ACTION              BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 1 TO PL-MODE
     MOVE 2 TO PL-PERM
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     MOVE SPACES TO WS-KEYB
     MOVE "chain_command_block" TO WS-KEYB
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     MOVE "N" TO TL-MODE
     MOVE 1 TO PL-PERM
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 40-x1§2 using a chain command block with level 1 opens nothing" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PL-PERM
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 40-x1§2 with creative and level 2 a chain command block opens the command block screen" TO TL-CASE
     MOVE SCR-CMDBLOCK TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
*>   4.4 and 4.5 example 1: the boxes (overlays) and the buttons as "x:y:wxh".
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY OR SM-W-KIND(WS-I) = WK-BUTTON
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-x1§4 the command box (10, 50), the previous-output box (10, 135, 276 wide), the output button (290, 135), mode, conditional and automatic (6, 110, 214 at y 165, 100 x 20), Done (6, 192) and Cancel (164, 192)" TO TL-CASE
     MOVE "10:50:300x20 10:135:276x20 290:135:20x20 6:165:100x20 110:165:100x20 214:165:100x20 6:192:150x20 164:192:150x20 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   4.6 the cycles: the mode list has three entries and wraps (REDSTONE to SEQUENCE); a FALSE-initial boolean goes to TRUE first.
     MOVE ACT-CMD-MODE TO WS-ACTION
     CALL "CMDBLOCK-ACTION" USING CLIENT-STATE WS-ACTION
     MOVE EB-MODE TO WS-E1
     MOVE ACT-CMD-MODE TO WS-ACTION
     CALL "CMDBLOCK-ACTION" USING CLIENT-STATE WS-ACTION
     MOVE EB-MODE TO WS-E2
     CALL "CMDBLOCK-ACTION" USING CLIENT-STATE WS-ACTION
     CALL "CMDBLOCK-ACTION" USING CLIENT-STATE WS-ACTION
     MOVE EB-MODE TO WS-E3
     MOVE ACT-CMD-TYPE TO WS-ACTION
     CALL "CMDBLOCK-ACTION" USING CLIENT-STATE WS-ACTION
     MOVE EB-COND TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-x1§4.6 the mode starts at REDSTONE (2) and cycles to SEQUENCE (0), AUTO (1), then two more clicks wrap through REDSTONE to SEQUENCE (0); the first click on the FALSE type button gives TRUE (1)" TO TL-CASE
     MOVE "0101" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

 END PROGRAM TEST-SCREEN-40-X1.

 COPY CLTEST.
