*> Test US12-client (spec 002 T3296 to T3311; docs/protocol/40-menus-9-block-editor-screens.md sections 2, 3, 4 and 8): the permission rule (Entity Event 24 + level on the player; both creative and
*> level 2 are needed), the six packets of the block editors (Set Command Block 0x37, Set Command Minecart 0x38, Set Structure Block 0x3C, Set Jigsaw Block 0x3B, Jigsaw Generate 0x1B, Set Test
*> Block 0x3D) and the command block screen through the real screen stack at GUI 320 x 240 (cx 160): opened by using a command block with the permission, the command typed, the mode, type,
*> trigger and track cycles, Enter or Done sends 0x37 with the mode and the flags, Escape or Cancel closes with no packet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-HEX                 PIC X(1024).
 01 WS-PACKET              BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 1.
 01 WS-Y                   BINARY-LONG VALUE 2.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-KEYB                PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(1100).
 01 WS-LEN                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-TRACK               BINARY-LONG.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-T4                  BINARY-LONG.
 01 WS-T5                  BINARY-LONG.
 01 WS-T6                  BINARY-LONG.
 01 WS-T7                  BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-NAME                PIC X(1100).
 01 WS-META                PIC X(1100).
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
     MOVE "N" TO TL-MODE
*>   2.2 the permission: Entity Event 24 + level for the local player's entity.
     MOVE 1 TO PL-MODE
     MOVE 26 TO WS-BYTE
     PERFORM SEND-EVENT
     CALL "CAN-USE-GM" USING CLIENT-STATE WS-OK
     MOVE "acceptance US12 40-9§2 creative with Entity Event 26 (level 2): the player can use game master blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO WS-BYTE
     PERFORM SEND-EVENT
     CALL "CAN-USE-GM" USING CLIENT-STATE WS-OK
     MOVE "acceptance US12 40-9§10 a creative player with level 1 (event 25) cannot (example 7)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 28 TO WS-BYTE
     PERFORM SEND-EVENT
     CALL "CAN-USE-GM" USING CLIENT-STATE WS-OK
     MOVE "acceptance US12 40-9§2.2 Entity Event 28 (level 4, owner) in creative can" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO PL-MODE
     CALL "CAN-USE-GM" USING CLIENT-STATE WS-OK
     MOVE "acceptance US12 40-9§2.2 level 4 (owner) in survival cannot: both creative and the permission are required" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 26 TO WS-BYTE
     PERFORM SEND-EVENT
     MOVE 1 TO PL-MODE
