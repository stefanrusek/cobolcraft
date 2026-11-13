*> Acceptance test of the join while the initial spawn is searched (docs/design/generation-worker.md): a client that has sent Finish Configuration while
*> the world's spawn search runs gets no Login yet (the connection stays in configuration, no player), and joins the tick the search ends, at the spawn
*> the search found. A client that finishes configuration when no search runs joins at once.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-JOIN-HOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-PATH                PIC X(256).
 01 WS-SLEEP               PIC 9V99 VALUE 0.01.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-GEN-FIXTURE"
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     PERFORM CONFIGURE-CLIENT
     MOVE "acceptance gen join given a spawn search in progress when the client finishes configuration then it is still in configuration, its Finish Configuration held back" TO TL-CASE
     MOVE CN-PHASE(WS-CONN) TO TL-OBSERVED-N
     MOVE PH-CONFIG TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL GQ-SP-STATE = 0 OR WS-TICKS > 6000
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
         IF GQ-SP-STATE NOT = 0
             CALL "C$SLEEP" USING WS-SLEEP
         END-IF
     END-PERFORM
     PERFORM FINISH-CLIENT
     MOVE "acceptance gen join given the search ended when the tick released the client then it is in play with a player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF CN-PHASE(WS-CONN) = PH-PLAY AND CN-PLAYER(WS-CONN) > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "acceptance gen join given the search ended when the player joined then it stands at the found spawn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF PL-X(WS-ROW) = CW-SPAWN-X AND PL-Z(WS-ROW) = CW-SPAWN-Z
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a connection that is gone or not held is left alone by the release, and a client with no search joins at once
     CALL "CONFIG-RELEASE-HELD"
     MOVE "acceptance gen join given no search when the client finishes configuration then it joins at once" TO TL-CASE
     PERFORM CONFIGURE-CLIENT
     PERFORM FINISH-CLIENT
     COMPUTE TL-OBSERVED-N = CN-PHASE(WS-CONN) * 100 + FUNCTION MIN(CN-PLAYER(WS-CONN), 1)
     COMPUTE TL-EXPECTED-N = PH-PLAY * 100 + 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FINISH-CLIENT.
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 CONFIGURE-CLIENT.
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-MAX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "PB-FREE" USING PB-BUFFER.
 END PROGRAM ACC-GEN-JOIN-HOLD.
 COPY CORETEST.
 COPY GENFIXTURE.
