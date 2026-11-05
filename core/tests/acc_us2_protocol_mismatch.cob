*> Acceptance test, US2 edge case "different protocol version" (spec US2; 02 Intention handling;
*> 09 §2): a client whose protocol version is not 777 still gets the server-list status, and its
*> login ends with Login Disconnect multiplayer.disconnect.incompatible ["CobolCraft"] and a close.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-PROTOCOL-MISMATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FX-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PATH                PIC X(256).
 01 WS-KIND                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-STATUS-IDS          PIC X(40).
 01 WS-LOGIN-SAME          PIC X(3).
 01 WS-LOGIN-CLOSE         BINARY-LONG.
 01 WS-STATUS-CLOSE        BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 B-BYTES                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING FX-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND

*>   When it pings: the other-protocol Intention with intent 1 (status), Status Request, Ping.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-other-protocol.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     SET ADDRESS OF B-BYTES TO PB-ADDR
     MOVE X"01" TO B-BYTES(PB-LENGTH:1)
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE CN-CLOSE(WS-CONN) TO WS-STATUS-CLOSE
     CALL "TEST-DRAIN" USING WS-CONN ST-BUFFER WS-CLOSE
     MOVE SPACES TO WS-STATUS-IDS
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-STATUS-IDS
                 WITH POINTER WS-PTR
         END-IF
     END-PERFORM

*>   When it logs in: the other-protocol Intention with intent 2 (login).
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-other-protocol.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "PB-RESET" USING ST-BUFFER
     MOVE CN-CLOSE(WS-CONN) TO WS-LOGIN-CLOSE
     CALL "TEST-DRAIN" USING WS-CONN ST-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/login-s2c-00-login-disconnect-protocol-mismatch.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH FX-BUFFER
     MOVE "no" TO WS-LOGIN-SAME
     IF WS-OUTCOME = 0 AND PK-LENGTH = FX-LENGTH
         SET ADDRESS OF B-BYTES TO PK-ADDR
         MOVE B-BYTES(1:PK-LENGTH) TO WS-PATH
         SET ADDRESS OF B-BYTES TO FX-ADDR
         IF WS-PATH(1:FX-LENGTH) = B-BYTES(1:FX-LENGTH)
             MOVE "yes" TO WS-LOGIN-SAME
         END-IF
     END-IF
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME

     MOVE "acceptance US2 edge given a client with a different protocol version when it pings "
         & "and when it logs in then status is answered and login ends with the 02 disconnect "
         & "behaviour" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "status: packets 0 1, closed 1; login: protocol-mismatch fixture yes, then none 1, "
         & "closed 1" TO TL-EXPECTED
     MOVE WS-STATUS-CLOSE TO WS-EDIT
     MOVE WS-LOGIN-CLOSE TO WS-EDIT2
     MOVE WS-OUTCOME TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING "status: packets " FUNCTION TRIM(WS-STATUS-IDS) ", closed " FUNCTION TRIM(WS-EDIT)
         "; login: protocol-mismatch fixture " WS-LOGIN-SAME ", then none "
         FUNCTION TRIM(WS-EDIT3) ", closed " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US2-PROTOCOL-MISMATCH.

 COPY CORETEST.
