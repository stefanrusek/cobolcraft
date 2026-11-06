*> Implementation test of the guest hosting of client/src/sp-host.cob (US17-2, US17-4; research R6,
*> R7; core-host-api §2; shim-abi §3): in a world opened to others, guest TCP connections are
*> accepted, registered as core network connections (Set Compression answers their Hello) and
*> pumped every frame, so a guest joins and plays (the online count grows); a guest closing its
*> connection calls CORE-CONN-CLOSED (the player leaves, the slot is freed); a guest beyond the
*> CL-MAX-GUESTS slots is refused and closed; a failed send frees its slot; quitting calls CORE-STOP
*> with the §17 host-closed text and closes every guest after flushing its Disconnect. The guests are
*> real loopback connections driven by this test with the wire fixtures.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HOST-NETWORK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==RX-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-host-network".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-FOLDER              PIC X(80) VALUE "Hosted".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-NAME                PIC X(64) VALUE "Hosted".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-HOST                PIC X(16) VALUE Z"127.0.0.1".
 01 WS-GUEST               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-PENDING-SEEN        BINARY-LONG.
 01 WS-GUESTS.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-RC                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-THRESHOLD           BINARY-LONG VALUE 256.
 01 WS-PATH                PIC X(256).
 01 WS-AREA                PIC X(65536).
 01 WS-AREA-CAP            BINARY-LONG VALUE 65536.
 01 WS-GOT                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4194304.
 01 WS-HEX                 PIC X(1024).
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
*> Hello (login 0x00) of "Bob", framed without compression: length 21, id 0, name, profile id 0.
 01 WS-HELLO.
    05 FILLER              PIC X(3) VALUE X"150003".
    05 WS-HELLO-NAME       PIC X(3) VALUE "Bob".
    05 FILLER              PIC X(16) VALUE LOW-VALUES.
 01 WS-HELLO-LENGTH        BINARY-LONG VALUE 22.
 01 B-RX                   PIC X(1073741824) BASED.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING RX-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PB-BUFFER WS-AREA-CAP
     CALL "PB-INIT" USING FR-BUFFER WS-AREA-CAP
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE 1 TO SP-GUEST-MODE
     MOVE 0 TO SP-GUEST-OPERATOR
     CALL "SP-OPEN-OTHERS" USING CLIENT-STATE

*>   A guest connects: accepted on a following frame, a core network connection.
     PERFORM GUEST-CONNECT
     MOVE "host network a guest TCP connection is accepted into a guest slot with a core "
         & "connection" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "used 1 core 1" TO TL-EXPECTED
     PERFORM FIND-SLOT
     MOVE WS-USED TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-SLOT > 0
         IF GH-CORE-ID(WS-SLOT) > 0
             MOVE 1 TO WS-E2
         END-IF
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "used " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Intention (login) and Hello: a network connection is answered with Set Compression (256).
     PERFORM GUEST-HELLO
     MOVE "host network the guest connection is a network connection: its Hello is answered "
         & "with Set Compression 256 (frame 03 03 80 02)" TO TL-CASE
     MOVE "03038002" TO TL-EXPECTED
     SET ADDRESS OF B-RX TO RX-ADDR
     MOVE SPACES TO WS-HEX
     IF RX-LENGTH >= 4
         CALL "TEST-HEX-OF" USING B-RX WS-FOUR WS-HEX
     END-IF
     MOVE WS-HEX TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Configuration and play: the guest joins the host's world (US17-2).
     PERFORM GUEST-JOIN
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "acceptance US17-2 given a world opened to others when another Player joins at its "
         & "address then they enter the host's world: 2 players online" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CST-PLAYERS-ONLINE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The guest closes its connection: CORE-CONN-CLOSED, the player leaves, the slot is freed.
     CALL STATIC "cc_net_close" USING BY VALUE WS-GUEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR WS-USED = 0
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM COUNT-USED
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "host network a guest closing its connection calls CORE-CONN-CLOSED: the player leaves "
         & "and the slot is freed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "used 0 online 1" TO TL-EXPECTED
     MOVE WS-USED TO WS-E1
     MOVE CST-PLAYERS-ONLINE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "used " FUNCTION TRIM(WS-E1) " online " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One guest more than the slots: refused and closed; the others stay.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9
         CALL STATIC "cc_net_connect" USING BY REFERENCE WS-HOST BY VALUE SP-PORT
             BY REFERENCE WS-G(WS-J) RETURNING WS-RC
     END-PERFORM
     PERFORM 10 TIMES
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     PERFORM COUNT-USED
     MOVE WS-USED TO WS-E1
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9
         MOVE WS-G(WS-J) TO WS-GUEST
         CALL "PB-RESET" USING RX-BUFFER
         PERFORM GUEST-RECV
         ADD WS-CLOSED TO WS-COUNT
     END-PERFORM
     MOVE "host network a guest beyond the CL-MAX-GUESTS (8) slots is refused and closed; the "
         & "others stay" TO TL-CASE
     MOVE "used 8 closed 1" TO TL-EXPECTED
     MOVE WS-COUNT TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "used " FUNCTION TRIM(WS-E1) " closed " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   GUESTS-CLOSE releases every guest (each sees the end of its stream) and closes the listener;
