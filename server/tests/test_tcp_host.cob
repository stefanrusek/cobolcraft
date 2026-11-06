*> Implementation test of the server's TCP host (server/src/tcp-host.cob; research R6, R14;
*> contracts/core-host-api.md §2): accepted loopback connections are registered with the core as
*> network connections; received bytes reach CORE-CONN-INPUT; CORE-CONN-OUTPUT bytes are sent,
*> partial sends included; the transport closes after a close-flag hand-back is flushed; a peer close
*> calls CORE-CONN-CLOSED; a socket error on one connection logs "ERROR connection: <detail>" and
*> serving continues; a connection the core has no room for is refused the same way.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TCP-HOST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY CCSHIM.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 01 SVT-ROOT               PIC X(64) EXTERNAL.
 01 WS-WORLD               PIC X(64) VALUE Z"build/server-test-tcp/world".
 01 WS-RM                  PIC X(64) VALUE "rm -rf build/server-test-tcp && mkdir -p build/server-test-tcp".
 01 WS-CAPTURE             PIC X(256) VALUE "build/server-test-tcp/stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-CREATED             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PORT-ZERO           BINARY-LONG VALUE 0.
 01 WS-PORT                BINARY-LONG.
 01 WS-CLIENT-A            BINARY-LONG.
 01 WS-CLIENT-C            BINARY-LONG.
 01 WS-CLIENT-E            BINARY-LONG.
 01 WS-CLIENT-F            BINARY-LONG.
 01 WS-CLIENT              BINARY-LONG.
 01 WS-CLIENTS.
    05 WS-CLIENT-H         BINARY-LONG OCCURS 65 TIMES.
 01 WS-PATH                PIC X(256).
 01 WS-THRESHOLD           BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-COMPRESSED          BINARY-LONG VALUE 256.
 01 WS-WAIT                BINARY-LONG VALUE 20.
 01 WS-LONG-WAIT           BINARY-LONG VALUE 200.
 01 WS-POLL                BINARY-LONG VALUE 20.
 01 WS-POLL-LONG           BINARY-LONG VALUE 1000.
 01 WS-SLEEP               BINARY-LONG VALUE 50.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-EVER-CLOSED         BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PACKETS             BINARY-LONG.
 01 WS-LOGINS              BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROUNDS              BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-PENDING-SEEN        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CONSOLE             PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE SPACES TO SVT-ROOT
     CALL "SYSTEM" USING WS-RM
     PERFORM SET-SETTINGS
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING FR-BUFFER WS-CAPACITY

*>   Listen on a system-chosen port, connect, accept.
     CALL "TCP-LISTEN" USING WS-PORT-ZERO
     MOVE SV-BOUND-PORT TO WS-PORT
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT-A
     CALL "TCP-POLL" USING WS-POLL-LONG
     PERFORM COUNT-USED
     MOVE "test tcp host TCP-LISTEN port 0 listens on a system-chosen port and TCP-POLL accepts a "
         & "loopback connection into slot 1 registered as core connection 1" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "port>0 used 1 handle>0 core 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-USED TO WS-EDIT
     MOVE SV-CORE-ID(1) TO WS-EDIT2
     STRING "port" DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-PORT > 0
         STRING FUNCTION TRIM(TL-OBSERVED) ">0" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " used " FUNCTION TRIM(WS-EDIT) " handle"
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF SV-HANDLE(1) > 0
         STRING FUNCTION TRIM(TL-OBSERVED) ">0" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " core " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Intention and Hello reach the core; Set Compression (network connections only) and Login
*>   Finished come back over the socket.
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-A WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-A WS-PATH WS-NONE
     MOVE WS-CLIENT-A TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     PERFORM 10 TIMES
         PERFORM SERVE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "test tcp host received bytes reach CORE-CONN-INPUT and CORE-CONN-OUTPUT bytes are sent: "
         & "Set Compression of a network connection" TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-03-set-compression.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-COMPRESSED WS-PACKET-ID WS-OUTCOME
     MOVE "test tcp host then Login Finished in a compressed frame" TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-02-login-finished.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

