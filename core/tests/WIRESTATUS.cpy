*> contract_wire_server.cob cases (test infrastructure): handshake, status and login (09 §3.1, §1,
*> §2; 02). Clientbound fixtures are compared with the core's builders and with what a memory or
*> network connection fed the serverbound fixtures receives; serverbound fixtures are fed to the
*> core (or to the Hello decoder) and the decoded values are checked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-STATUS-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PATH                PIC X(256).
 01 WS-DIR                 PIC X(23) VALUE "contract/fixtures/wire/".
 01 WS-KIND                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DRAIN-CLOSE         BINARY-LONG.
 01 WS-AREA                PIC X(512).
 01 WS-THRESHOLD           BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ONLINE              BINARY-LONG.
 01 WS-DESCRIPTION         PIC X(256).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-THRESHOLD-256       BINARY-LONG VALUE 256.
 01 WS-REST                BINARY-LONG.
 01 B-BYTES                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE WS-DIR TO WS-PATH

*>   Intention fixtures (handshake 0x00) decode: protocol, intent and the phase they select.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND
     PERFORM OPEN-CONN
     MOVE "handshake-c2s-00-intention-status.hex" TO WS-PATH(24:)
     PERFORM FEED
     MOVE "contract wire server handshake-c2s-00-intention-status decodes: protocol 777, intent 1, "
         & "status phase" TO TL-CASE
     MOVE "777 1 1 0" TO TL-EXPECTED
     PERFORM ASSERT-INTENTION
*>   Status Request (status 0x00) is answered by the Status Response of the default settings with
*>   the online count of the player table (no player: 0).
     MOVE "status-c2s-00-status-request.hex" TO WS-PATH(24:)
     PERFORM FEED
     PERFORM DRAIN
     MOVE -1 TO WS-THRESHOLD
     PERFORM NEXT-PACKET
     MOVE "contract wire server status-c2s-00-status-request decodes and is answered by "
         & "status-s2c-00-status-response (default settings, online 0)" TO TL-CASE
     MOVE "status-s2c-00-status-response.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
*>   Ping Request (status 0x01) is answered by Pong Response; then the connection closes.
     MOVE "status-c2s-01-ping-request.hex" TO WS-PATH(24:)
     PERFORM FEED
     PERFORM DRAIN
     PERFORM NEXT-PACKET
     MOVE "contract wire server status-c2s-01-ping-request decodes and is answered by "
         & "status-s2c-01-pong-response" TO TL-CASE
     MOVE "status-s2c-01-pong-response.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract wire server status connection closes after Pong Response" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CLOSE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The Status Response builder for the fixture's stated inputs.
     CALL "PB-RESET" USING PK-BUFFER
     MOVE 0 TO WS-ONLINE
     MOVE "A CobolCraft server" TO WS-DESCRIPTION
     CALL "STATUS-RESPONSE-BUILD" USING WS-ONLINE WS-DESCRIPTION PK-BUFFER
     MOVE "contract wire server Status Response builder (online 0, A CobolCraft server) equals "
         & "status-s2c-00-status-response" TO TL-CASE
     MOVE "status-s2c-00-status-response.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

*>   Intention with intent 2 (login), protocol 777: login phase, nothing sent yet.
     MOVE "handshake-c2s-00-intention-login.hex" TO WS-PATH(24:)
     PERFORM OPEN-CONN
     PERFORM FEED
     MOVE "contract wire server handshake-c2s-00-intention-login decodes: protocol 777, intent 2, "
         & "login phase, connection open" TO TL-CASE
     MOVE "777 2 2 0" TO TL-EXPECTED
     PERFORM ASSERT-INTENTION
