*> Contract test, the client side of the wire profile (contracts/proto-api.md §4; wire-profile.md
*> §3; docs/protocol/09-cobolcraft-profile.md): every serverbound fixture the client sends in
*> status, login, configuration and the play join equals what the client's builders (or its
*> replies) produce for the fixture's stated inputs, and every clientbound fixture of those phases
*> decodes to the stated values; then the play packets of moving and of other players (US3), and of
*> breaking, placing, the hotbar and the inventory (US4), of ground items and throwing (US5), and
*> of chat (US6), of health and attacking (US7), of eating and sprinting (US8), of crafting
*> (US10), the weather Game Events (US11), and of commands and the game mode change (US14).
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
 01 WS-J                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-GI-ID               BINARY-LONG.
 01 WS-GI-COUNT            BINARY-LONG.
 01 WS-GI-ITEM             BINARY-LONG.
 01 WS-GI-X                FLOAT-LONG VALUE 1.5.
 01 WS-GI-Y                FLOAT-LONG VALUE 54.0.
 01 WS-GI-Z                FLOAT-LONG VALUE 1.5.
 01 WS-BX                  BINARY-LONG VALUE 4.
 01 WS-BY                  BINARY-LONG VALUE 53.
 01 WS-BZ                  BINARY-LONG VALUE 8.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-HX                  FLOAT-SHORT VALUE 0.5.
 01 WS-HY                  FLOAT-SHORT VALUE 1.0.
 01 WS-HZ                  FLOAT-SHORT VALUE 0.5.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-ITEM2               BINARY-LONG.
 01 WS-CHAT                PIC X(1024) VALUE "hello".
 01 WS-CHAT-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CHAT-TIME           BINARY-DOUBLE VALUE 1700000000000.
 01 WS-EVENT               BINARY-LONG.
 01 WS-LEVEL               FLOAT-SHORT.
 01 WS-RAIN-EDIT           PIC 9.9.
 01 WS-THUNDER-EDIT        PIC 9.9.
 01 WS-NODE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CMD                 PIC X(1024).
 01 WS-CMD-LENGTH          BINARY-LONG.
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
     MOVE "contract wire client Login (extra dimensions off) keeps its one dimension name"
         TO TL-CASE
     PERFORM LEVELS-TEXT
     MOVE "1 cobolcraft:main" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-32-login-all-dimensions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Login (all dimensions) decodes every dimension name: "
         & "cobolcraft:main and cobolcraft:subroutine; it enters cobolcraft:main" TO TL-CASE
     PERFORM LEVELS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " in " FUNCTION TRIM(PL-DIM-NAME) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "2 cobolcraft:main cobolcraft:subroutine in cobolcraft:main" TO TL-EXPECTED
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
     MOVE 20 TO WS-EID
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract wire client Add Entity (sodgrazer) decodes to entity 20 of entity type 2 "
         & "(cobolcraft:sodgrazer, standin §3) at (12.5, 56, 3.5), yaw and head yaw 90" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "20 2 12.5000/56.0000/3.5000 90.0/0.0/90.0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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
     MOVE 21 TO WS-EID
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-EID TL-OBSERVED
     MOVE "contract wire client Add Entity (abend) decodes to entity 21 of entity type 3 "
         & "(cobolcraft:abend, standin §3) at (-3.5, 52, -6.5), yaw and head yaw -180" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "21 3 -3.5000/52.0000/-6.5000 -180.0/0.0/-180.0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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
