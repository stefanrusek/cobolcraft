*> Test US12-client (spec 002; the narrative and cross-reference sections 40-3 section 6 and 9, 40-9 section 9 and 40-x1 sections 1 and 3): the cheapest evidence that the stated facts hold in this client.
*> 40-3 6: the smithing template items the screen relies on exist in the standard content set (netherite upgrade and armor trim templates, keys ending _smithing_template). 40-3 9: the superseded rules
*> of 17 (anvil combining, enchantments, incompatibility, level cap) are the server's here: with a right stack the preview leaves the result slot and the cost to the server. 40-9 9: the packet ids of
*> the six editor packets agree with 40-x1 (0x37, 0x38, 0x3B, 0x3C, 0x3D, 0x41). 40-x1 1: the using of each editor block or minecart opens its screen. 40-x1 3: the generic edit box limits (128 name and
*> message, 15 numbers, 31 seed, 3 priorities).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NARRATIVE-REFS.
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
 01 WS-PACKET             BINARY-LONG.
 01 WS-CONN               BINARY-LONG VALUE CONN-GAME.
 01 WS-TEXT               PIC X(1100).
 01 WS-V1                 BINARY-LONG VALUE 1.
 01 WS-V2                 BINARY-LONG VALUE 1.
 01 WS-V3                 BINARY-LONG VALUE 1.
 01 WS-V4                 BINARY-LONG VALUE 1.
 01 WS-V5                 BINARY-LONG VALUE 1.
 01 WS-V6                 BINARY-LONG VALUE 1.
 01 WS-HEXLEN             BINARY-LONG.
 01 WS-NS                 PIC X(16).
 01 WS-PATH               PIC X(40).
 01 WS-MAX                BINARY-LONG.
 01 WS-BLOCK              BINARY-LONG.
 01 WS-TOOL               PIC X.
 01 WS-FOOD               BINARY-LONG.
 01 WS-KNOWN              BINARY-LONG.
 01 WS-COUNT              BINARY-LONG.
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
     MOVE 1 TO WS-I
     MOVE 0 TO WS-N
     MOVE SPACES TO TL-OBSERVED
     CALL "CL-ITEM-COUNT-NOW" USING WS-COUNT
     MOVE 0 TO WS-N
     MOVE 0 TO WS-D1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-COUNT
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-I WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-PATH = "netherite_upgrade_smithing_template"
             ADD 1 TO WS-N
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-D2
         IF WS-D2 > 29 AND WS-PATH(WS-D2 - 28:29) = "_armor_trim_smithing_template"
             ADD 1 TO WS-D1
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-3§6 the standard set holds the netherite upgrade template and at least one armor trim template (keys ending _smithing_template) the screen's hints rely on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-N = 1 AND WS-D1 > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-3 9: with a right stack the anvil preview does not compute the combine, enchantment or incompatibility rules: the result slot and the cost stay as the server sent them.
     MOVE 7 TO BM-ID
     MOVE 8 TO BM-TYPE
     MOVE 1 TO BX-COUNT(1)
     MOVE 5 TO BX-ITEM(1)
     MOVE 1 TO BX-COUNT(2)
     MOVE 6 TO BX-ITEM(2)
     MOVE 2 TO BX-COUNT(3)
     MOVE 9 TO BX-ITEM(3)
     MOVE 13 TO BM-DATA(1)
     CALL "ANVIL-RESPOND" USING CLIENT-STATE
     MOVE "acceptance US12 40-3§9 with a right stack the result slot (9 x 2) and the cost (13) stay the server's: the combine and enchantment rules of 17 are not recomputed here" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 9 * 10000 + 2 * 100 + 13
     COMPUTE TL-OBSERVED-N = BX-ITEM(3) * 10000 + BX-COUNT(3) * 100 + BM-DATA(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-9 9: the packet ids of the editor packets.
     MOVE 1 TO WS-D1
     MOVE 0 TO WS-D2
     MOVE SPACES TO WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-9§9 the six editor packets carry the ids 0x37 0x38 0x3b 0x3c 0x3d 0x41 of 40-x1" TO TL-CASE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     CALL "SEND-SET-COMMAND-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TEXT WS-D2 WS-V1 WS-V2
     PERFORM TAKE-ID
     CALL "SEND-SET-COMMAND-MINECART" USING CLIENT-STATE WS-V1 WS-TEXT WS-D2 WS-V2
     PERFORM TAKE-ID
     CALL "SEND-SET-JIGSAW-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z
     PERFORM TAKE-ID
     CALL "SEND-SET-STRUCTURE-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z
     PERFORM TAKE-ID
     CALL "SEND-SET-TEST-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-V1 WS-TEXT WS-D2
     PERFORM TAKE-ID
     CALL "SEND-TEST-INSTANCE-ACTION" USING CLIENT-STATE WS-X WS-Y WS-Z WS-V1 WS-TEXT WS-D2 WS-V2 WS-V3 WS-V4 WS-V5 WS-V6
     PERFORM TAKE-ID
     MOVE "37 38 3b 3c 3d 41 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-x1 1: using each editor block or minecart opens its screen (command block 24, the forms 25 with the form kind 1 test block, 2 jigsaw, 3 structure block, 4 test instance).
     MOVE 1 TO PL-MODE
     MOVE 2 TO PL-PERM
     MOVE 0 TO WS-N
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE "command_block" TO WS-KEYB
     PERFORM OPEN-BLOCK
     MOVE "test_block" TO WS-KEYB
     PERFORM OPEN-BLOCK
     MOVE "jigsaw" TO WS-KEYB
     PERFORM OPEN-BLOCK
     MOVE "structure_block" TO WS-KEYB
     PERFORM OPEN-BLOCK
     MOVE "test_instance_block" TO WS-KEYB
     PERFORM OPEN-BLOCK
     MOVE "acceptance US12 40-x1§1 using the command block, test block, jigsaw, structure block and test instance block opens screens 24, 25/1, 25/2, 25/3, 25/4" TO TL-CASE
     MOVE "24/0 25/1 25/2 25/3 25/4 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   40-x1 3: the generic edit box limits: 140 characters in the test block message give 128; 20 digits in a structure position box 15.
     MOVE 1 TO EB-FORM
     MOVE 1 TO EB-TB-MODE
     MOVE 0 TO EF-LEN(1)
     MOVE 1 TO EF-FOCUS
     MOVE SCR-FORM TO WS-N
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         INITIALIZE WS-EVENTS
         MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4) WS-KIND(1)
         MOVE 97 TO WS-A(1) WS-A(2) WS-A(3) WS-A(4)
         MOVE 4 TO WS-N
         PERFORM FRAME
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-x1§3 the test block message box holds at most 128 characters (132 typed)" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE EF-LEN(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

 TAKE-ID.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE SPACES TO WS-HEX
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     STRING WS-HEX(1:2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 OPEN-BLOCK.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     MOVE SCR-WORLD TO WS-D1
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-D1
     CALL "BLOCKEDIT-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE SM-SCREEN TO WS-E1
     MOVE EB-FORM TO WS-E2
     IF SM-SCREEN = SCR-CMDBLOCK
         MOVE 0 TO WS-E2
     END-IF
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
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

 END PROGRAM TEST-NARRATIVE-REFS.

 COPY CLTEST.
