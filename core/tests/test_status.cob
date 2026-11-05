*> Implementation test of core/src/status.cob and core/src/login.cob: the paths the acceptance and
*> contract tests leave unexecuted. Status: a second Status Request, malformed and unknown packets,
*> a description that needs JSON escaping and a non-zero online count (02 Status phase; 01 §7.3;
*> 09 §1, §2). Login: transfer intent and outdated client (02; 09 §2), protocol errors (02 "Login
*> timeouts and errors"), unsolicited Custom Query Answer and Cookie Response (02; 09 §4), the name
*> rule (09 §1), a name already in use by a connection still in configuration, a full player table
*> (FR-012), and the 09 §1 JSON forms.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STATUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FP-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PATH                PIC X(256).
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-CONN                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DRAIN-CLOSE         BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS                 PIC X(64).
 01 WS-PTR                 BINARY-LONG.
 01 WS-JSON                PIC X(4096).
 01 WS-JSON-CAPACITY       BINARY-LONG VALUE 4096.
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-JSON-MAX            BINARY-LONG VALUE 262144.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-STRING-MAX          BINARY-LONG VALUE 32767.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RESULT              PIC X(3).
 01 WS-CONSOLE             PIC X(512).
 01 B-BYTES                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING FP-BUFFER WS-CAPACITY
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   Status: only the first Status Request is answered; a second one closes (01 §7.3).
     PERFORM OPEN-STATUS
     PERFORM FEED-STATUS-REQUEST
     PERFORM FEED-STATUS-REQUEST
     PERFORM DRAIN-ALL
     MOVE "test status a second Status Request closes the connection without a second response"
         TO TL-CASE
     MOVE "ids 0; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Status: a Status Request with a byte left over is undecodable (01 §5).
     PERFORM OPEN-STATUS
     PERFORM START-PACKET
     MOVE 0 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test status a Status Request with a byte left over closes without an answer" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Status: a Ping Request whose Long is cut short is undecodable.
     PERFORM OPEN-STATUS
     PERFORM START-PACKET
     MOVE 1 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test status a Ping Request with a 4-byte time closes without a Pong" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Status: an unknown packet id is undecodable.
     PERFORM OPEN-STATUS
     PERFORM START-PACKET
     MOVE 2 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test status packet id 2 closes the connection" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Status: the description is JSON-escaped and the online count is the players in play.
     MOVE 'Say "hi" \o/' TO CS-DESCRIPTION
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM OPEN-LOGIN
     PERFORM FEED-HELLO
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     PERFORM OPEN-STATUS
     PERFORM FEED-STATUS-REQUEST
     PERFORM DRAIN-ALL
     MOVE "test status Status Response escapes the description and counts the player in play"
         TO TL-CASE
     MOVE 'ids 0; close 0; json {"version":{"name":"CobolCraft","protocol":777},"players":{"max":'
         & '20,"online":1},"description":"Say \"hi\" \\o/"}' TO TL-EXPECTED
     PERFORM ASSERT-JSON
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   Login: intent 3 (transfer) is refused with transfers_disabled (02; 09 §2).
     MOVE 777 TO WS-VALUE
     MOVE 3 TO WS-I
     PERFORM OPEN-INTENTION
     PERFORM DRAIN-ALL
     MOVE "test login intent 3 (transfer) gets Login Disconnect transfers_disabled and closes"
         TO TL-CASE
     MOVE 'ids 0; close 1; json {"translate":"multiplayer.disconnect.transfers_disabled"}'
         TO TL-EXPECTED
     PERFORM ASSERT-JSON

*>   Login: a client older than 754 gets outdated_client (02; 09 §2).
     MOVE 47 TO WS-VALUE
     MOVE 2 TO WS-I
     PERFORM OPEN-INTENTION
     PERFORM DRAIN-ALL
     MOVE "test login protocol 47 (below 754) gets Login Disconnect outdated_client CobolCraft"
         TO TL-CASE
     MOVE 'ids 0; close 1; json {"translate":"multiplayer.disconnect.outdated_client","with":'
         & '["CobolCraft"]}' TO TL-EXPECTED
     PERFORM ASSERT-JSON

*>   Login: Login Acknowledged before Login Finished is a protocol error (02).
     PERFORM OPEN-LOGIN
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     PERFORM DRAIN-ALL
     MOVE "test login Login Acknowledged before Hello closes the connection" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Login: a second Hello is a protocol error (02).
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM OPEN-LOGIN
     PERFORM FEED-HELLO
     PERFORM FEED-HELLO
     PERFORM DRAIN-ALL
     MOVE "test login a second Hello closes the connection after the first Login Finished"
         TO TL-CASE
     MOVE "ids 2; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Login: a name outside the 09 §1 rule is refused like an undecodable Hello.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM OPEN-LOGIN
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     SET ADDRESS OF B-BYTES TO PB-ADDR
     MOVE "-" TO B-BYTES(5:1)
     PERFORM FEED-PACKET
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     PERFORM DRAIN-ALL
     MOVE "test login Hello with the name Al-ce closes the connection, no player" TO TL-CASE
     MOVE "ids ; close 1; player 0" TO TL-EXPECTED
     PERFORM ASSERT-IDS-PLAYER

*>   Login: unsolicited Custom Query Answer (transaction 5, no payload) (02; 09 §4).
     PERFORM OPEN-LOGIN
     PERFORM START-PACKET
     MOVE 2 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 5 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE 0 TO WS-VALUE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login unsolicited Custom Query Answer gets unexpected_query_response and closes"
         TO TL-CASE
     MOVE 'ids 0; close 1; json {"translate":"multiplayer.disconnect.unexpected_query_response"}'
         TO TL-EXPECTED
     PERFORM ASSERT-JSON

*>   Login: a Custom Query Answer without its transaction id is undecodable.
     PERFORM OPEN-LOGIN
     PERFORM START-PACKET
     MOVE 2 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login Custom Query Answer with no transaction id closes without a packet"
         TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Login: unsolicited Cookie Response without and with a payload (02; 09 §4).
     PERFORM OPEN-LOGIN
     MOVE 0 TO WS-COUNT
     PERFORM BUILD-COOKIE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login unsolicited Cookie Response (no payload) gets unexpected_query_response"
         TO TL-CASE
     MOVE 'ids 0; close 1; json {"translate":"multiplayer.disconnect.unexpected_query_response"}'
         TO TL-EXPECTED
     PERFORM ASSERT-JSON

     PERFORM OPEN-LOGIN
     MOVE 3 TO WS-COUNT
     PERFORM BUILD-COOKIE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login unsolicited Cookie Response (3-byte payload) gets unexpected_query_response"
         TO TL-CASE
     PERFORM ASSERT-JSON

*>   Login: a Cookie Response payload above 5120 bytes is undecodable (ByteArray(5120)).
     PERFORM OPEN-LOGIN
     MOVE 5121 TO WS-COUNT
     PERFORM BUILD-COOKIE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login Cookie Response with a 5121-byte payload closes without a packet" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Login: packet id 1 (Key) is never expected: undecodable (09 §4).
     PERFORM OPEN-LOGIN
     PERFORM START-PACKET
     MOVE 1 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM FEED-PACKET
     PERFORM DRAIN-ALL
     MOVE "test login packet id 1 (Key) closes the connection" TO TL-CASE
     MOVE "ids ; close 1" TO TL-EXPECTED
     PERFORM ASSERT-IDS

*>   Login: the same name while the earlier connection is in configuration: the earlier one gets
*>   the configuration Disconnect (09 §3.1) and closes, its player leaves, the new one logs in.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM OPEN-LOGIN
     MOVE WS-CONN TO WS-FIRST
     PERFORM FEED-HELLO
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     PERFORM DRAIN-ALL
     PERFORM OPEN-LOGIN
     MOVE WS-CONN TO WS-SECOND
     PERFORM FEED-HELLO
     MOVE WS-FIRST TO WS-CONN
     PERFORM DRAIN-ALL
     MOVE "no" TO WS-RESULT
     IF WS-OUTCOME NOT = 2 AND FP-LENGTH > 0
         CALL "PB-GET-TEXT" USING FP-BUFFER PB-TEXT
         IF PB-TX-VALUE(1:PB-TX-LENGTH) = "cobolcraft.disconnect.replaced"
             MOVE "yes" TO WS-RESULT
         END-IF
     END-IF
     MOVE SPACES TO WS-JSON
     STRING FUNCTION TRIM(WS-IDS) " replaced " FUNCTION TRIM(WS-RESULT)
         DELIMITED BY SIZE INTO WS-JSON
     MOVE WS-CLOSE TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "close " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-SECOND TO WS-CONN
     PERFORM DRAIN-ALL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "PLAYER-FIND-NAME" USING WS-NAME WS-NAME-LENGTH WS-ROW
     MOVE "no" TO WS-RESULT
     IF WS-ROW > 0
         IF PL-CONN(WS-ROW) = WS-SECOND
             MOVE "yes" TO WS-RESULT
         END-IF
     END-IF
     MOVE "test login the same name while the earlier connection is in configuration replaces it"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "first: 2 replaced yes close 1; second: 2 close 0; Alice on second yes" TO TL-EXPECTED
     MOVE WS-CLOSE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "first: " FUNCTION TRIM(WS-JSON) " " FUNCTION TRIM(WS-TEXT) "; second: "
         FUNCTION TRIM(WS-IDS) " close " FUNCTION TRIM(WS-EDIT) "; Alice on second "
         FUNCTION TRIM(WS-RESULT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Login: a full player table: one ERROR console line and the connection closes (FR-012).
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-PLAYERS
         MOVE 1 TO PL-USED(WS-I)
     END-PERFORM
     PERFORM OPEN-LOGIN
     PERFORM FEED-HELLO
     PERFORM DRAIN-ALL
     SET CB-ADDR TO ADDRESS OF WS-CONSOLE
     MOVE 512 TO CB-CAPACITY
     MOVE SPACES TO WS-CONSOLE
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE "test login a full player table logs one ERROR line and closes the connection"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ids ; close 1; console ERROR login: the player table is full|" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     INSPECT WS-CONSOLE REPLACING ALL X"0A" BY "|"
     MOVE WS-CLOSE TO WS-EDIT
     STRING "ids " FUNCTION TRIM(WS-IDS) "; close " FUNCTION TRIM(WS-EDIT) "; console "
         WS-CONSOLE(1:CB-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   09 §1 JSON forms: plain text (escaped), translate with two arguments.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 'a"b\c' TO PB-TX-VALUE
     MOVE 5 TO PB-TX-LENGTH
     CALL "PB-RESET" USING FP-BUFFER
     CALL "TEXT-JSON" USING PB-TEXT FP-BUFFER
     MOVE SPACES TO WS-JSON
     SET ADDRESS OF B-BYTES TO FP-ADDR
     MOVE B-BYTES(1:FP-LENGTH) TO WS-JSON
     MOVE "|" TO WS-JSON(FP-LENGTH + 1:1)
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "k" TO PB-TX-VALUE
     MOVE 1 TO PB-TX-LENGTH
     MOVE 2 TO PB-TX-ARG-COUNT
     MOVE "x" TO PB-TX-ARG-VALUE(1)
     MOVE 1 TO PB-TX-ARG-LENGTH(1)
     MOVE 'y"' TO PB-TX-ARG-VALUE(2)
     MOVE 2 TO PB-TX-ARG-LENGTH(2)
     MOVE FP-LENGTH TO WS-PTR
     CALL "TEXT-JSON" USING PB-TEXT FP-BUFFER
     SET ADDRESS OF B-BYTES TO FP-ADDR
     COMPUTE WS-COUNT = FP-LENGTH - WS-PTR
     MOVE B-BYTES(WS-PTR + 1:WS-COUNT) TO WS-JSON(WS-PTR + 2:WS-COUNT)
     MOVE "test login JSON text forms: plain text escaped, translate with two arguments" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE '"a\"b\\c"|{"translate":"k","with":["x","y\""]}' TO TL-EXPECTED
     MOVE WS-JSON TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   09 §1 name rule.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE "a_Z9" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     PERFORM CHECK-NAME
     MOVE 0 TO WS-NAME-LENGTH
     PERFORM CHECK-NAME
     MOVE "abcdefghijklmnopq" TO WS-TEXT
     MOVE 17 TO WS-NAME-LENGTH
     CALL "LOGIN-NAME-VALID" USING WS-TEXT WS-NAME-LENGTH WS-VALID
     MOVE WS-VALID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "a b" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     PERFORM CHECK-NAME
     MOVE "ab~" TO WS-NAME
     PERFORM CHECK-NAME
     MOVE "test login name rule: a_Z9 valid; empty, 17 characters, a b and ab~ invalid" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     CALL "PB-FREE" USING FP-BUFFER
     STOP RUN.

 OPEN-STATUS.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 OPEN-LOGIN.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

*> An Intention with protocol WS-VALUE and intent WS-I on a new connection.
 OPEN-INTENTION.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     PERFORM START-PACKET
     MOVE 0 TO WS-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE "localhost" TO WS-TEXT
     MOVE 9 TO WS-TEXT-LENGTH
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-LENGTH WS-STRING-MAX
     MOVE 25565 TO WS-COUNT
     CALL "PB-PUT-USHORT" USING PB-BUFFER WS-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-I
     PERFORM FEED-PACKET.

 FEED-STATUS-REQUEST.
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 FEED-HELLO.
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 START-PACKET.
     CALL "PB-RESET" USING PB-BUFFER.

 FEED-PACKET.
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER.

*> Cookie Response (login 0x04): key minecraft:k, then a payload of WS-COUNT zero bytes (none
*> when WS-COUNT = 0).
 BUILD-COOKIE.
     PERFORM START-PACKET
     MOVE 4 TO WS-VALUE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-VALUE
     MOVE "minecraft:k" TO WS-TEXT
     MOVE 11 TO WS-TEXT-LENGTH
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-TEXT WS-TEXT-LENGTH
     IF WS-COUNT = 0
         MOVE 0 TO WS-VALUE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-VALUE
     ELSE
         MOVE 1 TO WS-VALUE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-VALUE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE 0 TO WS-VALUE
             CALL "PB-PUT-BYTE" USING PB-BUFFER WS-VALUE
         END-PERFORM
     END-IF.

*> Drains WS-CONN: WS-CLOSE = its close flag (read before the drain, which may release it),
*> WS-IDS = the packet ids received, FP-BUFFER = the first packet (PB-POS after its id).
 DRAIN-ALL.
     MOVE CN-CLOSE(WS-CONN) TO WS-CLOSE
     CALL "PB-RESET" USING ST-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN ST-BUFFER WS-DRAIN-CLOSE
     MOVE SPACES TO WS-IDS
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-OUTCOME WS-COUNT
     CALL "PB-RESET" USING FP-BUFFER
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-COUNT
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-IDS WITH POINTER WS-PTR
             IF WS-COUNT = 1
                 MOVE PK-BUFFER TO FP-BUFFER
                 CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
             END-IF
         END-IF
     END-PERFORM.

 ASSERT-IDS.
     MOVE "T" TO TL-MODE
     MOVE WS-CLOSE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "ids " FUNCTION TRIM(WS-IDS) "; close " FUNCTION TRIM(WS-EDIT)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-IDS-PLAYER.
     MOVE "T" TO TL-MODE
     MOVE WS-CLOSE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-PLAYER TO WS-EDIT2
     STRING "ids " FUNCTION TRIM(WS-IDS) "; close " FUNCTION TRIM(WS-EDIT) "; player "
         FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The first packet's String (Status Response or Login Disconnect JSON) after the ids and close.
 ASSERT-JSON.
     MOVE SPACES TO WS-JSON
     MOVE 0 TO WS-JSON-LENGTH
     IF FP-LENGTH > 0
         CALL "PB-GET-STRING" USING FP-BUFFER WS-JSON-MAX WS-JSON WS-JSON-CAPACITY WS-JSON-LENGTH
     END-IF
     MOVE "T" TO TL-MODE
     MOVE WS-CLOSE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "ids " FUNCTION TRIM(WS-IDS) "; close " FUNCTION TRIM(WS-EDIT) "; json "
         WS-JSON DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NAME.
     CALL "LOGIN-NAME-VALID" USING WS-NAME WS-NAME-LENGTH WS-VALID
     MOVE WS-VALID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.
 END PROGRAM TEST-STATUS.

 COPY CORETEST.