*>   ---- play, breaking, placing, hotbar and inventory (US4): builders ----
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1
                 MOVE 0 TO WS-ACTION
                 MOVE 1 TO WS-SEQ
                 MOVE "contract/fixtures/wire/play-c2s-29-player-action-start-destroy.hex"
                     TO WS-PATH
             WHEN 2
                 MOVE 2 TO WS-ACTION
                 MOVE 2 TO WS-SEQ
                 MOVE "contract/fixtures/wire/play-c2s-29-player-action-abort-destroy.hex"
                     TO WS-PATH
             WHEN OTHER
                 MOVE 3 TO WS-ACTION
                 MOVE 3 TO WS-SEQ
                 MOVE "contract/fixtures/wire/play-c2s-29-player-action-stop-destroy.hex"
                     TO WS-PATH
         END-EVALUATE
         CALL "PB-RESET" USING PB-BUFFER
         CALL "CLP-PLAYER-ACTION" USING PB-BUFFER WS-ACTION WS-BX WS-BY WS-BZ WS-FACE WS-SEQ
         MOVE SPACES TO TL-CASE
         STRING "contract wire client Player Action " FUNCTION CHAR(WS-ACTION + 49)
             " ((4, 53, 8), up) equals " FUNCTION TRIM(WS-PATH(24:)) DELIMITED BY SIZE
             INTO TL-CASE
         CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     END-PERFORM
     MOVE 4 TO WS-SEQ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-USE-ITEM-ON" USING PB-BUFFER WS-BX WS-BY WS-BZ WS-FACE WS-HX WS-HY WS-HZ WS-SEQ
     MOVE "contract wire client Use Item On ((4, 53, 8), up, cursor (0.5, 1, 0.5), sequence 4) "
         & "equals play-c2s-42-use-item-on.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-42-use-item-on.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 3 TO WS-SLOT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-SET-CARRIED" USING PB-BUFFER WS-SLOT
     MOVE "contract wire client Set Carried Item (slot 3) equals play-c2s-36-set-carried-item.hex"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-36-set-carried-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 1 TO WS-STATE
     MOVE 0 TO WS-SLOT WS-COUNT WS-ITEM
     MOVE 64 TO WS-COUNT2
     MOVE 2 TO WS-ITEM2
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CONTAINER-CLICK" USING PB-BUFFER WS-STATE WS-SLOT WS-COUNT WS-ITEM WS-COUNT2
         WS-ITEM2
     MOVE "contract wire client Container Click (state 1, left pickup of slot 0: slot 0 empty, "
         & "64 greystone carried) equals play-c2s-12-container-click.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-12-container-click.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 9 TO WS-SLOT
     MOVE 64 TO WS-COUNT
     MOVE 7 TO WS-ITEM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CREATIVE-SLOT" USING PB-BUFFER WS-SLOT WS-COUNT WS-ITEM
     MOVE "contract wire client Set Creative Mode Slot (slot 9, 64 lucite) equals "
         & "play-c2s-39-set-creative-mode-slot.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-39-set-creative-mode-slot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   ---- play, breaking, placing, hotbar and inventory (US4): decoding (the spawn chunk (0, 0)