*>   Intention with protocol 776: login phase, answered and closed (09 §2).
     MOVE "handshake-c2s-00-intention-other-protocol.hex" TO WS-PATH(24:)
     PERFORM OPEN-CONN
     PERFORM FEED
     MOVE "contract wire server handshake-c2s-00-intention-other-protocol decodes: protocol 776, "
         & "intent 2, login phase, closed" TO TL-CASE
     MOVE "776 2 2 1" TO TL-EXPECTED
     PERFORM ASSERT-INTENTION
     PERFORM DRAIN
     PERFORM NEXT-PACKET
     MOVE "contract wire server other protocol is answered by "
         & "login-s2c-00-login-disconnect-protocol-mismatch" TO TL-CASE
     MOVE "login-s2c-00-login-disconnect-protocol-mismatch.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

*>   Hello (login 0x00) decodes to the name and the profile UUID.
     MOVE "login-c2s-00-hello.hex" TO WS-PATH(24:)
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "LOGIN-HELLO-DECODE" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-UUID WS-OK
     MOVE WS-UUID TO WS-AREA
     CALL "TEST-HEX-OF" USING WS-AREA WS-SIXTEEN WS-HEX
     MOVE "contract wire server login-c2s-00-hello decodes: name Alice, offline UUID of Alice"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 Alice 5 10920508d5d83eed93d292f193afe7d7" TO TL-EXPECTED
     MOVE WS-NAME-LENGTH TO WS-EDIT
     MOVE WS-OK TO WS-EDIT2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-EDIT) " "
         WS-HEX(1:32) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Builders: Set Compression, Login Finished, Login Disconnect.
     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-COMPRESSION-BUILD" USING WS-THRESHOLD-256 PK-BUFFER
     MOVE "contract wire server Set Compression builder (256) equals login-s2c-03-set-compression"
         TO TL-CASE
     MOVE "login-s2c-03-set-compression.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-FINISHED-BUILD" USING WS-UUID WS-NAME WS-NAME-LENGTH PK-BUFFER
     MOVE "contract wire server Login Finished builder (Alice) equals login-s2c-02-login-finished"
         TO TL-CASE
     MOVE "login-s2c-02-login-finished.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "cobolcraft.disconnect.barred" TO PB-TX-VALUE
     MOVE 28 TO PB-TX-LENGTH
     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-DISCONNECT-BUILD" USING PB-TEXT PK-BUFFER
     MOVE "contract wire server Login Disconnect builder (barred) equals "
         & "login-s2c-00-login-disconnect-banned" TO TL-CASE
     MOVE "login-s2c-00-login-disconnect-banned.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "cobolcraft.disconnect.not_on_guestlist" TO PB-TX-VALUE
     MOVE 38 TO PB-TX-LENGTH
     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-DISCONNECT-BUILD" USING PB-TEXT PK-BUFFER
     MOVE "contract wire server Login Disconnect builder (not_on_guestlist) equals "
         & "login-s2c-00-login-disconnect-not-allow-listed" TO TL-CASE
     MOVE "login-s2c-00-login-disconnect-not-allow-listed.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "cobolcraft.disconnect.name_is_host" TO PB-TX-VALUE
     MOVE 34 TO PB-TX-LENGTH
     MOVE 1 TO PB-TX-ARG-COUNT
     MOVE "Alice" TO PB-TX-ARG-VALUE(1)
     MOVE 5 TO PB-TX-ARG-LENGTH(1)
     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-DISCONNECT-BUILD" USING PB-TEXT PK-BUFFER
     MOVE "contract wire server Login Disconnect builder (name_is_host Alice) equals "
         & "login-s2c-00-login-disconnect-name-in-use" TO TL-CASE
     MOVE "login-s2c-00-login-disconnect-name-in-use.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "multiplayer.disconnect.incompatible" TO PB-TX-VALUE
     MOVE 35 TO PB-TX-LENGTH
     MOVE "CobolCraft" TO PB-TX-ARG-VALUE(1)
     MOVE 10 TO PB-TX-ARG-LENGTH(1)
     CALL "PB-RESET" USING PK-BUFFER
     CALL "LOGIN-DISCONNECT-BUILD" USING PB-TEXT PK-BUFFER
     MOVE "contract wire server Login Disconnect builder (incompatible CobolCraft) equals "
         & "login-s2c-00-login-disconnect-protocol-mismatch" TO TL-CASE
     MOVE "login-s2c-00-login-disconnect-protocol-mismatch.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT

*>   Memory connection: Hello is answered by Login Finished alone (no Set Compression, 09 §2).
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND
     PERFORM OPEN-CONN
     MOVE "handshake-c2s-00-intention-login.hex" TO WS-PATH(24:)
     PERFORM FEED
     MOVE "login-c2s-00-hello.hex" TO WS-PATH(24:)
     PERFORM FEED
     PERFORM DRAIN
     MOVE -1 TO WS-THRESHOLD
     PERFORM NEXT-PACKET
     MOVE "contract wire server memory connection: Hello is answered by "
         & "login-s2c-02-login-finished" TO TL-CASE
     MOVE "login-s2c-02-login-finished.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     PERFORM NEXT-PACKET
     MOVE "contract wire server memory connection: no Set Compression, nothing after Login Finished"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Login Acknowledged (login 0x03) decodes and moves the connection to configuration.
     MOVE "login-c2s-03-login-acknowledged.hex" TO WS-PATH(24:)
     PERFORM FEED
     MOVE "contract wire server login-c2s-03-login-acknowledged decodes: configuration phase"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE PH-CONFIG TO TL-EXPECTED-N
     MOVE CN-PHASE(WS-CONN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Network connection: Set Compression (uncompressed), then Login Finished compressed at 256.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-NETWORK TO WS-KIND
     PERFORM OPEN-CONN
     MOVE "handshake-c2s-00-intention-login.hex" TO WS-PATH(24:)
     PERFORM FEED
     MOVE "login-c2s-00-hello.hex" TO WS-PATH(24:)
     PERFORM FEED
     PERFORM DRAIN
     MOVE -1 TO WS-THRESHOLD
     PERFORM NEXT-PACKET
     MOVE "contract wire server network connection: Hello is answered first by "
         & "login-s2c-03-set-compression, uncompressed" TO TL-CASE
     MOVE "login-s2c-03-set-compression.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 256 TO WS-THRESHOLD
     PERFORM NEXT-PACKET
*>   In the compressed layout PB-FRAME-DECODE keeps the Data length VarInt (0 for a short packet)
*>   in front of the id; the packet is rebuilt as id + body for the comparison.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     SET ADDRESS OF B-BYTES TO PK-ADDR
     COMPUTE WS-REST = PK-LENGTH - PK-POS
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BYTES(PK-POS + 1:1) WS-REST
     MOVE "contract wire server network connection: then login-s2c-02-login-finished in the "
         & "compressed frame layout" TO TL-CASE
     MOVE "login-s2c-02-login-finished.hex" TO WS-PATH(24:)
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "login-c2s-03-login-acknowledged.hex" TO WS-PATH(24:)
     PERFORM FEED
     MOVE "contract wire server network connection: compressed login-c2s-03-login-acknowledged "
         & "decodes: configuration phase" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE PH-CONFIG TO TL-EXPECTED-N
     MOVE CN-PHASE(WS-CONN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.

 OPEN-CONN.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN.

 FEED.
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 DRAIN.
*>   The close flag is read before draining: a drain that empties a closed connection releases it.
     MOVE CN-CLOSE(WS-CONN) TO WS-CLOSE
     CALL "PB-RESET" USING ST-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN ST-BUFFER WS-DRAIN-CLOSE.

 NEXT-PACKET.
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME.

 ASSERT-INTENTION.
     MOVE "T" TO TL-MODE
     MOVE CN-PROTOCOL(WS-CONN) TO WS-EDIT
     MOVE CN-INTENT(WS-CONN) TO WS-EDIT2
     MOVE CN-PHASE(WS-CONN) TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " "
         CN-CLOSE(WS-CONN) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM WIRE-STATUS-CASES.
