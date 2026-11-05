*> Implementation test of inbound handling (core/src/session.cob; 01 §2, §3, §5, §7): bytes split at
*> arbitrary boundaries assemble into packets, joined packets are each dispatched by the phase they
*> arrive in, and a packet or frame the core cannot decode closes the connection (01 §5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SESSION-INBOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY TESTLIB.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-THRESHOLD           BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-FIXTURE             PIC X(256).
 01 WS-PHASE-BEFORE        BINARY-LONG.
 01 WS-IDS                 PIC X(64).
 01 WS-EDIT                PIC Z(8)9.
 01 WS-BAD                 BINARY-LONG VALUE -1.   *> bytes FF FF FF FF
 01 B-FRAME                PIC X(4096) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING FR-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY

*>   One byte at a time: nothing happens until the frame is complete.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-FIXTURE
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PB-BUFFER
     MOVE -1 TO WS-THRESHOLD
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER WS-THRESHOLD
     SET ADDRESS OF B-FRAME TO FR-ADDR
     MOVE 1 TO CB-LENGTH CB-CAPACITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FR-LENGTH
         MOVE CN-PHASE(WS-ID) TO WS-PHASE-BEFORE
         SET CB-ADDR TO ADDRESS OF B-FRAME(WS-I:1)
         CALL "CORE-CONN-INPUT" USING WS-ID CORE-BUFFER
     END-PERFORM
     MOVE "test session inbound an Intention fed one byte at a time is handled after its last byte"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = PH-HANDSHAKE * 10 + PH-STATUS
     COMPUTE TL-OBSERVED-N = WS-PHASE-BEFORE * 10 + CN-PHASE(WS-ID)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Joined packets: Intention, Status Request and Ping Request in one input are dispatched in
*>   order, the last two by the status phase (answered by Status Response and Pong Response).
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PB-RESET" USING FR-BUFFER
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-FIXTURE
     PERFORM FRAME-FIXTURE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-FIXTURE
     PERFORM FRAME-FIXTURE
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-FIXTURE
     PERFORM FRAME-FIXTURE
     SET CB-ADDR TO FR-ADDR
     MOVE FR-LENGTH TO CB-LENGTH CB-CAPACITY
     CALL "CORE-CONN-INPUT" USING WS-ID CORE-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     MOVE SPACES TO WS-IDS
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-IDS) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
                 INTO WS-IDS
         END-IF
     END-PERFORM
     MOVE "test session inbound joined packets are dispatched in order by the status phase" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-IDS) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Undecodable input closes the connection (01 §5).
     MOVE "test session inbound an unknown handshake packet id closes the connection" TO TL-CASE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 5 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-AND-EXPECT-CLOSE

     MOVE "test session inbound an Intention with intent 4 closes the connection" TO TL-CASE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-FIXTURE
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PB-BUFFER
     SUBTRACT 1 FROM PB-LENGTH
     MOVE 4 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-AND-EXPECT-CLOSE

     MOVE "test session inbound an Intention with bytes left over closes the connection" TO TL-CASE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-AND-EXPECT-CLOSE

     MOVE "test session inbound a frame length wider than 3 bytes closes the connection" TO TL-CASE
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     SET CB-ADDR TO ADDRESS OF WS-BAD
     MOVE 4 TO CB-LENGTH CB-CAPACITY
     CALL "CORE-CONN-INPUT" USING WS-ID CORE-BUFFER
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CN-CLOSE(WS-ID) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test session inbound bytes received after the close flag are dropped" TO TL-CASE
     MOVE CN-IN(WS-ID) TO FR-BUFFER
     MOVE FR-LENGTH TO TL-EXPECTED-N
     CALL "CORE-CONN-INPUT" USING WS-ID CORE-BUFFER
     MOVE CN-IN(WS-ID) TO FR-BUFFER
     MOVE FR-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Compressed frames (01 §3.3) once compression is on: a short packet with Data length 0 is
*>   accepted; a compressed packet below the threshold is rejected (server-side validation).
     CALL "PB-INIT" USING FR-BUFFER WS-CAPACITY
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE 1 TO CN-COMPRESS(WS-ID)
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-FIXTURE
     CALL "TEST-FEED" USING WS-ID WS-FIXTURE
     MOVE "test session inbound with compression on a frame with Data length 0 is decoded" TO TL-CASE
     MOVE PH-STATUS TO TL-EXPECTED-N
     MOVE CN-PHASE(WS-ID) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE 1 TO CN-COMPRESS(WS-ID)
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PB-BUFFER
     CALL "PB-RESET" USING FR-BUFFER
     MOVE 0 TO WS-THRESHOLD
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER WS-THRESHOLD
     SET CB-ADDR TO FR-ADDR
     MOVE FR-LENGTH TO CB-LENGTH CB-CAPACITY
     CALL "CORE-CONN-INPUT" USING WS-ID CORE-BUFFER
     MOVE "test session inbound a compressed packet below the threshold closes the connection" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CN-CLOSE(WS-ID) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FRAME-FIXTURE.
     CALL "TEST-LOAD-HEX" USING WS-FIXTURE PK-BUFFER
     MOVE -1 TO WS-THRESHOLD
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PK-BUFFER WS-THRESHOLD.

 FEED-AND-EXPECT-CLOSE.
     CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CN-CLOSE(WS-ID) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SESSION-INBOUND.

 COPY CORETEST.