*>   opening again listens anew.
     CALL "GUESTS-CLOSE" USING CLIENT-STATE
     PERFORM COUNT-USED
     MOVE WS-USED TO WS-E1
     MOVE SP-LISTENER TO WS-E2
     CALL "TEST-SLEEP"
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9
         MOVE WS-G(WS-J) TO WS-GUEST
         PERFORM GUEST-RECV
         ADD WS-CLOSED TO WS-COUNT
         CALL STATIC "cc_net_close" USING BY VALUE WS-G(WS-J)
     END-PERFORM
     MOVE "host network GUESTS-CLOSE closes every guest connection and the listener" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "used 0 listener 0 closed 9" TO TL-EXPECTED
     MOVE WS-COUNT TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "used " FUNCTION TRIM(WS-E1) " listener " FUNCTION TRIM(WS-E2) " closed "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-OPEN-OTHERS" USING CLIENT-STATE

*>   A socket error: a status guest closes before the host writes; the first send succeeds and the
*>   peer answers with a reset, so the next send fails: the slot is freed.
     PERFORM GUEST-CONNECT
     PERFORM FIND-SLOT
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-NONE
     CALL "TEST-SLEEP"
     CALL "GUEST-PUMP-IN" USING CLIENT-STATE WS-SLOT
     CALL STATIC "cc_net_close" USING BY VALUE WS-GUEST
     CALL "TEST-SLEEP"
     CALL "GUEST-PUMP-OUT" USING CLIENT-STATE WS-SLOT
     CALL "TEST-SLEEP"
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-RESET" USING FR-BUFFER
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER WS-NONE
     SET CB-ADDR TO FR-ADDR
     MOVE FR-LENGTH TO CB-CAPACITY CB-LENGTH
     CALL "CORE-CONN-INPUT" USING GH-CORE-ID(WS-SLOT) CORE-BUFFER
     CALL "GUEST-PUMP-OUT" USING CLIENT-STATE WS-SLOT
     PERFORM COUNT-USED
     MOVE "host network a failed send to a guest (reset by the peer) frees its slot" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Quitting with a guest in play (US17-4): CORE-STOP with the host-closed text; the guest gets