*>   Configuration and the join produce more bytes than the (shrunk) socket buffers hold while the
*>   client does not read: the host keeps the unsent rest and sends it once the client reads.
     CALL "SVT-SHRINK-BUFFERS" USING WS-PORT
     CALL "SVT-CONFIGURE" USING WS-CLIENT-A
     MOVE 0 TO WS-PENDING-SEEN
     PERFORM 40 TIMES
         CALL "TCP-POLL" USING WS-POLL
         CALL "TCP-FLUSH"
         IF SV-OUT-PENDING(1) > 0
             MOVE 1 TO WS-PENDING-SEEN
         END-IF
     END-PERFORM
     MOVE "test tcp host a partial send keeps the unsent bytes pending" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PENDING-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 0 TO WS-ROUNDS
     MOVE -1 TO WS-BEFORE
     PERFORM UNTIL WS-ROUNDS > 500 OR (SV-OUT-PENDING(1) = 0 AND WS-BEFORE = ST-LENGTH)
         MOVE ST-LENGTH TO WS-BEFORE
         PERFORM SERVE-AND-RECEIVE
         ADD 1 TO WS-ROUNDS
     END-PERFORM
     MOVE 0 TO WS-PACKETS WS-LOGINS WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-COMPRESSED WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-PACKETS
             IF WS-PACKET-ID = 50
                 ADD 1 TO WS-LOGINS
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-LEFT = ST-LENGTH - ST-POS
     MOVE "test tcp host after partial sends every byte arrives in order: whole frames to the end "
         & "of the stream, one Login (play) among them" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "outcome 1 left 0 logins 1 many packets" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OUTCOME TO WS-EDIT
     MOVE WS-LEFT TO WS-EDIT2
     MOVE WS-LOGINS TO WS-EDIT3
     STRING "outcome " FUNCTION TRIM(WS-EDIT) " left " FUNCTION TRIM(WS-EDIT2) " logins "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-PACKETS > 20
         STRING FUNCTION TRIM(TL-OBSERVED) " many packets" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A login with another protocol version ends with Login Disconnect and the close flag: the host
*>   sends the disconnect, then closes the transport and frees the slot.
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT-C
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-other-protocol.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-C WS-PATH WS-NONE
     MOVE WS-CLIENT-C TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 0 TO WS-EVER-CLOSED
     PERFORM 10 TIMES
         PERFORM SERVE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "test tcp host a close-flag hand-back: the Login Disconnect bytes are sent" TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-00-login-disconnect-protocol-mismatch.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     PERFORM COUNT-USED
     MOVE "test tcp host then the transport is closed (client sees the end of the stream) and its "
         & "slot freed" TO TL-CASE
     MOVE "closed 1 used 1" TO TL-EXPECTED
     PERFORM OBSERVE-CLOSED-USED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT-C

*>   The joined player's client closes: the host calls CORE-CONN-CLOSED and the player leaves.
     PERFORM DRAIN-CONSOLE
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT-A
     PERFORM 5 TIMES
         CALL "TCP-POLL" USING WS-POLL
         CALL "TCP-FLUSH"
     END-PERFORM
     PERFORM DRAIN-CONSOLE
     PERFORM COUNT-USED
     MOVE 0 TO WS-COUNT
     INSPECT WS-CONSOLE TALLYING WS-COUNT FOR ALL "Alice left"
     MOVE "test tcp host a peer close calls CORE-CONN-CLOSED: the player leaves and the slot is freed"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "left 1 used 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-COUNT TO WS-EDIT
     MOVE WS-USED TO WS-EDIT2
     STRING "left " FUNCTION TRIM(WS-EDIT) " used " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A socket error: the status client closes before the server writes; the first send succeeds
