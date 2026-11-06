*> Acceptance test US18-7 client half (spec.md User Story 18; 08 §9.1, §9.8; standin-content §17;
*> client/src/packs/download.cob, screens/pack-prompt.cob): declining a required pack sends declined
*> (and nothing else: the client does not disconnect itself); the server's configuration Disconnect
*> with cobolcraft.disconnect.pack_required returns the Player to the server list with the message
*> rendered from its translate key. A saved "never accept" policy declines without asking; an
*> optional pack under it is declined too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US18-REQUIRED-DECLINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-required".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAMES               PIC X(256) VALUE SPACES.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-ACTION              BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-READ                PIC X(1024).
 01 WS-E1                  PIC Z9.
 01 WS-E2                  PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE 1 TO SL-COUNT
     MOVE "Test" TO SL-NAME(1)
     MOVE 4 TO SL-NAME-LENGTH(1)
     MOVE "127.0.0.1" TO SL-ADDR(1)
     MOVE 9 TO SL-ADDR-LENGTH(1)
     MOVE 0 TO SL-POLICY(1)
     MOVE 1 TO RP-ENTRY-JOINED
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE SCR-CONNECTING TO SM-SCREEN
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-required-prompt.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US18-7 Given a server that requires its pack When the Player joins Then the "
         & "prompt says the pack is required" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Server Resource Pack|This server requires a resource pack; declining disconnects you|"
         & "The server says: Please accept the CobolCraft pack|Your answer is kept for this server|"
         & "Accept|Decline" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACK-DECLINE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-READ WS-THRESHOLD
     MOVE "acceptance US18-7 Given the prompt for a required pack When the Player declines Then "
         & "declined is sent, the client stays connected and the answer is kept" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CN-PHASE(WS-CONN) TO WS-E1
     MOVE SL-POLICY(1) TO WS-E2
     STRING FUNCTION TRIM(WS-READ) " phase " FUNCTION TRIM(WS-E1) " policy " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0600112233445566778899aabbccddeeff01 phase 4 policy 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/config-s2c-02-disconnect-pack-required.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance US18-7 Given the declined required pack When the server disconnects the "
         & "Player Then they are back on the server list with the message that the server "
         & "requires its pack" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " SM-MESSAGE(1:SM-MESSAGE-LENGTH) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "2 This server requires its resource pack" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER

*>   Rejoin: the saved "never accept" declines the required pack without asking, and the
*>   optional one too.
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN WS-SERVER
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE SCR-CONNECTING TO SM-SCREEN
     MOVE 1 TO RP-ENTRY-JOINED
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-required-prompt.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-optional.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-READ WS-THRESHOLD
     MOVE "acceptance US18-7 Given the server's packs are never accepted When it pushes a "
         & "required and then an optional pack Then both are declined without a prompt" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(WS-READ) " screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "0600112233445566778899aabbccddeeff01 0600112233445566778899aabbccddeeff01 screen 4"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_net_close" USING BY VALUE WS-SERVER
     STOP RUN.
 END PROGRAM ACC-US18-REQUIRED-DECLINE.
 COPY CLTEST.
 COPY PACKTEST.