*>   8 the packets (hex of the packet as the server receives it).
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE "T" TO TL-MODE
     MOVE "say hi" TO WS-TEXT
     MOVE 6 TO WS-LEN
     MOVE 2 TO WS-MODE
     MOVE 5 TO WS-FLAGS
     CALL "SEND-SET-COMMAND-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TEXT WS-LEN WS-MODE WS-FLAGS
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Set Command Block 0x37: position, command, mode 2 (REDSTONE), flags 5" TO TL-CASE
     MOVE "370000004000003002067361792068690205" TO TL-EXPECTED
     MOVE WS-HEX(1:36) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 300 TO WS-ENTITY
     MOVE "x" TO WS-TEXT
     MOVE 1 TO WS-LEN
     MOVE 1 TO WS-TRACK
     CALL "SEND-SET-COMMAND-MINECART" USING CLIENT-STATE WS-ENTITY WS-TEXT WS-LEN WS-TRACK
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Set Command Minecart 0x38: entity 300 (ac02), command x, track output true" TO TL-CASE
     MOVE "38ac02017801" TO TL-EXPECTED
     MOVE WS-HEX(1:12) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-LEVELS
     MOVE 1 TO WS-KEEP
     MOVE 7 TO WS-LEVELS
     CALL "SEND-JIGSAW-GENERATE" USING CLIENT-STATE WS-X WS-Y WS-Z WS-LEVELS WS-KEEP
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Jigsaw Generate 0x1B: position, levels 7, keep jigsaws true" TO TL-CASE
     MOVE "1b00000040000030020701" TO TL-EXPECTED
     MOVE WS-HEX(1:22) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-MODE
     MOVE "m" TO WS-TEXT
     MOVE 1 TO WS-LEN
     CALL "SEND-SET-TEST-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-MODE WS-TEXT WS-LEN
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Set Test Block 0x3D: position, mode 2, message m" TO TL-CASE
     MOVE "3d000000400000300202016d" TO TL-EXPECTED
     MOVE WS-HEX(1:24) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "a" TO EB-JG-TEXT(1)
     MOVE "b" TO EB-JG-TEXT(2)
     MOVE "c" TO EB-JG-TEXT(3)
     MOVE "d" TO EB-JG-TEXT(4)
     MOVE 1 TO EB-JG-LEN(1) EB-JG-LEN(2) EB-JG-LEN(3) EB-JG-LEN(4)
     MOVE 0 TO EB-JG-JOINT
     MOVE 3 TO EB-JG-SELECTION
     MOVE 4 TO EB-JG-PLACEMENT
     CALL "SEND-SET-JIGSAW-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Set Jigsaw Block 0x3B: position, name a, target b, pool c, final state d, joint rollable, priorities 3 and 4" TO TL-CASE
     MOVE "3b0000004000003002016101620163016408726f6c6c61626c650304" TO TL-EXPECTED
     MOVE WS-HEX(1:56) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EB-ST-UPDATE
     MOVE 1 TO EB-ST-MODE
     MOVE "n" TO EB-ST-NAME
     MOVE 1 TO EB-ST-NAME-LEN
     MOVE 1 TO EB-ST-OFFSET(1)
     MOVE 2 TO EB-ST-OFFSET(2)
     MOVE -3 TO EB-ST-OFFSET(3)
     MOVE 4 TO EB-ST-SIZE(1)
     MOVE 5 TO EB-ST-SIZE(2)
     MOVE 6 TO EB-ST-SIZE(3)
     MOVE 0 TO EB-ST-MIRROR
     MOVE 1 TO EB-ST-ROTATION
     MOVE 0 TO EB-ST-META-LEN
     MOVE 1.0 TO EB-ST-INTEGRITY
     MOVE 5 TO EB-ST-SEED
     MOVE 5 TO EB-ST-FLAGS
     CALL "SEND-SET-STRUCTURE-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§8 Set Structure Block 0x3C: position, update 1, mode 1, name n, offsets 1 2 -3 (bytes), sizes 4 5 6, mirror 0, rotation 1, empty metadata, integrity 1.0, seed 5, flags 5" TO TL-CASE
     MOVE "3c00000040000030020101016e0102fd0405060001003f8000000505" TO TL-EXPECTED
     MOVE WS-HEX(1:56) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The command block screen: a standard set open; a command block state; with level 1 nothing opens, with level 2 the screen.
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     MOVE SPACES TO WS-KEYB
     MOVE "command_block" TO WS-KEYB
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYB WS-ID WS-ROW WS-STATUS
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE FUNCTION NUMVAL(CT-BR-DEFAULT-STATE) TO WS-STATE
     MOVE 25 TO WS-BYTE
     PERFORM SEND-EVENT
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-9§2.1 using a command block with level 1: no screen" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 26 TO WS-BYTE
     PERFORM SEND-EVENT
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 40-9§2.1 using a command block with creative and level 2 opens the command block screen" TO TL-CASE
     MOVE SCR-CMDBLOCK TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Type the command, cycle mode twice (REDSTONE to SEQUENCE to AUTO), type, trigger and track once.
     MOVE 6 TO WS-N
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2) WS-KIND(3) WS-KIND(4)
     MOVE 115 TO WS-A(1)
     MOVE 97 TO WS-A(2)
     MOVE 121 TO WS-A(3)
     MOVE 32 TO WS-A(4)
     MOVE 4 TO WS-N
     PERFORM FRAME
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 104 TO WS-A(1)
     MOVE 105 TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE 50 TO WS-D1
     MOVE 175 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM CLICK-GUI
     MOVE 160 TO WS-D1
     PERFORM CLICK-GUI
     MOVE 260 TO WS-D1
     PERFORM CLICK-GUI
     MOVE 300 TO WS-D1
     MOVE 145 TO WS-D2
     PERFORM CLICK-GUI
     MOVE "T" TO TL-MODE
     PERFORM BUTTON-TEXTS
     MOVE "acceptance US12 40-9§4 the cycles read Repeat (mode AUTO), Conditional, Always Active and the track output O" TO TL-CASE
     MOVE "O|Repeat|Conditional|Always Active|" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Enter sends Set Command Block: mode AUTO (1), flags track 1 + conditional 2 + automatic 4 = 7.
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE 257 TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§4.1 Enter sends Set Command Block: position (1, 2, 3), the command 'say hi', mode 1, flags 7" TO TL-CASE
     MOVE "370000004000003002067361792068690107" TO TL-EXPECTED
     MOVE WS-HEX(1:36) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-9§4.1 and the screen closes: the world" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Escape sends nothing.
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-ESCAPE TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     PERFORM FLUSH
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-9§3 Escape closes the screen with no packet" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-HEX(1:6) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Done sends it too.
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 0 TO WS-N
     PERFORM FRAME
     MOVE 20 TO WS-D1
     MOVE 200 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "acceptance US12 40-9§4.1 the Done button (6, 192) sends Set Command Block with an empty command, mode 2 (REDSTONE), flags 0: 37 pos 00 02 00" TO TL-CASE
     MOVE "370000004000003002000200" TO TL-EXPECTED
     MOVE WS-HEX(1:24) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Coverage of the remaining branches: the aligned joint of Set Jigsaw Block and Backspace in the command box.
     MOVE 1 TO EB-JG-JOINT
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     CALL "SEND-SET-JIGSAW-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z
     PERFORM FLUSH
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-9§8 Set Jigsaw Block with the joint aligned: the string 07 aligned" TO TL-CASE
     MOVE "3b00000040000030020161016201630164 07616c69676e65640304" TO TL-EXPECTED
     MOVE "3b0000004000003002016101620163016407616c69676e65640304" TO TL-EXPECTED
     MOVE WS-HEX(1:54) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     INITIALIZE WS-EVENTS
     MOVE CC-EV-TEXT TO WS-KIND(1) WS-KIND(2)
     MOVE 97 TO WS-A(1)
     MOVE 98 TO WS-A(2)
     MOVE 2 TO WS-N
     PERFORM FRAME
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-KEY-BACKSPACE TO WS-A(1)
     MOVE 1 TO WS-N
     PERFORM FRAME
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-9§4.1 Backspace in the command box removes a character: ab becomes a" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EB-CMD-LEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Overview: none of the five screens sends a packet when it is cancelled: the Cancel button closes the command block screen with no packet.
     CALL "CMDBLOCK-USE-CHECK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N
     PERFORM FRAME
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-HEX WS-THRESHOLD
     MOVE 170 TO WS-D1
     MOVE 200 TO WS-D2
     PERFORM CLICK-GUI
     PERFORM FLUSH
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) ":" WS-HEX(1:4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 40-9§1 Overview: Cancel closes the command block screen (world, screen 5) and sends no packet" TO TL-CASE
     MOVE "5:" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

*> Entity Event (05a 0x22) for the local player's entity with the event WS-BYTE.
 SEND-EVENT.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE PL-ENTITY-ID TO WS-ID
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-BYTE
     MOVE 34 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
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

*> TL-OBSERVED: the texts of the four cycle buttons (y 135 and 165) in widget order, each followed by a bar.
 BUTTON-TEXTS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-BUTTON AND (SM-W-Y(WS-I) = 165 OR SM-W-Y(WS-I) = 135) AND SM-W-LENGTH(WS-I) > 0
             STRING SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-9.

 COPY CLTEST.
