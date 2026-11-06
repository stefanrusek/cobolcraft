*> Contract test, the client side of the wire profile (contracts/proto-api.md §4; wire-profile.md
*> §3; docs/protocol/09-cobolcraft-profile.md): every serverbound fixture the client sends in
*> status, login, configuration and the play join equals what the client's builders (or its
*> replies) produce for the fixture's stated inputs, and every clientbound fixture of those phases
*> decodes to the stated values; then the play packets of moving and of other players (US3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-WIRE-CLIENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256).
 01 WS-HOST                PIC X(256) VALUE "localhost".
 01 WS-HOST-LENGTH         BINARY-LONG VALUE 9.
 01 WS-PORT                BINARY-LONG VALUE 25565.
 01 WS-INTENT              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE VALUE 1762300800000.
 01 WS-KEEP                BINARY-DOUBLE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-VIEW                BINARY-LONG VALUE 8.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-X                   FLOAT-LONG VALUE 4.5.
 01 WS-Y                   FLOAT-LONG VALUE 54.0.
 01 WS-Z                   FLOAT-LONG VALUE 8.5.
 01 WS-YAW                 FLOAT-SHORT VALUE -90.0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-RATE                FLOAT-SHORT VALUE 9.0.
 01 WS-TID                 BINARY-LONG VALUE 1.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-STATE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MX                  FLOAT-LONG VALUE 5.25.
 01 WS-MY                  FLOAT-LONG VALUE 54.0.
 01 WS-MZ                  FLOAT-LONG VALUE 8.5.
 01 WS-MYAW                FLOAT-SHORT VALUE 45.0.
 01 WS-MPITCH              FLOAT-SHORT VALUE 30.0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EID                 BINARY-LONG.
 01 WS-NAME-OUT            PIC X(16).
 01 WS-NAME-OUT-LENGTH     BINARY-LONG.
 01 WS-REGISTRIES.
    05 FILLER PIC X(40) VALUE "cat-sound-variant".
    05 FILLER PIC X(40) VALUE "cat-variant".
    05 FILLER PIC X(40) VALUE "chat-type".
    05 FILLER PIC X(40) VALUE "chicken-sound-variant".
    05 FILLER PIC X(40) VALUE "chicken-variant".
    05 FILLER PIC X(40) VALUE "cow-sound-variant".
    05 FILLER PIC X(40) VALUE "cow-variant".
    05 FILLER PIC X(40) VALUE "damage-type".
    05 FILLER PIC X(40) VALUE "dimension-type".
    05 FILLER PIC X(40) VALUE "frog-variant".
    05 FILLER PIC X(40) VALUE "painting-variant".
    05 FILLER PIC X(40) VALUE "pig-sound-variant".
    05 FILLER PIC X(40) VALUE "pig-variant".
    05 FILLER PIC X(40) VALUE "wolf-sound-variant".
    05 FILLER PIC X(40) VALUE "wolf-variant".
    05 FILLER PIC X(40) VALUE "world-clock".
    05 FILLER PIC X(40) VALUE "worldgen-biome".
    05 FILLER PIC X(40) VALUE "zombie-nautilus-variant".
 01 WS-REGISTRY-TABLE REDEFINES WS-REGISTRIES.
    05 WS-REGISTRY         PIC X(40) OCCURS 18 TIMES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH

*>   ---- status and login: builders ----
     MOVE 1 TO WS-INTENT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-INTENTION" USING PB-BUFFER WS-HOST WS-HOST-LENGTH WS-PORT WS-INTENT
     MOVE "contract wire client Intention (status) equals handshake-c2s-00-intention-status.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-status.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 2 TO WS-INTENT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-INTENTION" USING PB-BUFFER WS-HOST WS-HOST-LENGTH WS-PORT WS-INTENT
     MOVE "contract wire client Intention (login) equals handshake-c2s-00-intention-login.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 0 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-SIMPLE" USING PB-BUFFER WS-ID
     MOVE "contract wire client Status Request equals status-c2s-00-status-request.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/status-c2s-00-status-request.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PING-REQUEST" USING PB-BUFFER WS-TIME
     MOVE "contract wire client Ping Request equals status-c2s-01-ping-request.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/status-c2s-01-ping-request.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-HELLO" USING PB-BUFFER WS-NAME WS-NAME-LENGTH
     MOVE "contract wire client Hello (Alice, offline UUID) equals login-c2s-00-hello.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 3 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-SIMPLE" USING PB-BUFFER WS-ID
     MOVE "contract wire client Login Acknowledged equals login-c2s-03-login-acknowledged.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   ---- status: decoding (a ping connection for server-list entry 1) ----
     MOVE 1 TO SL-COUNT
     MOVE CONN-PING TO WS-CONN
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-STATUS TO CN-PHASE(WS-CONN)
     MOVE 1 TO CN-ENTRY(WS-CONN)
     MOVE "contract/fixtures/wire/status-s2c-00-status-response.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Status Response decodes to description, 0 of 20 online, protocol "
         & "777 (compatible), then Ping Request is sent" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "A CobolCraft server|0|20|0|CobolCraft|01" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE SL-ONLINE(1) TO WS-EDIT
     MOVE SL-MAX(1) TO WS-EDIT2
     CALL "TEST-SENT-IDS" USING CLIENT-STATE WS-CONN WS-TEXT
     STRING SL-DESC(1)(1:SL-DESC-LENGTH(1)) "|" FUNCTION TRIM(WS-EDIT) "|" FUNCTION TRIM(WS-EDIT2)
         "|" SL-INCOMPATIBLE(1) "|" SL-VERSION(1)(1:SL-VERSION-LENGTH(1)) "|"
         FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/status-s2c-01-pong-response.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Pong Response ends the status exchange: the entry is answered, the "
         & "connection closed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = SLS-ANSWERED * 10 + PH-NONE
     COMPUTE TL-OBSERVED-N = SL-STATUS(1) * 10 + CN-PHASE(WS-CONN)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ---- login: decoding on the game connection ----
     MOVE CONN-GAME TO WS-CONN
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-LOGIN TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/login-s2c-03-set-compression.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Set Compression decodes to threshold 256" TO TL-CASE
     MOVE 256 TO TL-EXPECTED-N
     MOVE CN-THRESHOLD(WS-CONN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/login-s2c-02-login-finished.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Login Finished: Login Acknowledged, brand and Client Information "
         & "are sent and the connection is in configuration" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SENT-IDS" USING CLIENT-STATE WS-CONN WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE CN-PHASE(WS-CONN) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " phase " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "03 02 00 phase 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client brand equals config-c2s-02-custom-payload-brand.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 3 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client Client Information equals config-c2s-00-client-information.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

*>   ---- configuration ----
     MOVE "contract/fixtures/wire/config-s2c-01-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-0d-update-enabled-features.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-0f-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client Select Known Packs is answered with config-c2s-07-select-known-"
         & "packs.hex; brand and features need no answer" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE SPACES TO WS-PATH
         STRING "contract/fixtures/wire/config-s2c-07-registry-data-" FUNCTION TRIM(WS-REGISTRY(WS-I))
             ".hex" DELIMITED BY SIZE INTO WS-PATH
         CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     END-PERFORM
     MOVE "contract/fixtures/wire/config-s2c-0e-update-tags.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client every Registry Data fixture decodes; dimension types surface "
         & "(0..256, sky) and sunless (0..128, no sky) and 3 biomes are kept" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE RG-REGISTRIES TO WS-EDIT
     MOVE RG-DIM-COUNT TO WS-EDIT2
     MOVE RG-BIOMES TO WS-EDIT3
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " "
         FUNCTION TRIM(RG-DIM-NAME(1)) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE RG-DIM-HEIGHT(1) TO WS-EDIT
     MOVE RG-DIM-HEIGHT(2) TO WS-EDIT2
     MOVE RG-DIM-MIN-Y(2) TO WS-EDIT3
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " RG-DIM-HAS-SKY(1) " "
         FUNCTION TRIM(RG-DIM-NAME(2)) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " "
         RG-DIM-HAS-SKY(2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "18 2 3 cobolcraft:surface 256 1 cobolcraft:sunless 128 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/config-s2c-04-keep-alive.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client configuration Keep Alive is echoed as config-c2s-04-keep-alive.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-04-keep-alive.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client Finish Configuration is answered with config-c2s-03-finish-"
         & "configuration.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract wire client after Finish Configuration the connection is in play" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE PH-PLAY TO TL-EXPECTED-N
     MOVE CN-PHASE(WS-CONN) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

*>   ---- play: builders ----
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ACCEPT-TELEPORT" USING PB-BUFFER WS-TID WS-X WS-Y WS-Z WS-YAW WS-PITCH
     MOVE "contract wire client Accept Teleportation equals play-c2s-00-accept-teleportation.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-00-accept-teleportation.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-BATCH-RECEIVED" USING PB-BUFFER WS-RATE
     MOVE "contract wire client Chunk Batch Received equals play-c2s-0b-chunk-batch-received.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 44 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-SIMPLE" USING PB-BUFFER WS-ID
     MOVE "contract wire client Player Loaded equals play-c2s-2c-player-loaded.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2c-player-loaded.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 13 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-SIMPLE" USING PB-BUFFER WS-ID
     MOVE "contract wire client Client Tick End equals play-c2s-0d-client-tick-end.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0d-client-tick-end.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   ---- play: decoding the join sequence ----
     MOVE "contract/fixtures/wire/play-s2c-32-login-main.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Login decodes: entity 1, view distance 8, cobolcraft:main of type "
         & "0 (height 256 from the registry), survival; the world screen" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-ENTITY-ID TO WS-EDIT
     MOVE PL-VIEW-DISTANCE TO WS-EDIT2
     MOVE PL-HEIGHT TO WS-EDIT3
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(PL-DIM-NAME) " "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-MODE TO WS-EDIT
     MOVE SM-SCREEN TO WS-EDIT2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 8 cobolcraft:main 256 0 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO PL-MODE
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-03-game-mode.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Game Event 3 decodes to game mode 0 (survival)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-MODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-13-wait-chunks.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-49-player-position.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client Player Position (after Game Event 13) is accepted with "
         & "play-c2s-00-accept-teleportation.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-00-accept-teleportation.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract wire client Player Position decodes to (4.5, 54, 8.5), yaw -90, pitch 0"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT = PL-X * 10
     COMPUTE WS-EDIT2 = PL-Y * 10
     COMPUTE WS-EDIT3 = PL-Z * 10
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT = PL-YAW
     COMPUTE WS-EDIT2 = PL-PITCH
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "45 540 85 -90 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN

     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-survival.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-63-set-default-spawn-position.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-73-set-time.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client abilities (walk 0.1), spawn (4, 54, 8), Set Time 6000, held slot "
         & "0 and the starting inventory decode" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT = PL-WALK-SPEED * 100
     MOVE PL-SPAWN-Y TO WS-EDIT2
     MOVE PL-TIME TO WS-EDIT3
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-HELD TO WS-EDIT
     MOVE PL-SLOT-COUNT(1) TO WS-EDIT2
     MOVE PL-SLOT-ITEM(10) TO WS-EDIT3
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2)
         " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "10 54 6000 0 64 11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-6e-set-player-inventory.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Set Player Inventory decodes: slot 0 holds 63 greystone" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6302 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-SLOT-COUNT(1) * 100 + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-0c-chunk-batch-start.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Level Chunk With Light decodes into the replica: the marker "
         & "glowtube at (8, 59, 8) with block light 15, turf at (4, 53, 8), above it sky light 15 and "
         & "block light 15 - 9 (standin §5.2 policy)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 8 TO WS-CX
     MOVE 59 TO WS-CY
     MOVE 8 TO WS-CZ
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE 4 TO WS-CX
     MOVE 53 TO WS-CY
     MOVE 8 TO WS-CZ
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE 4 TO WS-CX
     MOVE 54 TO WS-CY
     MOVE 8 TO WS-CZ
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE "13/0/15 4/0/0 0/15/6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-0b-chunk-batch-finished.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client Chunk Batch Finished is answered with play-c2s-0b-chunk-batch-"
         & "received.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 2 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client after the first batch and the position Player Loaded is sent "
         & "(play-c2s-2c-player-loaded.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2c-player-loaded.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-CLEAR-SENT" USING CLIENT-STATE WS-CONN
     MOVE "contract/fixtures/wire/play-s2c-2d-keep-alive.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-INDEX
     CALL "TEST-SENT" USING CLIENT-STATE WS-CONN WS-INDEX PB-BUFFER WS-FOUND
     MOVE "contract wire client play Keep Alive is echoed as play-c2s-1c-keep-alive.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1c-keep-alive.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   ---- play, moving and other players (US3): builders ----
     MOVE 30 TO WS-ID
     MOVE 1 TO WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MOVE" USING PB-BUFFER WS-ID WS-MX WS-MY WS-MZ WS-MYAW WS-MPITCH WS-FLAGS
     MOVE "contract wire client Move Player Pos ((5.25, 54, 8.5), on ground) equals "
         & "play-c2s-1e-move-player-pos.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1e-move-player-pos.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 31 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MOVE" USING PB-BUFFER WS-ID WS-MX WS-MY WS-MZ WS-MYAW WS-MPITCH WS-FLAGS
     MOVE "contract wire client Move Player Pos Rot (yaw 45, pitch 30) equals "
         & "play-c2s-1f-move-player-pos-rot.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1f-move-player-pos-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 32 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MOVE" USING PB-BUFFER WS-ID WS-MX WS-MY WS-MZ WS-MYAW WS-MPITCH WS-FLAGS
     MOVE "contract wire client Move Player Rot equals play-c2s-20-move-player-rot.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-20-move-player-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 33 TO WS-ID
     MOVE 3 TO WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-MOVE" USING PB-BUFFER WS-ID WS-MX WS-MY WS-MZ WS-MYAW WS-MPITCH WS-FLAGS
     MOVE "contract wire client Move Player Status Only (on ground, horizontal collision) equals "
         & "play-c2s-21-move-player-status-only.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-21-move-player-status-only.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 2 TO WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ABILITIES" USING PB-BUFFER WS-FLAGS
     MOVE "contract wire client Player Abilities (flying) equals play-c2s-28-player-abilities.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-28-player-abilities.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   ---- play, moving and other players (US3): decoding ----
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-47-player-info-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-EID
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-EID WS-ROW
     MOVE SPACES TO WS-NAME-OUT
     MOVE 0 TO WS-NAME-OUT-LENGTH
     IF WS-ROW > 0
         CALL "ENTITY-NAME" USING CLIENT-STATE WS-ROW WS-NAME-OUT WS-NAME-OUT-LENGTH
     END-IF
     MOVE "contract wire client Add Entity (operator) decodes to entity 1, type 0 at (4.5, 54, "
         & "8.5), pitch 0, yaw and head yaw -90, and Player Info Update names its UUID Alice"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     STRING FUNCTION TRIM(TL-OBSERVED) " " WS-NAME-OUT(1:WS-NAME-OUT-LENGTH) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "1 0 4.5000/54.0000/8.5000 -90.0/0.0/-90.0 0 Alice" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-46-player-info-remove.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO WS-NAME-OUT-LENGTH
     CALL "ENTITY-NAME" USING CLIENT-STATE WS-ROW WS-NAME-OUT WS-NAME-OUT-LENGTH
     MOVE "contract wire client Player Info Remove removes Alice from the player list" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NAME-OUT-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-36-move-entity-pos.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 20 TO WS-EID
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract/fixtures/wire/play-s2c-37-move-entity-pos-rot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract/fixtures/wire/play-s2c-39-move-entity-rot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract/fixtures/wire/play-s2c-55-rotate-head.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract wire client Move Entity Pos, Pos Rot and Rot and Rotate Head decode against "
         & "the sodgrazer added at (12.5, 56, 3.5) facing 90: x + 256/4096, then z - 256/4096 with yaw "
         & "-180, then yaw -90, then head yaw -90" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "20 2 12.5625/56.0000/3.5000 90.0/0.0/90.0 1 20 2 12.5625/56.0000/3.4375 -180.0/0.0/"
         & "90.0 1 20 2 12.5625/56.0000/3.4375 -90.0/0.0/90.0 1 20 2 12.5625/56.0000/3.4375 "
         & "-90.0/0.0/-90.0 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-80-teleport-entity.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-EID
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract wire client Teleport Entity decodes: entity 1 at (100.5, 70, -20.5), yaw -90, "
         & "pitch 0, not on the ground" TO TL-CASE
     MOVE "1 0 100.5000/70.0000/-20.5000 -90.0/0.0/-90.0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-loose-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-abend.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-4e-remove-entities.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Remove Entities decodes: entities 10 and 21 are removed, 1 and 20 "
         & "remain" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 10 TO WS-EID
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE 21 TO WS-EID
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE 1 TO WS-EID
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-EID WS-ROW
     MOVE 20 TO WS-EID
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-EID WS-INDEX
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION CHAR(FUNCTION MIN(WS-ROW, 1) + 49)
         FUNCTION CHAR(FUNCTION MIN(WS-INDEX, 1) + 49) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "10 none 21 none 11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -9 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE "contract/fixtures/wire/play-s2c-26-forget-level-chunk.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE "contract/fixtures/wire/play-s2c-60-set-chunk-cache-center.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Forget Level Chunk decodes to chunk (-9, 3), which leaves the "
         & "replica; Set Chunk Cache Center decodes to (-1, 2)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-ROW TO WS-EDIT
     MOVE PL-CENTER-CX TO WS-EDIT2
     MOVE PL-CENTER-CZ TO WS-EDIT3
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 -1 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-WIRE-CLIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CELL.
*> USING CLIENT-STATE, x, y, z, text (appended): "<state>/<sky>/<block>" of the replica cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-E1                  PIC Z9.
 01 WS-E2                  PIC Z9.
 01 WS-E3                  PIC Z9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-TEXT.
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E1
     MOVE WS-SKY TO WS-E2
     MOVE WS-BLOCK TO WS-E3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/"
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-CELL.
 COPY CLTEST.
