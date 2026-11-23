 *> Implementation test of the model customisation byte of the client's Client Information (T51007/T51214 core half; docs/protocol/47 section 5.2 and 5.3,
*> 03 Client Information): CLP-CONFIG-START sends the skin parts of the options modelPart_* (all seven on by default: 127), not a fixed 0. The wire fixture
*> config-c2s-00-client-information.hex (model customisation 0) is the packet of a client whose seven parts are all off (contract_wire_client sets them so).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIENT-INFO-PARTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 B-PACKET               PIC X(512) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     MOVE "T" TO TL-MODE

*>   No option set: every part is on, 127 (0x7f).
     PERFORM SEND-INFO
     MOVE "client info parts no modelPart option: the byte is 127" TO TL-CASE
     MOVE "0005656e5f75730800017f01000100" TO TL-EXPECTED
     PERFORM CHECK-INFO

*>   Cape (0x01) and hat (0x40) off: 127 - 1 - 64 = 62 (0x3e).
     MOVE "modelPart_cape" TO WS-NAME
     PERFORM SET-FALSE
     MOVE "modelPart_hat" TO WS-NAME
     PERFORM SET-FALSE
     PERFORM SEND-INFO
     MOVE "client info parts cape and hat off: the byte is 62" TO TL-CASE
     MOVE "0005656e5f75730800013e01000100" TO TL-EXPECTED
     PERFORM CHECK-INFO

*>   All seven off: 0, the packet of the wire fixture.
     MOVE "modelPart_jacket" TO WS-NAME
     PERFORM SET-FALSE
     MOVE "modelPart_left_sleeve" TO WS-NAME
     PERFORM SET-FALSE
     MOVE "modelPart_right_sleeve" TO WS-NAME
     PERFORM SET-FALSE
     MOVE "modelPart_left_pants_leg" TO WS-NAME
     PERFORM SET-FALSE
     MOVE "modelPart_right_pants_leg" TO WS-NAME
     PERFORM SET-FALSE
     PERFORM SEND-INFO
     MOVE "client info parts all seven parts off: the byte is 0 (config-c2s-00-client-information.hex)" TO TL-CASE
     MOVE "0005656e5f75730800010001000100" TO TL-EXPECTED
     PERFORM CHECK-INFO
     STOP RUN.

 SET-FALSE.
     MOVE "false" TO WS-VALUE
     MOVE 5 TO WS-VALUE-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-OK
     .

*> The configuration opening on a fresh game connection: the second packet queued (after the brand) is Client Information.
 SEND-INFO.
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     CALL "CLP-CONFIG-START" USING CLIENT-STATE WS-CONN
     MOVE 2 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     SET ADDRESS OF B-PACKET TO PB-ADDR
     CALL "TEST-HEX-OF" USING B-PACKET PB-LENGTH WS-HEX
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     .

 CHECK-INFO.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HEX(1:PB-LENGTH * 2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-CLIENT-INFO-PARTS.

 COPY CLTEST.
