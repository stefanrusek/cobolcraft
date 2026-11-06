*> Contract test, the server's consumer side of the C glue ABI (contracts/shim-abi.md §1, §3): every
*> CCSHIM.cpy constant the server uses (CC-AGAIN, CC-ADDR-IN-USE, CC-CLOSED) has the contract's
*> value, and each cc_net_* call the server makes (listen, accept, poll, recv, send, close) links and
*> returns a defined outcome on a minimal loopback call with the calling convention of research R2.
*> The server's one cc_fatal call (a port already in use) is exercised by test_listen_in_use.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVER-CONTRACT-SHIM-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-HOST                PIC X(16) VALUE Z"127.0.0.1".
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-WAIT                BINARY-LONG VALUE 1000.
 01 WS-SLEEP               BINARY-LONG VALUE 20.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-LISTENER2           BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-PORT2               BINARY-LONG.
 01 WS-CLIENT              BINARY-LONG.
 01 WS-SERVER              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-RC2                 BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG.
 01 WS-READY               PIC X(2).
 01 WS-DATA                PIC X(3) VALUE "abc".
 01 WS-AREA                PIC X(64).
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "contract server shim consumer CC-AGAIN 1, CC-ADDR-IN-USE 2, CC-CLOSED 4 (shim-abi §1, §3)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 124 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CC-AGAIN * 100 + CC-ADDR-IN-USE * 10 + CC-CLOSED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-PORT RETURNING WS-RC
     MOVE "contract server shim consumer cc_net_listen port 0 returns 0, a handle and the actual port"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 handle port" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RC TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-LISTENER > 0
         STRING FUNCTION TRIM(TL-OBSERVED) " handle" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     IF WS-PORT > 0
         STRING FUNCTION TRIM(TL-OBSERVED) " port" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL STATIC "cc_net_listen" USING BY VALUE WS-PORT BY REFERENCE WS-LISTENER2
         BY REFERENCE WS-PORT2 RETURNING WS-RC
     MOVE "contract server shim consumer cc_net_listen on a port in use returns CC_ADDR_IN_USE"
         TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-ADDR-IN-USE TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE WS-SERVER RETURNING WS-RC
     MOVE "contract server shim consumer cc_net_accept with no pending client returns CC_AGAIN"
         TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-AGAIN TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A loopback client: the listener becomes ready in cc_net_poll and cc_net_accept returns it.
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT
     MOVE WS-LISTENER TO WS-HANDLE
     MOVE LOW-VALUES TO WS-READY
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE WS-SERVER
         RETURNING WS-RC2
     MOVE "contract server shim consumer cc_net_poll returns 0 with the listener ready, then "
         & "cc_net_accept returns 0 and a handle" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 ready 0 handle" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RC TO WS-EDIT
     MOVE WS-RC2 TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-READY(1:1) = X"01"
         STRING FUNCTION TRIM(TL-OBSERVED) " ready" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     IF WS-SERVER > 0
         STRING FUNCTION TRIM(TL-OBSERVED) " handle" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Bytes from the client arrive through cc_net_recv; then nothing is available.
     CALL STATIC "cc_net_send" USING BY VALUE WS-CLIENT BY REFERENCE WS-DATA BY VALUE WS-THREE
         BY REFERENCE WS-SENT RETURNING WS-RC
     MOVE WS-SERVER TO WS-HANDLE
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC2
     MOVE SPACES TO WS-AREA
     CALL STATIC "cc_net_recv" USING BY VALUE WS-SERVER BY REFERENCE WS-AREA BY VALUE WS-CAPACITY
         BY REFERENCE WS-GOT RETURNING WS-RC2
     MOVE "contract server shim consumer cc_net_send returns 0 with 3 sent and cc_net_recv returns 0 "
         & "with the 3 bytes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 3 0 3 abc" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RC TO WS-EDIT
     MOVE WS-SENT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-RC2 TO WS-EDIT
     MOVE WS-GOT TO WS-EDIT2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " "
         WS-AREA(1:3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_recv" USING BY VALUE WS-SERVER BY REFERENCE WS-AREA BY VALUE WS-CAPACITY
         BY REFERENCE WS-GOT RETURNING WS-RC
     MOVE "contract server shim consumer cc_net_recv with nothing available returns CC_AGAIN"
         TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-AGAIN TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The client closes: cc_net_recv returns CC_CLOSED; sending to it soon returns CC_CLOSED.
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC2
     CALL STATIC "cc_net_recv" USING BY VALUE WS-SERVER BY REFERENCE WS-AREA BY VALUE WS-CAPACITY
         BY REFERENCE WS-GOT RETURNING WS-RC
     MOVE "contract server shim consumer cc_net_recv after the peer closed returns CC_CLOSED"
         TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-CLOSED TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-RC
     PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-RC NOT = 0 OR WS-TRIES > 50
         CALL STATIC "cc_net_send" USING BY VALUE WS-SERVER BY REFERENCE WS-DATA BY VALUE WS-THREE
             BY REFERENCE WS-SENT RETURNING WS-RC
         CALL "SVT-SLEEP-MS" USING WS-SLEEP
     END-PERFORM
     MOVE "contract server shim consumer cc_net_send to a closed peer returns CC_CLOSED" TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-CLOSED TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER

*>   cc_net_close of the listener: a new connection to its port is refused.
     CALL STATIC "cc_net_close" USING BY VALUE WS-LISTENER
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT
     CALL STATIC "cc_net_status" USING BY VALUE WS-CLIENT RETURNING WS-RC
     MOVE "contract server shim consumer after cc_net_close of the listener a connect is refused"
         TO TL-CASE
     PERFORM ASSERT-RC-IS
     MOVE CC-CLOSED TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT
     STOP RUN.

 ASSERT-RC-IS.
     MOVE "N" TO TL-MODE
     MOVE WS-RC TO TL-OBSERVED-N.
 END PROGRAM SERVER-CONTRACT-SHIM-CONSUMER.
 COPY SVTEST.