*>   and the peer answers with a reset, so the next send fails.
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT-E
     CALL "TCP-POLL" USING WS-POLL-LONG
     PERFORM FIND-SLOT
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-E WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-E WS-PATH WS-NONE
     PERFORM 3 TIMES
         CALL "TCP-POLL" USING WS-SLEEP
     END-PERFORM
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT-E
     CALL "SVT-SLEEP-MS" USING WS-SLEEP
     CALL "TCP-PUMP-OUT" USING WS-SLOT
     CALL "SVT-SLEEP-MS" USING WS-SLEEP
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-PATH
     CALL "SVT-LOAD-HEX" USING WS-PATH PK-BUFFER
     CALL "PB-RESET" USING FR-BUFFER
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PK-BUFFER WS-NONE
     SET CB-ADDR TO FR-ADDR
     MOVE FR-LENGTH TO CB-CAPACITY CB-LENGTH
     CALL "CORE-CONN-INPUT" USING SV-CORE-ID(WS-SLOT) CORE-BUFFER
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "TCP-PUMP-OUT" USING WS-SLOT
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE "test tcp host a socket error on one connection logs one ERROR connection line" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ERROR connection: send failed: closed or reset by the peer" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-USED
     MOVE "test tcp host the failed connection is closed and its slot freed" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Serving continues: a new status client gets its Status Response.
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT-F
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-F WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-CLIENT-F WS-PATH WS-NONE
     MOVE WS-CLIENT-F TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     PERFORM 10 TIMES
         PERFORM SERVE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "test tcp host after a socket error serving continues: a new client gets Status Response"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 1000 + WS-PACKET-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   TCP-CLOSE-ALL closes every transport and the listener: the client sees the end of the stream.
     CALL "TCP-CLOSE-ALL"
     CALL "PB-RESET" USING ST-BUFFER
     CALL "SVT-RECV" USING WS-CLIENT-F ST-BUFFER WS-LONG-WAIT WS-CLOSED
     PERFORM COUNT-USED
     MOVE "test tcp host TCP-CLOSE-ALL closes every connection and the listener" TO TL-CASE
     MOVE "closed 1 used 0 listener 0" TO TL-EXPECTED
     PERFORM OBSERVE-CLOSED-USED
     MOVE SV-LISTENER TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " listener " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT-F

*>   The core has room for CORE-MAX-CONNS (64) connections: the 65th is refused with an ERROR line
*>   and closed; the others stay.
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TCP-LISTEN" USING WS-PORT-ZERO
     MOVE SV-BOUND-PORT TO WS-PORT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65
         CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT-H(WS-I)
     END-PERFORM
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     PERFORM 5 TIMES
         CALL "TCP-POLL" USING WS-POLL
     END-PERFORM
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE "test tcp host a connection the core has no room for logs one ERROR connection line"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ERROR connection: refused, too many connections" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING ST-BUFFER
     CALL "SVT-RECV" USING WS-CLIENT-H(65) ST-BUFFER WS-LONG-WAIT WS-CLOSED
     PERFORM COUNT-USED
     MOVE "test tcp host the refused connection is closed and the 64 others stay" TO TL-CASE
     MOVE "closed 1 used 64" TO TL-EXPECTED
     PERFORM OBSERVE-CLOSED-USED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TCP-CLOSE-ALL"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65
         CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT-H(WS-I)
     END-PERFORM
     STOP RUN.

*> The operator-surface §2 defaults, extra dimensions off (only cobolcraft:main).
 SET-SETTINGS.
     INITIALIZE CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE "world" TO CS-NEW-WORLD-NAME.

*> One host round (poll with accept and receive, then flush), then the client WS-CLIENT reads.
 SERVE-AND-RECEIVE.
     CALL "TCP-POLL" USING WS-POLL
     CALL "TCP-FLUSH"
     CALL "SVT-RECV" USING WS-CLIENT ST-BUFFER WS-WAIT WS-CLOSED
     IF WS-CLOSED = 1
         MOVE 1 TO WS-EVER-CLOSED
     END-IF.

 COUNT-USED.
     MOVE 0 TO WS-USED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS
         IF SV-HANDLE(WS-I) > 0
             ADD 1 TO WS-USED
         END-IF
     END-PERFORM.

 FIND-SLOT.
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SV-MAX-CONNS OR WS-SLOT > 0
         IF SV-HANDLE(WS-I) > 0
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM.

 OBSERVE-CLOSED-USED.
     IF WS-CLOSED = 1
         MOVE 1 TO WS-EVER-CLOSED
     END-IF
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-EVER-CLOSED TO WS-EDIT
     MOVE WS-USED TO WS-EDIT2
     STRING "closed " FUNCTION TRIM(WS-EDIT) " used " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 0 TO WS-EVER-CLOSED.

 DRAIN-CONSOLE.
     MOVE SPACES TO WS-CONSOLE
     SET CB-ADDR TO ADDRESS OF WS-CONSOLE
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER.
 END PROGRAM TEST-TCP-HOST.
 COPY SVTEST.