*>   its Disconnect, then the end of the stream; the listener is closed. A second guest (Cat) that
*>   does not read, over shrunk socket buffers, keeps unsent bytes pending (a partial send); it is
*>   closed with the rest.
     PERFORM GUEST-CONNECT
     PERFORM GUEST-HELLO
     PERFORM GUEST-JOIN
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-PLAYERS-ONLINE TO WS-E1
     MOVE WS-GUEST TO WS-BOB
     MOVE "Cat" TO WS-HELLO-NAME
     PERFORM GUEST-CONNECT
     PERFORM GUEST-HELLO
     CALL "TEST-SHRINK-BUFFERS" USING SP-PORT
     PERFORM GUEST-CONFIGURE
     MOVE WS-BOB TO WS-GUEST
     MOVE 0 TO WS-PENDING-SEEN
     PERFORM 40 TIMES
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM GUEST-RECV
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CL-MAX-GUESTS
             IF GH-HANDLE(WS-J) > 0 AND GH-OUT-PENDING(WS-J) > 0
                 MOVE 1 TO WS-PENDING-SEEN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "host network a guest that does not read keeps the unsent bytes pending (partial send)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PENDING-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "PB-RESET" USING RX-BUFFER
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE 0 TO WS-CLOSED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR WS-CLOSED = 1
         CALL "TEST-SLEEP"
         PERFORM GUEST-RECV
     END-PERFORM
     MOVE 0 TO WS-COUNT
     SET ADDRESS OF B-RX TO RX-ADDR
     IF RX-LENGTH > 0
         INSPECT B-RX(1:RX-LENGTH) TALLYING WS-COUNT
             FOR ALL "cobolcraft.disconnect.host_closed"
     END-IF
     PERFORM COUNT-USED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "acceptance US17-4 given a world opened to others when the host quits then the guest is "
         & "disconnected with the host-closed text and every guest connection is closed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "online 2 found 1 text 1 closed 1 used 0 listener 0 run 2 active 0" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E2
     MOVE WS-COUNT TO WS-E3
     MOVE WS-CLOSED TO WS-E4
     MOVE SPACES TO WS-HEX
     STRING "online " FUNCTION TRIM(WS-E1) " found " FUNCTION TRIM(WS-E2) " text "
         FUNCTION TRIM(WS-E3) " closed " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO WS-HEX
     MOVE WS-USED TO WS-E1
     MOVE SP-LISTENER TO WS-E2
     MOVE CST-RUN-STATE TO WS-E3
     MOVE SP-ACTIVE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-HEX) " used " FUNCTION TRIM(WS-E1) " listener "
         FUNCTION TRIM(WS-E2) " run " FUNCTION TRIM(WS-E3) " active " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-GUEST
     STOP RUN.

*> A new guest connection (WS-GUEST) to the listener, accepted by a following frame.
 GUEST-CONNECT.
     PERFORM COUNT-USED
     COMPUTE WS-WANT = WS-USED + 1
     CALL STATIC "cc_net_connect" USING BY REFERENCE WS-HOST BY VALUE SP-PORT
         BY REFERENCE WS-GUEST RETURNING WS-RC
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR WS-USED = WS-WANT
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM COUNT-USED
     END-PERFORM
     CALL "PB-RESET" USING RX-BUFFER.

*> Intention (login) and Bob's Hello; frames until something has been received.
 GUEST-HELLO.
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-NONE
     CALL "TEST-SERVE-BYTES" USING WS-GUEST WS-HELLO WS-HELLO-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR RX-LENGTH > 4
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM GUEST-RECV
     END-PERFORM.

*> Login Acknowledged and the configuration (compressed frames), then frames (the guest's bytes
*> drained) until two players are online.
 GUEST-JOIN.
     PERFORM GUEST-CONFIGURE
     MOVE 0 TO CST-PLAYERS-ONLINE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR CST-PLAYERS-ONLINE = 2
         CALL "TEST-SLEEP"
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM GUEST-RECV
         CALL "CORE-STATUS-GET" USING CORE-STATUS
     END-PERFORM.

 GUEST-CONFIGURE.
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-THRESHOLD
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-THRESHOLD
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-THRESHOLD
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-THRESHOLD
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-SERVE" USING WS-GUEST WS-PATH WS-THRESHOLD.

*> Everything the guest WS-GUEST has received so far, appended to RX-BUFFER; WS-CLOSED 1 at the
*> end of the stream.
 GUEST-RECV.
     MOVE 0 TO WS-RC WS-CLOSED
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_recv" USING BY VALUE WS-GUEST BY REFERENCE WS-AREA
             BY VALUE WS-AREA-CAP BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0
             CALL "PB-APPEND-BYTES" USING RX-BUFFER WS-AREA WS-GOT
         END-IF
     END-PERFORM
     IF WS-RC = CC-CLOSED
         MOVE 1 TO WS-CLOSED
     END-IF.

 COUNT-USED.
     MOVE 0 TO WS-USED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CL-MAX-GUESTS
         IF GH-HANDLE(WS-J) > 0
             ADD 1 TO WS-USED
         END-IF
     END-PERFORM.

