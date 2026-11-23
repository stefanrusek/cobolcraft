*> Test of the Client Information of the play phase (T51007 leftover; docs/protocol/47 section 5.2 "Options.save() calls broadcastOptions(); the packet is sent only when it differs
*> from the last one sent"): CLIENT-INFO-BROADCAST (protocol-play.cob, called at the end of every OPTIONS-SAVE) sends nothing in configuration or while the skin parts byte of the options is
*> the one last sent, and in play with another byte sends Client Information 0x0E (the 03 layout) once, with that byte.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIENT-INFO-PLAY.
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
 01 B-PACKET               PIC X(512) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     CALL "CLP-CONFIG-START" USING CLIENT-STATE WS-CONN
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     MOVE "N" TO TL-MODE

     CALL "CLIENT-INFO-BROADCAST" USING CLIENT-STATE
     PERFORM FIND-FIRST
     MOVE "client info play a save in configuration sends nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     CALL "CLIENT-INFO-BROADCAST" USING CLIENT-STATE
     PERFORM FIND-FIRST
     MOVE "client info play a save in play with the skin parts as sent sends nothing" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The hat (0x40) off: 127 - 64 = 63 (0x3f).
     MOVE "modelPart_hat" TO WS-NAME
     MOVE "false" TO WS-VALUE
     MOVE 5 TO WS-VALUE-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-OK
     CALL "CLIENT-INFO-BROADCAST" USING CLIENT-STATE
     PERFORM FIND-FIRST
     MOVE "client info play a changed skin part in play sends one packet" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "client info play the packet is 0x0E with the byte 63 and the rest of the configuration packet" TO TL-CASE
     MOVE "0e05656e5f75730800013f01000100" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HEX(1:30) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     CALL "CLIENT-INFO-BROADCAST" USING CLIENT-STATE
     PERFORM FIND-FIRST
     MOVE "N" TO TL-MODE
     MOVE "client info play the same byte again sends nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The first packet queued on the game connection: found out (1/0) and its hex.
 FIND-FIRST.
     MOVE 1 TO WS-INDEX
     MOVE SPACES TO WS-HEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     IF WS-FOUND = 1
         SET ADDRESS OF B-PACKET TO PB-ADDR
         CALL "TEST-HEX-OF" USING B-PACKET PB-LENGTH WS-HEX
     END-IF
     .
 END PROGRAM TEST-CLIENT-INFO-PLAY.

 COPY CLTEST.