*>   is still in the replica) ----
     MOVE "contract/fixtures/wire/play-s2c-08-block-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Block Update decodes: (8, 59, 8) becomes state 14 (glowtube "
         & "lit=false) in the replica" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 8 TO WS-CX
     MOVE 59 TO WS-CY
     MOVE 8 TO WS-CZ
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE TL-OBSERVED(1:3) TO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "14/" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-31-light-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Light Update decodes: block light of sections Y 3 and Y 4 of chunk "
         & "(0, 0) is cleared, sky light kept" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 8 TO WS-CX
     MOVE 59 TO WS-CY
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE 4 TO WS-CX
     MOVE 54 TO WS-CY
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE "14/0/0 0/15/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-56-section-blocks-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Section Blocks Update decodes: section (0, 3, 0) changes (9, 55, "
         & "8) to 15 and (8, 60, 8) to 11" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 9 TO WS-CX
     MOVE 55 TO WS-CY
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE 8 TO WS-CX
     MOVE 60 TO WS-CY
     CALL "TEST-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ TL-OBSERVED
     MOVE "15/15/0 11/15/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-04-block-changed-ack.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-05-block-destruction.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Block Changed Ack decodes to sequence 7; Block Destruction to "
         & "breaker 1, (5, 53, 8), progress 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 71553083 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CT-ACK * 10000000 + BD-ENTITY * 1000000 + BD-X * 100000
         + BD-Y * 1000 + BD-Z * 10 + BD-PROGRESS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PL-CARRIED-COUNT
     MOVE 3 TO PL-CARRIED-ITEM
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Container Set Content decodes: state id 1, slot 8 one pry_bar, slot "
         & "10 empty, the cursor empty" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-INV-STATE-ID TO WS-EDIT
     COMPUTE WS-EDIT2 = PL-SLOT-COUNT(9) * 100 + PL-SLOT-ITEM(9)
     COMPUTE WS-EDIT3 = PL-SLOT-COUNT(11) * 100 + PL-SLOT-ITEM(11)
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-EDIT = PL-CARRIED-COUNT * 100 + PL-CARRIED-ITEM
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "1 110 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-14-container-set-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Container Set Slot decodes: state id 2, slot 0 holds 63 greystone"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 26302 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-INV-STATE-ID * 10000 + PL-SLOT-COUNT(1) * 100 + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO PL-HELD
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE "contract/fixtures/wire/play-s2c-6e-set-player-inventory.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Set Held Slot decodes to slot 0 and Set Player Inventory to 63 "
         & "greystone in slot 0" TO TL-CASE
     MOVE 6302 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-HELD * 10000 + PL-SLOT-COUNT(1) * 100 + PL-SLOT-ITEM(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, ground items and throwing (US5) ----
     MOVE 5 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ITEM-ACTION" USING PB-BUFFER WS-ACTION
     MOVE "contract wire client Player Action 5 drop item equals "
         & "play-c2s-29-player-action-drop-item.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-drop-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 4 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ITEM-ACTION" USING PB-BUFFER WS-ACTION
     MOVE "contract wire client Player Action 4 drop all items equals "
         & "play-c2s-29-player-action-drop-all-items.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-drop-all-items.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-loose-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-65-set-entity-data-item.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Add Entity (loose_item) and Set Entity Data (item) decode: entity "
         & "10 of type 1 at (5.5, 53.25, 8.5), motion 0, holding 1 turf (item 4)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 10 TO WS-GI-ID
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-GI-ID TL-OBSERVED
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-GI-ID TL-OBSERVED
     MOVE "10 1 5.5000/53.2500/8.5000 0.0/0.0/0.0 0 10 1x4 0.0000/0.0000/0.0000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-GI-ID
     MOVE 1 TO WS-GI-COUNT
     MOVE 2 TO WS-GI-ITEM
     CALL "TEST-ADD-ITEM" USING CLIENT-STATE WS-CONN WS-GI-ID WS-GI-X WS-GI-Y WS-GI-Z
         WS-GI-COUNT WS-GI-ITEM
     MOVE "contract/fixtures/wire/play-s2c-67-set-entity-motion.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Set Entity Motion decodes: entity 11 moves (0.25, 0.12, 0) blocks "
         & "per tick (within the LpVec3 step)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-GI-ID TL-OBSERVED
     MOVE "11 1x2 0.2500/0.1200/0.0000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-7f-take-item-entity.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Take Item Entity decodes: entity 1 takes the 1 item of entity 10, "
         & "which leaves the replica; entity 11 stays" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 10 TO WS-GI-ID
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-GI-ID TL-OBSERVED
     MOVE 11 TO WS-GI-ID
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-GI-ID TL-OBSERVED
     MOVE "10 none 11 1x2 0.2500/0.1200/0.0000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, chat (US6) ----
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CHAT" USING PB-BUFFER WS-CHAT WS-CHAT-LENGTH WS-CHAT-TIME
     MOVE "contract wire client Chat (hello, timestamp 1700000000000, no signature) equals "
         & "play-c2s-09-chat.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-09-chat.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-chat.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-command-feedback.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-death.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client System Chat decodes: the literal player chat, the translated "
         & "command feedback and death message, in order, into the chat history" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CH-COUNT
         MOVE CH-LENGTH(WS-I) TO WS-COUNT
         STRING "|" CH-TEXT(WS-I)(1:WS-COUNT) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-INDEX
     END-PERFORM
     MOVE "|<Alice> hello|Alice now holds operator status|Alice misjudged the drop"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, health, damage, death and attacking (US7) ----
     MOVE 21 TO WS-EID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ATTACK" USING PB-BUFFER WS-EID
     MOVE "contract wire client Attack (entity 21) equals play-c2s-01-attack.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-01-attack.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 0 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CLIENT-COMMAND" USING PB-BUFFER WS-ACTION
     MOVE "contract wire client Client Command (action 0 PERFORM_RESPAWN) equals "
         & "play-c2s-0c-client-command-respawn.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0c-client-command-respawn.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 0 TO PL-FOOD
     MOVE 0 TO PL-HEALTH
     MOVE "contract/fixtures/wire/play-s2c-6a-set-health.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Set Health decodes: health 30, food 24" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-EDIT ROUNDED = PL-HEALTH
     MOVE PL-FOOD TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "30 24" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PL-HURT-UNTIL
     MOVE "contract/fixtures/wire/play-s2c-19-damage-event.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Damage Event decodes: entity 1, the local player, was hurt (the "
         & "hurt indication runs)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HURT-UNTIL > CL-NOW-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-HURT-UNTIL
     MOVE "contract/fixtures/wire/play-s2c-2b-hurt-animation.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Hurt Animation decodes: entity 1, the local player, was hurt (the "
         & "hurt indication runs)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HURT-UNTIL > CL-NOW-MS
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-45-player-combat-kill.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Player Combat Kill decodes: player 1 died, the death screen shows "
         & "the translated message" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-EDIT
     MOVE SM-DEATH-CAUSE-LENGTH TO WS-COUNT
     STRING FUNCTION TRIM(WS-EDIT) " " SM-DEATH-CAUSE(1:WS-COUNT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "10 Alice was halted by an Abend" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Respawn decodes: cobolcraft:subroutine of type 1 (no sky light, "
         & "y 0 to 127, from the registry), survival; the world screen" TO TL-CASE
     PERFORM RESPAWN-TEXT
     MOVE "cobolcraft:subroutine 1 0 0 5 0/128" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Respawn decodes: cobolcraft:main of type 0 (sky light, y 0 to "
         & "255), survival; the world screen" TO TL-CASE
     PERFORM RESPAWN-TEXT
     MOVE "cobolcraft:main 0 1 0 5 0/256" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, eating and sprinting (US8) ----
     MOVE 5 TO WS-SEQ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-USE-ITEM" USING PB-BUFFER WS-SEQ WS-YAW WS-PITCH
     MOVE "contract wire client Use Item (main hand, sequence 5, yaw -90, pitch 0) equals "
         & "play-c2s-43-use-item.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-43-use-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 6 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-ITEM-ACTION" USING PB-BUFFER WS-ACTION
     MOVE "contract wire client Player Action 6 release use item equals "
         & "play-c2s-29-player-action-release-use-item.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-release-use-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 1 TO WS-EID
     MOVE 1 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLAYER-COMMAND" USING PB-BUFFER WS-EID WS-ACTION
     MOVE "contract wire client Player Command 1 start sprinting (entity 1, data 0) equals "
         & "play-c2s-2a-player-command-start-sprinting.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2a-player-command-start-sprinting.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE 2 TO WS-ACTION
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLAYER-COMMAND" USING PB-BUFFER WS-EID WS-ACTION
     MOVE "contract wire client Player Command 2 stop sprinting (entity 1, data 0) equals "
         & "play-c2s-2a-player-command-stop-sprinting.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2a-player-command-stop-sprinting.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 1 TO PL-ENTITY-ID
     MOVE 1 TO PL-EATING
     MOVE "contract/fixtures/wire/play-s2c-22-entity-event-eating-finished.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Entity Event decodes: entity 1, the local player, event 9 eating "
         & "finished (the client stops eating)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-EATING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PL-ENTITY-ID
     MOVE 1 TO PL-EATING
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Entity Event decodes: entity 1 is another player here, so the local "
         & "player goes on eating" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-EATING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, crafting (US10) ----
     MOVE 0 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PLACE-RECIPE" USING PB-BUFFER WS-ID
     MOVE "contract wire client Place Recipe (container 0, display id 0, use max items false) "
         & "equals play-c2s-27-place-recipe.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-27-place-recipe.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-4b-recipe-book-add.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Recipe Book Add decodes every standin §13 recipe (display id, "
         & "ingredients, result) with its craftable flag: requirements present only for 0"
         TO TL-CASE
     PERFORM RECIPES-TEXT
     MOVE "9 0:4x2>2x9:1 1:4x5>2x7:0 2:3x2+1x6>1x10:0 3:2x2+1x6>1x11:0 4:1x7+1x15>2x8:0 "
         & "5:4x4+1x3>1x14:0 6:2x12+1x8>2x13:0 7:4x9+2x15+1x8>1x16:0 8:2x6+2x7>1x15:0"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Recipe Book Add with Replace true replaces the recipe book (the "
         & "same nine recipes again, not eighteen)" TO TL-CASE
     PERFORM RECIPES-TEXT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, weather (US11; standin §14.1, §14.4; 09 §3.3 weather values) ----
*>   Hailstorm: 1 (0.0), 7 (1.0), 8 (1.0), all three from their fixtures.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-08-thunder-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Game Events 1, 7 (1.0) and 8 (1.0) from their fixtures decode to "
         & "the pair (1.0, 1.0): cobolcraft:hailstorm" TO TL-CASE
     PERFORM WEATHER-TEXT
     MOVE "rain 1.0 thunder 1.0 kind 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Clear: 2 (0.0) from its fixture; then 7 and 8 with 0.0.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-02-stop-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 0 TO WS-LEVEL
     MOVE 7 TO WS-EVENT
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     MOVE 8 TO WS-EVENT
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     MOVE "contract wire client Game Events 2 (from its fixture), 7 (0.0) and 8 (0.0) decode to "
         & "the pair (0.0, 0.0): cobolcraft:clear" TO TL-CASE
     PERFORM WEATHER-TEXT
     MOVE "rain 0.0 thunder 0.0 kind 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drizzle: 1 and 7 (1.0) from their fixtures, 8 with 0.0.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 8 TO WS-EVENT
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     MOVE "contract wire client Game Events 1, 7 (1.0) and 8 (0.0) decode to the pair (1.0, 0.0): "
         & "cobolcraft:drizzle" TO TL-CASE
     PERFORM WEATHER-TEXT
     MOVE "rain 1.0 thunder 0.0 kind 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Event 2 alone stops the rain: (0.0, 0.0) whatever came before.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-02-stop-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Game Event 2 (from its fixture) after drizzle decodes to "
         & "cobolcraft:clear" TO TL-CASE
     PERFORM WEATHER-TEXT
     MOVE "rain 0.0 thunder 0.0 kind 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- play, commands (US14; 09 §3.3 Commands, Command Suggestion(s), Chat Command) ----
     MOVE "/murmur Al" TO WS-CMD
     MOVE 10 TO WS-CMD-LENGTH
     MOVE 1 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-COMMAND-SUGGESTION" USING PB-BUFFER WS-ID WS-CMD WS-CMD-LENGTH
     MOVE "contract wire client Command Suggestion (transaction 1, /murmur Al) equals "
         & "play-c2s-0f-command-suggestion.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0f-command-suggestion.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "promote Alice" TO WS-CMD
     MOVE 13 TO WS-CMD-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CHAT-COMMAND" USING PB-BUFFER WS-CMD WS-CMD-LENGTH
     MOVE "contract wire client Chat Command (promote Alice, no leading slash) equals "
         & "play-c2s-07-chat-command.hex" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-07-chat-command.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Commands (everyone) decodes the 6-node tree: each node's name, "
         & "flags and children, the greedy message argument, root 0" TO TL-CASE
     PERFORM COMMANDS-TEXT
     MOVE "6 root 0 :0>1,2,3 howto:5 roster:5 murmur:1>4 player:18>5 message:6*" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Commands (operator) decodes the 90-node tree (replacing the "
         & "last): the root's 24 commands in standin §16.2 order" TO TL-CASE
     PERFORM ROOT-TEXT
     MOVE "90 root 0 howto roster murmur promote demote eject bar unbar barlist guestlist mode "
         & "relocate supply empty vitality ration conjure sweep clock skies homestead announce "
         & "persist shutdown" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract wire client Commands (operator) decodes the relocate subtree: player, then "
         & "at x y z (dimension) and to target" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-NODE FROM 31 BY 1 UNTIL WS-NODE > 39
         MOVE SPACES TO WS-TEXT
         PERFORM NODE-TEXT
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     MOVE "player:18>32,37 at:1>33 x:2>34 y:2>35 z:6>36 dimension:22 to:1>38 target:22 "
         & "supply:1>40" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO CS-TRANSACTION
     MOVE "contract/fixtures/wire/play-s2c-0f-command-suggestions.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Command Suggestions decodes the answer to transaction 1: one "
         & "suggestion Alice" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CS-ANSWERS TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " CS-A-TEXT(1)(1:5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 Alice" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ---- play, game mode (US14-2 set-mode; 09 §3.2 Game Event 3: 0.0 survival, 1.0 creative) ----
     MOVE 3 TO WS-EVENT
     MOVE 1.0 TO WS-LEVEL
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     MOVE "contract wire client Game Event 3 with 1.0 decodes to creative: may fly (abilities "
         & "0x0D as the server's creative Player Abilities)" TO TL-CASE
     PERFORM MODE-TEXT
     MOVE "mode 1 abilities 13 flying 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-FLYING
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-03-game-mode.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract wire client Game Event 3 (play-s2c-27-game-event-03-game-mode.hex, 0.0) "
         & "decodes to survival: no abilities, flying ends" TO TL-CASE
     PERFORM MODE-TEXT
     MOVE "mode 0 abilities 0 flying 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COMMANDS-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE CM-COUNT TO WS-EDIT
     MOVE CM-ROOT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " root " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     PERFORM VARYING WS-NODE FROM 0 BY 1 UNTIL WS-NODE >= CM-COUNT
         MOVE SPACES TO WS-TEXT
         PERFORM NODE-TEXT
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     .

*> WS-TEXT (spaces) gets "<name>:<flags>[><child>,...][*]" of node WS-NODE (* = greedy).
 NODE-TEXT.
     MOVE 1 TO WS-INDEX
     COMPUTE WS-ROW = WS-NODE + 1
     MOVE CM-NAME-LENGTH(WS-ROW) TO WS-K
     IF WS-K > 0
         STRING CM-NAME(WS-ROW)(1:WS-K) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
     END-IF
     MOVE CM-FLAGS(WS-ROW) TO WS-EDIT
     STRING ":" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CM-CHILDREN(WS-ROW)
         IF WS-J = 1
             STRING ">" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
         ELSE
             STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
         END-IF
         COMPUTE WS-K = CM-FIRST(WS-ROW) + WS-J - 1
         MOVE CM-LINK(WS-K) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
     END-PERFORM
     IF CM-GREEDY(WS-ROW) = 1
         STRING "*" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-INDEX
     END-IF
     .

 ROOT-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE CM-COUNT TO WS-EDIT
     MOVE CM-ROOT TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " root " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     COMPUTE WS-ROW = CM-ROOT + 1
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > CM-CHILDREN(WS-ROW)
         COMPUTE WS-K = CM-FIRST(WS-ROW) + WS-J - 1
         COMPUTE WS-NODE = CM-LINK(WS-K) + 1
         MOVE CM-NAME-LENGTH(WS-NODE) TO WS-K
         STRING FUNCTION TRIM(TL-OBSERVED) " " CM-NAME(WS-NODE)(1:WS-K) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     .

 MODE-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-MODE TO WS-EDIT
     MOVE PL-ABILITIES TO WS-EDIT2
     STRING "mode " FUNCTION TRIM(WS-EDIT) " abilities " FUNCTION TRIM(WS-EDIT2) " flying "
         PL-FLYING DELIMITED BY SIZE INTO TL-OBSERVED
     .

 RECIPES-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-INDEX
     MOVE RB-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RB-COUNT
         MOVE RB-ID(WS-I) TO WS-EDIT
         STRING " " FUNCTION TRIM(WS-EDIT) ":" DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-INDEX
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RB-IN-COUNT(WS-I)
             IF WS-J > 1
                 STRING "+" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-INDEX
             END-IF
             MOVE RB-IN-AMOUNT(WS-I, WS-J) TO WS-EDIT
             MOVE RB-IN-ITEM(WS-I, WS-J) TO WS-EDIT2
             STRING FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-INDEX
         END-PERFORM
         MOVE RB-RES-AMOUNT(WS-I) TO WS-EDIT
         MOVE RB-RES-ITEM(WS-I) TO WS-EDIT2
         STRING ">" FUNCTION TRIM(WS-EDIT) "x" FUNCTION TRIM(WS-EDIT2) ":" RB-CRAFTABLE(WS-I)
             DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-INDEX
     END-PERFORM
     .

 WEATHER-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-RAIN-EDIT ROUNDED = PL-RAIN
     COMPUTE WS-THUNDER-EDIT ROUNDED = PL-THUNDER
     MOVE PL-WEATHER TO WS-EDIT3
     STRING "rain " WS-RAIN-EDIT " thunder " WS-THUNDER-EDIT " kind " FUNCTION TRIM(WS-EDIT3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     .

 RESPAWN-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-DIM-TYPE TO WS-EDIT
     MOVE PL-MODE TO WS-EDIT2
     MOVE SM-SCREEN TO WS-EDIT3
     STRING FUNCTION TRIM(PL-DIM-NAME) " " FUNCTION TRIM(WS-EDIT) " " PL-HAS-SKY " "
         FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-MIN-Y TO WS-EDIT
     MOVE PL-HEIGHT TO WS-EDIT2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     .

 LEVELS-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-LEVEL-COUNT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > PL-LEVEL-COUNT
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(PL-LEVEL(WS-COUNT))
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     .
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