*> The first used guest slot (WS-SLOT, 0 none) and the used count.
 FIND-SLOT.
     PERFORM COUNT-USED
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-J FROM CL-MAX-GUESTS BY -1 UNTIL WS-J < 1
         IF GH-HANDLE(WS-J) > 0
             MOVE WS-J TO WS-SLOT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-HOST-NETWORK.

*> TEST-SHRINK-BUFFERS USING port: 4096-byte socket buffers for every open socket of this process
*> connected to that port (receive) or accepted on it (send), so a partial send happens (macOS grows
*> loopback buffers to megabytes); as server/tests/SVTEST.cpy SVT-SHRINK-BUFFERS.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SHRINK-BUFFERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FD                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PEER-PORT           BINARY-LONG.
 01 WS-OWN-PORT            BINARY-LONG.
 01 WS-ADDRESS.
    05 WS-SIN-LEN          PIC X.
    05 WS-SIN-FAMILY       PIC X.
    05 WS-SIN-PORT         PIC X(2).
    05 FILLER              PIC X(12).
 01 WS-ADDRESS-LENGTH      BINARY-LONG UNSIGNED.
 01 WS-SOL-SOCKET          BINARY-LONG VALUE 65535.
 01 WS-SO-SNDBUF           BINARY-LONG VALUE 4097.
 01 WS-SO-RCVBUF           BINARY-LONG VALUE 4098.
 01 WS-SIZE                BINARY-LONG VALUE 4096.
 01 WS-SIZE-LENGTH         BINARY-LONG UNSIGNED VALUE 4.
 LINKAGE SECTION.
 01 L-PORT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PORT.
     PERFORM VARYING WS-FD FROM 3 BY 1 UNTIL WS-FD > 1024
         MOVE -1 TO WS-PEER-PORT WS-OWN-PORT
         MOVE 16 TO WS-ADDRESS-LENGTH
         CALL STATIC "getpeername" USING BY VALUE WS-FD BY REFERENCE WS-ADDRESS
             BY REFERENCE WS-ADDRESS-LENGTH RETURNING WS-RC
*>       sin_port is in network byte order (big-endian).
         IF WS-RC = 0
             COMPUTE WS-PEER-PORT = (FUNCTION ORD(WS-SIN-PORT(1:1)) - 1) * 256
                 + FUNCTION ORD(WS-SIN-PORT(2:1)) - 1
             MOVE 16 TO WS-ADDRESS-LENGTH
             CALL STATIC "getsockname" USING BY VALUE WS-FD BY REFERENCE WS-ADDRESS
                 BY REFERENCE WS-ADDRESS-LENGTH RETURNING WS-RC
             COMPUTE WS-OWN-PORT = (FUNCTION ORD(WS-SIN-PORT(1:1)) - 1) * 256
                 + FUNCTION ORD(WS-SIN-PORT(2:1)) - 1
         END-IF
         IF WS-PEER-PORT = L-PORT
             CALL STATIC "setsockopt" USING BY VALUE WS-FD BY VALUE WS-SOL-SOCKET
                 BY VALUE WS-SO-RCVBUF BY REFERENCE WS-SIZE BY VALUE WS-SIZE-LENGTH
                 RETURNING WS-RC
         END-IF
         IF WS-OWN-PORT = L-PORT
             CALL STATIC "setsockopt" USING BY VALUE WS-FD BY VALUE WS-SOL-SOCKET
                 BY VALUE WS-SO-SNDBUF BY REFERENCE WS-SIZE BY VALUE WS-SIZE-LENGTH
                 RETURNING WS-RC
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM TEST-SHRINK-BUFFERS.
 COPY CLTEST.
