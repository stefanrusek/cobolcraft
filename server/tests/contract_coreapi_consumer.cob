*> Contract test, the server's consumer side of the game core host API (contracts/core-host-api.md
*> §1, §2, §4): record lengths and constant values from COREAPI.cpy; the host's start sequence
*> (CORE-WORLD-OPEN of ./world, then listen); the per-connection pump (CORE-CONN-OPEN network,
*> CORE-CONN-INPUT, CORE-CONN-OUTPUT, the close flag, CORE-CONN-CLOSED) seen from a loopback client;
*> and the tick cadence (one CORE-TICK per elapsed 50 ms). Runs in the scratch directory
*> build/server-test-contract (the server works in its current directory, operator-surface §1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONTRACT-COREAPI-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY SVSTATE.
 COPY TESTLIB.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-contract".
 01 WS-WORLD-DIR           PIC X(16) VALUE "world".
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PORT                BINARY-LONG VALUE 25565.
 01 WS-CLIENT              BINARY-LONG.
 01 WS-STATUS-CLIENT       BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-COMPRESSED          BINARY-LONG VALUE 256.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-CLOSED              BINARY-LONG.
 01 WS-EVER-CLOSED         BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-START               BINARY-DOUBLE.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-SHUTDOWN            PIC X(16) VALUE Z"shutdown".
 01 WS-STATE-BEFORE        BINARY-LONG.
 01 WS-LEVEL-DAT           PIC X(32) VALUE "world/level.dat".
 01 WS-CAPTURE             PIC X(256) VALUE "stdout.txt".
 01 WS-CAPTURED            PIC X(4096).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE "N" TO TL-MODE
     MOVE "contract server coreapi consumer record lengths CORE-SETTINGS 3829 CORE-BUFFER 16 "
         & "CORE-STATUS 5 (core-host-api §1)" TO TL-CASE
     MOVE 3829016005 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = LENGTH OF CORE-SETTINGS * 1000000 + LENGTH OF CORE-BUFFER * 1000
         + LENGTH OF CORE-STATUS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract server coreapi consumer connection kinds network 0 memory 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CORE-CONN-NETWORK * 10 + CORE-CONN-MEMORY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract server coreapi consumer the host keeps a whole CORE-SETTINGS record" TO TL-CASE
     MOVE LENGTH OF CORE-SETTINGS TO TL-EXPECTED-N
     MOVE LENGTH OF SV-SETTINGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Start: CORE-WORLD-OPEN of ./world, then listening on the configured port.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     CALL "SV-START"
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     CALL "SVT-CONNECT" USING WS-PORT WS-CLIENT
     CALL STATIC "cc_net_status" USING BY VALUE WS-CLIENT RETURNING WS-OUTCOME
     MOVE "contract server coreapi consumer SV-START opens ./world with CORE-WORLD-OPEN, then listens "
         & "on port 25565; the core runs (state 0, nobody online)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "world port 25565 accepting run 0 online 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-WORLD-DIR WS-FILE-INFO
     IF RETURN-CODE = 0
         MOVE "world" TO TL-OBSERVED
     END-IF
     MOVE SV-BOUND-PORT TO WS-EDIT
     STRING FUNCTION TRIM(TL-OBSERVED) " port " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     IF WS-OUTCOME = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " accepting" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE CST-RUN-STATE TO WS-EDIT
     MOVE CST-PLAYERS-ONLINE TO WS-EDIT2
     STRING FUNCTION TRIM(TL-OBSERVED) " run " FUNCTION TRIM(WS-EDIT) " online "
         FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 0 TO RETURN-CODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-CLIENT

*>   Per-connection pump, status: Status Response, then the Pong of the Ping.
     CALL "SVT-CONNECT" USING WS-PORT WS-STATUS-CLIENT
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-STATUS-CLIENT WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-STATUS-CLIENT WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-STATUS-CLIENT WS-PATH WS-NONE
     MOVE WS-STATUS-CLIENT TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     PERFORM 10 TIMES
         PERFORM ITERATE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "contract server coreapi consumer status through SV-ITERATE: Status Response" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 1000 + WS-PACKET-ID
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "contract server coreapi consumer status through SV-ITERATE: Pong Response" TO TL-CASE
     MOVE "contract/fixtures/wire/status-s2c-01-pong-response.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-STATUS-CLIENT

*>   Per-connection pump, login and configuration: Alice comes online.
     CALL "SVT-CONNECT" USING WS-PORT WS-ALICE
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-ALICE WS-PATH WS-NONE
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-ALICE WS-PATH WS-NONE
     MOVE WS-ALICE TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     PERFORM 5 TIMES
         PERFORM ITERATE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "contract server coreapi consumer login through SV-ITERATE: Set Compression (network)"
         TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-03-set-compression.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-COMPRESSED WS-PACKET-ID WS-OUTCOME
     MOVE "contract server coreapi consumer login through SV-ITERATE: Login Finished" TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-02-login-finished.hex" TO WS-PATH
     CALL "SVT-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "SVT-CONFIGURE" USING WS-ALICE
     PERFORM 40 TIMES
         PERFORM ITERATE-AND-RECEIVE
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "contract server coreapi consumer after configuration through SV-ITERATE one player is "
         & "online" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CST-PLAYERS-ONLINE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Close flag: a login with another protocol version gets Login Disconnect, then the close.
     CALL "SVT-CONNECT" USING WS-PORT WS-MISMATCH
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-other-protocol.hex" TO WS-PATH
     CALL "SVT-SEND-FIXTURE" USING WS-MISMATCH WS-PATH WS-NONE
     MOVE WS-MISMATCH TO WS-CLIENT
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 0 TO WS-EVER-CLOSED
     PERFORM 10 TIMES
         PERFORM ITERATE-AND-RECEIVE
     END-PERFORM
     CALL "SVT-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-NONE WS-PACKET-ID WS-OUTCOME
     MOVE "contract server coreapi consumer close flag: Login Disconnect, then the transport closes"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "packet 0 closed 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT = WS-OUTCOME * 1000 + WS-PACKET-ID
     MOVE WS-EVER-CLOSED TO WS-EDIT2
     STRING "packet " FUNCTION TRIM(WS-EDIT) " closed " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-MISMATCH

*>   CORE-CONN-CLOSED: Alice's client closes and she is no longer online.
     CALL STATIC "cc_net_close" USING BY VALUE WS-ALICE
     PERFORM 5 TIMES
         CALL "SV-ITERATE"
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "contract server coreapi consumer a peer close reaches CORE-CONN-CLOSED: nobody online"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CST-PLAYERS-ONLINE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tick cadence: one CORE-TICK per elapsed 50 ms, 20 in a second (18 to 22 allows the clock's
*>   10 ms resolution at both ends).
     MOVE SV-TICKS TO WS-TICKS
     CALL "SVT-NOW-MS" USING WS-START
     MOVE WS-START TO WS-NOW
     PERFORM UNTIL WS-NOW - WS-START >= 1000
         CALL "SV-ITERATE"
         CALL "SVT-NOW-MS" USING WS-NOW
     END-PERFORM
     COMPUTE WS-TICKS = SV-TICKS - WS-TICKS
     MOVE "contract server coreapi consumer one CORE-TICK per elapsed 50 ms: 18 to 22 in a second"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "in range" TO TL-EXPECTED
     MOVE WS-TICKS TO WS-EDIT
     MOVE WS-EDIT TO TL-OBSERVED
     IF WS-TICKS >= 18 AND WS-TICKS <= 22
         MOVE "in range" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Stop handling (core-host-api §2): the stop command sets run state 1; the next SV-ITERATE turns
*>   it into CORE-STOP with the stopping text (the world saved, run state 2), flushes, and prints
*>   the Stopping and Stopped lines; the host exits after run state 2 (SV-RUN, test_sv_main).
*>   level.dat is removed first, so finding it afterwards shows the save.
     CALL "CBL_DELETE_FILE" USING WS-LEVEL-DAT
     CALL "CORE-CONSOLE" USING WS-SHUTDOWN
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-RUN-STATE TO WS-STATE-BEFORE
     CALL "SVT-CAPTURE-START" USING WS-CAPTURE
     CALL "SV-ITERATE"
     CALL "SVT-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     CALL "SVT-UNSTAMP" USING WS-CAPTURED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "contract server coreapi consumer stop handling: run state 1, then SV-ITERATE calls "
         & "CORE-STOP (run state 2, level.dat saved) between the Stopping and Stopped lines"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "run 1 then 2 saved | Shutting down | Stopping: saving world and disconnecting players | "
         & "Stopped" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATE-BEFORE TO WS-EDIT
     MOVE CST-RUN-STATE TO WS-EDIT2
     STRING "run " FUNCTION TRIM(WS-EDIT) " then " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-LEVEL-DAT WS-FILE-INFO
     IF RETURN-CODE = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " saved" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE 0 TO RETURN-CODE
     STRING FUNCTION TRIM(TL-OBSERVED) " | " FUNCTION TRIM(WS-CAPTURED) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SV-SHUTDOWN"
     STOP RUN.

 ITERATE-AND-RECEIVE.
     CALL "SV-ITERATE"
     CALL "SVT-RECV" USING WS-CLIENT ST-BUFFER WS-WAIT WS-CLOSED
     IF WS-CLOSED = 1
         MOVE 1 TO WS-EVER-CLOSED
     END-IF.
 END PROGRAM SV-CONTRACT-COREAPI-CONSUMER.
 COPY SVTEST.
